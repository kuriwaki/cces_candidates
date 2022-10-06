library(stringi)
library(stringr)
library(tidyr)
library(dplyr)
library(haven)


# Load the data ------

jim_data_raw <- read_dta("~/Dropbox/CCES_candidates/Input/election_results_2006_2016.dta")
jim_data <- filter(jim_data_raw, nextup != year)

jim_data2018 <- haven::read_dta("~/Dropbox/CCES_candidates/Input/election_results_2018_names_updated.dta")


# make the 2018 election data the same format at the other years
jim_data2018 <- jim_data2018 |>
  group_by(state, year, office, dist, type, name) |>
  summarize(
    vote_g = sum(vote_g),
    party = str_c(party, collapse = ", "),
    inc = max(inc),
    w_g = max(w_g),
    .groups = "drop"
  )


# Only keep the offices of interest and even years. Make new variables for "house dist" so that we don't
# incorrectly match the senate and governor observations.

jim_data <- bind_rows(jim_data, jim_data2018) |> 
  filter(office %in% c("H", "S", "G"),
         year %% 2 == 0) |> 
  mutate(dist = replace(dist, office == "S", NA)) |> 
  select(-chk_name, -u_g, -nextup) # remove names we will not use

###########################################
# Rename Variables and Pull out Last Names ------
###########################################

# rename some variables
jim_data <- jim_data |>
  rename(
    dist_up = dist,
    st = state
  )

# pull out the last names of candidates in jim's data
jim_data$namelast <- gsub(",.*$", "", jim_data$name)
jim_data$namelast <- word(jim_data$namelast, -1)
jim_data$namelast <- trimws(jim_data$namelast)


###########################################
# Simple Version of Party  --------
###########################################
jim_data <- jim_data |> 
  mutate(party_short = recode(party, 
                              Indep = "I",
                              IDP = "I",
                              L = "Lbt",
                              Refomr = "Rfm",
                              DFL = "D", 
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
                              "R, Reform" = "R",
                              "R,C" = "R",
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
                              
                              #Jaclyn's add ons
                              "Indep Pty" = "I",
                              "Indep P" = "I",
                              "independent" = "I",
                              "Indp" = "I",
  ))

###########################################
# Clean Names in Jim's data  --------
###########################################

jim_data$namelast[jim_data$name == "DEN-DULK, JOHN D. (J.D.)" & jim_data$year == 2006 & jim_data$office == "H"] <- "DENDULK"

jim_data$namelast[jim_data$name == "MACK, MARY BONO" & jim_data$year == 2006 & jim_data$office == "H"] <- "BONO"

jim_data$namelast[jim_data$name == "DEMAIO, ANTHONY R." & jim_data$year == 2006 & jim_data$office == "H"] <- "DE MAIO"
jim_data$name[jim_data$name == "DEMAIO, ANTHONY R."] <- "DE MAIO, ANTHONY R."

jim_data$namelast[jim_data$name == "LAMALFA, DOUG" & jim_data$year == 2012 & jim_data$office == "H"] <- "LA MALFA"

jim_data$namelast[jim_data$name == "LAMALFA, DOUG" & jim_data$year == 2014 & jim_data$office == "H"] <- "LA MALFA"

jim_data$namelast[jim_data$name == "FULLER-KENDALL, VIRGINIA" & jim_data$year == 2012 & jim_data$office == "H"] <- "FULLER"

jim_data$namelast[jim_data$name == "ALARCEN, RICHARD" & jim_data$year == 2016 & jim_data$office == "H"] <- "ALARCON"
jim_data$name[jim_data$name == "ALARCEN, RICHARD"] <- "ALARCON, RICHARD"

jim_data$namelast[jim_data$name == "YEVANCY, MANNY" & jim_data$year == 2012 & jim_data$office == "H"] <- "YEVANCEY"
jim_data$name[jim_data$name == "YEVANCY, MANNY"] <- "YEVANCEY, MANNY"

