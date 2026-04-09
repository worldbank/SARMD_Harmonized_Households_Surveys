/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   LKA_2019_HIES_v01_M_v01_A_SARMD_IDN.do	</_Program name_>
<_Application_>    STATA 16.0	<_Application_>
<_Author(s)_>      jogreen@worldbank.org	</_Author(s)_>
<_Date created_>   06-26-2022	</_Date created_>
<_Date modified>   26 May 2022	</_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        LKA	</_Country_>
<_Survey Title_>   HIES	</_Survey Title_>
<_Survey Year_>    2019	</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:	06-26-2022
File:	LKA_2019_HIES_v01_M_v01_A_SARMD_IDN.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>
clear all
set more off

local code         "LKA"
local year         "2019"
local survey       "HIES"
local vm           "01"
local va           "01"
local type         "SARMD"
glo   module       "IDN"
local yearfolder   "`code'_`year'_`survey'"
local gmdfolder    "`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD"
local filename     "`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD_${module}"
*</_Program setup_>

* global path on Joe's computer
if ("`c(username)'"=="sunquat") {
	glo basepath "/Users/`c(username)'/Projects/WORLD BANK/SAR - GMD data harmonization/datalib/`code'/`yearfolder'"
	glo input "${basepath}/`yearfolder'_v`vm'_M"
	glo output "${basepath}/`yearfolder'_v`vm'_M_v`va'_A_SARGMD/Data/Harmonized"
	
	* load and merge relevant data
	cd "${input}/Data/Stata"
	* weight data
	use "weight_2019", clear
	* roster data
	merge 1:m psu using "LKA_2019_HIES_v01_M", nogen assert(match)
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
	tempfile hh_level_data
	* weight data
	datalibweb, country(`code') year(`year') type(SARRAW) filename(weight_2019.dta)
	save `hh_level_data'
	* merge in durable goods data
	datalibweb, country(`code') year(`year') type(SARRAW) filename(LKA_2019_HIES_v01_M.dta)
	merge m:1 psu using `hh_level_data', nogen assert(match)
	*</_Datalibweb request_>
}

*<_countrycode_>
*<_countrycode_note_> country code *</_countrycode_note_>
*<_countrycode_note_> countrycode brought in from rawdata *</_countrycode_note_>
gen countrycode=code
*</_countrycode_>

*<_year_>
*<_year_note_> Year *</_year_note_>
*<_year_note_> year brought in from rawdata *</_year_note_>
* NOTE: this variable already exists in harmonized form.
*</_year_>

*<_int_year_>
*<_int_year_note_> interview year *</_int_year_note_>
*<_int_year_note_> int_year brought in from rawdata *</_int_year_note_>
g int_year = year
*</_int_year_>

*<_int_month_>
*<_int_month_note_> interview month *</_int_month_note_>
*<_int_month_note_> int_month brought in from rawdata *</_int_month_note_>
g int_month = month
*</_int_month_>

*<_hhid_>
*<_hhid_note_> Household identifier  *</_hhid_note_>
*<_hhid_note_> hhid defined in LKA_2019_HIES_v01_M *</_hhid_note_>
* NOTE: this variable already exists in harmonized form.
*</_hhid_>

*<_hhid_org_>
*<_hhid_org_note_> Household identifier in the raw data  *</_hhid_org_note_>
*<_hhid_org_note_> hhid_org brought in from rawdata *</_hhid_org_note_>
gen hhid_orig =string((district*10^12)+(psu*10^5)+(snumber*10^2)+(hhno), "%15.0f")
*</_hhid_org_>

*<_pid_>
*<_pid_note_> Personal identifier  *</_pid_note_>
*<_pid_note_> pid defined in LKA_2019_HIES_v01_M *</_pid_note_>
* NOTE: this variable already exists in harmonized form.
*</_pid_>

*<_pid_orig_>
*<_pid_orig_note_> Personal identifier in the raw data  *</_pid_orig_note_>
*<_pid_orig_note_> pid_orig brought in from rawdata *</_pid_orig_note_>
gen pid_orig = person_serial_no
*</_pid_orig_>

*<_hhidkeyvars_>
*<_hhidkeyvars_note_> Variables used to construct Household identifier  *</_hhidkeyvars_note_>
*<_hhidkeyvars_note_> hhidkeyvars brought in from rawdata *</_hhidkeyvars_note_>
local hhidkeyvars "district psu hhno snumber"
foreach v of local hhidkeyvars {
	la var `v' "hhidkeyvars `v'"
}
*</_hhidkeyvars_>

*<_pidkeyvars_>
*<_pidkeyvars_note_> Variables used to construct Personal identifier  *</_pidkeyvars_note_>
*<_pidkeyvars_note_> pidkeyvars brought in from rawdata *</_pidkeyvars_note_>
local pidkeyvars "person_serial_no"
foreach v of local pidkeyvars {
	la var `v' "pidkeyvars `v'"
}
*</_pidkeyvars_>

*<_weight_>
*<_weight_note_> Household weight *</_weight_note_>
*<_weight_note_> weight brought in from rawdata *</_weight_note_>
clonevar weight = finalweight
*</_weight_>

*<_weighttype_>
*<_weighttype_note_> Weight type (frequency, probability, analytical, importance) *</_weighttype_note_>
*<_weighttype_note_> weighttype brought in from rawdata *</_weighttype_note_>
g weighttype = "PW"
*</_weighttype_>

*<_Keep variables_>
keep countrycode year int_year int_month hhid hhid_orig pid pid_orig `hhidkeyvars' `pidkeyvars' weight weighttype
order countrycode year hhid pid weight weighttype
sort hhid pid 
*</_Keep variables_>

*<_Save data file_>
do "${rootdatalib}/`code'/`yearfolder'/`yearfolder'_v`vm'_M_v`va'_A_SARMD/Programs/Labels_GMD2.0.do"
compress
if ("`c(username)'"=="sunquat") save "${output}/`filename'", replace
else save "$rootdatalib\\`code'\\`yearfolder'\\`gmdfolder'\Data\Harmonized\\`filename'.dta" , replace
*</_Save data file_>
