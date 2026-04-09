/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   `code'_`year'_`survey'_v01_M_v01_A_GMD_COR.do	</_Program name_>
<_Application_>    STATA 16.0	<_Application_>
<_Author(s)_>      Juan Segnana <jsegnana@worldbank.org>	</_Author(s)_>
<_Date created_>   05-25-2021	</_Date created_>
<_Date modified>   07-06 2023	by Adriana Castillo Castillo </_Date modified_>
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

local code         "MDV"
local year         "2016"
local survey       "HIES"
local vm           "01"
local va           "01"
local type         "SARMD"
local yearfolder   "`code'_`year'_`survey'"
local input        "${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata"
glo output         "${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata"
*</_Program setup_>



/** DATABASE ASSEMBLENT */
	
	* Merge individual and housing data
	use "`input'\F4.dta", clear
	merge m:1 Form_ID using "`input'\F2.dta"
	drop _merge
	
	* Merge with atolls
	preserve
	use "`input'\F3-Q12-Q23.dta", clear
	collapse (first) Atoll_Island IslandCode block HHSN surveyMonth Atoll Adjustedhouseholdweight, by(Form_ID)
	save "`input'\Atolls.dta", replace
	restore
	merge m:1 Form_ID using "`input'\Atolls.dta"
	drop _merge	
	
	* Merge with assets
	preserve
	use "`input'\F2-Q30.dta" , clear
	keep Form_ID _Item _HaveAccess
	rename _HaveAccess access_
	recode access_ (1=1) (2 9=0)
	replace _Item="Car"          	if _Item=="Car/Jeep"
	replace _Item="Computer"     	if _Item=="Computer/Laptop"
	replace _Item="Radio"        	if _Item=="Radio/Set"
	replace _Item="Air_condition" 	if _Item=="Air condition"
	replace _Item="Dhoni_Speed_boat"   if _Item=="Dhoni/Speed boat" 
	replace _Item="Mobile_phone"       if _Item=="Mobile phone" 
	replace _Item="Motor_cycle"    	if _Item=="Motor cycle" 
	replace _Item="Rice_cooker"       if _Item=="Rice cooker"  
	replace _Item="Washing_machine"    if _Item=="Washing machine" 
	replace _Item="Water_pump"         if _Item=="Water pump" 
	reshape wide access_, i( Form_ID ) j( _Item ) string
	save "`input'\Assets.dta", replace
	restore
	merge m:1 Form_ID using "`input'\Assets.dta"
	drop _merge
	foreach var of varlist access_Bicycle-access_Telephone{
	replace `var'=0 if `var'==.
	}
	
	* Merge total food expenditures
	preserve
	use "`input'\F7-Q3-Q5.dta", clear
	collapse (rawsum) exp, by(Form_ID)
	rename exp weekly_foodexp
	label var weekly_foodexp "7 day total household food expenditures"
	save "`input'\Food.dta", replace
	restore
	merge m:1 Form_ID using "`input'\Food.dta"
	drop _merge
	
	* Merge labor force module
	merge 1:1 Form_ID Id using "`input'\F5.dta" 
	drop if _merge==2
	drop _merge
	merge 1:1 Form_ID Id using "`input'\F6.dta" 
	drop if _merge==2
	drop _merge
	
	* Merge welfare aggregate provided by Christina Wieser
	preserve
	*use  "`input'\Poverty and technical documents\World Bank\Christina Wieser\poverty.dta" , clear
	use "${rootdatalib}\\`code'\\`code'_`year'_`survey'\\`code'_`year'_`survey'_v`vm'_M\Poverty and technical documents\World Bank\Christina Wieser\poverty.dta", clear
	rename hhid Form_ID
	save "`input'\Welfare.dta", replace 
	restore
	
	merge m:1 Form_ID using "`input'\Welfare.dta", force
	drop _merge male
	egen tag=tag(Form_ID)


*<_Save data file_>
compress
if ("`c(username)'"=="dekopon") save "${output}/`yearfolder'_M.dta", replace
else save "${output}/`yearfolder'_M.dta" , replace
*</_Save data file_>
