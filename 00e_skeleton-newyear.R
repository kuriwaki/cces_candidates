# Build a skeleton of a new election year from the Clerk of the House volume.
#
#   Rscript 00e_skeleton-newyear.R 2026
#
# Input  : data/clerk/clerk_raw_<year>.csv, written by
#          .claude/skills/clerk-election-returns/scripts/extract_clerk.py
# Output : data/<year>/candidates_<year>_skeleton.csv   <- feeds 01_stack-sources.R
#          data/<year>/candidates_<year>_name-review.csv
#          data/<year>/candidates_<year>_party-review.csv
#          data/<year>/candidates_<year>_hand-entry.csv
#
# The skeleton carries what the Clerk volume actually states plus the identity
# columns we can resolve from our own history.  It deliberately leaves
# `totalvotes`, `won` and `inc` as NA: those are derived, not printed, and are
# filled in a separate reviewed pass (see the skill's SKILL.md, step 8).
#
# name_snyder is filled two ways, and `name_source` always says which:
#
#   "history"      the row matched exactly one prior person in the same State,
#                  and that person's existing name_snyder was copied verbatim.
#                  This is the only authoritative route: the Clerk prints
#                  "Barry Moore" where the convention needs "MOORE, FELIX BARRY",
#                  and no rule recovers "FELIX" from the page.
#   "reformatted"  no prior person matched, so the printed name was reordered
#                  into LAST, FIRST MIDDLE (NICKNAME), SUFFIX.  This invents
#                  nothing - it only rearranges what the Clerk printed - but it
#                  cannot know a two-word surname or a fuller legal name, so
#                  every such row is listed for review.

library(tidyverse)
library(fs)

args <- commandArgs(trailingOnly = TRUE)
YEAR <- as.integer(if (length(args) >= 1) args[[1]] else 2026)
clerk_path <- if (length(args) >= 2) args[[2]] else
  path("data", "clerk", str_glue("clerk_raw_{YEAR}.csv"))
# Prior candidate rows: the rds built by this pipeline, else a Dataverse .tab
history_path <- if (length(args) >= 3) args[[3]] else
  path("data", "intermediate", str_glue("candidates_2006-{YEAR - 2}.rds"))
out_dir <- if (length(args) >= 4) args[[4]] else path("data", as.character(YEAR))

stopifnot(file_exists(clerk_path))
dir_create(out_dir)

# Senate class up for election in a given cycle -------------------------------
senate_class <- function(year) c(1L, 2L, 3L)[((year - 2024) %/% 2) %% 3 + 1]
stopifnot(senate_class(2024) == 1, senate_class(2026) == 2, senate_class(2022) == 3)

# Clerk party wording -> the short codes 00c_party-recode-functions.R expects --
clerk_party_short <- c(
  "Republican" = "R", "Democrat" = "D", "Democratic" = "D",
  "Democratic-Farmer-Labor" = "DFL", "Democratic-Nonpartisan League" = "D",
  "Libertarian" = "Lbt", "Green" = "Grn", "Independent" = "I",
  "Independence" = "Independence", "Constitution" = "Const",
  "Working Families" = "Wk Fam", "Conservative" = "C",
  "No Party" = "No Pty", "No Party Affiliation" = "NPA",
  "Nonpartisan" = "NP", "Unaffiliated" = "Unaffiliated",
  "Write-in" = "W-I", "Petition" = "Petition", "By Petition" = "Petition"
)

# ---------------------------------------------------------------- name tools
norm_name <- function(x) {
  x |>
    str_replace_all("[‘’“”]", "'") |>
    iconv(to = "ASCII//TRANSLIT", sub = "") |>
    str_to_upper() |>
    str_replace_all("[.'\"]", " ") |>
    str_squish()
}
SUFFIXES <- c("JR", "SR", "I", "II", "III", "IV", "V", "MD", "PHD", "DDS", "ESQ")

