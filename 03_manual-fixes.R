jsdat_raw <- readRDS("data/intermediate/prelim/candidates_party-recoded.rds")

# Rename variables to match expected names (if needed)
if ("candidatevotes" %in% names(jsdat_raw)) {
  jsdat_raw <- jsdat_raw |> rename(vote_g = candidatevotes)
}
if ("won" %in% names(jsdat_raw)) {
  jsdat_raw <- jsdat_raw |> rename(w_g = won)
}
if ("name" %in% names(jsdat_raw)) {
  jsdat_raw <- jsdat_raw |> rename(name_snyder = name)
}

jsdat <- jsdat_raw


# MANUAL FIXES ============================================================

# Adding missing candidates ----

# Add LA candidates if not already present
la_additions <- tibble::tribble(
  ~state, ~year, ~office, ~dist, ~type, ~nextup, ~party, ~name_snyder, ~w_g, ~u_g, ~inc, ~vote_g,
  "LA", 2022, "H", 4, "G", 2024, "R", "JOHNSON, MIKE", 1, 1, 1, NA,
  "LA", 2006, "H", 5, "G", 2008, "D", "HEARN, WILLIAMS GLORIA", 0, 1, 0, 33233,
  "LA", 2006, "H", 5, "G", 2008, "Lbt", "SANDERS, BRENT", 0, 1, 0, 1876,
  "LA", 2006, "H", 5, "G", 2008, "I", "WATTS, JOHN", 0, 1, 0, 1262,
  "LA", 2006, "H", 7, "G", 2008, "D", "STAGG, MIKE", 0, 1, 0, 47133
)

# Only add rows that don't already exist
for (i in 1:nrow(la_additions)) {
  row <- la_additions[i, ]
  exists <- jsdat |>
    filter(state == row$state, year == row$year, office == row$office,
           dist == row$dist, name_snyder == row$name_snyder) |>
    nrow() > 0

  if (!exists) {
    jsdat <- jsdat |> add_row(!!!row)
  }
}


# Adding Georgia 2020/2021 elections ----

