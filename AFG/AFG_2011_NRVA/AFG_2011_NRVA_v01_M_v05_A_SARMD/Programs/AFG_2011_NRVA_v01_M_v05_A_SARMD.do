/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                                   SOUTH ASIA MICRO DATABASE                                      **
**                                                                                                  **
** COUNTRY			Afghanistan
** COUNTRY ISO CODE	AFG
** YEAR				2011
** SURVEY NAME		National Risk and Vulnerability Assessment 2011-2012
** SURVEY AGENCY	Central Statistics Organization
** RESPONSIBLE		Triana Yentzen
** MODFIFIED BY 	Fernando Enrique Morales Velandia
** Date: 			02/26/2018                                                                      **
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
	local input "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\AFG\AFG_2011_NRVA\AFG_2011_NRVA_v01_M"
	local output "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\AFG\AFG_2011_NRVA\AFG_2011_NRVA_v01_M_v05_A_SARMD"
	glo pricedata "D:\SOUTH ASIA MICRO DATABASE\CPI\cpi_ppp_sarmd_weighted.dta"
 	glo shares "D:\SOUTH ASIA MICRO DATABASE\APPS\DATA CHECK\Food and non-food shares\AFG"
	glo fixlabels "D:\SOUTH ASIA MICRO DATABASE\APPS\DATA CHECK\Label fixing"

** LOG FILE
log using "`output'\Doc\Technical\AFG_2011_NRVA_v01_M_v05_A_SARMD.log",replace

/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/


** DATABASE ASSEMBLENT

	* PREPARE DATASETS

	local filesh "F_22 F_23 M_1&2 M_04 M_05 M_06 M_07a M_07c M_09 M_10 M_11c M_13"
	local filesi "F_21 F_24 M_03 M_08 M_11a M_12"

	loca i=1
	foreach file in `filesh'{
	use "`input'\Data\Stata\\`file'", clear
	sort Household_Code
	tempfile h`i'
	qui compress
	save `h`i''
	local i= `i'+1
	}

	loca i=1
	foreach file in `filesi'{
	use "`input'\Data\Stata\\`file'", clear
	sort Household_Code
	tempfile i`i'
	qui compress
	save `i`i''
	local i= `i'+1
	}

	* MERGE DATASETS
	
	use "`input'\Data\Stata\Core individual.dta", clear
	merge m:1 Household_Code using "`input'\Data\Stata\Core Household.dta"
	drop _merge

	qui compress

	local i=1
	foreach file in `filesh'{
	merge m:1 Household_Code using `h`i''
	qui drop if _merge==2
	drop _merge
	local i=`i'+1
	}

	local i=1
	foreach file in `filesi'{
	merge 1:1 Household_Code Unique_Mem_ID using `i`i'', force
	qui drop if _merge==2
	drop _merge
	local i=`i'+1
	}

	ren Household_Code hhid
	sort hhid
	merge m:1 hhid using "`input'\Data\Stata\poverty2011.dta" 

	drop Q_22* Q_23*
	drop Q_3_2
	qui compress

/*****************************************************************************************************
*                                                                                                    *
                                   * STANDARD SURVEY MODULE
*                                                                                                    *
*****************************************************************************************************/
	
	
** COUNTRY
*<_countrycode_>
	gen str4 countrycode="AFG"
	label var countrycode "Country code"
*</_countrycode_>


** YEAR
*<_year_>
	gen int year=2011
	label var year "Year of survey"
*</_year_>
 
 
** SURVEY NAME 
*<_survey_>
	gen str survey="NRVA"
	label var survey "Survey Acronym"
*</_survey_>


** INTERVIEW YEAR
*<_int_year_>
	gen int_year=int_year_c
	label var int_year "Year of the interview"
*</_int_year_>
	
	
** INTERVIEW MONTH
*<_int_month_>
	gen int_month=int_month_c
	la de lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value int_month lblint_month
	label var int_month "Month of the interview"
*</_int_month_>

**FIELD WORKD***
*<_fieldwork_> 
gen fieldwork=ym(int_year_c, int_month_c)
format %tm fieldwork
la var fieldwork "Date of fieldwork"
*<_/fieldwork_> 


** HOUSEHOLD IDENTIFICATION NUMBER
*<_idh_>
	gen str idh = hhid
	label var idh "Household id"
*</_idh_>


** INDIVIDUAL IDENTIFICATION NUMBER
*<_idp_>
	gen idp= Unique_Mem_ID
	label var idp "Individual id"
*</_idp_>


** HOUSEHOLD WEIGHTS
*<_wgt_>
	gen double wgt=hh_weight
	label var wgt "Household sampling weight"
*</_wgt_>


** STRATA
*<_strata_>
	gen strata=Province_Code
	*replace strata=35 if Resident_Location_Code==3
	label var strata "Strata"
*</_strata_>


** PSU
*<_psu_>
	destring cid, gen(psu)
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
	recode Resident_Location_Code (2=0)(3=0), gen(urban)
	label var urban "Urban/Rural"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban
	notes urban: "AFG 2011" Kuchi replaced as rural
*</_urban_>


