/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                                   SOUTH ASIA MICRO DATABASE                                      **
**                                                                                                  **
** COUNTRY			Sri Lanka
** COUNTRY ISO CODE	LKA
** YEAR				2009
** SURVEY NAME		HOUSEHOLD INCOME AND EXPENDITURE SURVEY - 2009/10
** SURVEY AGENCY	NATIONAL HOUSEHOLD SAMPLE SURVEY PROGRAMME
** RESPONSIBLE		Triana Yentzen
** MODFIED BY		Julian Eduardo Diaz Gutierrez
** Date				08/12/2016
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
	local input "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\LKA\LKA_2009_HIES\LKA_2009_HIES_v01_M"
	local output "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\LKA\LKA_2009_HIES\LKA_2009_HIES_v01_M_v03_A_SARMD\"
	glo pricedata "D:\SOUTH ASIA MICRO DATABASE\CPI\cpi_ppp_sarmd_weighted.dta"
	glo shares "D:\SOUTH ASIA MICRO DATABASE\APPS\DATA CHECK\Food and non-food shares\LKA"
	glo fixlabels "D:\SOUTH ASIA MICRO DATABASE\APPS\DATA CHECK\Label fixing"

** LOG FILE
	log using "`output'\Doc\Technical\LKA_2009_HIES_v01_M_v03_A_SARMD.log",replace


/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/


** DATABASE ASSEMBLENT

* PREPARE DATABASES

* School Education
	use "`input'\Data\Stata\hies_2009_sec2_school.dta", clear
	sort district sector dsdiv month psu sample serial numhh result pno
	tempfile education
	save `education'
	
* Employment & Income
	use "`input'\Data\Stata\hies_2009_sec5_1_empincome.dta",clear
	sort district sector dsdiv month psu sample serial numhh result pno
	bys district sector dsdiv month psu sample serial numhh result pno: gen n=_n
	replace n=n-1
	bys district sector dsdiv month psu sample serial numhh result pno: egen njobs=max(n)
	drop if main_sec==2
	sort district sector dsdiv month psu sample serial numhh result pno wage_1m
	duplicates tag district sector dsdiv month psu sample serial numhh result pno, gen(tag)
	drop if tag==1 & main_sec==.
	drop main_sec tag n
	tempfile employment
	save `employment'
	
*Housing
	use "`input'\Data\Stata\hies_2009_sec8_housing.dta", clear
	sort district sector dsdiv month psu sample serial numhh result
	tempfile housing
	save `housing'

*Durables
	use "`input'\Data\Stata\hies_2009_sec6a_goods", clear
	sort district sector dsdiv month psu sample serial numhh result
	tempfile durables
	save `durables'
	
*Landholding
	use "`input'\Data\Stata\hies_2009_sec9_land_livestock", clear
	sort district sector dsdiv month psu sample serial numhh result
	tempfile landholding
	save `landholding'

* MERGE

* Demographic
	use "`input'\Data\Stata\hies_2009_sec1_demo.dta"
	sort district sector dsdiv month psu sample serial numhh result pno

* School Education
	merge district sector dsdiv month psu sample serial numhh result pno using `education'
	tab 	_merge
	drop 	_merge
	sort district sector dsdiv month psu sample serial numhh result pno

* Employmen & Income
	merge district sector dsdiv month psu sample serial numhh result pno using `employment'
	tab 	_merge
	ren 	_merge mergeem
	sort district sector dsdiv month psu sample serial numhh result pno

*Housing
	merge district sector dsdiv month psu sample serial numhh result using `housing'
	tab 	_merge
	drop 	_merge

*Durables
	merge m:1 district sector dsdiv month psu sample serial numhh result using `durables'
	tab 	_merge
	drop 	_merge

*Landholding
	merge m:1 district sector dsdiv month psu sample serial numhh result using `landholding'
	tab 	_merge
	drop 	_merge

	
* Consumption Aggregate
	assert hhid != ""
	lab var hhid "household id"

	ren province province_str
	merge m:1 hhid using "`input'\Data\Stata\wfile2009.dta"
	tab _merge
	
	
* Drop people not living in the house
	drop if pno>=40

notes _dta: "LKA 2009" Data analysis done only on people whom are lving in the house.

	
/*****************************************************************************************************
*                                                                                                    *
                                   * STANDARD SURVEY MODULE
*                                                                                                    *
*****************************************************************************************************/

	
** COUNTRY
*<_countrycode_>
	gen str4 countrycode="LKA"
	label var countrycode "Country code"
*</_countrycode_>


** YEAR
*<_year_>
	gen int year=2009
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
	gen   idh=hhid
	tostring hhid, replace
	label var idh "Household id"
*</_idh_>


** INDIVIDUAL IDENTIFICATION NUMBER
*<_idp_>

	egen idp=concat(idh pno)
	label var idp "Individual id"
*</_idp_>
	duplicates drop idp,force

	
** HOUSEHOLD WEIGHTS
*<_wgt_>
	gen double wgt=weight
	label var wgt "Household sampling weight"
*</_wgt_>


** STRATA
*<_strata_>
	gen strata=.
	label var strata "Strata"
	note strata: "LKA 2009" Variable strata cannot be readily identified
*</_strata_>


** PSU
*<_psu_>
	label var psu "Primary sampling units"
*</_psu_>

	
** MASTER VERSION
*<_vermast_>

	gen vermast="01"
	label var vermast "Master Version"
