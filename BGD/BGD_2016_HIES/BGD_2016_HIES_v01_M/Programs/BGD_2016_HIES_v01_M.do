/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   		BGD_2016_HIES_v01_M.do				   </_Program name_>
<_Application_>    		STATA 17.0							     <_Application_>
<_Author(s)_>      		acastillocastill@worldbank.org	          </_Author(s)_>
<_Author(s)_>      		tornarolli@gmail.com	          		  </_Author(s)_>
<_Date created_>   		05-25-2021	                           </_Date created_>
<_Date modified>   		19-03-2024	                          </_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        		BGD											</_Country_>
<_Survey Title_>   		HIES								   </_Survey Title_>
<_Survey Year_>    		2016									</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:					19-03-2024
File:					BGD_2016_HIES_v01_M.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>
clear all
set more off

global cpiver       	"09"
local code         		"BGD"
local year         		"2016"
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
use "${input}\HH_SEC_1A.dta", clear
drop    s1aq0a s1aq08-s1aq17 s1aq04-s1aq06
gen     idp = indid
order   hhid idp
duplicates report
duplicates drop
duplicates tag hhid idp, gen(tag)
drop if tag==1 & s1aq07==2
drop tag 
sort hhid idp
save `roster'

**** INCOMES FROM SECTION 4: DAY LABOURERS and EMPLOYEES    
* Day labourers (s4aq07==1 | s4aq08==1)                                                      
* Employees     (s4aq07==4 | s4aq08==4)   
tempfile sect4
use "${input}\HH_SEC_4.dta", clear

* Define as non agricultural labourers those with income info but without info on hours/months/relationship
* They do not inform their labour relationship at first, but then they inform incomes associated to a particular labour relationship
replace s4aq08 = 1			if  s4aq02==. & s4aq03==. & s4aq04==. & s4bq01==1
replace s4aq08 = 4			if  s4aq02==. & s4aq03==. & s4aq04==. & s4bq08!=. & s4bq08!=0
replace s4aq08 = 4			if  s4aq02==. & s4aq03==. & s4aq04==. & s4bq09!=. & s4bq09!=0

* Erasing 348 cases with missings in most relevant variables 
drop if  s4aq02==. & s4aq03==. & s4aq04==. & s4aq07==. & s4aq08==.  						

* Correcting inconsistencias in labour relationship (reports a relationship but declares income in other relationship)
replace s4aq07 = 1			if  s4aq06==1 & s4aq07!=1 & s4aq07!=4 & s4bq01==1 & s4bq02c>0 & s4bq02c<. 	
replace s4aq07 = 4			if  s4aq06==1 & s4aq07!=1 & s4aq07!=4 & s4bq01==2 &  s4bq08>0 & s4bq08<. 	
replace s4aq07 = 4			if  s4aq06==1 & s4aq07!=1 & s4aq07!=4 & s4bq01==2 &  s4bq09>0 & s4bq09<. 	

replace s4aq08 = 1			if  s4aq06==2 & s4aq08!=1 & s4aq08!=4 & s4bq01==1 & s4bq02c>0 & s4bq02c<. 	
replace s4aq08 = 4			if  s4aq06==2 & s4aq08!=1 & s4aq08!=4 & s4bq01==2 &  s4bq08>0 & s4bq08<. 	
replace s4aq08 = 4			if  s4aq06==2 & s4aq08!=1 & s4aq08!=4 & s4bq01==2 &  s4bq09>0 & s4bq09<. 	

* Correcting inconsistencies among day labourers and employees
replace s4aq07 = 4			if  s4aq07==1 & s4bq02c==. & s4bq05a==. & ((s4bq08>0 & s4bq08<.) |  (s4bq09>0 & s4bq09<.))
replace s4aq08 = 4			if  s4aq08==1 & s4bq02c==. & s4bq05a==. & ((s4bq08>0 & s4bq08<.) |  (s4bq09>0 & s4bq09<.))
replace s4aq07 = 1			if  s4aq07==4 & s4bq08==. & s4bq09==. & ((s4bq02c>0 & s4bq02c<.) | (s4bq05a>0 & s4bq05a<.))
replace s4aq08 = 1			if  s4aq08==4 & s4bq08==. & s4bq09==. & ((s4bq02c>0 & s4bq02c<.) | (s4bq05a>0 & s4bq05a<.))

replace s4bq02c = .	if  s4bq02c==0
replace s4bq05b = .	if  s4bq05b==0
replace s4bq08 = .	if  s4bq08==0
replace s4bq09 = .	if  s4bq09==0

keep if s4aq08==1 | s4aq07==1 | s4aq08==4 | s4aq07==4
gen  idp = indid

*******************************************************************************************************************************
****** 1 - CALCULATE MEDIANS  
	
*** A - By stratum and industry
foreach var in s4aq02 s4aq03 s4bq02c s4bq05b s4bq08 s4bq09 {
	gen medstr`var' = .
	}
levelsof stratum16, 	local(strat)
levelsof s4aq01c, 	local(industry)
foreach var in s4aq02 s4aq03 s4bq02c s4bq05b s4bq08 s4bq09 {
			foreach s of local strat {
				foreach i of local industry {
					qui sum `var' [aw=hhwgt] 				if  stratum16==`s' & s4aq01c==`i' & `var'!=0, detail
					qui replace medstr`var' = r(p50) 		if  stratum16==`s' & s4aq01c==`i' & medstr`var'==.
					}
				}
			}

*** B - By urban/rural and industry		 
foreach var in s4aq02 s4aq03 s4bq02c s4bq05b s4bq08 s4bq09 {
	gen medur`var' = .
	}
levelsof urbrural, 	local(strat)
levelsof s4aq01c, 		local(industry)	  	 
foreach var in s4aq02 s4aq03 s4bq02c s4bq05b s4bq08 s4bq09 {
	 	    foreach s of local strat {
	            foreach i of local industry {
				    qui sum `var' [aw=hhwgt] 				if  urbrural==`s' & s4aq01c==`i' & `var'!=0, detail
		            qui replace medur`var' = r(p50) 			if  urbrural==`s' & s4aq01c==`i' & medur`var'==.
					}
				} 
			}
	  	   	  
*** C - By industry
foreach var in s4aq02 s4aq03 s4bq02c s4bq05b s4bq08 s4bq09 {
	gen medcnt`var' = .
	}
levelsof s4aq01c, 		local(industry)	 
foreach var in s4aq02 s4aq03 s4bq02c s4bq05b s4bq08 s4bq09 {
	  	    foreach i of local industry {
				qui sum `var' [aw=hhwgt] 				if  s4aq01c==`i' & `var'!=0, detail
				replace medcnt`var' = r(p50) 			if  medcnt`var'==.
				}
			}
   
   
