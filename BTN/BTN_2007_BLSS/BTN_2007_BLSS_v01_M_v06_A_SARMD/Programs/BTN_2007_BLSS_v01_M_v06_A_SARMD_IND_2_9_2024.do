/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                       INTERNATIONAL INCOME DISTRIBUTION DATABASE (I2D2)                          **
**                                                                                                  **
** COUNTRY			BHUTAN
** COUNTRY ISO CODE	BTN
** YEAR				2007
** SURVEY NAME		BHUTAN LIVING STANDARD SURVEY (BLSS) 2007
** SURVEY AGENCY	NATIONAL STATISTICAL BUREAU
** RESPONSIBLE		Triana Yentzen
** MODFIED BY		Fernando Enrique Morales Velandia
** Date				02/15/2018

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
** DIRECTORY
	local input "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\BTN\BTN_2007_BLSS\BTN_2007_BLSS_v01_M"
	local output "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\BTN\BTN_2007_BLSS\BTN_2007_BLSS_v01_M_v05_A_SARMD"
	glo pricedata "D:\SOUTH ASIA MICRO DATABASE\CPI\cpi_ppp_sarmd_weighted.dta"
	glo shares "D:\SOUTH ASIA MICRO DATABASE\APPS\DATA CHECK\Food and non-food shares\BTN"
	glo fixlabels "D:\SOUTH ASIA MICRO DATABASE\APPS\DATA CHECK\Label fixing"

** LOG FILE
	log using "`output'\Doc\Technical\BTN_2007_BLSS_v01_M_v05_A_SARMD.log",replace
	*/
	
local cpiver       "10"
local code         "BTN"
local year         "2007"
local survey       "BLSS"
local vm           "01"
local va           "06"
local type         "SARMD"
glo   module       "IND"
local yearfolder   "`code'_`year'_`survey'"
local SARMDfolder    "`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD"
local filename     "`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD_${module}"

glo   pricedata    "P:\SARMD\SARST\09.CPI\before_2016\cpi_ppp_sarmd_weighted.dta"
glo   shares       "P:\SARMD\SARDATABANK\APPS\DATA CHECK\Food and non-food shares\\`code'"

/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/


** DATABASE ASSEMBLENT

	* PREPARE DATASETS
	
	use "${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M/Data/Stata\hroster.dta" 
	order dcode tgcode houseid slno
	sort  dcode tgcode hhno slno
	tempfile roster
	save `roster'
	
	use "${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M/Data/Stata\block1.dta" 
	ren slnp slno
	order dcode tgcode houseid slno
	sort  dcode tgcode houseid slno
	tempfile individual
	save `individual'
	
	use "${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M/Data/Stata\block2.dta" 
	order dcode tgcode houseid
	sort  dcode tgcode houseid
	tempfile housing
	save `housing'
	
	use "${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M/Data/Stata\block3.dta" 
	order dcode tgcode houseid
	sort  dcode tgcode houseid
	tempfile assets
	save `assets'
	
	use "${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M/Data/Stata\block7.dta" 
	order dcode tgcode houseid
	sort  dcode tgcode houseid
	tempfile income
	save `income'
	
	use "${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M/Data/Stata\hh.dta" 
	ren houseno hhno
	order dcode tgcode houseid
	sort  dcode tgcode houseid

	keep  dcode tgcode hhno houseid pce* totpovline reg_deflator poor
	sort houseid
	tempfile consumption
	save `consumption'
	clear
	
	* MERGE DATASETS
	
	use `roster' 
	merge 1:1 dcode tgcode houseid slno using `individual'
	drop _merge
	
	merge m:1 dcode tgcode houseid using `housing'
	drop _merge
	
	merge m:1 dcode tgcode houseid using `assets'
	drop _merge
	
	merge m:1 dcode tgcode houseid using `income'
	drop _merge
	
	sort houseid
	merge m:1 houseid using `consumption'
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
	gen code = "BTN"
	gen countryname = "Bhutan"
*</_countrycode_>


** YEAR
*<_year_>
	gen int year=2007
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
	tostring idh, replace
	label var idh "Household id"
	
	clonevar hhid = idh 
*</_idh_>

clonevar idh_org = houseid

** INDIVIDUAL IDENTIFICATION NUMBER
*<_idp_>

	gen str8 HID_str = string(houseid,"%08.0f")
	gen str2 pno= string(slno,"%02.0f") 
	gen str15 indiv=HID_str+pno
	destring indiv, generate(idp)
	format idp %15.0f
	tostring idp, replace
	isid idp
	label var idp "Individual id"
*</_idp_>

clonevar pid = idp 

clonevar idp_org = indiv

** HOUSEHOLD WEIGHTS
*<_wgt_>
	gen wgt=weight
	label var wgt "Household sampling weight"
*</_wgt_>

	
** STRATA
*<_strata_>
	gen strata=dcode
	label var strata "Strata"
*</_strata_>


** PSU
*<_psu_>
	gen psu=dtgbccd
	label var psu "Primary sampling units"
*</_psu_>

	
** MASTER VERSION
*<_vermast_>
	gen vermast="`vm'"
	label var vermast "Master Version"
*</_vermast_>
	
	
** ALTERATION VERSION
*<_veralt_>

	gen veralt="`va'"
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
	gen area01=dcode
	recode area01 (12=1)	(15=1)	(18=1)	(24=1)	(20=1)	(14=1)	(29=2)	(11=2)	(27=2)	(30=2)	(16=3)	(17=3)	(25=3)	(26=3)	(19=3)	(21=3)	(22=1)	(23=2)	(28=2)	(13=2), gen(subnatid0)
	la de lblsubnatid0 1 "Western" 2 "Central" 3 "Eastern" 4 "Southern"
	label values subnatid0 lblsubnatid0
	notes subnatid0: "BTN 2007" refer to technical doc for detail on classification and comparability with other rounds
	notes subnatid0: "BTN 2007" the underlying  classification is not part of an official distribution of the country, nor of the sampling methodology. It should be used to compare results with BTN 2003.0
	label var subnatid0 "Macro regional areas"
