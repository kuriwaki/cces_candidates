# Validate the clerk-election-returns pipeline against released CAGE.
#
# Run from the repo root after TASK.md has been executed for a year CAGE already
# covers:
#
#   Rscript .claude/skills/clerk-election-returns/scripts/validate_pipeline.R 2024
#
# Compares the pipeline's data/<year>/candidates_<year>_skeleton.csv and its
# hand-entry list with the CAGE rows for that year, prints the diagnostics and
# writes them to data/clerk/validation/<year>/: summary.csv (one row per
# measure), candidates.csv (one row per candidate, pipeline vs CAGE, with each
# comparison) and cage_scope.csv (every CAGE row and whether the pipeline was
# responsible for it).

library(tidyverse)
library(fs)

YEAR <- as.integer(commandArgs(trailingOnly = TRUE)[[1]])
options(width = 250)
CAGE_FILE <- "candidates_2006-2024.tab"
CAGE_VERSION <- "4.1"

val_dir <- path("data", "clerk", "validation", YEAR)
dir_create(val_dir)

norm <- \(x) x |>
  stringi::stri_trans_general("Latin-ASCII") |>
  str_to_upper() |>
  str_replace_all("[^A-Z ]", " ") |>
  str_squish()
surname <- \(x) norm(str_extract(x, "^[^,]+"))
given <- \(x) norm(str_remove(coalesce(str_split_i(x, ",", 2), ""), "\\(.*\\)"))
nickname <- \(x) norm(coalesce(str_extract(x, "(?<=\\()[^)]+"), ""))
suffix <- \(x) norm(coalesce(str_split_i(x, ",", 3), ""))
race_key <- \(state, office, dist, type) str_c(state, office, if_else(office == "H", as.character(dist), ""), type, sep = "|")
same <- \(a, b) coalesce(a == b, is.na(a) & is.na(b))

# Read ----

skel <- read_csv(path("data", YEAR, str_glue("candidates_{YEAR}_skeleton.csv")), col_types = cols(.default = "c")) |>
  mutate(across(c(dist, nextup, candidatevotes, totalvotes, won), as.numeric),
         key = race_key(state, office, dist, type))

hand <- read_csv(path("data", YEAR, str_glue("candidates_{YEAR}_hand-entry.csv")), col_types = cols(.default = "c")) |>
  filter(scope == "race") |>
  mutate(key = race_key(state, office, dist, if_else(special == "1", "S", "G")))

cage <- dataverse::get_dataframe_by_name(
  file = CAGE_FILE,
  dataset = "10.7910/DVN/DGDRDT",
  server = "dataverse.harvard.edu",
  version = CAGE_VERSION,
  .f = \(f) read_tsv(f, show_col_types = FALSE))

# Scope: which CAGE rows the skeleton is responsible for ----

cage_scope <- cage |>
  filter(year == YEAR, office %in% c("H", "S")) |>
  mutate(key = race_key(state, office, dist, type),
         scope = case_when(
           office == "H" & type == "S" ~ "House special (not printed in the volume)",
           key %in% hand$key ~ "On the hand-entry list",
           runoff %in% 1 & key %in% skel$key ~ "Runoff round, but the race is in the skeleton",
           runoff %in% 1 ~ "Runoff round (not printed in the volume)",
           key %in% skel$key ~ "Scored",
           .default = "Race missing from the skeleton"
         ))

# races the pipeline sends to hand entry although CAGE takes them from the November volume
hand_but_regular <- cage_scope |>
  filter(scope == "On the hand-entry list", type == "G", !runoff %in% 1) |>
  distinct(state, office, dist, key) |>
  left_join(distinct(hand, key, reason), by = "key")

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
  mutate(pid = row_number(), sur = surname(name_snyder), sur_last = word(sur, -1), votes = candidatevotes)

truth <- cage_scope |>
  filter(scope == "Scored") |>
  mutate(cid = row_number(), sur = surname(name_snyder), sur_last = word(sur, -1), votes = candidatevotes)

# votes come last so that vote agreement is mostly measured on name-matched pairs
pairs <- tibble(pid = integer(), cid = integer(), how = character()) |>
  match_on(pipe, truth, "name_snyder", "exact name") |>
  match_on(pipe, truth, "sur", "surname") |>
  match_on(pipe, truth, "sur_last", "last surname token") |>
  match_on(pipe, truth, "votes", "vote count")

# Compare each candidate ----

prior_people <- cage |>
  filter(year < YEAR) |>
  distinct(state, c_name = name_snyder) |>
  mutate(prior = TRUE)

