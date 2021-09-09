library(haven)
library(fs)
library(knitr)
library(glue)
library(kableExtra)
library(tidyverse)


source("00b_xtabs-functions.R")

# data ---
jsdat <- read_dta("release/candidates_2006-2020.dta")
# version where labelled class is a factor
js_fct <- jsdat %>%
  mutate(party = recode_factor(party, D = "D", R = "R", Lbt = "Lbt", Grn = "Grn", .default = "Oth"))

# counts JS ----
js_fct %>% filter(party %in% c("D", "R"), office != "P") %>%  write_numbers("all")
js_fct %>% filter(office == "G", party %in% c("D", "R")) %>% write_numbers("gov")
js_fct %>% filter(office == "H", party %in% c("D", "R")) %>% write_numbers("house")
js_fct %>% filter(office == "S", party %in% c("D", "R")) %>% write_numbers("sen")


# main xtab


# party short
xtabs(~ year + party, js_fct, subset = (office == "G"), drop.unused.levels = TRUE) %>%
  fmt_xtab("Gov party") %>% wri_xtab("party_G")
xtabs(~ year + party, js_fct, subset = (office == "H"), drop.unused.levels = TRUE) %>%
  fmt_xtab("House party") %>% wri_xtab("party_H")
xtabs(~ year + party, js_fct, subset = (office == "S"), drop.unused.levels = TRUE) %>%
  fmt_xtab("Senate party") %>% wri_xtab("party_S")



# party formal
js_fct  %>%
  mutate(party_formal = fct_relevel(party_formal, "D", "R", "Lbt", "Grn", "I")) %>%
  xtabs(~ party_formal + office, .) %>%
  fmt_xtab("Office", long = TRUE, rowname = "party-formal") %>%
  wri_xtab("party-formal_by-office")


# office
jsdat  %>%
  mutate(office = fct_relevel(factor(office), "P", "S", "H", "G")) %>%
  xtabs(~ year + office, .) %>%
  fmt_xtab("office") %>%
  wri_xtab("office")


# incumbent
xtabs(~ year + inc, jsdat, subset = office == "G") %>%
  fmt_xtab("Gov inc") %>% wri_xtab("inc_G")
xtabs(~ year + inc, jsdat, subset = office == "H") %>%
  fmt_xtab("House inc") %>% wri_xtab("inc_H")
xtabs(~ year + inc, jsdat, subset = office == "S") %>%
  fmt_xtab("Senate inc") %>% wri_xtab("inc_S")


# special vs. general
xtabs(~ year + type, jsdat, subset = office == "G") %>%
  fmt_xtab("Gov type") %>% wri_xtab("type_G")
xtabs(~ year + type, jsdat, subset = office == "H") %>%
  fmt_xtab("House type") %>% wri_xtab("type_H")
xtabs(~ year + type, jsdat, subset = office == "S") %>%
  fmt_xtab("Senate type") %>% wri_xtab("type_S")


# runoff
xtabs(~ year + runoff, jsdat, subset = office == "G") %>%
  fmt_xtab("Gov runoff") %>% wri_xtab("runoff_G")
xtabs(~ year + runoff, jsdat, subset = office == "H") %>%
  fmt_xtab("House runoff") %>% wri_xtab("runoff_H")
xtabs(~ year + runoff, jsdat, subset = office == "S") %>%
  fmt_xtab("Senate runoff") %>% wri_xtab("runoff_S")

# nextup
xtabs(~ year + nextup, jsdat, subset = office == "G") %>%
  fmt_xtab("Gov nextup") %>% wri_xtab("nextup_G")
xtabs(~ year + nextup, jsdat, subset = office == "H") %>%
  fmt_xtab("House nextup") %>% wri_xtab("nextup_H")
xtabs(~ year + nextup, jsdat, subset = office == "S") %>%
  fmt_xtab("Senate nextup") %>% wri_xtab("nextup_S")

# won
xtabs(~ year + won, jsdat, subset = office == "G") %>%
  fmt_xtab("Gov won") %>% wri_xtab("won_G")
xtabs(~ year + won, jsdat, subset = office == "H") %>%
  fmt_xtab("House won") %>% wri_xtab("won_H")
xtabs(~ year + won, jsdat, subset = office == "S") %>%
  fmt_xtab("Senate won") %>% wri_xtab("won_S")

# winning party
xtabs(~ year + party, js_fct, subset = (office == "G" & won == 1), drop.unused.levels = TRUE) %>%
  fmt_xtab("\\\\shortstack{Gov\\\\\\\\party (winners)}") %>% wri_xtab("party-won_G")
xtabs(~ year + party, js_fct, subset = (office == "H" & won == 1), drop.unused.levels = TRUE) %>%
  fmt_xtab("\\\\shortstack{House\\\\\\\\party (winners)}") %>% wri_xtab("party-won_H")
xtabs(~ year + party, js_fct, subset = (office == "S" & won == 1), drop.unused.levels = TRUE) %>%
  fmt_xtab("\\\\shortstack{Senate\\\\\\\\party (winners)}") %>% wri_xtab("party-won_S")