****** 2 - COUNT NUMBER OF OBS WITHIUT MISSINGS AND ZERIOS BY STRATUM, URBAN AND RURAL, AND INDUSTRY 		
foreach var in s4aq02 s4aq03 s4bq02c s4bq05b s4bq08 s4bq09 {
	bysort stratum16 s4aq01c:  egen countstratum16`var'	= count(`var') 	if  `var'!=0
	bysort urbrural  s4aq01c:  egen countarea`var'  	= count(`var') 	if  `var'!=0
	}
	  
 	
****** 3 - We impute the MEDIAN values at different levels. We start from the lowest (stratum) to the highest level (national)
noi di as error "Replacing missing values by stratum median values per industry"	
replace s4bq02c = medstrs4bq02c 		if (s4aq07==1 | s4aq08==1) & s4bq02c==. & s4bq01==1 & countstratum16s4bq02c>30
replace s4bq02c = medstrs4bq02c 		if (s4aq07==1 | s4aq08==1) & s4bq02c==. & s4bq01!=1 & countstratum16s4bq02c>30
replace s4bq05b = medstrs4bq05b 		if (s4aq07==1 | s4aq08==1) & s4bq05b==. & s4bq03==1 & countstratum16s4bq05b>30
replace  s4bq08 = medstrs4bq08 		if (s4aq07==4 | s4aq08==4) & s4bq08==.  & s4bq01==2 & countstratum16s4bq08>30
replace  s4bq08 = medstrs4bq08 		if (s4aq07==4 | s4aq08==4) & s4bq08==.  & s4bq01!=1 & countstratum16s4bq08>30
replace  s4bq09 = medstrs4bq09 		if (s4aq07==4 | s4aq08==4) & s4bq09==.  & s4bq03==1 & countstratum16s4bq09>30
replace  s4aq02 = medstrs4aq02 		if  s4aq02==. & countstratum16s4bq08>30
replace  s4aq03 = medstrs4aq03 		if  s4aq03==. & countstratum16s4bq09>30
noi di as error "Replacing missing values by urban/rural median values per industry"	
replace s4bq02c = medurs4bq02c 		if (s4aq07==1 | s4aq08==1) & s4bq02c==. & s4bq01==1 & countareas4bq02c>30
replace s4bq02c = medurs4bq02c 		if (s4aq07==1 | s4aq08==1) & s4bq02c==. & s4bq01!=1 & countareas4bq02c>30
replace s4bq05b = medurs4bq05b 		if (s4aq07==1 | s4aq08==1) & s4bq05b==. & s4bq03==1 & countareas4bq05b>30
replace  s4bq08 = medurs4bq08 		if (s4aq07==4 | s4aq08==4) & s4bq08==.  & s4bq01==2 & countareas4bq08>30
replace  s4bq08 = medurs4bq08 		if (s4aq07==4 | s4aq08==4) & s4bq08==.  & s4bq01!=1 & countareas4bq08>30
replace  s4bq09 = medurs4bq09 		if (s4aq07==4 | s4aq08==4) & s4bq09==.  & s4bq03==1 & countareas4bq09>30
replace  s4aq02 = medurs4aq02 		if  s4aq02==. & countareas4bq08>30
replace  s4aq03 = medurs4aq03 		if  s4aq03==. & countareas4bq09>30
noi di as error "Replacing missing values by country median values per industry"	
replace s4bq02c = medcnts4bq02c 		if (s4aq07==1 | s4aq08==1) & s4bq02c==. & s4bq01==1 
replace s4bq02c = medcnts4bq02c 		if (s4aq07==1 | s4aq08==1) & s4bq02c==. & s4bq01!=1 
replace s4bq05b = medcnts4bq05b 		if (s4aq07==1 | s4aq08==1) & s4bq05b==. & s4bq03==1 
replace  s4bq08 = medcnts4bq08 		if (s4aq07==4 | s4aq08==4) & s4bq08==.  & s4bq01==2 
replace  s4bq08 = medcnts4bq08 		if (s4aq07==4 | s4aq08==4) & s4bq08==.  & s4bq01!=1 
replace  s4bq09 = medcnts4bq09 		if (s4aq07==4 | s4aq08==4) & s4bq09==.  & s4bq03==1 
replace  s4aq02 = medcnts4aq02 		if  s4aq02==. 
replace  s4aq03 = medcnts4aq03 		if  s4aq03==. 
replace  s4aq02 = round(s4aq02)
replace  s4aq03 = round(s4aq03)

*******************************************************************************************************************************

* Monthly Income of those working as day labourers
* s4bq02c: What was the (average) daily wage in cash in the past 12 months? (TAKA)
* s4bq05b: How much did you receive in-kind per day? (TAKA)
*  s4aq03: On average, how many days per month did you work?
*  s4aq02: How many months did you do this activity in the last 12 months?
replace s4bq01 = 1								if  (s4aq07==1 | s4aq08==1) & s4bq02c>0 & s4bq02c<. & s4bq01!=1

gen daylab_cash = s4bq02c * s4aq03 * (s4aq02/12)	if  s4bq01==1 	
gen daylab_kind = s4bq05b * s4aq03 * (s4aq02/12)	if  s4bq01==1 & s4bq03==1

* Monthly Income of those working as employees
* s4bq08: What is your total net take-home monthly remuneration after all deduction at source?
* s4bq08: What is the total value of in-kind or other benefits you received over the past 12 months?
gen     employee_cash = s4bq08						if  s4bq01==2
replace employee_cash = s4bq08						if (s4aq07==4 | s4aq08==4) & employee_cash==. & s4bq08!=0 & s4bq08!=.
gen 	employee_kind = s4bq09/12					if  s4bq01==2
replace employee_kind = s4bq09/12					if (s4aq07==4 | s4aq08==4) & employee_kind==. & s4bq09!=0 & s4bq09!=.

order  hhid idp activity
sort   hhid idp activity
drop   indid activity s4aq05a s4aq05b s4bq01 s4bq02a s4bq02b s4bq02c s4bq03 s4bq04 s4bq05a s4bq05b s4bq07 s4bq08 s4bq09    
save `sect4'


**** INCOMES FROM SECTION 5: NON-AGRICULTURAL BUSINESSES                                               
* Self-Employed (s4aq08==2)                                                         
* Employers     (s4aq08==3) 
tempfile section4
tempfile sect5
tempfile section5
tempfile section5_1
tempfile section5_2
tempfile section5_2aux
tempfile section5_3

* Preparation of Section 4 (to be merged with Section 5)
use "${input}\HH_SEC_4.dta", clear
keep if s4aq08==2 | s4aq08==3
gen  idp = indid

* Keeping the activity with the most worked hours
gen  hours = s4aq02 * s4aq03 * s4aq04
egen aux_hours = sum(hours), by(hhid idp)
egen max_hours = max(hours), by(hhid idp)
drop if hours!=max_hours
duplicates tag hhid idp, gen(tag)
drop if (hhid==83018  | hhid==736087  | hhid==880116  | hhid==1564108) & tag==1						// NO INFO IN SECTION 5
drop if (hhid==212076 | hhid==390055  | hhid==1129036 | hhid==1315093 | hhid==1927070) & activity==1	// HIGHER PROFIT IN SECTION 5
drop if (hhid==885054 | hhid==1248119 | hhid==1381017 | hhid==1472017 | hhid==2139098) & activity==2	// HIGHER PROFIT IN SECTION 5
drop if (hhid==1475040) & activity==4																	// HIGHER PROFIT IN SECTION 5
replace hours = aux_hours

* Share of individual hours in household hours
egen hours_hh = sum(hours), by(hhid)
gen  share_ind = hours/hours_hh
order hhid idp 
sort  hhid idp 
drop  indid activity s4aq05a s4aq05b s4bq01 s4bq02a s4bq02b s4bq02c s4bq03 s4bq04 s4bq05a s4bq05b s4bq07 s4bq08 s4bq09 max_hours tag  hours_hh aux_hours
save `section4'