*</_vermast_>
	
	
** ALTERATION VERSION
*<_veralt_>

	gen veralt="03"
	label var veralt "Alteration Version"
*</_veralt_>	
	
/*****************************************************************************************************
*                                                                                                    *
                                   FIX ISSUES WITHIN THE RAW DATA
*                                                                                                    *
*****************************************************************************************************/


* More than one houosehold head
	gen hdind=(relation==1)
	recode hdind (0=.)
	bysort idh : egen count=count(hdind)

	replace relation=5 if count!=1 & relation==1 & pno!=1
	drop count hdind

	
/*****************************************************************************************************
*                                                                                                    *
                                   HOUSEHOLD CHARACTERISTICS MODULE
*                                                                                                    *
*****************************************************************************************************/


** LOCATION (URBAN/RURAL)
*<_urban_>
	gen byte urban=sector
	recode urban (2 3=0)
	label var urban "Urban/Rural"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban
*</_urban_>

** LOCATION (ESTATE)
*<_sector_>
	label define lblsector 1 "Urban" 2 "Rural" 3 "Estate"
	label values sector lblsector
	label var sector "Sector (Sri Lanka)"
	notes _dta: "LKA 2009" Variable "sector" not included in the dictionaries and left as missing.

*</_sector_>


** REGIONAL AREA 1 DIGIT ADMN LEVEL
*<_subnatid1_>
	gen byte subnatid1=district
	recode subnatid1 (11/13=1) (21/23=2) (31/33=3) (41/45=4) (51/53=5) (61/62=6) (71/72=7) (81/82=8) (91/92=9)
	la de lblsubnatid1 1 "Western" 2 "Central" 3 "Southern" 4 "Northern" 5 "Eastern" 6 "North-Western" 7"North-Central" 8"Uva" 9"Sabaragamuwa"
	label var subnatid1 "Macro regional areas"
	label values subnatid1 lblsubnatid1
		numlabel lblsubnatid1, remove
		numlabel lblsubnatid1, add mask("# - ")
		decode subnatid1, gen(subnatid1_temp)
		drop subnatid1
		rename subnatid1_temp subnatid1
*</_subnatid1_>


	*<_gaul_adm1_code_>
		gen gaul_adm1_code=.
		label var gaul_adm1_code "GAUL code for admin1 level"
		replace gaul_adm1_code=2096 if subnatid1=="2 - Central"
		replace gaul_adm1_code=2097 if subnatid1=="5 - Eastern"
		replace gaul_adm1_code=2098 if subnatid1=="7 - North-central"
		replace gaul_adm1_code=2099 if subnatid1=="6 - North-western"
		replace gaul_adm1_code=2100 if subnatid1=="4 - Northern"
		replace gaul_adm1_code=2101 if subnatid1=="9 - Sabaragamuwa"
		replace gaul_adm1_code=2102 if subnatid1=="3 - Southern"
		replace gaul_adm1_code=2103 if subnatid1=="8 - Uva"
		replace gaul_adm1_code=2104 if subnatid1=="1 - Western"
	*<_gaul_adm1_code_>


** REGIONAL AREA 2 DIGIT ADMN LEVEL
*<_subnatid2_>
	gen byte subnatid2=district
	la de lblsubnatid2  11 "Colombo" 12 "Gampaha" 13 "Kalutara" 21 "Kandy" 22 "Matale" 23 "Nuwara-eliya" 31 "Galle" 32 "Matara" 33 "Hambantota" 41 "Jaffna" 42 "Mannar" 43 "Vavuniya" 44 "Mullaitivu" 45 "Kilinochchi" 51 "Batticaloa" 52 "Ampara" 53 "Tricomalee" 61 "Kurunegala" 62 "Puttlam" 71 "Anuradhapura" 72 "Polonnaruwa" 81 "Badulla" 82 "Moneragala" 91 "Ratnapura" 92 "Kegalle"
	label var subnatid2 "Region at 1 digit (ADMN1)"
	label values subnatid2 lblsubnatid2
		numlabel lblsubnatid2, remove
		numlabel lblsubnatid2, add mask("# - ")
		decode subnatid2, gen(subnatid2_temp)
		drop subnatid2
		rename subnatid2_temp subnatid2