**REGIONAL AREAS
** REGIONAL AREA 1 DIGIT ADMN LEVEL
*<_subnatid1_>
	recode Province_Code (17=14) (31=23) (9=16) (21=19) (10=32) (24=34) (33=25) (29=22) (11=6) (23=31) (30=27) (32=24) (28=20) (27=28) (14=9) (15=11) (19=17) (7=12) (6=10) (34=26) (16=13) (12=7) (13=8) (8=33) (20=18) (22=21) (18=15) (25=30) (26=29), gen(subnatid1)
	la de lblsubnatid1 1 "Kabul" 2 "Kapisa" 3 "Parwan" 4 "Wardak" 5 "Logar" 6 "Ghazni" 7 "Paktika" 8 "Paktya" 9 "Khost" 10 "Nangarhar" 11 "Kunarha" 12 "Laghman" 13 "Nuristan" 14 "Badakhshan" 15 "Takhar" 16 "Baghlan" 17 "Kunduz" 18 "Samangan" 19 "Balkh" 20 "Jawzjan" 21 "Sar-I-Poul" 22 "Faryab" 23 "Badghis" 24 "Hirat" 25 "Farah" 26 "Nimroz" 27 "Helmand" 28 "Kandahar" 29 "Zabul" 30 "Uruzgan" 31 "Ghor" 32 "Bamyan" 33 "Panjsher" 34 "Daikindi"
	label var subnatid1 "Region at 1 digit (ADMN1)"
	label values subnatid1 lblsubnatid1
*</_subnatid2_>


** MACRO REGIONAL AREA
*<_subnatid0_>
	recode subnatid1 (1 2 3 4 5 33 = 1) (6/9=2) (10/13=3) (14/17=4) (18/22=5) (23/25=6) (26/30=7) (31 32 34=8), gen(subnatid0)
	la de lblsubnatid0 1 "Central" 2 "South" 3 "East" 4 "Northeast" 5 "North" 6 "West" 7 "Southwest" 8 "West-Central"
	label var subnatid0 "Macro regional areas"
	label values subnatid0 lblsubnatid0
*</_subnatid1_>

		numlabel lblsubnatid1, add mask("# - ")
		decode subnatid1, gen(subnatid1_temp)
		drop subnatid1
		rename subnatid1_temp subnatid1
		
*<_gaul_adm1_code_>
	gen gaul_adm1_code=.
	label var gaul_adm1_code "Subnational ID - highest level"
	replace gaul_adm1_code=2144 if subnatid1=="1 - Kabul"
	replace gaul_adm1_code=2146 if subnatid1=="2 - Kapisa"
	replace gaul_adm1_code=2164 if subnatid1=="3 - Parwan"
	replace gaul_adm1_code=2160 if subnatid1=="4 - Wardak"
	replace gaul_adm1_code=2151 if subnatid1=="5 - Logar"
	replace gaul_adm1_code=2139 if subnatid1=="6 - Ghazni"
	replace gaul_adm1_code=2155 if subnatid1=="7 - Paktika"
	replace gaul_adm1_code=2156 if subnatid1=="8 - Paktya"
	replace gaul_adm1_code=2147 if subnatid1=="9 - Khost"
	replace gaul_adm1_code=2152 if subnatid1=="10 - Nangarhar"
	replace gaul_adm1_code=2148 if subnatid1=="11 - Kunarha"
	replace gaul_adm1_code=2150 if subnatid1=="12 - Laghman"
	replace gaul_adm1_code=2154 if subnatid1=="13 - Nuristan"
	replace gaul_adm1_code=2132 if subnatid1=="14 - Badakhshan"
	replace gaul_adm1_code=2159 if subnatid1=="15 - Takhar"
	replace gaul_adm1_code=2134 if subnatid1=="16 - Baghlan"
	replace gaul_adm1_code=2149 if subnatid1=="17 - Kunduz"
	replace gaul_adm1_code=2157 if subnatid1=="18 - Samangan"
	replace gaul_adm1_code=2135 if subnatid1=="19 - Balkh"
	replace gaul_adm1_code=2143 if subnatid1=="20 - Jawzjan"
	replace gaul_adm1_code=2158 if subnatid1=="21 - Sar-I-Poul"
	replace gaul_adm1_code=2138 if subnatid1=="22 - Faryab"
	replace gaul_adm1_code=2133 if subnatid1=="23 - Badghis"
	replace gaul_adm1_code=2142 if subnatid1=="24 - Hirat"
	replace gaul_adm1_code=2137 if subnatid1=="25 - Farah"
	replace gaul_adm1_code=2153 if subnatid1=="26 - Nimroz"
	replace gaul_adm1_code=2141 if subnatid1=="27 - Helmand"
	replace gaul_adm1_code=2145 if subnatid1=="28 - Kandahar"
	replace gaul_adm1_code=2161 if subnatid1=="29 - Zabul"
	replace gaul_adm1_code=2165 if subnatid1=="30 - Uruzgan"
	replace gaul_adm1_code=2140 if subnatid1=="31 - Ghor"
	replace gaul_adm1_code=2136 if subnatid1=="32 - Bamyan"
	replace gaul_adm1_code=2163 if subnatid1=="33 - Panjsher"
	replace gaul_adm1_code=2162 if subnatid1=="34 - Daikindi"
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
	gen byte ownhouse=.
	replace ownhouse=1 if inlist(Q_4_6,1,2,3,5,7)
	replace ownhouse=0 if inlist(Q_4_6,4,6,8,9)
	label var ownhouse "House ownership"
	la de lblownhouse 0 "No" 1 "Yes"
	label values ownhouse lblownhouse
*</_ownhouse_>


