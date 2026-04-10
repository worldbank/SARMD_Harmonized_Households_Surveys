set more off
*===============================================================================
* PROJECT: SRI LANKA SCD
* Data: HIES 2001-02
* Date: 15th October 2014
* Author: Lidia Ceriani
* This dofile: Label and arrange each section
*===============================================================================
global dir  "C:\Users\wb436991\Box Sync\WB\SAR_Sri_Lanka\Data\HIES\HIES_2001_02\"
global data "${dir}\Data_original"
global out 	"${dir}\Data_processed"

*===============================================================================
* SECTION 5.1 - EMPLOYMENT INCOME
*===============================================================================\
use "${data}/Section_31.dta", clear
rename r7c2 	pid
rename r7c3		pri_sec
rename r7c7		industry
rename r7c5		isco_code
rename r7c8		wages_salaries
rename r7c9		allowences
rename r7c10	bonus

drop if pid>40 | rcode!=1

keep wages_salaries allowences bonus hhid pid pri_sec isco_code industry

replace pri_sec=1 if pri_sec==. | pri_sec==0
duplicates drop hhid pid pri_sec wages_salaries allowences bonus, force

reshape wide wages_salaries allowences bonus isco_code industry, i(hhid pid) j(pri_sec)
rename *1 *_1
rename *2 *_2
label var wages_salaries_1  "Wages and salaries, main occupation"
label var allowences_1 		"Tips, Commission, Overtime pay, main occupation"
label var bonus_1			"Bonus, Arrears, Payment, main occupation"
label var wages_salaries_2	"Wages and salaries, secondary occupation"
label var allowences_2 		"Tips, Commission, Overtime pay, secondary occupation"
label var bonus_2			"Bonus, Arrears, Payment, secondary occupation"
label var isco_code_1		"Occupation Code, main occupation"
label var isco_code_2		"Occupation Code, secondary occupation"
label var industry_1		"Industry, main occupation"
label var industry_2		"Industry, secondary occupation"
rename * s51_*
rename *allowence* *allowance*
rename s51_hhid hhid
rename s51_pid pid

save "${out}/Section_31.dta", replace

*===============================================================================
* SECTION 5.2 - INCOME FROM AGRICULTURAL ACTIVITIES
*===============================================================================\
use "${data}/Section_34.dta", clear

rename r12c2		pid
rename r12c4		col_4x
rename r12a 		col_5x 
rename r12r 		col_6x 
rename r12p			col_7x 
rename r12c5		col_8x1 
rename r12c7		col_9x
rename r12c6	 	col_10x1
keep col_4x col_5x col_6x col_7x col_8x1 col_9x col_10x1 hhid pid
replace col_4x=9 if col_4x==.
replace col_4x=6 if col_4x==9

duplicates drop hhid pid col_4x col_5x col_6x col_7x col_8x1 col_9x col_10x1, force
duplicates report hhid pid col_4x
collapse (sum) col_5x col_6x col_7x col_8x1 col_9x col_10x1, by(hhid pid col_4x)

rename *x *
rename *x1 *_1
rename col_* s52_*_
reshape wide s52_5_ s52_6_ s52_7_  s52_8_1_ s52_9_  s52_10_1_  , i(hhid pid) j(s52_4)

forvalues i=1(1)6{
label var s52_5_`i' 	"Cultivated area, Acres"
label var s52_6_`i' 	"Cultivated area, Roods"
label var s52_7_`i' 	"Cultivated area, Perches"
label var s52_8_1_`i'	"Value of the output, Rs" 
label var s52_9_`i' 	"Cost of input, Rs"
label var s52_10_1_`i' 	"Value of self-consumption, Rs"
}

rename s52*_1 s52*_paddy
rename s52*_2 s52*_chilies
rename s52*_3 s52*_onions
rename s52*_4 s52*_vegetables
rename s52*_5 s52*_tobacco
rename s52*_6 s52*_other

rename s52_5_* s52_acres_*
rename s52_6_* s52_roods_*
rename s52_7_* s52_perchs_*

save "${out}/Section_34.dta", replace

*===============================================================================
* SECTION 5.3 - INCOME FROM OTHER AGRICULTURAL ACTIVITIES
*===============================================================================
use "${data}/Section_35.dta", clear
rename r14c2  	pid
rename r14c4  	seasonal_crop
rename r14a		acres_5_3
rename r14r		roods_5_3
rename r14p		perchs_5_3
rename r14c5	output_5_3
rename r14c6	self_5_3
rename r14c7	input_5_3

duplicates drop hhid pid seasonal_crop acres_5_3 roods_5_3 perchs_5_3 output_5_3 input_5_3 self_5_3, force
duplicates report hhid pid seasonal_crop

collapse (sum) acres_5_3 roods_5_3 perchs_5_3 output_5_3 input_5_3 self_5_3, by(hhid pid seasonal_crop)

