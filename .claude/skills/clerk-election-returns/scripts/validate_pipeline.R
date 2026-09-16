# Validate the clerk-election-returns pipeline on a year CAGE already covers.
#
# Run from the repo root:
#
#   Rscript .claude/skills/clerk-election-returns/scripts/validate_pipeline.R 2024
#
# Runs extract_clerk.py and 00e_skeleton-newyear.R end to end, then scores the
# skeleton against released CAGE on candidate counts, party, name_snyder and
# votes. The name history handed to 00e is cut off before YEAR, so a name can
# only be carried over from an earlier cycle, never copied from the answer.
# Every extracted vote is also re-read from the PDF with poppler (pdftools), an
# engine independent of the pypdf extractor.
#
# Only creates new files: the PDF under data/clerk/, and summary.csv,
# candidates.csv, cage_scope.csv, poppler_check.csv plus the pipeline's own
# outputs under data/clerk/validation/<year>/. No existing file is changed.

library(tidyverse)
library(fs)

YEAR <- as.integer(commandArgs(trailingOnly = TRUE)[[1]])
CAGE_FILE <- "candidates_2006-2024.tab"
CAGE_VERSION <- "4.1"

skill_dir <- path(".claude", "skills", "clerk-election-returns")
pdf_path <- path("data", "clerk", str_glue("{YEAR}election.pdf"))
val_dir <- path("data", "clerk", "validation", YEAR)
clerk_csv <- path(val_dir, str_glue("clerk_raw_{YEAR}.csv"))
report_json <- path(val_dir, str_glue("clerk_report_{YEAR}.json"))
dir_create(val_dir)

norm <- \(x) x |>
  stringi::stri_trans_general("Latin-ASCII") |>
  str_to_upper() |>
  str_replace_all("[^A-Z ]", " ") |>
  str_squish()
surname <- \(x) norm(str_extract(x, "^[^,]+"))
given <- \(x) norm(str_remove(coalesce(str_split_i(x, ",", 2), ""), "\\(.*\\)"))
nickname <- \(x) norm(coalesce(str_extract(x, "(?<=\\()[^)]+"), ""))
race_key <- \(state, office, dist, type) str_c(state, office, if_else(office == "H", as.character(dist), ""), type, sep = "|")

# Run the pipeline ----

if (!file_exists(pdf_path)) {
  download.file(str_glue("https://history.house.gov/Institution/Election-Statistics/{YEAR}election/"),
                pdf_path, mode = "wb")
}

cage <- dataverse::get_dataframe_by_name(
  file = CAGE_FILE,
  dataset = "10.7910/DVN/DGDRDT",
  server = "dataverse.harvard.edu",
  version = CAGE_VERSION,
  .f = \(f) read_tsv(f, show_col_types = FALSE))

write_rds(filter(cage, year < YEAR), path(val_dir, "cage_history.rds"))

status <- system2("python3", c(path(skill_dir, "scripts", "extract_clerk.py"), pdf_path, YEAR,
                               "-o", clerk_csv, "--report", report_json))
stopifnot(status == 0)
status <- system2("Rscript", c("00e_skeleton-newyear.R", YEAR, clerk_csv,
                               path(val_dir, "cage_history.rds"), val_dir))
stopifnot(status == 0)

clerk <- read_csv(clerk_csv, col_types = cols(.default = "c"))
report <- jsonlite::read_json(report_json)
hand <- read_csv(path(val_dir, str_glue("candidates_{YEAR}_hand-entry.csv")), col_types = cols(.default = "c"))

skel <- read_csv(path(val_dir, str_glue("candidates_{YEAR}_skeleton.csv")), col_types = cols(.default = "c")) |>
  mutate(votes = as.numeric(candidatevotes),
         key = race_key(state, office, dist, type))

# Scope: which CAGE rows the automatic path is responsible for ----

# a race with any row on the hand-entry list is a hand-entry race, even if
# some of its rows also went into the skeleton
hand_keys <- hand |>
  transmute(key = race_key(state_abb, office, dist, if_else(is.na(unexpired_term_ending), "G", "S"))) |>
  distinct() |>
  pull(key)

