clear all
set more off

use "D:\__I2D2\Bhutan\2003\BLSS\Original\SAR_OD\btn2003_ori.dta" 
bys ihsn_no hid: keep if _n==1

save "D:\__I2D2\Bhutan\2003\BLSS\Other\btn2003_ori_2.dta", replace

use "D:\__I2D2\Bhutan\2003\BLSS\Original\SAR_OD\btn2003_hld.dta"

merge 1:1 ihsn_no hid using "D:\__I2D2\Bhutan\2003\BLSS\Other\btn2003_ori_2.dta"

tostring ori_hid, gen(idh)
sort idh



gen pce_real1=tocon_de/(12*hhsize)
gen pce_real2=tocon_nd/(12*hhsize)
gen pce_real3=cons_tot/(12*hhsize)


keep idh stratum psu reg_defl pce_real* wta_hh wta_pop

save "D:\__I2D2\Bhutan\2003\BLSS\Other\pcc.dta", replace