** TENURE OF DWELLING
*<_tenure_>
   gen tenure=.
   replace tenure=1 if inlist(Q_4_6,1,2,3,5,7)
   replace tenure=2 if Q_4_6==8
   replace tenure=3 if tenure!=1 & tenure!=2 & Q_4_6!=.
   label var tenure "Tenure of Dwelling"
   la de lbltenure 1 "Owner" 2"Renter" 3"Other"
   la val tenure lbltenure
*</_tenure_>	

** LANDHOLDING
*<_lanholding_>
   gen landholding=.
   label var landholding "Household owns any land"
   la de lbllandholding 0 "No" 1 "Yes"
   la val landholding lbllandholding
*</_tenure_>	



*ORIGINAL WATER CATEGORIES
*<_water_orig_>
gen water_orig=Q_4_18
la var water_orig "Source of Drinking Water-Original from raw file"
#delimit
la def lblwater_orig 1 "Open well - public"
           2 "Open well - private"
           3 "Hand pump - public"
           4 "Hand pump - private"
           5 "Bored wells (motorised/hand pump)"
           6 "Spring - unprotected"
           7 "Spring - protected"
           8 "Piped  - private"
           9 "Piped - municipal"
          10 "Kariz"
          11 "River, lake, channel, pool, drainage"
          12 "Water tanker"
          13 "Bottled water, mineral water"
          14 "Other, specify";
#delimit cr
la val water_orig lblwater_orig
*</_water_orig_>



*PIPED SOURCE OF WATER
*<_piped_water_>
recode Q_4_18 (8/9=1) (1/7=0) (10/14=0), gen(piped_water)
la var piped_water "Household has access to piped water"
la def lblpiped_water 1 "Yes" 0 "No"
la val piped_water lblpiped_water
*</_piped_water_>


**INTERNATIONAL WATER COMPARISON (Joint Monitoring Program)
*<_water_jmp_>
gen water_jmp=.
replace water_jmp=6 if inlist(Q_4_18,1,2)
replace water_jmp=4 if inlist(Q_4_18,3,4,5)
replace water_jmp=7 if inlist(Q_4_18,7)
replace water_jmp=8 if inlist(Q_4_18,6)
replace water_jmp=1 if inlist(Q_4_18,8)
replace water_jmp=3 if inlist(Q_4_18,9)
replace water_jmp=5 if inlist(Q_4_18,10)
replace water_jmp=12 if inlist(Q_4_18,11)
replace water_jmp=10 if inlist(Q_4_18,12)
replace water_jmp=13 if inlist(Q_4_18,13)
replace water_jmp=14 if inlist(Q_4_18,14)

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
replace sar_improved_water=1 if inlist(water_jmp,1,2,3,4,5,7,9,13)
replace sar_improved_water=0 if inlist(water_jmp, 6,8,10,11,12,14)
replace water_jmp=.
la def lblsar_improved_water 1 "Improved" 0 "Unimproved"
la var sar_improved_water "Improved source of drinking water-using country-specific definitions"
la val sar_improved_water lblsar_improved_water
*</_sar_improved_water_>


*ORIGINAL WATER CATEGORIES
*<_water_original_>
clonevar j=Q_4_18
#delimit
la def lblwater_original 	1 "Open well - public"
							2 "Open well - private"
							3 "Hand pump - public"
							4 "Hand pump - private"
							5 "Bored wells (motorised/hand pump)"
							6 "Spring - unprotected"
							7 "Spring - protected"
							8 "Piped  - private"
							9 "Piped - municipal"
							10 "Kariz"
							11 "River, lake, channel, pool, drainage"
							12 "Water tanker"
							13 "Bottled water, mineral water"
							14 "Other, specify";
#delimit cr
la val j lblwater_original		
decode j, gen(water_original)
drop j
la var water_original "Source of Drinking Water-Original from raw file"
*</_water_original_>
				   

	** WATER SOURCE
	*<_water_source_>
		gen water_source=.
		replace water_source=10 if Q_4_18==1
		replace water_source=10 if Q_4_18==2
		replace water_source=4 if Q_4_18==3
		replace water_source=4 if Q_4_18==4
		replace water_source=4 if Q_4_18==5
		replace water_source=9 if Q_4_18==6
		replace water_source=6 if Q_4_18==7
		replace water_source=1 if Q_4_18==8
		replace water_source=3 if Q_4_18==9
		replace water_source=5 if Q_4_18==10
		replace water_source=13 if Q_4_18==11
		replace water_source=12 if Q_4_18==12
		replace water_source=7 if Q_4_18==13
		replace water_source=14 if Q_4_18==14
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
		gen pipedwater_acc=0 if inlist(Q_4_18,1,2,3,4,5,6,7,10,11,12,13,14) // Asuming other is not piped water
		replace pipedwater_acc=3 if inlist(Q_4_18,8,9)
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
	recode Q_4_12_Electic_Grid (2=0), gen(electricity)
	label var electricity "Electricity main source"
	la de lblelectricity 0 "No" 1 "Yes"
	label values electricity lblelectricity
*</_electricity_>

*ORIGINAL TOILET CATEGORIES
*<_toilet_orig_>
gen toilet_orig=Q_4_16
la var toilet_orig "Access to sanitation facility-Original from raw file"
#delimit
la def lbltoilet_orig 1 "Open pit"
					  2 "Traditional covered latrine"
					  3 "Improved latrine"
					  4 "Flush latrine"
					  5 "None (open field, bush) or sahrahi"
					  6 "Dearan (not pit)"
					  7 "Other";
#delimit cr
la val toilet_orig lbltoilet_orig
*</_toilet_orig_>


