/*------------------------------------------------------------------------------
  GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   		LKA_2009_HIES_v01_M.do				   </_Program name_>
<_Application_>    		STATA 17.0							     <_Application_>
<_Author(s)_>      		lmorenoherrera@worldbank.org	          </_Author(s)_>
<_Author(s)_>      		tornarolli@gmail.com	          		  </_Author(s)_>
<_Date created_>   		        	                           </_Date created_>
<_Date modified>   		08-12-2023	                          </_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        		LKA											</_Country_>
<_Survey Title_>   		HIES								   </_Survey Title_>
<_Survey Year_>    		2009									</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:					08-12-2023
File:					LKA_2009_HIES_v01_M.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>
clear all
set more off

local code         	"LKA"
local year         	"2009"
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
use "${input}\hies_2009_sec5_1_empincome.dta", clear
* There are some cases where a secondary job is reported, but no primary job is reported
* In those cases, we change the secondary to primary jobs
duplicates tag hhid pid, gen(flag)
replace main_sec = 1		if  main_sec==2 & flag==0
replace main_sec = 2		if  main_sec==. & flag==1
replace main_sec = 1		if  main_sec==. & wage_1m!=.
drop if  main_sec==. & wage_1m==.

* Change format from LONG to WIDE
rename wage_1m wages_salaries_
rename ot_1m allowences_
rename bonus_12m bonus_
keep hhid pid main_sec wages allowences bonus
reshape wide wages allowences bonus, i(hhid pid) j(main_sec)
replace bonus_1 = bonus_1/12
replace bonus_2 = bonus_2/12
egen employment_income1 = rsum(wages_salaries_1 allowences_1 bonus_1), m
egen employment_income2 = rsum(wages_salaries_2 allowences_2 bonus_2), m
order hhid pid
sort  hhid pid
tempfile employment_income
save `employment_income'

 
*** INCOME FROM AGRICULTURAL ACTIVITIES 
use "${input}\hies_2009_sec5_2_scrop_income.dta", clear
keep hhid pid crop output_12m input_12m 
drop if crop==. & output_12m==.
replace crop = 9		if  crop==.
rename output_12m output_12m_  		/* there are 71 missings in value of output    */
rename input_12m  input_12m_  			/* there are 83 missings in cost of input      */
reshape wide output_12m_ input_12m_, i(hhid pid) j(crop)

egen output = rsum(output_12m_1 output_12m_2 output_12m_3 output_12m_4 output_12m_5 output_12m_6 output_12m_7 output_12m_9), missing
egen inputs = rsum(input_12m_1 input_12m_2 input_12m_3 input_12m_4 input_12m_5 input_12m_6 input_12m_7 input_12m_9), missing
replace inputs = inputs*(-1)
egen    agricultural_income = rsum(output inputs), missing
replace agricultural_income = agricultural_income/12
drop output inputs
order hhid pid
sort  hhid pid
tempfile agricultural_income
save `agricultural_income'


*** OTHER AGRICULTURAL INCOME 
use "${input}\HIES_2009_10_sec_5_3_Other_Agri_income.dta", clear
tostring district psu sample_n serial_no ser_no_sec_5_3, replace
gen zero = "0"
egen temp_psu 		= concat(zero zero psu)
replace psu			= substr(temp_psu,-3,.)
egen temp_snumber	= concat(zero sample_n)
replace sample_n		= substr(temp_snumber,-2,.)
egen hhid = concat(district psu sample_n serial_no)
destring district psu sample_n serial_no, replace
egen temp_ser_no_sec_5_3 = concat(zero ser_no_sec_5_3)
replace ser_no_sec_5_3 = substr(temp_ser_no_sec_5_3,-2,.)
egen pid = concat(hhid ser_no_sec_5_3)
drop temp* zero
drop if seasonal_crop==. & output==.
replace seasonal_crop = 19 	if  seasonal_crop==.
duplicates report hhid pid seasonal_crop
duplicates drop hhid pid seasonal_crop, force

keep hhid pid seasonal output input
rename output_5_3 output_5_3_
rename input_5_3 input_5_3_
reshape wide output input, i(hhid pid) j(seasonal_crop)

egen output = rsum(output_5_3_1 output_5_3_2 output_5_3_3 output_5_3_4 output_5_3_5 output_5_3_6 output_5_3_7 output_5_3_8 output_5_3_9 output_5_3_10 output_5_3_19), missing
egen inputs = rsum(input_5_3_1 input_5_3_2 input_5_3_3 input_5_3_4 input_5_3_5 input_5_3_6 input_5_3_7 input_5_3_8 input_5_3_9 input_5_3_10 input_5_3_19), missing
replace inputs = inputs*(-1)
egen agricultural_other = rsum(output inputs), missing
drop output inputs
sort hhid pid
tempfile agricultural_other
save `agricultural_other'


