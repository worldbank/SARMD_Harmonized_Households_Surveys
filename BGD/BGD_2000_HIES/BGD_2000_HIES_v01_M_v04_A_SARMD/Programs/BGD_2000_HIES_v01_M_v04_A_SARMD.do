/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                                   SOUTH ASIA MICRO DATABASE                                      **
**                                                                                                  **
** COUNTRY			Bangladesh
** COUNTRY ISO CODE	BGD
** YEAR				2000
** SURVEY NAME		HOUSEHOLD INCOME AND EXPENDITURE SURVEY-2000
** SURVEY AGENCY	BANGLADESH BUREAU OF STATISTICS
** RESPONSIBLE		Triana Yentzen
** MODFIED BY		Fernando Enrique Morales Velandia
** Date				02/15/2018
**                                                                                                  **
******************************************************************************************************
*****************************************************************************************************/

/*****************************************************************************************************
*                                                                                                    *
                                   INITIAL COMMANDS
*                                                                                                    *
*****************************************************************************************************/


** INITIAL COMMANDS
	cap log close 
	clear
	set more off
	set mem 800m

** DIRECTORY
	local input "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\BGD\BGD_2000_HIES\BGD_2000_HIES_v01_M"
	local output "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\BGD\BGD_2000_HIES\BGD_2000_HIES_v01_M_v04_A_SARMD"
	glo pricedata "D:\SOUTH ASIA MICRO DATABASE\CPI\cpi_ppp_sarmd_weighted.dta"
	glo shares "D:\SOUTH ASIA MICRO DATABASE\APPS\DATA CHECK\Food and non-food shares\BGD"
	glo fixlabels "D:\SOUTH ASIA MICRO DATABASE\APPS\DATA CHECK\Label fixing"

** LOG FILE
	log using "`output'\Doc\Technical\BGD_2000_HIES_v01_M_v04_A_SARMD.log",replace

/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/

	* PREPARE DATASETS
	use "`input'\Data\Stata\consumption_00_05_10.dta", clear
	keep if year==1
	drop psu
	label drop year
	tempfile consumption
	save `consumption', replace

	use "`input'\Data\Stata\activity.dta", clear
	sort hhcode idcode activity
	drop if idcode==.
	*Order by importance 
	gsort hhcode idcode -s5a02 -s5a03 -s5a04
	bys hhcode idcode: gen n=_n
	bys hhcode idcode: egen njobs=max(n)

	keep hhcode idcode n njobs s5a01b s5a02 s5a01c s5a03 s5a04 s5a06 s5b02 s5b07 s5b08 
	reshape wide s5a01b s5a01c s5a03 s5a02 s5a04 s5a06 s5b02 s5b07 s5b08, i(hhcode idcode) j(n)
	replace njobs=njobs-1 /*Create var specifying additional jobs*/
	

	tempfile labor
	save `labor'
	

	use "`input'\Data\Stata\summ_hhexp.dta", clear
	sort hhcode
	tempfile exp
	save `exp'
	
	use "`input'\Data\Stata\hh_s1_3_4_plist.dta", clear
	sort hhcode idcode
	tempfile plist
	save `plist'

	use "`input'\Data\Stata\summ_income03.dta", clear
	sort hhcode
	tempfile hhincome
	save `hhincome'

	**Add durables
	use "`input'\Data\Stata\hh_s9e_durables.dta" , clear
	decode itemcode, generate(codeit)
	replace codeit =strtoname( codeit )
	replace codeit=substr(codeit, 1,11)
	drop hhid psu value
	egen codeit1=concat( codeit itemcode )
	drop codeit itemcode
	reshape wide number , i(hhcode ) j(codeit1) string
	tempfile durables
	save `durables'
	
	**Add landholding
	use "`input'\Data\Stata\agri01", clear
	sort hhcode
	tempfile landholding
	save `landholding'
	
	**Add livestock assets
	use "`input'\Data\Stata\agri03", clear
	duplicates report hhcode
	decode animcode, gen(animal)
	drop s7c01b s7c02a s7c02b s7c03a s7c03b s7c04a s7c04b psu hhid
	egen anim2=concat( animal animcode )
	drop animcode
	drop animal
	ren s7c01a num
	replace anim2=strtoname(anim2)
	reshape wide num, i( hhcode ) j(anim2) string
	tempfile agric
	save `agric'
	
	* COMBINE DATASETS
	
	use "`input'\Data\Stata\hh_s2_8_hhlist.dta"
	gen id=hhcode
	format id %14.0g
	tostring id, replace
	sort id

	* Merge household level data
	merge 1:1 id using `consumption'
	drop year wgt
	drop _merge
	
	merge 1:1 hhcode using `exp'
	drop _merge
	
	sort hhcode
	merge 1:1 hhcode using `hhincome'
	drop _merge
	
	merge 1:1 hhcode using `durables'
	drop _merge
	
	merge 1:1 hhcode using `landholding'
	drop _merge
	
	merge 1:1 hhcode using `agric'
	drop _merge

	*Merge individual leveldata
	sort hhcode
	merge 1:m hhcode using `plist', force
	order id hhcode idcode
	drop _merge
	
	tostring hhid, replace
	
	sort hhcode idcode
	merge 1:1 hhcode idcode using `labor'
	drop _merge

/*****************************************************************************************************
*                                                                                                    *
                                   * STANDARD SURVEY MODULE
*                                                                                                    *
*****************************************************************************************************/

	
** COUNTRY
*<_countrycode_>
	gen str4 countrycode="BGD"
	label var countrycode "Country code"
*</_countrycode_>


** YEAR
*<_year_>
	gen int year=2000
	label var year "Year of survey"
*</_year_>

** SURVEY NAME 
*<_survey_>
	gen str survey="HIES"
	label var survey "Survey Acronym"
*</_survey_>

** INTERVIEW YEAR
*<_int_year_>
	gen byte int_year=.
	label var int_year "Year of the interview"
*</_int_year_>
	
	
** INTERVIEW MONTH
*<_int_month_>
	gen byte int_month=month
	la de lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value int_month lblint_month
	label var int_month "Month of the interview"
*</_int_month_>


** HOUSEHOLD IDENTIFICATION NUMBER
*<_idh_>
	tostring hhcode, gen(idh)
	label var idh "Household id"
*</_idh_>


** INDIVIDUAL IDENTIFICATION NUMBER
*<_idp_>

	egen idp=concat(idh idcode), punct(-)
	label var idp "Individual id"
*</_idp_>


** HOUSEHOLD WEIGHTS
*<_wgt_>
	gen double wgt=hhwght
	label var wgt "Household sampling weight"
*</_wgt_>


** STRATA
*<_strata_>
	destring stratum, gen(strata)
	label var strata "Strata"
*</_strata_>


** PSU
	label var psu "Primary sampling units"
*</_psu_>

	
** MASTER VERSION
*<_vermast_>

	gen vermast="01"
	label var vermast "Master Version"
*</_vermast_>
	
	
** ALTERATION VERSION
*<_veralt_>

	gen veralt="04"
	label var veralt "Alteration Version"
*</_veralt_>	
	
/*****************************************************************************************************
*                                                                                                    *
                                   HOUSEHOLD CHARACTERISTICS MODULE
*                                                                                                    *
*****************************************************************************************************/

** LOCATION (URBAN/RURAL)
*<_urban_>
	gen byte urban=urbrural
	recode urban (2=0)
	label var urban "Urban/Rural"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban
*</_urban_>


** REGIONAL AREA 1 DIGIT ADMN LEVEL
*<_subnatid1_>
	gen byte subnatid1=.
	forval i=1/5{
replace division=`i'*10 if division==`i'
}
replace division=60 if region==90
replace division=55 if inlist(region, 35, 85)
replace subnatid1=division
	la de lblsubnatid1 10 "Barisal" 20"Chittagong" 30"Dhaka" 40"Khulna" 50"Rajshahi" 55"Rangpur" 60"Sylhet"
	label var subnatid1 "Region at 1 digit (ADMN1)"
	label values subnatid1 lblsubnatid1
*</_subnatid1_>


** REGIONAL AREA 2 DIGIT ADMN LEVEL
*<_subnatid2_>
	gen byte subnatid2=district
	label copy district lblsubnatid2
	label var subnatid2 "Region at 2 digit (ADMN2)"
	label values subnatid2 lblsubnatid2
*</_subnatid2_>

	
** REGIONAL AREA 3 DIGIT ADMN LEVEL
*<_subnatid3_>
	gen byte subnatid3=.
	label var subnatid3 "Region at 3 digit (ADMN3)"
	label values subnatid3 lblsubnatid3
*</_subnatid3_>
	
	
** HOUSE OWNERSHIP
*<_ownhouse_>
	gen byte ownhouse=s211
	recode ownhouse (2/5=0) (6=.)
	label var ownhouse "House ownership"
	la de lblownhouse 0 "No" 1 "Yes"
	label values ownhouse lblownhouse
*</_ownhouse_>


