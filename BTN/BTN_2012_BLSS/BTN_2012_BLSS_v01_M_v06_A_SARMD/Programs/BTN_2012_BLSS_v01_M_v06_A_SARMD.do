/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                                   SOUTH ASIA MICRO DATABASE                                      **
**                                                                                                  **
** COUNTRY			BHUTAN
** COUNTRY ISO CODE	BTN
** YEAR				2012
** SURVEY NAME		BHUTAN LIVING STANDARD SURVEY (BLSS) 2012
** SURVEY AGENCY	NATIONAL STATISTICAL BUREAU
** RESPONSIBLE		Triana Yentzen
** MODFIED BY		Fernando Enrique Morales Velandia
** Date				2/12/2018
** MODFIED BY		David Newhouse (to merge with new custom CPI series)
** Date				6/5/2018


**
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
	local input "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\BTN\BTN_2012_BLSS\BTN_2012_BLSS_v01_M"
	local output "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\BTN\BTN_2012_BLSS\BTN_2012_BLSS_v01_M_v06_A_SARMD"
	glo pricedata "D:\SOUTH ASIA MICRO DATABASE\CPI\cpi_ppp_sarmd_weighted.dta"
	glo shares "D:\SOUTH ASIA MICRO DATABASE\APPS\DATA CHECK\Food and non-food shares\BTN"
	glo fixlabels "D:\SOUTH ASIA MICRO DATABASE\APPS\DATA CHECK\Label fixing"

** LOG FILE
	log using "`output'\Doc\Technical\BTN_2012_BLSS_v01_M_v06_A_SARMD.log",replace

/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/


** DATABASE ASSEMBLENT

	use "`input'\Data\Stata\block1.dta", clear
	
	merge m:1 bchiwog hh6 using "`input'\Data\Stata\block2.dta"
	drop _merge
	
	merge m:1 bchiwog hh6 using "`input'\Data\Stata\block3.dta"
	drop _merge


	merge m:1 bchiwog hh6 using  "`input'\Data\Stata\poverty_estimate.dta"
	drop _merge
	

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
	gen int year=2012
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
	gen double idh=houseid
	format idh %12.0f
	tostring idh, replace
	label var idh "Household id"
*</_idh_>


** INDIVIDUAL IDENTIFICATION NUMBER
*<_idp_>

	egen idp=concat(idh slno)
	label var idp "Individual id"
*</_idp_>


** HOUSEHOLD WEIGHTS
*<_wgt_>
	gen wgt=weight
	label var wgt "Household sampling weight"
*</_wgt_>


** STRATA
*<_strata_>
	drop strata
	gen strata=hh1
	label var strata "Strata"
*</_strata_>


** PSU
*<_psu_>
	gen psu=bchiwog
	label var psu "Primary sampling units"
*</_psu_>

	
** MASTER VERSION
*<_vermast_>

	gen vermast="01"
	label var vermast "Master Version"
*</_vermast_>
	
	
** ALTERATION VERSION
*<_veralt_>

	gen veralt="05"
	label var veralt "Alteration Version"
*</_veralt_>	
	
	
/*****************************************************************************************************
*                                                                                                    *
                                   HOUSEHOLD CHARACTERISTICS MODULE
*                                                                                                    *
*****************************************************************************************************/


** LOCATION (URBAN/RURAL)
*<_urban_>
	gen urban=area
	recode urban (2=0)
	label var urban "Urban/Rural"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban
*</_urban_>


** MACRO REGIONAL AREA
*<_subnatid0_>
	gen area01=hh1
	recode area01 (12=1)(15=1)	(18=1)	(24=1)	(20=1)	(14=1)	(29=2)	(11=2)	(27=2)	(30=2)	(16=3)	(17=3)	(25=3)	(26=3)	(19=3)	(21=3)	(22=1)	(23=2)	(28=2)	(13=2), gen(subnatid0)
	la de lblsubnatid0 1 "Western" 2 "Central" 3 "Eastern" 4 "Southern"
	label values subnatid0 lblsubnatid0
	notes subnatid0: "BTN 2012" refer to technical doc for detail on classification
	label var subnatid0 "Macro regional areas"
*</_subnatid0_>
	
** REGIONAL AREA 1 DIGIT ADMN LEVEL
*<_subnatid1_>
	gen subnatid1=hh1
	recode subnatid1 (11=21) (12=11) (13=44) (14=16) (15=12) (16=31) (17=32) (18=13) (19=35) (20=15) (21=36) (22=41) (23=42) (24=14) (25=33) (26=34) (27=22) (28=43) (29=17) (30=23)
	la de lblsubnatid1 11"Chukha" 12"Ha" 13"Paro" 14"Thimphu" 15"Punakha" 16"Gasa" ///
	17 "Wangdi Phodrang" 21"Bumthang" 22"Trongsa" 23"Zhemgang" 31"Lhuntshi" 32"Mongar" ///
	33"Trashigang" 34 "Tashi Yangtse" 35"Pemagatshel" 36"Samdrup Jongkhar" 41"Samtse" ///
	42"Sarpang" 43"Tsirang" 44"Dagana"
	label var subnatid1 "Regional at 1 digit (ADMN1)"
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
	label var subnatid3 "Regional at 3 digit (ADMN3)"
	label values subnatid3 lblsubnatid3
*</_subnatid3_>


** HOUSE OWNERSHIP
*<_ownhouse_>
	gen ownhouse=hs2
	recode ownhouse (2=0) (9=.)
	label var ownhouse "House ownership"
	la de lblownhouse 0 "No" 1 "Yes"
	label values ownhouse lblownhouse
*</_ownhouse_>


** TENURE OF DWELLING
*<_tenure_>
   gen tenure=.
   replace tenure=1 if hs2==1
   replace tenure=2 if hs2==2 & (  hs3==1 | hs3==2)
   replace tenure=3 if  hs3==3 &  hs2!=1
   label var tenure "Tenure of Dwelling"
   la de lbltenure 1 "Owner" 2"Renter" 3"Other"
   la val tenure lbltenure
   *</_tenure_>	


** LANDHOLDING
*<_lanholding_>
   gen landholding=as3wo>0 | as3do>0 | as3or>0 if !mi(as3wo,as3do,as3or)
   label var landholding "Household owns any land"
   la de lbllandholding 0 "No" 1 "Yes"
   la val landholding lbllandholding
   notes landholding: "BTN 2012" this variable was generated if  hh owned either wet, dry or or orchard land
*</_tenure_>	

