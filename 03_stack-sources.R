library(tidyverse)
library(haven)
stopifnot(packageVersion("readr") >= "2.0.0")

# read data ----
jsdat_all <- read_rds("data/intermediate/snyder_2006-2024.rds")
fmt2024 <- read_rds("data/snyder-fmt_2024.rds")

# 2020 state exec
gov_2020_2022 <- read_csv("data/intermediate/2020_2022_gov.csv",
                     show_col_types = FALSE) |>
  mutate(party_formal = party) # this was basically what I was entering

# president
pres_2008_2020 <- read_csv("data/intermediate/2008-2020_pres.csv",
                           show_col_types = FALSE) |>
  mutate(
    office = "P",
    type = "G",
    nextup = year + 4
  )

# fixing blank party entries
jsdat_all <- jsdat_all |>
  bind_rows(fmt2024) |>
  mutate(party = replace(party, name == "COOPER, ERIC" & state == "IA" & year == 2010, "Lbt"),
         party = replace(party, name == "HUGHES, GREGORY JAMES" & state == "IA" & year == 2010, "I"),
         party = replace(party, name == "NARCISSE, JONATHAN R." & state == "IA" & year == 2010, "I"),
         party = replace(party, name == "ROSENFIELD, DAVID" & state == "IA" & year == 2010, "I"),
         party = replace(party, name == "BEACHAM, ANDREW R." & state == "KY" & year == 2012, "I"),
         party = replace(party, name == "VANCE, RANDOLPH S." & state == "KY" & year == 2012, "I"),
         party = replace(party, name == "MCMASTERS, THOMAS (TOM)" & state == "OH" & year == 2016, "NPA"),
         party = replace(party, name == "SMITH, RAYBURN DOUGLAS" & state == "PA" & year == 2012, "Lbt"),
         dist = replace(dist, name == "VANCE, RANDOLPH S.", 6)) |>
  mutate(party = case_when(
    name == "[NONE OF THESE]" ~ "NPA",
    TRUE ~ party
  )) |>
  filter(party != "")

# party_formal coding
jsdat_all <- jsdat_all |>
  # ADD GOVERNOR
  bind_rows(gov_2020_2022) |>
  mutate(party_formal = party)

# Fusion 2018 - some removals ----

cand_level_vars <- c("year", "office", "state", "dist", "type", "runoff", "nextup", "name")

# recode fusion people post 2018-2022 as fusion by summing their votes
entries_fusion_post18 <- jsdat_all |>
  ungroup() |>
  filter(year %in% c(2018, 2020, 2022, 2024), state %in% c("NY", "CT", "SC")) |>
  mutate(party_formal = fct_relevel(party_formal, "D", "R")) |>
  arrange(party_formal) |>
  group_by(across(all_of(cand_level_vars))) |>
  select(party_formal, inc, vote_g, w_g) |>
  # add votes, concatenate party, and take w_g
  summarize(
    vote_g = as.integer(sum(vote_g)),
    w_g = as.integer(any(w_g == 1)),
    inc = as.integer(any(inc == 1)),
    party_formal = str_c(as.character(party_formal), collapse = ", "),
    nparties = n(),
    .groups = "drop"
  ) |>
  filter(nparties >= 2) |>
  select(-nparties) |>
  mutate(
    party = replace(party_formal,
                    str_sub(party_formal, 1, 1) == "D",
                    "D"),
    party = replace(party,
                    str_sub(party_formal, 1, 1) == "R",
                    "R")
  )

jsdat_all <- jsdat_all |>
  # drop all candidates whose names match with the fusion list
  anti_join(entries_fusion_post18, by = cand_level_vars) |>
  # stack the summarized versions back in
  bind_rows(entries_fusion_post18)



