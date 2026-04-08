/*------------------------------------------------------------------------------
  GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   		PAK_2018_HIES_v02_M.do				   </_Program name_>
<_Application_>    		STATA 17.0							     <_Application_>
<_Author(s)_>      		tornarolli@gmail.com	          		  </_Author(s)_>
<_Date created_>   		03-17-2025	                           </_Date created_>
<_Date modified>   		03-17-2025	                          </_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        		PAK											</_Country_>
<_Survey Title_>   		HIES								   </_Survey Title_>
<_Survey Year_>    		2018									</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:					03-17-2025
File:					PAK_2018_HIES_v02_M.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>
clear all
set more off

global cpiver       	"09"
local code         	"PAK"
local year         	"2018"
local survey       	"HIES"
local vm           	"02"
local yearfolder   	"`code'_`year'_`survey'"
global input       	"${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata"
global output      	"${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata"
global pricedata    	""
global shares 		""	
*</_Program setup_>
	
*<_Datalibweb request_>

*<_Folder creation_>
cap mkdir "${output}"
*</_Folder creation_>

	
***************************************************************************************************
**** MASTER DATABASE
***************************************************************************************************

* HOUSEHOLD ROSTER, FEMALES AND ALL CHILDREN (we also have "sec 1a.dta": same questions, more observations)
use "${input}/plist.dta", clear

* SURVEY INFORMATION
merge m:1 hhcode  using "${input}/sec_00.dta", nogen keep(master match)
* There are 867 observations deleted after the merge.
* Those are cases in which the interview was not completed (partially refused, refused or non-contact at all)

* EMPLOYMENT AND INCOME
merge 1:1 hhcode idc using "${input}/sec_1b (2).dta", nogen keep(master match) 

* EDUCATION
merge 1:1 hhcode idc using "${input}/sec_2ab.dta", nogen keep(master match) 

* ICT INDICATORS 
merge 1:1 hhcode idc using "${input}/sec 2c.dta", nogen keep(master match) 

* HEALTH (sec_3a: diarrhoea)
* HEALTH (sec_3b: immunization)
* HEALTH (sec_3c: malaria, hepatitis, tuberculosis)
* PREGNANCY HISTORY (sec_4a)
* MATERNITY HISTORY (sec_4b)
* FAMILY PLANNING (sec_4c)
* PRE AND POST NATAL CARE (sec_4d)
* WOMEN IN DECISION MAKING (sec_4e)
* HOUSEHOLD MISCELLANEOUS INFORMATION (sec_4f)

* HOUSING CHARACTERISTICS
merge m:1 hhcode using "${input}/sec_5a.dta", nogen keep(master match)

* FOOD INSECURITY EXPERIENCE SCALE (sec_5b)

* HOUSEHOLD EXPENDITURE (sec_6a)
preserve 
use "${input}/sec_6a.dta", clear
keep if itc>=41101 & itc<=42103 
collapse (sum) v2 v3 v4, by(hhcode)
egen housing_rent = rsum(v2 v3 v4), missing
keep hhcode housing_rent 
replace housing_rent = housing_rent/12
tempfile rent 
save    `rent'
restore
merge m:1 hhcode using `rent', nogen keep(master match)

* HOUSEHOLD EXPENDITURE PROCESSED
merge m:1 hhcode using "${input}/CA_1819_sharing_v2.dta", nogen keep(master match)
drop nomexpend 
merge m:1 hhcode using "${input}/poverty_1819_v2.dta", nogen keep(master match) keepusing(nomexpend)

* DURABLE CONSUMPTION ITEMS
preserve
use "${input}/sec_7a", clear
keep if inlist(code,701,702,703,704,705,706,710,711,713,714,727,728,729,730,731,732)
keep hhcode code c02
tostring code, replace 
egen 	dur = concat(code)
replace dur = strtoname(dur)
keep hhcode dur c02
reshape wide c02, i(hhcode) j(dur) string
tempfile durables
save   `durables'
restore

* TRANSFERS RECEIVED AND PAID
preserve
use "${input}/sec_8a", clear
* Excluded: 
*	801 = receipts from committees
*	813 = receipts from life insurance claims
*	814 = receipts from general insurance claims
keep if inlist(code,802,804,805,806,807,811,812,815,816,817,818,819,820)
keep hhcode code c02
tostring code, replace 
egen 	transf = concat(code)
replace transf = strtoname(transf)
keep hhcode transf c02
reshape wide c02, i(hhcode) j(transf) string
tempfile transfers
save   `transfers'
restore

* BUILDINGS AND LAND OWNED BY THE HOUSEHOLD
preserve 
use "${input}/sec_9a.dta", clear
keep hhcode code s9aq01 s9aq04
drop if code==910
tostring code, replace 
egen    code2 = concat(code)
replace code2 = strtoname(code2)
keep hhcode code2 s9aq01 s9aq04
reshape wide s9aq01 s9aq04, i(hhcode) j(code2) string
tempfile land_building
save   `land_building'
restore

* FINANCIAL ASSETS AND LIABILITIES, LOANS AND CREDIT
preserve 
use "${input}/sec_9b.dta", clear
keep if inlist(code,953,960,962,970,971)
keep hhcode code c02
tostring code, replace 
egen    code2 = concat(code)
replace code2 = strtoname(code2)
keep hhcode code2 c02
reshape wide c02, i(hhcode) j(code2) string
tempfile financial
save   `financial'
restore

* AGRICULTURAL SHEET 1 - Land rented out
preserve 
use "${input}/sec_10a.dta", clear
keep if codes==105 | codes==107
keep hhcode idc codes s10c1
tostring codes, replace 
egen    code2 = concat(codes)
replace code2 = strtoname(code2)
keep hhcode idc code2 s10
reshape wide s10c1, i(hhcode idc) j(code2) string
tempfile agrisheet1
save   `agrisheet1'
restore

* AGRICULTURAL SHEET 2 - Crop Production
preserve 
use "${input}/sec_10a.dta", clear
keep if codes==135 
keep hhcode idc s10c3 s10c4
rename s10c3 s10c_production
rename s10c4 s10c_landlord
tempfile agrisheet2
save   `agrisheet2'
restore

* AGRICULTURAL SHEET 3 - Inputs
preserve 
use "${input}/sec_10a.dta", clear
keep if codes==150
keep hhcode idc s10c1
rename s10c1 s10c_inputs
tempfile agrisheet3
save   `agrisheet3'
restore

* LIVESTOCK, POULTRY, FISH, FORESTRY, HONEY BEE, SHEET 1 - Animals 
preserve
use "${input}/sec_10b.dta", clear
keep if codes==165
keep hhcode idc s10c3 s10c5 s10c6  
rename s10c3 s10c_soldanimals
rename s10c5 s10c_purchasedanimals
rename s10c6 s10c_lostanimals
tempfile livestock1
save   `livestock1'
restore

* LIVESTOCK, POULTRY, FISH, FORESTRY, HONEY BEE, SHEET 2 - by-products 
preserve
use "${input}/sec_10b.dta", clear
keep if codes==180
keep hhcode idc s10c3
rename s10c3 s10c_byproducts
tempfile livestock2
save   `livestock2'
restore

* LIVESTOCK, POULTRY, FISH, FORESTRY, HONEY BEE, SHEET 3 - Inputs 
preserve
use "${input}/sec_10b.dta", clear
keep if codes==195
keep hhcode idc s10c1
rename s10c1 s10c_inputsanimals
tempfile livestock3
save   `livestock3'
restore

* LIVESTOCK, POULTRY, FISH, FORESTRY, HONEY BEE, SHEET 4 - Agricultural Equipments 
preserve
use "${input}/sec_10b.dta", clear
keep if codes==197
keep hhcode idc s10c1 
rename s10c1 s10c1_197
tempfile livestock4
save   `livestock4'
restore

* NON-AGRICULTURAL ESTABLISHMENT, SHEET 1 - Equipments 
preserve
use "${input}/sec_11ab.dta", clear
keep if (codes==288 | codes==289) & s11a>0
keep hhcode idc s11a
rename s11a s11a_equipment
tempfile equipment
save   `equipment'
restore

* NON-AGRICULTURAL ESTABLISHMENT, SHEET 2 - General Operating Expenses 
preserve
use "${input}/sec_11ab.dta", clear
keep if codes==220 
keep hhcode idc occu s11c
rename s11c s11c_gralexpenses
collapse (sum) s11c_gralexpenses, by(hhcode idc occu)
reshape wide s11c_gralexpenses, i(hhcode idc) j(occu)
tempfile nonagri1
save   `nonagri1'
restore

* NON-AGRICULTURAL ESTABLISHMENT, SHEET 3 - Special Operating Expenses 
preserve
use "${input}/sec_11ab.dta", clear
keep if codes==230 
keep hhcode idc occu s11c
rename s11c s11c_specexpenses
collapse (sum) s11c_specexpenses, by(hhcode idc occu)
reshape wide s11c_specexpenses, i(hhcode idc) j(occu)
tempfile nonagri2
save   `nonagri2'
restore

* NON-AGRICULTURAL ESTABLISHMENT, SHEET 4 - Other Expenses 
preserve
use "${input}/sec_11ab.dta", clear
keep if codes==250 
keep hhcode idc occu s11c
rename s11c s11c_othexpenses
collapse (sum) s11c_othexpenses, by(hhcode idc occu)
reshape wide s11c_othexpenses, i(hhcode idc) j(occu)
tempfile nonagri3
save   `nonagri3'
restore

* NON-AGRICULTURAL ESTABLISHMENT, SHEET 5 - Sales 
preserve
use "${input}/sec_11ab.dta", clear
keep if codes==265
keep hhcode idc occu s11c
rename s11c s11c_sales
collapse (sum) s11c_sales, by(hhcode idc occu)
reshape wide s11c_sales, i(hhcode idc) j(occu)
tempfile nonagri4
save   `nonagri4'
restore

* NON-AGRICULTURAL ESTABLISHMENT, SHEET 6 - Revenues 
preserve
use "${input}/sec_11ab.dta", clear
keep if codes==285 
keep hhcode idc occu s11c
rename s11c s11c_revenues
collapse (sum) s11c_revenues, by(hhcode idc occu)
reshape wide s11c_revenues, i(hhcode idc) j(occu)
tempfile nonagri5
save   `nonagri5'
restore

merge m:1 hhcode using `durables', 		nogen keep(master match)
merge m:1 hhcode using `transfers', 		nogen keep(master match)
merge m:1 hhcode using `land_building', 	nogen keep(master match)
merge m:1 hhcode using `financial', 		nogen keep(master match)
merge 1:1 hhcode idc using `agrisheet1', nogen keep(master match)
merge 1:1 hhcode idc using `agrisheet2', nogen keep(master match)
merge 1:1 hhcode idc using `agrisheet3', nogen keep(master match)
merge 1:1 hhcode idc using `livestock1', nogen keep(master match)
merge 1:1 hhcode idc using `livestock2', nogen keep(master match)
merge 1:1 hhcode idc using `livestock3', nogen keep(master match)
merge 1:1 hhcode idc using `livestock4', nogen keep(master match)
merge 1:1 hhcode idc using `equipment',  nogen keep(master match)
merge 1:1 hhcode idc using `nonagri1',   nogen keep(master match)
merge 1:1 hhcode idc using `nonagri2',   nogen keep(master match)
merge 1:1 hhcode idc using `nonagri3',   nogen keep(master match)
merge 1:1 hhcode idc using `nonagri4',   nogen keep(master match)
merge 1:1 hhcode idc using `nonagri5',   nogen keep(master match)


*****************************************************************************************************************
*** AGRICULTURAL MODULE
* Crops 
egen 	earnings_crop = rsum(s10c_production), missing
egen 	expenses_crop = rsum(s10c1_107 s10c_inputs s10c_landlord), missing 
replace expenses_crop = expenses_crop*(-1) 

* Livestock
egen 	earnings_live = rsum(s10c_soldanimals s10c_byproducts), missing
egen 	expenses_live = rsum(s10c_inputsanimals s10c_lostanimals s10c_purchasedanimals), missing 
replace expenses_live = expenses_live*(-1) 

egen    agricultural1 = rsum(earnings_crop earnings_live expenses_crop expenses_live), missing
replace agricultural1 = agricultural1/12
replace agricultural1 = 0					if  agricultural1<0
*****************************************************************************************************************

*****************************************************************************************************************
*** EMPLOYMENT MODULE 
gen monthly_income = s1bq08*s1bq09			if  s1bq06>=6 & s1bq06<=9 
gen annual_income = s1bq10					if  s1bq06>=6 & s1bq06<=9 
gen inkind_income = s1bq19					if  s1bq06>=6 & s1bq06<=9
gen second_income = s1bq15					if  s1bq14>=6 & s1bq14<=9

egen    agricultural2 = rsum(monthly_income annual_income second_income inkind_income), missing
replace agricultural2 = agricultural2/12

drop monthly_income annual_income inkind_incom* second_income
*****************************************************************************************************************
*** MAX INCOME
egen aux_agriculture = rowmax(agricultural1 agricultural2)
*****************************************************************************************************************


/*****************************************************************************************************************
*** NON-AGRICULTURAL MODULE 
egen earnings_nonagri1 = rsum(s11c_sales1 s11c_revenues1 s11a_equipment), missing
egen expenses_nonagri1 = rsum(s11c_gralexpenses1 s11c_specexpenses1 s11c_othexpenses1), missing 
replace expenses_nonagri1 = expenses_nonagri1*(-1) 

egen    nonagri11 = rsum(earnings_nonagri1 expenses_nonagri1), missing
replace nonagri11 = 0					if  nonagri11<0
replace nonagri11 = nonagri11/12

egen earnings_nonagri2 = rsum(s11c_sales2 s11c_revenues2), missing
egen expenses_nonagri2 = rsum(s11c_gralexpenses2 s11c_specexpenses2 s11c_othexpenses2), missing 
replace expenses_nonagri2 = expenses_nonagri2*(-1) 

egen    nonagri12 = rsum(earnings_nonagri2 expenses_nonagri2), missing
replace nonagri12 = 0					if  nonagri12<0
replace nonagri12 = nonagri12/12

egen    nonagri1 = rsum(nonagri11 nonagri12), missing
replace nonagri1 = .						if  nonagri1>1000000
*****************************************************************************************************************

*****************************************************************************************************************
*** EMPLOYMENT MODULE 
gen monthly_income2 = s1bq08*s1bq09			if  s1bq06==1 | s1bq06==3 
gen annual_income2 = s1bq10				if  s1bq06==1 | s1bq06==3 
gen inkind_income2 = s1bq19				if  s1bq06==1 | s1bq06==3
gen second_income2 = s1bq15				if  s1bq14==1 | s1bq14==3

egen    nonagri2 = rsum(monthly_income2 annual_income2 second_income2 inkind_income2), missing
replace nonagri2 = nonagri2/12
drop monthly_income2 annual_income2 inkind_incom* second_income2
*****************************************************************************************************************

*** MAX INCOME
egen self_nonagri = rowmax(/*nonagri1*/ nonagri2)
*****************************************************************************************************************/

