library(tidyverse)
library(haven)
cand <- read_dta("~/Dropbox/elections/data/input/snyder/tmp_H_1950_1980.dta")
cand <- read_dta("~/Dropbox/elections/data/input/snyder/js_2020-11-03_statewide_1950-2018.dta")
cand <- read_dta("~/Dropbox/CCES_candidates_Dropbox/Release/candidates_snyder.dta")


cand |>
  filter(st %in% "OR") |>
  # filter(party %in% c("D", "R")) |>
  filter(str_detect(name_snyder, regex("cours", ignore_case = TRUE))) |>
  select(year, st, di = dist_up, office, name_snyder, party, inc)
