/*------------------------------------------------------------------------------
  GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   		IND_2022_HCES_v03_M.do			   </_Program name_>
<_Application_>    		STATA 17.0							     <_Application_>
<_Author(s)_>      		tornarolli@gmail.com	          		  </_Author(s)_>
<_Date created_>   		31-07-2025	                           </_Date created_>
<_Date modified>   		04-08-2025	                          </_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        		IND											</_Country_>
<_Survey Title_>   		HCES								   </_Survey Title_>
<_Survey Year_>    		2022-2023  								</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:					04-08-2025
File:					IND_2022_HCES_v03_M.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>
clear all
set more off

local code         		"IND"
local year         		"2022"
local survey       		"HCES"
local vm           		"03"
local type         		"SARMD"
local yearfolder   		"`code'_`year'_`survey'"
global input       		"${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata"
global output      		"${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata"
*</_Program setup_>


*<_Datalibweb request_>

************************************************
**** HCES22_LVL_01: HOUSEHOLD CHARACTERISTICS 
************************************************
use "${input}\level01_2022.dta", clear 
egen hhid = concat(fsu b1q1pt11 b1q1pt12)
gen hhwt = mult/100
order hhid
save "${output}\LVL_01.dta", replace


************************************************
**** HCES22_LVL_02: HOUSEHOLD CHARACTERISTICS 
************************************************
use "${input}\level02_2022.dta", clear
egen hhid = concat(fsu b1q1pt11 b1q1pt12)
egen pid = concat(fsu b1q1pt11 b1q1pt12 b3q1)
gen pwt = mult/100
order hhid pid
save "${output}\LVL_02.dta", replace


************************************************
**** HCES22_LVL_03: HOUSEHOLD CHARACTERISTICS 
************************************************	
use "${input}\level03_2022.dta", clear
egen hhid = concat(fsu b1q1pt11 b1q1pt12)
gen hhwt = mult/100
order hhid
save "${output}\LVL_03.dta", replace


************************************************
**** HCES22_LVL_04: FOOD ITEMS 
************************************************
use "${input}\level04_2022.dta", clear 
egen hhid = concat(fsu b1q1pt11 b1q1pt12)
gen hhwt = mult/100
order hhid
save "${output}\LVL_04.dta", replace


************************************************
**** HCES22_LVL_05: FOOD ITEMS (LAST 30 DAYS)
************************************************
use "${input}\level05_2022.dta", clear
egen hhid = concat(fsu b1q1pt11 b1q1pt12)
gen hhwt = mult/100
order hhid 
save "${output}\LVL_05.dta", replace

collapse (sum) b5pt1q6, by(hhid)
tempfile level_5 
save "`level_5'"

************************************************
**** HCES22_LVL_06: FOOD ITEMS (LAST 7 DAYS) 
************************************************
use "${input}\level06_2022.dta", clear
egen hhid = concat(fsu b1q1pt11 b1q1pt12)
gen hhwt = mult/100
order hhid 
save "${output}\LVL_06.dta", replace

collapse (sum) b7pt1q4, by(hhid)

merge 1:1 hhid using "`level_5'"
keep hhid
tempfile control
save `control'


************************************************
**** HCES22_LVL_07: CONSUMABLE AND SERVICES 
************************************************
use "${input}\level07_2022.dta", clear
egen hhid = concat(fsu b1q1pt11 b1q1pt12)
gen hhwt = mult/100
order hhid
save "${output}\LVL_07.dta", replace


************************************************
**** HCES22_LVL_08: CONSUMABLES AND SERVICES 
************************************************
use "${input}\level08_2022.dta", clear
egen hhid = concat(fsu b1q1pt11 b1q1pt12)
gen hhwt = mult/100
order hhid 
save "${output}\LVL_08.dta", replace


************************************************
**** HCES22_LVL_09: CONSUMABLES AND SERVICES
************************************************
use "${input}\level09_2022.dta", clear
egen hhid = concat(fsu b1q1pt11 b1q1pt12)
gen hhwt = mult/100
order hhid 
save "${output}\LVL_09.dta", replace


************************************************
**** HCES22_LVL_10: CONSUMABLES AND SERVICES 
************************************************
use "${input}\level10_2022.dta", clear
egen hhid = concat(fsu b1q1pt11 b1q1pt12)
gen hhwt = mult/100
order hhid 
save "${output}\LVL_10.dta", replace


************************************************
**** HCES22_LVL_11: DURABLE GOODS 
************************************************
use "${input}\level11_2022.dta", clear
egen hhid = concat(fsu b1q1pt11 b1q1pt12)
gen hhwt = mult/100
order hhid
save "${output}\LVL_11.dta", replace


************************************************
**** HCES22_LVL_12: DURABLE GOODS
************************************************
use "${input}\level12_2022.dta", clear
egen hhid = concat(fsu b1q1pt11 b1q1pt12)
gen hhwt = mult/100
order hhid 
save "${output}\LVL_12.dta", replace


************************************************
**** HCES22_LVL_13: DURABLE GOODS 
************************************************
use "${input}\level13_2022.dta", clear
egen hhid = concat(fsu b1q1pt11 b1q1pt12)
gen hhwt = mult/100
order hhid
save "${output}\LVL_13.dta", replace


************************************************
**** HCES22_LVL_14: FDQ-CSQ-DGQ 
************************************************
use "${input}\level14_2022.dta", clear

egen hhid = concat(fsu b1q1pt11 b1q1pt12)
gen hhwt = mult/100
label variable ba1b1c1_1 "section code"
label variable ba1b1c1_2 "item code"	
label variable ba1b1c1_3 "value"

order hhid ba1b1c1_2 ba1b1c1_3	
save "${output}\LVL_14.dta", replace


************************************************
**** HCES22_LVL_15: HCQ-FDQ-CSQ-DGQ
************************************************	
use "${input}\level15_2022.dta", clear

egen hhid = concat(fsu b1q1pt11 b1q1pt12)
gen hhwt = mult/100

label variable section "section code"
label variable b1pt1a2b2c2 "time taken to canvass the questionnaire (in minutes)"
label variable ba2b2c2q5 "household's usual consumption expenditure in a month (in Rs.)"
label variable ba2b2c2q6 "total expenditure incurred on online purchase/payment in last 30 days"
label variable ba2b2c2q7 "informant code"
label variable ba2b2c2q8 "response code"
label variable ba2b2c2q9 "household size"

encode section, gen(section_new)
destring section_new, replace
label define sect 1 "Household characteristics" 2 "Food expenditure" 3 "Consumables and services expenditure" 4 "Durable goods expenditure" 
label values section_new "sect"
	

label define response 1 "Informant co-operative and capable" 2 "Informant co-operative but not capable" 3 "Informant busy" 4 "Informant reluctant" 9 "Others"
destring ba2b2c2q8, replace 
label values ba2b2c2q8 "response"	

order hhid section_new ba2b2c2q5 ba2b2c2q6 ba2b2c2q9 ba2b2c2q8
unique hhid section
save "${output}\LVL_15.dta", replace


**********************************************************************************
**********************************************************************************
* LVL 01:    261,746 observations (household level)
* LVL 02:  1,127,039 observations (individual level)
* LVL 03:    261,746 observations (household level) 
* LVL 04:    261,746 observations (household level) 
* LVL 05: 12,056,839 observations (item level)  			  ---> reshape  
* LVL 06:  1,637,576 observations (item level)  			  ---> reshape 
* LVL 07:    261,746 observations (household level)
* LVL 08:  1,410,652 observations (item level)  			  ---> reshape 
* LVL 09:  7,942,402 observations (item level)  			  ---> reshape 
* LVL 10:    762,523 observations (item level)  			  ---> reshape 
* LVL 11:    261,746 observations (household level)
* LVL 12:  4,410,298 observations (item level)  			  ---> reshape
* LVL 13:  4,500,902 observations (item level)  			  ---> reshape
* LVL 14:  8,075,528 observations (item level) 				  ---> reshape
* LVL 15:  1,046,984 observations (household x section level) ---> reshape

use "${output}\LVL_02.dta", clear
merge m:1 hhid using "${output}\LVL_01.dta"
drop _merge
merge m:1 hhid using "${output}\LVL_03.dta"
drop _merge
merge m:1 hhid using "${output}\LVL_04.dta"
drop _merge
merge m:1 hhid using "${output}\LVL_07.dta"
drop _merge
merge m:1 hhid using "${output}\LVL_11.dta"
drop _merge
merge m:1 hhid using `control'
drop if _merge!=3
drop _merge
merge m:1 hhid using "${output}\IND_PRIMUS_2022-23.dta", keepusing(welfaredef_final)
drop _merge 

forvalues i = 1(1)9 { 
	erase "${output}\LVL_0`i'.dta"
	} 
forvalues i = 10(1)15 { 
	erase "${output}\LVL_`i'.dta"
	} 

label variable survey "survey"
label variable year "survey year"
label variable fsu "fist sampling unit serial no."
label variable sector "rural/urban"
label variable state "state"
label variable nss_region "nss region"
label variable district "district"
label variable stratum "stratum"
label variable sub_stratum "substratum"
label variable panel "panel"
label variable sub_sample "sub sample"
label variable fod_subregion "fod subsample"
label variable b1q1pt7 "sample sub-unit no."
label variable b1q1pt10 "sample sub-division no."
label variable b1q1pt11 "second-stage stratum no."
label variable b1q1pt12 "sample household no."
label variable questionaire_no "questionnaire no."
label variable level "block level"
label variable b3q1 "person serial no"
label variable b3q3 "relation to household hold"
label variable b3q4 "gender"
label variable b3q5 "age (in years)"
label variable b3q6 "marital status"
label variable b3q7 "highest education level attained"
label variable b3q8 "total years of education completed"
label variable b3q9 "whether used internet from any location in last 30 days, applicable to >=3 years"
label variable b3q10 "no. of days away from home during last 30 days"
label variable b3q11 "no. of meals usually taken in a day"
label variable b3q12 "no. of meals taken during last 30 days from school, balwadi, etc."
label variable b3q13 "no. of meals taken during last 30 days from employers as prerequisities or part of wage"
label variable b3q14 "no. of meals received free of cost from other sources during last 30 days"
label variable b3q15 "no. of meals paid for during lat 30 days"
label variable b3q16 "no. of meals taken during last 30 days at home"
label variable b3q17 "member status"
label variable fdq "FDQ original member"
label variable mult "multiplier"
label variable hhwt "household weight"
label variable pwt "person level weights"
label variable hhid "unique household id"
label variable pid "unique individual id"
label variable b1q1pt13 "survey code"
label variable b1q1pt14 "reason for substitution"
label variable b2q2pt1 "household size"
label variable b4q4pt1 "whether any household member was engaged in economic activities during last 365 days"
label variable b4q4pt3 "NC0-2015 Code (3 digit)"
label variable b4q4pt5 "NIC-2008 Code (3 digit)"
label variable b4q4pt6 "broad activities from which maximum income was derived by the household during last 365 days"
label variable b4q4pt7 "whether major source of income from self-employment was from agricultural/non-agricultural sector"
label variable b4q4pt8 "whether the major income from regular wage/salary earning from agricultural/non-agricultural sector"
label variable b4q4pt9 "whether the major income from casual labour was from agricultural sector/non-agricultural sector"
label variable b4q4pt10 "household type"
label variable b4q4pt11 "religion of the household head"
label variable b4q4pt12 "social group of the household head (caste)"
label variable b4q4pt13 "whether the household own (owned & possessed or leased out) any land (within the country) as on the date of survey"
label variable b4q4pt14 "type of land owned"
label variable b4q4pt15 "total owned (owned and possessed or leased out) land (within the country) by the household as on the date of survey (area in acre)"
label variable b4q4pt16 "whether the household have a dwelling unit at present place of enumeration"
label variable b4q4pt17 "type of dwelling unit"
label variable b4q4pt18 "basic building material used for major portion of the wall of the dwelling unit"
label variable b4q4pt19 "basic building material used for construction of the major portion of the outer exposed part of the roof of the dwelling unit"
label variable b4q4pt20 "basic building material used for construction of the major portion of the floor of the dwelling unit"
label variable b4q4pt21 "primary source of energy of the household for cooking"
label variable b4q4pt22 "primary source of energy of the household for lighting"
label variable b4q4pt23 "source of drinking water (last 365 days)"
label variable b4q4pt24 "time taken by the household for a single trip to reach the source, obtain water and back to household (in minutes)"
label variable b4q4pt25 "type of access of the household to latrine"
label variable b4q4pt26 "type of latrine in which the household has access"
label variable b4q4pt29 "type of ration card possessed by the household as on the date of survey"
label variable b4q4pt30 "prevailing rate of rent in the locality is available (for rural only)"
label variable b4q4pt31 "benefitted from PMGKY as on the date on the survey"
label variable b4q4pt32 "any member of the household of age 0-18 years died during the period of last 5 years preceding the date of survey"
label variable b4q4pt33 "no of members of the household of age 0–18 years died during the period of last 5 years preceding the date of survey"
label variable b4pt1q411 "whether the household procured any item using the ration card during the last 30 days"
label variable b4pt14121 "rice procured using ration card during the last 30 days"
label variable b4pt14122 "wheat procured using ration card during the last 30 days"
label variable b4pt14123 "coarse grain procured using ration card during the last 30 days"
label variable b4pt14124 "sugar procured using ration card during the last 30 days"
label variable b4pt14125 "pulses procured using ration card during the last 30 days"
label variable b4pt14126 "edible oil procured using ration card during the last 30 days"
label variable b4pt14127 "other food items procured using ration card during the last 30 days"
label variable b4pt14131 "groceries purchased/paid online during the reference period"
label variable b4pt14132 "milk purchased/paid online during the reference period"
label variable b4pt14133 "vegetables purchased/paid online during the reference period"
label variable b4pt14134 "fresh fruits purchased/paid online during the reference period"
label variable b4pt14135 "dry fruits purchased/paid online during the reference period"	
label variable b4pt14136 "eggs, fish, meat purchased/paid online during the reference period"
label variable b4pt14137 "served processed food purchased/paid online during the reference period"
label variable b4pt14138 "packed processed food purchased/paid online during the reference period"
label variable b4pt14139 "other food items purchased/paid online during the reference period"
label variable b4pt1414 "ceremony performed during last 30 days"
label variable b4pt1415 "meals served to non-household members during the last 30 days"
label variable b4pt2420 "whether the household procured kerosene using ration card during last 30 days"
label variable b4pt2421_1 "whether household received subsidy on LPG cylinder during the last 3 months"
label variable b4pt2421_2 "number of subsidized LPG cylinder received during the last 3 months preceding the date of survey"
label variable b4pt2422 "whether household received free electricity during the last 30 days"
label variable b4pt2423_1 "whether any household member is attending/attended educational institution during last 365 days"
label variable b4pt2423_2 "number attending/attended government institution"
label variable b4pt2423_3 "number attending/attended private institution"
label variable b4pt24241_1 "whether any member of the household received following items free textbooks in last 365 days"
label variable b4pt24241_2	 "total no. of free textbooks received"
label variable b4pt24242_1	 "whether any member of the household received free stationary in last 365 days" 
label variable b4pt24242_2	 "total no. of free stationaries received"
label variable b4pt24243_1	 "whether any member of the household received following items free school bag in last 365 days"
label variable b4pt24243_2	 "total no. of free school bags received"
label variable b4pt24244_1	 "whether any member of the household received following other free items related to schooling in last 365 days"
label variable b4pt24244_2	 "total no. of other free items related to schooling received"
label variable b4pt2426_1	"whether any member received reimbursement/waiver of school/clg fee during last 365 days"
label variable b4pt2426_2	"number of member received reimbursement/waiver"
label variable b4pt2427_1	"one or more member beneficiary of Pradhan Mantri Jan Aarogya Yojana (Ayushman Bharat) or any other state specific public health scheme"
label variable b4pt2427_2	"number of beneficairies of Pradhan Mantri Jan Aarogya Yojana (Ayushman Bharat) or any other state specific public health scheme"
label variable b4pt2428 "whether there was any case of hospitalization in the household during last 365 days"
label variable b4pt2429_1	"one or more member received benefits of medical treatment (medical – hospitalisation) under Pradhan Mantri Jan Aarogya Yojana Card (Ayushman Bharat) or any other state specific public health scheme during the last 365 days"
label variable b4pt2429_2	"number of beneficiaries of medical treatment (medical – hospitalisation) under Pradhan Mantri Jan Aarogya Yojana Card (Ayushman Bharat) or any other state specific public health scheme during the last 365 days"
label variable b4pt2429_3	"amount received for medical treatment (medical – hospitalisation) under Pradhan Mantri Jan Aarogya Yojana Card (Ayushman Bharat) or any other state specific public health scheme during the last 365 days"
label variable b4pt242101 "whether any online purchase/payment has been made during the reference period to buy - fuel & light"
label variable b4pt242102 "whether any online purchase/payment has been made during the reference period to buy - toilet articles & other household consumables"
label variable b4pt242103 "whether any online purchase/payment has been made during the reference period to buy - education"
label variable b4pt242104 "whether any online purchase/payment has been made during the reference period to buy - medicine & other medical services"
label variable b4pt242105 "whether any online purchase/payment has been made during the reference period to buy - services (travel, recharges, bill payment, cinema/theatre, internet, etc.)"
label variable b4pt24211 "household has internet facility as on the date of the survey"
label variable b4pt34311 "clothing purchased/paid online during last 365 days"
label variable b4pt34312 "footwear purchased/paid online during last 365 days"
label variable b4pt34313 "furniture purchased/paid online during last 365 days"
label variable b4pt34314 "mobile purchased/paid online during last 365 days"
label variable b4pt34315 "personal goods (laptop, PC, tablet, clock, watch, etc.) purchased/paid online during last 365 days"
label variable b4pt34316 "goods for recreation (TV, camera, pen-drive, musical instruments, etc.) purchased/paid online during last 365 days"
label variable b4pt34317 "cooking and other household appliances purchased/paid online during last 365 days"
label variable b4pt34318 "crockery and utensils purchased/paid online during last 365 days"
label variable b4pt34319 "sports goods purchased/paid online during last 365 days"
label variable b4pt343110 "medical equipment purchased/paid online during last 365 days"
label variable b4pt343111 "bedding purchased/paid online during last 365 days"
label variable b4pt34321_1 "one of more household member received free laptop"
label variable b4pt34321_2 "total number of free laptops"
label variable b4pt34322_1 "one of more household member received free tablet"
label variable b4pt34322_2 "total number of free tablet"
label variable b4pt34323_1 "one of more household member received free mobile"
label variable b4pt34323_2 "total number of free mobile"
label variable b4pt34324_1 "one of more household member received free bicycle"
label variable b4pt34324_2 "total number of free bicycle"
label variable b4pt34325_1 "one of more household member received free motorcycle/scooty"
label variable b4pt34325_2 "total number of free motorcycle/scooty"
label variable b4pt34326_1 "one of more household member received free clothing (school uniform etc.)"
label variable b4pt34326_2 "total number of free clothing (school usiform etc.)"
label variable b4pt34327_1 "one of more household member received free footwear (school shoe)"
label variable b4pt34327_2 "total number of free footwear (school shoe)"
label variable b4pt34328_1 "one of more household member received other free items"
label variable b4pt34328_2 "total number of other free items"
label variable b4pt34331 "Household has one or more television"
label variable b4pt34332 "Household has one or more radio"
label variable b4pt34333 "Household has one or more laptop/pc"
label variable b4pt34334 "Household has one or more mobile handset"
label variable b4pt34335 "Household has one or more bicycle"
label variable b4pt34336 "Household has one or more motorcycle, scooty"
label variable b4pt34337 "Household has one or more motor car, jeep, van"
label variable b4pt34338 "Household has one or more trucks" 
label variable b4pt34339 "Household has one or more animal cart"
label variable b4pt343310 "Household has one or more refrigerator"
label variable b4pt343311 "Household has one or more washing machine"
label variable b4pt343312 "Household has one or more air conditioner/air cooler"
label variable b4pt3434 "Type of multichanel tv facility"

label define yes 1 "Yes" 
local lista "b4pt34311 b4pt34312 b4pt34313 b4pt34314 b4pt34315 b4pt34316 b4pt34317 b4pt34318 b4pt34319 b4pt343110 b4pt343111 b4pt34321_1 b4pt34322_1 b4pt34323_1 b4pt34324_1 b4pt34325_1 b4pt34326_1 b4pt34327_1 b4pt34328_1 b4pt34331 b4pt34332 b4pt34333 b4pt34334 b4pt34335 b4pt34336 b4pt34337 b4pt34338 b4pt34339 b4pt343310 b4pt343311 b4pt343312 b4pt3434"
foreach var in `lista' {
	destring `var', replace
    label values `var' "yes"
	}

label define yesno 1 "Yes" 2 "No"
local lista "b4q4pt30 b4q4pt31 b4q4pt32 b4q4pt16 b4q4pt13 b4pt24211 b4q4pt1 b4pt1q411 b4pt2420 b4pt2421_1 b4pt2423_1 b4pt24241_1 b4pt24242_1 b4pt24243_1 b4pt24244_1 b4pt2426_1 b4pt2427_1 b4pt2429_1 b4pt242101 b4pt242102 b4pt242103 b4pt242104 b4pt242105 b4pt24211"
foreach var in `lista' {
	destring `var', replace
    label values `var' "yesno"
	}
	
label define hospital 1 "Yes - Government/Public hospital" 2 "Yes - Private (including charitable/trust run) hospital" 3 "Yes - Both government and private" 4 "No"
destring b4pt2428, replace 
label values b4pt2428 "hospital"

capture label drop sector
destring sector state panel, replace 
label define sector 1 "rural" 2 "urban"
label values sector "sector"

capture label drop state
label define state 1 "Jammu and Kashmir" 2 "Himachal Pradesh" 3 "Punjab" 4 "Chandigarh" 5 "Uttrakhand" 6 "Haryana" 7 "Delhi" 8 "Rajasthan" 9 "Uttar Pradesh" 10 "Bihar" 11 "Sikkim" 12 "Arunachal Pradesh" 13 "Nagaland" 14 "Manipur" 15 "Mizoram" 16 "Tripura" 17 "Meghalaya" 18 "Assam" 19 "West Bengal" 20 "Jharkhand" 21 "Odisha" 22 "Chattisgarh" 23 "Madhya Pradesh" 24 "Gujarat" 25 "Dadra Nagar Haveli & Diu Daman" 27 "Maharashtra" 28 "Andhra Pradesh" 29 "Karnataka" 30 "Goa" 31 "Lakshadweep" 32 "Kerala" 33 "Tamil Nadu" 34 "Puducherry" 35 "Andaman and Nicobar Islands" 36 "Telangana" 37 "Ladakh" 						
label values state "state"

capture label drop panel
label define panel 1 "August - October 2022" 2 "September - November 2022" 3 "October - December 2022" 4 "November 2022-January 2023" 5 "December 2022 -February 2023" 6 "January - March 2023" 7 "February - April 2023" 8 "March - May 2023" 9 "April - June 2023" 10 "May - July 2023" 
label values panel "panel"

destring b1q1pt11, replace 
label define sss 1 "Affluent households" 2 "Middle households" 3 "Remaining households"
label values b1q1pt11 "sss"

destring b1q1pt13 b1q1pt14, replace
label define survey_code 1 "Original" 2 "Substitute" 3 "Casualty"
label values b1q1pt13 "survey_code"
 
label define reason 1 "Informant busy" 2 "Members away from home" 3 "Informant non-cooperative" 9 "Others"
label values b1q1pt14 "reason"	

destring b3q3-b3q7, replace
label define relations 1 "Self" 2 "Spouse of head" 3 "Married child" 4 "Spouse of married child" 5 "Unmarried child" 6 "Grandchild" 7 "Father/Mother/Father-in-law/Mother-in-law" 8 "Brother/Sister/Brother-in-law/Sister-in-law/Other relatives" 9 "Servants/Employees/Other non-relatives"
label values b3q3 "relations"
	
label define sex 1 "Male" 2 "Female" 3 "Transgender" 
label values b3q4 "sex"
	
label define marital_status 1 "Never married" 2 "Currently married" 3 "Widowed" 4 "Divorced/Separated" 
label values b3q6 "marital_status"
	
label define highest_edu 1 "Not literate" 2 "Literate with no formal education" 3 "Below primary" 4 "Primary" 5 "Upper primary/middle" 6 "Secondary" 7 "Higher secondary" 8 "Diploma/Certificate course (up to secondary)" 10 "Diploma/Certificate course (higher secondary)" 11 "Diploma/Certificate course (graduation and above)" 12 "Graduate" 13 "Post graduate and above" 
label values b3q7 "highest_edu"

destring b4q4pt10 b4q4pt11, replace
label define religion 1 "Hinduism" 2 "Islam" 3 "Christianity" 4 "Sikhism" 5 "Jainism" 6 "Buddhism" 7 "Zoroastrianism" 9 "Others" 0 "Not reported"
label values b4q4pt10 "religion" 

label define caste 1 "Scheduled Tribe" 2 "Scheduled Caste" 3 "Other Backward Class" 9 "Others" 0 "Not reported" 
label values b4q4pt11 "caste" 

destring b4q4pt6 b4q4pt7 b4q4pt8 b4q4pt9 b4q4pt14 , replace
label define maxincome 1 "Self-employment" 2 "Regular wage/salaried earnings" 3 "Casual labor" 
label values b4q4pt6 "maxincome"

label define se 1 "Self-employment in agriculture" 2 "Self-employment in non-agriculture"
label values b4q4pt7 "se"

label define wage 3 "Regular wage/salary earning in agriculture" 4 "Regular wage/salary earning in non-agriculture"
label values b4q4pt8 "wage" 

label define casual 5 "Casual labor in agriculture" 6 "Casual labor in non-agriculture" 
label values b4q4pt9 "casual" 

label define typeof_land 1 "Homestead only" 2 "Homestead and other land" 3 "Other land only"
label values b4q4pt14 "typeof_land"

destring b4q4pt17 b4q4pt18 b4q4pt19 b4q4pt20 b4q4pt21 b4q4pt23 b4q4pt25 b4q4pt26 b4q4pt29, replace 
label define dwell 1 "Owned" 2 "Hired" 3 "Others"
label values b4q4pt17 "dwell"

label define material1 1 "Grass/straw/leaves/reeds/bamboo etc." 2 "Mud (with/without bamboo)/unburnt brick" 3 "Canvas/cloth" 4 "Other katcha" 5 "Timber" 6 "Burnt brick/stone/lime stone" 7 "Iron or other metal sheet" 8 "Cement/RBC/RCC" 9 "Other pucca"
label values b4q4pt18 "material1"

label define material2 1 "Grass/straw/leaves/reeds/bamboo etc." 2 "Mud (with/without bamboo)/unburnt brick" 3 "Canvas/cloth" 4 "Other katcha" 5 "Tiles/slate" 6 "Burnt brick/stone/lime stone" 7 "Iron/zinc/othe metal sheet/asbestos sheet" 8 "Cement/RBC/RCC" 9 "Other pucca"
label values b4q4pt19 "material2"
label values b4q4pt20 "material2"

label define cooking 1 "Firewood and chips" 2 "LPG" 3 "Other natural gas" 4 "Dung cake" 5 "Kerosene" 6 "Coke/coal" 7 "Gobar gas" 8 "Other biogas" 10 "Charcoal" 11 "Electricity" 12 "No cooking arrangement" 9 "Others"
label values b4q4pt21 "cooking"

label define drinking 1 "Bottled water" 2 "Piped water into dwelling" 3 "Piped water to yard/plot" 4 "Piped water from neighbour" 5 "Public tap/standpipe" 6 "Tube well" 7 "Hand pump" 8 "Well: Protected" 9 "Well: Unprotected" 10 "Tanker trunk: Public" 11 "Tanker trunk: Private" 12 "Spring: Protected" 13 "Spring: Unprotected" 14 "Rainwater collection" 15 "Surface water: tank/pond" 16 "Other surface water (river, dam, stream, canal, lake etc.)" 19 "Others (cart with small tank or drum etc.)"
label values b4q4pt23 "drinking"

label define latrine_access 1 "Exclusive use of household" 2 "Common use of households in the building" 3 "Public/community latrine without payment" 4 "Public/community latrine with payment" 9 "Others" 5 "No access to latrine" 
label values b4q4pt25 "latrine_access"

label define latrine_type 1 "Flush/pour-flush to: piped sewer system" 2 "Flush/pour-flush to: septic tank" 3 "Flush/pour-flush to: twin leach pit" 4 "Flush/pour-flush to: single leach pit" 5 "Flush/pour-flush to: elsewhere (open drain, open pit, open field, etc.)" 6 "Ventilated improved pit latrine" 7 "Pit latrine with slab" 8 "Pit latrine without slab/open pit" 10 "Composting latrine" 11 "Open drain/nallah" 19 "Others" 
label values b4q4pt26 "latrine_type"

label define ration_card_type 1 "Antyodaya Anna Yojna" 2 "Below Poverty Line" 3 "Above Poverty Line" 4 "Priority Households" 5 "State Food Security Scheme" 9 "Others" 0 "No ration card" 
label values b4q4pt29 "ration_card_type"

****************************************************************************************************************
****************************************************************************************************************

order hhid pid
sort  hhid pid
*</_Datalibweb request_>


*<_Save data file_>
compress
save "${output}/`yearfolder'_v`vm'_M.dta", replace
*</_Save data file_>	