** TENURE OF DWELLING
*<_tenure_>
   gen tenure=.
   replace tenure=1 if s211==1
   replace tenure=2 if s211==2 
   replace tenure=3 if (s211!=1 & s211!=2 & s211!=6) & s211!=.
   label var tenure "Tenure of Dwelling"
   la de lbltenure 1 "Owner" 2"Renter" 3"Other"
   la val tenure lbltenure
*</_tenure_>	


** LANDHOLDING
*<_lanholding_>
   gen landholding= (s7a01>0 | s7a02>0 | s7a03>0) if !mi(s7a01,s7a02,s7a03)
   label var landholding "Household owns any land"
   la de lbllandholding 0 "No" 1 "Yes"
   la val landholding lbllandholding
   note landholding: "BGD 2000" dummy activated if hh owns at least more than 0 acres of any type of land (aggricultural, dwelling, non-productive).
 *</_tenure_>	

 *ORIGINAL WATER CATEGORIES
*<_water_orig_>
gen water_orig=s206
la var water_orig "Source of Drinking Water-Original from raw file"
#delimit
la def lblwater_orig 1 "Supply water"
					 2 "Tubewell"
					 3 "Pond / River"
					 4 "Well"
					 5 "Waterfall / Spring"
					 6 "Other";
#delimit cr
la val water_orig lblwater_orig
*</_water_orig_>


*PIPED SOURCE OF WATER
*<_piped_water_>
gen piped_water= s206==1 if s206!=.
la var piped_water "Household has access to piped water"
la def lblpiped_water 1 "Yes" 0 "No"
la val piped_water lblpiped_water
note piped_water: "BGD 2000" note that "Supply water" category does not necessarily cover water supplied into dwelling. It may be tap water into compound or from public tap. See technical documentation from Water GP for further detail.

*</_piped_water_>


**INTERNATIONAL WATER COMPARISON (Joint Monitoring Program)
*<_water_jmp_>
gen water_jmp=.
replace water_jmp=1 if s206==1
replace water_jmp=4 if s206==2
replace water_jmp=12 if s206==3
replace water_jmp=14 if s206==4
replace water_jmp=14 if s206==5
replace water_jmp=14 if s206==6

label var water_jmp "Source of drinking water-using Joint Monitoring Program categories"
#delimit
la de lblwater_jmp 1 "Piped into dwelling" 	
				   2 "Piped into compound, yard or plot" 
				   3 "Public tap / standpipe" 
				   4 "Tubewell, Borehole" 
				   5 "Protected well"
				   6 "Unprotected well"
				   7 "Protected spring"
				   8 "Unprotected spring"
				   9 "Rain water"
				   10 "Tanker-truck or other vendor"
				   11 "Cart with small tank / drum"
				   12 "Surface water (river, stream, dam, lake, pond)"
				   13 "Bottled water"
				   14 "Other";
#delimit cr
la values  water_jmp lblwater_jmp
note water_jmp: "BGD 2000" Categories "Well" and "Waterfall / Spring" are classified as other according to JMP definitions, given that this are ambigous categories. 
note water_jmp: "BGD 2000" note that "Piped into dwelling" category does not necessarily cover water supplied into dwelling. It may be tap water into compound or from public tap. See technical documentation from Water GP for further detail.

*</_water_jmp_>

*SAR improved source of drinking water
*<_sar_improved_water_>
gen sar_improved_water=.
replace sar_improved_water=1 if inlist(water_jmp,1,2,3,4,5,7,9)
replace sar_improved_water=0 if inlist(water_jmp, 6,8,10,11,12,13,14)
la def lblsar_improved_water 1 "Improved" 0 "Unimproved"
la var sar_improved_water "Improved source of drinking water-using country-specific definitions"
la val sar_improved_water lblsar_improved_water
*</_sar_improved_water_>


	*ORIGINAL WATER CATEGORIES
	*<_water_original_>
	clonevar j=s206
	#delimit
	la def lblwater_original 1 "Supply water"
							 2 "Tubewell"
							 3 "Pond/river"
							 4 "Well"
							 5 "Waterfall/string"
							 6 "Other";
	#delimit cr
	la val j lblwater_original		
	decode j, gen(water_original)
	drop j
	la var water_original "Source of Drinking Water-Original from raw file"
	*</_water_original_>


	** WATER SOURCE
	*<_water_source_>
		gen water_source=.
		replace water_source=1 if s206==1
		replace water_source=4 if s206==2
		replace water_source=13 if s206==3
		replace water_source=14 if s206==4
		replace water_source=14 if s206==5
		replace water_source=14 if s206==6
		#delimit
			la de lblwater_source 1 "Piped water into dwelling" 	
								  2 "Piped water to yard/plot" 
								  3 "Public tap or standpipe" 
								  4 "Tubewell or borehole" 
								  5 "Protected dug well"
								  6 "Protected spring"
								  7 "Bottled water"
								  8 "Rainwater"
								  9 "Unprotected spring"
								  10 "Unprotected dug well"
								  11 "Cart with small tank/drum"
								  12 "Tanker-truck"
								  13 "Surface water"
								  14 "Other";
		#delimit cr
		la val water_source lblwater_source
		la var water_source "Sources of drinking water"
	*</_water_source_>

	
	** SAR IMPROVED SOURCE OF DRINKING WATER
	*<_improved_water_>
		gen improved_water=.
		replace improved_water=1 if inrange(water_source,1,8)
		replace improved_water=0 if inrange(water_source,9,14) // Asuming other is not improved water source
		la def lblimproved_water 1 "Improved" 0 "Unimproved"
		la val improved_water lblimproved_water
		la var improved_water "Improved access to drinking water"
	*</_improved_water_>


	** PIPED SOURCE OF WATER ACCESS
	*<_pipedwater_acc_>
		gen pipedwater_acc=0 if inlist(s206,2,3,4,5,6) // Asuming other is not piped water
		replace pipedwater_acc=3 if inlist(s206,1)
		#delimit 
		la def lblpipedwater_acc	0 "No"
									1 "Yes, in premise"
									2 "Yes, but not in premise"
									3 "Yes, unstated whether in or outside premise";
		#delimit cr
		la val pipedwater_acc lblpipedwater_acc
		la var pipedwater_acc "Household has access to piped water"
	*</_pipedwater_acc_>

	
	** WATER TYPE VARIABLE USED IN THE SURVEY
	*<_watertype_quest_>
		gen watertype_quest=1
		#delimit
		la def lblwaterquest_type	1 "Drinking water"
									2 "General water"
									3 "Both"
									4 "Others";
		#delimit cr
		la val watertype_quest lblwaterquest_type
		la var watertype_quest "Type of water questions used in the survey"
	*</_watertype_quest_>

	
** ELECTRICITY PUBLIC CONNECTION
*<_electricity_>
	gen byte electricity=s208
	recode electricity (2=0)
	label var electricity "Electricity main source"
	la de lblelectricity 0 "No" 1 "Yes"
	label values electricity lblelectricity
*</_electricity_>

*ORIGINAL WATER CATEGORIES
*<_toilet_orig_>
gen toilet_orig=s205
la var toilet_orig "Access to sanitation facility-Original from raw file"
#delimit
la def lbltoilet_orig 1 "Sanitary"
					  2 "Pacca latrine (Water seal)"
					  3 "Pacca latrine (pit)"
					  4 "Kacha latrine (Permanent)"
					  5 "Kacha latrine (Temporary)"
					  6 "Open field";
#delimit cr
la val toilet_orig lbltoilet_orig
*</_toilet_orig_>

*SEWAGE TOILET
*<_sewage_toilet_>
gen sewage_toilet=s205
recode sewage_toilet  2/6=0
la var sewage_toilet "Household has access to sewage toilet"
la def lblsewage_toilet 1 "Yes" 0 "No"
la val sewage_toilet lblsewage_toilet
*</_sewage_toilet_>


**INTERNATIONAL SANITATION COMPARISON (Joint Monitoring Program)
*<_toilet_jmp_>
gen toilet_jmp=.
replace toilet_jmp=14 if inrange(s205,1,5)
replace toilet_jmp=12 if s205==6

label var toilet_jmp "Access to sanitation facility-using Joint Monitoring Program categories"
#delimit 
la def lbltoilet_jmp 1 "Flush to piped sewer  system"
					2 "Flush to septic tank"
					3 "Flush to pit latrine"
					4 "Flush to somewhere else"
					5 "Flush, don't know where"
					6 "Ventilated improved pit latrine"
					7 "Pit latrine with slab"
					8 "Pit latrine without slab/open pit"
					9 "Composting toilet"
					10 "Bucket toilet"
					11 "Hanging toilet/hanging latrine"
					12 "No facility/bush/field"
					13 "Other";
#delimit cr
la val toilet_jmp lbltoilet_jmp
note toilet_jmp: "BGD 2000" Due to multiple ambiguities, categories "Sanitary", "Pacca latrine (Water seal)", "Pacca latrine (pit)", "Kacha latrine (Permanent)" ///
 "Kacha latrine (Temporary)" are classified as other. Take into account that some of this sources of toilet may be either improved or unimproved. 
