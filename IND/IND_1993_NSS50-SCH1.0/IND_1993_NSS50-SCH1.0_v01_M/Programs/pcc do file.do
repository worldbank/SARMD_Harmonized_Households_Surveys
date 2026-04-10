clear
set mem 600m
set more off

local path "D:\__I2D2\India\1993\NSS_SCH1"

use "`path'\Original\Dta\constructed\poverty50.dta", clear

keep hhid sector hhsize mpce_mrp mpce_urp pline poor pwt pline_ind_93

su pline_ind_93 [w=pwt]
gen pline_mrp=r(mean)

gen mpce_mrp_real=mpce_mrp*pline_mrp/pline

sort hhid
generate idh=string(hhid, "%15.0f")

gen pline_urp_sector=.
replace pline_urp_sector=236.6 if sector==1
replace pline_urp_sector=318.2 if sector==2

su pline_urp_sector [w=pwt]
gen pline_urp=r(mean)

gen mpce_urp_real=mpce_urp*(pline_urp/pline_urp_sector)
la var mpce_urp_real "Real PC Monthly Consumption (URP)"
ren pline_ind_93 pline_mrp_sector

keep idh mpce_urp_real mpce_mrp_real pline_urp pline_mrp pline_urp_sector pline_mrp_sector pline pwt

order idh mpce_urp_real mpce_mrp_real pline_urp pline_mrp pline_urp_sector pline_mrp_sector pline pwt

sort idh

save "`path'\Others\pcc50.dta", replace
/*
