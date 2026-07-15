/*------------------------------------------------------------------------------
  GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   		BGD_2010_HIES_v01_M.do				   </_Program name_>
<_Application_>    		STATA 17.0							     <_Application_>
<_Author(s)_>      		acastillocastill@worldbank.org	          </_Author(s)_>
<_Author(s)_>      		tornarolli@gmail.com	          		  </_Author(s)_>
<_Date created_>   		05-25-2021	                           </_Date created_>
<_Date modified>   		September 2024	                      </_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        		BGD											</_Country_>
<_Survey Title_>   		HIES								   </_Survey Title_>
<_Survey Year_>    		2010									</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:					23-09-2024
File:					BGD_2010_HIES_v01_M.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>
clear all
set more off

global cpiver       	"09"
local code         		"BGD"
local year         		"2010"
local survey       		"HIES"
local vm           		"01"
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
use "${input}\rt002.dta", clear
destring psu hhold, replace
gen     idp = idcode
order   psu hhold idp
duplicates report
duplicates drop
keep psu hhold idp s01a_q02-s01a_q07
sort psu hhold idp
save `roster'

* INCOMES FROM SECTION 4: DAY LABOURERS and EMPLOYEES    
* Day labourers (s04a_q07==1 | s04a_q08==1)                                                      
* Employees     (s04a_q07==4 | s04a_q08==4)   
tempfile sect4
use "${input}\rt003.dta", clear

destring psu hhold, replace 
replace s04a_q02 = 12		if  s04a_q02>12
replace s04a_q03 = 30		if  s04a_q03>30
replace s04a_q04 = 24		if  s04a_q04>24			

* Correcting inconsistencias in labour relationship (reports a relationship but declares income in other relationship)
replace s04a_q07 = 1			if  s04a_q07>1  & s04a_q07<5  & (s04a_q08==. | s04a_q08==0) & s04b_q_2>0 & s04b_q_2<.
replace s04a_q07 = 1			if  s04a_q07>1  & s04a_q07<5  &  s04a_q08==2 & s04b_q_2>0 & s04b_q_2<.
replace s04a_q08 = .			if  s04a_q07==1 & s04a_q08==2 & s04b_q_2>0 & s04b_q_2<. & psu==209
replace s04a_q08 = 1			if  s04a_q08>1 & s04a_q08<5 & (s04a_q07==. | s04a_q07==0) & s04b_q_2>0 & s04b_q_2<.
replace s04a_q07 = 4			if  s04a_q07>0 & s04a_q07<4 & (s04a_q08==. | s04a_q08==0) & s04b_q08>0 & s04b_q08<.
replace s04a_q08 = 4			if  s04a_q08>0 & s04a_q08<4 & (s04a_q07==. | s04a_q07==0) & s04b_q08>0 & s04b_q08<.

replace s04b_q_2 = .				if  s04b_q_2==0
replace s04b_q_3 = .				if  s04b_q_3==0
replace s04b_q08 = .				if  s04b_q08==0
replace s04b_q09 = .				if  s04b_q09==0
	
keep if s04a_q08==1 | s04a_q07==1 | s04a_q08==4 | s04a_q07==4
replace s04a_q07 = .		if  s04a_q07==0
replace s04a_q08 = .		if  s04a_q08==0

gen  idp = idcode

*******************************************************************************************************************************
preserve 
tempfile auxiliar
use "${input}\hhold_exp_hies2010.dta", clear
destring psu hhold, replace
save `auxiliar'
restore

merge m:1 psu hhold using `auxiliar', keepusing(stratum wgt popwgt urbrural div)
drop if _merge==2
	
****** 1 - CALCULATE MEDIANS  
	
*** A - By stratum and industry
destring s04a_q_2, replace
foreach var in s04b_q_2 s04b_q_3 s04b_q08 s04b_q09 {
	gen medstr`var' = .
	}
levelsof stratum, 	local(strat)
levelsof s04a_q_2, 	local(industry)
foreach var in s04b_q_2 s04b_q_3 s04b_q08 s04b_q09 {
			foreach s of local strat {
				foreach i of local industry {
					qui sum `var' [aw=wgt] 			if  stratum==`s' & s04a_q_2==`i' & `var'!=0, detail
					qui replace medstr`var' = r(p50) 	if  stratum==`s' & s04a_q_2==`i' & medstr`var'==.
					}
				}
			}

*** B - By urban/rural and industry		 
foreach var in s04b_q_2 s04b_q_3 s04b_q08 s04b_q09 {
	gen medur`var' = .
	}
levelsof urbrural, 	local(strat)
levelsof s04a_q_2, 		local(industry)	  	 
foreach var in s04b_q_2 s04b_q_3 s04b_q08 s04b_q09 {
	 	    foreach s of local strat {
	            foreach i of local industry {
				    qui sum `var' [aw=wgt] 				if urbrural==`s' & s04a_q_2==`i' & `var'!=0, detail
		            qui replace medur`var' = r(p50) 		if urbrural==`s' & s04a_q_2==`i' & medur`var'==.
					}
				} 
			}
	  	   	  
*** C - By industry
foreach var in s04b_q_2 s04b_q_3 s04b_q08 s04b_q09 {
	gen medcnt`var' = .
	}
levelsof s04a_q_2, 		local(industry)	 
foreach var in s04b_q_2 s04b_q_3 s04b_q08 s04b_q09 {
	  	    foreach i of local industry {
				qui sum `var' [aw=wgt] 					if  s04a_q_2==`i' & `var'!=0, detail
				replace medcnt`var' = r(p50) 			if  medcnt`var'==.
				}
			}
   
   
****** 2 - COUNT NUMBER OF OBS WITHIUT MISSINGS AND ZERIOS BY STRATUM, URBAN AND RURAL, AND INDUSTRY 		
foreach var in s04b_q_2 s04b_q_3 s04b_q08 s04b_q09 {
	bysort  stratum s04a_q_2:  egen countstratum16`var'	= count(`var') 	if  `var'!=0
	bysort urbrural s04a_q_2:  egen countarea`var'  	= count(`var') 	if  `var'!=0
	}
	  
 	
****** 3 - We impute the MEDIAN values at different levels. We start from the lowest (stratum) to the highest level (national)
noi di as error "Replacing missing values by stratum median values per industry"	
replace s04b_q_2 = medstrs04b_q_2 		if  s04b_q_2==. & s04b_q01==1 & countstratum16s04b_q_2>30
replace s04b_q_3 = medstrs04b_q_3 		if  s04b_q_3==. & s04b_q03==1 & countstratum16s04b_q_3>30
replace s04b_q08 = medstrs04b_q08 		if  s04b_q08==. & s04b_q01==2 & countstratum16s04b_q08>30
replace s04b_q09 = medstrs04b_q09 		if  s04b_q09==. & s04b_q01==2 & countstratum16s04b_q09>30
noi di as error "Replacing missing values by urban/rural median values per industry"	
replace s04b_q_2 = medurs04b_q_2 		if  s04b_q_2==. & s04b_q01==1 & countareas04b_q_2>30
replace s04b_q_3 = medurs04b_q_3 		if  s04b_q_3==. & s04b_q03==1 & countareas04b_q_3>30
replace s04b_q08 = medurs04b_q08 		if  s04b_q08==. & s04b_q01==2 & countareas04b_q08>30
replace s04b_q09 = medurs04b_q09 		if  s04b_q09==. & s04b_q01==2 & countareas04b_q09>30
noi di as error "Replacing missing values by country median values per industry"	
replace s04b_q_2 = medcnts04b_q_2 		if  s04b_q_2==. & s04b_q01==1 
replace s04b_q_3 = medcnts04b_q_3 		if  s04b_q_3==. & s04b_q03==1
replace s04b_q08 = medcnts04b_q08 		if  s04b_q08==. & s04b_q01==2
replace s04b_q09 = medcnts04b_q09 		if  s04b_q09==. & s04b_q01==2
*******************************************************************************************************************************

* Monthly Income of those working as day labourers
* s04b_q_2: What was the (average) daily wage in cash in the past 12 months? (TAKA)
* s04b_q_3: How much did you receive in-kind per day? (TAKA)
* s04a_q03: On average, how many days per month did you work?
* s04a_q02: How many months did you do this activity in the last 12 months?
gen daylab_cash = s04b_q_2 * s04a_q03 * (s04a_q02/12)	if  s04b_q01==1 	
gen daylab_kind = s04b_q_3 * s04a_q03 * (s04a_q02/12)	if  s04b_q01==1 & s04b_q03==1

* Monthly Income of those working as employees
* s04b_q08: What is your total net take-home monthly remuneration after all deduction at source?
* s04b_q09: What is the total value of in-kind or other benefits you received over the past 12 months?
gen employee_cash = s04b_q08							if  s04b_q01==2
gen employee_kind = s04b_q09/12						if  s04b_q01==2

egen x = rsum(daylab_cash daylab_kind employee_cash employee_kind), missing
drop if x==.
order  psu hhold idp 
sort   psu hhold idp 
drop   idcode* s04a_q05 s04a_q_3 s04b_q01 s04b_q02 s04b_q_1 s04b_q_2 s04b_q03 s04b_q04 s04b_q05 s04b_q_3 s04b_q07 s04b_q08 s04b_q09 x   
save `sect4'


**** INCOMES FROM SECTION 5: NON-AGRICULTURAL BUSINESSES                                               
* Self-Employed (s04a_q08==2)                                                         
* Employers     (s04a_q08==3) 
tempfile section4
tempfile sect5
tempfile section5
tempfile section5_1
tempfile section5_2
tempfile section5_2aux
tempfile section5_3

* FOR THOSE WITH INCOME INFO AND MATCHING EMPLOYMENT INFO
* Preparation of Section 4 (to be merged with Section 5)
use "${input}\rt003.dta", clear
destring psu hhold, replace
keep if s04a_q08==2 | s04a_q08==3
gen  idp = idcode

* Keeping the activity with the most worked hours
gen  hours = s04a_q02 * s04a_q03 * s04a_q04
egen aux_hours = sum(hours), by(psu hhold idp)
egen max_hours = max(hours), by(psu hhold idp)
drop if hours!=max_hours
duplicates tag psu hhold idp, gen(tag)
drop if ((psu==439 & hhold==31)   | (psu==579 & hhold==218)) & tag==1
drop if ((psu==51  & hhold==89)   | (psu==156 & hhold==48)  | (psu==330 & hhold==52)) & serial=="01" 	// HIGHER PROFIT IN SECTION 5
drop if ((psu==37  & hhold==185)) & serial=="01" 													  	// HIGHER PROFIT IN SECTION 5
drop if ((psu==193 & hhold==97)   | (psu==418 & hhold==99)  | (psu==410 & hhold==106)) & serial=="02" 	// HIGHER PROFIT IN SECTION 5
drop if ((psu==612 & hhold==94))  & serial=="02" 													  	// HIGHER PROFIT IN SECTION 5
drop if ((psu==51  & hhold==120)) & serial=="03"												  		// HIGHER PROFIT IN SECTION 5
drop if ((psu==605 & hhold==10))  & serial=="06"												  		// HIGHER PROFIT IN SECTION 5
drop if ((psu==578 & hhold==58))  & serial!="01"												  		// HIGHER PROFIT IN SECTION 5
replace hours = aux_hours

* Share of individual hours in household hours
egen hours_hh = sum(hours), by(psu hhold)
gen  share_ind = hours/hours_hh
order psu hhold idp 
sort  psu hhold idp 
drop  idcode* s04a_q05 s04a_q_3 s04b_q01 s04b_q02 s04b_q_1 s04b_q_2 s04b_q03 s04b_q04 s04b_q05 s04b_q_3 s04b_q07 s04b_q08 s04b_q09 max_hours tag hours_hh aux_hours
save `section4'


use "${input}\rt004.dta", clear
destring psu hhold, replace
* Total Non-Agricultural Income by Activity
* s05b_q20: Net revenues over the past 12 months?
* s05a_q07: What share of profit is owned by household?
gen month_nonagri = (s05b_q20 * (s05a_q07/100)) / 12
collapse (sum) month_nonagri, by(psu hhold)
sort psu hhold
save `section5'	

use  `section4'	
sort  psu hhold idp
merge m:1 psu hhold using `section5'

* Save info for those with income info but without employment info
preserve
tempfile only_income_info
keep if _merge==2 
keep psu hhold month_nonagri
sort psu hhold
save `only_income_info'	
restore

replace month_nonagri = month_nonagri*share_ind
drop if _merge==2
gen   x1 = 1	if  _merge==1
drop _merge
sort  psu hhold idp
save `section5_1'	

* FOR THOSE WITH INCOME INFO BUT WITHOUT MATCHING EMPLOYMENT INFO
use "${input}\rt004.dta", clear
destring psu hhold, replace
sort psu hhold
merge m:1 psu hhold using `only_income_info'
drop if _merge!=3
drop _merge 
keep if enumber==1
keep psu hhold s05a_q_1 month_nonagri
sort psu hhold
save    `section5_2aux'

use "${input}\rt003.dta", clear
destring psu hhold, replace
gen  idp = idcode
drop if s04a_q08==2 | s04a_q08==3

gen hours = s04a_q02 * s04a_q03 * s04a_q04
collapse (sum) hours, by(psu hhold idp)
egen share_tot = sum(hours), by(psu hhold)
gen  share_ind = hours/share_tot
sort psu hhold idp
merge m:1 psu hhold using `section5_2aux'	

* Save info for those with income info but without employment info
preserve
keep if _merge==2 
keep psu hhold s05a_q_1 month_nonagri
sort psu hhold
tempfile only_income_info_2
save `only_income_info_2'	
restore

replace month_nonagri = month_nonagri*share_ind
drop if _merge!=3
drop _merge
keep  psu hhold idp s05a_q_1 month_nonagri
order psu hhold idp s05a_q_1 month_nonagri
sort psu hhold idp
gen  x2 = 1
save `section5_2'	

* FOR THOSE WITH INCOME INFO BUT WITHOUT EMPLOYMENT INFO AT ALL
use `roster', clear
merge m:1 psu hhold using `only_income_info_2'
drop if _merge!=3
drop if s01a_q03!=1
drop _merge
keep psu hhold idp s05a_q_1 month_nonagri
gen  x3 = 1
sort psu hhold idp
save `section5_3'

* Append Section 5
use          `section5_1'
append using `section5_2'
append using `section5_3'	

gen     anomalies = 1	if  x1==1
replace anomalies = 2	if  x2==1
replace anomalies = 3    if  x3==1
drop x*
destring s04a_q_2, replace 
sort psu hhold idp
save    `sect5'


**** INCOMES FROM SECTION 7: AGRICULTURAL ACTIVITIES
* Self-Employed (s04a_q07==2)
* Employers     (s04a_q07==3)
tempfile section7
tempfile section4
use "${input}\rt003.dta", clear
destring psu hhold, replace
keep if s04a_q07==2 | s04a_q07==3
gen  idp = idcode

* Keeping the activity with the most worked hours
gen  hours = s04a_q02 * s04a_q03 * s04a_q04
egen aux_hours = sum(hours), by(psu hhold idp)
egen max_hours = max(hours), by(psu hhold idp)
drop if hours!=max_hours
duplicates tag psu hhold idp, gen(tag)
drop if tag==1 & serial!="01"
replace hours = aux_hours

* Share of individual hours in household hours
egen hours_hh = sum(hours), by(psu hhold)
gen  share_ind = hours/hours_hh
order psu hhold idp 
sort  psu hhold idp 
drop   s04a_q05 s04a_q_3 s04b_q02 s04b_q_1 idcode s04b_q07 s04b_q08 s04b_q09 s04b_q_2 s04b_q_3 s04b_q01 s04b_q03 s04b_q04 s04b_q05 max_hours tag serial hours_hh aux_hours
save `section4'


**** Section 7B  - CROP PRODUCTION at household/crop level
tempfile section7b
use "${input}\rt006.dta", clear

destring psu hhold, replace
keep if  s07b_q02==1
* s07b_q04: How much in total of crop did you produce in the last 12 months? (kg)
* s07b_q_1: How much in total of crop did you produce in the last 12 months? (taka/kg)
* s07b_q05: How much did your household consumed in the last 12 months?
* s07b_q06: How much did your household sell in the last 12 months?

******************************************************************************************************************
merge m:1 psu hhold using `auxiliar', keepusing(stratum wgt popwgt urbrural div)
drop  if _merge==2

* Rural variable	 
gen rural = (urbrural==1)

****** 1 - We found outliers in the unit values (s07b_q_1) that were affecting the gini. 

* When s07b_q04>0 and the unit value is zero we replace these values for missing and we use the medians to impute those prices
gen 	p = s07b_q_1
replace p = . 		if  (s07b_q04>0 & s07b_q04~=.) & p==0
gen   lnp = ln(p) 
	

* A - Identify and replace outliers as missings
levelsof crop_cod, local (crop) 	
foreach f of local crop {
			sum p [aw=wgt] 	if  crop_cod==`f', detail	

			* When the variance of p exists and is different from zero we detect and delete outliers
			if r(Var)!=0 & r(Var)<. {
					levelsof stratum, local(strat)
					foreach s of local strat {
							sum p [aw=wgt] 		if  p>0 & p<. & stratum==`s' & crop_cod==`f'
							local antp = r(N)
							sum lnp [aw=wgt] 	if  stratum==`s' & crop_cod==`f', detail
							local ameanp = r(mean)
							local asdp   = r(sd)			
      						replace p = . 		if (abs((lnp-`ameanp')/`asdp')>3.5 & ~mi(lnp)) & stratum==`s' & crop_cod==`f'
							count if p>0 & ~mi(p) & stratum==`s' & crop_cod==`f'
							local postp = r(N)
							}
					}
			}
gen outlier = (p==.)

* B - Count number of observations without outliers
bysort stratum	crop_cod: egen countstratum16 	= count(p)
bysort rural  	crop_cod: egen countarea  	= count(p)	
	
* C - Calculate medians 

* By stratum and crop	
levelsof stratum, 	local(strat)
levelsof crop_cod,   local(crop)
gen medianstratum = . 
foreach s of local strat {
				foreach f of local crop {
					sum p [aw=wgt] 					if  stratum==`s' & crop_cod==`f' & p!=0, detail
					replace medianstratum = r(p50) 	if  stratum==`s' & crop_cod==`f' & medianstratum==.
					}
				}		
		
* By urban/rural and crop		 
levelsof rural,  	local(strat)
levelsof crop_cod, 	local(crop)
gen medianarea = . 
foreach s of local strat {
				foreach f of local crop {
					sum p [aw=wgt] 					if  rural==`s' & crop_cod==`f' & p!=0, detail
					replace medianarea = r(p50) 		if  rural==`s' & crop_cod==`f' & medianarea==.
					}
				}

* By country and crop
levelsof crop_cod, local(crop)
gen mediancountry =.
foreach f of local crop {
				sum p [aw=wgt] 					if  crop_cod==`f' & p!=0, detail
				replace mediancountry = r(p50) 
				}
	  

* C - We impute the MEDIAN values at different levels. We start from the lowest (stratum) to the highest level (national)	
noi di as error "Replacing outliers by stratum median price per crop_cod"	
replace p = medianstratum 		if  p==. & countstratum16>30
noi di as error "Replacing outliers by area median price per crop_cod"	
replace p = medianarea 			if  p==. & countarea>30
noi di as error "Replacing outliers by country median price per crop_cod"	
replace p = mediancountry 		if  p==. 
******************************************************************************************************************
replace s07b_q_1 = p

gen crop_cons = s07b_q05 * s07b_q_1/12	
gen crop_sold = s07b_q06 * s07b_q_1/12
collapse (sum) crop_cons crop_sold, by(psu hhold)
drop if crop_cons==0 & crop_sold==0
sort  psu hhold
save `section7b', replace


**** Sección 7C1 - LIVESTOCK and POULTRY at household/animal level
tempfile section7c1
use "${input}\rt007.dta", clear
destring psu hhold, replace
* s07c_q_3: How many died/did your household sell in the last 12 months? (taka)
* s07c_q_4: How many did your household consume in the 12 months? (taka)
gen livestock_cons = s07c_q_3/12
gen livestock_sold = s07c_q_4/12
collapse (sum) livestock_cons livestock_sold, by(psu hhold)
drop if livestock_cons==0 & livestock_sold==0
sort  psu hhold
save `section7c1', replace


**** Sección 7C2 - LIVESTOCK and POULTRY BY-PRODUCTS at household/by-product level
tempfile section7c2
use "${input}\rt008.dta", clear

destring psu hhold, replace
* s07c_q_2: How much did you sell in the last 12 months? (taka)
* s07c_q_3: How much did you consume in the last 12 months? (taka
gen byproduct_cons = s07c_q_3/12
gen byproduct_sold = s07c_q_2/12
collapse (sum) byproduct_cons byproduct_sold, by(psu hhold)
drop if byproduct_cons==0 & byproduct_sold==0
sort  psu hhold
save `section7c2', replace


**** Sección 7C3 - FISH FARMING and FISH CAPTURE at household/fish level
tempfile section7c3
use "${input}\rt009.dta", clear
destring psu hhold, replace
* s07c_q_2: How much did your household sell in the past 12 months? (taka)
* s07c_q_3: How much did your household consume in the 12 months? (taka)
gen fish_cons = s07c_q_3/12
gen fish_sold = s07c_q_2/12
collapse (sum) fish_cons fish_sold, by(psu hhold)
drop if fish_cons==0 & fish_sold==0
sort  psu hhold
save `section7c3', replace


**** Sección 7C4 - FARM FORESTRY at household/tree level
tempfile section7c4
use "${input}\rt010.dta", clear
destring psu hhold, replace
* s07c_q15: How much did your household sell in the last 12 months? (taka)
* s07c_q16: How much did your household consume in the last 12 months? (taka
gen tree_cons = s07c_q16/12
gen tree_sold = s07c_q15/12
collapse (sum) tree_cons tree_sold, by(psu hhold)
drop if tree_cons==0 & tree_sold==0
sort  psu hhold
save `section7c4', replace


**** Sección 7D - EXPENSES ON AGRICULTURAL INPUTS at household/input level
tempfile section7d
use "${input}\rt011.dta", clear
destring psu hhold, replace
keep if s07d_q_1>=0 & s07d_q_1<999999

* s07d_q_1: How much did your household spend on the (item) in the last 12 months? (Taka)
gen     agri_expenditure = s07d_q_1/12
replace agri_expenditure = agri_expenditure*(-1)
collapse (sum) agri_expenditure, by(psu hhold)
drop if agri_expenditure==0
sort  psu hhold
save `section7d', replace


* AGRICULTURAL ASSETS
tempfile section7e
use "${input}\rt012.dta", clear
destring psu hhold, replace
gen agri_asset_inc = s07e_q04/12 	if  agric_as~=420
collapse (sum) agri_asset_inc, by(psu hhold)
drop if agri_asset_inc==0
sort psu hhold
save `section7e', replace


use  `section7b', clear
merge 1:1 psu hhold using `section7c1'
drop _merge
sort  psu hhold
merge 1:1 psu hhold using `section7c2'
drop _merge
sort  psu hhold
merge 1:1 psu hhold using `section7c3'
drop _merge
sort  psu hhold
merge 1:1 psu hhold using `section7c4'
drop _merge
sort  psu hhold
merge 1:1 psu hhold using `section7d'
drop _merge
sort  psu hhold
egen agri_income = rsum(crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold), missing

gen     type_agri = 1	if  agri_income==.					/* no agricultural income, but agricultural expenditure		*/
replace type_agri = 2	if  agri_expend==.					/* no agricultural expenditure, but agricultural income 	*/
replace type_agri = 3	if  agri_income!=. & agri_expend!=.	/* both agricultural income and agricultural expenditure 	*/