*</_toilet_jmp_>


*SAR improved type of toilet
*<_sar_improved_toilet_>
gen sar_improved_toilet=.
replace sar_improved_toilet=1 if inlist(s205,1,2,3)
replace sar_improved_toilet=0 if inlist(s205,4,5,6)
la def lblsar_improved_toilet 1 "Improved" 0 "Unimproved"
la var sar_improved_toilet "Improved type of sanitation facility-using country-specific definitions"
la val sar_improved_toilet lblsar_improved_toilet
*</_sar_improved_toilet_>


	** ORIGINAL SANITATION CATEGORIES 
	*<_sanitation_original_>
		clonevar j=s205
		#delimit
		la def lblsanitation_original   1 "Sanitary"
										2 "Pacca latrine (Water seal)"
										3 "Pacca latrine (Pit)"
										4 "Kacha latrine (perm)"
										5 "Kacha latrine (temp)"
										6 "Other";
		#delimit cr
		la val j lblsanitation_original
		decode j, gen(sanitation_original)
		drop j
		la var sanitation_original "Access to sanitation facility-Original from raw file"
	*</_sanitation_original_>

	
	** SANITATION SOURCE
	*<_sanitation_source_>
		gen sanitation_source=.
		#delimit
		la def lblsanitation_source	1	"A flush toilet"
									2	"A piped sewer system"
									3	"A septic tank"
									4	"Pit latrine"
									5	"Ventilated improved pit latrine (VIP)"
									6	"Pit latrine with slab"
									7	"Composting toilet"
									8	"Special case"
									9	"A flush/pour flush to elsewhere"
									10	"A pit latrine without slab"
									11	"Bucket"
									12	"Hanging toilet or hanging latrine"
									13	"No facilities or bush or field"
									14	"Other";
		#delimit cr
		la val sanitation_source lblsanitation_source
		la var sanitation_source "Sources of sanitation facilities"
	*</_sanitation_source_>

	
	** SAR IMPROVED SANITATION 
	*<_improved_sanitation_>
		gen improved_sanitation=.
		replace improved_sanitation=1 if inlist(s205,1,2,3)
		replace improved_sanitation=0 if inlist(s205,4,5,6)
		la def lblimproved_sanitation 1 "Improved" 0 "Unimproved"
		la val improved_sanitation lblimproved_sanitation
		la var improved_sanitation "Improved type of sanitation facility-using country-specific definitions"
	*</_improved_sanitation_>
	

	** ACCESS TO FLUSH TOILET
	*<_toilet_acc_>
		gen toilet_acc=3 if improved_sanitation==1
		replace toilet_acc=0 if improved_sanitation==0 
		#delimit 
		la def lbltoilet_acc		0 "No"
									1 "Yes, in premise"
									2 "Yes, but not in premise"
									3 "Yes, unstated whether in or outside premise";
		#delimit cr
		la val toilet_acc lbltoilet_acc
		la var toilet_acc "Household has access to flushed toilet"
	*</_toilet_acc_>

	
** INTERNET
	gen byte internet=.
	label var internet "Internet connection"
	la de lblinternet 0 "No" 1 "Yes"
	label values internet lblinternet


/*****************************************************************************************************
*                                                                                                    *
                                   DEMOGRAPHIC MODULE
*                                                                                                    *
*****************************************************************************************************/
** HOUSEHOLD SIZE
*<_hsize_>
	ren hhsize hsize
	label var hsize "Household size"
*</_hsize_>

**POPULATION WEIGHT
*<_pop_wgt_>
	gen pop_wgt=wgt*hsize
	la var pop_wgt "Population weight"
*</_pop_wgt_>



** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
*<_relationharm_>
	gen byte relationharm=relation
	recode relationharm  (6=4) (4 5 7 8 9  10 11=5) (12 13 14 = 6)
	label var relationharm "Relationship to the head of household"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Non-relatives"
	label values relationharm  lblrelationharm
*</_relationharm_>

** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
*<_relationcs_>

	gen byte relationcs=relation
	la var relationcs "Relationship to the head of household country/region specific"
	label define lblrelationcs 1 "Head" 2 "Husband/Wife" 3 "Son/Daughter" 4 "Spouse of Son/Daughter" 5 "Grandchild" 6 "Father/Mother" 7 "Brother/Sister" 8 "Niece/Nephew" 9 "Father/Mother-in-law" 10 "Brother/Sister-in-law" 11 "Other relative" 12 "Servant" 13 "Employee" 14 "Other"
	label values relationcs lblrelationcs
*</_relationcs_>


** GENDER
*<_male_>
	gen byte male=sex
	recode male (2=0)
	label var male "Sex of household member"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale
*</_male_>


** AGE
*<_age_>
	label var age "Age of individual"
	replace age=98 if age>=98 & age!=.
*</_age_>


** SOCIAL GROUP
*<_soc_>
	gen byte soc=religion
	label var soc "Social group"
	la de lblsoc 1 "Islam" 2 "Hinduism" 3 "Buddhism" 4 "Christianity" 5 "Other"
	label values soc lblsoc
*</_soc_>


** MARITAL STATUS
*<_marital_>
	gen byte marital=mstatus
	recode marital 8=. 1=1 4/5=4 3=5 2=2
	label var marital "Marital status"
	la de lblmarital 1 "Married" 2 "Never Married" 3 "Living Together" 4 "Divorced/separated" 5 "Widowed"
	label values marital lblmarital
*</_marital_>


/*****************************************************************************************************
*                                                                                                    *
                                   EDUCATION MODULE
*                                                                                                    *
*****************************************************************************************************/


** EDUCATION MODULE AGE
*<_ed_mod_age_>
	gen byte ed_mod_age=5
	label var ed_mod_age "Education module application age"
*</_ed_mod_age_>


** CURRENTLY AT SCHOOL
*<_atschool_>
	gen byte atschool=s3b01
	recode atschool (2=0)
	replace atschool =. if  age<5
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool
note atschool: "BGD 2000" Attendance question is used	
*</_atschool_>


** CAN READ AND WRITE
*<_literacy_>
	gen byte literacy=.
	replace literacy=1 if s3a01==1 & s3a02==1
	replace literacy=0 if s3a01==2 | s3a02==2
	replace literacy =. if  age<5
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
*</_literacy_>


** YEARS OF EDUCATION COMPLETED
*<_educy_>
	gen byte educy=s3a04
	recode educy (11=12) (12=16) (13=18) (14=19) (15=14) (16=14) (17=.)
	replace educy=s3b02 if educy==. & s3b02!=.
	*Substract one year of education to those currently studying before secondary
	replace educy=educy-1 if  s3b02<=11 & s3a04==.
	*Substract one year of education to those currently studying after secondary
	recode educy (10=11) (12=15) (13=17) (14=18) (15=13) (16=13) (17=.) (-1=0) if s3b02!=.  & s3a04==.
	replace educy=. if age<5
	label var educy "Years of education"
	replace educy=. if educy>age & age!=. & educy!=.
	note educy: "BGD 2000" Variable not coded properly in raw data. Compare with options in questionnaire
	/*check: https://www.winona.edu/socialwork/Media/Prodhan%20The%20Educational%20System%20in%20Bangladesh%20and%20Scope%20for%20Improvement.pdf*/
*</_educy_>


** EDUCATION LEVEL 7 CATEGORIES
*<_educat7_>
	gen byte educat7=.
	replace educat7=1 if educy==0
	replace educat7=2 if (educy>0 & educy<5)
	replace educat7=3 if (educy==5)
	replace educat7=4 if (educy>5 & educy<12)
	replace educat7=5 if (educy==12)
	replace educat7=7 if (educy>12 & educy<23)
	replace educat7=6 if inlist(educy,13,14) 
	replace educat7=8 if s3a04==17 | s3b02==17 
	replace educat7=. if age<5
	la var educat7 "Level of education 7 categories"
	label define lbleducat7 1 "No education" 2 "Primary incomplete" 3 "Primary complete" ///
	4 "Secondary incomplete" 5 "Secondary complete" 6 "Higher than secondary but not university" /// 
	7 "University incomplete or complete" 8 "Other" 9 "Not classified"
	label values educat7 lbleducat7
*</_educat7_>



** EDUCATION LEVEL 4 CATEGORIES
*<_educat4_>
	gen byte educat4=educat7
	recode educat4 (2/3=2) (4/5=3) (6 7=4) (8=.)
	label var educat4 "Level of education 4 categories"
	label define lbleducat4 1 "No education" 2 "Primary (complete or incomplete)" ///
	3 "Secondary (complete or incomplete)" 4 "Tertiary (complete or incomplete)"
	label values educat4 lbleducat4
*</_educat4_>