*</_subnatid0_>

** REGIONAL AREA 1 DIGIT ADMN LEVEL
*<_subnatid1_>
	gen subnatid1=dcode
	recode subnatid1 11=21 12=11 13=44 14=16 15=12 16=31 17=32 18=13 19=35 20=15 21=36 22=41 23=42 24=14 25=33 26=34 27=22 28=43 29=17 30=23
	la de lblsubnatid1 11"Chukha" 12"Ha" 13"Paro" 14"Thimphu" 15"Punakha" 16"Gasa" ///
	17"Wangdi Phodrang" 21"Bumthang" 22"Trongsa" 23"Zhemgang" 31"Lhuntshi" 32"Mongar" ///
	33"Trashigang" 34"Tashi Yangtse" 35"Pemagatshel" 36"Samdrup Jongkhar" 41"Samtse" ///
	42"Sarpang" 43"Tsirang" 44"Dagana"
	label var subnatid1 "Region at 1 digit (ADMN1)"
	label values subnatid1 lblsubnatid1
	notes subnatid1: "BTN 2007" this round is representative at district (dzonkhag) level whichs is this division. Also, at urban and rural desaggregation
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
	label var subnatid3 "Region at 3 digit (ADMN3)"
*</_subnatid3_>
	
	
gen subnatid4=""

	gen subnatid1_sar="" 
gen subnatid2_sar=""
gen subnatid3_sar=""
gen subnatid4_sar=""

** HOUSE OWNERSHIP
*<_ownhouse_>
	g		ownhouse = 1 if b2q2==1
	replace	ownhouse = 2 if inlist(b2q3,1,2)
	replace	ownhouse = 3 if b2q3==3
	note ownhouse: For BTN_2007_BLSS, we assumed those who did not own their home (b2q2 = 2) AND were not paying rent (b2q3 = 3) were provided for free (ownhouse = 3). It could be that they are in the house without permission (ownhouse = 4), but we did not know and categorized all into "provided for free" based on our best guess.
*</_ownhouse_>


** TENURE OF DWELLING
*<_tenure_>
   gen tenure=.
   replace tenure=1 if b2q2==1
   replace tenure=2 if b2q2==2 & ( b2q3==1 |  b2q3==2)
   replace tenure=3 if  b2q3==3 & b2q2!=1
   label var tenure "Tenure of Dwelling"
   la de lbltenure 1 "Owner" 2"Renter" 3"Other"
   la val tenure lbltenure
*</_tenure_>	


** LANDHOLDING
*<_lanholding_>
   gen landholding= b3q3wto>0 | b3q3dto>0 | b3q3or>0  if !mi(b3q3wto,b3q3dto,b3q3or)
   label var landholding "Household owns any land"
   la de lbllandholding 0 "No" 1 "Yes"
   la val landholding lbllandholding
   notes landholding: "BTN 2007" this variable was generated if  hh owned either wet, dry or or orchard land
*</_tenure_>	


*ORIGINAL WATER CATEGORIES
*<_water_orig_>
gen water_orig=b2q12
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
replace piped_water=b2q12==1 if b2q12!=.
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
note water_jmp: "BTN 2007" Due to multiple ambiguities in the options of raw data, JMP categories could not be identified, mainly those coming from piped water.
*</_water_jmp_>


*SAR improved source of drinking water
*<_sar_improved_water_>
gen sar_improved_water=.
replace sar_improved_water=1 if inlist(b2q12,1,2,3,4)
replace sar_improved_water=0 if inlist(b2q12,5,6,7,8) 
la def lblsar_improved_water 1 "Improved" 0 "Unimproved"
la var sar_improved_water "Improved source of drinking water-using country-specific definitions"
la val sar_improved_water lblsar_improved_water
note sar_improved_water: "BTN 2007" Due to not knowing whether category 'sptring' was protected or unprotected, it was taken as unimproved source of water based on judgement call
*</_sar_improved_water_>


*ORIGINAL WATER CATEGORIES
*<_water_original_>
clonevar j=b2q12
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
		replace water_source=1 if b2q12==1
		replace water_source=2 if b2q12==2
		replace water_source=3 if b2q12==3
		replace water_source=5 if b2q12==4
		replace water_source=10 if b2q12==5
		replace water_source=13 if b2q12==7
		replace water_source=14 if b2q12==8
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
		gen pipedwater_acc=0 if inrange(b2q12,2,8) // Asuming other is not piped water
		replace pipedwater_acc=3 if inlist(b2q12,1)
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
	gen electricity=.
	replace electricity=0 if b2q18==1 | 3 | 4
	replace electricity=1 if b2q18==2
	label var electricity "Electricity main source"
	la de lblelectricity 0 "No" 1 "Yes"
	label values electricity lblelectricity
*</_electricity_>

*ORIGINAL TOILET CATEGORIES
*<_toilet_orig_>
gen toilet_orig=b2q16
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
replace sewage_toilet=b2q16==1 if b2q16!=.
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




*IMPROVED SANITATION (Based on Joint Monitoring Program Definition)
*<_impr_toilet_jmp_>
gen impr_toilet=.
replace impr_toilet=1 if inlist(toilet_jmp,1,2,3,6,7,9)
replace impr_toilet=0 if inlist(toilet_jmp,4,5,8,10,11,12)
la var  impr_toilet "Improved sanitation facility-using Joint Monitoring Program categories"
la de lblimpr_toilet_jmp 1 "Improved" 0 "Unimproved"
la val 	impr_toilet  lblimpr_toilet_jmp	   
*</_impr_toilet_jmp_>