egen  agri_net = rsum(agri_income agri_expend), missing

keep  psu hhold agri_net agri_income agri_expend crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold
order psu hhold agri_net agri_income agri_expend crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold
sort  psu hhold
save `section7'	


************************************************************
* FOR THOSE WITH INCOME INFO AND MATCHING EMPLOYMENT INFO
************************************************************
tempfile section7_1
use  `section4'	
sort  psu hhold idp
merge m:1 psu hhold using `section7'

* Save info for those with income info but without employment info
preserve
keep if _merge==2 
keep psu hhold agri_net agri_income agri_expend crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold
sort psu hhold
tempfile only_income_info3
save `only_income_info3'	
restore

local lista "agri_net agri_income agri_expend crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold"
foreach income in `lista' {
	replace `income' = `income'*share_ind
	}
drop if _merge==2
gen    x1 = 1	if  _merge==1
drop _merge
order psu hhold idp agri_net agri_income agri_expend crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold 
sort  psu hhold idp
save `section7_1'	


*******************************************************************
* FOR THOSE WITH INCOME INFO BUT WITHOUT MARCHING EMPLOYMENT INFO
*******************************************************************
tempfile section7_2
use "${input}\rt003.dta", clear
destring psu hhold, replace
gen  idp = idcode
drop if s04a_q07==2 | s04a_q07==3
gen hours = s04a_q02 * s04a_q03 * s04a_q04
collapse (sum) hours, by(psu hhold idp)
egen share_tot = sum(hours), by(psu hhold)
gen  share_ind = hours/share_tot
keep psu hhold idp share_ind
sort psu hhold idp
merge m:1 psu hhold using `only_income_info3'	

