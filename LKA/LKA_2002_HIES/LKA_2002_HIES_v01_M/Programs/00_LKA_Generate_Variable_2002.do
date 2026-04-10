set more off
*===============================================================================
* PROJECT: SRI LANKA SCD
* Data: HIES 2001-02
* Date: 7th November 2014
* Author: Lidia Ceriani
* This dofile: Profiling of the poor and the bottom 40
*===============================================================================

global dir  "C:\Users\wb436991\Box Sync\WB\SAR_Sri_Lanka\"
global data "${dir}\Data\HIES\HIES_2001_02\Data_processed\poverty"
global raw "${dir}\Data\HIES\HIES_2001_02\Data_processed"
global out "${dir}\Data\HIES\HIES_2001_02\Data_processed\profile"

*===============================================================================
* Define Local with the variable you are using below
* This should be the only section of the dofile to change, along with the 
* datasets names below
*===============================================================================

*local	do not change				change with variable in your dataset
*-------------------------------------------------------------------------------
* Section 1
local 	pid							pno
local 	district 					district
local 	province					prov
local 	sector						sector
local 	age							age
local 	sex							sex
local 	curr_educ					educat	
local 	industry					industry
local 	labour_force_status 		u_acti	
local	edu_attained				educat 
local	reltohead					r_ship
local 	ethnicity					ethnicity
local 	religion					religion
local 	migrant_hh					pno

* Section Education (missing)
local 	type_of_school				type_of_school
local 	edu_distance_to				distance
local	edu_mean_to					transport_medium
local	edu_time_to					time_to_school
local	access_edu_preschool_time		.
local	access_edu_preschool_distance	.
local	access_edu_primary_time			.
local	access_edu_primary_distance		.
local 	access_edu_secondary_time		.
local 	access_edu_secondary_distance	.

* Section Health (missing)
local	health_disability				is_ill_disable		
local 	health_out_gov					.   	
local	health_out_priv					.
local	health_in_gov					is_stay_govhospital7
local	health_in_priv					stay_in_privte_hospital9
local	access_hospital_time			hospital_time		
local	access_hospital_distance		hospital
local	access_maternity_time			maternity_home_time
local	access_maternity_distance		matrenity_home
local	access_clinic_time				maternity_clinic_time
local	access_clinic_distance			maternity_clinic
local	access_dispensory_time_gov		gov_dispensary_time		
local	access_dispensory_distance_gov	gov_dispensarz
local	access_dispensory_time_priv		private_dispensary_ti
local	access_dispensory_distance_priv	private_dispensary
				
* Section Consumption
local 	nf_code						item
local 	nf_value		 			value

* Section 31
local	income_empl_hh				is_employment_income

* Section 34
local	income_agri_hh				r11q1

* Section 35
local	income_agri_other_hh		r13q1

* Section 33
local 	income_non_agri_hh			r9q1

* Section 32
local 	income_nlabor_hh			is_other_income
local	sp_samurdhi					s551_samurdhi 			
local	sp_schoolfood				s551_sc_lunch
local	sp_triposhfood				s551_threeposha
local   sp_pension					s551_pension
local   sp_elderly					s551_elder
local 	sp_disability				s551_disability_and_relief

* Source: DCS Colombo Price Index, base 2006/07
* monthly average between July t and June t+1
*-------------------------------------------------------------------------------
local cpi0102_02base   = 100
local cpi0607_02base   = 150.5
local cpi0910_02base   = 212.8
local cpi0910_0607base = 137.93
local cpi1213_0607base = 169.21

* Between 2009/10 and 2012/13 surveys, the base year for the ccpi has been changed
* From 2002 to 2006/07. The adj_factor_0910 make sure we get the same poverty
* for 2009 in 2012/13 prices. It is obtained as the ratio between the poverty line
* for 2009/10 inflating the 2002 line with base02 and base0607
*-------------------------------------------------------------------------------
local adj_factor_0910 = 1.025

* Similar for 2006/07. The official poverty estimates are based on a povery line
* of Rs 2233, which is the poverty line obtained by inflating 2002 poverty line
* with a ccpi base 02. When the poverty line is instead obtained by using ccpi 0607
* the poverty line is 2142
*-------------------------------------------------------------------------------
local adj_factor_0607 = 1.043

* Consumption
local 	hh_exp						ncons
local 	exp							exp
local 	pline_nat  					3624.442 

* International Poverty Lines
local 	pline_125					3028.9						
local 	pline_250					6057.8
local 	pline_400					9692.401


