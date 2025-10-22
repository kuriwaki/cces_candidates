library(tidyverse)
library(haven)

js <- read_dta("data/snyder/2025-08-18 tmp_S_H_G_1990_2024.dta")


# party coding
js |>
  mutate(party_formal = party) |>
  count(party_formal, sort = TRUE)
  tidylog::mutate(
    party_formal = recode(
      party_formal,
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
    )
  ) |>
  tidylog::mutate(
    party = recode(
      party,
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
      "SCC" = "R",
    )
  ) |>
  mutate(
    party_formal = replace(party_formal, name == "PERRONE, MICHAEL, JR." & year == 2008, "I Pg"),
    party_formal = replace(party_formal, name == "GEDDINGS, HAROLD, III" & year == 2014, "Labor")
  ) |>
  mutate(
    party = replace(party, name == "GRIBBEN, WENDY" & year == 2016, "Grn"),
    party = replace(party, name == "MCLAUGHLIN, CURTIS E., JR." & year == 2014, "I"),
  ) |>
  mutate(
    party = replace(party_formal,
                    str_sub(party_formal, 1, 1) == "D",
                    "D"),
    party = replace(party,
                    str_sub(party_formal, 1, 1) == "R",
                    "R")
  )
