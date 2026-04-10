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
/*
	glo rootdatalib "P:\SARMD\SARDATABANK"
	glo folder "SAR_DATABANK"
** DIRECTORY
	local input "${rootdatalib}\SAR_DATABANK\BTN\BTN_2017_BLSS\BTN_2017_BLSS_v01_M"
	local output "${rootdatalib}\\${folder}\BTN\BTN_2017_BLSS\BTN_2017_BLSS_v01_M_v02_A_SARMD"
	glo pricedata "${rootdatalib}\CPI\cpi_ppp_sarmd_weighted.dta"
	glo shares "${rootdatalib}\APPS\DATA CHECK\Food and non-food shares\BTN"
	glo fixlabels "${rootdatalib}\APPS\DATA CHECK\Label fixing"
	local path "${rootdatalib}\\${folder}\BTN\BTN_2017_BLSS\BTN_2017_BLSS_v01_M_v02_A_SARMD\Data"
	*/
	
glo   cpiver       "v10"
local code         "BTN"
local year         2017
local survey       "BLSS"
local vm           "01"
local va           "03"
local type         "SARMD"
global module       	"IND"
local yearfolder    	"`code'_`year'_`survey'"
local SARMDfolder    	"`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'"
local filename      	"`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'_${module}"
glo output          	"${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\\Data\Harmonized" 
	
	

** LOG FILE
	*log using "`output'\Doc\Technical\BTN_2017_BLSS_v01_M_v05_A_SARMD.log",replace

/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/


** DATABASE ASSEMBLENT

	use "${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M/Data/Stata\interview_actions.dta", clear
	keep if Action=="Completed"
	gen day=date(Date,"MDY")
	bys Int: egen maxdate=max(day)
	keep if day==maxdate
	keep Int Date
	rename InterviewId houseid
	duplicates drop houseid, force
	tempfile date
	save `date'
	
	use "${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M/Data/Stata\hhroster.dta"
	rename (ParentId1 Id) (Id pid)
	merge m:1 Id using "${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M/Data/Stata\version 2 bhutan living standard survey 2017 final.dta"
	drop if _m==2
	drop _m
	rename Id houseid
	merge m:1 houseid using "${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M/Data/Stata\poverty_estimate_CPI.dta"
	drop if _m==2
	drop _m
	merge m:1 houseid using "${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M/Data/Stata\psu.dta"
	drop if _m==2
	drop _m
	merge m:1 houseid using `date'
	drop if _m==2
	
 
/*****************************************************************************************************
*                                                                                                    *
                                   * STANDARD SURVEY MODULE
*                                                                                                    *
*****************************************************************************************************/
numlabel, add

** COUNTRY
*<_countrycode_>
	gen str4 countrycode="`code'"
	label var countrycode "Country code"
*</_countrycode_>

gen code = "`code'"


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

gen month= .
	
** HOUSEHOLD IDENTIFICATION NUMBER
*<_idh_>
	gen hhid=houseid
	clonevar idh = hhid 
*</_idh_>

clonevar idh_org = houseid

** INDIVIDUAL IDENTIFICATION NUMBER
*<_idp_>
rename pid idp_org

	egen idp=concat(hhid idp_org), p(-)
	label var idp "Individual id"
*</_idp_>

clonevar pid = idp 

** HOUSEHOLD WEIGHTS
*<_wgt_>
	bys hhid: gen double wgt=popweight/_N
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
	notes subnatid0: "BTN 2017" refer to technical doc for detail on classification
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
	gen subnatid2=""
	label var subnatid2 "Region at 2 digit (ADMN2)"
*</_subnatid2_>
	
	
** REGIONAL AREA 3 DIGIT ADMN LEVEL
*<_subnatid3_>
	gen subnatid3=""
	label var subnatid3 "Regional at 3 digit (ADMN3)"
*</_subnatid3_>

	gen subnatid4=""
	
	gen subnatid1_sar="" 
gen subnatid2_sar=""
gen subnatid3_sar=""
gen subnatid4_sar=""
	
** HOUSE OWNERSHIP
*<_ownhouse_>
	g		ownhouse = 1 if HS2==1
	replace	ownhouse = 2 if inlist(HS3,1,2)
	replace	ownhouse = 3 if HS3==3
	note ownhouse: For BTN_2017_BLSS, we assumed those who did not own their home (HS2 = 2) AND were not paying rent (HS3 = 3) were provided for free (ownhouse = 3). It could be that they are in the house without permission (ownhouse = 4), but we did not know and categorized all into "provided for free" based on our best guess.