# Short forms that usually stand for a longer legal name.  Used ONLY to raise a
# review flag - the page does not contain "JEFFREY", so nothing is filled in.
DIMINUTIVES <- c("AL","ANDY","ART","BEN","BERNIE","BETH","BILL","BOB","BOBBY",
  "CAL","CHARLIE","CHRIS","CHUCK","DAN","DANNY","DAVE","DEB","DEBBIE","DICK",
  "DON","DOUG","ED","EDDIE","FRAN","FRANK","FRED","GABE","GREG","HANK","JACK",
  "JAKE","JEFF","JERRY","JIM","JIMMY","JOE","JOEY","JOHNNY","JON","KATE","KATHY",
  "KEN","KEVIN","LARRY","LIZ","LOU","MATT","MAX","MICKEY","MIKE","NICK","PAT",
  "PATTY","PETE","PHIL","RANDY","RAY","RICH","RICK","ROB","ROBBIE","RON","RUDY",
  "RUSS","SAL","SAM","SANDY","STEVE","SUE","TED","TERRI","TERRY","TIM","TOM",
  "TOMMY","TONI","TONY","VIC","WALT","WILL","ZACH")

drop_suffix <- function(tokens) tokens[!tokens %in% SUFFIXES]

# Reorder a printed name into the Snyder form.  Nothing is added: initials stay
# initials, a nickname in quotes moves into parentheses at the end of the given
# names, a trailing suffix stays a suffix.  The last whitespace-delimited token
# is taken as the surname, which is why two-word surnames need human review.
snyder_reformat <- function(printed) {
  # The Clerk sets nicknames in curly double quotes and apostrophes as curly
  # singles, so the two must be normalised separately or D'Arrigo looks like a
  # nickname.  The Snyder convention is unaccented.
  x <- str_replace_all(printed, "[\u201C\u201D]", "\"")
  x <- str_replace_all(x, "[\u2018\u2019]", "'")
  x <- stringi::stri_trans_general(x, "Latin-ASCII")
  # a suffix may or may not be set off by a comma: "Whalen III", "Whalen, Jr."
  suffix <- str_match(x, "(?:,\\s*|\\s+)(Jr|Sr|II|III|IV|V)\\.?\\s*$")[, 2]
  x      <- str_remove(x, "(?:,\\s*|\\s+)(Jr|Sr|II|III|IV|V)\\.?\\s*$")
  nick   <- str_match(x, '"([^"]+)"')[, 2]
  x      <- str_squish(str_remove(x, '"[^"]+"'))
  toks   <- str_split(str_squish(x), " ")[[1]]
  toks   <- toks[toks != ""]
  if (length(toks) < 2) return(NA_character_)
  given  <- toks[-length(toks)]
  given <- if_else(str_detect(given, "^[A-Za-z]$"), str_c(given, "."), given)
  # a given name that is nothing but initials is written closed up: "W.C."
  sep   <- if (all(str_detect(given, "^[A-Za-z]\\.$"))) "" else " "
  out <- str_c(str_to_upper(toks[length(toks)]), ", ",
               str_to_upper(str_c(given, collapse = sep)))
  if (!is.na(nick))   out <- str_c(out, " (", str_to_upper(nick), ")")
  if (!is.na(suffix)) out <- str_c(out, ", ", str_to_upper(suffix),
                                   if (suffix %in% c("Jr", "Sr")) "." else "")
  out
}

# The Snyder form is  LAST, FIRST MIDDLE (NICKNAME), SUFFIX
snyder_parts <- function(name_snyder) {
  bits    <- str_split(name_snyder, ",", n = 3)
  surname <- map_chr(bits, ~ norm_name(.x[1]))
  given   <- map_chr(bits, ~ if (length(.x) > 1) norm_name(.x[2]) else "")
  tibble(surname = surname,
         given_tokens = str_split(str_replace_all(given, "[()]", " ") |> str_squish(), " "))
}

# Printed form is  First Middle "Nickname" Last, Suffix
printed_parts <- function(name_printed) {
  clean  <- norm_name(str_remove(name_printed, ",\\s*(Jr|Sr|I{1,3}|IV|V)\\.?\\s*$"))
  tokens <- str_split(clean, " ")
  tibble(printed_clean = clean, printed_tokens = map(tokens, drop_suffix))
}

message("reading ", clerk_path)
clerk <- read_csv(clerk_path, col_types = cols(.default = "c")) |>
  mutate(across(c(dist, candidatevotes), ~ suppressWarnings(as.integer(.x))))