*SEWAGE TOILET
*<_sewage_toilet_>
recode Q_4_16 (4=1) (1 2 3 5 6 7=0), gen(sewage_toilet)
la var sewage_toilet "Household has access to sewage toilet"
la def lblsewage_toilet 1 "Yes" 0 "No"
la val sewage_toilet lblsewage_toilet
note sewage_toilet: "AFG 2011" toilet was created if hh had public connection
*</_sewage_toilet_>


**INTERNATIONAL SANITATION COMPARISON (Joint Monitoring Program)
*<_toilet_jmp_>
gen toilet_jmp=.
replace toilet_jmp=12 if Q_4_16==5
replace toilet_jmp=4 if Q_4_16==6
replace toilet_jmp=8 if Q_4_16==1
replace toilet_jmp=7 if Q_4_16==2
replace toilet_jmp=6 if Q_4_16==3
replace toilet_jmp=3 if Q_4_16==4
replace toilet_jmp=13 if Q_4_16==7

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
replace sar_improved_toilet=1 if inlist(toilet_jmp,1,2,3,6,7,9)
replace sar_improved_toilet=0 if inlist(toilet_jmp,4,5,8,10,11,12,13)
replace sar_improved_toilet=0 if Q_4_17==1
replace toilet_jmp=.
la def lblsar_improved_toilet 1 "Improved" 0 "Unimproved"
la var sar_improved_toilet "Improved type of sanitation facility-using country-specific definitions"
la val sar_improved_toilet lblsar_improved_toilet
*</_sar_improved_toilet_>


	** ORIGINAL SANITATION CATEGORIES 
	*<_sanitation_original_>
		clonevar j=Q_4_16
		#delimit
		la def lblsanitation_original   1 "Open pit"
										2 "Traditional covered latrine"
										3 "Improved latrine"
										4 "Flush latrine"
										5 "None (open field, bush) or sahrahi"
										6 "Dearan (not pit)"
										7 "Other";
		#delimit cr
		la val j lblsanitation_original
		decode j, gen(sanitation_original)
		drop j
		la var sanitation_original "Access to sanitation facility-Original from raw file"
	*</_sanitation_original_>


	** SANITATION SOURCE
	*<_sanitation_source_>
		gen sanitation_source=.
		replace sanitation_source=10 if Q_4_16==1
		replace sanitation_source=6 if Q_4_16==2
		replace sanitation_source=5 if Q_4_16==3
		replace sanitation_source=4 if Q_4_16==4
		replace sanitation_source=13 if Q_4_16==5
		replace sanitation_source=9 if Q_4_16==6
		replace sanitation_source=14 if Q_4_16==7
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
	gen z=1 
	*replace z=0 if Q_3_3==11
	bys hhid: egen hsize=sum(z) 
	label var hsize "Household size"
	note hsize: "AFG 2011" variable takes all categories since there is no way to identify paying boarders and domestic servants
*</_hsize_>

**POPULATION WEIGHT
*<_pop_wgt_>
	gen pop_wgt=wgt*hsize
	la var pop_wgt "Population weight"
*</_pop_wgt_>


** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
*<_relationharm_>
	gen byte relationharm=Q_3_3
	recode relationharm (6=4) (4 5 7 8 9 10=5) (11=6)
	label var relationharm "Relationship to the head of household"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Non-relatives"
	label values relationharm  lblrelationharm
*</_relationharm_>

** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
*<_relationcs_>

	gen byte relationcs=Q_3_3
	la var relationcs "Relationship to the head of household country/region specific"
	la define lblrelationcs 1 "Household head" 2 "Wife or husband" 3 "Son or daugher" 4 "Son/daughter-in-law" 5 "Grandchild" 6 "Father or mother" 7 "Nephew or niece" 8 "Brother or sister" 9 "Brother/sister-in-law" 10 "Other relative" 11 "Unrelated member"
	label values relationcs lblrelationcs
*</_relationcs_>


** GENDER
*<_male_>
	gen byte male=Q_3_4
	recode male (2=0)
	label var male "Sex of household member"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale
*</_male_>


** AGE
*<_age_>
	gen byte age=Q_3_5
	replace age=98 if age>=98
	label var age "Age of individual"
*</_age_>


** SOCIAL GROUP
*<_soc_>
	gen byte soc=.
	label var soc "Social group"
	la de lblsoc 1 ""
	label values soc lblsoc
*</_soc_>


** MARITAL STATUS
*<_marital_>
	gen byte marital=Q_3_6
	recode marital (4 5=2) (2=4) (3= 5) 
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
	gen byte ed_mod_age=6
	label var ed_mod_age "Education module application age"
*</_ed_mod_age_>



** CURRENTLY AT SCHOOL
*<_atschool_>
	gen byte atschool=Q_12_8
	recode atschool (2=0)
	replace atschool=0 if Q_12_5==2
	replace atschool = . if age < 6
	replace atschool = . if age > 24
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool
	notes atschool: "AFG 2011" question related to attendance to school was used
	notes atschool: "AFG 2011" the upper range of age for attendace was set in the questionnaire

*</_atschool_>


** CAN READ AND WRITE
*<_literacy_>
	gen byte literacy=Q_12_3
	recode literacy (2=0)
	replace literacy=. if age<6
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
*</_literacy_>


