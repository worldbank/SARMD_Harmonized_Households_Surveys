/*------------------------------------------------------------------------------
  GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   	BGD_2016_HIES_v01_M_v07_A_SARMD_DEM.do	   </_Program name_>
<_Application_>    	STATA 17.0									 <_Application_>
<_Author(s)_>      	Leo Tornarolli <tornarolli@gmail.com>		  </_Author(s)_>
<_Date created_>   	10-2023									   </_Date created_>
<_Date modified>   	March 2024							      </_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        	BGD											    </_Country_>
<_Survey Title_>   	HIES								       </_Survey Title_>
<_Survey Year_>    	2016										</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:				03-2024
File:				BGD_2016_HIES_v01_M_v07_A_SARMD_DEM.do
First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>
clear all
set more off

local code         		"BGD"
local year         		"2016"
local survey       		"HIES"
local vm           		"01"
local va           		"07"
local type         		"SARMD"
global module       	"DEM"
local yearfolder    	"`code'_`year'_`survey'"
local SARMDfolder    	"`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'"
local filename      	"`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'_${module}"
global output       	"${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\\Data\Harmonized" 
*</_Program setup_>


*<_Datalibweb request_>
use   "${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata\\`yearfolder'_v`vm'_M.dta", clear
egen  idp = concat(hhid idp1), punct(-)
sort  hhid idp
merge 1:1 hhid idp using "${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\Data\Harmonized\\`yearfolder'_v`vm'_M_v`va'_A_`type'_IND.dta" 
*</_Datalibweb request_>


*<_countrycode_>
*<_countrycode_note_> country code *</_countrycode_note_>
/*<_countrycode_note_> iso3 code upper letter *</_countrycode_note_>*/
*<_countrycode_note_> countrycode brought in from SARMD *</_countrycode_note_>
*</_countrycode_>

*<_year_>
*<_year_note_> Year *</_year_note_>
/*<_year_note_> field work start at *</_year_note_>*/
*<_year_note_> year brought in from SARMD *</_year_note_>
*</_year_>

*<_hhid_>
*<_hhid_note_> Household identifier  *</_hhid_note_>
/*<_hhid_note_> . *</_hhid_note_>*/
*<_hhid_note_> hhid brought in from SARMD *</_hhid_note_>
*</_hhid_>

*<_pid_>
*<_pid_note_> Personal identifier  *</_pid_note_>
/*<_pid_note_> country specific *</_pid_note_>*/
*<_pid_note_> pid brought in from SARMD *</_pid_note_>
*</_pid_>

*<_weight_>
*<_weight_note_> Household weight *</_weight_note_>
/*<_weight_note_> . *</_weight_note_>*/
*<_weight_note_> weight brought in from SARMD *</_weight_note_>
clonevar weight = wgt
*</_weight_>

*<_weighttype_>
*<_weighttype_note_> Weight type (frequency, probability, analytical, importance) *</_weighttype_note_>
/*<_weighttype_note_> . *</_weighttype_note_>*/
*<_weighttype_note_> weighttype brought in from SARMD *</_weighttype_note_>
*</_weighttype_>

*<_language_>
*<_language_note_> Language *</_language_note_>
/*<_language_note_> classification is country specific.  *</_language_note_>*/
*<_language_note_> language brought in from rawdata *</_language_note_>
gen   language = .
notes language: HIES 2016 does not collect information on language
*</_language_>

*<_age_>
*<_age_note_> Age of individual (continuous) *</_age_note_>
/*<_age_note_>  *</_age_note_>*/
*<_age_note_> age brought in from SARMD *</_age_note_>
*</_age_>

*<_agecat_>
*<_agecat_note_> Age of individual (categorical) *</_agecat_note_>
/*<_agecat_note_>  *</_agecat_note_>*/
*<_agecat_note_> agecat brought in from rawdata *</_agecat_note_>
gen   agecat = "."
notes agecat: missing given that in HIES 2016 age is captured as a continuous variable
*</_agecat_>

*<_male_>
*<_male_note_> Sex of household member (male=1) *</_male_note_>
/*<_male_note_>  1 " Male" 0 "Female" *</_male_note_>*/
*<_male_note_> male brought in from SARMD *</_male_note_>
*</_male_>

