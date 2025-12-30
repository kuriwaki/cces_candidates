library(tidyverse)
library(haven)
source("00c_party-recode-functions.R")

js0 <- read_rds("data/intermediate/prelim/candidates_stacked.rds")

# party coding
js1 <- js0 |>
  tidylog::mutate(party_formal = party_fringeparties(party_formal)) |>
  tidylog::mutate(party = party_oneletter(party),
                  party = replace(party, !party %in% c("D", "R",  "I",  "Lbt","Grn"), "Other"))

js1 |>
  write_rds("data/intermediate/prelim/candidates_party-recoded.rds")


stop()

# WIP: TO CHECK IF STILL NECESSARY ---

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

# BULK EDIT PARTY SHORT
mutate(party = replace(party, !party %in% c("D", "R",  "I",  "Lbt","Grn"), "Other")) |>


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
