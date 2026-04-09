/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   MDV_2019_HIES_v01_M_v01_A_GMD_DEM.do	</_Program name_>
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
File:	MDV_2019_HIES_v01_M_v01_A_GMD_DEM.do
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
local va           "01";
local type         "SARMD";
local yearfolder   "MDV_2019_HIES";
local gmdfolder    "MDV_2019_HIES_v01_M_v01_A_SARMD";
local filename     "MDV_2019_HIES_v01_M_v01_A_SARMD_DEM";
*</_Program setup_>;

*<_Folder creation_>;
cap mkdir "$rootdatalib";
cap mkdir "$rootdatalib\\`code'";
cap mkdir "$rootdatalib\\`code'\\`yearfolder'";
cap mkdir "$rootdatalib\\`code'\\`yearfolder'\\`gmdfolder'";
cap mkdir "$rootdatalib\\`code'\\`yearfolder'\\`gmdfolder'\Data";
cap mkdir "$rootdatalib\\`code'\\`yearfolder'\\`gmdfolder'\Data\Harmonized";
*</_Folder creation_>;

** DIRECTORY;
*<_Datalibweb request_>;
#delimit cr
*datalibweb, country(`code') year(`year') type(`type') survey(`survey') vermast(`vm') veralt(`va') mod(IND) clear 
#delimit ;
	use "$rootdatalib\MDV\MDV_2019_HIES\MDV_2019_HIES_v01_M\Data\Stata\MDV_2019_HIES_v01_M.dta", clear;
	drop countrycode year hhid pid;
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

*<_hhid_>;
*<_hhid_note_> Household identifier  *</_hhid_note_>;
*<_hhid_note_> hhid brought in from rawdata *</_hhid_note_>;
gen hhid=uqhhid;
tostring hhid, replace;
label var hhid "Household id";
note hhid: hhid=uqhhid  4,721 values;
*</_hhid_>;

*<_pid_>;
*<_pid_note_> Personal identifier  *</_pid_note_>;
*<_pid_note_> pid brought in from rawdata *</_pid_note_>;
egen pid = concat(uqhhid person_no), punct(-);
note pid: pid=uqhhid - person_no  24,749 values;
*</_pid_>;

*<_weight_>;
*<_weight_note_> Household weight *</_weight_note_>;
*<_weight_note_> weight brought in from rawdata *</_weight_note_>;
gen double weight=wgt;
note weight: weight=wgt;
*</_weight_>;

*<_weighttype_>;
*<_weighttype_note_> Weight type (frequency, probability, analytical, importance) *</_weighttype_note_>;
*<_weighttype_note_> weighttype brought in from rawdata *</_weighttype_note_>;
gen weighttype="PW";
note weighttype: "Probability Weight";
*</_weighttype_>;

*<_language_>;
*<_language_note_> Language *</_language_note_>;
*<_language_note_> language brought in from rawdata *</_language_note_>;
gen language="Dhivehi";
*</_language_>;

*<_age_>;
*<_age_note_> Age of individual (continuous) *</_age_note_>;
*<_age_note_> age brought in from rawdata *</_age_note_>;
gen age=Age;
*</_age_>;

*<_agecat_>;
*<_agecat_note_> Age of individual (categorical) *</_agecat_note_>;
*<_agecat_note_> agecat brought in from rawdata *</_agecat_note_>;
gen agecat=.;;
*</_agecat_>;

*<_male_>;
*<_male_note_> Sex of household member (male=1) *</_male_note_>;
*<_male_note_> male brought in from rawdata *</_male_note_>;
gen male=Sex; replace male=0 if male==1; replace male=1 if male==2;
note male: male=1 "Male" - male=0 "Female";
*</_male_>;