** EDUCATION LEVEL 5 CATEGORIES
*<_educat5_>
	gen educat5=.
	replace educat5=1 if educat7==1
	replace educat5=2 if educat7==2
	replace educat5=3 if educat7==3 | educat7==4
	replace educat5=4 if educat7==5
	replace educat5=5 if educat7==6 | educat7==7
	label define lbleducat5 1 "No education" 2 "Primary incomplete" ///
	3 "Primary complete but secondary incomplete" 4 "Secondary complete" ///
	5 "Some tertiary/post-secondary"
	label values educat5 lbleducat5
*</_educat5_>

	la var educat5 "Level of education 5 categories"


** EVER ATTENDED SCHOOL
*<_everattend_>
	gen byte everattend=1 if educat4>1 & educat4!=.
	replace everattend=0 if educat4==1
	replace everattend=. if age<5
	label var everattend "Ever attended school"
	la de lbleverattend 0 "No" 1 "Yes"
	label values everattend lbleverattend
*</_everattend_>

	replace educy=0 if everattend==0
	replace educat7=1 if everattend==0
	replace educat4=1 if everattend==0
	replace educat5=1 if everattend==0
foreach var in atschool literacy educy everattend educat4 educat5 educat7{
replace `var'=. if age<ed_mod_age
}


/*****************************************************************************************************
*                                                                                                    *
                                   LABOR MODULE
*                                                                                                    *
*****************************************************************************************************/


** LABOR MODULE AGE
*<_lb_mod_age_>

 gen byte lb_mod_age=5
	label var lb_mod_age "Labor module application age"
*</_lb_mod_age_>


** LABOR STATUS
*<_lstatus_>
	gen byte lstatus=.
	replace lstatus=1 if s1b01==1
	replace lstatus=2 if (s1b01==2 & s1b03==1) 
	replace lstatus=3 if s1b01==2 & (s1b02==2 | s1b03==2)
	replace lstatus=2 if s1b04==9
	replace lstatus=. if age<lb_mod_age
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
	notes lstatus: "BGD 2000" the categories of question 4 section 1 changed compared to the questionnaire. There is one additional category.
	notes lstatus: "BGD 2000"a person is considered "unemployed" if not working but waiting to start a new job.
	notes lstatus: "BGD 2000" question related to ‘able to accept a job’ is not taken into account in the definition of unemployed.
*</_lstatus_>

** LABOR STATUS LAST YEAR
*<_lstatus_year_>
	*gen byte lstatus_year=1 if inlist(s1b01,1,2)
	gen byte lstatus_year=1 if (s5a021>0 & s5a021<=12) | (s5a022>0 & s5a022<=12) | (s5a023>0 & s5a023<=12) | (s5a024>0 & s5a024<=12) | (s5a025>0 & s5a025<=12) 
	replace lstatus_year=0 if s5a01b1==.
	replace lstatus_year=. if age<lb_mod_age & age!=.
	label var lstatus_year "Labor status during last year"
	la de lbllstatus_year 1 "Employed" 0 "Not employed" 
	label values lstatus_year lbllstatus_year
*</_lstatus_year_>


** EMPLOYMENT STATUS
*<_empstat_>
	gen byte empstat=.
	replace empstat=1 if s5a061==1
	replace empstat=4 if s5a061>=2 & s5a061<=3
	replace empstat=. if lstatus==2| lstatus==3
	label var empstat "Employment status"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other"
	label values empstat lblempstat
	notes empstat: "BGD 2000" the categories for further rounds allow to identify if person is employer
*</_empstat_>

** EMPLOYMENT STATUS LAST YEAR
*<_empstat_year_>
	gen byte empstat_year=empstat
	replace empstat_year=. if lstatus_year!=1
	label var empstat_year "Employment status during last year"
	la de lblempstat_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_year lblempstat_year
*</_empstat_year_>


** NUMBER OF ADDITIONAL JOBS 
*<_njobs_>
	label var njobs "Number of additional jobs"
	replace njobs=. if lstatus!=1
*</_njobs_>


** NUMBER OF ADDITIONAL JOBS LAST YEAR
*<_njobs_year_>
	gen byte njobs_year=njobs
	replace njobs_year=. if lstatus_year!=1
	label var njobs_year "Number of additional jobs during last year"
*</_njobs_year_>



** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
*<_ocusec_>
	gen byte ocusec=s5b071
	recode ocusec (1 2 4 6 7 = 1) (3 5 8=2) 
	replace ocusec=. if lstatus==2| lstatus==3
	label var ocusec "Sector of activity"
	la de lblocusec 1 "Public, state owned, government, army, NGO" 2 "Private"
	label values ocusec lblocusec
*</_ocusec_>


** REASONS NOT IN THE LABOR FORCE
*<_nlfreason_>
	gen byte nlfreason=s1b04
	recode nlfreason (1 5 6 8 9 10 11 = 5) (3=1) (4  =3) (7=4) 
	replace nlfreason=. if lstatus!=3 
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housewife" 3 "Retired" 4 "Disable" 5 "Other"
	label values nlfreason lblnlfreason
*</_nlfreason_>

** UNEMPLOYMENT DURATION: MONTHS LOOKING FOR A JOB
*<_unempldur_l_>
	gen byte unempldur_l=.
	label var unempldur_l "Unemployment duration (months) lower bracket"
*</_unempldur_l_>

*<_unempldur_u_>

	gen byte unempldur_u=.
	label var unempldur_u "Unemployment duration (months) upper bracket"
*</_unempldur_u_>


**ORIGINAL INDUSTRY CLASSIFICATION
*<_industry_orig_>
gen industry_orig=s5a01c1
label define lblindustry_orig 1 `"AGRICULTURE, HUNTING AND RELATED SERVICE ACT"', modify
label define lblindustry_orig 2 `"FORESTRY, LOGGING AND RELATED SERVICE ACTIVI"', modify
label define lblindustry_orig 5 `"FISHING, OPERATION OF FISH HATCHERIES AND FI"', modify
label define lblindustry_orig 10 `"MINING OF COAL AND LIGNITE; EXTRACTION OF PE"', modify
label define lblindustry_orig 11 `"EXTRACTION OF CRUDE PETROLEUM AND NATURAL GA"', modify
label define lblindustry_orig 12 `"MINING OF URANIUM AND THORIUM ORES"', modify
label define lblindustry_orig 13 `"MINING OF METAL ORES"', modify
label define lblindustry_orig 14 `"OTHER MINING AND QUARRYING"', modify
label define lblindustry_orig 15 `"MANUFACTURING OF FOOD PRODUCTS AND BEVERAGES"', modify
label define lblindustry_orig 16 `"MANUFACTURING OF TOBACCO PRODUCTS"', modify
label define lblindustry_orig 17 `"MANUFACTURE OF TEXTILES"', modify
label define lblindustry_orig 18 `"MANUFACTURE OF WEARING APPAREL; DRESSING AND"', modify
label define lblindustry_orig 19 `"TANNING AND DRESSING OF LEATHER ; MANUFACTUR"', modify
label define lblindustry_orig 20 `"MANUFACTURE OF WOOD AND OF PRODUCTS OF WOOD"', modify
label define lblindustry_orig 21 `"MANUFACTURE OF PAPER AND PAPER PRODUCTS"', modify
label define lblindustry_orig 22 `"PUBLISHING, PRINTING AND REPRODUCTION OF REC"', modify
label define lblindustry_orig 23 `"MANUFACTURE OF COKE, REFINED PETROLEUM PRODU"', modify
label define lblindustry_orig 24 `"MANUFACTURE OF CHEMICALS AND CHEMICAL PRODUC"', modify
label define lblindustry_orig 25 `"MANUFACTURE OF RUBBER AND PLASTIC PRODUCTS"', modify
label define lblindustry_orig 26 `"MANUFACTURE OF OTHER NON-METALLIC MINERAL PR"', modify
label define lblindustry_orig 27 `"MANUFACTURE OF BASIC METALS"', modify
label define lblindustry_orig 28 `"MANUFACTURE OF FABRICATED METAL PRODUCTS, EX"', modify
label define lblindustry_orig 29 `"MANUFACTURE OF EQUIPMENT N.E.C."', modify
label define lblindustry_orig 30 `"MANUFACTURE OF OFFICE, ACCOUNTING AND COMPUT"', modify
label define lblindustry_orig 31 `"MANUFACTURE OF ELECTRICAL MACHINERY AND APPA"', modify
label define lblindustry_orig 32 `"MANUFACTURE OF RADIO, TELEVISION AND COMMUNI"', modify
label define lblindustry_orig 33 `"MANUFACTURE OF MEDICAL, PRECISION AND OPTICA"', modify
label define lblindustry_orig 34 `"MANUFACTURE OF MOTOR VEHICLES, TRAILERS AN D"', modify
label define lblindustry_orig 35 `"MANUFACTURE OF OTHER TRANSPORT EQUIPMENT"', modify
label define lblindustry_orig 36 `"MANUFACTURE OF FURNITURE; MANUFACTURING, N.E"', modify
label define lblindustry_orig 37 `"RECYCLING"', modify
label define lblindustry_orig 40 `"ELECTRICITY, GAS, STEAM AND HOT WATER SUPPLY"', modify
label define lblindustry_orig 41 `"COLLECTION, PURIFICATION AND DISTRIBUTION OF"', modify
label define lblindustry_orig 45 `"CONSTRUCTION"', modify
label define lblindustry_orig 50 `"SALE, MAINTENANCE AND REPAIR OF MOTOR VEHICL"', modify
label define lblindustry_orig 51 `"WHOLESALE TRADE AND COMMISSION TRADE, EXCEPT"', modify
label define lblindustry_orig 52 `"RETAIL TRADE, EXCEPT OF MOTOR VEHICLES AND M"', modify
label define lblindustry_orig 55 `"HOTELS AND RESTAURANTS"', modify
label define lblindustry_orig 60 `"LAND TRANSPORT, TRANSPORT VIA PIPELINE"', modify
label define lblindustry_orig 61 `"WATER TRANSPORT"', modify
label define lblindustry_orig 62 `"AIR TRANSPORT"', modify
label define lblindustry_orig 63 `"SUPPORTING AND AUXILIARY TRANSPORT ACTIVITIE"', modify
label define lblindustry_orig 64 `"POST AND TELECOMMUNICATIONS"', modify
label define lblindustry_orig 65 `"FINANCIAL INTERMEDIATION EXCEPT INSURANCE AN"', modify
label define lblindustry_orig 66 `"INSURANCE AND PENSION FUNDING, EXCEPT COMPUL"', modify
label define lblindustry_orig 67 `"ACTIVITIES AUXILIARY TO FINANCIAL INTERMEDIA"', modify
label define lblindustry_orig 70 `"REAL ESTATE ACTIVITIES"', modify
label define lblindustry_orig 71 `"RENTING OF MACHINERY AND EQUIPMENT WITHOUT O"', modify
label define lblindustry_orig 72 `"COMPUTER AND RELATED ACTIVITIES"', modify
label define lblindustry_orig 73 `"RESEARCH AND DEVELOPMENT"', modify
label define lblindustry_orig 74 `"OTHER BUSINESS ACTIVITIES"', modify
label define lblindustry_orig 75 `"PUBLIC ADMINISTRATION AND DEFENSE; COMPULSOR"', modify
label define lblindustry_orig 80 `"EDUCATION"', modify
label define lblindustry_orig 81 `"HEALTH AND SOCIAL WORK"', modify
label define lblindustry_orig 90 `"SEWAGE AND REFUSE DISPOSAL, SANITATION AND S"', modify
label define lblindustry_orig 91 `"ACTIVITIES OF MEMBER SHIP ORGANIZATIONS N.E."', modify
label define lblindustry_orig 92 `"RECREATIONAL, CULTURAL AND SPORTING ACTIVITI"', modify
label define lblindustry_orig 95 `"PRIVATE HOUSEHOLD WITH EMPLOYED PERSONS"', modify
label define lblindustry_orig 99 `"EXTRA TERRITORIAL ORGANIZATIONS AND BODIES"', modify
label val industry_orig lblindustry_orig
replace industry_orig=. if lstatus!=1
la var industry_orig "Original industry code"
*</_industry_orig_>


** INDUSTRY CLASSIFICATION
*<_industry_>
	gen byte industry=s5a01c1
	recode industry (1/5=1) (10/14=2) (15/38=3) (40/43=4) (45=5) (50/59=6) (60/64=7) (65/74=8) (75=9) (76/99=10) (0=.)
	label var industry "1 digit industry classification"
	replace industry=. if lstatus==2| lstatus==3
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transports and comnunications" 8 "Financial and business-oriented services" 9 "Public Administration" 10 "Other services, Unspecified"
	label values industry lblindustry
*</_industry_>
	*http://www.ilo.org/public/english/bureau/stat/isco/docs/resol08.pdf

**ORIGINAL OCCUPATION CLASSIFICATION
*<_occup_orig_>
	gen occup_orig=s5a01b1
	label define lbloccup_orig 1 `"PHYSICAL SCIENTISTS AND RELATED TECHNICIANS"', modify
	label define lbloccup_orig 2 `"ARCHITECTS AND ENGINEERS"', modify
	label define lbloccup_orig 3 `"TECHNICIANS FOR ARCHITECTS AND ENGINEERS"', modify
	label define lbloccup_orig 4 "AIRCRAFT AND SHIPS' OFFICERS", modify
	label define lbloccup_orig 5 `"LIFE SCIENTISTS AND RELATED TECHNICIANS"', modify
	label define lbloccup_orig 6 `"MEDICAL, DENTAL AND VETERINARY"', modify
	label define lbloccup_orig 7 `"NURSES, NURSING ASSISTANTS AND MEDICAL RELAT"', modify
	label define lbloccup_orig 8 `"STATISTICIANS, MATHEMATICIANS, SYSTEM ANALYS"', modify
	label define lbloccup_orig 9 `"ECONOMISTS"', modify
	label define lbloccup_orig 10 `"ACCOUNTANTS"', modify
	label define lbloccup_orig 12 `"JURISTS"', modify
	label define lbloccup_orig 13 `"TEACHERS"', modify
	label define lbloccup_orig 14 `"WORKERS IN RELIGION"', modify
	label define lbloccup_orig 15 `"AUTHORS, JOURNALISTS AND RELATED WRITERS"', modify
	label define lbloccup_orig 16 `"FINE AND COMMERCIAL ARTISTS, PHOTOGRAPHERS A"', modify
	label define lbloccup_orig 17 `"PERFORMING AND AUDIOVISUAL ARTISTS"', modify
	label define lbloccup_orig 18 `"SPORTSMEN AND RELATED WORKERS"', modify
	label define lbloccup_orig 19 `"PROFESSIONAL, TECHNICAL AND RELATED WORKERS"', modify
	label define lbloccup_orig 20 `"LEGISLATIVE OFFICIALS AND GOVT. ADMINISTRATO"', modify
	label define lbloccup_orig 21 `"MANAGERS"', modify
	label define lbloccup_orig 30 `"GOVERNMENT EXECUTIVE OFFICIALS"', modify
	label define lbloccup_orig 31 `"CLERICAL SUPERVISORS"', modify
	label define lbloccup_orig 32 `"STENOGRAPHERS, TYPISTS AND CARD-AND TAPE PUN"', modify
	label define lbloccup_orig 33 `"BOOK KEEPERS, CASHIERS AND RELATED WORKERS"', modify
	label define lbloccup_orig 34 `"COMPUTING MACHINE OPERATORS"', modify
	label define lbloccup_orig 35 `"TRANSPORT AND COMMUNICATION SUPERVISORS"', modify
	label define lbloccup_orig 36 `"TRANSPORT CONDUCTORS"', modify
	label define lbloccup_orig 37 `"MAIL DISTRIBUTION CLERKS"', modify
	label define lbloccup_orig 38 `"TELEPHONE AND TELEGRAPH OPERATORS"', modify
	label define lbloccup_orig 39 `"CLERICAL AND RELATED WORKERS N. E. C."', modify
	label define lbloccup_orig 40 `"MANAGERS (WHOLESALE AND RETAIL TRADE)"', modify
	label define lbloccup_orig 42 `"SALES SUPERVISOR AND BUYERS"', modify
	label define lbloccup_orig 43 `"TECHNICAL SALESMEN, COMMERCIAL TRAVELERS AND"', modify
	label define lbloccup_orig 44 `"INSURANCE, REAL ESTATE, BUSINESS AND RELATED"', modify
	label define lbloccup_orig 45 `"SALESMEN, STREET VENDORS AND RELATED WORKERS"', modify
	label define lbloccup_orig 49 `"SALESMEN NOT ELSEWHERE CLASSIFIED"', modify
	label define lbloccup_orig 50 `"MANAGERS-CATERING AND LODGING SERVICES"', modify
	label define lbloccup_orig 51 `"WORKING PROPRIETORS (CATERING AND LODGING SE"', modify
	label define lbloccup_orig 52 `"SUPERVISORS- CATERING AND LODGING SERVICES"', modify
	label define lbloccup_orig 53 `"COOKS, WAITERS AND RELATED WORKERS"', modify
	label define lbloccup_orig 54 `"MAIDS AND RELATED HOUSEKEEPING SERVICE WORKE"', modify
	label define lbloccup_orig 55 `"BUILDING, CARETAKERS, CLEANERS AND RELATED W"', modify
	label define lbloccup_orig 56 `"LAUNDERERS, DRY-CLEANERS AND PRESSERS"', modify
	label define lbloccup_orig 58 `"PROTECTIVE SERVICE WORKERS"', modify
	label define lbloccup_orig 59 `"SERVICE WORKERS NOT ELSEWHERE CLASSIFIED"', modify
	label define lbloccup_orig 60 `"FARM MANGERS AND SUPERVISORS"', modify
	label define lbloccup_orig 61 `"FARMERS"', modify
	label define lbloccup_orig 63 `"FORESTRY WORKERS"', modify
	label define lbloccup_orig 64 `"FISHERMEN, HUNTERS AND RELATED WORKERS"', modify
	label define lbloccup_orig 70 `"PRODUCTION SUPERVISORS AND GENERAL FOREMEN"', modify
	label define lbloccup_orig 71 `"MINERS, QUARRYMEN, WELL DRILLERS AND RELATED"', modify
	label define lbloccup_orig 72 `"METAL PROCESSORS"', modify
	label define lbloccup_orig 73 `"WOOD PAPER AND PAPER MAKERS"', modify
	label define lbloccup_orig 74 `"CHEMICAL PROCESSORS AND RELATED WORKERS"', modify
	label define lbloccup_orig 75 `"SPINNERS, WEAVERS, KNITTERS, DYERS AND RELAT"', modify
	label define lbloccup_orig 76 `"TANNERS, FELLMOUGERS AND PELT DRESSERS"', modify
	label define lbloccup_orig 77 `"FOOD AND BEVERAGE PROCESSORS"', modify
	label define lbloccup_orig 78 `"TOBACCO PREPARERS AND CIGARETTE MAKERS"', modify
	label define lbloccup_orig 79 `"TAILORS, DRESSMAKERS, SEWERS, UPHOLSTERERS A"', modify
	label define lbloccup_orig 80 `"SHOEMAKERS AND LEATHER GOODS MAKERS"', modify
	label define lbloccup_orig 81 `"CABINETMAKERS AND RELATED WOOD WORKERS"', modify
	label define lbloccup_orig 82 `"STONE CUTTERS AND FINISHERS"', modify
	label define lbloccup_orig 83 `"FORGING WORKERS, TOOLMAKERS AND METALWORKING"', modify
	label define lbloccup_orig 84 `"MACHINERY FITTERS, MACHINERY MECHANICS AND P"', modify
	label define lbloccup_orig 85 `"ELECTRICAL FITTERS AND RELATED ELECTRICAL AN"', modify
	label define lbloccup_orig 86 `"BROADEST AND SOUND EQUIPMENT OPERATORS AND M"', modify
	label define lbloccup_orig 87 `"PLUMBERS, WELDERS AND SHEET METAL AND STRUCT"', modify
	label define lbloccup_orig 88 `"JEWELLERY AND PRECIOUS METAL WORKERS"', modify
	label define lbloccup_orig 89 `"GLASS FORMERS, POTTERS AND RELATED WORKERS"', modify
	label define lbloccup_orig 90 `"RUBBER AND PLASTICS PRODUCT MAKERS"', modify
	label define lbloccup_orig 91 `"PAPER AND PAPERBOARD PRODUCTS MAKERS"', modify
	label define lbloccup_orig 92 `"PRINTERS AND RELATED WORKERS"', modify
	la val occup_orig lbloccup_orig
	replace occup_orig=. if lstatus!=1
	la var occup_orig "Original occupation code"
*</_occup_orig_>
	
	
	
** OCCUPATION CLASSIFICATION
*<_occup_>
#delimit
recode s5a01b1 (1=3)	(2=2)	(3=3)	(4=2)	(5=3)	(6=2)	(40=1)	(8=2)	(9=2)	(10=2)	(12=2)	(13=2)	(14=3)	(15=2)	
(16=2)	(17=2)	(18=2)	(19=2)	(20=1)	(21=1)	(30=1)	(31=4)	(32=4)	(33=4)	(34=8)	(35=8)	(50=1)	(7=2)	(42=3)	(39=4)	(43=3)
	(44=3)	(86=3)	(37=4)	(38=4)	(36=5)	(45=5)	(51=5)	(52=5)	(53=5)	(54=5)	(49=5)	(70=6)	(58=5)	(59=5)	(60=6)	(61=6)	(63=6)
	(64=6)	(71=7)	(72=7)	(75=7)	(74=8)	(76=7)	(77=7)	(78=7)	(79=7)	(80=7)	(81=7)	(82=7)	(83=7)	(84=7)	(85=7)	(87=7)	(88=7)
	(89=7)	(92=7)	(90=8)	(91=8)	(55=9)	(56=9) (0 41=.), gen(occup);
	#delimit cr
	replace occup=. if lstatus==2| lstatus==3
	label var occup "1 digit occupational classification"
	la de lbloccup 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup lbloccup
	/*check here http://www.ilo.org/public/english/bureau/stat/isco/isco88/major.htm*/
*</_occup_>


** FIRM SIZE
*<_firmsize_l_>
	gen byte firmsize_l=.
	label var firmsize_l "Firm size (lower bracket)"
*</_firmsize_l_>

*<_firmsize_u_>

	gen byte firmsize_u=.
	label var firmsize_u "Firm size (upper bracket)"

*</_firmsize_u_>


** HOURS WORKED LAST WEEK
*<_whours_>
	gen whours=int(s5a041*s5a031)/4.25
	replace whours=. if lstatus==2| lstatus==3
	label var whours "Hours of work in last week"
*</_whours_>


** WAGES
*<_wage_>
	gen double wage=.
	replace wage=s5b081 if s5b081>=0 & s5b081!=.
	replace wage=s5b021 if s5b021>=0 & s5b021!=. & wage!=.
	replace wage=0 if empstat==2
	replace wage=. if lstatus!=1
	label var wage "Last wage payment"
*</_wage_>


** WAGES TIME UNIT
*<_unitwage_>
	gen byte unitwage=.
	replace unitwage=1 if s5b021==wage & wage!=.
	replace unitwage=5 if s5b081==wage & wage!=.
	replace unitwage=. if lstatus!=1
	label var unitwage "Last wages time unit"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Quarterly" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage lblunitwage
*</_wageunit_>


** EMPLOYMENT STATUS - SECOND JOB
*<_empstat_2_>
	gen byte empstat_2=.
	replace empstat_2=1 if s5a062==1
	replace empstat_2=4 if s5a062>=2 & s5a062<=3
	replace empstat_2=. if njobs==0 | njobs==. | lstatus!=1
	label var empstat_2 "Employment status - second job"
	la de lblempstat_2 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_2 lblempstat_2
*</_empstat_2_>

** EMPLOYMENT STATUS - SECOND JOB LAST YEAR
*<_empstat_2_year_>
	gen byte empstat_2_year=.
	replace empstat_2_year=empstat_2
	replace empstat_2_year=. if njobs_year==0 | njobs_year==. | lstatus_year!=1
	label var empstat_2_year "Employment status - second job last year"
	la de lblempstat_2_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_2_year lblempstat_2
*</_empstat_2_>

** INDUSTRY CLASSIFICATION - SECOND JOB
*<_industry_2_>
	gen byte industry_2=s5a01c2
	recode industry_2 (0/5=1) (10/14=2) (15/38=3) (40/43=4) (45=5) (50/59=6) (60/64=7) (65/74=8) (75=9) (76/99=10)
	replace industry_2=. if njobs==0 | njobs==. | lstatus!=1
	label var industry_2 "1 digit industry classification - second job"
	la de lblindustry_2 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industry_2 lblindustry
*<_industry_2_>


**SURVEY SPECIFIC INDUSTRY CLASSIFICATION - SECOND JOB
*<_industry_orig_2_>
	gen industry_orig_2=s5a01c2
	replace industry_orig_2=. if njobs==0 | njobs==. | lstatus!=1
	label var industry_orig_2 "Original Industry Codes - Second job"
	la de lblindustry_orig_2 1""
	label values industry_orig_2 lblindustry_orig
*</_industry_orig_2>


** OCCUPATION CLASSIFICATION - SECOND JOB
*<_occup_2_>
#delimit
recode s5a01b2 (1=3)	(2=2)	(3=3)	(4=2)	(5=3)	(6=2)	(40=1)	(8=2)	(9=2)	(10=2)	(12=2)	(13=2)	(14=3)	(15=2)	
(16=2)	(17=2)	(18=2)	(19=2)	(20=1)	(21=1)	(30=1)	(31=4)	(32=4)	(33=4)	(34=8)	(35=8)	(50=1)	(7=2)	(42=3)	(39=4)	(43=3)
	(44=3)	(86=3)	(37=4)	(38=4)	(36=5)	(45=5)	(51=5)	(52=5)	(53=5)	(54=5)	(49=5)	(70=6)	(58=5)	(59=5)	(60=6)	(61=6)	(63=6)
	(64=6)	(71=7)	(72=7)	(75=7)	(74=8)	(76=7)	(77=7)	(78=7)	(79=7)	(80=7)	(81=7)	(82=7)	(83=7)	(84=7)	(85=7)	(87=7)	(88=7)
	(89=7)	(92=7)	(90=8)	(91=8)	(55=9)	(56=9) (0 41=.), gen(occup_2);
	#delimit cr
	replace occup_2=. if njobs==0 | njobs==. | lstatus!=1
	label var occup_2 "1 digit occupational classification - second job"
	la de lbloccup_2 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup_2 lbloccup_2
*</_occup_2_>


** WAGES - SECOND JOB
*<_wage_2_>
	gen double wage_2=.
	replace wage_2=s5b082 if s5b082>=0 & s5b082~=.
	replace wage_2=s5b022 if s5b022>=0 & s5b022~=. 
	replace wage_2=0 if empstat_2==2
	replace wage_2=. if njobs==0 | njobs==. | lstatus!=1
	label var wage_2 "Last wage payment - Second job"
*</_wage_2_>


** WAGES TIME UNIT - SECOND JOB
*<_unitwage_2_>
	gen byte unitwage_2=.
	replace unitwage_2=1 if s5b022==wage_2 & wage_2!=.
	replace unitwage_2=5 if s5b082==wage_2 & wage_2!=.
	replace unitwage_2=. if njobs==0 | njobs==. | lstatus!=1
	label var unitwage_2 "Last wages time unit - Second job"
	la de lblunitwage_2 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Every two months"  5 "Monthly" 6 "Quarterly" 7 "Every six months" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage_2 lblunitwage_2
*</_unitwage_2_>

** CONTRACT
*<_contract_>
	gen byte contract=.
	label var contract "Contract"
	la de lblcontract 0 "Without contract" 1 "With contract"
	label values contract lblcontract
*</_contract_>


** HEALTH INSURANCE
*<_healthins_>
	gen byte healthins=.
	label var healthins "Health insurance"
	la de lblhealthins 0 "Without health insurance" 1 "With health insurance"
	label values healthins lblhealthins
*</_healthins_>


** SOCIAL SECURITY
*<_socialsec_>
	gen byte socialsec=.
	label var socialsec "Social security"
	la de lblsocialsec 1 "With" 0 "Without"
	label values socialsec lblsocialsec
*</_socialsec_>


** UNION MEMBERSHIP
*<_union_>
	gen byte union=.
	label var union "Union membership"
	la de lblunion 0 "No member" 1 "Member"
	label values union lblunion
*</_union_>

foreach var in lstatus lstatus_year empstat empstat_year njobs_year ocusec nlfreason unempldur_l unempldur_u industry_orig industry occup_orig occup firmsize_l firmsize_u whours wage unitwage empstat_2 empstat_2_year industry_2 industry_orig_2 occup_2 wage_2 unitwage_2 contract healthins socialsec union{
replace `var'=. if age<lb_mod_age
}

