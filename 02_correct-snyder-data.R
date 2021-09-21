library(tidyverse)
library(haven)

# raw
jsdat_raw <- read_dta("data/snyder/2021-07-29 sen_gov_house_2006_2020.dta")

# Changes, additions ---

jsdat <- jsdat_raw %>%
  # https://github.com/kuriwaki/cces_candidates/issues/7: same day special
  mutate(
    type = replace(
      x = type,
      list = (year == 2006 & state == "TX" & dist == 22 & nextup == 2006),
      values = "S"
    ),
    type = replace(
      x = type,
      list = (year == 2006 & state == "TX" & dist == 22 & nextup == 2008),
      values = "G"
    )
  ) %>%
  # https://github.com/kuriwaki/cces_candidates/issues/21: missing election
  add_row(state = "OK", year = 2016, office = "H", dist = 1,
          type = "G", nextup = 2018,
          party = "R",
          name = "BRIDENSTINE, JAMES FREDERICK (JIM)", inc = 1,
          w_g = 1, u_g = 1,
          vote_g = NA)

# Senate dist issue
jsdat <- jsdat %>%
  group_by(state, year, office) %>%
  arrange(dist) %>%
  fill(dist, .direction = "down") %>%
  mutate(
    dist = replace(dist, state == "AL" & office == "S" & type == "S" & year == 2017, 2),
    dist = replace(dist, state == "AZ" & office == "S" & type == "S" & year == 2020, 3),
    dist = replace(dist, state == "GA" & office == "S" & type == "S" & year == 2020, 3),
    nextup = replace(nextup, state == "GA" & office == "S" & type == "S" & year == 2020, 2022),
    type = replace(type, state == "DE" & office == "S" & year == 2010, "S"),
    type = replace(type, state == "WY" & office == "S" & year == 2008 & dist == 1, "S"),
    dist = replace(dist, state == "LA" & office == "H" & name == "LETLOW, JULIA", 5)
  )

# Fixing 2020 Georgia Special candidates
jsdat <- jsdat %>%
  mutate(
    temp = ifelse(state == "GA" & year == 2020 & type == "S", 1, 0),
    temp = replace(temp, name == "LOEFFLER, KELLY" | name == "WARNOCK, RAPHAEL GAMALIEL", 0)
  ) %>%
  filter(temp == 0) %>%
  select(-temp) %>%
  mutate(
    vote_g = replace(vote_g, year == 2020 & state == "GA" & office == "S" & name == "LOEFFLER, KELLY", 2195841),
    vote_g = replace(vote_g, year == 2020 & state == "GA" & office == "S" & name == "WARNOCK, RAPHAEL GAMALIEL", 2289113),
    vote_g = replace(vote_g, year == 2020 & state == "GA" & office == "S" & name == "OSSOFF, JON", 2269923),
    vote_g = replace(vote_g, year == 2020 & state == "GA" & office == "S" & name == "PERDUE, DAVID A.", 2214979)
  )

# Adding "runoff" variable and removing extraneous candidates
## Georgia data comes from https://sos.ga.gov/index.php/Elections/current_and_past_elections_results
## Louisiana data comes from https://voterportal.sos.la.gov/graphical
jsdat <- jsdat %>%
  mutate(
    temp = 0, # Temporary var that ids non-runoff candidates
    temp = replace(temp, state == "LA" & year == 2020 & dist == 5, 1),
    temp = replace(temp, name == "LETLOW, LUKE J." & year == 2020 |
      name == "HARRIS, LANCE" & year == 2020, 0)
  ) %>%
  filter(temp == 0,
    name != "BUCKLEY, ALLEN" | year != 2008) %>%
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
  )) %>%
  mutate(runoff = case_when(
    state == "GA" | state == "LA" ~ runoff,
    TRUE ~ NA_real_
  ))

# Correcting vote totals to reflect runoffs
jsdat <- jsdat %>%
  mutate(vote_g = case_when(
    year == 2008 & state == "GA" & name == "MARTIN, JAMES FRANCIS (JIM)" ~ 909923,
    year == 2008 & state == "GA" & name == "CHAMBLISS, C. SAXBY" ~ 1228033,
    year == 2020 & state == "LA" & name == "LETLOW, LUKE J." ~ 49183,
    year == 2020 & state == "LA" & name == "HARRIS, LANCE" ~ 30124,
    TRUE ~ vote_g
  ))

# Fix Oregon 2018 Gov winner
jsdat <- jsdat %>%
  mutate(w_g = replace(w_g, year == 2018 & state == "OR" & office == "G" & name == "BUEHLER, KNUTE", 0))

# Fix Rhode Island 2006 Gov results
jsdat <- jsdat %>%
  mutate(w_g = replace(w_g, year == 2006 & state == "RI" & office == "G" & name == "CARCIERI, DONALD L.", 1),
         w_g = replace(w_g, year == 2006 & state == "RI" & office == "G" & name == "FOGARTY, CHARLES J.", 0),
         vote_g = replace(vote_g, year == 2006 & state == "RI" & office == "G" & name == "CARCIERI, DONALD L.", 197306),
         vote_g = replace(vote_g, year == 2006 & state == "RI" & office == "G" & name == "FOGARTY, CHARLES J.", 189503),
         )

# Karin Housley w_g fix
jsdat <- jsdat %>%
  mutate(w_g = replace(w_g, year == 2018 & state == "MN" & name == "HOUSLEY, KARIN", 0))

# removing Ellen Brickley
jsdat <- jsdat %>%
  filter(name != "BRICKLEY, ELLEN")

# NC-09 election fraud case
jsdat <- jsdat %>%
  mutate(w_g = replace(w_g, office == "H" & year == 2018 & state == "NC" & dist == 9 & type == "G", NA))