* Save info for those with income info but without employment info
preserve
keep if _merge==2 
keep psu hhold agri_net agri_income agri_expend crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold
sort psu hhold
tempfile only_income_info_4
save `only_income_info_4'	
restore

local lista "agri_net agri_income agri_expend crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold"
foreach income in `lista' {
	replace `income' = `income'*share_ind
	}
drop if _merge!=3
drop    _merge

keep  psu hhold idp agri_net agri_income agri_expend crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold share_ind 
order psu hhold idp agri_net agri_income agri_expend crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold share_ind
sort  psu hhold idp
gen   x2=1
save `section7_2'	


********************************************************************
* FOR THOSE WITH INCOME INFO BUT WITHOUT EMPLOYMENT INFO AT ALL
********************************************************************
use `roster', clear
merge m:1 psu hhold using `only_income_info_4'
drop if _merge!=3
drop if s01a_q03!=1
drop _merge
keep psu hhold idp agri_net agri_income agri_expend crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold
gen  x3 = 1
sort psu hhold idp

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
destring s04a_q_2, replace
sort psu hhold idp
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
gen 	w_cat = 1 				if  s04a_q07==1 | s04a_q08==1 
replace w_cat = 2 				if  s04a_q07==2 | s04a_q08==2
replace w_cat = 3 				if  s04a_q07==3 | s04a_q08==3
replace w_cat = 4 				if  s04a_q07==4 | s04a_q08==4 

* Worked Hours (Year)
capture drop hours
gen     hours = s04a_q02 * s04a_q03 * s04a_q04

* Worked Months
gen     months = s04a_q02

* Industry
destring s04a_q*, replace
destring s05a_q*, replace

replace s04a_q_2 = s05a_q_1		if  s04a_q_2==.
replace s04a_q_2 = 1				if  anomalies==5 | anomalies==6

egen    income = rsum(daylab_cash daylab_kind employee_cash employee_kind month_nonagri agri_net), missing
replace income = income*(-1)

local var "w_cat hours months s04a_q_1 s04a_q_2 s04b_q06 daylab_cash daylab_kind employee_cash employee_kind month_nonagri agri_net anomalies"
foreach v in `var' {
	rename `v' `v'_
	}
