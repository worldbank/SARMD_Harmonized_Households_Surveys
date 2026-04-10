capture drop_all
capture label drop_all
set more off
set mem 300m
infix using "M:\PREM\Pinaki\NSS50_Sch1\D671014R_U.dct"

keep if level==10
sort hh_id
save "M:\PREM\Pinaki\NSS50_Sch1\D671014U.dta", replace
clear

use "M:\PREM\Pinaki\NSS50_Sch1\D671014R.dta", clear
append using "M:\PREM\Pinaki\NSS50_Sch1\D671014U.dta"
sort hh_id
save "M:\PREM\Pinaki\NSS50_Sch1\D671014R_U.dta", replace
clear

