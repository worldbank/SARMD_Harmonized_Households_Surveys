set more off
*===============================================================================
* PROJECT: SRI LANKA SCD
* Data: HIES 2012-13
* Date: 14th October 2014
* Author: Lidia Ceriani
* This dofile: Import original data in .csv and save it in .dta
*===============================================================================
* Define Directories
global dir "C:\Users\wb436991\Box Sync\WB\SAR_Sri_Lanka\Data\HIES\HIES_2012_13"
global out "${dir}\Data_dta"
local myfilelist : dir "$dir\Data_csv" files "sec_*"

foreach file of local myfilelist{
cd "$dir\Data_csv"
di "`file'"
import delimited "`file'", clear
cd "$dir\Data_dta"
local subfile = subinstr("`file'", ".csv", ".dta", 1)
!rename "`file'" "`subfile'"
save "`subfile'", replace
}

import delimited  "${dir}\Data_csv\weights201213HIES.csv", clear
save "${dir}\Data_dta\weights201213HIES.dta", replace
