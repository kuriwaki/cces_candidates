library(tidyverse)
library(haven)

df <- read_dta("data/snyder/2022-09-30 tmp_gov_sen_house_1990_2020.dta")
names(df)

df  |>
filter(office == "H", w_g == 1, year == 1998, state == "NY")  |>
group_by(state, dist)  |>
count()  |>
View()

# Add 1990 VT at-large district

df <- df  |>
    add_row(state = "VT",
            year = 1990,
            office = "H",
            dist = 1,
            type = "G",
            nextup = 1992,
            party = "I",
            dem_rep_oth = NA,
            name = "SANDERS, BERNARD (BERNIE)",
            inc = 0,
            vote_g = 117522,
            w_g = 1,
            u_g = NA_real_)  |>
    add_row(state = "VT",
            year = 1990,
            office = "H",
            dist = 1,
            type = "G",
            nextup = 1992,
            party = "R",
            dem_rep_oth = NA,
            name = "SMITH, PETER PLYMPTON",
            inc = 1,
            vote_g = 82938,
            w_g = 0,
            u_g = NA_real_)  |>
    add_row(state = "VT",
            year = 1990,
            office = "H",
            dist = 1,
            type = "G",
            nextup = 1992,
            party = "D",
            dem_rep_oth = NA,
            name = "SANDOVAL, DOLORES",
            inc = 0,
            vote_g = 6315,
            w_g = 0,
            u_g = NA_real_)  |>
    add_row(state = "VT",
            year = 1990,
            office = "H",
            dist = 1,
            type = "G",
            nextup = 1992,
            party = "Liberty Union",
            dem_rep_oth = NA,
            name = "DIAMONDSTONE, PETER",
            inc = 0,
            vote_g = 1965,
            w_g = 0,
            u_g = NA_real_)

# Add 1990 NY 14 special election

# Add 1990 NY 18 special election

# Add 1990 NJ 1 special election

# Add 1991 special elections

# Add 1992 VT at-large district

df <- df  |>
    add_row(state = "VT",
            year = 1992,
            office = "H",
            dist = 1,
            type = "G",
            nextup = 1994,
            party = "I",
            dem_rep_oth = NA,
            name = "SANDERS, BERNARD (BERNIE)",
            inc = 1,
            vote_g = 162724,
            w_g = 1,
            u_g = NA_real_)  |>
    add_row(state = "VT",
            year = 1992,
            office = "H",
            dist = 1,
            type = "G",
            nextup = 1994,
            party = "R",
            dem_rep_oth = NA,
            name = "PHILBIN, TIM",
            inc = 0,
            vote_g = 86901,
            w_g = 0,
            u_g = NA_real_)  |>
    add_row(state = "VT",
            year = 1992,
            office = "H",
            dist = 1,
            type = "G",
            nextup = 1994,
            party = "D",
            dem_rep_oth = NA,
            name = "YOUNG, LEWIS EMMET",
            inc = 0,
            vote_g = 22279,
            w_g = 0,
            u_g = NA_real_)  |>
    add_row(state = "VT",
            year = 1992,
            office = "H",
            dist = 1,
            type = "G",
            nextup = 1994,
            party = "Liberty Union",
            dem_rep_oth = NA,
            name = "DIAMONDSTONE, PETER",
            inc = 0,
            vote_g = 3660,
            w_g = 0,
            u_g = NA_real_)  |>
    add_row(state = "VT",
            year = 1992,
            office = "H",
            dist = 1,
            type = "G",
            nextup = 1994,
            party = "Natural Law/New Alliance",
            dem_rep_oth = NA,
            name = "DEWEY, JOHN",
            inc = 0,
            vote_g = 3549,
            w_g = 0,
            u_g = NA_real_)  |>
    add_row(state = "VT",
            year = 1992,
            office = "H",
            dist = 1,
            type = "G",
            nextup = 1994,
            party = "Freedom for LaRouche",
            dem_rep_oth = NA,
            name = "MILLER, DOUGLAS",
            inc = 0,
            vote_g = 2049,
            w_g = 0,
            u_g = NA_real_)

# Add 1998 NY

df <- df |>
  add_row(state = "NY",
          year = 1998,
          office = "H",
          dist = 6,
          type = "G",
          nextup = 2000,
          party = "D",
          dem_rep_oth = NA,
          name = "MEEKS, GREGORY W.",
          inc = 0,
          vote_g = 73235+1693+1194,
          w_g = 1,
          u_g = 1
          )

# Add 2004 VT at-large district

df <- df  |>
    add_row(state = "VT",
            year = 2004,
            office = "H",
            dist = 1,
            type = "G",
            nextup = 2006,
            party = "I",
            dem_rep_oth = NA,
            name = "SANDERS, BERNARD (BERNIE)",
            inc = 1,
            vote_g = 205774,
            w_g = 1,
            u_g = NA_real_)  |>
    add_row(state = "VT",
            year = 2004,
            office = "H",
            dist = 1,
            type = "G",
            nextup = 2006,
            party = "R",
            dem_rep_oth = NA,
            name = "PARKE, GREG",
            inc = 0,
            vote_g = 74721,
            w_g = 0,
            u_g = NA_real_)  |>
    add_row(state = "VT",
            year = 2004,
            office = "H",
            dist = 1,
            type = "G",
            nextup = 2006,
            party = "D",
            dem_rep_oth = NA,
            name = "DROWN, LARRY",
            inc = 0,
            vote_g = 21684,
            w_g = 0,
            u_g = NA_real_)  |>
    add_row(state = "VT",
            year = 2004,
            office = "H",
            dist = 1,
            type = "G",
            nextup = 2006,
            party = "Liberty Union/Progressive",
            dem_rep_oth = NA,
            name = "NEWTON, JANE",
            inc = 0,
            vote_g = 3018,
            w_g = 0,
            u_g = NA_real_)


