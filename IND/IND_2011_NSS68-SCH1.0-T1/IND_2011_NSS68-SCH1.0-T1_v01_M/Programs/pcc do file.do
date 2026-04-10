clear
set mem 600m
set more off

local path "D:\__I2D2\India\2011\NSS_SCH1"

use "`path'\Others\poverty68.dta", clear

/*
drop if mpce_urp==.
drop if mpce_urp==0
*/

*REAL CONSUMPTION IN 2011-12 ALL INDIA RURAL/URBAN RUPEES accordingly
gen real_mpce111=mpce_mrp*(pline_ind_11/pline)
la var real_mpce111 "Real-PC Monthly Cons-in Urb/Rural Rupees"

* WEIGHTED AVERAGE POVERTY LINE
qui su pline_ind_11 [aw=pwt]
gen pline_mrp=r(mean)
* 868.57233

* SPATIALY DEFLATED CONSUMPTION VARIABLE (TO NATIONAL)
gen mpce_mrp_real=real_mpce111*(pline_mrp/pline_ind_11)
la var mpce_mrp_real "Real PC Monthly Consumption (MRP)"
*/
sort hhid
ren hhid ID

format ID %9.0f

gen pline_urp_sector=.
replace pline_urp_sector=763.9 	if sector==1
replace pline_urp_sector=1114.0	if sector==2

su pline_urp_sector [w=pwt]
gen pline_urp=r(mean)

gen mpce_urp_real=mpce_urp*(pline_urp/pline_urp_sector)
la var mpce_urp_real "Real PC Monthly Consumption (URP)"
ren pline_ind_11 pline_mrp_sector
keep ID mpce_urp_real mpce_mrp_real pline_urp pline_mrp pline_urp_sector pline_mrp_sector pline pwt

order ID mpce_urp_real mpce_mrp_real pline_urp pline_mrp pline_urp_sector pline_mrp_sector pline pwt

save "`path'\Others\pcc68.dta", replace
/*
* TABULATIONS

gen poor=1 if mpce_mrp_real<pline_mrp & mpce_mrp_real!=.
replace poor=0 if mpce_mrp_real>=pline_mrp & mpce_mrp_real!=.

* Mine
gen poor_1=(real_mpce111<pline_ind_11)
gen poor_2=(real_pcc<pline_ind)

tab state sector [aw=pwt], sum(poor_1) nost noo nofr
tab state sector [aw=pwt], sum(poor_2) nost noo nofr

* Yours
tab state sector [aw=pwt], sum(poor) nost noo nofr
*/