** YEARS OF EDUCATION COMPLETED
*<_educy_>
	gen  educy = Q_12_7
	replace educy=6  if Q_12_6==2 & educy==0
	replace educy=9  if Q_12_6==3 & educy==0
	replace educy=12 if Q_12_6==4 & educy==0
	replace educy=12 if Q_12_6==5 & educy==0
	replace educy=16 if Q_12_6==6 & educy==0
	replace educy=12 if Q_12_6==7 & educy==0
	replace educy=12 if Q_12_6==9 & educy==0
	*** assign a zero to those who never attended school ***
	replace  educy = 0 if Q_12_5==2
	replace educy=. if educy>age+1 & educy!=. & age!=.
	label var educy "Years of education"
*</_educy_>

	
** EDUCATION LEVEL 7 CATEGORIES
*<_educat7_>

	gen educat7=.
	replace educat7=1 if Q_12_5==2
	replace educat7=2 if Q_12_6==1 & Q_12_7<6 & Q_12_7!=.
	replace educat7=3 if (Q_12_6==1 & Q_12_7==6 ) 
	replace educat7=4 if Q_12_6==2 | (Q_12_6==3 & Q_12_7<12 & Q_12_7!=.)
	replace educat7=5 if Q_12_6==3 & Q_12_7==12
	replace educat7=7 if Q_12_6>3 & Q_12_6!=.
	replace educat7=2 if Q_12_6==8 | Q_12_6==10
	replace educat7=6 if Q_12_6==4 | Q_12_6==7
	la var educat7 "Level of education 7 categories"
	label define lbleducat7 1 "No education" 2 "Primary incomplete" 3 "Primary complete" ///
	4 "Secondary incomplete" 5 "Secondary complete" 6 "Higher than secondary but not university" /// 
	7 "University incomplete or complete" 8 "Other" 9 "Not classified"
	label values educat7 lbleducat7
*</_educat7_>


** EDUCATION LEVEL 5 CATEGORIES
*<_educat5_>
	gen educat5=.
	replace educat5=1 if Q_12_5==2
	replace educat5=2 if Q_12_6==1 & Q_12_7<6 &Q_12_7!=.
	replace educat5=3 if (Q_12_6==1 & Q_12_7==6 ) | Q_12_6==2 | (Q_12_6==3 & Q_12_7<12 & Q_12_7!=.)
	replace educat5=4 if Q_12_6==3 & Q_12_7==12
	replace educat5=5 if Q_12_6>3 & Q_12_6!=.
	replace educat5=2 if Q_12_6==8 | Q_12_6==10
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
	replace educat4=2 if educat7>=2 & educat7<=3
	replace educat4=3 if educat7>=4 & educat7<=5
	replace educat4=4 if educat7>=6 & educat7<=7
	label var educat4 "Level of education 4 categories"
	label define lbleducat4 1 "No education" 2 "Primary (complete or incomplete)" ///
	3 "Secondary (complete or incomplete)" 4 "Tertiary (complete or incomplete)"
	label values educat4 lbleducat4
*</_educat4_>


** EVER ATTENDED SCHOOL
*<_everattend_>
	gen byte everattend=Q_12_5
	replace everattend = 1 if atschool==1
	recode everattend (2=0)
	replace everattend = . if age < 6
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
notes _dta: "AFG 2011" No comparability in labor market outcomes from previous/following year. Changes in screening process and recall period of variables


** LABOR MODULE AGE
*<_lb_mod_age_>
 gen byte lb_mod_age=14
	label var lb_mod_age "Labor module application age"
*</_lb_mod_age_>

** LABOR STATUS
*<_lstatus_>
	gen lstatus=1 if Q_8_2==1
	replace lstatus=1 if Q_8_3==1
	replace lstatus=2 if Q_8_2==2
	replace lstatus=2 if Q_8_6==1 | Q_8_7==8 | Q_8_7==9
	*replace lstatus=1 if Q_8_4>=1 & Q_8_4<=2
	replace lstatus=3 if Q_8_5==2 | Q_8_6==2
	*replace lstatus=2 if Q_8_5==1 & lstatus!=1
	replace lstatus=. if age<14
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
	recode Q_8_11 (1/3=1) (5=3) (6=2), gen(empstat)
	replace empstat=. if lstatus!=1
	label var empstat "Employment status"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee/Family worker" 3 "Employer" 4 "Self-employed" 5 "Other, not classificable"
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
	gen byte njobs=.
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
	gen byte ocusec=1 if Q_8_11==3
	replace ocusec=2 if Q_8_11==2
	replace ocusec=. if lstatus!=1
	label var ocusec "Sector of activity"
	la de lblocusec 1 "Public, state owned, NGO, government, army" 2 "Private"
	label values ocusec lblocusec
*</_ocusec_>


** REASONS NOT IN THE LABOR FORCE
*<_nlfreason_>
	recode Q_8_7 (5=4) (6=1) (7 10/13=5) (8/9=.), gen(nlfreason)
	replace nlfreason=. if lstatus!=3
	la de lblnlfreason 1 "Student" 2 "Housewife" 3 "Retired" 4 "Disable" 5 "Other"
	label values nlfreason lblnlfreason
	label var nlfreason "Reason not in the labor force"
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
	gen industry_orig=Q_8_9
	label define lblindustry_orig 1 `"Agriculture"', modify
	label define lblindustry_orig 2 `"Livestock"', modify
	label define lblindustry_orig 3 `"Manufacturing/processing (handicraft, food processing, tailoring, etc)"', modify
	label define lblindustry_orig 4 `"Construction (e.g roads, buildings) "', modify
	label define lblindustry_orig 5 `"Wholesale and retail trade"', modify
	label define lblindustry_orig 6 `"Transportation and communication"', modify
	label define lblindustry_orig 7 `"Health"', modify
	label define lblindustry_orig 8 `"Education"', modify
	label define lblindustry_orig 9 `"Other governement services"', modify
	label define lblindustry_orig 10 `"UN/NGOs"', modify
	label define lblindustry_orig 11 "Other services", modify
	label val industry_orig lblindustry_orig
	replace industry_orig=. if lstatus!=1
	la var industry_orig "Original industry code"
