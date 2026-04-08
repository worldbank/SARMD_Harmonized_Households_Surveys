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
local year         "2015"
local survey       "HIES"
local vm           "01"
local va           "05"
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
	use "`input'\Data\Original\sec_3a.dta", clear
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
	drop province
	isid hhcode
	merge 1:m hhcode using `aux'
	tab _merge
	drop if _merge==1
	drop _merge
	save `aux', replace
/*
Consumption from Master Consumption File
(For now I'll add it directly from Freeha's Poverty File)
*/
/*	use "`input'\Data\Stata\Consumption Master File with CPI.dta"
	tempfile comp
	keep if year==2013
	keep hhcode nomexpend eqadultM peaexpM psupind new_pline texpend region hhsizeM province
	save  `comp' , replace

	use `aux', clear
	merge m:1 hhcode using `comp'
	tab _merge
	drop if _merge!=3
	drop _merge
	*/
	use "`input'\Data\Consumption\poverty_1516.dta"
	
	tempfile comp
	keep if year==2015
	cap ren npline new_pline
	keep hhcode nomexpend eqadultM peaexpM psupind new_pline texpend region hhsizeM province
	save  `comp' , replace

	use `aux', clear
	merge m:1 hhcode using `comp'
	tab _merge
	drop if _merge!=3
	drop _merge
	save `aux', replace
	
	merge 1:1 hhcode idc using "`input'\Data\Original\roster.dta"
	tab _merge
	drop if _merge!=3
	drop _merge
	
	tempfile ref
	save `ref'

	/* No durables information this year, only durables' consumption
	**Add durables
	use "`input'\Data\Original\sec_4abcde.dta", clear
	stop
	duplicates report hhcode itc
	keep hhcode itc v1
	decode itc, gen (itc1)
	egen itc2=concat( itc1 itc )
	replace itc2=strtoname(itc2)
	replace itc2=substr(itc2, 1,20)
	keep hhcode itc2 v1
	ren v1 numdur
	reshape wide numdur, i( hhcode ) j( itc2 ) string
	tempfile durables
	save `durables'
	*/
		
***Add livestock assets
	use "`input'\Data\Original\sec_7b.dta", clear
	duplicates tag hhcode codes, gen(TAG)
	drop if TAG==1 & s7bc1==.
	drop TAG
	keep s7bc1 codes hhcode
	decode codes, gen(itc)
	egen itc2=concat( itc codes )
	replace itc2=strtoname(itc2)
	replace itc2=substr(itc2, 1,20)
	keep hhcode s7bc1 itc2
	ren s7bc1 numlivestock
	reshape wide numlivestock, i( hhcode ) j( itc2 ) string
	tempfile agri
	save `agri'

	
**Add landholding information
	use "`input'\Data\Original\sec_6a.dta", clear
	keep hhcode code s6aq01
	reshape wide s6aq01, i( hhcode ) j(code)
	tempfile landholding
	save `landholding'
	
	use `ref'
	*foreach s in landholding durables{
	foreach s in landholding{
	merge m:1 hhcode using ``s''
	drop if _merge==2
	drop _merge
	}
	

**Add deflactor information	
	merge m:1 psu using "$rootdatalib\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata\psu_paasche_2015_pdef1.dta", force 
	
*</_Datalibweb request_>
	

*<_Save data file_>
compress
if ("`c(username)'"=="dekopon") save "${output}/`yearfolder'_M.dta", replace
else save "${output}/`yearfolder'_M.dta" , replace
*</_Save data file_>
