library(tidyverse)
library(haven)
stopifnot(packageVersion("readr") >= "2.0.0")

# read data ----
jsdat_all <- read_rds("data/intermediate/snyder_2006-2020.rds")

# 2020 state exec
gov_2020 <- read_csv("data/intermediate/2020_gov.csv",
                     show_col_types = FALSE)
# president
pres_2008_2020 <- read_csv("data/intermediate/2008-2020_pres.csv",
                           show_col_types = FALSE) %>%
  mutate(
    office = "P",
    type = "G",
    nextup = year + 4
  )


# filter, stack, modify ------
jsdat <- jsdat_all %>%
  # ONLY keep three offices
  filter(office %in% c("S", "H", "G", "P")) %>%
  # ADD GOVERNOR
  bind_rows(gov_2020) %>%
  # ADD PRESIDENT
  bind_rows(pres_2008_2020) %>%
  # PARTY EDITS
  mutate(party_formal = str_squish(party),
         party = recode_factor(party_formal,
                               `Democrat` = "D",
                               `Republican` = "R",
                               `DFL` = "D"),
         party = fct_lump_n(party, n = 6)
  ) %>%
  # VARIABLE RENAME
  mutate(
    candidatevotes = coalesce(candidatevotes, vote_g),
    won = coalesce(won, w_g)) %>%
  select(-vote_g, -w_g, -u_g) %>%
  rename(name_snyder = name) %>%
  # TOTAL VOTE
  group_by(year, office, state, dist, type) %>%
  mutate(totalvotes = sum(candidatevotes)) %>%
  ungroup() %>%
  # ARRANGE
  arrange(year, state, desc(office), state, party)



# Save -----
write_rds(jsdat, "data/intermediate/candidates_2006-2020.rds")