*</_subnatid2_>


	*<_gaul_adm2_code_>
		gen gaul_adm2_code=.
		label var gaul_adm2_code "GAUL code for admin2 level"
		replace gaul_adm2_code=30896 if subnatid2=="13 - Kalutara"
		replace gaul_adm2_code=30895 if subnatid2=="12 - Gampaha"
		replace gaul_adm2_code=30894 if subnatid2=="11 - Colombo"
		replace gaul_adm2_code=30893 if subnatid2=="82 - Moneragala"
		replace gaul_adm2_code=30892 if subnatid2=="81 - Badulla"
		replace gaul_adm2_code=30891 if subnatid2=="32 - Matara"
		replace gaul_adm2_code=30890 if subnatid2=="33 - Hambantota"
		replace gaul_adm2_code=30889 if subnatid2=="31 - Galle"
		replace gaul_adm2_code=30888 if subnatid2=="91 - Ratnapura"
		replace gaul_adm2_code=30887 if subnatid2=="92 - Kegalle"
		replace gaul_adm2_code=30886 if subnatid2=="43 - Vavuniya"
		replace gaul_adm2_code=30885 if subnatid2=="44 - Mullaitivu"
		replace gaul_adm2_code=30884 if subnatid2=="42 - Mannar"
		replace gaul_adm2_code=30883 if subnatid2=="45 - Kilinochchi"
		replace gaul_adm2_code=30882 if subnatid2=="41 - Jaffna"
		replace gaul_adm2_code=30881 if subnatid2=="62 - Puttlam"
		replace gaul_adm2_code=30880 if subnatid2=="61 - Kurunegala"
		replace gaul_adm2_code=30879 if subnatid2=="72 - Polonnaruwa"
		replace gaul_adm2_code=30878 if subnatid2=="71 - Anuradhapura"
		replace gaul_adm2_code=30877 if subnatid2=="53 - Tricomalee"
		replace gaul_adm2_code=30876 if subnatid2=="51 - Batticaloa"
		replace gaul_adm2_code=30875 if subnatid2=="52 - Ampara"
		replace gaul_adm2_code=30874 if subnatid2=="23 - Nuwara-eliya"
		replace gaul_adm2_code=30873 if subnatid2=="21 - Kandy"
		replace gaul_adm2_code=30872 if subnatid2=="22 - Matale"
	*<_gaul_adm2_code_>
	

** REGIONAL AREA 3 DIGIT ADMN LEVEL
*<_subnatid3_>
	gen byte subnatid3=.
	label var subnatid3 "Region at 3 digit (ADMN3)"
	label values subnatid3 lblsubnatid3
*</_subnatid3_>


** HOUSE OWNERSHIP
*<_ownhouse_>
	gen byte ownhouse=ownership
	recode ownhouse (1/4=1) (5/99=0)
	label var ownhouse "House ownership"
	la de lblownhouse 0 "No" 1 "Yes"
	label values ownhouse lblownhouse
*</_ownhouse_>

** TENURE OF DWELLING
*<_tenure_>
   gen tenure=.
   replace tenure=1 if ownership>0 & ownership<=4
   replace tenure=2 if ownership>4 & ownership<=7
   replace tenure=3 if tenure!=1 & tenure!=2 & ownership<.
   label var tenure "Tenure of Dwelling"
   la de lbltenure 1 "Owner" 2"Renter" 3"Other"
   la val tenure lbltenure
*</_tenure_>	


** LANDHOLDING
*<_lanholding_>
   gen landholding=.
   replace landholding=. if aglandown==. | aglandown==3
   label var landholding "Household owns any land"
   la de lbllandholding 0 "No" 1 "Yes"
   la val landholding lbllandholding
*</_tenure_>	


*ORIGINAL WATER CATEGORIES
*<_water_orig_>
gen water_orig=drinkwat
la var water_orig "Source of Drinking Water-Original from raw file"
#delimit
la def lblwater_orig 1 "Protected well within premises"
					 2 "Protected well outside premises"
					 3 "Unprotected well"
					 4 "Tube well"
					 5 "Tap within unit/Premises (main line)"
					 6 "Tap outside premises (main line)"
					 7 "Stream water collected & distributed by pipe lines"
					 8 "River/Tank/Streams"
					 9 "Other";
#delimit cr
la val water_orig lblwater_orig
*</_water_orig_>


*PIPED SOURCE OF WATER
*<_piped_water_>
gen piped_water=.
replace piped_water=1 if drinkwat==5 | drinkwat==6
replace piped_water=0 if drinkwat<5 | drinkwat>6
la var piped_water "Household has access to piped water"
la def lblpiped_water 1 "Yes" 0 "No"
la val piped_water lblpiped_water
*</_piped_water_>


**INTERNATIONAL WATER COMPARISON (Joint Monitoring Program)
*<_water_jmp_>
gen water_jmp=.
replace water_jmp=5 if inlist(drinkwat,1,2)
replace water_jmp=6 if inlist(drinkwat,3)
replace water_jmp=4 if inlist(drinkwat,4)
replace water_jmp=1 if inlist(drinkwat,5)
replace water_jmp=2 if inlist(drinkwat,6)
replace water_jmp=14 if inlist(drinkwat,7)
replace water_jmp=12 if inlist(drinkwat,8)
replace water_jmp=14 if inlist(drinkwat,9)

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
note water_jmp: "LKA 2009" Category "Stream water collected & distributed by pipe lines" is ///
identified as "other" in water_jmp, but it is an unimproved source of drinking water. See (www.wssinfo.org/documents/?tx_displaycontroller%5Bregion%5D=&tx_displaycontroller%5Bsearch_word%5D=Sri+Lanka&tx_displaycontroller%5Btype%5D=country_files) for more clarification
*</_water_jmp_>

 
 *SAR improved source of drinking water
*<_sar_improved_water_>
gen sar_improved_water=.
replace sar_improved_water=1 if inlist(water_jmp,1,2,3,4,5,7,9)
replace sar_improved_water=0 if inlist(water_jmp, 6,8,10,11,12,13,14)
replace sar_improved_water=1 if drinkwat==7
la def lblsar_improved_water 1 "Improved" 0 "Unimproved"
la var sar_improved_water "Improved source of drinking water-using country-specific definitions"
la val sar_improved_water lblsar_improved_water
*</_sar_improved_water_>


