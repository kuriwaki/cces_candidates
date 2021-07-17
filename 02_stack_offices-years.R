
# Frontmatter -------------------------------------------------------------

library(haven)
library(tidyverse)

if (Sys.info()["user"] == "jeremiahcha") {
  setwd("/Users/jeremiahcha/Desktop/github/cces_candidates/")
}


# Loading in data ---------------------------------------------------------

# Congressional and Gubernatorial Candidates (2006-2016)
cand_16 <- read_dta("data/snyder/2020-06-13 election_results_2006_2016.dta")
# Congressional and Gubernatorial Candidates (2018)
cand_18 <- read_dta("data/snyder/2020-08-16 election_results_2018_names_updated.dta")
# Congressional and Gubernatorial Candidates (2020)
cand_20 <- read_dta("data/intermediate/2020_uspresident-congress_JC-SK.dta")



# Binding data --------

cand_all <- bind_rows(cand_16, cand_18, cand_20) %>%
  arrange(year, office, state, dist)

# Limit to necessary and rename ------
cand <- cand_all %>%
  select(year, state, office, dist, type, nextup,
         party, name,
         inc, cand_all = vote_g, won = w_g)


# Add variable labels -----


# Release Dataverse version
write_dta(cand, "release/candidates_2006-2020.dta")

