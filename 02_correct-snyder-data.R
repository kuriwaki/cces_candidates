library(tidyverse)
library(haven)

# raw
jsdat_raw <- read_dta("data/snyder/2021-07-29 sen_gov_house_2006_2020.dta")


# issue 7
jsdat <- jsdat_raw %>%
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

# Senate dist issue
jsdat <- jsdat %>%
  group_by(state, year, office) %>%
  arrange(dist) %>%
  fill(dist, .direction = "down") %>%
  mutate(
    dist = replace(dist, state == "AL" & office == "S" & type == "S" & year == 2017, 2),
    dist = replace(dist, state == "AZ" & office == "S" & type == "S" & year == 2020, 3),
    dist = replace(dist, state == "LA" & office == "H" & name == "LETLOW, JULIA", 5)
  )

# Fixing 2020 Georgia Special candidates
jsdat <- jsdat %>%
  mutate(
    temp = ifelse(state == "GA" & year == 2020 & type == "S", 1, 0),
    temp = replace(temp, name == "LOEFFLER, KELLY" |
      name == "WARNOCK, RAPHAEL GAMALIEL", 0)
  ) %>%
  filter(temp == 0) %>%
  select(-temp) %>%
  mutate(
    vote_g = replace(vote_g, name == "LOEFFLER, KELLY", 2195841),
    vote_g = replace(vote_g, name == "WARNOCK, RAPHAEL GAMALIEL", 2289113),
    vote_g = replace(vote_g, name == "OSSOFF, JON", 2269923),
    vote_g = replace(vote_g, name == "PERDUE, DAVID A.", 2214979)
  )

# Adding "runoff" variable and removing extraneous candidates
## Georgia data comes from https://sos.ga.gov/index.php/Elections/current_and_past_elections_results
## Louisiana data comes from https://voterportal.sos.la.gov/graphical
jsdat <- jsdat %>%
  mutate(
    temp = 0, # Temporary var that ids non-runoff candidates
    temp = replace(temp, state == "LA" & year == 2020 & dist == 5, 1),
    temp = replace(temp, name == "LETLOW, LUKE J." & year == 2020 |
      name == "HARRIS, LANCE" & year == 2020, 0)
  ) %>%
  filter(temp == 0,
    name != "BUCKLEY, ALLEN" | year != 2008) %>%
  select(-temp) %>%
  mutate(runoff = case_when(
    state == "GA" & year == 2020 & office == "S" ~ 1, # 2020 Georgia Runoff
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
  )) %>%
  mutate(runoff = case_when(
    state == "GA" | state == "LA" ~ runoff,
    TRUE ~ NA_real_
  ))

# Correcting vote totals to reflect runoffs
jsdat <- jsdat %>%
  mutate(vote_g = case_when(
    year == 2008 & name == "MARTIN, JAMES FRANCIS (JIM)" ~ 909923,
    year == 2008 & name == "CHAMBLISS, C. SAXBY" ~ 1228033,
    year == 2020 & name == "LETLOW, LUKE J." ~ 49183,
    year == 2020 & name == "HARRIS, LANCE" ~ 30124,
    TRUE ~ vote_g
  ))

# Karin Housley w_g fix
jsdat <- jsdat %>%
  mutate(w_g = replace(w_g, name == "HOUSLEY, KARIN" & year == 2018, 0))

# fixing blank party entries
jsdat <- jsdat %>%
  mutate(party = replace(party, name == "COOPER, ERIC" & state == "IA" & year == 2010, "Lbt"),
         party = replace(party, name == "HUGHES, GREGORY JAMES" & state == "IA" & year == 2010, "I"),
         party = replace(party, name == "NARCISSE, JONATHAN R." & state == "IA" & year == 2010, "I"),
         party = replace(party, name == "ROSENFIELD, DAVID" & state == "IA" & year == 2010, "I"),
         party = replace(party, name == "BEACHAM, ANDREW R." & state == "KY" & year == 2012, "I"),
         party = replace(party, name == "VANCE, RANDOLPH S." & state == "KY" & year == 2012, "I"),
         party = replace(party, name == "MCMASTERS, THOMAS (TOM)" & state == "OH" & year == 2016, "NPA"),
         party = replace(party, name == "SMITH, RAYBURN DOUGLAS" & state == "PA" & year == 2012, "Lbt"),
         dist = replace(dist, name == "VANCE, RANDOLPH S.", 6)) %>%
  mutate(party = case_when(
    name == "[NONE OF THESE]" ~ "NPA",
    TRUE ~ party
  )) %>%
  filter(party != "")

