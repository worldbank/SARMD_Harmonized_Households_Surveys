/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                                   SOUTH ASIA MICRO DATABASE                                      **
**                                                                                                  **
** COUNTRY			BHUTAN
** COUNTRY ISO CODE	BTN
** YEAR				2017
** SURVEY NAME		BHUTAN LIVING STANDARD SURVEY (BLSS) 2017
** SURVEY AGENCY	NATIONAL STATISTICAL BUREAU
** RESPONSIBLE		Cristobal Bennett
** MODFIED BY		Cristobal Bennett
** Date				5/22/2018

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
	local input "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\BTN\BTN_2012_BLSS\BTN_2017_BLSS_v01_M"
	local output "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\BTN\BTN_2012_BLSS\BTN_2017_BLSS_v01_M_v01_A_SARMD"
	glo pricedata "D:\SOUTH ASIA MICRO DATABASE\CPI\cpi_ppp_sarmd_weighted.dta"
	glo shares "D:\SOUTH ASIA MICRO DATABASE\APPS\DATA CHECK\Food and non-food shares\BTN"
	glo fixlabels "D:\SOUTH ASIA MICRO DATABASE\APPS\DATA CHECK\Label fixing"
	local path "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\BTN\BTN_2017_BLSS\BTN_2017_BLSS_v01_M_v01_A_SARMD\Data"

** LOG FILE
	*log using "`output'\Doc\Technical\BTN_2012_BLSS_v01_M_v05_A_SARMD.log",replace

/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/