sort psu hhold idp income
by   psu hhold idp: gen act = _n				   

keep  psu hhold idp w_cat hours months s04a_q_1 s04a_q_2 s04b_q06 daylab_cash daylab_kind employee_cash employee_kind month_nonagri agri_net act anomalies share_ind
order psu hhold idp w_cat hours months s04a_q_1 s04a_q_2 s04b_q06 daylab_cash daylab_kind employee_cash employee_kind month_nonagri agri_net act anomalies share_ind
reshape wide       w_cat	hours months s04a_q_1 s04a_q_2 s04b_q06 daylab_cash daylab_kind employee_cash employee_kind month_nonagri agri_net anomalies share_ind, j(act) i(psu hhold idp)

label   define worker 1 Daily 2 SelfEmployed 3 Employer 4 Employee 
label   values  w_cat_1 worker
label   values  w_cat_2 worker
label   values  w_cat_3 worker
label   values  w_cat_4 worker

forvalues t = 1(1)5 {
label var hours_`t' 				"Yearly Hours of work in activity `t'"
label var months_`t' 			"Months of work in activity `t'"
label var w_cat_`t' 				"Employment Category - Activity `t'"
label var s04a_q_2_`t' 			"Industry Code - Activity `t'"
label var s04a_q_1_`t' 			"Occupation Code - Activity `t'"
label var s04b_q06_`t' 			"Sector of Occupation - Activity `t'"
label var daylab_cash_`t' 		"Monthly income (CASH) of daily labourers (taka) - Activity `t'"
label var daylab_kind_`t' 		"Monthly income (IN-KIND) of daily labourers (taka) - Activity `t'"
label var employee_cash_`t' 		"Monthly income (CASH) of employees (taka) - Activity `t'"
label var employee_kind_`t' 		"Monthly income (KIND) of employees (taka) - Activity `t'"
label var month_nonagri_`t' 		"Monthly income in non-agricultural activities as self-employed or employer (taka) - Activity `t'"
label var agri_net_`t' 			"Monthly income in agricultural activities as self-employed or employer (taka) - Activity `t'"
}
tempfile sect_4_5_7
sort psu hhold idp
save `sect_4_5_7'

use `roster', clear
merge 1:1 psu hhold idp using `sect_4_5_7'
drop if _merge==2
drop _merge
tempfile sect_4_5_7
sort psu hhold idp

local var "daylab_cash_ daylab_kind_ employee_cash_ employee_kind_ month_nonagri_ agri_net_"
foreach income in `var' {
	forvalues j = 1(1)5 {
	replace `income'`j' = .	if `income'`j'==0
	}
	}
drop employee_cash_5 employee_kind_5 daylab_cash_5 daylab_kind_5 month_nonagri_5

save `sect_4_5_7'


****************************************
* INCOMES FROM SECTION 8: OTHER INCOME 
****************************************
tempfile sect8
use "${input}\rt001.dta", clear
destring psu hhold, replace
keep psu hhold s08b_q01 s08b_q02 s08b_q03 s08b_q_1 s08b_q_2 s08b_q04 s08b_q05 s08b_q06 s08b_q07 s08b_q08 s08b_q09 s08b_q11 s08b_q12 s08b_q13

unab xvars: s08b_q01 s08b_q02 s08b_q03 s08b_q_1 s08b_q_2 s08b_q04 s08b_q05 s08b_q06 s08b_q07 s08b_q08 s08b_q09 s08b_q11 s08b_q12 s08b_q13
foreach x of local xvars { 
    replace `x' = `x'/12
}
keep psu hhold s08b_q01 s08b_q02 s08b_q03 s08b_q_1 s08b_q_2 s08b_q04 s08b_q05 s08b_q06 s08b_q07 s08b_q08 s08b_q09 s08b_q11 s08b_q12 s08b_q13
sort psu hhold
save `sect8'

use `sect_4_5_7'
merge m:1 psu hhold using `sect8'
drop _merge
unab xvars: s08b_q01 s08b_q02 s08b_q03 s08b_q_1 s08b_q_2 s08b_q04 s08b_q05 s08b_q06 s08b_q07 s08b_q08 s08b_q09 s08b_q11 s08b_q12 s08b_q13
foreach x of local xvars { 
    replace `x' = . 	if  s01a_q03!=1
	replace `x' = .		if  `x'==0
	}
