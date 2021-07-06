use "data/input/2021-06-19_election_results_2020_pres_house_ussen.dta", clear

keep if office == "H"
keep if inrange(substr(state, 1, 1), "A", "N")


// Alabama
replace name = "ROGERS, MICHAEL DENNIS (MIKE)"       if state == "AL" & name == "ROGERS, MIKE"
replace name = "ADERHOLT, ROBERT BROWN "             if state == "AL" & name == "ADERHOLT, ROBERT B."
replace name = "BROOKS, MORRIS J. (MO), JR."         if state == "AL" & name == "BROOKS, MO"
replace name = "PALMER, GARY"                        if state == "AL" & name == "PALMER, GARY J."
replace name = "SEWELL, TERRYCINA ANDREA (TERRI)"    if state == "AL" & name == "SEWELL, TERRI A."
// Alaska
replace name = "GALVIN, ALYSE S."                    if state == "AK" & name == "GALVIN, ALYSE S." // SAME
replace name = "YOUNG, DONALD E. (DON)"              if state == "AK" & name == "YOUNG, DON"
// Arizona
replace name = "O'HALLERAN, TOM C."                  if state == "AZ" & name == "O'HALLERAN, TOM"
replace name = "KIRKPATRICK, ANN"                    if state == "AZ" & name == "KIRKPATRICK, ANN" // SAME
replace name = "GRIJALVA, RAUL M."                   if state == "AZ" & name == "GRIJALVA, RAUL M." // SAME
replace name = "GOSAR, PAUL ANTHONY"                 if state == "AZ" & name == "GOSAR, PAUL A."
replace name = "GREENE, JOAN"                        if state == "AZ" & name == "GREENE, JOAN" // SAME
replace name = "BIGGS, ANDY"                         if state == "AZ" & name == "BIGGS, ANDY" // SAME
replace name = "TIPIRNENI, HIRAI"                    if state == "AZ" & name == "TIPIRNENI, HIRAL" // SAME
replace name = "SCHWEIKERT, DAVID"                   if state == "AZ" & name == "SCHWEIKERT, DAVID" // SAME
replace name = "GALLEGO, RUBEN"                      if state == "AZ" & name == "GALLEGO, RUBEN" // SAME
replace name = "LESKO, DEBBIE"                       if state == "AZ" & name == "LESKO, DEBBIE" // SAME
replace name = "STANTON, GREG"                       if state == "AZ" & name == "STANTON, GREG" // SAME
replace name = "GILES, DAVE"                         if state == "AZ" & name == "GILES, DAVID VICTOR"
// Arkansas
replace name = "CRAWFORD, ERIC ALAN (RICK)"          if state == "AR" & name == "CRAWFORD, ERIC A. (RICK)"
replace name = "ELLIOTT, JOYCE"                      if state == "AR" & name == "ELLIOTT, JOYCE" // SAME,
replace name = "HILL, FRENCH"                        if state == "AR" & name == "HILL, J FRENCH" // 2020 Name has first initial (J)
replace name = "WOMACK, STEPHEN ALLEN (STEVE)"       if state == "AR" & name == "WOMACK, STEVE"
replace name = "KALAGIAS, MICHAEL J."                if state == "AR" & name == "KALAGIAS, MICHAEL J."
replace name = "WESTERMAN, BRUCE"                    if state == "AR" & name == "WESTERMAN, BRUCE" // SAME
replace name = "GILBERT, FRANK"                      if state == "AR" & name == "GILBERT, FRANK" // SAME
replace name = "DENNEY, AUDREY"                      if state == "AR" & name == "DENNEY, AUDREY" // SAME
// California
replace name = "LAMALFA, DOUG"                       if state == "CA" & name == "LAMALFA, DOUG" // SAME,
replace name = "HUFFMAN, JARED WILLIAM"              if state == "CA" & name == "HUFFMAN, JARED"
replace name = "MENSING, DALE K."                    if state == "CA" & name == "MENSING, DALE K." // SAME
replace name = "GARAMENDI, JOHN R."                  if state == "CA" & name == "GARAMENDI, JOHN"
replace name = "MCCLINTOCK, THOMAS MILLER (TOM)"     if state == "CA" & name == "MCCLINTOCK, TOM"
replace name = "THOMPSON, C. MICHAEL (MIKE)"         if state == "CA" & name == "THOMPSON, MIKE"
replace name = "MATSUI, DORIS O."                    if state == "CA" & name == "MATSUI, DORIS O." // SAME
replace name = "BERA, AMERISH (AMI)"                 if state == "CA" & name == "BERA, AMI"
replace name = "MCNERNEY, GERALD MARK (JERRY)"       if state == "CA" & name == "MCNERNEY, JERRY"
replace name = "AMADOR, ANTONIO C. (TONY)"           if state == "CA" & name == "AMADOR, ANTONIO C. (TONY)" // SAME
replace name = "HARDER, JOSH"                        if state == "CA" & name == "HARDER, JOSH" // SAME
replace name = "DESAULNIER, MARK"                    if state == "CA" & name == "DESAULNIER, MARK" // SAME
replace name = "PELOSI, NANCY"                       if state == "CA" & name == "PELOSI, NANCY" // SAME
replace name = "LEE, BARBARA J."                     if state == "CA" & name == "LEE, BARBARA"
replace name = "SPEIER, KAREN (JACKIE)"              if state == "CA" & name == "SPEIER, JACKIE"
replace name = "SWALWELL, ERIC MICHAEL"              if state == "CA" & name == "SWALWELL, ERIC"
replace name = "COSTA, JIM"                          if state == "CA" & name == "COSTA, JIM" // SAME
replace name = "KHANNA, ROHIT (RO)"                  if state == "CA" & name == "KHANNA, RO"
replace name = "ESHOO, ANNA G."                      if state == "CA" & name == "ESHOO, ANNA G." // SAME
replace name = "LOFGREN, ZOE"                        if state == "CA" & name == "LOFGREN, ZOE" // SAME
replace name = "AGUILERA, JUSTIN JAMES"              if state == "CA" & name == "AGUILERA, JUSTIN JAMES" // SAME
replace name = "PANETTA, JIMMY VARNI"                if state == "CA" & name == "PANETTA, JIMMY" // SAME
replace name = "GORMAN, JEFFREY A. (JEFF)"           if state == "CA" & name == "GORMAN, JEFF"
replace name = "COX, T.J."                           if state == "CA" & name == "COX, TJ"
replace name = "VALADAO, DAVID G."                   if state == "CA" & name == "VALADAO, DAVID G." // SAME
replace name = "NUNES, DEVIN GERALD"                 if state == "CA" & name == "NUNES, DEVIN"
replace name = "MCCARTHY, KEVIN"                     if state == "CA" & name == "MCCARTHY, KEVIN"
replace name = "CARBAJAL, SALUD"                     if state == "CA" & name == "CARBAJAL, SALUD O." // ASK
replace name = "BROWNLEY, JULIA"                     if state == "CA" & name == "BROWNLEY, JULIA" // SAME
replace name = "BALDWIN KENNEDY, RONDA"              if state == "CA" & name == "BALDWIN-KENNEDY, RONDA"
replace name = "CHU, JUDY M."                        if state == "CA" & name == "CHU, JUDY"
replace name = "NALBANDIAN, JOHNNY J."               if state == "CA" & name == "NALBANDIAN, JOHNNY J." // SAME,
replace name = "SCHIFF, ADAM B."                     if state == "CA" & name == "SCHIFF, ADAM B." // SAME
replace name = "CARDENAS, TONY"                      if state == "CA" & name == "CÃ¡RDENAS, TONY"
replace name = "DUENAS, ANGELICA MARIA"              if state == "CA" & name == "DUEÃ±AS, ANGÃ©LICA MARIA"
replace name = "SHERMAN, BRAD"                       if state == "CA" & name == "SHERMAN, BRAD" // SAME
replace name = "REED, MARK S."                       if state == "CA" & name == "REED, MARK S." // SAME
replace name = "AGUILAR, PETE"                       if state == "CA" & name == "AGUILAR, PETE" // SAME
replace name = "NAPOLITANO, GRACE FLORES"            if state == "CA" & name == "NAPOLITANO, GRACE F."
replace name = "SCOTT, JOSHUA M."                    if state == "CA" & name == "SCOTT, JOSHUA M." // SAME
replace name = "LIEU, TED W."                        if state == "CA" & name == "LIEU, TED"
replace name = "GOMEZ, JIMMY"                        if state == "CA" & name == "GOMEZ, JIMMY" // SAME
replace name = "TORRES, NORMA J."                    if state == "CA" & name == "TORRES, NORMA J." // SAME
replace name = "RUIZ, RAUL"                          if state == "CA" & name == "RUIZ, RAUL" // SAME
replace name = "BASS, KAREN R."                      if state == "CA" & name == "BASS, KAREN"
replace name = "SANCHEZ, LINDA T."                   if state == "CA" & name == "SANCHEZ, LINDA T." // SAME
replace name = "CISNEROS, GIL"                       if state == "CA" & name == "CISNEROS, GILBERT RAY, JR."
replace name = "KIM, YOUNG"                          if state == "CA" & name == "KIM, YOUNG" // SAME
replace name = "ROYBAL-ALLARD, LUCILLE"              if state == "CA" & name == "ROYBAL-ALLARD, LUCILLE" // SAME
replace name = "DELGADO, ANTONIO"                    if state == "CA" & name == "DELGADO, ANTONIO" // SAME
replace name = "TAKANO, MARK ALLAN"                  if state == "CA" & name == "TAKANO, MARK"
replace name = "SMITH, AJA"                          if state == "CA" & name == "SMITH, AJA" // SAME
replace name = "CALVERT, KENNETH STANTON (KEN)"      if state == "CA" & name == "CALVERT, KEN"
replace name = "WATERS, MAXINE"                      if state == "CA" & name == "WATERS, MAXINE" // SAME
replace name = "BARRAGAN, NANETTE DIAZ"              if state == "CA" & name == "BARRAGÃ¡N, NANETTE DIAZ"
replace name = "PORTER, KATIE"                       if state == "CA" & name == "PORTER, KATIE" // SAME
replace name = "CORREA, JOSE LUIS (LOU)"             if state == "CA" & name == "CORREA, J LUIS"
replace name = "LOWENTHAL, ALAN S."                  if state == "CA" & name == "LOWENTHAL, ALAN S." // SAME
replace name = "BRISCOE, JOHN"                       if state == "CA" & name == "BRISCOE, JOHN" // SAME
replace name = "ROUDA, HARLEY"                       if state == "CA" & name == "ROUDA, HARLEY" // SAME
replace name = "LEVIN, MIKE"                         if state == "CA" & name == "LEVIN, MIKE" // SAME
replace name = "CAMPA-NAJJAR, AMMAR"                 if state == "CA" & name == "CAMPA-NAJJAR, AMMAR" // SAME
replace name = "ISSA, DARRELL EDWARD"                if state == "CA" & name == "ISSA, DARRELL"
replace name = "VARGAS, JUAN CARLOS"                 if state == "CA" & name == "VARGAS, JUAN"
replace name = "HIDALGO, JUAN M., JR."               if state == "CA" & name == "HIDALGO, JUAN M., JR" // SAME
replace name = "PETERS, SCOTT"                       if state == "CA" & name == "PETERS, SCOTT H."
// Colorado
replace name = "DEGETTE, DIANA LOUISE"               if state == "CO" & name == "DEGETTE, DIANA"
replace name = "FIORINO, PAUL NOEL"                  if state == "CO" & name == "FIORINO, PAUL NOEL" // SAME
replace name = "NEGUSE, JOE"                         if state == "CO" & name == "NEGUSE, JOE" // SAME
replace name = "BUSH, DIANE E. MITSCH"               if state == "CO" & name == "BUSH, DIANE MITSCH"
replace name = "BUCK, KENNETH (KEN)"                 if state == "CO" & name == "BUCK, KEN"
replace name = "GRIFFITH, BRUCE"                     if state == "CO" & name == "GRIFFITH, BRUCE" // SAME
replace name = "LAMBORN, DOUGLAS L. (DOUG)"          if state == "CO" & name == "LAMBORN, DOUG"
replace name = "CROW, JASON"                         if state == "CO" & name == "CROW, JASON" // SAME
replace name = "OLSEN, NORMAN T. (NORM)"             if state == "CO" & name == "OLSEN, NORM"
replace name = "PERLMUTTER, EDWIN G. (ED)"           if state == "CO" & name == "PERLMUTTER, ED"
replace name = "STOCKHAM, CHARLES (CASPER)"          if state == "CO" & name == "STOCKHAM, CHARLES (CASPER)" // SAME
// Connecticut
replace name = "MCCORMICK, THOMAS"                   if state == "CT" & name == "MCCORMICK, THOMAS E."
replace name = "COURTNEY, JOSEPH D. (JOE)"           if state == "CT" & name == "COURTNEY, JOE"
replace name = "REALE, DANIEL J. (DAN)"              if state == "CT" & name == "REALE, DANIEL"
replace name = "DELAURO, ROSA L."                    if state == "CT" & name == "DELAURO, ROSA L." // SAME
replace name = "HIMES, JAMES A. (JIM)"               if state == "CT" & name == "HIMES, JAMES A."
replace name = "HAYES, JAHANA"                       if state == "CT" & name == "HAYES, JAHANA" // SAME
// Delaware
replace name = "BLUNT ROCHESTER, LISA LATRELLE"      if name == "ROCHESTER, LISA BLUNT"
// Florida
replace name = "GAETZ, MATT (JERRY)"                 if state == "FL" & name == "GAETZ, MATT"
replace name = "DUNN, NEAL"                          if state == "FL" & name == "DUNN, NEAL P."
replace name = "RUTHERFORD, JOHN"                    if state == "FL" & name == "RUTHERFORD, JOHN H." // ASK
replace name = "LAWSON, ALFRED J. (AL), JR."         if state == "FL" & name == "LAWSON, AL, JR."
replace name = "CURTIS, CLINT"                       if state == "FL" & name == "CURTIS, CLINT" // ASK
replace name = "WALTZ, MICHAEL"                      if state == "FL" & name == "WALTZ, MICHAEL" // SAME
replace name = "MURPHY, STEPHANIE"                   if state == "FL" & name == "MURPHY, STEPHANIE N."
replace name = "POSEY, WILLIAM (BILL)"               if state == "FL" & name == "POSEY, BILL"
replace name = "SOTO, DARREN MICHAEL"                if state == "FL" & name == "SOTO, DARREN"
replace name = "DEMINGS, VALDEZ B. (VAL)"            if state == "FL" & name == "DEMINGS, VAL BUTLER"
replace name = "COTTRELL, DANA"                      if state == "FL" & name == "COTTRELL, DANA MARIE"
replace name = "WEBSTER, DANIEL A. (DAN)"            if state == "FL" & name == "WEBSTER, DANIEL"
replace name = "BILIRAKIS, GUS MICHAEL"              if state == "FL" & name == "BILIRAKIS, GUS M."
replace name = "CRIST, CHARLES J. (CHARLIE)"         if state == "FL" & name == "CRIST, CHARLIE"
replace name = "CASTOR, KATHERINE ANNE (KATHY)"      if state == "FL" & name == "CASTOR, KATHY"
replace name = "QUINN, CHRISTINE Y."                 if state == "FL" & name == "QUINN, CHRISTINE Y." // SAME
replace name = "COHN, ALAN M."                       if state == "FL" & name == "COHN, ALAN"
replace name = "BUCHANAN, VERNON (VERN)"             if state == "FL" & name == "BUCHANAN, VERN"
replace name = "ELLISON, ALLEN"                      if state == "FL" & name == "ELLISON, ALLEN" // SAME
replace name = "STEUBE, GREG"                        if state == "FL" & name == "STEUBE, W GREGORY"
replace name = "MAST, BRIAN J."                      if state == "FL" & name == "MAST, BRIAN J." // SAME
replace name = "HASTINGS, ALCEE LAMAR"               if state == "FL" & name == "HASTINGS, ALCEE L."
replace name = "FRANKEL, LOIS JANE"                  if state == "FL" & name == "FRANKEL, LOIS"
replace name = "DEUTCH, THEODORE ELIOT (TED)"        if state == "FL" & name == "DEUTCH, THEODORE E."
replace name = "SCHULTZ, DEBBIE WASSERMAN"           if state == "FL" & name == "SCHULTZ, DEBBIE WASSERMAN" // SAME
replace name = "SPALDING, CARLA ARLENE"              if state == "FL" & name == "SPALDING, CARLA"
replace name = "WILSON, FREDERICA S. (FREDDI)"       if state == "FL" & name == "WILSON, FREDERICA S."
replace name = "DIAZ-BALART, MARIO"                  if state == "FL" & name == "DIAZ-BALART, MARIO"
replace name = "MUCARSEL-POWELL, DEBBIE"             if state == "FL" & name == "MUCARSEL-POWELL, DEBBIE" // SAME
replace name = "SHALALA, DONNA"                      if state == "FL" & name == "SHALALA, DONNA E."
replace name = "SALAZAR, MARIA ELVIRA"               if state == "FL" & name == "SALAZAR, MARIA ELVIRA"
// Georgia
replace name = "CARTER, EARL L. (BUDDY)"             if state == "GA" & name == "CARTER, EARL L. (BUDDY)" // SAME
replace name = "BISHOP, SANFORD DIXON, JR."          if state == "GA" & name == "BISHOP, SANFORD D., JR."
replace name = "FERGUSON, DREW"                      if state == "GA" & name == "FERGUSON, A. DREW, IV"
replace name = "JOHNSON, HENRY C. (HANK), JR."       if state == "GA" & name == "JOHNSON, HENRY C. (HANK), JR." // SAME
replace name = "MCBATH, LUCY"                        if state == "GA" & name == "MCBATH, LUCY" // SAME
replace name = "HANDEL, KAREN C."                    if state == "GA" & name == "HANDEL, KAREN"
replace name = "BOURDEAUX, CAROLYN"                  if state == "GA" & name == "BOURDEAUX, CAROLYN" // SAME
replace name = "SCOTT, JAMES AUSTIN"                 if state == "GA" & name == "SCOTT, AUSTIN"
replace name = "JOHNSON-GREEN, TABITHA A."           if state == "GA" & name == "JOHNSON-GREEN, TABITHA"
replace name = "HICE, JODY B."                       if state == "GA" & name == "HICE, JODY B." // SAME
replace name = "LOUDERMILK, BARRY D."                if state == "GA" & name == "LOUDERMILK, BARRY"
replace name = "ALLEN, RICHARD W. (RICK)"            if state == "GA" & name == "ALLEN, RICK W."
replace name = "SCOTT, DAVID ALBERT"                 if state == "GA" & name == "SCOTT, DAVID"
// Hawaii
replace name = "CASE, EDWARD ESPENETT (ED)"          if state == "HI" & name == "CASE, ED"
replace name = "CURTIS, RON"                         if state == "HI" & name == "CURTIS, RON" // SAME
replace name = "TIPPENS, MICHELLE ROSE"              if state == "HI" & name == "TIPPENS, MICHELLE ROSE" // SAME
replace name = "IUFFRE, JOHN M. (RAGHU)"             if state == "HI" & name == "GIUFFRE, JOHN (RAGHU)"
// Idaho
replace name = "FULCHER, RUSSELL M. (RUSS)"          if state == "ID" & name == "FULCHER, RUSS"
replace name = "SWISHER, AARON"                      if state == "ID" & name == "SWISHER, C AARON"
replace name = "SIMPSON, MICHAEL K. (MIKE)"          if state == "ID" & name == "SIMPSON, MICHAEL K."
// Illinois
replace name = "RUSH, BOBBY LEE"                     if state == "IL" & name == "RUSH, BOBBY L."
replace name = "KELLY, ROBIN L."                     if state == "IL" & name == "KELLY, ROBIN L." // SAME
replace name = "GARCIA, CHUY"                        if state == "IL" & name == "GARCIA, JESUS G. (CHUY)"
replace name = "QUIGLEY, MICHAEL (MIKE)"             if state == "IL" & name == "QUIGLEY, MIKE"
replace name = "HANSON, TOM"                         if state == "IL" & name == "HANSON, TOMMY"
replace name = "CASTEN, SEAN"                        if state == "IL" & name == "CASTEN, SEAN" // SAME
replace name = "DAVIS, DANNY K."                     if state == "IL" & name == "DAVIS, DANNY K." // SAME
replace name = "CAMERON, CRAIG"                      if state == "IL" & name == "CAMERON, CRAIG" // SAME
replace name = "KRISHNAMOORTHI, S. RAJA"             if state == "IL" & name == "KRISHNAMOORTHI, RAJA"
replace name = "SCHAKOWSKY, JANICE D. (JAN)"         if state == "IL" & name == "SCHAKOWSKY, JANICE D."
replace name = "SCHNEIDER, BRADLEY SCOTT (BRAD)"     if state == "IL" & name == "SCHNEIDER, BRADLEY SCOTT"
replace name = "FOSTER, G. WILLIAM (BILL)"           if state == "IL" & name == "FOSTER, BILL"
replace name = "BOST, MICHAEL J. (MIKE)"             if state == "IL" & name == "BOST, MIKE"
replace name = "LONDRIGAN, BETSY DIRKSEN"            if state == "IL" & name == "LONDRIGAN, BETSY DIRKSEN" // SAME
replace name = "DAVIS, RODNEY L."                    if state == "IL" & name == "DAVIS, RODNEY"
replace name = "UNDERWOOD, LAUREN"                   if state == "IL" & name == "UNDERWOOD, LAUREN" // SAME
replace name = "OBERWEIS, JAMES D. (JIM)"            if state == "IL" & name == "OBERWEIS, JIM"
replace name = "KINZINGER, ADAM"                     if state == "IL" & name == "KINZINGER, ADAM" // SAME
replace name = "BUSTOS, CHERI"                       if state == "IL" & name == "BUSTOS, CHERI" // SAME
replace name = "LAHOOD, DARIN M."                    if state == "IL" & name == "LAHOOD, DARIN"
// Indiana
replace name = "LEYVA, MARK J."                      if state == "IN" & name == "LEYVA, MARK"
replace name = "WALORSKI, JACKIE SWIHART"            if state == "IN" & name == "WALORSKI, JACKIE"
replace name = "BANKS, JAMES E. (JIM)"               if state == "IN" & name == "BANKS, JIM"
replace name = "BAIRD, JIM"                          if state == "IN" & name == "BAIRD, JAMES R."
replace name = "LAKE, JEANNINE LEE"                  if state == "IN" & name == "LAKE, JEANNINE LEE" // SAME
replace name = "PENCE, GREG"                         if state == "IN" & name == "PENCE, GREG" // SAME
replace name = "FERKINHOFF, TOM"                     if state == "IN" & name == "FERKINHOFF, TOM"
replace name = "CARSON, ANDRE D."                    if state == "IN" & name == "CARSON, ANDRÃ©"
replace name = "BUCSHON, LARRY D."                   if state == "IN" & name == "BUCSHON, LARRY"
replace name = "HOLLINGSWORTH, JOSEPH A. (TREY), III" if state == "IN" & name == "HOLLINGSWORTH, TREY"
// Iowa
replace name = "MILLER-MEEKS, MARIANNETTE JANE"      if state == "IA" & name == "MILLER-MEEKS, MARIANNETTE"
replace name = "AXNE, CINDY"                         if state == "IA" & name == "AXNE, CYNTHIA"
replace name = "YOUNG, DAVID"                        if state == "IA" & name == "YOUNG, DAVID" // SAME
replace name = "HOLDER, BRYAN JACK"                  if state == "IA" & name == "HOLDER, BRYAN JACK" // SAME
replace name = "SCHOLTEN, J.D."                      if state == "IA" & name == "SCHOLTEN, J D." // SAME
// Kansas
replace name = "LATURNER, JACOB"                     if state == "KS" & name == "LATURNER, JAKE" // SAME
replace name = "GARRARD, ROBERT DAVID"               if state == "KS" & name == "GARRARD, ROBERT"
replace name = "DAVIDS, SHARICE"                     if state == "KS" & name == "DAVIDS, SHARICE" // SAME
replace name = "HOHE, STEVEN A. (STEVE)"             if state == "KS" & name == "OHE, STEVEN A."
replace name = "ESTES, RON"                          if state == "KS" & name == "ESTES, RON" // SAME
// Kentucky
replace name = "COMER, JAMES R. (JAMIE), JR."        if state == "KY" & name == "COMER, JAMES"
replace name = "LINDERMAN, HANK"                     if state == "KY" & name == "LINDERMAN, HANK" // SAME
replace name = "GUTHRIE, STEVEN (BRETT)"             if state == "KY" & name == "GUTHRIE, BRETT"
replace name = "YARMUTH, JOHN A"                     if state == "KY" & name == "YARMUTH, JOHN A." // SAME
replace name = "PALAZZO, STEVEN MCCARTY"             if state == "KY" & name == "PALAZZO, STEVEN M."
replace name = "MASSIE, THOMAS H."                   if state == "KY" & name == "MASSIE, THOMAS"
replace name = "ROGERS, HAROLD DALLAS (HAL)"         if state == "KY" & name == "ROGERS, HAROLD"
replace name = "BARR, GARLAND (ANDY)"                if state == "KY" & name == "BARR, ANDY"
replace name = "HARRIS, FRANK"                       if state == "KY" & name == "HARRIS, FRANK" // SAME
// Louisiana
replace name = "DUGAS, LEE ANN"                      if state == "LA" & name == "DUGAS, LEE ANN" // SAME
replace name = "SCALISE, STEPHEN J. (STEVE)"         if state == "LA" & name == "SCALISE, STEVE"
replace name = "KEARNEY, HOWARD L."                  if state == "LA" & name == "KEARNEY, HOWARD"
replace name = "RICHMOND, CEDRIC L."                 if state == "LA" & name == "RICHMOND, CEDRIC L."
replace name = "BATISTE, BELDEN (NOONIE MAN)"        if state == "LA" & name == "BATISTE, BELDEN (NOONIE MAN)" // SAME
replace name = "ANDERSON, ROB"                       if state == "LA" & name == "ANDERSON, (ROB)"
replace name = "HIGGINS, CLAY"                       if state == "LA" & name == "HIGGINS, CLAY" // SAME
replace name = "TRUNDLE, RYAN"                       if state == "LA" & name == "TRUNDLE, RYAN" // SAME
replace name = "JOHNSON, MIKE"                       if state == "LA" & name == "JOHNSON, MIKE" // SAME
replace name = "ROBINSON, RANDALL SCOTT (SCOTTY)"    if state == "LA" & name == "ROBINSON, (SCOTTY)" // https://ballotpedia.org/Randall_Scott_Robinson_(Louisiana)
replace name = "HASTY, MATTHEW (MATT)"               if state == "LA" & name == "HASTY, (MATT)" // https://docquery.fec.gov/pdf/640/202007179250399640/202007179250399640.pdf
replace name = "GRAVES, GARRET"                      if state == "LA" & name == "GRAVES, GARRET" // SAME
// Maine
replace name = "PINGREE, ROCHELLE M. (CHELLIE)"      if state == "ME" & name == "PINGREE, CHELLIE"
replace name = "GOLDEN, JARED F."                    if state == "ME" & name == "GOLDEN, JARED F." // SAME
// Maryland
replace name = "HARRIS, ANDREW P. (ANDY)"            if state == "MD" & name == "HARRIS, ANDY"
replace name = "RUPPERSBERGER, C.A. (DUTCH)"         if state == "MD" & name == "RUPPERSBERGER, C A. DUTCH"
replace name = "SARBANES, JOHN P."                   if state == "MD" & name == "SARBANES, JOHN P." // SAME
replace name = "ANTHONY, CHARLES"                    if state == "MD" & name == "ANTHONY, CHARLES" // SAME
replace name = "BROWN, ANTHONY G."                   if state == "MD" & name == "BROWN, ANTHONY G." // SAME
replace name = "MCDERMOTT, GEORGE EDWARD"            if state == "MD" & name == "MCDERMOTT, GEORGE E."
replace name = "HOYER, STENY HAMILTON"               if state == "MD" & name == "HOYER, STENY H."
replace name = "TRONE, DAVID"                        if state == "MD" & name == "TRONE, DAVID J."
replace name = "GLUCK, GEORGE"                       if state == "MD" & name == "GLUCK, GEORGE" // SAME
replace name = "RASKIN, JAMIN B."                    if state == "MD" & name == "RASKIN, JAMIE"
// Massachusetts
replace name = "NEAL, RICHARD E."                    if state == "MA" & name == "NEAL, RICHARD E." // SAME
replace name = "MCGOVERN, JAMES P. (JIM)"            if state == "MA" & name == "MCGOVERN, JAMES P."
replace name = "LOVVORN, TRACY LYN"                  if state == "MA" & name == "LOVVORN, TRACY LYN" // SAME
replace name = "TRAHAN, LORI LOUREIRO"               if state == "MA" & name == "TRAHAN, LORI"
replace name = "CLARK, KATHERINE M."                 if state == "MA" & name == "CLARK, KATHERINE M." // SAME
replace name = "MOULTON, SETH W."                    if state == "MA" & name == "MOULTON, SETH"
replace name = "PRESSLEY, AYANNA S."                 if state == "MA" & name == "PRESSLEY, AYANNA"
replace name = "LYNCH, STEPHEN F."                   if state == "MA" & name == "LYNCH, STEPHEN F." // SAME
replace name = "KEATING, WILLIAM RICHARD (BILL)"     if state == "MA" & name == "KEATING, WILLIAM R."
replace name = "BRADY, HELEN"                        if state == "MA" & name == "BRADY, HELEN" // SAME
// Michigan
replace name = "FERGUSON, DANA"                      if state == "MI" & name == "FERGUSON, DANA" // SAME
replace name = "BERGMAN, JACK"                       if state == "MI" & name == "BERGMAN, JACK" // SAME
replace name = "HUIZENGA, WILLIAM P. (BILL)"         if state == "MI" & name == "HUIZENGA, BILL"
replace name = "VAN SICKLE, GERALD TRUMAN"           if state == "MI" & name == "SICKLE, GERALD T. VAN"
replace name = "SCHOLTEN, J.D."                      if state == "MI" & name == "SCHOLTEN, J D."
replace name = "HILLIARD, JERRY"                     if state == "MI" & name == "HILLIARD, JERRY" // SAME
replace name = "MOOLENAAR, JOHN"                     if state == "MI" & name == "MOOLENAAR, JOHN R."
replace name = "KILDEE, DANIEL TIMOTHY (DAN)"        if state == "MI" & name == "KILDEE, DANIEL T."
replace name = "GOODWIN, KATHY"                      if state == "MI" & name == "GOODWIN, KATHY" // SAME
replace name = "UPTON, FREDERICK STEPHEN (FRED)"     if state == "MI" & name == "UPTON, FRED"
replace name = "LAWRENCE, JOHN"                      if state == "MI" & name == "LAWRENCE, JOHN" // SAME
replace name = "DRISKELL, GRETCHEN D."               if state == "MI" & name == "DRISKELL, GRETCHEN D." // SAME
replace name = "WALBERG, TIMOTHY L. (TIM)"           if state == "MI" & name == "WALBERG, TIM"
replace name = "SLOTKIN, ELISSA"                     if state == "MI" & name == "SLOTKIN, ELISSA" // SAME
replace name = "LEVIN, ANDY"                         if state == "MI" & name == "LEVIN, ANDY" // SAME
replace name = "KIRBY, ANDREA"                       if state == "MI" & name == "KIRBY, ANDREA L."
replace name = "BIZON, KIMBERLY"                     if state == "MI" & name == "BIZON, KIMBERLY" // SAME
replace name = "STEVENS, HALEY"                      if state == "MI" & name == "STEVENS, HALEY M."
replace name = "SCHWARTZ, LEONARD C."                if state == "MI" & name == "SCHWARTZ, LEONARD"
replace name = "DINGELL, DEBBIE INSLEY"              if state == "MI" & name == "DINGELL, DEBBIE"
replace name = "JONES, JEFFREY W. (JEFF)"            if state == "MI" & name == "JONES, JEFF"
replace name = "WALKOWICZ, GARY"                     if state == "MI" & name == "WALKOWICZ, GARY" // SAME
replace name = "TLAIB, RASHIDA"                      if state == "MI" & name == "TLAIB, RASHIDA" // SAME
replace name = "JOHNSON, SAM"                        if state == "MI" & name == "JOHNSON, SAM" // SAME
replace name = "WILCOXON, D. ETTA"                   if state == "MI" & name == "WILCOXON, D ETTA" // SAME
replace name = "LAWRENCE, BRENDA LUIENAR"            if state == "MI" & name == "LAWRENCE, BRENDA L."
replace name = "GIOIA, LISA LANE"                    if state == "MI" & name == "GIOIA, LISA LANE" // SAME
replace name = "KOLODY, PHILIP"                      if state == "MI" & name == "KOLODY, PHILIP" // SAME
replace name = "SHABAZZ, CLYDE K."                   if state == "MI" & name == "SHABAZZ, CLYDE K." // SAME
// Minnesota
replace name = "FEEHAN, DAN"                         if state == "MN" & name == "FEEHAN, DAN" // SAME
replace name = "HAGEDORN, JAMES (JIM)"               if state == "MN" & name == "HAGEDORN, JIM "
replace name = "CRAIG, ANGELA DAWN (ANGIE)"          if state == "MN" & name == "CRAIG, ANGIE"
replace name = "PHILLIPS, DEAN"                      if state == "MN" & name == "PHILLIPS, DEAN" // SAME
replace name = "MCCOLLUM, BETTY"                     if state == "MN" & name == "MCCOLLUM, BETTY" // SAME
replace name = "SINDT, SUSAN PENDERGAST"             if state == "MN" & name == "SINDT, SUSAN"
replace name = "OMAR, ILHAN"                         if state == "MN" & name == "OMAR, ILHAN" // SAME
replace name = "EMMER, THOMAS (TOM)"                 if state == "MN" & name == "EMMER, TOM"
replace name = "PETERSON, COLLIN CLARK"              if state == "MN" & name == "PETERSON, COLLIN C."
replace name = "STAUBER, PETE"                       if state == "MN" & name == "STAUBER, PETE" // SAME
replace name = "SCHWARTZBACKER, JUDITH"              if state == "MN" & name == "SCHWARTZBACKER, JUDITH" // SAME
// Mississippi
replace name = "KELLY, TRENT"                        if state == "MS" & name == "KELLY, TRENT" // SAME
replace name = "THOMPSON, BENNIE G."                 if state == "MS" & name == "THOMPSON, BENNIE G." // SAME
replace name = "GUEST, MICHAEL"                      if state == "MS" & name == "GUEST, MICHAEL" // SAME
replace name = "PALAZZO, STEVEN MCCARTY"             if state == "MS" & name == "PALAZZO, STEVEN M."
// Missouri
replace name = "WAGNER, ANN L."                      if state == "MO" & name == "WAGNER, ANN"
replace name = "LUETKEMEYER, W. BLAINE"              if state == "MO" & name == "LUETKEMEYER, BLAINE"
replace name = "HARTZLER, VICKY J."                  if state == "MO" & name == "HARTZLER, VICKY"
replace name = "LEAVER, EMANUEL, II"                 if state == "MO" & name == "CLEAVER, EMANUEL"
replace name = "GRAVES, SAMUEL B. (SAM), JR."        if state == "MO" & name == "GRAVES, SAM"
replace name = "HIGGINS, JAMES EDWARD (JIM)"         if state == "MO" & name == "HIGGINS, JIM"
replace name = "LONG, BILLY"                         if state == "MO" & name == "LONG, BILLY" // SAME
replace name = "CRAIG, KEVIN"                        if state == "MO" & name == "CRAIG, KEVIN" // SAME
replace name = "ELLIS, KATHY"                        if state == "MO" & name == "ELLIS, KATHY" // SAME
replace name = "SMITH, JASON T."                     if state == "MO" & name == "SMITH, JASON"
// Montana
replace name = "WILLIAMS, KATHLEEN"                  if state == "MT" & name == "WILLIAMS, KATHLEEN" // SAME
replace name = "ROSENDALE, MATTHEW M. (MATT)"        if state == "MT" & name == "ROSENDALE, MATT"
// North Carolina
replace name = "BUTTERFIELD, GEORGE K. (G.K.), JR."  if state == "NC" & name == "BUTTERFIELD, G K."
replace name = "ROSS, DEBORAH K."                    if state == "NC" & name == "ROSS, DEBORAH K." // SAME
replace name = "MATEMU, JEFF"                        if state == "NC" & name == "MATEMU, JEFF" // SAME
replace name = "PRICE, DAVID EUGENE"                 if state == "NC" & name == "PRICE, DAVID E."
replace name = "BROWN, DAVID WILSON"                 if state == "NC" & name == "BROWN, DAVID WILSON" // SAME
replace name = "FOXX, VIRGINIA ANN"                  if state == "NC" & name == "FOXX, VIRGINIA"
replace name = "GREGORY, JEFFREY DALE (JEFF)"        if state == "NC" & name == "GREGORY, JEFF"
replace name = "MANNING, KATHY"                      if state == "NC" & name == "MANNING, KATHY" // SAME
replace name = "ROUZER, DAVID CHESTON"               if state == "NC" & name == "ROUZER, DAVID"
replace name = "HUDSON, RICHARD L., JR."             if state == "NC" & name == "HUDSON, RICHARD"
replace name = "MCHENRY, PATRICK TIMOTHY"            if state == "NC" & name == "MCHENRY, PATRICK T."
replace name = "ADAMS, ALMA SHEALEY"                 if state == "NC" & name == "ADAMS, ALMA S"
replace name = "BUDD, THEODORE PAUL (TED)"           if state == "NC" & name == "BUDD, TED"
replace name = "TIMMONS-GOODSON, PATRICIA (PAT)"     if state == "NC" & name == "TIMMONS-GOODSON, PATRICIA"
// Nebraska
replace name = "FORTENBERRY, JEFFREY (JEFF)"         if state == "NE" & name == "FORTENBERRY, JEFF"
replace name = "EASTMAN, KARA"                       if state == "NE" & name == "EASTMAN, KARA" // SAME
replace name = "BACON, DONALD JOHN (DON)"            if state == "NE" & name == "BACON, DON"
replace name = "SMITH, ADRIAN M."                    if state == "NE" & name == "SMITH, ADRIAN"
// Nevada
replace name = "TITUS, ALICE C. (DINA)"              if state == "NV" & name == "TITUS, DINA"
replace name = "BENTLEY, JOYCE"                      if state == "NV" & name == "BENTLEY, JOYCE" // SAME
replace name = "BAKARI, KAMAU A."                    if state == "NV" & name == "BAKARI, KAMAU"
replace name = "STRAWDER, ROBERT"                    if state == "NV" & name == "STRAWDER, ROBERT VAN, JR."
replace name = "AMODEI, MARK EUGENE"                 if state == "NV" & name == "AMODEI, MARK E."
replace name = "HANSEN, JANINE"                      if state == "NV" & name == "HANSEN, JANINE" // SAME
replace name = "LEE, SUSIE"                          if state == "NV" & name == "LEE, SUSIE" // SAME
replace name = "BROWN, STEVE"                        if state == "NV" & name == "BROWN, STEVE" // SAME
replace name = "HORSFORD, STEVEN ALEXZANDER"         if state == "NV" & name == "HORSFORD, STEVEN"
// New Hampshire
replace name = "PAPPAS, CHRIS"                       if state == "NH" & name == "PAPPAS, CHRIS" // SAME
// New Jersey
replace name = "KUSTER, ANN MCLANE (ANNIE)"          if state == "NJ" & name == "LUSTER, ANN M."
replace name = "NORCROSS, DONALD W."                 if state == "NJ" & name == "NORCROSS, DONALD"
replace name = "VAN DREW, JEFF"                      if state == "NJ" & name == "DREW, JEFFERSON VAN"
replace name = "KIM, ANDY"                           if state == "NJ" & name == "KIM, ANDY" // SAME
replace name = "SHAPIRO, ROBERT"                     if state == "NJ" & name == "SHAPIRO, ROBERT" // SAME
replace name = "SMITH, CHRISTOPHER H. (CHRIS)"       if state == "NJ" & name == "SMITH, CHRISTOPHER H."
replace name = "SCHROEDER, HENRY E. (HANK)"          if state == "NJ" & name == "SCHROEDER, HANK"
replace name = "RUFO, MICHAEL"                       if state == "NJ" & name == "RUFO, MICHAEL J."
replace name = "GOTTHEIMER, JOSHUA S. (JOSH)"        if state == "NJ" & name == "GOTTHEIMER, JOSH" // ASK
replace name = "PALLONE, FRANK J., JR."              if state == "NJ" & name == "PALLONE, FRANK, JR."
replace name = "MALINOWSKI, TOM"                     if state == "NJ" & name == "MALINOWSKI, TOM" // SAME
replace name = "KEAN, THOMAS H., JR."                if state == "NJ" & name == "KEAN, THOMAS H., JR." // SAME
replace name = "SIRES, ALBIO"                        if state == "NJ" & name == "SIRES, ALBIO" // SAME
replace name = "DELANEY, DAN"                        if state == "NJ" & name == "DELANEY, DAN" // SAME
replace name = "PASCRELL, WILLIAM J. (BILL), JR."    if state == "NJ" & name == "PASCRELL, BILL, JR."
replace name = "PAYNE, DONALD M. (DON), JR."         if state == "NJ" & name == "PAYNE, DONALD M., JR."
replace name = "SHERRILL, MIKIE"                     if state == "NJ" & name == "SHERRILL, MIKIE" // SAME
replace name = "WATSON COLEMAN, BONNIE"              if state == "NJ" & name == "COLEMAN, BONNIE WATSON"
replace name = "FORCHION, ROBERT EDWARD"             if state == "NJ" & name == "FORCHION, EDWARD (NJ WEEDMAN)"
replace name = "CODY, KENNETH J. (KEN)"              if state == "NJ" & name == "CODY, KENNETH J."
// New Mexico
replace name = "HAALAND, DEBRA A."                   if state == "NM" & name == "HAALAND, DEBRA A." // SAME
replace name = "SMALL, XOCHITL TORRES"               if state == "NM" & name == "SMALL, XOCHITL TORRES" // SAME
replace name = "HERRELL, YVETTE"                     if state == "NM" & name == "HERRELL, YVETTE" // SAME
// New York
replace name = "ZELDIN, LEE M."                      if state == "NY" & name == "ZELDIN, LEE M." // SAME
replace name = "SUOZZI, THOMAS R. (TOM)"             if state == "NY" & name == "SUOZZI, THOMAS R."
replace name = "RICE, KATHLEEN M."                   if state == "NY" & name == "RICE, KATHLEEN M." // SAME
replace name = "MEEKS, GREGORY W."                   if state == "NY" & name == "MEEKS, GREGORY W." // SAME
replace name = "MENG, GRACE"                         if state == "NY" & name == "MENG, GRACE" // SAME
replace name = "VELAZQUEZ, NYDIA M."                 if state == "NY" & name == "VELAZQUEZ, NYDIA M." // SAME
replace name = "JEFFRIES, HAKEEM S."                 if state == "NY" & name == "JEFFRIES, HAKEEM S." // SAME
replace name = "CLARKE, YVETTE DIANE"                if state == "NY" & name == "CLARKE, YVETTE D." // SAME
replace name = "ANABILAH-AZUMAH, JOEL"               if state == "NY" & name == "ANABILAH-AZUMAH, JOEL B."
replace name = "NADLER, JERROLD L. (JERRY)"          if state == "NY" & name == "NADLER, JERROLD"
replace name = "ROSE, MAX N."                        if state == "NY" & name == "ROSE, MAX"
replace name = "MALONEY, CAROLYN B."                 if state == "NY" & name == "MALONEY, CAROLYN B." // SAME
replace name = "ESPAILLAT, ADRIANO"                  if state == "NY" & name == "ESPAILLAT, ADRIANO" // SAME
replace name = "OCASIO-CORTEZ, ALEXANDRIA"           if state == "NY" & name == "OCASIO-CORTEZ, ALEXANDRIA" // SAME
replace name = "MALONEY, SEAN PATRICK"               if state == "NY" & name == "MALONEY, SEAN PATRICK" // SAME
replace name = "FARLEY, CHELE CHIAVACCI"             if state == "NY" & name == "FARLEY, CHELE C."
replace name = "SMITH, SCOTT A."                     if state == "NY" & name == "SMITH, SCOTT A." // SAME
replace name = "DELGADO, ANTONIO"                    if state == "NY" & name == "DELGADO, ANTONIO" // SAME
replace name = "GREENFIELD, STEVEN"                  if state == "NY" & name == "GREENFIELD, STEVEN" // SAME
replace name = "TONKO, PAUL DAVID"                   if state == "NY" & name == "TONKO, PAUL"
replace name = "COBB, TEDRA L."                      if state == "NY" & name == "COBB, TEDRA L." // SAME
replace name = "STEFANIK, ELISE M."                  if state == "NY" & name == "STEFANIK, ELISE M." // SAME
replace name = "BRINDISI, ANTHONY J."                if state == "NY" & name == "BRINDISI, ANTHONY" // SAME
replace name = "TENNEY, CLAUDIA"                     if state == "NY" & name == "TENNEY, CLAUDIA" // SAME
replace name = "MITRANO, TRACY"                      if state == "NY" & name == "MITRANO, TRACY" // SAME
replace name = "REED, THOMAS W. (TOM), II"           if state == "NY" & name == "REED, TOM"
replace name = "BALTER, DANA"                        if state == "NY" & name == "BALTER, DANA" // SAME
replace name = "KATKO, JOHN M."                      if state == "NY" & name == "KATKO, JOHN"
replace name = "MORELLE, JOSEPH D."                  if state == "NY" & name == "MORELLE, JOSEPH D." // SAME
replace name = "HIGGINS, BRIAN M."                   if state == "NY" & name == "HIGGINS, BRIAN" 