* FOR THOSE WITH INCOME INFO AND MATCHING EMPLOYMENT INFO
use "${input}\HH_SEC_5.dta", clear
drop if s5q20==.
* Total Non-Agricultural Income by Activity
* s5q20: Net revenues over the past 12 months?
* s5q07: What share of profit is owned by household?
gen month_nonagri = (s5q20 * (s5q07/100)) / 12
collapse (sum) month_nonagri, by(hhid)
sort hhid
save `section5'	

use  `section4'	
sort  hhid idp
merge m:1 hhid using `section5'

* Save info for those with income info but without employment info
preserve
tempfile only_income_info
keep if _merge==2 
keep hhid month_nonagri
sort hhid
save `only_income_info'	
restore

replace month_nonagri = month_nonagri*share_ind
drop if _merge==2
gen   x1 = 1	if  _merge==1
drop _merge
sort  hhid idp
save `section5_1'	

* FOR THOSE WITH INCOME INFO BUT WITHOUT MATCHING EMPLOYMENT INFO
use "${input}\HH_SEC_5.dta", clear
drop if s5q20==.
sort hhid
merge m:1 hhid using `only_income_info'
drop if _merge!=3
drop _merge 
keep if s5q00==1
keep hhid s5q01b month_nonagri
sort hhid
save    `section5_2aux'

use "${input}\HH_SEC_4.dta", clear
gen  idp = indid
drop if s4aq08==2 | s4aq08==3

gen hours = s4aq02 * s4aq03 * s4aq04
collapse (sum) hours, by(hhid idp)
egen share_tot = sum(hours), by(hhid)
gen  share_ind = hours/share_tot
sort hhid idp
merge m:1 hhid using `section5_2aux'	

* Save info for those with income info but without employment info
preserve
keep if _merge==2 
keep hhid s5q01b month_nonagri
sort hhid
tempfile only_income_info_2
save `only_income_info_2'	
restore

replace month_nonagri = month_nonagri*share_ind
drop if _merge!=3
drop _merge
keep  hhid idp s5q01b month_nonagri
order hhid idp s5q01b month_nonagri
sort hhid idp
gen  x2 = 1
save `section5_2'	

* FOR THOSE WITH INCOME INFO BUT WITHOUT EMPLOYMENT INFO AT ALL
use `roster', clear
merge m:1 hhid using `only_income_info_2'
drop if _merge!=3
drop if s1aq02!=1
drop _merge
keep hhid idp s5q01b month_nonagri
gen  x3 = 1
sort hhid idp
save `section5_3'

* Append Section 5
use          `section5_1'
append using `section5_2'
append using `section5_3'	

gen     anomalies = 1	if  x1==1
replace anomalies = 2	if  x2==1
replace anomalies = 3    if  x3==1
drop x*
sort hhid idp
save    `sect5'


**** INCOMES FROM SECTION 7: AGRICULTURAL ACTIVITIES
* Self-Employed (s4aq07==2)
* Employers     (s4aq07==3)
tempfile section7
tempfile section4
use "${input}\HH_SEC_4.dta", clear
keep if s4aq07==2 | s4aq07==3
gen  idp = indid

* Keeping the activity with the most worked hours
gen  hours = s4aq02 * s4aq03 * s4aq04
egen aux_hours = sum(hours), by(hhid idp)
egen max_hours = max(hours), by(hhid idp)
drop if hours!=max_hours
duplicates tag hhid idp, gen(tag)
drop if tag==2 & activity>1
drop if tag==1 & activity>2
drop tag
duplicates tag hhid idp, gen(tag)
drop if activity==2 & tag==1
duplicates report
replace hours = aux_hours

* Share of individual hours in household hours
egen hours_hh = sum(hours), by(hhid)
gen  share_ind = hours/hours_hh
order hhid idp 
sort  hhid idp 
drop  s4aq05a s4aq05b s4bq02a s4bq02b indid s4bq07 s4bq08 s4bq09 s4bq02c s4bq05b s4bq01 s4bq03 s4bq04 s4bq05a max_hours tag activity hours_hh aux_hours
save `section4'


**** Section 7B  - CROP PRODUCTION at household/crop level
tempfile section7b
use "${input}\HH_SEC_7B.dta", clear
keep if  s7bq02==1
* s7bq04a: How much in total of crop did you produce in the last 12 months? (kg)
* s7bq04b: How much in total of crop did you produce in the last 12 months? (taka/kg)
*  s7bq05: How much did your household consumed in the last 12 months?
*  s7bq06: How much did your household sell in the last 12 months?
replace s7bq05 = s7bq05_r		if (s7bq05_r!=0 & s7bq05_r!=.) 
replace s7bq06 = s7bq06_r		if (s7bq06_r!=0 & s7bq06_r!=.) 
replace s7bq04b = .			if  s7bq04b==999 | s7bq04b<=0

******************************************************************************************************************
* Rural variable	 
gen rural = (urbrural==1)

****** 1 - We found outliers in the unit values (s7bq04b) that were affecting the gini. 

* When s7bq04a>0 and the unit value is zero we replace these values for missing and we use the medians to impute those prices
gen 	p = s7bq04b
replace p = . 		if  (s7bq04a>0 & s7bq04a~=.) & p==0
gen   lnp = ln(p) 
	

