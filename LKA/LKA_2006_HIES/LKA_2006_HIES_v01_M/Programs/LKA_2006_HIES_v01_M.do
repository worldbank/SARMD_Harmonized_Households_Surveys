/*------------------------------------------------------------------------------
  GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   		LKA_2006_HIES_v01_M.do				   </_Program name_>
<_Application_>    		STATA 17.0							     <_Application_>
<_Author(s)_>      		lmorenoherrera@worldbank.org	          </_Author(s)_>
<_Author(s)_>      		tornarolli@gmail.com	          		  </_Author(s)_>
<_Date created_>   		        	                           </_Date created_>
<_Date modified>   		08-12-2023	                          </_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        		LKA											</_Country_>
<_Survey Title_>   		HIES								   </_Survey Title_>
<_Survey Year_>    		2006									</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:					08-12-2023
File:					LKA_2006_HIES_v01_M.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>
clear all
set more off

local code         	"LKA"
local year         	"2006"
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
use "${input}\sec_5_1_emp_incomeV2.dta", clear
* There are some cases where a secondary job is reported, but no primary job is reported
* In those cases, we change the secondary to primary jobs
gen 	sdist = string(district)
gen 	spsu = "00" + string(psu) 		if  psu<10
replace spsu = "0" + string(psu) 			if  psu>=10 & psu<100
replace spsu = string(psu) 				if  psu>=100
gen 	ssamp = string(sample_n)
replace ssamp = "0" + string(sample_n) 	if  sample_n<10
gen 	shhno = string(serial_no)
egen hhid = concat(sdist spsu ssamp shhno)
gen   pid = serial_no_sec_1
drop sdist spsu ssamp shhno
duplicates tag hhid pid, gen(flag)
replace pri_sec = 2		if  pri_sec==. & flag==1

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
order hhid pid
sort  hhid pid
tempfile employment_income
save `employment_income'
  
 
*** INCOME FROM AGRICULTURAL ACTIVITIES 
use "${input}\sec_5_2_agri_incomeV2.dta", clear
gen 	sdist = string(district)
gen 	spsu = "00" + string(psu) 		if  psu<10
replace spsu = "0" + string(psu) 			if  psu>=10 & psu<100
replace spsu = string(psu) 				if  psu>=100
gen 	ssamp = string(sample_n)
replace ssamp = "0" + string(sample_n) 	if  sample_n<10
gen 	shhno = string(serial_no)
egen hhid = concat(sdist spsu ssamp shhno)
gen   pid = ser_no_sec_5_2
drop sdist spsu ssamp shhno

keep hhid pid seas_crops_code output_5_2 input_5_2 
rename output_5_2 output_5_2_  		/* there are 71 missings in value of output    */
rename input_5_2  input_5_2_  			/* there are 83 missings in cost of input      */
reshape wide output_5_2_ input_5_2_, i(hhid pid) j(seas_crops_code)

egen output = rsum(output_5_2_1 output_5_2_2 output_5_2_3 output_5_2_4 output_5_2_5 output_5_2_6 output_5_2_7 output_5_2_9), missing
egen inputs = rsum(input_5_2_1 input_5_2_2 input_5_2_3 input_5_2_4 input_5_2_5 input_5_2_6 input_5_2_7 input_5_2_9), missing
replace inputs = inputs*(-1)
egen    agricultural_income = rsum(output inputs), missing
replace agricultural_income = agricultural_income/12
drop output inputs
order hhid pid
sort  hhid pid
tempfile agricultural_income
save `agricultural_income'
  
 
*** OTHER AGRICULTURAL INCOME 
use "${input}\sec_5_3_other_agri_income.dta", clear
gen 	sdist = string(district)
gen 	spsu = "00" + string(psu) 		if  psu<10
replace spsu = "0" + string(psu) 			if  psu>=10 & psu<100
replace spsu = string(psu) 				if  psu>=100
gen 	ssamp = string(sample_n)
replace ssamp = "0" + string(sample_n) 	if  sample_n<10
gen 	shhno = string(serial_no)
egen hhid = concat(sdist spsu ssamp shhno)
gen   pid = ser_no_sec_5_3
drop sdist spsu ssamp shhno

keep hhid pid seasonal output input
rename output_5_3 output_5_3_
rename input_5_3 input_5_3_
reshape wide output input, i(hhid pid) j(seasonal_crop)

egen output = rsum(output_5_3_1 output_5_3_2 output_5_3_3 output_5_3_4 output_5_3_5 output_5_3_6 output_5_3_7 output_5_3_8 output_5_3_9 output_5_3_10 output_5_3_19), missing
egen inputs = rsum(input_5_3_1 input_5_3_2 input_5_3_3 input_5_3_4 input_5_3_5 input_5_3_6 input_5_3_7 input_5_3_8 input_5_3_9 input_5_3_10 input_5_3_19), missing
replace inputs = inputs*(-1)
egen agricultural_other = rsum(output inputs), missing
drop output inputs
order hhid pid
sort  hhid pid
tempfile agricultural_other
save `agricultural_other'