# removing entries without names
jsdat <- jsdat %>%
  filter(name != "" | !is.na(vote_g))

# adding in vote totals
jsdat <- jsdat %>%
  mutate(vote_g = replace(vote_g, name == "JINDAL, BOBBY" & office == "H" & year == 2006 & state == "LA", 130508),
         vote_g = replace(vote_g, name == "MCCRERY, JAMES O. (JIM)" & office == "H" & year == 2006 & state == "LA", 77078),
         vote_g = replace(vote_g, name == "ALEXANDER, RODNEY M." & office == "H" & year == 2006 & state == "LA", 78211),
         vote_g = replace(vote_g, name == "BOUSTANY, CHARLES W., JR." & office == "H" & year == 2006 & state == "LA", 113720),
         vote_g = replace(vote_g, name == "BAKER, RICHARD HUGH" & office == "H" & year == 2006 & state == "LA", 94658),
         vote_g = replace(vote_g, name == "MELANCON, CHARLES J. (CHARLIE), JR." & office == "H" & year == 2006 & state == "LA", 75023),
         vote_g = replace(vote_g, name == "JINDAL, BOBBY" & office == "G" & year == 2007 & state == "LA", 699275),
         vote_g = replace(vote_g, name == "GAIERO, THEODORE J., JR." & office == "H" & year == 2008 & state == "MA", 114),
         vote_g = replace(vote_g, name == "SPEIER, KAREN (JACKIE)" & type == "S" & year == 2008 & state == "CA", 66279),
         vote_g = replace(vote_g, name == "DJOU, CHARLES KONG" & type == "S" & year == 2010 & state == "HI", 67610),
         vote_g = replace(vote_g, name == "PAYNE, DONALD M. (DON), JR." & type == "S" & year == 2012 & state == "NJ", 166413),
         vote_g = replace(vote_g, name == "SCALISE, STEPHEN J. (STEVE)" & type == "G" & year == 2012 & state == "LA", 193496),
         vote_g = replace(vote_g, name == "RICHMOND, CEDRIC L." & type == "G" & year == 2012 & state == "LA", 158501),
         vote_g = replace(vote_g, name == "FLEMING, JOHN C., JR." & type == "G" & year == 2012 & state == "LA", 187894),
         vote_g = replace(vote_g, name == "ALEXANDER, RODNEY M." & type == "G" & year == 2012 & state == "LA", 202536),
         vote_g = replace(vote_g, name == "CASSIDY, WILLIAM (BILL)" & type == "G" & year == 2012 & state == "LA", 243553),
         vote_g = replace(vote_g, name == "SCALISE, STEPHEN J. (STEVE)" & type == "G" & year == 2014 & state == "LA", 189250),
         vote_g = replace(vote_g, name == "RICHMOND, CEDRIC L." & type == "G" & year == 2014 & state == "LA", 152201),
         vote_g = replace(vote_g, name == "BOUSTANY, CHARLES W., JR." & type == "G" & year == 2014 & state == "LA", 185867),
         vote_g = replace(vote_g, name == "FLEMING, JOHN C., JR." & type == "G" & year == 2014 & state == "LA", 152683),
         vote_g = replace(vote_g, name == "SCALISE, STEPHEN J. (STEVE)" & type == "G" & year == 2016 & state == "LA", 243645),
         vote_g = replace(vote_g, name == "RICHMOND, CEDRIC L." & type == "G" & year == 2016 & state == "LA", 198289),
         vote_g = replace(vote_g, name == "ABRAHAM, RALPH LEE" & type == "G" & year == 2016 & state == "LA", 208345),
         vote_g = replace(vote_g, name == "GRAVES, GARRET" & type == "G" & year == 2016 & state == "LA", 207483),
         vote_g = replace(vote_g, name == "MURPHY, GREGORY F. (GREG)" & type == "S" & year == 2019 & state == "NC", 70407),
         vote_g = replace(vote_g, name == "BISHOP, DAN" & type == "S" & year == 2019 & state == "NC", 96573),
         vote_g = replace(vote_g, name == "KELLER, FREDERICK B. (FRED)" & type == "S" & year == 2019 & state == "PA", 90000),
         vote_g = replace(vote_g, name == "LETLOW, JULIA" & type == "S" & year == 2021 & state == "LA", 67203),
         vote_g = replace(vote_g, name == "ROSSANO, TIMOTHY" & year == 2014 & state == "FL", 12),
         vote_g = replace(vote_g, name == "JINDAL, BOBBY" & office == "G" & year == 2011 & state == "LA", 673239)
         )

# addressing issue 25: TX-23 special election runoff
jsdat <- jsdat %>%
  filter(
    !(year == 2006 & state == "TX" & dist == 23 & vote_g < 24594)
  ) %>%
  mutate(type = replace(type, year == 2006 & state == "TX" & dist == 23, "S"),
         runoff = replace(runoff, year == 2006 & state == "TX" & dist == 23, 1),
         vote_g = replace(vote_g, year == 2006 & state == "TX" & dist == 23 & party == "R", 32217),
         vote_g = replace(vote_g, year == 2006 & state == "TX" & dist == 23 & party == "D", 38256),
         w_g = replace(w_g, year == 2006 & state == "TX" & dist == 23 & party == "R", 0),
         w_g = replace(w_g, year == 2006 & state == "TX" & dist == 23 & party == "D", 1))

# addressing issues 9, 10, 13, 14, 16, 17, 18, 19, 20
house_append <- read.csv("data/intermediate/cand_house_append.csv")
jsdat <- bind_rows(jsdat, house_append)

# write
write_rds(jsdat, "data/intermediate/snyder_2006-2020.rds")