/*****************************************************************************************************
*                                                                                                    *
                                   MIGRATION MODULE
*                                                                                                    *
*****************************************************************************************************/


**REGION OF BIRTH JURISDICTION
*<_rbirth_juris_>
	gen byte rbirth_juris=.
	label var rbirth_juris "Region of birth jurisdiction"
	la de lblrbirth_juris 1 "subnatid1" 2 "subnatid2" 3 "subnatid3" 4 "Other country"  9 "Other code"
	label values rbirth_juris lblrbirth_juris
*</_rbirth_juris_>

**REGION OF BIRTH
*<_rbirth_>
	gen byte rbirth=.
	label var rbirth "Region of Birth"
*</_rbirth_>

** REGION OF PREVIOUS RESIDENCE JURISDICTION
*<_rprevious_juris_>
	gen byte rprevious_juris=.
	label var rprevious_juris "Region of previous residence jurisdiction"
	la de lblrprevious_juris 1 "reg01" 2 "reg02" 3 "reg03" 4 "Other country"  9 "Other code"
	label values rprevious_juris lblrprevious_juris
*</_rprevious_juris_>

**REGION OF PREVIOUS RESIDENCE
*<_rprevious_>
	gen byte rprevious=.
	label var rprevious "Region of previous residence"
*</_rprevious_>