*</_industry_orig_>

** INDUSTRY CLASSIFICATION
*<_industry_>
	gen byte industry=Q_8_9
	recode industry (1/2=1) (4=5) (5=6) (6=7) (7=10) (8/9=9) (10/11=10)
	replace industry=. if lstatus!=1
	label var industry "1 digit industry classification"
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industry lblindustry
*</_industry_>

**ORIGINAL OCCUPATION CLASSIFICATION
*<_occup_orig_>
	gen occup_orig=Q_8_10
	label define lbloccup_orig 1 `"Farming"', modify
	label define lbloccup_orig 2 `"Shepherding"', modify
	label define lbloccup_orig 3 `"Sales and trade"', modify
	label define lbloccup_orig 4 `"Construction and mining"', modify
	label define lbloccup_orig 5 `"Food processing"', modify
	label define lbloccup_orig 6 `"Metal and wood work"', modify
	label define lbloccup_orig 7 `"Handicraft work"', modify
	label define lbloccup_orig 8 `"Plant and machine operating"', modify
	label define lbloccup_orig 9 `"Driver (car, truck, bus, taxi)"', modify
	label define lbloccup_orig 10 `"Health workers"', modify
	label define lbloccup_orig 11 `"Teaching"', modify
	label define lbloccup_orig 12 `"Security work"', modify
	label define lbloccup_orig 13 `"Other service work"', modify
	label define lbloccup_orig 14 `"Other work"', modify
	la val occup_orig lbloccup_orig
	replace occup_orig=. if lstatus!=1
	la var occup_orig "Original occupation code"
	notes occup_orig: "AFG 2011" occupation levels are country specific and do not follow international catalogue
*</_occup_orig_>



** OCCUPATION CLASSIFICATION
*<_occup_>
	recode Q_8_10 ( 10 11 =2) (3 12 13=5) (5 6 7=7) (8 9=8) (1 2 4=9)  (14=99), gen(occup)
	replace occup=. if lstatus!=1
	label var occup "1 digit occupational classification"
	la de lbloccup 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup lbloccup
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
	gen whours = (Q_8_12 * Q_8_13)
	replace whours = . if lstatus != 1
	replace whours  = 96 if whours  > 96 & whours < .
	replace whours = . if whours  > 168
	label var whours "Hours of work in last week"
*</_whours_>


** WAGES
*<_wage_>
	gen double wage=.
	replace wage=. if lstatus!=1
	replace wage=0 if empstat==2 & wage!=.
	label var wage "Last wage payment"
*</_wage_>


** WAGES TIME UNIT
*<_unitwage_>
	gen byte unitwage=.
	replace unitwage=. if lstatus!=1 & empstat!=1
	replace unitwage=. if wage==.
	label var unitwage "Last wages time unit"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Quarterly" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage lblunitwage
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

