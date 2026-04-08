/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   `code'_`year'_`survey'_v01_M_v01_A_GMD_COR.do	</_Program name_>
<_Application_>    STATA 16.0	<_Application_>
<_Author(s)_>      acastillocastill@worldbank.org	</_Author(s)_>
<_Date created_>   05-25-2021	</_Date created_>
<_Date modified>   09-08 2021	</_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        `code'	</_Country_>
<_Survey Title_>   `survey'	</_Survey Title_>
<_Survey Year_>    `year'	</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:	02-01-2024
File:	`code'_`year'_`survey'_v01_M_v01_A_`type'_COR.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>
clear all
set more off

local code         "PAK"
local year         "2004"
local survey       "HIES"
local vm           "01"
local type         "SARMD"
local yearfolder   "`code'_`year'_`survey'"
local input        "$rootdatalib\\`code'\\`code'_`year'_`survey'\\`code'_`year'_`survey'_v`vm'_M"
glo output         "${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata"

	glo sarmd            "P:/SARMD/SOUTH ASIA MICRO DATABASE"
	global shares        "P:/SARMD/SARDATABANK/APPS/DATA CHECK/Food and non-food shares/PAK"	
*</_Program setup_>


	
*<_Datalibweb request_>

	use "`input'//Data/Stata/pslmA.dta", clear
	duplicates list hhcode
	ren hhcode HID
	format HID %12.0f
	sort HID

	preserve

	use "`input'//Data/Stata/PLSMclean.dta", clear
	ren hhcode HID
	format HID %12.0f
	sort HID
	tempfile wgt
	save `wgt'

	restore
	merge HID using `wgt'
	tab _
	drop _

	sort HID
	tempfile basic_info
	save `basic_info'

	use "`input'//Data/Stata/pslmB.dta", clear
	ren hhcode HID
	format HID %12.0f


	sort HID serialno
	tempfile temp
	save `temp'

	use "`input'//Data/Stata/pslmC.dta", clear
	ren hhcode HID
	format HID %12.0f
	duplicates examples HID serialno

	sort HID serialno
	merge HID serialno using `temp'
	tab _
	drop if _==1
	drop _
	duplicates examples HID serialno
	sort HID 
	save `temp', replace

	use "`input'//Data/Stata/pslmG.dta", clear
	ren hhcode HID
	format HID %12.0f
	sort HID
	merge HID using `temp'
	tab _m
	drop _m
	sort HID
	save `temp', replace

	use "`input'//Data/Stata/pslmH1_inc.dta", clear
	ren hhcode HID
	format HID %12.0f
	egen total_inc = rowtotal( inc1 inc2 inc3 inc4 inc5 inc6 inc7 inc8 inc9 inc10 inc11 inc12), missing
	sort HID
	merge HID using `temp'
	tab _m
	drop _m
	sort HID serialno
	save `temp', replace

	use "`input'//Data/Stata/pslmE.dta", clear
	ren hhcode HID
	format HID %12.0f
	sort HID serialno
	merge HID serialno using `temp'
	tab _m
	drop _m
	sort HID serialno
	merge HID using  `basic_info'
	drop _merge
	save `temp', replace

/*Assets*/
	use "`input'//Data/Stata/assets.dta", clear
	ren hhcode HID
	format HID %12.0f
	merge 1:m HID using `temp'
	drop if _merge==1
	drop _merge
	save `temp', replace

	
	/*
Consumption. 
*/
	use "`input'//Data/Stata/Consumption Master File with CPI.dta"
	tempfile comp
	keep if year==2004
	keep hhcode nomexpend hhsizeM eqadultM peaexpM psupind new_pline texpend region weight
	ren hhcode HID

	merge 1:m HID using `temp'
	tab _merge
	keep if _merge==3
	drop _merge

	save `temp', replace
	use "`input'//Data/Stata/consumption (L1-3).dta"
	ren hhcode HID
	keep HID stratum substrat 
	duplicates drop stratum substrat HID, force
	
	merge 1:m HID using `temp'
	tab _merge
	keep if _merge==3

	*Merge with spatial deflator
	*gen psu = substr(hhid,1,7)
	merge m:1 psu using "$rootdatalib/PAK/PAK_2004_HIES/PAK_2004_HIES_v01_M/Data/Stata/psu_paasche_2004_pdef1.dta", nogen 
		
	notes _dta: "PAK 2004" for this round there is not information available for the identification of landholding, livestock assets, durables. This information comes from section F of the questionnaire.
*</_Datalibweb request_>
	

*<_Save data file_>
compress
if ("`c(username)'"=="dekopon") save "${output}/`yearfolder'_M.dta", replace
else save "${output}/`yearfolder'_M.dta" , replace
*</_Save data file_>
