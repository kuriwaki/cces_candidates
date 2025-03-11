cand <- readRDS("data/intermediate/candidates_2006-2022.rds")

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


write_rds(cand, "data/intermediate/candidates_2006-2022.rds")