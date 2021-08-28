library(tidyverse)
library(haven)

# read data ----
jsdat_all <- read_rds("data/intermediate/snyder_2006-2020.rds")
gov_2020 <- read_csv("data/intermediate/2020_gov.csv")


# filter, stack, modify ------
jsdat <- jsdat_all %>%
  # ONLY keep three offices
  filter(office %in% c("S", "H", "G")) %>%
  # ADD GOVERNOR
  bind_rows(gov_2020) %>%
  # PARTY EDITS
  mutate(party_formal = str_squish(party),
         party = recode_factor(party_formal, `Democrat` = "D", `Republican` = "R"),
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
