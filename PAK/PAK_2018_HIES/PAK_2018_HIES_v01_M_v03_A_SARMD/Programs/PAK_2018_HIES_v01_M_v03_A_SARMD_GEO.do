/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   PAK_2018_PSLM_v_M_v_A_GMD_GEO.do	</_Program name_>
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
File:	PAK_2018_PSLM_v_M_v_A_GMD_GEO.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>
cap log close 
clear all
set more off

local code         "PAK"
local year         "2018"
local survey       "HIES"
local vm           "01"
local va           "03"
local type         "SARMD"
global module       	"GEO"
local yearfolder    "`code'_`year'_`survey'"
local SARMDfolder    "`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'"
local filename      "`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'_${module}"
glo output          "${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\\Data\Harmonized" 
*</_Program setup_>


*<_Datalibweb request_>
use "${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\Data\Harmonized\\`yearfolder'_v`vm'_M_v`va'_A_`type'_IND.dta" , clear 
*</_Datalibweb request_>


*<_countrycode_>
*<_countrycode_note_> country code *</_countrycode_note_>
*<_countrycode_note_> countrycode brought in from SARMD *</_countrycode_note_>
*replace code=countrycode
*</_countrycode_>

*<_year_>
*<_year_note_> Year *</_year_note_>
*<_year_note_> year brought in from SARMD *</_year_note_>
replace year=year
*</_year_>

*<_hhid_>
*<_hhid_note_> Household identifier  *</_hhid_note_>
*<_hhid_note_> hhid brought in from SARMD *</_hhid_note_>
*clonevar hhid=idh
*</_hhid_>

*<_pid_>
*<_pid_note_> Personal identifier  *</_pid_note_>
*<_pid_note_> pid brought in from rawdata *</_pid_note_>
*clonevar pid  = idp
*</_pid_>

*<_weight_>
*<_weight_note_> Household weight *</_weight_note_>
*<_weight_note_> weight brought in from rawdata *</_weight_note_>
clonevar  weights=wgt
*</_weight_>

*<_weighttype_>
*<_weighttype_note_> Weight type (frequency, probability, analytical, importance) *</_weighttype_note_>
*<_weighttype_note_> weighttype brought in from rawdata *</_weighttype_note_>
*gen weighttype = "IW"
*</_weighttype_>

*<_subnatid1_>
*<_subnatid1_note_> Subnational ID - highest level *</_subnatid1_note_>
*<_subnatid1_note_> subnatid1 brought in from SARMD *</_subnatid1_note_>
/*
gen subnatid1_new=subnatid1
tostring subnatid1_new, replace
replace subnatid1_new="1 - Punjab" 				if subnatid1==1
replace subnatid1_new="2 - Sindh"  				if subnatid1==2
replace subnatid1_new="3 - Khyber Pakhtunkhwa"  if subnatid1==3
replace subnatid1_new="4 - Balochistan" 		if subnatid1==4
drop subnatid1
rename subnatid1_new subnatid1
*/
*</_subnatid1_>

*<_subnatid2_>
*<_subnatid2_note_> Subnational ID - second highest level *</_subnatid2_note_>
*<_subnatid2_note_> subnatid2 brought in from SARMD *</_subnatid2_note_>
*rename subnatid2 subnatid2
*</_subnatid2_>

*<_subnatid3_>
*<_subnatid3_note_> Subnational ID - third highest level *</_subnatid3_note_>
*<_subnatid3_note_> subnatid3 brought in from SARMD *</_subnatid3_note_>
*rename subnatid3 subnatid3
*</_subnatid3_>

*<_subnatid4_>
*<_subnatid4_note_> Subnational ID - lowest level *</_subnatid4_note_>
*<_subnatid4_note_> subnatid4 brought in from SARMD *</_subnatid4_note_>
*gen subnatid4 = .
*</_subnatid4_>

*<_subnatidsurvey_>
*<_subnatidsurvey_note_> Survey representation of geographical units *</_subnatidsurvey_note_>
*<_subnatidsurvey_note_> subnatidsurvey brought in from SARMD *</_subnatidsurvey_note_>
gen subnatidsurvey=.
*</_subnatidsurvey_>

*<_strata_>
*<_strata_note_> Strata *</_strata_note_>
*<_strata_note_> strata brought in from SARMD *</_strata_note_>
cap rename stratum strata
	cap confirm var strata
	if (_rc) gen strata = .
*</_strata_>

*<_psu_>
*<_psu_note_> PSU *</_psu_note_>
*<_psu_note_> psu brought in from SARMD *</_psu_note_>
*</_psu_>

*<_subnatid1_prev_>
*<_subnatid1_prev_note_> Subnatid *</_subnatid1_prev_note_>
*<_subnatid1_prev_note_> subnatid1_prev brought in from SARMD *</_subnatid1_prev_note_>
gen subnatid1_prev=.
*</_subnatid1_prev_>

*<_subnatid2_prev_>
*<_subnatid2_prev_note_> Subnatid *</_subnatid2_prev_note_>
*<_subnatid2_prev_note_> subnatid2_prev brought in from SARMD *</_subnatid2_prev_note_>
gen subnatid2_prev=.
*</_subnatid2_prev_>

*<_subnatid3_prev_>
*<_subnatid3_prev_note_> Subnatid *</_subnatid3_prev_note_>
*<_subnatid3_prev_note_> subnatid3_prev brought in from SARMD *</_subnatid3_prev_note_>
gen subnatid3_prev=.
*</_subnatid3_prev_>

*<_subnatid4_prev_>
*<_subnatid4_prev_note_> Subnatid *</_subnatid4_prev_note_>
*<_subnatid4_prev_note_> subnatid4_prev brought in from SARMD *</_subnatid4_prev_note_>
gen subnatid4_prev=.
*</_subnatid4_prev_>

*<_gaul_adm1_code_>
*<_gaul_adm1_code_note_> Gaul Code *</_gaul_adm1_code_note_>
*<_gaul_adm1_code_note_> gaul_adm1_code brought in from SARMD *</_gaul_adm1_code_note_>
cap gen gaul_adm1_code=.
*</_gaul_adm1_code_>

*<_gaul_adm2_code_>
*<_gaul_adm2_code_note_> Gaul Code *</_gaul_adm2_code_note_>
*<_gaul_adm2_code_note_> gaul_adm2_code brought in from SARMD *</_gaul_adm2_code_note_>
gen gaul_adm2_code=.
*</_gaul_adm2_code_>

*<_gaul_adm3_code_>
*<_gaul_adm3_code_note_> Gaul Code *</_gaul_adm3_code_note_>
*<_gaul_adm3_code_note_> gaul_adm3_code brought in from SARMD *</_gaul_adm3_code_note_>
gen gaul_adm3_code=.
*</_gaul_adm3_code_>

*<_urban_>
*<_urban_note_> Urban (1) or rural (0) *</_urban_note_>
*<_urban_note_> urban brought in from SARMD *</_urban_note_>
*rename urban urban
*</_urban_>

clonevar hhid_orig = idh_org
clonevar pid_orig = idp_org
g weight = wgt

*<_Save data file_>
quietly do 	"$rootdofiles\_aux\Labels_GMD2.0.do"
save "$output\\`filename'.dta", replace
*</_Save data file_>
