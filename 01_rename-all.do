cd "~/Dropbox/cces_candidates/"

use "~/Dropbox/CCES_candidates_Dropbox/Input/from-snyder/2021-06-19_election_results_2020_pres_house_ussen.dta", clear


do 01a_rename-prez.do 
do 01b_rename-uss.do
do 01c_rename-ush-A-M.R
do 01d_rename-ush-O-W.do 