** YEAR OF MOST RECENT MOVE
*<_yrmove_>
	gen int yrmove=.
	label var yrmove "Year of most recent move"
*</_yrmove_>

/*****************************************************************************************************
*                                                                                                    *
                                            ASSETS 
*                                                                                                    *
*****************************************************************************************************/

** LAND PHONE
*<_landphone_>

	gen landphone=.
	label var landphone "Household has landphone"
	la de lbllandphone 0 "No" 1 "Yes"
	label values landphone lbllandphone
*</_landphone_>


** CEL PHONE
*<_cellphone_>
	gen cellphone=.
	label var cellphone "Household has Cell phone"
	la de lblcellphone 0 "No" 1 "Yes"
	label values cellphone lblcellphone
*</_cellphone_>


** COMPUTER
*<_computer_>
	gen computer=.
	label var computer "Household has computer"
	la de lblcomputer 0 "No" 1 "Yes"
	label values computer lblcomputer
*</_computer_>

** RADIO
*<_radio_>
	gen radio= numberRadio______541>0 & !mi(numberRadio______541)
	label var radio "Household has radio"
	la de lblradio 0 "No" 1 "Yes"
	label val radio lblradio
*</_radio_>

** TELEVISION
*<_television_>
	gen television= numberTelevision_552>0 & numberTelevision_552<.
	label var television "Household has Television"
	la de lbltelevision 0 "No" 1 "Yes"
	label val television lbltelevision
