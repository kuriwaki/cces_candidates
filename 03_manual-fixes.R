jsdat_raw <- readRDS("data/intermediate/prelim/candidates_party-recoded.rds")

# Changes, additions ---
jsdat <- jsdat_raw |>
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
  ) |>
  # https://github.com/kuriwaki/cces_candidates/issues/21: missing election
  add_row(state = "OK", year = 2016, office = "H", dist = 1,
          type = "G", nextup = 2018,
          party = "R",
          name = "BRIDENSTINE, JAMES FREDERICK (JIM)", inc = 1,
          w_g = 1, u_g = 1,
          vote_g = NA) |>
  bind_rows(
    tibble::tribble(
      ~state, ~year, ~office, ~dist, ~type, ~nextup, ~party,           ~name, ~w_g, ~u_g, ~inc, ~vote_g,
      "LA", 2022, "H", 4, "G", 2024, "R", "JOHNSON, MIKE",    1,    1,    1, NA,
      "LA", 2006, "H", 5, "G", 2008, "D", "HEARN, WILLIAMS GLORIA",0,1,0,33233,
      "LA", 2006, "H", 5, "G", 2008, "Lbt", "SANDERS, BRENT",0,1,0,1876,
      "LA", 2006, "H", 5, "G", 2008, "I", "WATTS, JOHN",0,1,0,1262,
      "LA", 2006, "H", 7, "G", 2008, "D", "STAGG, MIKE",0,1,0,47133,
    )
  )

# Senate dist issue
jsdat <- jsdat |>
  group_by(state, year, office) |>
  arrange(dist) |>
  fill(dist, .direction = "down") |>
  ungroup() |>
  mutate(
    dist = replace(dist, state == "AL" & office == "S" & type == "S" & year == 2017, 2),
    dist = replace(dist, state == "AZ" & office == "S" & type == "S" & year == 2020, 3),
    dist = replace(dist, state == "GA" & office == "S" & type == "S" & year == 2020, 3),
    nextup = replace(nextup, state == "GA" & office == "S" & type == "S" & year == 2020, 2022),
    type = replace(type, state == "DE" & office == "S" & year == 2010, "S"),
    type = replace(type, state == "WY" & office == "S" & year == 2008 & dist == 1, "S"),
    dist = replace(dist, state == "LA" & office == "H" & name == "LETLOW, JULIA", 5),
    dist = replace(dist, state == "OK"   & type == "S" & office == "S" & year == 2022, 2),
    nextup = replace(nextup, state == "OK" & type == "S" & office == "S" & year == 2022, 2026),
    dist = replace(dist, state == "CA" & office == "S" & year == 2022, 3),
  ) |>
  # padilla was up for 2 cycles
  tidylog::filter(!(type == "S" & state == "CA" & year == 2022 & office == "S"))

