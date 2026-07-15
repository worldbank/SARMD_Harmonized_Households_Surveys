/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   AFG_2019_LCS_v01_M_v01_A_GMD_IDN.do	</_Program name_>
<_Application_>    STATA 16.0	<_Application_>
<_Author(s)_>      jogreen@worldbank.org	</_Author(s)_>
<_Date created_>   05-25-2020	</_Date created_>
<_Date modified>   08-08-2021	</_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        AFG	</_Country_>
<_Survey Title_>   LCS	</_Survey Title_>
<_Survey Year_>    2019	</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:	08-08-2021
File:	AFG_2019_LCS_v01_M_v01_A_GMD_IDN.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>
clear all
set more off

local code         "AFG"
local year         "2019"
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
	* IND data
	use "$output/`yearfolder'_v`vm'_M_v`va'_A_`type'_IND", clear
}
* global paths on WB computer
else {
	*<_Folder creation_>
	*</_Folder creation_>
	
	*<_Datalibweb request_>
	use "${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\Data\Harmonized\\`yearfolder'_v`vm'_M_v`va'_A_`type'_IND.dta", clear

}

*<_countrycode_>
*<_countrycode_note_> country code *</_countrycode_note_>
*<_countrycode_note_> countrycode brought in from rawdata *</_countrycode_note_>
*g countrycode = "`code'"
*</_countrycode_>