*SAR improved type of toilet
*<_sar_improved_toilet_>
gen sar_improved_toilet=.
replace sar_improved_toilet=1 if inlist(b2q16,1,2)
replace sar_improved_toilet=0 if inlist(b2q16,3,4,5)
replace sar_improved_toilet=0 if b2q17==1
la def lblsar_improved_toilet 1 "Improved" 0 "Unimproved"
la var sar_improved_toilet "Improved type of sanitation facility-using country-specific definitions"
la val sar_improved_toilet lblsar_improved_toilet
*</_sar_improved_toilet_>


	** ORIGINAL SANITATION CATEGORIES 
	*<_sanitation_original_>
		clonevar j=b2q16
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
		replace sanitation_source=2 if b2q16==1
		replace sanitation_source=3 if b2q16==2
		replace sanitation_source=4 if b2q16==3
		replace sanitation_source=13 if b2q16==4
		replace sanitation_source=14 if b2q16==5
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
		gen toilet_acc=3 if b2q16==1
		replace toilet_acc=0 if b2q16!=1 & b2q16!=.
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
	gen internet=.
	label var internet "Internet connection"
	la de lblinternet 0 "No" 1 "Yes"
	label values internet lblinternet

	clonevar shared_toilet = b2q17 

/*****************************************************************************************************
*                                                                                                    *
                                   DEMOGRAPHIC MODULE
*                                                                                                    *
*****************************************************************************************************/

** HOUSEHOLD SIZE
*<_hsize_>
	gen z=1 
	bys idh: egen hsize=sum(z)
	label var hsize "Household size"
	notes hsize: "BTN 2007" hsize was computed differently with respect to version 2
*</_hsize_>

**POPULATION WEIGHT
*<_pop_wgt_>
	gen pop_wgt=wgt*hsize
	la var pop_wgt "Population weight"
*</_pop_wgt_>


** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
*<_relationharm_>

	gen relationharm=b11q2
	recode relationharm (5/11=5) (12/13=6)
	label var relationharm "Relationship to the head of household"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Non-relatives"
	label values relationharm  lblrelationharm
*</_relationharm_>

** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
*<_relationcs_>

	gen byte relationcs=b11q2
	la var relationcs "Relationship to the head of household country/region specific"
	label define lblrelationcs 1 "Self(head)" 2 "Wife/Husband" 3 "Son/daughter" 4 "Father/Mother" 5 "Sister/Brother" 6 "Grandchild" 7 "Niece/nephew" 8 "Son-in-law/daughter-in-law" 9 "Brother-in-law/sister-in-law" 10 "Father-in-law/mother-in-law" 11 "Other family relative" 12 "Live-in-servant" 13 "Other-non-relative"
	label values relationcs lblrelationcs
*</_relationcs_>


** GENDER
*<_male_>
	gen male=b11q1
	recode male (2=0)
	label var male "Sex of household member"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale
*</_male_>

** AGE
*<_age_>
	*gen age=b11q3
	label var age "Age of individual"
	replace age=98 if age>=98 & age!=.
*</_age_>


** SOCIAL GROUP
*<_soc_>
	gen soc=b11q5
	label var soc "Social group"
	la de lblsoc 1 "Bhutanese" 2 "Other"
	label values soc lblsoc
	notes soc: "BTN 2007" this variable has "nationality"
*</_soc_>


** MARITAL STATUS
*<_marital_>
	gen marital=b11q4
	recode marital (1=1) (6=3) (3 4=4) (2=2) (5=5)
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
	gen everattend=1 if b12q11==1|b12q11==2
	recode everattend (.=0) if b12q11==3
	label var everattend "Ever attended school"
	la de lbleverattend 0 "No" 1 "Yes"
	label values everattend lbleverattend
	notes everattend: "BTN 2007" this variable includes people with no education and/or pre-primary education
*</_everattend_>



** CURRENTLY AT SCHOOL
*<_atschool_>
	gen atschool= b12q11==1 if b12q11<.
	replace atschool=. if age<ed_mod_age
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool
	notes atschool: "BTN 2007" this variable includes people with no education and/or pre-primary education
*</_atschool_>


** CAN READ AND WRITE
*<_literacy_>
	gen literacy=.
	replace literacy=0 if b12q10d==2 & b12q10e==2 & b12q10l==2 & b12q10o==2
	replace literacy=1 if b12q10d==1 | b12q10e==1 | b12q10l==1 | b12q10o==1
	replace literacy=. if age<ed_mod_age
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
*</_literacy_>

** YEARS OF EDUCATION COMPLETED
*<_educy_>
gen educy1=.
 replace educy1=0 if b12q12==00 | b12q12==01 | b12q20==00
 replace educy1=1 if b12q12==02 | b12q20==01
 replace educy1=2 if b12q12==03 | b12q20==02
 replace educy1=3 if b12q12==04 | b12q20==03
 replace educy1=4 if b12q12==05 | b12q20==04
 replace educy1=5 if b12q12==06 | b12q20==05
 replace educy1=6 if b12q12==07 | b12q20==06
 replace educy1=7 if b12q12==08 | b12q20==07
 replace educy1=8 if b12q12==09 | b12q20==08
 replace educy1=9 if b12q12==10 | b12q20==09
 replace educy1=10 if b12q12==11 | b12q20==10
 replace educy1=11 if b12q12==12 | b12q20==11
 replace educy1=12 if b12q20==12
 replace educy1=13 if  b12q12==13 
 replace educy1=14 if b12q20==13 | b12q12==14
 replace educy1=15 if b12q20==14
 replace educy1=16 if b12q12==15
 replace educy1=17 if b12q20==15
 replace educy1=18 if b12q12==16
 replace educy1=19 if b12q20==16
 replace educy1=0 if b12q11==3
replace educy=. if age<ed_mod_age 
replace educy=. if educy>age+1 & educy<. & age!=.
 rename educy1 educy
 label var educy "Years of education"
*</_educy_>

