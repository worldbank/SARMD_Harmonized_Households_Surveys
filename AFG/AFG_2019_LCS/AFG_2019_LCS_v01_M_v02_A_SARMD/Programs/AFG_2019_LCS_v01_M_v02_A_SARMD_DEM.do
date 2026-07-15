/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   AFG_2019_LCS_v01_M_v01_A_GMD_DEM.do	</_Program name_>
<_Application_>    STATA 16.0	<_Application_>
<_Author(s)_>      jogreen@worldbank.org	</_Author(s)_>
<_Date created_>   05-25-2020	</_Date created_>
<_Date modified>   08-08-2021	</_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        AFG	</_Country_>
<_Survey Title_>   LCS	</_Survey Title_>
<_Survey Year_>    2019	</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:	08-08-2021
File:	AFG_2019_LCS_v01_M_v01_A_GMD_DEM.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/
*<_Program setup_>
clear all
set more off

local code         "AFG"
local year         "2019"
local survey       "LCS"
local vm           "01"
local va           "02"
local type         "SARMD"
local yearfolder   "`code'_`year'_`survey'"
local harmfolder   "`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'"
local filename     "`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'_DEM"
	glo output "${rootdatalib}\\`code'\\`yearfolder'\\`harmfolder'\Data\Harmonized"

*</_Program setup_>

* global path on Joe's computer
if ("`c(username)'"=="dekopon") {
	glo basepath "/Users/dekopon/Projects/WORLD BANK/SAR - GMD data harmonization/datalib/`code'/`yearfolder'"
	glo input "${basepath}/`yearfolder'_v`vm'_M"
	glo output "${basepath}/`yearfolder'_v`vm'_M_v`va'_A_SARGMD/Data/Harmonized"
	
	* load and merge relevant data
	cd "${input}/Data/Stata"
	* roster data
	use "roster_male.dta", clear
	* disability data
	merge 1:1 HH_ID Mem_ID using "disability", nogen assert(match)
	* household data
	merge m:1 HH_ID using "household_male", nogen assert(match)
	rename HH_ID hhid_orig
	destring hhid, g(HH_ID)	//note: need to fill in hhid if subsequent merged data contains umatched observations.
	* weight data
	merge m:1 HH_ID using "clusters", nogen assert(match)
}
* global paths on WB computer
else {
	*<_Folder creation_>
	*</_Folder creation_>
	
	
	
	*<_Datalibweb request_>
	use "${rootdatalib}\\`code'\\`code'_`year'_`survey'\\`code'_`year'_`survey'_v`vm'_M\Data\Stata\\`code'_`year'_`survey'_M.dta", clear 
	
	preserve
	use "$rootdatalib\\`code'\\`yearfolder'\\`harmfolder'\Data\Harmonized\\`yearfolder'_v`vm'_M_v`va'_A_SARMD_IND.dta", clear
	clonevar hhid_orig=idh_org
	clonevar Mem_ID   =pid 
	tempfile SARMDIND
	save     `SARMDIND'	
	restore 
	merge m:1 hhid_orig Mem_ID using `SARMDIND', gen(m_IND)
	

	
	/*
	tempfile individual_level_data
	local dlw "datalibweb, country(`code') year(`year') type(SARRAW) surveyid(`code'_`year'_`survey'_v`vm'_M)"
	*qui `dlw' filename(temp_pov_2016_2019_consolidated.dta)
	use "${rootdatalib}\\`code'\\`code'_`year'_`survey'\\`code'_`year'_`survey'_v01_M\Data\Stata\temp_pov_2016_2019_consolidated.dta", clear 
	keep if year==`year'
	drop year
	rename hhid HH_ID
	save `individual_level_data'	//NOTE: The poverty data is actually HH-level data, but will be merged into individual-level data in the next step.
	* roster data
	* NOTE: some individuals do not have poverty data. 
	local dlw "datalibweb, country(`code') year(`year') type(SARRAW) surveyid(`code'_`year'_`survey'_v`vm'_M)"
	`dlw' filename(roster_male.dta)
	merge m:1 HH_ID using `individual_level_data', gen(m_pov_roster) 
	save `individual_level_data', replace
	* disability data
	local dlw "datalibweb, country(`code') year(`year') type(SARRAW) surveyid(`code'_`year'_`survey'_v`vm'_M)"
	`dlw' filename(disability.dta)
	merge 1:1 HH_ID Mem_ID using `individual_level_data', nogen 
	save `individual_level_data', replace
	* household data
	local dlw "datalibweb, country(`code') year(`year') type(SARRAW) surveyid(`code'_`year'_`survey'_v`vm'_M)"
	`dlw' filename(household_male.dta)
	merge 1:m HH_ID using `individual_level_data', nogen 
	rename HH_ID hhid_orig
	destring hhid_orig, g(HH_ID)	//note: need to fill in hhid if subsequent merged data contains umatched observations.
	save `individual_level_data', replace
	* weight data
	local dlw "datalibweb, country(`code') year(`year') type(SARRAW) surveyid(`code'_`year'_`survey'_v`vm'_M)"
	`dlw' filename(clusters.dta)
	merge 1:m HH_ID using `individual_level_data', nogen update replace
	*/
	*</_Datalibweb request_>
}

*<_countrycode_>
*<_countrycode_note_> country code *</_countrycode_note_>
*<_countrycode_note_> countrycode brought in from rawdata *</_countrycode_note_>
*g countrycode = "`code'"
*</_countrycode_>

