cd "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\MDV\MDV_2016_HIES\MDV_2016_HIES_v01_M\Data\Stata\"

local filenames : dir "." files "*.dta"
foreach b of local filenames{
display "`b'"
use `b', clear
sum, sep(0)
}

x
use "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\MDV\MDV_2016_HIES\MDV_2016_HIES_v01_M\Data\Stata\F3-Q12-Q23.dta"

egen tag=tag(Form_ID)
tab Atoll if tag==1
gen urb=0
replace urb=1 if Atoll=="Male" 
tab urb if tag==1
x

* 4,910 households
* 26,025 individuals

use "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\MDV\MDV_2016_HIES\MDV_2016_HIES_v01_M\Data\Stata\F4.dta", clear 
