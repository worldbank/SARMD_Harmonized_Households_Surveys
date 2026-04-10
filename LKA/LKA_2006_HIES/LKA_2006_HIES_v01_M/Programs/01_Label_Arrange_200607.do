set more off
*===============================================================================
* PROJECT: SRI LANKA SCD
* Data: HIES 2009-10
* Date: 15th October 2014
* Author: Lidia Ceriani
* This dofile: Label and arrange each section
*===============================================================================
global dir  "C:\Users\wb436991\Box Sync\WB\SAR_Sri_Lanka\Data\HIES\HIES_2006_07\"
global data "${dir}\Data_original"
global out 	"${dir}\Data_processed"

*===============================================================================
* SECTION 5.1 - EMPLOYMENT INCOME
*===============================================================================\
use "${data}/sec_5_1_emp_incomeV2.dta", clear

* Generate HHID
*-------------------------------------------------------------------------------
gen sdist = string(district)
gen spsu = "00" + string(psu) if psu <10
replace spsu = "0" + string(psu) if psu >= 10 & psu <100
replace spsu = string(psu) if psu >= 100
gen ssamp = string( sample_n)
replace ssamp = "0" + string(sample_n) if sample_n <10
gen shhno = string( serial_no)
egen hhid = concat( sdist spsu ssamp shhno )
drop sdist spsu ssamp shhno
sort hhid
label var hhid "Household ID"
*-------------------------------------------------------------------------------

rename serial_no_sec_1 pid
drop if pid>40 | result!=1
keep wages_salaries allowences bonus hhid pid pri_sec

replace pri_sec=1 if pri_sec==. | pri_sec==0
duplicates drop hhid pid pri_sec, force

reshape wide wages_salaries allowences bonus, i(hhid pid) j(pri_sec)
rename *1 *_1
rename *2 *_2
label var wages_salaries_1  "Wages and salaries, main occupation"
label var allowences_1 		"Tips, Commission, Overtime pay, main occupation"
label var bonus_1			"Bonus, Arrears, Payment, main occupation"
label var wages_salaries_2	"Wages and salaries, secondary occupation"
label var allowences_2 		"Tips, Commission, Overtime pay, secondary occupation"
label var bonus_2			"Bonus, Arrears, Payment, secondary occupation"

rename * s51_*
rename *allowence* *allowance*
rename s51_hhid hhid
rename s51_pid pid

save "${out}/sec_5_1_emp_incomeV2.dta", replace

*===============================================================================
* SECTION 5.2 - INCOME FROM AGRICULTURAL ACTIVITIES
*===============================================================================\
use "${data}/sec_5_2_agri_incomeV2.dta", clear

* Generate HHID
*-------------------------------------------------------------------------------
gen sdist = string(district)
gen spsu = "00" + string(psu) if psu <10
replace spsu = "0" + string(psu) if psu >= 10 & psu <100
replace spsu = string(psu) if psu >= 100
gen ssamp = string( sample_n)
replace ssamp = "0" + string(sample_n) if sample_n <10
gen shhno = string( serial_no)
egen hhid = concat( sdist spsu ssamp shhno )
drop sdist spsu ssamp shhno
sort hhid
label var hhid "Household ID"
*-------------------------------------------------------------------------------
rename ser_no_sec_5_2		pid
rename seas_crops_code 		col_4x
rename acr_5_2 				col_5x 
rename rt_5_2 				col_6x 
rename p			 		col_7x 
rename output_5_2		 	col_8x1 
rename input_5_2			col_9x
rename hh_consumption	 	col_10x1
keep col_4x col_5x col_6x col_7x col_8x1 col_9x col_10x1 hhid pid

replace col_4x=9 if col_4x==.
replace col_4x=8 if col_4x==9

rename *x *
rename *x1 *_1
rename col_* s52_*_
reshape wide s52_5_ s52_6_ s52_7_  s52_8_1_ s52_9_  s52_10_1_  , i(hhid pid) j(s52_4)

