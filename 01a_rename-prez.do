use ${js_2020_init}, clear

keep if office ==  "P"

replace name = "BIDEN, JOSEPH R., JR." if name == "DEMOCRATIC"
replace name = "TRUMP, DONALD J."      if name == "REPUBLICAN"
replace name = "JORGENSEN, JO"         if name == "LIBERTARIAN"


save data/intermediate/2020_uspresident, replace