sort psu hhold idp
tempfile sect_4_5_7_8
save `sect_4_5_7_8'


****************************************
* INCOMES FROM SECTION 9: HOUSING RENT 
****************************************
tempfile sect9
use "${input}\rt019.dta", clear
destring psu hhold, replace
keep  if  item==382
duplicates report psu hhold
gen   housing_rent = s09d2_q0/12
sort  psu hhold
save `sect9', replace

use `sect_4_5_7_8'
merge m:1 psu hhold using `sect9'
drop _merge
sort  psu hhold idp

merge m:1 psu hhold using `section7e'
drop _merge
sort  psu hhold idp

tempfile sect_4_5_7_8_9
save    `sect_4_5_7_8_9'


***********************************************
* INCOMES FROM SECTION 1C: SOCIAL SAFETY NETS
***********************************************
tempfile sect1
use "${input}\rt002.dta", clear

keep  if s01c_q01==1
destring psu hhold, replace
gen idp = idcode
order psu hhold idp


* S01C_Q05: How much did you receive in cash in last 12 months?
replace s01c_q05 = .		if  s01c_q05==0
* OLD-AGE ALLOWANCE
replace s01c_q05 = 300		if  s01c_q02==1 & s01c_q05>0 & s01c_q05<.		/* we assume that all people report monthly values */
* WIDOWS ALLOWANCE
replace s01c_q05 = 300		if  s01c_q02==2 & s01c_q05>0 & s01c_q05<.		/* we assume that all people report monthly values */
* DISABLED ALLOWANCE
replace s01c_q05 = 300		if  s01c_q02==3 & s01c_q05>0 & s01c_q05<.		/* we assume that all people report monthly values */