candidates <- pairs |>
  full_join(select(pipe, pid, key, state, office, dist, name_printed, party_lines, name_basis, name_snyder,
                   party, party_formal, votes, totalvotes, won, nextup, source_page, flags),
            by = "pid") |>
  full_join(select(truth, cid, c_key = key, c_state = state, c_office = office, c_dist = dist, c_name = name_snyder,
                   c_party = party, c_party_formal = party_formal, c_votes = votes, c_totalvotes = totalvotes,
                   c_won = won, c_nextup = nextup),
            by = "cid") |>
  mutate(key = coalesce(key, c_key),
         state = coalesce(state, c_state),
         office = coalesce(office, c_office),
         status = case_when(
           !is.na(pid) & !is.na(cid) ~ "matched",
           is.na(cid) ~ "pipeline only",
           .default = "CAGE only"
         )) |>
  left_join(prior_people, by = c("state", "c_name")) |>
  mutate(
    prior = coalesce(prior, FALSE),
    from_history = str_starts(coalesce(name_basis, ""), "history"),
    name_equal = coalesce(name_snyder == c_name, FALSE),
    name_outcome = case_when(
      status != "matched" ~ NA,
      prior & name_equal ~ "returning: linked to their CAGE record",
      prior & from_history ~ "returning: linked to a different record",
      prior ~ "returning: not linked (new name built)",
      name_equal ~ "new: name identical",
      from_history ~ "new in CAGE: pipeline linked to an earlier record",
      .default = "new: name differs"
    ),
    name_diff = case_when(
      status != "matched" | name_equal ~ NA,
      str_remove_all(norm(name_snyder), " ") == str_remove_all(norm(c_name), " ") ~ "punctuation or spacing",
      surname(name_snyder) != surname(c_name) ~ "surname",
      word(given(name_snyder), 1) != word(given(c_name), 1) ~ "first name",
      given(name_snyder) != given(c_name) ~ "middle name or initial",
      nickname(name_snyder) != nickname(c_name) ~ "nickname",
      suffix(name_snyder) != suffix(c_name) ~ "suffix",
      .default = "order of name parts"
    ),
    party_equal = coalesce(party == c_party, FALSE),
    party_formal_equal = coalesce(party_formal == c_party_formal, FALSE),
    votes_outcome = case_when(
      status != "matched" ~ NA,
      is.na(votes) & is.na(c_votes) ~ "both blank",
      is.na(votes) ~ "blank in pipeline",
      is.na(c_votes) ~ "blank in CAGE",
      votes == c_votes ~ "equal",
      .default = "differ"
    ),
    totalvotes_equal = same(totalvotes, c_totalvotes),
    won_equal = same(won, c_won),
    dist_equal = same(dist, c_dist),
    nextup_equal = same(nextup, c_nextup)
  ) |>
  select(-pid, -cid, -c_key, -c_state, -c_office)

# Summary ----

metric <- \(section, name, n, d = NA) tibble(section, metric = name, n = as.numeric(n), d = as.numeric(d))
m <- filter(candidates, status == "matched")
dr <- filter(m, c_party %in% c("D", "R"))
scored <- filter(cage_scope, scope == "Scored")

