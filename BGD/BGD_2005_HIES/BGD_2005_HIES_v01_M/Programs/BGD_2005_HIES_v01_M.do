/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   		BGD_2005_HIES_v01_M.do				   </_Program name_>
<_Application_>    		STATA 17.0							     <_Application_>
<_Author(s)_>      		acastillocastill@worldbank.org	          </_Author(s)_>
<_Author(s)_>      		tornarolli@gmail.com	          		  </_Author(s)_>
<_Date created_>   		05-25-2021	                           </_Date created_>
<_Date modified>   		08-09 2023	                          </_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        		BGD											</_Country_>
<_Survey Title_>   		HIES								   </_Survey Title_>
<_Survey Year_>    		2005									</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:					08-15-2023
File:					BGD_2005_HIES_v01_M.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>
clear all
set more off

global cpiver       	"10"
local code         		"BGD"
local year         		"2005"
local survey       		"HIES"
local vm           		"01"
local va           		"06"
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
use "${input}\s1a.dta", clear
gen     idp = idc
order   hhold idp
duplicates report
duplicates drop
keep hhold idp q01_1a-q07_1a
sort hhold idp
save `roster'

* INCOMES FROM SECTION 5: DAY LABOURERS and EMPLOYEES    
* Day labourers (q07_5a==1 | q08_5a==1)                                                      
* Employees     (q07_5a==4 | q08_5a==4)   
tempfile sect4
tempfile s5b
use "${input}\s5b.dta", clear
duplicates report hhold idc as
duplicates drop 
save `s5b'

use "${input}\s5a.dta", clear
sort hhold idc as
merge 1:1 hhold idc as using `s5b' 
 
replace q02_5a = 12		if  q02_5a>12 & q02_5a<.
replace q03_5a = 30		if  q03_5a>30 & q03_5a<.
replace q04_5a = 24		if  q04_5a>24 & q04_5a<.			
	
gen     q78_5a = 1		if  q07_5a!=1 & q07_5a!=4 & q08_5a!=1 & q08_5a!=4 & q02c_5b!=. & q01_5b==1		// to correct inconsistencies
replace q78_5a = 4		if  q07_5a!=1 & q07_5a!=4 & q08_5a!=1 & q08_5a!=4 &  q08_5b!=. & q01_5b==2		// to correct inconsistencies
replace q78_5a = 4		if  q07_5a!=1 & q07_5a!=4 & q08_5a!=1 & q08_5a!=4 &  q09_5b!=. & q01_5b==2		// to correct inconsistencies
keep if q08_5a==1 | q07_5a==1 | q08_5a==4 | q07_5a==4 |  q78_5a==1 | q78_5a==4
gen  idp = idc

* Monthly Income of those working as day labourers
* q02c_5b: What was the (average) daily wage in cash in the past 12 months? (TAKA)
* q05b_5b: How much did you receive in-kind per day? (TAKA)
*  q03_5a: On average, how many days per month did you work?
*  q02_5a: How many months did you do this activity in the last 12 months?
gen daylab_cash = q02c_5b * q03_5a * (q02_5a/12)		if  q01_5b==1 	
gen daylab_kind = q05b_5b * q03_5a * (q02_5a/12)		if  q01_5b==1 & q03_5b==1

* Monthly Income of those working as employees
* q08_5b: What is your total net take-home monthly remuneration after all deduction at source?
* q09_5b: What is the total value of in-kind or other benefits you received over the past 12 months?
gen employee_cash = q08_5b							if  q01_5b==2
gen employee_kind = q09_5b/12							if  q01_5b==2

egen x = rsum( daylab_cash daylab_kind employee_cash employee_kind), missing
drop if x==.
order  hhold idp 
sort   hhold idp 
ta _merge
drop  q05* q06_5a q01_5b q02a_5b q02b_5b q02c_5b q03_5b q04_5b q07_5b q08_5b q09_5b x up _merge rec_type div rmo stratum wgt
destring hhold, replace
save `sect4'