hand <- filter(clerk, !is.na(hand_entry), hand_entry != "")
write_csv(hand, path(out_dir, str_glue("candidates_{YEAR}_hand-entry.csv")), na = "")
message("set aside ", nrow(hand), " rows for hand entry (runoffs / specials)")

cand <- clerk |>
  filter(kind == "candidate",
         office %in% c("H", "S"),
         !state_abb %in% c("DC", "AS", "GU", "PR", "VI", "MP"),
         is.na(hand_entry) | hand_entry == "")

# votes: the candidate's own line plus every cross-endorsement line -----------
sum_votes <- function(own, extra) {
  parts <- c(own, str_split(replace_na(extra, ""), ";\\s*")[[1]])
  parts <- parts[parts != "" & !is.na(parts)]
  if (length(parts) == 0 || is.na(own) || own == "") return(NA_integer_)
  sum(as.integer(parts))
}

skel <- cand |>
  rowwise() |>
  mutate(candidatevotes = sum_votes(as.character(candidatevotes), extra_votes)) |>
  ungroup() |>
  mutate(
    year   = YEAR,
    state  = state_abb,
    dist   = if_else(office == "S", senate_class(YEAR), dist),
    type   = "G",
    nextup = if_else(office == "S", YEAR + 6L, YEAR + 2L),
    party_formal = if_else(extra_parties == "" | is.na(extra_parties),
                           party_printed,
                           str_c(party_printed, ", ", extra_parties)),
    runoff = if_else(state == "LA", 0L, NA_integer_)
  )

# ------------------------------------------------------------------ parties
source("00c_party-recode-functions.R")
short <- function(x) {
  out <- unname(clerk_party_short[x])
  coalesce(out, x)
}
skel <- skel |>
  mutate(
    party_formal = map_chr(str_split(party_formal, ",\\s*"),
                           ~ str_c(short(str_trim(.x)), collapse = ", ")),
    party_formal = party_fringeparties(party_formal),
    party        = party_oneletter(party_formal),
    party        = if_else(party %in% c("D", "R", "I", "Lbt", "Grn"), party, "Other")
  )

party_review <- skel |>
  filter(party == "Other") |>
  count(party_printed, party_formal, sort = TRUE)
write_csv(party_review, path(out_dir, str_glue("candidates_{YEAR}_party-review.csv")), na = "")

# ----------------------------------------------------- name_snyder carry-over
read_history <- function(p) {
  if (!file_exists(p)) stop("no candidate history at ", p,
                            " - pass one as the third argument")
  if (path_ext(p) == "rds") readRDS(p) |> as_tibble()
  else read_tsv(p, col_types = cols(.default = "c"), quote = "\"") |>
    mutate(year = as.integer(as.numeric(year)),
           won  = suppressWarnings(as.integer(as.numeric(won))))
}
hist_raw <- read_history(history_path)
message("history: ", nrow(hist_raw), " rows, through ", max(hist_raw$year))

people <- hist_raw |>
  filter(!is.na(name_snyder), name_snyder != "") |>
  distinct(state, name_snyder) |>
  bind_cols(snyder_parts(pull(distinct(filter(hist_raw, !is.na(name_snyder) &
                                                name_snyder != ""),
                                       state, name_snyder), name_snyder)))

pp <- printed_parts(skel$name_printed)
skel <- bind_cols(skel, pp)

match_one <- function(st, printed_clean, printed_tokens) {
  pool <- people[people$state == st, ]
  if (nrow(pool) == 0) return(NA_character_)
  # surname must terminate the printed name (handles WASSERMAN SCHULTZ, JACKSON LEE)
  hit <- which(pool$surname != "" &
               (printed_clean == pool$surname |
                str_detect(printed_clean, str_c("\\b", str_replace_all(pool$surname,
                           "([.\\\\|()\\[\\]{}^$*+?])", "\\\\\\1"), "$"))))
  if (length(hit) == 0) return(NA_character_)
  # A surname alone is not enough: "Justin Lee" must not inherit the identity of
  # "LEE, BARBARA J.".  Require a whole forename or nickname in common - initials
  # are deliberately not enough, because "James D. Hooper" and "HOOPER, DON"
  # share a "D" and are different people.
  keep <- hit[map_lgl(hit, function(i) {
    given <- pool$given_tokens[[i]]
    given <- given[nchar(given) > 1]
    fore  <- setdiff(printed_tokens, str_split(pool$surname[i], " ")[[1]])
    fore  <- fore[nchar(fore) > 1 & !fore %in% SUFFIXES]
    length(given) > 0 && length(fore) > 0 && any(fore %in% given)
  })]
  if (length(keep) == 1) pool$name_snyder[keep] else NA_character_
}

