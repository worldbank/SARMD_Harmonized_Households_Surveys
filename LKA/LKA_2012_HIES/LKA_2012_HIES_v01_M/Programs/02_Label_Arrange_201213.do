set more off
*===============================================================================
* PROJECT: SRI LANKA SCD
* Data: HIES 2012-13
* Date: 15th October 2014
* Author: Lidia Ceriani
* This dofile: Label and arrange each section
*===============================================================================
global dir  "C:\Users\wb436991\Box Sync\WB\SAR_Sri_Lanka\Data\HIES\HIES_2012_13\"
global data "${dir}\Data_dta"
global out 	"${dir}\Data_processed"

*===============================================================================
* Generate Household ID in each file
*===============================================================================

local myfilelist : dir "$data" files "sec_*"
foreach file of local myfilelist{
cd "$data"
use "`file'", clear

* Generate Household ID
*-------------------------------------------------------------------------------
* Household ID is obtained by concatenating:
* Month, Sector, District, PSU, SSU, Household Number
* Lines 10 and 11, p.1, questionnaire
* The household ID contains 10 digits: "1 2" "3" "4 5" "6 7 8" "9 10"
* "1 2" 	district
* "3" 		sector
* "4 5" 	month
* "6 7 8" 	psu
* "9 10" 	snumber
*-------------------------------------------------------------------------------

sort district sector month psu snumber hhno
sum district sector month psu snumber hhno
tostring district sector month psu snumber hhno, replace

gen zero="0"
egen temp_month 	= concat(zero month)
replace month		= substr(temp_month,-2,.)
egen temp_psu 		= concat(zero zero psu)
replace psu			= substr(temp_psu,-3,.)
egen temp_snumber	= concat(zero snumber)
replace snumber		= substr(temp_snumber,-2,.)
drop temp* zero

egen hhid=concat(district sector month psu snumber hhno)
destring district sector month psu snumber hhno, replace
label var hhid "Household ID"

* District
*-------------------------------------------------------------------------------
#delimit;
label define district 	11"Colombo"
						12"Gampaha"
						13"Kalutara"
						21"Kandy"
						22"Matale"
						23"Nuwara Eliya"
						31"Galle"
						32"Matara"
						33"Hambantota"
						41"Jaffna"
						42"Mannar"
						43"Vavuniya"
						44"Mulaitivu"
						45"Kikinochchi"
						51"Batiacaloa"
						52"Ampara"
						53"Trincomalee"
						61"Kurunegala"
						62"Puttalam"
						71"Anuradhapura"
						72"Polonnaruwa"
						81"Badulla"
						82"Monaragala"
						91"Ratnapura"
						92"Kegalle";
#delimit cr

label values district district

* Province
*-------------------------------------------------------------------------------
gen province=.				
replace province=1	if district>10	& district<	20
replace province=2	if district>20	& district<	30
replace province=3	if district>30	& district<	40
replace province=4	if district>40	& district<	50
replace province=5	if district>50	& district<	60
replace province=6	if district>60	& district<	70
replace province=7	if district>70	& district<	80
replace province=8	if district>80	& district<	90
replace province=9  if district>90
				
#delimit;			
label define province	1	"Western"
						2	"Central"
						3	"Southern"
						4	"Northen"
						5	"Eastern"
						6	"North-Western"
						7	"North-Central"
						8	"Uva"
						9	"Sabaragamuwa";
#delimit cr

label values province province

* Sector
*-------------------------------------------------------------------------------
label define sector 1"Urban" 2"Rural" 3"Estate"
label values sector sector


cd "$out"
save "`file'", replace
}

*===============================================================================
* SECTION 1 - Demographic Characteristics
*===============================================================================
use "${out}\sec_1_demographic.dta", clear
duplicates report hhid person_serial_no

	
* Personal ID
*-------------------------------------------------------------------------------
gen pid=person_serial_no


* Living somewhere else
*-------------------------------------------------------------------------------