** ELECTRICITY PUBLIC CONNECTION
*<_electricity_>
	gen byte electricity=lighting
	recode electricity (2=1) (nonmiss=0)
	label var electricity "Electricity main source"
	la de lblelectricity 0 "No" 1 "Yes"
	label values electricity lblelectricity
	notes electricity: "LKA 2009" variable was created if household's main source of lighting is electricity
*</_electricity_>


*ORIGINAL TOILET CATEGORIES
*<_toilet_orig_>
gen toilet_orig=toilettype
la var toilet_orig "Access to sanitation facility-Original from raw file"
#delimit
la def lbltoilet_orig 1 "Water seal"
					  2 "Pour flush"
					  3 "Pit"
					  9 "Other";
#delimit cr
la val toilet_orig lbltoilet_orig
*</_toilet_orig_>

*SEWAGE TOILET
*<_sewage_toilet_>
gen sewage_toilet=.
*replace sewage_toilet=1 if  toilettype<=2
*replace sewage_toilet=0 if  toilettype>=3
la var sewage_toilet "Household has access to sewage toilet"
la def lblsewage_toilet 1 "Yes" 0 "No"
la val sewage_toilet lblsewage_toilet
note sewage_toilet: "LKA 2009" There is not certainty if water seal/pour flush are sanitation sources connected to sewage system
*</_sewage_toilet_>


**INTERNATIONAL SANITATION COMPARISON (Joint Monitoring Program)
*<_toilet_jmp_>
gen toilet_jmp=.
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
*</_toilet_jmp_>
note toilet_jmp: "LKA 2009" Due to multiple ambiguities, toilet_jmp could not be identified.

*SAR improved type of toilet
*<_sar_improved_toilet_>
gen sar_improved_toilet=.
replace sar_improved_toilet=1 if toilettype<=2
replace sar_improved_toilet=0 if toilettype>=3
replace sar_improved_toilet=0 if toiletuse==2
la def lblsar_improved_toilet 1 "Improved" 0 "Unimproved"
la var sar_improved_toilet "Improved type of sanitation facility-using country-specific definitions"
la val sar_improved_toilet lblsar_improved_toilet
*</_sar_improved_toilet_>

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

	bysort idh : egen hsize=count(pno) 
	la var hsize "Household size"
	notes hsize: "LKA 2009" all individuals normally living in the household  were taken into account for the measurement of household size, according to questionnaire
*</_hsize_>

**POPULATION WEIGHT
*<_pop_wgt_>
	gen pop_wgt=wgt*hsize
	la var pop_wgt "Population weight"
*</_pop_wgt_>


** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
*<_relationharm_>
	gen byte relationharm=relation
	recode relationharm ( 6/9=6)
	label var relationharm "Relationship to the head of household"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Non-relatives"
	label values relationharm  lblrelationharm
*</_relationharm_>

** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
*<_relationcs_>

	gen byte relationcs=relation
	la var relationcs "Relationship to the head of household country/region specific"
	la define lblrelationcs 1 "Head" 2 "Wife/Husband" 3 "Son/Daughter" 4 "Parents" 5 "Other relative" 6 "Domestic servants" 7 "Boarder" 9 "Other"
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
	* Generate Age based on Month and Year of Birth for missing cases
	* 99.5% of cases turns out to be 0 == babies
	gen 	year_interview=2009 if month>=7 & month!=.
	replace year_interview=2010 if month<=6
	gen birth_year_b=.
	replace birth_year_b=2000 if birth_year<=10
	replace birth_year_b=1900 if birth_year>10 & birth_year!=.
	replace birth_year=birth_year+birth_year_b
	gen dob=mdy(b_month,1,birth_year)
	gen date=mdy(month,1,year_interview)
	gen age_date=int((date-dob)/365)
	replace age=age_date if age==. & age_date!=.
	replace age=98 if age>=98 & age<.
	label var age "Age of individual"
	notes age: "LKA 2009" Variable was generated based on the month and year of birth for missing cases
*</_age_>

** SOCIAL GROUP
*<_soc_>
	gen byte soc=ethnic
	recode soc (9=7)
	label var soc "Social group"
	la de lblsoc 1 "Sinhala" 2"Sri Lanka Tamil" 3"Indian Tamil" 4"Sri Lanka Moors" 5"Malay" 6"Burgher" 7"Other"
	label values soc lblsoc
*</_soc_>

** MARITAL STATUS
*<_marital_>*	gen byte marital=marital_status
	recode marital (1=2) (2=1) (3=5) (4/5=4)
	label var marital "Marital status"
	la de lblmarital 1 "Married" 2 "Never Married" 3 "Living Together" 4 "Divorced/separated" 5 "Widowed"
	label values marital lblmarital
	replace marital=. if age<10 & marital!=.
	notes marital:"LKA 2009" 18 observation of computed age were assignted to missing on marital status because marital should only be answered by people 10 years old and above
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


* CURRENTLY AT SCHOOL
*<_atschool_>
	gen byte atschool=1 if s_attend==1
	replace atschool=0 if s_attend==2 | s_attend==3 | education==19
	replace atschool=1 if school>=2 & school<=5
	replace atschool=0 if school==7
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool
	notes atschool: "LKA 2009" attendace variable was used (people 5=>)
*</_atschool_>*/


** CAN READ AND WRITE
*<_literacy_>
	gen byte literacy=.
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
	notes literacy: "LKA 2009" no question that relates literacy for this round
*</_literacy_>

	replace education=. if education==17