*ORIGINAL WATER CATEGORIES
*<_water_orig_>
gen water_orig=hs16
la var water_orig "Source of Drinking Water-Original from raw file"
#delimit
la def lblwater_orig 1 "Pipe in dwelling/ compound"
					 2 "Neighbour's pipe"
					 3 "Public outdoor tap"
					 4 "Protected well"
					 5 "Unprotected well"
					 6 "Protected spring"
					 7 "Unprotected spring"
					 8 "Rain water collection"
					 9 "Tanker truck"
					 10 "Cart with small tank/drum"
					 11 "Surface water (river, stream, dam, lake, pond, canal, irrigation channel)"
					 12 "Bottled water"
					 13 "Other (specify)";
#delimit cr
la val water_orig lblwater_orig
*</_water_orig_>


*ORIGINAL WATER CATEGORIES
*<_water_original_>
clonevar j=hs16
#delimit
la def lblwater_original 1 "Pipe in dwelling/ compound"
						 2 "Neighbour's pipe"
					     3 "Public outdoor tap"
					     4 "Protected well"
					     5 "Unprotected well"
					     6 "Protected spring"
					     7 "Unprotected spring"
					     8 "Rain water collection"
					     9 "Tanker truck"
					     10 "Cart with small tank/drum"
					     11 "Surface water (river, stream, dam, lake, pond, canal, irrigation channel)"
					     12 "Bottled water"
					     13 "Other (specify)";
#delimit cr
la val j lblwater_original		
decode j, gen(water_original)
drop j
la var water_original "Source of Drinking Water-Original from raw file"
*</_water_original_>

				   
	** WATER SOURCE
	*<_water_source_>
		gen water_source=.
		replace water_source=1 if hs16==1
		replace water_source=2 if hs16==2
		replace water_source=3 if hs16==3
		replace water_source=5 if hs16==4
		replace water_source=10 if hs16==5
		replace water_source=6 if hs16==6
		replace water_source=9 if hs16==7
		replace water_source=8 if hs16==8
		replace water_source=12 if hs16==9
		replace water_source=11 if hs16==10
		replace water_source=13 if hs16==11
		replace water_source=7 if hs16==12
		replace water_source=14 if hs16==13
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
		gen pipedwater_acc=0 if inrange(hs16,2,13) // Asuming other is not piped water
		replace pipedwater_acc=3 if inlist(hs16,1)
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

	
*PIPED SOURCE OF WATER
*<_piped_water_>
gen piped_water=hs16
recode piped_water (2/13=0) (99=.)
la var piped_water "Household has access to piped water"
la def lblpiped_water 1 "Yes" 0 "No"
la val piped_water lblpiped_water
*</_piped_water_>


**INTERNATIONAL WATER COMPARISON (Joint Monitoring Program)
*<_water_jmp_>
gen water_jmp=hs16
recode water_jmp (1=1) (2=2) (3=3) (4=5) (5=6) (6=7) (7=8) (8=9) (9=10) (10=11) ///
(11=12) (12=13) (13=14)

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
*</_water_jmp_>

  *SAR improved source of drinking water
*<_sar_improved_water_>
gen sar_improved_water=.
replace sar_improved_water=1 if inlist(hs16,1,2,3,4,6,8)
replace sar_improved_water=0 if inlist(hs16,5,7,9,10,11,12,13) 
la def lblsar_improved_water 1 "Improved" 0 "Unimproved"
la var sar_improved_water "Improved source of drinking water-using country-specific definitions"
la val sar_improved_water lblsar_improved_water
*</_sar_improved_water_>


** ELECTRICITY PUBLIC CONNECTION
*<_electricity_>
	gen electricity=hs25
	recode electricity (1 3 4 = 0) (2=1) (9=.)
	label var electricity "Electricity main source"
	la de lblelectricity 0 "No" 1 "Yes"
	label values electricity lblelectricity
*</_electricity_>

*ORIGINAL TOILET CATEGORIES
*<_toilet_orig_>
gen toilet_orig=hs21
la var toilet_orig "Access to sanitation facility-Original from raw file"
#delimit
la def lbltoilet_orig 1 "Flush to piped sewer system"
					  2 "Flush to septic tank (without soak pit)"
					  3 "Flush to septic tank (with soak pit)"
					  4 "Flush to pit (latrine)"
					  5 "Flush to somehere else"
					  6 "Flush to unkown place/Not sure/Don't know"
					  7 "Ventilated improved pit"
					  8 "Pit latrine with slab"
					  9 "Pit latrine without a slap/open pit"
					  10 "Long drop latrine"
					  11 "Composting toilet"
					  12 "Bucket"
					  13 "No facility/Bush/Field";
#delimit cr
la val toilet_orig lbltoilet_orig
*</_toilet_orig_>


*SEWAGE TOILET
*<_sewage_toilet_>
gen sewage_toilet=hs21
recode sewage_toilet (2/13=0) (99=.)
la var sewage_toilet "Household has access to sewage toilet"
la def lblsewage_toilet 1 "Yes" 0 "No"
la val sewage_toilet lblsewage_toilet
*</_sewage_toilet_>


**INTERNATIONAL SANITATION COMPARISON (Joint Monitoring Program)
*<_toilet_jmp_>
gen toilet_jmp=hs21
recode toilet_jmp (1=1) (2 3=2) (4=3) (5=4) (6=5) (7=6) (8=7) (9=8) (10=11) (11=9) (12=10) (13=12) 
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
replace sar_improved_toilet=1 if inlist(hs21,1,2,3,4,7,8,11)
replace sar_improved_toilet=0 if inlist(hs21,5,6,9,10,12,13)
replace sar_improved_toilet=0 if hs22==1
la def lblsar_improved_toilet 1 "Improved" 0 "Unimproved"
la var sar_improved_toilet "Improved type of sanitation facility-using country-specific definitions"
la val sar_improved_toilet lblsar_improved_toilet
*</_sar_improved_toilet_>


	** ORIGINAL SANITATION CATEGORIES 
	*<_sanitation_original_>
		clonevar j=hs21
		#delimit
		la def lblsanitation_original   1 "Flush to piped sewer system"
										2 "Flush to septic tank (without soak pit)"
										3 "Flush to septic tank (with soak pit)"
										4 "Flush to pit (latrine)"
										5 "Flush to somehere else"
										6 "Flush to unkown place/Not sure/Don't know"
										7 "Ventilated improved pit"
										8 "Pit latrine with slab"
										9 "Pit latrine without a slap/open pit"
										10 "Long drop latrine"
										11 "Composting toilet"
										12 "Bucket"
										13 "No facility/Bush/Field";
		#delimit cr
		la val j lblsanitation_original
		decode j, gen(sanitation_original)
		drop j
		la var sanitation_original "Access to sanitation facility-Original from raw file"
	*</_sanitation_original_>


	** SANITATION SOURCE
	*<_sanitation_source_>
		gen sanitation_source=.
		replace sanitation_source=2 if hs21==1
		replace sanitation_source=3 if hs21==2
		replace sanitation_source=3 if hs21==3
		replace sanitation_source=4 if hs21==4
		replace sanitation_source=9 if hs21==5
		replace sanitation_source=9 if hs21==6
		replace sanitation_source=5 if hs21==7
		replace sanitation_source=6 if hs21==8
		replace sanitation_source=10 if hs21==9
		replace sanitation_source=12 if hs21==10
		replace sanitation_source=7 if hs21==11
		replace sanitation_source=11 if hs21==12
		replace sanitation_source=13 if hs21==13
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
		gen toilet_acc=3 if inrange(hs21,1,6)
		replace toilet_acc=0 if inrange(hs21,7,13)
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
	gen internet=0 if hs14a=="a"
	replace internet=1 if internet==. & hs14a!=""
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
	drop hsize
	gen z=1
	bys idh: egen hsize=sum(z)
	label var hsize "Household size"
