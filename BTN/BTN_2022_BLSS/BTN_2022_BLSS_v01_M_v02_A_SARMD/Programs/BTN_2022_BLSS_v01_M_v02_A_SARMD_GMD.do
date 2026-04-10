/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   BTN_2022_BLSS_v01_M_v01_A_SARMD_GMD.do	</_Program name_>
<_Application_>    STATA 16.0	<_Application_>
<_Author(s)_>      jogreen@worldbank.org	</_Author(s)_>
<_Date created_>   11-28-2022	</_Date created_>
<_Date modified>   11-28-2022	</_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        BTN	</_Country_>
<_Survey Title_>   BLSS	</_Survey Title_>
<_Survey Year_>    2022	</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:	11-28-2022
File:	BTN_2022_BLSS_v01_M_v01_A_SARMD_IDN.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>
clear all
set more off

local code         "BTN"
local year         "2022"
local survey       "BLSS"
local vm           "01"
local va           "01"
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
	noi di "`mod'"
    sort hhid pid
	sum hhid pid
	if (inlist("`mod'","COR", "DEM", "LBR")) {
	merge 1:1 hhid pid using "${harmonized}\\`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD_`mod'.dta", gen(`mod')
	}
	if (inlist("`mod'","GEO", "DWL", "UTL")) {
	merge m:1 hhid using "${harmonized}\\`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD_`mod'.dta", gen(`mod')
    }
    
	tab `mod'    
}
	* Define svy
	svyset,clear
	bys strata: egen hh_stratum=sum(weights)
	replace hh_stratum=round(hh_stratum)
	gen one=1
	bys strata: egen hhs_stratum=sum(one)
	gen fpc1=((hh_stratum-hhs_stratum)/(hh_stratum-1))^1/2
	svyset psu [pw=weight], strata(strata) fpc(fpc1) || hhid 

*</_Merge file_>

*</_Save data file_>
 save "${rootdatalib}\\`code'\\`yearfolder'\\`gmdfolder'\Data\Harmonized\\`filename'.dta" , replace
*</_Save data file_>
