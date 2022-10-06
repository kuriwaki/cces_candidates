library(haven)
library(tidyverse)

jcsk <- read_dta("data/intermediate/2020_uspresident-congress_JC-SK.dta") |>
  filter(office == "H" |
           office == "S",
         party != "Under Votes",
         party != "Over Votes",
         name != "WRITE-IN",
         !grepl("Blank", party),
         !grepl("Misc", party),
         vote_g >= 10) |>
  mutate(dist = case_when(
    dist == 0 ~ 1,
    TRUE ~ as.double(dist)
  ))

jim20 <- read_dta("data/intermediate/sen_gov_house_2006_2020.dta") |>
  filter(year == 2020) |>
  arrange(state, office, type) |>
  mutate(dist = case_when(
    office == "S" ~ NA_integer_,
    TRUE ~ as.integer(dist)
  ))

notjcsk <- anti_join(jim20, jcsk, by = c("state", "office", "dist", "name")) |>
  arrange(state, office, dist, name)
notjim20 <- anti_join(jcsk, jim20, by = c("state", "office", "dist", "name")) |>
  arrange(state, office, dist, name)