jim_data$namelast[jim_data$name == "SCURRY-SMITH, GLOREATHA (GLO)" & jim_data$year == 2014 & jim_data$office == "H"] <- "SMITH"

jim_data$namelast[jim_data$name == "SCURRY-SMITH, GLOREATHA (GLO)" & jim_data$year == 2016 & jim_data$office == "H"] <- "SMITH"

jim_data$namelast[jim_data$name == "PERSEK, JOSEPH (JOE)" & jim_data$year == 2014 & jim_data$office == "H"] <- "PERSKE"
jim_data$name[jim_data$name == "PERSEK, JOSEPH (JOE)"] <- "PERSKE, JOSEPH (JOE)"

jim_data$namelast[jim_data$name == "PERRY, ELIZABETH" & jim_data$year == 2014 & jim_data$office == "H"] <- "PERRI"
jim_data$name[jim_data$name == "PERRY, ELIZABETH"] <- "PERRI, ELIZABETH"

jim_data$namelast[jim_data$name == "PUENTE-BRADSHAW, JESSICA" & jim_data$year == 2012 & jim_data$office == "H"] <- "BRADSHAW"

jim_data$namelast[jim_data$name == "STANCZACK, JAMES" & jim_data$year == 2014 & jim_data$office == "H"] <- "STANCZAK"
jim_data$name[jim_data$name == "STANCZACK, JAMES"] <- "STANCZAK, JAMES"

jim_data$namelast[jim_data$name == "HILDEBRANT, ELAINE B." & jim_data$year == 2014 & jim_data$office == "H"] <- "HILDEBRANDT"
jim_data$name[jim_data$name == "HILDEBRANT, ELAINE B."] <- "HILDEBRANDT, ELAINE B."

jim_data$namelast[jim_data$name == "HERRERA BEUTLER, JAIME" & jim_data$year == 2010 & jim_data$office == "H"] <- "HERRERA"

jim_data$namelast[jim_data$name == "CELLIS, PEDRO" & jim_data$year == 2014 & jim_data$office == "H"] <- "CELIS"
jim_data$name[jim_data$name == "CELLIS, PEDRO"] <- "CELIS, PEDRO"

jim_data$namelast[jim_data$name == "SANDLIN, STEPHANIE HERSETH" & jim_data$year == 2006 & jim_data$office == "H"] <- "HERSETH"

jim_data$namelast[jim_data$name == "DELLA VALLE, FRANK L." & jim_data$year == 2010 & jim_data$office == "H"] <- "DELLA VALLE"

jim_data$namelast[jim_data$name == "HASSEN, MARGARET WOOD (MAGGIE)"] <- "HASSAN"
jim_data$name[jim_data$name == "HASSEN, MARGARET WOOD (MAGGIE)"] <- "HASSAN, MARGARET WOOD (MAGGIE)"



# Fix the last names of candidates who ran against people with the same last name in the same district in the same year
jim_data$namelast[jim_data$name == "ROSS, MICHAEL AVERY (MIKE)" & jim_data$year == 2006 & jim_data$office == "H"] <- "M.ROSS"
jim_data$namelast[jim_data$name == "ROSS, JOE C." & jim_data$year == 2006 & jim_data$office == "H"] <- "J.ROSS"

# No corresponding observations in the cces because of the year but gonna fix anyways
jim_data$namelast[jim_data$name == "CHU, JUDY M." & jim_data$year == 2009 & jim_data$office == "H"] <- "J.CHU"
jim_data$namelast[jim_data$name == "CHU, BETTY" & jim_data$year == 2009 & jim_data$office == "H"] <- "B.CHU"

jim_data$namelast[jim_data$name == "JOHNSON, FRED L. (FREDDIE), III" & jim_data$year == 2008 & jim_data$office == "H"] <- "F.JOHNSON"
jim_data$namelast[jim_data$name == "JOHNSON, DAN" & jim_data$year == 2008 & jim_data$office == "H"] <- "D.JOHNSON"

