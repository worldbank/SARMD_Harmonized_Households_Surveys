/*------------------------------------------------------------------------------
  GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   		LKA_2019_HIES_v01_M.do				   </_Program name_>
<_Application_>    		STATA 17.0							     <_Application_>
<_Author(s)_>      		lmorenoherrera@worldbank.org	          </_Author(s)_>
<_Author(s)_>      		tornarolli@gmail.com	          		  </_Author(s)_>
<_Date created_>   		24-05-2022	                           </_Date created_>
<_Date modified>   		11-15-2023	                          </_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        		LKA											</_Country_>
<_Survey Title_>   		HIES								   </_Survey Title_>
<_Survey Year_>    		2019									</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:					11-15-2023
File:					LKA_2019_HIES_v01_M.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>
clear all
set more off

local code         	"LKA"
local year         	"2019"
local survey       	"HIES"
local vm           	"01"
local yearfolder   	"`code'_`year'_`survey'"
global input       	"${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata"
global output      	"${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata"
*</_Program setup_>

	
*<_Datalibweb request_>

***************************************************************************************************
**** FOOD EXPENDITURE
***************************************************************************************************

*** INCOME FROM PAID EMPLOYMENT
use "${input}\SEC_4_1_FOOD_EXP.dta", clear
keep hhid pid code quantity value inkind_value

reshape wide quantity value inkind_value, i(hhid pid) j(code)
destring pid, replace
tostring pid, replace
sort     hhid pid
tempfile food_expenditure
save    `food_expenditure'


***************************************************************************************************
**** INCOME
***************************************************************************************************

*** INCOME FROM PAID EMPLOYMENT
use "${input}\SEC_5_1_EMP_INCOME.dta", clear
* There are some cases where a secondary job is reported, but no primary job is reported
* In those cases, we change the secondary to primary jobs
duplicates tag hhid pid, gen(flag)
replace pri_sec = 1		if  pri_sec==2 & flag==0

* Change format from LONG to WIDE
keep hhid pid pri_sec wages allowences bonus
rename wages_salaries wages_salaries_
rename allowences allowences_
rename bonus bonus_
reshape wide wages allowences bonus, i(hhid pid) j(pri_sec)
replace bonus_1 = bonus_1/12
replace bonus_2 = bonus_2/12
egen employment_income1 = rsum(wages_salaries_1 allowences_1 bonus_1), m
egen employment_income2 = rsum(wages_salaries_2 allowences_2 bonus_2), m
sort hhid pid
tempfile employment_income
save `employment_income'
  
 
*** INCOME FROM AGRICULTURAL ACTIVITIES 
use "${input}\SEC_5_2_AGRI_INCOME.dta", clear
keep hhid pid s52_col_4 s52_col_8 s52_col_81 s52_col_9 s52_col_13
rename s52_col_8   s52_col_8_  		/* there are 89 missings in quantity of output */
rename s52_col_81  s52_col_81_  		/* there are 71 missings in value of output    */
rename s52_col_9   s52_col_9_  		/* there are 83 missings in cost of input      */
rename s52_col_13  s52_col_13_			/* fertilizers and subsidies				   */ 
reshape wide s52_col_8_ s52_col_81_ s52_col_9_ s52_col_13_, i(hhid pid) j(s52_col_4)

