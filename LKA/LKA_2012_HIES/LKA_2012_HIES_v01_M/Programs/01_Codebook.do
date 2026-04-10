set more off

*===============================================================================
* PROJECT: SRI LANKA SCD
* Data: HIES 2012-13
* Date: 4th November 2014
* Author: Lidia Ceriani
* This dofile: Codebook of 2012/13 Data
*===============================================================================
* Define Directories
global dir "C:\Users\wb436991\Box Sync\WB\SAR_Sri_Lanka\Data\HIES\HIES_2012_13"
global out "${dir}\Data_processed\codebook"
local myfilelist : dir "$dir\Data_dta" files "sec_*"

cap log close
log using "${out}\HIES_2012_13_codebook.txt", text replace 

foreach file of local myfilelist{
cd "${dir}\Data_dta"
di in red "========================================================================================================================"
di in red "`file'"
di in red "========================================================================================================================"
use "`file'" , clear
codebook 
}
log close
