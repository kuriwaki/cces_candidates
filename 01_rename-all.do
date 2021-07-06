if (c(username) == "shirokuriwaki") {
	cd "~/Dropbox/cces_candidates/"
	global js_2020_init "~/Dropbox/CCES_candidates_Dropbox/Input/from-snyder/2021-06-19_election_results_2020_pres_house_ussen.dta"
}

if (c(username) == "jeremiahcha") {
	cd "~/Dropbox/cces_candidates/"
	global js_2020_init "/Users/jeremiahcha/Dropbox/from-snyder.dta"
}

	
run 01a_rename-prez.do
run 01b_rename-uss.do
run 01c_rename-ush-A-N.do
run 01d_rename-ush-O-W.do


use          data/intermediate/2020_uspresident.dta, clear
append using data/intermediate/2020_ussenate.dta
append using data/intermediate/2020_ushouse_A-N.dta
append using data/intermediate/2020_ushouse_O-W.dta


save release/2020_uspresident-congress.dta, replace
