/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   		BGD_2000_HIES_v01_M.do				   </_Program name_>
<_Application_>    		STATA 17.0							     <_Application_>
<_Author(s)_>      		acastillocastill@worldbank.org	          </_Author(s)_>
<_Author(s)_>      		tornarolli@gmail.com	          		  </_Author(s)_>
<_Date created_>   		05-25-2021	                           </_Date created_>
<_Date modified>   		08-09 2023	                          </_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        		BGD											</_Country_>
<_Survey Title_>   		HIES								   </_Survey Title_>
<_Survey Year_>    		2000									</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:					08-15-2023
File:					BGD_2000_HIES_v01_M.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>
clear all
set more off

global cpiver       	"10"
local code         		"BGD"
local year         		"2000"
local survey       		"HIES"
local vm           		"01"
local type         		"SARMD"
local yearfolder   		"`code'_`year'_`survey'"
global input       		"${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata"
global output      		"${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata"
*</_Program setup_>

	
*<_Datalibweb request_>

***************************************************************************************************
**** INCOME
***************************************************************************************************
* INDIVIDUAL ROSTER
tempfile roster
use "${input}\plist.dta", clear
gen     idp = idc
order   hhcode idp
duplicates report
duplicates drop
keep hhcode idp psu sex-mstatus 
sort hhcode idp
save `roster'

* INCOMES FROM SECTION 5: DAY LABOURERS and EMPLOYEES    
* Employees (s5a06==1)   
tempfile sect4
use "${input}\activity.dta", clear
gen  idp = idc
 
replace s5a02 = 12		if  s5a02>12 & s5a02<.
replace s5a03 = 30		if  s5a03>30 & s5a03<.
replace s5a04 = 24		if  s5a04>24 & s5a04<.	
			
replace s5a06 = 1		if  s5a06!=1 & s5b01!=.   
keep if s5a06==1 

* Monthly Income of those working as day labourers
* s5b02: What was the daily wage in cash in the past 12 months? (TAKA)
* s5b05: How much did you receive in-kind per day? (KGS)                      
* s5a03: On average, how many days per month did you work?
* s5a02: How many months did you do this activity in the last 12 months?
gen daylab_cash = s5b02 * s5a03 * (s5a02/12)		if  s5b01==1 	

* impute in-kind payments for daily basis
gen double paddy = s5b05*s5a03*s5a02*6.68/12 		if  s5b01==1 & s5b03==1 & s5b04==1
gen double  rice = s5b05*s5a03*s5a02*12/12   		if  s5b01==1 & s5b03==1 & s5b04==2
gen double wheat = s5b05*s5a03*s5a02*12/12   		if  s5b01==1 & s5b03==1 & s5b04==3
egen daylab_kind = rsum(paddy rice wheat), missing

* Monthly Income of those working as employees
* s5b08: What is your total net take-home monthly remuneration after all deduction at source?
* s5b10: What is the total value of in-kind or other benefits you received over the past 12 months?
gen employee_cash = s5b08							if  s5b01==2
gen employee_kind = s5b10/12						if  s5b01==2

egen x = rsum(daylab_cash daylab_kind employee_cash employee_kind), missing
drop if x==.
order hhcode idp 
sort  hhcode idp 
drop  s5a05* s5b01 s5b02 s5b03 s5b04 s5b05 s5b06 s5b08 s5b09 s5b10 x paddy rice wheat 
destring hhcode, replace
save `sect4'


**** INCOMES FROM SECTION 5: NON-AGRICULTURAL BUSINESSES                                               
* Self-Employed (s5a06==2)                                                         
tempfile section4
tempfile sect5
tempfile section5
tempfile section5_1
tempfile section5_2
tempfile section5_2aux
tempfile section5_3

* FOR THOSE WITH INCOME INFO AND MATCHING EMPLOYMENT INFO
* Preparation of Section 5 (to be merged with Section 6)
use "${input}\activity.dta", clear
keep if s5a06==2
gen  idp = idc