* Prepare some dataset
*-------------------------------------------------------------------------------
use "${raw}\Section_1.dta", clear
gen m=(`migrant_hh'>40)
bysort hhid: egen migrant_hh = sum(m)
drop m
replace migrant_hh=1 if migrant_hh>1
rename `pid' pid
drop if pid>40 
drop if rcode ~=1
gen age_old=age
count if age==.
replace age=0 if age>=.
tempfile sect1_demo
save `sect1_demo'

use "${raw}\Section_22.dta", clear
preserve
keep if  `nf_code'>=2601 & `nf_code'<=2619
collapse (sum) `nf_value', by(hhid)
rename `nf_value' edu_exp
label var edu_exp "Nominal Monthly HH Expenditure for Education"
tempfile edu_exp
save `edu_exp'
restore

preserve
keep if  `nf_code'>=2301 & `nf_code'<=2319
collapse (sum) `nf_value', by(hhid)
rename `nf_value' health_exp
label var health_exp "Nominal Monthly HH Expenditure for Health"
tempfile health_exp
save `health_exp'
restore

preserve
keep if  `nf_code'==2101
collapse (sum) `nf_value', by(hhid)
rename `nf_value' electricity_exp
label var electricity_exp "Nominal Monthly HH Expenditure for Electricity"
tempfile electricity_exp
save `electricity_exp'
restore

preserve
keep if  `nf_code'>=2502 & `nf_code'<=2504
collapse (sum) `nf_value', by(hhid)
rename `nf_value' phone_exp
label var phone_exp "Nominal Monthly HH Expenditure for Telephone"
tempfile phone_exp
save `phone_exp'
restore

preserve
keep if  `nf_code'>=2401 & `nf_code'<=2419
collapse (sum) `nf_value', by(hhid)
rename `nf_value' transport_exp
label var transport_exp "Nominal Monthly HH Expenditure for Transport"
tempfile transport_exp
save `transport_exp'
restore

use "${raw}\Section_31.dta", clear
keep hhid
gen `income_empl_hh'=1
collapse (mean) `income_empl_hh', by(hhid)
tempfile is_income_empl_hh
save `is_income_empl_hh'

use "${raw}\Section_32.dta", clear 
keep hhid
gen `income_nlabor_hh'=1
collapse (mean) `income_nlabor_hh', by(hhid)
tempfile is_income_nlabor_hh
save `is_income_nlabor_hh'

use "${raw}\Section_33.dta", clear 
mvencode _all, mv(0) overr
egen output_max = rowmax(s54_output_mining_quarrying s54_output_manufacturing s54_output_construction s54_output_trade s54_output_transport s54_output_hotel_restaurant s54_output_other)
tempfile income_nagri
save `income_nagri'


use "${raw}\Section_33_filter.dta", clear
keep `income_non_agri_hh' hhid 
replace `income_non_agri_hh'=0 if `income_non_agri_hh'==2
tempfile is_income_non_agri_hh
save `is_income_non_agri_hh'


use "${raw}\Section_34_filter.dta", clear
keep `income_agri_hh' hhid
replace `income_agri_hh'=0 if `income_agri_hh'==2
tempfile is_income_agri_hh
save `is_income_agri_hh'

use "${raw}\Section_35_filter.dta", clear
keep 	`income_agri_other_hh' hhid
replace `income_agri_other_hh'=0 if `income_agri_other_hh'==2
tempfile is_income_agri_other_hh
save `is_income_agri_other_hh'

use "${raw}\Section_36.dta", clear
forvalues i=1(1)2{
replace s36_meals_`i'	=(s36_meals_`i'/7)*365/12
replace s36_clothing_`i'= s36_clothing_`i'/6
}
label var	s36_meals_1		"Meals, food items, monthly, from employer"
label var	s36_clothing_1 	"Clothing, monthly, from employer"
label var	s36_meals_2		"Meals, food items, monthly, from other"
label var	s36_clothing_2 	"Clothing, monthly, from other"
tempfile in_kind_income
save `in_kind_income'

* Merge Dataset together
*-------------------------------------------------------------------------------

* Open the dta where you have the consumption aggregate
*-------------------------------------------------------------------------------
use "${data}/wfile200102.dta", clear
keep 	hhid district province sector psu month weight hhsize ///
		mfval mlt_val mnf_val mnf_val_drop ///
		sb_food sb_nfood sb_exp  ///
		tm_food tm_nfood  ///
		ncons npccons npcexpd  ///
		cpi_dcs  ///
		rcons rpccons* rpcexpd  ///
		pov_line poor fval* rpc_fval* nfval* rpc_nfval* cpi*


* And with all other section of the dataset
*-------------------------------------------------------------------------------
merge 1:1 hhid using `is_income_empl_hh'
drop _merge
merge 1:1 hhid using `is_income_agri_hh'
drop _merge
merge 1:1 hhid using `is_income_agri_other_hh'
drop _merge
merge 1:1 hhid using `is_income_non_agri_hh'
drop _merge
merge 1:1 hhid using `is_income_nlabor_hh'
drop _merge
merge m:1 hhid using `edu_exp'
drop _merge
merge m:1 hhid using `health_exp'
drop _merge
merge m:1 hhid using `electricity_exp'
drop _merge
merge m:1 hhid using `phone_exp'
drop _merge
merge m:1 hhid using `transport_exp'
drop _merge
merge m:1 hhid using "${raw}/Section_37"
drop _merge

* Merge it with dta with individual information
*-------------------------------------------------------------------------------
merge 1:m hhid using `sect1_demo'
assert _merge==3
drop _merge
merge m:1 hhid pid using "${raw}\Section_31.dta" 
tab _m
drop if _m==2 																	
drop _merge
mvencode is_employment_income, mv(0) overr

merge m:1 hhid pid using "${raw}\Section_32.dta" 
tab _m
drop if _m==2 																	
drop _merge
mvencode is_other_income, mv(0) overr

merge m:1 hhid pid using `income_nagri'
tab _m
drop if _m==2 																	
drop _merge
merge m:1 hhid pid using "${raw}\Section_34.dta" 
tab _m
drop if _m==2 																	
drop _merge
merge m:1 hhid pid using "${raw}\Section_35.dta" 
tab _m
drop if _m==2 																	
drop _merge
merge m:1 hhid pid using `in_kind_income'
tab _m
drop if _m==2 																	

*===============================================================================
* Add variables which are not in 2001/02
*===============================================================================
* Education
gen type_of_school 			= .
gen distance 				= .
gen transport_medium 		= .
gen time_to_school 			= .

* Health
gen	is_ill_disable			= .	
gen is_stay_govhospital7	= .
gen stay_in_privte_hospital9 = .

gen hospital_time			=.		
gen hospital				=.
gen maternity_home_time		=.
gen matrenity_home			=.
gen maternity_clinic_time	=.
gen maternity_clinic		=.
gen gov_dispensary_time		=.	
gen gov_dispensarz			=.
gen private_dispensary_ti	=.
gen private_dispensary		=.

gen s551_sc_lunch = .  
gen s551_threeposha = .
gen s551_elder = .
gen s551_scholar = .
gen s552_disaster = .
gen camera=.
gen mechine=.
gen debt_ccards = .
gen debt_ccards_amount = .
gen credit_atm = .

