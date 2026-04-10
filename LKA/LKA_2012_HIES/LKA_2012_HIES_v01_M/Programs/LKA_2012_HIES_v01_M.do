/*------------------------------------------------------------------------------
  GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   		LKA_2012_HIES_v02_M.do				   </_Program name_>
<_Application_>    		STATA 17.0							     <_Application_>
<_Author(s)_>      		lmorenoherrera@worldbank.org	          </_Author(s)_>
<_Author(s)_>      		tornarolli@gmail.com	          		  </_Author(s)_>
<_Date created_>   					                           </_Date created_>
<_Date modified>   		08-12-2023	                          </_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        		LKA											</_Country_>
<_Survey Title_>   		HIES								   </_Survey Title_>
<_Survey Year_>    		2012									</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:					08-12-2023
File:					LKA_2012_HIES_v02_M.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>
clear all
set more off

local code         	"LKA"
local year         	"2012"
local survey       	"HIES"
local vm           	"01"
local yearfolder   	"`code'_`year'_`survey'"
global input       	"${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata"
global output      	"${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata"
*</_Program setup_>

	
*<_Datalibweb request_>

***************************************************************************************************
**** INCOME
***************************************************************************************************

*** INCOME FROM PAID EMPLOYMENT
use "${input}\sec_5_1_emp_income.dta", clear
* There are some cases where a secondary job is reported, but no primary job is reported
* In those cases, we change the secondary to primary jobs
gen person_serial_no = serial_no_sec_1
duplicates tag district sector month psu snumber hhno person_serial_no, gen(flag)
replace pri_sec = 1		if  pri_sec==2 & flag==0
drop if pri_sec==0
drop if pri_sec==. & wages_salaries==.
drop if pri_sec==. & wages_salaries==0
replace pri_sec = 1		if  pri_sec==.

* Change format from LONG to WIDE
keep district sector month psu snumber hhno person_serial_no pri_sec wages allowences bonus
rename wages_salaries wages_salaries_
rename allowences allowences_
rename bonus bonus_
reshape wide wages allowences bonus, i(district sector month psu snumber hhno person_serial_no) j(pri_sec)
replace bonus_1 = bonus_1/12
replace bonus_2 = bonus_2/12
egen employment_income1 = rsum(wages_salaries_1 allowences_1 bonus_1), m
egen employment_income2 = rsum(wages_salaries_2 allowences_2 bonus_2), m
order district sector month psu snumber hhno person_serial_no
sort  district sector month psu snumber hhno person_serial_no
tempfile employment_income
save `employment_income'


*** INCOME FROM AGRICULTURAL ACTIVITIES 
use "${input}\sec_5_2_agri_income.dta", clear
gen person_serial_no = col_2x
drop if col_4x==. & col_8x==.
replace col_4x = 9	if col_4x==.
drop if col_8x1==.

keep district sector month psu snumber hhno person_serial_no col_4x col_8x col_8x1 col_9x col_13x
rename col_8x  col_8x_  			/* there are 198 missings in quantity of output */
rename col_8x1 col_8x1_  			/* there are 161 missings in value of output    */
rename col_9x  col_9x_  			/* there are 320 missings in cost of input      */
rename col_13x col_13x_			/* fertilizers and subsidies				   */ 
reshape wide col_8x_ col_8x1_ col_9x_ col_13x_, i(district sector month psu snumber hhno person_serial_no) j(col_4x)

