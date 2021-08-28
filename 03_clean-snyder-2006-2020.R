source("07_xtabs-functions.R")

gov_2020 <- read_dta("data/intermediate/2020_govstateexec.dta")
jsdat_all <- read_dta("data/snyder/2021-07-29 sen_gov_house_2006_2020.dta")
jsdat_all %>% filter(str_detect(name, "OSSOFF"))


jsdat <- jsdat_all %>%
  # ONLY KEEP GENERALS in three offices
  filter(office %in% c("S", "H", "G")) %>%
  # ADD GOVERNOR
  bind_rows(filter(gov_2020, year == 2020, office == "G")) %>%
  # PARTY EDITS
  mutate(party_formal = str_squish(party),
         party = fct_lump_n(party, n = 6),
         party = recode_factor(party_formal, `Democrat` = "D", `Republican` = "R")
  ) %>%
  # VARIABLE RENAME
  mutate(
    candidatevotes = coalesce(candidatevotes, vote_g),
    won = coalesce(won, w_g)) %>%
  select(-vote_g, -w_g, -u_g, -name_orig) %>%
  # TOTAL VOTE
  group_by(year, office, state, dist, type) %>%
  mutate(totalvotes = sum(candidatevotes)) %>%
  ungroup() %>%
  # ARRANGE
  arrange(year, state, desc(office), state, party)



# Out
write_rds(jsdat, "data/intermediate/candidates_2006-2020.rds")