# Note: totalvotes, vote_g_share, and n will be recalculated at end of script
# 2020 Special election (Class 3, unexpired Isakson term) - jungle primary went to runoff
# 2021 is the runoff for that special election
# nextup = 2022 because winner serves remainder of Isakson's term (expires Jan 2023)
# Loeffler was appointed incumbent (inc = 1), all others are challengers (inc = 0)
ga_additions <- tibble::tribble(
  ~state, ~year, ~office, ~dist, ~type, ~nextup, ~party, ~name_snyder, ~vote_g, ~w_g, ~inc,
  # 2020 Special election (unexpired term) - jungle primary, no winner
  "GA", 2020, "S", 3, "G", 2022, "D", "WARNOCK, RAPHAEL GAMALIEL", 1617035, 0, 0,
  "GA", 2020, "S", 3, "G", 2022, "D", "JACKSON, DEBORAH", 324118, 0, 0,
  "GA", 2020, "S", 3, "G", 2022, "D", "LIEBERMAN, MATT", 136021, 0, 0,
  "GA", 2020, "S", 3, "G", 2022, "D", "JOHNSON-SHEALEY, TAMARA", 106767, 0, 0,
  "GA", 2020, "S", 3, "G", 2022, "D", "JAMES, JAMESIA", 94406, 0, 0,
  "GA", 2020, "S", 3, "G", 2022, "D", "SLADE, JOY FELICIA", 44945, 0, 0,
  "GA", 2020, "S", 3, "G", 2022, "D", "WINFIELD, RICHARD DIEN", 28687, 0, 0,
  "GA", 2020, "S", 3, "G", 2022, "D", "TARVER, ED", 26333, 0, 0,
  "GA", 2020, "S", 3, "G", 2022, "R", "LOEFFLER, KELLY", 1273214, 0, 1,
  "GA", 2020, "S", 3, "G", 2022, "R", "COLLINS, DOUG", 980454, 0, 0,
  "GA", 2020, "S", 3, "G", 2022, "R", "GRAYSON, DERRICK E.", 51592, 0, 0,
  "GA", 2020, "S", 3, "G", 2022, "R", "DAVIS JACKSON, ANNETTE", 44335, 0, 0,
  "GA", 2020, "S", 3, "G", 2022, "R", "TAYLOR, KANDISS", 40349, 0, 0,
  "GA", 2020, "S", 3, "G", 2022, "R", "JOHNSON, A. WAYNE", 36176, 0, 0,
  "GA", 2020, "S", 3, "G", 2022, "I", "SLOWINSKI, BRIAN", 35431, 0, 0,
  "GA", 2020, "S", 3, "G", 2022, "I", "BUCKLEY, ALLEN", 17954, 0, 0,
  "GA", 2020, "S", 3, "G", 2022, "I", "FORTUIN, JOHN GREEN", 15293, 0, 0,
  "GA", 2020, "S", 3, "G", 2022, "I", "BARTELL, AL", 14640, 0, 0,
  "GA", 2020, "S", 3, "G", 2022, "I", "STOVALL, VALENCIA", 13318, 0, 0,
  "GA", 2020, "S", 3, "G", 2022, "I", "GREENE, MICHAEL TODD", 13293, 0, 0,
  "GA", 2020, "S", 3, "G", 2022, "I", "MACK, ROD", 7, 0, 0,
  # 2021 Special runoff - Warnock vs. Loeffler (Jan 5, 2021 runoff)
  "GA", 2021, "S", 3, "S", 2022, "D", "WARNOCK, RAPHAEL GAMALIEL", 2289113, 1, 0,
  "GA", 2021, "S", 3, "S", 2022, "R", "LOEFFLER, KELLY", 2195841, 0, 1
)

# Only add rows that don't already exist
for (i in seq_len(nrow(ga_additions))) {
  row <- ga_additions[i, ]
  exists <- jsdat |>
    filter(state == row$state, year == row$year, office == row$office,
           dist == row$dist, name_snyder == row$name_snyder) |>
    nrow() > 0

  if (!exists) {
    jsdat <- jsdat |> add_row(!!!row)
  }
}

# Fixing 2020/2022 Georgia Special candidates
jsdat <- jsdat |>
  # remove runoff only candidates (but keep the main candidates)
  mutate(
    temp = ifelse((state == "GA" & year %in% 2020:2022 & office == "S"), 1, 0),
    temp = replace(temp, name_snyder %in% c("LOEFFLER, KELLY", "WARNOCK, RAPHAEL GAMALIEL",
                                     "WALKER, HERSCHEL JUNIOR",
                                     "OSSOFF, JON", "PERDUE, DAVID A."), 0)
  ) |>
  tidylog::filter(temp == 0) |>
  select(-temp) |>
  # Update vote_g for 2022 GA runoff candidates (2020/2021 already set when rows added)
  mutate(
    vote_g = replace(vote_g, year == 2022 & state == "GA" & office == "S" & name_snyder == "WALKER, HERSCHEL JUNIOR", 1721244),
    vote_g = replace(vote_g, year == 2022 & state == "GA" & office == "S" & name_snyder == "WARNOCK, RAPHAEL GAMALIEL", 1820633)
  ) |>
  # Fix incumbency for GA special elections
  # Loeffler was appointed incumbent, Warnock/Walker are challengers
  mutate(
    inc = replace(inc, state == "GA" & year %in% 2020:2022 & office == "S" & name_snyder == "LOEFFLER, KELLY", 1),
    inc = replace(inc, state == "GA" & year %in% 2020:2022 & office == "S" & name_snyder == "WARNOCK, RAPHAEL GAMALIEL", 0),
    inc = replace(inc, state == "GA" & year == 2022 & office == "S" & name_snyder == "WALKER, HERSCHEL JUNIOR", 0)
  )