* Keeping the activity with the most worked hours
gen  hours = s5a02 * s5a03 * s5a04
egen aux_hours = sum(hours), by(hhcode idp)
egen max_hours = max(hours), by(hhcode idp)
drop if hours!=max_hours
duplicates tag hhcode idp, gen(tag)
drop if tag==1 & activity!="B"
replace hours = aux_hours

* Share of individual hours in household hours
egen hours_hh = sum(hours), by(hhcode)
gen  share_ind = hours/hours_hh
order hhcode idp 
sort  hhcode idp
drop  idc* max_hours tag hours_hh aux_hours  
save `section4'

use "${input}\business.dta", clear
* Total Non-Agricultural Income by Activity
* s620: Net revenues over the past 12 months?
* s607: What share of profit is owned by household?
gen month_nonagri = (s620 * (s607/100)) / 12
collapse (sum) month_nonagri, by(hhcode)
sort hhcode
save `section5'	

use  `section4'	
sort  hhcode idp
merge m:1 hhcode using `section5'

* Save info for those with income info but without employment info
preserve
tempfile only_income_info
keep if _merge==2 
keep hhcode month_nonagri
sort hhcode
save `only_income_info'	
restore

replace month_nonagri = month_nonagri*share_ind
drop if _merge==2
gen   x1 = 1	if  _merge==1
drop _merge share_ind
sort  hhcode idp
save `section5_1'	

* FOR THOSE WITH INCOME INFO BUT WITHOUT MATCHING EMPLOYMENT INFO
use "${input}\business.dta", clear
sort hhcode
merge m:1 hhcode using `only_income_info'
drop if _merge!=3
drop _merge 
keep if business==1
keep hhcode s601b month_nonagri
sort hhcode
save    `section5_2aux'

use "${input}\activity.dta", clear
gen  idp = idc
drop if s5a06==1 | s5a06==3

gen hours = s5a02 * s5a03 * s5a04
collapse (sum) hours, by(hhcode idp)
egen share_tot = sum(hours), by(hhcode)
gen  share_ind = hours/share_tot
sort hhcode idp
merge m:1 hhcode using `section5_2aux'	

* Save info for those with income info but without employment info
preserve
keep if _merge==2 
keep hhcode s601b month_nonagri
sort hhcode
tempfile only_income_info_2
save `only_income_info_2'	
restore

replace month_nonagri = month_nonagri*share_ind
drop if _merge!=3
drop _merge share_ind
keep  hhcode idp s601b month_nonagri
order hhcode idp s601b month_nonagri
sort hhcode idp
gen  x2 = 1
save `section5_2'	

* FOR THOSE WITH INCOME INFO BUT WITHOUT EMPLOYMENT INFO AT ALL
use `roster', clear
merge m:1 hhcode using `only_income_info_2'
drop if _merge!=3
drop if relation!=1
drop _merge
keep hhcode idp s601b month_nonagri
gen  x3 = 1
sort hhcode idp
save `section5_3'

* Append Section 5
use          `section5_1'
append using `section5_2'
append using `section5_3'	

gen     anomalies = 1	if  x1==1
replace anomalies = 2	if  x2==1
replace anomalies = 3    if  x3==1
drop x*
sort hhcode idp
destring hhcode, replace
save    `sect5'


**** INCOMES FROM SECTION 7: AGRICULTURAL ACTIVITIES
* Self-Employed (s5a06==3)
tempfile section7
tempfile section4
use "${input}\activity.dta", clear
destring hhcode, replace
keep if s5a06==3
gen  idp = idc

* Keeping the activity with the most worked hours
gen  hours = s5a02 * s5a03 * s5a04
egen aux_hours = sum(hours), by(hhcode idp)
egen max_hours = max(hours), by(hhcode idp)
drop if hours!=max_hours
duplicates tag hhcode idp, gen(tag)
drop if tag==1 & activity!="B"
replace hours = aux_hours

