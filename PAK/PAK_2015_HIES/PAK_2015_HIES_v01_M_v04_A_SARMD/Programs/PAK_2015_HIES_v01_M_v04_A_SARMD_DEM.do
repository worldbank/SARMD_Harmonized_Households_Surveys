/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   PAK_2015_PSLM_v01_M_v04_A_GMD_DEM.do	</_Program name_>
<_Application_>    STATA 16.0	<_Application_>
<_Author(s)_>      Navishti Das and Javier Parada	</_Author(s)_>
<_Date created_>   03-03-2019	</_Date created_>
<_Date modified>    3 Mar 2020	</_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        PAK	</_Country_>
<_Survey Title_>   PSLM	</_Survey Title_>
<_Survey Year_>    2015	</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:	03-03-2019
File:	PAK_2015_PSLM_v01_M_v04_A_GMD_DEM.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/


*<_Program setup_>;
#delimit ;
clear all;
set more off;

glo rootdatalib    "P:\SARMD\SARDATABANK\SAR_DATABANK";
local code         "PAK";
local year         "2015";
local survey       "HIES";
local vm           "01";
local va           "04";
local type         "SARMD";
local yearfolder   "`code'_`year'_`survey'";
local gmdfolder    "`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD";
local filename     "`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD_DEM";
*</_Program setup_>;


*<_Datalibweb request_>;
#delimit cr
cap datalibweb, country(`code') year(`year') type(`type') survey(`survey') vermast(`vm') veralt(`va') mod(IND) clear 
if _rc!=0 {
	use "$rootdatalib\\`code'\\`code'_`year'_`survey'\\`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD\Data\Harmonized\\`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD_IND", clear 
}
#delimit ;
*</_Datalibweb request_>;

*<_countrycode_>;
*<_countrycode_note_> country code *</_countrycode_note_>;
*<_countrycode_note_> countrycode brought in from SARMD *</_countrycode_note_>;
*code;
*</_countrycode_>;

*<_year_>;
*<_year_note_> Year *</_year_note_>;
*<_year_note_> year brought in from SARMD *</_year_note_>;
*year;
*</_year_>;

*<_hhid_>;
*<_hhid_note_> Household identifier  *</_hhid_note_>;
*<_hhid_note_> hhid brought in from SARMD *</_hhid_note_>;
clonevar hhid = idh;
*</_hhid_>;

*<_pid_>;
*<_pid_note_> Personal identifier  *</_pid_note_>;
*<_pid_note_> pid brought in from rawdata *</_pid_note_>;
clonevar pid  = idp;
*</_pid_>;

*<_weight_>;
*<_weight_note_> Household weight *</_weight_note_>;
*<_weight_note_> weight brought in from rawdata *</_weight_note_>;
clonevar  weight = wgt;
*</_weight_>;

*<_weighttype_>;
*<_weighttype_note_> Weight type (frequency, probability, analytical, importance) *</_weighttype_note_>;
*<_weighttype_note_> weighttype brought in from rawdata *</_weighttype_note_>;
gen weighttype = "PW";
*</_weighttype_>;

*<_language_>;
*<_language_note_> Language *</_language_note_>;
*<_language_note_> language brought in from SARMD *</_language_note_>;
*gen language=.;
*</_language_>;

*<_age_>;
*<_age_note_> Age of individual (continuous) *</_age_note_>;
*<_age_note_> age brought in from SARMD *</_age_note_>;
*age ;
*</_age_>;

*<_agecat_>;
*<_agecat_note_> Age of individual (categorical) *</_agecat_note_>;
*<_agecat_note_> agecat brought in from SARMD *</_agecat_note_>;
gen agecat=".";
replace agecat="15 years or younger" if age<=15;
replace agecat="16-24 years old"     if age<=16 & age<=24;
replace agecat="25-54 years old"     if age<=25 & age<=54;
replace agecat="55-64 years old"     if age<=55 & age<=64;
replace agecat="65 years or older"   if age>=65;
*</_agecat_>;

*<_male_>;
*<_male_note_> Sex of household member (male=1) *</_male_note_>;
*<_male_note_> male brought in from SARMD *</_male_note_>;
*male ;
*</_male_>;

*<_relationharm_>;
*<_relationharm_note_> Relationship to head of household harmonized across all regions *</_relationharm_note_>;
*<_relationharm_note_> relationharm brought in from SARMD *</_relationharm_note_>;
*relationharm;
*</_relationharm_>;

*<_relationcs_>;
*<_relationcs_note_> Relationship to head of household harmonized across all regions *</_relationcs_note_>;
*<_relationcs_note_> relationcs brought in from SARMD *</_relationcs_note_>;
*relationcs;
*</_relationcs_>;

*<_marital_>;
*<_marital_note_> Marital status *</_marital_note_>;
*<_marital_note_> marital brought in from SARMD *</_marital_note_>;
*marital;
*</_marital_>;

*<_eye_dsablty_>;
*<_eye_dsablty_note_> Difficulty seeing *</_eye_dsablty_note_>;
*<_eye_dsablty_note_> eye_dsablty brought in from SARMD *</_eye_dsablty_note_>;
gen eye_dsablty=.;
*</_eye_dsablty_>;

*<_hear_dsablty_>;
*<_hear_dsablty_note_> Difficulty hearing *</_hear_dsablty_note_>;
*<_hear_dsablty_note_> hear_dsablty brought in from SARMD *</_hear_dsablty_note_>;
gen hear_dsablty=.;
*</_hear_dsablty_>;

*<_walk_dsablty_>;
*<_walk_dsablty_note_> Difficulty walking or climbing steps *</_walk_dsablty_note_>;
*<_walk_dsablty_note_> walk_dsablty brought in from SARMD *</_walk_dsablty_note_>;
gen walk_dsablty=.;
*</_walk_dsablty_>;

*<_conc_dsord_>;
*<_conc_dsord_note_> Difficulty remembering or concentrating *</_conc_dsord_note_>;
*<_conc_dsord_note_> conc_dsord brought in from SARMD *</_conc_dsord_note_>;
gen conc_dsord=.;
*</_conc_dsord_>;

*<_slfcre_dsablty_>;
*<_slfcre_dsablty_note_> Difficulty with self-care *</_slfcre_dsablty_note_>;
*<_slfcre_dsablty_note_> slfcre_dsablty brought in from SARMD *</_slfcre_dsablty_note_>;
gen slfcre_dsablty=.;
*</_slfcre_dsablty_>;

*<_comm_dsablty_>;
*<_comm_dsablty_note_> Difficulty communicating *</_comm_dsablty_note_>;
*<_comm_dsablty_note_> comm_dsablty brought in from SARMD *</_comm_dsablty_note_>;
gen comm_dsablty=.;
*</_comm_dsablty_>;

*<_Keep variables_>;
*keep countrycode year hhid pid weight weighttype language age agecat male relationharm relationcs marital eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty;
order countrycode year hhid pid weight weighttype;
sort hhid pid ;
*</_Keep variables_>;

*<_Save data file_>;
save "$rootdatalib\\`code'\\`yearfolder'\\`gmdfolder'\Data\Harmonized\\`filename'.dta" , replace;
*save "$rootdatalib\GMD\\`code'\\`yearfolder'\\`gmdfolder'\Data\Harmonized\\`filename'.dta" , replace;
*</_Save data file_>;