* Auxiliar Income Variables (according to Labor Relationship)
* 1 = Employer (less than 10 employees)
* 2 = Employer (10 or more employees)
* 3 = Self-employed non-agricultural
* 4 = Paid employee	
* 5 = Contributing family worker
* 6 = Own cultivator
* 7 = Share-cropper	
* 8 = Contract cultivator
* 9 = Livestocker
gen monthly_income = s1bq08*s1bq09/12		if  s1bq06>=1 & s1bq06<=5	
gen annual_income = s1bq10/12				if  s1bq06>=1 & s1bq06<=5		
gen inkind_income = s1bq19/12				if  s1bq06>=1 & s1bq06<=5	
gen second_income = s1bq15/12				if  s1bq14>=1 & s1bq14<=5	

gen self_agriculture1 = aux_agriculture		if  s1bq06>=6 & s1bq06<=9			/* main job		*/
replace aux_agriculture = .				if  s1bq06>=6 & s1bq06<=9		
gen self_agriculture2 = aux_agriculture		if  s1bq14>=6 & s1bq14<=9			/* second job 	*/
replace aux_agriculture = .				if  s1bq14>=6 & s1bq14<=9
gen self_agriculture3 = aux_agriculture										/* third job	*/
drop aux_agriculture


* DEFLACTORS 	
merge m:1 psu using "${input}/psu_paasche_2018_pdef1.dta", nogen assert(match)

*<_Save data file_>
compress
save "${output}/`yearfolder'_v`vm'_M.dta", replace
*</_Save data file_>

