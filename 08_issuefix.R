cand <- readRDS("data/intermediate/candidates_2006-2020.rds")

# Fixing Issue # 26 "Missing gubernatorial candidate states #26"

cand <- cand %>%
  mutate(
    state = replace(state, state == "" & year == 2011 & office == "G", "LA")
  )

# Fixing Issue # 27 "Three last name misspellings #27"
cand <- cand %>%
  mutate(
    name_snyder = replace(name_snyder, grepl("YEVANCY", name_snyder), "YEVANCEY, MANNY"),
    name_snyder = replace(name_snyder, grepl("STANCZACK", name_snyder), "STANCZAK, JAMES"),
    name_snyder = replace(name_snyder, grepl("WEIDER", name_snyder), "WIEDER, JOHN")
  )

# Fixing Issue # 29 "Fix Ron Caesar Spelling #29"
cand <- cand %>%
  mutate(
    name_snyder = replace(name_snyder, name_snyder == "CEASAR, RON" & state == "LA", "CAESAR, RON")
  )

# Fixing Issue # 26 "Missing gubernatorial candidate states #26"

cand <- cand %>%
  mutate(
    state = replace(state, state == "" & year == 2011 & office == "G", "LA")
  )

# Fixing Issue # 27 "Three last name misspellings #27"
cand <- cand %>%
  mutate(
    name_snyder = replace(name_snyder, grepl("YEVANCY", name_snyder), "YEVANCEY, MANNY"),
    name_snyder = replace(name_snyder, grepl("STANCZACK", name_snyder), "STANCZAK, JAMES"),
    name_snyder = replace(name_snyder, grepl("WEIDER", name_snyder), "WIEDER, JOHN")
  )

# Fixing Issue # 29 "Fix Ron Caesar Spelling #29"
cand <- cand %>%
  mutate(
    name_snyder = replace(name_snyder, name_snyder == "CEASAR, RON" & state == "LA", "CAESAR, RON")
  )

# Fixing Issue # 30 "Corrections on incumbency"
cand <- cand %>%
  mutate(
    inc = replace(inc, name_snyder == "BREWER, JANICE (JAN)" & state == "AZ" & office == "G" & year == 2010, 1),
    inc = replace(inc, name_snyder == "MURRAY, JULIANNE E." & state == "DE" & office == "G" & year == 2020, 0)
  )

# Fixing Issue # 35 "Standardized names -- Joe Kennedy III (MA)

cand <- cand |>
  mutate(
    name_snyder = replace(name_snyder, name_snyder == "KENNEDY, JOSEPH P., III" & year == 2018 & office == "H", "KENNEDY, JOSEPH P. (JOE), III")
  ) |>
  mutate(
    name_snyder = replace(name_snyder, name_snyder == "BEUTLER, JAIME HERRERA", "HERRERA BEUTLER, JAIME")
    ) |>
  mutate(
    name_snyder = replace(name_snyder, name_snyder == "DEAN, MADELEINE", "DEAN CUNNANE, MADELEINE"),
    name_snyder = replace(name_snyder, name_snyder == "CUNNANE, MADELEINE DEAN", "DEAN CUNNANE, MADELEINE")
  ) |>
  mutate(
    name_snyder = replace(name_snyder, name_snyder == "WAKELY, TOMMY", "WAKELY, THOMAS J. (TOM)")
  )

write_rds(cand, "data/intermediate/candidates_2006-2020.rds")