cage_scope <- cage |>
  filter(year == YEAR, office %in% c("H", "S")) |>
  mutate(key = race_key(state, office, dist, type),
         votes = candidatevotes,
         scope = case_when(
           office == "H" & type == "S" ~ "House special (not printed in volume)",
           key %in% hand_keys ~ "Hand-entry worklist",
           runoff %in% 1 & key %in% skel$key ~ "Runoff race sent to skeleton",
           runoff %in% 1 ~ "Runoff round (not printed in volume)",
           key %in% skel$key ~ "Automatic",
           .default = "Race missing from extraction"
         ))

count(cage_scope, scope)

# Match candidates within race ----

match_on <- function(pairs, pipe, truth, col, how) {
  p <- pipe |>
    filter(!pid %in% pairs$pid, !is.na(.data[[col]])) |>
    filter(n() == 1, .by = all_of(c("key", col)))
  t <- truth |>
    filter(!cid %in% pairs$cid, !is.na(.data[[col]])) |>
    filter(n() == 1, .by = all_of(c("key", col)))
  m <- inner_join(select(p, key, all_of(col), pid), select(t, key, all_of(col), cid), by = c("key", col)) |>
    transmute(pid, cid, how = how)
  bind_rows(pairs, m)
}

pipe <- skel |>
  filter(!key %in% hand_keys) |>
  mutate(pid = row_number(), sur = surname(name_snyder), sur_last = word(sur, -1))

truth <- cage_scope |>
  filter(scope == "Automatic") |>
  mutate(cid = row_number(), sur = surname(name_snyder), sur_last = word(sur, -1))

# votes come last so that vote agreement is mostly measured on name-matched pairs
pairs <- tibble(pid = integer(), cid = integer(), how = character()) |>
  match_on(pipe, truth, "name_snyder", "exact name") |>
  match_on(pipe, truth, "sur", "surname") |>
  match_on(pipe, truth, "sur_last", "last surname token") |>
  match_on(pipe, truth, "votes", "vote count")

# Score each candidate ----

prior_people <- cage |>
  filter(year < YEAR) |>
  distinct(state, c_name = name_snyder) |>
  mutate(prior = TRUE)
later_people <- cage |>
  filter(year > YEAR) |>
  distinct(state, c_name = name_snyder) |>
  mutate(runs_later = TRUE)

incomplete_races <- report$problems |>
  keep(\(p) str_starts(p$msg, "at least one vote missing")) |>
  map_chr(\(p) race_key(p$race[[1]], p$race[[2]], p$race[[3]] %||% "", "G"))

candidates <- pairs |>
  full_join(select(pipe, pid, key, state, office, dist, name_printed, party_printed, name_snyder,
                   name_source, name_needs_review, party, party_formal, votes, clerk_flags, source_page),
            by = "pid") |>
  full_join(select(truth, cid, c_key = key, c_state = state, c_office = office, c_dist = dist,
                   c_name = name_snyder, c_party = party, c_party_formal = party_formal, c_votes = votes),
            by = "cid") |>
  mutate(key = coalesce(key, c_key),
         state = coalesce(state, c_state),
         office = coalesce(office, c_office),
         dist = coalesce(dist, as.character(c_dist)),
         status = case_when(
           !is.na(pid) & !is.na(cid) ~ "matched",
           is.na(cid) ~ "pipeline only",
           .default = "CAGE only"
         )) |>
  left_join(prior_people, by = c("state", "c_name")) |>
  left_join(later_people, by = c("state", "c_name")) |>
  mutate(
    year = YEAR,
    prior = coalesce(prior, FALSE),
    runs_later = coalesce(runs_later, FALSE),
    name_equal = coalesce(name_snyder == c_name, FALSE),
    name_outcome = case_when(
      status != "matched" ~ NA,
      prior & name_equal ~ "Returning: linked to prior record",
      prior & name_source == "history" ~ "Returning: linked to a different record",
      prior ~ "Returning: link missed (treated as new)",
      name_equal ~ "New: name matches CAGE",
      name_source == "history" ~ "New per CAGE: pipeline linked to a prior record",
      .default = "New: name differs from CAGE"
    ),
    name_diff = case_when(
      status != "matched" | name_equal ~ NA,
      str_remove_all(norm(name_snyder), " ") == str_remove_all(norm(c_name), " ") ~ "punctuation or spacing",
      surname(name_snyder) != surname(c_name) ~ "surname",
      word(given(name_snyder), 1) != word(given(c_name), 1) ~ "first name (e.g. MIKE vs MICHAEL)",
      given(name_snyder) != given(c_name) ~ "middle name or initial",
      nickname(name_snyder) != nickname(c_name) ~ "nickname",
      norm(coalesce(str_split_i(name_snyder, ",", 3), "")) != norm(coalesce(str_split_i(c_name, ",", 3), "")) ~ "suffix",
      .default = "order of name parts"
    ),
    party_equal = coalesce(party == c_party, FALSE),
    party_formal_equal = coalesce(party_formal == c_party_formal, FALSE),
    recap_verified = !str_detect(coalesce(clerk_flags, ""), "UNVERIFIED|MISMATCH") &
      !key %in% incomplete_races,
    vote_outcome = case_when(
      status != "matched" ~ NA,
      is.na(votes) & is.na(c_votes) ~ "both blank",
      is.na(votes) ~ "pipeline blank",
      is.na(c_votes) ~ "CAGE blank",
      votes == c_votes ~ "equal",
      .default = "differ"
    )
  ) |>
  select(-pid, -cid, -c_key, -c_state, -c_office, -c_dist)