egen output = rsum(s52_col_81_1 s52_col_81_2 s52_col_81_3 s52_col_81_4 s52_col_81_5 s52_col_81_6 s52_col_81_7 s52_col_81_9), missing
egen fertil = rsum(s52_col_13_1 s52_col_13_2 s52_col_13_3 s52_col_13_4 s52_col_13_5 s52_col_13_6 s52_col_13_7 s52_col_13_9), missing
egen inputs = rsum(s52_col_9_1 s52_col_9_2 s52_col_9_3 s52_col_9_4 s52_col_9_5 s52_col_9_6 s52_col_9_7 s52_col_9_9), missing
replace inputs = inputs*(-1)
egen    agricultural_income = rsum(output fertil inputs), missing
replace agricultural_income = agricultural_income/12
drop output fertil inputs
sort hhid pid
tempfile agricultural_income
save `agricultural_income'
  
 
*** OTHER AGRICULTURAL INCOME 
use "${input}\SEC_5_3_OTHER_AGRI_INCOME.dta", clear
keep hhid pid seasonal output input fertilizes
rename output_5_3 output_5_3_
rename input_5_3 input_5_3_
rename fertilizes fertilizes_
reshape wide output input fertilizes, i(hhid pid) j(seasonal_crop)

egen output = rsum(output_5_3_1 output_5_3_2 output_5_3_3 output_5_3_4 output_5_3_5 output_5_3_6 output_5_3_7 output_5_3_8 output_5_3_9 output_5_3_10 output_5_3_11 output_5_3_12 output_5_3_13 output_5_3_14 output_5_3_15 output_5_3_16 output_5_3_99), missing
egen fertil = rsum(fertilizes_1 fertilizes_2 fertilizes_3 fertilizes_4 fertilizes_5 fertilizes_6 fertilizes_7 fertilizes_8 fertilizes_9 fertilizes_10 fertilizes_11 fertilizes_12 fertilizes_13 fertilizes_14 fertilizes_15 fertilizes_16 fertilizes_99), missing
egen inputs = rsum(input_5_3_1 input_5_3_2 input_5_3_3 input_5_3_4 input_5_3_5 input_5_3_6 input_5_3_7 input_5_3_8 input_5_3_9 input_5_3_10 input_5_3_11 input_5_3_12 input_5_3_13 input_5_3_14 input_5_3_15 input_5_3_16 input_5_3_99), missing
replace inputs = inputs*(-1)
egen agricultural_other = rsum(output fertil inputs), missing
drop output fertil inputs
sort hhid pid
tempfile agricultural_other
save `agricultural_other'


*** NON-AGRICULTURAL INCOME 
use "${input}\SEC_5_4_NON_AGRI_INCOME.dta", clear

keep hhid pid non_agri output_5_4 input_5_4 subsidies
rename output_5_4 output_5_4_
rename input_5_4 input_5_4_
rename subsidies subsidies_
reshape wide output input subsidies, i(hhid pid) j(non_agri)

egen output = rsum(output_5_4_1 output_5_4_2 output_5_4_3 output_5_4_4 output_5_4_5 output_5_4_6 output_5_4_9), missing
egen subsid = rsum(subsidies_1 subsidies_2 subsidies_3 subsidies_4 subsidies_5 subsidies_6 subsidies_9), missing
egen inputs = rsum(input_5_4_1 input_5_4_2 input_5_4_3 input_5_4_4 input_5_4_5 input_5_4_6 input_5_4_9), missing
replace inputs = inputs*(-1)
egen non_agricultural = rsum(output subsid inputs), missing
drop output subsid inputs
sort hhid pid
tempfile noagricultural_income
save `noagricultural_income'
 
  
*** OTHER INCOME 
use "${input}\SEC_5_5_1_OTHER_INCOME.dta", clear
keep hhid pid pension-income_local
replace other_income = other_income/12
replace income_forign = income_forign/12
replace income_local = income_local/12
sort hhid pid
tempfile other_income
save `other_income'
 
 
*** WINDFALL INCOME 
use "${input}\SEC_5_5_2_WINDFALL_INCOME.dta", clear
keep hhid pid loans-diaster
sort hhid pid
tempfile windfall_income
save `windfall_income'


***************************************************************************************************
**** DURABLE GOODS
***************************************************************************************************
use "${input}\SEC_6A_DURABLE_GOODS.dta", clear
rename s6a_aircon aircon
keep hhid radio tv vcd sewingmechine washing_mechine fridge cookers electric_fans telephone telephone_mobile computers camera aircon bicycle motor_bicycle three_wheeler motor_car_van bus_lorry tractor_2_wheel tractor_4_wheel pesticider threshers waterpumps mechine boats fishing_nets
sort hhid 
tempfile durable_goods
save  `durable_goods'


