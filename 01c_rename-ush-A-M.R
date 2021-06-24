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
         "PATTERSON, BUZZ", "BUBSER, CHRISTINE", "OBERNOLTE, JAY", "HOWZE, TED",
         "SHARMA, NISHA", "BUTTAR, SHAHID", "PITERMAN, NIKKA", "PETEL, RAN S.",
         "HAYDEN, ALISON", "COOKINGHAM, KEVIN", "TANDON, RITESH", "KUMAR, RISHI",
         "VALADAO, DAVID G.", "MANGONE, KIM", "CALDWELL, ANDY", "SMITH, CHRISTY",
         "GARCIA, MIKE", "BALDWIN KENNEDY, RONDA", "EARLY, ERIC", "GIBBONEY, AGNES",
         "BRADLEY, JAMES P.", "KIM, DAVID", "CARGILE, MIKE", "CRUZ, ERIN",
         "WEBBER, ERROL", "TOLAR, MICHAEL", "O'MARA, WILLIAM (LIAM)", "COLLINS, JOE E., III",
         "JOYA, ANALILIA", "RATHS, GREG", "WATERS, JAMES S.", "STEEL, MICHELLE",
         "MARYOTT, BRIAN", "DEBELLO, JIM", "JACOBS, SARA", "GOMEZ, GEORGETTE",
         "BOLLING, SHANE", "FUREY, KYLE", "KOK, JAN", "WINN, CHARLIE", "ATKINSON, THOM",
         "SWING, GARY", "BOEBERT, LAUREN", "KEIL, JOHN RYAN", "MILTON, CRITTER",
         "MCCORKLE, IKE", "IRELAND, LAURA", "FREELAND, JILLIAN", "DUFFETT, ED",
         "MURPHY, MARCUS ALLEN", "KELTIE, REBECCA", "HOUSE, STEVE", "KULIKOWSKI, JAIMIE LYNN",
         "BILES, KEN", "OLSZTA, DAVID", "FAY, MARY", "ANDERSON, JUSTIN", "MARTINEAU, CASSANDRA",
         "STREICKER, MARGARET", "PAGLINO, JUSTIN C.", "RIDDLE, JONATHAN", "MERLEN, BRIAN",
         "SULLIVAN, DAVID X.", "WALCZAK, BRUCE W.", "MURPHY, LEE", "PURCELL, CATHERINE S.",
         "ROGERS, DAVID L.", "EHR, PHIL", "ORAM, ALBERT", "CHRISTENSEN, ADAM", "CAMMACK, KAT",
         "DEEGAN, DONNA", "ADLER, GARY", "VALENTIN, LEO", "GARLINGTON, WILLIAM R.",
         "KENNEDY, JIM", "OLSON, WILLIAM P. (BILL)", "FRANCOIS, VENNIA", "WALKER, KIMBERLY",
         "LUNA, ANNA PAULINA", "FRANKLIN, SCOTT", "GOOD, MARGARET",
         "MURRAY, THEODORE (PINK TIE)", "KEITH, PAM", "MILLER, K W.",
         "BANYAI, CINDY LYN", "DONALDS, BYRON", "MUSSELWHITE, GREG",
         "LOOMER, LAURA", "MALKEMUS, CHARLESTON", "PRUDEN, JAMES (JIM)",
         "SPICER, LAVERN", "OLIVO, CHRISTINE ALEXANDRIA", "GIMENEZ, CARLOS",
         "GRIGGS, JOYCE MARIE", )


# Regex Check -------------------------------------------------------------

js_06_18 %>%
  filter(str_detect(name, "BISHOP")) %>%
  select(name, state, dist, office)