foreach var in union socialsec healthins contract unitwage wage whours firmsize_u firmsize_l occup_orig occup industry_orig industry unempldur_u unempldur_l nlfreason ocusec njobs empstat lstatus{
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

	gen byte landphone=.
	label var landphone "Household has landphone"
	la de lbllandphone 0 "No" 1 "Yes"
	label values landphone lbllandphone
*</_landphone_>


** CEL PHONE
*<_cellphone_>
	recode Q_7_6_Mobile_Own (2/13=1), gen(cellphone)
	label var cellphone "Household has Cell phone"
	la de lblcellphone 0 "No" 1 "Yes"
	label values cellphone lblcellphone
*</_cellphone_>


** COMPUTER
*<_computer_>
	gen byte computer=.
	label var computer "Household has Computer"
	la de lblcomputer 0 "No" 1 "Yes"
	label values computer lblcomputer
*</_computer_>

** RADIO
*<_radio_>
	gen radio=Q_7_1_Radio>0 if Q_7_1_Radio<.
	label var radio "Household has radio"
	la de lblradio 0 "No" 1 "Yes"
	label val radio lblradio
*</_radio_>

** TELEVISION
*<_television_>
	gen television=Q_7_1_TV>0 if Q_7_1_TV<.
	label var television "Household has Television"
	la de lbltelevision 0 "No" 1 "Yes"
	label val television lbltelevision
*</_television>

** FAN
*<_fan_>
	gen fan=Q_7_1_Electrice_Fan>0 if Q_7_1_Electrice_Fan<.
	label var fan "Household has Fan"
	la de lblfan 0 "No" 1 "Yes"
	label val fan lblfan
*</_fan>

** SEWING MACHINE
*<_sewingmachine_>
	gen sewingmachine=Q_7_1_Sewing_Machine>0 if Q_7_1_Sewing_Machine<. 
	label var sewingmachine "Household has Sewing machine"
	la de lblsewingmachine 0 "No" 1 "Yes"
	label val sewingmachine lblsewingmachine
*</_sewingmachine>

** WASHING MACHINE
*<_washingmachine_>
	gen washingmachine=.
	label var washingmachine "Household has Washing machine"
	la de lblwashingmachine 0 "No" 1 "Yes"
	label val washingmachine lblwashingmachine
*</_washingmachine>

** REFRIGERATOR
*<_refrigerator_>
	gen refrigerator=Q_7_1_Refrigerator>0 if Q_7_1_Refrigerator<.
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
	gen bicycle=Q_7_1_Bicycle>0 if Q_7_1_Bicycle<.
	label var bicycle "Household has Bicycle"
	la de lblbycicle 0 "No" 1 "Yes"
	label val bicycle lblbycicle
*</_bycicle>

** MOTORCYCLE
*<_motorcycle_>
	gen motorcycle=Q_7_1_Motorcycle>0 if Q_7_1_Motorcycle<.
	label var motorcycle "Household has Motorcycle"
	la de lblmotorcycle 0 "No" 1 "Yes"
	label val motorcycle lblmotorcycle
*</_motorcycle>

** MOTOR CAR
*<_motorcar_>
	gen motorcar=Q_7_1_Car>0 if Q_7_1_Car<.
	label var motorcar "Household has Motor car "
	la de lblmotorcar 0 "No" 1 "Yes"
	label val motorcar lblmotorcar
*</_motorcar>

** COW
*<_cow_>
	gen cow=.
	label var cow "Household has cow"
	la de lblcow 0 "No" 1 "Yes"
	label val cow lblcow
*</_cow>

** BUFFALO
*<_buffalo_>
	gen buffalo=.
	label var buffalo "Household has buffalo"
	la de lblbuffalo 0 "No" 1 "Yes"
	label val buffalo lblbuffalo
*</_buffalo>

** CHICKEN
*<_chicken_>
	gen chicken=Q_5_2_Chickens>0 if Q_5_2_Chickens<.
	label var chicken "Household has chicken"
	la de lblchicken 0 "No" 1 "Yes"
	label val chicken lblchicken
*</_chicken>


/*****************************************************************************************************
*                                                                                                    *
                                   WELFARE MODULE
*                                                                                                    *
*****************************************************************************************************/
 notes _dta: "AFG 2011" Helmand and Khost provinces removed from welfare aggregate. This hinders comparability across time

 ** SPATIAL DEFLATOR
*<_spdef_>
	gen spdef=pexnom_t/ pexadj_t
	la var spdef "Spatial deflator"
*</_spdef_>

	
** WELFARE
*<_welfare_>
	sum pline [w=hh_weight]
	gen PLN_ps=`r(mean)'
	gen def_ps=pline/PLN_ps
	gen welfare=(pexnom_t/def_ps)  /*the plines are in nominal terms in 2011*/
	replace welfare=. if pov_sample==0
	la var welfare "Welfare aggregate"
*</_welfare_>

*<_welfarenom_>
	gen welfarenom=pexnom_t
	replace welfarenom=. if pov_sample==0
	replace welfarenom=. if welfare==.
	la var welfarenom "Welfare aggregate in nominal terms"
*</_welfarenom_>

*<_welfaredef_>
	gen welfaredef=welfare
	replace welfaredef=. if pov_sample==0
	la var welfaredef "Welfare aggregate spatially deflated"
*</_welfaredef_>

*<_welfshprosperity_>
	gen welfshprosperity=welfare
	replace welfshprosperity=. if pov_sample==0
	la var welfshprosperity "Welfare aggregate for shared prosperity"
*</_welfshprosperity_>

	gen welfshprtype="EXP"
	label var welfshprtype "Welfare type for shared prosperity indicator (income, consumption or expenditure)"

*<_welfaretype_>
	gen welfaretype="EXP"
	la var welfaretype "Type of welfare measure (income, consumption or expenditure) for welfare, welfarenom, welfaredef"
*</_welfaretype_>

*<_welfareother_>
	gen welfareother=.
	la var welfareother "Welfare Aggregate if different welfare type is used from welfare, welfarenom, welfaredef"
	
*</_welfareother_>

*<_welfareothertype_>
	gen welfareothertype="INC"
	la var welfareothertype "Type of welfare measure (income, consumption or expenditure) for welfareother"
*</_welfareothertype_>

*<_welfarenat_>
	gen welfarenat=welfare
	replace welfarenat=. if pov_sample==0
	la var welfarenat "Welfare aggregate for national poverty"
*</_welfarenat_>	
	
	foreach var in welfare welfarenom welfaredef welfshprosperit welfareother welfarenat{
	replace `var'=. if subnatid2==9 | subnatid2==27
	}

*QUINTILE, DECILE AND FOOD/NON-FOOD SHARES OF CONSUMPTION AGGREGATE
	levelsof year, loc(y)
	merge m:1 idh using "$shares\\AFG_fnf_`y'", keepusing (food_share nfood_share quintile_cons_aggregate decile_cons_aggregate) gen(_merge1)
	drop _merge1
	
	
/*****************************************************************************************************
*                                                                                                    *
                                   NATIONAL POVERTY
*                                                                                                    *
*****************************************************************************************************/