*</_ownhouse_>

gen typehouse=. 

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
	


	gen shared_toilet =.
	replace shared_toilet=1 if HS22==1
	replace shared_toilet=0 if HS22==2
	
	
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
	notes everattend: "BTN 2017" this variable includes people with no education and/or pre-primary education
*</_everattend_>



** CURRENTLY AT SCHOOL
*<_atschool_>
	gen byte atschool=ED2
	recode  atschool 2/3=0
	replace atschool=. if age<ed_mod_age 
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool
	notes atschool: "BTN 2017" this variable includes people with no education and/or pre-primary education
*</_atschool_>


** CAN READ AND WRITE
*<_literacy_>
	gen byte literacy=inlist(1,ED1__1,ED1__2,ED1__3,ED1__4)
	replace literacy=. if age<ed_mod_age
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
*</_literacy_>


** LANGUAGE
*<_language_>
	gen language = ""
	replace language = "Dzongkha" if ED1__1==1 & language==""
	replace language = "Lotsham" if ED1__2==1 & language==""
	replace language = "English" if ED1__3==1 & language==""
	replace language = "Other language" if ED1__4==1 & language==""
*</_language_>


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
	notes ocusec: "BTN 2017" this variable was captured as missing due to lack of relevant question
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
	notes industry: "BTN 2017" no relevant question for creating variable, compared with previous rounds. Take into account for comparability purposes
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
	note whours: "BTN 2017" relevant question not available. Take into account for comparability purposes.
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

gen industry_year=.
gen industry_2_year=.
gen industry_orig_year=.
gen industry_orig_2_year=.
gen occup_year = .
gen ocusec_year =.

*do "$rootdofiles\_aux\Labels_SARMD.do"

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
	notes landphone: "BTN 2017" relevant question not available on this round, due to changes in questionnaire
	rename landphone lphone 
*</_landphone_>


** CEL PHONE
*<_cellphone_>
	gen byte cellphone=(HS13>1) if HS13>=0
	label var cellphone "Household has Cell phone"
	la de lblcellphone 0 "No" 1 "Yes"
	label values cellphone lblcellphone
	notes cellphone: "BTN 2017" this variable may not be comparable nor added across years due to changes in questionnaire.
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

** BICYCLE
*<_bicycle_>
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
                                            ASSETS 
*                                                                                                    *
*****************************************************************************************************/

** LANDPHONE
/*<_landphone_>

                gen byte landphone=.
                label var landphone "Ownership of a land phone"
                la de lbllandphone 0 "No" 1 "Yes"
                label values landphone lbllandphone*/
*</_landphone_>

** CELLPHONE
/*<_cellphone_>

                gen byte cellphone=.
                label var cellphone "Ownership of a cell phone"
                la de lblcellphone 0 "No" 1 "Yes"
                label values cellphone lblcellphone*/
*</_cellphone_>

** PHONE
*<_phone_>

                gen byte phone=.
                label var phone "Ownership of a telephone"
                la de lblphone 0 "No" 1 "Yes"
                label values phone lblphone
*</_phone_>

** COMPUTER
/*<_computer_>

                gen byte computer=.
                label var computer "Ownership of a computer"
                la de lblcomputer 0 "No" 1 "Yes"
                label values computer lblcomputer*/
*</_computer_>

** INTERNET
/*<_internet_>

                gen byte internet=.
                label var internet "Ownership of a  internet"
                la de lblinternet 1 "Subscribed in the house" 2 "Accessible outside the house" 3 "Either" 4 "No internet"
                label values internet lblinternet*/
*</_internet_>

** RADIO
/*<_radio_>

                gen byte radio=.
                label var radio "Ownership of a radio"
                la de lblradio 0 "No" 1 "Yes"
                label values radio lblradio*/
*</_radio_>

** TV
*<_tv_>

                gen byte tv=.
                label var tv "Ownership of a tv"
                la de lbltv 0 "No" 1 "Yes"
                label values tv lbltv
*</_tv_>

** TV_CABLE
*<_tv_cable_>

                gen byte tv_cable=.
                label var tv_cable "Ownership of a cable tv"
                la de lbltv_cable 0 "No" 1 "Yes"
                label values tv_cable lbltv_cable
*</_tv_cable_>

