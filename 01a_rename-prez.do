cd "~/Dropbox/cces_candidates/"


use "~/Dropbox/CCES_candidates_Dropbox/Input/from-snyder/2021-06-19_election_results_2020_pres_house_ussen.dta", clear

keep if office ==  "P"

replace name = "BIDEN, JOSEPH R., JR." if name == "DEMOCRATIC"
replace name = "TRUMP, DONALD J."      if name == "REPUBLICAN"
replace name = "JORGENSEN, JO"         if name == "LIBERTARIAN"


save intermediate/2020_uspresident, replace