# party_formal coding
jsdat <- jsdat %>%
  mutate(party_formal = party) %>%
  mutate(
    party_formal = recode(party_formal,
      # Independents
      "Indep" = "I",
      "IDP" = "I",
      "Indep Pty" = "I",
      "Indep P" = "I",
      "independent" = "I",
      "Indp" = "I",
      "I (1)" = "I",
      "I (2)" = "I",
      "I (3)" = "I",
      "I - Maine Course" = "I",
      "IDEA" = "I",
      "IP" = "I",
      "Indep P of DE" = "I",
      "Indep Pty of OR" = "I",
      "Indep for ME" = "I",
      "Marijuana" = "I",
      "O" = "I",

      # Libertarian
      "L" = "Lbt",

      # Independent American Party
      "Indep Amer" = "IAP",
      "Independent Amer" = "IAP",
      "Independent American" = "IAP",

      # Independent Green
      "Indep Grn" = "I Grn",

      # Independent Reform
      "Indep Rfm" = "I Reform",

      # American Party of SC
      "Amer" = "Amer Pty of SC",

      # Conservative Parties
      "Amer Const" = "C",
      "CRV" = "C",
      "Conserv" = "C",

      # Constitution
      "CNJ" = "Const",
      "CPI" = "Const",
      "CST" = "Const",
      "Con" = "Const",
      "Const Pty of FL" = "Const",
      "Const Pty of WI" = "Const",

      # Common Sense
      "CMS" = "Common Sense",
      "Common Sense Pty" = "Common Sense",

      # Democratic-Republican
      "D-R Pty" = "D-R",
      "Democ-Repub" = "D-R",

      # Economic Growth
      "Economic Growth" = "Econ Growth",

      # For the People
      "For The People" = "For the People",

      # Freedom
      "Fdm" = "Freedom",

      # Independence
      "independence" = "Independence",

      # Legal Marijuana Now
      "Legal Marij" = "Legal Marijuana Now",
      "Legal Marij Now" = "Legal Marijuana Now",
      "Legal Medical Now" = "Legal Marijuana Now",
      "Legal marijuana now" = "Legal Marijuana Now",

      # Liberty Union
      "Lty U" = "Liberty Union",

      # Mountain
      "Mountain Pty" = "Mountain",

      # Natural Law Party
      "Nlp" = "Natural Law",

      # Nebraska
      "NB" = "Nebraska",

      # New Independent Party
      "New Indep Pty Iowa" = "New Indep Pty",

      # No Party Affiliation
      "NP" = "NPA",
      "NSP" = "NPA",
      "No Political Pty" = "NPA",
      "V" = "NPA",
      "no affiliation" = "NPA",

      # NSA DID 911
      "NSA Did 911" = "NSA DID 911",

      # Peace and Freedom
      "Peace & Freedom" = "P&F",

      # Petition
      "PET" = "Petition",

      # Populist
      "Pop" = "Populist",
      "Populist Pty" = "Populist",

      # Progressive
      "Pg" = "Progressive",

      # Reform
      "Refomr" = "Rfm",
      "reform" = "Rfm",

      # Rent 2 Damn High
      "Rent Too High" = "Rent 2 Damn High",

      # Socialist Party
      "Socialist" = "SUS",
      "Sos" = "SUS",

      # Socialist Worker
      "Soc Wk" = "SWP",
      "Soc Work" = "SWP",
      "Soc Workers" = "SWP",

      # Taxpayer
      "Taxp" = "Taxpayers",

      # Tea Party
      "NJ Tea Pty" = "Tea Pty",

      # Unaffiliated
      "UNA" = "Unaffiliated",
      "Una" = "Unaffiliated",

      # United Citizens
      "UNC" = "United Citizens",

      # Unity
      "Unity Pty of CO" = "UPA",

      # U.S. Taxpayers
      "Ust" = "US Taxpayers",
      "us taxpayers" = "US Taxpayers",

      # Write-in
      "W-I (1)" = "W-I",
      "W-I (2)" = "W-I",
      "W-I (3)" = "W-I",
      "W-I (R)?" = "W-I (R)",

      # We the People
      "We The People" = "We the People",

      # We Deserve Better
      "we deserve better" = "We Deserve Better",

      # Working Families
      "Work Fam" = "Wk Fam",
      "Working Families" = "Wk Fam"
    ),
    party_formal = replace(party_formal, name == "PERRONE, MICHAEL, JR." & year == 2008, "I Pg"),
    party_formal = replace(party_formal, name == "GEDDINGS, HAROLD, III" & year == 2014, "Labor")
  )

