cd "~/Dropbox/cces_candidates/"


use "~/Dropbox/CCES_candidates_Dropbox/Input/from-snyder/2021-06-19_election_results_2020_pres_house_ussen.dta", clear




* in Alabama, neither Tuberville and Doug Jones were in the 2006-2018 dataset. 
*  we therefore do not touch these new candidates


keep if office == "S"
replace name = "SULLIVAN, DANIEL S. (DAN)" if state == "AK" & name == "SULLIVAN, DAN"
replace name = "MCSALLY, MARTHA E." if state == "AZ" & name == "MCSALLY, MARTHA"
replace name = "COTTON, THOMAS (TOM)" if state == "AR" & name == "COTTON, TOM"
replace name = "HICKENLOOPER, JOHN" if state == "CO" & name == "HICKENLOOPER, JOHN W." // this is a simplifying change but it follows older candidate dataset
replace  state == "CO" & name == "GARDNER, CORY" 




replace name = "COLLINS, DOUGLAS ALLEN (DOUG)" if state == "GA" & name == "COLLINS, DOUG"
* why is JON OSSOFF not in the original data?
replace name = "PERDUE, DAVID A." if state == "GA" & name == "PERDUE, DAVID"