* Share of individual hours in household hours
egen hours_hh = sum(hours), by(hhcode)
gen  share_ind = hours/hours_hh
order hhcode idp 
sort  hhcode idp 
drop  idc max_hours tag hours_hh aux_hours 
save `section4'


**** Section 7B  - CROP PRODUCTION at household/crop level
tempfile section7b
use "${input}\agri02.dta", clear
* s7b02a: How much in total of crop did you produce in the last 12 months? (kg)
* s7b02b: How much in total of crop did you produce in the last 12 months? (taka/kg)
*  s7b05: How much did your household consumed in the last 12 months?
*  s7b04: How much did your household sell in the last 12 months?
gen crop_cons = s7b05 * s7b02b/12	
gen crop_sold = s7b04 * s7b02b/12
collapse (sum) crop_cons crop_sold, by(hhcode)
drop if crop_cons==0 & crop_sold==0
sort  hhcode
save `section7b', replace


**** Sección 7C1 - LIVESTOCK and POULTRY at household/animal level
tempfile section7c1
use "${input}\agri03.dta", clear
* s7c03b: How many died/did your household sell in the last 12 months? (taka)
* s7c04b: How many did your household consume in the 12 months? (taka)
gen livestock_cons = s7c03b/12
gen livestock_sold = s7c04b/12
collapse (sum) livestock_cons livestock_sold, by(hhcode)
drop if livestock_cons==0 & livestock_sold==0
sort  hhcode
save `section7c1', replace


**** Sección 7C2 - LIVESTOCK and POULTRY BY-PRODUCTS at household/by-product level
tempfile section7c2
use "${input}\agri04.dta", clear
* s7c02b: How much did you sell in the last 12 months? (taka)
* s7c03b: How much did you consume in the last 12 months? (taka
gen byproduct_cons = s7c03b/12
gen byproduct_sold = s7c02b/12
collapse (sum) byproduct_cons byproduct_sold, by(hhcode)
drop if byproduct_cons==0 & byproduct_sold==0
sort  hhcode
save `section7c2', replace


**** Sección 7C3 - FISH FARMING and FISH CAPTURE at household/fish level
tempfile section7c3
use "${input}\agri05.dta", clear
* s7c02b: How much did your household sell in the past 12 months? (taka)
* s7c03b: How much did your household consume in the 12 months? (taka)
gen fish_cons = s7c03b/12
gen fish_sold = s7c02b/12
collapse (sum) fish_cons fish_sold, by(hhcode)
drop if fish_cons==0 & fish_sold==0
sort  hhcode
save `section7c3', replace


**** Sección 7C4 - FARM FORESTRY at household/tree level
tempfile section7c4
use "${input}\agri06.dta", clear
* s7c02: How much did your household sell in the last 12 months? (taka)
* s7c03: How much did your household consume in the last 12 months? (taka
gen tree_cons = s7c03/12
gen tree_sold = s7c02/12
collapse (sum) tree_cons tree_sold, by(hhcode)
drop if tree_cons==0 & tree_sold==0
sort  hhcode
save `section7c4', replace


**** Sección 7D - EXPENSES ON AGRICULTURAL INPUTS at household/input level
tempfile section7d
use "${input}\agri07.dta", clear

* s7d01b: How much did your household spend on the (item) in the last 12 months? (Taka)
gen     agri_expenditure = s7d01b/12
replace agri_expenditure = agri_expenditure*(-1)
collapse (sum) agri_expenditure, by(hhcode)
drop if agri_expenditure==0
sort  hhcode
save `section7d', replace


use  `section7b', clear
merge 1:1 hhcode using `section7c1'
drop _merge
sort  hhcode
merge 1:1 hhcode using `section7c2'
drop _merge
sort  hhcode
merge 1:1 hhcode using `section7c3'
drop _merge
sort  hhcode
merge 1:1 hhcode using `section7c4'
drop _merge
sort  hhcode
merge 1:1 hhcode using `section7d'
drop _merge
sort  hhcode
egen agri_income = rsum(crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold), missing

gen     type_agri = 1	if  agri_income==.					/* no agricultural income, but agricultural expenditure		*/
replace type_agri = 2	if  agri_expend==.					/* no agricultural expenditure, but agricultural income 	*/
replace type_agri = 3	if  agri_income!=. & agri_expend!=.	/* both agricultural income and agricultural expenditure 	*/

egen  agri_net = rsum(agri_income agri_expend), missing

keep  hhcode agri_net agri_income agri_expend crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold
order hhcode agri_net agri_income agri_expend crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold
destring hhcode, replace
sort  hhcode
save `section7'	


