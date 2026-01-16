library(tidyverse)
library(tidylog)

jsdat_raw <- readRDS("data/intermediate/prelim/candidates_party-recoded.rds") |>
  filter(year >= 2006)

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

# Remove u_g and vote_g_share columns if they exist
jsdat_raw <- jsdat_raw |> select(-any_of(c("u_g", "vote_g_share")))

jsdat <- jsdat_raw


# MANUAL FIXES ============================================================

# Adding missing candidates ----

# Add LA candidates if not already present
la_additions <- tibble::tribble(
  ~state, ~year, ~office, ~dist, ~type, ~nextup, ~party, ~party_formal, ~name_snyder, ~w_g, ~inc, ~vote_g,
  "LA", 2006, "H", 5, "G", 2008, "D", "D", "HEARN, WILLIAMS GLORIA", 0, 0, 33233,
  "LA", 2006, "H", 5, "G", 2008, "Lbt", "Lbt", "SANDERS, BRENT", 0, 0, 1876,
  "LA", 2006, "H", 5, "G", 2008, "I", "I", "WATTS, JOHN", 0, 0, 1262,
  "LA", 2006, "H", 7, "G", 2008, "D", "D", "STAGG, MIKE", 0, 0, 47133
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

jsdat <- jsdat |>
  filter(!(state == "GA" & year == 2020 & office == "S"))

ga_additions <- tibble::tribble(
  ~state, ~year, ~office, ~dist, ~type, ~nextup, ~party, ~party_formal, ~name_snyder, ~vote_g, ~w_g, ~inc,
  # 2021 Special runoff - Warnock vs. Loeffler (Jan 5, 2021 runoff)
  "GA", 2020, "S", 3, "S", 2022, "D", "D", "WARNOCK, RAPHAEL GAMALIEL", 2289113, 1, 0,
  "GA", 2020, "S", 3, "S", 2022, "R", "R", "LOEFFLER, KELLY", 2195841, 0, 1,
  "GA", 2020, "S", 2, "G", 2022, "D", "D", "OSSOFF, THOMAS JONATHAN (JON)", 2269923, 1, 0,
  "GA", 2020, "S", 2, "G", 2022, "R", "R", "PERDUE, DAVID A.", 2214979, 0, 0
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
  tidylog::mutate(
    temp = ifelse((state == "GA" & year %in% 2020:2022 & office == "S"), 1, 0),
    temp = replace(temp, name_snyder %in% c("LOEFFLER, KELLY", "WARNOCK, RAPHAEL GAMALIEL",
                                     "WALKER, HERSCHEL JUNIOR",
                                     "OSSOFF, THOMAS JONATHAN (JON)", "PERDUE, DAVID A."), 0)
  ) |>
  tidylog::filter(temp == 0) |>
  select(-temp) |>
  # Update vote_g for 2022 GA runoff candidates (2020/2021 already set when rows added)
  tidylog::mutate(
    vote_g = replace(vote_g, year == 2022 & state == "GA" & office == "S" & name_snyder == "WALKER, HERSCHEL JUNIOR", 1721244),
    vote_g = replace(vote_g, year == 2022 & state == "GA" & office == "S" & name_snyder == "WARNOCK, RAPHAEL GAMALIEL", 1820633)
  ) |>
  # Fix incumbency for GA special elections
  # Loeffler was appointed incumbent, Warnock/Walker are challengers
  tidylog::mutate(
    inc = replace(inc, state == "GA" & year %in% 2020:2022 & office == "S" & name_snyder == "LOEFFLER, KELLY", 1),
    inc = replace(inc, state == "GA" & year %in% 2020:2022 & office == "S" & name_snyder == "WARNOCK, RAPHAEL GAMALIEL", 0),
    inc = replace(inc, state == "GA" & year == 2022 & office == "S" & name_snyder == "WALKER, HERSCHEL JUNIOR", 0)
  ) |>
  mutate(
    inc = replace(inc, year == 2022 & state == "GA" & office == "S" & name_snyder == "WARNOCK, RAPHAEL GAMALIEL", 2)
  )


# Runoff elections ----

# Removing extraneous candidates
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
  tidylog::mutate(runoff = case_when(
    state == "GA" & year == 2022 & office == "S" ~ 1, # 2022 Georgia Runoff
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
  tidylog::mutate(vote_g = case_when(
    year == 2008 & state == "GA" & name_snyder == "MARTIN, JAMES FRANCIS (JIM)" ~ 909923,
    year == 2008 & state == "GA" & name_snyder == "CHAMBLISS, C. SAXBY" ~ 1228033,
    year == 2020 & state == "LA" & name_snyder == "LETLOW, LUKE J." ~ 49183,
    year == 2020 & state == "LA" & name_snyder == "HARRIS, LANCE" ~ 30124,
    TRUE ~ vote_g
  ))

# Other vote total additions
jsdat <- jsdat |>
  tidylog::mutate(vote_g = replace(vote_g, name_snyder == "JINDAL, BOBBY" & office == "H" & year == 2006 & state == "LA", 130508),
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
  tidylog::mutate(w_g = replace(w_g, year == 2018 & state == "OR" & office == "G" & name_snyder == "BUEHLER, KNUTE", 0))

# Fix Rhode Island 2006 Gov results
jsdat <- jsdat |>
  tidylog::mutate(w_g = replace(w_g, year == 2006 & state == "RI" & office == "G" & name_snyder == "CARCIERI, DONALD L.", 1),
         w_g = replace(w_g, year == 2006 & state == "RI" & office == "G" & name_snyder == "FOGARTY, CHARLES J.", 0),
         vote_g = replace(vote_g, year == 2006 & state == "RI" & office == "G" & name_snyder == "CARCIERI, DONALD L.", 197306),
         vote_g = replace(vote_g, year == 2006 & state == "RI" & office == "G" & name_snyder == "FOGARTY, CHARLES J.", 189503)
  )

# Karin Housley w_g fix
jsdat <- jsdat |>
  tidylog::mutate(w_g = replace(w_g, year == 2018 & state == "MN" & name_snyder == "HOUSLEY, KARIN", 0))

# NC-09 election fraud case
jsdat <- jsdat |>
  tidylog::mutate(w_g = replace(w_g, office == "H" & year == 2018 & state == "NC" & dist == 9 & type == "G", NA))

# Fix IN-02 Walorski result
jsdat <- jsdat |>
  tidylog::mutate(w_g = replace(w_g, name_snyder == "STEURY, PAUL D." & office == "H" & year == 2022, 0))

# TX-23 special election runoff
jsdat <- jsdat |>
  tidylog::filter(
    !(year == 2006 & state == "TX" & office == "H" & dist == 23 & vote_g < 24594)
  ) |>
  tidylog::mutate(type = replace(type, year == 2006 & state == "TX" & dist == 23, "G"),
         vote_g = replace(vote_g, year == 2006 & state == "TX" & dist == 23 & party == "R", 32217),
         vote_g = replace(vote_g, year == 2006 & state == "TX" & dist == 23 & party == "D", 38256),
         w_g = replace(w_g, year == 2006 & state == "TX" & dist == 23 & party == "R", 0),
         w_g = replace(w_g, year == 2006 & state == "TX" & dist == 23 & party == "D", 1))


# Removing candidates ----

# Removing duplicates or not-rans
jsdat <- jsdat |>
  # Removing Ellen Brickley
  tidylog::filter(name_snyder != "BRICKLEY, ELLEN") |>
  # duplicate entry with VAN DUYNE
  tidylog::filter(!(office == "H" & state == "TX" & dist == 24 & year == 2022 & name_snyder == "VANDUYNE, BETH")) |>
  # rest were primary losses, not in general
  tidylog::filter(!(office == "H" & state == "FL" & dist == 5 & year == 2022 & name_snyder != "RUTHERFORD, JOHN H.")) |>
  # no votes
  tidylog::filter(!(office == "H" & state == "CT" & dist == 4 & year == 2022 & name_snyder == "GOLDSTEIN, MICHAEL TED"))

# Removing entries without names
jsdat <- jsdat |>
  filter(name_snyder != "" | !is.na(vote_g))


# Party corrections ----

jsdat <- jsdat |>
  # writein
  tidylog::mutate(party = replace(party, name_snyder == "SMITH, DELLA JEAN (DJ)" & year == 2016, "Other")) |>
  tidylog::mutate(party = replace(party, name_snyder == "RAMSBURG, KAREN LYNN" & year == 2012, "D")) |>
  tidylog::mutate(party = replace(party, name_snyder != "VAN HOLLEN, CHRISTOPHER (CHRIS), JR." & year == 2016 & office == "S" & party == "D" & state == "MD", "Other"))


# Incumbency fixes ----

jsdat <- jsdat |>
  tidylog::mutate(
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


# Manually fixing TX-22 2006 ----

jsdat <- jsdat |>
  tidylog::filter(
    !(state == "TX" & year == 2006 & office == "H" & dist == 22)
  )

# TX-22 2006 general election
tx22_additions <- tibble::tribble(
  ~state, ~year, ~office, ~dist, ~type, ~nextup, ~party, ~party_formal, ~name_snyder, ~w_g, ~inc, ~vote_g,
  "TX", 2006, "H", 22, "G", 2008, "D", "D", "LAMPSON, NICHOLAS V. (NICK)", 1, 0, 76775,
  "TX", 2006, "H", 22, "G", 2008, "Lbt", "Lbt", "SMITHER, M. BOB", 0, 0, 9009,
  "TX", 2006, "H", 22, "G", 2008, "Other", "W-I", "SEKULA GIBBS, SHELLEY A.", 0, 0, 61938,
  "TX", 2006, "H", 22, "G", 2008, "Other", "W-I", "RICHARDSON, DONALD LUTHER (DON)", 0, 0, 428,
  "TX", 2006, "H", 22, "G", 2008, "Other", "W-I", "REASBECK, JOE", 0, 0, 89
)


# Only add rows that don't already exist
for (i in seq_len(nrow(tx22_additions))) {
  row <- tx22_additions[i, ]
  exists <- jsdat |>
    filter(state == row$state, year == row$year, office == row$office,
           dist == row$dist, name_snyder == row$name_snyder, type == row$type) |>
    nrow() > 0

  if (!exists) {
    jsdat <- jsdat |> add_row(!!!row)
  }
}

# McMasters, Thomas (Tom) Manual Edit ----

jsdat <- jsdat |>
  tidylog::mutate(
    party = replace(party, name_snyder == "MCMASTERS, THOMAS (TOM)", "I"),
    party_formal = replace(party_formal, name_snyder == "MCMASTERS, THOMAS (TOM)", "W-I")
  )

# Fixing nextup for Arizona races ----

jsdat <- jsdat |>
  tidylog::mutate(
    nextup = replace(nextup, state == "AZ" & year == 2020 & office == "S" & type == "S", 2022)
  )

# Adding Angus King races ----

king_additions <- tibble::tribble(
  ~state, ~year, ~office, ~dist, ~type, ~nextup, ~party, ~party_formal, ~name_snyder, ~inc, ~vote_g, ~w_g,
  # 2018 Senate election
  "ME", 2018, "S", 1, "G", 2024, "I", "I", "KING, ANGUS S., JR.", 0, 370580, 1,
  "ME", 2018, "S", 1, "G", 2024, "R", "R", "SUMNERS, CHARLES E., JR.", 0, 215399, 0,
  "ME", 2018, "S", 1, "G", 2024, "D", "D", "DILL, CYNTHIA ANN", 0, 92900, 0,
  "ME", 2018, "S", 1, "G", 2024, "I", "I", "WOODS, STEPHEN M.", 0, 10289, 0,
  "ME", 2018, "S", 1, "G", 2024, "Other", "Nonparty", "DALTON, DANNY FRANCIS", 0, 5624, 0,
  "ME", 2018, "S", 1, "G", 2024, "Other", "Independent for Liberty", "DODGE, ANDREW IAN", 0, 5624, 0,
  # 2012 Senate election
  "ME", 2012, "S", 1, "G", 2018, "I", "I", "KING, ANGUS S., JR.", 1, 344575, 1,
  "ME", 2012, "S", 1, "G", 2018, "R", "R", "BRAKEY, ERIC L.", 0, 223502, 0,
  "ME", 2012, "S", 1, "G", 2018, "D", "D", "RINGELSTEIN, ZAK", 0, 66268, 0
)

# Check if Kings entries already exist and add only if they don't
for (i in seq_len(nrow(king_additions))) {
  row <- king_additions[i, ]
  exists <- jsdat |>
    filter(state == row$state, year == row$year, office == row$office,
           dist == row$dist, name_snyder == row$name_snyder) |>
    nrow() > 0

  if (!exists) {
    jsdat <- jsdat |> add_row(!!!row)
    cat(sprintf("Added: %s (%s %d Senate)\n", row$name_snyder, row$state, row$year))
  } else {
    cat(sprintf("Already exists: %s (%s %d Senate)\n", row$name_snyder, row$state, row$year))
  }
}

# Adding Joe Lieberman races ----

lieberman_additions <- tibble::tribble(
  ~state, ~year, ~office, ~dist, ~type, ~nextup, ~party, ~party_formal, ~name_snyder, ~inc, ~vote_g, ~w_g,
  # 2006 Senate election
  "CT", 2006, "S", 1, "G", 2012, "I", "Connecticut for Lieberman", "LIEBERMAN, JOSEPH I.", 1, 564095, 1,
  "CT", 2006, "S", 1, "G", 2012, "D", "D", "LAMONT, NED", 0, 450844, 0,
  "CT", 2006, "S", 1, "G", 2012, "R", "R", "SCHLESINGER, ALAN", 0, 109198, 0,
  "CT", 2006, "S", 1, "G", 2012, "Grn", "Green", "FERRUCCI, RALPH A.", 0, 5922, 0,
  "CT", 2006, "S", 1, "G", 2012, "Other", "Concerned Citizens", "KNIBBS, TIMOTHY A.", 0, 4638, 0,
  "CT", 2006, "S", 1, "G", 2012, "Other", "Write-in", "VASSAR, CARL E.", 0, 80, 0,
)

# Check if Lieberman entries already exist and add only if they don't
for (i in seq_len(nrow(lieberman_additions))) {
  row <- lieberman_additions[i, ]
  exists <- jsdat |>
    filter(state == row$state, year == row$year, office == row$office,
           dist == row$dist, name_snyder == row$name_snyder) |>
    nrow() > 0

  if (!exists) {
    jsdat <- jsdat |> add_row(!!!row)
    cat(sprintf("Added: %s (%s %d Senate)\n", row$name_snyder, row$state, row$year))
  } else {
    cat(sprintf("Already exists: %s (%s %d Senate)\n", row$name_snyder, row$state, row$year))
  }
}


# Adding Bernard Sanders Senate elections ----

# Vermont Senate races for Bernard Sanders (2018, 2012, 2006)
sanders_additions <- tibble::tribble(
  ~state, ~year, ~office, ~dist, ~type, ~nextup, ~party, ~party_formal, ~name_snyder, ~inc, ~vote_g, ~w_g,
  # 2018 Senate election
  "VT", 2018, "S", 1, "G", 2024, "I", "I", "SANDERS, BERNARD (BERNIE)", 1, 183649, 1,
  "VT", 2018, "S", 1, "G", 2024, "R", "R", "ZUPAN, LAWRENCE", 0, 74815, 0,
  "VT", 2018, "S", 1, "G", 2024, "I", "I", "PEACOCK, BRAD J.", 0, 3655, 0,
  "VT", 2018, "S", 1, "G", 2024, "I", "I", "BESTE, RUSSELL", 0, 2763, 0,
  "VT", 2018, "S", 1, "G", 2024, "I", "I", "GILBERT, EDWARD S., JR.", 0, 2244, 0,
  "VT", 2018, "S", 1, "G", 2024, "I", "I", "ADELUOLA, FOLASADE", 0, 1979, 0,
  "VT", 2018, "S", 1, "G", 2024, "Other", "Liberty Union", "KANE, REID", 0, 1171, 0,
  "VT", 2018, "S", 1, "G", 2024, "I", "I", "SVITAVSKY, JON", 0, 1130, 0,
  "VT", 2018, "S", 1, "G", 2024, "I", "I", "BUSA, BRUCE", 0, 914, 0,
  # 2012 Senate election
  "VT", 2012, "S", 1, "G", 2018, "I", "I", "SANDERS, BERNARD (BERNIE)", 1, 207848, 1,
  "VT", 2012, "S", 1, "G", 2018, "R", "R", "MACGOVERN, JOHN", 0, 72898, 0,
  "VT", 2012, "S", 1, "G", 2018, "Other", "Liberty Union", "DIAMONDSTONE, PETER", 0, 2511, 0,
  "VT", 2012, "S", 1, "G", 2018, "Other", "Peace and Prosperity", "MOSS, PETER", 0, 2452, 0,
  "VT", 2012, "S", 1, "G", 2018, "Other", "United States Marijuana", "ERICSON, CHRIS", 0, 5924, 0,
  "VT", 2012, "S", 1, "G", 2018, "Other", "VoteKISS", "Laframboise", 0, 877, 0,
  # 2006 Senate election
  "VT", 2006, "S", 1, "G", 2012, "I", "I", "SANDERS, BERNARD (BERNIE)", 0, 171638, 1,
  "VT", 2006, "S", 1, "G", 2012, "R", "R", "TARRANT, RICHARD", 0, 84924, 0,
  "VT", 2006, "S", 1, "G", 2012, "I", "I", "ERICSON, CRIS", 0, 1735, 0,
  "VT", 2006, "S", 1, "G", 2012, "Grn", "Vermont Green", "HILL, CRAIG", 0, 1536, 0,
  "VT", 2006, "S", 1, "G", 2012, "Other", "Liberty Union", "DIAMONDSTONE, PETER", 0, 801, 0,
  "VT" , 2006, "S", 1, "G", 2012, "Other", "Anti-Bush", "MOSS, PETER", 0, 1518, 0
)

# Check if Sanders entries already exist and add only if they don't
for (i in seq_len(nrow(sanders_additions))) {
  row <- sanders_additions[i, ]
  exists <- jsdat |>
    filter(state == row$state, year == row$year, office == row$office,
           dist == row$dist, name_snyder == row$name_snyder) |>
    nrow() > 0

  if (!exists) {
    jsdat <- jsdat |> add_row(!!!row)
    cat(sprintf("Added: %s (%s %d Senate)\n", row$name_snyder, row$state, row$year))
  } else {
    cat(sprintf("Already exists: %s (%s %d Senate)\n", row$name_snyder, row$state, row$year))
  }
}

# Adding Bill Cassidy 2020 race ----

louisiana_senate_2020 <- tibble::tribble(
  ~state, ~year, ~office, ~dist, ~type, ~nextup, ~party, ~party_formal, ~name_snyder, ~inc, ~vote_g, ~w_g,
  # 2020 Senate election
  "LA", 2020, "S", 1, "G", 2026, "R", "R", "CASSIDY, WILLIAM (BILL)", 1, 1228908, 1,
  "LA", 2020, "S", 1, "G", 2026, "D", "D", "PERKINS, ADRIAN", 0, 394049, 0,
  "LA", 2020, "S", 1, "G", 2026, "D", "D", "EDWARDS, DERRICK (CHAMP)", 0, 229814, 0,
  "LA", 2020, "S", 1, "G", 2026, "D", "D", "PIERCE, ANTOINE", 0, 55710, 0,
  "LA", 2020, "S", 1, "G", 2026, "R", "R", "MURPHY, DUSTIN", 0, 38383, 0,
  "LA", 2020, "S", 1, "G", 2026, "D", "D", "KNIGHT, DAVID DREW", 0, 36962, 0,
  "LA", 2020, "S", 1, "G", 2026, "I", "I", "BILLIOT, BERYL", 0, 17362, 0,
  "LA", 2020, "S", 1, "G", 2026, "I", "I", "BOURGEOIS, JOHN PAUL", 0, 16518, 0,
  "LA", 2020, "S", 1, "G", 2026, "D", "D", "WENSTRUP, PETER", 0, 14454, 0,
  "LA", 2020, "S", 1, "G", 2026, "L", "L", "SIGLER, AARON C.", 0, 11321, 0,
  "LA", 2020, "S", 1, "G", 2026, "I", "I", "MENDOZA, M. V. (VINNY)", 0, 7811, 0,
  "LA", 2020, "S", 1, "G", 2026, "Other", "Other", "PRICE, MELINDA MARY", 0, 7680, 0,
  "LA", 2020, "S", 1, "G", 2026, "I", "I", "MONTGOMERY, JAMAR", 0, 5804, 0,
  "LA", 2020, "S", 1, "G", 2026, "I", "I", "DARET, RENO JEAN, III", 0, 3954, 0,
  "LA", 2020, "S", 1, "G", 2026, "Other", "Other", "JOHN, XAN", 0, 2813, 0
)


# Check if Cassidy entries already exist and add only if they don't
for (i in seq_len(nrow(louisiana_senate_2020))) {
  row <- louisiana_senate_2020[i, ]
  exists <- jsdat |>
    filter(state == row$state, year == row$year, office == row$office,
           dist == row$dist, name_snyder == row$name_snyder) |>
    nrow() > 0

  if (!exists) {
    jsdat <- jsdat |> add_row(!!!row)
    cat(sprintf("Added: %s (%s %d Senate)\n", row$name_snyder, row$state, row$year))
  } else {
    cat(sprintf("Already exists: %s (%s %d Senate)\n", row$name_snyder, row$state, row$year))
  }
}

# GITHUB ISSUES ===========================================================


# Issues #9, #10, #13, #14, #16, #17, #18, #19, #20: House append ----

house_append <- read.csv("data/intermediate/cand_house_append.csv")

# Rename 'name' to 'name_snyder' if needed
if ("name" %in% names(house_append) && !"name_snyder" %in% names(house_append)) {
  house_append <- house_append |> rename(name_snyder = name)
}

# Remove u_g and vote_g_share columns if they exist
house_append <- house_append |>
  select(-any_of(c("u_g", "vote_g_share")))

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
            w_g = 1,
            vote_g = NA)
}


# Issue #26: Missing gubernatorial candidate states ----

cand <- jsdat %>%
  tidylog::mutate(
    state = replace(state, state == "" & year == 2011 & office == "G", "LA")
  )


# Issue #27: Three last name misspellings ----

cand <- cand %>%
  tidylog::mutate(
    name_snyder = replace(name_snyder, str_detect(name_snyder, "YEVANCY"), "YEVANCEY, MANNY"),
    name_snyder = replace(name_snyder, str_detect(name_snyder, "STANCZACK"), "STANCZAK, JAMES"),
    name_snyder = replace(name_snyder, str_detect(name_snyder, "WEIDER"), "WIEDER, JOHN")
  )


# Issue #29: Fix Ron Caesar Spelling ----

cand <- cand %>%
  tidylog::mutate(
    name_snyder = replace(name_snyder, name_snyder == "CEASAR, RON" & state == "LA", "CAESAR, RON")
  )


# Issue #30: Corrections on incumbency ----

cand <- cand %>%
  tidylog::mutate(
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
    "WAKELY, TOMMY" ~ "WAKELY, THOMAS J. (TOM)",
    "CUELLAR, HENRY" ~ "CUELLAR, ENRIQUE ROBERTO (HENRY)",
    "SHERRILL, MIKIE" ~ "SHERRILL, REBECCA MICHELLE (MIKIE)",
    "KELLY, TRENT" ~ "KELLY, JOHN TRENT",
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
  ~state, ~year, ~office, ~dist, ~type, ~nextup, ~party, ~party_formal, ~name_snyder, ~inc, ~vote_g, ~w_g,
  # NY-15
  "NY", 2024, "H", 15, "G", 2026, "D", "D", "TORRES, RITCHIE", 1, 130392, 1,
  "NY", 2024, "H", 15, "G", 2026, "R", "R", "DURAN, GONZALEZ", 0, 36010, 0,
  "NY", 2024, "H", 15, "G", 2026, "Other", "LaRouche", "JOSE VEGA, LAROUCHE", 0, 0, 0,
  # Maine Senate
  "ME", 2024, "S", 2, "G", 2030, "R", "R", "KOUZOUNAS, DEMI", 0, 284338, 0,
  "ME", 2024, "S", 2, "G", 2030, "D", "D", "COSTELLO, DAVID ALLEN", 0, 88891, 0,
  "ME", 2024, "S", 2, "G", 2030, "I", "I", "KING, ANGUS S., JR.", 1, 427331, 1,
  "ME", 2024, "S", 2, "G", 2030, "I", "I", "CHERRY, JASON S.", 0, 20222, 0,
  # Vermont Senate
  "VT", 2024, "S", 2, "G", 2030, "R", "R", "MALLOY, GERALD", 0, 116512, 0,
  "VT", 2024, "S", 2, "G", 2030, "I", "I", "SANDERS, BERNARD (BERNIE)", 1, 229429, 1,
  "VT", 2024, "S", 2, "G", 2030, "I", "I", "BERRY, STEVE", 0, 7941, 0,
  "VT", 2024, "S", 2, "G", 2030, "Lbt", "Lbt", "HILL, MATT", 0, 4530, 0,
  "VT", 2024, "S", 2, "G", 2030, "Other", "Green Mountain Peace and Justice", "SCHOVILLE, JUSTIN", 0, 3339, 0,
  "VT", 2024, "S", 2, "G", 2030, "Other", "Epic", "STEWART GREENSTEIN, MARK", 0, 1104, 0
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
    n = first(na.omit(n)),
    totalvotes = first(na.omit(totalvotes)),
    .groups = "drop"
  )

# Remove the original multi-row fusion candidates and add the aggregated versions
cand <- cand %>%
  filter(!(is_fusion_state & n_party_rows > 1)) %>%
  select(-n_party_rows, -is_fusion_state) %>%
  bind_rows(fusion_agg)


# Recalculate totalvotes ----
# After fusion aggregation, recalculate:
# - totalvotes: sum of vote_g within each race
# - n: number of candidates in the race

cand <- cand %>%
  group_by(state, year, office, dist, type) %>%
  mutate(
    n = n(),
    totalvotes = sum(vote_g, na.rm = TRUE)
  ) %>%
  ungroup()


write_rds(cand, "data/intermediate/candidates_2006-2024.rds")
