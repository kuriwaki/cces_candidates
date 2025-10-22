cand <- readRDS("data/intermediate/prelim/candidates_party-recoded.rds")

# #35 "Standardized names -- Joe Kennedy III
# #43
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