# Runoff elections ----

# Adding "runoff" variable and removing extraneous candidates
## Georgia data comes from https://sos.ga.gov/index.php/Elections/current_and_past_elections_results
## Louisiana data comes from https://voterportal.sos.la.gov/graphical
jsdat <- jsdat |>
  mutate(
    temp = 0, # Temporary var that ids non-runoff candidates
    temp = replace(temp, state == "LA" & year == 2020 & dist == 5, 1),
    temp = replace(temp, name_snyder == "LETLOW, LUKE J." & year == 2020 |
                     name_snyder == "HARRIS, LANCE" & year == 2020, 0)
  ) |>
  filter(temp == 0,
         name_snyder != "BUCKLEY, ALLEN" | year != 2008) |>
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


# Vote total corrections ----

# Correcting vote totals to reflect runoffs
jsdat <- jsdat |>
  mutate(vote_g = case_when(
    year == 2008 & state == "GA" & name_snyder == "MARTIN, JAMES FRANCIS (JIM)" ~ 909923,
    year == 2008 & state == "GA" & name_snyder == "CHAMBLISS, C. SAXBY" ~ 1228033,
    year == 2020 & state == "LA" & name_snyder == "LETLOW, LUKE J." ~ 49183,
    year == 2020 & state == "LA" & name_snyder == "HARRIS, LANCE" ~ 30124,
    TRUE ~ vote_g
  ))

