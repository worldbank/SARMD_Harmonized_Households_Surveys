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
local year         "2005"
local survey       "HIES"
local vm           "02"
local va           "03"
local type         "SARMD"
local yearfolder   "`code'_`year'_`survey'"
local input        "$rootdatalib\\`code'\\`code'_`year'_`survey'\\`code'_`year'_`survey'_v`vm'_M"
glo output         "${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata"
*</_Program setup_>


	
*<_Datalibweb request_>

** DATABASE ASSEMBLENT
	tempfile aux
	use "`input'\Data\Stata\roster with weights", clear
	duplicates report hhcode idc
	/*No duplicates in ID of HH and individual*/
	save `aux'
	
	
**Add employment and income

	use "`input'\Data\Stata\sec 1b", clear
	duplicates report hhcode idc
	isid hhcode idc
	merge m:1 hhcode idc using `aux'
	drop if _merge==1
	tab _merge
	drop _merge
	save `aux', replace
	
**Add literacy and formal education
	use "`input'\Data\Stata\sec 2a", clear
	duplicates tag hhcode province region psu idc, gen(tag)
	drop if tag!=0 & s2bq19c==.
	merge 1:m hhcode idc using `aux'
	drop if _merge==1
	tab _merge
	drop _merge
	save `aux', replace


**Add housing
	use "`input'\Data\Stata\sec 5", clear
	merge 1:m hhcode using `aux'
	ta _merge
	drop _merge
	save `aux', replace

**Add consumption
	use "`input'\Data\Stata\Consumption Master File with CPI.dta"
	ren year yearn
	keep if yearn==2005
	drop intmonth intyear
	merge 1:m hhcode using `aux'
	drop _merge
	save `aux', replace
	
**Add durables
	use "`input'\Data\Stata\sec7m.dta",clear
	keep hhcode itc s7mq02
	ren itc serialno
	
		#delimit;
	lab def code
	 700 "total"
	 701 "Refrigerator"
	 702 "Freezer"
	 703 "Air conditioner"
	 704 `"Air cooler"'
	 705 "Fan (Ceiling, Table, Pedestal, Exhaust)"
	 706 "Geyser (Gas, Electric)"
	 707 "Washing machine/dryer"
	 708 "Camera  (Still)"
	 709 "Camera (Movie )"
	 710  "Cooking stove"
	 711 "Cooking Range, Microwave oven"
	 712 "Heater"
	 713 "Bicycle"
	 714  "Car / Vehicle"
	 715  "Motorcycle/scooter"
	 716  "tv"
	 717  "VCR, VCP, Receiver, De-coder"
	 718  "Radio / cassette player"
	 719  "Compact disk player"
	 720  "Vacuum cleaner"
	 721  "Sewing/Knitting Machine"
	 722  "Personal Computer"
	 723  "Other";
	 #delimit cr
	
	label values serialno .
	label values serialno code
	decode serialno, gen(itc)
	replace itc=strtoname(itc)
	replace itc=substr(itc, 1,15)
	egen itc2= concat(itc serialno)
	keep hhcode s7mq02 itc2
	ren s7mq02 numdur
	reshape wide numdur, i(hhcode) j(itc2) strin
	tempfile durables
	save `durables'

/***Add livestock assets
	
	use "`input'\Data\Stata\sec 10b",clear
	#delimit;
	la def cattle
	151 "Cattle"
	152 "Buffalo"
	159 "Poultry";
	#delimit cr
	la val code .
	la values codes cattle
	ren codes serialno
	decode serialno, gen(itc)
	egen itc2=concat(itc serialno )
	ren s10ba numlivestock 
	duplicates drop hhcode itc2, force
	keep hhcode itc2 numlivestock
	reshape wide numlivestock, i( hhcode ) j( itc2 ) strin
	tempfile agric
	save `agric'*/

use "`input'\Data\Stata\interview_month", clear
ren year year1
tempfile inter
save `inter'
	
	
*Add landholding information

	use "`input'\Data\Stata\sec 9a", clear
	keep hhcode code s9aq01
	reshape wide s9aq01, i( hhcode ) j( code )
	tempfile landholding
	save `landholding'
	
	use `aux', clear
	foreach s in landholding durables inter{
	merge m:1 hhcode using ``s''
	drop if _merge==2
	drop _merge
	}
	
	*Merge with spatial deflator
	*gen psu = substr(hhid,1,7)
	merge m:1 psu using "$rootdatalib\PAK\PAK_2005_HIES\PAK_2005_HIES_v`vm'_M\Data\Stata\psu_paasche_2005_pdef1.dta", nogen 

*</_Datalibweb request_>
	

*<_Save data file_>
compress
if ("`c(username)'"=="dekopon") save "${output}/`yearfolder'_M.dta", replace
else save "${output}/`yearfolder'_M.dta" , replace
*</_Save data file_>
