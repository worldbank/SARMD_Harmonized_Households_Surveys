set more off
*===============================================================================
* PROJECT: SRI LANKA SCD
* Data: HIES 2012-13
* Date: 4th November 2014
* Author: Lidia Ceriani
* This dofile: Generate Household id for each sections
*===============================================================================
global dir  "C:\Users\wb436991\Box Sync\WB\SAR_Sri_Lanka\Data\HIES\HIES_2001_02\"
global data "${dir}\Data_original\raw_2001_02"
global out 	"${dir}\Data_original"

*===============================================================================
* Generate Household ID in each file
*===============================================================================

local myfilelist : dir "$data" files "tem*"
foreach file of local myfilelist{
cd "$data"
use "`file'", clear

* Generate District
*-------------------------------------------------------------------------------
gen prov_s = string(prov)
gen district_s = string(dist)
egen district = concat(prov_s district_s)
destring district, replace	
drop *_s
drop dist

cd "$out"
save "`file'", replace
}

use "${out}\tem_r1"
save"${out}\Section_1", replace
use "${out}\tem_r2"
save"${out}\Section_f02", replace
use "${out}\tem_r3"
save"${out}\Section_21", replace
use "${out}\tem_r4" 
save"${out}\Section_22", replace
use "${out}\tem_r5"
save"${out}\Section_23_filter", replace
use "${out}\tem_r6" 
save"${out}\Section_23", replace
use "${out}\tem_r7" 
save"${out}\Section_31", replace
use "${out}\tem_r8" 
save"${out}\Section_32", replace
use "${out}\tem_r9" 
save"${out}\Section_33_filter", replace
use "${out}\tem_r10" 
save"${out}\Section_33", replace
use "${out}\tem_r11" 
save"${out}\Section_34_filter", replace
use "${out}\tem_r12" 
save"${out}\Section_34", replace
use "${out}\tem_r13" 
save"${out}\Section_35_filter", replace
use "${out}\tem_r14" 
save"${out}\Section_35", replace
use "${out}\tem_r15" 
save"${out}\Section_36_filter", replace
use "${out}\tem_r16" 
save"${out}\Section_36", replace
use "${out}\tem_r17" 
save"${out}\Section_37", replace

local myfilelist : dir "$out" files "tem*"
foreach file of local myfilelist{
cd "$out"
rm "`file'"
}