forvalues i=1(1)8{
label var s52_5_`i' 	"Cultivated area, Acres"
label var s52_6_`i' 	"Cultivated area, Roods"
label var s52_7_`i' 	"Cultivated area, Perches"
label var s52_8_1_`i'	"Value of the output, Rs" 
label var s52_9_`i' 	"Cost of input, Rs"
label var s52_10_1_`i' 	"Value of self-consumption, Rs"
}

rename s52_5_* s52_acres_*
rename s52_6_* s52_roods_*
rename s52_7_* s52_perchs_*

rename s52*_1 s52*_paddy
rename s52*_2 s52*_chilies
rename s52*_3 s52*_onions
rename s52*_4 s52*_vegetables
rename s52*_5 s52*_cereals
rename s52*_6 s52*_yams
rename s52*_7 s52*_tobacco
rename s52*_8 s52*_other

save "${out}/sec_5_2_agri_incomeV2.dta", replace

*===============================================================================
* SECTION 5.3 - INCOME FROM OTHER AGRICULTURAL ACTIVITIES
*===============================================================================
use "${data}/sec_5_3_other_agri_income.dta", clear
* Generate HHID
*-------------------------------------------------------------------------------
gen sdist = string(district)
gen spsu = "00" + string(psu) if psu <10
replace spsu = "0" + string(psu) if psu >= 10 & psu <100
replace spsu = string(psu) if psu >= 100
gen ssamp = string( sample_n)
replace ssamp = "0" + string(sample_n) if sample_n <10
gen shhno = string( serial_no)
egen hhid = concat( sdist spsu ssamp shhno )
drop sdist spsu ssamp shhno
sort hhid
label var hhid "Household ID"
*-------------------------------------------------------------------------------
rename ser_no_sec_5_3 pid
 
duplicates drop hhid pid seasonal_crop, force

keep seasonal_crop acres_5_3 roots_5_3 perchs_5_3 output_5_3 input_5_3  hhid  pid
replace seasonal_crop=99 if seasonal_crop==16 | seasonal_crop==19 | seasonal_crop==24 |seasonal_crop==.
replace seasonal_crop=11 if seasonal_crop==99

rename *_5_3 s53_*_
reshape wide s53_acres_ s53_roots_ s53_perchs_ s53_output_ s53_input_ , i(hhid pid) j(seasonal_crop)

