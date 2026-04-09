/*------------------------------------------------------------------------------
  GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   	LKA_2019_HIES_v01_M_v03_A_SARMD_DEM.do	   </_Program name_>
<_Application_>    	STATA 17.0									 <_Application_>
<_Author(s)_>       Joe Green 		<jogreen@worldbank.org>		  </_Author(s)_>
<_Date created_>    06-2022	                                   </_Date created_>
<_Author(s)_>      	Leo Tornarolli 	<tornarolli@gmail.com>		  </_Author(s)_>
<_Date modified_>   10-2024									  </_Date modified_>
<_Date modified>    October 2023							  </_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        	LKA											    </_Country_>
<_Survey Title_>   	HIES									   </_Survey Title_>
<_Survey Year_>    	2019										</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:				10-2024
File:				LKA_2019_HIES_v01_M_v03_A_SARMD_DEM.do
First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>
clear all
set more off

local code         		"LKA"
local year         		"2019"
local survey       		"HIES"
local vm           		"01"
local va           		"03"
local type         		"SARMD"
global module       	"DEM"
local yearfolder    	"`code'_`year'_`survey'"
local SARMDfolder    	"`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'"
local filename      	"`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'_${module}"
glo output          	"${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\\Data\Harmonized" 
*</_Program setup_>



*<_Datalibweb request_>
use   "${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata\\`yearfolder'_v`vm'_M.dta", clear
sort  hhid pid
merge 1:1 hhid pid using "${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\Data\Harmonized\\`yearfolder'_v`vm'_M_v`va'_A_`type'_IND.dta" 
drop _merge
*</_Datalibweb request_>


*<_countrycode_>
*<_countrycode_note_> country code *</_countrycode_note_>
*<_countrycode_note_> countrycode brought in from rawdata *</_countrycode_note_>
*</_countrycode_>

*<_year_>
*<_year_note_> Year *</_year_note_>
*<_year_note_> year brought in from rawdata *</_year_note_>
* NOTE: this variable already exists in harmonized form
*</_year_>

*<_hhid_>
*<_hhid_note_> Household identifier  *</_hhid_note_>
*<_hhid_note_> hhid brought in from rawdata *</_hhid_note_>
* NOTE: this variable already exists in harmonized form
*</_hhid_>

*<_pid_>
*<_pid_note_> Personal identifier  *</_pid_note_>
*<_pid_note_> pid brought in from rawdata *</_pid_note_>
* NOTE: this variable already exists in harmonized form
*</_pid_>

*<_weight_>
*<_weight_note_> Household weight *</_weight_note_>
*<_weight_note_> weight brought in from rawdata *</_weight_note_>
clonevar weight = finalweight
*</_weight_>

*<_weighttype_>
*<_weighttype_note_> Weight type (frequency, probability, analytical, importance) *</_weighttype_note_>
*<_weighttype_note_> weighttype brought in from rawdata *</_weighttype_note_>
*</_weighttype_>

*<_language_>
*<_language_note_> Language *</_language_note_>
*<_language_note_> language brought in from rawdata *</_language_note_>
gen  language = .
note language: LKA_2019_HIES does not have any relevant questions or variables.
*</_language_>

*<_age_>
*<_age_note_> Age of individual (continuous) *</_age_note_>
*<_age_note_> age brought in from rawdata *</_age_note_>
* NOTE: this variable already exists in harmonized form
*</_age_>

*<_agecat_>
*<_agecat_note_> Age of individual (categorical) *</_agecat_note_>
*<_agecat_note_> agecat brought in from rawdata *</_agecat_note_>
gen  agecat = .
note agecat: LKA 2019 has continuous ages.
*</_agecat_>

*<_male_>
*<_male_note_> Sex of household member (male=1) *</_male_note_>
*<_male_note_> male brought in from rawdata *</_male_note_>
*recode sex (1=1) (2=0) (*=.), g(male)
*</_male_>

*<_relationharm_>
*<_relationharm_note_> Relationship to head of household harmonized across all regions *</_relationharm_note_>
*<_relationharm_note_> relationharm brought in from rawdata *</_relationharm_note_>
*</_relationharm_>

*<_relationcs_>
*<_relationcs_note_> Original relationship to head of household *</_relationcs_note_>
*<_relationcs_note_> relationcs brought in from rawdata *</_relationcs_note_>
*</_relationcs_>

*<_marital_>
*<_marital_note_> Marital status *</_marital_note_>
*<_marital_note_> marital brought in from rawdata *</_marital_note_>
*</_marital_>

*<_eye_dsablty_>
*<_eye_dsablty_note_> Difficulty seeing *</_eye_dsablty_note_>
*<_eye_dsablty_note_> eye_dsablty brought in from rawdata *</_eye_dsablty_note_>
gen eye_dsablty = s3b_a
*</_eye_dsablty_>

*<_hear_dsablty_>
*<_hear_dsablty_note_> Difficulty hearing *</_hear_dsablty_note_>
*<_hear_dsablty_note_> hear_dsablty brought in from rawdata *</_hear_dsablty_note_>
gen hear_dsablty = s3b_6
*</_hear_dsablty_>

*<_walk_dsablty_>
*<_walk_dsablty_note_> Difficulty walking or climbing steps *</_walk_dsablty_note_>
*<_walk_dsablty_note_> walk_dsablty brought in from rawdata *</_walk_dsablty_note_>
gen walk_dsablty = s3b_7
*</_walk_dsablty_>

*<_conc_dsord_>
*<_conc_dsord_note_> Difficulty remembering or concentrating *</_conc_dsord_note_>
*<_conc_dsord_note_> conc_dsord brought in from rawdata *</_conc_dsord_note_>
gen conc_dsord = s3b_10
*</_conc_dsord_>

*<_slfcre_dsablty_>
*<_slfcre_dsablty_note_> Difficulty with self-care *</_slfcre_dsablty_note_>
*<_slfcre_dsablty_note_> slfcre_dsablty brought in from rawdata *</_slfcre_dsablty_note_>
gen slfcre_dsablty = s3b_11
*</_slfcre_dsablty_>

*<_comm_dsablty_>
*<_comm_dsablty_note_> Difficulty communicating *</_comm_dsablty_note_>
*<_comm_dsablty_note_> comm_dsablty brought in from rawdata *</_comm_dsablty_note_>
gen comm_dsablty = s3b_12
*</_comm_dsablty_>

*<_cellphone_i_>
*<_cellphone_i_note_> Ownership of a cell phone (individual) *</_cellphone_i_note_>
*<_cellphone_i_note_> cellphone_i brought in from rawdata *</_cellphone_i_note_>
gen cellphone_i=.
note cellphone_i: LKA 2019 asks about cell phone ownership at the HH-level only.
*</_cellphone_i_>


*<_Keep variables_>
order countrycode year hhid pid weight weighttype
sort  hhid pid
*</_Keep variables_>


*<_Save data file_>
quietly do 	"$rootdofiles\_aux\Labels_GMD2.0.do"
save 		"$output\\`filename'.dta", replace
*</_Save data file_>