* A - Identify and replace outliers as missings
levelsof s7bq00, local (crop) 	
foreach f of local crop {
			sum p [aw=hhwgt] 	if  s7bq00==`f', detail	

			* When the variance of p exists and is different from zero we detect and delete outliers
			if r(Var)!=0 & r(Var)<. {
					levelsof stratum16, local(strat)
					foreach s of local strat {
							sum p [aw=hhwgt] 	if  p>0 & p<. & stratum16==`s' & s7bq00==`f'
							local antp = r(N)
							sum lnp [aw=hhwgt] if  stratum16==`s' & s7bq00==`f', detail
							local ameanp = r(mean)
							local asdp   = r(sd)			
      						replace p = . 		if (abs((lnp-`ameanp')/`asdp')>3.5 & ~mi(lnp)) & stratum16==`s' & s7bq00==`f'
							count if p>0 & ~mi(p) & stratum16==`s' & s7bq00==`f'
							local postp = r(N)
							}
					}
			}
gen outlier = (p==.)

* B - Count number of observations without outliers
bysort stratum16 s7bq00: egen countstratum16 = count(p)
bysort rural    s7bq00: egen countarea  = count(p)	
	
* C - Calculate medians 

* By stratum and crop	
levelsof stratum16, local(strat)
levelsof s7bq00,   local(crop)
gen medianstratum = . 
foreach s of local strat {
				foreach f of local crop {
					sum p [aw=hhwgt] 				if  stratum16==`s' & s7bq00==`f' & p!=0, detail
					replace medianstratum = r(p50) 	if  stratum16==`s' & s7bq00==`f' & medianstratum==.
					}
				}		
		
* By urban/rural and crop		 
levelsof rural,  local(strat)
levelsof s7bq00, local(crop)
gen medianarea = . 
foreach s of local strat {
				foreach f of local crop {
					sum p [aw=hhwgt] 				if  rural==`s' & s7bq00==`f' & p!=0, detail
					replace medianarea = r(p50) 		if  rural==`s' & s7bq00==`f' & medianarea==.
					}
				}

* By country and crop
levelsof s7bq00, local(crop)
gen mediancountry =.
foreach f of local crop {
				sum p [aw=hhwgt] 					if  s7bq00==`f' & p!=0, detail
				replace mediancountry = r(p50) 
				}
	  

* C - We impute the MEDIAN values at different levels. We start from the lowest (stratum) to the highest level (national)	
noi di as error "Replacing outliers by stratum median price per s7bq00"	
replace p = medianstratum 		if  p==. & countstratum16>30
noi di as error "Replacing outliers by area median price per s7bq00"	
replace p = medianarea 			if  p==. & countarea>30
noi di as error "Replacing outliers by country median price per s7bq00"	
replace p = mediancountry 		if  p==. 
******************************************************************************************************************
replace s7bq04b = p

gen crop_cons = s7bq05 * s7bq04b/12	
gen crop_sold = s7bq06 * s7bq04b/12
collapse (sum) crop_cons crop_sold, by(hhid)
drop if crop_cons==0 & crop_sold==0
sort  hhid
save `section7b', replace


**** Section 7C1 - LIVESTOCK and POULTRY at household/animal level
tempfile section7c1
use "${input}\HH_SEC_7C1.dta", clear
* s7c1Q04B:  How many died/did your household sell in the last 12 months? (taka)
* s7c1Q05B:  How many did your household consume in the 12 months? (taka)
replace s7c1q04b = s7c1q04b_r		if (s7c1q04b_r!=0 & s7c1q04b_r!=.) 
replace s7c1q05b = s7c1q05b_r		if (s7c1q05b_r!=0 & s7c1q05b_r!=.) 

gen livestock_cons = s7c1q04b/12
gen livestock_sold = s7c1q05b/12
collapse (sum) livestock_cons livestock_sold, by(hhid)
drop if livestock_cons==0 & livestock_sold==0
sort  hhid
save `section7c1', replace


**** Section 7C2 - LIVESTOCK and POULTRY BY-PRODUCTS at household/by-product level
tempfile section7c2
use "${input}\HH_SEC_7C2.dta", clear
* s7c2q07b: How much did you sell in the last 12 months? (taka)
* s7c2q08b: How much did you consume in the last 12 months? (taka
replace s7c2q07b = s7c2q07b_r		if (s7c2q07b_r!=0 & s7c2q07b_r!=.) 
replace s7c2q08b = s7c2q08b_r		if (s7c2q08b_r!=0 & s7c2q08b_r!=.) 

gen byproduct_cons = s7c2q08b/12
gen byproduct_sold = s7c2q07b/12
collapse (sum) byproduct_cons byproduct_sold, by(hhid)
drop if byproduct_cons==0 & byproduct_sold==0
sort  hhid
save `section7c2', replace


**** Section 7C3 - FISH FARMING and FISH CAPTURE at household/fish level
tempfile section7c3
use "${input}\HH_SEC_7C3.dta", clear
* s7c3q11b: How much did your household sell in the past 12 months? (taka)
* s7c3q12b: How much did your household consume in the 12 months? (taka)
replace s7c3q11b = .		if  s7c3q11b==9999999

gen fish_cons = s7c3q12b/12
gen fish_sold = s7c3q11b/12
collapse (sum) fish_cons fish_sold, by(hhid)
drop if fish_cons==0 & fish_sold==0
sort  hhid
save `section7c3', replace


**** Section 7C4 - FARM FORESTRY at household/tree level
tempfile section7c4
use "${input}\HH_SEC_7C4.dta", clear
*  s7c4q15: How much did your household sell in the last 12 months? (taka)
*  s7c4q16: How much did your household consume in the last 12 months? (taka

gen tree_cons = s7c4q16/12
gen tree_sold = s7c4q15/12
collapse (sum) tree_cons tree_sold, by(hhid)
drop if tree_cons==0 & tree_sold==0
sort  hhid
save `section7c4', replace


**** Section 7D - EXPENSES ON AGRICULTURAL INPUTS at household/input level
tempfile section7d
use "${input}\HH_SEC_7D.dta", clear
keep	if  s7dq02b>=0 & s7dq02b<999999

* s7dq02b: How much did your household spend on the (item) in the last 12 months? (Taka)
gen     agri_expenditure = s7dq02b/12
replace agri_expenditure = agri_expenditure*(-1)
collapse (sum) agri_expenditure, by(hhid)
drop if agri_expenditure==0
sort  hhid
save `section7d', replace


**** Section 7E - AGRICULTURAL ASSETS
tempfile section7e
use "${input}\HH_SEC_7E.dta", clear
gen agri_asset_inc = s7eq04/12 	if  s7eq00~=420
collapse (sum) agri_asset_inc, by(hhid)
drop if agri_asset_inc==0
sort hhid
save `section7e', replace


use  `section7b', clear
merge 1:1 hhid using `section7c1'
drop _merge
sort  hhid
merge 1:1 hhid using `section7c2'
drop _merge
sort  hhid
merge 1:1 hhid using `section7c3'
drop _merge
sort  hhid
merge 1:1 hhid using `section7c4'
drop _merge
sort  hhid
merge 1:1 hhid using `section7d'
drop _merge
sort  hhid
egen agri_income = rsum(crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold), missing

gen     type_agri = 1	if  agri_income==.					/* no agricultural income, but agricultural expenditure		*/
replace type_agri = 2	if  agri_expend==.					/* no agricultural expenditure, but agricultural income 	*/
replace type_agri = 3	if  agri_income!=. & agri_expend!=.	/* both agricultural income and agricultural expenditure 	*/

egen  agri_net = rsum(agri_income agri_expend), missing

keep  hhid agri_net agri_income agri_expend crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold
order hhid agri_net agri_income agri_expend crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold
sort  hhid
save `section7'	


* FOR THOSE WITH INCOME INFO AND MATCHING EMPLOYMENT INFO
tempfile section7_1
use  `section4'	
sort  hhid idp
merge m:1 hhid using `section7'

* Save info for those with income info but without employment info
preserve
keep if _merge==2 
keep hhid agri_net agri_income agri_expend crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold
sort hhid
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
order hhid idp agri_net agri_income agri_expend crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold 
sort  hhid idp
save `section7_1'	


* FOR THOSE WITH INCOME INFO BUT WITHOUT MARCHING EMPLOYMENT INFO
tempfile section7_2
use "${input}\HH_SEC_4.dta", clear
gen  idp = indid
drop if s4aq07==2 | s4aq07==3
gen hours = s4aq02 * s4aq03 * s4aq04
collapse (sum) hours, by(hhid idp)
egen share_tot = sum(hours), by(hhid)
gen  share_ind = hours/share_tot
keep hhid idp share_ind
sort hhid idp
merge m:1 hhid using `only_income_info3'	

* Save info for those with income info but without employment info
preserve
keep if _merge==2 
keep hhid agri_net agri_income agri_expend crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold
sort hhid
tempfile only_income_info_4
save `only_income_info_4'	
restore

local lista "agri_net agri_income agri_expend crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold"
foreach income in `lista' {
	replace `income' = `income'*share_ind
	}
drop if _merge!=3
drop    _merge

keep  hhid idp agri_net agri_income agri_expend crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold share_ind
order hhid idp agri_net agri_income agri_expend crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold share_ind
sort  hhid idp
gen   x2=1
save `section7_2'	


* FOR THOSE WITH INCOME INFO BUT WITHOUT EMPLOYMENT INFO AT ALL
use `roster', clear
merge m:1 hhid using `only_income_info_4'
drop if _merge!=3
drop if s1aq02!=1
drop _merge
keep hhid idp agri_net agri_income agri_expend crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold
gen  x3 = 1
sort hhid idp

tempfile section7_3
save `section7_3'


* APPEND SECTION 7
use          `section7_1'
append using `section7_2'	
append using `section7_3'	

gen     anomalies2 = 4	if  x1==1
replace anomalies2 = 5	if  x2==1
replace anomalies2 = 6	if  x3==1
drop x*
sort hhid idp
tempfile sect7
save    `sect7'


* APPEND SECTIONS 4-5-7
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
gen 	w_cat = 1 				if  s4aq07==1 | s4aq08==1
replace w_cat = 2 				if  s4aq07==2 | s4aq08==2
replace w_cat = 3 				if  s4aq07==3 | s4aq08==3
replace w_cat = 4 				if  s4aq07==4 | s4aq08==4 

* Worked Hours (Year)
capture drop hours
gen     hours = s4aq02 * s4aq03 * s4aq04

* Worked Months
gen     months = s4aq02

* Industry
replace s4aq01c = s5q01b			if  s4aq01c==.
replace s4aq01c = 1				if  anomalies==5 | anomalies==6

egen    income = rsum(daylab_cash daylab_kind employee_cash employee_kind month_nonagri agri_net), missing
replace income = income*(-1)

local var "w_cat hours months s4aq01b s4aq01c s4bq06 daylab_cash daylab_kind employee_cash employee_kind month_nonagri agri_net anomalies"
foreach v in `var' {
	rename `v' `v'_
	}