**** INCOMES FROM SECTION 5: NON-AGRICULTURAL BUSINESSES                                               
* Self-Employed (q08_5a==2)                                                         
* Employers     (q08_5a==3) 
tempfile section4
tempfile sect5
tempfile section5
tempfile section5_1
tempfile section5_2
tempfile section5_2aux
tempfile section5_3

* FOR THOSE WITH INCOME INFO AND MATCHING EMPLOYMENT INFO
* Preparation of Section 5 (to be merged with Section 6)
use "${input}\s5a.dta", clear
sort hhold idc as
merge 1:1 hhold idc as using `s5b' 
drop  _merge
keep if q08_5a==2 | q08_5a==3
gen  idp = idc

* Keeping the activity with the most worked hours
gen  hours = q02_5a * q03_5a * q04_5a
egen aux_hours = sum(hours), by(hhold idp)
egen max_hours = max(hours), by(hhold idp)
drop if hours!=max_hours
duplicates tag hhold idp, gen(tag)
drop if (hhold=="3140601121" | hhold=="1831412004") & as=="A" & tag==1 
drop if (hhold=="0350201033" | hhold=="1951502209" | hhold=="2232104203" | hhold=="1282805168" | hhold=="3480307049" | hhold=="4390809137" | hhold=="3921010137" | hhold=="2411411182" | hhold=="2742112007" | hhold=="3110612063" | hhold=="2481516029" | hhold=="2602016052" | hhold=="4872316122" | hhold=="2401415159" | hhold=="1391514035") & as=="B" & tag==1 
drop if (hhold=="2752101133" | hhold=="1482204082" | hhold=="0330106009" | hhold=="2481516090") & as=="C" & tag==1 
drop if (hhold=="1142705054" | hhold=="0522806109" | hhold=="0482511170") & as=="D" & tag==1 
drop if (hhold=="3160609027" | hhold=="2461512155") & as=="E" & tag==1 
drop if  hhold=="4610901080" & as=="F" & tag==1 
replace hours = aux_hours

* Share of individual hours in household hours
egen hours_hh = sum(hours), by(hhold)
gen  share_ind = hours/hours_hh
order hhold idp 
sort  hhold idp
drop  idc* max_hours wgt up tag hours_hh aux_hours rec_type div rmo stratum q05* 
save `section4'

use "${input}\s61.dta", clear
merge 1:1 hhold en using "${input}\s62.dta"
keep if _merge==3
drop _merge 

* Total Non-Agricultural Income by Activity
* q20_62: Net revenues over the past 12 months?
* q07_61: What share of profit is owned by household?
gen month_nonagri = (q20_62 * (q07_61/100)) / 12
collapse (sum) month_nonagri, by(hhold)
sort hhold
save `section5'	

use  `section4'	
sort  hhold idp
merge m:1 hhold using `section5'

* Save info for those with income info but without employment info
preserve
tempfile only_income_info
keep if _merge==2 
keep hhold month_nonagri
sort hhold
save `only_income_info'	
restore

replace month_nonagri = month_nonagri*share_ind
drop if _merge==2
gen   x1 = 1	if  _merge==1
drop _merge share_ind
sort  hhold idp
save `section5_1'	

* FOR THOSE WITH INCOME INFO BUT WITHOUT MATCHING EMPLOYMENT INFO
use "${input}\s61.dta", clear
merge 1:1 hhold en using "${input}\s62.dta"
keep if _merge==3
drop _merge 

sort hhold
merge m:1 hhold using `only_income_info'
drop if _merge!=3
drop _merge 
keep if en=="1"
keep hhold q01b_61 month_nonagri
sort hhold
save    `section5_2aux'

use "${input}\s5a.dta", clear
gen  idp = idc
drop if q08_5a==2 | q08_5a==3

gen hours = q02_5a * q03_5a * q04_5a
collapse (sum) hours, by(hhold idp)
egen share_tot = sum(hours), by(hhold)
gen  share_ind = hours/share_tot
sort hhold idp
merge m:1 hhold using `section5_2aux'	