# Adding Georgia 2020 elections
jsdat <- jsdat |>
  # Special election (unexpired term) - Warnock
  add_row(state = "GA", year = 2020, office = "S", dist = 3, type = "G",
          name = "WARNOCK, RAPHAEL GAMALIEL", party = "D", vote_g = 2289113) %>%
  add_row(state = "GA", year = 2020, office = "S", dist = 3, type = "G",
          name = "JACKSON, DEBORAH", party = "D", vote_g = 324118) %>%
  add_row(state = "GA", year = 2020, office = "S", dist = 3, type = "G",
          name = "LIEBERMAN, MATT", party = "D", vote_g = 136021) %>%
  add_row(state = "GA", year = 2020, office = "S", dist = 3, type = "G",
          name = "JOHNSON-SHEALEY, TAMARA", party = "D", vote_g = 106767) %>%
  add_row(state = "GA", year = 2020, office = "S", dist = 3, type = "G",
          name = "JAMES, JAMESIA", party = "D", vote_g = 94406) %>%
  add_row(state = "GA", year = 2020, office = "S", dist = 3, type = "G",
          name = "SLADE, JOY FELICIA", party = "D", vote_g = 44945) %>%
  add_row(state = "GA", year = 2020, office = "S", dist = 3, type = "G",
          name = "WINFIELD, RICHARD DIEN", party = "D", vote_g = 28687) %>%
  add_row(state = "GA", year = 2020, office = "S", dist = 3, type = "G",
          name = "TARVER, ED", party = "D", vote_g = 26333) %>%
  add_row(state = "GA", year = 2020, office = "S", dist = 3, type = "G",
          name = "LOEFFLER, KELLY", party = "R", vote_g = 2195841) %>%
  add_row(state = "GA", year = 2020, office = "S", dist = 3, type = "G",
          name = "COLLINS, DOUG", party = "R", vote_g = 980454) %>%
  add_row(state = "GA", year = 2020, office = "S", dist = 3, type = "G",
          name = "GRAYSON, DERRICK E.", party = "R", vote_g = 51592) %>%
  add_row(state = "GA", year = 2020, office = "S", dist = 3, type = "G",
          name = "DAVIS JACKSON, ANNETTE", party = "R", vote_g = 44335) %>%
  add_row(state = "GA", year = 2020, office = "S", dist = 3, type = "G",
          name = "TAYLOR, KANDISS", party = "R", vote_g = 40349) %>%
  add_row(state = "GA", year = 2020, office = "S", dist = 3, type = "G",
          name = "JOHNSON, A. WAYNE", party = "R", vote_g = 36176) %>%
  add_row(state = "GA", year = 2020, office = "S", dist = 3, type = "G",
          name = "SLOWINSKI, BRIAN", party = NA, vote_g = 35431) %>%
  add_row(state = "GA", year = 2020, office = "S", dist = 3, type = "G",
          name = "BUCKLEY, ALLEN", party = NA, vote_g = 17954) %>%
  add_row(state = "GA", year = 2020, office = "S", dist = 3, type = "G",
          name = "FORTUIN, JOHN GREEN", party = NA, vote_g = 15293) %>%
  add_row(state = "GA", year = 2020, office = "S", dist = 3, type = "G",
          name = "BARTELL, AL", party = NA, vote_g = 14640) %>%
  add_row(state = "GA", year = 2020, office = "S", dist = 3, type = "G",
          name = "STOVALL, VALENCIA", party = NA, vote_g = 13318) %>%
  add_row(state = "GA", year = 2020, office = "S", dist = 3, type = "G",
          name = "GREENE, MICHAEL TODD", party = NA, vote_g = 13293) %>%
  add_row(state = "GA", year = 2020, office = "S", dist = 3, type = "G",
          name = "MACK, ROD", party = NA, vote_g = 7) %>%

  # Regular election (full term) - Ossoff
  add_row(state = "GA", year = 2021, office = "S", dist = 2, type = "G",
          name = "OSSOFF, JON", party = "D", vote_g = 2269923) %>%
  add_row(state = "GA", year = 2021, office = "S", dist = 2, type = "G",
          name = "PERDUE, DAVID A.", party = "R", vote_g = 2214979) %>%
  add_row(state = "GA", year = 2021, office = "S", dist = 2, type = "G",
          name = "HAZEL, SHANE", party = NA, vote_g = 115039) |>

  # Special runoff - Warnock vs. Loeffler 2021
  add_row(state = "GA", year = 2021, office = "S", dist = 3, type = "S",
        name = "WARNOCK, RAPHAEL GAMALIEL", party = "D", vote_g = 2289113) %>%
  add_row(state = "GA", year = 2021, office = "S", dist = 3, type = "S",
          name = "LOEFFLER, KELLY", party = "R", vote_g = 2195841)

#
# # Fixing 2020 Georgia Special candidates
# jsdat <- jsdat |>
#   # remove runoff only candidates
#   mutate(
#     temp = ifelse((state == "GA" & year %in% 2020:2022 & office == "S"), 1, 0),
#     temp = replace(temp, name %in% c("LOEFFLER, KELLY", "WARNOCK, RAPHAEL GAMALIEL",
#                                      "WALKER, HERSCHEL JUNIOR",
#                                      "OSSOFF, JON", "PERDUE, DAVID A."), 0)
#   ) |>
#   tidylog::filter(temp == 0) |>
#   select(-temp) |>
#   mutate(
#     vote_g = replace(vote_g, year == 2020 & state == "GA" & office == "S" & name == "LOEFFLER, KELLY", 2195841),
#     vote_g = replace(vote_g, year == 2020 & state == "GA" & office == "S" & name == "WARNOCK, RAPHAEL GAMALIEL", 2289113),
#     vote_g = replace(vote_g, year == 2022 & state == "GA" & office == "S" & name == "WALKER, HERSCHEL JUNIOR", 1721244),
#     vote_g = replace(vote_g, year == 2022 & state == "GA" & office == "S" & name == "WARNOCK, RAPHAEL GAMALIEL", 1820633),
#     vote_g = replace(vote_g, year == 2020 & state == "GA" & office == "S" & name == "OSSOFF, JON", 2269923),
#     vote_g = replace(vote_g, year == 2020 & state == "GA" & office == "S" & name == "PERDUE, DAVID A.", 2214979)
#   )

