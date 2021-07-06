cd "~/Dropbox/cces_candidates/"

run 01a_rename-prez.do
run 01b_rename-uss.do
run 01d_rename-ush-O-W.do


use intermediate/2020_uspresident.dta, clear
append using intermediate/2020_ussenate
append using intermediate/2020_ushouse_O-W.dta