*** FOOD PROGRAMS
gen     price = .
replace price = 15			if  s01c_q_4==1    /* Rice	 	  */
replace price = 15			if  s01c_q_4==2	   /* Maize 	  */
replace price = 15			if  s01c_q_4==3	   /* Wheat 	  */
replace price = 50			if  s01c_q_4==5	   /* Clothing    */		
replace price = 15			if  s01c_q_4==6	   /* Other       */

gen     kind = price*s01c_q_5
replace kind = .			if  kind==0

egen    ssn = rsum(s01c_q05 kind), missing
rename  s01c_q05 cash

collapse (sum) cash kind ssn, by(psu hhold idp s01c_q02)
reshape wide ssn cash kind, i(psu hhold idp) j(s01c_q02)

sort    psu hhold idp
save `sect1', replace

use `sect_4_5_7_8_9'
merge 1:1 psu hhold idp using `sect1'
drop _merge
sort psu hhold idp
tempfile sect_4_5_7_8_9_1
save `sect_4_5_7_8_9_1'


* STIPEND
use "${input}\rt002.dta", clear
destring psu hhold, replace
gen idp = idcode
gen stipend_primary = s02b_q04/12
gen stipend_secondary = s02b_q06/12

keep psu hhold idp stipend*
sort psu hhold idp
tempfile stipend
save `stipend', replace

use `sect_4_5_7_8_9_1'
merge 1:1 psu hhold idp using `stipend'
drop _merge
sort psu hhold idp
tempfile income
save `income', replace