egen output = rsum(col_8x1_1 col_8x1_2 col_8x1_3 col_8x1_4 col_8x1_5 col_8x1_6 col_8x1_7 col_8x1_9), missing
egen fertil = rsum(col_13x_1 col_13x_2 col_13x_3 col_13x_4 col_13x_5 col_13x_6 col_13x_7 col_13x_9), missing
egen inputs = rsum(col_9x_1 col_9x_2 col_9x_3 col_9x_4 col_9x_5 col_9x_6 col_9x_7 col_9x_9), missing
replace inputs = inputs*(-1)
egen    agricultural_income = rsum(output fertil inputs), missing
replace agricultural_income = agricultural_income/12
drop output fertil inputs
order district sector month psu snumber hhno person_serial_no
sort  district sector month psu snumber hhno person_serial_no
tempfile agricultural_income
save `agricultural_income'

 
*** OTHER AGRICULTURAL INCOME 
use "${input}\sec_5_3_other_agri_income.dta", clear
gen person_serial_no = ser_no_sec_5_3
drop if seasonal_crop==. & output==.
drop if seasonal_crop==. & output==0
replace seasonal_crop = 99	if  seasonal_crop==.

keep district sector month psu snumber hhno person_serial_no seasonal output input fertilizes
rename output_5_3 output_5_3_
rename input_5_3 input_5_3_
rename fertilizes fertilizes_
reshape wide output input fertilizes, i(district sector month psu snumber hhno person_serial_no) j(seasonal_crop)

egen output = rsum(output_5_3_1 output_5_3_2 output_5_3_3 output_5_3_4 output_5_3_5 output_5_3_6 output_5_3_7 output_5_3_8 output_5_3_9 output_5_3_10 output_5_3_16 output_5_3_19 output_5_3_24 output_5_3_99), missing
egen fertil = rsum(fertilizes_1 fertilizes_2 fertilizes_3 fertilizes_4 fertilizes_5 fertilizes_6 fertilizes_7 fertilizes_8 fertilizes_9 fertilizes_10 fertilizes_16 fertilizes_19 fertilizes_24 fertilizes_99), missing
egen inputs = rsum(input_5_3_1 input_5_3_2 input_5_3_3 input_5_3_4 input_5_3_5 input_5_3_6 input_5_3_7 input_5_3_8 input_5_3_9 input_5_3_10 input_5_3_16 input_5_3_19 input_5_3_24 input_5_3_99), missing
replace inputs = inputs*(-1)
egen agricultural_other = rsum(output fertil inputs), missing
drop output fertil inputs
order district sector month psu snumber hhno person_serial_no
sort  district sector month psu snumber hhno person_serial_no
tempfile agricultural_other
save `agricultural_other'


*** NON-AGRICULTURAL INCOME 
use "${input}\sec_5_4_non_agri_income.dta", clear
gen person_serial_no = serial_5_4
drop if non_agri==. & output==.
replace non_agri = 9		if  non_agri==. | non_agri==0
replace output = 9500	if  district==72 & sector==2 & month==9 & psu==14 & snumber==7 & hhno==1 & non_agri==9 & output==5000
drop                    if  district==72 & sector==2 & month==9 & psu==14 & snumber==7 & hhno==1 & non_agri==9 & output==4500

keep district sector month psu snumber hhno person_serial_no non_agri output_5_4 input_5_4 subsidies
rename output_5_4 output_5_4_
rename input_5_4 input_5_4_
rename subsidies subsidies_
reshape wide output input subsidies, i(district sector month psu snumber hhno person_serial_no) j(non_agri)

egen output = rsum(output_5_4_1 output_5_4_2 output_5_4_3 output_5_4_4 output_5_4_5 output_5_4_6 output_5_4_7 output_5_4_9), missing
egen subsid = rsum(subsidies_1 subsidies_2 subsidies_3 subsidies_4 subsidies_5 subsidies_6 subsidies_7 subsidies_9), missing
egen inputs = rsum(input_5_4_1 input_5_4_2 input_5_4_3 input_5_4_4 input_5_4_5 input_5_4_6 input_5_4_7 input_5_4_9), missing
replace inputs = inputs*(-1)
egen non_agricultural = rsum(output subsid inputs), missing
drop output subsid inputs
order district sector month psu snumber hhno person_serial_no
sort  district sector month psu snumber hhno person_serial_no
tempfile noagricultural_income
save `noagricultural_income'

  
*** OTHER INCOME 
use "${input}\sec_5_5_1_other_income.dta", clear
gen person_serial_no = serial_5_5_1
drop if person>16
replace samurdhi = 1700	if  district==41 & sector==2 & month==10 & psu==28 & snumber==8 & hhno==1 & person_serial_no==1 & samurdhi==1500
drop 					if  district==41 & sector==2 & month==10 & psu==28 & snumber==8 & hhno==1 & person_serial_no==1 & samurdhi==200

keep district sector month psu snumber hhno person_serial_no pension-income_local
replace other_income = other_income/12
replace income_forign = income_forign/12
replace income_local = income_local/12
order district sector month psu snumber hhno person_serial_no
sort  district sector month psu snumber hhno person_serial_no
tempfile other_income
save `other_income'

 
*** WINDFALL INCOME 
use "${input}\sec_5_5_2_windfall_income.dta", clear
gen person_serial_no = person_5_5_2
keep district sector month psu snumber hhno person_serial_no loans-diaster
order district sector month psu snumber hhno person_serial_no
sort  district sector month psu snumber hhno person_serial_no
tempfile windfall_income
save `windfall_income'


***************************************************************************************************
**** DURABLE GOODS
***************************************************************************************************
use "${input}\sec_6_a_durable_goods.dta", clear
keep district sector month psu snumber hhno radio tv vcd sewing_mechine washing_mechine fridge cookert electric_fans telephone telephone_mobile computers camera bicycle motor_bicycle three_wheeler motor_car_van bus_lorry tractor_2_wheel tractor_4_wheel pesticider threshers waterpumps mechine boats fishing_nets
sort district sector month psu snumber hhno 
tempfile durable_goods
save  `durable_goods'