* Save info for those with income info but without employment info
preserve
keep if _merge==2 
keep hhold q01b_61 month_nonagri
sort hhold
tempfile only_income_info_2
save `only_income_info_2'	
restore

replace month_nonagri = month_nonagri*share_ind
drop if _merge!=3
drop _merge share_ind
keep  hhold idp q01b_61 month_nonagri
order hhold idp q01b_61 month_nonagri
sort hhold idp
gen  x2 = 1
save `section5_2'	

* FOR THOSE WITH INCOME INFO BUT WITHOUT EMPLOYMENT INFO AT ALL
use `roster', clear
merge m:1 hhold using `only_income_info_2'
drop if _merge!=3
drop if q03_1a!=1
drop _merge
keep hhold idp q01b_61 month_nonagri
gen  x3 = 1
sort hhold idp
save `section5_3'

* Append Section 5
use          `section5_1'
append using `section5_2'
append using `section5_3'	

gen     anomalies = 1	if  x1==1
replace anomalies = 2	if  x2==1
replace anomalies = 3    if  x3==1
drop x*
sort hhold idp
destring hhold, replace
save    `sect5'


**** INCOMES FROM SECTION 7: AGRICULTURAL ACTIVITIES
* Self-Employed (q07_5a==2)
* Employers     (q07_5a==3)
tempfile section7
tempfile section4
use "${input}\s5a.dta", clear
sort hhold idc as
merge 1:1 hhold idc as using `s5b' 
drop  _merge
destring hhold, replace
keep if q07_5a==2 | q07_5a==3
gen  idp = idc

* Keeping the activity with the most worked hours
gen  hours = q02_5a * q03_5a * q04_5a
egen aux_hours = sum(hours), by(hhold idp)
egen max_hours = max(hours), by(hhold idp)
drop if hours!=max_hours
duplicates tag hhold idp, gen(tag)
drop if tag==1 & as!="A"
replace hours = aux_hours

* Share of individual hours in household hours
egen hours_hh = sum(hours), by(hhold)
gen  share_ind = hours/hours_hh
order hhold idp 
sort  hhold idp 
drop  q05a_5a q05b_5a idc max_hours tag as hours_hh aux_hours rec_type div rmo stratum wgt up
save `section4'


**** Section 7B  - CROP PRODUCTION at household/crop level
tempfile section7b
use "${input}\s7b.dta", clear
* q02a_7b: How much in total of crop did you produce in the last 12 months? (kg)
* q02b_7b: How much in total of crop did you produce in the last 12 months? (taka/kg)
*  q05_7b: How much did your household consumed in the last 12 months?
*  q04_7b: How much did your household sell in the last 12 months?
gen crop_cons = q05_7b * q02b_7b/12	
gen crop_sold = q04_7b * q02b_7b/12
collapse (sum) crop_cons crop_sold, by(hhold)
drop if crop_cons==0 & crop_sold==0
sort  hhold
save `section7b', replace


**** Sección 7C1 - LIVESTOCK and POULTRY at household/animal level
tempfile section7c1
use "${input}\s7c1.dta", clear
* q03b_7c1: How many died/did your household sell in the last 12 months? (taka)
* q04b_7c1: How many did your household consume in the 12 months? (taka)
gen livestock_cons = q03b_7c1/12
gen livestock_sold = q04b_7c1/12
collapse (sum) livestock_cons livestock_sold, by(hhold)
drop if livestock_cons==0 & livestock_sold==0
sort  hhold
save `section7c1', replace


**** Sección 7C2 - LIVESTOCK and POULTRY BY-PRODUCTS at household/by-product level
tempfile section7c2
use "${input}\s7c2.dta", clear
* q02b_7c2: How much did you sell in the last 12 months? (taka)
* q03b_7c2: How much did you consume in the last 12 months? (taka
gen byproduct_cons = q03b_7c2/12
gen byproduct_sold = q02b_7c2/12
collapse (sum) byproduct_cons byproduct_sold, by(hhold)
drop if byproduct_cons==0 & byproduct_sold==0
sort  hhold
save `section7c2', replace


