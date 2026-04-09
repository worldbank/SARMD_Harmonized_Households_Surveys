/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   LKA_2016_HIES_v01_M_v01_A_GMD_GEO.do	</_Program name_>
<_Application_>    STATA 16.0	<_Application_>
<_Author(s)_>      Navishti Das and Javier Parada	</_Author(s)_>
<_Date created_>   03-03-2019	</_Date created_>
<_Date modified>    3 Mar 2020	</_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        LKA	</_Country_>
<_Survey Title_>   HIES	</_Survey Title_>
<_Survey Year_>    2016	</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:	03-03-2019
File:	LKA_2016_HIES_v01_M_v01_A_GMD_GEO.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>;
#delimit ;
clear all;
set more off;

local code         "LKA";
local year         "2016";
local survey       "HIES";
local vm           "01";
local va           "01";
local type         "SARMD";
local yearfolder   "LKA_2016_HIES";
local gmdfolder    "LKA_2016_HIES_v01_M_v01_A_GMD";
local filename     "LKA_2016_HIES_v01_M_v01_A_GMD_GEO";
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

*<_subnatid1_>;
*<_subnatid1_note_> Subnational ID - highest level *</_subnatid1_note_>;
*<_subnatid1_note_> subnatid1 brought in from SARMD *</_subnatid1_note_>;
*subnatid1;
*</_subnatid1_>;

*<_subnatid2_>;
*<_subnatid2_note_> Subnational ID - second highest level *</_subnatid2_note_>;
*<_subnatid2_note_> subnatid2 brought in from SARMD *</_subnatid2_note_>;
*subnatid2;
*</_subnatid2_>;

*<_subnatid3_>;
*<_subnatid3_note_> Subnational ID - third highest level *</_subnatid3_note_>;
*<_subnatid3_note_> subnatid3 brought in from SARMD *</_subnatid3_note_>;
gen subnatid3=.;
*</_subnatid3_>;

*<_subnatid4_>;
*<_subnatid4_note_> Subnational ID - lowest level *</_subnatid4_note_>;
*<_subnatid4_note_> subnatid4 brought in from SARMD *</_subnatid4_note_>;
gen subnatid4 = .;
*</_subnatid4_>;

*<_subnatidsurvey_>;
*<_subnatidsurvey_note_> Survey representation of geographical units *</_subnatidsurvey_note_>;
*<_subnatidsurvey_note_> subnatidsurvey brought in from SARMD *</_subnatidsurvey_note_>;
gen subnatidsurvey=.;
*</_subnatidsurvey_>;

*<_strata_>;
*<_strata_note_> Strata *</_strata_note_>;
*<_strata_note_> strata brought in from SARMD *</_strata_note_>;
*strata;
*</_strata_>;

*<_psu_>;
*<_psu_note_> PSU *</_psu_note_>;
*<_psu_note_> psu brought in from SARMD *</_psu_note_>;
*psu;
*</_psu_>;

*<_subnatid1_prev_>;
*<_subnatid1_prev_note_> Subnatid *</_subnatid1_prev_note_>;
*<_subnatid1_prev_note_> subnatid1_prev brought in from SARMD *</_subnatid1_prev_note_>;
gen subnatid1_prev=.;
*</_subnatid1_prev_>;

*<_subnatid2_prev_>;
*<_subnatid2_prev_note_> Subnatid *</_subnatid2_prev_note_>;
*<_subnatid2_prev_note_> subnatid2_prev brought in from SARMD *</_subnatid2_prev_note_>;
gen subnatid2_prev=.;
*</_subnatid2_prev_>;

*<_subnatid3_prev_>;
*<_subnatid3_prev_note_> Subnatid *</_subnatid3_prev_note_>;
*<_subnatid3_prev_note_> subnatid3_prev brought in from SARMD *</_subnatid3_prev_note_>;
gen subnatid3_prev=.;
*</_subnatid3_prev_>;

*<_subnatid4_prev_>;
*<_subnatid4_prev_note_> Subnatid *</_subnatid4_prev_note_>;
*<_subnatid4_prev_note_> subnatid4_prev brought in from SARMD *</_subnatid4_prev_note_>;
gen subnatid4_prev=.;
*</_subnatid4_prev_>;

*<_gaul_adm1_code_>;
*<_gaul_adm1_code_note_> Gaul Code *</_gaul_adm1_code_note_>;
*<_gaul_adm1_code_note_> gaul_adm1_code brought in from SARMD *</_gaul_adm1_code_note_>;
replace  gaul_adm1_code=gaul_adm1_code;
*</_gaul_adm1_code_>;

*<_gaul_adm2_code_>;
*<_gaul_adm2_code_note_> Gaul Code *</_gaul_adm2_code_note_>;
*<_gaul_adm2_code_note_> gaul_adm2_code brought in from SARMD *</_gaul_adm2_code_note_>;
*gen gaul_adm2_code=.;
*</_gaul_adm2_code_>;

*<_gaul_adm3_code_>;
*<_gaul_adm3_code_note_> Gaul Code *</_gaul_adm3_code_note_>;
*<_gaul_adm3_code_note_> gaul_adm3_code brought in from SARMD *</_gaul_adm3_code_note_>;
gen gaul_adm3_code=.;
*</_gaul_adm3_code_>;

*<_urban_>;
*<_urban_note_> Urban (1) or rural (0) *</_urban_note_>;
*<_urban_note_> urban brought in from SARMD *</_urban_note_>;
*urban;
*</_urban_>;

*<_Keep variables_>;
*keep countrycode year hhid pid weight weighttype subnatid1 subnatid2 subnatid3 subnatid4 subnatidsurvey strata psu subnatid1_prev subnatid2_prev subnatid3_prev subnatid4_prev gaul_adm1_code gaul_adm2_code gaul_adm3_code urban;
order countrycode year hhid pid weight weighttype;
sort hhid pid ;
*</_Keep variables_>;

*<_Save data file_>;
save "$rootdatalib\GMD\\`code'\\`yearfolder'\\`gmdfolder'\Data\Harmonized\\`filename'.dta" , replace;
*</_Save data file_>;