* Water
gen water_main_other = .
*-------------------------------------------------------------------------------
* 	Categories
*-------------------------------------------------------------------------------
	gen		country		=	"LKA"
	gen 	year		=	2002
	gen 	urban		=  	sector
	gen 	overall		=  	1

* Weight
*-------------------------------------------------------------------------------
	gen 		hh_weight	=	weight / hhsize
	label var 	hh_weight 	"weight/hhsize: use on the individual level dataset to have share of households"

	gen 		ind_weight	=	weight 
	label var 	ind_weight 	"weight: use on the individual level dataset to have share of individuals"

	gen 		ind_head_weight	= weight*hhsize
	label var	ind_head_weight "weight: use the household level dataset to have share of individuals"

* Generate a consumption aggregate not including exceptional expenses and durables
*-------------------------------------------------------------------------------
		mvencode rpccons mnf_val_drop, mv(0) overr
		gen rpccons_trim = rpccons-mnf_val_drop

* Consumption aggregate at 2012/13 prices
*-------------------------------------------------------------------------------
		gen exp = rpccons
		gen exp_trim = rpccons_trim

		replace exp = ((exp/`cpi0102_02base')*`cpi0910_02base')
		replace exp = ((exp/`cpi0910_0607base')*`cpi1213_0607base')/`adj_factor_0910'

		replace exp_trim = ((exp_trim/`cpi0102_02base')*`cpi0910_02base')
		replace exp_trim = ((exp_trim/`cpi0910_0607base')*`cpi1213_0607base')/`adj_factor_0910'

* From now on, the dofile should work without any change even with previous years
*===============================================================================

* Make sure all expenditure are not missing
*-------------------------------------------------------------------------------
mvencode *_exp, mv(0) overr

* Add districts which are not in 2002
*-------------------------------------------------------------------------------
sum pid
local N=r(N)
local obs_1=`N'+1
local obs_2=`N'+2
local obs_3=`N'+3
local obs_4=`N'+4
local obs_5=`N'+5
local obs_6=`N'+6
local obs_7=`N'+7
local obs_8=`N'+8

set obs `obs_8'
replace district = 41 in `obs_1'
replace district = 42 in `obs_2'
replace district = 43 in `obs_3'
replace district = 44 in `obs_4'
replace district = 45 in `obs_5'
replace district = 51 in `obs_6'
replace district = 52 in `obs_7'
replace district = 53 in `obs_8'

* And province
replace province = 4 	if district>40 & district<50
replace province = 5  	if district>50 & district<60

* Generate dummy for each district
*-------------------------------------------------------------------------------		
	levelsof `district', local(levels)
	foreach l of local levels {
	gen dis_`l'=(`district' ==`l')
	}

* Generate dummy for each province
*-------------------------------------------------------------------------------	
	levelsof `province', local(provinces)
	foreach l of local provinces {
	gen prov_`l'=(`province' ==`l')
	}
	label define province 1"Western" 2"Central" 3"Southern" 4"Northen" 5"Eastern" 6"North-Western" 7"North-Central" 8"Uva" 9"Sabaragamuwa"
	label values `province' province

* Generate dummy for each sector
*-------------------------------------------------------------------------------	
	levelsof `sector', local(levels)
	foreach l of local levels {
	gen sector_`l'=(`sector' ==`l')
	}
	cap drop urban 
	cap drop rural
	cap drop estate
	
	rename sector_1 urban
	rename sector_2 rural
	rename sector_3 estate
	
* Generate dummy for each gender 
*-------------------------------------------------------------------------------	
	gen male	=(`sex'==1)
	gen female	=(`sex'==2)
	
	bysort hhid: gen male_hh = sum(male==1 & `reltohead'==1)
	bysort hhid: gen female_hh = sum(female==1 & `reltohead'==1)

 * 	Reference Population
*-------------------------------------------------------------------------------
	gen 	pline_125 	= `pline_125'
	gen 	pline_250 	= `pline_250'
	gen 	pline_400	= `pline_400'
	
	gen		poor_nat 	= (`exp'<`pline_nat') 
	gen		npoor_nat	= (poor_nat==0) 
	
	gen 	poor_125	= (`exp'<`pline_125')
	gen 	npoor_125	= (poor_125==0)
	
	gen 	poor_250	= (`exp'<`pline_250')
	gen 	npoor_250	= (poor_125==0)

	gen 	poor_400	= (`exp'<`pline_400')
	gen 	npoor_400	= (poor_400==0)
	
	local poor "poor_nat npoor_nat poor_125 npoor_125 poor_250 npoor_250 poor_400 npoor_400" 
	foreach p of local poor{
	replace `p'=. if hhid==""
	}
	
	xtile decile=`exp' [aw=ind_weight], nq(10)
	forvalues i=1(1)9{
	gen p0`i'=(decile==`i')
	}
	gen p10=(decile==10)	

	gen b40 = (decile==1|decile==2|decile==3|decile==4)
	gen t60 = (b40==0)
	
*	Demographic Information		
*-------------------------------------------------------------------------------
* Gender
*-------------------------------------------------------------------------------
	gen	gender	=	(`sex'==1)

* Relation to household head
*-------------------------------------------------------------------------------
	gen reltohead = `reltohead'
	gen head=(`reltohead'==1)

* Age
*-------------------------------------------------------------------------------
	gen child		= (`age'<15)
	bysort hhid: egen n_child = sum(child)
	
	gen elderly		= (`age'>=65)
	bysort hhid: egen n_elderly = sum(elderly)
	
	gen adult		= (`age'>=15)
	bysort hhid: egen n_adult = sum(adult)
	
	gen age_1529 		= (`age'>=15 & `age'<=29)
	replace age_1529 	= . if `age'<15
	
	gen age_3049 		= (`age'>=30 & `age'<=49)
	replace age_3049 	= . if `age'<15
	
	gen age_5064 		= (`age'>=50 & `age'<=64)
	replace age_5064 	= . if `age'<15
	
	gen age_65 			= (`age'>=65)
	replace age_65 		= . if `age'<15

* Ethnicity
*-------------------------------------------------------------------------------
	gen ethnic_sinhala 	= (`ethnicity' ==1)
	gen ethnic_sl_tamil	= (`ethnicity' ==2)
	gen ethnic_in_tamil	= (`ethnicity' ==3)
	gen ethnic_sl_moors	= (`ethnicity' ==4)
	gen ethnic_other 	= (`ethnicity'>4)
	
	label var  ethnic_sinhala 	"Ethnicity: Sinhala"
	label var  ethnic_sl_tamil 	"Ethnicity: Sri Lanka Tamil"
	label var  ethnic_in_tamil 	"Ethnicity: Indian Tamil"
	label var  ethnic_sl_moors 	"Ethnicity: Sri Lanka Moors"
	label var  ethnic_other 	"Ethnicity: Others (Malay, Burger, Other)"

* Religion
*-------------------------------------------------------------------------------
	gen religion_buddisth	= (`religion' ==1)
	gen religion_hindu		= (`religion' ==2)
	gen religion_islam		= (`religion' ==3)
	gen religion_cristian	= (`religion' ==4)
	gen religion_other 		= (`religion'>4)
	
	label var  religion_buddisth 	"Religion: Buddisth"
	label var  religion_hindu 		"Religion: Hindu"
	label var  religion_islam 		"Religion: Islam"
	label var  religion_cristian 	"Religion: Roman Catholic/Other Christian"
	label var  religion_other 		"Religion: Others"

* Education
*-------------------------------------------------------------------------------	
	gen 	edu_years	=	`edu_attained'
	replace edu_years	=	0 		if   	`edu_attained'==19 

	gen edu_years_20plus = edu_years if age>=20
	gen edu_years_head	 = edu_years if reltohead==1
																				
	gen		 edu_attendance_3_4			= .
	replace  edu_attendance_3_4			= 1 if `curr_educ'==1 | `curr_educ'==4
	replace  edu_attendance_3_4			= 0 if `curr_educ'==7 
	replace  edu_attendance_3_4			= . if `age'<3 | `age'>4	
	label define edu_attendance_3_4 1 "Pre School or Other educational institution" 0"Not Attending"
	label values edu_attendance_3_4 edu_attendance_3_4
	
		
	gen		edu_attendance_5_20		= .
	replace edu_attendance_5_20		= 1 if `curr_educ'>=1 & `curr_educ'<=6 		/*shiva_note some are attending pre school as not completed 5 year at addmision */
	replace edu_attendance_5_20		= 0 if `curr_educ'==0 | `curr_educ'>=7	
	replace edu_attendance_5_20		= . if `age'<5 | `age'>20
	label define edu_attendance_5_20 1"School or Other educational institution" 0"Not Attending"
	label values edu_attendance_5_20 edu_attendance_5_20

		
	gen	edu_school_type					= 0
	replace edu_school_type				= 1 if `type_of_school'==1
	replace edu_school_type				= 2 if `type_of_school'==2 | `type_of_school'==3
	replace edu_school_type				= . if `age'<5 | `age'>20
	label define edu_school_type 1"Public" 2"Private"
	label values edu_school_type edu_school_type
		
	gen edu_school_type_public			= (edu_school_type==1)
	replace edu_school_type_public	 	= . if edu_school_type==.
	gen edu_school_type_private			= (edu_school_type==2)
	replace edu_school_type_private 	= . if edu_school_type==.
	
	
	gen	edu_distance_to					= `edu_distance_to'
	
	gen	edu_mean_to						= `edu_mean_to'
	replace edu_mean_to = 9 if edu_mean_to==0 | edu_mean_to==7
	
	gen edu_mean_walk = (edu_mean_to==1)
	gen edu_mean_bike = (edu_mean_to==2)
	gen edu_mean_motor = (edu_mean_to==3)
	gen edu_mean_schbus = (edu_mean_to==4)
	gen edu_mean_bus = (edu_mean_to==5)
	gen edu_mean_train = (edu_mean_to==6)
	gen edu_mean_other = (edu_mean_to==9)
	local edu_mean walk bike motor schbus bus train other
	foreach m of local edu_mean{
	replace edu_mean_`m'=. if edu_mean_to==.
	}

	gen	edu_time_to						= `edu_time_to'

	gen	edu_attained					= `edu_attained'

	gen	access_edu_preschool_time		= `access_edu_preschool_time'

	gen	access_edu_preschool_distance	= `access_edu_preschool_distance'

	gen	access_edu_primary_time			= `access_edu_primary_time'

	gen	access_edu_primary_distance		= `access_edu_primary_distance'

	gen	access_edu_secondary_time		= `access_edu_secondary_time'

	gen	access_edu_secondary_distance	= `access_edu_secondary_distance'

	gen	edu_sh							= edu_exp / `hh_exp'

	gen edu_0_none_u_primary				= `edu_attained'==0 | `edu_attained'<5 | `edu_attained'==19
	gen edu_1_primary						= `edu_attained'>=5 & `edu_attained'<9
	gen edu_2_jr_secondary					= `edu_attained'>=9 & `edu_attained'<11
	gen edu_3_sr_secondary					= `edu_attained'>=11 & `edu_attained'<13
	gen edu_4_collegiate					= `edu_attained'==13
	gen edu_5_tertiary						= `edu_attained'>13 & `edu_attained'<17

* 	Health
*-------------------------------------------------------------------------------
	local varlist "`health_disability' `access_hospital_time' `access_hospital_distance' `access_maternity_time' `access_maternity_distance' `access_clinic_time' `access_clinic_distance'"

	rename	`health_disability'			 health_disability
	rename	`access_hospital_time'		 access_hospital_time
	rename	`access_hospital_distance'	 access_hospital_distance
	rename	`access_maternity_time'		 access_maternity_time
	rename	`access_maternity_distance'	 access_maternity_distance
	rename	`access_clinic_time'		 access_clinic_time
	rename	`access_clinic_distance'	 access_clinic_distance

	gen		access_dispensory_time	 	= min(`access_dispensory_time_gov' ,`access_dispensory_time_priv')
	gen		access_dispensory_distance  = min(`access_dispensory_distance_gov' , `access_dispensory_distance_priv')

	gen 	health_sh			 	= health_exp / `hh_exp'
	gen 	health_sh_10			= (health_sh>0.10)
	gen 	health_sh_25			= (health_sh>0.25)

*	Electricity		
*-------------------------------------------------------------------------------
	gen	electricity_hh				= (electricity_exp>0 & electricity_exp!=.)
	gen	electricity_sh				= electricity_exp / `hh_exp'


*	Telephone		
*-------------------------------------------------------------------------------
	gen	phone_sh					= phone_exp / `hh_exp'

*	Social_Protection		
*-------------------------------------------------------------------------------
	bysort hhid: egen	sp_samurdhi_hh		=	total(`sp_samurdhi'>0 	& `sp_samurdhi'!=.)
	bysort hhid: egen	sp_pension_hh		=	total(`sp_pension'>0   &    `sp_pension'!=.)
	bysort hhid: egen	sp_disability_hh	=	total(`sp_disability'>0   &   `sp_disability'!=.)

	replace sp_samurdhi_hh = 1 		if sp_samurdhi_hh>1
	replace sp_pension_hh = 1 		if sp_pension_hh>1
	replace sp_disability_hh = 1 	if sp_disability_hh>1
	

*===============================================================================
* Income
*===============================================================================

* Household receiving each type of income
*-------------------------------------------------------------------------------
	rename `income_empl_hh'  		income_empl_hh_d
	rename `income_agri_hh'	 		income_agri_hh_d
	rename `income_agri_other_hh'	income_agri_other_hh_d
	rename `income_non_agri_hh'		income_non_agri_hh_d
	rename `income_nlabor_hh'		income_nlabor_hh_d

* Employment
*-------------------------------------------------------------------------------
	egen  	income_empl_wage_i 		= rowtotal(s51_wages*)
	egen 	income_empl_allowance_i = rowtotal(s51_allowance*)
	egen 	income_empl_bonus_i		= rowtotal(s51_bonus*)
	replace income_empl_bonus_i		= income_empl_bonus_i / 12
	egen 	income_empl_i			= rowtotal(income_empl_wage_i income_empl_allowance_i income_empl_bonus_i)
	
	bysort hhid: egen  	income_empl_wage_hh 		= sum(income_empl_wage_i)
	bysort hhid: egen 	income_empl_allowance_hh 	= sum(income_empl_allowance_i)
	bysort hhid: egen 	income_empl_bonus_hh 		= sum(income_empl_bonus_i)
	
	gen 	income_empl_wage_pc			= income_empl_wage_hh		/hhsize
	gen 	income_empl_allowance_pc 	= income_empl_allowance_hh	/hhsize
	gen 	income_empl_bonus_pc 		= income_empl_bonus_hh		/hhsize	
	
	egen 	income_empl_pc				= rowtotal(income_empl_wage_pc income_empl_allowance_pc income_empl_bonus_pc)

* Main Job
*-------------------------------------------------------------------------------
forvalues n=1(1)2{
	egen  	income_empl_wage_`n'_i 			= rowtotal(s51_wages*_`n')
	egen 	income_empl_allowance_`n'_i 	= rowtotal(s51_allowance*_`n')
	egen 	income_empl_bonus_`n'_i			= rowtotal(s51_bonus*_`n')
	replace income_empl_bonus_`n'_i			= income_empl_bonus_`n'_i / 12
	egen 	income_empl_`n'_i				= rowtotal(income_empl_wage_`n'_i income_empl_allowance_`n'_i income_empl_bonus_`n'_i)
	
	bysort hhid: egen  	income_empl_wage_`n'_hh 		= sum(income_empl_wage_`n'_i)
	bysort hhid: egen 	income_empl_allowance_`n'_hh 	= sum(income_empl_allowance_`n'_i)
	bysort hhid: egen 	income_empl_bonus_`n'_hh		= sum(income_empl_bonus_`n'_i)
	bysort hhid: egen 	income_empl_`n'_hh 			= sum(income_empl_`n'_i)
	
	gen 	income_empl_wage_`n'_pc			= income_empl_wage_`n'_hh		/hhsize
	gen 	income_empl_allowance_`n'_pc 	= income_empl_allowance_`n'_hh	/hhsize
	gen 	income_empl_bonus_`n'_pc		= income_empl_bonus_`n'_hh		/hhsize	
	gen 	income_empl_`n'_pc				= income_empl_`n'_hh 			/ hhsize
}	

* Agricultural
*-------------------------------------------------------------------------------
* Individual Level
	egen 	income_agri_output_i 	= rowtotal(s52_8_1_*)
	egen 	income_agri_input_i 	= rowtotal(s52_9_*)
	egen 	income_agri_self_i 		= rowtotal(s52_10_*)

* Monthly
	replace 	income_agri_output_i 	= income_agri_output_i	/ 12
	replace 	income_agri_input_i 	= income_agri_input_i	/ 12
	replace 	income_agri_self_i 		= income_agri_self_i	/ 12
	gen 		income_agri_net_i		= income_agri_output_i - income_agri_input_i
	replace 	income_agri_net_i		= income_agri_self_i - income_agri_input_i if income_agri_self_i>income_agri_output_i & income_agri_self_i!=.
	replace 	income_agri_net_i      = 0 if income_agri_net_i <0

* Household Level
	bysort hhid: egen 	income_agri_output_hh		= sum(income_agri_output_i)
	bysort hhid: egen 	income_agri_input_hh		= sum(income_agri_input_i)
	bysort hhid: egen 	income_agri_self_hh			= sum(income_agri_self_i)
	bysort hhid: egen 	income_agri_net_hh			= sum(income_agri_net_i)

* Per capita level
	gen 	income_agri_output_pc 		= income_agri_output_hh	/hhsize
	gen 	income_agri_input_pc 		= income_agri_input_hh	/hhsize
	gen 	income_agri_self_pc 		= income_agri_self_hh	/hhsize
	gen 	income_agri_net_pc			= income_agri_net_hh 	/hhsize
	

* Other Agricultural
*-------------------------------------------------------------------------------
* Individual Level
	egen 	income_oagri_output_i 	= rowtotal(s53_output*)
	egen 	income_oagri_input_i 	= rowtotal(s53_input*)
	egen 	income_oagri_self_i 	= rowtotal(s53_self*)

* Monthly (is already monthly)
	gen 		income_oagri_net_i		= income_oagri_output_i  - income_oagri_input_i
	replace 	income_oagri_net_i		= income_oagri_self_i  - income_oagri_input_i if income_oagri_self_i>income_oagri_output_i & income_oagri_self_i!=.
	replace 	income_oagri_net_i      = 0 if income_oagri_net_i <0
	
* Household Level
	bysort hhid: egen 	income_oagri_output_hh		= sum(income_oagri_output_i)
	bysort hhid: egen 	income_oagri_input_hh		= sum(income_oagri_input_i)
	bysort hhid: egen 	income_oagri_self_hh		= sum(income_oagri_self_i)
	bysort hhid: egen 	income_oagri_net_hh			= sum(income_oagri_net_i)
	
* Per capita level
	gen		income_oagri_output_pc 		= income_oagri_output_hh /hhsize
	gen		income_oagri_input_pc 		= income_oagri_input_hh	 /hhsize
	gen		income_oagri_self_pc 		= income_oagri_self_hh	 /hhsize	
	gen 	income_oagri_net_pc			= income_oagri_net_hh 	/ hhsize

	replace income_oagri_net_pc			= 0 if income_oagri_net_pc<0

* Agricultural + Other Agricultural
*-------------------------------------------------------------------------------
	gen 	income_farm_net_i		= income_agri_net_i + income_oagri_net_i
	gen 	income_farm_net_hh		= income_agri_net_hh + income_oagri_net_hh
	gen 	income_farm_net_pc		= income_agri_net_pc + income_oagri_net_pc

* Non Agriculture
*-------------------------------------------------------------------------------
* Individual Level
	egen 	income_nagri_output_i 	= rowtotal(s54_output*)
	egen 	income_nagri_input_i 	= rowtotal(s54_input*)
	gen 	income_nagri_net_i		= income_nagri_output_i - income_nagri_input_i
	replace income_nagri_net_i      = 0 if income_nagri_net_i <0

* Household Level
	bysort hhid: egen 	income_nagri_output_hh		= sum(income_nagri_output_i)
	bysort hhid: egen 	income_nagri_input_hh		= sum(income_nagri_input_i)
	bysort hhid: egen 	income_nagri_net_hh			= sum(income_nagri_net_i)

* Per capita level
	gen	 income_nagri_output_pc 	= income_nagri_output_hh	/hhsize
	gen	 income_nagri_input_pc 		= income_nagri_input_hh		/hhsize
	gen	 income_nagri_net_pc 		= income_nagri_net_hh		/hhsize

* Total Labor Income
*-------------------------------------------------------------------------------
* Individual Level
	egen 	income_labor_i 	= rowtotal(income_empl_i  income_farm_net_i income_nagri_net_i)
	
* Household Level
	bysort hhid: egen 	income_labor_hh	= sum(income_labor_i)

* Per capita level
	gen income_labor_pc = income_labor_hh	/hhsize

* Other Non labor Income
*-------------------------------------------------------------------------------
* Monthly for transfer
	replace s551_income_abroad 	= s551_income_abroad	/12
	replace s551_income_local  	= s551_income_local		/12

* Individual Level
	egen 	income_nlabor_i 	= rowtotal(s551_*)
	
* Household Level
	bysort hhid: egen 	income_nlabor_hh	= sum(income_nlabor_i)

* Per capita level
	gen income_nlabor_pc = income_nlabor_hh	/hhsize

* In particular: Pensions, Relief, Rents, Samurdhi, Dividends, Other, Remittances from abroad, Domestic Transfers
*-------------------------------------------------------------------------------
rename *income_abroad *abroad
rename *income_local  *local
local other_income "pension disability_and_relief property_rents samurdhi dividends elder scholar sc_lunch threeposha other_income abroad local"
foreach oi of local other_income{
* Individual Level
	egen 	income_`oi'_i 	= rowtotal(s551_`oi')
	
* Household Level
	bysort hhid: egen 	income_`oi'_hh	= sum(income_`oi'_i)

* Per capita level
	gen income_`oi'_pc = income_`oi'_hh	/hhsize
}

* IN KIND INCOME
*-------------------------------------------------------------------------------
* Fix rental income
	replace s37_own_rent = s37_own_rent/hhsize
	
* Individual Level
	egen income_inkind_i = rowtotal(s36* s37_own_rent)

* Household Level
	bysort hhid: egen 	income_inkind_hh = sum(income_inkind_i)

* Per Capita Level	
	gen 	income_inkind_pc = income_inkind_hh / hhsize

* TOTAL INCOME (Wage + Farm + NonFarm + Other)
*-------------------------------------------------------------------------------
* Individual Level
#delimit ;
	egen 	income_tot_i	= rowtotal(	income_labor_i
										income_nlabor_i 
										income_inkind_i
										) ;
#delimit cr

* Household Level
#delimit ;
	egen 	income_tot_hh	= rowtotal(	income_labor_hh
										income_nlabor_hh
										income_inkind_hh
										) ;
#delimit cr

* Per capita level
#delimit ;
	egen 	income_tot_pc	= rowtotal(	income_labor_pc
										income_nlabor_pc
										income_inkind_pc
										) ;
#delimit cr

local  income "empl agri_net oagri_net farm_net nagri_net labor nlabor inkind"
foreach i of local income{
gen income_sh_`i' = income_`i'_hh/income_tot_hh
label var income_sh_`i' "Share of `i' income in total income"
}

* Generate max labor income source (excluding inkind and nonlabor)
*-------------------------------------------------------------------------------
* NB: the max function ignores missing values

* At individual Level
*gen 	max_income_i 	= max(income_empl_i ,  income_farm_net_i , income_nagri_net_i, income_nlabor_i)
gen 	max_income_i 	= max(income_empl_i ,  income_farm_net_i , income_nagri_net_i)
replace max_income_i = .  if max_income_i == 0  & `labour_force_status'!=1

* At household Level
*gen 	max_income_hh 	= max(income_empl_hh , income_farm_net_hh , income_nagri_net_hh, income_nlabor_hh)
gen 	max_income_hh 	= max(income_empl_hh , income_farm_net_hh , income_nagri_net_hh)
replace max_income_hh = . if max_income_hh == 0 & `labour_force_status'!=1


* Industry (for 2006 ISIC Rev.3.1)
* http://unstats.un.org/unsd/cr/registry/regcst.asp?Cl=17
*-------------------------------------------------------------------------------
	gen industry=.
	replace industry = s51_industry_1 if income_empl_i==max_income_i
	
	replace industry = 1000 if s54_output_mining_quarrying 	== output_max & income_nagri_net_i==max_income_i
	replace industry = 1500 if s54_output_manufacturing		== output_max & income_nagri_net_i==max_income_i
	replace industry = 4500 if s54_output_construction 		== output_max & income_nagri_net_i==max_income_i
	replace industry = 5000 if s54_output_trade 			== output_max & income_nagri_net_i==max_income_i
	replace industry = 6000 if s54_output_transport 		== output_max & income_nagri_net_i==max_income_i
	replace industry = 5500 if s54_output_hotel_restaurant 	== output_max & income_nagri_net_i==max_income_i
	replace industry = 9000 if s54_output_other 			== output_max & income_nagri_net_i==max_income_i
	
	replace industry = 111  if income_farm_net_i==max_income_i
	
	gen 	industry_short 	= .
	replace industry_short 	= 1 if `industry'>=100  & `industry'<1000
	replace industry_short 	= 2 if `industry'>=1000 & `industry'<5000
	replace industry_short 	= 3 if `industry'>=5000 & (`industry'!=.)
	label define industry_short 1"Agriculture" 2"Industries" 3"Services" 4"Not_Classified"
	label values industry_short industry_short
	
	gen ind_agr	 	= (industry_short==1)
	replace ind_agr = . if industry_short==.
	gen ind_ind 	= (industry_short==2)
	replace ind_ind = . if industry_short==.
	gen ind_ser 	= (industry_short==3)
	replace ind_ser = . if industry_short==.

	
	gen 	industry_2digits = int(`industry' /100) if `industry'!=.
	gen 	industry_long = 1 if industry_2digits>=1 & industry_2digits<=6
	replace industry_long = 2 if industry_2digits>=10 & industry_2digits<=14
	replace industry_long = 3 if industry_2digits>=15 & industry_2digits<=37
	replace industry_long = 4 if industry_2digits>=40 & industry_2digits<=41 
	replace industry_long = 5 if industry_2digits==45
	replace industry_long = 6 if industry_2digits>=50 & industry_2digits<=52
	replace industry_long = 7 if industry_2digits==55
	replace industry_long = 8 if industry_2digits>=60 & industry_2digits<=64
	replace industry_long = 9 if industry_2digits>=65 & industry_2digits<=67
	replace industry_long = 10 if industry_2digits>=70 & industry_2digits<=74
	replace industry_long = 11 if industry_2digits==75
	replace industry_long = 12 if industry_2digits==80
	replace industry_long = 13 if industry_2digits==85
	replace industry_long = 14 if industry_2digits>=90 & industry_2digits<=93
	replace industry_long = 15 if industry_2digits>=95 & industry_2digits<=97
	replace industry_long = 16 if industry_2digits==99
	
#delimit;	
	label define industry_long 		1"Agriculture, forestry, fishing"
									2"Mining and quarrying"
									3"Manufacturing"
									4"Electricity, gas,water supply"
									5"Construction"
									6"Wholesale and retail trade"
									7"Hotels and Restaurants"
									8"Transport, Storage and communication"
									9"Financial Intermediation"
									10"Real estate, renting and business activities"
									11"Public administration and defence"
									12"Education"
									13"Health and social work"
									14"Other community, social and personal service activities"
									15"Activities of private households"
									16"Extraterritorial organizations and bodies";
#delimit cr
	label values industry_long industry_long
	
	
* Labour Force Status
*-------------------------------------------------------------------------------		
																				/*shiva_note better get employed from question 12=1 lidia_note we are using q12 section1*/
	gen 	lfstat = .
	replace lfstat = 1 if `labour_force_status'==1
	replace lfstat = 2 if `labour_force_status'==2
	replace lfstat = 3 if `labour_force_status'==3	
	replace lfstat = 4 if `labour_force_status'==4
	replace lfstat = 5 if `labour_force_status'==5
	replace lfstat = 6 if `labour_force_status'==9
	replace lfstat = 1 if lfstat!=1 & income_labor_i>0 & income_labor_i!=.

	label define lfstat 1"Employed" 2"Unemployed" 3"Student" 4"Household work" 5"Unable to work" 6"OLF"
	label values lfstat lfstat
		
	gen lfstat_employed	 		= (lfstat==1)
	replace lfstat_employed 	= . if lfstat==.
	gen lfstat_unemployed		= (lfstat==2)
	replace lfstat_unemployed 	= . if lfstat==.
	gen lfstat_olf				= (lfstat>=3 & lfstat!=.)
	replace lfstat_olf 			= . if lfstat==.

	rename `labour_force_status'  	labour_force_status
	gen employment_type=.
	gen isco_code=.

	gen lfpart   = (lfstat_employed==1 | lfstat_unemployed==1)
	replace lfpart = . if age<15

*-------------------------------------------------------------------------------
* MAIN LFSTAT
*-------------------------------------------------------------------------------
#delimit ;
	gen main_salaried_farm 	= (
								lfstat==1 & 
								income_empl_i>0  & 
								income_empl_i==max_income_i & 
								industry_short==1
								) ;
								
	gen main_salaried_nfarm 	= (
								lfstat==1 & 
								income_empl_i>0  & 
								income_empl_i==max_income_i & 
								industry_short!=1
								);
								
	gen main_self_farm  		=  (
								lfstat==1 & 
								main_salaried_farm==0 & main_salaried_nfarm==0 & 
								income_farm_net_i ==max_income_i & 
								income_farm_net_i!=0
								);
								
	gen main_self_nfarm 		= (
								lfstat==1 & 
								main_salaried_farm==0 & main_salaried_nfarm==0 & 
								income_nagri_output_i>0 & 
								income_nagri_output_i!=. & 
								income_nagri_net_i==max_income_i) ;
								
	gen main_unpaid			= ((lfstat==1 & income_labor_i==0) | (lfstat==1 & 
							  (main_salaried_farm==0 & 
							   main_salaried_nfarm==0 &
							   main_self_farm == 0 &
							   main_self_nfarm == 0 )));
	
	
	gen main_notempl			=  lfstat!=1 ;
#delimit cr
	
	replace industry_short = 1 if main_self_farm==1
	
	egen main_count=rowtotal(main_salaried_farm main_salaried_nfarm main_self_farm main_self_nfarm main_unpaid main_notempl)	
	tab main_count

* Generate main source of income
*-------------------------------------------------------------------------------
* By individual
gen 	main_activity_i = 1 if (main_salaried_farm==1)
replace main_activity_i = 2 if (main_salaried_nfarm==1)
replace main_activity_i = 3 if  main_self_farm  == 1
replace main_activity_i = 4 if  main_self_nfarm == 1
replace main_activity_i = 5 if  main_notempl ==1 
replace main_activity_i = 6 if  main_unpaid == 1
replace main_activity_i = . if age<15

label define main_activity_i  1"Wage from Agri" 2"Wage from Non Farm" 3"Self Agri" 4"Self Non Farm" 5"Not Employed" 6"Unpaid Family Worker"
label values main_activity_i main_activity_i

* By Household level
gen 	main_activity_hh = .
replace main_activity_hh = 1	if max_income_hh == income_empl_hh 		& income_empl_hh>0
replace main_activity_hh = 2	if max_income_hh == income_farm_net_hh	& income_farm_net_hh>0
replace main_activity_hh = 3	if max_income_hh == income_nagri_net_hh & income_nagri_net_hh>0

label define main_activity_hh  1"Wage and Salaries" 2"Self Agri" 3"Self Non Farm"
label values main_activity_hh main_activity_hh

gen aux_self_agri = (main_activity_i==3)
gen aux_self_nagri = (main_activity_i==4)

bysort hhid: egen aux_self_agri_hh = sum(aux_self_agri)
bysort hhid: egen aux_self_nagri_hh = sum(aux_self_nagri)

* Combination of activities at household level
gen  	combo_activity_hh = 0
replace combo_activity_hh = 1 if aux_self_agri_hh > 0 & aux_self_nagri_hh == 0
replace combo_activity_hh = 2 if aux_self_nagri_hh > 0 & aux_self_agri_hh == 0
replace combo_activity_hh = 3 if aux_self_agri_hh > 0 & aux_self_nagri_hh > 0

label define combo_activity_hh 1"Only Non Agri" 2"Only Agri" 3"Agri and Non Agri"
label values combo_activity_hh combo_activity_hh
drop aux_*

*===============================================================================
* Spatially deflate incomes
*===============================================================================
rename *samurdhi_food *samurdhi

local  income "tot empl empl_wage_1 empl_wage_2 agri_net oagri_net nagri_net nlabor farm_net labor inkind pension disability_and_relief property_rents samurdhi dividends elder scholar sc_lunch threeposha other_income abroad local"
foreach i of local income{
gen rincome_`i'_i = income_`i'_i  	/ cpi_dcs
gen rincome_`i'_pc = income_`i'_pc  / cpi_dcs
gen rincome_`i'_hh = income_`i'_hh  / cpi_dcs
}


*===============================================================================
* LAND - Transform All land measures into acres
*===============================================================================
local seasonal_crop "paddy chilies onions vegetables tobacco other"
foreach sc of local seasonal_crop{
	replace  s52_roods_`sc' 	= s52_roods_`sc' / 4			
	replace  s52_perchs_`sc'  = s52_perchs_`sc' / 160
	mvencode s52*_`sc', mv(0) overr 
}

local other_crop "tea coconut coffee_banana meat fish eggs milk other_food firewood other"
foreach oc of local other_crop{
	replace s53_roods_`oc' 	= s53_roods_`oc' / 4			
	replace s53_perchs_`oc'  = s53_perchs_`oc' / 160
	mvencode s53*_`oc', mv(0) overr 
}

* At individual level
*-------------------------------------------------------------------------------
	egen	land_seasonal_crop_i 		= rowtotal(s52_roods* s52_perchs* s52_acres*), missing
	egen	land_other_crop_i			= rowtotal(s53_roods* s53_perchs* s53_acres*), missing
	egen	land_total_i				= rowtotal(land_seasonal_crop land_other_crop), missing

* At household level
*-------------------------------------------------------------------------------
	bysort hhid: egen land_seasonal_crop_hh = sum(land_seasonal_crop_i)
	bysort hhid: egen land_other_crop_hh	= sum(land_other_crop_i)
	bysort hhid: egen land_total_hh			= sum(land_total_i)
	

saveold "${out}/LKA_0102_profile.dta", replace