# Re-read every vote with poppler ----

page_lines <- tibble(text = pdftools::pdf_text(pdf_path)) |>
  mutate(page = as.character(row_number())) |>
  separate_longer_delim(text, "\n") |>
  mutate(line = row_number(), .by = page) |>
  mutate(text = str_to_upper(stringi::stri_trans_general(text, "Latin-ASCII")))

# a cross-endorsement line sits a few lines under the candidate's own line
poppler_check <- clerk |>
  filter(kind == "candidate", !is.na(candidatevotes)) |>
  mutate(token = word(str_remove(norm(name_printed), " (JR|SR|II|III|IV|V)$"), -1)) |>
  transmute(state_abb, office, dist, page, name_printed, token,
            own = candidatevotes, extra = coalesce(extra_votes, "")) |>
  pivot_longer(c(own, extra), names_to = "line_type", values_to = "votes") |>
  separate_longer_delim(votes, "; ") |>
  filter(votes != "") |>
  mutate(check_id = row_number(),
         printed = format(as.numeric(votes), big.mark = ",", scientific = FALSE, trim = TRUE),
         lo = if_else(line_type == "own", -1, 0),
         hi = if_else(line_type == "own", 1, 4))

name_hits <- poppler_check |>
  inner_join(page_lines, by = "page", relationship = "many-to-many") |>
  filter(str_detect(text, str_c("\\b", token, "\\b"))) |>
  select(check_id, name_line = line)

vote_hits <- poppler_check |>
  inner_join(page_lines, by = "page", relationship = "many-to-many") |>
  filter(str_detect(text, str_c("(?<![0-9,])", printed, "(?![0-9]|,[0-9])"))) |>
  select(check_id, vote_line = line)

confirmed <- inner_join(name_hits, vote_hits, by = "check_id", relationship = "many-to-many") |>
  left_join(select(poppler_check, check_id, lo, hi), by = "check_id") |>
  filter(vote_line - name_line >= lo, vote_line - name_line <= hi) |>
  distinct(check_id)

poppler_check <- poppler_check |>
  mutate(year = YEAR, confirmed = check_id %in% confirmed$check_id)

# Summarise ----

metric <- \(section, name, n, d = NA) tibble(section, metric = name, n = as.numeric(n), d = as.numeric(d))
m <- filter(candidates, status == "matched")
states50 <- filter(clerk, kind == "candidate", office == "H", !state_abb %in% c("DC", "AS", "GU", "PR", "VI", "MP"))