*<_relationharm_>
*<_relationharm_note_> Relationship to head of household harmonized across all regions *</_relationharm_note_>
/*<_relationharm_note_>  1 "Head" 2 "Spouse" 3 "Child" 4 "Parents" 5 "Other relative" 6 "Non-relative" *</_relationharm_note_>*/
*<_relationharm_note_> relationharm brought in from SARMD *</_relationharm_note_>
*</_relationharm_>

*<_relationcs_>
*<_relationcs_note_> Original relationship to head of household *</_relationcs_note_>
/*<_relationcs_note_> Clonevar of original variable *</_relationcs_note_>*/
*<_relationcs_note_> relationcs brought in from SARMD *</_relationcs_note_>
*</_relationcs_>

*<_marital_>
*<_marital_note_> Marital status *</_marital_note_>
/*<_marital_note_> 1 "Married" 2 "Never married" 3 "Living together" 4 "Divorced/Separated" 5 "Widowed" *</_marital_note_>*/
*<_marital_note_> marital brought in from SARMD *</_marital_note_>
*</_marital_>


*<_eye_dsablty_>
*<_eye_dsablty_note_> Difficulty seeing *</_eye_dsablty_note_>
/*<_eye_dsablty_note_>  1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all" *</_eye_dsablty_note_>*/
*<_eye_dsablty_note_> eye_dsablty brought in from rawdata: variable s1aq12 *</_eye_dsablty_note_>
gen eye_dsablty = s1aq12
*</_eye_dsablty_>

*<_hear_dsablty_>
*<_hear_dsablty_note_> Difficulty hearing *</_hear_dsablty_note_>
/*<_hear_dsablty_note_>  1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all" *</_hear_dsablty_note_>*/
*<_hear_dsablty_note_> hear_dsablty brought in from rawdata: variable s1aq13 *</_hear_dsablty_note_>
gen hear_dsablty = s1aq13
*</_hear_dsablty_>

*<_walk_dsablty_>
*<_walk_dsablty_note_> Difficulty walking or climbing steps *</_walk_dsablty_note_>
/*<_walk_dsablty_note_>  1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all" *</_walk_dsablty_note_>*/
*<_walk_dsablty_note_> walk_dsablty brought in from rawdata: variable s1aq14 *</_walk_dsablty_note_>
gen walk_dsablty = s1aq14
*</_walk_dsablty_>

*<_conc_dsord_>
*<_conc_dsord_note_> Difficulty remembering or concentrating *</_conc_dsord_note_>
/*<_conc_dsord_note_>  1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all" *</_conc_dsord_note_>*/
*<_conc_dsord_note_> conc_dsord brought in from rawdata: variable s1aq15 *</_conc_dsord_note_>
gen conc_dsord = s1aq15
*</_conc_dsord_>

*<_slfcre_dsablty_>
*<_slfcre_dsablty_note_> Difficulty with self-care *</_slfcre_dsablty_note_>
/*<_slfcre_dsablty_note_>  1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all" *</_slfcre_dsablty_note_>*/
*<_slfcre_dsablty_note_> slfcre_dsablty brought in from rawdata: variable s1aq16 *</_slfcre_dsablty_note_>
gen slfcre_dsablty = s1aq16
*</_slfcre_dsablty_>

*<_comm_dsablty_>
*<_comm_dsablty_note_> Difficulty communicating *</_comm_dsablty_note_>
/*<_comm_dsablty_note_>  1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all" *</_comm_dsablty_note_>*/
*<_comm_dsablty_note_> comm_dsablty brought in from rawdata: variable s1aq17 *</_comm_dsablty_note_>
gen comm_dsablty = s1aq17
*</_comm_dsablty_>


*<_Keep variables_>
order countrycode year hhid pid weight weighttype
sort  hhid pid
*</_Keep variables_>


*<_Save data file_>
quietly do 	"$rootdofiles\_aux\Labels_GMD2.0.do"
save 		"$output\\`filename'.dta", replace
*</_Save data file_>