**** Sección 7C3 - FISH FARMING and FISH CAPTURE at household/fish level
tempfile section7c3
use "${input}\s7c3.dta", clear
* q02b_7c3: How much did your household sell in the past 12 months? (taka)
* q03b_7c3: How much did your household consume in the 12 months? (taka)
gen fish_cons = q03b_7c3/12
gen fish_sold = q02b_7c3/12
collapse (sum) fish_cons fish_sold, by(hhold)
drop if fish_cons==0 & fish_sold==0
sort  hhold
save `section7c3', replace


**** Sección 7C4 - FARM FORESTRY at household/tree level
tempfile section7c4
use "${input}\s7c4.dta", clear
* q02_7c4: How much did your household sell in the last 12 months? (taka)
* q03_7c4: How much did your household consume in the last 12 months? (taka
gen tree_cons = q03_7c4/12
gen tree_sold = q02_7c4/12
collapse (sum) tree_cons tree_sold, by(hhold)
drop if tree_cons==0 & tree_sold==0
sort  hhold
save `section7c4', replace


**** Sección 7D - EXPENSES ON AGRICULTURAL INPUTS at household/input level
tempfile section7d
use "${input}\s7d.dta", clear

* q01b_7d: How much did your household spend on the (item) in the last 12 months? (Taka)
gen     agri_expenditure = q01b_7d/12
replace agri_expenditure = agri_expenditure*(-1)
collapse (sum) agri_expenditure, by(hhold)
drop if agri_expenditure==0
sort  hhold
save `section7d', replace


use  `section7b', clear
merge 1:1 hhold using `section7c1'
drop _merge
sort  hhold
merge 1:1 hhold using `section7c2'
drop _merge
sort  hhold
merge 1:1 hhold using `section7c3'
drop _merge
sort  hhold
merge 1:1 hhold using `section7c4'
drop _merge
sort  hhold
merge 1:1 hhold using `section7d'
drop _merge
sort  hhold
egen agri_income = rsum(crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold), missing

gen     type_agri = 1	if  agri_income==.					/* no agricultural income, but agricultural expenditure		*/
replace type_agri = 2	if  agri_expend==.					/* no agricultural expenditure, but agricultural income 	*/
replace type_agri = 3	if  agri_income!=. & agri_expend!=.	/* both agricultural income and agricultural expenditure 	*/

egen  agri_net = rsum(agri_income agri_expend), missing

keep  hhold agri_net agri_income agri_expend crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold
order hhold agri_net agri_income agri_expend crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold
destring hhold, replace
sort  hhold
save `section7'	


************************************************************
* FOR THOSE WITH INCOME INFO AND MATCHING EMPLOYMENT INFO
************************************************************
tempfile section7_1
use  `section4'	
sort  hhold idp
merge m:1 hhold using `section7'

* Save info for those with income info but without employment info
preserve
keep if _merge==2 
keep hhold agri_net agri_income agri_expend crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold
sort hhold
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
order hhold idp agri_net agri_income agri_expend crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold 
sort  hhold idp
save `section7_1'	


*******************************************************************
* FOR THOSE WITH INCOME INFO BUT WITHOUT MARCHING EMPLOYMENT INFO
*******************************************************************
tempfile section7_2
use "${input}\s5a.dta", clear
gen  idp = idc
drop if q07_5a==2 | q07_5a==3
gen hours = q02_5a * q03_5a * q04_5a
collapse (sum) hours, by(hhold idp)
egen share_tot = sum(hours), by(hhold)
gen  share_ind = hours/share_tot
keep hhold idp share_ind
destring hhold, replace
sort hhold idp
merge m:1 hhold using `only_income_info3'	

* Save info for those with income info but without employment info
preserve
keep if _merge==2 
keep hhold agri_net agri_income agri_expend crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold
sort hhold
tempfile only_income_info_4
save `only_income_info_4'	
restore

local lista "agri_net agri_income agri_expend crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold"
foreach income in `lista' {
	replace `income' = `income'*share_ind
	}