*</_hsize_>

**POPULATION WEIGHT
*<_pop_wgt_>
	gen pop_wgt=wgt*hsize
	la var pop_wgt "Population weight"
*</_pop_wgt_>

** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
*<_relationharm_>
	gen relationharm=d2
	recode relationharm (5/12=5) (13/14=6) (99=.)
	replace ownhouse=. if relationharm==6
	label var relationharm "Relationship to the head of household"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Non-relatives"
	label values relationharm  lblrelationharm
*</_relationharm_>

** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
*<_relationcs_>

	gen byte relationcs=d2
	replace relationcs=. if d2==99
	la var relationcs "Relationship to the head of household country/region specific"
	label define lblrelationcs 1 "Self(head)" 2 "Wife/Husband/Partner" 3 "Son/daughter" 4 "Father/Mother" 5 "Sister/Brother" 6 "Grandfather/Grandmother" 7 "Grandchild" 8 "Niece/nephew" 9 "Son-in-law/daughter-in-law" 10 "Brother-in-law/sister-in-law" 11 "Father-in-law/mother-in-law" 12 "Other family relative" 13 "Live-in-servant" 14 "Other-non-relative"
	label values relationcs lblrelationcs
*</_relationcs_>


** GENDER
*<_male_>
	gen male=d1
	recode male (2=0) (9=.)
	label var male "Sex of household member"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale
*</_male_>


** AGE
*<_age_>
	gen age=d3
	replace age=98 if age>=98 & age!=.
	label var age "Age of individual"
*</_age_>


** SOCIAL GROUP
*<_soc_>
	gen soc=d6
	recode soc (9=.)
	label var soc "Social group"
	la de lblsoc 1 "Bhutanese" 2 "Other"
	label values soc lblsoc
	notes soc: "BTN 2012" this variable has "nationality"
*</_soc_>


** MARITAL STATUS
*<_marital_>
	gen marital=d4
	recode marital (3=1) (1=2) (2=3) (4/5=4) (6=5) (9=.)
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
	gen ed_mod_age=3
	label var ed_mod_age "Education module application age"
*</_ed_mod_age_>


** EVER ATTENDED SCHOOL
*<_everattend_>
	gen everattend=ed2
	recode everattend (1 2 = 1) (3= 0) (9=.)
	label var everattend "Ever attended school"
	la de lbleverattend 0 "No" 1 "Yes"
	label values everattend lbleverattend
	notes everattend: "BTN 2012" this variable includes people with no education and/or pre-primary education
*</_everattend_>



** CURRENTLY AT SCHOOL
*<_atschool_>
	gen atschool= ed2
	recode atschool (2/3=0) (9=.)
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool
	notes atschool: "BTN 2012" this variable includes people with no education and/or pre-primary education
*</_atschool_>


** CAN READ AND WRITE
*<_literacy_>
	gen literacy=.
	replace literacy=0 if ed1dz==2 & ed1eng==2 & ed1lot==2 & ed1oth==2
	replace literacy=1 if ed1dz==1 | ed1eng==1 | ed1lot==1 | ed1oth==1
	replace literacy=. if age<ed_mod_age
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
*</_literacy_>


** YEARS OF EDUCATION COMPLETED
*<_educy_>
gen educy1=.
gen educy2=.
replace educy1=ed3
recode educy1 (13/14=14) (15=14) (17=18) (18=0) (19/99=.)
replace educy2=ed11
recode educy2 (13/14=14) (16=17) (17=19) (18=0) (19/99=.)
gen educy=educy1
replace educy=0 if ed2==3
replace educy=educy2 if educy2!=.
replace educy=. if age<ed_mod_age 
replace educy=. if educy>age+1 & educy<. & age!=.
label var educy "Years of education"
*</_educy_>



** EDUCATION LEVEL 7 CATEGORIES
*<_educat7_>
gen edulevel1=.
replace edulevel1=1 if educy==0
replace edulevel1=2 if educy>0 & educy<9
replace edulevel1=3 if educy==9
replace edulevel1=4 if educy>9 & educy<12
replace edulevel1=5 if educy==12
replace edulevel1=7 if educy>12 & educy!=.
replace edulevel1=6 if inlist(ed3,13,14) | inlist(ed11,13,14)
replace edulevel1=8 if inlist(19,ed3,ed11)
replace edulevel1=. if age<ed_mod_age
rename edulevel1 educat7
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
	la var educat5 "Level of education 5 categories"

	*</_educat5_>



** EDUCATION LEVEL 4 CATEGORIES
*<_educat4_>
	gen byte educat4=educat7
	recode educat4 (2/3=2) (4/5=3) (6 7=4)
	label var educat4 "Level of education 4 categories"
	label define lbleducat4 1 "No education" 2 "Primary (complete or incomplete)" ///
	3 "Secondary (complete or incomplete)" 4 "Tertiary (complete or incomplete)"
	label values educat4 lbleducat4
	replace educat4=. if educat7==8
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
*</_lb_mod_age_>



** LABOR STATUS
*<_lstatus_>
	gen lstatus = .  
	replace lstatus = 1 if inlist(1, e1,  e2,  e3)
	replace lstatus = 2 if  e4==1 & mi(lstatus)
	replace lstatus = 3 if e5!=. & lstatus!=1
	replace lstatus = . if age<15 
	label var lstatus "Labor status"
	label define lbllstatus 1"Employed" 2"Unemployed" 3"Not-in-labor-force"
	label values lstatus lbllstatus