** VIDEO
*<_video_>

                gen byte video=AS1__4 if AS1__4>=0
                label var video "Ownership of a video"
                la de lblvideo 0 "No" 1 "Yes"
                label values video lblvideo
*</_video_>

** FRIDGE
*<_fridge_>

                gen byte fridge=.
                label var fridge "Ownership of a refrigerator"
                la de lblfridge 0 "No" 1 "Yes"
                label values fridge lblfridge
*</_fridge_>

** SEWMACH
*<_sewmach_>

                gen byte sewmach=.
                label var sewmach "Ownership of a sewing machine"
                la de lblsewmach 0 "No" 1 "Yes"
                label values sewmach lblsewmach
*</_sewmach_>

** WASHMACH
*<_washmach_>

                gen byte washmach=.
                label var washmach "Ownership of a washing machine"
                la de lblwashmach 0 "No" 1 "Yes"
                label values washmach lblwashmach
*</_washmach_>

** STOVE
*<_stove_>

                gen byte stove=AS1__12 if AS1__12>=0
                label var stove "Ownership of a stove"
                la de lblstove 0 "No" 1 "Yes"
                label values stove lblstove
*</_stove_>

** RICECOOK
*<_ricecook_>

                gen byte ricecook=.
                label var ricecook "Ownership of a rice cooker"
                la de lblricecook 0 "No" 1 "Yes"
                label values ricecook lblricecook
*</_ricecook_>

** FAN
/*<_fan_>

                gen byte fan=.
                label var fan "Ownership of an electric fan"
                la de lblfan 0 "No" 1 "Yes"
                label values fan lblfan*/
*</_fan_>

** AC
*<_ac_>

                gen byte ac=.
                label var ac "Ownership of a central or wall air conditioner"
                la de lblac 0 "No" 1 "Yes"
                label values ac lblac
*</_ac_>
	
** ETABLET
*<_etablet_>

                gen byte etablet=AS2__21 if AS2__21>=0
                label var etablet "Ownership of a electronic tablet"
                la de lbletablet 0 "No" 1 "Yes"
                label values etablet lbletablet
*</_etablet_>

** EWPUMP
*<_ewpump_>

                gen byte ewpump=.
                label var ewpump "Ownership of a electric water pump"
                la de lblewpump 0 "No" 1 "Yes"
                label values ewpump lblewpump
*</_ewpump_>

** BCYCLE
*<_bcycle_>

                gen byte bcycle=.
                label var bcycle "Ownership of a bicycle"
                la de lblbcycle 0 "No" 1 "Yes"
                label values bcycle lblbcycle
*</_bcycle_>

** MCYCLE
*<_mcycle_>

                gen byte mcycle=.
                label var mcycle "Ownership of a motorcycle"
                la de lblmcycle 0 "No" 1 "Yes"
                label values mcycle lblmcycle
*</_mcycle_>

** OXCART
*<_oxcart_>

                gen byte oxcart=.
                label var oxcart "Ownership of a oxcart"
                la de lbloxcart 0 "No" 1 "Yes"
                label values oxcart lbloxcart
*</_oxcart_>

** BOAT
*<_boat_>

                gen byte boat=.
                label var boat "Ownership of a boat"
                la de lblboat 0 "No" 1 "Yes"
                label values boat lblboat
*</_boat_>

** CAR
*<_car_>

                gen byte car=.
                label var car "Ownership of a Car"
                la de lblcar 0 "No" 1 "Yes"
                label values car lblcar
*</_car_>

** CANOE
*<_canoe_>

                gen byte canoe=.
                label var canoe "Ownership of a canoes"
                la de lblcanoe 0 "No" 1 "Yes"
                label values canoe lblcanoe
*</_canoe_>

** ROOF
*<_roof_>

                gen byte roof=HS10
				recode roof (1=31) (2=34) (3=33) (4=12) (5=36) (6=96) 
                label var roof "Main material used for roof"
				#delimit
                la de lblroof 12 "Natural – Thatch/palm leaf" 13 "Natural – Sod" 14 "Natural – Other" 
								21 "Rudimentary – Rustic mat" 22 "Rudimentary – Palm/bamboo" 23 "Rudimentary – Wood planks" 
								24 "Rudimentary – Other" 31 "Finished – Roofing" 32 "Finished – Asbestos" 33 "Finished – Tile" 
								34 "Finished – Concrete" 35 "Finished – Metal tile" 36 "Finished – Roofing shingles" 
								37 "Finished – Other" 96 "Other – “Specific”";
                #delimit cr                
				label values roof lblroof
