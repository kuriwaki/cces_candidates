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

write_rds(cand, "data/intermediate/candidates_2006-2020.rds")