library(dataverse)
library(tidyverse)
library(tidylog)

# Dataverse
pres_raw <- get_dataframe_by_name(
  file = "1976-2020-president.tab",
  dataset = "10.7910/DVN/42MVDX",
  original = TRUE,
  server = "dataverse.harvard.edu",
  version = "8",
  .f = read_csv)

# 2024
pres_24_init <- read_csv("https://raw.githubusercontent.com/MEDSL/2024-elections-official/refs/heads/main/2024-president-state.csv") |>
  mutate(across(c(state_fips, state_ic, version), as.numeric)) |>
  rename(candidatevotes = votes)

# merge parties in missing states (NV, VT, )
pres_24_ptys <- pres_24_init |>
  filter(!writein) |>
  count(candidate, party_detailed) |>
  slice_max(n, by = c(candidate)) |> # modal party
  filter(!is.na(party_detailed))

pres_24 <- pres_24_init |>
  left_join(pres_24_ptys, by = "candidate") |>
  mutate(party_detailed = coalesce(party_detailed.x, party_detailed.y))

# Recode party, variable names, etc..
pres_fmt <- pres_raw |>
  bind_rows(pres_24) |>
  dplyr::filter(year >= 2006) |>
  dplyr::transmute(
    year,
    state = state_po,
    candidate,
    writein,
    party = recode(party_simplified, REPUBLICAN = "R", DEMOCRAT = "D", LIBERTARIAN = "Lbt", GREEN = "Grn", OTHER = "Other"),
    party_formal = recode(str_to_title(party_detailed), Republican = "R", Democrat = "D", Libertarian = "Lbt", Green = "Grn"),
    candidatevotes
  ) |>
  tidylog::mutate(
    party = replace(party, party_formal == "Working Families", "D"),
    party = replace(party, party_formal == "Women's Equality" & state == "NY", "D"),
    party = replace(party, party_formal == "Independence" & state == "NY" & year %in% c(2008), "R"),
    party = replace(party, party_formal == "Independence" & state == "NY" & year %in% c(2016), "Lbt"),
    party = replace(party, party_formal == "Conservative", "R")) |>
  tidylog::mutate(
    # writins
    party = replace(party, (writein), "W-I"),
    candidate = replace(candidate, writein, "W-I"),
    party_formal = replace(party_formal, writein, NA_character_),
    name = recode(
      candidate,
      `OBAMA, BARACK H.` = "OBAMA, BARACK",
      `CLINTON, HILLARY` = "CLINTON, HILLARY RODHAM",
      `BIDEN, JOSEPH R. JR` = "BIDEN, JOSEPH R., JR.",
      `MCCAIN, JOHN` = "MCCAIN, JOHN S.",
      `PAUL, RONALD \"\"RON\"\"` = "PAUL, RONALD E. (RON)",
    ),
    name = str_replace(name, "\"{1,}$", ")"),
    name = str_replace(name, "\\s\"{1,}", " ("),
    inc = case_when(
      str_detect(name, "OBAMA") & year == 2012 ~ 1,
      str_detect(name, "TRUMP") & year == 2020 ~ 1,
      TRUE ~ 0
    )
  ) |>
  select(-writein, -candidate) |>
  relocate(year, state,
           party, party_formal,
           name,
           inc,
           candidatevotes)

# collapse fusion
pres_fmt2 <- pres_fmt |>
  summarize(
    party_formal = str_c(as.character(party_formal), collapse = ", "),
    candidatevotes = sum(candidatevotes, na.rm = TRUE),
    .by = c(year, state, party, name, inc)
    )

# drop
# - candidates with less than 10 votes
# - blank votes, overvotes, scatterings, etc..
pres_sel <- pres_fmt2 |>
  filter(candidatevotes >= 10) |>
  filter(!is.na(party_formal))

xtabs(~ year + party, pres_sel)

# write to intermediate
write_csv(pres_sel, "data/intermediate/2008-2024_pres.csv")
