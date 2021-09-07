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

# Adding "runoff" variable and removing extraneous candidates
## Georgia data comes from https://sos.ga.gov/index.php/Elections/current_and_past_elections_results
## Louisiana data comes from https://voterportal.sos.la.gov/graphical
jsdat <- jsdat %>%
  mutate(temp = 0, # Temporary var that ids non-runoff candidates
         temp = replace(temp, state == "LA" & year == 2020 & dist == 5, 1),
         temp = replace(temp, name == "LETLOW, LUKE J." & year == 2020 |
                          name == "HARRIS, LANCE" & year == 2020, 0)) %>%
  filter(temp == 0 |
         (name != "BUCKLEY, ALLEN" & year != 2008)) %>%
  select(-temp) %>%
  mutate(runoff = case_when(
    state == "GA" & year == 2020 & office == "S" ~ 1, # 2020 Georgia Runoff
    state == "GA" & year == 2007 & office == "H" & dist == 10 ~ 1,
    state == "GA" & year == 2008 & office == "S" ~ 1,
    state == "GA" & year == 2010 & dist == 9 & type == "S" ~ 1,
    state == "GA" & year == 2017 & dist == 6 & type == "S" ~ 1,
    state == "LA" & year == 2020 & dist == 5 & type == "G" ~ 1,
    state == "LA" & year == 2016 & office == "S" ~ 1,
    state == "LA" & year == 2016 & dist == 3 & type == "G" ~ 1,
    state == "LA" & year == 2016 & dist == 3 & type == "G" ~ 1,
    state == "LA" & year == 2014 & office == "S" ~ 1,
    state == "LA" & year == 2014 & office == "H" & dist == 5 ~ 1,
    state == "LA" & year == 2014 & office == "H" & dist == 6 ~ 1,
    state == "LA" & year == 2013 & office == "H" & dist == 5 ~ 1,
    state == "LA" & year == 2012 & office == "H" & dist == 3 ~ 1,
    state == "LA" & year == 2006 & office == "H" & dist == 2 ~ 1,
    TRUE ~ 0
    )
  )

# Correcting vote totals to reflect runoffs
jsdat <- jsdat %>%
  mutate(vote_g = case_when(
    year == 2008 & name == "MARTIN, JAMES FRANCIS (JIM)" ~ 909923,
    year == 2008 & name == "CHAMBLISS, C. SAXBY" ~ 1228033,
    year == 2020 & name == "LETLOW, LUKE J." ~ 49183,
    year == 2020 & name == "HARRIS, LANCE" ~ 30124
    )
  )

# Karin Housley w_g fix
jsdat <- jsdat %>%
  mutate(w_g = replace(w_g, name == "HOUSLEY, KARIN" & year == 2018, 0))

# write
write_rds(jsdat, "data/intermediate/snyder_2006-2020.rds")