# Fusion 2018 - some removals ----

cand_level_vars <- c("year", "office", "state", "dist", "type", "runoff", "nextup", "name")

# recode fusion people post 2018-2020 as fusion by summing their votes
entries_fusion_post18 <- jsdat %>%
  ungroup() %>%
  filter(year %in% c(2018, 2020), state %in% c("NY", "CT", "SC")) %>%
  mutate(party_formal = fct_relevel(party_formal, "D", "R")) %>%
  arrange(party_formal) %>%
  group_by(across(all_of(cand_level_vars))) %>%
  select(party_formal, inc, vote_g, w_g) %>%
  # add votes, concatenate party, and take w_g
  summarize(
    vote_g = as.integer(sum(vote_g)),
    w_g = as.integer(any(w_g == 1)),
    inc = as.integer(any(inc == 1)),
    party_formal = str_c(as.character(party_formal), collapse = ", "),
    nparties = n(),
    .groups = "drop"
  ) %>%
  filter(nparties >= 2) %>%
  select(-nparties) %>%
  mutate(
    party = replace(party_formal,
                    str_sub(party_formal, 1, 1) == "D",
                    "D"),
    party = replace(party,
                    str_sub(party_formal, 1, 1) == "R",
                    "R")
  )

jsdat <- jsdat %>%
  # drop all candidates whose names match with the fusion list
  anti_join(entries_fusion_post18, by = cand_level_vars) %>%
  # stack the summarized versions back in
  bind_rows(entries_fusion_post18)



# party coding
jsdat <- jsdat %>%
  mutate(
    party = recode(party,
      # Democrats
      "DFL" = "D",
      "D,WF" = "D",
      "D,Wk Fam" = "D",
      "D, I, Wk Fam, Women's Equality" = "D",
      "D, Reform, Wk Fam" = "D",
      "D, Reform, Wk Fam, Women's Equality" = "D",
      "D, Wk Fam" = "D",
      "D, Wk Fam, Women's Equality" = "D",
      "D, Women's Equality" = "D",
      "D,C,Indep,WF" = "D",
      "D,I,WF" = "D",
      "D,IDP,WF" = "D",
      "D,Indep,WF" = "D",
      "D,R" = "D",
      "D,WF" = "D",
      "D,WF,IDP" = "D",
      "D,WF,Indep" = "D",
      "D,Wk Fam" = "D",
      "D, I, Reform, Wk Fam, Women's Equality" = "D",

      # Republicans
      "R, Reform" = "R",
      "R,C" = "R",
      "R, C" = "R",
      "R, C, Reform" = "R",
      "R, C, I, Reform" = "R",
      "R, C, Independence" = "R",
      "R, Const, Independence" = "R",
      "R, I" = "R",
      "R,C,I" = "R",
      "R,C,Indep" = "R",
      "R,C,Lbt" = "R",
      "R,C,SCC" = "R",
      "R,C,Taxp" = "R",
      "R,CR" = "R",
      "R,CRV" = "R",
      "R,CRV,IDP" = "R",
      "R,I" = "R",
      "R,IDP" = "R",
      "R,Indep" = "R",
      "R,Lbt" = "R",
      "R,Tax" = "R",
      "R,Tax,C,Indep" = "R",
      "R,Taxp" = "R",
      "I, R" = "R",
      "Conservative, R" = "R",
      "Conservative, R, Reform" = "R",
      "Conservative, I, R" = "R",
      "Conservative, I, R, Reform" = "R",
      "Conservative, I, R, Reform, Tax Revolt" = "R",
      "SCC" = "R"
    ),
    party = replace(party, name == "GRIBBEN, WENDY" & year == 2016, "Grn"),
    party = replace(party, name == "MCLAUGHLIN, CURTIS E., JR." & year == 2014, "I"),
    party = case_when(
      party == "D" | party == "R" | party == "I" | party == "Lbt" |
        party == "Grn" ~ party,
      TRUE ~ "Other"
    )
  )


