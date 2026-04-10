/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   BTN_2022_BLSS_v01_M_v01_A_SARMD_DEM.do	</_Program name_>
<_Application_>    STATA 16.0	<_Application_>
<_Author(s)_>      jogreen@worldbank.org	</_Author(s)_>
<_Date created_>   11-28-2022	</_Date created_>
<_Date modified>   11-28-2022	</_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        BTN	</_Country_>
<_Survey Title_>   BLSS	</_Survey Title_>
<_Survey Year_>    2022	</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:	11-28-2022
File:	BTN_2022_BLSS_v01_M_v01_A_SARMD_DEM.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>
clear all
set more off

local code         "BTN"
local year         2022
local survey       "BLSS"
local vm           "01"
local va           "02"
local type         "SARMD"
global module       	"DEM"
local yearfolder    "`code'_`year'_`survey'"
local SARMDfolder    "`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'"
local filename      "`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'_${module}"
glo output          "${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\\Data\Harmonized" 
*</_Program setup_>

*<_Datalibweb request_>
	* weights
	datalibweb, country(`code') year(`year') type(SARRAW) filename(weights) local localpath(${rootdatalib})
	tempfile weight
	save `weight'
	
	* merge in main data
	datalibweb, country(`code') year(`year') type(SARRAW) filename(`yearfolder'_v`vm'_M.dta) local localpath(${rootdatalib})

	* The weights variable in the BTN_2022_BLSS_v01_M file is the old weights variable, so remove it.
	drop weight weights
	merge m:1 interview__id using `weight', nogen assert(match)
	tempfile base 
	save `base'
	
	use "${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\Data\Harmonized\\`yearfolder'_v`vm'_M_v`va'_A_`type'_IND.dta" 
	merge 1:1 hhid pid using `base', nogen
*</_Datalibweb request_>

*<_countrycode_>
*<_countrycode_note_> country code *</_countrycode_note_>
*<_countrycode_note_> countrycode brought in from rawdata *</_countrycode_note_>
* NOTE: this variable already exists in harmonized form
cap gen countrycode="`code'"
*</_countrycode_>

*<_year_>
*<_year_note_> Year *</_year_note_>
*<_year_note_> year brought in from rawdata *</_year_note_>
* NOTE: this variable already exists in harmonized form
confirm var  year
*</_year_>

*<_hhid_>
*<_hhid_note_> Household identifier  *</_hhid_note_>
*<_hhid_note_> hhid brought in from rawdata *</_hhid_note_>
* NOTE: this variable already exists in harmonized form
confirm var  hhid
*</_hhid_>

*<_pid_>
*<_pid_note_> Personal identifier  *</_pid_note_>
*<_pid_note_> pid brought in from rawdata *</_pid_note_>
* NOTE: this variable already exists in harmonized form
confirm var  pid
*</_pid_>

*<_weight_>
*<_weight_note_> Household weight *</_weight_note_>
*<_weight_note_> weight brought in from rawdata *</_weight_note_>
* NOTE: this variable already exists in harmonized form
clonevar weight = weights
*</_weight_>

*<_weighttype_>
*<_weighttype_note_> Weight type (frequency, probability, analytical, importance) *</_weighttype_note_>
*<_weighttype_note_> weighttype brought in from rawdata *</_weighttype_note_>
* NOTE: this variable already exists in harmonized form
confirm var  weighttype
*</_weighttype_>

*<_language_>
*<_language_note_> Language *</_language_note_>
*<_language_note_> language brought in from rawdata *</_language_note_>
local 2 "English"
local 3 "Lhotsham"
local 4 "Other language (not Dzongkha, English, or Lhotsham)"
g		language = "Dzongkha" if ed1__1==1
forval lg = 2/4 {
	replace	language = language + ", & ``lg''" if ed1__`lg'==1 & ~missing(language)
	replace	language = "``lg''" if ed1__`lg'==1 & missing(language)
}
*</_language_>

*<_age_>
*<_age_note_> Age of individual (continuous) *</_age_note_>
*<_age_note_> age brought in from rawdata *</_age_note_>
* NOTE: this variable already exists in harmonized form
confirm var  age
*</_age_>

*<_agecat_>
*<_agecat_note_> Age of individual (categorical) *</_agecat_note_>
*<_agecat_note_> agecat brought in from rawdata *</_agecat_note_>
gen agecat=.
*</_agecat_>

*<_male_>
*<_male_note_> Sex of household member (male=1) *</_male_note_>
*<_male_note_> male brought in from rawdata *</_male_note_>
*recode d1 (1=1) (2=0) (*=.), g(male)
*</_male_>

*<_relationharm_>
*<_relationharm_note_> Relationship to head of household harmonized across all regions *</_relationharm_note_>
*<_relationharm_note_> relationharm brought in from rawdata *</_relationharm_note_>
cap recode d2 (1=1) (2=2) (3/4=3) (5/6=4) (7/31=5) (32/33=6) (*=.), g(relationharm)
*</_relationharm_>

*<_relationcs_>
*<_relationcs_note_> Original relationship to head of household *</_relationcs_note_>
*<_relationcs_note_> relationcs brought in from rawdata *</_relationcs_note_>
cap clonevar relationcs = d2
*</_relationcs_>

*<_marital_>
*<_marital_note_> Marital status *</_marital_note_>
*<_marital_note_> marital brought in from rawdata *</_marital_note_>
*recode d4 (1=2) (2=3) (3=1) (4/5=4) (6=5) (*=.), g(marital)
*</_marital_>

*<_eye_dsablty_>
*<_eye_dsablty_note_> Difficulty seeing *</_eye_dsablty_note_>
*<_eye_dsablty_note_> eye_dsablty brought in from rawdata *</_eye_dsablty_note_>
gen eye_dsablty = .
*</_eye_dsablty_>

*<_hear_dsablty_>
*<_hear_dsablty_note_> Difficulty hearing *</_hear_dsablty_note_>
*<_hear_dsablty_note_> hear_dsablty brought in from rawdata *</_hear_dsablty_note_>
gen hear_dsablty = .
*</_hear_dsablty_>

*<_walk_dsablty_>
*<_walk_dsablty_note_> Difficulty walking or climbing steps *</_walk_dsablty_note_>
*<_walk_dsablty_note_> walk_dsablty brought in from rawdata *</_walk_dsablty_note_>
gen walk_dsablty = .
*</_walk_dsablty_>

*<_conc_dsord_>
*<_conc_dsord_note_> Difficulty remembering or concentrating *</_conc_dsord_note_>
*<_conc_dsord_note_> conc_dsord brought in from rawdata *</_conc_dsord_note_>
gen conc_dsord = .
*</_conc_dsord_>

*<_slfcre_dsablty_>
*<_slfcre_dsablty_note_> Difficulty with self-care *</_slfcre_dsablty_note_>
*<_slfcre_dsablty_note_> slfcre_dsablty brought in from rawdata *</_slfcre_dsablty_note_>
gen slfcre_dsablty = .
*</_slfcre_dsablty_>

*<_comm_dsablty_>
*<_comm_dsablty_note_> Difficulty communicating *</_comm_dsablty_note_>
*<_comm_dsablty_note_> comm_dsablty brought in from rawdata *</_comm_dsablty_note_>
gen comm_dsablty = .
*</_comm_dsablty_>

*<_Keep variables_>
*keep countrycode year hhid pid weight weighttype language age agecat male relationharm relationcs marital eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty
order countrycode year hhid pid weight weighttype
sort hhid pid 
isid hhid pid
*</_Keep variables_>


*<_Save data file_>
quietly do 	"$rootdofiles\_aux\Labels_GMD2.0.do"
save "$output\\`filename'.dta", replace
*</_Save data file_>