# Other vote total additions
jsdat <- jsdat |>
  mutate(vote_g = replace(vote_g, name_snyder == "JINDAL, BOBBY" & office == "H" & year == 2006 & state == "LA", 130508),
         vote_g = replace(vote_g, name_snyder == "MCCRERY, JAMES O. (JIM)" & office == "H" & year == 2006 & state == "LA", 77078),
         vote_g = replace(vote_g, name_snyder == "ALEXANDER, RODNEY M." & office == "H" & year == 2006 & state == "LA", 78211),
         vote_g = replace(vote_g, name_snyder == "BOUSTANY, CHARLES W., JR." & office == "H" & year == 2006 & state == "LA", 113720),
         vote_g = replace(vote_g, name_snyder == "BAKER, RICHARD HUGH" & office == "H" & year == 2006 & state == "LA", 94658),
         vote_g = replace(vote_g, name_snyder == "MELANCON, CHARLES J. (CHARLIE), JR." & office == "H" & year == 2006 & state == "LA", 75023),
         vote_g = replace(vote_g, name_snyder == "JINDAL, BOBBY" & office == "G" & year == 2007 & state == "LA", 699275),
         vote_g = replace(vote_g, name_snyder == "GAIERO, THEODORE J., JR." & office == "H" & year == 2008 & state == "MA", 114),
         vote_g = replace(vote_g, name_snyder == "SPEIER, KAREN (JACKIE)" & type == "S" & year == 2008 & state == "CA", 66279),
         vote_g = replace(vote_g, name_snyder == "DJOU, CHARLES KONG" & type == "S" & year == 2010 & state == "HI", 67610),
         vote_g = replace(vote_g, name_snyder == "PAYNE, DONALD M. (DON), JR." & type == "S" & year == 2012 & state == "NJ", 166413),
         vote_g = replace(vote_g, name_snyder == "SCALISE, STEPHEN J. (STEVE)" & type == "G" & year == 2012 & state == "LA", 193496),
         vote_g = replace(vote_g, name_snyder == "RICHMOND, CEDRIC L." & type == "G" & year == 2012 & state == "LA", 158501),
         vote_g = replace(vote_g, name_snyder == "FLEMING, JOHN C., JR." & type == "G" & year == 2012 & state == "LA", 187894),
         vote_g = replace(vote_g, name_snyder == "ALEXANDER, RODNEY M." & type == "G" & year == 2012 & state == "LA", 202536),
         vote_g = replace(vote_g, name_snyder == "CASSIDY, WILLIAM (BILL)" & type == "G" & year == 2012 & state == "LA", 243553),
         vote_g = replace(vote_g, name_snyder == "SCALISE, STEPHEN J. (STEVE)" & type == "G" & year == 2014 & state == "LA", 189250),
         vote_g = replace(vote_g, name_snyder == "RICHMOND, CEDRIC L." & type == "G" & year == 2014 & state == "LA", 152201),
         vote_g = replace(vote_g, name_snyder == "BOUSTANY, CHARLES W., JR." & type == "G" & year == 2014 & state == "LA", 185867),
         vote_g = replace(vote_g, name_snyder == "FLEMING, JOHN C., JR." & type == "G" & year == 2014 & state == "LA", 152683),
         vote_g = replace(vote_g, name_snyder == "SCALISE, STEPHEN J. (STEVE)" & type == "G" & year == 2016 & state == "LA", 243645),
         vote_g = replace(vote_g, name_snyder == "RICHMOND, CEDRIC L." & type == "G" & year == 2016 & state == "LA", 198289),
         vote_g = replace(vote_g, name_snyder == "ABRAHAM, RALPH LEE" & type == "G" & year == 2016 & state == "LA", 208345),
         vote_g = replace(vote_g, name_snyder == "GRAVES, GARRET" & type == "G" & year == 2016 & state == "LA", 207483),
         vote_g = replace(vote_g, name_snyder == "MURPHY, GREGORY F. (GREG)" & type == "S" & year == 2019 & state == "NC", 70407),
         vote_g = replace(vote_g, name_snyder == "BISHOP, DAN" & type == "S" & year == 2019 & state == "NC", 96573),
         vote_g = replace(vote_g, name_snyder == "KELLER, FREDERICK B. (FRED)" & type == "S" & year == 2019 & state == "PA", 90000),
         vote_g = replace(vote_g, name_snyder == "LETLOW, JULIA" & type == "S" & year == 2021 & state == "LA", 67203),
         vote_g = replace(vote_g, name_snyder == "ROSSANO, TIMOTHY" & year == 2014 & state == "FL", 12),
         vote_g = replace(vote_g, name_snyder == "JINDAL, BOBBY" & office == "G" & year == 2011 & state == "LA", 673239),
         vote_g = replace(vote_g, name_snyder == "FLORES, MAYRA" & year == 2022 & type == "S", 14799)
  )


# Winner (w_g) corrections ----

# Fix Oregon 2018 Gov winner
jsdat <- jsdat |>
  mutate(w_g = replace(w_g, year == 2018 & state == "OR" & office == "G" & name_snyder == "BUEHLER, KNUTE", 0))

# Fix Rhode Island 2006 Gov results
jsdat <- jsdat |>
  mutate(w_g = replace(w_g, year == 2006 & state == "RI" & office == "G" & name_snyder == "CARCIERI, DONALD L.", 1),
         w_g = replace(w_g, year == 2006 & state == "RI" & office == "G" & name_snyder == "FOGARTY, CHARLES J.", 0),
         vote_g = replace(vote_g, year == 2006 & state == "RI" & office == "G" & name_snyder == "CARCIERI, DONALD L.", 197306),
         vote_g = replace(vote_g, year == 2006 & state == "RI" & office == "G" & name_snyder == "FOGARTY, CHARLES J.", 189503)
  )

# Karin Housley w_g fix
jsdat <- jsdat |>
  mutate(w_g = replace(w_g, year == 2018 & state == "MN" & name_snyder == "HOUSLEY, KARIN", 0))

# NC-09 election fraud case
jsdat <- jsdat |>
  mutate(w_g = replace(w_g, office == "H" & year == 2018 & state == "NC" & dist == 9 & type == "G", NA))