** EDUCATION LEVEL 7 CATEGORIES
*<_educat7_>
	gen educat7=.
	replace educat7=1 if educy==0
	replace educat7=2 if educy>0 & educy<9
	replace educat7=3 if educy==9
	replace educat7=4 if educy>9 & educy<12
	replace educat7=5 if educy==12
	replace educat7=6 if inlist(13,b12q12,b12q20) & educy!=.
	replace educat7=7 if (inrange(b12q12,14,16) | inrange(b12q20,14,16)) & educy!=.
	replace educat7=8 if inlist(17,b12q12,b12q20)
	replace educat7=. if age<ed_mod_age
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
recode   educat7       (1 2=0) (3 4 5 6 7=1) (8=.) 	if everattend==1, gen(primarycomp)
clonevar school        	= atschool

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
	replace lstatus = 1 if inlist(1, b14q37d,  b14q38d,  b14q39d)
	replace lstatus = 2 if  b14q40==1 & mi(lstatus)
	replace lstatus = 3 if b14q41!=.
	replace lstatus = . if age<15 
	label var lstatus "Labor status"
	label define lbllstatus 1"Employed" 2"Unemployed" 3"Not-in-labor-force"
	label values lstatus lbllstatus
*</_lstatus_>

** LABOR STATUS LAST YEAR
*<_lstatus_year_>
	gen byte lstatus_year= 1 if inlist(1, b14q37m,  b14q38m,  b14q39m)
	replace lstatus_year=0 if b14q37m==2 & b14q38m==2 & b14q39m==2
	replace lstatus_year=. if age<lb_mod_age & age!=.
	label var lstatus_year "Labor status during last year"
	la de lbllstatus_year 1 "Employed" 0 "Not employed" 
	label values lstatus_year lbllstatus_year
*</_lstatus_year_>


** EMPLOYMENT STATUS
*<_empstat_>
	gen empstat=b14q43
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
	gen njobs=b14q47
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
	gen ocusec=b14q46
	recode ocusec (1 3=1) ( 2 4 5 6 7 8 9 =3)  (10=.)
	recode ocusec 3=2
	label var ocusec "Sector of activity"
	la de lblocusec 1 "Public, state owned, government, army" 2 "NGO" 3 "Private"
	label values ocusec lblocusec
	replace ocusec=. if lstatus!=1 | age<15
	notes: ocusec: "BTN 2007" "other" category is captured as missing
*</_ocusec_>