*</_lstatus_>


** LABOR STATUS LAST YEAR
*<_lstatus_year_>
	gen byte lstatus_year=.
	replace lstatus_year=. if age<lb_mod_age & age!=.
	label var lstatus_year "Labor status during last year"
	la de lbllstatus_year 1 "Employed" 0 "Not employed" 
	label values lstatus_year lbllstatus_year
*</_lstatus_year_>


** EMPLOYMENT STATUS
*<_empstat_>
	gen empstat=e6
	recode empstat (1 2=1) (3=2) (5=3) (6=5)
	label var empstat "Employment status"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other"
	label values empstat lblempstat
*</_empstat_>
	replace empstat=. if lstatus!=1 | age<15

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
	gen njobs=.
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
	gen ocusec=.
	label var ocusec "Sector of activity"
	la de lblocusec 1 "Public, state owned, government, army" 2 "NGO" 3 "Private"
	label values ocusec lblocusec
	replace ocusec=. if lstatus!=1 | age<15
	notes ocusec: "BTN 2012" this variable was captured as missing due to lack of relevant question
*</_ocusec_>

** REASONS NOT IN THE LABOR FORCE
*<_nlfreason_>
	gen nlfreason=e5
	recode nlfreason (8=1) (7=2) (9=3) (1 10=4) (2/6 11=5) (99=.)
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
	gen industry_orig=.
	la val industry_orig lblindustry_orig
	replace industry_orig=. if lstatus!=1
	la var industry_orig "Original industry code"
*</_industry_orig_>


** INDUSTRY CLASSIFICATION
*<_industry_>
	gen industry=.
	replace  industry =. if age<15 | industry==11
	replace industry=. if lstatus!=1
	label var industry "1 digit industry classification"
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industry lblindustry
	notes industry: "BTN 2012" no relevant question for creating variable, compared with previous rounds. Take into account for comparability purposes
*</_industry_>