sort hhid idp income
by   hhid idp: gen act = _n				   

keep  hhid idp w_cat 	hours months s4aq01b s4aq01c s4bq06 daylab_cash daylab_kind employee_cash employee_kind month_nonagri agri_net act anomalies share_ind
order hhid idp w_cat 	hours months s4aq01b s4aq01c s4bq06 daylab_cash daylab_kind employee_cash employee_kind month_nonagri agri_net act anomalies share_ind
reshape wide      w_cat 	hours months s4aq01b s4aq01c s4bq06 daylab_cash daylab_kind employee_cash employee_kind month_nonagri agri_net anomalies share_ind, j(act) i(hhid idp)

label   define worker 1 Daily 2 SelfEmployed 3 Employer 4 Employee 
label   values  w_cat_1 worker
label   values  w_cat_2 worker
label   values  w_cat_3 worker
label   values  w_cat_4 worker

forvalues t = 1(1)10 {
label var hours_`t' 				"Yearly Hours of work in activity `t'"
label var months_`t' 			"Months of work in activity `t'"
label var w_cat_`t' 				"Employment Category - Activity `t'"
label var s4aq01c_`t' 			"Industry Code - Activity `t'"
label var s4aq01b_`t' 			"Occupation Code - Activity `t'"
label var s4bq06_`t' 			"Sector of Occupation - Activity `t'"
label var daylab_cash_`t' 		"Monthly income (CASH) of daily labourers (taka) - Activity `t'"
label var daylab_kind_`t' 		"Monthly income (IN-KIND) of daily labourers (taka) - Activity `t'"
label var employee_cash_`t' 		"Monthly income (CASH) of employees (taka) - Activity `t'"
label var employee_kind_`t' 		"Monthly income (KIND) of employees (taka) - Activity `t'"
label var month_nonagri_`t' 		"Monthly income in non-agricultural activities as self-employed or employer (taka) - Activity `t'"
label var agri_net_`t' 			"Monthly income in agricultural activities as self-employed or employer (taka) - Activity `t'"
}
tempfile sect_4_5_7
sort hhid idp
save `sect_4_5_7'

use `roster', clear
merge 1:1 hhid idp using `sect_4_5_7'
drop if _merge==2
drop _merge
tempfile sect_4_5_7
sort hhid idp

local var "daylab_cash_ daylab_kind_ employee_cash_ employee_kind_ month_nonagri_ agri_net_"
foreach income in `var' {
	forvalues j = 1(1)10 {
	replace `income'`j' = .	if `income'`j'==0
	}
	}
drop employee_cash_5 employee_kind_5 employee_cash_6 employee_kind_6 employee_cash_7 employee_kind_7 employee_cash_8 employee_kind_8 employee_cash_9 employee_kind_9 employee_cash_10 employee_kind_10
drop daylab_cash_9 daylab_kind_9 daylab_cash_10 daylab_kind_10
drop agri_net_5 agri_net_6 agri_net_7 agri_net_8 agri_net_9 agri_net_10
drop month_nonagri_5 month_nonagri_6 month_nonagri_7 month_nonagri_8 month_nonagri_9 month_nonagri_10
save `sect_4_5_7'


**** Section 8 - OTHER INCOME 
tempfile sect8
use "${input}\HH_SEC_8B.dta", clear
keep hhid s8bq01 s8bq02 s8bq03a s8bq03b s8bq03c s8bq04 s8bq05 s8bq06 s8bq07 s8bq08 s8bq09 s8bq11 s8bq12 s8bq13

unab xvars: s8bq01 s8bq02 s8bq03a s8bq03b s8bq03c s8bq04 s8bq05 s8bq06 s8bq07 s8bq08 s8bq09 s8bq11 s8bq12 s8bq13
foreach x of local xvars { 
    replace `x' = `x'/12
}
keep hhid s8bq01 s8bq02 s8bq03a s8bq03b s8bq03c s8bq04 s8bq05 s8bq06 s8bq07 s8bq08 s8bq09 s8bq11 s8bq12 s8bq13
sort hhid
save `sect8'

use `sect_4_5_7'
merge m:1 hhid using `sect8'
drop _merge

unab xvars: s8bq01 s8bq02 s8bq03a s8bq03b s8bq03c s8bq04 s8bq05 s8bq06 s8bq07 s8bq08 s8bq09 s8bq11 s8bq12 s8bq13
foreach x of local xvars { 
    replace `x' = . 	if  s1aq02!=1
	replace `x' = .		if  `x'==0
	}
