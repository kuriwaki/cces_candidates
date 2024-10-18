library(googlesheets4)
library(tidyverse)

g2020_ss <- gs4_get(ss = "1tnOcrDqstmgOOhyJQcDzCz0Qxg68TIiYhPegYg7Bdxs")
g2020_gov <- range_read(g2020_ss, sheet = "State-Executive")

g2022_ss <- gs4_get(ss = "1apAGzAvsgJqhPXMZa85IgAIF_7SaHncA6Bh4jAP6aNk")
g2022_gov <- range_read(g2022_ss, sheet = "State-Executive")

g2022_std <- g2022_gov |>
  rename(state = st) |>
  filter(office == "G") |>
  mutate(nextup = case_when(
    state == "NH" ~ year + 2,
    state == "VT" ~ year + 2,
    TRUE ~ year + 4
  ),
  runoff = NA,
  type = "G")

# rename for other data
g2020_std <- g2020_gov |>
  rename(state = st) |>
  filter(office == "G") |>
  mutate(nextup = case_when(
    state == "NH" ~ year + 2,
    state == "VT" ~ year + 2,
    TRUE ~ year + 4
  ))

g2020_2022 <- g2020_std |>
  bind_rows(g2022_std)

write_csv(g2020_2022, "data/intermediate/2020_2022_gov.csv")
