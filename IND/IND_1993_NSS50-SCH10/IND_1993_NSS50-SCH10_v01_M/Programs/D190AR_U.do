
capture drop_all
capture label drop_all
set more off
set mem 200m
infix using "M:\PREM\Pinaki\NSS50_Sch10\D190AR_U.dct"

order hh_id hh_no prsn_no sector state region sex age act_no
sort hh_id
save "M:\PREM\Pinaki\NSS50_Sch10\D190AU.dta", replace
clear

/*****************/

use "M:\PREM\Pinaki\NSS50_Sch10\D190AR.dta", clear
append using "M:\PREM\Pinaki\NSS50_Sch10\D190AU.dta",	nolabel nonotes
sort hh_id prsn_no
save "M:\PREM\Pinaki\NSS50_Sch10\D190AR_U.dta", replace
clear