preserve
keep if result==1
keep hhid pid sex relationship
keep if pid>40
replace pid=pid-40
drop if pid>=4   /* 36 households with more than 3 */
reshape wide sex relationship, i(hhid) j(pid)
rename relationship* migrant_reltohead_*
rename sex* migrant_sex_*
tempfile migrant
save `migrant'
restore
merge m:1 hhid using `migrant'
drop _merge

gen m=(pid>40)
bysort hhid: egen migrant_count = sum(m)
drop m

* Add variable indicating if the HH has some HH members living abroad
*-------------------------------------------------------------------------------
gen m=1 if pid>40
bysort hhid: egen migrant_hh=sum(m)
replace migrant_hh=1 if migrant_hh>1 & migrant_hh!=.
drop m

gen not_in_hh = (person_serial_no>40)
label define not_in_hh  1"Not living in the HH" 0"Living in the HH"
label values not_in_hh not_in_hh


* Relationship to the HH Head
*-------------------------------------------------------------------------------
#delimit ;
label define relationship 	1"Head" 
							2"Spouse" 
							3"Son/Daughter" 
							4"Parents" 
							5"Other Relative" 
							6"Domestic Servant"
							7"Boarder"
							9"Other" ;
#delimit cr
label values relationship relationship

*Sex
*-------------------------------------------------------------------------------
label define sex 1"Male" 2"Female"
label var sex "1-male 2-female"
label values sex sex

* Ethnicity
*-------------------------------------------------------------------------------
#delimit;
label define ethnicity 	1"Sinhala"
						2"Sri Lanka Tamil"
						3"Indian Tamil"
						4"Sri Lanka Moors"
						5"Malay"
						6"Burgher"
						9"Other";
#delimit cr
label values ethnicity ethnicity 

* Religion
*-------------------------------------------------------------------------------
#delimit;
label define religion 	1"Buddihist"
						2"Hindu"
						3"Islam"
						4"Roman Catholic/Other Christian"
						9"Other";

#delimit cr
label values religion religion 

* Marial Status
*-------------------------------------------------------------------------------
#delimit;
label define marital_status 	1"Never Married"
								2"Married"
								3"Widowed"
								4"Divorced"
								5"Separated";

#delimit cr
label values marital_status marital_status 

* Attendance at shool or other Educational Institution (for 3 years and over)
*-------------------------------------------------------------------------------
#delimit;
label define curr_educ	1"Pre school"
						2"School"
						3"University"
						4"Other educational institution"
						5"Vocational/Technical institution"
						6"Pending results GCE"
						9"Does not attend";
#delimit cr
label values curr_educ curr_educ 

				
* Level of Education (for 5 year and over)
*-------------------------------------------------------------------------------
#delimit;
label define education 	0"Studying in grade 1"
						1"Passed Grade 1"
						2"Passed Grade 2"
						3"Passed Grade 3"
						4"Passed Grade 4"
						5"Passed Grade 5"
						6"Passed Grade 6"
						7"Passed Grade 7"
						8"Passed Grade 8"
						9"Passed Grade 9"
						10"Passed Grade 10"
						11"Passed GCE or equivalent"
						12"Passed Grade 12"
						13"Passed GCE or equivalent"
						14"Passed GAQ/GSQ"
						15"Passed Degree"
						16"Passed post Graduate Diplome"
						17"PhD"
						18"Special Education unit"
						19"No Schooling";
#delimit cr
label values education education


* Main Occupation (15+)
*-------------------------------------------------------------------------------
#delimit;
label define main_activity 	1"Looking for and available to work"
							2"Student"
							3"Household work"
							4"Unable/Too old to work"
							9"Other";
#delimit cr
label values main_activity main_activity

* Employment Status in main occupation (15+)
*-------------------------------------------------------------------------------
#delimit;
label define employment_status 	1"Government Employee"
								2"Semi Government Employee"
								3"Private Sector Employee"
								4"Employee"
								5"Own account worker"
								6"Contributing family worker";
#delimit cr
label values employment_status employment_status


* Keeping only individuals living in the household who completed the interview
keep if pid<40 & result==1