*** NON-AGRICULTURAL INCOME 
use "${input}\hies_2009_sec5_4_nonagri_income.dta", clear
drop if  non_agri==. & output_1m==.
replace non_agri = 7			if  non_agri==.
replace  input_1m = 23825	if  input_1m==20000  & pid=="1218409102"
replace output_1m = 38960	if  output_1m==30000 & pid=="1218409102"
drop	if  input==3825 & pid=="1218409102" 
replace  input_1m = 54800	if  input_1m==54000  & pid=="6103407101"
replace output_1m = 65000	if  output_1m==62000 & pid=="6103407101"
drop	if  input==800  & pid=="6103407101" 

keep hhid pid non_agri output_1m input_1m 
rename output_1m output_1m_
rename input_1m input_1m_
reshape wide output input, i(hhid pid) j(non_agri)

egen output = rsum(output_1m_1 output_1m_2 output_1m_3 output_1m_4 output_1m_5 output_1m_6 output_1m_7), missing
egen inputs = rsum(input_1m_1 input_1m_2 input_1m_3 input_1m_4 input_1m_5 input_1m_6 input_1m_7), missing
replace inputs = inputs*(-1)
egen non_agricultural = rsum(output inputs), missing
replace non_agricultural = .	if non_agricultural>9000000
drop output inputs
order hhid pid
sort  hhid pid
tempfile noagricultural_income
save `noagricultural_income'

  
*** OTHER INCOME 
use "${input}\hies_2009_sec5_5_transfer_income.dta", clear
keep hhid pid pension-remit_loc_12m
replace remit_abr_12m = remit_abr_12m/12
replace remit_loc_12m = remit_loc_12m/12
order hhid pid
sort  hhid pid
tempfile other_income
save `other_income'
 
 
*** WINDFALL INCOME 
use "${input}\hies_2009_sec5_5_adhoc_income.dta", clear
keep hhid pid loan-lottery
order hhid pid
sort  hhid pid
tempfile windfall_income
save `windfall_income'


***************************************************************************************************
**** DURABLE GOODS
***************************************************************************************************
use "${input}\hies_2009_sec6a_goods.dta", clear
keep hhid radio tv vcd sewmach washmach fridge cooker fan landphone mobile comput bicyc m_bicyc thrwheel carvan buslory tract2w tract4w spray thresh watpum boat fishnet
sort hhid 
tempfile durable_goods
save  `durable_goods'


***************************************************************************************************
**** DEMOGRAPHICS
***************************************************************************************************
use "${input}\hies_2009_sec1_demo.dta", clear
drop  if pno>18
order hhid pid
sort  hhid pid
tempfile demographics
save  `demographics'


***************************************************************************************************
**** SCHOOL EDUCATION
***************************************************************************************************
use "${input}\hies_2009_sec2_school.dta", clear
order hhid pid
sort  hhid pid
tempfile school_education
save  `school_education'


***************************************************************************************************
**** HEALTH
***************************************************************************************************
use "${input}\hies_2009_sec3_health.dta", clear
duplicates report hhid pid
duplicates drop hhid pid, force
order hhid pid
sort  hhid pid
tempfile health
save   `health'


***************************************************************************************************
**** NON-FOOD EXPENDITURES
***************************************************************************************************
use "${input}\hies_2009_sec4_2_nonfood.dta", clear
keep if itc==2001
sort hhid
tempfile nonfood
save   `nonfood'


***************************************************************************************************
**** HOUSING
***************************************************************************************************
use "${input}\hies_2009_sec8_housing.dta", clear
sort hhid
tempfile housing
save   `housing'


***************************************************************************************************
**** LAND OWNERSHIP
***************************************************************************************************
use "${input}\hies_2009_sec9_land_livestock.dta", clear
keep hhid aglandown cowsbuff goatsheeps pigs chicken otherani
sort hhid
tempfile land_owner_livestock
save  `land_owner_livestock'


***************************************************************************************************
**** SPATIAL DEFLATORS
***************************************************************************************************
use "${input}\wfile2009.dta", clear
keep district cpi_dcs
collapse (mean) cpi_dcs, by(district)
sort district
tempfile deflator
save   `deflator'


***************************************************************************************************
**** HOUSEHOLD EXPENDITURE AND INCOME
***************************************************************************************************
use "${input}\wfile2009.dta", clear
sort hhid
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

 