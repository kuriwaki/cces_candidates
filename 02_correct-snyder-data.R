library(tidyverse)
library(haven)

# raw
jsdat_raw <- read_dta("data/snyder/2021-07-29 sen_gov_house_2006_2020.dta")


# issue 7
jsdat <- jsdat_raw %>%
  mutate(
    type = replace(
      x = type,
      list = (year == 2006 & state == "TX" & dist == 22 & nextup == 2006),
      values = "S"),
    type = replace(
      x = type,
      list = (year == 2006 & state == "TX" & dist == 22 & nextup == 2008),
      values = "G")
    )

# Senate dist issue
jsdat <- jsdat %>%
  group_by(state, year, office) %>%
  arrange(dist) %>%
  fill(dist, .direction = "down") %>%
  mutate(dist = replace(dist, state == "AL" & office == "S" & type == "S" & year == 2017, 2),
         dist = replace(dist, state == "AZ" & office == "S" & type == "S" & year == 2020, 3),
         dist = replace(dist, state == "LA" & office == "H" & name == "LETLOW, JULIA", 5))

# write
write_rds(jsdat, "data/intermediate/snyder_2006-2020.rds")