sort hhid idp
tempfile sect_4_5_7_8
save `sect_4_5_7_8'


**** Section 9 - HOUSING RENT 
tempfile sect9
use "${input}\HH_SEC_9D2.dta", clear
keep  if  s9d2q00==392
duplicates report hhid
gen   housing_rent = s9d2q01/12
sort  hhid
save `sect9', replace

use `sect_4_5_7_8'
merge m:1 hhid using `sect9'
drop _merge
sort  hhid idp

merge m:1 hhid using `section7e'
drop _merge
sort  hhid idp

tempfile sect_4_5_7_8_9
save    `sect_4_5_7_8_9'


**** Section 1C - SAFETY NETS
tempfile sect1
use "${input}\HH_SEC_1C.dta", clear
keep  	if s1cq01==1
replace s1cq02 = 88		if  s1cq02==.
drop    if s1cq02==0

gen   idp = indid
order hhid idp

*  S1CQ10A: How much did you receive in cash in last 12 months?
* S1CQ101D: How much did you receive in-kind in last 12 months? 1
* S1CQ102D: How much did you receive in-kind in last 12 months? 2

* Correcting amounts of some cash transfers
* OLD-AGE ALLOWANCE
replace s1cq10a = 1200			if  s1cq02==7 &    s1cq10a>0 & s1cq10a<1200
replace s1cq10a = 1200			if  s1cq02==7 & s1cq10a>1200 & s1cq10a<1800
replace s1cq10a = 2400			if  s1cq02==7 & s1cq10a>1800 & s1cq10a<2400
replace s1cq10a = 2400			if  s1cq02==7 & s1cq10a>2400 & s1cq10a<3000
replace s1cq10a = 3600			if  s1cq02==7 & s1cq10a>3000 & s1cq10a<3600
replace s1cq10a = 3600			if  s1cq02==7 & s1cq10a>3600 & s1cq10a<4200
replace s1cq10a = 3600			if  s1cq02==7 & s1cq10a>4200 & s1cq10a<4800
replace s1cq10a = 3600			if  s1cq02==7 & s1cq10a>4800 & s1cq10a<.

* WIDOWS ALLOWANCE
replace s1cq10a = 1200			if  s1cq02==8 &    s1cq10a>0 & s1cq10a<1200
replace s1cq10a = 1200			if  s1cq02==8 & s1cq10a>1200 & s1cq10a<1800
replace s1cq10a = 2400			if  s1cq02==8 & s1cq10a>1800 & s1cq10a<2400
replace s1cq10a = 2400			if  s1cq02==8 & s1cq10a>2400 & s1cq10a<3000
replace s1cq10a = 3600			if  s1cq02==8 & s1cq10a>3000 & s1cq10a<3600
replace s1cq10a = 3600			if  s1cq02==8 & s1cq10a>3600 & s1cq10a<4200
replace s1cq10a = 3600			if  s1cq02==8 & s1cq10a>4200 & s1cq10a<4800
replace s1cq10a = 3600			if  s1cq02==8 & s1cq10a>4800 & s1cq10a<.

* DISABLED ALLOWANCE
replace s1cq10a = 1500			if  s1cq02==15 &    s1cq10a>0 & s1cq10a<1500
replace s1cq10a = 1500			if  s1cq02==15 & s1cq10a>1500 & s1cq10a<2250
replace s1cq10a = 3000			if  s1cq02==15 & s1cq10a>2250 & s1cq10a<3000
replace s1cq10a = 3000			if  s1cq02==15 & s1cq10a>3000 & s1cq10a<3750
replace s1cq10a = 4500			if  s1cq02==15 & s1cq10a>3750 & s1cq10a<4500
replace s1cq10a = 4500			if  s1cq02==15 & s1cq10a>4500 & s1cq10a<5250
replace s1cq10a = 6000			if  s1cq02==15 & s1cq10a>5250 & s1cq10a<6000
replace s1cq10a = 6000			if  s1cq02==15 & s1cq10a>6000 & s1cq10a<.


replace  s1cq10a = .							if  s1cq10a==0
replace  s1cq10a = s1cq10a/12
replace s1cq101d = .							if  s1cq101d==0
replace s1cq101d = s1cq101d/12
replace s1cq102d = .							if  s1cq102d==0
replace s1cq102d = s1cq102d/12
drop if s1cq10a==. & s1cq101d==. & s1cq102d==.

egen    ssn_cash = rsum(s1cq10a), missing
egen	ssn_kind = rsum(s1cq101d s1cq102d), missing

* Last payment
gen  	snet_cash_last = s1cq05a/12
egen 	snet_kind_last = rsum(s1cq071d s1cq072d) 	if  s1cq06==1
replace snet_kind_last = snet_kind_last/12

replace ssn_cash = snet_cash_last				if (ssn_cash==. | ssn_cash==0) & snet_cash_last>0 & snet_cash_last<.
replace ssn_kind = snet_kind_last				if (ssn_kind==. | ssn_kind==0) & snet_kind_last>0 & snet_kind_last<.

collapse (sum) ssn_cash ssn_kind, by(hhid idp s1cq02)
egen ssn = rsum(ssn_cash ssn_kind), missing
reshape wide ssn_cash ssn_kind ssn, i(hhid idp) j(s1cq02)
sort  hhid idp
save `sect1', replace

use `sect_4_5_7_8_9'
merge 1:1 hhid idp using `sect1'
drop _merge
sort  hhid idp
tempfile sect_4_5_7_8_9_1
save `sect_4_5_7_8_9_1'


**** Section 2B - EDUCATIONAL STIPEND
use "${input}\HH_SEC_2B.dta", clear
keep if s2bq04==1
keep if s2bq06>0
gen idp = indid

gen  stipend_inc = s2bq06/12
keep hhid idp stipend_inc
sort hhid idp
tempfile stipend
save `stipend', replace

use `sect_4_5_7_8_9_1'
merge 1:1 hhid idp using `stipend'
drop _merge
sort  hhid idp
tempfile income
save `income'