** REASONS NOT IN THE LABOR FORCE
*<_nlfreason_>
	gen nlfreason=b14q41
	recode nlfreason (8=1) (7=2) (9=3) (1 10=4) (2/6 11=5)
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
	gen industry_orig=b14q45
	label define lblindustry_orig 11 `"Growing of crops/market gardening/horticulture"', modify
	label define lblindustry_orig 12 `"Farming of animals"', modify
	label define lblindustry_orig 13 `"Growing of crops combined with farming of animals (mixed far"', modify
	label define lblindustry_orig 14 `"Agricultural and animal husbandry service activities, except"', modify
	label define lblindustry_orig 15 `"Hunting, trapping and game propagation including related ser"', modify
	label define lblindustry_orig 20 `"Forestry, logging and related service activities"', modify
	label define lblindustry_orig 50 `"Fishing, operation of fish hatcheries and fish farms/service"', modify
	label define lblindustry_orig 101 `"Mining and agglomeration of hard coal"', modify
	label define lblindustry_orig 102 `"Mining and agglomeration of lignite"', modify
	label define lblindustry_orig 103 `"Extraction and agglomeration of peat"', modify
	label define lblindustry_orig 111 `"Extraction of crude petroleum and natural gas"', modify
	label define lblindustry_orig 112 `"Service activities incidental to oil and gas extraction excl"', modify
	label define lblindustry_orig 120 `"Mining of uranium and thorium ores"', modify
	label define lblindustry_orig 131 `"Mining of iron ores"', modify
	label define lblindustry_orig 132 `"Mining of non-ferrous metal ores, except uranium thorium ore"', modify
	label define lblindustry_orig 141 `"Quarrying of stone, sand and clay"', modify
	label define lblindustry_orig 142 `"Mining and quarrying"', modify
	label define lblindustry_orig 151 `"Production, processing and preservation of meat,fish,fruit,v"', modify
	label define lblindustry_orig 152 `"Manufacture of dairy products"', modify
	label define lblindustry_orig 153 `"Manufacture of grain mill products, starches and starches an"', modify
	label define lblindustry_orig 154 `"Manufacture of other food products"', modify
	label define lblindustry_orig 155 `"Manufacture of beverages"', modify
	label define lblindustry_orig 160 `"Manufacture of tobacco products"', modify
	label define lblindustry_orig 171 `"Spinning, weaving and finishing of textiles"', modify
	label define lblindustry_orig 172 `"Manufacture of other textiles"', modify
	label define lblindustry_orig 173 `"Manufacture of knitted and crocheted fabrics and articles"', modify
	label define lblindustry_orig 181 `"Manufacture of wearing apparel, except fur apparal"', modify
	label define lblindustry_orig 182 `"Dressing and dyeing of fur; manufacture of article of fur"', modify
	label define lblindustry_orig 191 `"Tanning and dressing of leather; manufacture of luggage, han"', modify
	label define lblindustry_orig 192 `"Manufacture of footwear"', modify
	label define lblindustry_orig 201 `"Sawmilling and planing of wood"', modify
	label define lblindustry_orig 202 `"Manufacture of products of wood, cork, straw and plaiting ma"', modify
	label define lblindustry_orig 210 `"Manufacture of paper and paper products"', modify
	label define lblindustry_orig 221 `"Publishing"', modify
	label define lblindustry_orig 222 `"Printing and service activities related to printing"', modify
	label define lblindustry_orig 223 `"Reproduction of recorded media"', modify
	label define lblindustry_orig 231 `"Manufacture of coke oven products"', modify
	label define lblindustry_orig 232 `"Manufacture of refined petroleum products"', modify
	label define lblindustry_orig 233 `"Processing of nuclear fuel"', modify
	label define lblindustry_orig 241 `"Manufacture of basic chemicals"', modify
	label define lblindustry_orig 242 `"Manufacture of other chemical products preparations,perfumes"', modify
	label define lblindustry_orig 243 `"Manufacture of man-made fibres"', modify
	label define lblindustry_orig 251 `"Manufacture of rubber products"', modify
	label define lblindustry_orig 252 `"Manufacture of plastic products"', modify
	label define lblindustry_orig 261 `"Manufacture of glass and glass products"', modify
	label define lblindustry_orig 269 `"Manufacture of non-metallic mineral products"', modify
	label define lblindustry_orig 271 `"Manufacture of basic iron and steel"', modify
	label define lblindustry_orig 272 `"Manufacture of basic precious and non-ferrous metals"', modify
	label define lblindustry_orig 273 `"Casting of metals"', modify
	label define lblindustry_orig 281 `"Manufacture of structural metal products, tanks, reservoirs"', modify
	label define lblindustry_orig 289 `"Manufacture of other fabricated metal products; metal workin"', modify
	label define lblindustry_orig 291 `"Manufacture of general purpose machinery"', modify
	label define lblindustry_orig 292 `"Manufacture of special purpose machinery"', modify
	label define lblindustry_orig 293 `"Manufacture of domestic appliances"', modify
	label define lblindustry_orig 300 `"Manufacture of office, accounting and computing machinery"', modify
	label define lblindustry_orig 311 `"Manufacture of electric motors, generators and transformers"', modify
	label define lblindustry_orig 312 `"Manufacture of electricity distribution and control apparatu"', modify
	label define lblindustry_orig 313 `"Manufacture of insulated wire and cable"', modify
	label define lblindustry_orig 314 `"Manufacture of accumulators, primary cells and primary batte"', modify
	label define lblindustry_orig 315 `"Manufacture of electric lamps and lighting equipment"', modify
	label define lblindustry_orig 319 `"Manufacture of other electrical equipment"', modify
	label define lblindustry_orig 321 `"Manufacture of electronic valves and tubes and other electro"', modify
	label define lblindustry_orig 322 `"Manufacture of television and radio transmitters and apparat"', modify
	label define lblindustry_orig 323 `"Manufacture of television and radio receivers, sound or vide"', modify
	label define lblindustry_orig 331 `"Manufacture of medical appliances and instruments and applia"', modify
	label define lblindustry_orig 332 `"Manufacture of optical instruments and photographic equipmen"', modify
	label define lblindustry_orig 333 `"Manufacture of watches and clocks"', modify
	label define lblindustry_orig 341 `"Manufacture of motor vehicles"', modify
	label define lblindustry_orig 342 `"Manufacture of bodies (coachwork) for motor vehicles; manufa"', modify
	label define lblindustry_orig 343 `"Manufacture of parts and accessories for motor vehicles and"', modify
	label define lblindustry_orig 351 `"Building and repairing of ships and boats"', modify
	label define lblindustry_orig 352 `"Manufacture of railway and tramway locomotives and rolling s"', modify
	label define lblindustry_orig 353 `"Manufacture of aircraft and spacecraft"', modify
	label define lblindustry_orig 359 `"Manufacture of transport equipment"', modify
	label define lblindustry_orig 361 `"Manufacture of furniture"', modify
	label define lblindustry_orig 369 `"Manufacture of n.e.c"', modify
	label define lblindustry_orig 371 `"Recycling of metal waste and scrap"', modify
	label define lblindustry_orig 372 `"Recycling of non-metal waste and scrap"', modify
	label define lblindustry_orig 401 `"Production, collection and distribution of electricity"', modify
	label define lblindustry_orig 402 `"Manufacture of gas; distribution of gaseous fuels through ma"', modify
	label define lblindustry_orig 403 `"Steam and hot water supply"', modify
	label define lblindustry_orig 410 `"Collection, purification and distribution of water"', modify
	label define lblindustry_orig 451 `"Site preparation"', modify
	label define lblindustry_orig 452 `"Building of complete constructions or parts thereof; civil e"', modify
	label define lblindustry_orig 453 `"Building installation"', modify
	label define lblindustry_orig 454 `"Building completion"', modify
	label define lblindustry_orig 455 `"Renting of construction or demolition equipment with operato"', modify
	label define lblindustry_orig 501 `"Sale of motor vehicles"', modify
	label define lblindustry_orig 502 `"Maintenance and repair of motor vehicles"', modify
	label define lblindustry_orig 503 `"Sale of motor vehicle parts and accessories"', modify
	label define lblindustry_orig 504 `"Sale, maintenance and repair of motorcycles and related part"', modify
	label define lblindustry_orig 505 `"Retail sale of automotive fuel"', modify
	label define lblindustry_orig 511 `"Wholesale on a fee or contract basis"', modify
	label define lblindustry_orig 512 `"Wholesale of agricultural raw materials, live animals, food,"', modify
	label define lblindustry_orig 513 `"Wholesale of household goods"', modify
	label define lblindustry_orig 514 `"Wholesale of non-agricultural intermediate products, waste a"', modify
	label define lblindustry_orig 515 `"Wholesale of machinery, equipment and supplies"', modify
	label define lblindustry_orig 519 `"Other wholesale"', modify
	label define lblindustry_orig 521 `"Non-specialized retail trade in stores"', modify
	label define lblindustry_orig 522 `"Retail sale of food, beverages and tobacco in specialized st"', modify
	label define lblindustry_orig 523 `"Other retail trade of new goods in specialized stores"', modify
	label define lblindustry_orig 524 `"Retail sale of second-hand goods in stores"', modify
	label define lblindustry_orig 525 `"Retail trade not in stores"', modify
	label define lblindustry_orig 526 `"Repair of personal and household goods"', modify
	label define lblindustry_orig 551 `"Hotels; camping sites and other provision of short-stay acco"', modify
	label define lblindustry_orig 552 `"Restaurants, bars and canteens"', modify
	label define lblindustry_orig 601 `"Transport via railways"', modify
	label define lblindustry_orig 602 `"Other land transport"', modify
	label define lblindustry_orig 603 `"Transport via pipelines"', modify
	label define lblindustry_orig 611 `"Sea and coastal water transport"', modify
	label define lblindustry_orig 612 `"Inland water transport"', modify
	label define lblindustry_orig 621 `"Scheduled air transport"', modify
	label define lblindustry_orig 622 `"Non-scheduled air transport"', modify
	label define lblindustry_orig 630 `"Supporting and auxiliary transport activities ; activities o"', modify
	label define lblindustry_orig 641 `"Post and currier activities"', modify
	label define lblindustry_orig 642 `"Telecommunications"', modify
	label define lblindustry_orig 651 `"Monetary intermediation"', modify
	label define lblindustry_orig 659 `"Other financial intermediation"', modify
	label define lblindustry_orig 660 `"Insurance and pension funding, except compulsory social secu"', modify
	label define lblindustry_orig 671 `"Activities auxiliary to financial intermediation, except ins"', modify
	label define lblindustry_orig 672 `"Activities auxiliary to insurance and pension fund"', modify
	label define lblindustry_orig 701 `"Real estate activities with own or leased property"', modify
	label define lblindustry_orig 702 `"Real estate activities on a fee or contract basis"', modify
	label define lblindustry_orig 711 `"Renting of transport equipment"', modify
	label define lblindustry_orig 719 `"Renting of personal and household goods"', modify
	label define lblindustry_orig 721 `"Hardware consultancy"', modify
	label define lblindustry_orig 722 `"Software consultancy and supply"', modify
	label define lblindustry_orig 723 `"Data processing"', modify
	label define lblindustry_orig 724 `"Data base activities"', modify
	label define lblindustry_orig 725 `"Maintenance and repair of office, accounting and computing m"', modify
	label define lblindustry_orig 729 `"Other computer related activities"', modify
	label define lblindustry_orig 731 `"Research and experimental developmental on natural sciences"', modify
	label define lblindustry_orig 732 `"Research and experimental development on social sciences and"', modify
	label define lblindustry_orig 741 `"Legal, accounting, book-keeping and auditing activities, tax"', modify
	label define lblindustry_orig 742 `"Architectural, engineering and other technical activities"', modify
	label define lblindustry_orig 743 `"Advertising"', modify
	label define lblindustry_orig 749 `"Business activities n.e.c"', modify
	label define lblindustry_orig 751 `"Administration of the State and the economic and social poli"', modify
	label define lblindustry_orig 752 `"Provision of services to the community as a whole"', modify
	label define lblindustry_orig 753 `"Compulsory social security activities"', modify
	label define lblindustry_orig 801 `"Primary education"', modify
	label define lblindustry_orig 802 `"Secondary education"', modify
	label define lblindustry_orig 803 `"Higher Education"', modify
	label define lblindustry_orig 809 `"Adult and other education"', modify
	label define lblindustry_orig 851 `"Human health activities"', modify
	label define lblindustry_orig 852 `"Veterinary activities"', modify
	label define lblindustry_orig 853 `"Social work activities"', modify
	label define lblindustry_orig 900 `"Sewage and refuse disposal, sanitation and similar activitie"', modify
	label define lblindustry_orig 911 `"Activities of business, employers and professional organizat"', modify
	label define lblindustry_orig 912 `"Activities of trade unions"', modify
	label define lblindustry_orig 919 `"Activities of other membership organizations"', modify
	label define lblindustry_orig 921 `"Motion picture, radio, television and other entertainment ac"', modify
	label define lblindustry_orig 922 `"News agency activities"', modify
	label define lblindustry_orig 923 `"Library, archives, museums and other cultural activities"', modify
	label define lblindustry_orig 924 `"Sporting and other recreational activities"', modify
	label define lblindustry_orig 930 `"Other service activities"', modify
	label define lblindustry_orig 950 `"Private households with employed persons"', modify
	label define lblindustry_orig 990 `"Extra-territorial organizations and bodies"', modify
	la val industry_orig lblindustry_orig
	replace industry_orig=. if lstatus!=1
	la var industry_orig "Original industry code"