*<_year_>
*<_year_note_> Year *</_year_note_>
*<_year_note_> year brought in from rawdata *</_year_note_>
*g year = `year'
*</_year_>

*<_int_year_>
*<_int_year_note_> interview year *</_int_year_note_>
*<_int_year_note_> int_year brought in from rawdata *</_int_year_note_>
*g		int_year = 2020 if yy==98 | (yy==99 & inrange(mm,1,3)) | (yy==99 & mm==4 & inrange(dd,1,16))
*recode	int_year (.=2021) if ~missing(yy)
note int_year: The data uses the Solar Hijri calendar. The survey dates convert to 2020 and 2021 in the Gregorian calendar, with 17/4/1399 being January 1, 2021.
*</_int_year_>

*<_int_year_orig_>
*<_int_year_orig_note_> interview year in the raw data *</_int_year_orig_note_>
*<_int_year_orig_note_> int_year_orig brought in from rawdata *</_int_year_orig_note_>
*clonevar int_year_orig = yy
*note int_year_orig: FYI it appears the date responses are in the Solar Hijri calendar.
*</_int_year_orig_>

*<_int_month_>
*<_int_month_note_> interview month *</_int_month_note_>
*<_int_month_note_> int_month brought in from rawdata *</_int_month_note_>
/*
g		int_month = 1 if yy==99 & ((mm==4 & inrange(dd,11,.)) | (mm==5 & inrange(dd,1,11)))
replace	int_month = 2 if yy==99 & ((mm==5 & inrange(dd,12,.)) | (mm==6 & inrange(dd,1,10)))
replace	int_month = 3 if (yy==99 & mm==6 & inrange(dd,10,.)) | (yy==98 & mm==7 & inrange(dd,1,11))
replace	int_month = 4 if yy==98 & ((mm==7 & inrange(dd,12,.)) | (mm==8 & inrange(dd,1,10)))
replace	int_month = 5 if yy==98 & ((mm==8 & inrange(dd,11,.)) | (mm==9 & inrange(dd,1,10)))
replace	int_month = 6 if yy==98 & ((mm==9 & inrange(dd,11,.)) | (mm==10 & inrange(dd,1,9)))
replace	int_month = 7 if yy==98 & ((mm==10 & inrange(dd,10,.)) | (mm==11 & inrange(dd,1,9)))
replace	int_month = 8 if yy==98 & ((mm==11 & inrange(dd,10,.)) | (mm==12 & inrange(dd,1,9)))
replace	int_month = 9 if (yy==98 & mm==12 & inrange(dd,10,.)) | (yy==99 & mm==1 & inrange(dd,1,8))
replace	int_month = 10 if yy==99 & ((mm==1 & inrange(dd,9,.)) | (mm==2 & inrange(dd,1,9)))
replace	int_month = 11 if yy==99 & ((mm==2 & inrange(dd,10,.)) | (mm==3 & inrange(dd,1,9)))
replace	int_month = 12 if yy==99 & ((mm==3 & inrange(dd,10,.)) | (mm==4 & inrange(dd,1,10)))
*/
note int_month: The data uses the Solar Hijri calendar. The survey dates convert to 2020 and 2021 in the Gregorian calendar, with 17/4/1399 being January 1, 2021.
*</_int_month_>

*<_int_month_orig_>
*<_int_month_orig_note_> interview month *</_int_month_orig_note_>
*<_int_month_orig_note_> int_month brought in from rawdata *</_int_month_orig_note_>
*clonevar int_month_orig = mm
*note int_year_orig: FYI it appears the date responses are in the Solar Hijri calendar.
*</_int_month_orig_>

*<_hhid_>
*<_hhid_note_> Household identifier  *</_hhid_note_>
*<_hhid_note_> hhid brought in from rawdata *</_hhid_note_>
*clonevar hhid = hhid_orig
*</_hhid_>

*<_hhid_org_>
*<_hhid_org_note_> Household identifier in the raw data  *</_hhid_org_note_>
*<_hhid_org_note_> hhid_org created above *</_hhid_org_note_>
clonevar hhid_orig = idh_org
*</_hhid_org_>

*<_pid_>
*<_pid_note_> Personal identifier  *</_pid_note_>
*<_pid_note_> pid brought in from rawdata *</_pid_note_>
*clonevar pid = Mem_ID
*</_pid_>

*<_pid_orig_>
*<_pid_orig_note_> Personal identifier in the raw data  *</_pid_orig_note_>
*<_pid_orig_note_> pid_orig brought in from rawdata *</_pid_orig_note_>
clonevar pid_orig = idp_org
*</_pid_orig_>

*<_hhidkeyvars_>
*<_hhidkeyvars_note_> Variables used to construct Household identifier  *</_hhidkeyvars_note_>
*<_hhidkeyvars_note_> hhidkeyvars brought in from rawdata *</_hhidkeyvars_note_>
g hhidkeyvars = "HH_ID"
*</_hhidkeyvars_>

*<_pidkeyvars_>
*<_pidkeyvars_note_> Variables used to construct Personal identifier  *</_pidkeyvars_note_>
*<_pidkeyvars_note_> pidkeyvars brought in from rawdata *</_pidkeyvars_note_>
g pidkeyvars = "Mem_ID"
*</_pidkeyvars_>

*<_weight_>
*<_weight_note_> Household weight *</_weight_note_>
*<_weight_note_> weight brought in from rawdata *</_weight_note_>
clonevar weight = wgt
*</_weight_>

*<_weighttype_>
*<_weighttype_note_> Weight type (frequency, probability, analytical, importance) *</_weighttype_note_>
*<_weighttype_note_> weighttype brought in from rawdata *</_weighttype_note_>
*g weighttype = "PW"
*</_weighttype_>

*<_Keep variables_>
*keep countrycode year int_year int_year_orig int_month int_month_orig hhid hhid_orig pid pid_orig hhidkeyvars pidkeyvars weight weighttype
order countrycode year hhid pid weight weighttype
sort hhid pid 
*</_Keep variables_>

*<_Save data file_>
if ("`c(username)'"=="sunquat") global rootdofiles "/Users/`c(username)'/Projects/WORLD BANK/2023 SAR QCHECK/SARDATABANK/SARMDdofiles"
quietly do 	"$rootdofiles/_aux/Labels_GMD2.0.do"
save "$output/`filename'.dta", replace
*</_Save data file_>