# Adding "runoff" variable and removing extraneous candidates
## Georgia data comes from https://sos.ga.gov/index.php/Elections/current_and_past_elections_results
## Louisiana data comes from https://voterportal.sos.la.gov/graphical
jsdat <- jsdat |>
  mutate(
    temp = 0, # Temporary var that ids non-runoff candidates
    temp = replace(temp, state == "LA" & year == 2020 & dist == 5, 1),
    temp = replace(temp, name == "LETLOW, LUKE J." & year == 2020 |
                     name == "HARRIS, LANCE" & year == 2020, 0)
  ) |>
  filter(temp == 0,
         name != "BUCKLEY, ALLEN" | year != 2008) |>
  select(-temp) |>
  mutate(runoff = case_when(
    state == "GA" & year == 2022 & office == "S" ~ 1, # 2022 Georgia Runoff
    state == "GA" & year == 2021 & office == "S" ~ 1, # 2020 Georgia Runoff
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
  )) |>
  mutate(runoff = case_when(
    state == "GA" | state == "LA" ~ runoff,
    TRUE ~ NA_real_
  ))

# Correcting vote totals to reflect runoffs
jsdat <- jsdat |>
  mutate(vote_g = case_when(
    year == 2008 & state == "GA" & name == "MARTIN, JAMES FRANCIS (JIM)" ~ 909923,
    year == 2008 & state == "GA" & name == "CHAMBLISS, C. SAXBY" ~ 1228033,
    year == 2020 & state == "LA" & name == "LETLOW, LUKE J." ~ 49183,
    year == 2020 & state == "LA" & name == "HARRIS, LANCE" ~ 30124,
    TRUE ~ vote_g
  ))

# Fix Oregon 2018 Gov winner
jsdat <- jsdat |>
  mutate(w_g = replace(w_g, year == 2018 & state == "OR" & office == "G" & name == "BUEHLER, KNUTE", 0))

# Fix Rhode Island 2006 Gov results
jsdat <- jsdat |>
  mutate(w_g = replace(w_g, year == 2006 & state == "RI" & office == "G" & name == "CARCIERI, DONALD L.", 1),
         w_g = replace(w_g, year == 2006 & state == "RI" & office == "G" & name == "FOGARTY, CHARLES J.", 0),
         vote_g = replace(vote_g, year == 2006 & state == "RI" & office == "G" & name == "CARCIERI, DONALD L.", 197306),
         vote_g = replace(vote_g, year == 2006 & state == "RI" & office == "G" & name == "FOGARTY, CHARLES J.", 189503),
  )

# Karin Housley w_g fix
jsdat <- jsdat |>
  mutate(w_g = replace(w_g, year == 2018 & state == "MN" & name == "HOUSLEY, KARIN", 0))

# removing Ellen Brickley
jsdat <- jsdat |>
  filter(name != "BRICKLEY, ELLEN")

# NC-09 election fraud case
jsdat <- jsdat |>
  mutate(w_g = replace(w_g, office == "H" & year == 2018 & state == "NC" & dist == 9 & type == "G", NA))

# removing duplicates or not-rans
jsdat <- jsdat |>
  # duplicate entry with VAN DUYNE
  filter(!(office == "H" & state == "TX" & dist == 24 & year == 2022 & name == "VANDUYNE, BETH")) |>
  # rest were primary losses, not in general
  filter(!(office == "H" & state == "FL" & dist == 5 & year == 2022 & name != "RUTHERFORD, JOHN H.")) |>
  # no votes
  tidylog::filter(!(office == "H" & state == "CT" & dist == 4 & year == 2022 & name == "GOLDSTEIN, MICHAEL TED")) |>
  # writein
  tidylog::mutate(party = replace(party, name == "SMITH, DELLA JEAN (DJ)" & year == 2016, "W-I")) |>
  tidylog::mutate(party = replace(party, name == "RAMSBURG, KAREN LYNN" & year == 2012, "D")) |>
  tidylog::mutate(party = replace(party, name != "VAN HOLLEN, CHRISTOPHER (CHRIS), JR." & year == 2016 & office == "S" & party == "D" & state == "MD", "W-I"))