jim_data$namelast[jim_data$name == "WILLIAMS, COBBY MONDALE" & jim_data$year == 2012 & jim_data$office == "H"] <- "C.WILLIAMS"
jim_data$namelast[jim_data$name == "WILLIAMS, LAJENA" & jim_data$year == 2012 & jim_data$office == "H"] <- "L.WILLIAMS"

jim_data$namelast[jim_data$name == "COLLINS, WILLIAM C. (BILL)" & jim_data$year == 2010 & jim_data$office == "H"] <- "W.COLLINS"
jim_data$namelast[jim_data$name == "COLLINS, TIM" & jim_data$year == 2010 & jim_data$office == "H"] <- "T.COLLINS"

jim_data$namelast[jim_data$name == "SMITH, D. ADAM" & jim_data$year == 2018 & jim_data$st == "WA" & jim_data$dist_up == 9 & jim_data$office == "H"] <- "A.SMITH"
jim_data$namelast[jim_data$name == "SMITH, SARAH" & jim_data$year == 2018 & jim_data$st == "WA" & jim_data$dist_up == 9 & jim_data$office == "H"] <- "S.SMITH"

jim_data$namelast[jim_data$name == "SMITH, RAYBURN DOUGLAS" & jim_data$year == 2012 & jim_data$st == "PA" & jim_data$office == "S"] <- "R.SMITH"
jim_data$namelast[jim_data$name == "SMITH, TOM" & jim_data$year == 2012 & jim_data$st == "PA" & jim_data$office == "S"] <- "T.SMITH"

jim_data$namelast[jim_data$name == "HATCH, JULIAN" & jim_data$year == 2006 & jim_data$st == "UT" & jim_data$office == "S"] <- "J.HATCH"
jim_data$namelast[jim_data$name == "HATCH, ORRIN G." & jim_data$year == 2006 & jim_data$st == "UT" & jim_data$office == "S"] <- "O.HATCH"

jim_data$namelast[jim_data$name == "BURKE, MARY" & jim_data$year == 2014 & jim_data$st == "WI" & jim_data$office == "G"] <- "M.BURKE"
jim_data$namelast[jim_data$name == "BURKE, ROBERT" & jim_data$year == 2014 & jim_data$st == "WI" & jim_data$office == "G"] <- "R.BURKE"


# Have to fix peter welch in vermont
jim_data$party[jim_data$name == "WELCH, PETER F." & jim_data$year == 2016 & jim_data$party == "D"] <- "D,R"

# mulitple parties
jim_data$multiple_parties <- str_count(jim_data$party, ",")

# fix some errors in the 2018 code
jim_data$name[jim_data$name=="PETERS, SCOTT"] <- "PETERS, SCOTT H."
jim_data$name[jim_data$name=="KELLY, MIKE"] <- "KELLY, GEORGE J. (MIKE), JR."
jim_data$name[jim_data$name=="RICE, TOM"] <- "RICE, HUGH THOMPSON (TOM), JR."
jim_data$name[jim_data$name=="RUTHERFORD, JOHN"] <- "RUTHERFORD, JOHN H."
jim_data$name[jim_data$name=="MARSHALL, ROGER"] <- "MARSHALL, ROGER W."
jim_data$name[jim_data$name=="WALKER, MARK"] <- "WALKER, BRADLEY MARK"
jim_data$name[jim_data$name=="SCOTT, AUSTIN"] <- "SCOTT, JAMES AUSTIN"
jim_data$name[jim_data$name=="PALMER, GARY"] <- "PALMER, GARY J."
jim_data$name[jim_data$name=="CARBAJAL, SALUD"] <- "CARBAJAL, SALUD O."
jim_data$name[jim_data$name=="LEE, SHEILA JACKSON"] <- "JACKSON LEE, SHEILA"
jim_data$name[jim_data$name=="BEUTLER, JAIME HERRERA"] <- "HERRERA BEUTLER, JAIME"
jim_data$name[jim_data$name=="MOONEY, ALEXANDER X. (ALEX)"] <- "MOONEY, ALEX X."
jim_data$name[jim_data$name=="ROCHESTER, LISA BLUNT"] <- "BLUNT ROCHESTER, LISA"
jim_data$name[jim_data$name=="HILL, FRENCH"] <- "HILL, J. FRENCH"
jim_data$name[jim_data$name=="GOTTHEIMER, JOSHUA S."] <- "GOTTHEIMER, JOSHUA S. (JOSH)"
jim_data$name[jim_data$name=="CORREA, LOU (LOIS)"] <- "CORREA, JOSE LUIS (LOU)"
jim_data$name[jim_data$name=="KENNEDY, JOSEPH P., III"] <- "KENNEDY, JOSEPH P. (JOE), III"
jim_data$name[jim_data$name=="MOOLENAAR, JOHN"] <- "MOOLENAAR, JOHN R."
jim_data$name[jim_data$name=="WEBER, RANDY K., SR."] <- "WEBER, RANDY"
jim_data$name[jim_data$name=="THOMPSON, MIKE"] <- "THOMPSON, C. MICHAEL (MIKE)"


