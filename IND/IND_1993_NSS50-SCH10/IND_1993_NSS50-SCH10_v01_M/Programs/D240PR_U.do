
capture drop_all
capture label drop_all
set more off
set mem 200m
infix using "M:\PREM\Pinaki\NSS50_Sch10\D240PR_U.dct"

order hh_id hh_no prsn_no sector state region
sort hh_id
save "M:\PREM\Pinaki\NSS50_Sch10\D240PU.dta", replace
clear

/*********/

use "M:\PREM\Pinaki\NSS50_Sch10\D240PR.dta", clear
append using "M:\PREM\Pinaki\NSS50_Sch10\D240PU.dta",	nolabel nonotes
sort hh_id prsn_no
save "M:\PREM\Pinaki\NSS50_Sch10\D240PR_U.dta", replace
clear
