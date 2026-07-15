/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   `code'_`year'_`survey'_v01_M.do	</_Program name_>
<_Application_>    STATA 16.0	<_Application_>
<_Author(s)_>      jogreen@worldbank.org	</_Author(s)_>
<_Date created_>   12-11-2023	</_Date created_>
<_Date modified>   12-11-2023	</_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        `code'	</_Country_>
<_Survey Title_>   `survey'	</_Survey Title_>
<_Survey Year_>    `year'	</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:	12-11-2023
File:	`code'_`year'_`survey'_v01_M_v01_A_`type'_COR.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>
clear all
set more off

local	code         "AFG"
local	year         "2013"
local	survey       "LCS"
local	vm           "01"
local	va           "04"
local	type         "SARMD"
local	yearfolder   "`code'_`year'_`survey'"
*</_Program setup_>

* global path on Joe's computer
if ("`c(username)'"=="sunquat") {
	glo basepath "/Users/`c(username)'/Projects/WORLD BANK/2023 SAR QCHECK/SARDATABANK/WORKINGDATA/`code'/`yearfolder'"
	glo input "${basepath}/`yearfolder'_v`vm'_M/Data/Stata"
	glo output "${input}"
	
	* load and merge relevant data (note: removed roster_male.dta and clusters.dta as it was not used in the updated WB computer code)
	
}
* global paths on WB computer
else {
	glo input "${rootdatalib}/`code'/`yearfolder'/`yearfolder'_v`vm'_M/Data/Stata"
	glo output "${input}"
}
cd "${input}"

* PREPARE DATASETS

	* MERGE DATASETS
	* HH-level data
	use "H_22-23", clear
	foreach file in "H_04-09" "H_01" "H_02" {
		merge 1:1 hh_id using `file', nogen assert(match)
	}
	* individual-level data
	merge 1:m hh_id using "H_03", nogen assert(match)
	foreach file in "H_10" "H_11" "H_12" {
		merge 1:1 hh_id ind_id using `file', nogen assert(master match)
	}
	* prepare final data
	rename hh_id hhid
	sort hhid

*<_Save data file_>
compress
if ("`c(username)'"=="sunquat") save "${output}/`yearfolder'_M.dta", replace
else save "${output}/`yearfolder'_M.dta" , replace
*</_Save data file_>
