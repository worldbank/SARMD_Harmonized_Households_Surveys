/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   MDV_2019_HIES_v01_M_v01_A_GMD_IDN.do	</_Program name_>
<_Application_>    STATA 16.0	<_Application_>
<_Author(s)_>      Juan Segnana <jsegnana@worldbank.org>	</_Author(s)_>
<_Date created_>   05-03-2020	</_Date created_>
<_Date modified>    3 May 2021	</_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        MDV	</_Country_>
<_Survey Title_>   HIES	</_Survey Title_>
<_Survey Year_>    2019	</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:	05-03-2020
File:	MDV_2019_HIES_v01_M_v01_A_GMD_IDN.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>;
#delimit ;
clear all;
set more off;

local code         "MDV";
local year         "2019";
local survey       "HIES";
local vm           "01";
local va           "02";
local type         "SARMD";
local yearfolder   "`code'_`year'_`survey'";
local gmdfolder    "`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'";
local filename     "`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'_IDN";
*</_Program setup_>;

*<_Folder creation_>;
cap mkdir "$rootdatalib\GMD";
cap mkdir "$rootdatalib\\`code'";
cap mkdir "$rootdatalib\\`code'\\`yearfolder'";
cap mkdir "$rootdatalib\\`code'\\`yearfolder'\\`gmdfolder'";
cap mkdir "$rootdatalib\\`code'\\`yearfolder'\\`gmdfolder'\Data";
cap mkdir "$rootdatalib\\`code'\\`yearfolder'\\`gmdfolder'\Data\Harmonized";
*</_Folder creation_>;

** DIRECTORY;
*<_Datalibweb request_>;
#delimit cr
datalibweb, country(`code') year(`year') type(SARRAW) surveyid(`code'_`year'_`survey'_v`vm'_M) filename(`code'_`year'_`survey'_v`vm'_M.dta) clear 
#delimit ;
drop year hhid pid;
*</_Datalibweb request_>;

*<_countrycode_>;
*<_countrycode_note_> country code *</_countrycode_note_>;
*<_countrycode_note_> countrycode brought in from rawdata *</_countrycode_note_>;
gen countrycode="MDV";
note countrycode: countrycode=MDV;
*</_countrycode_>;

*<_year_>;
*<_year_note_> Year *</_year_note_>;
*<_year_note_> year brought in from rawdata *</_year_note_>;
gen year=2019;
note year: year=2019;
*</_year_>;

*<_int_year_>;
*<_int_year_note_> interview year *</_int_year_note_>;
*<_int_year_note_> int_year brought in from rawdata *</_int_year_note_>;
gen int_year=year(dofc(f1_strtme));
note int_year: Year of interview;
*</_int_year_>;

*<_int_month_>;
*<_int_month_note_> interview month *</_int_month_note_>;
*<_int_month_note_> int_month brought in from rawdata *</_int_month_note_>;
gen int_month=month(dofc( f1_strtme));
note int_month: Month of interview;
*</_int_month_>;

*<_hhid_>;
*<_hhid_note_> Household identifier  *</_hhid_note_>;
*<_hhid_note_> hhid brought in from rawdata *</_hhid_note_>;
gen hhid=uqhhid;
tostring hhid, replace;
label var hhid "Household id";
note hhid: hhid=uqhh_id  4,721 values;
*</_hhid_>;

*<_hhid_orig_>;
*<_hhid_orig_note_> Household identifier in the raw data  *</_hhid_orig_note_>;
*<_hhid_orig_note_> hhid_orig brought in from rawdata *</_hhid_orig_note_>;
gen hhid_orig=uqhhid;
note hhid_orig: Household identifier in the raw data;
*</_hhid_orig_>;

*<_pid_>;
*<_pid_note_> Personal identifier  *</_pid_note_>;
*<_pid_note_> pid brought in from rawdata *</_pid_note_>;
egen pid=concat(uqhhid person_no), punct(-);
note pid: pid=uqhhid - person_no  24,845 values;
*</_pid_>;

*<_pid_orig_>;
*<_pid_orig_note_> Personal identifier in the raw data  *</_pid_orig_note_>;
*<_pid_orig_note_> pid_orig brought in from rawdata *</_pid_orig_note_>;
gen pid_orig=person_no;
note pid_orig: Personal identifier in the raw data;
*</_pid_orig_>;

*<_hhidkeyvars_>;
*<_hhidkeyvars_note_> Variables used to construct Household identifier  *</_hhidkeyvars_note_>;
*<_hhidkeyvars_note_> hhidkeyvars brought in from rawdata *</_hhidkeyvars_note_>;
local hhidkeyvars="uqhhid";
*</_hhidkeyvars_>;

*<_pidkeyvars_>;
*<_pidkeyvars_note_> Variables used to construct Personal identifier  *</_pidkeyvars_note_>;
*<_pidkeyvars_note_> pidkeyvars brought in from rawdata *</_pidkeyvars_note_>;
local pidkeyvars="uqhhid person_no";
*</_pidkeyvars_>;

*<_weight_>;
*<_weight_note_> Household weight *</_weight_note_>;
*<_weight_note_> weight brought in from rawdata *</_weight_note_>;
gen weight=wgt;
note weight: weight=wgt;
*</_weight_>;

*<_weighttype_>;
*<_weighttype_note_> Weight type (frequency, probability, analytical, importance) *</_weighttype_note_>;
*<_weighttype_note_> weighttype brought in from rawdata *</_weighttype_note_>;
gen weighttype="PW";
note weighttype: "Probability weight";
*</_weighttype_>;

*<_Keep variables_>;
keep countrycode year int_year int_month hhid hhid_orig pid pid_orig `hhidkeyvars' `pidkeyvars' weight weighttype;
order countrycode year hhid pid weight weighttype;
sort hhid pid ;
*</_Keep variables_>;

*<_Save data file_>;
glo module="IDN";
include "${rootdatalib}\_aux\GMD2.0labels.do";
save "$rootdatalib\\`code'\\`yearfolder'\\`gmdfolder'\Data\Harmonized\\`filename'.dta" , replace;
*</_Save data file_>;
exit;