js_20 %>%
  filter(str_detect(name, "BISHOP")) %>%
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
         name = replace(name, name == "AMADOR, ANTONIO C. (TONY)", "AMADOR, ANTONIO C. (TONY)"), #SAME
         name = replace(name, name == "HARDER, JOSH", "HARDER, JOSH"), #SAME
         name = replace(name, name == "DESAULNIER, MARK", "DESAULNIER, MARK"), #SAME
         name = replace(name, name == "PELOSI, NANCY", "PELOSI, NANCY"), #SAME
         name = replace(name, name == "LEE, BARBARA", "LEE, BARBARA J."),
         name = replace(name, name == "SPEIER, JACKIE", "SPEIER, KAREN (JACKIE)"),
         name = replace(name, name == "SWALWELL, ERIC", "SWALWELL, ERIC MICHAEL"),
         name = replace(name, name == "COSTA, JIM", "COSTA, JIM"), #SAME
         name = replace(name, name == "KHANNA, RO", "KHANNA, ROHIT (RO)"),
         name = replace(name, name == "ESHOO, ANNA G.", "ESHOO, ANNA G."), #SAME
         name = replace(name, name == "LOFGREN, ZOE", "LOFGREN, ZOE"), #SAME
         name = replace(name, name == "AGUILERA, JUSTIN JAMES", "AGUILERA, JUSTIN JAMES"), #SAME
         name = replace(name, name == "PANETTA, JIMMY", "PANETTA, JIMMY VARNI"), #SAME
         name = replace(name, name == "GORMAN, JEFF", "GORMAN, JEFFREY A. (JEFF)"),
         name = replace(name, name == "COX, TJ", "COX, T.J."),
         name = replace(name, name == "VALADAO, DAVID G.", "VALADAO, DAVID G."), #SAME
         name = replace(name, name == "NUNES, DEVIN", "NUNES, DEVIN GERALD"),
         name = replace(name, name == "MCCARTHY, KEVIN", "MCCARTHY, KEVIN"),
         name = replace(name, name == "CARBAJAL, SALUD O.", "CARBAJAL, SALUD O."), #ASK
         name = replace(name, name == "BROWNLEY, JULIA", "BROWNLEY, JULIA"), #SAME
         name = replace(name, name == "BALDWIN-KENNEDY, RONDA", "BALDWIN KENNEDY, RONDA"),
         name = replace(name, name == "CHU, JUDY", "CHU, JUDY M."),
         name = replace(name, name == "NALBANDIAN, JOHNNY J.", "NALBANDIAN, JOHNNY J."), #SAME,
         name = replace(name, name == "SCHIFF, ADAM B.", "SCHIFF, ADAM B."), #SAME
         name = replace(name, name == "CÃ¡RDENAS, TONY", "CARDENAS, TONY"),
         name = replace(name, name == "DUEÃ±AS, ANGÃ©LICA MARIA", "DUENAS, ANGELICA MARIA"),
         name = replace(name, name == "SHERMAN, BRAD", "SHERMAN, BRAD"), #SAME
         name = replace(name, name == "REED, MARK S.", "REED, MARK S."), #SAME
         name = replace(name, name == "AGUILAR, PETE", "AGUILAR, PETE"), #SAME
         name = replace(name, name == "NAPOLITANO, GRACE F.", "NAPOLITANO, GRACE FLORES"),
         name = replace(name, name == "SCOTT, JOSHUA M.", "SCOTT, JOSHUA M."), #SAME
         name = replace(name, name == "LIEU, TED", "LIEU, TED W."),
         name = replace(name, name == "GOMEZ, JIMMY", "GOMEZ, JIMMY"), #SAME
         name = replace(name, name == "TORRES, NORMA J.", "TORRES, NORMA J."), #SAME
         name = replace(name, name == "RUIZ, RAUL", "RUIZ, RAUL"), #SAME
         name = replace(name, name == "BASS, KAREN", "BASS, KAREN R."),
         name = replace(name, name == "SANCHEZ, LINDA T.", "SANCHEZ, LINDA T."), #SAME
         name = replace(name, name == "CISNEROS, GILBERT RAY, JR.", "CISNEROS, GIL"),
         name = replace(name, name == "KIM, YOUNG", "KIM, YOUNG"), #SAME
         name = replace(name, name == "ROYBAL-ALLARD, LUCILLE", "ROYBAL-ALLARD, LUCILLE"), #SAME
         name = replace(name, name == "DELGADO, ANTONIO", "DELGADO, ANTONIO"), #SAME
         name = replace(name, name == "TAKANO, MARK", "TAKANO, MARK ALLAN"),
         name = replace(name, name == "SMITH, AJA", "SMITH, AJA"), #SAME
         name = replace(name, name == "CALVERT, KEN", "CALVERT, KENNETH STANTON (KEN)"),
         name = replace(name, name == "WATERS, MAXINE", "WATERS, MAXINE"), #SAME
         name = replace(name, name == "BARRAGÃ¡N, NANETTE DIAZ", "BARRAGAN, NANETTE DIAZ"),
         name = replace(name, name == "PORTER, KATIE", "PORTER, KATIE"), #SAME
         name = replace(name, name == "CORREA, J LUIS", "CORREA, JOSE LUIS (LOU)"),
         name = replace(name, name == "LOWENTHAL, ALAN S.", "LOWENTHAL, ALAN S."), #SAME
         name = replace(name, name == "BRISCOE, JOHN", "BRISCOE, JOHN"), #SAME
         name = replace(name, name == "ROUDA, HARLEY", "ROUDA, HARLEY"), #SAME
         name = replace(name, name == "LEVIN, MIKE", "LEVIN, MIKE"), #SAME
         name = replace(name, name == "CAMPA-NAJJAR, AMMAR", "CAMPA-NAJJAR, AMMAR"), #SAME
         name = replace(name, name == "ISSA, DARRELL", "ISSA, DARRELL EDWARD"),
         name = replace(name, name == "VARGAS, JUAN", "VARGAS, JUAN CARLOS"),
         name = replace(name, name == "HIDALGO, JUAN M., JR", "HIDALGO, JUAN M., JR."), #SAME
         name = replace(name, name == "PETERS, SCOTT H.", "PETERS, SCOTT H. "), #ASK
         name = replace(name, name == "DEGETTE, DIANA", "DEGETTE, DIANA LOUISE"),
         name = replace(name, name == "FIORINO, PAUL NOEL", "FIORINO, PAUL NOEL"), #SAME
         name = replace(name, name == "NEGUSE, JOE", "NEGUSE, JOE"), #SAME
         name = replace(name, name == "BUSH, DIANE MITSCH", "BUSH, DIANE E. MITSCH"),
         name = replace(name, name == "BUCK, KEN", "BUCK, KENNETH (KEN)"),
         name = replace(name, name == "GRIFFITH, BRUCE", "GRIFFITH, BRUCE"), #SAME
         name = replace(name, name == "LAMBORN, DOUG", "LAMBORN, DOUGLAS L. (DOUG)"),
         name = replace(name, name == "CROW, JASON", "CROW, JASON"), #SAME
         name = replace(name, name == "OLSEN, NORM", "OLSEN, NORMAN T. (NORM)"),
         name = replace(name, name == "PERLMUTTER, ED", "PERLMUTTER, EDWIN G. (ED)"),
         name = replace(name, name == "STOCKHAM, CHARLES (CASPER)", "STOCKHAM, CHARLES (CASPER)"), #SAME
         name = replace(name, name == "MCCORMICK, THOMAS E.", "MCCORMICK, THOMAS"),
         name = replace(name, name == "COURTNEY, JOE", "COURTNEY, JOSEPH D. (JOE)"),
         name = replace(name, name == "REALE, DANIEL", "REALE, DANIEL J. (DAN)"),
         name = replace(name, name == "DELAURO, ROSA L.", "DELAURO, ROSA L."), #SAME
         name = replace(name, name == "HIMES, JAMES A.", "HIMES, JAMES A. (JIM)"),
         name = replace(name, name == "HAYES, JAHANA", "HAYES, JAHANA"), #SAME
         name = replace(name, name == "ROCHESTER, LISA BLUNT", "ROCHESTER, LISA BLUNT"), #ASK
         name = replace(name, name == "GAETZ, MATT", "GAETZ, MATT (JERRY)"),
         name = replace(name, name == "DUNN, NEAL P.", "DUNN, NEAL"),
         name = replace(name, name == "RUTHERFORD, JOHN H.", "RUTHERFORD, JOHN H."), #ASK
         name = replace(name, name == "LAWSON, AL, JR.", "LAWSON, ALFRED J. (AL), JR."),
         name = replace(name, name == "CURTIS, CLINT", "CURTIS, CLINT"), #ASK
         name = replace(name, name == "WALTZ, MICHAEL", "WALTZ, MICHAEL"), #SAME
         name = replace(name, name == "MURPHY, STEPHANIE N.", "MURPHY, STEPHANIE"),
         name = replace(name, name == "POSEY, BILL", "POSEY, WILLIAM (BILL)"),
         name = replace(name, name == "SOTO, DARREN", "SOTO, DARREN MICHAEL"),
         name = replace(name, name == "DEMINGS, VAL BUTLER", "DEMINGS, VALDEZ B. (VAL)"),
         name = replace(name, name == "COTTRELL, DANA MARIE", "COTTRELL, DANA"),
         name = replace(name, name == "WEBSTER, DANIEL", "WEBSTER, DANIEL A. (DAN)"),
         name = replace(name, name == "BILIRAKIS, GUS M.", "BILIRAKIS, GUS MICHAEL"),
         name = replace(name, name == "CRIST, CHARLIE", "CRIST, CHARLES J. (CHARLIE)"),
         name = replace(name, name == "CASTOR, KATHY", "CASTOR, KATHERINE ANNE (KATHY)"),
         name = replace(name, name == "QUINN, CHRISTINE Y.", "QUINN, CHRISTINE Y."), #SAME
         name = replace(name, name == "COHN, ALAN", "COHN, ALAN M."),
         name = replace(name, name == "BUCHANAN, VERN", "BUCHANAN, VERNON (VERN)"),
         name = replace(name, name == "ELLISON, ALLEN", "ELLISON, ALLEN"), #SAME
         name = replace(name, name == "STEUBE, W GREGORY", "STEUBE, GREG"),
         name = replace(name, name == "MAST, BRIAN J.", "MAST, BRIAN J."), #SAME
         name = replace(name, name == "HASTINGS, ALCEE L.", "HASTINGS, ALCEE LAMAR"),
         name = replace(name, name == "FRANKEL, LOIS", "FRANKEL, LOIS JANE"),
         name = replace(name, name == "DEUTCH, THEODORE E.", "DEUTCH, THEODORE ELIOT (TED)"),
         name = replace(name, name == "SCHULTZ, DEBBIE WASSERMAN", "SCHULTZ, DEBBIE WASSERMAN"), #SAME
         name = replace(name, name == "SPALDING, CARLA", "SPALDING, CARLA ARLENE"),
         name = replace(name, name == "WILSON, FREDERICA S.", "WILSON, FREDERICA S. (FREDDI)"),
         name = replace(name, name == "DIAZ-BALART, MARIO", "DIAZ-BALART, MARIO"), #ASK
         name = replace(name, name == "MUCARSEL-POWELL, DEBBIE", "MUCARSEL-POWELL, DEBBIE"), #SAME
         name = replace(name, name == "SHALALA, DONNA E.", "SHALALA, DONNA"),
         name = replace(name, name == "SALAZAR, MARIA ELVIRA", "SALAZAR, MARIA ELVIRA"),
         name = replace(name, name == "CARTER, EARL L. (BUDDY)", "CARTER, EARL L. (BUDDY)"), #SAME
         name = replace(name, name == "BISHOP, SANFORD D., JR.", "BISHOP, SANFORD DIXON, JR."),
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
