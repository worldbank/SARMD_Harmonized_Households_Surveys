/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   BTN_2022_BLSS_v01_M_v01_A_SARMD_IDN.do	</_Program name_>
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
local year         2022
local survey       "BLSS"
local vm           "01"
local va           "02"
local type         "SARMD"
global module       	"IDN"
local yearfolder    "`code'_`year'_`survey'"
local SARMDfolder    "`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'"
local filename      "`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'_${module}"
glo output          "${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\\Data\Harmonized" 
*</_Program setup_>

/*
* global path on Joe's computer
if ("`c(username)'"=="sunquat") {
	glo rootdatalib "/Users/`c(username)'/Projects/WORLD BANK/SAR - GMD data harmonization/datalib"
	glo basepath "$rootdatalib/`code'/`yearfolder'"
	glo input "${basepath}/`yearfolder'_v`vm'_M"
	glo output "${basepath}/`yearfolder'_v`vm'_M_v`va'_A_SARGMD/Data/Harmonized"
	
	* load and merge data
	use "${rootdatalib}/BTN/BTN_2022_BLSS/BTN_2022_BLSS_v01_M/Data/Stata/BTN_2022_BLSS_v01_M.dta", clear
	* The weights variable in the BTN_2022_BLSS_v01_M file is the old weights variable, so remove it.
	drop weight weights
	* merge in the "Final HH weights" variable
	merge m:1 interview__id using "${rootdatalib}/BTN/BTN_2022_BLSS/BTN_2022_BLSS_v01_M/Data/Stata/weights", nogen assert(match)
}
* global paths on WB computer
else {
	*<_Folder creation_>
	cap mkdir "$rootdatalib"
	cap mkdir "$rootdatalib\\`code'"
	cap mkdir "$rootdatalib\\`code'\\`yearfolder'"
	cap mkdir "$rootdatalib\\`code'\\`yearfolder'\\`gmdfolder'"
	cap mkdir "$rootdatalib\\`code'\\`yearfolder'\\`gmdfolder'\Data"
	cap mkdir "$rootdatalib\\`code'\\`yearfolder'\\`gmdfolder'\Data\Harmonized"
	*</_Folder creation_>

	*<_Datalibweb request_>
	* load and merge relevant data
	tempfile individual_level_data
	* weights
	datalibweb, country(`code') year(`year') type(SARRAW) filename(weights) local localpath(${rootdatalib})
	save `individual_level_data', replace
	
	* merge in main data
	datalibweb, country(`code') year(`year') type(SARRAW) filename(`yearfolder'_v`vm'_M.dta) local localpath(${rootdatalib})

	* The weights variable in the BTN_2022_BLSS_v01_M file is the old weights variable, so remove it.
	drop weight weights
	merge m:1 interview__id using `individual_level_data', nogen assert(match)
	*</_Datalibweb request_>
}
*/
	* weights
	datalibweb, country(`code') year(`year') type(SARRAW) filename(weights) local localpath(${rootdatalib})
	tempfile weight
	save `weight'
	
	* merge in main data
	datalibweb, country(`code') year(`year') type(SARRAW) filename(`yearfolder'_v`vm'_M.dta) local localpath(${rootdatalib})

	* The weights variable in the BTN_2022_BLSS_v01_M file is the old weights variable, so remove it.
	drop weight weights
	merge m:1 interview__id using `weight', nogen assert(match)
	tempfile base 
	save `base'
	
	use "${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\Data\Harmonized\\`yearfolder'_v`vm'_M_v`va'_A_`type'_IND.dta" 
	merge 1:1 hhid pid using `base', nogen

*<_countrycode_>
*<_countrycode_note_> country code *</_countrycode_note_>
*<_countrycode_note_> countrycode brought in from rawdata *</_countrycode_note_>
*gen countrycode="`code'"
*</_countrycode_>

*<_year_>
*<_year_note_> Year *</_year_note_>
*<_year_note_> year brought in from rawdata *</_year_note_>
confirm var year
*</_year_>

*<_int_year_>
*<_int_year_note_> interview year *</_int_year_note_>
*<_int_year_note_> int_year brought in from rawdata *</_int_year_note_>
*g int_year = year
*</_int_year_>

*<_int_month_>
*<_int_month_note_> interview month *</_int_month_note_>
*<_int_month_note_> int_month brought in from rawdata *</_int_month_note_>
*g int_month = .
*</_int_month_>

*<_hhid_>
*<_hhid_note_> Household identifier  *</_hhid_note_>
*<_hhid_note_> hhid defined in BTN_2019_HIES_v01_M *</_hhid_note_>
confirm var hhid
*</_hhid_>

*<_hhid_org_>
*<_hhid_org_note_> Household identifier in the raw data  *</_hhid_org_note_>
*<_hhid_org_note_> hhid_org brought in from rawdata *</_hhid_org_note_>
clonevar hhid_orig = interview__id
*</_hhid_org_>

*<_pid_>
*<_pid_note_> Personal identifier  *</_pid_note_>
*<_pid_note_> pid defined in BTN_2019_HIES_v01_M *</_pid_note_>
confirm var pid
*</_pid_>

* confirm hhid and pid uniquely identify each observation
isid hhid pid

*<_pid_orig_>
*<_pid_orig_note_> Personal identifier in the raw data  *</_pid_orig_note_>
*<_pid_orig_note_> pid_orig brought in from rawdata *</_pid_orig_note_>
gen pid_orig = slno
*</_pid_orig_>

*<_hhidkeyvars_>
*<_hhidkeyvars_note_> Variables used to construct Household identifier  *</_hhidkeyvars_note_>
*<_hhidkeyvars_note_> hhidkeyvars brought in from rawdata *</_hhidkeyvars_note_>
local hhidkeyvars "interview__id"
foreach v of local hhidkeyvars {
	la var `v' "hhidkeyvars `v'"
}
*</_hhidkeyvars_>

*<_pidkeyvars_>
*<_pidkeyvars_note_> Variables used to construct Personal identifier  *</_pidkeyvars_note_>
*<_pidkeyvars_note_> pidkeyvars brought in from rawdata *</_pidkeyvars_note_>
local pidkeyvars "slno"
foreach v of local pidkeyvars {
	la var `v' "pidkeyvars `v'"
}
*</_pidkeyvars_>

*<_weight_>
*<_weight_note_> Household weight *</_weight_note_>
*<_weight_note_> weight brought in from rawdata *</_weight_note_>
clonevar weight = weights
*</_weight_>

*<_weighttype_>
*<_weighttype_note_> Weight type (frequency, probability, analytical, importance) *</_weighttype_note_>
*<_weighttype_note_> weighttype brought in from rawdata *</_weighttype_note_>
confirm var weighttype
*</_weighttype_>

*<_Keep variables_>
order countrycode year hhid pid weight weighttype
sort hhid pid 
isid hhid pid
*</_Keep variables_>

*<_Save data file_>
quietly do 	"$rootdofiles\_aux\Labels_GMD2.0.do"
save "$output\\`filename'.dta", replace
*</_Save data file_>
