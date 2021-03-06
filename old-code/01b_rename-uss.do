use ${js_2020_init}, clear

keep if office == "S"

* in Alabama, neither Tuberville and Doug Jones were in the 2006-2018 dataset. 
*  we therefore do not touch these new candidates

replace name = "SULLIVAN, DANIEL S. (DAN)"    if state == "AK" & name == "SULLIVAN, DAN"

replace name = "MCSALLY, MARTHA E."           if state == "AZ" & name == "MCSALLY, MARTHA"

replace name = "COTTON, THOMAS (TOM)"         if state == "AR" & name == "COTTON, TOM"

replace name = "HICKENLOOPER, JOHN W."           if state == "CO" & name == "HICKENLOOPER, JOHN W." // SAME

replace name = "COLLINS, DOUGLAS ALLEN (DOUG)" if state == "GA" & name == "COLLINS, DOUG"
replace name = "PERDUE, DAVID A."              if state == "GA" & name == "PERDUE, DAVID"
* why is JON OSSOFF not in the original data?


replace name = "RISCH, JAMES E. (JIM)"        if state == "ID" & name == "RISCH, JAMES E."

replace name = "DURBIN, RICHARD J. (DICK)"    if state == "IL" & name == "DURBIN, RICHARD J."

replace name = "MCCONNELL, MITCH, JR."        if state == "KY" & name == "MCCONNELL, MITCH"

replace name = "CASSIDY, WILLIAM (BILL)"      if state == "LA" & name == "CASSIDY, BILL"

replace name = "MARKEY, EDWARD JOHN (ED)"     if state == "MA" & name == "MARKEY, EDWARD J."


* watch for john james -- how was he coded in 2018

replace name = "DAINES, STEVEN (STEVE)"       if state == "MT" & name == "DAINES, STEVE"

replace name = "BOOKER, CORY"                 if state == "NJ" & name == "BOOKER, CORY A."

replace name = "LUJAN, BEN RAY, JR."          if  state == "NM" & regexm(name, "BEN RAY")

replace name = "INHOFE, JAMES M. (JIM)"       if state == "OK" & name == "INHOFE, JAMES M."

replace name = "MERKLEY, JEFFERY A. (JEFF)"   if state == "OR" & name == "MERKLEY, JEFF"

replace name = "REED, JOHN F. (JACK)"         if state == "RI" & name == "REED, JACK"

replace name = "GRAHAM, LINDSEY O."           if state == "SC" & name == "GRAHAM, LINDSEY"

replace name = "ROUNDS, MICHAEL (MIKE)"       if state == "SD" & name == "ROUNDS, MIKE"

* and special character example

replace name = "HEGAR, MARY JENNINGS (MJ)"    if state == "TX" & name == "HEGAR, MARY (MJ)"
replace name = "CORNYN, JOHN, III"            if state == "TX" & name == "CORNYN, JOHN"

replace name = "LUMMIS, CYNTHIA MARIE"        if state == "WY" & name == "LUMMIS, CYNTHIA M."


* save
save data/intermediate/2020_ussenate.dta, replace