drop if _merge!=3
drop    _merge

keep  hhold idp agri_net agri_income agri_expend crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold 
order hhold idp agri_net agri_income agri_expend crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold 
sort  hhold idp
gen   x2=1
save `section7_2'	


********************************************************************
* FOR THOSE WITH INCOME INFO BUT WITHOUT EMPLOYMENT INFO AT ALL
********************************************************************
use `roster', clear
destring hhold, replace
merge m:1 hhold using `only_income_info_4'
drop if _merge!=3
drop if q03_1a!=1
drop _merge
keep hhold idp agri_net agri_income agri_expend crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold
gen  x3 = 1
sort hhold idp

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
sort hhold idp
destring hhold, replace
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
gen 	w_cat = 1 				if  q07_5a==1 | q08_5a==1 | q78_5a==1 
replace w_cat = 2 				if  q07_5a==2 | q08_5a==2
replace w_cat = 3 				if  q07_5a==3 | q08_5a==3
replace w_cat = 4 				if  q07_5a==4 | q08_5a==4 | q78_5a==4 

* Worked Hours (Year)
capture drop hours
gen     hours = q02_5a * q03_5a * q04_5a

* Worked Months
gen     months = q02_5a

* Industry
destring q01c_5a, replace

replace q01c_5a = q01b_61			if  q01c_5a==.
replace q01c_5a = 1				if  anomalies==5 | anomalies==6

egen    income = rsum(daylab_cash daylab_kind employee_cash employee_kind month_nonagri agri_net), missing
replace income = income*(-1)

local var "w_cat hours months q01b_5a q01c_5a q06_5b daylab_cash daylab_kind employee_cash employee_kind month_nonagri agri_net anomalies"
foreach v in `var' {
	rename `v' `v'_
	}
sort hhold idp income
by   hhold idp: gen act = _n				   

keep  hhold idp 	w_cat hours months q01b_5a q01c_5a q06_5b daylab_cash daylab_kind employee_cash employee_kind month_nonagri agri_net act anomalies
order hhold idp 	w_cat hours months q01b_5a q01c_5a q06_5b daylab_cash daylab_kind employee_cash employee_kind month_nonagri agri_net act anomalies
reshape wide  	w_cat hours months q01b_5a q01c_5a q06_5b daylab_cash daylab_kind employee_cash employee_kind month_nonagri agri_net anomalies, j(act) i(hhold idp)

label   define worker 1 Daily 2 SelfEmployed 3 Employer 4 Employee 
label   values  w_cat_1 worker
label   values  w_cat_2 worker
label   values  w_cat_3 worker
label   values  w_cat_4 worker