*</_television>

** FAN
*<_fan_>
	gen fan= numberFans_______549>0 & numberFans_______549<.
	label var fan "Household has Fan"
	la de lblfan 0 "No" 1 "Yes"
	label val fan lblfan
*</_fan>

** SEWING MACHINE
*<_sewingmachine_>
	gen sewingmachine=numberSewing_mach556>0 & numberSewing_mach556<.
	label var sewingmachine "Household has Sewing machine"
	la de lblsewingmachine 0 "No" 1 "Yes"
	label val sewingmachine lblsewingmachine
*</_sewingmachine>

** WASHING MACHINE
*<_washingmachine_>
	gen washingmachine=numberWashing_mac548>0 & numberWashing_mac548<.
	label var washingmachine "Household has Washing machine"
	la de lblwashingmachine 0 "No" 1 "Yes"
	label val washingmachine lblwashingmachine
*</_washingmachine>

** REFRIGERATOR
*<_refrigerator_>
	gen refrigerator=numberRefrigerato547>0 & numberRefrigerato547<.
	label var refrigerator "Household has Refrigerator"
	la de lblrefrigerator 0 "No" 1 "Yes"
	label val refrigerator lblrefrigerator
*</_refrigerator>

** LAMP
*<_lamp_>
	gen lamp=.
	label var lamp "Household has Lamp"
	la de lbllamp 0 "No" 1 "Yes"
	label val lamp lbllamp
*</_lamp>

** BYCICLE
*<_bycicle_>
	gen bicycle=numberBicycle____544>0 & numberBicycle____544<.
	label var bicycle "Household has Bicycle"
	la de lblbycicle 0 "No" 1 "Yes"
	label val bicycle lblbycicle
*</_bycicle>

** MOTORCYCLE
*<_motorcycle_>
	gen motorcycle=numberMotorcycle_545>0 & numberMotorcycle_545<.
	label var motorcycle "Household has Motorcycle"
	la de lblmotorcycle 0 "No" 1 "Yes"
	label val motorcycle lblmotorcycle
*</_motorcycle>

** MOTOR CAR
*<_motorcar_>
	gen motorcar= numberMotor_car_e546>0 & numberMotor_car_e546<.
	label var motorcar "Household has Motor car"
	la de lblmotorcar 0 "No" 1 "Yes"
	label val motorcar lblmotorcar
*</_motorcar>

** COW
*<_cow_>
	gen cow=numCattle201>0 & numCattle201<.
	label var cow "Household has Cow"
	la de lblcow 0 "No" 1 "Yes"
	label val cow lblcow
*</_cow>

** BUFFALO
*<_buffalo_>
	gen buffalo=numBuffalo204>0 & numBuffalo204<.
	label var buffalo "Household has Buffalo"
	la de lblbuffalo 0 "No" 1 "Yes"
	label val buffalo lblbuffalo
*</_buffalo>

** CHICKEN
*<_chicken_>
	gen chicken=numChicken206>0 & numChicken206<.
	label var chicken "Household has Chicken"
	la de lblchicken 0 "No" 1 "Yes"
	label val chicken lblchicken
*</_chicken>

notes _dta: "BGD 2000" creation of assets for BGD in 2000 was done assuming that missing values reported in the durables list were zero for all households. The reason behind this is because we do not have good reports from the module of durables.
/*****************************************************************************************************
*                                                                                                    *
                                   WELFARE MODULE
*                                                                                                    *
*****************************************************************************************************/


** SPATIAL DEFLATOR
*<_spdef_>
	gen spdef=zu00
	la var spdef "Spatial deflator"
*</_spdef_>

** WELFARE
*<_welfare_>
	gen welfare=pcexp
	la var welfare "Welfare aggregate"
*</_welfare_>

*<_welfarenom_>
	gen welfarenom=pcexp
	la var welfarenom "Welfare aggregate in nominal terms"
*</_welfarenom_>

*<_welfaredef_>
	gen welfaredef=.
	la var welfaredef "Welfare aggregate spatially deflated"
*</_welfaredef_>

