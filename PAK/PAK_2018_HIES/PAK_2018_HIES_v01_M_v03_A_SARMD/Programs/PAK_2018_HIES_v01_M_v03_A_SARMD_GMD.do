/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   `code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'_COR.do	</_Program name_>
<_Application_>    STATA 16.0	<_Application_>
<_Author(s)_>      	</_Author(s)_>
<_Date created_>   	</_Date created_>
<_Date modified>   	</_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        LKA	</_Country_>
<_Survey Title_>   HIES	</_Survey Title_>
<_Survey Year_>    2019	</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:	
File:	`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'_COR.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>
clear all
set more off

local code         "PAK"
local year         "2018"
local survey       "HIES"
local vm           "01"
local va           "03"
local type         "SARMD"
global module       	"GMD"
local yearfolder    "`code'_`year'_`survey'"
local SARMDfolder    "`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'"
local filename      "`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'_${module}"
glo output          "${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\\Data\Harmonized" 
*</_Program setup_>


* global path on Joe's computer
if ("`c(username)'"=="sunquat") {
	glo harmonized "/Users/`c(username)'/Projects/WORLD BANK/2023 SAR QCHECK/SARDATABANK/WORKINGDATA/`code'/`yearfolder'/`gmdfolder'/Data/Harmonized"
	glo rootdatalib "/Users/`c(username)'/Projects/WORLD BANK/2023 SAR QCHECK/SARDATABANK/WORKINGDATA"
}
* global paths on WB computer
else {
	*</_Program setup_>
	glo harmonized "${rootdatalib}/`code'/`yearfolder'/`gmdfolder'/Data/Harmonized"
	
}

*</_Merge file_>
*Merge files
use "${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\Data\Harmonized\\`yearfolder'_v`vm'_M_v`va'_A_`type'_IND.dta" , clear 
noi di "`mod'"
sort hhid pid
local mods COR GEO DEM LBR DWL UTL 
foreach mod of local mods {
    sort hhid pid
	if (inlist("`mod'","COR", "DEM", "LBR")) {
	merge 1:1 hhid pid using "${harmonized}/`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD_`mod'.dta", gen(`mod')
	}
	if (inlist("`mod'","GEO", "DWL", "UTL")) {
	merge m:1 hhid pid using "${harmonized}/`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD_`mod'.dta", gen(`mod')
    }
    noi di "`mod'"
	tab `mod'    
}

*</_Merge file_>
*<_Save data file_>
save "$output\\`filename'.dta", replace
*</_Save data file_>