keep seasonal_crop acres_5_3 roods_5_3 perchs_5_3 output_5_3 input_5_3 self_5_3 hhid  pid
replace seasonal_crop=99 if seasonal_crop==16 | seasonal_crop==19 | seasonal_crop==24 |seasonal_crop==.
replace seasonal_crop=11 if seasonal_crop==99

rename *_5_3 s53_*_
reshape wide s53_acres_ s53_roods_ s53_perchs_ s53_output_ s53_input_ s53_self, i(hhid pid) j(seasonal_crop)

forvalues i=1(1)10{
label var s53_acres_`i'     "Cultivated area, Acres"
label var s53_roods_`i'		"Cultivated area, Roods"
label var s53_perchs_`i' 	"Cultivated area, Perches"
label var s53_output_`i' 	"Value of output, Rs"
label var s53_input_`i'		"Cost of input, Rs"
label var s53_self_`i'		"Value of self-consumption, Rs"
}

rename s53*_1 s53*_tea
rename s53*_2 s53*_coconut
rename s53*_3 s53*_coffee_banana
rename s53*_4 s53*_meat
rename s53*_5 s53*_fish
rename s53*_6 s53*_eggs
rename s53*_7 s53*_milk
rename s53*_8 s53*_other_food
rename s53*_9 s53*_firewood
rename s53*_10 s53*_other

save "${out}/Section_35.dta", replace

*===============================================================================
* SECTION 5.4 - INCOME FROM NON-AGRICULTURAL ACTIVITIES
*===============================================================================\
use "${data}/Section_33.dta", clear

rename r10c2  	pid
rename r10c4  	non_agri
rename r10c5	output_5_4
rename r10c6	input_5_4

duplicates drop hhid pid non_agr output_5_4 input_5_4, force

duplicates report hhid pid non_agr, force
collapse (sum) output_5_4 input_5_4 , by(hhid pid non_agri)

keep non_agri output_5_4 input_5_4  hhid pid pid
replace non_agri=7 if non_agr==0 | non_agri==.

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

save "${out}/Section_33.dta", replace

*===============================================================================
* SECTION 5.5.1 - OTHER INCOME
*===============================================================================
use "${data}/Section_32.dta", clear

rename r8c2 	pid
rename r8c3		pension
rename r8c4		disability_and_relief 
rename r8c5		property_rents  
rename r8c6		samurdhi_food 
rename r8c7		dividends 
rename r8c8		other_income 
rename r8c9		income_abroad 
rename r8c10	income_local

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

save "${out}/Section_32.dta", replace

*===============================================================================
* SECTION 3.6 - IN KIND INCOME
*===============================================================================
use "${data}/Section_36.dta", clear

* Fix hhid which is created differently from other files
sort district hsno
tostring district hsno, replace
gen zero="0"
egen temp_hsno 		= concat(zero zero zero zero hsno)
replace hsno		= substr(temp_hsno,-4,.)
drop temp* zero
rename hhid hhid_old
egen hhid=concat(district hsno)

drop pid
rename	r16c2	pid
rename 	r16c3	s36_source	
rename 	r16c4	s36_meals
rename 	r16c5	s36_housing
rename 	r16c6	s36_clothing
rename 	r16c7	s36_health
rename 	r16c8	s36_warrants
rename 	r16c9	s36_other

keep hhid pid s36_*

duplicates drop hhid pid  s36_*, force
mvencode s36_*, mv(0) overr

collapse (sum) s36_meals s36_housing s36_clothing s36_health s36_warrants s36_other, by(hhid pid s36_source)

reshape wide s36_meals s36_housing s36_clothing s36_health s36_warrants s36_other , i(hhid pid) j(s36_source)

rename *1 *_1
rename *2 *_2

label var	s36_meals_1		"Meals, food items, last week, from employer"
label var	s36_housing_1	"Housing, last month, from employer"
label var	s36_clothing_1 	"Clothing, last 6 months, from employer"
label var	s36_health_1	"Medical facilities, last month, from employer"
label var	s36_warrants_1	"Warrants, last month, from employer"
label var	s36_other_1		"Other, last month, from employer"

label var	s36_meals_2		"Meals, food items, last week, from other"
label var	s36_housing_2	"Housing, last month, from other"
label var	s36_clothing_2 	"Clothing, last 6 months, from other"
label var	s36_health_2	"Medical facilities, last month, from other"
label var	s36_warrants_2	"Warrants, last month, from other"
label var	s36_other_2		"Other, last month, from other"

order hhid pid s36*
save "${out}/Section_36.dta", replace

*===============================================================================
* SECTION 3.7 - OWNER OCCUPIED SELF-ASSESSED RENT
*===============================================================================
use "${data}/Section_37.dta", clear
keep hhid r17q1 r17v1

rename r17q1	s37_own_yn
rename r17v1	s37_own_rent

label var s37_own_yn 	"The household occupied its own house 1-yes 2-no"
label var s37_own_rent	"Gross rental value per month"

save "${out}/Section_37.dta", replace
