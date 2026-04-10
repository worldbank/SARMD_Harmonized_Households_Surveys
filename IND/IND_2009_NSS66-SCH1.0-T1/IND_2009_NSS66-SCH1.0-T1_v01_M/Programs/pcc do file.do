clear
set mem 600m
set more off

local path "C:\Users\wb461263\Dropbox\SAR\SAR2D2\India\NSS_Sch1\2009\Dta\Raw\Constructed"

use "`path'\poverty66.dta", clear

keep hhid sector district hhsize mpce_mrp mpce_urp pline poor pwt pline_ind_09

su pline_ind_09 [w=pwt]
gen pline_mrp=r(mean)

gen mpce_mrp_real=mpce_mrp*pline_mrp/pline

sort hhid

format hhid %9.0f

gen pline_urp_sector=.
replace pline_urp_sector=641.4 if sector==1
replace pline_urp_sector=931.2 if sector==2

su pline_urp_sector [w=pwt]
gen pline_urp=r(mean)

gen mpce_urp_real=mpce_urp*(pline_urp/pline_urp_sector)
la var mpce_urp_real "Real PC Monthly Consumption (URP)"
ren pline_ind_09 pline_mrp_sector

keep hhid mpce_urp_real mpce_mrp_real mpce_mrp pline_urp pline_mrp pline_urp_sector pline_mrp_sector pline pwt

order hhid mpce_urp_real mpce_mrp_real mpce_mrp pline_urp pline_mrp pline_urp_sector pline_mrp_sector pline pwt

save "`path'\pcc66.dta", replace
/*
