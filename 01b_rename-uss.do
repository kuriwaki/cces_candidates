cd "~/Dropbox/cces_candidates/"


use "~/Dropbox/CCES_candidates_Dropbox/Input/from-snyder/2021-06-19_election_results_2020_pres_house_ussen.dta", clear




* in Alabama, neither Tuberville and Doug Jones were in the 2006-2018 dataset. 
*  we therefore do not touch these new candidates

replace name = "SULLIVAN, DANIEL S. (DAN)" if office == "S" & name == "SULLIVAN, DAN"
replace name = "MCSALLY, MARTHA E." if office == "S" & name == "MCSALLY, MARTHA"
replace name = "COTTON, THOMAS (TOM)" if office == "S" & name == "COTTON, TOM"
replace name = "HICKENLOOPER, JOHN" if office == "S" & name == "HICKENLOOPER, JOHN W." // this is a simplifying change but it follows older candidate data