*<_relationharm_>;
*<_relationharm_note_> Relationship to head of household harmonized across all regions *</_relationharm_note_>;
*<_relationharm_note_> relationharm brought in from rawdata *</_relationharm_note_>;
gen relationharm=.;
replace relationharm=1 if relhhh==.;
replace relationharm=2 if relhhh==2;
replace relationharm=3 if relhhh==3  | relhhh==4;
replace relationharm=5 if relhhh==5;
replace relationharm=4 if relhhh==6  | relhhh==7;
replace relationharm=5 if relhhh==8;
replace relationharm=5 if relhhh==9  | relhhh==10;
replace relationharm=5 if relhhh==11 | relhhh==12;
replace relationharm=6 if relhhh==13; 
note relationharm: relationharm="Relationship to head of household harmonized across all regions";
*</_relationharm_>;

*<_relationcs_>;
*<_relationcs_note_> Original relationship to head of household *</_relationcs_note_>;
*<_relationcs_note_> relationcs brought in from rawdata *</_relationcs_note_>;
gen relationcs=.;;
*</_relationcs_>;

*<_marital_>;
*<_marital_note_> Marital status *</_marital_note_>;
*<_marital_note_> marital brought in from rawdata *</_marital_note_>;
gen marital=.;
replace marital=1 if maritalStatus==2;
replace marital=2 if maritalStatus==1;
replace marital=4 if maritalStatus==3;
replace marital=5 if maritalStatus==4;
note marital: Marital status;
*</_marital_>;

*<_eye_dsablty_>;
*<_eye_dsablty_note_> Difficulty seeing *</_eye_dsablty_note_>;
*<_eye_dsablty_note_> eye_dsablty brought in from rawdata *</_eye_dsablty_note_>;
gen eye_dsablty=SeingWthGlasses; 
note eye_dsablty: Difficulty seeing;
*</_eye_dsablty_>;

*<_hear_dsablty_>;
*<_hear_dsablty_note_> Difficulty hearing *</_hear_dsablty_note_>;
*<_hear_dsablty_note_> hear_dsablty brought in from rawdata *</_hear_dsablty_note_>;
gen hear_dsablty=WthHearingAid;
note: hear_dsablty: Difficulty seeing;
*</_hear_dsablty_>;

*<_walk_dsablty_>;
*<_walk_dsablty_note_> Difficulty walking or climbing steps *</_walk_dsablty_note_>;
*<_walk_dsablty_note_> walk_dsablty brought in from rawdata *</_walk_dsablty_note_>;
gen walk_dsablty=WalkingClimbing;
note walk_dsablty: Difficulty walking;
*</_walk_dsablty_>;

*<_conc_dsord_>;
*<_conc_dsord_note_> Difficulty remembering or concentrating *</_conc_dsord_note_>;
*<_conc_dsord_note_> conc_dsord brought in from rawdata *</_conc_dsord_note_>;
gen conc_dsord=Remembering;
note conc_dsord: Difficulty remembering or concentrating;
*</_conc_dsord_>;

*<_slfcre_dsablty_>;
*<_slfcre_dsablty_note_> Difficulty with self-care *</_slfcre_dsablty_note_>;
*<_slfcre_dsablty_note_> slfcre_dsablty brought in from rawdata *</_slfcre_dsablty_note_>;
gen slfcre_dsablty=Selfcare;
note slfcre_dsablty: Difficulty with self-care;
*</_slfcre_dsablty_>;

*<_comm_dsablty_>;
*<_comm_dsablty_note_> Difficulty communicating *</_comm_dsablty_note_>;
*<_comm_dsablty_note_> comm_dsablty brought in from rawdata *</_comm_dsablty_note_>;
gen comm_dsablty=Communicating;
note comm_dsablty: Difficulty communicating;
*</_comm_dsablty_>;

*<_Keep variables_>;
keep countrycode year hhid pid weight weighttype language age agecat male relationharm relationcs marital eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty;
order countrycode year hhid pid weight weighttype;
sort hhid pid ;
*</_Keep variables_>;

*<_Save data file_>;
glo module="DEM";
include "${rootdatalib}\_aux\GMD2.0labels.do";

save "$rootdatalib\\`code'\\`yearfolder'\\`gmdfolder'\Data\Harmonized\\`filename'.dta" , replace;
*</_Save data file_>;