skel <- skel |>
  mutate(
    name_from_history = pmap_chr(list(state, printed_clean, printed_tokens), match_one),
    name_reformatted  = map_chr(name_printed, snyder_reformat),
    name_source       = if_else(is.na(name_from_history), "reformatted", "history"),
    name_snyder       = coalesce(name_from_history, name_reformatted),
    # a surname that is not the last single token cannot be found mechanically
    name_needs_review = name_source == "reformatted" &
      (lengths(printed_tokens) > 3 |
       str_detect(str_to_lower(name_printed),
                  "\\b(van|von|de|del|della|di|la|le|st|mac|mc|bin|al)\\.?\\s") |
       map_lgl(printed_tokens, ~ length(.x) > 0 && .x[[1]] %in% DIMINUTIVES) |
       is.na(name_reformatted))
  )

# incumbency PROPOSAL only - `inc` itself stays NA and is coded by hand -------
last_win <- hist_raw |>
  filter(won == 1, !is.na(name_snyder)) |>
  group_by(state, name_snyder, office) |>
  slice_max(year, n = 1, with_ties = FALSE) |>
  ungroup() |>
  transmute(state, name_snyder, office,
            inc_proposed = if_else(type == "S", 2L, 1L),
            inc_basis = str_glue("won {office} in {year} (type {type})"))

skel <- left_join(skel, last_win, by = c("state", "name_snyder", "office")) |>
  mutate(inc_proposed = replace_na(inc_proposed, 0L),
         inc_proposed = if_else(is.na(name_snyder), NA_integer_, inc_proposed),
         inc          = NA_integer_,        # filled by hand; see SKILL.md
         totalvotes   = NA_integer_,        # derived later, not printed
         won          = NA_integer_)        # derived later, not printed

out <- skel |>
  select(year, state, office, dist, type, nextup, party, party_formal,
         name_snyder, inc, candidatevotes, totalvotes, won, runoff,
         name_printed, party_printed, name_source, name_needs_review,
         inc_proposed, inc_basis, source_page = page, clerk_flags = flags) |>
  arrange(state, desc(office), dist, desc(candidatevotes))

write_csv(out, path(out_dir, str_glue("candidates_{YEAR}_skeleton.csv")), na = "")

out <- out |>
  group_by(state, office, dist) |>
  mutate(name_needs_review = name_needs_review |
           (name_source == "reformatted" & !is.na(candidatevotes) &
            any(!is.na(candidatevotes)) &
            candidatevotes == suppressWarnings(max(candidatevotes, na.rm = TRUE)))) |>
  ungroup()
write_csv(out, path(out_dir, str_glue("candidates_{YEAR}_skeleton.csv")), na = "")

review <- out |>
  filter(name_source == "reformatted") |>
  transmute(state, office, dist, name_printed, party_printed, candidatevotes,
            name_snyder_proposed = name_snyder,
            priority = if_else(name_needs_review, "CHECK", "likely fine"),
            note = if_else(
              name_needs_review,
              paste("leads the race, uses a short forename, or has a surname that",
                    "may be more than the last token - confirm the full legal name"),
              "no prior person of this name in this State - confirm they are new"),
            source_page)
write_csv(review, path(out_dir, str_glue("candidates_{YEAR}_name-review.csv")), na = "")

message(str_glue(
  "\n{nrow(out)} candidate rows written to {out_dir}\n",
  "  name_snyder from history   : {sum(out$name_source == 'history')}\n",
  "  name_snyder reformatted    : {sum(out$name_source == 'reformatted')}\n",
  "    of those flagged CHECK   : {sum(out$name_needs_review, na.rm = TRUE)}\n",
  "  party = Other        : {sum(out$party == 'Other')}\n",
  "  votes missing        : {sum(is.na(out$candidatevotes))}\n",
  "  left NA on purpose   : inc, totalvotes, won\n"))