# add incumbency fixes
jsdat <- jsdat |>
  mutate(
    inc = replace(inc, office == "S" & state == "MO" & year == 2016 & party %in% c("Grn", "I"), 0),
    inc = replace(inc, office == "S" & state == "NV" & year == 2016 & party %in% c(""), 0),
    inc = replace(inc, office == "S" & state == "SD" & year == 2014, 0),
    inc = replace(inc, office == "S" & state == "NJ" & year == 2013, 0),
    inc = replace(inc, office == "S" & state == "MA" & year == 2013 & party == "12 Visions Pty", 0),
    inc = replace(inc, office == "H" & state == "LA" & year == 2021 & name == "LETLOW, JULIA", 0),
    inc = replace(inc, office == "H" & state == "KS" & year == 2017 & name == "ROCKHOLD, CHRIS", 0),
    inc = replace(inc, office %in% c("H", "S") & year %% 2 == 0 & party %in% c("Grn", "Lbt", "W-I", "", "US Taxpayers"), 0)
  )

# fix IN-02 Walorski result
jsdat <- jsdat |>
  mutate(w_g = replace(w_g, name == "STEURY, PAUL D." & office == "H" & year == 2022, 0))

# removing entries without names
jsdat <- jsdat |>
  filter(name != "" | !is.na(vote_g))

# adding in vote totals
jsdat <- jsdat |>
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

# Fixing FLORES, MAYRA
jsdat <- jsdat |>
  mutate(
    vote_g = replace(vote_g, name == "FLORES, MAYRA" & year == 2022 & type == "S", 14799)
  )

# Adding Ryan, Pat

# addressing issue 25: TX-23 special election runoff
jsdat <- jsdat |>
  filter(
    !(year == 2006 & state == "TX" & office == "H" & dist == 23 & vote_g < 24594)
  ) |>
  mutate(type = replace(type, year == 2006 & state == "TX" & dist == 23, "G"),
         runoff = replace(runoff, year == 2006 & state == "TX" & dist == 23, 1),
         vote_g = replace(vote_g, year == 2006 & state == "TX" & dist == 23 & party == "R", 32217),
         vote_g = replace(vote_g, year == 2006 & state == "TX" & dist == 23 & party == "D", 38256),
         w_g = replace(w_g, year == 2006 & state == "TX" & dist == 23 & party == "R", 0),
         w_g = replace(w_g, year == 2006 & state == "TX" & dist == 23 & party == "D", 1))

# addressing issues 9, 10, 13, 14, 16, 17, 18, 19, 20
house_append <- read.csv("data/intermediate/cand_house_append.csv")
jsdat <- bind_rows(jsdat, house_append)

# Missing inc values (#41)
jsdat <- jsdat |>
  left_join(
    tibble::tribble(
      ~state, ~year, ~office,                               ~name, ~inc,
      "IN",  2012,     "G",                   "BONEHAM, RUPERT",  0,
      "IN",  2012,     "G",                    "GREGG, JOHN R.",  0,
      "KY",  2015,     "G",                       "BEVIN, MATT",  0,
      "KY",  2015,     "G",                      "CURTIS, DREW",  0,
      "LA",  2015,     "G",                 "EDWARDS, JOHN BEL",  0,
      "MO",  2016,     "G",                         "FITZ, DON",  0,
      "MO",  2016,     "G", "TURILLI, LESTER BENTON (LES), JR.",  0,
      "VA",  2013,     "G",               "MCAULIFFE, TERRY R.",  0,
      "VA",  2013,     "G",                 "SARVIS, ROBERT C.",  0
    ),
    by = c("state", "year", "office", "name"),
    relationship = "one-to-one"
  ) |>
  mutate(inc = coalesce(inc.y, inc.x),
         inc.x = NULL,
         inc.y = NULL)