*</_industry_orig_>

** INDUSTRY CLASSIFICATION
*<_industry_>
	gen industry=int(b14q45/10)
	recode industry (1/5=1) (10/14=2) (15/37=3) (40/41=4) (45=5) (50/55=6) (60/64=7) (65/74=8) (75=9) (80/99=10) 
	replace  industry =. if age<15 | industry==11
	replace industry=. if lstatus!=1
	label var industry "1 digit industry classification"
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industry lblindustry
*</_industry_>

**ORIGINAL OCCUPATION CLASSIFICATION
*<_occup_orig_>
	gen occup_orig=b14q44
	label define lbloccup_orig 1 `"Armed forces"', modify
	label define lbloccup_orig 11 `"Legislators and senior officials"', modify
	label define lbloccup_orig 12 `"Corporate managers"', modify
	label define lbloccup_orig 13 `"General managers"', modify
	label define lbloccup_orig 21 `"Physical, mathematical & engineering science professionals"', modify
	label define lbloccup_orig 22 `"Life science & health professionals"', modify
	label define lbloccup_orig 23 `"Teaching professionals"', modify
	label define lbloccup_orig 24 `"Other professionals"', modify
	label define lbloccup_orig 31 `"Physical science & engineering associate professionals"', modify
	label define lbloccup_orig 32 `"Life science and health associate professionals"', modify
	label define lbloccup_orig 33 `"Teaching associate professionals"', modify
	label define lbloccup_orig 34 `"Other associate professionals"', modify
	label define lbloccup_orig 41 `"Office clerks"', modify
	label define lbloccup_orig 42 `"Customer service clerks"', modify
	label define lbloccup_orig 51 `"Personal and protective services workers"', modify
	label define lbloccup_orig 52 `"Model, salespersons and demonstrators"', modify
	label define lbloccup_orig 61 `"Market oriented skilled agricultural & fishery workers"', modify
	label define lbloccup_orig 62 `"Subsistence agricultural & fishery related workers"', modify
	label define lbloccup_orig 71 `"Extraction and buildings trade workers"', modify
	label define lbloccup_orig 72 `"Metal, machinery & related trade workers"', modify
	label define lbloccup_orig 73 `"Precision, handicraft, printing & related trades workers"', modify
	label define lbloccup_orig 74 `"Other craft and related trades workers"', modify
	label define lbloccup_orig 81 `"Industrial plant operators"', modify
	label define lbloccup_orig 82 `"Stationary machine operators and assemblers"', modify
	label define lbloccup_orig 83 `"Drivers and mobile machine operators"', modify
	label define lbloccup_orig 88 `"Contractor"', modify
	label define lbloccup_orig 91 `"Sale and services elementary occupations"', modify
	label define lbloccup_orig 92 `"Agricultural, fishery and related labourers"', modify
	label define lbloccup_orig 93 `"Labourers in mining, construction, manufacturing & transport"', modify
	label define lbloccup_orig 97 `"No skill"', modify
	label define lbloccup_orig 98 `"Occupation not stated"', modify
	label define lbloccup_orig 99 `"Occupation not classified by economic activity"', modify
	la val occup_orig lbloccup_orig
	replace occup_orig=. if lstatus!=1
	la var occup_orig "Original occupation code"