*</_roof_>

** WALL
*<_wall_>

                gen byte wall=HS9
				recode wall (1=22) (2=34) (3=34) (4=22) (5=12) (6=96) 
                label var wall "Main material used for external walls"
				#delimit
                la de lblwall 12 "Natural – Cane/palm/trunks" 13 "Natural – Dirt" 14 "Natural – Other" 
				21 "Rudimentary – Bamboo with mud" 22 "Rudimentary – Stone with mud" 23 "Rudimentary – Uncovered adobe" 
				24 "Rudimentary – Plywood" 25 "Rudimentary – Cardboard" 26 "Rudimentary – Reused wood" 27 "Rudimentary – Other" 
				31 "Finished – Woven Bamboo" 32 "Finished – Stone with lime/cement" 34 "Finished – Cement blocks" 
				35 "Finished – Covered adobe" 36 "Finished – Wood planks/shingles" 37 "Finished – Plaster wire" 
				38 "Finished – GRC/Gypsum/Asbestos" 39 "Finished – Other" 96 "Other – “Specific”";
                #delimit cr
                label values wall lblwall
*</_wall_>

** FLOOR
*<_floor_>

                gen byte floor=HS11
				recode floor (1=21) (2=35) (3=35) (4=11) (5=37) (6=96) 
                label var floor "Main material used for floor"
				#delimit
                la de lblfloor 11 "Natural – Earth/sand" 12 "Natural – Dung" 13 "Natural –¬ Other" 
				21 "Rudimentary –¬ Wood planks " 22 "Rudimentary –¬ Palm/bamboo" 23 "Rudimentary – Other" 
				31 "Finished – Parquet or polished wood" 32 "Finished – Vinyl or asphalt strips" 33 "Finished – Ceramic/marble/granite" 
				34 "Finished – Floor tiles/teraso" 35 "Finished – Cement/red bricks" 36 "Finished – Carpet" 37 "Finished – Other" 96 "Other – Specific";
                #delimit cr
                label values floor lblfloor
*</_floor_>

** KITCHEN
*<_kitchen_>

                gen byte kitchen=.
                label var kitchen "Separate kitchen in the dwelling"
                la de lblkitchen 0 "No" 1 "Yes"
                label values kitchen lblkitchen
*</_kitchen_>

** BATH
*<_bath_>

                gen byte bath=.
                label var bath "Bathing facility in the dwelling"
                la de lblbath 0 "No" 1 "Yes"
                label values bath lblbath
*</_bath_>

** ROOMS
*<_rooms_>

                *gen byte rooms=.
                label var rooms "Number of habitable rooms"
*</_rooms_>

** AREASPACE
*<_areaspace_>

                gen byte areaspace=.
                label var areaspace "Area"
*</_areaspace_>

** OWNHOUSE
/*<_ownhouse_>

                gen byte ownhouse=.
                label var ownhouse "Ownership of house"
                la de lblownhouse 1 "ownership/ secure rights" 2 "renting" 3 "provided for free" 4 "without permission"
                label values ownhouse lblownhouse*/
*</_ownhouse_>

** ACQUI_HOUSE
*<_acqui_house_>

                gen byte acqui_house=HS2
				recode acqui_house (2=3)
                label var acqui_house "Acquisition of house"
                la de lblacqui_house  1 "Purchased" 2 "Inherited" 3 "Rental" 4 "Other"
                label values acqui_house lblacqui_house
*</_acqui_house_>

** ACQUI_LAND
*<_acqui_land_>

                gen byte acqui_land=.
                label var acqui_land "Acquisition of residential land"
                la de lblacqui_land 1 "Purchased" 2 "Inherited" 3 "Rental" 4 "Other"
                label values acqui_land lblacqui_land
*</_acqui_land_>

** DWELOWNLTI
*<_dwelownlti_>

                gen byte dwelownlti=.
                label var dwelownlti "Legal title for Ownership"
                la de lbldwelownlti 0 "No" 1 "Yes"
                label values dwelownlti lbldwelownlti
*</_dwelownlti_>

** FEM_DWELOWNLTI
*<_fem_dwelownlti_>

                gen byte fem_dwelownlti=.
                label var fem_dwelownlti "Legal title for Ownership - Female"
                la de lblfem_dwelownlti 0 "No" 1 "Yes"
                label values fem_dwelownlti lblfem_dwelownlti