// NY Working Family and Democrats
replace name = "GOROFF, NANCY S."          if state == "NY" & dist == 1 &  party == "Working Families"
replace name = "GORDON, JACKIE"            if state == "NY" & dist == 2 &  party == "Working Families"
replace name = "GORDON, JACKIE"            if state == "NY" & dist == 2 &  party == "Independence"
replace name = "SUOZZI, THOMAS R. (TOM)"   if state == "NY" & dist == 3 &  party == "Working Families"
replace name = "SUOZZI, THOMAS R. (TOM)"   if state == "NY" & dist == 3 &  party == "Independence"
replace name = "MENG, GRACE"               if state == "NY" & dist == 6 &  party == "Working Families"
replace name = "VELAZQUEZ, NYDIA M."       if state == "NY" & dist == 7 &  party == "Working Families"
replace name = "JEFFRIES, HAKEEM S."       if state == "NY" & dist == 8 &  party == "Working Families"
replace name = "CLARKE, YVETTE D."         if state == "NY" & dist == 9 &  party == "Working Families"
replace name = "NADLER, JERROLD L. (JERRY)" if state == "NY" & dist == 10 & party == "Working Families"
replace name = "ROSE, MAX N."              if state == "NY" & dist == 11 & party == "Independence"
replace name = "ESPAILLAT, ADRIANO"        if state == "NY" & dist == 13 & party == "Working Families"
replace name = "JONES, MONDAIRE"           if state == "NY" & dist == 17 & party == "Working Families"
replace name = "MALONEY, SEAN PATRICK"     if state == "NY" & dist == 18 & party == "Working Families"
replace name = "MALONEY, SEAN PATRICK"     if state == "NY" & dist == 18 & party == "Independence"
replace name = "DELGADO, ANTONIO"          if state == "NY" & dist == 19 & party == "Working Families"
replace name = "DELGADO, ANTONIO"          if state == "NY" & dist == 19 & party == "Save American Movement"
replace name = "TONKO, PAUL DAVID"         if state == "NY" & dist == 20 & party == "Working Families"
replace name = "TONKO, PAUL DAVID"         if state == "NY" & dist == 20 & party == "Independence"
replace name = "COBB, TEDRA L."            if state == "NY" & dist == 21 & party == "Working Families"
replace name = "BRINDISI, ANTHONY"         if state == "NY" & dist == 22 & party == "Working Families"
replace name = "BRINDISI, ANTHONY"         if state == "NY" & dist == 22 & party == "Independence"
replace name = "MITRANO, TRACY"            if state == "NY" & dist == 23 & party == "Working Families"
replace name = "MORELLE, JOSEPH D."        if state == "NY" & dist == 25 & party == "Working Families"
replace name = "MORELLE, JOSEPH D."        if state == "NY" & dist == 25 & party == "Independence"
replace name = "HIGGINS, BRIAN M."         if state == "NY" & dist == 26 & party == "Working Families"
replace name = "HIGGINS, BRIAN M."         if state == "NY" & dist == 26 & party == "Save America Movement"
replace name = "MCMURRAY, NATHAN D."       if state == "NY" & dist == 27 & party == "Working Families"
replace name = "ZELDIN, LEE M."            if state == "NY" & dist == 1 &  party == "Conservative"
replace name = "ZELDIN, LEE M."            if state == "NY" & dist == 1 &  party == "Independence"
replace name = "GARBARINO, ANDREW R."      if state == "NY" & dist == 2 &  party == "Conservative"
replace name = "GARBARINO, ANDREW R."      if state == "NY" & dist == 2 &  party == "Libertarian"
replace name = "GARBARINO, ANDREW R."      if state == "NY" & dist == 2 &  party == "Serve America Movement"
replace name = "SANTOS, GEORGE A. D"       if state == "NY" & dist == 3 &  party == "Conservative"
replace name = "TUMAN, DOUGLAS L."         if state == "NY" & dist == 4 &  party == "Conservative"
replace name = "ZMICH, THOMAS J."          if state == "NY" & dist == 6 &  party == "Conservative"
replace name = "ZMICH, THOMAS J."          if state == "NY" & dist == 6 &  party == "Save Our City"
replace name = "ZMICH, THOMAS J."          if state == "NY" & dist == 6 &  party == "Libertarian"
replace name = "KELLY, BRIAN W."           if state == "NY" & dist == 7 &  party == "Conservative"
replace name = "WALLACE, GARFIELD H."      if state == "NY" & dist == 8 &  party == "Conservative"
replace name = "JEAN-PIERRE, CONSTANTINE"  if state == "NY" & dist == 9 &  party == "Conservative"
replace name = "BERNSTEIN, CATHY A."       if state == "NY" & dist == 10 & party == "Conservative"
replace name = "MALLIOTAKIS, NICOLE"       if state == "NY" & dist == 11 & party == "Conservative"
replace name = "SANTIAGO-CANO, CARLOS"     if state == "NY" & dist == 12 & party == "Conservative"
replace name = "CUMMINGS, JOHN C."         if state == "NY" & dist == 14 & party == "Conservative"
replace name = "DELICES, PATRICK"          if state == "NY" & dist == 15 & party == "Conservative"
replace name = "FARLEY, CHELE CHIAVACCI"   if state == "NY" & dist == 18 & party == "Conservative"
replace name = "SMITH, SCOTT A."           if state == "NY" & dist == 18 & party == "Serve America Movement"
replace name = "JOY, ELIZABETH L."         if state == "NY" & dist == 20 & party == "Conservative"
replace name = "JOY, ELIZABETH L."         if state == "NY" & dist == 20 & party == "Serve America Movement"
replace name = "STEFANIK, ELISE M."        if state == "NY" & dist == 21 & party == "Conservative"
replace name = "STEFANIK, ELISE M."        if state == "NY" & dist == 21 & party == "Independence"
replace name = "TENNEY, CLAUDIA"           if state == "NY" & dist == 22 & party == "Conservative"
replace name = "REED, THOMAS W. (TOM), II" if state == "NY" & dist == 23 & party == "Conservative"
replace name = "REED, THOMAS W. (TOM), II" if state == "NY" & dist == 23 & party == "Independence"
replace name = "KATKO, JOHN M."            if state == "NY" & dist == 24 & party == "Conservative"
replace name = "KATKO, JOHN M."            if state == "NY" & dist == 24 & party == "Independence"
replace name = "MITRIS, GEORGE"            if state == "NY" & dist == 25 & party == "Conservative"
replace name = "JACOBS, CHRIS"             if state == "NY" & dist == 27 & party == "Constitution"
replace name = "JACOBS, CHRIS"             if state == "NY" & dist == 27 & party == "Independence"

// CT Working Families Party
replace name = "LARSON, JOHN B."           if state == "CT" & dist == 1 & party == "Working Families"
replace name = "COURTNEY, JOSEPH D. (JOE)" if state == "CT" & dist == 2 & party == "Working Families"
replace name = "DELAURO, ROSA L."          if state == "CT" & dist == 3 & party == "Working Families"
replace name = "STREICKER, MARGARET".      if state == "CT" & dist == 3 & party == "Independent"
replace name = "HAYES, JAHANA"             if state == "CT" & dist == 5 & party == "Working Families"
* save
save data/intermediate/2020_ushouse_A-N.dta, replace
