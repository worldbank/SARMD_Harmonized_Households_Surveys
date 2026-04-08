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
local year         "2010"
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
Consumption. From Freeha's Database
*/
	use "`input'\Data\Stata\Consumption Master File with CPI.dta"
	tempfile comp
	keep if year==2010
	keep hhcode nomexpend eqadultM peaexpM psupind new_pline texpend region hhsizeM
	save  `comp' , replace

/*
Household Roster
*/
	use "`input'\Data\Stata\plist.dta", clear
	tempfile aux
	isid hhcode idc
	merge m:1 hhcode using `comp'
	drop _merge
	
	save `aux', replace
/*
Employment
*/
	use "`input'\Data\Stata\sec_e_.dta", clear
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
	use "`input'\Data\Stata\sec c.dta", clear
	isid hhcode idc 
	merge 1:1 hhcode idc using `aux'
	tab _merge

/*
0 obs deleted
*/
	*drop if _merge==1
	drop _merge
	save `aux', replace


/*
Detail on the family (housing info)
*/
	use "`input'\Data\Stata\sec g.dta", clear
	isid hhcode
	merge 1:m hhcode using `aux'
	tab _merge
	*drop if _merge==1

/*
0 obs deleted
*/
	drop _merge
	save `aux', replace

/*
Assets in possession
*/
	use "`input'\Data\Stata\sec f2.dta", clear
	isid hhcode
	merge 1:m hhcode using `aux'
	tab _merge

/*
0 obs deleted
*/
	*drop if _merge==1
	drop _merge
	save `aux', replace

	use "`input'\Data\Stata\sec_a.dta", clear
	isid hhcode
	merge 1:m hhcode using `aux'
	tab _merge
	*drop if _merge==1
	drop _merge
	save `aux', replace

	use `aux', clear
	merge m:1 hhcode using `comp'
	tab _merge
	drop _merge
	tempfile ref
	save `ref'
	
**Add durables
	use "`input'\Data\Stata\sec 7_m", clear
	keep hhcode code S7mq02
	decode code, gen(itc)
	egen itc2=concat( itc code )
	replace itc2=strtoname(itc2)
	replace itc2=substr(itc2, 1,20)
	keep hhcode itc2 S7mq02
	ren S7mq02 numdur
	reshape wide numdur, i(hhcode) j( itc2 ) string
	tempfile durables
	save `durables'

/***Add livestock assets
	use "`input'\Data\Stata\sec 10b_qb", clear
	duplicates report hhcode codes
	keep hhcode codes s10bA
	decode codes, gen(itc)
	egen itc2=concat( itc codes )
	replace itc2=strtoname(itc2)
	replace itc2=substr(itc2, 1,20)
	rename s10bA numlivestock
	keep hhcode numlivestock itc2
	reshape wide numlivestock, i( hhcode ) j( itc2 ) string
	tempfile agri
	save `agri'*/

*Add landholding info	

/*	use "`input'\Data\Stata\Sec F1", clear
	keep if q1to10==1
	keep if sf1col1==1
	ren sf1col1 landholding
	duplicates report hhcode
	keep hhcode landholding
	tempfile landholding 
	save `landholding'*/

tempfile weights
use "`input'\Data\Stata\hhweights", clear
save `weights'

	use `ref', clear
	foreach s in  durables weights{
	merge m:1 hhcode using ``s''
	ta _merge
	drop if _merge==2
	drop _merge
	}
	
	*Merge with spatial deflator
	*rename psu psu_old
	*gen psu = real(substr(string(hhcode, "%20.0g"), 1, 7))
	*format psu %20.0g
	merge m:1 psu using "$rootdatalib\PAK\PAK_2010_HIES\PAK_2010_HIES_v01_M\Data\Stata\psu_paasche_2010_pdef1.dta", nogen 

	
***************************************************************************************************
* Rename Variables

ren Enu_Date 	enu_date
*</_Datalibweb request_>
	

*<_Save data file_>
compress
if ("`c(username)'"=="dekopon") save "${output}/`yearfolder'_M.dta", replace
else save "${output}/`yearfolder'_M.dta" , replace
*</_Save data file_>