summary <- bind_rows(
  metric("extraction", "races whose printed lines sum to the PDF's recapitulation", report$races_matching_recap, report$races_cross_checked),
  metric("extraction", "ERROR entries in extractor report", sum(map_chr(report$problems, "level") == "ERROR")),
  metric("extraction", "extracted vote figures re-read identically by poppler", sum(poppler_check$confirmed), nrow(poppler_check)),
  metric("extraction", "House districts found (50 states)", nrow(distinct(states50, state_abb, dist)), 435),
  metric("extraction", "rows routed to hand-entry worklist", nrow(filter(hand, kind == "candidate"))),
  metric("counts", "CAGE H/S candidate rows in scope for the automatic path", sum(cage_scope$scope == "Automatic"), nrow(cage_scope)),
  metric("counts", "CAGE in-scope races found in skeleton", n_distinct(truth$key), n_distinct(truth$key)),
  metric("counts", "CAGE in-scope candidates matched to a skeleton row", nrow(m), nrow(truth)),
  metric("counts", "skeleton rows matched to a CAGE candidate", nrow(m), nrow(pipe)),
  metric("counts", "skeleton rows with no CAGE counterpart", sum(candidates$status == "pipeline only")),
  metric("counts", "CAGE rows with no skeleton counterpart", sum(candidates$status == "CAGE only")),
  metric("counts", "skeleton rows in a race that is also on the hand-entry list", sum(skel$key %in% hand_keys)),
  metric("counts", "CAGE races missing from extraction", n_distinct(filter(cage_scope, scope == "Race missing from extraction")$key)),
  metric("counts", "CAGE runoff races sent to skeleton", n_distinct(filter(cage_scope, scope == "Runoff race sent to skeleton")$key)),
  metric("party", "party equal", sum(m$party_equal), nrow(m)),
  metric("party", "party equal where CAGE is D or R", sum(filter(m, c_party %in% c("D", "R"))$party_equal), sum(m$c_party %in% c("D", "R"))),
  metric("party", "D/R candidates given the opposite major party", sum(m$party %in% c("D", "R") & m$c_party %in% c("D", "R") & !m$party_equal)),
  metric("party", "party_formal equal", sum(m$party_formal_equal), nrow(m)),
  metric("names", "name_snyder equal", sum(m$name_equal), nrow(m)),
  metric("names", "name_snyder equal, carried from history", sum(filter(m, name_source == "history")$name_equal), sum(m$name_source == "history")),
  metric("names", "name_snyder equal, reformatted from PDF", sum(filter(m, name_source == "reformatted")$name_equal), sum(m$name_source == "reformatted")),
  metric("names", "returning candidates linked to their prior record", sum(m$name_outcome == "Returning: linked to prior record"), sum(m$prior)),
  metric("names", "returning candidates with link missed", sum(m$name_outcome == "Returning: link missed (treated as new)"), sum(m$prior)),
  metric("names", "candidates linked to a prior record CAGE does not use", sum(str_detect(m$name_outcome, "different record|pipeline linked"))),
  metric("names", "reformatted names that differ from CAGE and are flagged CHECK",
         sum(filter(m, name_source == "reformatted", !name_equal)$name_needs_review == "TRUE"),
         sum(m$name_source == "reformatted" & !m$name_equal)),
  metric("names", "new names that differ from CAGE, person runs again later",
         sum(m$name_outcome == "New: name differs from CAGE" & m$runs_later),
         sum(m$name_outcome == "New: name differs from CAGE")),
  metric("votes", "votes equal", sum(m$vote_outcome == "equal"), sum(m$vote_outcome %in% c("equal", "differ"))),
  metric("votes", "votes equal in recapitulation-verified races",
         sum(filter(m, recap_verified)$vote_outcome == "equal"),
         sum(filter(m, recap_verified)$vote_outcome %in% c("equal", "differ"))),
  metric("votes", "votes blank in skeleton but present in CAGE", sum(m$vote_outcome == "pipeline blank")),
  metric("votes", "votes blank in CAGE but present in skeleton", sum(m$vote_outcome == "CAGE blank"))
) |>
  mutate(year = YEAR, rate = n / d, .before = 1)

message(str_glue("{YEAR}: {nrow(m)}/{nrow(truth)} CAGE candidates matched, ",
                 "party {sum(m$party_equal)}/{nrow(m)}, names {sum(m$name_equal)}/{nrow(m)}, ",
                 "votes {sum(m$vote_outcome == 'equal')}/{sum(m$vote_outcome %in% c('equal', 'differ'))}"))

write_csv(summary, path(val_dir, "summary.csv"), na = "")
write_csv(candidates, path(val_dir, "candidates.csv"), na = "")
write_csv(select(cage_scope, -votes), path(val_dir, "cage_scope.csv"), na = "")
write_csv(poppler_check, path(val_dir, "poppler_check.csv"), na = "")
