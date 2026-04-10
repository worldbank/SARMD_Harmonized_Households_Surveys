/*------------------------------------------------------------------------------
  GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   		IND_2023_HCES_v03_M.do			   	   </_Program name_>
<_Application_>    		STATA 17.0							     <_Application_>
<_Author(s)_>      		tornarolli@gmail.com	          		  </_Author(s)_>
<_Date created_>   		09-02-2026	                           </_Date created_>
<_Date modified>   		09-02-2026	                          </_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        		IND											</_Country_>
<_Survey Title_>   		HCES								   </_Survey Title_>
<_Survey Year_>    		2023-2024  								</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:					09-02-2026
File:					IND_2023_HCES_v03_M.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>
clear all
set more off

local code         		"IND"
local year         		"2023"
local survey       		"HCES"
local vm           		"01"
local type         		"SARMD"
local yearfolder   		"`code'_`year'_`survey'"
global input       		"${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata"
global output      		"${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata"
*</_Program setup_>


*<_Datalibweb request_>
************************************************
**** HCES22_LVL_01: HOUSEHOLD CHARACTERISTICS 
************************************************
use "${input}\level01_2023.dta", clear 
destring Sample_Household_No, replace
egen hhid = concat(FSU_Serial_No Second_Stage_Stratum_No Sample_Household_No)
gen hhwt = Multiplier/100
order hhid
save "${output}\LVL_01.dta", replace


************************************************
**** HCES22_LVL_02: HOUSEHOLD CHARACTERISTICS 
************************************************
use "${input}\level02_2023.dta", clear
destring Sample_Household_No, replace
egen hhid = concat(FSU_Serial_No Second_Stage_Stratum_No Sample_Household_No)
egen pid = concat(FSU_Serial_No Second_Stage_Stratum_No Sample_Household_No Person_Serial_No)
gen pwt = Multiplier/100
order hhid pid
save "${output}\LVL_02.dta", replace


************************************************
**** HCES22_LVL_03: HOUSEHOLD CHARACTERISTICS 
************************************************	
use "${input}\level03_2023.dta", clear
destring Sample_Household_No, replace
egen hhid = concat(FSU_Serial_No Second_Stage_Stratum_No Sample_Household_No)
gen hhwt = Multiplier/100
order hhid
save "${output}\LVL_03.dta", replace


************************************************
**** HCES22_LVL_04: FOOD ITEMS 
************************************************
use "${input}\level04_2023.dta", clear 
destring Sample_Household_No, replace
egen hhid = concat(FSU_Serial_No Second_Stage_Stratum_No Sample_Household_No)
gen hhwt = Multiplier/100
order hhid
save "${output}\LVL_04.dta", replace


************************************************
**** HCES22_LVL_05: FOOD ITEMS (LAST 30 DAYS)
************************************************
use "${input}\level05_2023.dta", clear
destring Sample_Household_No, replace
egen hhid = concat(FSU_Serial_No Second_Stage_Stratum_No Sample_Household_No)
gen hhwt = Multiplier/100
order hhid 
save "${output}\LVL_05.dta", replace

collapse (sum) Total_Consumption_Value, by(hhid)
rename Total_Consumption_Value Total_Consumption_Value_30_days 
tempfile level_5 
save "`level_5'"

************************************************
**** HCES22_LVL_06: FOOD ITEMS (LAST 7 DAYS) 
************************************************
use "${input}\level06_2023.dta", clear
destring Sample_Household_No, replace
egen hhid = concat(FSU_Serial_No Second_Stage_Stratum_No Sample_Household_No)
gen hhwt = Multiplier/100
order hhid 
save "${output}\LVL_06.dta", replace
destring Total_*, replace

collapse (sum) Total_Consumption_Value, by(hhid)
rename Total_Consumption_Value Total_Consumption_Value_7_days 
merge 1:1 hhid using "`level_5'"
keep hhid
tempfile control
save `control'


************************************************
**** HCES22_LVL_07: CONSUMABLE AND SERVICES 
************************************************
use "${input}\level07_2023.dta", clear
destring Sample_Household_No, replace
egen hhid = concat(FSU_Serial_No Second_Stage_Stratum_No Sample_Household_No)
gen hhwt = Multiplier/100
order hhid
save "${output}\LVL_07.dta", replace


************************************************
**** HCES22_LVL_08: CONSUMABLES AND SERVICES 
************************************************
use "${input}\level08_2023.dta", clear
destring Sample_Household_No, replace
egen hhid = concat(FSU_Serial_No Second_Stage_Stratum_No Sample_Household_No)
gen hhwt = Multiplier/100
order hhid 
save "${output}\LVL_08.dta", replace
keep if Item_Code_8_1>="331" & Item_Code_8_1<="346" 
keep hhid Item_Code_8_1 Total_consumption_value_rs
rename Total_consumption_value_rs exp
reshape wide exp, i(hhid) j(Item_Code_8_1) string
save "${output}\LVL_08_expenditures.dta", replace


************************************************
**** HCES22_LVL_09: CONSUMABLES AND SERVICES
************************************************
use "${input}\level09_2023.dta", clear
destring Sample_Household_No, replace
egen hhid = concat(FSU_Serial_No Second_Stage_Stratum_No Sample_Household_No)
gen hhwt = Multiplier/100
order hhid 
save "${output}\LVL_09.dta", replace
keep if   Item_Code_9_1_to_11_4=="487" | Item_Code_9_1_to_11_4=="488" | Item_Code_9_1_to_11_4=="496" | Item_Code_9_1_to_11_4=="512" | Item_Code_9_1_to_11_4=="513" | Item_Code_9_1_to_11_4=="540"
keep hhid Item_Code_9_1_to_11_4 Value_Rs_9_1_to_11_4
rename Value_Rs_9_1_to_11_4 exp
reshape wide exp, i(hhid) j(Item_Code_9_1_to_11_4) string
save "${output}\LVL_09_expenditures.dta", replace


************************************************
**** HCES22_LVL_10: CONSUMABLES AND SERVICES 
************************************************
use "${input}\level10_2023.dta", clear
destring Sample_Household_No, replace
egen hhid = concat(FSU_Serial_No Second_Stage_Stratum_No Sample_Household_No)
gen hhwt = Multiplier/100
order hhid 
save "${output}\LVL_10.dta", replace


************************************************
**** HCES22_LVL_11: DURABLE GOODS 
************************************************
use "${input}\level11_2023.dta", clear
destring Sample_Household_No, replace
egen hhid = concat(FSU_Serial_No Second_Stage_Stratum_No Sample_Household_No)
gen hhwt = Multiplier/100
order hhid
save "${output}\LVL_11.dta", replace


************************************************
**** HCES22_LVL_12: DURABLE GOODS
************************************************
use "${input}\level12_2023.dta", clear
destring Sample_Household_No, replace
egen hhid = concat(FSU_Serial_No Second_Stage_Stratum_No Sample_Household_No)
rename MULTIPLIER Multiplier
rename ITEM_CODE Item_Code 
rename QUANTITY Quantity
rename VALUE Value
gen hhwt = Multiplier/100
order hhid 
save "${output}\LVL_12.dta", replace


************************************************
**** HCES22_LVL_13: DURABLE GOODS 
************************************************
use "${input}\level13_2023.dta", clear
destring Sample_Household_No, replace
egen hhid = concat(FSU_Serial_No Second_Stage_Stratum_No Sample_Household_No)
rename ITEM_CODE Item_Code
rename FIRST_PURCHASE_NUMBER First_Purchase_Number
rename PURCHASED_ON_HIRE Purchased_On_Hire
rename FIRST_PURCHASE_VALUE First_Purchase_Value
rename REPAIR_COST Repair_Cost
rename SECOND_HAND_NUMBER Second_Hand_Number
rename SECOND_HAND_VALUE Second_Hand_Value
rename TOTAL_EXPENDITURE Total_Expenditure
rename MULTIPLIER Multiplier
gen hhwt = Multiplier/100
order hhid
save "${output}\LVL_13.dta", replace


************************************************
**** HCES22_LVL_14: FDQ-CSQ-DGQ 
************************************************
use "${input}\level14_2023.dta", clear
destring Sample_Household_No, replace
egen hhid = concat(FSU_Serial_No Second_Stage_Stratum_No Sample_Household_No)
rename SECTION Section 
rename ITEM_CODE Item_Code
rename VALUE_RS Value_Rs
rename MULTIPLIER Multiplier

gen hhwt = Multiplier/100

order hhid Item_Code Value_Rs	
save "${output}\LVL_14.dta", replace


************************************************
**** HCES22_LVL_15: HCQ-FDQ-CSQ-DGQ
************************************************	
use "${input}\level15_2023.dta", clear
destring Sample_Household_No, replace
egen hhid = concat(FSU_Serial_No Second_Stage_Stratum_No Sample_Household_No)
rename VISIT Visit 
rename LEVEL Level
rename SECTION Section
rename TIME_TAKEN Time_Taken
rename MONTHLY_CONSUMPTION_EXP Monthly_Consumption_Exp 
rename ONLINE_EXPENDITURE Online_Expenditure
rename INFORMANT_CODE Informant_Code
rename RESPONSE_CODE Response_Code
rename HOUSEHOLD_SIZE Household_Size
rename VISIT_MONTH Visit_Month
rename MULTIPLIER Multiplier
gen hhwt = Multiplier/100

encode Section, gen(section_new)
destring section_new, replace
label define sect 1 "Household characteristics" 2 "Food expenditure" 3 "Consumables and services expenditure" 4 "Durable goods expenditure" 
label values section_new "sect"

label define response 1 "Informant co-operative and capable" 2 "Informant co-operative but not capable" 3 "Informant busy" 4 "Informant reluctant" 9 "Others"
destring Response_Code, replace 

order hhid section_new Monthly_Consumption_Exp Online_Expenditure Household_Size Response_Code 
unique hhid section
save "${output}\LVL_15.dta", replace


**********************************************************************************
**********************************************************************************
* LVL 01:    261,953 observations (household level)
* LVL 02:  1,107,221 observations (individual level)
* LVL 03:    261,953 observations (household level) 
* LVL 04:    261,953 observations (household level) 
* LVL 05: 12,754,437 observations (item level)  			  ---> reshape  
* LVL 06:  1,757,264 observations (item level)  			  ---> reshape 
* LVL 07:    261,953 observations (household level)
* LVL 08:  1,499,971 observations (item level)  			  ---> reshape 
* LVL 09:  8,259,120 observations (item level)  			  ---> reshape 
* LVL 10:    829,310 observations (item level)  			  ---> reshape 
* LVL 11:    261,953 observations (household level)
* LVL 12:  4,707,351 observations (item level)  			  ---> reshape
* LVL 13:  4,951,749 observations (item level)  			  ---> reshape
* LVL 14:  8,296,569 observations (item level) 				  ---> reshape
* LVL 15:  1,047,812 observations (household x section level) ---> reshape

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
merge m:1 hhid using "${output}\LVL_08_expenditures.dta"
drop _merge
merge m:1 hhid using "${output}\LVL_09_expenditures.dta"
drop _merge
merge m:1 hhid using `control'
drop if _merge!=3
drop _merge
merge m:1 hhid using "${output}\\IND_PRIMUS_2023-24_v2.dta", keepusing(pwt welfarenom_final welfaredef_final cpi_2022 cpi_2017 cpi_2021) nogen
merge m:1 hhid using "${output}\\welfare_agg_21_all.dta", keepusing(hhsize-scenario) nogen


forvalues i = 1(1)9 { 
	erase "${output}\LVL_0`i'.dta"
	} 
forvalues i = 10(1)15 { 
	erase "${output}\LVL_`i'.dta"
	} 
	erase "${output}\LVL_08_expenditures.dta"
	erase "${output}\LVL_09_expenditures.dta"

****************************************************************************************************************
****************************************************************************************************************

order hhid pid
sort  hhid pid
*</_Datalibweb request_>


*<_Save data file_>
compress
save "${output}/`yearfolder'_v`vm'_M.dta", replace
*</_Save data file_>	