**** Section 1A - HOUSEHOLD AND INDIVIDUAL ROSTER (including DISABILITIES)
use "${input}\HH_SEC_1A.dta", clear
tempfile roster
ren indid idp
sort hhid idp
duplicates report idp hhid s1aq01 s1aq03 s1aq02 s1aq05 
duplicates drop idp hhid s1aq01 s1aq03 s1aq02 s1aq05, force
egen member1= count(idp), by(hhid)
drop if member1==0
drop if idp==.
save `roster', replace


**** Section 1B - EMPLOYMENT LAST WEEK/MONTH
use "${input}\HH_SEC_1B.dta", clear
tempfile employment
ren indid idp
sort hhid idp
drop if idp==.
duplicates report idp hhid
save `employment', replace
	
	
**** Section 2A - LITERACY AND ATTAINMENT
use "${input}\HH_SEC_2A.dta", clear
tempfile education_all
rename indid idp
sort hhid idp
drop if  idp==.
duplicates report hhid idp s2aq01 s2aq02 s2aq04 s2aq03
duplicates drop hhid idp s2aq01 s2aq02 s2aq04 s2aq03, force
save `education_all', replace
	
	
**** Section 2B - EDUCATION - CURRENT ENROLLMENT
use "${input}\HH_SEC_2B.dta",clear
tempfile education_current
rename indid idp	
sort hhid idp
drop if idp==.
duplicates report hhid idp s2bq01 s2bq03 s2bq02
duplicates drop hhid idp s2bq01 s2bq03 s2bq02, force
save `education_current', replace
	
	
**** Section 7C1 - ASSETS/ANIMALS
use "${input}\HH_SEC_7C1.dta", clear	
tempfile assets_animal
sort hhid
* Keep assets that are used in the harmonized variables (cow, buffalo and chicken)
keep if s7c1q00==201 | s7c1q00==204 | s7c1q00==205
keep hhid s7c1q02a s7c1q00   
replace s7c1q02a = 1 	if  s7c1q02a>=1 & s7c1q02a!=.
replace s7c1q02a = 0 	if  s7c1q02a==.
rename  s7c1q02a s7c1q02a_
reshape wide s7c1q02a_, i(hhid) j(s7c1q00)
duplicates report hhid
save `assets_animal', replace	
	
**** Sction 9E - ASSETS/MATERIALS
use "${input}\HH_SEC_9E.dta", clear
tempfile assets
drop if s9eq00==.
gen 	assets = 1 		if  s9eq01b=="X"
replace assets = 0 		if  s9eq01a=="X"
replace assets = 1 		if  s9eq02!=.
* Some cases of mismatch data (the data doesn't allows us to classify if the person has the asset)
replace assets = . 		if  s9eq01b=="X" & s9eq01a=="X"  	// Mark both Yes and No
replace assets = . 		if  s9eq01a=="X" & s9eq02!=.	 	// Mark No but have number of items
replace assets = . 		if  assets==1 & s9eq02==.		 	// Mark Yes but doesn't have the number
keep hhid assets s9eq00
* Keep assets that are used in the harmonized variables
keep if s9eq00==571 | (s9eq00>=574 & s9eq00<=579) | s9eq00==582 | s9eq00==585 |  s9eq00==586  | s9eq00==594 | s9eq00==597 | s9eq00==598 | s9eq00==599 
reshape wide assets, i(hhid) j(s9eq00)
duplicates report hhid
save `assets', replace 

	
**** CONSUMPTION
use "${input}\poverty_indicators2016.dta", clear
tempfile consumption
sort hhid
duplicates report hhid
save `consumption', replace
	
	
**** Section 6A - HOUSING
use "${input}\HH_SEC_6A.dta", clear
tempfile housing
sort hhid
duplicates report hhid
save `housing', replace
	
	
**** Section 9C - EXPENDITURES 1 (MONTHLY EXPENSES)
tempfile expenditures1
use "${input}\HH_SEC_9C.dta", clear
keep if (s9cq00>=241 & s9cq00<=249) | (s9cq00>=292 & s9cq00<=294) | s9cq00==296
collapse (sum) s9cq01 s9cq02 s9cq03, by(hhid s9cq00)
rename s9cq01 s9cq01_
rename s9cq02 s9cq02_
rename s9cq03 s9cq03_
keep hhid s9cq00 s9cq01_ s9cq02_ s9cq03_
reshape wide s9cq01_ s9cq02_ s9cq03_, j(s9cq00) i(hhid)
duplicates report hhid
sort  hhid
save `expenditures1', replace
	
	
**** Section 9D2 - EXPENDITURES 2 (ANNUAL EXPENSES)
tempfile expenditures2
use "${input}\HH_SEC_9D2.dta", clear
keep if s9d2q00>=393 & s9d2q00<=399
collapse (sum) s9d2q01, by(hhid s9d2q00)
rename s9d2q01 s9d2q01_
keep hhid s9d2q00 s9d2q01_
reshape wide s9d2q01_, j(s9d2q00) i(hhid)
duplicates report hhid
sort  hhid
save `expenditures2', replace
	
	
**** Section 7A - LAND
use "${input}\HH_SEC_7A.dta", clear
tempfile land
sort hhid
duplicates report hhid
save `land', replace
	
	
***************************************************************************************************
**** MERGE DATASETS
***************************************************************************************************
* Individual-level datasets
use `roster', clear
foreach i in employment education_all education_current income {
	merge 1:1 hhid idp using  ``i'', keep(1 3) nogen
	}
	
* Household-level datasets
foreach j in housing assets assets_animal land expenditures1 expenditures2 {
	merge m:1 hhid using ``j'', keep(1 3) nogen
	}
	
	merge m:1 hhid using `consumption', keep(3) nogen	
	
order  psu hhid idp hhwgt
sort   hhid idp
rename idp idp1
*</_Datalibweb request_>

* Combining information from SSN and Education modules
gen 	educy = .  
replace educy = 0 			if  s2aq01==2   
replace educy = 0 			if  s2aq03==2   
replace educy = s2aq04 		if  s2aq04<.
recode 	educy (11 = 12) (15 = 16) (18 = 18) (16 = 19) (17 = 17) (12 = 14) (14 = 14) (13 = 16) (19 = .) (21 = .)
replace educy = s2bq03 		if  educy==. & s2bq03!=.
replace educy = educy-1 		if (s2aq04==. & s2bq03<=11 & s2bq03!=.)
recode 	educy (10 = 11) (15 = 15) (18 = 17) (16 = 18) (17 = 16) (12 = 13) (14 = 13) (13 = 15) (19 = .) (21 = .) if (s2aq04==. & s2bq03!=.)
replace educy = 0 			if  educy==-1
replace educy = . 			if  educy==50
replace educy = . 			if (educy>s1aq03 & educy!=. & s1aq03!=.)
gen 	educat7 = .
replace educat7 = 1 			if  educy==0
replace educat7 = 2 			if  educy>0 & educy<5
replace educat7 = 3 			if  educy==5
replace educat7 = 4 			if  educy>5 & educy<12
replace educat7 = 5 			if  educy==12
replace educat7 = 7 			if  educy>12 & educy<23
replace educat7 = 6 			if  inlist(educy,13,14)
replace educat7 = 8 			if  s2aq04==19 | s2bq03==19
replace educat7 = . 			if  s1aq03<5


gen     ssn2_alt = .
replace ssn2_alt = stipend_inc			if  stipend_inc>0 & stipend_inc<. & educat>=1 & educat<=2
replace ssn2_alt = ssn2					if  ssn2_alt==. & ssn2>0 & ssn2<.

gen     ssn4_alt = .
replace ssn4_alt = stipend_inc			if  stipend_inc>0 & stipend_inc<. & educat==4
replace ssn4_alt = ssn4					if  ssn4_alt==. & ssn4>0 & ssn4<.

gen     ssn37_alt = stipend_inc 		if  ssn2_alt==. & ssn4_alt==.
drop educat7 educy


***** IMPUTATION FOOD PROGRAMS
*  3 = School feeding
* 16 = VGF
* 17 = Gratuitous relief
* 19 = GR
* 21 = Food assistance in Chittagong Hill Tracts
* 23 = Food/Cash for work
* 24 = Test relief food/cash
egen food_income_ind = rsum(ssn3 ssn16 ssn17 ssn19 ssn21 ssn23 ssn24), missing
egen food_income = sum(food_income_ind), by(hhid)

* By division/urban-rural-quintile
egen 	region = group(division_code)
replace region = 3 if region==5
replace region = 5 if region==6
replace region = 6 if region==7
replace region = 7 if region==8

* Welfare variable
sum zu16  [aw=hhwgt] 
local mean_nat = r(mean)
sum pcexp [aw=hhwgt] 
local avg = r(mean)
gen welfare = pcexp*`mean_nat'/zu16