jim_data$inc[jim_data$name=="DEAN, MADELEINE"] <- 0
jim_data$inc[jim_data$name=="JOYCE, JOHN"] <- 0
jim_data$inc[jim_data$name=="WALTZ, MICHAEL"] <- 0
jim_data$inc[jim_data$name=="HOULAHAN, CHRISSY"] <- 0
jim_data$inc[jim_data$name=="RESCHENTHALER, GUY"] <- 0
jim_data$inc[jim_data$name=="MILLER, CAROL"] <- 0
jim_data$inc[jim_data$name=="GUEST, MICHAEL"] <- 0
jim_data$inc[jim_data$name=="DONOVAN, DANIEL M. (DAN), JR."] <- 1
jim_data$inc[jim_data$name=="SWISHER, AARON"] <- 0
jim_data$inc[jim_data$name=="SIMPSON, MICHAEL K. (MIKE)" & jim_data$year==2018] <- 1
jim_data$inc[jim_data$name=="HERN, KEVIN"] <- 0
jim_data$inc[jim_data$name=="FASO, JOHN J." & jim_data$year==2018] <- 1
jim_data$inc[jim_data$name=="JOHNSON, DUSTIN (DUSTY)"] <- 0

#governor wins
jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="AK"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="AK" & jim_data$name=="DUNLEAVY, MIKE"] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="AL"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="AL" & jim_data$name=="IVEY, KAY E."] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="AR"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="AR" & jim_data$name=="HUTCHINSON, WILLIAM (ASA)"] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="AZ"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="AZ" & jim_data$name=="DUCEY, DOUG"] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="CA"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="CA" & jim_data$name=="NEWSOM, GAVIN"] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="CO"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="CO" & jim_data$name=="POLIS, JARED S."] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="CT"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="CT" & jim_data$name=="LAMONT, EDWARD M. (NED)"] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="FL"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="FL" & jim_data$name=="DESANTIS, RONALD D. (RON)"] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="GA"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="GA" & jim_data$name=="KEMP, BRIAN P."] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="HI"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="HI" & jim_data$name=="IGE, DAVID YUTAKA"] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="IA"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="IA" & jim_data$name=="REYNOLDS, KIM"] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="ID"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="ID" & jim_data$name=="LITTLE, BRAD"] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="IL"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="IL" & jim_data$name=="PRITZKER, JAY (J.B.)"] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="KS"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="KS" & jim_data$name=="KELLY, LAURA"] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="MA"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="MA" & jim_data$name=="BAKER, CHARLES D. (CHARLIE)"] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="MD"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="MD" & jim_data$name=="HOGAN, LAWRENCE JOSEPH (LARRY), JR."] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="ME"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="ME" & jim_data$name=="MILLS, JANET T."] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="MI"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="MI" & jim_data$name=="WHITMER, GRETCHEN"] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="MN"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="MN" & jim_data$name=="WALZ, TIMOTHY J. (TIM)"] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="NE"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="NE" & jim_data$name=="RICKETTS, PETE"] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="NH"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="NH" & jim_data$name=="SUNUNU, CHRISTOPHER (CHRIS)"] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="NM"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="NM" & jim_data$name=="GRISHAM, MICHELLE LUJAN"] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="NV"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="NV" & jim_data$name=="SISOLAK, STEVE"] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="NY"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="NY" & jim_data$name=="CUOMO, ANDREW M."] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="OH"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="OH" & jim_data$name=="DEWINE, MICHAEL (MIKE)"] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="OK"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="OK" & jim_data$name=="STITT, KEVIN"] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="OR" & is.na(jim_data$w_g)] <- 0

jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="PA"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="PA" & jim_data$name=="WOLF, THOMAS W. (TOM)"] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="RI"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="RI" & jim_data$name=="RAIMONDO, GINA M."] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="SC"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="SC" & jim_data$name=="MCMASTER, HENRY D."] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="SD"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="SD" & jim_data$name=="NOEM, KRISTI LYNN"] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="TN"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="TN" & jim_data$name=="LEE, BILL"] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="TX"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="TX" & jim_data$name=="ABBOTT, GREG"] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="VT"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="VT" & jim_data$name=="SCOTT, PHILLIP B. (PHIL)"] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="WI"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="WI" & jim_data$name=="EVERS, TONY"] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="WY"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="G" & jim_data$st=="WY" & jim_data$name=="GORDON, MARK"] <- 1


#senate wins
jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="AZ"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="AZ" & jim_data$name=="SINEMA, KYRSTEN"] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="CA"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="CA" & jim_data$name=="FEINSTEIN, DIANNE"] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="CT"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="CT" & jim_data$name=="MURPHY, CHRISTOPHER SCOTT (CHRIS)"] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="DE"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="DE" & jim_data$name=="CARPER, THOMAS RICHARD (TOM)"] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="FL"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="FL" & jim_data$name=="SCOTT, RICHARD (RICK)"] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="HI"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="HI" & jim_data$name=="HIRONO, MAZIE K."] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="IN"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="IN" & jim_data$name=="BRAUN, MIKE"] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="MA"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="MA" & jim_data$name=="WARREN, ELIZABETH A."] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="MD"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="MD" & jim_data$name=="CARDIN, BENJAMIN L. (BEN)"] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="ME"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="ME" & jim_data$name=="KING, ANGUS STANLEY, JR."] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="MI"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="MI" & jim_data$name=="STABENOW, DEBORAH ANN (DEBBIE)"] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="MN"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="MN" & jim_data$name=="KLOBUCHAR, AMY J."] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="MO"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="MO" & jim_data$name=="HAWLEY, JOSH"] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="MS"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="MS" & jim_data$name=="WICKER, ROGER F."] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="MT"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="MT" & jim_data$name=="TESTER, JON"] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="ND"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="ND" & jim_data$name=="CRAMER, KEVIN J."] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="NE"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="NE" & jim_data$name=="FISCHER, DEBRA S. (DEB)"] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="NJ"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="NJ" & jim_data$name=="MENENDEZ, ROBERT (BOB)"] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="NM"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="NM" & jim_data$name=="HEINRICH, MARTIN TREVOR"] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="NV"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="NV" & jim_data$name=="ROSEN, JACKLYN S. (JACKY)"] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="NY"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="NY" & jim_data$name=="GILLIBRAND, KIRSTEN ELIZABETH"] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="OH"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="OH" & jim_data$name=="BROWN, SHERROD C."] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="PA"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="PA" & jim_data$name=="CASEY, ROBERT P. (BOB), JR."] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="RI"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="RI" & jim_data$name=="WHITEHOUSE, SHELDON, II"] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="TN"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="TN" & jim_data$name=="BLACKBURN, MARSHA W."] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="TX"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="TX" & jim_data$name=="CRUZ, RAFAEL EDWARD (TED)"] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="UT"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="UT" & jim_data$name=="ROMNEY, MITT"] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="VA"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="VA" & jim_data$name=="KAINE, TIMOTHY MICHAEL (TIM)"] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="VT"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="VT" & jim_data$name=="SANDERS, BERNARD (BERNIE)"] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="WA"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="WA" & jim_data$name=="CANTWELL, MARIA"] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="WI"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="WI" & jim_data$name=="BALDWIN, TAMMY"] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="WV"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="WV" & jim_data$name=="MANCHIN, JOE, III"] <- 1

jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="WY"] <- 0
jim_data$w_g[jim_data$year==2018 & jim_data$office=="S" & jim_data$st=="WY" & jim_data$name=="BARRASSO, JOHN ANTHONY, III"] <- 1

#fixing inc for other years
jim_data$inc[jim_data$year==2014 & jim_data$office=="G" & jim_data$st=="AR"] <- 0
jim_data$inc[jim_data$year==2014 & jim_data$office=="G" & jim_data$st=="AZ"] <- 0
jim_data$inc[jim_data$year==2016 & jim_data$office=="H" & jim_data$st=="FL" & jim_data$name=="BYRON, DAVID"] <- 0
jim_data$inc[jim_data$year==2012 & jim_data$office=="G" & jim_data$st=="IN"] <- 0
jim_data$inc[jim_data$year==2016 & jim_data$office=="S" & jim_data$st=="IN" & jim_data$name=="JOHNSON, JAMES L., JR."] <- 0
jim_data$inc[jim_data$year==2014 & jim_data$office=="G" & jim_data$st=="MA"] <- 0
jim_data$inc[jim_data$year==2014 & jim_data$office=="G" & jim_data$st=="MD"] <- 0
jim_data$inc[jim_data$year==2016 & jim_data$office=="S" & jim_data$st=="MD"] <- 0
jim_data$inc[jim_data$year==2014 & jim_data$office=="S" & jim_data$st=="MI"] <- 0
jim_data$inc[jim_data$year==2016 & jim_data$office=="G" & jim_data$st=="MO"] <- 0
jim_data$inc[jim_data$year==2014 & jim_data$office=="G" & jim_data$st=="NE"] <- 0
jim_data$inc[jim_data$year==2014 & jim_data$office=="S" & jim_data$st=="NE"] <- 0
jim_data$inc[jim_data$year==2016 & jim_data$office=="S" & jim_data$st=="NV" & jim_data$name=="[NONE OF THESE]"] <- 0
jim_data$inc[jim_data$year==2014 & jim_data$office=="S" & jim_data$st=="SD"] <- 0
jim_data$inc[jim_data$year==2014 & jim_data$office=="S" & jim_data$st=="WV"] <- 0

# Only going to keep the observation for the candidate that combines all of the vote they got when running
# on different party lines, such as dems and working party. also, only going to keep general election results.
# I decided to include runoffs when they are the listed candidate in the CCES but to note it in the data column).

# COLLAPSE
# Keep the observation that combines the party votes and create the variables of interest
jim_data <- jim_data |>
  group_by(year, st, dist_up, office, type, name) |>
  filter(multiple_parties == max(multiple_parties)) |>
  group_by(year, st, dist_up, office, type) |>
  mutate(totalvotes = sum(vote_g, na.rm = TRUE))  |>
  select(-multiple_parties)
# group_by(year, st, dist_up, office, name)#  |>
# mutate(votepct = vote_g / totalvotes)
# Save -----
haven::write_dta(jim_data, "~/Dropbox/CCES_candidates/Output/CandidateLevel_Candidates.dta")


