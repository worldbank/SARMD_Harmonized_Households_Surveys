clear
set mem 600m
set more off

local path "D:\__I2D2\India\2004\NSS_SCH1"

use "`path'\Original\Dta\constructed\poverty61.dta", clear

keep hhid sector district hhsize mpce_mrp a16 pline poor pwt pline_ind_04

su pline_ind_04 [w=pwt]
gen pline_mrp=r(mean)

gen mpce_mrp_real=mpce_mrp*pline_mrp/pline

sort hhid
destring hhid, gen(ID)

format ID %9.0f

gen pline_urp_sector=.
replace pline_urp_sector=425.1 if sector==1
replace pline_urp_sector=641.4 if sector==2

su pline_urp_sector [w=pwt]
gen pline_urp=r(mean)

destring a16, gen(mpce_urp_100)
gen mpce_urp=mpce_urp_100/(100*hhsize)

gen mpce_urp_real=mpce_urp*(pline_urp/pline_urp_sector)
la var mpce_urp_real "Real PC Monthly Consumption (URP)"
ren pline_ind_04 pline_mrp_sector

keep ID mpce_urp_real mpce_mrp_real pline_urp pline_mrp pline_urp_sector pline_mrp_sector pline pwt

order ID mpce_urp_real mpce_mrp_real pline_urp pline_mrp pline_urp_sector pline_mrp_sector pline pwt

save "`path'\Others\pcc61.dta", replace
/*