***************************************************************************************************
**** DEMOGRAPHICS
***************************************************************************************************
use "${input}\sec_1_demographic.dta", clear
drop if result!=1
drop if person>16
sort district sector month psu snumber hhno person_serial_no
tempfile demographics
save  `demographics'


***************************************************************************************************
**** SCHOOL EDUCATION
***************************************************************************************************
use "${input}\sec_2_school_education.dta", clear
gen person_serial_no = r2_person_serial
order district sector month psu snumber hhno person_serial_no
sort  district sector month psu snumber hhno person_serial_no
tempfile school_education
save  `school_education'


***************************************************************************************************
**** HEALTH
***************************************************************************************************
use "${input}\sec_3_health.dta", clear
gen person_serial_no = r3_person_serial2
order district sector month psu snumber hhno person_serial_no
sort  district sector month psu snumber hhno person_serial_no
tempfile health
save   `health'


***************************************************************************************************
**** NON-FOOD EXPENDITURES
***************************************************************************************************
use "${input}\sec_4_2_nonfood.dta", clear
keep if nf_code==2001
sort district sector month psu snumber hhno
tempfile nonfood
save   `nonfood'


***************************************************************************************************
**** HOUSING
***************************************************************************************************
use "${input}\sec_8_housing.dta", clear
sort district sector month psu snumber hhno
tempfile housing
save   `housing'

***************************************************************************************************
**** LAND OWNERSHIP
***************************************************************************************************
use "${input}\sec_9_land_animal.dta", clear
drop if result!=1

keep district sector month psu snumber hhno is_agriland_owner cows_buffalows goats_sheeps pigs chickens other_animals
sort district sector month psu snumber hhno
tempfile land_owner_livestock
save  `land_owner_livestock'


***************************************************************************************************
**** FINAL WEIGHTS
***************************************************************************************************
use "${input}\weights201213HIES.dta", clear
sort district psu
tempfile weights
save   `weights'


***************************************************************************************************
**** SPATIAL DEFLATORS
***************************************************************************************************
use "${input}\wfile201213.dta", clear
keep district cpi_dcs
collapse (mean) cpi_dcs, by(district)
tempfile deflator
save   `deflator'


***************************************************************************************************
**** HOUSEHOLD EXPENDITURE AND INCOME
***************************************************************************************************
use "${input}\consumption_hies_2012_13.dta", clear
duplicates report hhid
duplicates drop
sort hhid
tempfile hh_exp_inc
save  `hh_exp_inc'

	
***************************************************************************************************
**** MERGE DATASETS
***************************************************************************************************
* Individual-level datasets
use `demographics', clear

foreach i in employment_income agricultural_income agricultural_other noagricultural_income other_income windfall_income school_education health {
	merge 1:1 district sector month psu snumber hhno person_serial_no using ``i'', keep(1 3) nogen
	}
	
* Household-level datasets
foreach j in durable_goods nonfood housing land_owner_livestock {
	merge m:1 district sector month psu snumber hhno using ``j'', keep(1 3) nogen
	}

tostring district sector month psu snumber hhno, replace
gen zero = "0"
egen temp_month 	= concat(zero month)
replace month	= substr(temp_month,-2,.)
egen temp_psu 	= concat(zero zero psu)
replace psu		= substr(temp_psu,-3,.)
egen temp_snumber	= concat(zero snumber)
replace snumber	= substr(temp_snumber,-2,.)
drop temp* zero
egen hhid = concat(district sector month psu snumber hhno)
destring district sector month psu snumber hhno, replace

foreach j in hh_exp_inc {
	merge m:1 hhid using ``j'', keep(1 3) nogen
	}

	merge m:1 district psu using `weights', keep(3) nogen	
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
	
order district sector month psu snumber hhno person_serial_no
sort  district sector month psu snumber hhno person_serial_no
*</_Datalibweb request_>


*<_Save data file_>
compress
save "${output}/`yearfolder'_v`vm'_M.dta", replace
*</_Save data file_>

 