# party coding
jsdat_all <- jsdat_all |>
  mutate(
    party = recode(party,
                   # Democrats
                   "DFL" = "D",
                   "D,WF" = "D",
                   "D,Wk Fam" = "D",
                   "D, I, Wk Fam, Women's Equality" = "D",
                   "D, Reform, Wk Fam" = "D",
                   "D, Reform, Wk Fam, Women's Equality" = "D",
                   "D, Wk Fam" = "D",
                   "D, Wk Fam, Women's Equality" = "D",
                   "D, Women's Equality" = "D",
                   "D,C,Indep,WF" = "D",
                   "D,I,WF" = "D",
                   "D,IDP,WF" = "D",
                   "D,Indep,WF" = "D",
                   "D,R" = "D",
                   "D,WF" = "D",
                   "D,WF,IDP" = "D",
                   "D,WF,Indep" = "D",
                   "D,Wk Fam" = "D",
                   "D, I, Reform, Wk Fam, Women's Equality" = "D",

                   # Republicans
                   "R, Reform" = "R",
                   "R,C" = "R",
                   "R, C" = "R",
                   "R, C, Reform" = "R",
                   "R, C, I, Reform" = "R",
                   "R, C, Independence" = "R",
                   "R, Const, Independence" = "R",
                   "R, I" = "R",
                   "R,C,I" = "R",
                   "R,C,Indep" = "R",
                   "R,C,Lbt" = "R",
                   "R,C,SCC" = "R",
                   "R,C,Taxp" = "R",
                   "R,CR" = "R",
                   "R,CRV" = "R",
                   "R,CRV,IDP" = "R",
                   "R,I" = "R",
                   "R,IDP" = "R",
                   "R,Indep" = "R",
                   "R,Lbt" = "R",
                   "R,Tax" = "R",
                   "R,Tax,C,Indep" = "R",
                   "R,Taxp" = "R",
                   "I, R" = "R",
                   "Conservative, R" = "R",
                   "Conservative, R, Reform" = "R",
                   "Conservative, I, R" = "R",
                   "Conservative, I, R, Reform" = "R",
                   "Conservative, I, R, Reform, Tax Revolt" = "R",
                   "SCC" = "R"
    ),
    party = replace(party, name == "GRIBBEN, WENDY" & year == 2016, "Grn"),
    party = replace(party, name == "MCLAUGHLIN, CURTIS E., JR." & year == 2014, "I")
  )


# REMOVALS -----
# remove triple counted fusion candidates
entries_fusion_pre18 <- jsdat_all |>
  ungroup() |>
  # double counted fusion
  filter(!(name == "KING, PETER T. (PETE)" & party_formal == "R,Tax" & year == 2012 & state == "NY")) |>
  # keep the sum version of fusion
  filter((party == "D" & str_detect(party_formal, "D.+(Wk Fam|WF)")) |
           (party == "R" & str_detect(party_formal, "R.+(C|Indep|Tax|I$|IDP|Lbt)")))

cands_fusion_pre18 <- jsdat_all |>
  ungroup() |>
  semi_join(distinct(entries_fusion_pre18, year, office, state, dist, type, name)) |>
  mutate(drop = !str_detect(party_formal, ",")) |>  # we will flag the candidates to DROP. This is candidates who are NOT combined counts.
  mutate(drop = replace(drop, name == "LABATE, STEPHEN A." & party_formal != "R,Tax,C,Indep" & year == 2012 & state == "NY", TRUE),
         drop = replace(drop, name == "DIOGUARDI, JOSEPH J." & party_formal != "R,C,Taxp" & year == 2010 & state == "NY", TRUE),
         drop = replace(drop, name == "LALLY, GRANT M." & party_formal != "R,C,Lbt" & year == 2014 & state == "NY", TRUE))



# Drop the non-combined candidates ------
entries_to_drop <- filter(cands_fusion_pre18, drop) |>
  add_row(name = "KING, PETER T. (PETE)",
          party_formal = "R,Tax",
          office = "H",
          state = "NY",
          dist = 2,
          type = "G",
          year = 2012,
          runoff = NA,
          nextup = 2014
  )

jsdat_all <- jsdat_all |>
  ungroup() |>
  anti_join(entries_to_drop,
            by = c(cand_level_vars, "party_formal"))


# removing extraneous observations ------
jsdat_all <- jsdat_all |>
  filter(name != "SCHWEIDEL, JOEL",
         name != "CARLSON, ELAINE SUE",
         name != "BEARDSLEY, MICHAEL",
         name != "WELCH, PETER F." | party != "R",
         name != "WELCH, PETER F." | party_formal != "D" | year != 2008
  )

# WELCH, PETER F. party formal correction
jsdat_all <- jsdat_all |>
  mutate(party_formal = replace(party_formal, name == "WELCH, PETER F." & year == 2008, "D"))

# ROMNEY Fix

jsdat_all <- jsdat_all |>
  mutate(name = replace(name, name == "MITT, ROMNEY", "ROMNEY, MITT"))

# filter, stack, modify ------
jsdat_all <- jsdat_all |>
  # ONLY keep three offices
  filter(office %in% c("S", "H", "G", "P")) |>
  # ADD PRESIDENT
  bind_rows(pres_2008_2020) |>
  # BULK EDIT PARTY SHORT
  mutate(party = replace(party, !party %in% c("D", "R",  "I",  "Lbt","Grn"), "Other")) |>
  # VARIABLE RENAME
  mutate(
    candidatevotes = coalesce(candidatevotes, vote_g),
    won = coalesce(w_g)) |>
  select(-vote_g, -w_g, -u_g) |>
  rename(name_snyder = name) |>
  # TOTAL VOTE
  group_by(year, office, state, dist, type) |>
  mutate(totalvotes = sum(candidatevotes)) |>
  ungroup() |>
  # ARRANGE
  arrange(year, state, desc(office), dist, type, party)



# Save -----
write_rds(jsdat_all, "data/intermediate/prelim/candidates_2006-2024.rds")
