set more off
*===============================================================================
* PROJECT: SRI LANKA SCD
* Data: HIES 2009-10
* Date: 15th October 2014
* Author: Lidia Ceriani
* This dofile: Label and arrange each section
*===============================================================================
global dir  "C:\Users\wb436991\Box Sync\WB\SAR_Sri_Lanka\Data\HIES\HIES_2009_10\"
global data "${dir}\Data_original\raw2009"
global out 	"${dir}\Data_processed"

*===============================================================================
* SECTION 5.1 - EMPLOYMENT INCOME
*===============================================================================\
use "${data}/hies_2009_sec5_1_empincome.dta", clear
drop if pno>40 | result!=1
rename wage_1m 		wages_salaries
rename ot_1m		allowences 
rename bonus_12m	bonus
rename main_sec		pri_sec
keep wages_salaries allowences bonus hhid pno pri_sec

replace pri_sec=1 if pri_sec==. | pri_sec==0
duplicates drop hhid pno pri_sec, force

reshape wide wages_salaries allowences bonus, i(hhid pno) j(pri_sec)
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
rename s51_pno pno

save "${out}/hies_2009_sec5_1_empincome.dta", replace

*===============================================================================
* SECTION 5.2 - INCOME FROM AGRICULTURAL ACTIVITIES
*===============================================================================\
use "${data}/hies_2009_sec5_2_scrop_income.dta", clear
rename crop 		col_4x
rename acre 		col_5x 
rename root 		col_6x 
rename perch 		col_7x 
rename output_12m 	col_8x1 
rename input_12m	col_9x
rename hh_con_12m 	col_10x1
keep col_4x col_5x col_6x col_7x col_8x1 col_9x col_10x1 hhid pno

replace col_4x=9 if col_4x==.
replace col_4x=8 if col_4x==9

rename *x *
rename *x1 *_1
rename col_* s52_*_
reshape wide s52_5_ s52_6_ s52_7_  s52_8_1_ s52_9_  s52_10_1_  , i(hhid pno) j(s52_4)

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

save "${out}/hies_2009_sec5_2_scrop_income.dta", replace

*===============================================================================
* SECTION 5.3 - INCOME FROM OTHER AGRICULTURAL ACTIVITIES
*===============================================================================
use "${data}/hies_2009_sec5_3_ocrop_income.dta", clear

rename crop 		seasonal_crop
rename acre 		acres_5_3
rename root 		roots_5_3
rename perch 		perchs_5_3
rename output_1m 	output_5_3
rename input_1m 	input_5_3

* One duplicate
duplicates drop hhid pno seasonal_crop, force
keep seasonal_crop acres_5_3 roots_5_3 perchs_5_3 output_5_3 input_5_3  hhid  pno
replace seasonal_crop=99 if seasonal_crop==16 | seasonal_crop==19 | seasonal_crop==24 |seasonal_crop==.
replace seasonal_crop=11 if seasonal_crop==99

rename *_5_3 s53_*_
reshape wide s53_acres_ s53_roots_ s53_perchs_ s53_output_ s53_input_ , i(hhid pno) j(seasonal_crop)

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

rename s53_roots_* s53_roods_*

save "${out}/hies_2009_sec5_3_ocrop_income.dta", replace

*===============================================================================
* SECTION 5.4 - INCOME FROM NON-AGRICULTURAL ACTIVITIES
*===============================================================================\
use "${data}/hies_2009_sec5_4_nonagri_income.dta", clear
rename output_1m 	output_5_4
rename input_1m		input_5_4

keep non_agri output_5_4 input_5_4  hhid pno pno
replace non_agri=9 if non_agr==0 | non_agri==7 | non_agri==.
replace non_agri=7 if non_agri==9

* One duplicates
duplicates drop hhid pno non_agr, force

rename output_5_4 s54_output_
rename input_5_4  s54_input_

reshape wide s54_output_ s54_input_ , i(hhid pno) j(non_agri)

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

save "${out}/hies_2009_sec5_4_nonagri_income.dta", replace

*===============================================================================
* SECTION 5.5.1 - OTHER INCOME
*===============================================================================
use "${data}/hies_2009_sec5_5_transfer_income.dta", clear

drop if pno>40 | result!=1

rename disability 		disability_and_relief 
rename rent 			property_rents  
rename interest 		dividends 
rename other_cash 		other_income 
rename remit_abr_12m 	income_abroad
rename remit_loc_12m 	income_local

duplicates drop hhid pno, force

keep hhid pno pno pension disability_and_relief property_rents  samurdhi dividends other_income income_abroad income_local

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
rename s551_pno pno

save "${out}/hies_2009_sec5_5_transfer_income.dta", replace

*===============================================================================
* SECTION 5.5.2 - WINDFALL INCOME
*===============================================================================\
use "${data}/hies_2009_sec5_5_adhoc_income.dta", clear
drop if pno>40 | result!=1

rename loan_tkn 	loans 
rename sales 		pawning_selling 
rename withdraw 	deposits_pensions_epf 
rename recpt_pay	seettu_debts 
rename compens 		insuarance 

keep hhid pno loans pawning_selling deposits_pensions_epf gift seettu_debts  insuarance lottery 
label var loans 				"Loans taken, last 12 months, Rs"
label var pawning_selling 		"Sale of assets (land, house, jewellary), last 12 months, Rs"
label var deposits_pensions_epf "Withdrawals from savings et al, last 12 months, Rs"
label var gifts					"Income receives from births, deaths, marriages, last 12 months, Rs"
label var seettu_debts 			"Seettu, repayments of loans given, last 12 months, Rs"
label var insuarance 			"Compensation insurance, last 12 months, Rs"
label var lottery 				"Other lottery/Ad hoc gains, last 12 months, Rs"

rename * s552_*
rename s552_hhid hhid
rename s552_pno pno

save "${out}/hies_2009_sec5_5_adhoc_income.dta", replace

