
# Frontmatter -------------------------------------------------------------

library(haven)
library(tidyverse)

setwd("/Users/jeremiahcha/Desktop/github/cces_candidates/")


# Loading in data ---------------------------------------------------------

# Congressional and Gubernatorial Candidates (2006-2016)
cand_16 <- read_dta("data/snyder/2020-06-13 election_results_2006_2016.dta")
# Congressional and Gubernatorial Candidates (2018)
cand_18 <- read_dta("data/snyder/2020-08-16 election_results_2018_names_updated.dta")
# Congressional and Gubernatorial Candidates (2020)
cand_20 <- read_dta("data/intermediate/2020_uspresident-congress_JC-SK.dta")



# Binding data ------------------------------------------------------------

cand <- bind_rows(cand_16, cand_18, cand_20)
