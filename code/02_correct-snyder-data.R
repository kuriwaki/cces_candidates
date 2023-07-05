library(tidyverse)
library(haven)

df <- read_dta("data/snyder/2022-09-30 tmp_gov_sen_house_1990_2020.dta")
names(df)

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

# Add 1992 special elections

# Add 1993 special elections

# Add 1994 special elections

# Add 1995 special elections

# Add 1996 special elections

# Add 1997 special elections

# Add 1998 special elections

# Add 1999 special elections

# Add 2000 special elections

# Add 2001 special elections

# Add 2002 special elections

# Add 2003 special elections

# Add 2004 special elections

# Add 2005 special elections