***************************************************************************************************
**** DEMOGRAPHICS
***************************************************************************************************
use "${input}\SEC_1_DEMOGRAPHIC.dta", clear
keep if residence==1
sort hhid pid
tempfile demographics
save  `demographics'


***************************************************************************************************
**** SCHOOL EDUCATION
***************************************************************************************************
use "${input}\SEC_2_SCHOOL_EDUCATION.dta", clear
sort hhid pid
tempfile school_education
save  `school_education'


***************************************************************************************************
**** HEALTH
***************************************************************************************************
use "${input}\SEC_3A_HEALTH.dta", clear
sort hhid pid
tempfile health_3a
save   `health_3a'

use "${input}\SECTION_3B.dta", clear
sort hhid pid
tempfile health_3b
save   `health_3b'

***************************************************************************************************
**** FACILITIES
***************************************************************************************************
use "${input}\SEC_7_BASIC_FACILITIES.dta", clear
sort hhid
tempfile facilities
save   `facilities'


***************************************************************************************************
**** NON-FOOD EXPENDITURES
***************************************************************************************************
use "${input}\SEC_4_2_NONFOOD.dta", clear
keep if nf_code==2001
sort hhid
tempfile nonfood
save   `nonfood'


***************************************************************************************************
**** HOUSING
***************************************************************************************************
use "${input}\SEC_8_HOUSING.dta", clear
sort hhid
tempfile housing
save   `housing'


***************************************************************************************************
**** LAND OWNERSHIP
***************************************************************************************************
use "${input}\SECTION_9_IS_A_LAND.dta", clear
keep hhid is_agriland_owner
sort hhid
tempfile land_owner
save  `land_owner'


***************************************************************************************************
**** LIVESTOCK OWNERSHIP
***************************************************************************************************
use "${input}\SECTION_9_2_OWNED_LIVESTOCKS.dta", clear
rename s9_cattle cows
keep hhid cows goats_sheeps pigs chickens other_animals
sort hhid
tempfile livestock
save  `livestock'


***************************************************************************************************
**** FINAL WEIGHTS
***************************************************************************************************
use "${input}\weight_2019.dta", clear
sort psu
tempfile weights
save   `weights'


