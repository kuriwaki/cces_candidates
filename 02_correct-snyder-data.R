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

# Fixing 2020 Georgia Special candidates
jsdat <- jsdat %>%
  mutate(temp = ifelse(state == "GA" & year == 2020 & type == "S", 1, 0) ,
         temp = replace(temp, name == "LOEFFLER, KELLY" |
                         name == "WARNOCK, RAPHAEL GAMALIEL", 0)) %>%
  filter(temp == 0) %>%
  select(-temp) %>%
  mutate(vote_g = replace(vote_g, name == "LOEFFLER, KELLY", 2195841),
         vote_g = replace(vote_g, name == "WARNOCK, RAPHAEL GAMALIEL", 2289113),
         vote_g = replace(vote_g, name == "OSSOFF, JON", 2269923),
         vote_g = replace(vote_g, name == "PERDUE, DAVID A.", 2214979))


# write
write_rds(jsdat, "data/intermediate/snyder_2006-2020.rds")
