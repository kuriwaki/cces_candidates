cd "~/Dropbox/cces_candidates/"


use "~/Dropbox/CCES_candidates_Dropbox/Input/from-snyder/2021-06-19_election_results_2020_pres_house_ussen.dta", clear


replace name = "BIDEN, JOSEPH R., JR." if office == "P" & name == "DEMOCRATIC"
replace name = "TRUMP, DONALD J." if office == "P" & name == "REPUBLICAN"
replace name = "JORGENSEN, JO" if office == "P" & name == "LIBERTARIAN"
