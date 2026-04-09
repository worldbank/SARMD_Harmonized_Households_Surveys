/*------------------------------------------------------------------------------
  GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   	LKA_2019_HIES_v01_M_v03_A_SARMD_IDN.do	   </_Program name_>
<_Application_>    	STATA 17.0									 <_Application_>
<_Author(s)_>       Joe Green 		<jogreen@worldbank.org>		  </_Author(s)_>
<_Date created_>    06-2022	                                   </_Date created_>
<_Author(s)_>      	Leo Tornarolli 	<tornarolli@gmail.com>		  </_Author(s)_>
<_Date modified_>   10-2024									  </_Date modified_>
<_Date modified>    October 2024							  </_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        	LKA											    </_Country_>
<_Survey Title_>   	HIES									   </_Survey Title_>
<_Survey Year_>    	2019										</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:				10-2024
File:				LKA_2019_HIES_v01_M_v03_A_SARMD_IDN.do
First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>
clear all
set more off

globa cpiver       		"v08"
local code         		"LKA"
local year         		"2019"
local survey       		"HIES"
local vm           		"01"
local va           		"03"
local type         		"SARMD"
global module       	"IDN"
local yearfolder    	"`code'_`year'_`survey'"
local SARMDfolder    	"`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'"
local filename      	"`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'_${module}"
glo output          	"${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\\Data\Harmonized" 
*</_Program setup_>


*<_Datalibweb request_>
use "${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\Data\Harmonized\\`yearfolder'_v`vm'_M_v`va'_A_`type'_IND.dta" 
*</_Datalibweb request_>

*<_countrycode_>
*<_countrycode_note_> country code *</_countrycode_note_>
*<_countrycode_note_> countrycode brought in from rawdata *</_countrycode_note_>
*gen countrycode=code
*</_countrycode_>

*<_year_>
*<_year_note_> Year *</_year_note_>
*<_year_note_> year brought in from rawdata *</_year_note_>
* NOTE: this variable already exists in harmonized form.
*</_year_>

*<_int_year_>
*<_int_year_note_> interview year *</_int_year_note_>
*<_int_year_note_> int_year brought in from rawdata *</_int_year_note_>
*gen int_year = year
*</_int_year_>

*<_int_month_>
*<_int_month_note_> interview month *</_int_month_note_>
*<_int_month_note_> int_month brought in from rawdata *</_int_month_note_>
*gen int_month = month
*</_int_month_>

*<_hhid_>
*<_hhid_note_> Household identifier  *</_hhid_note_>
*<_hhid_note_> hhid defined in LKA_2019_HIES_v01_M *</_hhid_note_>
* NOTE: this variable already exists in harmonized form.
*</_hhid_>

*<_hhid_org_>
*<_hhid_org_note_> Household identifier in the raw data  *</_hhid_org_note_>
*<_hhid_org_note_> hhid_org brought in from rawdata *</_hhid_org_note_>
gen hhid_orig = hhid
*</_hhid_org_>

*<_pid_>
*<_pid_note_> Personal identifier  *</_pid_note_>
*<_pid_note_> pid defined in LKA_2019_HIES_v01_M *</_pid_note_>
* NOTE: this variable already exists in harmonized form.
*</_pid_>

*<_pid_orig_>
*<_pid_orig_note_> Personal identifier in the raw data  *</_pid_orig_note_>
*<_pid_orig_note_> pid_orig brought in from rawdata *</_pid_orig_note_>
gen pid_orig = pid
*</_pid_orig_>

*<_hhidkeyvars_>
*<_hhidkeyvars_note_> Variables used to construct Household identifier  *</_hhidkeyvars_note_>
*<_hhidkeyvars_note_> hhidkeyvars brought in from rawdata *</_hhidkeyvars_note_>
local hhidkeyvars "hhid"
foreach v of local hhidkeyvars {
	la var `v' "hhidkeyvars `v'"
}
*</_hhidkeyvars_>

*<_pidkeyvars_>
*<_pidkeyvars_note_> Variables used to construct Personal identifier  *</_pidkeyvars_note_>
*<_pidkeyvars_note_> pidkeyvars brought in from rawdata *</_pidkeyvars_note_>
local pidkeyvars "pid"
foreach v of local pidkeyvars {
	la var `v' "pidkeyvars `v'"
}
*</_pidkeyvars_>

*<_weight_>
*<_weight_note_> Household weight *</_weight_note_>
*<_weight_note_> weight brought in from rawdata *</_weight_note_>
clonevar weight = wgt
*</_weight_>

*<_weighttype_>
*<_weighttype_note_> Weight type (frequency, probability, analytical, importance) *</_weighttype_note_>
*<_weighttype_note_> weighttype brought in from rawdata *</_weighttype_note_>
*gen weighttype = "PW"
*</_weighttype_>


*<_Keep variables_>
order countrycode year hhid pid weight weighttype
sort  hhid pid 
*</_Keep variables_>


*<_Save data file_>
quietly do 	"$rootdofiles\_aux\Labels_GMD2.0.do"
save 		"$output\\`filename'.dta", replace
*</_Save data file_>