** YEARS OF EDUCATION COMPLETED
*<_educy_>
	gen byte educy=education
	recode educy (19 = 0) (14=13) (15 = 17) (16 = 19) (17=.)
	label var educy "Years of education"
	replace educy=0 if education==19
	replace educy=0 if s_attend==2
	replace educy=. if educy>=age-2 & educy!=. & age!=.
	replace age=. 	if educy>=age-2 & educy!=. & age!=.
*</_educy_>
	
** EDUCATION LEVEL 7 CATEGORIES
*<_educat7_>
	gen byte educat7=education
	recode educat7 (19 = 1) (0/5 = 2) (6 = 3) (7/10 = 4) (11/14 = 5) (15/16 = 7) (17=.)
	replace educat7=1 if educy==0
	label define lbleducat7 1 "No education" 2 "Primary incomplete" 3 "Primary complete" ///
	4 "Secondary incomplete" 5 "Secondary complete" 6 "Higher than secondary but not university" /// 
	7 "University incomplete or complete" 8 "Other" 9 "Not classified"
	label values educat7 lbleducat7
	la var educat7 "Level of education 7 categories"
*</_educat7_>



** EDUCATION LEVEL 5 CATEGORIES
*<_educat5_>
	gen educat5=.
	replace educat5=1 if educat7==1
	replace educat5=2 if educat7==2
	replace educat5=3 if educat7==3 | educat7==4
	replace educat5=4 if educat7==5
	replace educat5=5 if educat7==6 | educat7==7
	la var educat5 "Level of education 5 categories"
	label define lbleducat5 1 "No education" 2 "Primary incomplete" ///
	3 "Primary complete but secondary incomplete" 4 "Secondary complete" ///
	5 "Some tertiary/post-secondary"
	label values educat5 lbleducat5
*</_educat5_>


** EDUCATION LEVEL 4 CATEGORIES
*<_educat4_>
	gen byte educat4=.
	replace educat4=1 if educat7==1 
	replace educat4=2 if educat7==2 | educat7==3
	replace educat4=3 if educat7==4 | educat7==5
	replace educat4=4 if educat7==6 | educat7==7
	label var educat4 "Level of education 4 categories"
	label define lbleducat4 1 "No education" 2 "Primary (complete or incomplete)" ///
	3 "Secondary (complete or incomplete)" 4 "Tertiary (complete or incomplete)"
	label values educat4 lbleducat4
*</_educat4_>


** EVER ATTENDED SCHOOL
*<_everattend_>
	recode school (1/6=1)  (7 9 =.), gen(everattend)
	replace everattend=0 if  s_attend==2
	replace everattend=1 if atschool==1 | s_attend==3
	replace everattend=0 if educat4==1
	label var everattend "Ever attended school"
	la de lbleverattend 0 "No" 1 "Yes"
	label values everattend lbleverattend
*</_everattend_>


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
 gen byte lb_mod_age=10
	label var lb_mod_age "Labor module application age"
*</_lb_mod_age_>

** LABOR STATUS
*<_lstatus_>
	gen byte lstatus=cur_act
	recode lstatus (3 4 5 6 9=3) 
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
*</_lstatus_>

** LABOR STATUS LAST YEAR
*<_lstatus_year_>
	gen byte lstatus_year=.
	replace lstatus_year=. if age<lb_mod_age & age!=.
	label var lstatus_year "Labor status during last year"
	la de lbllstatus_year 1 "Employed" 2 "Unemployed" 3 "Non-in-labor force"
	label values lstatus_year lbllstatus_year
*</_lstatus_year_>


** EMPLOYMENT STATUS
*<_empstat_>
	gen byte empstat=emp_stat
	recode empstat (1 2 3=1) (6=2) (4=3) (5=4) (9=.)
	label var empstat "Employment status"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed"
	label values empstat lblempstat
	replace empstat=. if lstatus!=1
*</_empstat_>


** EMPLOYMENT STATUS LAST YEAR
*<_empstat_year_>
	gen byte empstat_year=.
	replace empstat_year=. if lstatus_year!=1
	label var empstat_year "Employment status during last year"
	la de lblempstat_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_year lblempstat_year
*</_empstat_year_>

** NUMBER OF ADDITIONAL JOBS 
*<_njobs_>
	label var njobs "Number of additional jobs"
*</_njobs_>

** NUMBER OF ADDITIONAL JOBS LAST YEAR
*<_njobs_year_>
	gen byte njobs_year=.
	replace njobs_year=. if lstatus_year!=1
	label var njobs_year "Number of additional jobs during last year"
*</_njobs_year_>


** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
*<_ocusec_>
	gen byte ocusec=emp_stat
	recode ocusec (2=1) (3/6=2) (9=.)
	label var ocusec "Sector of activity"
	la de lblocusec 1 "Public, state owned, government, army, NGO" 2 "Private"
	label values ocusec lblocusec
*</_ocusec_>
	replace ocusec=. if lstatus!=1

** REASONS NOT IN THE LABOR FORCE
*<_nlfreason_>
	gen byte nlfreason=.
	replace nlfreason=1 if cur_act==3
	replace nlfreason=2 if cur_act==4
	replace nlfreason=5 if cur_act==5 | cur_act==6 | cur_act==9
	replace nlfreason=. if lstatus!=3
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housewife" 3 "Retired" 4 "Disable" 5 "Other"
	label values nlfreason lblnlfreason