*</_occup_orig_>


** OCCUPATION CLASSIFICATION
*<_occup_>
	gen occup=int(b14q44/10)
	recode occup (0=10)
	recode occup(9=99) if inlist(b14q44, 97,98,99)
	label var occup "1 digit occupational classification"
	la de occup 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup occup
	replace occup=. if lstatus!=1
	notes occup: "BTN 2007" ISCO88 is implemented
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
	gen whours=b14q52m
	*infeasible weekly working hours reported - to be recoded to missing
	*histogram whours if whours<100
	replace whours=. if whours>98
	replace whours=. if lstatus!=1 | age<15
	label var whours "Hours of work in last week"
	note whours: "BTN 2007" infeasible weekly working hours reported (>98)- to be recoded to missing
*</_whours_>


** WAGES
*<_wage_>
	gen wage=.
	label var wage "Last wage payment"
*<_/wage_>

** WAGES TIME UNIT
*<_unitwage_>
	gen unitwage=.
	label var unitwage "Last wages time unit"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly"
*</_wageunit_>


** EMPLOYMENT STATUS - SECOND JOB
*<_empstat_2_>
	gen empstat_2=b14q48
	recode empstat_2 (1 2=1) (3=2) (5=3) (6=.)
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
	gen industry_2=b14q50
	recode industry_2 (11/50=1) (101/142=2) (151/372=3) (401/410=4) (451/455=5) (501/552=6) ///
	(601/642=7) (651/749=8) (751=9) (752/990=10)
	replace industry_2=. if njobs==0 | njobs==. | lstatus!=1
	label var industry_2 "1 digit industry classification - second job"
	la de lblindustry_2 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industry_2 lblindustry
*<_industry_2_>


**SURVEY SPECIFIC INDUSTRY CLASSIFICATION - SECOND JOB
*<_industry_orig_2_>
	gen industry_orig_2=b14q50
	replace industry_orig_2=. if njobs==0 | njobs==. | lstatus!=1
	label var industry_orig_2 "Original Industry Codes - Second job"
	la de lblindustry_orig_2 1""
	label values industry_orig_2 lblindustry_orig
*</_industry_orig_2>


** OCCUPATION CLASSIFICATION - SECOND JOB
*<_occup_2_>
	gen occup_2=b14q49
	recode occup_2 (1=10) (11/13=1) (21/24=2) (31/34=3) (41/42=4) (51/52=5) (61/62=6) (71/74=7) (81/88=8) (91/93=9) (97/98=99)
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
	label values unitwage lblunitwage
	gen contract=.
	label var contract "Contract"
	la de lblcontract 0 "Without contract" 1 "With contract"
*</_contract_>

** HEALTH INSURANCE
*<_healthins_>
	label values contract lblcontract
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


