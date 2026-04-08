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
local year         "2007"
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
	use "`input'\Data\Stata\plist", clear
	isid hhcode idc 
/*No duplicates in combination of hh code and individual code*/	
	save `aux'

**Add employment and income

	use "`input'\Data\Stata\sec1b", clear
	merge 1:m hhcode idc using `aux'
	drop if _merge==1
	drop _merge
	save `aux',replace
	
**Add literacy and formal education
	use "`input'\Data\Stata\sec2a", clear
	merge 1:m hhcode idc using `aux'
	drop if _merge==1
	drop _merge
	save `aux', replace

**Add housing
	use "`input'\Data\Stata\sec5", clear
	merge 1:m hhcode using `aux'
	drop _merge
	save `aux', replace
	
**Add consumption
	use "`input'\Data\Stata\Consumption Master File with CPI (2007)", clear
	**Change codes to merge with existing raw files
	tostring hhcode, gen(hh0)
	ge hh1=substr(hh0, -3,.)
	gen hh2=substr(hh0, -9, 6)
	gen zero="0"
	egen hhcode1=concat(hh2 zero hh1)
	drop hhcode
	destring hhcode1, gen (hhcode)
	drop hh0 hh1 zero
	merge 1:m hhcode using `aux'
	drop _merge
	save `aux', replace


**Add durables
	use "`input'\Data\Stata\sec7m", clear
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
	
	label values itc .
	la val itc code
	keep hhcode itc s7mq01
	decode itc, gen(itc1)
	egen itc2=concat(itc1 itc )
	duplicates report hhcode itc2
	keep hhcode s7mq01 itc2
	ren s7mq01 numdur
	replace itc2=strtoname(itc2)
	replace itc2=substr(itc2, 1,20)
	reshape wide numdur, i(hhcode) j(itc2) string
	tempfile durables
	save `durables'

***Landholding
	use "`input'\Data\Stata\sec9a",clear
	keep hhcode code s9aq01
reshape wide s9aq01, i(hhcode) j(code)
tempfile landholding
save `landholding', replace
	
/***Add livestock assets information	
	use "`input'\Data\Stata\sec 10b", clear
	duplicates report hhcode codes
	keep hhcode codes s10ba
	decode codes, gen(itc)
	egen itc2=concat( itc codes )
	replace itc2=strtoname(itc2)
	replace itc2=substr(itc2, 1,20)
	ren s10ba numlivestock
	duplicates report hhcode itc2
	keep hhcode itc2 numlivestock
	reshape wide numlivestock, i( hhcode ) j(itc2) string
	tempfile agric
	save `agric'*/
	
	
**Merge data-sets
use `aux', clear
foreach s in landholding durables{
	merge m:1 hhcode using ``s''
	drop if _merge==2
	drop _merge
	}
	
	*Merge with spatial deflator
	rename psu psu_old
	gen psu = substr(hhcode1,1,8)
	destring psu , replace 
	merge m:1 psu using "$rootdatalib\PAK\PAK_2007_HIES\PAK_2007_HIES_v`vm'_M\Data\Stata\psu_paasche_2007_pdef1.dta", nogen 
*</_Datalibweb request_>
	

*<_Save data file_>
compress
if ("`c(username)'"=="dekopon") save "${output}/`yearfolder'_M.dta", replace
else save "${output}/`yearfolder'_M.dta" , replace
*</_Save data file_>