forvalues t = 1(1)4 {
label var hours_`t' 				"Yearly Hours of work in activity `t'"
label var months_`t' 			"Months of work in activity `t'"
label var w_cat_`t' 				"Employment Category - Activity `t'"
label var q01c_5a_`t' 			"Industry Code - Activity `t'"
label var q01b_5a_`t' 			"Occupation Code - Activity `t'"
label var q06_5b_`t' 			"Sector of Occupation - Activity `t'"
label var daylab_cash_`t' 		"Monthly income (CASH) of daily labourers (taka) - Activity `t'"
label var daylab_kind_`t' 		"Monthly income (IN-KIND) of daily labourers (taka) - Activity `t'"
label var employee_cash_`t' 		"Monthly income (CASH) of employees (taka) - Activity `t'"
label var employee_kind_`t' 		"Monthly income (KIND) of employees (taka) - Activity `t'"
label var month_nonagri_`t' 		"Monthly income in non-agricultural activities as self-employed or employer (taka) - Activity `t'"
label var agri_net_`t' 			"Monthly income in agricultural activities as self-employed or employer (taka) - Activity `t'"
}
tempfile sect_4_5_7
sort hhold idp
save `sect_4_5_7'

use `roster', clear
destring hhold, replace
merge 1:1 hhold idp using `sect_4_5_7'
drop if _merge==2
drop _merge
tempfile sect_4_5_7
sort hhold idp

local var "daylab_cash_ daylab_kind_ employee_cash_ employee_kind_ month_nonagri_ agri_net_"
foreach income in `var' {
	forvalues j = 1(1)4 {
	replace `income'`j' = .	if `income'`j'==0
	}
	}
save `sect_4_5_7'


****************************************
* INCOMES FROM SECTION 8: OTHER INCOME 
****************************************
tempfile sect8
use "${input}\s8b.dta", clear
keep hhold q01_8b q02_8b q03a_8b q03b_8b q03c_8b q04_8b q05_8b q06_8b q07_8b q08_8b q09_8b q10_8b q11_8b q12_8b

unab xvars: q01_8b q02_8b q03a_8b q03b_8b q03c_8b q04_8b q05_8b q06_8b q07_8b q08_8b q09_8b q10_8b q11_8b q12_8b
foreach x of local xvars { 
    replace `x' = `x'/12
}
keep hhold q01_8b q02_8b q03a_8b q03b_8b q03c_8b q04_8b q05_8b q06_8b q07_8b q08_8b q09_8b q10_8b q11_8b q12_8b
sort hhold
destring hhold, replace
save `sect8'

use `sect_4_5_7'
merge m:1 hhold using `sect8'
drop _merge
unab xvars: q01_8b q02_8b q03a_8b q03b_8b q03c_8b q04_8b q05_8b q06_8b q07_8b q08_8b q09_8b q10_8b q11_8b q12_8b
foreach x of local xvars { 
    replace `x' = . 	if  q03_1a!=1
	replace `x' = .		if  `x'==0
	}
sort hhold idp
tempfile sect_4_5_7_8
save `sect_4_5_7_8'


****************************************
* INCOMES FROM SECTION 9: HOUSING RENT 
****************************************
tempfile sect9
use "${input}\s9d2.dta", clear
keep  if  code=="382"
duplicates report hhold
gen   housing_rent = q01_9d2/12
sort  hhold
destring hhold, replace
save `sect9', replace

use `sect_4_5_7_8'
merge m:1 hhold using `sect9'
drop _merge
sort hhold idp
tempfile sect_4_5_7_8_9
save    `sect_4_5_7_8_9'


***********************************************
* INCOMES FROM SECTION 8C: SOCIAL SAFETY NETS --> at household level
***********************************************
tempfile sect1
tempfile sect2
use  "${input}\s8c2.dta", clear
save `sect2', replace

use  "${input}\s8c1.dta", clear
keep  if  q01a_8c1==1
merge 1:1 hhold sl using `sect2', keep(match)

* Q10A_8C2: How much did you receive in cash in last 12 months?

* OLD-AGE ALLOWANCE (assuming a monthly value of 150, it could be 180 in some months...)
replace q10a_8c2 = 150					if  q01b_8c1==9 & q10a_8c2>0    & q10a_8c2<225
replace q10a_8c2 = 300					if  q01b_8c1==9 & q10a_8c2>225  & q10a_8c2<375
replace q10a_8c2 = 450					if  q01b_8c1==9 & q10a_8c2>375  & q10a_8c2<525
replace q10a_8c2 = 600					if  q01b_8c1==9 & q10a_8c2>525  & q10a_8c2<675
replace q10a_8c2 = 750					if  q01b_8c1==9 & q10a_8c2>675  & q10a_8c2<825
replace q10a_8c2 = 900					if  q01b_8c1==9 & q10a_8c2>825  & q10a_8c2<975
replace q10a_8c2 = 1050					if  q01b_8c1==9 & q10a_8c2>975  & q10a_8c2<1125
replace q10a_8c2 = 1200					if  q01b_8c1==9 & q10a_8c2>1125 & q10a_8c2<1275
replace q10a_8c2 = 1350					if  q01b_8c1==9 & q10a_8c2>1275 & q10a_8c2<1425
replace q10a_8c2 = 1500					if  q01b_8c1==9 & q10a_8c2>1425 & q10a_8c2<1575
replace q10a_8c2 = 1650					if  q01b_8c1==9 & q10a_8c2>1575 & q10a_8c2<1725
replace q10a_8c2 = 1800					if  q01b_8c1==9 & q10a_8c2>1725 & q10a_8c2<1800
replace q10a_8c2 = 1980					if  q01b_8c1==9 & q10a_8c2>1800 & q10a_8c2<.

replace q10a_8c2 = .					if  q10a_8c2==0
replace q10a_8c2 = q10a_8c2/12
egen    ssn = rsum(q10a_8c2), missing

collapse (sum) ssn, by(hhold q01b_8c1)
reshape wide ssn, i(hhold) j(q01b_8c1)
sort     hhold
destring hhold, replace
save `sect1', replace