# Name recodings
#45
jsdat <- jsdat |>
  tidylog::mutate(name = str_replace(name, "Ê", " "))


if (FALSE) {
  # Corrections to 1990-2005 ------------------------------------------------
  js1990_raw <- read_dta("data/snyder/2022-09-30 tmp_gov_sen_house_1990_2020.dta")

  js1990 <- js1990_raw |>
    filter(year < 2006)

  empty <- js1990 |>
    filter(is.na(vote_g))

  # Lot's of Louisiana to manually figure out

  nowin <- js1990 |>
    group_by(year, state, office, dist) |>
    summarise(win = sum(w_g)) |>
    filter(win == 1)

  # At least one winner per contest

  hdist <- js1990 |>
    filter(office == "H") |>
    group_by(year) |>
    summarise(win = sum(w_g))

  # Pretty good numbers - should check this against Brookings/Wikipedia

  sdist <- js1990 |>
    filter(office == "S") |>
    group_by(year) |>
    summarise(win = sum(w_g))
}

# #35 "Standardized names -- Joe Kennedy III
# #43
cand <- jsdat %>%
  tidylog::mutate(name_snyder = case_match(
    name_snyder,
    "BOYDA, NANCY\xcaE." ~ "BOYDA, NANCY E.",
    "KENNEDY, JOSEPH P., III" ~ "KENNEDY, JOSEPH P. (JOE), III",
    "BEUTLER, JAIME HERRERA" ~ "HERRERA BEUTLER, JAIME",
    "DEAN, MADELEINE" ~ "DEAN CUNNANE, MADELEINE",
    "WAKELY, TOMMY" ~ "WAKELY, THOMAS J. (TOM)",
    "CUELLAR, HENRY" ~ "CUELLAR, ENRIQUE ROBERTO (HENRY)",
    "SHERRILL, MIKIE" ~ "SHERRILL, REBECCA MICHELLE (MIKIE)",
    "KELLY, TRENT" ~ "KELLY, JOHN TRENT",
    "GARCIA, CHUY" ~ "GARCIA, JESUS G. (CHUY)",
    "SCOTT, JAMES AUSTIN" ~ "SCOTT, AUSTIN",
    "FERGUSON, DREW" ~ "FERGUSON, ANDREW DREW, IV",
    "STEUBE, GREG" ~ "STEUBE, W. GREGORY (GREG)",
    .default = name_snyder
  ))


# #26 "Missing gubernatorial candidate states"
cand <- cand %>%
  mutate(
    state = replace(state, state == "" & year == 2011 & office == "G", "LA")
  )

# #27 "Three last name misspellings"
cand <- cand %>%
  mutate(
    name_snyder = replace(name_snyder, str_detect(name_snyder, "YEVANCY"), "YEVANCEY, MANNY"),
    name_snyder = replace(name_snyder, str_detect(name_snyder, "STANCZACK"), "STANCZAK, JAMES"),
    name_snyder = replace(name_snyder, str_detect(name_snyder, "WEIDER"), "WIEDER, JOHN")
  )

# #29 "Fix Ron Caesar Spelling"
cand <- cand %>%
  mutate(
    name_snyder = replace(name_snyder, name_snyder == "CEASAR, RON" & state == "LA", "CAESAR, RON")
  )

# #30 "Corrections on incumbency"
cand <- cand %>%
  mutate(
    inc = replace(inc, name_snyder == "BREWER, JANICE (JAN)" & state == "AZ" & office == "G" & year == 2010, 1),
    inc = replace(inc, name_snyder == "MURRAY, JULIANNE E." & state == "DE" & office == "G" & year == 2020, 0)
  )