# Fix IN-02 Walorski result
jsdat <- jsdat |>
  mutate(w_g = replace(w_g, name_snyder == "STEURY, PAUL D." & office == "H" & year == 2022, 0))

# TX-23 special election runoff
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


# Removing candidates ----

# Removing Ellen Brickley
jsdat <- jsdat |>
  filter(name_snyder != "BRICKLEY, ELLEN")

# Removing duplicates or not-rans
jsdat <- jsdat |>
  # duplicate entry with VAN DUYNE
  filter(!(office == "H" & state == "TX" & dist == 24 & year == 2022 & name_snyder == "VANDUYNE, BETH")) |>
  # rest were primary losses, not in general
  filter(!(office == "H" & state == "FL" & dist == 5 & year == 2022 & name_snyder != "RUTHERFORD, JOHN H.")) |>
  # no votes
  tidylog::filter(!(office == "H" & state == "CT" & dist == 4 & year == 2022 & name_snyder == "GOLDSTEIN, MICHAEL TED"))

# Removing entries without names
jsdat <- jsdat |>
  filter(name_snyder != "" | !is.na(vote_g))


# Party corrections ----

jsdat <- jsdat |>
  # writein
  tidylog::mutate(party = replace(party, name_snyder == "SMITH, DELLA JEAN (DJ)" & year == 2016, "W-I")) |>
  tidylog::mutate(party = replace(party, name_snyder == "RAMSBURG, KAREN LYNN" & year == 2012, "D")) |>
  tidylog::mutate(party = replace(party, name_snyder != "VAN HOLLEN, CHRISTOPHER (CHRIS), JR." & year == 2016 & office == "S" & party == "D" & state == "MD", "W-I"))


# Incumbency fixes ----

jsdat <- jsdat |>
  mutate(
    inc = replace(inc, office == "S" & state == "MO" & year == 2016 & party %in% c("Grn", "I"), 0),
    inc = replace(inc, office == "S" & state == "NV" & year == 2016 & party %in% c(""), 0),
    inc = replace(inc, office == "S" & state == "SD" & year == 2014, 0),
    inc = replace(inc, office == "S" & state == "NJ" & year == 2013, 0),
    inc = replace(inc, office == "S" & state == "MA" & year == 2013 & party == "12 Visions Pty", 0),
    inc = replace(inc, office == "H" & state == "LA" & year == 2021 & name_snyder == "LETLOW, JULIA", 0),
    inc = replace(inc, office == "H" & state == "KS" & year == 2017 & name_snyder == "ROCKHOLD, CHRIS", 0),
    inc = replace(inc, office %in% c("H", "S") & year %% 2 == 0 & party %in% c("Grn", "Lbt", "W-I", "", "US Taxpayers"), 0)
  )


# Name recodings ----

jsdat <- jsdat |>
  tidylog::mutate(name_snyder = str_replace(name_snyder, "Ê", " "))



# GITHUB ISSUES ===========================================================

# Issue #7: TX-22 2006 election type ----
# https://github.com/kuriwaki/cces_candidates/issues/7

jsdat <- jsdat |>
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
  )


# Issues #9, #10, #13, #14, #16, #17, #18, #19, #20: House append ----

house_append <- read.csv("data/intermediate/cand_house_append.csv")

# Rename 'name' to 'name_snyder' if needed
if ("name" %in% names(house_append) && !"name_snyder" %in% names(house_append)) {
  house_append <- house_append |> rename(name_snyder = name)
}

# Only add rows that don't already exist
for (i in seq_len(nrow(house_append))) {
  row <- house_append[i, ]
  exists <- jsdat |>
    filter(state == row$state, year == row$year, office == row$office,
           dist == row$dist, name_snyder == row$name_snyder) |>
    nrow() > 0

  if (!exists) {
    jsdat <- jsdat |> add_row(!!!row)
  }
}


# Issue #21: Adding Bridenstine ----
# https://github.com/kuriwaki/cces_candidates/issues/21

