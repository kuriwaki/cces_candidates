# Set-up ------------------------------------------------------------------


library(tidyverse)
library(haven)

setwd("/Users/jeremiahcha/Dropbox/from-snyder")


# Data Loading ------------------------------------------------------------

js_06 <- read_dta("2020-06-13 election_results_2006_2016.dta") # Candidate data 2006-2016

js_18 <- read_dta("2020-08-16 election_results_2018_names_updated.dta") # Candidate 2018

js_06_18 <- bind_rows(js_06, js_18) %>%# Binding two datasets
  arrange(state, dist, name)

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
         "GARCIA, MIKE", "BALDWIN-KENNEDY, RONDA", "EARLY, ERIC", "GIBBONEY, AGNES",
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
         "GRIGGS, JOYCE MARIE", "COLE, DON", "ALMONORD, VAL",
         "EZAMMUDEEN, JOHSIE CRUZ", "WILLIAMS, NIKEMA", "STANTON-KING, ANGELA",
         "MCCORMICK, RICH", "HOLLIDAY, LINDSAY", "PANDY, DEVIN", "CLYDE, ANDREW",
         "BARRETT, DANA", "JOHNSON, LIZ", "HITES, BECKY E.", "AUSDAL, KEVIN VAN",
         "GREENE, MARJORIE TAYLOR", "AHELE, KAIALIAI (KAI)", "AKANA, JOE",
         "HOOMANAWANUI, JONATHAN", "BURRUS, RON", "SOTO, RUDY", "EVANS, JOE",
         "LAW, IDAHO SIERRA", "WHITE, PHILANISE", "RABORN, THERESA J.",
         "NEWMAN, MARIE", "FRICILONE, MIKE", "SOLORIO, JESUS",
         "WILDA, THOMAS J.", "IVES, JEANNE", "REDPATH, BILL",
         "JENNINGS, TRACY", "NELSON, PRESTON GABRIEL", "SANGARI, SARGIS",
         "MUKHERJEE, VALERIE RAMIREZ", "LAIB, RICK", "LENZI, RAYMOND C.",
         "WEAVER, ERIKA C.", "MILLER, MARY", "BRZOZOWSKI, DANI",
         "KING, ESTHER JOY", "PETRILLI, GEORGE", "MRVAN, FRANK J.",
         "STRAUSS, MICHAEL", "HACKETT, PATRICIA (PAT)", "COLDIRON, CHIP",
         "MACKEY, JOE", "HALE, CHRISTINA", "SPARTZ, VICTORIA",
         "TUCKER, KENNETH", "SMITH, SUSAN MARIE", "MARSILI, E THOMASINA",
         "RODENBERGER, JAMES D.", "RUFF, ANDY", "MILLIS, TONYA L.",
         "FINKENAUER, ABBY", "HINSON, ASHLEY", "HART, RITA R.",
         "FEENSTRA, RANDY", "BARNETT, KALI", "MANN, TRACEY",
         "DE LA ISLA, MICHELLE", "ADKINS, AMANDA L.", "LOMBARD, LAURA",
         "RHODES, JAMES", "PERRY, ROBERT LEE", "CARTER, LEWIS", "OWENSBY, ALEXANDRA",
         "BEST, MATTHEW RYAN", "HICKS, JOSH", "HARRIS, GLENN ADRAIN",
         "SCHILLING, DAVID M.", "VINCENT, SHELDON C., SR.", "JAMES, COLBY",
         "HARRIS, BRAYLON", "LELEUX, BRANDON", "HOUSTON, KENNY", "GIBSON, BEN",
         "CHRISTOPHE, SANDRA (CANDY)", "LEMELLE, MARTIN, JR.", "SNOWDEN, PHILLIP",
         "LAGARDE, JESSE P.", "LETLOW, LUKE J.", "HARRIS, LANCE", "ROBINSON, (SCOTTY)",
         "GUILLORY, ALLEN, SR.", "HASTY, (MATT)", "WILLIAMS, DARTANYON (DAW)",
         "SLOAN, SHANNON", "TORREGANO, RICHARD (RPT)", "ALLEN, JAY T.",
         "CRAFTS, DALE JOHN", "MASON, MIA", "SALLING, JOHNNY RAY", "PALOMBI, CHRIS",
         "PARROTT, NEIL C.", "HERRICK, JASON", "MFUME, KWEISI", "KLACIK, KIMBERLY",
         "COLL, GREGORY THOMAS", "AUCHINCLOSS, JAKE", "HALL, JULIE A.",
         "COLARUSSO, CAROLINE", "MORAN, JOHN PAUL", "OWENS, ROY A., SR.",
         "LOTT, JONATHAN D.", "MANLEY, MICHAEL", "BOREN, BEN", "BERGHOEF, BRYAN",
         "RIEKSE, MAX", "CREVIERE, JEAN-MICHEL", "MEIJER, PETER", "CANNY, DAVID",
         "SLEPR, AMY", "KELLY, TIM", "HARRIS, JAMES", "HOADLEY, JON",
         "DEPOY, JEFF", "JUNGE, PAUL", "HARTMAN, JOE", "LANGWORTHY, CHARLES J.",
         "SALIBA, MIKE", "MCCLAIN, LISA", "ESSHAKI, ERIC S.", "DUDENHOEFER, DAVID",
         "BOMER, ARTICIA", "PATRICK, ROBERT VANCE", "ROOD, BILL", "KISTNER, TYLER",
         "WEEKS, ADAM CHARLES", "QUALLS, KENDALL", "RECHTZIGEL, GENE",
         "JOHNSON, LACY", "MOORE, MICHAEL", "ZAHRADKA, TAWNJA", "FISCHBACH, MICHELLE",
         "JOHNSON, SLATER", "ANDERSON, RAE HART", "NYSTROM, QUINN", "ELIASON, ANTONIA",
         "FLOWERS, BRIAN", "BENFORD, DOROTHY (DOT)", "BUSH, CORI", "ROGERS, ANTHONY",
         "FURMAN, ALEX", "SCHUPP, JILL", "SCHULTE, MARTIN", "REZABEK, MEGAN",
         "STEINMAN, LEONARD J., II", "SIMMONS, LINDSEY", "KOONSE, STEVEN K.",
         "DERKS, RYAN", "DOMINICK, ROBIN", "ROSS, GENA L.", "MONTSENY, TERESA",
         "SCHMITZ, TOM", "BOLZ, KATE", "GRACE, DENNIS B.", " SCHAEFFER, TYLER",
         "ELSWORTH, MARK, JR.", "HOBBS, DUSTIN C.", "ACKERMAN, PATRICIA",
         "RODIMER, DAN (BIG DAN)", "RIDGES, ED S., II", "MARCHANT, JIM",
         "ESTEBAN, JONATHAN ROYCE", "RUBINSON, BARRY L.", "MOWERS, MATT",
         "DUMONT, ZACHARY S.", "NEGRON, STEVEN", "OLDING, ANDREW",
         "GUSTAFSON, CLAIRE H.", "KENNEDY, AMY", "HARVEY, JENNA",
         "EHRNSTROM, JESSE", "RICHTER, DAVID", "WEBER, MARTIN",
         "SCHMID, STEPHANIE", "PACHUTA, ANDREW", "PALLOTTA, FRANK T.",
         "VELLUCCI, LOUIS A.", "ONUOHA, CHRISTIAN", "MUSHNICK, JASON TODD",
         "PREMPEH, BILLY", "AURIEMMA, CHRIS", "ZINONE, JENNIFER",
         "KHALFANI, AKIL", "FITCHETTE, KHALIAH", "MIRRIONE, JOHN",
         "BECCHI, ROSEMARY", "RAZZOLI, MARK", "SMITH, SANDY", "SWAIN, ALAN D.",
         "FARROW, DARYL", "MURPHY, GREGORY F.", "THOMAS, ROBERT", "HAYWOOD, LEE",
         "WARD, CHRISTOPHER M.", "TIMMONS-GOODSON, PATRICIA", "WALLACE, CYNTHIA L.",
         "BISHOP, DAN", "PARKER, DAVID", "DAVIS, MOE", "CAWTHORN, MADISON",
         "DEBRUHL, TRACEY", "ZWINAK, TAMARA", "HUFFMAN, SCOTT",
         "HOLMES, MICHELLE GARCIA", "FERNANDEZ, TERESA LEGER", "JOHNSON, ALEXIS M.",
         "GOROFF, NANCY S.", "GORDON, JACKIE", "GARBARINO, ANDREW R.",
         "BURGER, HARRY R.", "SANTOS, GEORGE A.", "RABIN, HOWARD",
         "TUMAN, DOUGLAS L.", "NAHAM, JOSEPH R.", "ZMICH, THOMAS J.",
         "KELLY, BRIAN W.", "MIDONNET, GILBERT", "WALLACE, GARFIELD H.",
         "JEAN-PIERRE, CONSTANTINE", "POPKIN, GARY", "BERNSTEIN, CATHY A.",
         "MADRID, MICHAEL", "MALLIOTAKIS, NICOLE", "SANTIAGO-CANO, CARLOS",
         "KOLLN, STEVEN", "MORRIS-PERRY, CHRISTOPHER", "CUMMINGS, JOHN C.",
         "CARUSO-CABRERA, MICHELLE", "TORRES, RITCHIE", "DELICES, PATRICK",
         "BOWMAN, JAMAAL", "MCMANUS, PATRICK", "JONES, MONDAIRE",
         "MCARDLE-SCHULMAN, MAUREEN", "GOTTESFELD, YEHUDIS",
         "EISEN, JOSHUA", "PARIETTI, MICHAEL I.", "VAN DE WATER, KYLE",
         "ALEXANDER, VICTORIA N.", "JOY, ELIZABETH L.", "PRICE, KEITH D., JR.",
         "KOLSTEE, ANDREW M.", "WILLIAMS, STEVEN", "MITRIS, GEORGE",
         "DONOVAN, RICKY T., SR.", "RALEIGH, MICHAEL P.", "MCMURRAY, NATHAN D.",
         "JACOBS, CHRIS", "WHITMER, DUANE J.", "RAKNERUD, ZACH",
         "ARMSTRONG, KELLY", "PETERSON, STEVEN JAMES", "LAW, IDAHO SIERRA")


