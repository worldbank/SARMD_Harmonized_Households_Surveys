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
local year         "2011"
local survey       "HIES"
local vm           "01"
local va           "06"
local type         "SARMD"
local yearfolder   "`code'_`year'_`survey'"
local input        "$rootdatalib\\`code'\\`code'_`year'_`survey'\\`code'_`year'_`survey'_v`vm'_M"
glo output         "${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata"
*</_Program setup_>


	
*<_Datalibweb request_>

/*
Household Roster
*/
	use "`input'\Data\Original\plist.dta", clear
	tempfile aux
	isid hhcode idc

	save `aux', replace


/*
Employment
*/
	use "`input'\Data\Original\sec_1b.dta", clear
	isid hhcode idc
	merge 1:1 hhcode idc using `aux'
	tab _merge

/*
3 obs deleted
*/
	drop if _merge==1
	drop _merge
	save `aux', replace


/*
Education
*/
	use "`input'\Data\Original\sec_2a.dta", clear
	isid hhcode idc 
	merge 1:1 hhcode idc using `aux'
	tab _merge

/*
0 obs deleted
*/
	drop if _merge==1
	drop _merge
	save `aux', replace


/*
Detail on the family (housing info)
*/
	use "`input'\Data\Original\sec_5a.dta", clear
	isid hhcode
	merge 1:m hhcode using `aux'
	tab _merge
	drop if _merge==1

/*
0 obs deleted
*/
	drop _merge
	save `aux', replace

	use "`input'\Data\Original\sec_00a.dta", clear
	isid hhcode
	merge 1:m hhcode using `aux'
	tab _merge
	drop if _merge==1
	drop _merge
	save `aux', replace

/*
Consumption. From Nobuo database.
*/
	use "`input'\Data\Stata\Consumption Master File with CPI.dta"
	tempfile comp
	keep if year==2011
	keep hhcode nomexpend hhsizeM eqadultM peaexpM psupind new_pline texpend region
	save  `comp' , replace

	use `aux', clear
	merge m:1 hhcode using `comp'
	tab _merge
	drop if _merge!=3
	drop _merge
	
	
	merge 1:1 hhcode idc using "`input'\Data\Original\roster.dta"
	tab _merge
	drop if _merge!=3
	drop _merge
	tempfile ref
	save `ref'
	
**Add durables
	use "`input'\Data\Stata\sec_7m",clear
	duplicates report hhcode itc
	keep hhcode itc s7mq02
	decode itc, gen(itc1)
	egen itc2=concat( itc1 itc )
	duplicates report hhcode itc2
	replace itc2=strtoname(itc2)
	replace itc2=substr(itc2, 1,20)
	keep hhcode s7mq02 itc2
	rename s7mq02 numdur
	reshape wide numdur, i( hhcode ) j( itc2 ) string
	tempfile durables
	save `durables'

/***Add livestock assets
	use "`input'\Data\Stata\sec_10b",clear
	duplicates report hhcode codes
	keep codes s10bc1 hhcode
	decode codes, gen(itc)
	egen itc2=concat( itc codes )
	replace itc2=strtoname(itc2)
	replace itc2=substr(itc2, 1,20)
	keep hhcode s10bc1 itc2
	ren s10bc1 numlivestock
	reshape wide numlivestock, i( hhcode ) j( itc2 ) string
	tempfile agric
	save `agric'*/
	
**Add landholding information
	use "`input'\Data\Stata\sec_9a",clear
	keep hhcode code s9aq01
	reshape wide s9aq01, i(hhcode) j(code)
	tempfile landholding
	save `landholding'

	use `ref', clear
	foreach s in landholding  durables{
	merge m:1 hhcode using ``s''
	ta _merge
	drop if _merge==2
	drop _merge
	}

	*Merge with spatial deflator
	*rename psu psu_old
	*gen psu = real(substr(string(hhcode, "%20.0g"), 1, 7))
	*format psu %20.0g
	merge m:1 psu using "$rootdatalib\PAK\PAK_2011_HIES\PAK_2011_HIES_v01_M\Data\Stata\psu_paasche_2011_pdef1.dta", nogen 

*</_Datalibweb request_>
	

*<_Save data file_>
compress
if ("`c(username)'"=="dekopon") save "${output}/`yearfolder'_M.dta", replace
else save "${output}/`yearfolder'_M.dta" , replace
*</_Save data file_>
