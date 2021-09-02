library(haven)
library(fs)
library(knitr)
library(glue)
library(kableExtra)
library(tidyverse)


source("07_xtabs-functions.R")

# data ---
jsdat <- read_dta("release/candidates_2006-2020.dta")

# counts JS ----
jsdat %>% filter(as_factor(party) %in% c("D", "R")) %>%  write_numbers("all")
jsdat %>% filter(office == "G", as_factor(party) %in% c("D", "R")) %>% write_numbers("gov")
jsdat %>% filter(office == "H", as_factor(party) %in% c("D", "R")) %>% write_numbers("house")
jsdat %>% filter(office == "S", as_factor(party) %in% c("D", "R")) %>% write_numbers("sen")


# main xtab
xtabs(~ year + office, jsdat) %>%
  fmt_xtab("office") %>%
  wri_xtab("office_by-cand")



jsdat  %>%
  mutate(party = fct_relevel(as_factor(party), "D", "R", "I", "Lbt", "Grn")) %>%
  xtabs(~ year + party, .) %>%
  fmt_xtab("party") %>%
  wri_xtab("party_by-cand")

jsdat  %>%
  xtabs(~ year + office, .) %>%
  fmt_xtab("office") %>%
  wri_xtab("office_by-cand")

# incumbent
jsdat %>%
  xtabs(~ year + inc, .) %>%
  fmt_xtab("inc") %>%
  wri_xtab("inc_by-cand")

# special vs. general
jsdat %>%
  xtabs(~ year + type, .) %>%
  fmt_xtab("type") %>%
  wri_xtab("type_by-cand")