# Add BRIDENSTINE if not already present
if (nrow(jsdat |> filter(state == "OK", year == 2016, office == "H", dist == 1,
                          name_snyder == "BRIDENSTINE, JAMES FREDERICK (JIM)")) == 0) {
  jsdat <- jsdat |>
    add_row(state = "OK", year = 2016, office = "H", dist = 1,
            type = "G", nextup = 2018,
            party = "R",
            name_snyder = "BRIDENSTINE, JAMES FREDERICK (JIM)", inc = 1,
            w_g = 1, u_g = 1,
            vote_g = NA)
}


# Issue #26: Missing gubernatorial candidate states ----

cand <- jsdat %>%
  mutate(
    state = replace(state, state == "" & year == 2011 & office == "G", "LA")
  )


# Issue #27: Three last name misspellings ----

cand <- cand %>%
  mutate(
    name_snyder = replace(name_snyder, str_detect(name_snyder, "YEVANCY"), "YEVANCEY, MANNY"),
    name_snyder = replace(name_snyder, str_detect(name_snyder, "STANCZACK"), "STANCZAK, JAMES"),
    name_snyder = replace(name_snyder, str_detect(name_snyder, "WEIDER"), "WIEDER, JOHN")
  )


# Issue #29: Fix Ron Caesar Spelling ----

cand <- cand %>%
  mutate(
    name_snyder = replace(name_snyder, name_snyder == "CEASAR, RON" & state == "LA", "CAESAR, RON")
  )


# Issue #30: Corrections on incumbency ----

cand <- cand %>%
  mutate(
    inc = replace(inc, name_snyder == "BREWER, JANICE (JAN)" & state == "AZ" & office == "G" & year == 2010, 1),
    inc = replace(inc, name_snyder == "MURRAY, JULIANNE E." & state == "DE" & office == "G" & year == 2020, 0)
  )


# Issue #35: Standardized names -- Joe Kennedy III ----
# Issue #43

cand <- cand %>%
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


# Issue #41: Missing inc values ----