***************************************************************************************************
**** ROSTER
***************************************************************************************************
tempfile roster
use "${input}\rt002.dta", clear
destring psu hhold, replace
ren  idcode idp
duplicates report 
duplicates drop
egen member1 = count(idp), by(psu hhold)
drop if member1==0
drop if idp==.
keep psu hhold idp s01a*
sort psu hhold idp
save `roster', replace


***************************************************************************************************
**** EMPLOYMENT
***************************************************************************************************
tempfile employment
use "${input}\rt002.dta", clear
destring psu hhold, replace
ren idcode idp
duplicates report 
duplicates drop
drop if idp==.
keep psu hhold idp s01b*
sort psu hhold idp
save `employment', replace
	
	
***************************************************************************************************
**** EDUCATION - LITERACY AND ATTAINMENT
***************************************************************************************************
tempfile education_all
use "${input}\rt002.dta", clear
destring psu hhold, replace
ren idcode idp
duplicates report 
duplicates drop 
drop if  idp==.
keep psu hhold idp s02a*
sort psu hhold idp
save `education_all', replace
	
	
***************************************************************************************************
**** EDUCATION - CURRENT ENROLLMENT
***************************************************************************************************
tempfile education_current
use "${input}\rt002.dta",clear
destring psu hhold, replace
ren idcode idp	
duplicates report 
duplicates drop 
drop if  idp==.
keep psu hhold idp s02b_q01-s02b_q07
sort psu hhold idp
save `education_current', replace
	
	
***************************************************************************************************
**** ASSETS - MATERIALS
***************************************************************************************************
use "${input}\rt020.dta", clear
destring psu hhold, replace
drop ln s09e_q02 s09e_q03 s09e_q04
keep if s09e_q01==1
rename s09e_q01 asset
reshape wide asset, i(psu hhold) j(dg_code)
tempfile assets
save `assets'
	
	
***************************************************************************************************
**** ASSETS - ANIMALS
***************************************************************************************************
use "${input}\rt007.dta", clear
destring psu hhold, replace	
tempfile assets_animal
sort psu hhold
gen animal = 1	if s07c_q02>0 & s07c_q02<5000
drop s07c_q_1 s07c_q02 s07c_q03 s07c_q_2 s07c_q04 s07c_q_3 s07c_q_4 s07c_q04 s07c_q05 
reshape wide animal, i(psu hhold) j(liv_code)
duplicates report psu hhold
save `assets_animal', replace	
	
	
***************************************************************************************************
**** CONSUMPTION
***************************************************************************************************
use "${input}\consumption_00_05_10.dta", clear
tempfile consumption
keep if year==3
replace year = 2010
sort psu id
gen l = length(psu)
gen m = length(id)
gen hhold = substr(id,l+1,m-l)
drop m l
duplicates report psu 
destring psu hhold, replace
sort psu hhold
save `consumption', replace

	
***************************************************************************************************
**** HOUSING
***************************************************************************************************
use "${input}\rt001.dta", clear
tempfile housing
order psu hhold
keep psu hhold stratum region-wgt s06*
duplicates report psu hhold
sort psu hhold
save `housing', replace
	
	
***************************************************************************************************
**** LAND
***************************************************************************************************
use "${input}\rt001.dta", clear
tempfile land
order psu hhold
keep  psu hhold stratum region-wgt s07* s08a*
duplicates report psu hhold
sort psu hhold
duplicates report psu hhold
save `land', replace
	
	
***************************************************************************************************
**** MERGE DATASETS
***************************************************************************************************
* Individual-level datasets
use `roster', clear
foreach i in employment education_all education_current income {
	merge 1:1 psu hhold idp using  ``i'', keep(1 3) nogen
	}
	
* Household-level datasets
foreach j in housing consumption assets assets_animal land {
	merge m:1 psu hhold using ``j'', keep(1 3) nogen
	}
rename wgt hhwgt
order  psu hhold idp hhwgt
sort   psu hhold idp
rename idp idp1
*</_Datalibweb request_>

replace stipend_primary = .		if  stipend_primary==0
replace stipend_secondary = .	if  stipend_secondary==0

gen     ssn23_alt = .
replace ssn23_alt = stipend_primary			if  stipend_primary>0 & stipend_primary<. 
replace ssn23_alt = ssn23					if  ssn23_alt==. & ssn23>0 & ssn23<.

gen     ssn26_alt = .
replace ssn26_alt = stipend_secondary		if  stipend_secondary>0 & stipend_secondary<.
replace ssn26_alt = ssn26					if  ssn26_alt==. & ssn26>0 & ssn26<.


***** IMPUTATION FOOD PROGRAMS
* 10 = Allowance for Chittagong hill tracts 
* 16 = Subsidy for open market sales         
* 17 = VGD
* 18 = VGF
* 19 = Test relief - food
* 20 = GR
* 21 = Food for work                         
* 24 = School feeding program               
egen food_income_ind = rsum(ssn10 ssn16 ssn17 ssn18 ssn19 ssn20 ssn21 ssn24), missing
egen food_income = sum(food_income_ind), by(psu hhold)

* By division/urban-rural-quintile
egen 	region2 = group(region)