**ORIGINAL OCCUPATION CLASSIFICATION
*<_occup_orig_>
	gen occup_orig=e7
	label define lbloccup_orig 110 `"army/defence service/dy.commander/dy.commissioner/major/lieu"', modify
	label define lbloccup_orig 1110 `"legislators"', modify
	label define lbloccup_orig 1121 `"hm secretary/advisor to pm"', modify
	label define lbloccup_orig 1130 `"gup"', modify
	label define lbloccup_orig 1141 `"member of parliament"', modify
	label define lbloccup_orig 1142 `"dy. secretay/dyt secretary/dzongda/dungpa/regional secretary"', modify
	label define lbloccup_orig 1143 `"senior officials of humanitarian ad other special-interest o"', modify
	label define lbloccup_orig 1210 `"director\director general/jd/managing director/trade regiona"', modify
	label define lbloccup_orig 1221 `"production and operations managers"', modify
	label define lbloccup_orig 1222 `"bob manager/assistant manager"', modify
	label define lbloccup_orig 1223 `"personnel and industrial relations managers"', modify
	label define lbloccup_orig 1224 `"sales and marketing managers/sale managers/fcb manager/purch"', modify
	label define lbloccup_orig 1225 `"advertising and public realtion managers"', modify
	label define lbloccup_orig 1226 `"supply and distribution managers/bod manager"', modify
	label define lbloccup_orig 1227 `"computer services managers"', modify
	label define lbloccup_orig 1228 `"researcher"', modify
	label define lbloccup_orig 1229 `"other specialised managers"', modify
	label define lbloccup_orig 1311 `"manager/gm/sm in agriculture"', modify
	label define lbloccup_orig 1312 `"manager/gm/sm in manufacturing"', modify
	label define lbloccup_orig 1313 `"manager/gm/sm in construction"', modify
	label define lbloccup_orig 1314 `"manager/gm/sm in retail and wholesale"', modify
	label define lbloccup_orig 1315 `"manager/gm/sm in restaurants and hotels"', modify
	label define lbloccup_orig 1316 `"manager/gm/sm in transportation"', modify
	label define lbloccup_orig 1317 `"general managers of business services firms"', modify
	label define lbloccup_orig 1318 `"general managers in personal care,cleaing,repairs and relate"', modify
	label define lbloccup_orig 1319 `"manager"', modify
	label define lbloccup_orig 2112 `"metrology"', modify
	label define lbloccup_orig 2113 `"chemists"', modify
	label define lbloccup_orig 2114 `"seismological and geologist"', modify
	label define lbloccup_orig 2121 `"mathematicians ad related professionals"', modify
	label define lbloccup_orig 2122 `"statistician"', modify
	label define lbloccup_orig 2131 `"analyst/software engineer"', modify
	label define lbloccup_orig 2132 `"computer programmers"', modify
	label define lbloccup_orig 2139 `"ict officer"', modify
	label define lbloccup_orig 2141 `"architect"', modify
	label define lbloccup_orig 2142 `"civil engineer"', modify
	label define lbloccup_orig 2143 `"electrical engineer"', modify
	label define lbloccup_orig 2144 `"electronic and telecommunications engineers"', modify
	label define lbloccup_orig 2145 `"mechanical engineer"', modify
	label define lbloccup_orig 2146 `"chemical engineer"', modify
	label define lbloccup_orig 2147 `"mining engineers"', modify
	label define lbloccup_orig 2148 `"survey engineer/surveyor/maping officer"', modify
	label define lbloccup_orig 2149 `"computer engineer/associate engineer"', modify
	label define lbloccup_orig 2211 `"biodiversity officer/entomologist"', modify
	label define lbloccup_orig 2212 `"bacteriologists,pharmacologists ad related professionals"', modify
	label define lbloccup_orig 2213 `"agronomists ad related professionals"', modify
	label define lbloccup_orig 2221 `"doctor/medical doctors/surgeon"', modify
	label define lbloccup_orig 2222 `"dentist/prosthodontic specialist"', modify
	label define lbloccup_orig 2223 `"veterinarian"', modify
	label define lbloccup_orig 2224 `"pharmacist"', modify
	label define lbloccup_orig 2229 `"admo(asst.dzongkhag medical officer)/bio medical engineer/me"', modify
	label define lbloccup_orig 2230 `"gnm/anm/nurse"', modify
	label define lbloccup_orig 2310 `"sr. lecturer/lecturer/college teacher/high school teacher/"', modify
	label define lbloccup_orig 2320 `"lss teacher"', modify
	label define lbloccup_orig 2331 `"primary teacher"', modify
	label define lbloccup_orig 2332 `"preprimary education teaching professionals"', modify
	label define lbloccup_orig 2340 `"special education teaching professionals"', modify
	label define lbloccup_orig 2351 `"education methods specialists"', modify
	label define lbloccup_orig 2352 `"adeo(asst.dzongkhag education officer)"', modify
	label define lbloccup_orig 2359 `"nfe instructor/training of trainers"', modify
	label define lbloccup_orig 2411 `"charter accountant/accountant"', modify
	label define lbloccup_orig 2412 `"personal ad careers professionals"', modify
	label define lbloccup_orig 2419 `"proprietor/businessman"', modify
	label define lbloccup_orig 2421 `"lawyers"', modify
	label define lbloccup_orig 2422 `"judges/drangpon"', modify
	label define lbloccup_orig 2429 `"assistant attorney/other legal professionals"', modify
	label define lbloccup_orig 2431 `"archivists and curators"', modify
	label define lbloccup_orig 2432 `"librarian"', modify
	label define lbloccup_orig 2441 `"economists"', modify
	label define lbloccup_orig 2442 `"sociologists,anthropologists ad related professionals"', modify
	label define lbloccup_orig 2443 `"historians and political scientist"', modify
	label define lbloccup_orig 2444 `"translator and interpreters"', modify
	label define lbloccup_orig 2445 `"psychologists"', modify
	label define lbloccup_orig 2446 `"social work professionals"', modify
	label define lbloccup_orig 2451 `"journalist"', modify
	label define lbloccup_orig 2452 `"artist/craftman/freelance artist/scrap dealer"', modify
	label define lbloccup_orig 2453 `"composers, musicians and singers/music teacher"', modify
	label define lbloccup_orig 2454 `"choreographers and dancers"', modify
	label define lbloccup_orig 2455 `"film editor/film, stage and related actors/movie directors a"', modify
	label define lbloccup_orig 2460 `"monk/religion professionals"', modify
	label define lbloccup_orig 2461 `"revenue inspector"', modify
	label define lbloccup_orig 3111 `"lab assistant/incharge/technician/pharmacy technician"', modify
	label define lbloccup_orig 3112 `"civil engineering technicians"', modify
	label define lbloccup_orig 3113 `"auto electrician/solar technician"', modify
	label define lbloccup_orig 3114 `"electronics and telecommunications egineerig technicians"', modify
	label define lbloccup_orig 3115 `"mechanic/mechaical technician"', modify
	label define lbloccup_orig 3116 `"chemical engineering technicians"', modify
	label define lbloccup_orig 3117 `"mining and metallurgical technicians"', modify
	label define lbloccup_orig 3118 `"technical draughters"', modify
	label define lbloccup_orig 3119 `"techician"', modify
	label define lbloccup_orig 3121 `"computer techician"', modify
	label define lbloccup_orig 3122 `"hardware engineer"', modify
	label define lbloccup_orig 3123 `"industrial robot controllers"', modify
	label define lbloccup_orig 3131 `"photo designer/photographer/cameraman/sonographer"', modify
	label define lbloccup_orig 3132 `"radio grapher"', modify
	label define lbloccup_orig 3133 `"x-ray technician"', modify
	label define lbloccup_orig 3134 `"commissioner"', modify
	label define lbloccup_orig 3135 `"engineer"', modify
	label define lbloccup_orig 3136 `"statistical investigator"', modify
	label define lbloccup_orig 3139 `"other optical and electronic equipment controllers"', modify
	label define lbloccup_orig 3143 `"pilot"', modify
	label define lbloccup_orig 3144 `"air traffic controllers"', modify
	label define lbloccup_orig 3145 `"air traffic safety technicians"', modify
	label define lbloccup_orig 3151 `"building inspector"', modify
	label define lbloccup_orig 3211 `"life science technicians"', modify
	label define lbloccup_orig 3212 `"agronomy and forestry technician"', modify
	label define lbloccup_orig 3213 `"bsc, forestry/agriculture extension officer/dfo/dy. ranger/f"', modify
	label define lbloccup_orig 3221 `"dzongkhag health officer/ultra sonographer"', modify
	label define lbloccup_orig 3222 `"sanitarians"', modify
	label define lbloccup_orig 3223 `"dfo/dieticians and nutritionists"', modify
	label define lbloccup_orig 3224 `"eye specialist/ophthalmic technician"', modify
	label define lbloccup_orig 3225 `"dental hygienist"', modify
	label define lbloccup_orig 3226 `"physiotherapists"', modify
	label define lbloccup_orig 3227 `"animal husbandry/compounder/livestock officer/supervisor"', modify
	label define lbloccup_orig 3228 `"village health worker"', modify
	label define lbloccup_orig 3229 `"clinical assistant/assistant chemical officer/health assista"', modify
	label define lbloccup_orig 3231 `"nursing associate professionals"', modify
	label define lbloccup_orig 3232 `"midwifery associate professionals"', modify
	label define lbloccup_orig 3241 `"traditional physician/dungtso"', modify
	label define lbloccup_orig 3242 `"faith healers"', modify
	label define lbloccup_orig 3310 `"primary education teaching associate professionals"', modify
	label define lbloccup_orig 3320 `"preprimary eduation teaching associate professionals"', modify
	label define lbloccup_orig 3330 `"special education teaching associate professionals"', modify
	label define lbloccup_orig 3340 `"other teaching associate professionals"', modify
	label define lbloccup_orig 3411 `"banking/recovery officer"', modify
	label define lbloccup_orig 3412 `"development officer(ricbl)"', modify
	label define lbloccup_orig 3413 `"estate agents"', modify
	label define lbloccup_orig 3414 `"travel consultants and organizers"', modify
	label define lbloccup_orig 3415 `"technical and commercial sales representatives"', modify
	label define lbloccup_orig 3416 `"buyers"', modify
	label define lbloccup_orig 3417 `"appriasers and valuers"', modify
	label define lbloccup_orig 3418 `"auctioneers"', modify
	label define lbloccup_orig 3419 `"marketing officer(bank)"', modify
	label define lbloccup_orig 3421 `"broker"', modify
	label define lbloccup_orig 3422 `"clearing and forwarding agents"', modify
	label define lbloccup_orig 3423 `"contractor/contact paid worker"', modify
	label define lbloccup_orig 3429 `"other business services agents and trade brokers"', modify
	label define lbloccup_orig 3431 `"procurement/program/protocol & hospitility officer/adm/audit"', modify
	label define lbloccup_orig 3432 `"legal and related business associate professionals"', modify
	label define lbloccup_orig 3433 `"bookkeepers"', modify
	label define lbloccup_orig 3434 `"census officer/civil registration officer/dzongkhag statisti"', modify
	label define lbloccup_orig 3439 `"maintainence officer/trading officer"', modify
	label define lbloccup_orig 3441 `"custom inspector/drug inspector/immigration officer/trade in"', modify
	label define lbloccup_orig 3442 `"government tax and excise officials"', modify
	label define lbloccup_orig 3443 `"government welfare and pensio officials"', modify
	label define lbloccup_orig 3444 `"license officer"', modify
	label define lbloccup_orig 3445 `"investigating officer(crime)"', modify
	label define lbloccup_orig 3449 `"dzongkha credit officer/cultural officer/election officer/ch"', modify
	label define lbloccup_orig 3450 `"social secretary"', modify
	label define lbloccup_orig 3461 `"media designer/designer"', modify
	label define lbloccup_orig 3462 `"bbs programmer"', modify
	label define lbloccup_orig 3463 `"dzongkhag dancers"', modify
	label define lbloccup_orig 3465 `"badminton coach/archer/boc manager/tennis coach"', modify
	label define lbloccup_orig 3470 `"gomchen"', modify
	label define lbloccup_orig 3471 `"sample boy"', modify
	label define lbloccup_orig 3472 `"field assistant"', modify
	label define lbloccup_orig 4111 `"stenographers/typist"', modify
	label define lbloccup_orig 4112 `"word processing and related operators"', modify
	label define lbloccup_orig 4113 `"data entry operator/data puncher/computer operator"', modify
	label define lbloccup_orig 4114 `"calculating machine operators"', modify
	label define lbloccup_orig 4115 `"office assistant/pa/ps"', modify
	label define lbloccup_orig 4121 `"store keeper/incharge"', modify
	label define lbloccup_orig 4122 `"statistical and finance clerks"', modify
	label define lbloccup_orig 4131 `"stock clerks"', modify
	label define lbloccup_orig 4132 `"prouction clerks"', modify
	label define lbloccup_orig 4133 `"transport clerks"', modify
	label define lbloccup_orig 4141 `"dispatcher"', modify
	label define lbloccup_orig 4142 `"post master/man"', modify
	label define lbloccup_orig 4143 `"magazine editor/editor"', modify
	label define lbloccup_orig 4144 `"scribes"', modify
	label define lbloccup_orig 4211 `"ticketing/tourism/traditional guide/bank assistant/cashier"', modify
	label define lbloccup_orig 4212 `"teller"', modify
	label define lbloccup_orig 4215 `"billing clerk/bench clerk/parking fee collector/tax collecto"', modify
	label define lbloccup_orig 4221 `"travel agency clerks"', modify
	label define lbloccup_orig 4222 `"receptionist"', modify
	label define lbloccup_orig 4223 `"telephone operator/switchboard operator"', modify
	label define lbloccup_orig 4224 `"wireless operator"', modify
	label define lbloccup_orig 5111 `"flight attendants and travel stewards/air hostess"', modify
	label define lbloccup_orig 5112 `"transport conductor"', modify
	label define lbloccup_orig 5113 `"freelance guide/cultural and treking guide/guide/musium guid"', modify
	label define lbloccup_orig 5116 `"project officer"', modify
	label define lbloccup_orig 5121 `"house keeper"', modify
	label define lbloccup_orig 5122 `"head cook/cook/chef"', modify
	label define lbloccup_orig 5123 `"waiters/waitress/bartenders"', modify
	label define lbloccup_orig 5131 `"babysitter"', modify
	label define lbloccup_orig 5132 `"customer care"', modify
	label define lbloccup_orig 5133 `"maid/house helper"', modify
	label define lbloccup_orig 5139 `"other personal care workers"', modify
	label define lbloccup_orig 5141 `"beautician/barber/makeup artist"', modify
	label define lbloccup_orig 5149 `"tshogpa"', modify
	label define lbloccup_orig 5151 `"astrologers"', modify
	label define lbloccup_orig 5152 `"fortune-tellers,palmists and related workers"', modify
	label define lbloccup_orig 5161 `"fireman/fire fighter"', modify
	label define lbloccup_orig 5162 `"police/traffic police/constable"', modify
	label define lbloccup_orig 5163 `"prison guards"', modify
	label define lbloccup_orig 5169 `"protective services workers not elsewhere classified"', modify
	label define lbloccup_orig 5210 `"shopkeeper/saleperson"', modify
	label define lbloccup_orig 5220 `"stall and market salepersons"', modify
	label define lbloccup_orig 5230 `"fashion and other models"', modify
	label define lbloccup_orig 6111 `"field crop and vegetables growers"', modify
	label define lbloccup_orig 6112 `"tree and shrub crop growers"', modify
	label define lbloccup_orig 6113 `"gardener"', modify
	label define lbloccup_orig 6114 `"farmer"', modify
	label define lbloccup_orig 6121 `"diary and livestock producers"', modify
	label define lbloccup_orig 6122 `"poultry producers"', modify
	label define lbloccup_orig 6124 `"cow herder"', modify
	label define lbloccup_orig 6141 `"timber assistant/loading contractor/helper/fire wood collect"', modify
	label define lbloccup_orig 7111 `"mines inspector"', modify
	label define lbloccup_orig 7113 `"mason"', modify
	label define lbloccup_orig 7121 `"builders, traditional materials"', modify
	label define lbloccup_orig 7123 `"bricklayers,stonemasons and tile setters"', modify
	label define lbloccup_orig 7124 `"carpenter"', modify
	label define lbloccup_orig 7129 `"other building frame and related trades workers"', modify
	label define lbloccup_orig 7131 `"roofers"', modify
	label define lbloccup_orig 7132 `"plasters"', modify
	label define lbloccup_orig 7133 `"insulators"', modify
	label define lbloccup_orig 7134 `"glaziers"', modify
	label define lbloccup_orig 7135 `"plumber/water supplier"', modify
	label define lbloccup_orig 7136 `"building and related electricians"', modify
	label define lbloccup_orig 7141 `"painter"', modify
	label define lbloccup_orig 7211 `"metal moulders ad core makers"', modify
	label define lbloccup_orig 7212 `"welder"', modify
	label define lbloccup_orig 7213 `"sheet metal workers"', modify
	label define lbloccup_orig 7221 `"blacksmith"', modify
	label define lbloccup_orig 7231 `"automobile mechanic"', modify
	label define lbloccup_orig 7232 `"aircraft engine mechanics and fitters"', modify
	label define lbloccup_orig 7241 `"electrical  mechanics and fitters"', modify
	label define lbloccup_orig 7242 `"mobile repairing"', modify
	label define lbloccup_orig 7243 `"radio and tv services"', modify
	label define lbloccup_orig 7244 `"telegraph and telephoe installers"', modify
	label define lbloccup_orig 7245 `"cable operator/electrician/lineman"', modify
	label define lbloccup_orig 7313 `"goldsmith"', modify
	label define lbloccup_orig 7321 `"potter"', modify
	label define lbloccup_orig 7331 `"handicraft workers in wood and related materials"', modify
	label define lbloccup_orig 7332 `"handicrafts workers in textile, leather and related material"', modify
	label define lbloccup_orig 7343 `"printers"', modify
	label define lbloccup_orig 7344 `"binder"', modify
	label define lbloccup_orig 7411 `"butcher"', modify
	label define lbloccup_orig 7412 `"bakery personnel"', modify
	label define lbloccup_orig 7413 `"good and beverages tester/food inspector"', modify
	label define lbloccup_orig 7414 `"tobacco prepares and tobacco product makers"', modify
	label define lbloccup_orig 7421 `"woodcutter"', modify
	label define lbloccup_orig 7432 `"knitter/weaver"', modify
	label define lbloccup_orig 7433 `"tailor"', modify
	label define lbloccup_orig 7436 `"emdroiderers"', modify
	label define lbloccup_orig 7442 `"cobler"', modify
	label define lbloccup_orig 8111 `"mining plant operators"', modify
	label define lbloccup_orig 8141 `"sawmill, wood panel and related wood processing plant operat"', modify
	label define lbloccup_orig 8142 `"paper pulp preparation plant operators"', modify
	label define lbloccup_orig 8143 `"papermaking plant operators"', modify
	label define lbloccup_orig 8161 `"power house maintenance/operator"', modify
	label define lbloccup_orig 8211 `"machine operator"', modify
	label define lbloccup_orig 8212 `"cement and other mineral processig machine operators"', modify
	label define lbloccup_orig 8240 `"printing, binding machine operators"', modify
	label define lbloccup_orig 8251 `"printing machine operators"', modify
	label define lbloccup_orig 8252 `"binding machine operators"', modify
	label define lbloccup_orig 8253 `"paper and paperboard products machine operator"', modify
	label define lbloccup_orig 8322 `"car and taxi driver"', modify
	label define lbloccup_orig 8323 `"bus driver"', modify
	label define lbloccup_orig 8324 `"heavy truck driver"', modify
	label define lbloccup_orig 8332 `"earth moving and related machinery operators"', modify
	label define lbloccup_orig 8333 `"crane and dozer driver/excavator driver/roller operator"', modify
	label define lbloccup_orig 8341 `"plant and machinery helper"', modify
	label define lbloccup_orig 9111 `"street food vendors"', modify
	label define lbloccup_orig 9112 `"vegetable vender"', modify
	label define lbloccup_orig 9131 `"fetching water/washerman"', modify
	label define lbloccup_orig 9132 `"catering/cleaner/dishwasher/guest service attendant/handy bo"', modify
	label define lbloccup_orig 9141 `"caretaker"', modify
	label define lbloccup_orig 9151 `"gewog chupon/messenger/orange exporter/transporter/peon"', modify
	label define lbloccup_orig 9152 `"g4s/gate keeper/night guard/security guard/watchman"', modify
	label define lbloccup_orig 9153 `"private secretary guard"', modify
	label define lbloccup_orig 9154 `"guage reader(hydrology)/oil distributor/water meter reader"', modify
	label define lbloccup_orig 9161 `"garbage collectors"', modify
	label define lbloccup_orig 9162 `"dry sweeper/sweeper"', modify
	label define lbloccup_orig 9312 `"road and dam construction labourers/road inspector/superviso"', modify
	label define lbloccup_orig 9313 `"buildig construction labourers"', modify
	label define lbloccup_orig 9322 `"packing helper"', modify
	label define lbloccup_orig 9341 `"factory worker"', modify
	label define lbloccup_orig 9700 `"no skill"', modify
	label define lbloccup_orig 9800 `"occupation not stated"', modify
	label define lbloccup_orig 9900 `"occupation not classified by economic activity"', modify
	la val occup_orig lbloccup_orig
	replace occup_orig=. if lstatus!=1
	la var occup_orig "Original occupation code"
*</_occup_orig_>

** OCCUPATION CLASSIFICATION
*<_occup_>
	gen occup=int(e7/1000)
	recode occup (0=10)
	recode occup (9=99) if inlist(e7, 9700,9800,9900)
	label var occup "1 digit occupational classification"
	la de occup 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup occup
	replace occup=. if lstatus!=1 
	notes occup: "BTN 2012" ISCO88 is implemented
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
	gen whours=.
	label var whours "Hours of work in last week"
	note whours: "BTN 2012" relevant question not available. Take into account for comparability purposes.
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
*</_unitwage_>


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
	label values unitwage lblunitwage
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
*</_healthins_>

** SOCIAL SECURITY
*<_socialsec_>
	label values healthins lblhealthins
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

	gen byte landphone=.
	label var landphone "Household has landphone"
	la de lbllandphone 0 "No" 1 "Yes"
	label values landphone lbllandphone
	notes landphone: "BTN 2012" relevant question not available on this round, due to changes in questionnaire
*</_landphone_>


** CEL PHONE
*<_cellphone_>
	gen cellphone=. 
	label var cellphone "Household has Cell phone"
	la de lblcellphone 0 "No" 1 "Yes"
	label values cellphone lblcellphone
	notes cellphone: "BTN 2012" this variable may not be comparable nor added across years due to changes in questionnaire.
*</_cellphone_>


** COMPUTER
*<_computer_>
	label var computer "Household has computer"
	la de lblcomputer 0 "No" 1 "Yes"
	label values computer lblcomputer
*</_computer_>

** RADIO
*<_radio_>
	label var radio "Household has radio"
	la de lblradio 0 "No" 1 "Yes"
	label val radio lblradio
*</_radio_>

** TELEVISION
*<_television_>
	gen television=  as121==1 |  as121==2 if !mi(as121)
	label var television "Household has Television"
	la de lbltelevision 0 "No" 1 "Yes"
	label val television lbltelevision
*</_television>

** FAN
*<_fan_>
	label var fan "Household has Fan"
	la de lblfan 0 "No" 1 "Yes"
	label val fan lblfan
*</_fan>

** SEWING MACHINE
*<_sewingmachine_>
	gen sewingmachine=as118==1 | as118==2 if !mi(as118)
	label var sewingmachine "Household has Sewing machine"
	la de lblsewingmachine 0 "No" 1 "Yes"
	label val sewingmachine lblsewingmachine
*</_sewingmachine>

** WASHING MACHINE
*<_washingmachine_>
	gen washingmachine=as115==1 | as115==2 if !mi(as115)
	label var washingmachine "Household has Washing machine"
	la de lblwashingmachine 0 "No" 1 "Yes"
	label val washingmachine lblwashingmachine
*</_washingmachine>

** REFRIGERATOR
*<_refrigerator_>
	gen refrigerator= as111==1 |  as111==2 if !mi(as111)
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
	gen bicycle=  as123==1 |  as123==2 if !mi(as123)
	label var bicycle "Household has Bicycle"
	la de lblbycicle 0 "No" 1 "Yes"
	label val bicycle lblbycicle
*</_bycicle>

** MOTORCYCLE
*<_motorcycle_>
	gen motorcycle=as13==1 | as13==2 if !mi(as13)
	label var motorcycle "Household has Motorcycle"
	la de lblmotorcycle 0 "No" 1 "Yes"
	label val motorcycle lblmotorcycle
*</_motorcycle>

** MOTOR CAR
*<_motorcar_>
	gen motorcar= as19==1 |  as19==2 if !mi(as19)
	label var motorcar "Household has Motor car"
	la de lblmotorcar 0 "No" 1 "Yes"
	label val motorcar lblmotorcar
*</_motorcar>

** COW
*<_cow_>
	gen cow= as23>0 if  as23<.
	label var cow "Household has Cow"
	la de lblcow 0 "No" 1 "Yes"
	label val cow lblcow
*</_cow>

** BUFFALO
*<_buffalo_>
	gen buffalo=as27>0 if as27<.
	label var buffalo "Household has Buffalo"
	la de lblbuffalo 0 "No" 1 "Yes"
	label val buffalo lblbuffalo
*</_buffalo>

** CHICKEN
*<_chicken_>
	drop chicken
	gen chicken=.
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

	gen spdef=reg_deflator
	la var spdef "Spatial deflator"
*</_spdef_>


** WELFARE
*<_welfare_>
	gen welfare=pce_real
	la var welfare "Welfare aggregate"
*</_welfare_>

*<_welfarenom_>
	gen welfarenom=pce
	la var welfarenom "Welfare aggregate in nominal terms"
*</_welfarenom_>

*<_welfaredef_>
	gen welfaredef=pce_real
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
	levelsof year, loc(y)
	merge m:1 idh using "$shares\\BTN_fnf_`y'", keepusing (food_share nfood_share quintile_cons_aggregate decile_cons_aggregate)
	drop _merge