** DATABASE ASSEMBLENT

	use "`path'\Original\interview_actions.dta", clear
	keep if Action=="Completed"
	gen day=date(Date,"MDY")
	bys Int: egen maxdate=max(day)
	keep if day==maxdate
	keep Int Date
	rename InterviewId houseid
	duplicates drop houseid, force
	tempfile date
	save `date', replace

	use "`path'\Original\hhroster.dta"
	rename (ParentId1 Id) (Id pid)
	merge m:1 Id using "`path'\Original\version 2 bhutan living standard survey 2017 final.dta"
	drop if _m==2
	drop _m
	rename Id houseid
	merge m:1 houseid using "`path'\Original\poverty_estimate_CPI.dta"
	drop if _m==2
	drop _m
	merge m:1 houseid using "`path'\Original\psu.dta"
	drop if _m==2
	drop _m
	merge m:1 houseid using `date'
	drop if _m==2
	

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
	gen int year=2017
	label var year "Year of survey"
*</_year_>

** SURVEY NAME 
*<_survey_>
	gen str survey="BLSS"
	label var survey "Survey Acronym"
*</_survey_>


** INTERVIEW YEAR
*<_int_year_>
	gen int int_year=2017
	label var int_year "Year of the interview"
*</_int_year_>
	
	
** INTERVIEW MONTH
*<_int_month_>
	gen int_month=substr(Date,1,2)
	destring int_month, replace
	la de lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value int_month lblint_month
	label var int_month "Month of the interview"
*</_int_month_>

	
** HOUSEHOLD IDENTIFICATION NUMBER
*<_idh_>
	gen idh=houseid
	label var idh "Household id"
*</_idh_>


** INDIVIDUAL IDENTIFICATION NUMBER
*<_idp_>

	egen idp=concat(idh pid), p(-)
	label var idp "Individual id"
*</_idp_>


** HOUSEHOLD WEIGHTS
*<_wgt_>
	bys idh: gen double wgt=popweight/_N
	label var wgt "Household sampling weight"
*</_wgt_>


** STRATA
*<_strata_>
	gen strata=HH1
	label var strata "Strata"
*</_strata_>


** PSU
*<_psu_>
	*gen psu=psu_num
	label var psu "Primary sampling units"
*</_psu_>

	
** MASTER VERSION
*<_vermast_>

	gen vermast="01"
	label var vermast "Master Version"
*</_vermast_>
	
	
** ALTERATION VERSION
*<_veralt_>

	gen veralt="01"
	label var veralt "Alteration Version"
*</_veralt_>	
	
	
/*****************************************************************************************************
*                                                                                                    *
                                   HOUSEHOLD CHARACTERISTICS MODULE
*                                                                                                    *
*****************************************************************************************************/


** LOCATION (URBAN/RURAL)
*<_urban_>
	*gen byte urban=urbrur
	label var urban "Urban/Rural"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban
*</_urban_>


** MACRO REGIONAL AREA
*<_subnatid0_>
	gen subnatid0=HH1+10
	recode subnatid0 (24 18 15 22 12 20 14 = 1) (29 13 28 = 2) (16 17 19 21 25 26 = 3) (11 23 27 30=4)
	la de lblsubnatid0 1 "Western" 2 "Central" 3 "Eastern" 4 "Southern"
	label values subnatid0 lblsubnatid0
	label values subnatid0 lblsubnatid0
	notes subnatid0: "BTN 2012" refer to technical doc for detail on classification
	label var subnatid0 "Macro regional areas"
*</_subnatid0_>
	
** REGIONAL AREA 1 DIGIT ADMN LEVEL
*<_subnatid1_>
	gen subnatid1=HH1+10
	recode subnatid1 (11=21) (12=11) (13=44) (14=16) (15=12) (16=31) (17=32) (18=13) (19=35) (20=15) (21=36) (22=41) (23=42) (24=14) (25=33) (26=34) (27=22) (28=43) (29=17) (30=23)
	la de lblsubnatid1 11"Chukha" 12"Ha" 13"Paro" 14"Thimphu" 15"Punakha" 16"Gasa" ///
	17 "Wangdi Phodrang" 21"Bumthang" 22"Trongsa" 23"Zhemgang" 31"Lhuntshi" 32"Mongar" ///
	33"Trashigang" 34 "Tashi Yangtse" 35"Pemagatshel" 36"Samdrup Jongkhar" 41"Samtse" ///
	42"Sarpang" 43"Tsirang" 44"Dagana"
	label var subnatid1 "Regional at 1 digit (ADMN1)"
	label values subnatid1 lblsubnatid1
*</_subnatid1_>

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
	gen byte ownhouse=HS2
	recode ownhouse 2=0
	label var ownhouse "House ownership"
	la de lblownhouse 0 "No" 1 "Yes"
	label values ownhouse lblownhouse
*</_ownhouse_>


** TENURE OF DWELLING
*<_tenure_>
   gen tenure=.
   replace tenure=1 if HS2==1
   replace tenure=2 if HS2==2 & (  HS3==1 | HS3==2)
   replace tenure=3 if  HS3==3 &  HS2!=1
   label var tenure "Tenure of Dwelling"
   la de lbltenure 1 "Owner" 2"Renter" 3"Other"
   la val tenure lbltenure
   *</_tenure_>	


** LANDHOLDING
*<_lanholding_>
   gen landholding=AS13__1==1 | AS13__2==1 | AS13__3==1
   replace landholding=. if AS13__1<0 & AS13__2<0 & AS13__3<0
   label var landholding "Household owns any land"
   la de lbllandholding 0 "No" 1 "Yes"
   la val landholding lbllandholding
   notes landholding: "BTN 2017" this variable was generated if  hh owned either wet, dry or or orchard land
*</_tenure_>	

*ORIGINAL WATER CATEGORIES
*<_water_orig_>
gen water_orig=HS16 if HS16>0
la var water_orig "Source of Drinking Water-Original from raw file"
#delimit
la def lblwater_orig 1 "Pipe in dwelling"
					 2 "Pipe in compound"
					 3 "Neighbour's pipe"
					 4 "Public outdoor tap"
					 5 "Protected well"
					 6 "Unprotected well"
					 7 "Protected spring"
					 8 "Unprotected spring"
					 9 "Rain water collection"
					 10 "Tanker truck"
					 11 "Cart with small tank/drum"
					 12 "Surface water (river, stream, dam, lake, pond, canal, irrigation channel)"
					 13 "Bottled water"
					 14 "Other";
#delimit cr
la val water_orig lblwater_orig
*</_water_orig_>


*ORIGINAL WATER CATEGORIES
*<_water_original_>
clonevar j=HS16 if HS16>0
#delimit
la def lblwater_original 1 "Pipe in dwelling"
					 2 "Pipe in compound"
					 3 "Neighbour's pipe"
					 4 "Public outdoor tap"
					 5 "Protected well"
					 6 "Unprotected well"
					 7 "Protected spring"
					 8 "Unprotected spring"
					 9 "Rain water collection"
					 10 "Tanker truck"
					 11 "Cart with small tank/drum"
					 12 "Surface water (river, stream, dam, lake, pond, canal, irrigation channel)"
					 13 "Bottled water"
					 14 "Other";
#delimit cr
la val j lblwater_original		
decode j, gen(water_original)
drop j
la var water_original "Source of Drinking Water-Original from raw file"
*</_water_original_>

				   
	** WATER SOURCE
	*<_water_source_>
		gen water_source=.
		replace water_source=1 if HS16==1
		replace water_source=2 if inlist(HS16,2,3)
		replace water_source=3 if HS16==4
		replace water_source=5 if HS16==5
		replace water_source=10 if HS16==6
		replace water_source=6 if HS16==7
		replace water_source=9 if HS16==8
		replace water_source=8 if HS16==9
		replace water_source=12 if HS16==10
		replace water_source=11 if HS16==11
		replace water_source=13 if HS16==12
		replace water_source=7 if HS16==13
		replace water_source=14 if HS16==14
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
	/* WASH team: Replace cart and tanker truck as improved */
		replace improved_water=1 if HS16==10 | HS16==11
	*</_improved_water_>



	** PIPED SOURCE OF WATER ACCESS
	*<_pipedwater_acc_>
		gen pipedwater_acc=0 if inrange(HS16,3,13) // Asuming other is not piped water
		replace pipedwater_acc=3 if inlist(HS16,1,2)
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
gen piped_water=HS16 if HS16>0
recode piped_water (2=1) (3/13=0) 
la var piped_water "Household has access to piped water"
la def lblpiped_water 1 "Yes" 0 "No"
la val piped_water lblpiped_water
*</_piped_water_>


**INTERNATIONAL WATER COMPARISON (Joint Monitoring Program)
*<_water_jmp_>
gen water_jmp=HS16 if HS16>0
recode water_jmp 3=2 4=3
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
replace sar_improved_water=1 if inlist(HS16,1,2,3,4,5,7,9)
replace sar_improved_water=0 if inlist(HS16,6,8,10,11,12,13,14) 
la def lblsar_improved_water 1 "Improved" 0 "Unimproved"
la var sar_improved_water "Improved source of drinking water-using country-specific definitions"
la val sar_improved_water lblsar_improved_water
*</_sar_improved_water_>


** ELECTRICITY PUBLIC CONNECTION
*<_electricity_>
	gen byte electricity=HS25 if HS25>0
	recode electricity 1 3/4=0 2=1
	label var electricity "Electricity main source"
	la de lblelectricity 0 "No" 1 "Yes"
	label values electricity lblelectricity
*</_electricity_>

*ORIGINAL TOILET CATEGORIES
*<_toilet_orig_>
gen toilet_orig=HS21 if HS21>0
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
					  11 "Composting toilet/Ecosan"
					  12 "Bucket"
					  13 "No facility/Bush/Field";
#delimit cr
la val toilet_orig lbltoilet_orig
*</_toilet_orig_>


*SEWAGE TOILET
*<_sewage_toilet_>
gen sewage_toilet=HS21 if HS21>0
recode sewage_toilet 2/13=0
la var sewage_toilet "Household has access to sewage toilet"
la def lblsewage_toilet 1 "Yes" 0 "No"
la val sewage_toilet lblsewage_toilet
*</_sewage_toilet_>


**INTERNATIONAL SANITATION COMPARISON (Joint Monitoring Program)
*<_toilet_jmp_>
gen toilet_jmp=HS21 if HS21>0
recode toilet_jmp 2 3=2 4=3 5=4 6=5 7=6 8=7 9=8 10=11 11=9 12=10 13=12 
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
replace sar_improved_toilet=1 if inlist(HS21,1,2,3,4,7,8,11)
replace sar_improved_toilet=0 if inlist(HS21,5,6,9,10,12,13)
replace sar_improved_toilet=0 if HS22==1
la def lblsar_improved_toilet 1 "Improved" 0 "Unimproved"
la var sar_improved_toilet "Improved type of sanitation facility-using country-specific definitions"
la val sar_improved_toilet lblsar_improved_toilet
*</_sar_improved_toilet_>


	** ORIGINAL SANITATION CATEGORIES 
	*<_sanitation_original_>
		clonevar j=HS21 if HS21>0
		#delimit
		la def lblsanitation_original   1 "Flush to piped sewer system"
										2 "Flush to septic tank (without soak pit)"
										3 "Flush to septic tank (with soak pit)"
										4 "Flush to pit (latrine)"
										5 "Flush to somewhere else"
										6 "Flush to unkown place/Not sure/Don't know"
										7 "Ventilated improved pit"
										8 "Pit latrine with slab"
										9 "Pit latrine without a slap/open pit"
										10 "Long drop latrine"
										11 "Composting toilet/Ecosan"
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
		replace sanitation_source=2 if HS21==1
		replace sanitation_source=3 if HS21==2
		replace sanitation_source=3 if HS21==3
		replace sanitation_source=4 if HS21==4
		replace sanitation_source=9 if HS21==5
		replace sanitation_source=9 if HS21==6
		replace sanitation_source=5 if HS21==7
		replace sanitation_source=6 if HS21==8
		replace sanitation_source=10 if HS21==9
		replace sanitation_source=12 if HS21==10
		replace sanitation_source=7 if HS21==11
		replace sanitation_source=11 if HS21==12
		replace sanitation_source=13 if HS21==13
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
	/* WASH team: Replace flush to somewhere else and flush to unknown place as improved */
		replace improved_sanitation=1 if HS21==5 | HS21==6
		replace improved_sanitation=0 if HS22==1
		replace improved_sanitation=0 if HS23==2
		replace improved_sanitation=0 if HS23==1
	*</_improved_sanitation_>
	

	** ACCESS TO FLUSH TOILET
	*<_toilet_acc_>
		gen toilet_acc=3 if inrange(HS21,1,6)
		replace toilet_acc=0 if inrange(HS21,7,13)
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
	gen byte internet=(HS14==1) if HS14>0
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
	*bys idh: egen hsize=count(year)
	label var hsize "Household size"
*</_hsize_>

**POPULATION WEIGHT
*<_pop_wgt_>
	gen pop_wgt=popweight
	la var pop_wgt "Population weight"
*</_pop_wgt_>

** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
*<_relationharm_>
	gen byte relationharm=role
	recode relationharm 11=4 5/10 12=5 13/14=6
	replace ownhouse=. if relationharm==6
	label var relationharm "Relationship to the head of household"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Non-relatives"
	label values relationharm  lblrelationharm
*</_relationharm_>

** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
*<_relationcs_>

	gen byte relationcs=role
	la var relationcs "Relationship to the head of household country/region specific"
	label define lblrelationcs 1 "Self(head)" 2 "Wife/Husband/Partner" 3 "Son/daughter" 4 "Father/Mother" 5 "Sister/Brother" 6 "Grandfather/Grandmother" 7 "Grandchild" 8 "Niece/nephew" 9 "Son-in-law/daughter-in-law" 10 "Brother-in-law/sister-in-law" 11 "Father-in-law/mother-in-law" 12 "Other family relative" 13 "Live-in-servant" 14 "Other-non-relative"
	label values relationcs lblrelationcs
*</_relationcs_>


** GENDER
*<_male_>
	gen male=sex
	recode male (2=0) 
	label var male "Sex of household member"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale
*</_male_>


** AGE
*<_age_>
	*gen age=.
	replace age=98 if age>=98 & age!=.
	label var age "Age of individual"
*</_age_>


** SOCIAL GROUP
*<_soc_>
	gen byte soc=D6 if D6>0
	label var soc "Social group"
	la de lblsoc 1 "Bhutanese" 2 "Other"
	label values soc lblsoc
	notes soc: "BTN 2017" this variable has "nationality"
*</_soc_>


** MARITAL STATUS
*<_marital_>
	gen byte marital=D4 if D4>0
	recode marital 1=2 2=3 3=1 5=4 6=5
	label var marital "Marital status"
	la de lblmarital 1 "Married" 2 "Never Married" 3 "Living Together" 4 "Divorced/separated" 5 "Widowed"
	label values marital lblmarital
*</_marital_>


/*****************************************************************************************************
*                                                                                                    *
                                   DISABILITY MODULE
*                                                                                                    *
*****************************************************************************************************/

label define eye_disability_label 1 "No – no difficulty"  2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all"
label define hear_disability_label 1 "No – no difficulty"  2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all"
label define walk_disability_label 1 "No – no difficulty"  2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all"
label define conc_disability_label 1 "No – no difficulty"  2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all"
label define slfcre_disability_label 1 "No – no difficulty"  2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all"
label define comm_disability_label 1 "No – no difficulty"  2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all"

** 1. Do you have difficulty seeing, even if wearing glasses?	
	gen eye_dsablty = H17
	label values eye_dsablty eye_disability_label
	label var eye_dsablty "eye_dsablty is a numerical variable that indicates whether an individual has any difficulty in seeing, even when wearing glasses."

** 2. Do you have difficulty hearing, even if using a hearing aid?	
	gen hear_dsablty = H18
	label values hear_dsablty hear_disability_label
	label var hear_dsablty "hear_dsablty is a numerical variable that indicates whether an individual has any difficulty in hearing even when using a hearing aid."

** 3. Do you have difficulty walking or climbing steps?	
	gen walk_dsablty = H19
	label values walk_dsablty walk_disability_label
	label var walk_dsablty "walk_dsablty is a numerical variable that indicates whether an individual has any difficulty in walking or climbing steps."

** 4. Do you have difficulty remembering or concentrating?	
	gen conc_dsord = H20
	label values conc_dsord conc_disability_label
	label var conc_dsord "conc_dsord is a numerical variable that indicates whether an individual has any difficulty concentrating or remembering."

** 5. Do you have difficulty (with self-care such as) washing all over or dressing?	
	gen slfcre_dsablty = H21 
	label values slfcre_dsablty slfcre_disability_label
	label var slfcre_dsablty "slfcre_dsablty is a numerical variable that indicates whether an individual has any difficulty with self-care such as washing all over or dressing."

** 6. Using your usual (customary) language, do you have difficulty communicating, for example understanding or being understood?
	gen comm_dsablty = H22
	label values comm_dsablty comm_disability_label
	label var comm_dsablty "comm_dsablty is a numerical variable that indicates whether an individual has any difficulty communicating or understanding usual (customary) language."

replace eye_dsablty=. if eye_dsablty != 1 & eye_dsablty != 2 & eye_dsablty != 3 & eye_dsablty != 4
replace hear_dsablty=. if hear_dsablty != 1 & hear_dsablty != 2 & hear_dsablty != 3 & hear_dsablty != 4
replace walk_dsablty=. if walk_dsablty != 1 & walk_dsablty != 2 & walk_dsablty != 3 & walk_dsablty != 4
replace conc_dsord=. if conc_dsord != 1 & conc_dsord != 2 & conc_dsord != 3 & conc_dsord != 4
replace slfcre_dsablty=. if slfcre_dsablty != 1 & slfcre_dsablty != 2 & slfcre_dsablty != 3 & slfcre_dsablty != 4
replace comm_dsablty=. if comm_dsablty != 1 & comm_dsablty != 2 & comm_dsablty != 3 & comm_dsablty != 4

/*****************************************************************************************************
*                                                                                                    *
                                   EDUCATION MODULE
*                                                                                                    *
*****************************************************************************************************/


** EDUCATION MODULE AGE
*<_ed_mod_age_>
	gen ed_mod_age=2
	label var ed_mod_age "Education module application age"
*</_ed_mod_age_>


** EVER ATTENDED SCHOOL
*<_everattend_>
	gen byte everattend=ED2
	recode everattend 2=1 3=0
	replace everattend=. if age<ed_mod_age 
	label var everattend "Ever attended school"
	la de lbleverattend 0 "No" 1 "Yes"
	label values everattend lbleverattend
	notes everattend: "BTN 2012" this variable includes people with no education and/or pre-primary education
*</_everattend_>



** CURRENTLY AT SCHOOL
*<_atschool_>
	gen byte atschool=ED2
	recode  atschool 2/3=0
	replace atschool=. if age<ed_mod_age 
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool
	notes atschool: "BTN 2012" this variable includes people with no education and/or pre-primary education
*</_atschool_>


** CAN READ AND WRITE
*<_literacy_>
	gen byte literacy=inlist(1,ED1__1,ED1__2,ED1__3,ED1__4)
	replace literacy=. if age<ed_mod_age
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
*</_literacy_>


** YEARS OF EDUCATION COMPLETED
*<_educy_>
	gen educy1=ED3
	gen educy2=ED11
	recode educy1 13/16=14 17=14 18=16 19=18 20/21=0
	recode educy2 13/16=14 17=15 18=17 20/21=0
	gen educy=educy1
	replace educy=0 if ED2==3
	replace educy=educy2 if educy2!=.
	replace educy=. if age<ed_mod_age | age-educy1<5
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
	replace edulevel1=6 if inlist(ED3,13,16) | inlist(ED11,13,16)
	replace edulevel1=8 if inlist(20,ED3,ED11) |  inlist(21,ED3,ED11)
	replace edulevel1=. if age<ed_mod_age & age!=.
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
	gen byte lstatus=1 if inlist(1,E1,E4) | E1==2
	replace lstatus=2 if E10==1 & lstatus==.
	replace lstatus=3 if E10==2 & lstatus==.
	replace lstatus=. if age<lb_mod_age & age!=.
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
	gen byte empstat=E7
	recode empstat 2=1 5=2 6=5
	replace empstat=. if lstatus!=1
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
	gen byte nlfreason=E1
	recode nlfreason 3=1 5=2 6=4 7=3 4 8=5
	replace nlfreason=. if lstatus!=3
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
	gen industry_orig=E6 if E6>0
	la val industry_orig lblindustry_orig
	replace industry_orig=. if lstatus!=1
	la var industry_orig "Original industry code"
*</_industry_orig_>


** INDUSTRY CLASSIFICATION
*<_industry_>
	gen byte industry=floor(E6/100) if E6>0
	recode industry 0=. 1/3=1 4/5=2 6/22=3 23/25=4 26/27=5 28/30 34/35 47=6 31/33 36/39=7 40/46 48/53=8 54/55=9 56/97=10
	replace industry=1 if E1==1
	replace industry=. if lstatus!=1
	label var industry "1 digit industry classification"
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industry lblindustry
	notes industry: "BTN 2012" no relevant question for creating variable, compared with previous rounds. Take into account for comparability purposes
*</_industry_>

**ORIGINAL OCCUPATION CLASSIFICATION
*<_occup_orig_>
	gen occup_orig=E9 if E9>0
	replace occup_orig=. if lstatus!=1
	la var occup_orig "Original occupation code"
*</_occup_orig_>

** OCCUPATION CLASSIFICATION
*<_occup_>
	gen aux=floor(E9/100) 
	gen byte occup=floor(E9/1000) if E9>0
	replace occup=6 if occup==0
	replace occup=10 if inlist(aux,10,20)
	replace occup=5 if aux==14
	replace occup=. if lstatus!=1
	label var occup "1 digit occupational classification"
	la de occup 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup occup
	replace occup=. if lstatus!=1 
	notes occup: "BTN 2017" Own classification, similar to ISCO
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
	gen byte cellphone=(HS13>1) if HS13>=0
	label var cellphone "Household has Cell phone"
	la de lblcellphone 0 "No" 1 "Yes"
	label values cellphone lblcellphone
	notes cellphone: "BTN 2012" this variable may not be comparable nor added across years due to changes in questionnaire.
*</_cellphone_>


** COMPUTER
*<_computer_>
	gen byte computer=AS2__10 if AS2__10>=0
	label var computer "Household has computer"
	la de lblcomputer 0 "No" 1 "Yes"
	label values computer lblcomputer
*</_computer_>

** RADIO
*<_radio_>
	gen byte radio=AS1__8 if AS1__8>=0
	label var radio "Household has radio"
	la de lblradio 0 "No" 1 "Yes"
	label val radio lblradio
*</_radio_>

** TELEVISION
*<_television_>
	gen byte television=AS2__18 if AS2__18>=0
	label var television "Household has Television"
	la de lbltelevision 0 "No" 1 "Yes"
	label val television lbltelevision
*</_television>

** FAN
*<_fan_>
	gen byte fan=AS2__7 if AS2__7>=0
	label var fan "Household has Fan"
	la de lblfan 0 "No" 1 "Yes"
	label val fan lblfan
*</_fan>

** SEWING MACHINE
*<_sewingmachine_>
	gen byte sewingmachine=AS1__1 if AS1__1>=0
	label var sewingmachine "Household has Sewing machine"
	la de lblsewingmachine 0 "No" 1 "Yes"
	label val sewingmachine lblsewingmachine
*</_sewingmachine>

** WASHING MACHINE
*<_washingmachine_>
	gen byte washingmachine=AS2__13 if AS2__13>=0
	label var washingmachine "Household has Washing machine"
	la de lblwashingmachine 0 "No" 1 "Yes"
	label val washingmachine lblwashingmachine
*</_washingmachine>

** REFRIGERATOR
*<_refrigerator_>
	gen byte refrigerator=AS2__11 if AS2__11>=0
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
	gen bicycle=AS1__3 if AS1__3>=0
	label var bicycle "Household has Bicycle"
	la de lblbycicle 0 "No" 1 "Yes"
	label val bicycle lblbycicle
*</_bycicle>

** MOTORCYCLE
*<_motorcycle_>
	gen motorcycle=AS2__3 if AS2__3>=0
	label var motorcycle "Household has Motorcycle"
	la de lblmotorcycle 0 "No" 1 "Yes"
	label val motorcycle lblmotorcycle
*</_motorcycle>

** MOTOR CAR
*<_motorcar_>
	gen motorcar=AS2__9 if AS2__9>=0
	label var motorcar "Household has Motor car"
	la de lblmotorcar 0 "No" 1 "Yes"
	label val motorcar lblmotorcar
*</_motorcar>

** COW
*<_cow_>
	gen cow=AS9__3 if AS9__3>=0
	label var cow "Household has Cow"
	la de lblcow 0 "No" 1 "Yes"
	label val cow lblcow
*</_cow>

** BUFFALO
*<_buffalo_>
	gen buffalo=AS9__7 if AS9__7>=0
	label var buffalo "Household has Buffalo"
	la de lblbuffalo 0 "No" 1 "Yes"
	label val buffalo lblbuffalo
*</_buffalo>

** CHICKEN
*<_chicken_>
	gen chicken=AS9__8 if AS9__8>=0
	label var chicken "Household has Chicken"
	la de lblchicken 0 "No" 1 "Yes"
	label val chicken lblchicken
*</_chicken>

	
/*****************************************************************************************************
*                                                                                                    *
                                   WELFARE MODULE
*                                                                                                    *
*****************************************************************************************************/
** Auxiliar variable for real food expenditure per capita
	gen aux_pcfe_real=pcfe/paasche
	replace pcnfe_real=. if pcnfe_real<0
	replace pce_real=. if pce_real<0
	replace pce=. if pce<0

** SPATIAL DEFLATOR
*<_spdef_> 
	gen spdef=paasche
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

	**Consumption aggregate
	gen cons_aggregate=pce_real
	la var cons_aggregate "Consupmption aggregate spatially deflated"

	*Add food share
	*gen food_share=(pcfe_real/pce_real)*100
	gen food_share=(aux_pcfe_real/pce_real)*100
	la var food_share "Food share of welfarenat"
	
	**Add non-food share
	gen nfood_share=(pcnfe_real/pce_real)*100
	la var nfood_share "Non-food share of welfarenat"
		
	*Add quintile and decile of consumption aggregate
	xtile quintile_cons_aggregate=cons_aggregate [w=popweight], n(5)
	xtile decile_cons_aggregate=cons_aggregate [w=popweight], n(10)
		la var quintile_cons_aggregate "Quintile of welfarenat"
	la var decile_cons_aggregate "Decile of welfarenat"


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
	/*capture drop _merge
	gen urb=.
	merge m:1 countrycode year urb using "$pricedata", ///
	keepusing(countrycode year urb syear cpi`year'_w ppp`year')
	drop urb
	drop if _merge!=3
	drop _merge*/
	
	