*</_nlfreason_>	replace nlfreason=. if lstatus!=3

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
	gen industry_orig=main_ind
	la val industry_orig lblindustry_orig
	replace industry_orig=. if lstatus!=1
	la var industry_orig "Original industry code"
*</_industry_orig_>


** INDUSTRY CLASSIFICATION
*<_industry_>
	tostring main_ind, gen (stringind)
	rename main_ind inddus
	gen byte industry=.
	gen induus=real(substr(stringind,1,2)) if  inddus>=700
	replace industry=1 if inddus<=700
	replace industry=2 if induus>=10 & induus<=14
	replace industry=3 if induus>=15 & induus<=37
	replace industry=4 if induus==40 | induus==41
	replace industry=5 if induus==45
	replace industry=6 if induus>=50 & induus<=55
	replace industry=7 if induus>=60 & induus<=64
	replace industry=8 if induus>=65 & induus<=74
	replace industry=9 if induus>=75& induus<=75
	replace industry=10 if induus>75 & induus<=99
	replace industry=10 if industry==. & induus!=.
	label var industry "1 digit industry classification"
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transports and comnunications" 8 "Financial and business-oriented services" 9 "Public Administration" 10 "Other services, unspecified"
	label values industry lblindustry
	replace industry=. if lstatus!=1
	notes industry: "LKA 2009" ISIC Rev.3 is used.
*</_industry_>

**ORIGINAL OCCUPATION CLASSIFICATION
*<_occup_orig_>
	gen occup_orig=main_occ
	la val occup_orig lbloccup_orig
	replace occup_orig=. if lstatus!=1
	la var occup_orig "Original occupation code"
*</_occup_orig_>



** OCCUPATION CLASSIFICATION
*<_occup_>
	gen byte occup=int(main_occ/1000)
	recode occup (0 =10)
	label var occup "1 digit occupational classification"
	la de lbloccup 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup lbloccup
	replace occup=. if lstatus!=1
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
	gen whours=.
	label var whours "Hours of work in last week"
*</_whours_>


** WAGES
*<_wage_>
	gen double wage=wage_1m // LAST MONTH
	replace wage=. if lstatus!=1
	replace wage=0 if empstat==2
	label var wage "Last wage payment"
*</_wage_>

** WAGES TIME UNIT
*<_unitwage_>
	gen byte unitwage=5 if wage!=.
	replace unitwage=. if wage==.
	label var unitwage "Last wages time unit"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Quarterly" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage lblunitwage
	replace unitwage=. if lstatus!=1
*</_wageunit_>

** EMPLOYMENT STATUS - SECOND JOB
*<_empstat_2_>
	gen byte empstat_2=.
	replace empstat_2=. if njobs==0 | njobs==.
	label var empstat_2 "Employment status - second job"
	la de lblempstat_2 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_2 lblempstat_2
*</_empstat_2_>

** EMPLOYMENT STATUS - SECOND JOB LAST YEAR
*<_empstat_2_year_>
	gen byte empstat_2_year=.
	replace empstat_2_year=. if njobs_year==0 | njobs_year==.
	label var empstat_2_year "Employment status - second job"
	la de lblempstat_2_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_2 lblempstat_2
*</_empstat_2_>

** INDUSTRY CLASSIFICATION - SECOND JOB
*<_industry_2_>
	gen byte industry_2=.
	replace industry_2=. if njobs==0 | njobs==.
	label var industry_2 "1 digit industry classification - second job"
	la de lblindustry_2 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industry_2 lblindustry
*<_industry_2_>


**SURVEY SPECIFIC INDUSTRY CLASSIFICATION - SECOND JOB
*<_industry_orig_2_>
	gen industry_orig_2=.
	replace industry_orig_2=. if njobs==0 | njobs==.
	label var industry_orig_2 "Original Industry Codes - Second job"
	la de lblindustry_orig_2 1""
	label values industry_orig_2 lblindustry_orig_2
*</_industry_orig_2>


** OCCUPATION CLASSIFICATION - SECOND JOB
*<_occup_2_>
	gen byte occup_2=.
	replace occup_2=. if njobs==0 | njobs==.
	label var occup_2 "1 digit occupational classification - second job"
	la de lbloccup_2 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup_2 lbloccup_2
*</_occup_2_>


** WAGES - SECOND JOB
*<_wage_2_>
	gen double wage_2=.
	replace wage_2=. if njobs==0 | njobs==.
	label var wage_2 "Last wage payment - Second job"
*</_wage_2_>


** WAGES TIME UNIT - SECOND JOB
*<_unitwage_2_>
	gen byte unitwage_2=.
	replace unitwage_2=. if njobs==0 | njobs==.
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

