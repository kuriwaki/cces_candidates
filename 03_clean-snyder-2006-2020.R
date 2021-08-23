source("07_xtabs-functions.R")

gov_2020 <- read_dta("data/intermediate/2020_govstateexec.dta")
jsdat_all <- read_dta("data/snyder/2021-07-29 sen_gov_house_2006_2020.dta")



jsdat <- jsdat_all %>%
  # ONLY KEEP GENERALS in three offices
  filter(office %in% c("S", "H", "G")) %>%
  bind_rows(filter(gov_2020, year == 2020, office == "G")) %>%
  mutate(party_formal = str_squish(party),
         party = recode(party_formal, `Democrat` = "D", `Republican` = "R"),
         party = fct_lump_n(party, n = 6)
  )


jsdat %>% filter(party == "Other") %>%
  count(party_formal, sort = TRUE) %>%
  print(n = 336)