use `sect_4_5_7_8_9'
merge m:1 hhold using `sect1'
drop _merge
tempfile income
sort hhold idp
destring hhold, replace
save `income', replace

***************************************************************************************************
**** BASIC
***************************************************************************************************
tempfile basic
use "${input}\s0.dta", clear
duplicates report 
duplicates drop
keep hhold dis
sort hhold
destring hhold, replace
save `basic', replace

***************************************************************************************************
**** ROSTER
***************************************************************************************************
tempfile roster
use "${input}\s1a.dta", clear
ren  idc idp
duplicates report 
duplicates drop
egen member1 = count(idp), by(hhold)
drop if member1==0
keep hhold idp q01_1a-q10_1a
sort hhold idp
destring hhold, replace
save `roster', replace


***************************************************************************************************
**** EMPLOYMENT
***************************************************************************************************
tempfile employment
use "${input}\s1b.dta", clear
ren idc idp
duplicates report 
duplicates drop
duplicates tag hhold idp, gen(tag)
drop if hhold=="0011805042" & idp=="06" & q03_1b==. & tag==1
drop if hhold=="0742213175" & idp=="05" & q03_1b==. & tag==1
drop if hhold=="0902618177" & idp=="02" & q03_1b==. & tag==1
drop if hhold=="2021513171" & idp=="02" & q02_1b==. & tag==1
drop if hhold=="2021513171" & idp=="03" & q02_1b==. & tag==1
drop if hhold=="3460318116" & idp=="02" & q03_1b==. & tag==1
drop tag
duplicates drop
keep hhold idp q01_1b-q04_1b
sort hhold idp
destring hhold, replace
save `employment', replace

	
***************************************************************************************************
**** EDUCATION - LITERACY AND ATTAINMENT
***************************************************************************************************
tempfile education_all
use "${input}\s3a.dta", clear
ren idc idp
duplicates report 
duplicates drop
duplicates tag hhold idp, gen(tag)
drop if hhold=="0011805042" & idp=="01" & q01_3a==2 & q02_3a==. & tag==1
drop if hhold=="0011805042" & idp=="03" & q01_3a==2 & q02_3a==. & tag==1
drop if hhold=="0011805042" & idp=="04" & q01_3a==2 & q02_3a==. & tag==1
drop if hhold=="4571004121" & idp=="06" & q01_3a==2 & q02_3a==. & tag==1
drop tag 
keep hhold idp q01_3a-q05_3a
sort hhold idp
destring hhold, replace
save `education_all', replace

	
***************************************************************************************************
**** EDUCATION - CURRENT ENROLLMENT
***************************************************************************************************
tempfile education_current
use "${input}\s3b1.dta",clear
ren idc idp	
duplicates report 
duplicates drop 
duplicates tag hhold idp, gen(tag)
drop if hhold=="0011805042" & idp=="01" & q04_3b1==0 & tag==1
drop if hhold=="0041807032" & idp=="04" & q04_3b1==. & tag==1
drop if hhold=="0100102189" & idp=="02" & q02_3b1==0 & tag==1
drop if hhold=="0110110091" & idp=="02" & q02_3b1==0 & tag==1
drop if hhold=="0350201032" & idp=="04" & q02_3b1==. & tag==1
drop if hhold=="0902618076" & idp=="03" & q02_3b1==. & tag==1
drop if hhold=="2301811093" & idp=="04" & q02_3b1==16 & tag==1
drop tag 
keep hhold idp q01_3b1-q07_3b1
sort hhold idp
destring hhold, replace
save `education_current', replace

	
***************************************************************************************************
**** EDUCATION - STIPEND
***************************************************************************************************
tempfile stipend
use "${input}\s3b1.dta",clear
ren idc idp	
duplicates report 
duplicates drop 
duplicates tag hhold idp, gen(tag)
drop if hhold=="0011805042" & idp=="01" & q04_3b1==0 & tag==1
drop if hhold=="0041807032" & idp=="04" & q04_3b1==. & tag==1
drop if hhold=="0100102189" & idp=="02" & q02_3b1==0 & tag==1
drop if hhold=="0110110091" & idp=="02" & q02_3b1==0 & tag==1
drop if hhold=="0350201032" & idp=="04" & q02_3b1==. & tag==1
drop if hhold=="0902618076" & idp=="03" & q02_3b1==. & tag==1
drop if hhold=="2301811093" & idp=="04" & q02_3b1==16 & tag==1
drop tag 
gen     stipend_primary = q04_3b1/12
replace stipend_primary = .				if  stipend_primary==0
gen 	stipend_secondary = q06_3b1/12
replace stipend_secondary = .			if  stipend_secondary==0

