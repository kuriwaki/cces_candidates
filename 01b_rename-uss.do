cd "~/Dropbox/cces_candidates/"


use "~/Dropbox/CCES_candidates_Dropbox/Input/from-snyder/2021-06-19_election_results_2020_pres_house_ussen.dta", clear



replace name = "SULLIVAN, DANIEL S. (DAN)" if office == "S" & name == "SULLIVAN, DAN"