# Regex Check -------------------------------------------------------------

js_06_18 %>%
  filter(str_detect(name, "CARBAJAL,")) %>%
  select(name, state, dist, office, year)

js_20 %>%
  filter(str_detect(name, "CARBAJAL")) %>%
  select(name, state, dist, office, year)


# 2020 Name Changes -------------------------------------------------------

js_20 %>%
  mutate(# Alabama
         name = replace(name, name == "ROGERS, MIKE", "ROGERS, MICHAEL DENNIS (MIKE)"),
         name = replace(name, name == "ADERHOLT, ROBERT B.", "ADERHOLT, ROBERT BROWN "),
         name = replace(name, name == "BROOKS, MO", "BROOKS, MORRIS J. (MO), JR."),
         name = replace(name, name == "PALMER, GARY J.", "PALMER, GARY"),
         name = replace(name, name == "SEWELL, TERRI A.", "SEWELL, TERRYCINA ANDREA (TERRI)"),
         # Alaska
         name = replace(name, name == "GALVIN, ALYSE S.", "GALVIN, ALYSE S."), #SAME
         name = replace(name, name == "YOUNG, DON", "YOUNG, DONALD E. (DON)"),
         # Arizona
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
         # Arkansas
         name = replace(name, name == "CRAWFORD, ERIC A. (RICK)", "CRAWFORD, ERIC ALAN (RICK)"),
         name = replace(name, name == "ELLIOTT, JOYCE", "ELLIOTT, JOYCE"), #SAME,
         name = replace(name, name == "HILL, J FRENCH", "HILL, FRENCH"), # 2020 Name has first initial (J)
         name = replace(name, name == "WOMACK, STEVE", "WOMACK, STEPHEN ALLEN (STEVE)"),
         name = replace(name, name == "KALAGIAS, MICHAEL J.", "KALAGIAS, MICHAEL J."),
         name = replace(name, name == "WESTERMAN, BRUCE", "WESTERMAN, BRUCE"), #SAME
         name = replace(name, name == "GILBERT, FRANK", "GILBERT, FRANK"), #SAME
         name = replace(name, name == "DENNEY, AUDREY", "DENNEY, AUDREY"), #SAME
         # California
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
         name = replace(name, name == "CARBAJAL, SALUD O.", "CARBAJAL, SALUD"), #ASK
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
         name = replace(name, name == "PETERS, SCOTT H.", "PETERS, SCOTT"),
         # Colorado
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
         # Connecticut
         name = replace(name, name == "MCCORMICK, THOMAS E.", "MCCORMICK, THOMAS"),
         name = replace(name, name == "COURTNEY, JOE", "COURTNEY, JOSEPH D. (JOE)"),
         name = replace(name, name == "REALE, DANIEL", "REALE, DANIEL J. (DAN)"),
         name = replace(name, name == "DELAURO, ROSA L.", "DELAURO, ROSA L."), #SAME
         name = replace(name, name == "HIMES, JAMES A.", "HIMES, JAMES A. (JIM)"),
         name = replace(name, name == "HAYES, JAHANA", "HAYES, JAHANA"), #SAME
         # Delaware
         name = replace(name, name == "ROCHESTER, LISA BLUNT", "BLUNT ROCHESTER, LISA LATRELLE"),
         # Florida
         name = replace(name, name == "GAETZ, MATT", "GAETZ, MATT (JERRY)"),
         name = replace(name, name == "DUNN, NEAL P.", "DUNN, NEAL"),
         name = replace(name, name == "RUTHERFORD, JOHN H.", "RUTHERFORD, JOHN"), #ASK
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
         name = replace(name, name == "DIAZ-BALART, MARIO", "DIAZ-BALART, MARIO"),
         name = replace(name, name == "MUCARSEL-POWELL, DEBBIE", "MUCARSEL-POWELL, DEBBIE"), #SAME
         name = replace(name, name == "SHALALA, DONNA E.", "SHALALA, DONNA"),
         name = replace(name, name == "SALAZAR, MARIA ELVIRA", "SALAZAR, MARIA ELVIRA"),
         # Georgia
         name = replace(name, name == "CARTER, EARL L. (BUDDY)", "CARTER, EARL L. (BUDDY)"), #SAME
         name = replace(name, name == "BISHOP, SANFORD D., JR.", "BISHOP, SANFORD DIXON, JR."),
         name = replace(name, name == "FERGUSON, A. DREW, IV", "FERGUSON, DREW"),
         name = replace(name, name == "JOHNSON, HENRY C. (HANK), JR.", "JOHNSON, HENRY C. (HANK), JR."), #SAME
         name = replace(name, name == "MCBATH, LUCY", "MCBATH, LUCY"), #SAME
         name = replace(name, name == "HANDEL, KAREN", "HANDEL, KAREN C."),
         name = replace(name, name == "BOURDEAUX, CAROLYN", "BOURDEAUX, CAROLYN"), #SAME
         name = replace(name, name == "SCOTT, AUSTIN", "SCOTT, JAMES AUSTIN"),
         name = replace(name, name == "JOHNSON-GREEN, TABITHA", "JOHNSON-GREEN, TABITHA A."),
         name = replace(name, name == "HICE, JODY B.", "HICE, JODY B."), #SAME
         name = replace(name, name == "LOUDERMILK, BARRY", "LOUDERMILK, BARRY D."),
         name = replace(name, name == "ALLEN, RICK W.", "ALLEN, RICHARD W. (RICK)"),
         name = replace(name, name == "SCOTT, DAVID", "SCOTT, DAVID ALBERT"),
         # Hawaii
         name = replace(name, name == "CASE, ED", "CASE, EDWARD ESPENETT (ED)"),
         name = replace(name, name == "CURTIS, RON", "CURTIS, RON"), #SAME
         name = replace(name, name == "TIPPENS, MICHELLE ROSE", "TIPPENS, MICHELLE ROSE"), #SAME
         name = replace(name, name == "GIUFFRE, JOHN (RAGHU)", "IUFFRE, JOHN M. (RAGHU)"),
         # Idaho
         name = replace(name, name == "FULCHER, RUSS", "FULCHER, RUSSELL M. (RUSS)"),
         name = replace(name, name == "SWISHER, C AARON", "SWISHER, AARON"),
         name = replace(name, name == "SIMPSON, MICHAEL K.", "SIMPSON, MICHAEL K. (MIKE)"),
         # Illinois
         name = replace(name, name == "RUSH, BOBBY L.", "RUSH, BOBBY LEE"),
         name = replace(name, name == "KELLY, ROBIN L.", "KELLY, ROBIN L."), #SAME
         name = replace(name, name == "GARCIA, JESUS G. (CHUY)", "GARCIA, CHUY"),
         name = replace(name, name == "QUIGLEY, MIKE", "QUIGLEY, MICHAEL (MIKE)"),
         name = replace(name, name == "HANSON, TOMMY", "HANSON, TOM"),
         name = replace(name, name == "CASTEN, SEAN", "CASTEN, SEAN"), #SAME
         name = replace(name, name == "DAVIS, DANNY K.", "DAVIS, DANNY K."), #SAME
         name = replace(name, name == "CAMERON, CRAIG", "CAMERON, CRAIG"), #SAME
         name = replace(name, name == "KRISHNAMOORTHI, RAJA", "KRISHNAMOORTHI, S. RAJA"),
         name = replace(name, name == "SCHAKOWSKY, JANICE D.", "SCHAKOWSKY, JANICE D. (JAN)"),
         name = replace(name, name == "SCHNEIDER, BRADLEY SCOTT", "SCHNEIDER, BRADLEY SCOTT (BRAD)"),
         name = replace(name, name == "FOSTER, BILL", "FOSTER, G. WILLIAM (BILL)"),
         name = replace(name, name == "BOST, MIKE", "BOST, MICHAEL J. (MIKE)"),
         name = replace(name, name == "LONDRIGAN, BETSY DIRKSEN", "LONDRIGAN, BETSY DIRKSEN"), #SAME
         name = replace(name, name == "DAVIS, RODNEY", "DAVIS, RODNEY L."),
         name = replace(name, name == "UNDERWOOD, LAUREN", "UNDERWOOD, LAUREN"), #SAME
         name = replace(name, name == "OBERWEIS, JIM", "OBERWEIS, JAMES D. (JIM)"),
         name = replace(name, name == "KINZINGER, ADAM", "KINZINGER, ADAM"), #SAME
         name = replace(name, name == "BUSTOS, CHERI", "BUSTOS, CHERI"), #SAME
         name = replace(name, name == "LAHOOD, DARIN", "LAHOOD, DARIN M."),
         # Indiana
         name = replace(name, name == "LEYVA, MARK", "LEYVA, MARK J."),
         name = replace(name, name == "WALORSKI, JACKIE", "WALORSKI, JACKIE SWIHART"),
         name = replace(name, name == "BANKS, JIM", "BANKS, JAMES E. (JIM)"),
         name = replace(name, name == "BAIRD, JAMES R.", "BAIRD, JIM"),
         name = replace(name, name == "LAKE, JEANNINE LEE", "LAKE, JEANNINE LEE"), #SAME
         name = replace(name, name == "PENCE, GREG", "PENCE, GREG"), #SAME
         name = replace(name, name == "FERKINHOFF, TOM", "FERKINHOFF, TOM"),
         name = replace(name, name == "CARSON, ANDRÃ©", "CARSON, ANDRE D."),
         name = replace(name, name == "BUCSHON, LARRY", "BUCSHON, LARRY D."),
         name = replace(name, name == "HOLLINGSWORTH, TREY", "HOLLINGSWORTH, JOSEPH A. (TREY), III"),
         # Iowa
         name = replace(name, name == "MILLER-MEEKS, MARIANNETTE", "MILLER-MEEKS, MARIANNETTE JANE"),
         name = replace(name, name == "AXNE, CYNTHIA", "AXNE, CINDY"),
         name = replace(name, name == "YOUNG, DAVID", "YOUNG, DAVID"), #SAME
         name = replace(name, name == "HOLDER, BRYAN JACK", "HOLDER, BRYAN JACK"), #SAME
         name = replace(name, name == "SCHOLTEN, J D.", "SCHOLTEN, J.D."), #SAME
         # Kansas
         name = replace(name, name == "LATURNER, JAKE", "LATURNER, JACOB"), #SAME
         name = replace(name, name == "GARRARD, ROBERT", "GARRARD, ROBERT DAVID"),
         name = replace(name, name == "DAVIDS, SHARICE", "DAVIDS, SHARICE"), #SAME
         name = replace(name, name == "OHE, STEVEN A.", "HOHE, STEVEN A. (STEVE)"),
         name = replace(name, name == "ESTES, RON", "ESTES, RON"), #SAME
         # Kentucky
         name = replace(name, name == "COMER, JAMES", "COMER, JAMES R. (JAMIE), JR."),
         name = replace(name, name == "LINDERMAN, HANK", "LINDERMAN, HANK"), #SAME
         name = replace(name, name == "GUTHRIE, BRETT", "GUTHRIE, STEVEN (BRETT)"),
         name = replace(name, name == "YARMUTH, JOHN A.", "YARMUTH, JOHN A"), #SAME
         name = replace(name, name == "PALAZZO, STEVEN M.", "PALAZZO, STEVEN MCCARTY"),
         name = replace(name, name == "MASSIE, THOMAS", "MASSIE, THOMAS H."),
         name = replace(name, name == "ROGERS, HAROLD", "ROGERS, HAROLD DALLAS (HAL)"),
         name = replace(name, name == "BARR, ANDY", "BARR, GARLAND (ANDY)"),
         name = replace(name, name == "HARRIS, FRANK", "HARRIS, FRANK"), #SAME
         # Louisiana
         name = replace(name, name == "DUGAS, LEE ANN", "DUGAS, LEE ANN"), #SAME
         name = replace(name, name == "SCALISE, STEVE", "SCALISE, STEPHEN J. (STEVE)"),
         name = replace(name, name == "KEARNEY, HOWARD", "KEARNEY, HOWARD L."),
         name = replace(name, name == "RICHMOND, CEDRIC L.", "RICHMOND, CEDRIC L."),
         name = replace(name, name == "BATISTE, BELDEN (NOONIE MAN)", "BATISTE, BELDEN (NOONIE MAN)"), #SAME
         name = replace(name, name == "ANDERSON, (ROB)", "ANDERSON, ROB"),
         name = replace(name, name == "HIGGINS, CLAY", "HIGGINS, CLAY"), #SAME
         name = replace(name, name == "TRUNDLE, RYAN", "TRUNDLE, RYAN"), #SAME
         name = replace(name, name == "JOHNSON, MIKE", "JOHNSON, MIKE"), #SAME
         name = replace(name, name == "ROBINSON, (SCOTTY)", "ROBINSON, RANDALL SCOTT (SCOTTY)"), # https://ballotpedia.org/Randall_Scott_Robinson_(Louisiana)
         name = replace(name, name == "HASTY, (MATT)", "HASTY, MATTHEW (MATT)"), # https://docquery.fec.gov/pdf/640/202007179250399640/202007179250399640.pdf
         name = replace(name, name == "GRAVES, GARRET", "GRAVES, GARRET"), #SAME
         # Maine
         name = replace(name, name == "PINGREE, CHELLIE", "PINGREE, ROCHELLE M. (CHELLIE)"),
         name = replace(name, name == "GOLDEN, JARED F.", "GOLDEN, JARED F."), #SAME
         # Maryland
         name = replace(name, name == "HARRIS, ANDY", "HARRIS, ANDREW P. (ANDY)"),
         name = replace(name, name == "RUPPERSBERGER, C A. DUTCH", "RUPPERSBERGER, C.A. (DUTCH)"),
         name = replace(name, name == "SARBANES, JOHN P.", "SARBANES, JOHN P."), #SAME
         name = replace(name, name == "ANTHONY, CHARLES", "ANTHONY, CHARLES"), #SAME
         name = replace(name, name == "BROWN, ANTHONY G.", "BROWN, ANTHONY G."), #SAME
         name = replace(name, name == "MCDERMOTT, GEORGE E.", "MCDERMOTT, GEORGE EDWARD"),
         name = replace(name, name == "HOYER, STENY H.", "HOYER, STENY HAMILTON"),
         name = replace(name, name == "TRONE, DAVID J.", "TRONE, DAVID"),
         name = replace(name, name == "GLUCK, GEORGE", "GLUCK, GEORGE"), #SAME
         name = replace(name, name == "RASKIN, JAMIE", "RASKIN, JAMIN B."),
         # Massachusetts
         name = replace(name, name == "NEAL, RICHARD E.", "NEAL, RICHARD E."), #SAME
         name = replace(name, name == "MCGOVERN, JAMES P.", "MCGOVERN, JAMES P. (JIM)"),
         name = replace(name, name == "LOVVORN, TRACY LYN", "LOVVORN, TRACY LYN"), #SAME
         name = replace(name, name == "TRAHAN, LORI", "TRAHAN, LORI LOUREIRO"),
         name = replace(name, name == "CLARK, KATHERINE M.", "CLARK, KATHERINE M."), #SAME
         name = replace(name, name == "MOULTON, SETH", "MOULTON, SETH W."),
         name = replace(name, name == "PRESSLEY, AYANNA", "PRESSLEY, AYANNA S."),
         name = replace(name, name == "LYNCH, STEPHEN F.", "LYNCH, STEPHEN F."), #SAME
         name = replace(name, name == "KEATING, WILLIAM R.", "KEATING, WILLIAM RICHARD (BILL)"),
         name = replace(name, name == "BRADY, HELEN", "BRADY, HELEN"), #SAME
         # Michigan
         name = replace(name, name == "FERGUSON, DANA", "FERGUSON, DANA"), #SAME
         name = replace(name, name == "BERGMAN, JACK", "BERGMAN, JACK"), #SAME
         name = replace(name, name == "HUIZENGA, BILL", "HUIZENGA, WILLIAM P. (BILL)"),
         name = replace(name, name == "SICKLE, GERALD T. VAN", "VAN SICKLE, GERALD TRUMAN"),
         name = replace(name, name == "SCHOLTEN, J D.", "SCHOLTEN, J.D."),
         name = replace(name, name == "HILLIARD, JERRY", "HILLIARD, JERRY"), #SAME
         name = replace(name, name == "MOOLENAAR, JOHN R.", "MOOLENAAR, JOHN"),
         name = replace(name, name == "KILDEE, DANIEL T.", "KILDEE, DANIEL TIMOTHY (DAN)"),
         name = replace(name, name == "GOODWIN, KATHY", "GOODWIN, KATHY"), #SAME
         name = replace(name, name == "UPTON, FRED", "UPTON, FREDERICK STEPHEN (FRED)"),
         name = replace(name, name == "LAWRENCE, JOHN", "LAWRENCE, JOHN"), #SAME
         name = replace(name, name == "DRISKELL, GRETCHEN D.", "DRISKELL, GRETCHEN D."), #SAME
         name = replace(name, name == "WALBERG, TIM", "WALBERG, TIMOTHY L. (TIM)"),
         name = replace(name, name == "SLOTKIN, ELISSA", "SLOTKIN, ELISSA"), #SAME
         name = replace(name, name == "LEVIN, ANDY", "LEVIN, ANDY"), #SAME
         name = replace(name, name == "KIRBY, ANDREA L.", "KIRBY, ANDREA"),
         name = replace(name, name == "BIZON, KIMBERLY", "BIZON, KIMBERLY"), #SAME
         name = replace(name, name == "STEVENS, HALEY M.", "STEVENS, HALEY"),
         name = replace(name, name == "SCHWARTZ, LEONARD", "SCHWARTZ, LEONARD C."),
         name = replace(name, name == "DINGELL, DEBBIE", "DINGELL, DEBBIE INSLEY"),
         name = replace(name, name == "JONES, JEFF", "JONES, JEFFREY W. (JEFF)"),
         name = replace(name, name == "WALKOWICZ, GARY", "WALKOWICZ, GARY"), #SAME
         name = replace(name, name == "TLAIB, RASHIDA", "TLAIB, RASHIDA"), #SAME
         name = replace(name, name == "JOHNSON, SAM", "JOHNSON, SAM"), #SAME
         name = replace(name, name == "WILCOXON, D ETTA", "WILCOXON, D. ETTA"), #SAME
         name = replace(name, name == "LAWRENCE, BRENDA L.", "LAWRENCE, BRENDA LUIENAR"),
         name = replace(name, name == "GIOIA, LISA LANE", "GIOIA, LISA LANE"), #SAME
         name = replace(name, name == "KOLODY, PHILIP", "KOLODY, PHILIP"), #SAME
         name = replace(name, name == "SHABAZZ, CLYDE K.", "SHABAZZ, CLYDE K."), #SAME
         # Minnesota
         name = replace(name, name == "FEEHAN, DAN", "FEEHAN, DAN"), #SAME
         name = replace(name, name == "HAGEDORN, JIM ", "HAGEDORN, JAMES (JIM)"),
         name = replace(name, name == "CRAIG, ANGIE", "CRAIG, ANGELA DAWN (ANGIE)"),
         name = replace(name, name == "PHILLIPS, DEAN", "PHILLIPS, DEAN"), #SAME
         name = replace(name, name == "MCCOLLUM, BETTY", "MCCOLLUM, BETTY"), #SAME
         name = replace(name, name == "SINDT, SUSAN", "SINDT, SUSAN PENDERGAST"),
         name = replace(name, name == "OMAR, ILHAN", "OMAR, ILHAN"), #SAME
         name = replace(name, name == "EMMER, TOM", "EMMER, THOMAS (TOM)"),
         name = replace(name, name == "PETERSON, COLLIN C.", "PETERSON, COLLIN CLARK"),
         name = replace(name, name == "STAUBER, PETE", "STAUBER, PETE"), #SAME
         name = replace(name, name == "SCHWARTZBACKER, JUDITH", "SCHWARTZBACKER, JUDITH"), #SAME
         # Mississippi
         name = replace(name, name == "KELLY, TRENT", "KELLY, TRENT"), #SAME
         name = replace(name, name == "THOMPSON, BENNIE G.", "THOMPSON, BENNIE G."), #SAME
         name = replace(name, name == "GUEST, MICHAEL", "GUEST, MICHAEL"), #SAME
         name = replace(name, name == "PALAZZO, STEVEN M.", "PALAZZO, STEVEN MCCARTY"),
         # Missouri
         name = replace(name, name == "WAGNER, ANN", "WAGNER, ANN L."),
         name = replace(name, name == "LUETKEMEYER, BLAINE", "LUETKEMEYER, W. BLAINE"),
         name = replace(name, name == "HARTZLER, VICKY", "HARTZLER, VICKY J."),
         name = replace(name, name == "CLEAVER, EMANUEL", "LEAVER, EMANUEL, II"),
         name = replace(name, name == "GRAVES, SAM", "GRAVES, SAMUEL B. (SAM), JR."),
         name = replace(name, name == "HIGGINS, JIM", "HIGGINS, JAMES EDWARD (JIM)"),
         name = replace(name, name == "LONG, BILLY", "LONG, BILLY"), #SAME
         name = replace(name, name == "CRAIG, KEVIN", "CRAIG, KEVIN"), #SAME
         name = replace(name, name == "ELLIS, KATHY", "ELLIS, KATHY"), #SAME
         name = replace(name, name == "SMITH, JASON", "SMITH, JASON T."),
         # Montana
         name = replace(name, name == "WILLIAMS, KATHLEEN", "WILLIAMS, KATHLEEN"), #SAME
         name = replace(name, name == "ROSENDALE, MATT", "ROSENDALE, MATTHEW M. (MATT)"),
         # North Carolina
         name = replace(name, name == "BUTTERFIELD, G K.", "BUTTERFIELD, GEORGE K. (G.K.), JR."),
         name = replace(name, name == "ROSS, DEBORAH K.", "ROSS, DEBORAH K."), #SAME
         name = replace(name, name == "MATEMU, JEFF", "MATEMU, JEFF"), #SAME
         name = replace(name, name == "PRICE, DAVID E.", "PRICE, DAVID EUGENE"),
         name = replace(name, name == "BROWN, DAVID WILSON", "BROWN, DAVID WILSON"), #SAME
         name = replace(name, name == "FOXX, VIRGINIA", "FOXX, VIRGINIA ANN"),
         name = replace(name, name == "GREGORY, JEFF", "GREGORY, JEFFREY DALE (JEFF)"),
         name = replace(name, name == "MANNING, KATHY", "MANNING, KATHY"), #SAME
         name = replace(name, name == "ROUZER, DAVID", "ROUZER, DAVID CHESTON"),
         name = replace(name, name == "HUDSON, RICHARD", "HUDSON, RICHARD L., JR."),
         name = replace(name, name == "MCHENRY, PATRICK T.", "MCHENRY, PATRICK TIMOTHY"),
         name = replace(name, name == "ADAMS, ALMA S", "ADAMS, ALMA SHEALEY"),
         name = replace(name, name == "BUDD, TED", "BUDD, THEODORE PAUL (TED)"),
         # Nebraska
         name = replace(name, name == "FORTENBERRY, JEFF", "FORTENBERRY, JEFFREY (JEFF)"),
         name = replace(name, name == "EASTMAN, KARA", "EASTMAN, KARA"), #SAME
         name = replace(name, name == "BACON, DON", "BACON, DONALD JOHN (DON)"),
         name = replace(name, name == "SMITH, ADRIAN", "SMITH, ADRIAN M."),
         # Nevada
         name = replace(name, name == "TITUS, DINA", "TITUS, ALICE C. (DINA)"),
         name = replace(name, name == "BENTLEY, JOYCE", "BENTLEY, JOYCE"), #SAME
         name = replace(name, name == "BAKARI, KAMAU", "BAKARI, KAMAU A."),
         name = replace(name, name == "STRAWDER, ROBERT VAN, JR.", "STRAWDER, ROBERT"),
         name = replace(name, name == "AMODEI, MARK E.", "AMODEI, MARK EUGENE"),
         name = replace(name, name == "HANSEN, JANINE", "HANSEN, JANINE"), #SAME
         name = replace(name, name == "LEE, SUSIE", "LEE, SUSIE"), #SAME
         name = replace(name, name == "BROWN, STEVE", "BROWN, STEVE"), #SAME
         name = replace(name, name == "HORSFORD, STEVEN", "HORSFORD, STEVEN ALEXZANDER"),
         # New Hampshire
         name = replace(name, name == "PAPPAS, CHRIS", "PAPPAS, CHRIS"), #SAME
         # New Jersey
         name = replace(name, name == "LUSTER, ANN M.", "KUSTER, ANN MCLANE (ANNIE)"),
         name = replace(name, name == "NORCROSS, DONALD", "NORCROSS, DONALD W."),
         name = replace(name, name == "DREW, JEFFERSON VAN", "VAN DREW, JEFF"),
         name = replace(name, name == "KIM, ANDY", "KIM, ANDY"), #SAME
         name = replace(name, name == "SHAPIRO, ROBERT", "SHAPIRO, ROBERT"), #SAME
         name = replace(name, name == "SMITH, CHRISTOPHER H.", "SMITH, CHRISTOPHER H. (CHRIS)"),
         name = replace(name, name == "SCHROEDER, HANK", "SCHROEDER, HENRY E. (HANK)"),
         name = replace(name, name == "RUFO, MICHAEL J.", "RUFO, MICHAEL"),
         name = replace(name, name == "GOTTHEIMER, JOSH", "GOTTHEIMER, JOSHUA S. (JOSH)"), #ASK
         name = replace(name, name == "PALLONE, FRANK, JR.", "PALLONE, FRANK J., JR."),
         name = replace(name, name == "MALINOWSKI, TOM", "MALINOWSKI, TOM"), #SAME
         name = replace(name, name == "KEAN, THOMAS H., JR.", "KEAN, THOMAS H., JR."), #SAME
         name = replace(name, name == "SIRES, ALBIO", "SIRES, ALBIO"), #SAME
         name = replace(name, name == "DELANEY, DAN", "DELANEY, DAN"), #SAME
         name = replace(name, name == "PASCRELL, BILL, JR.", "PASCRELL, WILLIAM J. (BILL), JR."),
         name = replace(name, name == "PAYNE, DONALD M., JR.", "PAYNE, DONALD M. (DON), JR."),
         name = replace(name, name == "SHERRILL, MIKIE", "SHERRILL, MIKIE"), #SAME
         name = replace(name, name == "COLEMAN, BONNIE WATSON", "WATSON COLEMAN, BONNIE"),
         name = replace(name, name == "FORCHION, EDWARD (NJ WEEDMAN)", "FORCHION, ROBERT EDWARD"),
         name = replace(name, name == "CODY, KENNETH J.", "CODY, KENNETH J. (KEN)"),
         # New Mexico
         name = replace(name, name == "HAALAND, DEBRA A.", "HAALAND, DEBRA A."), #SAME
         name = replace(name, name == "SMALL, XOCHITL TORRES", "SMALL, XOCHITL TORRES"), #SAME
         name = replace(name, name == "HERRELL, YVETTE", "HERRELL, YVETTE"), #SAME
         # New York
         name = replace(name, name == "ZELDIN, LEE M.", "ZELDIN, LEE M."), #SAME
         name = replace(name, name == "SUOZZI, THOMAS R.", "SUOZZI, THOMAS R. (TOM)"),
         name = replace(name, name == "RICE, KATHLEEN M.", "RICE, KATHLEEN M."), #SAME
         name = replace(name, name == "MEEKS, GREGORY W.", "MEEKS, GREGORY W."), #SAME
         name = replace(name, name == "MENG, GRACE", "MENG, GRACE"), #SAME
         name = replace(name, name == "VELAZQUEZ, NYDIA M.", "VELAZQUEZ, NYDIA M."), #SAME
         name = replace(name, name == "JEFFRIES, HAKEEM S.", "JEFFRIES, HAKEEM S."), #SAME
         name = replace(name, name == "CLARKE, YVETTE D.", "CLARKE, YVETTE DIANE"), #SAME
         name = replace(name, name == "ANABILAH-AZUMAH, JOEL B.", "ANABILAH-AZUMAH, JOEL"),
         name = replace(name, name == "NADLER, JERROLD", "NADLER, JERROLD L. (JERRY)"),
         name = replace(name, name == "ROSE, MAX", "OSE, MAX N."),
         name = replace(name, name == "MALONEY, CAROLYN B.", "MALONEY, CAROLYN B."), #SAME
         name = replace(name, name == "ESPAILLAT, ADRIANO", "ESPAILLAT, ADRIANO"), #SAME
         name = replace(name, name == "OCASIO-CORTEZ, ALEXANDRIA", "OCASIO-CORTEZ, ALEXANDRIA"), #SAME
         name = replace(name, name == "MALONEY, SEAN PATRICK", "MALONEY, SEAN PATRICK"), #SAME
         name = replace(name, name == "FARLEY, CHELE C.", "FARLEY, CHELE CHIAVACCI"),
         name = replace(name, name == "SMITH, SCOTT A.", "SMITH, SCOTT A."), #SAME
         name = replace(name, name == "DELGADO, ANTONIO", "DELGADO, ANTONIO"), #SAME
         name = replace(name, name == "GREENFIELD, STEVEN", "GREENFIELD, STEVEN"), #SAME
         name = replace(name, name == "TONKO, PAUL", "TONKO, PAUL DAVID"),
         name = replace(name, name == "COBB, TEDRA L.", "COBB, TEDRA L."), #SAME
         name = replace(name, name == "STEFANIK, ELISE M.", "STEFANIK, ELISE M."), #SAME
         name = replace(name, name == "BRINDISI, ANTHONY", "BRINDISI, ANTHONY J."), #SAME
         name = replace(name, name == "TENNEY, CLAUDIA", "TENNEY, CLAUDIA"), #SAME
         name = replace(name, name == "MITRANO, TRACY", "MITRANO, TRACY"), #SAME
         name = replace(name, name == "REED, TOM", "REED, THOMAS W. (TOM), II"),
         name = replace(name, name == "BALTER, DANA", "BALTER, DANA"), #SAME
         name = replace(name, name == "KATKO, JOHN", "KATKO, JOHN M."),
         name = replace(name, name == "MORELLE, JOSEPH D.", "MORELLE, JOSEPH D."), #SAME
         name = replace(name, name == "HIGGINS, BRIAN", "HIGGINS, BRIAN M.")
  )