keep hhold idp stipend_*
sort hhold idp
destring hhold, replace
save `stipend', replace


**************************************************************************************************
**** ASSETS - MATERIALS
***************************************************************************************************
use "${input}\s9e.dta", clear
keep hhold code q02_9e
keep if q02_9e>0 & q02_9e<.
replace q02_9e = 1
rename q02_9e asset
destring code, replace
collapse (mean) asset, by(hhold code)
reshape wide asset, i(hhold) j(code)
tempfile assets
destring hhold, replace
save `assets'

	
***************************************************************************************************
**** ASSETS - ANIMALS
***************************************************************************************************
use "${input}\s7c1.dta", clear
tempfile assets_animal
sort hhold
gen animal = 1	if q01a_7c1>0 & q01a_7c1<5000
drop q*7c1 rec_type 
destring anc, replace
collapse (mean) animal, by(hhold anc)
reshape wide animal, i(hhold) j(anc)
duplicates report hhold
destring hhold, replace
save `assets_animal', replace	
	
	
***************************************************************************************************
**** CONSUMPTION
***************************************************************************************************
use "${input}\consumption_00_05_10.dta", clear
tempfile consumption
keep if year==2
replace year = 2005
ren id hhold
duplicates report hhold 
sort hhold
drop stratum div
destring hhold, replace
save `consumption', replace

	
***************************************************************************************************
**** HOUSING
***************************************************************************************************
use "${input}\s2.dta", clear
tempfile housing
order hhold
duplicates report hhold
sort hhold
destring hhold, replace
save `housing', replace
	
	
***************************************************************************************************
**** LAND
***************************************************************************************************
use "${input}\s7a.dta", clear
tempfile land
order hhold
duplicates report hhold
sort hhold
destring hhold, replace
save `land', replace
	
	
***************************************************************************************************
**** MERGE DATASETS
***************************************************************************************************
* Individual-level datasets
use `roster', clear
foreach i in employment education_all education_current stipend income {
	merge 1:1 hhold idp using  ``i'', keep(1 3) nogen
	}
	
* Household-level datasets
foreach j in basic housing consumption assets assets_animal land {
	merge m:1 hhold using ``j'', keep(1 3) nogen
	}
rename wgt hhwgt
order  hhold idp hhwgt
sort   hhold idp
rename idp idp1
*</_Datalibweb request_>


*<_Save data file_>
compress
save "${output}/`yearfolder'_v`vm'_M.dta", replace
*</_Save data file_>