*<_year_>
*<_year_note_> Year *</_year_note_>
*<_year_note_> year brought in from rawdata *</_year_note_>
*g year = `year'
*</_year_>

*<_hhid_>
*<_hhid_note_> Household identifier  *</_hhid_note_>
*<_hhid_note_> hhid brought in from rawdata *</_hhid_note_>
*clonevar hhid = hhid_orig
*</_hhid_>

*<_pid_>
*<_pid_note_> Personal identifier  *</_pid_note_>
*<_pid_note_> pid brought in from rawdata *</_pid_note_>
*clonevar pid = Mem_ID
*</_pid_>

*<_weight_>
*<_weight_note_> Household weight *</_weight_note_>
*<_weight_note_> weight brought in from rawdata *</_weight_note_>
clonevar weight = hh_weight
*</_weight_>

*<_weighttype_>
*<_weighttype_note_> Weight type (frequency, probability, analytical, importance) *</_weighttype_note_>
*<_weighttype_note_> weighttype brought in from rawdata *</_weighttype_note_>
*g weighttype = "PW"
*</_weighttype_>

*<_language_>
*<_language_note_> Language *</_language_note_>
*<_language_note_> language brought in from rawdata *</_language_note_>
gen language=.
note language: AFG 2019 does not have any relevant questions or variables.
*</_language_>

*<_age_>
*<_age_note_> Age of individual (continuous) *</_age_note_>
*<_age_note_> age brought in from rawdata *</_age_note_>
*gen age = q202
*</_age_>

*<_agecat_>
*<_agecat_note_> Age of individual (categorical) *</_agecat_note_>
*<_agecat_note_> agecat brought in from rawdata *</_agecat_note_>
gen agecat=.
note agecat: AFG 2019 has continuous ages.
*</_agecat_>

*<_male_>
*<_male_note_> Sex of household member (male=1) *</_male_note_>
*<_male_note_> male brought in from rawdata *</_male_note_>
*g male = (q203==1) if inlist(q203,1,2)
*</_male_>

*<_relationharm_>
*<_relationharm_note_> Relationship to head of household harmonized across all regions *</_relationharm_note_>
*<_relationharm_note_> relationharm brought in from rawdata *</_relationharm_note_>
*recode q201r (1=1) (2=2) (3=3) (4/5 7/10=5) (6=4) (11=6) (*=.), g(relationharm)
*</_relationharm_>

*<_relationcs_>
*<_relationcs_note_> Original relationship to head of household *</_relationcs_note_>
*<_relationcs_note_> relationcs brought in from rawdata *</_relationcs_note_>
*clonevar relationcs = q201r
*</_relationcs_>

*<_marital_>
*<_marital_note_> Marital status *</_marital_note_>
*<_marital_note_> marital brought in from rawdata *</_marital_note_>
*recode q204 (1=1) (2=4) (3=5) (4/5=2) (*=.), g(marital)
*</_marital_>

*<_eye_dsablty_>
*<_eye_dsablty_note_> Difficulty seeing *</_eye_dsablty_note_>
*<_eye_dsablty_note_> eye_dsablty brought in from rawdata *</_eye_dsablty_note_>
gen eye_dsablty = q2207 if inrange(q2207,1,4)
*</_eye_dsablty_>

*<_hear_dsablty_>
*<_hear_dsablty_note_> Difficulty hearing *</_hear_dsablty_note_>
*<_hear_dsablty_note_> hear_dsablty brought in from rawdata *</_hear_dsablty_note_>
gen hear_dsablty = q2209 if inrange(q2209,1,4)
*</_hear_dsablty_>

*<_walk_dsablty_>
*<_walk_dsablty_note_> Difficulty walking or climbing steps *</_walk_dsablty_note_>
*<_walk_dsablty_note_> walk_dsablty brought in from rawdata *</_walk_dsablty_note_>
gen walk_dsablty = q2211 if inrange(q2211,1,4)
*</_walk_dsablty_>

*<_conc_dsord_>
*<_conc_dsord_note_> Difficulty remembering or concentrating *</_conc_dsord_note_>
*<_conc_dsord_note_> conc_dsord brought in from rawdata *</_conc_dsord_note_>
gen conc_dsord = q2215 if inrange(q2215,1,4)
*</_conc_dsord_>

*<_slfcre_dsablty_>
*<_slfcre_dsablty_note_> Difficulty with self-care *</_slfcre_dsablty_note_>
*<_slfcre_dsablty_note_> slfcre_dsablty brought in from rawdata *</_slfcre_dsablty_note_>
gen slfcre_dsablty = q2213 if inrange(q2213,1,4)
*</_slfcre_dsablty_>

*<_comm_dsablty_>
*<_comm_dsablty_note_> Difficulty communicating *</_comm_dsablty_note_>
*<_comm_dsablty_note_> comm_dsablty brought in from rawdata *</_comm_dsablty_note_>
gen comm_dsablty = q2217 if inrange(q2217,1,4)
*</_comm_dsablty_>

*<_Keep variables_>
*keep countrycode year hhid pid weight weighttype language age agecat male relationharm relationcs marital eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty
order countrycode year hhid pid weight weighttype
sort hhid pid 
*</_Keep variables_>

*<_Save data file_>
do   "P:\SARMD\SARDATABANK\SARMDdofiles\_aux\Labels_GMD2.0.do"
*do 	 "$rootdatalib\\`code'\\`yearfolder'\\`SARMDfolder'\Programs\Labels_GMD2.0.do"
save "${rootdatalib}\\`code'\\`yearfolder'\\`harmfolder'\Data\Harmonized\\`filename'.dta" , replace
*</_Save data file_>
