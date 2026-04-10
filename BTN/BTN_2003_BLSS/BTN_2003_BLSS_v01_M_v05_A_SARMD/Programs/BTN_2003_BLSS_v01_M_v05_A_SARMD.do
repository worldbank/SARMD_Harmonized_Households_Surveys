/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                       INTERNATIONAL INCOME DISTRIBUTION DATABASE (I2D2)                          **
**                                                                                                  **
** COUNTRY			BHUTAN
** COUNTRY ISO CODE	BTN
** YEAR				2003
** SURVEY NAME		BHUTAN LIVING STANDARD SURVEY (BLSS) 2003
** SURVEY AGENCY	NATIONAL STATISTICAL BUREAU
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
	set mem 500m

** DIRECTORY
	local input "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\BTN\BTN_2003_BLSS\BTN_2003_BLSS_v01_M"
	local output "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\BTN\BTN_2003_BLSS\BTN_2003_BLSS_v01_M_v05_A_SARMD"
	glo pricedata "D:\SOUTH ASIA MICRO DATABASE\CPI\cpi_ppp_sarmd_weighted.dta"
	do "D:\SOUTH ASIA MICRO DATABASE\APPS\DATA CHECK\Label fixing\fixlabels", nostop

** LOG FILE
	log using "`output'\Doc\Technical\BTN_2003_BLSS_v01_M_v04_A_SARMD.log",replace

/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/