foreach var in lstatus lstatus_year empstat empstat_year njobs njobs_year ocusec nlfreason unempldur_l unempldur_u industry_orig industry occup_orig occup firmsize_l firmsize_u whours wage unitwage empstat_2 empstat_2_year industry_2 industry_orig_2 occup_2 wage_2 unitwage_2 contract healthins socialsec union{
replace `var'=. if age<lb_mod_age
}


gen industry_year=. 
gen industry_2_year=. 
gen industry_orig_year=. 
gen industry_orig_2_year=. 
gen occup_year=. 
gen ocusec_year=. 
gen industrycat10 = . 
gen industrycat4 = . 


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

	gen byte landphone=b2q11==1 if b2q11!=.
	label var landphone "Household has landphone"
	la de lbllandphone 0 "No" 1 "Yes"
	label values landphone lbllandphone
*</_landphone_>


** CEL PHONE
*<_cellphone_>

	gen cellphone=b3q1mp==1 | b3q1mp==2 if !mi(b3q1mp)  
	label var cellphone "Household has Cell phone"
	la de lblcellphone 0 "No" 1 "Yes"
	label values cellphone lblcellphone
*</_cellphone_>


** COMPUTER
*<_computer_>
	gen byte computer=b3q1cp==1 | b3q1cp==2 if !mi(b3q1cp)
	label var computer "Household has computer"
	la de lblcomputer 0 "No" 1 "Yes"
	label values computer lblcomputer
*</_computer_>

** RADIO
*<_radio_>
	gen radio=  b3q1rd==1 |  b3q1rd==2 if !mi(b3q1rd)
	label var radio "Household has radio"
	la de lblradio 0 "No" 1 "Yes"
	label val radio lblradio
*</_radio_>

** TELEVISION
*<_television_>
	gen television= b3q1tv==1 | b3q1tv==2 if !mi(b3q1tv)
	label var television "Household has Television"
	la de lbltelevision 0 "No" 1 "Yes"
	label val television lbltelevision
*</_television>

** FAN
*<_fan_>
	gen fan=  b3q1fn==1 |  b3q1fn==2 if !mi(b3q1fn)
	label var fan "Household has Fan"
	la de lblfan 0 "No" 1 "Yes"
	label val fan lblfan
*</_fan>

** SEWING MACHINE
*<_sewingmachine_>
	gen sewingmachine= b3q1sw==1 |  b3q1sw==2 if !mi(b3q1sw)
	label var sewingmachine "Household has Sewing machine"
	la de lblsewingmachine 0 "No" 1 "Yes"
	label val sewingmachine lblsewingmachine
*</_sewingmachine>

** WASHING MACHINE
*<_washingmachine_>
	gen washingmachine= b3q1wm==1 |  b3q1wm==2 if !mi(b3q1wm)
	label var washingmachine "Household has Washing machine"
	la de lblwashingmachine 0 "No" 1 "Yes"
	label val washingmachine lblwashingmachine
*</_washingmachine>

** REFRIGERATOR
*<_refrigerator_>
	gen refrigerator=b3q1rg==1 | b3q1rg==2 if !mi(b3q1rg)
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
	gen bicycle=  b3q1bc==1 |  b3q1bc==2 if !mi(b3q1bc)
	label var bicycle "Household has Bicycle"
	la de lblbycicle 0 "No" 1 "Yes"
	label val bicycle lblbycicle
*</_bycicle>

** MOTORCYCLE
*<_motorcycle_>
	gen motorcycle= b3q1mb==1 |  b3q1mb==2 if !mi(b3q1mb)
	label var motorcycle "Household has Motorcycle"
	la de lblmotorcycle 0 "No" 1 "Yes"
	label val motorcycle lblmotorcycle
*</_motorcycle>

** MOTOR CAR
*<_motorcar_>
	gen motorcar=  b3q1fc==1 |  b3q1fc==2 if !mi(b3q1fc)
	label var motorcar "Household has Motor car"
	la de lblmotorcar 0 "No" 1 "Yes"
	label val motorcar lblmotorcar
*</_motorcar>

** COW
*<_cow_>
	gen cow= b3q2ct>0 if  b3q2ct<.
	label var cow "Household has Cow"
	la de lblcow 0 "No" 1 "Yes"
	label val cow lblcow
*</_cow>

** BUFFALO
*<_buffalo_>
	gen buffalo=b3q2bf>0 if b3q2bf<.
	label var buffalo "Household has Buffalo"
	la de lblbuffalo 0 "No" 1 "Yes"
	label val buffalo lblbuffalo
*</_buffalo>

** CHICKEN
*<_chicken_>
	gen chicken=.
	label var chicken "Household has Chicken"
	la de lblchicken 0 "No" 1 "Yes"
	label val chicken lblchicken
*</_chicken>
	
clonevar lphone = landphone 

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
	gen welfarenat=welfaredef
	la var welfarenat "Welfare aggregate for national poverty"
*</_welfarenat_>	

*QUINTILE, DECILE AND FOOD/NON-FOOD SHARES OF CONSUMPTION AGGREGATE
	levelsof year, loc(y)
	merge m:1 idh using "$shares\\BTN_fnf_`y'", keepusing (food_share nfood_share quintile_cons_aggregate decile_cons_aggregate)
	drop _merge
	
	gen weighttype="PW"

	gen welfshprtype="EXP"

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
*********************************************f********************************************************/

	local year=2011
	
** USE SARMD CPI AND PPP
*<_cpi_>
	capture drop _merge
	tempfile data
	save `data'
	
	datalibweb, country(Support) year(2005) type(GMDRAW) surveyid(Support_2005_CPI_${cpiver}_M) filename(Final_CPI_PPP_to_be_used.dta)
	keep if code=="BTN" & year==2012
	keep code year cpi2011 icp2011 cpi2017 icp2017 comparability
		rename cpi2011 cpi2011_${cpiver}
		rename cpi2017 cpi2017_${cpiver}
		rename icp2011 ppp_2011
		rename icp2017 ppp_2017
		 
	merge 1:m code year using `data', keep(match) nogen 
*</_ppp_>

	
** CPI PERIOD
*<_cpiperiod_>
	gen cpiperiod="2007m3-2007m5"
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

gen month = .  

gen typehouse =. 

gen agecat =. 

gen converfactor = 1 

gen harmonization = "SARMD"

gen sector = .

gen gaul_adm2_code=.
gen gaul_adm3_code=.

clonevar imp_san_rec = improved_sanitation
clonevar imp_wat_rec = improved_water

/*****************************************************************************************************
*                                                                                                    *
                                   FINAL STEPS
*                                                                                                    *
*****************************************************************************************************/
*<_Save data file_>
preserve
quietly do "$rootdofiles/_aux/Labels_SARMD.do"
save "$rootdatalib/`code'/`yearfolder'/`SARMDfolder'/Data/Harmonized/`filename'.dta", replace
restore
*</_Save data file_>

*<_Save data file_>
cap replace welfare          =welfare*12
cap replace welfarenom       =welfarenom*12 
cap replace welfaredef       =welfaredef*12 
cap replace welfshprosperity =welfshprosperity*12
cap replace welfareother     =welfareother*12
cap replace welfarenat       =welfarenat*12
 do "$rootdofiles/_aux/Labels_GMD_All.do"
save "$rootdatalib/`code'/`yearfolder'/`SARMDfolder'/Data/Harmonized/`filename'_GMD_ALL.dta", replace
*</_Save data file_>




******************************  END OF DO-FILE  *****************************************************/