************************************************************
* FOR THOSE WITH INCOME INFO AND MATCHING EMPLOYMENT INFO
************************************************************
tempfile section7_1
use  `section4'	
sort  hhcode idp
merge m:1 hhcode using `section7'

* Save info for those with income info but without employment info
preserve
keep if _merge==2 
keep hhcode agri_net agri_income agri_expend crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold
sort hhcode
tempfile only_income_info3
save `only_income_info3'	
restore

local lista "agri_net agri_income agri_expend crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold"
foreach income in `lista' {
	replace `income' = `income'*share_ind
	}
drop if _merge==2
gen    x1 = 1	if  _merge==1
drop _merge share_ind
order hhcode idp agri_net agri_income agri_expend crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold 
sort  hhcode idp
save `section7_1'	


*******************************************************************
* FOR THOSE WITH INCOME INFO BUT WITHOUT MARCHING EMPLOYMENT INFO
*******************************************************************
tempfile section7_2
use "${input}\activity.dta", clear
gen  idp = idc
drop if s5a06==3
gen hours = s5a02 * s5a03 * s5a04
collapse (sum) hours, by(hhcode idp)
egen share_tot = sum(hours), by(hhcode)
gen  share_ind = hours/share_tot
keep hhcode idp share_ind
destring hhcode, replace
sort hhcode idp
merge m:1 hhcode using `only_income_info3'	

* Save info for those with income info but without employment info
preserve
keep if _merge==2 
keep hhcode agri_net agri_income agri_expend crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold
sort hhcode
tempfile only_income_info_4
save `only_income_info_4'	
restore

local lista "agri_net agri_income agri_expend crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold"
foreach income in `lista' {
	replace `income' = `income'*share_ind
	}
drop if _merge!=3
drop    _merge

keep  hhcode idp agri_net agri_income agri_expend crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold 
order hhcode idp agri_net agri_income agri_expend crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold 
sort  hhcode idp
gen   x2=1
save `section7_2'	


********************************************************************
* FOR THOSE WITH INCOME INFO BUT WITHOUT EMPLOYMENT INFO AT ALL
********************************************************************
use `roster', clear
destring hhcode, replace
merge m:1 hhcode using `only_income_info_4'
drop if _merge!=3
drop if relation!=1
drop _merge
keep hhcode idp agri_net agri_income agri_expend crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold
gen  x3 = 1
sort hhcode idp

tempfile section7_3
save `section7_3'

********************
* Append Section 7
********************
use          `section7_1'
append using `section7_2'	
append using `section7_3'	

gen     anomalies2 = 4	if  x1==1
replace anomalies2 = 5	if  x2==1
replace anomalies2 = 6	if  x3==1
drop x*
sort hhcode idp
destring hhcode, replace
tempfile sect7
save    `sect7'


**************************
* Append Sections 4-5-7
**************************
use          `sect4'
append using `sect5'	
append using `sect7'

replace anomalies = anomalies2 	if  anomalies==.
notes   anomalies: "=1 if it is non-agricultural self-employed or employer, but without income information"
notes   anomalies: "=2 if it has non-agricultural income, but it is employed in another sector"
notes   anomalies: "=3 if it has non-agricultural income, but is it not employed"
notes   anomalies: "=4 if it is agricultural self-employed or employer, but without income information"
notes   anomalies: "=5 if it has agricultural income, but it is employed in another sector"
notes   anomalies: "=6 if it has agricultural income, but is it not employed"
drop    anomalies2 

* Employment Categories
gen 	w_cat = 1 				if  s5a06==1  
replace w_cat = 2 				if  s5a06==2 | s5a06==3 

* Worked Hours (Year)
capture drop hours
gen hours = s5a02 * s5a03 * s5a04

* Worked Months
gen     months = s5a02

* Industry
destring s5a01c, replace

replace s5a01c = s601b			if  s5a01c==.
replace s5a01c = 1				if  anomalies==5 | anomalies==6

egen    income = rsum(daylab_cash daylab_kind employee_cash employee_kind month_nonagri agri_net), missing
replace income = income*(-1)

local var "w_cat hours months s5a01b s5a01c s5b07 daylab_cash daylab_kind employee_cash employee_kind month_nonagri agri_net anomalies"
foreach v in `var' {
	rename `v' `v'_
	}