*<_welfshprosperity_>
	gen welfshprosperity=welfare
	la var welfshprosperity "Welfare aggregate for shared prosperity"
*</_welfshprosperity_>

*<_welfaretype_>
	gen welfaretype="EXP"
	la var welfaretype "Type of welfare measure (income, consumption or expenditure) for welfare, welfarenom, welfaredef"
*</_welfaretype_>

*<_welfareother_>
	gen welfareother=(income/12)/hsize
	la var welfareother "Welfare Aggregate if different welfare type is used from welfare, welfarenom, welfaredef"
*</_welfareother_>

*<_welfareothertype_>
	gen welfareothertype="INC"
	la var welfareothertype "Type of welfare measure (income, consumption or expenditure) for welfareother"
*</_welfareothertype_>

*<_welfarenat_>
	gen welfarenat=welfare
	la var welfarenat "Welfare aggregate for national poverty"
*</_welfarenat_>

*QUINTILE AND DECILE OF CONSUMPTION AGGREGATE
	levelsof year, loc(y)
	merge m:1 idh using "$shares\\BGD_fnf_`y'", keepusing (quintile_cons_aggregate decile_cons_aggregate)
	drop _merge

	note _dta: "BGD 2000" Food/non-food shares are not included because there is not enough information to replicate their composition. 


/*****************************************************************************************************
*                                                                                                    *
                                   NATIONAL POVERTY
*                                                                                                    *
*****************************************************************************************************/


** POVERTY LINE (NATIONAL)
*<_pline_nat_>
	gen pline_nat=zu00
	label variable pline_nat "Poverty Line (National)"
*</_pline_nat_>


** HEADCOUNT RATIO (NATIONAL)
*<_poor_nat_>
	gen poor_nat=welfarenat<pline_nat & welfare!=.
	la var poor_nat "People below Poverty Line (National)"
	la define poor_nat 0 "Not Poor" 1 "Poor"
	la values poor_nat poor_nat
*</_poor_nat_>

	
/*****************************************************************************************************
*                                                                                                    *
                                   INTERNATIONAL POVERTY
*                                                                                                    *
*****************************************************************************************************/


	local year=2011
	
** USE SARMD CPI AND PPP
*<_cpi_>
	capture drop _merge
	gen urb=.
	merge m:1 countrycode year urb using "$pricedata", ///
	keepusing(countrycode year urb syear cpi`year'_w ppp`year')
	drop urb
	drop if _merge!=3
	drop _merge
	
	
** CPI VARIABLE
	ren cpi`year'_w cpi
	label variable cpi "CPI (Base `year'=1)"
*</_cpi_>
	
	
** PPP VARIABLE
*<_ppp_>
	ren ppp`year' 	ppp
	label variable ppp "PPP `year'"
*</_ppp_>

	
** CPI PERIOD
*<_cpiperiod_>
	gen cpiperiod=syear
	label var cpiperiod "Periodicity of CPI (year, year&month, year&quarter, weighted)"
*</_cpiperiod_>	
	
** POVERTY LINE (POVCALNET)
*<_pline_int_>
	gen pline_int=1.90*cpi*ppp*365/12
	label variable pline_int "Poverty Line (Povcalnet)"
*</_pline_int_>
	
	
** HEADCOUNT RATIO (POVCALNET)
*<_poor_int_>
	gen poor_int=welfare<pline_int & welfare!=.
	la var poor_int "People below Poverty Line (Povcalnet)"
	la define poor_int 0 "Not Poor" 1 "Poor"
	la values poor_int poor_int
*</_poor_int_>

/*****************************************************************************************************
*                                                                                                    *
                                   FINAL STEPS
*                                                                                                    *
*****************************************************************************************************/
** KEEP VARIABLES - ALL
	do "$fixlabels\fixlabels", nostop

	keep countrycode year survey idh idp wgt pop_wgt strata psu vermast veralt urban int_month int_year  ///
		subnatid1 subnatid2 subnatid3 ownhouse landholding tenure water_orig piped_water water_jmp sar_improved_water  electricity toilet_orig sewage_toilet toilet_jmp sar_improved_toilet  landphone cellphone ///
	     computer internet hsize relationharm relationcs male age soc marital ed_mod_age everattend ///
		 water_original water_source improved_water pipedwater_acc watertype_quest sanitation_original sanitation_source improved_sanitation toilet_acc ///
	     atschool electricity literacy educy educat4 educat5 educat7 lb_mod_age lstatus lstatus_year empstat empstat_year njobs njobs_year ///
	     ocusec nlfreason unempldur_l unempldur_u industry_orig industry occup_orig occup firmsize_l firmsize_u whours wage ///
		  unitwage empstat_2 empstat_2_year industry_2 industry_orig_2 occup_2 wage_2 unitwage_2 contract healthins socialsec union rbirth_juris rbirth rprevious_juris rprevious yrmove ///
		 landphone cellphone computer radio television fan sewingmachine washingmachine refrigerator lamp bicycle motorcycle motorcar cow buffalo chicken  ///
		 pline_nat pline_int poor_nat poor_int spdef cpi ppp cpiperiod welfare welfshprosperity welfarenom welfaredef welfarenat quintile_cons_aggregate decile_cons_aggregate welfareother welfaretype   welfareothertype  
		 
** ORDER VARIABLES

	order countrycode year survey idh idp wgt pop_wgt strata psu vermast veralt urban int_month int_year  ///
		subnatid1 subnatid2 subnatid3 ownhouse landholding tenure water_orig piped_water water_jmp sar_improved_water ///
		water_original water_source improved_water pipedwater_acc watertype_quest electricity toilet_orig sewage_toilet ///
		toilet_jmp sar_improved_toilet sanitation_original sanitation_source improved_sanitation toilet_acc landphone cellphone ///
	     computer internet hsize relationharm relationcs male age soc marital ed_mod_age everattend ///
	     atschool electricity literacy educy educat4 educat5 educat7 lb_mod_age lstatus lstatus_year empstat empstat_year njobs njobs_year ///
	     ocusec nlfreason unempldur_l unempldur_u industry_orig industry occup_orig occup firmsize_l firmsize_u whours wage ///
		  unitwage empstat_2 empstat_2_year industry_2 industry_orig_2 occup_2 wage_2 unitwage_2 contract healthins socialsec union rbirth_juris rbirth rprevious_juris rprevious yrmove ///
		 landphone cellphone computer radio television fan sewingmachine washingmachine refrigerator lamp bicycle motorcycle motorcar cow buffalo chicken  ///
		 pline_nat pline_int poor_nat poor_int spdef cpi ppp cpiperiod welfare welfshprosperity welfarenom welfaredef welfarenat quintile_cons_aggregate decile_cons_aggregate welfareother welfaretype  welfareothertype  
	compress

** DELETE MISSING VARIABLES

	foreach w in welfare welfareother {
	
		qui su `w'
		if r(N)==0 {
		
			drop `w'type
			
		}
	}

	
	glo keep=""
	qui levelsof countrycode, local(cty)
	foreach var of varlist countrycode - welfaretype {
		capture assert mi(`var')
		if !_rc {
		
			 display as txt "Variable " as result "`var'" as txt " for countrycode " as result `cty' as txt " contains all missing values -" as error " Variable Deleted"
			 
		}
		else {
		
			 glo keep = "$keep"+" "+"`var'"
			 
		}
	}
	
	keep countrycode year survey idh idp wgt pop_wgt strata psu vermast veralt ${keep} *type
	compress


	saveold "`output'\Data\Harmonized\BGD_2000_HIES_v01_M_v04_A_SARMD-FULL_IND.dta", replace version(12)
	saveold "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\BGD_2000_HIES_v01_M_v04_A_SARMD-FULL_IND.dta", replace version(12)

*********************************************************************************************************************************	
******RENAME COMPARABLE VARIABLES AND SAVE THEM IN _SARMD. UNCOMPARABLE VARIALBES ACROSS TIME SHOULD BE FOUND IN _SARMD-FULL*****
*********************************************************************************************************************************

loc var toilet_jmp  sar_improved_toilet empstat empstat_year ///
empstat_2 empstat_2_year  landholding unitwage wage unitwage_2 wage_2  toilet_jmp  sar_improved_toilet

foreach i of loc var{

cap sum `i'

	if _rc==0{
	loc a: var label `i'
	la var `i' "`a'-old non-comparable version"
	cap rename `i' `i'_v2
	}
	else if _rc==111{
	dis as error "Variable `i' does not exist in data-base"
	}
	
}	
	note _dta: "BGD 2000" Variables NAMED with "v2" are those not compatible with latest round (2010). ///
 These include the existing information from the particular survey, but the iformation should be used for comparability purposes  

		saveold "`output'\Data\Harmonized\BGD_2000_HIES_v01_M_v04_A_SARMD_IND.dta", replace version(12)
	saveold "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\BGD_2000_HIES_v01_M_v04_A_SARMD_IND.dta", replace version(12)

	

	log close




******************************  END OF DO-FILE  *****************************************************/