***************************************************************************************************
**** SPATIAL DEFLATORS
***************************************************************************************************
use "${input}\lpindex.dta", clear
sort district
tempfile deflator
save   `deflator'


***************************************************************************************************
**** HOUSEHOLD EXPENDITURE AND INCOME
***************************************************************************************************
use "${input}\HH_expenditure_hh_Income.dta", clear
sort hhid
tempfile hh_exp_inc
save  `hh_exp_inc'

	
***************************************************************************************************
**** MERGE DATASETS
***************************************************************************************************
* Individual-level datasets
use `demographics', clear
foreach i in employment_income agricultural_income agricultural_other noagricultural_income other_income windfall_income school_education health_3b food_expenditure {
	merge 1:1 hhid pid using ``i'', keep(1 3) nogen
	}

* Household-level datasets
foreach j in durable_goods facilities nonfood housing land_owner livestock hh_exp_inc {
	merge m:1 hhid using ``j'', keep(1 2 3) nogen
	}
	
	merge m:1 psu using `weights', keep(3) nogen	
	merge m:1 district using `deflator', keep(3) nogen	


****************************************************************************************************************
****************************************************************************************************************
*** Organizing income according to primary and other jobs
egen agricultural = rsum(agricultural_income agricultural_other), missing
drop agricultural_income agricultural_other
replace agricultural = .		if agricultural==0
replace non_agricultural = .	if non_agricultural==0
replace employment_income1 = .	if employment_income1==0
replace employment_income2 = .	if employment_income2==0

gen xx1 = 1		if  employment_income1!=0 & employment_income1!=.
gen xx2 = 1		if  employment_income2!=0 & employment_income2!=.
gen xx3 = 1		if  agricultural!=0 & agricultural!=.
gen xx4 = 1		if  non_agricultural!=0 & non_agricultural!=.
egen aux_jobs = rsum(xx1 xx2 xx3 xx4), missing
drop xx1 xx2 xx3 xx4

egen x = rowmax(employment_income1 agricultural non_agricultural)

gen x1 = 1		if  x==employment_income1 & aux_jobs>=2 & aux_jobs<=3
gen x2 = 1		if  x==agricultural & aux_jobs>=2 & aux_jobs<=3
gen x3 = 1		if  x==non_agricultural & aux_jobs>=2 & aux_jobs<=3
egen duplicates = rsum(x1 x2 x3), missing

* Employment Income is the higher income for those with 2 or more incomes
gen  employment_income_1 = employment_income1		if  employment_income1==x & duplicates==1
gen  employment_income22 = employment_income1		if  employment_income1!=x 
egen employment_income_2 = rsum(employment_income2 employment_income22), missing

* Agricultural Income is the higher income for those with 2 or more incomes
gen  agricultural_1 = agricultural        			if  agricultural==x & duplicates==1
gen  agricultural_2 = agricultural					if  agricultural!=x 

* Non Agricultural Income is the higher income for those with 2 or more incomes
gen  non_agricultural_1 = non_agricultural      	if  non_agricultural==x & duplicates==1
gen  non_agricultural_2 = non_agricultural			if  non_agricultural!=x 

* Solve duplicates
replace employment_income_1 = employment_income1		if  employment_income1==x & duplicates==2			/* employment income principal si iguala 			 */
replace employment_income_1 = employment_income1		if  employment_income1==x & duplicates==3			/* employment income principal si iguala 			 */
replace agricultural_2 = agricultural 				if  agricultural==x & duplicates==2				/* agricultural income no principal si iguala 		 */
replace agricultural_2 = agricultural 				if  agricultural==x & duplicates==3				/* agricultural income no principal si iguala 		 */
replace non_agricultural_1 = non_agricultural   	if  non_agricultural==x & duplicates==2 & x2==1	/* non agricultural principal si iguala agricultural */
replace non_agricultural_2 = non_agricultural   	if  non_agricultural==x & duplicates==2 & x1==1 	/* non agricultural no principal si iguala employment*/
replace non_agricultural_2 = non_agricultural   	if  non_agricultural==x & duplicates==3 			/* non agricultural no principal si iguala employment*/


* Income Components (final)
gen     employ_income1 = employment_income1			if  aux_jobs==1 & employment_income1!=. & employment_income1!=0
replace employ_income1 = employment_income_1		if  employment_income_1!=.
gen     employ_income2 = employment_income_2		if  employment_income_2!=0

gen     agricu_income1 = agricultural          	if  aux_jobs==1 & agricultural!=. & agricultural!=0
replace agricu_income1 = agricultural_1 			if  agricultural_1!=.
gen     agricu_income2 = agricultural_2 

gen     nonagr_income1 = non_agricultural       	if  aux_jobs==1 & non_agricultural!=. & non_agricultural!=0
replace nonagr_income1 = non_agricultural_1 		if  non_agricultural_1!=.
gen     nonagr_income2 = non_agricultural_2

drop agricultural x-non_agricultural_2

replace employment_income1 = employ_income1 
replace employment_income2 = employ_income2 
rename agricu_income1 agricultural_1
rename agricu_income2 agricultural_2
rename nonagr_income1 non_agricultural_1
rename nonagr_income2 non_agricultural_2
****************************************************************************************************************
****************************************************************************************************************

order hhid pid
sort  hhid pid
*</_Datalibweb request_>


*<_Save data file_>
compress
save "${output}/`yearfolder'_v`vm'_M.dta", replace
*</_Save data file_>

 