/*****************************************************************************************************
*                                                                                                    *
                                   NATIONAL POVERTY
*                                                                                                    *
*****************************************************************************************************/


** POVERTY LINE (NATIONAL)
*<_pline_nat_>
	ren totpovline pline_nat
	label variable pline_nat "Poverty Line (National)"
*</_pline_nat_>


** HEADCOUNT RATIO (NATIONAL)
*<_poor_nat_>
	gen poor_nat=welfarenat<pline_nat if welfaredef!=.
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

	keep countrycode year survey idh idp wgt pop_wgt strata psu vermast veralt urban int_month int_year subnatid0 ///
		subnatid1 subnatid2 subnatid3 gaul_adm1_code ownhouse landholding tenure water_orig piped_water water_jmp sar_improved_water  electricity toilet_orig sewage_toilet toilet_jmp sar_improved_toilet  landphone cellphone ///
		water_original water_source improved_water pipedwater_acc watertype_quest sanitation_original sanitation_source improved_sanitation toilet_acc ///
	     computer internet hsize relationharm relationcs male age soc marital ed_mod_age everattend ///
	     atschool electricity literacy educy educat4 educat5 educat7 lb_mod_age lstatus lstatus_year empstat empstat_year njobs njobs_year ///
	     ocusec nlfreason unempldur_l unempldur_u industry_orig industry occup_orig occup firmsize_l firmsize_u whours wage ///
		  unitwage empstat_2 empstat_2_year industry_2 industry_orig_2 occup_2 wage_2 unitwage_2 contract healthins socialsec union rbirth_juris rbirth rprevious_juris rprevious yrmove ///
		 landphone cellphone computer radio television fan sewingmachine washingmachine refrigerator lamp bicycle motorcycle motorcar cow buffalo chicken  ///
		 pline_nat pline_int poor_nat poor_int spdef cpi ppp cpiperiod welfare welfshprosperity  welfarenom welfaredef welfarenat food_share nfood_share quintile_cons_aggregate decile_cons_aggregate welfareother welfaretype welfareothertype  
		 