** CPI VARIABLE
	gen cpi=1.4796 
	label variable cpi "CPI (Base `year'=1)"
*</_cpi_>
	
	
** PPP VARIABLE
*<_ppp_>
	gen ppp=16.96291
	label variable ppp "PPP `year'"
*</_ppp_>

	
** CPI PERIOD
*<_cpiperiod_>
	gen cpiperiod="2017M03M06"
	*gen cpiperiod=syear
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
/* fixlabels.do missing*/
	*do "$fixlabels\fixlabels", nostop

	keep countrycode year survey idh idp wgt pop_wgt strata psu vermast veralt urban int_month int_year subnatid0 ///
		subnatid1 subnatid2 subnatid3 ownhouse landholding tenure water_orig piped_water water_jmp sar_improved_water  electricity toilet_orig sewage_toilet toilet_jmp sar_improved_toilet  landphone cellphone ///
		water_original water_source improved_water pipedwater_acc watertype_quest sanitation_original sanitation_source improved_sanitation toilet_acc ///
	     computer internet hsize relationharm relationcs male age soc marital eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty ed_mod_age everattend ///
	     atschool electricity literacy educy educat4 educat5 educat7 lb_mod_age lstatus lstatus_year empstat empstat_year njobs njobs_year ///
	     ocusec nlfreason unempldur_l unempldur_u industry_orig industry occup_orig occup firmsize_l firmsize_u whours wage ///
		  unitwage empstat_2 empstat_2_year industry_2 industry_orig_2 occup_2 wage_2 unitwage_2 contract healthins socialsec union rbirth_juris rbirth rprevious_juris rprevious yrmove ///
		 landphone cellphone computer radio television fan sewingmachine washingmachine refrigerator lamp bicycle motorcycle motorcar cow buffalo chicken  ///
		 pline_nat pline_int poor_nat poor_int spdef cpi ppp cpiperiod welfare welfshprosperity  welfarenom welfaredef welfarenat food_share nfood_share quintile_cons_aggregate decile_cons_aggregate welfareother welfaretype welfareothertype  
		 