merge m:1 district psu using "${data}\weights201213HIES.dta"
drop _merge
save "${out}/sec_1_demographic.dta", replace

*===============================================================================
* SECTION 2 SCHOOL EDUCATION (age 5-20)
*===============================================================================
use "${out}\sec_2_school_education.dta", clear
duplicates report hhid r2_person_serial

* Personal ID
*-------------------------------------------------------------------------------
gen pid=r2_person_serial 

* School Education
*-------------------------------------------------------------------------------
#delimit;
label define r2_school_education 	1"Currently Attending School"
									2"Never Attended"
									3"Attended in the past";
#delimit cr
label values r2_school_education r2_school_education

* Type of School 
*-------------------------------------------------------------------------------
label define type_of_school 1"Governent" 2"Private" 3"International" 
label values type_of_school type_of_school
 
* Grade (current year)
*-------------------------------------------------------------------------------
#delimit;

label define grade	 1"Grade 1"
					2"Grade 2"
					3"Grade 3"
					4"Grade 4"
					5"Grade 5"
					6"Grade 6"
					7"Grade 7"
					8"Grade 8"
					9"Grade 9"
					10"Grade 10"
					11"Grade 11"
					12"Grade 12"
					13"Grade 13"
					14"Special Education Unit"
					19"Not relevant";
 #delimit cr

label values grade_this_year grade

* Grade (last year) 
*-------------------------------------------------------------------------------
label values grade_last_year grade

* Mode of travel to school
*-------------------------------------------------------------------------------
#delimit;

label define transport_medium 	1"Walk"
								2"Bicycle"
								3"Motor bicycle/Three Wheeler/Car"
								4"School hiring Van/Bus"
								5"Bus"
								6"Train"
								9"Other";
#delimit cr

label values transport_medium transport_medium

* Reason to have ever attended school
*-------------------------------------------------------------------------------
#delimit;
label define noschooling_reason 1"School is too far away"
								2"Financial Problems"
								3"Family business"
								4"Disability/Illness"
								5"Civil disturbances"
								6"Not willing to attend/poor academic progress"
								7"Incompletion of 5 years at the beginning of the school year"
								9"Other";
#delimit cr

label values noschooling_reason noschooling_reason

* Reason not going to school
*-------------------------------------------------------------------------------
#delimit;
label define reason_not_going 	1"Further schooling not available or too far away"
								2"Financial Problems"
								3"Family business"
								4"Disability/Illness"
								5"Civil disturbances"
								6"Not willing to attend/poor academic progress"
								7"Pending results (GCE(O/L)/GCE(A/L)"
								8"Completed GCE(A/L)/Grade 13"
								9"Other";
#delimit cr
label values reason_not_going reason_not_going

* Keeping only individuals living in the household who completed the interview
keep if pid<40 & result==1

save "${out}/sec_2_school_education.dta", replace

*===============================================================================
* SECTION 3 HEALTH
*===============================================================================
use "${out}/sec_3_health.dta", clear
duplicates report hhid r3_person_serial

* Personal ID
*-------------------------------------------------------------------------------
gen pid=r3_person_serial

* Reason for Treatment
*-------------------------------------------------------------------------------
#delimit ;
label define reason 	1"Treatment for illness"
						2"Treatment for injury"
						3"Medical checkup/Consultation"
						4"Immunization"
						5"Treatment for infectious diseases (injections etc)"
						9"Other";
#delimit cr
label values reason_hospital4 reason
label values reason_for_what6 reason

* Reason for Staying
*-------------------------------------------------------------------------------
#delimit ;
label define stay 		1"Treatment for illness"
						2"Treatment for injury"
						3"Operation/Surgery"
						4"Child delivery"
						5"Treatment for infectious diseases (injections etc)"
						6"An accident"
						9"Other";
#delimit cr
label values reason_stay8 stay
label values reason_for_stay10 stay

