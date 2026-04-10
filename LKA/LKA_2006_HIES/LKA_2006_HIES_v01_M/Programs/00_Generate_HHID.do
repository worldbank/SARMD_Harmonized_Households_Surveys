set more off
*===============================================================================
* PROJECT: SRI LANKA SCD
* Data: HIES 2012-13
* Date: 4th November 2014
* Author: Lidia Ceriani
* This dofile: Generate Household id for each sections
*===============================================================================
global dir  "C:\Users\wb436991\Box Sync\WB\SAR_Sri_Lanka\Data\HIES\HIES_2006_07\"
global data "${dir}\Data_original"
global out 	"${dir}\Data_processed"

*===============================================================================
* Generate Household ID in each file
*===============================================================================

local myfilelist : dir "$data" files "sec_*"
foreach file of local myfilelist{
cd "$data"
use "`file'", clear

cap drop hhid
* Generate HHID
*-------------------------------------------------------------------------------
gen sdist = string(district)
gen spsu = "00" + string(psu) if psu <10
replace spsu = "0" + string(psu) if psu >= 10 & psu <100
replace spsu = string(psu) if psu >= 100
gen ssamp = string( sample_n)
replace ssamp = "0" + string(sample_n) if sample_n <10
gen shhno = string( serial_no)
egen hhid = concat( sdist spsu ssamp shhno )
drop sdist spsu ssamp shhno
sort hhid
label var hhid "Household ID"

cd "$out"
save "`file'", replace
}