cand <- cand |>
  left_join(
    tibble::tribble(
      ~state, ~year, ~office,                               ~name_snyder, ~inc,
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
    by = c("state", "year", "office", "name_snyder"),
    relationship = "one-to-one"
  ) |>
  mutate(inc = coalesce(inc.y, inc.x),
         inc.x = NULL,
         inc.y = NULL)



# 2024 ADDITIONS ----------------------------------------------------------

# Define 2024 additions
additions_2024 <- tibble::tribble(
  ~state, ~year, ~office, ~dist, ~type, ~nextup, ~party, ~name_snyder, ~inc, ~vote_g, ~w_g, ~vote_g_share,
  # NY-15
  "NY", 2024, "H", 15, "G", 2026, "D", "TORRES, RITCHIE", 1, 130392, 1, 0.6915697,
  "NY", 2024, "H", 15, "G", 2026, "R", "DURAN, GONZALEZ", 0, 36010, 0, 0.1909889,
  "NY", 2024, "H", 15, "G", 2026, "I", "JOSE VEGA, LAROUCHE", 0, 0, 0, 0.02167122,
  # Maine Senate
  "ME", 2024, "S", 2, "G", 2026, "D", "COSTELLO, DAVID ALLEN", 1, 0, 1, 0.5970149,
  "ME", 2024, "S", 2, "G", 2030, "R", "KOUZOUNAS, DEMI", 0, 284338, 0, 0.3376,
  "ME", 2024, "S", 2, "G", 2030, "D", "COSTELLO, DAVID ALLEN", 0, 88891, 0, 0.1056,
  "ME", 2024, "S", 2, "G", 2030, "Indep", "KING, ANGUS S., JR.", 1, 427331, 1, 0.5073,
  "ME", 2024, "S", 2, "G", 2030, "Indep", "CHERRY, JASON S.", 0, 20222, 0, 0.0240,
  # Vermont Senate
  "VT", 2024, "S", 2, "G", 2030, "R", "MALLOY, GERALD", 0, 116512, 0, 0.3212,
  "VT", 2024, "S", 2, "G", 2030, "Indep", "SANDERS, BERNARD", 1, 229429, 1, 0.6322,
  "VT", 2024, "S", 2, "G", 2030, "Indep", "BERRY, STEVE", 0, 7941, 0, 0.0219,
  "VT", 2024, "S", 2, "G", 2030, "L", "HILL, MATT", 0, 4530, 0, 0.0125,
  "VT", 2024, "S", 2, "G", 2030, "Green Mountain Peace and Justice", "SCHOVILLE, JUSTIN", 0, 3339, 0, 0.0092,
  "VT", 2024, "S", 2, "G", 2030, "Epic", "STEWART GREENSTEIN, MARK", 0, 1104, 0, 0.0030
)

# Only add 2024 rows that don't already exist
for (i in seq_len(nrow(additions_2024))) {
  row <- additions_2024[i, ]
  exists <- cand |>
    filter(state == row$state, year == row$year, office == row$office,
           dist == row$dist, name_snyder == row$name_snyder) |>
    nrow() > 0

  if (!exists) {
    cand <- cand |> add_row(!!!row)
  }
}


# NY and CT fusion voting aggregation ----
# In NY and CT, candidates can run on multiple party lines (e.g., Democratic and Working Families).
# Some years have these as separate rows, some as aggregated. This code aggregates all to a single
# row per candidate-race with summed votes and comma-separated party_formal.

# Identify NY/CT races with multiple rows for the same candidate
cand <- cand %>%
  group_by(state, year, office, dist, name_snyder) %>%
  mutate(
    n_party_rows = n(),
    is_fusion_state = state %in% c("NY", "CT")
  ) %>%
  ungroup()

# For NY/CT candidates with multiple rows, aggregate them
fusion_agg <- cand %>%
  filter(is_fusion_state & n_party_rows > 1) %>%
  group_by(state, year, office, dist, type, nextup, name_snyder) %>%
  summarize(
    # Sum votes across all party lines
    vote_g = sum(vote_g, na.rm = TRUE),
    # Take the primary party (D > R > others) - first non-Other party alphabetically
    party = first(party[party %in% c("D", "R")], default = first(party)),
    # Combine all unique parties from party_formal into comma-separated string
    party_formal = paste(unique(unlist(strsplit(party_formal, ","))), collapse = ","),
    # These should be the same across rows, take first non-NA
    inc = first(na.omit(inc)),
    w_g = first(na.omit(w_g)),
    u_g = first(na.omit(u_g)),
    vote_g_share = NA_real_,  # Will be recalculated below
    n = first(na.omit(n)),
    totalvotes = first(na.omit(totalvotes)),
    .groups = "drop"
  )

# Remove the original multi-row fusion candidates and add the aggregated versions
cand <- cand %>%
  filter(!(is_fusion_state & n_party_rows > 1)) %>%
  select(-n_party_rows, -is_fusion_state) %>%
  bind_rows(fusion_agg)


# Recalculate totalvotes, vote_g_share, and u_g ----
# After fusion aggregation, recalculate:
# - totalvotes: sum of vote_g within each race
# - vote_g_share: candidate's share of totalvotes
# - n: number of candidates in the race
# - u_g: whether the candidate was uncontested (1 if only candidate in race, 0 otherwise)

cand <- cand %>%
  group_by(state, year, office, dist, type) %>%
  mutate(
    n = n(),
    totalvotes = sum(vote_g, na.rm = TRUE),
    vote_g_share = vote_g / totalvotes,
    u_g = if_else(n == 1, 1, 0)
  ) %>%
  ungroup()


write_rds(cand, "data/intermediate/candidates_2006-2024.rds")