** DATABASE ASSEMBLENT
	
	* PREPARE DATASETS
	
	use "`input'\Data\Stata\hroster_edited.dta" 
	order stratum dzongkha town block houseno idno
	sort  stratum dzongkha town block houseno idno
	tempfile roster
	save `roster'
	
	use "`input'\Data\Stata\block2_edited.dta" 
	order stratum dzongkha town block houseno idno
	sort  stratum dzongkha town block houseno idno
	tempfile individual
	save `individual'
	
	use "`input'\Data\Stata\block1_edited.dta" 
	order stratum dzongkha town block houseno
	sort  stratum dzongkha town block houseno
	tempfile housing
	save `housing'
	
	use "`input'\Data\Stata\block3_edited.dta" 
	order stratum dzongkha town block houseno
	sort  stratum dzongkha town block houseno
	tempfile assets
	save `assets'
	
	use "`input'\Data\Stata\block7_edited.dta" 
	order stratum dzongkha town block houseno
	sort  stratum dzongkha town block houseno
	tempfile income
	save `income'
	
	use "`input'\Data\Stata\paachse_index.dta" 
	order stratum dzongkha town block houseno
	sort  stratum dzongkha town block houseno
	tempfile weight
	save `weight'
	
	use "`input'\Data\Stata\consumption_total.dta" 
	order stratum dzongkha town block houseno
	sort  stratum dzongkha town block houseno
	tempfile consumption
	save `consumption'
	
	* MERGE DATASETS
	
	use `roster' 
	merge 1:1 stratum dzongkha town block houseno idno using `individual'
	drop _merge
	
	merge m:1 stratum dzongkha town block houseno using `housing'
	drop _merge
	
	merge m:1 stratum dzongkha town block houseno using `assets'
	drop _merge
	
	merge m:1 stratum dzongkha town block houseno using `income'
	drop _merge

	merge m:1 stratum dzongkha town block houseno using `weight'
	drop _merge

	merge m:1 stratum dzongkha town block houseno using `consumption'
	drop _merge


	* MERGE WITH OLD CONSUMPTION AGGREGATE (Can't find a new one)
	gen stratum_	= string(stratum,"%02.0f")
	gen dzongkha_	= string(dzongkha,"%02.0f")
	gen town_		= string(town,"%02.0f")
	gen block_		= string(block,"%02.0f")
	replace block_	="00" if block==.
	gen houseno_	= string(houseno,"%02.0f")

	egen houseid_str=concat(stratum_ dzongkha_ town_ block_ houseno_)
	destring houseid_str , generate(idh)
	format idh %10.0f
	tostring idh, replace
	label var idh "Household id"
*</_idh_>
	
	merge m:1 idh using "`input'\Data\Stata\pcc.dta" 
	drop _merge
	
	notes _dta: "BTN 2003" data for this round is not comparable on poverty information
/*****************************************************************************************************
*                                                                                                    *
                                   * STANDARD SURVEY MODULE
*                                                                                                    *
*****************************************************************************************************/


** COUNTRY
*<_countrycode_>
	gen str4 countrycode="BTN"
	label var countrycode "Country code"
*</_countrycode_>


** YEAR
*<_year_>
	gen int year=2003
	label var year "Year of survey"
*</_year_>

** SURVEY NAME 
*<_survey_>
	gen str survey="BLSS"
	label var survey "Survey Acronym"
*</_survey_>



** INTERVIEW YEAR
*<_int_year_>
	gen byte int_year=.
	label var int_year "Year of the interview"
*</_int_year_>
	
	
** INTERVIEW MONTH
*<_int_month_>
	gen byte int_month=.
	la de lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value int_month lblint_month
	label var int_month "Month of the interview"
*</_int_month_>

	
** HOUSEHOLD IDENTIFICATION NUMBER
*<_idh_>
	label var idh "Household id"
*</_idh_>


** INDIVIDUAL IDENTIFICATION NUMBER
*<_idp_>

	gen ind_str	= string(idno,"%02.0f")
	egen idp	= concat(idh ind_str)
	label var idp "Individual id"
*</_idp_>

	
** HOUSEHOLD WEIGHTS
*<_wgt_>
	gen wgt=weight
	label var wgt "Household sampling weight"
*</_wgt_>


** STRATA
*<_strata_>
	gen strata=stratum
	label var strata "Strata"
*</_strata_>


** PSU
*<_psu_>
	*egen psu=group(stratum_ dzongkha_ town_ block_ )
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
	gen urban=stratum
	recode urban (2=0)
	label var urban "Urban/Rural"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban
*</_urban_>


**REGIONAL AREAS

** REGIONAL AREA 1 DIGIT ADMN LEVEL
*<_subnatid0_>
	gen area01=dzongkha
	*recode area01 (11 12 13 14  41 = 1) (15 16 17 44 43 = 2) (31/36=3) (21 22 23 42 = 4), gen(subnatid1)
	recode area01 (11/16 41 = 1) (17 21/23  42/44 = 2) (31/36 = 3), gen(subnatid0)
	label var subnatid0 "Macro regional areas"
	la de lblsubnatid0 1 "Western" 2 "Central" 3 "Eastern"  4 "Southern"
	notes subnatid0: "BTN 2003" refer to technical doc for detail on classification. This survey is representative at this level of classification. Also, this subdivision remains intact to compare with other rounds (2007/2012)
	label values subnatid0 lblsubnatid0
	*</_subnatid0_>

** REGIONAL AREA 2 DIGIT ADMN LEVEL
*<_subnatid1_>
	gen subnatid1=dzongkha
	label var subnatid1 "Region at 1 digit (ADMN1)"
	la de lblsubnatid1 11 "Chukha" 12 "Ha" 13 "Paro" 14 "Thimphu" 15 "Punakha" 16 "Gasa" ///
	17 "Wangdi Phodrang" 21 "Bumthang" 22 "Trongsa" 23 "Zhemgang" 31 "Lhuntshi" 32 "Mongar" ///
	33 "Trashigang" 34 "Tashi Yangtse" 35 "Pemagatshel" 36 "Samdrup Jongkhar" 41 "Samtse" ///
	42 "Sarpang" 43 "Tsirang" 44 "Dagana"
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
		replace gaul_adm1_code=2124 if subnatid1=="23 - Zhemgang"
		replace gaul_adm1_code=2123 if subnatid1=="17 - Wangdi Phodrang"
		replace gaul_adm1_code=2122 if subnatid1=="43 - Tsirang"
		replace gaul_adm1_code=2121 if subnatid1=="22 - Trongsa"
		replace gaul_adm1_code=2120 if subnatid1=="34 - Tashi Yangtse"
		replace gaul_adm1_code=2119 if subnatid1=="33 - Trashigang"
		replace gaul_adm1_code=2118 if subnatid1=="14 - Thimphu"
		replace gaul_adm1_code=2117 if subnatid1=="42 - Sarpang"
		replace gaul_adm1_code=2116 if subnatid1=="41 - Samtse"
		replace gaul_adm1_code=2115 if subnatid1=="36 - Samdrup Jongkhar"
		replace gaul_adm1_code=2114 if subnatid1=="15 - Punakha"
		replace gaul_adm1_code=2113 if subnatid1=="35 - Pemagatshel"
		replace gaul_adm1_code=2112 if subnatid1=="13 - Paro"
		replace gaul_adm1_code=2111 if subnatid1=="32 - Mongar"
		replace gaul_adm1_code=2110 if subnatid1=="31 - Lhuntshi"
		replace gaul_adm1_code=2109 if subnatid1=="12 - Ha"
		replace gaul_adm1_code=2108 if subnatid1=="16 - Gasa"
		replace gaul_adm1_code=2107 if subnatid1=="44 - Dagana"
		replace gaul_adm1_code=2106 if subnatid1=="11 - Chukha"
		replace gaul_adm1_code=2105 if subnatid1=="21 - Bumthang"
	*<_gaul_adm1_code_>

** REGIONAL AREA 2 DIGIT ADMN LEVEL
*<_subnatid2_>
	gen byte subnatid2=.
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
	gen ownhouse=b1_q2
	label var ownhouse "House ownership"
	recode ownhouse (2=0)
	la de lblownhouse 0 "No" 1 "Yes"
	label values ownhouse lblownhouse
*</_ownhouse_>


** TENURE OF DWELLING
*<_tenure_>
   gen tenure=.
   replace tenure=1 if b1_q2==1
   replace tenure=2 if b1_q2==2 & (b1_q3==1 | b1_q3==2) 
   replace tenure=3 if b1_q3==3 & b1_q2!=1
   label var tenure "Tenure of Dwelling"
   la de lbltenure 1 "Owner" 2"Renter" 3"Other"
   la val tenure lbltenure
*</_tenure_>	


** LANDHOLDING
*<_lanholding_>
   gen landholding= b3_q3wet>0 | b3_q3dry>0 | b3_q3orc>0 if !mi(b3_q3wet,b3_q3dry,b3_q3orc)
   label var landholding "Household owns any land"
   la de lbllandholding 0 "No" 1 "Yes"
   la val landholding lbllandholding
   notes landholding: "BTN 2003" this variable was generated if  hh owned either wet, dry or or orchard land
*</_tenure_>	

*ORIGINAL WATER CATEGORIES
*<_water_orig_>
gen water_orig=b1_q12
la var water_orig "Source of Drinking Water-Original from raw file"
#delimit
la def lblwater_orig 1 "Pipe in dwelling / compound"
					 2 "Neighbour's pipe"
					 3 "Public outdoor tap"
					 4 "Protected well"
					 5 "Unprotected well"
					 6 "Spring"
					 7 "River,Lake, Pind"
					 8 "Other";
#delimit cr
la val water_orig lblwater_orig
*</_water_orig_>

*PIPED SOURCE OF WATER
*<_piped_water_>
gen piped_water=.
replace piped_water=b1_q12==1 if b1_q12!=.
la var piped_water "Household has access to piped water"
la def lblpiped_water 1 "Yes" 0 "No"
la val piped_water lblpiped_water
*</_piped_water_>


**INTERNATIONAL WATER COMPARISON (Joint Monitoring Program)
*<_water_jmp_>
gen water_jmp=.
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
note water_jmp: "BTN 2003" Due to multiple ambiguities in the options of raw data, JMP categories could not be identified, mainly those coming from piped water.
*</_water_jmp_>


*SAR improved source of drinking water
*<_sar_improved_water_>
gen sar_improved_water=.
replace sar_improved_water=1 if inlist(b1_q12,1,2,3,4)
replace sar_improved_water=0 if inlist(b1_q12,5,6,7,8) 
la def lblsar_improved_water 1 "Improved" 0 "Unimproved"
la var sar_improved_water "Improved source of drinking water-using country-specific definitions"
la val sar_improved_water lblsar_improved_water
note sar_improved_water: "BTN 2003" Due to not knowing whether category 'sptring' was protected or unprotected, it was taken as unimproved source of water based on judgement call
*</_sar_improved_water_>


*ORIGINAL WATER CATEGORIES
*<_water_original_>
clonevar j=b1_q12
#delimit
la def lblwater_original 1 "Pipe in dwelling / compound"
						 2 "Neighbour's pipe"
						 3 "Public outdoor tap"
						 4 "Protected well"
						 5 "Unprotected well"
						 6 "Spring"
						 7 "River,Lake, Pind"
						 8 "Other";
#delimit cr
la val j lblwater_original		
decode j, gen(water_original)
drop j
la var water_original "Source of Drinking Water-Original from raw file"
*</_water_original_>

				   
	** WATER SOURCE
	*<_water_source_>
		gen water_source=.
		replace water_source=1 if b1_q12==1
		replace water_source=2 if b1_q12==2
		replace water_source=3 if b1_q12==3
		replace water_source=5 if b1_q12==4
		replace water_source=10 if b1_q12==5
		replace water_source=13 if b1_q12==7
		replace water_source=14 if b1_q12==8
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
		gen pipedwater_acc=0 if inrange(b1_q12,2,8) // Asuming other is not piped water
		replace pipedwater_acc=3 if inlist(b1_q12,1)
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
	gen electricity=b1_q18==2 if b1_q18!=.
	label var electricity "Electricity main source"
	la de lblelectricity 0 "No" 1 "Yes"
	label values electricity lblelectricity
*</_electricity_>

*ORIGINAL TOILET CATEGORIES
*<_toilet_orig_>
gen toilet_orig=b1_q16
la var toilet_orig "Access to sanitation facility-Original from raw file"
#delimit
la def lbltoilet_orig 1 "Flush toilet"
					  2 "Pit latrine + septic tank"
					  3 "Pit latrine, no septic tank"
					  4 "None (nature)"
					  5 "Other (specify)";
#delimit cr
la val toilet_orig lbltoilet_orig
*</_toilet_orig_>

*SEWAGE TOILET
*<_sewage_toilet_>
gen sewage_toilet=.
replace sewage_toilet=b1_q16==1 if b1_q16!=.
la var sewage_toilet "Household has access to sewage toilet"
la def lblsewage_toilet 1 "Yes" 0 "No"
la val sewage_toilet lblsewage_toilet
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

*SAR improved type of toilet
*<_sar_improved_toilet_>
gen sar_improved_toilet=.
replace sar_improved_toilet=1 if inlist(b1_q16,1,2)
replace sar_improved_toilet=0 if inlist(b1_q16,3,4,5)
replace sar_improved_toilet=0 if b1_q17==1
la def lblsar_improved_toilet 1 "Improved" 0 "Unimproved"
la var sar_improved_toilet "Improved type of sanitation facility-using country-specific definitions"
la val sar_improved_toilet lblsar_improved_toilet
*</_sar_improved_toilet_>


** ORIGINAL SANITATION CATEGORIES 
	*<_sanitation_original_>
		clonevar j=b1_q16
		#delimit
		la def lblsanitation_original   1 "Flush toilet"
										2 "Pit latrine + septic tank"
										3 "Pit latrine, no septic tank"
										4 "None (nature)"
										5 "Other (specify)";
		#delimit cr
		la val j lblsanitation_original
		decode j, gen(sanitation_original)
		drop j
		la var sanitation_original "Access to sanitation facility-Original from raw file"
	*</_sanitation_original_>


	** SANITATION SOURCE
	*<_sanitation_source_>
		gen sanitation_source=.
		replace sanitation_source=2 if b1_q16==1
		replace sanitation_source=3 if b1_q16==2
		replace sanitation_source=4 if b1_q16==3
		replace sanitation_source=13 if b1_q16==4
		replace sanitation_source=14 if b1_q16==5
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
		replace improved_sanitation=1 if inlist(sanitation_source,1,2,3,4,5,6,7,8)
		replace improved_sanitation=0 if inlist(sanitation_source,9,10,11,12,13,14)
		la def lblimproved_sanitation 1 "Improved" 0 "Unimproved"
		la val improved_sanitation lblimproved_sanitation
		la var improved_sanitation "Improved type of sanitation facility-using country-specific definitions"
	*</_improved_sanitation_>
	

	** ACCESS TO FLUSH TOILET
	*<_toilet_acc_>
		gen toilet_acc=3 if b1_q16==1
		replace toilet_acc=0 if b1_q16!=1 & b1_q16!=.
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
*<_internet_>
	gen internet=.
	label var internet "Internet connection"
	la de lblinternet 0 "No" 1 "Yes"
	label values internet lblinternet
*</_internet_>


/*****************************************************************************************************
*                                                                                                    *
                                   DEMOGRAPHIC MODULE
*                                                                                                    *
*****************************************************************************************************/

** HOUSEHOLD SIZE
*<_hsize_>
	ren hh_size hsize
	label var hsize "Household size"
*</_hsize_>

**POPULATION WEIGHT
*<_pop_wgt_>
	gen pop_wgt=wgt*hsize
	la var pop_wgt "Population weight"
*</_pop_wgt_>


** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
*<_relationharm_>
	gen relationharm=b21_q2
	recode relationharm (5/11=5) (12/13=6) 
	label var relationharm "Relationship to the head of household"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Non-relatives"
	label values relationharm  lblrelationharm
*</_relationharm_>

** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
*<_relationcs_>

	gen byte relationcs=b21_q2
	la var relationcs "Relationship to the head of household country/region specific"
	label define lblrelationcs 1 "Self(head)" 2 "Wife/Husband" 3 "Son/daughter" 4 "Father/Mother" 5 "Sister/Brother" 6 "Grandchild" 7 "Niece/nephew" 8 "Son-in-law/daughter-in-law" 9 "Brother-in-law/sister-in-law" 10 "Father-in-law/mother-in-law" 11 "Other family relative" 12 "Live-in-servant" 13 "Other-non-relative"
	label values relationcs lblrelationcs
*</_relationcs_>

** GENDER
*<_male_>
	gen male=b21_q1
	recode male (2=0)
	label var male "Sex of household member"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale
*</_male_>

** AGE
*<_age_>
	*gen age=b21_q3ag
	label var age "Age of individual"
	replace age=98 if age>=98 & age!=.
*</_age_>


** SOCIAL GROUP
*<_soc_>
	gen soc=b21_q5
	label var soc "Social group"
	la de lblsoc 1 "Bhutanese" 2 "Other"
	label values soc lblsoc
	notes soc: "BTN 2003" this variable has "nationality"
*</_soc_>

** MARITAL STATUS
*<_marital_>
	gen marital=b21_q4
	recode marital (3 4=4) (2=2) (5=5)
	label var marital "Marital status"
	la de lblmarital 1 "Married" 2 "Never Married" 3 "Living Together" 4 "Divorced/separated" 5 "Widowed"
	label values marital lblmarital
	notes marital: "BTN 2003" for futher rounds "living together" is available. Take into account for comparability purposes
*</_marital_>


/*****************************************************************************************************
*                                                                                                    *
                                   EDUCATION MODULE
*                                                                                                    *
*****************************************************************************************************/


** EDUCATION MODULE AGE
*<_ed_mod_age_>
	gen ed_mod_age=3
	label var ed_mod_age "Education module application age"
*</_ed_mod_age_>


** EVER ATTENDED SCHOOL
*<_everattend_>
	gen everattend=b22_q8
	recode everattend (2=0)
	label var everattend "Ever attended school"
	la de lbleverattend 0 "No" 1 "Yes"
	label values everattend lbleverattend
	notes everattend: "BTN 2003" this variable includes people with no education and/or pre-primary education
*</_everattend_>


** CURRENTLY AT SCHOOL
*<_atschool_>
	gen atschool=b22_q9
	recode atschool (2=0)
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool
	notes atschool: "BTN 2003" this variable includes people with no education and/or pre-primary education
	notes atschool: "BTN 2003" note that this variable may not be comparable with other rounds. The structure of the relevant question has changed with respect to further rounds
*</_atschool_>


** CAN READ AND WRITE
*<_literacy_>
	gen literacy=.
	replace literacy=0 if b22_q7dz==2 & b22_q7en==2 & b22_q7ot==2 & b22_q7lo==2
	replace literacy=1 if b22_q7dz==1 | b22_q7en==1 | b22_q7ot==1 | b22_q7lo==1
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
*</_literacy_>


** YEARS OF EDUCATION COMPLETED
*<_educy_>
	gen educy1=.
	replace educy1=0 if  b22_q10==00 |  b22_q10==01 | b22_q16==00
	replace educy1=1 if  b22_q10==02  | b22_q16==01
	replace educy1=2 if  b22_q10==03 | b22_q16==02
	replace educy1=3 if  b22_q10==04 | b22_q16==03
	replace educy1=4 if  b22_q10==05 | b22_q16==04
	replace educy1=5 if  b22_q10==06 | b22_q16==05
	replace educy1=6 if  b22_q10==07 | b22_q16==06
	replace educy1=7 if  b22_q10==08 | b22_q16==07
	replace educy1=8 if  b22_q10==09 | b22_q16==08
	replace educy1=9 if  b22_q10==10 | b22_q16==09
	replace educy1=10 if  b22_q10==11 | b22_q16==010
	replace educy1=11 if  b22_q10==12 | b22_q16==011
	replace educy1=12 if  inrange(b22_q10,13,15) | inrange(b22_q16,12,15)
	replace educy1=14 if  b22_q17==2 & inrange(b22_q16,12,15)
	replace educy1=16 if  b22_q17==1 & inrange(b22_q16,12,15)
	replace educy1 = 0 if b22_q8==2 
	replace educy=. if age<ed_mod_age 
	replace educy=. if educy>age+1 & educy<. & age!=.
	ren educy1 educy
	label var educy "Years of education"
*</_educy_>

** EDUCATION LEVEL 7 CATEGORIES
*<_educat7_>
	gen byte educat7=.
	replace educat7=1 if educy==0
	replace educat7=2 if educy>0 & educy<9
	replace educat7=3 if educy==9
	replace educat7=4 if educy>9 & educy<12
	replace educat7=5 if educy>=12 & educy<=15
	replace educat7=6 if educy==14
	replace educat7=7 if educy==16
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
	label define lbleducat5 1 "No education" 2 "Primary incomplete" ///
	3 "Primary complete but secondary incomplete" 4 "Secondary complete" ///
	5 "Some tertiary/post-secondary"
	label values educat5 lbleducat5
*</_educat5_>

	la var educat5 "Level of education 5 categories"

	
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

	foreach var in educy atschool literacy everattend educat4 educat5 educat7{
replace `var'=. if age<ed_mod_age
}

/*****************************************************************************************************
*                                                                                                    *
                                   LABOR MODULE
*                                                                                                    *
*****************************************************************************************************/
** LABOR MODULE AGE
*<_lb_mod_age_>

	gen lb_mod_age=15
	label var lb_mod_age "Labor module application age"
	notes lb_mod_age: "BTN 2003" the minimum age for this round (10 years or older) is different to the others (15 years). Take into account for comparability purposes
*</_lb_mod_age_>


** LABOR STATUS
*<_lstatus_>
	gen lstatus = .  
	replace lstatus = 1 if inlist(1,  b24_q33w, b24_q34w, b24_q35w)
	replace lstatus = 2 if  b24_q36==1 & mi(lstatus)
	replace lstatus = 3 if b24_q37!=. & lstatus!=1
	label var lstatus "Labor status"
	label define lbllstatus 1"Employed" 2"Unemployed" 3"Not-in-labor-force"
	label values lstatus lbllstatus
*</_lstatus_>

** LABOR STATUS LAST YEAR
*<_lstatus_year_>
	gen byte lstatus_year= 1 if inlist(1,  b24_q33y, b24_q34y, b24_q35y)
	replace lstatus_year=0 if b24_q33y==2 & b24_q34y==2 & b24_q35y==2
	replace lstatus_year=. if age<lb_mod_age & age!=.
	label var lstatus_year "Labor status during last year"
	la de lbllstatus_year 1 "Employed" 0 "Not employed" 
	label values lstatus_year lbllstatus_year
	*</_lstatus_year_>

	
** EMPLOYMENT STATUS
*<_empstat_>
	gen empstat=b24_q38
	recode empstat 2 6=1 5=2 3=4 7=5 4=3
	label var empstat "Employment status"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other"
	replace empstat =. if lstatus!=1
	label values empstat lblempstat
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
	gen njobs=b24_q42
	recode njobs 2=0
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
	gen ocusec=b24_q41
	recode ocusec (1 2 =1) ( 3/8 10 =3)  (9 11=.)
	recode ocusec (3=2)
	label var ocusec "Sector of activity"
	la de lblocusec 1 "Public, state owned, government, army, NGO" 2 "Private"
	label values ocusec lblocusec
	notes ocusec: "BTN 2003" category "foreign company/organ" is captured as missing
*</_ocusec_>
	replace ocusec=. if lstatus!=1 | age<15


** REASONS NOT IN THE LABOR FORCE
*<_nlfreason_>
	gen nlfreason=b24_q37
	recode nlfreason (5=1) (6=2) (7 8=3) (9=4) (1/4  10/11=5)
	 replace nlfreason=. if lstatus!=3
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housewife" 3 "Retired" 4 "Disable" 5 "Other"
	label values nlfreason lblnlfreason
*</_nlfreason_>

** UNEMPLOYMENT DURATION: MONTHS LOOKING FOR A JOB
*<_unempldur_l_>
	gen unempldur_l=.
	label var unempldur_l "Unemployment duration (months) lower bracket"
*</_unempldur_l_>

*<_unempldur_u_>

	gen unempldur_u=.
	label var unempldur_u "Unemployment duration (months) upper bracket"
*</_unempldur_u_>



**ORIGINAL INDUSTRY CLASSIFICATION
*<_industry_orig_>
	gen industry_orig=b24_q40
	label define lblbindustry_orig 1 `"Agriculture"', modify
	label define lblbindustry_orig 2 `"Mining"', modify
	label define lblbindustry_orig 3 `"Manufacturing"', modify
	label define lblbindustry_orig 4 `"Electricity/gas/water"', modify
	label define lblbindustry_orig 5 `"Construction"', modify
	label define lblbindustry_orig 6 `"Retail trade"', modify
	label define lblbindustry_orig 7 `"Hotels/restaurants"', modify
	label define lblbindustry_orig 8 `"Transport"', modify
	label define lblbindustry_orig 9 `"Finance/real estate"', modify
	label define lblbindustry_orig 10 `"Insurance"', modify
	label define lblbindustry_orig 11 `"Public administration/defence"', modify
	label define lblbindustry_orig 12 `"Education"', modify
	label define lblbindustry_orig 13 `"Health/social work"', modify
	label define lblbindustry_orig 14 `"Other"', modify
	la val industry_orig lblbindustry_orig
	replace industry_orig=. if lstatus!=1
	la var industry_orig "Original industry code"
*</_industry_orig_>


** INDUSTRY CLASSIFICATION
*<_industry_>
	gen industry=b24_q40
	recode industry (7=6) (8=7) (9 10=8) (11=9) (12/14=10)
	replace  industry =. if age<15 
	label var industry "1 digit industry classification"
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industry lblindustry
*</_industry_>

**ORIGINAL OCCUPATION CLASSIFICATION
*<_occup_orig_>
	gen occup_orig=b24_q39
	label define lblboccup_orig 11 `"Armed forces"', modify
	label define lblboccup_orig 111 `"Legislators"', modify
	label define lblboccup_orig 112 `"Senior government officials"', modify
	label define lblboccup_orig 113 `"Traditional chiefs and heads of villages"', modify
	label define lblboccup_orig 114 `"Senior officials of special interest organization"', modify
	label define lblboccup_orig 121 `"Directors and chief executives"', modify
	label define lblboccup_orig 122 `"Productions and operations department managers"', modify
	label define lblboccup_orig 123 `"Other department managers"', modify
	label define lblboccup_orig 131 `"General managers"', modify
	label define lblboccup_orig 211 `"Physicists/chemists and related professionals"', modify
	label define lblboccup_orig 212 `"Mathematicians/Statisticians and related professionals"', modify
	label define lblboccup_orig 213 `"Computing professionals"', modify
	label define lblboccup_orig 214 `"Architects/engineers and related professionals"', modify
	label define lblboccup_orig 221 `"Life science professionals"', modify
	label define lblboccup_orig 222 `"Health professionals"', modify
	label define lblboccup_orig 223 `"Nursing and midwifery professionals"', modify
	label define lblboccup_orig 231 `"College university and higher education teaching ptofessiona"', modify
	label define lblboccup_orig 232 `"Secondary education teaching professionals"', modify
	label define lblboccup_orig 233 `"Special edication teaching professionals"', modify
	label define lblboccup_orig 234 `"Other teaching professionals"', modify
	label define lblboccup_orig 241 `"Business professionals"', modify
	label define lblboccup_orig 242 `"Legal professionals"', modify
	label define lblboccup_orig 243 `"Archivists Librarians and related information professionals"', modify
	label define lblboccup_orig 244 `"Social science and related professionals"', modify
	label define lblboccup_orig 245 `"Writers and creative or performing artists"', modify
	label define lblboccup_orig 246 `"Religious professionals"', modify
	label define lblboccup_orig 311 `"Physical and engineering science technicians"', modify
	label define lblboccup_orig 312 `"Computer Associate Professionals"', modify
	label define lblboccup_orig 313 `"Optical and Electronic equipment operator"', modify
	label define lblboccup_orig 314 `"Ship amd aircraft controllers and technicicans"', modify
	label define lblboccup_orig 315 `"Safety and quality inspectors"', modify
	label define lblboccup_orig 321 `"Life science technicians and related associate professionals"', modify
	label define lblboccup_orig 322 `"Modern health associate professionals"', modify
	label define lblboccup_orig 323 `"Nursing and midwifery associate"', modify
	label define lblboccup_orig 324 `"Traditional medicine practioners and faith healers"', modify
	label define lblboccup_orig 331 `"Primary education teaching associate professionals"', modify
	label define lblboccup_orig 332 `"Pre-primary education teaching associate professionals"', modify
	label define lblboccup_orig 333 `"Special education teaching associate professionals"', modify
	label define lblboccup_orig 334 `"Other teaching associate professionals"', modify
	label define lblboccup_orig 341 `"Finance teaching associate professionals"', modify
	label define lblboccup_orig 342 `"Business services agents and trade brokers"', modify
	label define lblboccup_orig 343 `"Administrative associate professionals"', modify
	label define lblboccup_orig 344 `"Customs/tax and related government associate professionals"', modify
	label define lblboccup_orig 345 `"Police inspectors and dectatives"', modify
	label define lblboccup_orig 346 `"Social work associate professionals"', modify
	label define lblboccup_orig 347 `"Artist/entertainment and sports associate professionals"', modify
	label define lblboccup_orig 411 `"Secretaried and keyboard operating clerks"', modify
	label define lblboccup_orig 412 `"Numeracal clerks"', modify
	label define lblboccup_orig 413 `"Material recording and transport clerks"', modify
	label define lblboccup_orig 414 `"Library/mail and related clerks"', modify
	label define lblboccup_orig 415 `"Other offices clerks"', modify
	label define lblboccup_orig 421 `"Cashiers/tellers and related clerks"', modify
	label define lblboccup_orig 422 `"Client information clerks"', modify
	label define lblboccup_orig 511 `"Travel attendants and related workers"', modify
	label define lblboccup_orig 512 `"Housekeeping and restaurant services workers"', modify
	label define lblboccup_orig 513 `"Personal care and related workers"', modify
	label define lblboccup_orig 514 `"Astrologers/fortune-tellers and related workers"', modify
	label define lblboccup_orig 515 `"Protective service workers"', modify
	label define lblboccup_orig 521 `"Fasion and other models"', modify
	label define lblboccup_orig 522 `"Shop salepersons and demostrators"', modify
	label define lblboccup_orig 523 `"Stall and market salespersons"', modify
	label define lblboccup_orig 611 `"Market gardeners and crop growers"', modify
	label define lblboccup_orig 612 `"Market-oriented animal producers and related workers"', modify
	label define lblboccup_orig 613 `"Market-oriented crop and animal producers"', modify
	label define lblboccup_orig 614 `"Forestry and related workers"', modify
	label define lblboccup_orig 615 `"Fishery workers/hunters and trappers"', modify
	label define lblboccup_orig 621 `"Subsistence agricultural and fishery workers"', modify
	label define lblboccup_orig 711 `"Miners/shotfirers/stone cutters and ceavers"', modify
	label define lblboccup_orig 712 `"Building frame and related trade workers"', modify
	label define lblboccup_orig 713 `"Building finishing and related trade workers'"', modify
	label define lblboccup_orig 714 `"Painters/building structure cleaners and related trade worke"', modify
	label define lblboccup_orig 721 `"Metal moulders/ welders/sheet metal workers/structural metal"', modify
	label define lblboccup_orig 722 `"Blacksmiths/toolmakers and related trade workers"', modify
	label define lblboccup_orig 723 `"Machinery mechanics and fitters"', modify
	label define lblboccup_orig 724 `"Electrical and electronic equipment mechanics and fitters"', modify
	label define lblboccup_orig 731 `"Precision workers in metal and related materials"', modify
	label define lblboccup_orig 732 `"Potters/glass-makers and related trade workers"', modify
	label define lblboccup_orig 733 `"Handifraft workers in wood/textile/leather and related mater"', modify
	label define lblboccup_orig 734 `"Printing and related trade workers"', modify
	label define lblboccup_orig 741 `"Food processing and related trade workers"', modify
	label define lblboccup_orig 742 `"Wood traders/cabinet-makers and related trade workers"', modify
	label define lblboccup_orig 743 `"Textile/garment and related trade workers"', modify
	label define lblboccup_orig 744 `"Pelt. leather and shoemaking trade workers"', modify
	label define lblboccup_orig 811 `"Minining and mineral-processing plant operators"', modify
	label define lblboccup_orig 812 `"Metal-processing plant operators"', modify
	label define lblboccup_orig 813 `"Glass/ceramics and related plant operators"', modify
	label define lblboccup_orig 814 `"Wood-processing and papermaking plant operators"', modify
	label define lblboccup_orig 815 `"Chemical-processing plant operators"', modify
	label define lblboccup_orig 816 `"Power-production and related plant operators"', modify
	label define lblboccup_orig 817 `"Automated assembly lune and industrail robot operators"', modify
	label define lblboccup_orig 821 `"Metal and mineral products machine operators"', modify
	label define lblboccup_orig 822 `"Chemical products machine operators"', modify
	label define lblboccup_orig 823 `"Rubber and plastic products machine operators"', modify
	label define lblboccup_orig 824 `"Wood products machine operators"', modify
	label define lblboccup_orig 825 `"Printing/ binding and paper products machine operators"', modify
	label define lblboccup_orig 826 `"Textile/ fur and leather products machine operator"', modify
	label define lblboccup_orig 827 `"Food and related products machine operators"', modify
	label define lblboccup_orig 828 `"Assemblers"', modify
	label define lblboccup_orig 829 `"Other machine operators and assemblers/chain operators"', modify
	label define lblboccup_orig 831 `"Locomotive engine drivers and related workers"', modify
	label define lblboccup_orig 832 `"Motor vehicle drivers"', modify
	label define lblboccup_orig 833 `"Agricultural and other mobile plant operators"', modify
	label define lblboccup_orig 834 `"Ships deck crews and related workers"', modify
	label define lblboccup_orig 911 `"Street vendors and related workers"', modify
	label define lblboccup_orig 912 `"Shoe cleaning and other street services elementary occupatio"', modify
	label define lblboccup_orig 913 `"Domestic and related helpers/cleaners launderers"', modify
	label define lblboccup_orig 914 `"Building caretakers, window and related cleaners"', modify
	label define lblboccup_orig 915 `"Messengers/porters/doorkeepers and related cleaners"', modify
	label define lblboccup_orig 916 `"Garbage collectors and related labourers"', modify
	label define lblboccup_orig 921 `"Agricultural/fishery and related labourers"', modify
	label define lblboccup_orig 931 `"Mining and construction labourers"', modify
	label define lblboccup_orig 932 `"Manufacturing labourers"', modify
	label define lblboccup_orig 933 `"Transport labourers and freight handlers"', modify
	label define lblboccup_orig 999 `"Others"', modify
	la val occup_orig lblboccup_orig
	replace occup_orig=. if lstatus!=1
	la var occup_orig "Original occupation code"
*</_occup_orig_>


** OCCUPATION CLASSIFICATION
*<_occup_>
	gen occup=int(b24_q39/100)
	recode occup (0=10)
	recode occup(9=99) if b24_q39==999
	label var occup "1 digit occupational classification"
	la de occup 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup occup
	replace occup=. if lstatus!=1 
	notes occup: "BTN 2003" ISCO88 is implemented
*</_occup_>


** FIRM SIZE
*<_firmsize_l_>
	gen firmsize_l=.
	label var firmsize_l "Firm size (lower bracket)"
*</_firmsize_l_>

*<_firmsize_u_>

	gen firmsize_u=.
	label var firmsize_u "Firm size (upper bracket)"

*</_firmsize_u_>


** HOURS WORKED LAST WEEK
*<_whours_>
	gen whours=b24_q47m
	*histogram whours if whours<100
	replace whours=. if whours>98
	label var whours "Hours of work in last week"
	replace whours=. if lstatus!=1 
	note whours: "BTN 2003" infeasible weekly working hours reported (>98) - to be recoded to missing
*</_whours_>

** WAGES
*<_wage_>
	gen wage=.
	label var wage "Last wage payment"
*</_wage_>


** WAGES TIME UNIT
*<_unitwage_>
	gen unitwage=.
	label var unitwage "Last wages time unit"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly"
	label values unitwage lblunitwage
*</_wageunit_>


** EMPLOYMENT STATUS - SECOND JOB
*<_empstat_2_>
	gen empstat_2=b24_q43
	recode empstat_2 2 6=1 5=2 3=4 7=5 4=3
	replace empstat_2=. if njobs==0 | njobs==. | lstatus!=1
	label var empstat_2 "Employment status - second job"
	la de lblempstat_2 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_2 lblempstat_2
*</_empstat_2_>

** EMPLOYMENT STATUS - SECOND JOB LAST YEAR
*<_empstat_2_year_>
	gen byte empstat_2_year=.
	replace empstat_2_year=. if njobs_year==0 | njobs_year==. | lstatus_year!=1
	label var empstat_2_year "Employment status - second job"
	la de lblempstat_2_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_2 lblempstat_2
*</_empstat_2_>

** INDUSTRY CLASSIFICATION - SECOND JOB
*<_industry_2_>
	gen byte industry_2=b24_q45
	recode industry_2 (7=6) (8=7) (9 10=8) (11=9) (12/14=10)
	replace industry_2=. if njobs==0 | njobs==. | lstatus!=1
	label var industry_2 "1 digit industry classification - second job"
	la de lblindustry_2 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industry_2 lblindustry
*<_industry_2_>


**SURVEY SPECIFIC INDUSTRY CLASSIFICATION - SECOND JOB
*<_industry_orig_2_>
	gen industry_orig_2=b24_q45
	replace industry_orig_2=. if njobs==0 | njobs==. | lstatus!=1
	label var industry_orig_2 "Original Industry Codes - Second job"
	la de lblindustry_orig_2 1""
	label values industry_orig_2 lblbindustry_orig
*</_industry_orig_2>


** OCCUPATION CLASSIFICATION - SECOND JOB
*<_occup_2_>
	gen occup_2=int(b24_q44/100)
	recode occup_2 (0=10)
	recode occup_2 (9=99) if b24_q39==999
	replace occup_2=. if njobs==0 | njobs==. | lstatus!=1
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
	gen contract=.
	label var contract "Contract"
	la de lblcontract 0 "Without contract" 1 "With contract"
	label values contract lblcontract
*</_contract_>


** HEALTH INSURANCE
*<_healthins_>
	gen healthins=.
	label var healthins "Health insurance"
	la de lblhealthins 0 "Without health insurance" 1 "With health insurance"
	label values healthins lblhealthins
*</_healthins_>


** SOCIAL SECURITY
*<_socialsec_>
	gen socialsec=.
	label var socialsec "Social security"
	la de lblsocialsec 1 "With" 0 "Without"
	label values socialsec lblsocialsec
*</_socialsec_>


** UNION MEMBERSHIP
*<_union_>
	gen union=.
	label var union "Union membership"
	la de lblunion 0 "No member" 1 "Member"
	label values union lblunion
*</_union_>

foreach var in lstatus lstatus_year empstat empstat_year njobs njobs_year ocusec nlfreason unempldur_l unempldur_u industry_orig industry occup_orig occup firmsize_l firmsize_u whours wage unitwage empstat_2 empstat_2_year industry_2 industry_orig_2 occup_2 wage_2 unitwage_2 contract healthins socialsec union {
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

	gen landphone=b1_q11==1 if b1_q11!=.
	label var landphone "Household has landphone"
	la de lbllandphone 0 "No" 1 "Yes"
	label values landphone lbllandphone
*</_landphone_>


** CEL PHONE
*<_cellphone_>
	gen cellphone=b3_q1mob ==1|b3_q1mob ==2 if !mi(b3_q1mob)
	label var cellphone "Household has Cell phone"
	la de lblcellphone 0 "No" 1 "Yes"
	label values cellphone lblcellphone
*</_cellphone_>


** COMPUTER
*<_computer_>
	gen computer=b3_q1com ==1| b3_q1com ==2 if !mi(b3_q1com)
	replace computer=0 if b3_q1com==3
	label var computer "Household has computer"
	la de lblcomputer 0 "No" 1 "Yes"
	label values computer lblcomputer
*</_computer_>

** RADIO
*<_radio_>
	gen radio= b3_q1rad==1 | b3_q1rad==2 if !mi(b3_q1rad )
	label var radio "Household has radio"
	la de lblradio 0 "No" 1 "Yes"
	label val radio lblradio
*</_radio_>

** TELEVISION
*<_television_>
	gen television= b3_q1tv==1 | b3_q1tv==2 if !mi(b3_q1tv)
	label var television "Household has Television"
	la de lbltelevision 0 "No" 1 "Yes"
	label val television lbltelevision
*</_television>

** FAN
*<_fan_>
	gen fan= b3_q1fan==1 | b3_q1fan==2 if !mi(b3_q1fan)
	label var fan "Household has Fan"
	la de lblfan 0 "No" 1 "Yes"
	label val fan lblfan
*</_fan>

** SEWING MACHINE
*<_sewingmachine_>
	gen sewingmachine=b3_q1sma==1 | b3_q1sma==2 if !mi(b3_q1sma)
	label var sewingmachine "Household has Sewing machine"
	la de lblsewingmachine 0 "No" 1 "Yes"
	label val sewingmachine lblsewingmachine
*</_sewingmachine>

** WASHING MACHINE
*<_washingmachine_>
	gen washingmachine=b3_q1wma==1 | b3_q1wma==2 if !mi(b3_q1wma)
	label var washingmachine "Household has Washing machine"
	la de lblwashingmachine 0 "No" 1 "Yes"
	label val washingmachine lblwashingmachine
*</_washingmachine>

** REFRIGERATOR
*<_refrigerator_>
	gen refrigerator=b3_q1fri==1 | b3_q1fri==2 if !mi(b3_q1fri)
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
	gen bicycle= b3_q1bic==1 | b3_q1bic==2 if !mi(b3_q1bic)
	label var bicycle "Household has Bicycle"
	la de lblbycicle 0 "No" 1 "Yes"
	label val bicycle lblbycicle
*</_bycicle>

** MOTORCYCLE
*<_motorcycle_>
	gen motorcycle=b3_q1bik==1 | b3_q1bik==2 if !mi(b3_q1bik)
	label var motorcycle "Household has Motorcycle"
	la de lblmotorcycle 0 "No" 1 "Yes"
	label val motorcycle lblmotorcycle
*</_motorcycle>

** MOTOR CAR
*<_motorcar_>
	gen motorcar= b3_q1car==1 | b3_q1car==2 if !mi(b3_q1car)
	label var motorcar "Household has Motor car"
	la de lblmotorcar 0 "No" 1 "Yes"
	label val motorcar lblmotorcar
*</_motorcar>

** COW
*<_cow_>
	gen cow=b3_q2cat>0 if b3_q2cat<.
	label var cow "Household has Cow"
	la de lblcow 0 "No" 1 "Yes"
	label val cow lblcow
*</_cow>

** BUFFALO
*<_buffalo_>
	gen buffalo=b3_q2buf>0 if b3_q2buf<.
	label var buffalo "Household has Buffalo"
	la de lblbuffalo 0 "No" 1 "Yes"
	label val buffalo lblbuffalo
*</_buffalo>

** CHICKEN
*<_chicken_>
	gen chicken=b3_q2chi>0 if b3_q2chi<.
	label var chicken "Household has Chicken"
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
	gen spdef=paachse
	la var spdef "Spatial deflator"
*</_spdef_>

** WELFARE
*<_welfare_>
	gen welfare=pcc_t_mo
	la var welfare "Welfare aggregate"
*</_welfare_>

*<_welfarenom_>
	gen welfarenom=pcc_t_mo
	la var welfarenom "Welfare aggregate in nominal terms"
*</_welfarenom_>

*<_welfaredef_>
	gen welfaredef=pcc_t_mo*paachse
	la var welfaredef "Welfare aggregate spatially deflated"
*</_welfaredef_>

*<_welfshprosperity_>
	gen welfshprosperity=welfaredef
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
	gen welfarenat=welfaredef
	la var welfarenat "Welfare aggregate for national poverty"
*</_welfarenat_>	

*QUINTILE, DECILE AND FOOD/NON-FOOD SHARES OF CONSUMPTION AGGREGATE
	xtile quintile_cons_aggregate=welfarenat [w=wgt], n(5)
	xtile decile_cons_aggregate=welfarenat [w=wgt], n(10)
	la var quintile_cons_aggregate "Quintile of welfarenat"
	la var decile_cons_aggregate "Decile of welfarenat"


/*****************************************************************************************************
*                                                                                                    *
                                   NATIONAL POVERTY
*                                                                                                    *
*****************************************************************************************************/
	
	
** POVERTY LINE (NATIONAL)
*<_pline_nat_>
	gen pline_nat=740.36
	label variable pline_nat "Poverty Line (National)"
*</_pline_nat_>

	
** HEADCOUNT RATIO (NATIONAL)
*<_poor_nat_>
	gen poor_nat=welfarenat<pline_nat if welfaredef!=.
	la var poor_nat "People below Poverty Line (National)"
	la define poor_nat 0 "Not-Poor" 1 "Poor"
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
	do "D:\SOUTH ASIA MICRO DATABASE\APPS\DATA CHECK\Label fixing\fixlabels", nostop

	keep countrycode year survey idh idp wgt pop_wgt strata psu vermast veralt urban int_month int_year subnatid0  ///
		subnatid1 subnatid2 subnatid3 gaul_adm1_code ownhouse landholding tenure water_orig piped_water water_jmp sar_improved_water  electricity toilet_orig sewage_toilet toilet_jmp sar_improved_toilet  landphone cellphone ///
	     computer internet hsize relationharm relationcs male age soc marital ed_mod_age everattend ///
		 water_original water_source improved_water pipedwater_acc watertype_quest sanitation_original sanitation_source improved_sanitation toilet_acc ///
	     atschool electricity literacy educy educat4 educat5 educat7 lb_mod_age lstatus lstatus_year empstat empstat_year njobs njobs_year ///
	     ocusec nlfreason unempldur_l unempldur_u industry_orig industry occup_orig occup firmsize_l firmsize_u whours wage ///
		  unitwage empstat_2 empstat_2_year industry_2 industry_orig_2 occup_2 wage_2 unitwage_2 contract healthins socialsec union rbirth_juris rbirth rprevious_juris rprevious yrmove ///
		 landphone cellphone computer radio television fan sewingmachine washingmachine refrigerator lamp bicycle motorcycle motorcar cow buffalo chicken  ///
		 pline_nat pline_int poor_nat poor_int spdef cpi ppp cpiperiod welfare welfshprosperity welfarenom welfaredef welfarenat quintile_cons_aggregate decile_cons_aggregate welfareother welfaretype welfareothertype  
		 
** ORDER VARIABLES

	order countrycode year survey idh idp wgt pop_wgt strata psu vermast veralt urban int_month int_year subnatid0 ///
		subnatid1 subnatid2 subnatid3 gaul_adm1_code ownhouse landholding tenure water_orig piped_water water_jmp sar_improved_water ///
		water_original water_source improved_water pipedwater_acc watertype_quest electricity toilet_orig sewage_toilet ///
		toilet_jmp sar_improved_toilet sanitation_original sanitation_source improved_sanitation toilet_acc landphone cellphone ///
	     computer internet hsize relationharm relationcs male age soc marital ed_mod_age everattend ///
	     atschool electricity literacy educy educat4 educat5 educat7 lb_mod_age lstatus lstatus_year empstat empstat_year njobs njobs_year ///
	     ocusec nlfreason unempldur_l unempldur_u industry_orig industry occup_orig occup firmsize_l firmsize_u whours wage ///
		  unitwage empstat_2 empstat_2_year industry_2 industry_orig_2 occup_2 wage_2 unitwage_2 contract healthins socialsec union rbirth_juris rbirth rprevious_juris rprevious yrmove ///
		 landphone cellphone computer radio television fan sewingmachine washingmachine refrigerator lamp bicycle motorcycle motorcar cow buffalo chicken  ///
		 pline_nat pline_int poor_nat poor_int spdef cpi ppp cpiperiod welfare welfshprosperity welfarenom welfaredef welfarenat quintile_cons_aggregate decile_cons_aggregate welfareother welfaretype welfareothertype  


	
	compress

** DELETE MISSING VARIABLES

	glo keep=""
	qui levelsof countrycode, local(cty)
	foreach var of varlist countrycode - welfareothertype {
		capture assert mi(`var')
		if !_rc {
		
			 display as txt "Variable " as result "`var'" as txt " for countrycode " as result `cty' as txt " contains all missing values -" as error " Variable Deleted"
			 
		}
		else {
		
			 glo keep = "$keep"+" "+"`var'"
			 
		}
	}
		
	foreach w in welfare welfareother {
	
		qui su `w'
		if r(N)==0 {
		
		drop `w'type
		
		}
	}
	
	keep countrycode year survey idh idp wgt pop_wgt strata psu vermast veralt  ${keep} *type

	compress
	
	notes
	
	saveold "`output'\Data\Harmonized\BTN_2003_BLSS_v01_M_v05_A_SARMD-FULL_IND.dta", replace version(12)
	saveold "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\BTN_2003_BLSS_v01_M_v05_A_SARMD-FULL_IND.dta", replace version(12)

	log close

*********************************************************************************************************************************	
******RENAME COMPARABLE VARIABLES AND SAVE THEM IN _SARMD. UNCOMPARABLE VARIALBES ACROSS TIME SHOULD BE FOUND IN _SARMD-FULL*****
*********************************************************************************************************************************

loc var pline_nat pline_int poor_nat poor_int spdef cpi ppp cpiperiod welfare welfarenom welfaredef welfarenat quintile_cons_aggregate decile_cons_aggregate ///
 welfareother  welfareothertype educy educat4 educat5 educat7 empstat empstat_2 ocusec nlfreason piped_water water_jmp sar_improved_water ///
 sewage_toilet toilet_jmp sar_improved_toilet
  

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
	saveold "`output'\Data\Harmonized\BTN_2003_BLSS_v01_M_v05_A_SARMD_IND.dta", replace version(12)
	saveold "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\BTN_2003_BLSS_v01_M_v05_A_SARMD_IND.dta", replace version(12)

note _dta: "BTN 2003" Variables NAMED with "v2" are those not compatible with latest round (2012). ///
 These include the existing information from the particular survey, but the iformation should be used for comparability purposes  



******************************  END OF DO-FILE  *****************************************************/