sort hhcode idp income
by   hhcode idp: gen act = _n				   

keep  hhcode idp 	w_cat hours months s5a01b s5a01c s5b07 daylab_cash daylab_kind employee_cash employee_kind month_nonagri agri_net act anomalies
order hhcode idp 	w_cat hours months s5a01b s5a01c s5b07 daylab_cash daylab_kind employee_cash employee_kind month_nonagri agri_net act anomalies
reshape wide  	w_cat hours months s5a01b s5a01c s5b07 daylab_cash daylab_kind employee_cash employee_kind month_nonagri agri_net anomalies, j(act) i(hhcode idp)

label   define worker 1 Employee 2 SelfEmployed 
label   values  w_cat_1 worker
label   values  w_cat_2 worker
label   values  w_cat_3 worker
label   values  w_cat_4 worker
label   values  w_cat_5 worker

forvalues t = 1(1)5 {
label var hours_`t' 				"Yearly Hours of work in activity `t'"
label var months_`t' 			"Months of work in activity `t'"
label var w_cat_`t' 				"Employment Category - Activity `t'"
label var s5a01c_`t' 			"Industry Code - Activity `t'"
label var s5a01b_`t' 			"Occupation Code - Activity `t'"
label var s5b07_`t' 				"Sector of Occupation - Activity `t'"
label var daylab_cash_`t' 		"Monthly income (CASH) of daily labourers (taka) - Activity `t'"
label var daylab_kind_`t' 		"Monthly income (IN-KIND) of daily labourers (taka) - Activity `t'"
label var employee_cash_`t' 		"Monthly income (CASH) of employees (taka) - Activity `t'"
label var employee_kind_`t' 		"Monthly income (KIND) of employees (taka) - Activity `t'"
label var month_nonagri_`t' 		"Monthly income in non-agricultural activities as self-employed or employer (taka) - Activity `t'"
label var agri_net_`t' 			"Monthly income in agricultural activities as self-employed or employer (taka) - Activity `t'"
}
tempfile sect_4_5_7
sort hhcode idp
save `sect_4_5_7'

use `roster', clear
destring hhcode, replace
merge 1:1 hhcode idp using `sect_4_5_7'
drop if _merge==2
drop _merge
tempfile sect_4_5_7
sort hhcode idp

local var "daylab_cash_ daylab_kind_ employee_cash_ employee_kind_ month_nonagri_ agri_net_"
foreach income in `var' {
	forvalues j = 1(1)5 {
	replace `income'`j' = .	if `income'`j'==0
	}
	}
save `sect_4_5_7'


****************************************
* INCOMES FROM SECTION 8: OTHER INCOME 
****************************************
tempfile sect8
use "${input}\hhlist.dta", clear
keep hhcode s8b01 s8b02 s8b03 s8b04 s8b05 s8b06 s8b07 s8b08 s8b09 s8b10 s8b11 s8b12 

unab xvars: s8b01 s8b02 s8b03 s8b04 s8b05 s8b06 s8b07 s8b08 s8b09 s8b10 s8b11 s8b12
foreach x of local xvars { 
    replace `x' = `x'/12
}
keep hhcode s8b01 s8b02 s8b03 s8b04 s8b05 s8b06 s8b07 s8b08 s8b09 s8b10 s8b11 s8b12
sort hhcode
destring hhcode, replace
save `sect8'

use `sect_4_5_7'
merge m:1 hhcode using `sect8'
drop _merge
unab xvars: s8b01 s8b02 s8b03 s8b04 s8b05 s8b06 s8b07 s8b08 s8b09 s8b10 s8b11 s8b12
foreach x of local xvars { 
    replace `x' = . 	if  relation!=1
	replace `x' = .		if  `x'==0
	}