_ebin welfare [aw=hhwgt] 	if region==1 & urbrural==1, gen(quintile_1r) nq(5) 
_ebin welfare [aw=hhwgt] 	if region==2 & urbrural==1, gen(quintile_2r) nq(5) 
_ebin welfare [aw=hhwgt] 	if region==3 & urbrural==1, gen(quintile_3r) nq(5) 
_ebin welfare [aw=hhwgt] 	if region==4 & urbrural==1, gen(quintile_4r) nq(5) 
_ebin welfare [aw=hhwgt] 	if region==5 & urbrural==1, gen(quintile_5r) nq(5) 
_ebin welfare [aw=hhwgt] 	if region==6 & urbrural==1, gen(quintile_6r) nq(5) 
_ebin welfare [aw=hhwgt] 	if region==7 & urbrural==1, gen(quintile_7r) nq(5) 

_ebin welfare [aw=hhwgt] 	if region==1 & urbrural==2, gen(quintile_1u) nq(5) 
_ebin welfare [aw=hhwgt] 	if region==2 & urbrural==2, gen(quintile_2u) nq(5) 
_ebin welfare [aw=hhwgt] 	if region==3 & urbrural==2, gen(quintile_3u) nq(5) 
_ebin welfare [aw=hhwgt] 	if region==4 & urbrural==2, gen(quintile_4u) nq(5) 
_ebin welfare [aw=hhwgt] 	if region==5 & urbrural==2, gen(quintile_5u) nq(5) 
_ebin welfare [aw=hhwgt] 	if region==6 & urbrural==2, gen(quintile_6u) nq(5) 
_ebin welfare [aw=hhwgt] 	if region==7 & urbrural==2, gen(quintile_7u) nq(5)

********************************
*** SAMPLING BENEFICIARIES   ***
********************************
forvalues i = 1(1)7 {
	forvalues j = 1(1)5	{
		sum ssn3   [w=hhwgt] 	if  quintile_`i'r==`j'
		local local1 = r(sum_w)	
		sum ssn16  [w=hhwgt] 	if  quintile_`i'r==`j'
		local local2 = r(sum_w)
		sum ssn17  [w=hhwgt] 	if  quintile_`i'r==`j'
		local local3 = r(sum_w)
		sum ssn19  [w=hhwgt] 	if  quintile_`i'r==`j'
		local local4 = r(sum_w)
		sum ssn21  [w=hhwgt] 	if  quintile_`i'r==`j'
		local local5 = r(sum_w)
		sum ssn23  [w=hhwgt] 	if  quintile_`i'r==`j'
		local local6 = r(sum_w)
		sum ssn24  [w=hhwgt] 	if  quintile_`i'r==`j'
		local local7 = r(sum_w)		
		sum quarter [w=hhwgt]    if  quintile_`i'r==`j'
		local total = r(sum_w)			
		local sample`i'r`j' = (`local1'+`local2'+`local3'+`local4'+`local5'+`local6'+`local7')*2.67/`total'	

		set seed 1978
		gen     x`i'r`j' = runiform()   if  quintile_`i'r==`j'
		replace x`i'r`j' = . 			if  x`i'r`j'>`sample`i'r`j''  

		sum ssn3   [w=hhwgt] 	if  quintile_`i'u==`j'
		local local1 = r(sum_w)	
		sum ssn16  [w=hhwgt] 	if  quintile_`i'u==`j'
		local local2 = r(sum_w)
		sum ssn17  [w=hhwgt] 	if  quintile_`i'u==`j'
		local local3 = r(sum_w)
		sum ssn19  [w=hhwgt] 	if  quintile_`i'u==`j'
		local local4 = r(sum_w)
		sum ssn21  [w=hhwgt] 	if  quintile_`i'u==`j'
		local local5 = r(sum_w)
		sum ssn23  [w=hhwgt] 	if  quintile_`i'u==`j'
		local local6 = r(sum_w)
		sum ssn24  [w=hhwgt] 	if  quintile_`i'u==`j'
		local local7 = r(sum_w)		
		sum quarter [w=hhwgt]    if  quintile_`i'u==`j'
		local total = r(sum_w)
		local sample`i'u`j' = (`local1'+`local2'+`local3'+`local4'+`local5'+`local6'+`local7')*2.67/`total'	
		
		set seed 1978
		gen     x`i'u`j' = runiform()   if  quintile_`i'u==`j'
		replace x`i'u`j' = . 			if  x`i'u`j'>`sample`i'u`j'' 		
		}
	}

egen    new_program = rsum(x*)
replace new_program = 1					if  new_program>0 & new_program<.
replace new_program = .					if  new_program==0


***************************************
*** IMPUTING BENEFITS BY HOT-DECK   ***
***************************************
replace food_income_ind =-9				if  new_program==1
gen		food_si = food_income_ind
replace food_si = 0						if  food_income_ind==.
replace food_si = .						if  food_income_ind==-9

preserve
gen copia_food = food_si
drop if food_si== 0
hotdeck_cedlas copia_food, by(region urbrural) seed(123) keep(hhid idp1 copia_food) store
restore
capture drop _merge
merge 1:1 hhid idp1 using "imp1.dta"
drop _merge 

replace new_program = copia_food/1.35 	if   new_program==1

*<_Save data file_>
compress
save "${output}/`yearfolder'_v`vm'_M.dta", replace
*</_Save data file_>

