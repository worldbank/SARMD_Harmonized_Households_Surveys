/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   `code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'_IDN.do	</_Program name_>
<_Application_>    STATA 16.0	<_Application_>
<_Author(s)_>      Navishti Das and Javier Parada	</_Author(s)_>
<_Date created_>   03-03-2019	</_Date created_>
<_Date modified>   15 Jun 2020	</_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        AFG	</_Country_>
<_Survey Title_>   LCS	</_Survey Title_>
<_Survey Year_>    2016	</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:	06-24-2020
File:	`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'_IDN.do
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
local va           "03"
local type         "SARMD"
global module       	"IDN"
local yearfolder    "`code'_`year'_`survey'"
local SARMDfolder    "`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'"
local filename      "`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'_${module}"
glo output          "${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\\Data\Harmonized" 
*</_Program setup_>

* global path on Joe's computer
if ("`c(username)'"=="sunquat") {
	glo basepath "/Users/`c(username)'/Projects/WORLD BANK/2023 SAR QCHECK/SARDATABANK/WORKINGDATA/`code'/`yearfolder'"
	glo input "${basepath}/`yearfolder'_v`vm'_M"
	glo output "${basepath}/`yearfolder'_v`vm'_M_v`va'_A_SARMD/Data/Harmonized"
	
	* load and merge relevant data
	cd "${input}/Data/Stata"
	* input data
	use "${output}/`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD_IND", clear
}
* global paths on WB computer
else {
	*<_Folder creation_>
	cap mkdir "${rootdatalib}"
	cap mkdir "${rootdatalib}\\`code'"
	cap mkdir "${rootdatalib}\\`code'\\`yearfolder'"
	cap mkdir "${rootdatalib}\\`code'\\`yearfolder'\\`gmdfolder'"
	cap mkdir "${rootdatalib}\\`code'\\`yearfolder'\\`gmdfolder'\Data"
	cap mkdir "${rootdatalib}\\`code'\\`yearfolder'\\`gmdfolder'\Data\Harmonized"
	*</_Folder creation_>
	
	*<_Datalibweb request_>
	*datalibweb, country(`code') year(`year') type(`type') survey(`survey') vermast(`vm') veralt(`va') mod(IND) clear localpath(${rootdatalib}) local
	use "${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\Data\Harmonized\\`yearfolder'_v`vm'_M_v`va'_A_`type'_IND.dta" , clear 
	*</_Datalibweb request_>
}

*<_countrycode_>
*<_countrycode_note_> country code *</_countrycode_note_>
*<_countrycode_note_> countrycode brought in from SARMD *</_countrycode_note_>
*countrycode
*</_countrycode_>

*<_year_>
*<_year_note_> Year *</_year_note_>
*<_year_note_> year brought in from SARMD *</_year_note_>
*year
*</_year_>

*<_int_year_>
*<_int_year_note_> interview year *</_int_year_note_>
*<_int_year_note_> int_year brought in from SARMD *</_int_year_note_>
*int_year
*</_int_year_>

*<_int_month_>
*<_int_month_note_> interview month *</_int_month_note_>
*<_int_month_note_> int_month brought in from SARMD *</_int_month_note_>
cap gen int_month=.
*</_int_month_>

*<_hhid_>
*<_hhid_note_> Household identifier  *</_hhid_note_>
*<_hhid_note_> hhid brought in from SARMD *</_hhid_note_>
cap clonevar hhid = idh
*</_hhid_>

*<_hhid_orig_>
*<_hhid_orig_note_> Household identifier in the raw data  *</_hhid_orig_note_>
*<_hhid_orig_note_> hhid_orig brought in from rawdata *</_hhid_orig_note_>
gen hhid_orig = ""
*</_hhid_orig_>

*<_pid_>
*<_pid_note_> Personal identifier  *</_pid_note_>
*<_pid_note_> pid brought in from rawdata *</_pid_note_>
cap clonevar pid  = idp
*</_pid_>

*<_pid_orig_>
*<_pid_orig_note_> Personal identifier in the raw data  *</_pid_orig_note_>
*<_pid_orig_note_> pid_orig brought in from rawdata *</_pid_orig_note_>
gen pid_orig= ""
*</_pid_orig_>

*<_variable name in raw data_>
*<_variable name in raw data_note_> Variables used to construct Household identifier  *</_variable name in raw data_note_>
*<_variable name in raw data_note_> variable name in raw data brought in from rawdata *</_variable name in raw data_note_>
*
*</_variable name in raw data_>

*<_variable name in raw data_>
*<_variable name in raw data_note_> Variables used to construct Personal identifier  *</_variable name in raw data_note_>
*<_variable name in raw data_note_> variable name in raw data brought in from rawdata *</_variable name in raw data_note_>
*
*</_variable name in raw data_>

*<_weight_>
*<_weight_note_> Household weight *</_weight_note_>
*<_weight_note_> weight brought in from rawdata *</_weight_note_>
clonevar  weight = wgt
*</_weight_>

*<_weighttype_>
*<_weighttype_note_> Weight type (frequency, probability, analytical, importance) *</_weighttype_note_>
*<_weighttype_note_> weighttype brought in from rawdata *</_weighttype_note_>
*gen weighttype = "PW"
*</_weighttype_>

*<_Keep variables_>
*keep countrycode year int_year int_month hhid hhid_orig pid pid_orig weight weighttype
order countrycode year hhid pid weight weighttype
sort hhid pid 
*</_Keep variables_>

*<_Save data file_>
if ("`c(username)'"=="sunquat") global rootdofiles "/Users/`c(username)'/Projects/WORLD BANK/2023 SAR QCHECK/SARDATABANK/SARMDdofiles"
quietly do "$rootdofiles/_aux/Labels_GMD2.0.do"
save "$output/`filename'.dta", replace
*</_Save data file_>
