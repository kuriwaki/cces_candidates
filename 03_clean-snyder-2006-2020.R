source("07_xtabs-functions.R")


jsdat_all <- read_dta("data/snyder/2021-07-29 sen_gov_house_2006_2020.dta")



jsdat <- jsdat_all %>%
  # ONLY KEEP GENERALS in three offices
  filter(office %in% c("S", "H", "G"), year %% 2 == 0) %>%
  mutate(party_full = str_squish(party),
         party = recode(party_full, `Democrat` = "D", `Republican` = "R"),
         party = fct_lump_n(party, n = 6)
  )


jsdat %>% filter(party == "Other") %>% count(party_full, sort=  TRUE)