*</_fem_dwelownlti_>

** DWELOWNTI
*<_dwelownti_>

                gen byte dwelownti=.
                label var dwelownti "Type of Legal document"
                la de lbldwelownti 1 "Owner-occupied" 2 "Publicly owned" 3 "Privately owned" 4 "Communally owned" 5 "Cooperatively owned" 6 "Other, non-owner-occupied"
                label values dwelownti lbldwelownti
*</_dwelownti_>

** SELLDWEL
*<_selldwel_>

                gen byte selldwel=.
                label var selldwel "Right to sell dwelling"
                la de lblselldwel 0 "No" 1 "Yes"
                label values selldwel lblselldwel
*</_selldwel_>

** TRANSDWEL
*<_transdwel_>

                gen byte transdwel=.
                label var transdwel "Right to transfer dwelling"
                la de lbltransdwel 0 "No" 1 "Yes"
                label values transdwel lbltransdwel
*</_transdwel_>

** OWNLAND
*<_ownland_>

                gen byte ownland=.
                label var ownland "Ownership of land"
                la de lblownland 0 "No" 1 "Yes"
                label values ownland lblownland
*</_ownland_>

** DOCULAND
*<_doculand_>

                gen byte doculand=.
                label var doculand "Legal document for residential land"
                la de lbldoculand 0 "No" 1 "Yes"
                label values doculand lbldoculand
*</_doculand_>

** FEM_DOCULAND
*<_fem_doculand_>

                gen byte fem_doculand=.
                label var fem_doculand "Legal document for residential land - female"
                la de lblfem_doculand 0 "No" 1 "Yes"
                label values fem_doculand lblfem_doculand
*</_fem_doculand_>

** LANDOWNTI
*<_landownti_>

                gen byte landownti=.
                label var landownti "Land Ownership"
                la de lbllandownti 1 "Title; deed" 2 "leasehold (govt issued)" 3 "Customary land certificate/plot level" 4 "Customary based / group right" 5 "Cooperative group right" 6 "Other"
                label values landownti lbllandownti
*</_landownti_>

** SELLLAND
*<_sellland_>

                gen byte sellland=.
                label var sellland "Right to sell land"
                la de lblsellland 0 "No" 1 "Yes"
                label values sellland lblsellland
*</_sellland_>

** TRANSLAND
*<_transland_>

                gen byte transland=.
                label var transland "Right to transfer land"
                la de lbltransland 0 "No" 1 "Yes"
                label values transland lbltransland
*</_transland_>



** AREA_AGRILAND
*<_area_agriland_>

                gen byte area_agriland=AS10+AS11+AS12
                label var area_agriland "Area of Agriculture land"
*</_area_agriland_>

** AGRILAND
*<_agriland_>

                gen byte agriland=0
				replace agriland=1 if area_agriland>0 & area_agriland!=.
                label var agriland "Agriculture Land"
                la de lblagriland 0 "No" 1 "Yes"
                label values agriland lblagriland
*</_agriland_>



** AREA_OWNAGRILAND
*<_area_ownagriland_>
                
                gen byte area_ownagriland=AS10a+AS11a
                label var area_ownagriland "Area of agriculture land owned"
*</_area_ownagriland_>

** OWNAGRILAND
*<_ownagriland_>
                
                gen byte ownagriland=0
				replace ownagriland=1 if area_ownagriland>0 & area_ownagriland!=.
                label var ownagriland "Ownership of agriculture land"
                la de lblownagriland 0 "No" 1 "Yes"
                label values ownagriland lblownagriland
*</_ownagriland_>


** AREAPURCH_AGRILAND
*<_areapurch_agriland_>

                gen byte areapurch_agriland=.
                label var areapurch_agriland "Area of purchased agriculture land"
*</_areapurch_agriland_>

** PURCH_AGRILAND
*<_purch_agriland_>

                gen byte purch_agriland=.
                label var purch_agriland "Purchased agri land"
                la de lblpurch_agriland 0 "No" 1 "Yes"
                label values purch_agriland lblpurch_agriland
*</_purch_agriland_>


** AREAINHER_AGRILAND
*<_areainher_agriland_>

                gen byte areainher_agriland=.
                label var areainher_agriland "Area of inherited agriculture land"
*</_areainher_agriland_>