*** NON-AGRICULTURAL INCOME 
use "${input}\sec_5_4_non_agri_income.dta", clear
gen 	sdist = string(district)
gen 	spsu = "00" + string(psu) 		if  psu<10
replace spsu = "0" + string(psu) 			if  psu>=10 & psu<100
replace spsu = string(psu) 				if  psu>=100
gen 	ssamp = string(sample_n)
replace ssamp = "0" + string(sample_n) 	if  sample_n<10
gen 	shhno = string(serial_no)
egen hhid = concat(sdist spsu ssamp shhno)
gen   pid = serial_5_4
drop sdist spsu ssamp shhno

keep hhid pid non_agri output_5_4 input_5_4 
rename output_5_4 output_5_4_
rename input_5_4 input_5_4_
reshape wide output input, i(hhid pid) j(non_agri)

egen output = rsum(output_5_4_1 output_5_4_2 output_5_4_3 output_5_4_4 output_5_4_5 output_5_4_6 output_5_4_7), missing
egen inputs = rsum(input_5_4_1 input_5_4_2 input_5_4_3 input_5_4_4 input_5_4_5 input_5_4_6 input_5_4_7), missing
replace inputs = inputs*(-1)
egen non_agricultural = rsum(output inputs), missing
drop output inputs
order hhid pid
sort  hhid pid
tempfile noagricultural_income
save `noagricultural_income'
 
  
*** OTHER INCOME 
use "${input}\sec_5_5_1_other_income.dta", clear
gen 	sdist = string(district)
gen 	spsu = "00" + string(psu) 		if  psu<10
replace spsu = "0" + string(psu) 			if  psu>=10 & psu<100
replace spsu = string(psu) 				if  psu>=100
gen 	ssamp = string(sample_n)
replace ssamp = "0" + string(sample_n) 	if  sample_n<10
gen 	shhno = string(serial_no)
egen hhid = concat(sdist spsu ssamp shhno)
gen   pid = serial_5_5_1
drop sdist spsu ssamp shhno


keep hhid pid pension-local
replace abroad = abroad/12
replace local = local/12
order hhid pid
sort  hhid pid
tempfile other_income
save `other_income'
 
 
*** WINDFALL INCOME 
use "${input}\sec_5_5_2_windfall_income.dta", clear
gen 	sdist = string(district)
gen 	spsu = "00" + string(psu) 		if  psu<10
replace spsu = "0" + string(psu) 			if  psu>=10 & psu<100
replace spsu = string(psu) 				if  psu>=100
gen 	ssamp = string(sample_n)
replace ssamp = "0" + string(sample_n) 	if  sample_n<10
gen 	shhno = string(serial_no)
egen hhid = concat(sdist spsu ssamp shhno)
gen   pid = person_5_5_2
drop sdist spsu ssamp shhno

keep hhid pid loans-other_windfall
sort hhid pid
tempfile windfall_income
save `windfall_income'


***************************************************************************************************
**** DURABLE GOODS
***************************************************************************************************
use "${input}\sec_6a_durable_goodsV2.dta", clear
gen 	sdist = string(district)
gen 	spsu = "00" + string(psu) 		if  psu<10
replace spsu = "0" + string(psu) 			if  psu>=10 & psu<100
replace spsu = string(psu) 				if  psu>=100
gen 	ssamp = string(sample_n)
replace ssamp = "0" + string(sample_n) 	if  sample_n<10
gen 	shhno = string(serial_no)
egen hhid = concat(sdist spsu ssamp shhno)
drop sdist spsu ssamp shhno

keep hhid radio tv vcd sewing_mechine washing_mechine fridge cookert electric_fans telephone telephone_mobile computers bicycle motor_bicycle three_wheeler motor_car_van bus_lorry tractor_2_wheel tractor_4_wheel pesticider paddy_blower water_pumps boats fishing_nets
order hhid
sort  hhid 
tempfile durable_goods
save  `durable_goods'


***************************************************************************************************
**** DEMOGRAPHICS
***************************************************************************************************
use "${input}\sec_1_demographic.dta", clear
gen 	sdist = string(district)
gen 	spsu = "00" + string(psu) 		if  psu<10
replace spsu = "0" + string(psu) 			if  psu>=10 & psu<100
replace spsu = string(psu) 				if  psu>=100
gen 	ssamp = string(sample_n)
replace ssamp = "0" + string(sample_n) 	if  sample_n<10
gen 	shhno = string(serial_no)
egen hhid = concat(sdist spsu ssamp shhno)
gen   pid = person_serial_no
drop sdist spsu ssamp shhno
duplicates report hhid pid
duplicates drop hhid pid, force
drop if pid>16
order hhid pid
sort  hhid pid
tempfile demographics
save  `demographics'


***************************************************************************************************
**** SCHOOL EDUCATION
***************************************************************************************************
use "${input}\sec_2_school_education.dta", clear
gen 	sdist = string(district)
gen 	spsu = "00" + string(psu) 		if  psu<10
replace spsu = "0" + string(psu) 			if  psu>=10 & psu<100
replace spsu = string(psu) 				if  psu>=100
gen 	ssamp = string(sample_n)
replace ssamp = "0" + string(sample_n) 	if  sample_n<10
gen 	shhno = string(serial_no)
egen hhid = concat(sdist spsu ssamp shhno)
gen   pid = r2_person_serial
drop sdist spsu ssamp shhno
order hhid pid
sort  hhid pid
tempfile school_education
save  `school_education'


