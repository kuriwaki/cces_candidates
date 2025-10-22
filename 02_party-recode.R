library(tidyverse)
library(haven)
source("00c_party-recode-functions.R")

# temp, should change later to "data/intermediate/prelim/candidates_2006-2024.rds"
js <- read_dta("data/snyder/2025-08-18 tmp_S_H_G_1990_2024.dta")
js_pres <- read_dta("data/snyder/2025-10-22_pres_votes.dta")


# party coding
js |>
  tidylog::mutate(party_formal = party_fringeparties(party_formal)) |>
  tidylog::mutate(party = party_oneletter(party)) |>
  mutate(
    party_formal = replace(party_formal, name == "PERRONE, MICHAEL, JR." & year == 2008, "I Pg"),
    party_formal = replace(party_formal, name == "GEDDINGS, HAROLD, III" & year == 2014, "Labor")
  ) |>
  mutate(
    party = replace(party, name == "GRIBBEN, WENDY" & year == 2016, "Grn"),
    party = replace(party, name == "MCLAUGHLIN, CURTIS E., JR." & year == 2014, "I"),
  )

write_rds("data/intermediate/prelim/candidates_party-recoded.rds")
