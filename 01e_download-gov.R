library(googlesheets4)
library(tidyverse)

g2020_ss <- gs4_get(ss = "1tnOcrDqstmgOOhyJQcDzCz0Qxg68TIiYhPegYg7Bdxs")
g2020_gov <- range_read(g2020_ss, sheet = "State-Executive")

# rename for other data
g2020_std <- g2020_gov |>
  rename(state = st) |>
  filter(office == "G")

write_csv(g2020_std, "data/intermediate/2020_gov.csv")