***************************************************************************************************
**** HEALTH
***************************************************************************************************
use "${input}\sec_3_health.dta", clear
gen 	sdist = string(district)
gen 	spsu = "00" + string(psu) 		if  psu<10
replace spsu = "0" + string(psu) 			if  psu>=10 & psu<100
replace spsu = string(psu) 				if  psu>=100
gen 	ssamp = string(sample_n)
replace ssamp = "0" + string(sample_n) 	if  sample_n<10
gen 	shhno = string(serial_no)
egen hhid = concat(sdist spsu ssamp shhno)
gen   pid = r3_person_serial
drop sdist spsu ssamp shhno
order hhid pid
sort  hhid pid
tempfile health
save   `health'


***************************************************************************************************
**** NON-FOOD EXPENDITURES
***************************************************************************************************
use "${input}\sec_4_2_nonfood.dta", clear
gen 	sdist = string(district)
gen 	spsu = "00" + string(psu) 		if  psu<10
replace spsu = "0" + string(psu) 			if  psu>=10 & psu<100
replace spsu = string(psu) 				if  psu>=100
gen 	ssamp = string(sample_n)
replace ssamp = "0" + string(sample_n) 	if  sample_n<10
gen 	shhno = string(serial_no)
egen hhid = concat(sdist spsu ssamp shhno)
keep if nf_code==2001
order hhid
sort  hhid
tempfile nonfood
save   `nonfood'


***************************************************************************************************
**** HOUSING
***************************************************************************************************
use "${input}\sec_8_housing.dta", clear
gen 	sdist = string(district)
gen 	spsu = "00" + string(psu) 		if  psu<10
replace spsu = "0" + string(psu) 			if  psu>=10 & psu<100
replace spsu = string(psu) 				if  psu>=100
gen 	ssamp = string(sample_n)
replace ssamp = "0" + string(sample_n) 	if  sample_n<10
gen 	shhno = string(serial_no)
egen hhid = concat(sdist spsu ssamp shhno)
order hhid 
sort  hhid
tempfile housing
save   `housing'


***************************************************************************************************
**** LAND OWNERSHIP
***************************************************************************************************
use "${input}\sec_9_land_animal.dta", clear
gen 	sdist = string(district)
gen 	spsu = "00" + string(psu) 		if  psu<10
replace spsu = "0" + string(psu) 			if  psu>=10 & psu<100
replace spsu = string(psu) 				if  psu>=100
gen 	ssamp = string(sample_n)
replace ssamp = "0" + string(sample_n) 	if  sample_n<10
gen 	shhno = string(serial_no)
egen hhid = concat(sdist spsu ssamp shhno)

keep hhid is_agriland_owner cows_buffalows goats_sheeps pigs chickens other_animals
order hhid
sort  hhid
tempfile land_owner_livestock
save  `land_owner_livestock'


***************************************************************************************************
**** FINAL WEIGHTS
***************************************************************************************************
use "${input}\weight.dta", clear
keep dist psu hweight popweight
collapse (mean) hweight popweight, by(dist psu)
order dist psu
sort  dist psu
rename dist district
tempfile weights
save   `weights'


***************************************************************************************************
**** SPATIAL DEFLATORS
***************************************************************************************************
use "${input}\wfile200607.dta", clear
collapse (mean) cpi_dcs, by(district)
order district
sort  district
tempfile deflator
save   `deflator'


***************************************************************************************************
**** HOUSEHOLD EXPENDITURE AND INCOME
***************************************************************************************************
use "${input}\wfile200607.dta", clear
order hhid
sort  hhid
tempfile hh_exp_inc
save  `hh_exp_inc'

	
***************************************************************************************************
**** MERGE DATASETS
***************************************************************************************************
* Individual-level datasets
use `demographics', clear
foreach i in employment_income agricultural_income agricultural_other noagricultural_income other_income windfall_income school_education health {
	merge 1:1 hhid pid using ``i'', keep(1 3) nogen
	}
	
* Household-level datasets
foreach j in durable_goods nonfood housing land_owner_livestock hh_exp_inc {
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
	
drop if weight==.
order hhid pid
sort  hhid pid
*</_Datalibweb request_>


*<_Save data file_>
compress
save "${output}/`yearfolder'_v`vm'_M.dta", replace
*</_Save data file_>

 