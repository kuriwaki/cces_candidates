library(tidyverse)
library(haven)

setwd("/Users/jeremiahcha/Dropbox/from-snyder")


# Data Loading ------------------------------------------------------------

js_06 <- read_dta("2020-06-13 election_results_2006_2016.dta") # Candidate data 2006-2016

js_18 <- read_dta("2020-08-16 election_results_2018_names_updated.dta") # Candidate 2018

js_06_18 <- bind_rows(js_06, js_18) # Binding two datasets

js_20 <- read_dta("2021-06-19_election_results_2020_pres_house_ussen.dta") %>%
  filter(party != "Write-in",
         party != "Write-in (Independent)",
         party != "Write-in (Common Sense Moderate)",
         party != "Write-in (Libertarian)",
         party != "Write-in (Democratic)",
         party != "Write-in (Republican)") # Candidate data 2020


# New 2020 Candidates -----------------------------------------------------

new <- c("AVERHART, JAMES", "CARL, JERRY", "HARVEY-HALL, PHYLLIS", "MOORE, BARRY",
         "WINFREY, ADIA", "GALVIN, ALYSE S.", "SHEDD, TIFFANY", "MARTIN, BRANDON",
         "BAH, IMAN", "SCHLASS, BRANDON", "WOOD, DANIEL", "DISANTO, DELINA",
         "BARNETT, JOSHUA", "MUSCATO, MICHAEL", "WILLIAMS, CELESTE", "HANSON, WILLIAM H.",
         "HAMILTON, TAMIKA", "KENNEDY, BRYNNE S.", "GIBLIN, SCOTT", "BISH, CHRIS",
         "PATTERSON, BUZZ", "BUBSER, CHRISTINE", "OBERNOLTE, JAY", )


# Regex Check -------------------------------------------------------------

js_06_18 %>%
  filter(str_detect(name, "MCNERNEY,")) %>%
  select(name, state, dist, office)

js_20 %>%
  filter(str_detect(name, "MCNERNEY")) %>%
  select(name, state, dist, office)


# 2020 Name Changes -------------------------------------------------------

js_20 %>%
  mutate(name = replace(name, name == "ROGERS, MIKE", "ROGERS, MICHAEL DENNIS (MIKE)"),
         name = replace(name, name == "ADERHOLT, ROBERT B.", "ADERHOLT, ROBERT BROWN "),
         name = replace(name, name == "BROOKS, MO", "BROOKS, MORRIS J. (MO), JR."),
         name = replace(name, name == "PALMER, GARY J.", "PALMER, GARY"),
         name = replace(name, name == "GALVIN, ALYSE S.", "GALVIN, ALYSE S."), #SAME
         name = replace(name, name == "SEWELL, TERRI A.", "SEWELL, TERRYCINA ANDREA (TERRI)"),
         name = replace(name, name == "YOUNG, DON", "YOUNG, DONALD E. (DON)"),
         name = replace(name, name == "O'HALLERAN, TOM", "O'HALLERAN, TOM C."),
         name = replace(name, name == "KIRKPATRICK, ANN", "KIRKPATRICK, ANN"), #SAME
         name = replace(name, name == "GRIJALVA, RAUL M.", "GRIJALVA, RAUL M."), #SAME
         name = replace(name, name == "GOSAR, PAUL A.", "GOSAR, PAUL ANTHONY"),
         name = replace(name, name == "GREENE, JOAN", "GREENE, JOAN"), #SAME
         name = replace(name, name == "BIGGS, ANDY", "BIGGS, ANDY"), #SAME
         name = replace(name, name == "TIPIRNENI, HIRAL", "TIPIRNENI, HIRAI"), #SAME
         name = replace(name, name == "SCHWEIKERT, DAVID", "SCHWEIKERT, DAVID"), #SAME
         name = replace(name, name == "GALLEGO, RUBEN", "GALLEGO, RUBEN"), #SAME
         name = replace(name, name == "LESKO, DEBBIE", "LESKO, DEBBIE"), #SAME
         name = replace(name, name == "STANTON, GREG", "STANTON, GREG"), #SAME
         name = replace(name, name == "GILES, DAVID VICTOR", "GILES, DAVE"),
         name = replace(name, name == "CRAWFORD, ERIC A. (RICK)", "CRAWFORD, ERIC ALAN (RICK)"),
         name = replace(name, name == "ELLIOTT, JOYCE", "ELLIOTT, JOYCE"), #SAME,
         name = replace(name, name == "HILL, J FRENCH", "HILL, FRENCH"), # 2020 Name has first initial (J)
         name = replace(name, name == "WOMACK, STEVE", "WOMACK, STEPHEN ALLEN (STEVE)"),
         name = replace(name, name == "KALAGIAS, MICHAEL J.", "KALAGIAS, MICHAEL J."),
         name = replace(name, name == "WESTERMAN, BRUCE", "WESTERMAN, BRUCE"), #SAME
         name = replace(name, name == "GILBERT, FRANK", "GILBERT, FRANK"), #SAME
         name = replace(name, name == "DENNEY, AUDREY", "DENNEY, AUDREY"), #SAME
         name = replace(name, name == "LAMALFA, DOUG", "LAMALFA, DOUG"), #SAME,
         name = replace(name, name == "HUFFMAN, JARED", "HUFFMAN, JARED WILLIAM"),
         name = replace(name, name == "MENSING, DALE K.", "MENSING, DALE K."), #SAME
         name = replace(name, name == "GARAMENDI, JOHN", "GARAMENDI, JOHN R."),
         name = replace(name, name == "MCCLINTOCK, TOM", "MCCLINTOCK, THOMAS MILLER (TOM)"),
         name = replace(name, name == "THOMPSON, MIKE", "THOMPSON, C. MICHAEL (MIKE)"),
         name = replace(name, name == "MATSUI, DORIS O.", "MATSUI, DORIS O."), #SAME
         name = replace(name, name == "BERA, AMI", "BERA, AMERISH (AMI)"),
         name = replace(name, name == "MCNERNEY, JERRY", "MCNERNEY, GERALD MARK (JERRY)"),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),
         name = replace(name, name == ""),

         )
