
capture drop_all
capture label drop_all
set more off
set mem 200m
infix using "M:\PREM\Pinaki\NSS50_Sch10\D190HR_U.dct"
sort hh_id
save "M:\PREM\Pinaki\NSS50_Sch10\D190HU.dta", replace
clear

/**************/

use "M:\PREM\Pinaki\NSS50_Sch10\D190HR.dta", clear
append using "M:\PREM\Pinaki\NSS50_Sch10\D190HU.dta",	nolabel nonotes
drop sub_smpl sub_rnd vlg_blck strtm2
order hh_id hh_no sector state region stratum
sort hh_id
save "M:\PREM\Pinaki\NSS50_Sch10\D190HR_U.dta", replace
clear