forvalues i=1(1)11{
label var s53_acres_`i'     "Cultivated area, Acres"
label var s53_roots_`i'		"Cultivated area, Roods"
label var s53_perchs_`i' 	"Cultivated area, Perches"
label var s53_output_`i' 	"Value of output, Rs"
label var s53_input_`i'		"Cost of input, Rs"
}

rename s53*_1 s53*_tea
rename s53*_2 s53*_coconut
rename s53*_3 s53*_coffee
rename s53*_4 s53*_banana
rename s53*_5 s53*_meat
rename s53*_6 s53*_fish
rename s53*_7 s53*_eggs
rename s53*_8 s53*_milk
rename s53*_9 s53*_other_food
rename s53*_10 s53*_horticulture
rename s53*_11 s53*_other

rename s53_roots* s53_roods*

save "${out}/sec_5_3_other_agri_income.dta", replace

*===============================================================================
* SECTION 5.4 - INCOME FROM NON-AGRICULTURAL ACTIVITIES
*===============================================================================\
use "${data}/sec_5_4_non_agri_income.dta", clear
* Generate HHID
*-------------------------------------------------------------------------------
gen sdist = string(district)
gen spsu = "00" + string(psu) if psu <10
replace spsu = "0" + string(psu) if psu >= 10 & psu <100
replace spsu = string(psu) if psu >= 100
gen ssamp = string( sample_n)
replace ssamp = "0" + string(sample_n) if sample_n <10
gen shhno = string( serial_no)
egen hhid = concat( sdist spsu ssamp shhno )
drop sdist spsu ssamp shhno
sort hhid
label var hhid "Household ID"
*-------------------------------------------------------------------------------
rename serial_5_4	pid

keep non_agri output_5_4 input_5_4  hhid pid pid
replace non_agri=9 if non_agr==0 | non_agri==7 | non_agri==.
replace non_agri=7 if non_agri==9

duplicates drop hhid pid non_agr, force

rename output_5_4 s54_output_
rename input_5_4  s54_input_

reshape wide s54_output_ s54_input_ , i(hhid pid) j(non_agri)

forvalues i=1(1)7{
label var s54_output_`i'     	"Value of output, Rs"
label var s54_input_`i'			"Cost of input, Rs"
}

rename s54*_1 s54*_mining_quarrying
rename s54*_2 s54*_manufacturing
rename s54*_3 s54*_construction
rename s54*_4 s54*_trade
rename s54*_5 s54*_transport
rename s54*_6 s54*_hotel_restaurant
rename s54*_7 s54*_other

save "${out}/sec_5_4_non_agri_income.dta", replace

*===============================================================================
* SECTION 5.5.1 - OTHER INCOME
*===============================================================================
use "${data}/sec_5_5_1_other_income.dta", clear
* Generate HHID
*-------------------------------------------------------------------------------
gen sdist = string(district)
gen spsu = "00" + string(psu) if psu <10
replace spsu = "0" + string(psu) if psu >= 10 & psu <100
replace spsu = string(psu) if psu >= 100
gen ssamp = string( sample_n)
replace ssamp = "0" + string(sample_n) if sample_n <10
gen shhno = string( serial_no)
egen hhid = concat( sdist spsu ssamp shhno )
drop sdist spsu ssamp shhno
sort hhid
label var hhid "Household ID"
*-------------------------------------------------------------------------------
rename serial_5_5_1 	pid

rename other 			other_income 
rename abroad		 	income_abroad
rename local		 	income_local

duplicates drop hhid pid, force

keep hhid pid pid pension disability_and_relief property_rents  samurdhi dividends other_income income_abroad income_local

label var pension 				"Pension payment, last month, Rs"
label var disability_and_relief	"Disability, relief payments, last month, Rs" 
label var property_rents 		"Rents from properties, last month, Rs"
label var samurdhi 				"Samurdhi, last month, Rs"
label var dividends				"Dividends, last month, Rs" 
label var other_income 			"Other Income, last month, Rs"
label var income_abroad 		"Transfer from abroad, last 12 months, Rs"
label var income_local			"Tranfers from within the coutnry, last 12 months, Rs"

rename * s551_*
rename s551_hhid hhid
rename s551_pid pid

save "${out}/sec_5_5_1_other_income.dta", replace

*===============================================================================
* SECTION 5.5.2 - WINDFALL INCOME
*===============================================================================\
use "${data}/sec_5_5_2_windfall_income.dta", clear
* Generate HHID
*-------------------------------------------------------------------------------
gen sdist = string(district)
gen spsu = "00" + string(psu) if psu <10
replace spsu = "0" + string(psu) if psu >= 10 & psu <100
replace spsu = string(psu) if psu >= 100
gen ssamp = string( sample_n)
replace ssamp = "0" + string(sample_n) if sample_n <10
gen shhno = string( serial_no)
egen hhid = concat( sdist spsu ssamp shhno )
drop sdist spsu ssamp shhno
sort hhid
label var hhid "Household ID"
*-------------------------------------------------------------------------------
rename person_5_5_2 	pid
drop if pid>40 | result!=1

rename sittu_debts		seettu_debts 
rename compens 			insuarance 
rename other_windfall	gifts

keep hhid pid loans pawning_selling deposits_pensions_epf lottery seettu_debts insuarance gift   
label var loans 				"Loans taken, last 12 months, Rs"
label var pawning_selling 		"Sale of assets (land, house, jewellary), last 12 months, Rs"
label var deposits_pensions_epf "Withdrawals from savings et al, last 12 months, Rs"
label var gifts					"Income receives from births, deaths, marriages, last 12 months, Rs"
label var seettu_debts 			"Seettu, repayments of loans given, last 12 months, Rs"
label var insuarance 			"Compensation insurance, last 12 months, Rs"
label var lottery 				"Other lottery/Ad hoc gains, last 12 months, Rs"

rename * s552_*
rename s552_hhid hhid
rename s552_pid pid

save "${out}/sec_5_5_2_windfall_income.dta", replace

