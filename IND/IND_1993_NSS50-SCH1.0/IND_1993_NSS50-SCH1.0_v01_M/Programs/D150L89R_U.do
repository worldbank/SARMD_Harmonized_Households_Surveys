
/******************* Rural ********************/

capture drop_all
capture label drop_all
set more off
set mem 300m
infix using "M:\PREM\Pinaki\NSS50 (Sch1.0)\D150L89R.dct"

sort hhid
keep if level=="08"
keep if item==529|item==539|item==549|item==569|item==579|item==599|item==619|item==629|item==639|item==649

save "M:\PREM\Pinaki\NSS50 (Sch1.0)\D150L89R.dta", replace

clear

/******************* Urban ********************/

capture drop_all
capture label drop_all
set more off
set mem 300m
infix using "M:\PREM\Pinaki\NSS50 (Sch1.0)\D150L89U.dct"

sort hhid
keep if level=="08"
keep if item==529|item==539|item==549|item==569|item==579|item==599|item==619|item==629|item==639|item==649

save "M:\PREM\Pinaki\NSS50 (Sch1.0)\D150L89U.dta", replace

clear

*********************************

use "M:\PREM\Pinaki\NSS50 (Sch1.0)\D150L89R.dta", clear

append using "M:\PREM\Pinaki\NSS50 (Sch1.0)\D150L89U.dta", nolabel nonotes

save "M:\PREM\Pinaki\NSS50 (Sch1.0)\D150L89R_U.dta", replace
clear