foreach var in union socialsec healthins contract unitwage wage whours firmsize_u firmsize_l occup industry unempldur_u unempldur_l nlfreason ocusec njobs empstat lstatus{
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
	la de lblrbirth_juris 1 "reg01" 2 "reg02" 3 "reg03" 4 "Other country"  9 "Other code"
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

	recode landphone (2=0)
	label var landphone "Household has a land phone"
	la de lbllandphone 0 "No" 1 "Yes"
	label val landphone lbllandphone
*</_landphone_>


** CEL PHONE
*<_cellphone_>
	rename mobile cellphone
	recode cellphone (2=0)
	label var cellphone "Household has a cell phone"
	la de lblcellphone 0 "No" 1 "Yes"
	label val cellphone lblcellphone
*</_cellphone_>


** COMPUTER
*<_computer_>
	ren comput computer
	recode computer (2=0)
	label var computer "Household has a computer"
	la de lblcomputer 0 "No" 1 "Yes"
	label val computer lblcomputer
*</_computer_>

** RADIO
*<_radio_>
	recode radio (2=0)	
	label var radio "household has a radio"
	la de lblradio 0 "No" 1 "Yes"
	label val radio lblradio
*</_radio_>

** TELEVISION
*<_television_>
	ren tv television
	recode television (2=0)
	label var television "Household has a television"
	la de lbltelevision 0 "No" 1 "Yes"
	label val television lbltelevision
*</_television>

** FAN
*<_fan_>
	recode fan (2=0)
	label var fan "Household has a fan"
	la de lblfan 0 "No" 1 "Yes"
	label val fan lblfan
*</_fan>

** SEWING MACHINE
*<_sewingmachine_>
	ren sewmach sewingmachine
	recode sewingmachine (2=0)
	label var sewingmachine "Household has a sewing machine"
	la de lblsewingmachine 0 "No" 1 "Yes"
	label val sewingmachine lblsewingmachine
*</_sewingmachine>

** WASHING MACHINE
*<_washingmachine_>
	ren washmach washingmachine
	recode washingmachine (2=0) 
	label var washingmachine "Household has a washing machine"
	la de lblwashingmachine 0 "No" 1 "Yes"
	label val washingmachine lblwashingmachine
*</_washingmachine>

** REFRIGERATOR
*<_refrigerator_>
	ren fridge refrigerator
	recode refrigerator (2=0)
	label var refrigerator "Household has a refrigerator"
	la de lblrefrigerator 0 "No" 1 "Yes"
	label val refrigerator lblrefrigerator
*</_refrigerator>

** LAMP
*<_lamp_>
	gen lamp=.
	label var lamp "Household has a lamp"
	la de lbllamp 0 "No" 1 "Yes"
	label val lamp lbllamp
*</_lamp>

** BYCICLE
*<_bycicle_>
	ren bicyc bicycle 
	recode bicycle  (2=0)
	label var bicycle "Household has a bicycle"
	la de lblbycicle 0 "No" 1 "Yes"
	label val bicycle lblbycicle
*</_bycicle>

** MOTORCYCLE
*<_motorcycle_>
	ren   m_bicyc motorcycle
	recode motorcycle (2=0)
	label var motorcycle "Household has a motorcycle"
	la de lblmotorcycle 0 "No" 1 "Yes"
	label val motorcycle lblmotorcycle
*</_motorcycle>

** MOTOR CAR
*<_motorcar_>
	ren  carvan motorcar
	recode motorcar (2=0)
	label var motorcar "household has a motor car"
	la de lblmotorcar 0 "No" 1 "Yes"
	label val motorcar lblmotorcar
*</_motorcar>

** COW
*<_cow_>
	gen cow=.
	label var cow "Household has a cow"
	la de lblcow 0 "No" 1 "Yes"
	label val cow lblcow
*</_cow>

** BUFFALO
*<_buffalo_>
	gen buffalo=.
	label var buffalo "Household has a buffalo"
	la de lblbuffalo 0 "No" 1 "Yes"
	label val buffalo lblbuffalo
*</_buffalo>

** CHICKEN
*<_chicken_>
	recode chicken (2=0)
	label var chicken "Household has a chicken"
	la de lblchicken 0 "No" 1 "Yes"
	label val chicken lblchicken
*</_chicken>


/*****************************************************************************************************
*                                                                                                    *
                                   WELFARE MODULE
*                                                                                                    *
*****************************************************************************************************/


** SPATIAL DEFLATOR
*<_spdef_>
	gen spdef=cpi_dcs
	la var spdef "Spatial deflator"
*</_spdef_>

** WELFARE
*<_welfare_>
	gen welfare=npccons
	la var welfare "Welfare aggregate"
*</_welfare_>

*<_welfarenom_>
	gen welfarenom=npccons
	la var welfarenom "Welfare aggregate in nominal terms"
*</_welfarenom_>

*<_welfaredef_>
	gen welfaredef=rpccons
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
	gen welfareother=.
	la var welfareother "Welfare Aggregate if different welfare type is used from welfare, welfarenom, welfaredef"
*</_welfareother_>

*<_welfareothertype_>
	gen welfareothertype=""
	la var welfareothertype "Type of welfare measure (income, consumption or expenditure) for welfareother"
*</_welfareothertype_>

*<_welfarenat_>
	gen welfarenat=rpccons
	la var welfarenat "Welfare aggregate for national poverty"
*</_welfarenat_>	

*QUINTILE, DECILE AND FOOD/NON-FOOD SHARES OF CONSUMPTION AGGREGATE
	levelsof year, loc(y)
	merge m:1 idh using "$shares\\LKA_fnf_`y'", keepusing (food_share nfood_share quintile_cons_aggregate decile_cons_aggregate) gen(_merge2)
	drop _merge


/*****************************************************************************************************
*                                                                                                    *
                                   NATIONAL POVERTY
*                                                                                                    *
*****************************************************************************************************/

	
** POVERTY LINE (NATIONAL)
*<_pline_nat_>
	gen pline_nat=3028
	label variable pline_nat "Poverty Line (National)"
*</_pline_nat_>


** HEADCOUNT RATIO (NATIONAL)
*<_poor_nat_>
	gen poor_nat=welfarenat<pline_nat if welfarenat!=.
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

	keep countrycode year survey idh idp wgt pop_wgt strata psu vermast veralt urban sector int_month int_year  gaul_adm1_code gaul_adm2_code ///
		subnatid1 subnatid2 subnatid3 gaul_adm1_code gaul_adm2_code ownhouse landholding tenure water_orig piped_water water_jmp sar_improved_water  electricity toilet_orig sewage_toilet toilet_jmp sar_improved_toilet  landphone cellphone ///
	     computer internet hsize relationharm relationcs male age soc marital ed_mod_age everattend ///
	     atschool electricity literacy educy educat4 educat5 educat7 lb_mod_age lstatus lstatus_year empstat empstat_year njobs njobs_year ///
	     ocusec nlfreason unempldur_l unempldur_u industry_orig industry occup_orig occup firmsize_l firmsize_u whours wage ///
		  unitwage empstat_2 empstat_2_year industry_2 industry_orig_2 occup_2 wage_2 unitwage_2 contract healthins socialsec union rbirth_juris rbirth rprevious_juris rprevious yrmove ///
		 landphone cellphone computer radio television fan sewingmachine washingmachine refrigerator lamp bicycle motorcycle motorcar cow buffalo chicken  ///
		 pline_nat pline_int poor_nat poor_int spdef cpi ppp cpiperiod welfare welfshprosperity welfarenom welfaredef welfarenat food_share nfood_share quintile_cons_aggregate decile_cons_aggregate welfareother welfaretype welfareothertype  
		 
** ORDER VARIABLES

	order countrycode year survey idh idp wgt pop_wgt strata psu vermast veralt urban sector int_month int_year  gaul_adm1_code gaul_adm2_code ///
		subnatid1 subnatid2 subnatid3 gaul_adm1_code gaul_adm2_code ownhouse landholding tenure water_orig piped_water water_jmp sar_improved_water electricity toilet_orig sewage_toilet toilet_jmp sar_improved_toilet  landphone cellphone ///
	     computer internet hsize relationharm relationcs male age soc marital ed_mod_age everattend ///
	     atschool electricity literacy educy educat4 educat5 educat7 lb_mod_age lstatus lstatus_year empstat empstat_year njobs njobs_year ///
	     ocusec nlfreason unempldur_l unempldur_u industry_orig industry occup_orig occup firmsize_l firmsize_u whours wage ///
		  unitwage empstat_2 empstat_2_year industry_2 industry_orig_2 occup_2 wage_2 unitwage_2 contract healthins socialsec union rbirth_juris rbirth rprevious_juris rprevious yrmove ///
		 landphone cellphone computer radio television fan sewingmachine washingmachine refrigerator lamp bicycle motorcycle motorcar cow buffalo chicken  ///
		 pline_nat pline_int poor_nat poor_int spdef cpi ppp cpiperiod welfare welfshprosperity welfarenom welfaredef welfarenat food_share nfood_share quintile_cons_aggregate decile_cons_aggregate welfareother welfaretype welfareothertype  
	
	compress

** DELETE MISSING VARIABLES

	local keep ""
	qui levelsof countrycode, local(cty)
	foreach var of varlist urban - welfareother {
	qui sum `var'
	scalar sclrc = r(mean)
	if sclrc==. {
	     display as txt "Variable " as result "`var'" as txt " for countrycode " as result `cty' as txt " contains all missing values -" as error " Variable Deleted"
	}
	else {
	     local keep `keep' `var'
	}
	}
	
	foreach w in welfare welfareother{
	qui su `w'
	if r(N)==0{
	drop `w'type
}
}
	keep countrycode year survey idh idp wgt pop_wgt strata psu vermast veralt subnatid1 subnatid2 `keep' *type
	compress

	saveold "`output'\Data\Harmonized\LKA_2009_HIES_v01_M_v03_A_SARMD-FULL_IND.dta", replace version(12)
	saveold "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\LKA_2009_HIES_v01_M_v03_A_SARMD-FULL_IND.dta", replace version(12)

	notes
	
	log close

*********************************************************************************************************************************	
******RENAME COMPARABLE VARIABLES AND SAVE THEM IN _SARMD. UNCOMPARABLE VARIALBES ACROSS TIME SHOULD BE FOUND IN _SARMD-FULL*****
*********************************************************************************************************************************

loc var  lb_mod_age lstatus lstatus_year empstat empstat_year njobs_year ocusec ///
nlfreason unempldur_l unempldur_u industry_orig industry induus occup_orig occup firmsize_l ///
 firmsize_u whours wage unitwage empstat_2 empstat_2_year industry_2 industry_orig_2 occup_2 wage_2 ///
 unitwage_2 contract healthins socialsec union piped_water water_jmp sar_improved_water sar_improved_toilet  

 
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

note _dta: "LKA 2009" Variables NAMED with "v2" are those not compatible with latest round (2012). ///
 These include the existing information from the particular survey, but the iformation should be used for comparability purposes  

 saveold "`output'\Data\Harmonized\LKA_2009_HIES_v01_M_v03_A_SARMD_IND.dta", replace version(12)
saveold "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\LKA_2009_HIES_v01_M_v03_A_SARMD_IND.dta", replace version(12)




******************************  END OF DO-FILE  *****************************************************/
