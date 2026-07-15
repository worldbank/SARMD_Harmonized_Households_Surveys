/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   `code'_`year'_`survey'_v01_M_v01_A_GMD_COR.do	</_Program name_>
<_Application_>    STATA 16.0	<_Application_>
<_Author(s)_>      jogreen@worldbank.org	</_Author(s)_>
<_Date created_>   05-25-2021	</_Date created_>
<_Date modified>   09-08 2021	</_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        `code'	</_Country_>
<_Survey Title_>   `survey'	</_Survey Title_>
<_Survey Year_>    `year'	</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:	05-25-2020
File:	`code'_`year'_`survey'_v01_M_v01_A_`type'_COR.do
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
glo output         "${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata"
*</_Program setup_>

* global path on Joe's computer
if ("`c(username)'"=="dekopon") {
	glo basepath "/Users/dekopon/Projects/WORLD BANK/SAR - GMD data harmonization/datalib/`code'/`yearfolder'"
	glo input "${basepath}/`yearfolder'_v`vm'_M"
	glo output "${basepath}/`yearfolder'_v`vm'_M/Data/Stata"
	
                      
	* load and merge relevant data
	cd "${input}/Data/Stata"
	* poverty data
	use "temp_pov_2016_`year'_consolidated" if year==`year', clear
	* remove variables defined in the main section below
	drop year
	rename hhid HH_ID
	* roster data
	* NOTE: some individuals do not have poverty data.
	merge 1:m HH_ID using "roster_male.dta", nogen assert(using match)
	* disability data
	merge 1:1 HH_ID Mem_ID using "disability", nogen assert(match)
	rename HH_ID hhid_orig
	destring hhid_orig, g(HH_ID)	//note: need to fill in hhid if subsequent merged data contains umatched observations.
	* weight data
	merge m:1 HH_ID using "clusters", nogen assert(match)
}
* global paths on WB computer
else {
	*<_Folder creation_>
	/*
	cap mkdir "${rootdatalib}"
	cap mkdir "${rootdatalib}\\`code'"
	cap mkdir "${rootdatalib}\\`code'\\`yearfolder'"
	cap mkdir "${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M"
	cap mkdir "${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data"
	cap mkdir "${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata"
	*/
	*</_Folder creation_>
	
	*<_Datalibweb request_>
	* load and merge relevant data
	
	* poverty data
	tempfile individual_level_data
	local dlw "datalibweb, country(`code') year(`year') type(SARRAW) surveyid(`code'_`year'_`survey'_v`vm'_M)"
	*qui `dlw' filename(temp_pov_2016_2019_consolidated.dta)
	use "${rootdatalib}\\`code'\\`code'_`year'_`survey'\\`code'_`year'_`survey'_v`vm'_M\Data\Stata\temp_pov_2016_2019_consolidated.dta", clear 
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
	rename HH_ID hhid_orig
	destring hhid_orig, g(HH_ID)	//note: need to fill in hhid if subsequent merged data contains umatched observations.
	save `individual_level_data', replace
	
	
	* weight data
	local dlw "datalibweb, country(`code') year(`year') type(SARRAW) surveyid(`code'_`year'_`survey'_v`vm'_M)"
	`dlw' filename(clusters.dta)
	merge 1:m HH_ID using `individual_level_data', nogen  update replace
	*</_Datalibweb request_>
	*/
}

*<_Save data file_>
compress
if ("`c(username)'"=="dekopon") save "${output}/`yearfolder'_M.dta", replace
else save "${output}/`yearfolder'_M.dta" , replace
*</_Save data file_>