sort hhcode idp
tempfile sect_4_5_7_8
save `sect_4_5_7_8'


****************************************
* INCOMES FROM SECTION 9: HOUSING RENT 
****************************************
tempfile sect9
use "${input}\hh_s9d_nfood03.dta", clear
keep  if itemcode==372
duplicates report hhcode
gen   housing_rent = value/12
sort  hhcode
destring hhcode, replace
save `sect9', replace

use `sect_4_5_7_8'
merge m:1 hhcode using `sect9'
drop _merge
sort hhcode idp
tempfile sect_4_5_7_8_9
save    `sect_4_5_7_8_9'


***********************************************
* INCOMES FROM SECTION 8C: SOCIAL SAFETY NETS
***********************************************
tempfile sect1
use "${input}\hhlist.dta", clear
keep  hhcode s8b13*
order hhcode

egen wheat = rsum(s8b13dw s8b13fw s8b13gw s8b13ew)
egen  rice = rsum(s8b13dr s8b13fr s8b13gr s8b13er)
replace wheat = wheat*12/12
replace  rice = rice*12/12
egen    ssn_kind = rsum(wheat rice), missing
keep hhcode ssn_kind
collapse (sum) ssn_kind, by(hhcode)
sort  hhcode
destring hhcode, replace
save `sect1', replace

use `sect_4_5_7_8_9'
merge m:1 hhcode using `sect1'
drop _merge
tempfile income
sort hhcode idp
save `income', replace


***************************************************************************************************
**** BASIC
***************************************************************************************************
tempfile basic
use "${input}\hhlist.dta", clear
keep hhcode-hhsize
duplicates report 
duplicates drop
sort hhcode
save `basic', replace

***************************************************************************************************
**** ROSTER
***************************************************************************************************
tempfile roster
use "${input}\plist.dta", clear
gen   idp = idc
order hhcode idp
duplicates report
duplicates drop
keep hhcode idp psu sex-mstatus s1b01-s1b04 s3a* s3b* 
sort hhcode idp
save `roster', replace

	
***************************************************************************************************
**** ASSETS - MATERIALS
***************************************************************************************************
use "${input}\hh_s9e_durables.dta", clear
keep hhcode itemcode number
keep if number>0 & number<.
replace number = 1
rename number asset
collapse (mean) asset, by(hhcode itemcode)
reshape wide asset, i(hhcode) j(itemcode)
tempfile assets
save `assets'

	
***************************************************************************************************
**** ASSETS - ANIMALS
***************************************************************************************************
use "${input}\agri03.dta", clear
tempfile assets_animal
sort hhcode
gen animal = 1	if s7c01a>0 & s7c01a<5000
drop s7* hhid psu
collapse (mean) animal, by(hhcode animcode)
reshape wide animal, i(hhcode) j(animcode)
duplicates report hhcode
save `assets_animal', replace	
	
	
***************************************************************************************************
**** CONSUMPTION
***************************************************************************************************
use "${input}\consumption_00_05_10.dta", clear
tempfile consumption
keep if year==1
replace year = 2000
rename id hhcode
duplicates report hhcode 
sort hhcode
drop stratum div psu
destring hhcode, replace
save `consumption', replace

	
***************************************************************************************************
**** HOUSING
***************************************************************************************************
use "${input}\hhlist.dta", clear
keep hhcode s2*
tempfile housing
order hhcode
duplicates report hhcode
sort hhcode
save `housing', replace
	
	
***************************************************************************************************
**** LAND
***************************************************************************************************
use "${input}\agri01.dta", clear
tempfile land
keep  hhcode s7a*
order hhcode
duplicates report hhcode
sort hhcode
save `land', replace
	
	
***************************************************************************************************
**** MERGE DATASETS
***************************************************************************************************
* Individual-level datasets
use `roster', clear
merge 1:1 hhcode idp using  `income', keep(1 3) nogen
	
* Household-level datasets
foreach j in basic housing consumption assets assets_animal land {
	merge m:1 hhcode using ``j'', keep(1 3) nogen
	}
rename wgt hhwgt
order  hhcode idp hhwgt
sort   hhcode idp
rename idp idp1
*</_Datalibweb request_>


*<_Save data file_>
compress
save "${output}/`yearfolder'_v`vm'_M.dta", replace
*</_Save data file_>