* Ilness
*-------------------------------------------------------------------------------
#delimit ;
label define illness 	1"Heart Conditions/Diseases"
						2"Blood pressure"
						3"Diabetics"
						4"Asthma"
						5"Epilepsy"
						6"Cancer"
						7"Stomach diseasesGastritis"
						8"Diseases related to Eyes"
						9"Diseases related to Ears"
						10"Arthritis"
						11"Menthal retardation"
						12"Hemorrhoidis"
						13"Catarr"
						14"Severe Headache"
						15"Disabled at birth"
						16"Disabled by an accident"
						99"Other";
#delimit cr
label values what_ill_disable12 illness

* Keeping only individuals living in the household who completed the interview
keep if pid<40 & result==1
save "${out}/sec_3_health.dta", replace

*===============================================================================
* SECTION 5.1 - EMPLOYMENT INCOME
*===============================================================================\
use "${out}/sec_5_1_emp_income.dta", clear
gen pid=serial_no_sec_1
drop if pid>40 | result!=1
keep wages_salaries allowences bonus hhid pid pri_sec

* 24 pri_sec == . and 1 pri_sec==0
replace pri_sec=1 if pri_sec==. | pri_sec==0
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

save "${out}/sec_5_1_emp_income.dta", replace

*===============================================================================
* SECTION 5.2 - INCOME FROM AGRICULTURAL ACTIVITIES
*===============================================================================\
use "${out}/sec_5_2_agri_income.dta", clear
gen pid=col_2x
keep col_4x col_5x col_6x col_7x col_8x col_8x1 col_9x col_10x col_10x1 col_11x col_12x col_13x hhid pid
replace col_4x=9 if col_4x==.
replace col_4x=8 if col_4x==9

rename *x *
rename *x1 *_1
rename col_* s52_*_
reshape wide s52_5_ s52_6_ s52_7_ s52_8_ s52_8_1_ s52_9_ s52_10_ s52_10_1_ s52_11_ s52_12_ s52_13_, i(hhid pid) j(s52_4)

forvalues i=1(1)8{
label var s52_5_`i' 	"Cultivated area, Acres"
label var s52_6_`i' 	"Cultivated area, Roods"
label var s52_7_`i' 	"Cultivated area, Perches"
label var s52_8_`i' 	"Quantity of output, Kg"
label var s52_8_1_`i'	"Value of the output, Rs" 
label var s52_9_`i' 	"Cost of input, Rs"
label var s52_10_`i' 	"Quantity for self-consumption, Kg"
label var s52_10_1_`i' 	"Value of self-consumption, Rs"
label var s52_13_`i' 	"Fertilizer and other subsidies for last cultivation year"
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

label var s52_11_paddy 	"paddy: stock for self-consumption, Kg"
label var s52_12_paddy 	"paddy: stock for sale, Kg"

local agri_type "chilies onions vegetables cereals yams tobacco other"
foreach a of local agri_type{
drop s52_11_`a' s52_12_`a'
}
save "${out}/sec_5_2_agri_income.dta", replace

*===============================================================================
* SECTION 5.3 - INCOME FROM OTHER AGRICULTURAL ACTIVITIES
*===============================================================================
use "${out}/sec_5_3_other_agri_income.dta", clear
gen pid=ser_no_sec_5_3
* One duplicate
duplicates drop hhid pid seasonal_crop, force
keep seasonal_crop acres_5_3 roots_5_3 perchs_5_3 output_5_3 input_5_3 fertilizes hhid  pid
replace seasonal_crop=99 if seasonal_crop==16 | seasonal_crop==19 | seasonal_crop==24 |seasonal_crop==.
replace seasonal_crop=11 if seasonal_crop==99

rename *_5_3 s53_*_
rename fertilizes s53_fertilizers_
reshape wide s53_acres_ s53_roots_ s53_perchs_ s53_output_ s53_input_ s53_fertilizers_, i(hhid pid) j(seasonal_crop)

