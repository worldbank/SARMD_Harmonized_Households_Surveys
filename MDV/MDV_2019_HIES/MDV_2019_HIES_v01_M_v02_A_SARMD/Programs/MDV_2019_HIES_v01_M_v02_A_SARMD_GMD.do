/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   `code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'_COR.do	</_Program name_>
<_Application_>    STATA 16.0	<_Application_>
<_Author(s)_>      	</_Author(s)_>
<_Date created_>   	</_Date created_>
<_Date modified>   	</_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        MDV	</_Country_>
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

local code         "MDV"
local year         "2019"
local survey       "HIES"
local vm           "01"
local va           "02"
local type         "SARMD"
local yearfolder   "`code'_`year'_`survey'"
local gmdfolder    "`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'"
local filename     "`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'_GMD"
*</_Program setup_>
glo harmonized "${rootdatalib}\\`code'\\`yearfolder'\\`gmdfolder'\Data\Harmonized"
*</_Merge file_>
*Merge files
use "${harmonized}\\`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD_IDN.dta", clear
noi di "`mod'"
sort hhid pid
local mods COR GEO DEM LBR DWL UTL
foreach mod of local mods {
    sort hhid pid
	if (inlist("`mod'","COR", "DEM", "LBR", "GEO", "DWL", "UTL")) {
	merge 1:1 hhid pid using "${harmonized}\\`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD_`mod'.dta", gen(`mod')
	}
	if (inlist("`mod'", "XXX" )) {
	merge m:1 hhid using "${harmonized}\\`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD_`mod'.dta", gen(`mod')
    }
    noi di "`mod'"
	tab `mod'    
}

*</_Merge file_>

*</_Save data file_>
glo module="GMD"
do "${rootdatalib}/`code'/`yearfolder'/`yearfolder'_v`vm'_M_v`va'_A_SARMD/Programs/Labels_GMD2.0.do"
compress
 save "${rootdatalib}\\`code'\\`yearfolder'\\`gmdfolder'\Data\Harmonized\\`filename'.dta" , replace
*</_Save data file_>