** ORDER VARIABLES

	order countrycode year survey idh idp wgt pop_wgt strata psu vermast veralt urban int_month int_year subnatid0  ///
		subnatid1 subnatid2 subnatid3 ownhouse landholding tenure water_orig piped_water water_jmp sar_improved_water ///
		water_original water_source improved_water pipedwater_acc watertype_quest electricity toilet_orig sewage_toilet ///
		toilet_jmp sar_improved_toilet sanitation_original sanitation_source improved_sanitation toilet_acc landphone cellphone ///
	     computer internet hsize relationharm relationcs male age soc marital eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty ed_mod_age everattend ///
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
	
	/*
	foreach w in welfare welfareother {
	
		qui su `w'
		if r(N)==0 {
		
		drop `w'type
		
		}
	}
	*/
	keep countrycode year survey idh idp wgt pop_wgt strata psu vermast veralt ${keep} /**type*/
	drop welfaretype
	compress

	*saveold "`output'\Data\Harmonized\BTN_2012_BLSS_v01_M_v05_A_SARMD_IND.dta", replace version(12)
	*saveold "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\BTN_2012_BLSS_v01_M_v05_A_SARMD_IND.dta", replace version(12)
	save "`path'\Harmonized\BTN_2017_BLSS_v01_M_v01_A_SARMD_IND.dta", replace 
	*notes
	*log close




******************************  END OF DO-FILE  *****************************************************/