summary <- bind_rows(
  metric("counts", "CAGE House and Senate rows", nrow(cage_scope)),
  count(cage_scope, scope) |> transmute(section = "counts", metric = str_c("CAGE rows: ", scope), n, d = NA),
  metric("counts", "skeleton rows", nrow(skel)),
  metric("counts", "scored CAGE rows found in the skeleton", nrow(m), nrow(scored)),
  metric("counts", "skeleton rows found in CAGE", nrow(m), nrow(skel)),
  metric("counts", "skeleton rows with no CAGE counterpart", sum(candidates$status == "pipeline only")),
  metric("counts", "scored CAGE rows with no skeleton counterpart", sum(candidates$status == "CAGE only")),
  metric("counts", "races in both", n_distinct(intersect(skel$key, scored$key)), n_distinct(scored$key)),
  metric("counts", "hand-entry races CAGE takes from the November volume", nrow(hand_but_regular)),
  metric("party", "party identical", sum(m$party_equal), nrow(m)),
  metric("party", "CAGE D or R: party identical", sum(dr$party_equal), nrow(dr)),
  metric("party", "CAGE D or R: opposite major party", sum(dr$party %in% c("D", "R") & !dr$party_equal)),
  metric("party", "party_formal identical", sum(m$party_formal_equal), nrow(m)),
  metric("names", "name_snyder identical", sum(m$name_equal), nrow(m)),
  metric("names", "copied from history: identical", sum(m$name_equal & m$from_history), sum(m$from_history)),
  metric("names", "reformatted from printed name: identical", sum(m$name_equal & !m$from_history), sum(!m$from_history)),
  metric("names", "returning candidates linked to their CAGE record", sum(m$prior & m$name_equal), sum(m$prior)),
  metric("names", "returning candidates not linked", sum(m$name_outcome == "returning: not linked (new name built)", na.rm = TRUE)),
  metric("names", "linked to an earlier record CAGE did not use",
         sum(m$from_history & !m$name_equal)),
  metric("names", "new candidates: name identical", sum(!m$prior & m$name_equal), sum(!m$prior)),
  metric("votes", "candidatevotes identical", sum(m$votes_outcome == "equal"), sum(m$votes_outcome %in% c("equal", "differ"))),
  metric("votes", "candidatevotes blank in pipeline, present in CAGE", sum(m$votes_outcome == "blank in pipeline")),
  metric("votes", "candidatevotes blank in CAGE, present in pipeline", sum(m$votes_outcome == "blank in CAGE")),
  metric("votes", "totalvotes identical", sum(m$totalvotes_equal), nrow(m)),
  metric("votes", "won identical", sum(m$won_equal), nrow(m)),
  metric("other columns", "dist identical", sum(m$dist_equal), nrow(m)),
  metric("other columns", "nextup identical", sum(m$nextup_equal), nrow(m))
) |>
  mutate(year = YEAR, rate = n / d, .before = 1)

# Diagnostics ----

show <- \(df) if (nrow(df) == 0) message("none") else print(as.data.frame(df), row.names = FALSE, right = FALSE)

message(str_glue("\n# {YEAR}: pipeline skeleton vs CAGE v{CAGE_VERSION}"))
summary |>
  mutate(value = if_else(is.na(d), as.character(n), str_glue("{n} / {d} ({round(100 * rate, 1)}%)"))) |>
  select(section, metric, value) |>
  show()

message("\n# Skeleton rows with no CAGE counterpart")
candidates |>
  filter(status == "pipeline only") |>
  select(state, office, dist, name_printed, name_snyder, party_formal, votes) |>
  show()

message("\n# Scored CAGE rows with no skeleton counterpart")
candidates |>
  filter(status == "CAGE only") |>
  select(state, office, c_dist, c_name, c_party_formal, c_votes) |>
  show()

message("\n# CAGE races missing from the skeleton, or runoff rounds left in it")
cage_scope |>
  filter(scope %in% c("Race missing from the skeleton", "Runoff round, but the race is in the skeleton")) |>
  select(scope, state, office, dist, type, name_snyder, candidatevotes) |>
  show()

message("\n# Hand-entry races CAGE takes from the November volume")
show(hand_but_regular)

message("\n# Party differences (CAGE party by pipeline party)")
m |>
  filter(!party_equal) |>
  count(c_party, party) |>
  show()
m |>
  filter(!party_equal) |>
  select(state, office, dist, name_printed, party_lines, party, c_party, party_formal, c_party_formal) |>
  show()

message("\n# name_snyder differences")
m |>
  filter(!name_equal) |>
  count(name_outcome, name_diff) |>
  show()
m |>
  filter(!name_equal) |>
  arrange(name_outcome, name_diff) |>
  select(name_outcome, name_diff, state, office, dist, name_printed, name_snyder, c_name, name_basis) |>
  show()

message("\n# candidatevotes differences")
m |>
  filter(votes_outcome %in% c("differ", "blank in pipeline", "blank in CAGE")) |>
  select(votes_outcome, state, office, dist, name_printed, votes, c_votes, source_page) |>
  show()

message("\n# totalvotes and won differences")
m |>
  filter(!totalvotes_equal | !won_equal) |>
  select(state, office, dist, name_snyder, votes, totalvotes, c_totalvotes, won, c_won) |>
  show()

message("\n# dist and nextup differences")
m |>
  filter(!dist_equal | !nextup_equal) |>
  count(office, dist, c_dist, nextup, c_nextup) |>
  show()

write_csv(summary, path(val_dir, "summary.csv"), na = "")
write_csv(candidates, path(val_dir, "candidates.csv"), na = "")
write_csv(select(cage_scope, year, state, office, dist, type, name_snyder, party, candidatevotes, runoff, scope),
          path(val_dir, "cage_scope.csv"), na = "")

message(str_glue("\nwrote summary.csv, candidates.csv and cage_scope.csv to {val_dir}"))