* Welfare variable
sum zu10 [aw=hhwgt] 
local mean_nat = r(mean)
sum p_cons [aw=hhwgt] 
local avg = r(mean)
gen welfare = p_cons*`mean_nat'/zu10

_ebin welfare [aw=hhwgt] 	if region2==1 & urban==0, gen(quintile_1r) nq(5) 
_ebin welfare [aw=hhwgt] 	if region2==2 & urban==0, gen(quintile_2r) nq(5) 
_ebin welfare [aw=hhwgt] 	if region2==3 & urban==0, gen(quintile_3r) nq(5) 
_ebin welfare [aw=hhwgt] 	if region2==4 & urban==0, gen(quintile_4r) nq(5) 
_ebin welfare [aw=hhwgt] 	if region2==5 & urban==0, gen(quintile_5r) nq(5) 
_ebin welfare [aw=hhwgt] 	if region2==6 & urban==0, gen(quintile_6r) nq(5) 
_ebin welfare [aw=hhwgt] 	if region2==7 & urban==0, gen(quintile_7r) nq(5) 

_ebin welfare [aw=hhwgt] 	if region2==1 & urban==1, gen(quintile_1u) nq(5) 
_ebin welfare [aw=hhwgt] 	if region2==2 & urban==1, gen(quintile_2u) nq(5) 
_ebin welfare [aw=hhwgt] 	if region2==3 & urban==1, gen(quintile_3u) nq(5) 
_ebin welfare [aw=hhwgt] 	if region2==4 & urban==1, gen(quintile_4u) nq(5) 
_ebin welfare [aw=hhwgt] 	if region2==5 & urban==1, gen(quintile_5u) nq(5) 
_ebin welfare [aw=hhwgt] 	if region2==6 & urban==1, gen(quintile_6u) nq(5) 
_ebin welfare [aw=hhwgt] 	if region2==7 & urban==1, gen(quintile_7u) nq(5)

********************************
*** SAMPLING BENEFICIARIES   ***
********************************
forvalues i = 1(1)7 {
	forvalues j = 1(1)5	{
		sum ssn10  [w=hhwgt] 	if  quintile_`i'r==`j'
		local local1 = r(sum_w)	
		sum ssn16  [w=hhwgt] 	if  quintile_`i'r==`j'
		local local2 = r(sum_w)
		sum ssn17  [w=hhwgt] 	if  quintile_`i'r==`j'
		local local3 = r(sum_w)
		sum ssn18  [w=hhwgt] 	if  quintile_`i'r==`j'
		local local4 = r(sum_w)
		sum ssn19  [w=hhwgt] 	if  quintile_`i'r==`j'
		local local5 = r(sum_w)
		sum ssn20  [w=hhwgt] 	if  quintile_`i'r==`j'
		local local6 = r(sum_w)
		sum ssn21  [w=hhwgt] 	if  quintile_`i'r==`j'
		local local7 = r(sum_w)		
		sum ssn24  [w=hhwgt] 	if  quintile_`i'r==`j'
		local local8 = r(sum_w)			
		sum year [w=hhwgt]    if  quintile_`i'r==`j'
		local total = r(sum_w)			
		local sample`i'r`j' = (`local1'+`local2'+`local3'+`local4'+`local5'+`local6'+`local7'+`local8')*2.4/`total'	

		set seed 1978
		gen     x`i'r`j' = runiform()   if  quintile_`i'r==`j'
		replace x`i'r`j' = . 			if  x`i'r`j'>`sample`i'r`j''  
		
		sum ssn10  [w=hhwgt] 	if  quintile_`i'u==`j'
		local local1 = r(sum_w)	
		sum ssn16  [w=hhwgt] 	if  quintile_`i'u==`j'
		local local2 = r(sum_w)
		sum ssn17  [w=hhwgt] 	if  quintile_`i'u==`j'
		local local3 = r(sum_w)
		sum ssn18  [w=hhwgt] 	if  quintile_`i'u==`j'
		local local4 = r(sum_w)
		sum ssn19  [w=hhwgt] 	if  quintile_`i'u==`j'
		local local5 = r(sum_w)
		sum ssn20  [w=hhwgt] 	if  quintile_`i'u==`j'
		local local6 = r(sum_w)
		sum ssn21  [w=hhwgt] 	if  quintile_`i'u==`j'
		local local7 = r(sum_w)		
		sum ssn24  [w=hhwgt] 	if  quintile_`i'u==`j'
		local local8 = r(sum_w)				
		sum year [w=hhwgt]    if  quintile_`i'u==`j'
		local total = r(sum_w)
		local sample`i'u`j' = (`local1'+`local2'+`local3'+`local4'+`local5'+`local6'+`local7'+`local8')*2.4/`total'	
		
		set seed 1978
		gen     x`i'u`j' = runiform()   	if  quintile_`i'u==`j'
		replace x`i'u`j' = . 				if  x`i'u`j'>`sample`i'u`j'' 		
		}
	}

egen    new_program = rsum(x*)
replace new_program = 1						if  new_program>0 & new_program<.
replace new_program = .						if  new_program==0


***************************************
*** IMPUTING BENEFITS BY HOT-DECK   ***
***************************************
replace food_income_ind =-9					if  new_program==1 & ssn10!=0 & ssn16!=0 & ssn21!=0 & ssn24!=0
replace food_income_ind =-9					if  ssn10==0 | ssn16==0 | ssn17==0 | ssn18==0 | ssn19==0 | ssn20==0 | ssn21==0 | ssn24==0
gen		food_si = food_income_ind
replace food_si = 0							if  food_income_ind==.
replace food_si = .							if  food_income_ind==-9

preserve
gen copia_food = food_si
drop if food_si== 0
hotdeck_cedlas copia_food, by(region urban) seed(123) keep(psu hhold idp1 copia_food) store
restore
capture drop _merge
merge 1:1 psu hhold idp1 using "imp1.dta"

replace new_program = copia_food/5			if   new_program==1 & ssn10!=0 & ssn16!=0 & ssn17!=0 & ssn18!=0 & ssn19!=0 & ssn20!=0 & ssn21!=0 & ssn24!=0
replace ssn17 = copia_food/5				if   ssn17==0
replace ssn18 = copia_food/5				if   ssn18==0
replace ssn20 = copia_food/5				if   ssn20==0

*<_Save data file_>
compress
save "${output}/`yearfolder'_v`vm'_M.dta", replace
*</_Save data file_>