** INHER_AGRILAND
*<_inher_agriland_>

                gen byte inher_agriland=.
                label var inher_agriland "Inherit agriculture land"
                la de lblinher_agriland 0 "No" 1 "Yes"
                label values inher_agriland lblinher_agriland
*</_inher_agriland_>

** DOCUAGRILAND
*<_docuagriland_>

                gen byte docuagriland=.
                label var docuagriland "Documented Agri Land"
                la de lbldocuagriland 0 "No" 1 "Yes"
                label values docuagriland lbldocuagriland
*</_docuagriland_>

** AREA_DOCUAGRILAND
*<_area_docuagriland_>

                gen byte area_docuagriland=.
                label var area_docuagriland "Area of documented agri land"
*</_area_docuagriland_>

** FEM_AGRILANDOWNTI
*<_fem_agrilandownti_>

                gen byte fem_agrilandownti=.
                label var fem_agrilandownti "Ownership Agri Land - Female"
                la de lblfem_agrilandownti 0 "No" 1 "Yes"
                label values fem_agrilandownti lblfem_agrilandownti
*</_fem_agrilandownti_>

** AGRILANDOWNTI
*<_agrilandownti_>

                gen byte agrilandownti=.
                label var agrilandownti "Type Agri Land ownership doc" 
                la de lblagrilandownti 1 "Title; deed" 2 "Leasehold (govt issued)" 3 "Customary land certificate/plot level" 4 "Customary based / group right" 5 "Cooperative" 6 "Other"
                label values agrilandownti lblagrilandownti
*</_agrilandownti_>

** SELLAGRILAND
*<_sellagriland_>

                gen byte sellagriland=.
                label var sellagriland "Right to sell agri land"
                la de lblsellagriland 0 "No" 1 "Yes"
                label values sellagriland lblsellagriland
*</_sellagriland_>

** TRANSAGRILAND
*<_transagriland_>

                gen byte transagriland=.
                label var transagriland "Right to transfer agri land"
                la de lbltransagriland 0 "No" 1 "Yes"
                label values transagriland lbltransagriland
*</_transagriland_>

** TYPLIVQRT
*<_typlivqrt_>

                gen byte typlivqrt=.
                label var typlivqrt "Types of living quarters"
                la de lbltyplivqrt 1 "Housing units, conventional dwelling with basic facilities" 2 "Housing units, conventional dwelling without basic facilities" 3 "Other housing units" 4 "Collective living quarters, hotels, rooming houses and other lodging houses" 5 "Collective living quarters, institutions" 6 "Collective living quarters, camps and workers' quarters" 7 "Other collective living quarters"
                label values typlivqrt lbltyplivqrt
*</_typlivqrt_>

** YBUILT
*<_ybuilt_>

                gen byte ybuilt=.
                label var ybuilt "Year the dwelling built"
*</_ybuilt_>


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

gen weighttype = "PW"

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
	
	tempfile data
	save `data'
	
	datalibweb, country(Support) year(2005) type(GMDRAW) surveyid(Support_2005_CPI_${cpiver}_M) filename(Final_CPI_PPP_to_be_used.dta)
	keep if code=="BTN" & year==2017 
	keep code year cpi2011 icp2011 cpi2017 icp2017 comparability
		rename cpi2011 cpi2011_${cpiver}
		rename cpi2017 cpi2017_${cpiver}
		rename icp2011 ppp_2011
		rename icp2017 ppp_2017
		 
	merge 1:m code year using `data', keep(match) nogen 

** CPI VARIABLE
	*label variable cpi "CPI (Base `year'=1)"
*</_cpi_>
	
	
** PPP VARIABLE
*<_ppp_>
	*label variable ppp "PPP `year'"
*</_ppp_>

	
** CPI PERIOD
*<_cpiperiod_>
	gen cpiperiod="2017M03M06"
	*gen cpiperiod=syear
	label var cpiperiod "Periodicity of CPI (year, year&month, year&quarter, weighted)"
*</_cpiperiod_>	
	
** POVERTY LINE (POVCALNET)
*<_pline_int_>
	gen pline_int=1.90*cpi2017_${cpiver}*ppp_2017*365/12
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

*<_Save data file_>
quietly do "$rootdofiles\_aux\Labels_SARMD.do"
save "$output\\`filename'.dta", replace
*</_Save data file_>

******************************  END OF DO-FILE  *****************************************************/