forvalues i=1(1)11{
label var s53_acres_`i'     "Cultivated area, Acres"
label var s53_roots_`i'		"Cultivated area, Roods"
label var s53_perchs_`i' 	"Cultivated area, Perches"
label var s53_output_`i' 	"Value of output, Rs"
label var s53_input_`i'		"Cost of input, Rs"
label var s53_fertilizers_`i'	"Fertilizer and other subsidies for last cultivation year"
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

save "${out}/sec_5_3_other_agri_income.dta", replace

*===============================================================================
* SECTION 5.4 - INCOME FROM NON-AGRICULTURAL ACTIVITIES
*===============================================================================\
use "${out}/sec_5_4_non_agri_income.dta", clear
gen pid=serial_5_4
keep non_agri output_5_4 input_5_4 subsidies hhid pid
replace non_agri=9 if non_agr==0 | non_agri==7 | non_agri==.
replace non_agri=7 if non_agri==9

* One duplicates
duplicates drop hhid pid non_agr, force

rename output_5_4 s54_output_
rename input_5_4  s54_input_
rename subsidies  s54_subsidies_

reshape wide s54_output_ s54_input_ s54_subsidies_, i(hhid pid) j(non_agri)

forvalues i=1(1)7{
label var s54_output_`i'     	"Value of output, Rs"
label var s54_input_`i'			"Cost of input, Rs"
label var s54_subsidies_`i' 	"Subsidies, Rs"
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
*===============================================================================\
use "${out}/sec_5_5_1_other_income.dta", clear
gen pid=serial_5_5_1
drop if pid>40 | result!=1
* One duplicate
duplicates drop hhid pid, force
rename income_forign income_abroad

keep hhid pid pension disability_and_relief property_rents property_rents samurdhi dividends elder scholar sc_lunch threeposha other_income income_abroad income_local
label var pension 				"Pension payment, last month, Rs"
label var disability_and_relief	"Disability, relief payments, last month, Rs" 
label var property_rents 		"Rents from properties, last month, Rs"
label var samurdhi 				"Samurdhi, last month, Rs"
label var dividends				"Dividends, last month, Rs" 
label var elder 				"Elderly Payment, last month, Rs"
label var scholar				"Educational and Scholarships, last month, Rs" 
label var sc_lunch 				"School food program, last month, Rs"
label var threeposha			"Triposha food program, last month, Rs" 
label var other_income 			"Other Income, last 12 months, Rs"
label var income_abroad 		"Transfer from abroad, last 12 months, Rs"
label var income_local			"Tranfers from within the coutnry, last 12 months, Rs"

rename * s551_*
rename s551_hhid hhid
rename s551_pid pid

save "${out}/sec_5_5_1_other_income.dta", replace

*===============================================================================
* SECTION 5.5.2 - WINDFALL INCOME
*===============================================================================\
use "${out}/sec_5_5_2_windfall_income.dta", clear
gen pid=person_5_5_2
drop if pid>40 | result!=1
rename seettu_debits seettu_debts
keep hhid pid loans pawning_selling deposits_pensions_epf welfare_socity seettu_debts medical insuarance lottery foodallowence diaster
label var loans 				"Loans taken, last 12 months, Rs"
label var pawning_selling 		"Sale of assets (land, house, jewellary), last 12 months, Rs"
label var deposits_pensions_epf "Withdrawals from savings et al, last 12 months, Rs"
label var welfare_socity 		"Income receives from births, deaths, marriages, last 12 months, Rs"
label var seettu_debts 			"Seettu, repayments of loans given, last 12 months, Rs"
label var medical 				""
label var insuarance 			"Compensation insurance, last 12 months, Rs"
label var lottery 				"Other lottery/Ad hoc gains, last 12 months, Rs"
label var foodallowence 		"Food allowance, last 12 months, Rs"
label var diaster				"Disaster Relief Assistance, last 12 months, Rs"

rename * s552_*
rename s552_hhid hhid
rename s552_pid pid
rename s552_insuarance  	s552_insurance
rename s552_foodallowence  	s552_foodallowance
rename s552_diaster			s552_disaster
rename s552_welfare_socity	s552_gifts
save "${out}/sec_5_5_2_windfall_income.dta", replace