# 2024 corrections
cand <- cand |>
  cand <- cand |>
  # Adding in NY-15
  add_row(
    state = "NY",
    year = 2024,
    office = "H",
    party = "D",
    name = "TORRES, RITCHIE",
    dist = "15",
    type = "G",
    nextup = "2026",
    inc = "1",
    vote_g = "130392",
    w_g = "1",
    vote_g_share = "0.6915697"
  ) |>
  add_row(
    state = "NY",
    year = 2024,
    office = "H",
    party = "R",
    name = "DURAN, GONZALEZ",
    dist = "15",
    type = "G",
    nextup = "2026",
    inc = "0",
    vote_g = "36010",
    w_g = "0",
    vote_g_share = "0.1909889"
  ) |>
  add_row(
    state = "NY",
    year = 2024,
    office = "H",
    party = "I",
    name = "JOSE VEGA, LAROUCHE",
    dist = "15",
    type = "G",
    nextup = "2026",
    inc = "0",
    vote_g = "0",
    w_g = "0",
    vote_g_share = "0.02167122"
  ) |>

  # Adding in Maine, Vermont Senate
  add_row(
    state = "ME",
    year = 2024,
    office = "S",
    party = "D",
    name = "COSTELLO, DAVID ALLEN",
    dist = "2",
    type = "G",
    nextup = "2026",
    inc = "1",
    vote_g = "0",
    w_g = "1",
    vote_g_share = "0.5970149"
  ) |>
  add_row(
    state = "ME",
    year = 2024,
    office = "S",
    party = "R",
    name = "KOUZOUNAS, DEMI",
    dist = "2",
    type = "G",
    nextup = "2030",
    inc = "0",
    vote_g = "284338",
    w_g = "0",
    vote_g_share = "0.3376"
  ) |>
  add_row(
    state = "ME",
    year = 2024,
    office = "S",
    party = "D",
    name = "COSTELLO, DAVID ALLEN",
    dist = "2",
    type = "G",
    nextup = "2030",
    inc = "0",
    vote_g = "88891",
    w_g = "0",
    vote_g_share = "0.1056"
  ) |>
  add_row(
    state = "ME",
    year = 2024,
    office = "S",
    party = "Indep",
    name = "KING, ANGUS S., JR.",
    dist = "2",
    type = "G",
    nextup = "2030",
    inc = "1",
    vote_g = "427331",
    w_g = "1",
    vote_g_share = "0.5073"
  ) |>
  add_row(
    state = "ME",
    year = 2024,
    office = "S",
    party = "Indep",
    name = "CHERRY, JASON S.",
    dist = "2",
    type = "G",
    nextup = "2030",
    inc = "0",
    vote_g = "20222",
    w_g = "0",
    vote_g_share = "0.0240"
  ) |>
  add_row(
    state = "VT",
    year = 2024,
    office = "S",
    party = "R",
    name = "MALLOY, GERALD",
    dist = "2",
    type = "G",
    nextup = "2030",
    inc = "0",
    vote_g = "116512",
    w_g = "0",
    vote_g_share = "0.3212"
  ) |>
  add_row(
    state = "VT",
    year = 2024,
    office = "S",
    party = "Indep",
    name = "SANDERS, BERNARD",
    dist = "2",
    type = "G",
    nextup = "2030",
    inc = "1",
    vote_g = "229429",
    w_g = "1",
    vote_g_share = "0.6322"
  ) |>
  add_row(
    state = "VT",
    year = 2024,
    office = "S",
    party = "Indep",
    name = "BERRY, STEVE",
    dist = "2",
    type = "G",
    nextup = "2030",
    inc = "0",
    vote_g = "7941",
    w_g = "0",
    vote_g_share = "0.0219"
  ) |>
  add_row(
    state = "VT",
    year = 2024,
    office = "S",
    party = "L",
    name = "HILL, MATT",
    dist = "2",
    type = "G",
    nextup = "2030",
    inc = "0",
    vote_g = "4530",
    w_g = "0",
    vote_g_share = "0.0125"
  ) |>
  add_row(
    state = "VT",
    year = 2024,
    office = "S",
    party = "Green Mountain Peace and Justice",
    name = "SCHOVILLE, JUSTIN",
    dist = "2",
    type = "G",
    nextup = "2030",
    inc = "0",
    vote_g = "3339",
    w_g = "0",
    vote_g_share = "0.0092"
  ) |>
  add_row(
    state = "VT",
    year = 2024,
    office = "S",
    party = "Epic",
    name = "STEWART GREENSTEIN, MARK",
    dist = "2",
    type = "G",
    nextup = "2030",
    inc = "0",
    vote_g = "1104",
    w_g = "0",
    vote_g_share = "0.0030"
  )


write_rds(cand, "data/intermediate/candidates_2006-2024.rds")