# REMOVALS -----
# remove triple counted fusion candidates
entries_fusion_pre18 <- jsdat %>%
  ungroup() %>%
  # double counted fusion
  filter(!(name == "KING, PETER T. (PETE)" & party_formal == "R,Tax" & year == 2012 & state == "NY")) %>%
  # keep the sum version of fusion
  filter((party == "D" & str_detect(party_formal, "D.+(Wk Fam|WF)")) |
           (party == "R" & str_detect(party_formal, "R.+(C|Indep|Tax)")))

cands_fusion_pre18 <- jsdat %>%
  ungroup() %>%
  semi_join(distinct(entries_fusion_pre18, year, office, state, dist, type, name)) %>%
  mutate(drop = !str_detect(party_formal, ",")) # we will flag the candidates to DROP. This is candidates who are NOT combined counts.



# Drop the non-combined candidates ------
entries_to_drop <- filter(cands_fusion_pre18, drop) %>%
  add_row(name = "KING, PETER T. (PETE)",
          party_formal = "R,Tax",
          office = "H",
          state = "NY",
          dist = 2,
          type = "G",
          year = 2012,
          runoff = NA,
          nextup = 2014
          )

jsdat <- jsdat %>%
  ungroup() %>%
  anti_join(entries_to_drop,
            by = c(cand_level_vars, "party_formal"))


# removing extraneous observations ------
jsdat <- jsdat %>%
  filter(name != "SCHWEIDEL, JOEL",
         name != "CARLSON, ELAINE SUE",
         name != "BEARDSLEY, MICHAEL",
         name != "WELCH, PETER F." | party != "R",
         name != "WELCH, PETER F." | party_formal != "D" | year != 2008
  )

# WELCH, PETER F. party formal correction
jsdat <- jsdat %>%
  mutate(party_formal = replace(party_formal, name == "WELCH, PETER F." & year == 2008, "D"))


# removing entries without names
jsdat <- jsdat %>%
  filter(name != "" | !is.na(vote_g))

# adding in vote totals
jsdat <- jsdat %>%
  mutate(vote_g = replace(vote_g, name == "JINDAL, BOBBY" & office == "H" & year == 2006, 130508),
         u_g = replace(u_g, name == "JINDAL, BOBBY" & office == "H" & year == 2006, 0),
         vote_g = replace(vote_g, name == "MCCRERY, JAMES O. (JIM)" & office == "H" & year == 2006, 77078),
         u_g = replace(u_g, name == "MCCRERY, JAMES O. (JIM)" & office == "H" & year == 2006, 0),
         vote_g = replace(vote_g, name == "ALEXANDER, RODNEY M." & office == "H" & year == 2006, 78211),
         u_g = replace(u_g, name == "ALEXANDER, RODNEY M." & office == "H" & year == 2006, 0),
         vote_g = replace(vote_g, name == "BOUSTANY, CHARLES W., JR." & office == "H" & year == 2006, 113720),
         u_g = replace(u_g, name == "BOUSTANY, CHARLES W., JR." & office == "H" & year == 2006, 0),
         vote_g = replace(vote_g, name == "BAKER, RICHARD HUGH" & office == "H" & year == 2006, 94658),
         u_g = replace(u_g, name == "BAKER, RICHARD HUGH" & office == "H" & year == 2006, 0),
         vote_g = replace(vote_g, name == "MELANCON, CHARLES J. (CHARLIE), JR." & office == "H" & year == 2006, 75023),
         u_g = replace(u_g, name == "MELANCON, CHARLES J. (CHARLIE), JR." & office == "H" & year == 2006, 0),
         vote_g = replace(vote_g, name == "JINDAL, BOBBY" & office == "G" & year == 2007, 699275),
         u_g = replace(u_g, name == "JINDAL, BOBBY" & office == "G" & year == 2007, 0),
         vote_g = replace(vote_g, name == "GAIERO, THEODORE J., JR." & office == "H" & year == 2008, 114)
         )

# write
write_rds(jsdat, "data/intermediate/snyder_2006-2020.rds")

# temporary line to create data for jc party cleanup
write_dta(jsdat, "data/intermediate/snyder_2006-2020.dta")
