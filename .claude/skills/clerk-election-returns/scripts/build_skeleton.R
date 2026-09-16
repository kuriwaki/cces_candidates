# Build the CAGE skeleton for a new year from Claude's validated rows.
#
# Run from the repo root after check_readings.R:
#
#   Rscript .claude/skills/clerk-election-returns/scripts/build_skeleton.R 2026
#
# Keeps named candidates, including named write-ins, in House and Senate general
# elections, drops the races on the hand-entry list and the delegates, and writes
# data/<year>/candidates_<year>_skeleton.csv in the CAGE columns plus provenance.
# `inc` is left NA for hand coding; `totalvotes` and `won` are filled only for
# races whose candidate votes are all present.

library(tidyverse)
library(fs)

YEAR <- as.integer(commandArgs(trailingOnly = TRUE)[[1]])
TERR <- c("DC", "AS", "GU", "PR", "VI", "MP")

senate_class <- \(year) c(1L, 2L, 3L)[((year - 2024) %/% 2) %% 3 + 1]
stopifnot(senate_class(2024) == 1, senate_class(2026) == 2, senate_class(2022) == 3)

claude <- read_tsv(path("data", "clerk", str_glue("claude_rows_{YEAR}.tsv")),
                   col_types = cols(.default = "c"), quote = "", na = character())
hand <- read_csv(path("data", YEAR, str_glue("candidates_{YEAR}_hand-entry.csv")),
                 col_types = cols(.default = "c"), na = character())

hand_races <- hand |>
  filter(scope == "race") |>
  distinct(state, office, dist, special)

skel_sel <- claude |>
  mutate(dist = if_else(office == "S", "", as.character(as.integer(dist))),
         special = if_else(special == "", "0", special)) |>
  filter(kind %in% c("candidate", "writein"), office %in% c("H", "S"), !state %in% TERR) |>
  anti_join(hand_races, by = c("state", "office", "dist", "special"))

skel <- skel_sel |>
  mutate(year = YEAR,
         dist = coalesce(as.integer(na_if(dist, "")), senate_class(YEAR)),
         type = "G",
         nextup = if_else(office == "S", YEAR + 6L, YEAR + 2L),
         inc = NA_integer_,
         candidatevotes = as.numeric(na_if(candidatevotes, "")),
         runoff = if_else(state == "LA", 0L, NA_integer_)) |>
  mutate(complete = all(!is.na(candidatevotes)),
         totalvotes = if_else(complete, sum(candidatevotes), NA_real_),
         # an unopposed candidate whose count is not printed still won
         won = case_when(
           n() == 1 ~ 1L,
           complete ~ as.integer(candidatevotes == max(candidatevotes)),
           .default = NA_integer_
         ),
         .by = c(state, office, dist)) |>
  select(year, state, office, dist, type, nextup, party, party_formal, name_snyder, inc,
         candidatevotes, totalvotes, won, runoff,
         name_printed, party_lines, line_votes, name_basis, source_page = page, flags) |>
  arrange(state, desc(office), dist, desc(candidatevotes))

ties <- skel |>
  summarise(winners = sum(won, na.rm = TRUE), .by = c(state, office, dist)) |>
  filter(winners > 1)
count(skel, office)

write_csv(skel, path("data", YEAR, str_glue("candidates_{YEAR}_skeleton.csv")), na = "")

message(str_glue("{YEAR}: {nrow(skel)} skeleton rows in {n_distinct(skel$state, skel$office, skel$dist)} races, ",
                 "{sum(is.na(skel$totalvotes))} rows without totalvotes, {nrow(ties)} tied races"))
