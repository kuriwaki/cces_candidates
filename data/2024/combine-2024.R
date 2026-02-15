library(tidyverse)
library(haven)


js <- read_dta("data/2024/H_S_2024_js_2025-07-11.dta")
incs <- read_csv("data/2024/2024-inc-codings.csv")
pres <- read_dta("data/2024/skuriwaki/2024_parsed_sk.dta")

js_dat <- js |>
  arrange(desc(vote_g)) |>
  mutate(rank = 1:n(), .by = c(state, office, dist, type, party))

inc_dat <- incs |>
  arrange(desc(vote_g)) |>
  mutate(rank = 1:n(), .by = c(state, office, dist, type, party)) |>
  arrange(state, office, dist, type, party) |>
  select(state, office, dist, type, party, inc, rank) |>
  tidylog::filter(!is.na(party))

gov_manual <-
  tribble(
    ~state, ~party, ~name, ~vote_g, ~inc,
    "DE", "R", "RAMONE, MICHAEL (MIKE) J.", 219050, 0,
    "DE", "D", "MEYER, MATTHEW (MATT) STEPHEN", 279585, 0,
    "IN", "R", "BRAUN, MIKE", 1561279, 0,
    "IN", "D", "MCCORMICK, JENIFFER", 1179967, 0,
    "MO", "R", "KEHOE, MICHAEL LEO", 1746317, 0,
    "MO", "D", "QUADE, CRYSTAL", 1141152, 0,
    "MT", "R", "GIANFORTE, GREG", 354448, 1,
    "MT", "D", "BUSSE, RYAN", 232547, 0,
    "MT", "Lbt", "LEIB, KAISER", 15191, 0,
    "NH", "R", "AYOTTE, KELLY A.", 435400, 0,
    "NH", "D", "CRAIG, JOYCE", 360068, 0,
    "NC", "R", "ROBINSON, MARK KEITH", 2241309, 0,
    "NC", "D", "STEIN, JOSHUA HAROLD", 3069496, 0,
    "NC", "Lbt", "ROSS, MIKE", 176392, 0,
    "NC", "Constitution", "SMITH, VINNY", 54738, 0,
    "NC", "Grn", "TURNER, WAYNE", 49612, 0,
    "ND", "R", "ARMSTRONG, KELLY", 247056, 0,
    "ND", "D", "PIEPKORN, MERRILL", 94043, 0,
    "ND", "I", "COACHMAN, MICHAEL", 20322, 0,
    "UT", "R", "COX, SPENCER JAMES", 781431, 1,
    "UT", "D", "KING, BRIAN STEPHEN",  420513, 0,
    "UT", "I", "LYMAN, PHILLIP (PHIL) KAY",  200551, 0,
    "UT", "Lbt", "LATHAM, J. ROBERT",  41164, 0,
    "UT", "Other", "WILLIAMS, TOMMY",  27480, 0,
    "VT", "R", "SCOTT, PHILLIP B. (PHIL)", 266439, 1,
    "VT", "D", "CHARLESTIN, ESTHER",  79217,  0,
    "VT", "I", "HOYT, KEVIN", 9368, 0,
    "VT", "I", "GOODBAND, JUNE", 4512, 0,
    "VT", "I", "MUTINO, ELI (POA)", 2414, 0,
    "VT", "W-I", "W-I", 891, 0,
    "WA", "R", "REICHERT, DAVID GEORGE (DAVE)", 1709818, 0,
    "WA", "D", "FERGUSON, ROBERT (BOB) W.",  2143368, 0,
    "WA", "W-I", "W-I",  8202, 0,
    "WV", "R", "MORRISEY, PATRICK J.", 459300, 0,
    "WV", "D", "WILLIAMS, STEPHEN (STEVE) T.", 233976, 0,
  ) |>
  mutate(office = "G", type = "G", .after = state) |>
  mutate(nextup = if_else(state == "VT", 2026, 2028))


pres_dat <- pres |>
  filter(office == "P") |>
  select(office, state, type, name, party, vote_g) |>
  mutate(
    party = if_else(party == "", name, party),
    name = str_to_upper(name),
         name = case_when(
           str_detect(name, "J. TRUMP") ~ "TRUMP, DONALD J.",
           str_detect(name, "KAMALA") ~ "HARRIS, KAMALA",
           str_detect(name, "OLIVER") ~ "OLIVER, CHASE",
           str_detect(party, "GREEN") ~ "STEIN, JILL",
           .default = NA
         )) |>
  mutate(inc = 0, nextup = 2028)

js2024 <- js_dat |>
  tidylog::left_join(
    inc_dat,
    by = c("state", "office", "dist", "type", "party", "rank"),
    relationship = "one-to-one") |>
  tidylog::mutate(inc = replace_na(inc, 0)) |>
  bind_rows(gov_manual) |>
  mutate(w_g = as.numeric(vote_g == max(vote_g)), .by = c(state, office, dist, type)) |>
  mutate(year = 2024,
         nextup = if_else(office == "S", 2030, 2026)) |>
  mutate(nextup = replace(nextup, type == "S" & state == "NE", 2026)) |>
  bind_rows(pres_dat) |>
  select(-rank)

js2024 <- js2024 |>
  mutate(name = case_when(
    str_detect(name, "NANETTE DIAZ") ~ "BARRAGAN, NANETTE DIAZ",
    str_detect(name, "ARRIGO, TONY") ~ "D'ARRIGO, TONY",
    str_detect(name, "(CHUY)") ~ "GARCIA, JESUS G. (CHUY)",
    str_detect(name, "BRIEN, JOSHUA W.") ~ "O'BRIEN, JOOSHUA W.",
    str_detect(name, "ESPOSITO, ANTHONY") ~ "D'ESPOSITO, ANTHONY",
    .default = name
  )) |>
  mutate(year = 2024)


write_rds(js2024, "data/snyder-fmt_2024.rds")
