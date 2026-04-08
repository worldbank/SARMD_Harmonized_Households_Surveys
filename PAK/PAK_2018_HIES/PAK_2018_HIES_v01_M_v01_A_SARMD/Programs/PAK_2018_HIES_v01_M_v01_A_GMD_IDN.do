/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   PAK_2018_PSLM_v_M_v_A_GMD_IDN.do	</_Program name_>
<_Application_>    STATA 16.0	<_Application_>
<_Author(s)_>      Navishti Das and Javier Parada	</_Author(s)_>
<_Date created_>   03-03-2019	</_Date created_>
<_Date modified>   18 Feb 2021	</_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        PAK	</_Country_>
<_Survey Title_>   PSLM	</_Survey Title_>
<_Survey Year_>    2018	</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:	03-03-2019
File:	PAK_2018_PSLM_v_M_v_A_GMD_IDN.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>;
#delimit ;
clear all;
set more off;

local code         "PAK";
local year         "2018";
local survey       "PSLM";
local vm           "";
local va           "";
local type         "SARMD";
local yearfolder   "PAK_2018_PSLM";
local gmdfolder    "PAK_2018_PSLM_v_M_v_A_GMD";
local filename     "PAK_2018_PSLM_v_M_v_A_GMD_IDN";
*</_Program setup_>;

*<_Folder creation_>;
cap mkdir "$rootdatalib\GMD";
cap mkdir "$rootdatalib\GMD\\`code'";
cap mkdir "$rootdatalib\GMD\\`code'\\`yearfolder'";
cap mkdir "$rootdatalib\GMD\\`code'\\`yearfolder'\\`gmdfolder'";
cap mkdir "$rootdatalib\GMD\\`code'\\`yearfolder'\\`gmdfolder'\Data";
cap mkdir "$rootdatalib\GMD\\`code'\\`yearfolder'\\`gmdfolder'\Data\Harmonized";
*</_Folder creation_>;

*<_Datalibweb request_>;
#delimit cr
datalibweb, country(`code') year(`year') type(`type') survey(`survey') vermast(`vm') veralt(`va') mod(IND) clear 
#delimit ;
*</_Datalibweb request_>;

*<_countrycode_>;
*<_countrycode_note_> country code *</_countrycode_note_>;
*<_countrycode_note_> countrycode brought in from SARMD *</_countrycode_note_>;
*replace code=countrycode;;
*</_countrycode_>;

*<_year_>;
*<_year_note_> Year *</_year_note_>;
*<_year_note_> year brought in from SARMD *</_year_note_>;
replace year=year;;
*</_year_>;

*<_int_year_>;
*<_int_year_note_> interview year *</_int_year_note_>;
*<_int_year_note_> int_year brought in from SARMD *</_int_year_note_>;
replace int_year=int_year;;
*</_int_year_>;

*<_int_month_>;
*<_int_month_note_> interview month *</_int_month_note_>;
*<_int_month_note_> int_month brought in from SARMD *</_int_month_note_>;
replace int_month=int_month;;
*</_int_month_>;

*<_hhid_>;
*<_hhid_note_> Household identifier  *</_hhid_note_>;
*<_hhid_note_> hhid brought in from SARMD *</_hhid_note_>;
clonevar hhid=idh;;
*</_hhid_>;

*<_hhid_org_>;
*<_hhid_org_note_> Household identifier in the raw data  *</_hhid_org_note_>;
*<_hhid_org_note_> hhid_org brought in from rawdata *</_hhid_org_note_>;
gen hhid_orig = "";
*</_hhid_org_>;

*<_pid_>;
*<_pid_note_> Personal identifier  *</_pid_note_>;
*<_pid_note_> pid brought in from rawdata *</_pid_note_>;
clonevar pid  = idp;;
*</_pid_>;

*<_pid_orig_>;
*<_pid_orig_note_> Personal identifier in the raw data  *</_pid_orig_note_>;
*<_pid_orig_note_> pid_orig brought in from rawdata *</_pid_orig_note_>;
gen pid_orig="";
*</_pid_orig_>;

*<_variable name in raw data_>;
*<_variable name in raw data_note_> Variables used to construct Household identifier  *</_variable name in raw data_note_>;
*<_variable name in raw data_note_> variable name in raw data brought in from rawdata *</_variable name in raw data_note_>;
local keepvarid "`keepvarid' `hpid'";;
*</_variable name in raw data_>;

*<_variable name in raw data_>;
*<_variable name in raw data_note_> Variables used to construct Personal identifier  *</_variable name in raw data_note_>;
*<_variable name in raw data_note_> variable name in raw data brought in from rawdata *</_variable name in raw data_note_>;
local keepvarid "`keepvarid' `hhid_org'";;
*</_variable name in raw data_>;

*<_weight_>;
*<_weight_note_> Household weight *</_weight_note_>;
*<_weight_note_> weight brought in from rawdata *</_weight_note_>;
clonevar  weights=wgt;;
*</_weight_>;

*<_weighttype_>;
*<_weighttype_note_> Weight type (frequency, probability, analytical, importance) *</_weighttype_note_>;
*<_weighttype_note_> weighttype brought in from rawdata *</_weighttype_note_>;
gen weighttype = "IW";;
*</_weighttype_>;

*<_Keep variables_>;
*keep countrycode year int_year int_month hhid hhid_org pid pid_orig variable name in raw data weight weighttype;
order countrycode year hhid pid weights weighttype;
sort hhid pid ;
*</_Keep variables_>;

*<_Save data file_>;
save "$rootdatalib\GMD\\`code'\\`yearfolder'\\`gmdfolder'\Data\Harmonized\\`filename'.dta" , replace;
*</_Save data file_>;
