/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   `code'_`year'_`survey'_v01_M_v01_A_GMD_COR.do	</_Program name_>
<_Application_>    STATA 16.0	<_Application_>
<_Author(s)_>      acastillocastill@worldbank.org	</_Author(s)_>
<_Date created_>   05-25-2021	</_Date created_>
<_Date modified>   09-08 2021	</_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        `code'	</_Country_>
<_Survey Title_>   `survey'	</_Survey Title_>
<_Survey Year_>    `year'	</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:	05-25-2020
File:	`code'_`year'_`survey'_v01_M_v01_A_`type'_COR.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>
clear all
set more off

local code         "AFG"
local year         "2016"
local survey       "LCS"
local vm           "01"
local va           "02"
local type         "SARMD"
local yearfolder   "`code'_`year'_`survey'"
glo output         "${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata"
*</_Program setup_>


*<_Folder creation_>
/*cap mkdir "${rootdatalib}"
cap mkdir "${rootdatalib}\\`code'"
cap mkdir "${rootdatalib}\\`code'\\`yearfolder'"
cap mkdir "${rootdatalib}\\`code'\\`yearfolder'\\`gmdfolder'"
cap mkdir "${rootdatalib}\\`code'\\`yearfolder'\\`gmdfolder'\Data"
cap mkdir "${rootdatalib}\\`code'\\`yearfolder'\\`gmdfolder'\Data\Harmonized"
*/
*</_Folder creation_>

	
*<_Datalibweb request_>
*<_Raw data_>
foreach f in "H_02" "H_03" "H_04_10" "H_11" "H_24" "h_04_10" "H_12" {
	*datalibweb, country(AFG) year(2016) type(SARRAW) surveyid(`code'_`year'_`survey'_v`vm'_M) filename(`f'.dta) localpath(${rootdatalib}) local
	use "${rootdatalib}\\`code'\\`code'_`year'_`survey'\\`code'_`year'_`survey'_v`vm'_M\Data\Stata\\`f'.dta", clear 
	tempfile t`f'
	save `t`f'', replace
}
*datalibweb, country(AFG) year(2016) type(SARRAW) surveyid(`code'_`year'_`survey'_v`vm'_M) filename(H_01) localpath(${rootdatalib}) local
use "${rootdatalib}\\`code'\\`code'_`year'_`survey'\\`code'_`year'_`survey'_v`vm'_M\Data\Stata\H_01.dta", clear
*</_Raw data_>
merge 1:1 hh_id using `tH_02'
drop _merge
merge 1:m hh_id using `tH_03'
drop _merge
merge m:1 hh_id using `tH_04_10'
drop _merge
merge 1:1 ind_id using `tH_11'
drop _merge
merge 1:1 ind_id using `tH_24'
drop _merge
merge 1:1 ind_id using `tH_12'
drop _merge
clonevar hhid=hh_id
tempfile temp
save `temp', replace

use "${rootdatalib}\\`code'\\`code'_`year'_`survey'\\`code'_`year'_`survey'_v`vm'_M\Data\Stata\temp_pov_2016_2019_consolidated.dta", clear 
keep if year==`year'
drop year
merge 1:m hhid using `temp'
*</_Datalibweb request_>
	

*<_Save data file_>
compress
if ("`c(username)'"=="dekopon") save "${output}/`yearfolder'_M.dta", replace
else save "${output}/`yearfolder'_M.dta" , replace
*</_Save data file_>