** ORDER VARIABLES

	order countrycode year survey idh idp wgt pop_wgt strata psu vermast veralt urban int_month int_year subnatid0  ///
		subnatid1 subnatid2 subnatid3 gaul_adm1_code ownhouse landholding tenure water_orig piped_water water_jmp sar_improved_water ///
		water_original water_source improved_water pipedwater_acc watertype_quest electricity toilet_orig sewage_toilet ///
		toilet_jmp sar_improved_toilet sanitation_original sanitation_source improved_sanitation toilet_acc landphone cellphone ///
	     computer internet hsize relationharm relationcs male age soc marital ed_mod_age everattend ///
	     atschool electricity literacy educy educat4 educat5 educat7 lb_mod_age lstatus lstatus_year empstat empstat_year njobs njobs_year ///
	     ocusec nlfreason unempldur_l unempldur_u industry_orig industry occup_orig occup firmsize_l firmsize_u whours wage ///
		  unitwage empstat_2 empstat_2_year industry_2 industry_orig_2 occup_2 wage_2 unitwage_2 contract healthins socialsec union rbirth_juris rbirth rprevious_juris rprevious yrmove ///
		 landphone cellphone computer radio television fan sewingmachine washingmachine refrigerator lamp bicycle motorcycle motorcar cow buffalo chicken  ///
		 pline_nat pline_int poor_nat poor_int spdef cpi ppp cpiperiod welfare welfshprosperity  welfarenom welfaredef welfarenat food_share nfood_share quintile_cons_aggregate decile_cons_aggregate welfareother welfaretype welfareothertype  
	
	
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
	
	keep countrycode year survey idh idp wgt pop_wgt strata psu vermast veralt ${keep} *type

	compress

	saveold "`output'\Data\Harmonized\BTN_2012_BLSS_v01_M_v06_A_SARMD_IND.dta", replace version(12)
	saveold "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\BTN_2012_BLSS_v01_M_v06_A_SARMD_IND.dta", replace version(12)

	notes
	log close




******************************  END OF DO-FILE  *****************************************************/
