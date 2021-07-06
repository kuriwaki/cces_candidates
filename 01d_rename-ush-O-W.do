use ${js_2020_init}, clear

keep if office == "H"
keep if inrange(substr(state, 1, 1), "O", "Z")




replace name = "CHABOT, STEVEN J. (STEVE)"      if state == "OH" & name == "CHABOT, STEVE"
replace name = "JORDAN, JAMES D. (JIM)"         if state == "OH" & name == "JORDAN, JIM"
replace name = "LATTA, ROBERT EDWARD (BOB)"     if state == "OH" & name == "LATTA, ROBERT E."

replace name = "GIBBS, ROBERT (BOB)"            if state == "OH" & name == "GIBBS, BOB"
replace name = "KAPTUR, MARCIA C. (MARCY)"      if state == "OH" & name == "KAPTUR, MARCY"
replace name = "TURNER, MICHAEL R. (MIKE)"      if state == "OH" & name == "TURNER, MICHAEL R."
replace name = "RYAN, TIMOTHY J. (TIM)"         if state == "OH" & name == "RYAN, TIM"
replace name = "STIVERS, STEVEN (STEVE)"        if state == "OH" & name == "STIVERS, STEVE"
replace name = "COLE, TOM JEFFREY"              if state == "OK" & name == "COLE, TOM"
replace name = "HORN, KENDRA S."                if state == "OK" & name == "HORN, KENDRA" // 2018 to 2020


replace name = "LANGEVIN, JAMES R. (JIM)"       if state == "RI" & name == "LANGEVIN, JAMES R."
replace name = "HOULAHAN, CHRISSY J."           if state == "PA" & name == "HOULAHAN, CHRISSY" // 2018 to 2020
replace name = "CARTWRIGHT, MATTHEW A. (MATT)"  if state == "PA" & name == "CARTWRIGHT, MATTHEW ALTON"
replace name = "PERRY, SCOTT GORDON"            if state == "PA" & name == "PERRY, SCOTT G."
replace name = "KELLY, GEORGE J. (MIKE), JR."   if state == "PA" & name == "KELLY, GEORGE J., JR."
replace name = "LAMB, CONOR JAMES"              if state == "PA" & name == "LAMB, CONOR J."
replace name = "DOYLE, MICHAEL F. (MIKE), JR."  if state == "PA" & name == "DOYLE, MICHAEL F., JR."


replace name = "WILSON, ADDISON GRAVES (JOE)"   if state == "SC" & name == "WILSON, JOE"
replace name = "DUNCAN, JEFFREY D. (JEFF)"      if state == "SC" & name == "DUNCAN, JEFF"
replace name = "NORMAN, RALPH W."               if state == "SC" & name == "NORMAN, RALPH"
replace name = "CLYBURN, JAMES E. (JIM)"        if state == "SC" & name == "CLYBURN, JAMES E."
replace name = "RICE, HUGH THOMPSON (TOM), JR." if state == "SC" & name == "RICE, TOM"
replace name = "TIMMONS, WILLIAM R., IV"        if state == "SC" & name == "TIMMONS, WILLIAM R., IV" // 2018 to 2020

replace name = "JOHNSON, DUSTIN (DUSTY)"        if state == "SD" & name == "JOHNSON, DUSTY"

* hoyos, john rose for more 2018 to 2020
replace name = "DESJARLAIS, SCOTT EUGENE"       if state == "TN" & name == "DESJARLAIS, SCOTT"
replace name = "COOPER, JAMES H. (JIM)"         if state == "TN" & name == "COOPER, JIM"
replace name = "COHEN, STEPHEN IRA (STEVE)"     if state == "TN" & name == "COHEN, STEVE"


* crenshaw, ron wright for more 2018 to 2020
replace name = "GOHMERT, LOUIS (LOUIE)"         if state == "TX" & name == "GOHMERT, LOUIE"
replace name = "TAYLOR, NICHOLAS VANCAMPEN"     if state == "TX" & name == "TAYLOR, VAN"
replace name = "FLETCHER, LIZZIE PANNILL"       if state == "TX" & name == "FLETCHER, LIZZIE"
replace name = "BRADY, KEVIN P."                if state == "TX" & name == "BRADY, KEVIN"
replace name = "GREEN, ALEXANDER (AL)"          if state == "TX" & name == "GREEN, AL"
replace name = "SESSIONS, PETER A. (PETE)"      if state == "TX" & name == "SESSIONS, PETE"
replace name = "JACKSON LEE, SHEILA"            if state == "TX" & name == "LEE, SHEILA JACKSON"
replace name = "ARRINGTON, JODEY"               if state == "TX" & name == "ARRINGTON, JODEY C." // simplifying change


replace name = "CURTIS, JOHN R."                if state == "UT" & name == "CURTIS, JOHN" // 2018 to 2020
replace name = "OWENS, CLARENCE BURGESS"        if state == "UT" & name == "OWENS, BURGESS"
replace name = "MCADAMS, BENJAMIN MICHAEL (BEN)" if state == "UT" & name == "MCADAMS, BEN" // 2018 to 2020


replace name = "WITTMAN, ROBERT J. (ROB)"       if state == "VA" & name == "WITTMAN, ROBERT J."
replace name = "MCEACHIN, ASTON DONALD"         if state == "VA" & name == "MCEACHIN, A DONALD"
replace name = "CLINE, BENJAMIN LEE"            if state == "VA" & name == "CLINE, BEN" // 2018 to 2020
replace name = "SPANBERGER, ABIGAIL ANNE DAVIS" if state == "VA" & regexm(name, "SPANBERGER")
replace name = "GRIFFITH, H. MORGAN"            if state == "VA" & name == "GRIFFITH, H MORGAN" 
replace name = "WEXTON, JENNIFER T."            if state == "VA" & name == "WEXTON, JENNIFER"
replace name = "CONNOLLY, GERALD E. (GERRY)"    if state == "VA" & name == "CONNOLLY, GERALD E."


replace name = "THERON, DANIEL PETER"           if state == "WI" & name == "THERON, PETER"
replace name = "KIND, RONALD JAMES (RON)"       if state == "WI" & name == "KIND, RON"
replace name = "MOORE, GWENDOLYNNE S. (GWEN)"   if state == "WI" & name == "MOORE, GWEN"
replace name = "GROTHMAN, GLENN S."             if state == "WI"& name == "GROTHMAN, GLENN"


replace name = "MOONEY, ALEX X."                if state == "WV" & name == "MOONEY, ALEXANDER X."
replace name = "MILLER, CAROL"                  if state == "WV" & name == "MILLER, CAROL D."




* save
save data/intermediate/2020_ushouse_O-W.dta, replace