** POVERTY LINE (NATIONAL)
*<_pline_nat_>
	sum pline [w=hh_weight] 
	gen pline_nat=`r(mean)'
	label variable pline_nat "Poverty Line (National)"
*</_pline_nat_>


** HEADCOUNT RATIO (NATIONAL)
*<_poor_nat_>
	gen poor_nat=(welfare)<pline_nat & welfare!=.
	la var poor_nat "People below Poverty Line (National)"
	la define poor_nat 0 "Not Poor" 1 "Poor"
	la values poor_nat poor_nat
	replace poor_nat=. if pov_sample==0
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
	replace poor_int=. if pov_sample==0
	la var poor_int "People below Poverty Line (Povcalnet)"
	la define poor_int 0 "Not Poor" 1 "Poor"
	la values poor_int poor_int
*</_poor_int_>


qui su ppp
if r(mean)==0{
replace pline_int=.
replace poor_int=.
}
	
/*****************************************************************************************************
*                                                                                                    *
                                   FINAL STEPS
*                                                                                                    *
*****************************************************************************************************/
do "$fixlabels\fixlabels", nostop

** KEEP VARIABLES - ALL

	keep countrycode year survey idh idp wgt pop_wgt strata psu vermast veralt urban int_month int_year fieldwork subnatid0  ///
		subnatid1 subnatid2 subnatid3 gaul_adm1_code ownhouse landholding tenure water_orig piped_water water_jmp sar_improved_water  electricity toilet_orig sewage_toilet toilet_jmp sar_improved_toilet  landphone cellphone ///
	     computer internet hsize relationharm relationcs male age soc marital ed_mod_age everattend ///
	     water_original water_source improved_water pipedwater_acc watertype_quest sanitation_original sanitation_source improved_sanitation toilet_acc ///
	     atschool electricity literacy educy educat4 educat5 educat7 lb_mod_age lstatus lstatus_year empstat empstat_year njobs njobs_year ///
	     ocusec nlfreason unempldur_l unempldur_u industry_orig industry occup_orig occup firmsize_l firmsize_u whours wage ///
		  unitwage empstat_2 empstat_2_year industry_2 industry_orig_2 occup_2 wage_2 unitwage_2 contract healthins socialsec union rbirth_juris rbirth rprevious_juris rprevious yrmove ///
		 landphone cellphone computer radio television fan sewingmachine washingmachine refrigerator lamp bicycle motorcycle motorcar cow buffalo chicken  ///
		 pline_nat pline_int poor_nat poor_int spdef cpi ppp cpiperiod welfare welfshprosperity welfarenom welfaredef welfarenat food_share nfood_share quintile_cons_aggregate decile_cons_aggregate welfareother welfaretype welfareothertype  
		 
** ORDER VARIABLES

	order countrycode year survey idh idp wgt pop_wgt strata psu vermast veralt urban int_month int_year fieldwork subnatid0 ///
		subnatid1 subnatid2 subnatid3 gaul_adm1_code ownhouse landholding tenure water_orig piped_water water_jmp sar_improved_water water_original ///
		water_source improved_water pipedwater_acc watertype_quest electricity toilet_orig sewage_toilet toilet_jmp sar_improved_toilet ///
		sanitation_original sanitation_source improved_sanitation toilet_acc landphone cellphone ///
	     computer internet hsize relationharm relationcs male age soc marital ed_mod_age everattend ///
	     atschool electricity literacy educy educat4 educat5 educat7 lb_mod_age lstatus lstatus_year empstat empstat_year njobs njobs_year ///
	     ocusec nlfreason unempldur_l unempldur_u industry_orig industry occup_orig occup firmsize_l firmsize_u whours wage ///
		  unitwage empstat_2 empstat_2_year industry_2 industry_orig_2 occup_2 wage_2 unitwage_2 contract healthins socialsec union rbirth_juris rbirth rprevious_juris rprevious yrmove ///
		 landphone cellphone computer radio television fan sewingmachine washingmachine refrigerator lamp bicycle motorcycle motorcar cow buffalo chicken  ///
		 pline_nat pline_int poor_nat poor_int spdef cpi ppp cpiperiod welfare welfshprosperity welfarenom welfaredef welfarenat ///
		 food_share nfood_share quintile_cons_aggregate decile_cons_aggregate welfareother welfaretype welfareothertype  

	
	
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
	saveold "`output'\Data\Harmonized\AFG_2011_NRVA_v01_M_v05_A_SARMD-FULL_IND.dta", replace version(12)
	saveold "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\AFG_2011_NRVA_v01_M_v05_A_SARMD-FULL_IND.dta", replace version(12)

	notes
	
	log close
	
*********************************************************************************************************************************	
******RENAME COMPARABLE VARIABLES AND SAVE THEM IN _SARMD. UNCOMPARABLE VARIALBES ACROSS TIME SHOULD BE FOUND IN _SARMD-FULL*****
*********************************************************************************************************************************

loc var  lb_mod_age lstatus lstatus_year empstat empstat_year njobs njobs_year ///
	     ocusec nlfreason unempldur_l unempldur_u industry_orig industry occup_orig occup firmsize_l firmsize_u whours wage ///
		  unitwage empstat_2 empstat_2_year industry_2 industry_orig_2 occup_2 wage_2 unitwage_2 contract healthins socialsec ///
		  union sewage_toilet toilet_jmp sar_improved_toilet piped_water water_jmp sar_improved_water

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
	
	note _dta: "BGD 2011" Variables NAMED with "v2" are those not compatible with latest round (2013). ///

	saveold "`output'\Data\Harmonized\AFG_2011_NRVA_v01_M_v05_A_SARMD_IND.dta", replace version(12)
	saveold "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\AFG_2011_NRVA_v01_M_v05_A_SARMD_IND.dta", replace version(12)
	
	
******************************  END OF DO-FILE  *****************************************************/
