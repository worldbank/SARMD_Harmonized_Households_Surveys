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
Date:	05-25-2020
File:	`code'_`year'_`survey'_v01_M_v01_A_`type'_COR.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>
clear all
set more off

local code         "PAK"
local year         "2001"
local survey       "PIHS"
local vm           "01"
local type         "SARMD"
local yearfolder   "`code'_`year'_`survey'"
local input        "$rootdatalib\\`code'\\`code'_`year'_`survey'\\`code'_`year'_`survey'_v`vm'_M"
glo output         "${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata"
*</_Program setup_>


	
*<_Datalibweb request_>

** DATABASE ASSEMBLENT
	use "`input'//Data/Stata/Consumption Master File with CPI.dta"
	keep if year==2001
	keep year hhcode nomexpend eqadultM peaexpM psupind new_pline texpend region weight popwt hhsize hhsizeM province

*	tempfile comp
*	save `comp', replace


	merge m:m hhcode using "`input'//Data/Stata/plist.dta"
	order hhcode idc
	drop _merge

	merge m:m hhcode using "`input'//Data/Stata/educate.dta"
	order hhcode idc
	isid hhcode idc
	drop _merge
	

forval i=1/3{
		merge m:m hhcode idc using "`input'//Data/Stata/educat`i'.dta"
		isid hhcode idc
		drop _merge
}	
		merge m:m hhcode idc using "`input'//Data/Stata/income1.dta"
		isid hhcode idc
		drop _merge
		
		merge m:1 hhcode using "`input'//Data/Stata/intdate.dta"
		drop if _merge==2
		drop _merge
		isid hhcode idc

		merge m:1 hhcode using "`input'//Data/Stata/housing.dta"
		drop _merge
		isid hhcode idc
		tempfile ref
		save `ref'

		
		
		/***Add livestock assets		
		use "`input'//Data/Stata/Sect10b1", clear
		duplicates report hhcode itc 
		keep hhcode itc qa1
		decode itc, generate(itc1)
		egen itc2=concat(itc1 itc)
		keep hhcode qa1 itc2
		ren qa1 numlivestock		
		reshape wide numlivestock, i( hhcode ) j( itc2 ) string
		tempfile agri
		save `agri'*/

		**Add landholding information
		use "`input'//Data/Stata/sect9a", clear
		keep hhcode itc s9aq01
		reshape wide s9aq01, i( hhcode ) j( itc )
		tempfile landholding
		save `landholding'
		
		**Add durables
		use "`input'//Data/Stata/Sect7.dta", clear
		keep hhcode itc s7q01b
		decode itc, gen(itc1)
		egen itc2=concat( itc itc1 )
		keep hhcode itc2 s7q01b
		ren s7q01b numdur
		replace itc2=strtoname(itc2)
		replace itc2=substr(itc2, 1,15)
		reshape wide numdur, i( hhcode ) j( itc2 ) strin
		tempfile durables
		save `durables'
		
		*Merge data-sets
		use `ref', replace
		foreach s in landholding durables{
		merge m:1 hhcode using ``s''
		drop _merge
		}
				
		*Merge with spatial deflator
		*gen psu = substr(hhid,1,7)
		merge m:1 psu using "`input'//Data/Stata/psu_paasche_2001_pdef1.dta", nogen 
*</_Datalibweb request_>
	

*<_Save data file_>
compress
if ("`c(username)'"=="dekopon") save "${output}/`yearfolder'_M.dta", replace
else save "${output}/`yearfolder'_M.dta" , replace
*</_Save data file_>
