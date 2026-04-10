/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                                   SOUTH ASIA MICRO DATABASE                                      **
**                                                                                                  **
** COUNTRY	India
** COUNTRY ISO CODE	IND
** YEAR	1993
** SURVEY NAME	SOCIO-ECONOMIC SURVEY  FIFTIETH ROUND JULY 1993-JUNE 1994
*	HOUSEHOLD SCHEDULE 1 
** SURVEY AGENCY	GOVERNMENT OF INDIA NATIONAL SAMPLE SURVEY ORGANISATION
** CREATED  BY Triana Yentzen
** MODIFIED BY Fernando Enrique Morales Velandia
** Modified	 9/12/2017 

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
	local input "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\IND\IND_1993_NSS50-SCH1.0\IND_1993_NSS50-SCH1.0_v01_M"
	local output "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\IND\IND_1993_NSS50-SCH1.0\IND_1993_NSS50-SCH1.0_v01_M_v04_A_SARMD"
	glo pricedata "D:\SOUTH ASIA MICRO DATABASE\CPI\cpi_ppp_sarmd_weighted.dta"
	glo fixlabels "D:\SOUTH ASIA MICRO DATABASE\APPS\DATA CHECK\Label fixing"

	
** LOG FILE
	log using "`output'\Doc\Technical\IND_1993_NSS-SCH1_v01_M_v04_A_SARMD.log",replace



/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/


** DATABASE ASSEMBLENT
	
	* PREPARE DATASETS

	use "`input'\Data\Stata\NSS50_Sch1_bk4.dta", clear
	order sector stratum subround FSU_No secstgstr hhno pid
	sort subsample sector stratum subround FSU_No secstgstr hhno pid

	ren pid indid
	drop hhid
	
	order FSU_No secstgstr hhno indid
	sort FSU_No secstgstr hhno indid
	
	ren FSU_No fsu
	ren secstgstr secondstage
	ren subround subrnd
	
	tempfile roster
	save `roster'
	
	use "`input'\Data\Stata\NSS50_Sch1_bk_1_31.dta", clear
	order sector stratum subround FSU_No secstgstr hhno
	sort subsample sector stratum subround FSU_No secstgstr hhno

	drop hhid
	
	order FSU_No secstgstr hhno
	sort FSU_No secstgstr hhno
	
	ren FSU_No fsu
	ren secstgstr secondstage
	ren subround subrnd
	
	tempfile household
	save `household'
	

	use "`input'\Data\Stata\NSS50_Sch1_bk12_13.dta", clear
	order sector stratum subround FSU_No secstgstr hhno
	sort subsample sector stratum subround FSU_No secstgstr hhno

	drop hhid
	
	order FSU_No secstgstr hhno
	sort FSU_No secstgstr hhno
	
	ren FSU_No fsu
	ren secstgstr secondstage
	ren subround subrnd
	
	tempfile dwelling
	save `dwelling'
	
	*Assets
	use "`input'\Data\Stata\NSS50_Sch1_bk91.dta", clear
	order sector stratum subround FSU_No secstgstr hhno
	sort subsample sector stratum subround FSU_No secstgstr hhno

	drop hhid
	
	order FSU_No secstgstr hhno
	sort FSU_No secstgstr hhno
	
	ren FSU_No fsu
	ren secstgstr secondstage
	ren subround subrnd
	
	keep fsu secondstage hhno S1B91_v1 S1B91_v3
	keep if inlist(S1B91_v1, 711, 713, 750, 751, 755, 756, 757,761, 770, 771, 772)
	reshape wide S1B91_v3, i(fsu secondstage hhno) j(S1B91_v1)
	tempfile assets
	save `assets'
	
	*Animals
	use "`input'\Data\Stata\NSS50_Sch1_bk32.dta", clear
	order sector stratum subround FSU_No secstgstr hhno
	sort subsample sector stratum subround FSU_No secstgstr hhno

	drop hhid
	
	order FSU_No secstgstr hhno
	sort FSU_No secstgstr hhno
	
	ren FSU_No fsu
	ren secstgstr secondstage
	ren subround subrnd
	keep fsu secondstage hhno S1B32_v4
	tempfile animals
	save `animals'

	
	* COMBINE DATASETS
	
	use "`input'\Data\Stata\poverty50.dta", clear

	su pline_ind_93 [w=pwt]
	gen pline_mrp=r(mean)

	gen mpce_mrp_real=mpce_mrp*pline_mrp/pline

	sor hhid
	
*	gen pline_urp_sector=.
*	replace pline_urp_sector=236.6 if sector==1
*	replace pline_urp_sector=318.2 if sector==2

	su pline [w=pwt]
	gen pline_urp=r(mean)

	gen mpce_urp_real=mpce_urp*(pline_urp/pline)
	la var mpce_urp_real "Real PC Monthly Consumption (URP)"
	ren pline_ind_93 pline_mrp_sector

	keep hhsize hhid fsu secondstage hhno mpce_urp mpce_mrp mpce_urp_real mpce_mrp_real pline_urp pline_mrp pline_mrp_sector pline pwt

	order hhid fsu secondstage hhno mpce_urp mpce_mrp mpce_urp_real mpce_mrp_real pline_urp pline_mrp pline_mrp_sector pline pwt hhsize

	sort fsu secondstage hhno
	
	merge 1:m fsu secondstage hhno using `roster'
	drop if _merge==2
	drop _merge 
	
	merge m:1 fsu secondstage hhno using `household'
	drop if _merge==2
	drop _merge 
	
	merge m:1 fsu secondstage hhno using `dwelling'
	drop if _merge==2
	drop _merge 
	
	merge m:1 fsu secondstage hhno using `assets'
	drop if _merge==2
	drop _merge 
	
	merge m:1 fsu secondstage hhno using `animals'
	drop if _merge==2
	drop _merge 


/*****************************************************************************************************
*                                                                                                    *
                                   * STANDARD SURVEY MODULE
*                                                                                                    *
*****************************************************************************************************/

	
** COUNTRY
*<_countrycode_>
	gen str4 countrycode="IND"
	label var countrycode "Country code"
*</_countrycode_>


** YEAR
*<_year_>
	gen int year=1993
	label var year "Year of survey"
*</_year_>

** SURVEY NAME 
*<_survey_>
	gen str survey="NSS-SCH1"
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
	generate idh=string(hhid, "%15.0f")
	label var idh "Household id"
*</_idh_>


** INDIVIDUAL IDENTIFICATION NUMBER
*<_idp_>

	egen str idp=concat(idh indid), punct(-)	
	label var idp "Individual id"
*</_idp_>
	isid idp


** HOUSEHOLD WEIGHTS
*<_wgt_>
	gen wgt=MLT_combined/100
	label var wgt "Household sampling weight"
*</_wgt_>

** STRATA
*<_strata_>
	gen strata=stratum
	label var strata "Strata"
*</_strata_>

** PSU
*<_psu_>
	gen psu=fsu
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
	gen urban=sector
	recode urb (2=1) (1=0)
	label var urban "Urban/Rural"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban
*</_urban_>

/*
**REGIONAL AREAS
	recode state (1 2 3 4 6 8 = 1) (5 7 9 10 23 = 2) (12/18 = 3) (11 19 20 21 22 35 = 4) ( 24 25 26 27 30 = 5) (28 29 31 32 33 34 = 6), gen(subnatid1)
	label define lblsubnatid1 1 "Northern" 2 "North-Central" 3 "North-Eastern" 4 "Eastern" 5 "Western" 6 "Southern"
	label values subnatid1 lblsubnatid1
*</_subnatid1_>*/
gen subnatid2=.
	label var subnatid2 "Region at 2 digit (ADMN2)"
	label values subnatid2 lblsubnatid2
*</_subnatid1_>

** REGIONAL AREA 1 DIGIT ADMN LEVEL
*<_subnatid1_>

    ren state state_50
    g state=.
	replace state=1 if state_50==10
	replace state=2 if state_50==9
    replace state=3 if state_50==20
	replace state=4 if state_50==28
	replace state=6 if state_50==8
	replace state=7 if state_50==31
	replace state=8 if state_50==21
	replace state=9 if state_50==25
	replace state=10 if state_50==5
	replace state=11 if state_50==22
	replace state=12 if state_50==3
	replace state=13 if state_50==18
	replace state=14 if state_50==15
	replace state=15 if state_50==17
	replace state=16 if state_50==24
	replace state=17 if state_50==16
	replace state=18 if state_50==4
	replace state=19 if state_50==26
	replace state=21 if state_50==19
	replace state=23 if state_50==13
	replace state=24 if state_50==7
	replace state=25 if state_50==30
	replace state=26 if state_50==29
	replace state=27 if state_50==14
	replace state=28 if state_50==2
	replace state=29 if state_50==11
	replace state=30 if state_50==6
	replace state=31 if state_50==32
	replace state=32 if state_50==12
	replace state=33 if state_50==23
	replace state=34 if state_50==33
	replace state=35 if state_50==27
	
	gen subnatid1=state
	label define lblsubnatid1 01 "Jammu & Kashmir" 02 "Himachal Pradesh" 03 "Punjab" 4 "Chandigarh"          ///
	5 "Uttaranchal" 06 "Haryana" 7 "Delhi" 08 "Rajasthan" 9 "Uttar Pradesh" 10 "Bihar" 11 "Sikkim"           /// 
	12 "Arunachal Pradesh" 13 "Nagaland" 14 "Manipur" 15 "Mizoram" 16 "Tripura" 17 "Meghalaya"              ///
	18 "Assam" 19 "West Bengal" 20"Jharkhand" 21 "Orissa" 22"Chhattisgarh" 23 "Madhya Pradesh"              ///
	24 "Gujarat" 25 "Daman & Diu" 26 "Dadra & Nagar Haveli" 27 "Maharashtra" 28 "Andhra Pradesh"           ///
	29"Karnataka" 30 "Goa" 31"Lakshadweep" 32 "Kerala" 33 "Tamil Nadu" 34 "Pondicherry" 35 "A & N Islands"         
	label var subnatid1 "Region at 1 digit (ADMN1)"
	label values subnatid1 lblsubnatid1
		numlabel lblsubnatid1, remove
		numlabel lblsubnatid1, add mask("# - ")
		decode subnatid1, gen(subnatid1_temp)
		drop subnatid1
		rename subnatid1_temp subnatid1
*</_subnatid2_>

*<_gaul_adm1_code_>
	gen gaul_adm1_code=.
	label var gaul_adm1_code "GAUL code for admin1 level"
	replace gaul_adm1_code=2021 if subnatid1=="35 - A & N Islands"
	replace gaul_adm1_code=2022 if subnatid1=="28 - Andhra Pradesh"
	replace gaul_adm1_code=2023 if subnatid1=="18 - Assam"
	replace gaul_adm1_code=2024 if subnatid1=="7 - Delhi"
	replace gaul_adm1_code=2025 if subnatid1=="30 - Goa"
	replace gaul_adm1_code=2026 if subnatid1=="24 - Gujarat"
	replace gaul_adm1_code=2027 if subnatid1=="6 - Haryana"
	replace gaul_adm1_code=2028 if subnatid1=="2 - Himachal Pradesh"
	replace gaul_adm1_code=2029 if subnatid1=="29 - Karnataka"
	replace gaul_adm1_code=2030 if subnatid1=="32 - Kerala"
	replace gaul_adm1_code=2031 if subnatid1=="31 - Lakshadweep"
	replace gaul_adm1_code=2032 if subnatid1=="27 - Maharashtra"
	replace gaul_adm1_code=2033 if subnatid1=="14 - Manipur"
	replace gaul_adm1_code=2034 if subnatid1=="17 - Meghalaya"
	replace gaul_adm1_code=2035 if subnatid1=="15 - Mizoram"
	replace gaul_adm1_code=2036 if subnatid1=="13 - Nagaland"
	replace gaul_adm1_code=2037 if subnatid1=="21 - Orissa"
	replace gaul_adm1_code=2038 if subnatid1=="3 - Punjab"
	replace gaul_adm1_code=2039 if subnatid1=="8 - Rajasthan"
	replace gaul_adm1_code=2040 if subnatid1=="11 - Sikkim"
	replace gaul_adm1_code=2041 if subnatid1=="33 - Tamil Nadu"
	replace gaul_adm1_code=2042 if subnatid1=="16 - Tripura"
	replace gaul_adm1_code=2043 if subnatid1=="19 - West Bengal"
	replace gaul_adm1_code=2044 if subnatid1=="12 - Arunachal Pradesh"
	replace gaul_adm1_code=2045 if subnatid1=="10 - Bihar"
	replace gaul_adm1_code=2046 if subnatid1=="4 - Chandigarh"
	replace gaul_adm1_code=2047 if subnatid1=="22 - Chhattisgarh"
	replace gaul_adm1_code=2048 if subnatid1=="26 - Dadra & Nagar Haveli"
	replace gaul_adm1_code=2049 if subnatid1=="25 - Daman & Diu"
	replace gaul_adm1_code=2050 if subnatid1=="20 - Jharkhand"
	replace gaul_adm1_code=2051 if subnatid1=="23 - Madhya Pradesh"
	replace gaul_adm1_code=2052 if subnatid1=="34 - Pondicherry"
	replace gaul_adm1_code=2053 if subnatid1=="9 - Uttar Pradesh"
	replace gaul_adm1_code=2054 if subnatid1=="5 - Uttaranchal"
	replace gaul_adm1_code=2086 if subnatid1=="1 - Jammu & Kashmir"
*<_gaul_adm1_code_>
	
** REGIONAL AREA 3 DIGIT ADMN LEVEL
*<_subnatid3_>
	gen byte subnatid3=.
	label var subnatid3 "Region at 3 digit (ADMN3)"
	label values subnatid3 lblsubnatid3
*</_subnatid3_>
	
** HOUSE OWNERSHIP
*<_ownhouse_>
	gen ownhouse=.
	replace ownhouse=1 if S1B12_v1==2
	replace ownhouse=0 if inlist(S1B12_v1,3,4,9)
	label var ownhouse "House ownership"
	la de lblownhouse 0 "No" 1 "Yes"
	label values ownhouse lblownhouse
*</_ownhouse_>

** TENURE OF DWELLING
*<_tenure_>
   gen tenure=.
   replace tenure=1 if S1B12_v1==2
   replace tenure=2 if S1B12_v1==3 | S1B12_v1==4
   replace tenure=3 if S1B12_v1==9
   label var tenure "Tenure of Dwelling"
   la de lbltenure 1 "Owner" 2"Renter" 3"Other"
   la val tenure lbltenure
*</_tenure_>	


** LANDHOLDING
*<_lanholding_>
   gen landholding=1 if S1B31_v6==1
   replace landholding=0 if S1B31_v6==2
   label var landholding "Household owns any land"
   la de lbllandholding 0 "No" 1 "Yes"
   la val landholding lbllandholding
*</_tenure_>	


*ORIGINAL WATER CATEGORIES
*<_water_orig_>
gen water_orig=S1B12_v8
la var water_orig "Source of Drinking Water-Original from raw file"
#delimit
la def lblwater_orig 1 "Tap"
					 2 "Tube well, handpump"
					 3 "Well"
					 4 "Tank, pond reserved for drinking"
					 5 "Other tank"
					 6 "River, canalm lake"
					 7 "Spring"
					 9 "Other";
#delimit cr
la val water_orig lblwater_orig
*</_water_orig_>

*PIPED SOURCE OF WATER
*<_piped_water_>
gen piped_water=.
la var piped_water "Household has access to piped water"
la def lblpiped_water 1 "Yes" 0 "No"
la val piped_water lblpiped_water
*</_piped_water_>


**INTERNATIONAL WATER COMPARISON (Joint Monitoring Program)
*<_water_jmp_>
gen water_jmp=.
replace water_jmp=4 if S1B12_v8==2  
replace water_jmp=6 if S1B12_v8==3  
replace water_jmp=12 if S1B12_v8==4  
replace water_jmp=12 if S1B12_v8==5  
replace water_jmp=14 if S1B12_v8==6  
replace water_jmp=8 if S1B12_v8==7
replace water_jmp=14 if S1B12_v8==9

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
	replace sar_improved_water=1 if S1B12_v8==1
replace water_jmp=.
la def lblsar_improved_water 1 "Improved" 0 "Unimproved"
la var sar_improved_water "Improved source of drinking water-using country-specific definitions"
la val sar_improved_water lblsar_improved_water
*</_sar_improved_water_>


*ORIGINAL WATER CATEGORIES
	*<_water_original_>
	clonevar j=S1B12_v8
	#delimit
	la def lblwater_original 1 "Tap"
							 2 "Tube well, handpump"
							 3 "Well"
							 4 "Tank, pond reserved for drinking"
							 5 "Other tank"
							 6 "River, canalm lake"
							 7 "Spring"
							 9 "Other";
	#delimit cr
	la val j lblwater_original		
	decode j, gen(water_original)
	drop j
	la var water_original "Source of Drinking Water-Original from raw file"
	*</_water_original_>


	** WATER SOURCE
	*<_water_source_>
		gen water_source=.
		replace water_source=4 if S1B12_v8==2
		replace water_source=11 if S1B12_v8==4
		replace water_source=12 if S1B12_v8==5
		replace water_source=13 if S1B12_v8==6
		replace water_source=14 if S1B12_v8==9
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
		gen pipedwater_acc=.
		replace pipedwater_acc=1 if S1B12_v8==1
		replace pipedwater_acc=0 if S1B12_v8!=1 & S1B12_v8!=.
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

	gen electricity=S1B31_v22
	recode electricity (0=.)(5=1)(1 2 3 4 8 9=0) 
	label var electricity "Electricity main source"
	la de lblelectricity 0 "No" 1 "Yes"
	label values electricity lblelectricity
*</_electricity_>


*ORIGINAL TOILET CATEGORIES
*<_toilet_orig_>
gen toilet_orig=S1B12_v7
la var toilet_orig "Access to sanitation facility-Original from raw file"
#delimit
la def lbltoilet_orig 1 "No latrine"
					  2 "Service latrine"
					  3 "Septic tank"
					  4 "Flush system"
					  9 "Other";
#delimit cr
la val toilet_orig lbltoilet_orig
*</_toilet_orig_>

*SEWAGE TOILET
*<_sewage_toilet_>
gen sewage_toilet=.
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
replace sar_improved_toilet=1 if inlist(S1B12_v7,2,3,4)
replace sar_improved_toilet=0 if inlist(S1B12_v7,1,9)
la def lblsar_improved_toilet 1 "Improved" 0 "Unimproved"
la var sar_improved_toilet "Improved type of sanitation facility-using country-specific definitions"
la val sar_improved_toilet lblsar_improved_toilet
*</_sar_improved_toilet_>


	** ORIGINAL SANITATION CATEGORIES 
	*<_sanitation_original_>
		clonevar j=S1B12_v7
		#delimit
		la def lblsanitation_original   1 "No latrine"
										2 "Service latrine"
										3 "Septic tank"
										4 "Flush system"
										9 "Other";
		#delimit cr
		la val j lblsanitation_original
		decode j, gen(sanitation_original)
		drop j
		la var sanitation_original "Access to sanitation facility-Original from raw file"
	*</_sanitation_original_>


	** SANITATION SOURCE
	*<_sanitation_source_>
		gen sanitation_source=.
		replace sanitation_source=13 if S1B12_v7==1
		replace sanitation_source=4 if S1B12_v7==2
		replace sanitation_source=3 if S1B12_v7==3
		replace sanitation_source=1 if S1B12_v7==4
		replace sanitation_source=14 if S1B12_v7==9
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
		gen toilet_acc=.
		replace toilet_acc=3 if improved_sanitation==1
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
	gen internet=.
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

** HOUSEHOLD WEIGHTS FOR THE WDI
*<_wgt_wdi_>

egen wgt_urban=total(wgt) if urban==1
egen wgt_rural=total(wgt) if urban==0

gen wgt_wdi=wgt*(245376241.5/wgt_urban) if urban==1
replace wgt_wdi=wgt*(687754791.5/wgt_rural) if urban==0
label var wgt_wdi "Household sampling weight using WDI population growth"
*</_wgt_wdi_>

** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
*<_relationharm_>
	gen relationharm = S1B4_v3
	recode relationharm (3 5 = 3) (7=4) (4 6 8 = 5) (9=6) (0=.)
	label var relationharm "Relationship to the head of household"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Non-relatives"
	label values relationharm  lblrelationharm
*</_relationharm_>

** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
*<_relationcs_>

	gen byte relationcs = S1B4_v3
	la var relationcs "Relationship to the head of household country/region specific"
	label de lblrelationcs 1 "Head" 2 "Spouse of head" 3 "married child" 4 "spouse of married child"  ///
	5 "unmarried child" 6 "grandchild" 7 "father/mother/father-in-law/mother-in-law"  ///
	8 "brother/sister/brother-in-law/sister-in-law/other relations" 9 "servant/employee/other non-relative" 
	label val relationcs lblrelationcs
*</_relationcs_>

	
	* FIX RELATIONSHIP TO HEAD VARIABLE MANUALLY
	
	gen head=relationharm==1
	bys idh: egen heads=total(head)
	replace relationharm=1 if indid==1 & heads==0
	drop head heads
	
	gen head=relationharm==1
	bys idh: egen heads=total(head)
	replace relationharm=1 if relationharm==2 & heads==0
	drop head heads

	gen head=relationharm==1
	bys idh: egen heads=total(head)
	bys idh: egen min_rel=min(relationcs)
	
	replace relationharm=1 if min_rel==3 & relationcs==3
	replace relationharm=2 if min_rel==3 & relationcs==4
	replace relationharm=3 if min_rel==3 & relationcs==6
	drop head heads min_rel
	
	gen head=relationharm==1
	bys idh: egen heads=total(head)	
	bys idh: egen max_age=max(S1B4_v5)
	replace relationharm=1 if heads==0 & S1B4_v5==max_age
	drop head heads
	
	gen head=relationharm==1
	bys idh: egen heads=total(head)	
	replace relationharm=2 if relationharm==1 & indid!=1 & heads==2
	drop head heads
	
	gen head=relationharm==1
	bys idh: egen heads=total(head)	
	replace relationharm=1 if heads==0 & indid==1
	drop head heads
	
	gen head=relationharm==1
	bys idh: egen heads=total(head)	
	replace relationharm=5 if relationharm==1 & heads!=1 & indid!=1
	drop head heads
	
	gen head=relationharm==1
	bys idh: egen heads=total(head)	
	replace relationharm=1 if heads==0 & indid==1
	drop head heads
	
		
** GENDER
*<_male_>
	gen male= S1B4_v4
	recode male (2=0)
	label var male "Sex of household member"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale
*</_male_>


** AGE
*<_age_>
	gen age=S1B4_v5
	replace age=98 if age>98 & age<.
	label var age "Age of individual"
*</_age_>


** SOCIAL GROUP
*<_soc_>

/*
The caste variable exist too, named "S1B31_v5"
*/
	gen soc=S1B31_v4
	label var soc "Social group"
	label define lblsoc 1 "Hinduism" 2 "Islam" 3 "Christianity" 4 "Sikhism" 
	label define lblsoc 5 "Jainism" 6 "Buddhism" 7 "Zoroastrianism" 9 "Others", add
	label values soc lblsoc
*</_soc_>


** MARITAL STATUS
*<_marital_>
gen marital=S1B4_v6
	recode marital (1=2) (2=1) (3=5) (8=.)
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
	gen ed_mod_age=0
	label var ed_mod_age "Education module application age"
*</_ed_mod_age_>


** CURRENTLY AT SCHOOL
*<_atschool_>
	gen atschool=.
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool
*</_atschool_>


** CAN READ AND WRITE
*<_literacy_>
	gen literacy=S1B4_v7
	recode literacy (2/13 = 1) (1=0) (0=.)
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
*</_literacy_>


** YEARS OF EDUCATION COMPLETED
*<_educy_>
	recode S1B4_v7 (1/4=0)(5=2)(6=5) (7=8) (8 9=10) (10 11 12 13=15) (0=.), gen(educy)
	label var educy "Years of education"
	replace educy=. if educy>age & age!=. & educy!=.
*</_educy_>


** EDUCATION LEVEL 7 CATEGORIES
*<_educat7_>
	gen educat7=S1B4_v7
	recode educat7 (1 2 3 4=1) (5=2) (6=3) (7 8 =4) (9=5) (10 11 12 13=7) (0=.)
	la var educat7 "Level of education 7 categories"
	label define lbleducat7 1 "No education" 2 "Primary incomplete" 3 "Primary complete" ///
	4 "Secondary incomplete" 5 "Secondary complete" 6 "Higher than secondary but not university" /// 
	7 "University incomplete or complete" 8 "Other" 9 "Not classified"
	label values educat7 lbleducat7
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
	gen educat4=.
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
	recode S1B4_v7 (1 2 3 4= 0) (5 6 7 8 9 10 11 12 13=1) (0=.), gen (everattend)
	label var everattend "Ever attended school"
	la de lbleverattend 0 "No" 1 "Yes"
	label values everattend lbleverattend
*</_everattend_>

*preguntar a vibuti sobre esto
	replace educy=0 if everattend==0
	replace educat7=1 if everattend==0
	replace educat5=1 if everattend==0

/*****************************************************************************************************
*                                                                                                    *
                                   LABOR MODULE
*                                                                                                    *
*****************************************************************************************************/


** LABOR MODULE AGE
*<_lb_mod_age_>

	gen lb_mod_age=0
	label var lb_mod_age "Labor module application age"
*</_lb_mod_age_>



** LABOR STATUS
*<_lstatus_>
	gen lstatus=.
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
*</_lstatus_>


** EMPLOYMENT STATUS
*<_empstat_>
	gen empstat=.
	label var empstat "Employment status"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed"
	label values empstat lblempstat
*</_empstat_>


** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
*<_njobs_>
	gen njobs=.
	label var njobs "Number of additional jobs"
*</_njobs_>


** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
*<_ocusec_>
	gen ocusec=.
	label var ocusec "Sector of activity"
	la de lblocusec 1 "Public, state owned, government, army" 2 "NGO" 3 "Private"
	label values ocusec lblocusec
*</_ocusec_>


** REASONS NOT IN THE LABOR FORCE
*<_nlfreason_>
	gen nlfreason=.
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housewife" 3 "Retired" 4 "Disable" 5 "Other"
	label values nlfreason lblnlfreason
*</_nlfreason_>



** UNEMPLOYMENT DURATION: MONTHS LOOKING FOR A JOB
*<_unempldur_l_>
	gen unempldur_l=.
	replace unempldur_l=. if lstatus!=2
	label var unempldur_l "Unemployment duration (months) lower bracket"
*</_unempldur_l_>

*<_unempldur_u_>

	gen unempldur_u=.
	replace unempldur_u=. if lstatus!=2
	label var unempldur_u "Unemployment duration (months) upper bracket"
*</_unempldur_u_>

** INDUSTRY CLASSIFICATION
*<_industry_>
	gen industry=.
	label var industry "1 digit industry classification"
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transports and comnunications" 8 "Financial and business-oriented services" 9 "Community and family oriented services" 10 "Others"
	label values industry lblindustry
*</_industry_>
	replace industry=. if lstatus==2 | lstatus==3


** OCCUPATION CLASSIFICATION
*<_occup_>

	gen occup=.
	label var occup "1 digit occupational classification"
	label define occup 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers"  8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"


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
*</_whours_>

** WAGES
*<_wage_>
	gen wage=.
	replace wage=. if lstatus==2 | lstatus==3
	replace wage=0 if empstat==2
	label var wage "Last wage payment"
*</_wage_>


** WAGES TIME UNIT
*<_unitwage_>
	gen unitwage=.
	label var unitwage "Last wages time unit"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly"
	label values unitwage lblunitwage
*</_wageunit_>


** CONTRACT
*<_contract_>
	gen contract=.
	label var contract "Contract"
	la de lblcontract 0 "Without contract" 1 "With contract"
	label values contract lblcontract
*</_contract_>
	replace contract=. if lstatus==2 | lstatus==3


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

	replace union=. if  lstatus==2 | lstatus==3
	la de lblunion 0 "No member" 1 "Member"
	label values union lblunion
*</_union_>

	local lb_var "lstatus empstat njobs ocusec nlfreason unempldur_l unempldur_u industry occup firmsize_l firmsize_u whours wage unitwage contract healthins socialsec union"
	foreach v in `lb_var'{
	di "check `v' only for age>=lb_mod_age"

	replace `v'=. if( age<lb_mod_age & age!=.)
	}

/*****************************************************************************************************
*                                                                                                    *
                                   LABOR MODULE FOR INDIA
*                                                                                                    *
*****************************************************************************************************/

* main income earner OF THE HOUSEHOLD (_e)

** LABOR STATUS MAIN EARNER
*<_lstatus_e_>
	gen lstatus_e=.
	label var lstatus_e "Labor status (main earner)"
	la de lbllstatus_e 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus_e lbllstatus_e
*</_lstatus_e_>

** EMPLOYMENT STATUS MAIN EARNER
*<_empstat_e_>
	gen empstat_e=.
	label var empstat_e "Employment status (main earner)"
	la de lblempstat_e 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other"
	label values empstat_e lblempstat_e
*</_empstat_e_>

**ORIGINAL INDUSTRY CLASSIFICATION
*<_industry_orig_>
gen industry_e_orig=S1B31_v2i
#delimit
la def lblindustry_e_orig
	0	"Aggriculture, forestry and fishing"
	1	"Growing of Pulses (arhar, gram,moong,urd, etc.)"
	2	"Growing of Cotton"
	3	"Growing of Jute,Mesta,sann hemp or other kindred fibres"
	4	"Growing of oilseeds"
	5	"Growing of sugarcane of sugarbeet"
	6	"Growing of roots and tubers, vegetables,singhara,chillies and other spices (other than pepper and cardamom)"
	7	"Floriculture and horticulture including tree nurseries"
	8	"Growing of fodder crops"
	9	"Agricultural production n.e.c."
	10	"Plantation of tea"
	11	"Plantation of coffee"
	12	"Plantation of rubber"
	13	"Plantation of tobacco"
	14	"Plantation of pepper and cardamom"
	15	"Plantation of coconut and arecanut"
	16	"Plantation of edible nuts (excluding coconut and groundnut)"
	17	"Growing of fruits"
	18	"Growing of ganja, cinchona and opium etc."
	19	"Plantations not elsewhere classified"
	20	"Cattle breeding, rearing and ranching etc.; production of milk"
	21	"Goat breeding, rearing, ranching etc.; production of milk"
	22	"Rearing of sheep and production of shorn wool"
	23	"Rearing of horses, mules, camels and other pack animals"
	24	"Rearing of pigs and other animals not elsewhere classified"
	25	"Rearing of ducks,hens and other birds;production of eggs."
	26	"Rearing of bees, production of honey and wax [Collection of honey is classified in group 054]"
	27	"Rearing of silk-worms, production of cocoons and raw silk"
	29	"Rearing of livestock and production of livestock products, not elsewhere classified"
	30	"Pest destroying, spraying and pruning of infected stems, etc."
	31	"Operation of irrigation systems"
	32	"Animal shearing and livestock services n.e.c. (other than veterinary services)"
	33	"Grading of agricultural products and livestock"
	34	"Horticulture and nursery services"
	35	"Soil conservation services"
	36	"Scientific services like soil testing"
	37	"Soil desalination services"
	39	"Agricultural services not elsewhere classified (like harvesting and threshing, land clearing and land draining services"
	40	"Hunting, trapping and game propagation other than for sports."
	50	"Planting,replanting and conservation of forests"
	51	"Logging - felling and cutting of trees and preparation of rough, round, hewn or riven logs (including incidental hauling"
	52	"Production of firewood/ fuel wood (including charcoal by burning) by exploitation of forests"
	53	"Gathering of fodder by exploitation of forests"
	54	"Gathering of uncultivated materials such as gums, resins, lac, barks, munjh, herbs, honey,wild fruits, leaves, etc. by exploitation of forests."
	59	"Forestry services n.e.c."
	60	"Ocean ,sea, and coastal fishing"
	61	"Inland water fishing"
	62	"Pisciculture - rearing of fish, including fish hatcheries"
	63	"Collection of pearls, conches, shells, sponges and other sea products."
	64	"Cultivation of oysters for pearls"
	69	"Other allied activities and services incidental to fishing n.e.c."
	100	"Mining and agglomeration of coal"
	101	"Mining and agglomeration of lignite"
	102	"Extraction and agglomeration of peat"
	110	"extraction of crude petroleum"
	111	"Production of natural gas"
	120	"Mining of iron ore"
	130	"Mining of manganese ore"
	131	"Mining of chromite"
	132	"Mining of Bauxite"
	133	"Mining of precious/ semi-precious metal ores"
	134	"Mining of copper ore"
	135	"Mining of lead and zinc ores"
	136	"Mining of ilmenite, rutile, zircon and zirconium bearing ores"
	137	"Mining of wolfram and other tungsten bearing ores"
	138	"Mining of tin bearing ores"
	139	"Mining of metal ores other than iron ore or uranium group ores n.e.c."
	140	"Mining of uranium and thorium ores"
	150	"Mining and quarrying of rock aggregates, sand and clays"
	151	"Mining/quarrying of minerals for construction other than rock aggregates,sand and clays(classified in group150)"
	152	"Mining of fertilizer and chemicals minerals"
	153	"Mining of ceramic, refractory and glass minerals"
	154	"Salt mining/quarrying and screening, etc."
	155	"Mining of mica"
	156	"Mining of precious/semi-precious stones"
	159	"Mining of other non-metallic minerals not elsewhere classified"
	190	"Oil and gas field services, except exploration services [exploration services are classified in group 894]"
	191	"Services incidental to mining such as drilling, shafting,reclamation of mines , etc."
	199	"Other mining services not elsewhere classified"
	200	"Slaughtering, preparation and preservation of meat"
	201	"Manufacture of dairy products"
	202	"Canning and preservation of fruits and vegetables"
	203	"Processing, canning, and preservation of fish, crustacea and similar foods"
	204	"Grain milling"
	205	"Manufacture of Bakery Products"
	206	"Manufacture and refining of sugar (vacuum pan sugar factories)"
	207	"Production of indigenous sugar, boora, khandsari, gur, etc. from sugar-cane, palm juice , etc."
	208	"Production of common salt"
	209	"Manufacture of cocoa products and sugar confectionery (including sweetmeats)"
	210	"Manufacture of hydrogenated oils and vanaspati ghee etc."
	211	"Manufacture of vegetable oils and fats (other than hydrogenated)"
	212	"Manufacture of animal oils and fats , manufacture of fish oil"
	213	"Processing and blending of tea including manufacture of instant tea"
	214	"Coffee curing, roasting, grinding and blending etc. including manufacture of instant coffee"
	215	"Processing of edible nuts"
	216	"Manufacture of ice"
	217	"Manufacture of prepared animal and bird feed"
	218	"Manufacture of food products not elsewhere classified"
	220	"Distilling, rectifying and blending of spirits, ethyl alcohol production from fermented materials"
	221	"Manufacture of wines"
	222	"Manufacture of malt liquors and malt"
	223	"Production of country liquor9arrack and toddy etc.)"
	224	"Manufacture of soft drinks and syrups"
	225	"Tobacco stemming, redrying and all other operations connected with preparing raw leaf tobacco"
	226	"manufacture of bidi"
	227	"Manufacture of cigars, cigarettes, cheroots and cigarette tobacco"
	228	"Manufacture of snuff, zarda, chewing tobacco and other tobacco products n.e.c. (except pan masala containing tobacco)"
	229	"Manufacture of pan-masala, catechu(kattha) and chewing lime"
	230	"Cotton ginning, cleaning and baling"
	231	"Cotton spinning other than in mills (charkha)"
	232	"Weaving and finishing of cotton khadi"
	233	"Weaving and finishing of cotton textiles on handlooms"
	234	"Weaving and finishing of cotton textiles on powerlooms"
	235	"Cotton spinning, weaving and processing in mills"
	236	"Bleaching, dyeing and printing of cotton textiles (This group includes bleaching, dyeing and printing of not self-produced cotton textiles. No distinction is to be between these activities carried out on a fee or contract basis or by purchasing the materials and selling the finished products. Bleaching, dyeing and printing of self-produced textiles in composite mills is classified in class 235.4)"
	240	"Preparation of raw wool, silk and artificial/synthetic textile fibres for spinning"
	241	"Wool spinning, weaving and finishing other than in mills"
	242	"Wool spinning, weaving and processing in mills"
	243	"Bleaching and dyeing of woolen textiles "
	244	"Spinning, weaving and finishing of silk textiles other than in mills"
	245	"Spinning, weaving and processing of silk textiles in mills"
	246	"Bleaching, dyeing and printing of silk textiles"
	247	"Spinning, weaving and processing of man-made textile fibres"
	248	"Bleaching, dyeing and printing of artificial/synthetic textile fabrics"
	250	"Jute and mesta pressing and baling"
	251	"Preparatory operations (including carding and combing) on jute and mesta fibres"
	252	"Preparatory operations (including carding and combing) on coir fibres"
	253	"Preparatory operations (including carding and combing) on sann hemp and other vegetable fibres n.e.c."
	254	"Spinning, weaving and finishing of jute and mesta textiles"
	255	"Spinning, weaving and finishing of coir textiles"
	256	"Spinning, weaving and finishing of sann hemp and other vegetable fibre textiles n.e.c."
	257	"Bleaching, dyeing and printing of jute and mesta textiles"
	258	"Bleaching, dyeing and printing of coir textiles"
	259	"Bleaching, dyeing and printing of other vegetable fibre textiles n.e.c."
	260	"Manufacture of knitted or crocheted textile products"
	261	"Manufacture of all types of threads, cordage, ropes, twines and nets, etc."
	262	"Embroidery work, zari work and making of ornamental trimmings"
	263	"Manufacture of blankets, shawls, carpets, rugs, and other similar textile products"
	264	"Manufacture of floor coverings of jute, mesta sann-hemp and other kindled fibres and of coir"
	265	"Manufacture of all types of textile garments and clothing accessories n.e.c. (except by purely tailoring establishments) from not self-produced material(Note: in principle, the raw material is cut and sewn together in the establishments covered in this group)"
	266	"Manufacture of rain coats, hats, caps and school bags etc. from waterproof textile fabrics or plastic sheetings"
	267	"Manufacture of made-up textile articles; except apparel"
	268	"Manufacture of waterproof textile fabrics"
	269	"Manufacture of textiles/textile products not elsewhere classified like linoleum, padding wadding, upholstering and filling, etc."
	270	"Sawing and planing of wood (other than plywood)"
	271	"Manufacture of veneer sheets, plywood and their products"
	272	"Manufacture of structural wooden goods (including treated timber) such as beams, posts, doors and windows(excluding hewing and rough shaping of poles, bolts and other wood material which is classified under logging)"
	272	"Manufacture of structural wooden goods (including treated timber) such as beams, posts, doors and windows (excluding hewing and rough shaping of poles, bolts and other wood material which is classified under logging)"
	273	"Manufacture of wooden and cane boxes, crates, drums, barrels and other containers, baskets and other wares made entirely or mainly of cane, rattan, reed, bamboo, willow, fibres, leaves and grass"
	274	"Manufacture of wooden industrial goods n.e.c."
	275	"Manufacture of cork and cork products"
	276	"Manufacture of wooden furniture and fixtures"
	277	"Manufacture of bamboo and cane furniture and fixture"
	279	"Manufacture of products of wood, bamboo, cane reed and grass (including articles made from coconut shells etc.) n.e.c."
	280	"Manufacture of pulp, paper and paper board including manufacture of newsprint"
	281	"Manufacture of containers and boxes of paper or paper board"
	282	"Manufacture of paper and paper board articles and pulp products not elsewhere classified"
	283	"Manufacture of special purpose paper whether or not printed n.e.c."
	284	"Printing and purblishing of newspapers"
	285	"Printing and publishing of periodicals books, journals, directories, atlases, maps, sheet music, schedules & Pamphlets etc."
	286	"Printing of bank notes, currency notes, postage stamps, security passes, stamp papers and other similar products"
	287	"Engraving, etching, and block-making etc."
	288	"Book binding on account of others"
	289	"Printing and allied activities not elsewhere classified "
	290	"Tanning, curing,, finishing, embossing and japanning of leather"
	291	"Manufacture of footwear excluding repair) except of vulcanized or moulded rubber or plastic"
	292	"Manufacture of wearing apparel of leather and substitutes of leather"
	293	"Manufacture of consumer goods of leather and substitutes of leather; other than apparel and footwear(Note: Manufacture of school bags and traveling accessories from water-proof textile fabrics is included in group 266)"
	294	"Scrapping, currying, tanning, bleaching and dyeing of fur and other pelts for the trade"
	295	"Manufacture of wearing apparel of fur and pelts"
	296	"Manufacture of fur and skin rugs and other similar articles"
	299	"Manufacture of leather and fur products n.e.c."
	301	"Manufacture of fertilizers and pesticides"
	302	"Manufacture of plastics in primary forms; manufacture of synthetic rubber"
	303	"Manufacture of paints, varnishes, and related products; artists' colours and ink"
	304	"Manufacture of drugs, medicines and allied products"
	305	"Manufacture of perfumes, cosmetics, lotions, hair dressings, toothpastes, soap in any form, detergents, shampoos, shaving products, washing and cleaning preparations and other toilet preparations."
	306	"Manufacture of man-made fibres"
	307	"Manufacture of matches."
	308	"Manufacture of explosives, ammunition and fire works"
	309	"Manufacture of chemical products not elsewhere classified."
	310	"Tyre and tube industries."
	311	"Manufacture of footwear made primarily of vulcanised or moulded rubber and plastics."
	312	"Manufacture of rubber products not elsewhere classified"
	313	"Manufacture of plastic products not elsewhere classified."
	314	"Manufacture of refined petroleum products (this group includes production of liquids of gaseous fuels, illuminating oils, lubricating oils or greases or other products obtained from crude petroleum or their fractionation productions, Liquification of natural gas is classified in group 111 and bottling of natural gas or liquified petroleum gas is classified in group 315)"
	315	"Bottling of natural gas or liquified petroleum gas."
	316	"Manufacture of refined petroleum products not elsewhere classified (this group includes Manufacture of variety of products extracted/obtained from the products or residues of petroleum refining)."
	317	"Processing of nuclear fuels (this group includes extraction of uranium metals from pitch blende or other uranium bearing ores; Manufacture of alloys or dispersions or mixtures of natural uranium or its compounds, Manufacture of enriched uranium and its compounds; plutonium and its compounds; uranium depleted in U 235 and its compounds; thorium and its compounds; other radio active elements, isotops or compounds and non-irradiated fuel elements for use in nuclear reactors.  Production of heavy water is classified in group 309.)"
	318	"Manufacture of coke oven products (this group includes operation of coke ovens chiefly for the production of coke or semi-coke from hard-coal and lignite, retort carbon and residual products such as coal tar or pitch agglomeration of coke is included.  Distillation of coal tar is classified in group 319 below)"
	319	"Manufacture of other coal and coal tar products not elsewhere classified."
	320	"Manufacture of refractory products and structural clay products."
	321	"Manufacture of glass and glass products."
	322	"Manufacture of earthen and plaster products."
	323	"Manufacture of non-structural ceramic ware"
	324	"Manufacture of cement, lime and plaster"
	325	"Manufacture of mica products"
	326	"Stone dressing and crushing, Manufacture of structural stone goods and stone ware."
	327	"Manufacture of asbestos cement and other cement products."
	329	"Manufacture of miscellaneous non-metallic mineral products not elsewhere classified."
	330	"Manufacture of iron and steel in primary/semi-finished forms."
	340	"Manufacture of fabricated structural metal products."
	341	"Manufacture of fabricated metal products not elsewhere classified."
	342	"Manufacture of furniture and fixtures primarily of metal"
	343	"Manufacture of hand tools, weights and measures and general hardware."
	344	"Forging, pressing, stamping and roll-forming of metal; power metallurgy. (This group includes production of a wide variety of finished or semi-finished metal products, by means of the above activities which, individually, would be characteristically produced in other activity categories)"
	345	"Treatment or coating of metals; general mechanical engineering on a sub-contract basis. (This group includes plating, polishing, anodizing, engraving, printing, hardening, buffing, deburring, sand blasting, welding or other specialised operations on metals on a fee or contract basis.   The units classified here, generally, do not take ownership of the goods nor do they sell them to third parties)."
	346	"Manufacture of metal cutlery, utensils and kitchenware"
	349	"Manufacture of metal products (except machinery and equipment) not elsewhere classified"
	350	"Manufacture of agricultural machinery and equipment and parts thereof"
	351	"Manufacture of machinery and equipment used by construction and mining industries"
	352	"Manufacture of prime movers, boilers, steam generating plants and nuclear reactors"
	353	"Manufacture of industrial machinery for food and textile industries (including bottling and filling machinery)"
	354	"Manufacture of industrial machinery for other than food and textile industries"
	355	"Manufacture of refrigerators,  airconditioners and fire fighting equipment and their parts and accessories."
	356	"Manufacture of general purpose non-electrical machinery/equipment, their components and accessories, n.e.c."
	357	"Manufacture of machine tools, their parts and accessories"
	358	"Manufacture of office, computing and accounting machinery and parts, (Note: Manufacture of computers and computer based systems including word processors is classified in group 367)"
	359	"Manufacture of special purpose machinery/equipment, their components and accessories n.e.c."
	360	"Manufacture of electrical industrial machinery, apparatus and parts thereof"
	361	"Manufacture of insulated wires and cables, including manufacture of optical fibre cables"
	362	"Manufacture of accumulators, primary cells and primary batteries"
	363	"Manufacture of electric lamps"
	364	"Manufacture of electric fans and electric/electro-thermic domestic appliances and parts thereof"
	365	"Manufacture of apparatus for radio broadcasting, television transmission, radar apparatus and radio-remote control apparatus and apparatus for radio/line telephony and line telegraphy"
	366	"Manufacture of television receivers; reception apparatus for radio broadcasting, radio telephony/telegraphy, video recording or reproducing apparatus, turn-tables, record-players, cassette-players and other sound reproducing apparatus, sound recording reproducing apparatus, microphones, loudspeakers, amplifiers and sound amplifiers and prerecorded audio/video records/tapes."
	367	"Manufacture of computers and computer based systems"
	368	"Manufacture of electronic valves and tubes and other electronic components n.e.c."
	369	"Manufacture of radiographic X-ray apparatus X-ray tubes and parts and manufacture of electrical equipment n.e.c."
	370	"Ship and boat building"
	371	"Manufacture of locomotives and parts"
	372	"Manufacture of railway/tramway wagons and coaches and other railroad equipment n.e.c."
	373	"Manufacture of heavy motor vehicles; coach work"
	374	"Manufacture of motor cars and other motor vehicles principally designed for the transport of less than 10 persons (includes manufacture of racing cars and golf-cars etc.)"
	375	"Manufacture of motor-cycles and scooters and parts (including three-wheelers)"
	376	"Manufacture of bicycles, cycle-rickshaws"
	377	"Manufacture of aircraft, spacecraft and their parts"
	378	"Manufacture of bullock-carts, push-carts and hand-carts etc."
	379	"Manufacture of transport equipment and parts not elsewhere classified"
	380	"Manufacture of medical, surgical, scientific and measuring equipment except optical equipment"
	381	"Manufacture of photographic, cinematographic and optical goods and equipment (excluding photochemicals, sensitised paper and film)"
	382	"Manufacture of watches and clocks"
	383	"Manufacture of jewellery and related articles"
	384	"Minting of currency coins"
	385	"Manufacture of sports and athletic gooks"
	386	"Manufacture of musical instruments (Note: Manufacture of toy musical instruments is classified in group 389)"
	387	"Manufacture of stationery articles n.e.c."
	388	"Manufacture of items based on solar energy like solar cells, cookers, air and water heating systems and other related items"
	389	"Manufacture of miscellaneous products not elsewhere classified"
	390	"Repair of agricultural machinery/equipment"
	391	"Repair of prime-movers, boilers, steam-generating plants and nuclear reactors"
	392	"Repair of machine tools"
	393	"Repair of industrial machinery other than machine tools"
	394	"Repair of office, computing and accounting machinery"
	395	"Repair of electrical industrial machinery and apparatus"
	396	"Repair of apparatus for radio-broadcasting or television transmission; radar apparatus, radio remote control apparatus and apparatus for radio/line telephony or line telegraphy"
	397	"Repair of locomotives and other railroad equipment"
	398	"Repair of heavy motor vehicles"
	399	"Repair of machinery and equipment not elsewhere classified"
	400	"Generation and transmission of electric energy"
	401	"Distribution of electric energy to households, industrial, commercial and other users."
	410	"Generation of gas in gas-works and distribution through mains to households, industrial, commercial and other users."
	420	"Water supply I.e. collection, purification and distribution of water."
	430	"Generation of solar energy"
	431	"Generation and distribution of bio-gas energy"
	432	"Generation of energy through wind mills"
	439	"Generation and distribution of other non-conventional energy n.e.c."
	500	"Construction and maintenance of buildings"
	501	"Construction and maintenance of roads, railbeds, bridges, tunnels, pipelines, ropeways, ports, harbours and runways etc."
	502	"Construction/erection and maintenance of power, telecommunication and transmission lines"
	503	"Construction and maintenance of waterways and water reservoirs such as bunds, embankments, dams, canals, tanks, wells, tubewells and aquaducts etc."
	504	"Construction and maintenance of hydro-electric projects."
	505	"Construction and maintenance of power plants except hydro-electric projects"
	506	"Construction and maintenance of industrial plants excluding power plants"
	509	"Construction and maintenance not elsewhere classified"
	510	"Plumbing and drainage"
	511	"Heating and air-conditioning installation, lift installation, sound-proofing etc."
	512	"Setting of tiles, marble, bricks, glass and stonel"
	513	"Timber works (such as fixing of doors, windows, panels); structural steel work; R.C.C. work and binding of the bars and roof trusses"
	514	"Electrical installation work for constructions"
	515	"Painting and decorating work for constructions"
	519	"Other activities allied to construction not elsewhere classified"
	600	"Wholesale trade in cereals and pulses"
	601	"Wholesale trade in basic food-stuffs (other than cereals and pulses)"
	602	"Wholesale trade in textile fibres of vegetable/animal origin"
	603	"Wholesale trade in un-manufactured tobacco, pan levels, opium, ganja and cinchona etc."
	604	"Wholesale trade in straw, fodder and other animal/poultry feed"
	605	"Wholesale trade in live animal and poultry"
	606	"Wholesale trade in manufactured foodstuffs"
	607	"Wholesale trade in tea, coffee, cocoa, tobacco products and beverages other than intoxicants"
	608	"Wholesale trade in intoxicants like wines and liquors including incidental bottling"
	609	"Wholesale trade in textiles and textile products, like all kinds of yarn, fabrics, garments, and other made-up articles etc. (including second-hand textile goods)"
	610	"Wholesale trade in wool, cane, bamboo and thatches etc."
	611	"Wholesale trade in paper and other stationery goods"
	612	"Wholesale trade in skin, leather, fur and their products"
	613	"Wholesale trade in fuel and lighting products"
	614	"Wholesale trade in petrol, mobile oil and allied products"
	615	"Wholesale trade in medicines and chemicals"
	616	"Wholesale trade in fertilizers and pesticides"
	617	"Wholesale trade in toiletry, perfumery and cosmetics"
	618	"Wholesale trade in metal, porcelain and glass utensils, crockery and chinaware"
	619	"Wholesale trade in ores and metals"
	620	"Wholesale trade in agricultural and industrial machinery"
	621	"Wholesale trade in electrical machinery and equipment"
	622	"Wholesale trade in electronic equipment and accessories"
	623	"Wholesale trade in transport and storage equipment"
	630	"Wholesale trade in furniture and fixtures"
	631	"Wholesale trade in rubber, plastic and their products"
	632	"Wholesale trade in building materials"
	633	"Wholesale trade in hardware and sanitary fixtures"
	634	"Wholesale trade in household equipment, appliances n.e.c."
	635	"Wholesale trade in scientific, medical and surgical instruments"
	636	"Wholesale trade in watches/clocks, eye-glasses and spectacle frames"
	637	"Wholesale trade in precious metals, stones and jewellery"
	638	"Wholesale trade in wastes and metal scraps"
	639	"Wholesale trade in miscellaneous goods not elsewhere classified"
	640	"Commission agents dealing in agricultural raw materials, live animals, food, beverages, intoxicants and textiles"
	641	"Commission agents dealing in wood, paper, skin, leather and fur, fuel, petroleum, chemicals, perfumery, cosmetics, glass, ores and metals"
	642	"Commission agents dealing in machinery and equipment"
	649	"Other commission agents n.e.c."
	650	"Specialised retail trade in cereals and pulses, tea, coffee, spices, flour and other basic food items"
	651	"Retail trade in vegetables and fruits"
	652	"Retail trade in meat, fish and poultry"
	653	"Retail trade in sweetmeat, bakery products dairy products and eggs"
	654	"Retail trade in aerated water, soft drinks and ice-cream"
	655	"Retail trade in pan, bidi and cigarette"
	656	"Retail trade in wine and liquor, not consumed on the spot"
	659	"Retail trade in food and food articles, beverages, tobacco and intoxicants not elsewhere classified"
	660	"Retail trade in textiles"
	661	"Retail trade in ready-made garments, hosiery/knitted garments, etc. (includes Retail trade in second-hand garments)"
	670	"Retail trade in firewood, coal, kerosene oil and cooking gases"
	671	"Retail trade in footwear"
	672	"Retail trade in crockery, glass-ware and plastic ware"
	673	"Retail trade in utensils (except those specialising in plastic wares)"
	674	"Retail trade in furniture"
	675	"Retail trade in electric/electronic equipment (including watches and clocks)"
	676	"Retail trade in jewellery"
	679	"Retail trade in fuel and other household utilities and durables not elsewhere classified"
	680	"Retail trade in books, magazines, and stationery (including distribution of newspapers)"
	681	"Retail trade in agricultural inputs, viz. Seeds, fertilizers and pesticides"
	682	"Retail trade in motor fuels"
	683	"Retail trade in building materials"
	684	"Retail trade in agricultural machinery and equipment"
	685	"Retail trade in industrial machinery and equipment - electrical and non-electrical"
	686	"Retail trade in transport equipment"
	687	"Retail trade in pharmaceutical, medical and orthopaedic goods"
	688	"Non specialised retail trade including non-store retail trade"
	689	"Retail trade not elsewhere classified"
	690	"Restaurants, cafes and other eating and drinking places (Note: This group includes sales of prepared foods and drinks for immediate consumption on the premises such as restaurants, cafes, lunch counters and refreshment stands. Also includes are catering activities and take-out activities as well as dining-car activities of railway companies and other passenger transport facilities which are operated as independent activities.  Sales through vending machines, vending stalls, whether or not mobile, are included.  Note 2:   The above mentioned activities, if carried out in connection with the provision of lodging, are to be classified in group 691)"
	691	"Hotels, rooming houses, camps and other lodging places"
	700	"Railway transport"
	701	"Passenger transport by bus (including tramways)"
	702	"Passenger transport by motor vehicles other than by bus"
	703	"Freight transport by motor vehicles"
	704	"Passenger or freight transport via hackney - carriages bullock-carts, ekkas, tongas etc."
	705	"Transport via animals like horses, elephants, mules, camels , etc."
	706	"Transport by man (including rickshaw pullers, handcart pullers, porters , coolies, etc.)"
	707	"Pipe-line transport"
	708	"Supporting services to land transport, like operation of highway bridges, toll roads, vehicular tunnels, parking lots, etc."
	709	"Other land transport"
	710	"Ocean and coastal water transport"
	711	"Inland water transport"
	712	"Supporting services to water-transport like operation and maintenance of piers, docks, pilotage, lighthouses, loading and discharging of vessels, etc."
	720	"Air transport carriers (of passengers and freight)"
	721	"Supporting services to air transport, like operation of airports flying facilities, radio beacons, flying control centres, radar stations, etc."
	730	"Cargo handling incidental to land transport"
	731	"Cargo handling incidental to water tramsport"
	732	"Cargo handling incidental to air transport"
	733	"Renting and leasing (except financial leasing ) of motor vehicles, without operator for passenger transport (Renting and leasing of motor cycles, scooters and mopeds etc. is classified in group 850)"
	734	"Renting and leasing (except financial leasing) of motor vehicles, without operator, for freight transport"
	735	"Renting and leasing (except financial leasing) of aircrafts"
	736	"Renting and leasing (except financial leasing) of ships"
	737	"Activities of tourist and travel agents"
	738	"Activities of transport agents other than tourist and travel agents"
	739	"Other services incidental to transport n.e.c."
	740	"Warehousing of agricultural products without refrigeration"
	741	"Warehousing of agricultural products with refrigeration (cold storages)"
	749	"Storage and warehousing services not elsewhere classified (including warehousing of furniture, automobiles, gas and oil, chemicals and textiles. Also included is storage of goods in foreign trade zones)"
	750	"Postal, telegraphic, wireless and signal communication services"
	751	"Courier activities other than post. (This group includes picking up, transport and delivery of letters and mail-type, usually small parcels and packages. Either only one kind of transport or more than one mode of transport may be involved and the activity may be carried out with either self-owned (private) or public transport media. All postal activities carried out by the National Postal Administration are classified in group 750)"
	752	"Telephone communication services"
	759	"Communication services not elsewhere classified"
	800	"Deposit activities (This group includes activities of central banks, commercial banks, savings banks, savings and loan associations and other such institutions whose major source of funds is deposits)"
	801	"Other credit activities (This group includes activities of such units whose chief activity is making loans. They are distinguished from the deposit institutions in that the chief source of funds is equity or short term paper etc., but not deposits)"
	802	"Other banking activities"
	803	"Securities dealing activities (This group includes activities of brokers and dealers and central exchanges dealing in all kinds of negotiable instruments and underwriters and agents in the floatation of new securities)"
	804	"Financial services other than securities dealing activities"
	810	"Provident services"
	811	"Insurance carriers, life"
	812	"Deposit/credit guaranty insurance services"
	819	"Insurance carriers other than life such as fire, marine, accident, health including insurance agents, valuers/assessors, etc."
	820	"Purchase, sale, letting and operating of real estate such as residential and non-residential buildings, developing and sub-dividing real estate into lots, lessors of real property, real estate agents, brokers and managers engaged in renting buying and selling, managing and appraising real estates on a contract or fee basis"
	830	"Legal services such as those rendered by advocates, barristers, solicitors, pleaders, mukatiars, etc."
	840	"Bulk purchase and sale of lottery tickets"
	841	"Sale of lottery tickets to individuals"
	850	"Renting of transport equipment without operator n.e.c. (Includes short-term rental as well as extended-term leasing with or without maintenance)"
	851	"Renting of agricultural machinery and equipment, without operator"
	852	"Renting of office, accounting and computing machinery and equipment, without operator. (Renting of computer time on an hourly or time-sharing basis is classified in group 892. Renting of computers or computer-related equipment with management or operation is also classified in group 892)"
	853	"Renting of other industrial machinery and equipment. (This group includes the renting or leasing of all kinds of machinery which is generally used as investment goods by industries)."
	854	"Renting of personal and household goods. (This group includes the rental of all kinds of goods whether or not the customers are households. It involves the rental of such goods as textiles, wearing apparel and footwear, furniture, pottery and glass,kitchen and tableware, electrical appliances and house-wares, jewellery, musical instruments, and so on. Book rental is classified in group 956)"
	890	"Auctioneering services"
	891	"Accounting, book-keeping and auditing activities, including tax consultancy services"
	892	"Data processing, software development and computer consultancy services"
	893	"Business and management consultancy activities"
	894	"Architectural and engineering and other technical consultancy activities"
	895	"Technical testing and analysis services. (This group includes testing of all types of materials and products. Seed testing is classified in 039.9 and medical testing in division 93)"
	896	"Advertising"
	897	"Press agency activities. (This group includes news syndicate and news agency activities on a fee or contract basis. Includes activities of independent news reporters, news writers, etc.)"
	898	"Recruitment and provision of personnel"
	899	"Other business services not elsewhere classified"
	900	"Public services in the union government including defence services"
	901	"Public services in state governments including police services"
	902	"Public services in local bodies, departments and offices engaged in administration like local taxation and business regulations etc."
	903	"Public services in quasi-government bodies"
	910	"Sanitation and similar services such as garbage and sewage disposal, operation of drainage systems and all other types of work connected with public health and sanitation"
	920	"Educational services rendered by technical or vocational colleges, schools and other institutions"
	921	"Educational services rendered by non-technical colleges, schools, universities and other institutions"
	922	"Research and scientific services not classified elsewhere such as those rendered by institutions and laboratories engaged in research in the biological, physical and social sciences, meteorological institutes and medical research organisations etc."
	930	"Health and medical services rendered by organisations and individuals such as hospitals, dispensaries, sanatoria, nursing homes, maternal and child welfare clinics, by allopathic/ayurvedic, unani, homaeopathic, etc. practitioners"
	931	"Veterinary services (including birds' hospitals)"
	940	"Religious services rendered by organisations or individuals"
	941	"Welfare services rendered by organisations operating on a no-profit basis for the promotion of welfare of the community such as relief societies, creches, homes for the aged, and physically handicapped, etc.q"
	942	"Services rendered by business, professional and labour organisations n.e.c."
	943	"Services rendered by cooperative societies n.e.c."
	949	"Community services not elsewhere classified"
	950	"Motion picture and video film production"
	951	"Motion picture distribution and projection services"
	952	"Stage production and related services"
	953	"Authors, music composers, singers, dancers, magicians , and other independent artistes not elsewhere classified"
	954	"Radio and television broadcasting and related services"
	955	"Operation of circuses and race tracks"
	956	"Libraries, museums, botanical and zoo-logical gardens, zoos, game sanctuaries etc."
	957	"Audio and video casette libraries"
	958	"Video parlours, electronic games and other amusement centres n.e.c."
	959	"Recreational services n.e.c."
	960	"Domestic services"
	961	"Laundry, cleaning and dyeing services"
	962	"Hair dressing such as those done by barbers, hair dressing saloons and beauty shops etc."
	963	"Portrait and commercial photographic studios"
	964	"Tailoring establishments"
	969	"Personal services not elsewhere classified"
	970	"Repair of footwear and other leather goods"
	971	"Repair of household electrical appliances"
	972	"Repair of TV, VCR, radio, transistor, tape-recorder, refrigerator and other electronic appliances"
	973	"Repair of watches, clocks and jewellery"
	974	"Repair of motor vehicles and motor cycles except trucks, lorry and other heavy vehicles"
	975	"Repair of bicycles and cycle rickshaws"
	979	"Repair enterprises not elsewhere classified"
	980	"International and other extra territorial bodies"
	990	"Services not elsewhere classified";
	#delimit cr
	la val industry_e_orig lblindustry_e_orig
	la var industry_e_orig "Original industry code"
	notes industry_e_orig : "IND 1993" downloaded from http://dipp.nic.in/English/Investor/Investers_Gudlines/NIC_codes/nic.htm
*</_industry_e_orig_>

** INDUSTRY CLASSIFICATION MAIN EARNER
*<_industry_e_>
	gen ind=int(S1B31_v2i/100)
	recode ind 	(0=1) (1=2) (2/3=3) (4=4) (5=5) (6=6) (7=7) (8=8) (9=10), gen(industry_e)
	replace industry_e=9 if S1B31_v2i>=900 & S1B31_v2i<=910
	label var industry_e "1 digit industry classification (main earner)"
	la de lblindustry_e 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" ///
	5 "Construction"  6 "Commerce" 7 "Transports and comnunications" 8 "Financial and business-oriented services" ///
	9 "Public Administration" 10 "Other services, Unspecified"
	label values industry_e lblindustry_e
*</_industry_e_>

**ORIGINAL OCCUPATION CLASSIFICATION
*<_occup_orig_>
	gen occup_e_orig=S1B31_v2ii
	#delimit
	label define lbloccup_e_orig 
	0	"Physicist"
	1	"Chemists (Excluding Pharmaceutical Chemists)"
	2	"Geologists And Geophysicists"
	3	"Meteorologist"
	9	"Physical Scientists, N"
	10	"Physical Science Technicians"
	20	"Architects And Town Planners"
	21	"Civil Engineers"
	22	"Electrical And Electronic Engineers"
	23	"Mechanical Engineers"
	24	"Chemical Engineers"
	25	"Metallurgists"
	26	"Mining Engineers"
	27	"Industrial Engineers"
	28	"Surveyors"
	29	"Architects, Engineers, Technologists And Surveyors ,N"
	30	"Draughtsmen"
	31	"Civil Engineering Overseers And Technicians"
	32	"Electrical And Electronic Engineering Overseers And Technicians"
	33	"Mechanical Engineering Overseers And Technicians"
	34	"Chemical Engineering Technicians"
	35	"Metallurgical Technicians"
	36	"Mining Technicians"
	37	"Survey Technicians"
	39	"Engineering Technicians, N"
	40	"Aircraft Pilots"
	41	"Flight Engineers"
	42	"Flight Navigators"
	43	"Ship'S Deck Officers And Pilots"
	44	"Ships Engineers"
	49	"Aircraft And Ship'S Officers, N"
	50	"Biologists, Zoologists, Botanists And Related Scientists"
	51	"Bacteriologists, Pharmacologists &Related Scientists"
	52	"Silviculturists"
	53	"Agronomists And Agricultural Scientists"
	59	"Life Scientists, N"
	60	"Life Science Technicians"
	70	"Physicians And Surgeons, Allopathic"
	71	"Physicians And Surgeons, Ayurvedic"
	72	"Physicians And Surgeons, Homoeopathic"
	73	"Physician And Surgeons, Unani"
	74	"Dental Surgeons"
	75	"Veterinarians"
	76	"Pharmacists"
	77	"Dieticians And Nutritionists"
	78	"Public Health Physicians"
	79	"Physicians And Surgeons, N"
	80	"Vaccinators, Inoculators And Medical Assistants"
	81	"Dental Assistants"
	83	"Pharmaceutical Assistants"
	84	"Nurses"
	85	"Midwives And Health Visitors"
	86	"X-Ray Technicians"
	87	"Optometrists And Opticians"
	88	"Physiotherapists And Occupational Therapists"
	89	"Technicians , N"
	90	"Scientific Medical And Technical Persons, Other"
	100	"Mthematiciansa"
	101	"Statisticians"
	102	"Actuaries"
	103	"System Analysts And Programmers"
	104	"Statistical Investigators And Related Workers"
	109	"Mathematicians, Statisticians & Related Workers ,N"
	110	"Economists"
	111	"Economic Investigators And Related Workers"
	119	"Economists And Related Workers, N"
	120	"Accountants And Auditors"
	121	"Cost And Works Accountants"
	129	"Accountants, Auditors And Related Workers, N"
	130	"Sociologists And Anthropologists"
	131	"Historians, Archeologists & Political Scientists & Related Workers"
	132	"Geographers"
	133	"Psychologists"
	134	"Librarians, Archivists And Curators"
	135	"Philologists, Translators And Interpreters"
	136	"Personnel And Occupational Specialists"
	137	"Labour, Social Welfare & Political Workers"
	139	"Social Scientists And Related Workers, N"
	140	"Lawyers"
	141	"Judges And Magistrates"
	142	"Legal Assistants"
	149	"Jurists, N"
	150	"Teachers, University And Colleges"
	151	"Teachers, Higher Secondary & Secondary Schools"
	152	"Teachers, Middle School"
	153	"Teachers, Primary"
	154	"Teachers, Pre-Primary"
	155	"Teachers, Special Education"
	156	"Teachers, Craft"
	159	"Teachers, N"
	160	"Poets, Authors And Critics"
	161	"Editors And Journalists"
	169	"Poets, Authors, Journalists And Related Workers, N"
	170	"Sculptors, Painters And Related Artists"
	171	"Commercial Artists, Interior Decorators& Designers"
	172	"Movie Camera Operators"
	173	"Photographers, Other"
	179	"Sculptors, Painters, Photographers &Related Creative Artists, N"
	180	"Composers, Musicians And Singers"
	181	"Choreographers And Dancers"
	182	"Actors"
	183	"Stage & Film Directors & Producers (Performing Arts)"
	184	"Circus Performers"
	189	"Composers And Performing Artists, N"
	190	"Ordained Religious Workers"
	191	"Non-Ordained Religious Workers"
	192	"Astrologers, Palmists And Related Workers"
	193	"Athletes, Sportsmen And Related Workers"
	199	"Professional Workers N"
	200	"Elected Officials, Union Government"
	201	"Elected Officials, State Government"
	202	"Elected Officials, Local Bodies"
	209	"Elected Officials, N"
	210	"Administrative & Executive Officials, Union Govt"
	211	"Administrative & Executive Officials, State Government"
	212	"Administrative& Executive Officials, Quasi G Overnment"
	213	"Administrative &Executive Officials, Local Bodies"
	219	"Administrative &Executive Officials, Govt & Local Bodies, N"
	220	"Working Proprietors, Directors & Managers, Wholesale"
	221	"Working Proprietors, Directors & Managers, Retail Trade"
	229	"Working Proprietors, Directors And Managers Wholesale & Retail Trade, N"
	230	"Directors And Managers, Bank"
	231	"Directors And Managers, Insurance"
	239	"Directors And Managers, Financial Institution N"
	240	"Working Proprietors ,Directors &Managers, Mining, Quarrying And Well Drilling"
	241	"Working Proprietors, Directors & Managers, Construction"
	242	"Working Proprietors, Directors & Managers, Electricity, Gas And Water"
	243	"Working Proprietors, Directors & Managers, Manufacturing"
	249	"Manufacturing And Related Concerns, N"
	250	"Working Proprietors, Directors ,Managers & Related Executives, Transport"
	251	"Directors, Managers & Related Executives, Communication"
	252	"Warehouse"
	259	"Storage And Communication, N"
	260	"Working Proprietors, Directors & Managers, Lodging &Catering Services"
	261	"Working Props, Dirs & Managers, Recreation & Entertain"
	269	"Working Proprietors, Directors, Managers,& Related Executives, Other Services"
	299	"Administrative, Executive &Ma Nagerial Workers, N"
	300	"Clerical Supervisors,( Office"
	301	"Other Supervisors (Inspectors, Etc"
	302	"Ministerial And Office Assistants"
	309	"Clerical And Other Supervisors, Other"
	310	"Village Officials"
	320	"Stenographers And Steno-Typists"
	321	"Typists"
	322	"Tele-Typists"
	323	"Card & Tapepunching Machine Operators"
	329	"Stenographer, Typist & Card & Tape Punching Operators, N"
	330	"Book Keepers And Accounts Clerks"
	331	"Cashiers"
	339	"Bookkeepers, Cashiers & Related Workers, N"
	340	"Book-Keeping & Calculating Machine Operators"
	341	"Automatic Data Processing Machine Operators"
	349	"Computing Machine Operators, N"
	350	"Clerks, General"
	351	"Store Keeper And Related Workers"
	352	"Receptionists"
	353	"Library Clerks"
	354	"Time Keepers"
	355	"Coders"
	356	"Ticket Sellers"
	358	"Office Attendants (Peons, Daftries, Etc)"
	359	"Clerical & Related Workers(Including Proof Readers &Copy Holders), N"
	360	"Station Masters And Station Superintendents, Transport"
	361	"Postmasters, Telegraph Masters And Other Supervisors"
	369	"Transport & Communication Supervisor, N"
	370	"Guards And Breaks Men, Railway"
	371	"Conductors, Transport"
	379	"Transport Conductors And Guards, N"
	380	"Postmen"
	381	"Messengers And Dispatch Riders"
	389	"Mail Distributors And Related Workers, N"
	390	"Telephone Operators"
	391	"Telegraphists And Signallers"
	392	"Radio Communication And Wireless Operators"
	399	"Telephone And Telegraph Operators, N"
	400	"Merchants And Shopkeepers, Wholesale Trade"
	401	"Merchants And Shopkeepers, Retail Trade"
	409	"Merchants & Shop Keepers & Wholesale & Retail Trade, N"
	410	"Sales Supervisors"
	411	"Purchasing Agents"
	412	"Selling Agents"
	419	"Manufacturers Agents, N"
	420	"Technical Salesmen And Service Advisors"
	421	"Commercial Travellers"
	429	"Technical Salesmen And Commercial Travellers, N"
	430	"Salesmen, Shop Assistants And Demonstrators"
	431	"Street Vendors, Canvassers And News Vendors"
	439	"Salesmen, Shop Assistants & Related Workers, N"
	440	"Agents And Salesmen, Insurance"
	441	"Agents, Brokers And Salesmen, Real Estate"
	442	"Agents And Brokers, Securities And Shares"
	443	"Agents, Brokers & Salesmen, Advertising & Other Business Services"
	444	"Auctioneers"
	445	"Valuers And Appraisers"
	449	"NEC"
	450	"Money Lenders (Including Indigenous Bankers)"
	451	"Pawn Brokers"
	459	"Money Lenders And Pawn Brokers, N"
	490	"Sales Workers, N"
	500	"Hotel And Restaurant Keepers"
	510	"House Keepers, Matrons And Stewards"
	520	"Cooks And Cook Bearers"
	521	"Butlers, Bearers And Waiters"
	522	"Bartenders And Related Workers"
	529	"Cooks, Waiters And Related Workers, N"
	530	"Ayahs, Nurse, Maids"
	531	"Domestic Servants"
	539	"Maids And Related Housekeeping Service Workers, N"
	540	"Building Caretakers"
	541	"Sweepers, Cleaners And Related Workers"
	542	"Watermen"
	549	"Building Caretakers, Sweepers, Cleaners & Related Workers, N"
	550	"Laundrymen, Washermen And Dhobis"
	551	"Dry Cleaners And Pressers"
	559	"Launderers, Dry Cleaners And Pressers, N"
	560	"Hair D Ressers, Barbers, Beauticians & Related Workers"
	570	"Fire Fighters"
	571	"Policemen And Detectives"
	572	"Customs Examiners, Patrollers & Related Workers"
	573	"Protection Force, Home Guard And Security Workers"
	574	"Watchmen, Chowkidars And Gate Keepers"
	579	"Protective Service Workers, N"
	590	"Guides"
	591	"Undertakers And Embalmers"
	599	"Service Workers, N"
	600	"Farm Managers & Supervisors, Crop Production"
	601	"Manager, Plantation"
	602	"Farm Managers, Horticulture"
	603	"Farm Manager, Livestock Farm"
	604	"Farm Manager, Dairy Farm"
	605	"Farm Manager, Poultry Farm"
	609	"Farm Managers And Supervisors, N"
	610	"Cultivators (Owners)"
	611	"Cultivators (Tenants)"
	619	"Cultivators, N"
	620	"Planters"
	621	"Livestock Farmers"
	622	"Dairy Farmers"
	623	"Poultry Farmers"
	624	"Insect Rearers"
	625	"Orchard, Vineyard And Related Workers"
	629	"Farmers, Other Than Cultivators, N"
	630	"Agricultural Labourers"
	640	"Plantation Labourers"
	641	"Tappers, (Palm, Rubber Trees, Etc"
	649	"Plantation Labourers And Related Workers, N"
	650	"Farm Machinery Operators"
	651	"Farm Workers, Animal, Birds And Insect Rearing"
	652	"Gardeners And Nursery Workers"
	659	"Other Farm Workers, N"
	660	"Foresters And Related Workers"
	661	"Harvesters & Gatherers Of Forest Products Including Lac(Except Logs)"
	662	"Log Fellers And Wood Cutters"
	663	"Charcoal Burners & Forest Product Processors"
	669	"Loggers And Other Forestry Workers, N"
	670	"Hunters"
	671	"Trappers"
	679	"Hunters And Related Workers, N"
	680	"Fishermen, Deep Sea"
	681	"Fishermen, Inland And Coastal Waters"
	682	"Conch & Shell Gatherers, Sponge & Pearl Divers"
	689	"Fishermen And Related Workers, N"
	710	"Supervisor & Foreman, Mining, Quarrying, Well Drilling & Related Activities"
	711	"Miners"
	712	"Quarrymen"
	713	"Drillers, Mines And Quarries"
	714	"Shot Firers"
	715	"Miners And Quarrymen, Other"
	716	"Well Drillers, Petroleum And Gas"
	717	"Well Drillers, Other Than Petroleum And Gas"
	718	"Mineral Treaters"
	719	"Miners, Quarrymen & Related Workers, N"
	720	"Supervisors & Foremen, Metal Smelting Converting Refining"
	721	"Metal Smelting, Converting & Refining Furnace Men"
	722	"Metal Rolling Mill Workers"
	723	"Metal Melters And Reheaters"
	724	"Metal Casters"
	725	"Metal Moulder And Core Makers"
	726	"Metal Annealers, Temperers And Case Hardeners"
	727	"Metal Drawers And Extruders"
	728	"Metal Platters And Coaters"
	729	"Metal Processors, N"
	730	"Supervisor & Foreman, Wood Preparation & Paper Making"
	731	"Wood Treaters"
	732	"Sawyers, Plywood Makers & Related Wood Processing Workers"
	733	"Paper Pulp Preparers"
	734	"Paper Makers"
	739	"Wood Preparation And Paper Making Workers N"
	740	"Supervisor & Foreman, Chemical Processing & Related Activities"
	741	"Crushers, Grinders And Mixers"
	742	"Cookers, Roasters And Related Heat Treaters"
	743	"Filter And Separator Operators"
	744	"Still And Reactor Operators"
	745	"Petroleum Refining Workers,"
	749	"Chemical Processors And Related Workers, N"
	750	"Supervisors & Foremen, Spinning, Weaving, Knitting, Dyeing & Related"
	751	"Fibre Preparers"
	752	"Spinners And Winders"
	753	"Warpers And Sizers"
	754	"Weaving & Knitting Machine Setters & Pattern Card Preparers"
	755	"Weavers And Related Workers"
	756	"Carpet Makers And Finishers"
	757	"Knitters"
	758	"Bleachers, Dyers And Textile Product Finishers"
	759	"Spinners, Weavers,K Nitters,Dyers & Related Workers, N"
	760	"Supervisors & Foremen, Tanning & Pelt Dressing"
	761	"Tanners And Fell Mongers"
	762	"Pelt Dressers"
	769	"Fell Mongers And Pelt Dressers, N"
	770	"Supervisors & Foremen, Food & Beverage Processing"
	771	"Grain Millers, Parchers And Related Workers"
	772	"Crushers And Pressers, Oil Seeds"
	773	"Khandsari, Sugar And Gur Makers"
	774	"Butchers And Meat Preparers"
	775	"Food Preservers And Canners"
	776	"Dairy Product Processors"
	777	"Bakers, Confectioners, Candy & Sweet Meat Makers, Other Food Processors"
	778	"Tea, Coffee & Cocoa Prepares"
	779	"Brewers & Aerated Water & Beverage Makers"
	780	"Supervisors & Foremen Tobacco & Tobacco Product Makers"
	781	"Tobacco Prepares"
	782	"Cigar Makers"
	783	"Cigarette Makers"
	784	"Bidi Makers"
	789	"Tobacco Prepares And Tobacco Product Makers, N"
	790	"Supervisors & Foremen, Tailoring, Dress Making, Sewing, Upholsterywork"
	791	"Tailors And Dress Makers"
	793	"Milliners, Hat And Cap Makers"
	794	"Pattern Makers And Cutters"
	795	"Sewers And Embroiders"
	796	"Upholsterers And Related Workers"
	799	"Tailors, Dressmakers, Sewers, Upholsterers & Related Workers, N"
	800	"Supervisor & Foremen, Shoe & Leather Goods Making"
	801	"Shoe Makers & Shoe Repairers"
	802	"Shoe Cutters, Lasters, Sewers And Related Workers"
	803	"Harness And Saddle Makers"
	809	"Leather, Cutters, Lasters & Sewers & Related Workers, N"
	810	"Processes"
	811	"Carpenter"
	813	"Wood Working Machine Operators"
	814	"Cart Builders And Wheel Wrights"
	815	"Coach And Body Builders"
	816	"Shipwrights And Boat Builders"
	819	"Carpenters, Cabinet Makers & Related Workers,N"
	820	"Supervisors And Foremen, Stone Cutting And Carving"
	821	"Stone Cutter And Carvers"
	829	"Stone Cutters And Carvers, N"
	830	"Supervisors & Foremen, Blacksmithy, Tool Making And Machine Tool Operations"
	831	"Blacksmiths, Hammersmiths & Forgin G Press Operators"
	832	"Metal Markers"
	833	"Tool Makers And Metal Pattern Makers"
	834	"Machine Tool Setters"
	835	"Machine Tool Operators"
	836	"Metal Grinders, Polishers And Tool Sharpeners"
	839	"Blacksmiths, Toolmakers, Machine Tool Operators, N"
	840	"Instrument Making (Except Electrical)"
	841	"Watch, Clock & Precision Instrument Makers(Except Electrical)"
	842	"Machinery Fitters And Machine Assemblers"
	843	"Motor Vehicle Mechanics"
	844	"Aircraft Engine Mechanics"
	845	"Mechanics, Repairmen, Other"
	849	"Electrical),N"
	850	"Installing & Repairing"
	851	"Electricians, Electrical Fitters And Related Workers"
	852	"Electronics Fitters"
	853	"Electric And Electronic Equipment Assemblers"
	854	"Radio Television Mechanics And Repairmen"
	855	"Electrical Wiremen"
	856	"Telephone And Telegraph Installers And Repairmen"
	857	"Electric Linemen And Cable Jointers"
	859	"Electrical Fitters & Related Electrical & Electronic Workers, N"
	860	"Supvisors, Broadcasting, Audio-Visual Projection & Sound Equipment Operators"
	861	"Radio Broadcasting Televisio N Operators"
	862	"Sound Equipment Operators & Cinema Projectionists"
	869	"Broadcasting Station & Sound Equipment Operators & Cinema Projectionists"
	870	"Supervisors, Foremen, Plumbing, Welding Structural & Sheet Metal Working"
	871	"Plumbers And Pipe Fitters"
	872	"Welders And Flame Cutters"
	873	"Sheet Metal Workers"
	874	"Metal Plate And Structural Metal Workers"
	879	"Plumbers, Welders, Sheet Metal & Structural Metal Preparers & Erectors, N"
	880	"Supervisors, Jewellery And Precious Metal Working"
	881	"Jewellers, Goldsmiths & Silversmiths"
	882	"Jewellery Engravers"
	883	"Other Metal Engravers (Except Printing)"
	889	"Jewellers & Precious Metal Workers, N"
	890	"Supervisors & Foremen, Glass Forming, Pottery & Related Activities"
	891	"Glass Formers, Cutters, Grinders And Finishers"
	892	"Potters And Related Clay & Abrasive Formers"
	893	"Glass And Ceramic Kilnmen"
	894	"Glass Engravers And Etchers"
	895	"Glass And Ceramics Painters And Decorators"
	899	"Glass Formers, Potters & Related Workers, N"
	900	"Supervisors &Foremen, Rubber &Plastics Product Making"
	901	"Plastics Product Makers"
	902	"Rubber Product Makers ( Except Tyre Makers & Vulcanisers)"
	903	"Tyre Makers And Vulcanisers"
	909	"Rubber And Plastics Product Makers, N"
	910	"Supervisors & Foremen Paper & Paper Board Product Making"
	911	"Paper And Paper Board Product Makers"
	919	"Paper And Paper Product Makers, N"
	920	"Supervisors & Foremen Printing & Related Work"
	921	"Compositors"
	922	"Type Setters And Photo-Type Setters"
	923	"Printing Pressman"
	924	"Stereo-Typers And Electro-Typers"
	925	"Engravers, Printing(Except Photo Engravers)"
	926	"Photo Engravers"
	927	"Book Binders And Related Workers"
	928	"Photographic Dark Room Workers"
	929	"Printers And Related Workers, N"
	930	"Supervisors And Foremen, Painting"
	931	"Painters, Construction"
	932	"Painters, Spray And Sign Writing"
	939	"Painters, N"
	940	"Supervisors And Foremen Production & Related Activities, N"
	941	"Musical Instrument Makers And Tuners"
	942	"Basketry Weavers And Brush Makers"
	943	"Non-Metallic Mineral Product Makers"
	949	"Production And Related Workers, N"
	950	"Supervisors & Foremen, Bricklaying Other Construction Work"
	951	"Bricklayers, Stone Masons And Tile Setters"
	952	"Reinforced Concreters, Cement Finishers And Terrazzo Workers"
	953	"Roofers"
	954	"Parquetry Workers"
	955	"Plasterers"
	956	"Insulators"
	957	"Glaziers"
	958	"Hut Builders And Thatchers"
	959	"Construction Workers, N"
	960	"Supervisors & Foremen, Stationary &Related Equipment Operations"
	961	"Stationary Engine &Related Equipment Operators"
	962	"Boilermen And Firemen"
	963	"Oilers & Greasers (Including Cleaners Motor Vehicle)"
	969	"Stationary Engine & Related Equipment Operators, N"
	970	"Supervisors & Foremen, Material & Freight Handling & Related Equipment"
	971	"Loaders And Unloaders"
	972	"Riggers And Cable Splicer"
	973	"Crane And Hoist Operators"
	974	"Earth Moving & Related Machinery Operators"
	975	"Checkers, Testers, Sorters, Weighers And Counters"
	976	"Packers, Labellers And Related Workers"
	979	"Material Handling Equipment Operators, N"
	980	"Supervisors &Foremen, Transport Equipment Operation"
	981	"Ships 'Deck Ratings, Barge Crews And Boatmen"
	982	"Ships' Engine Room Ratings"
	983	"Drivers, Railways"
	984	"Firemen, Railways"
	985	"Pointsmen, Signalmen And Shunters, Railways"
	986	"Tram Car And Motor Vehicle Drivers"
	987	"Drivers, Animal And Animal Drawn Vehicles"
	988	"Cycle Rickshaw Drivers And Rickshaw Pullers"
	989	"Transport Equipment Operators And Drivers, N";
	#delimit cr
	la val occup_e_orig lbloccup_e_orig
	la var occup_e_orig "Original occupation code"
*</_occup_e_orig_>

** OCCUPATION CLASSIFICATION MAIN EARNER
*<_occup_e_>

    /*Please see the excel file called "occupation_classification" in folder doc-techinical to see how this variable
	was constructed using the ISCO-08. It is important to note that the difference between category 7 and 8 in 
	the India NCO 1968 is not very clear. */

    gen str3 occup3=string(S1B31_v2ii,"%03.0f")
    gen str3 occup2=substr(occup3,1,2)
	gen occup_e=.
	
	**Senior officials, Managers
	replace occup_e=2 if inrange(occup2, "20","31")
    replace occup_e=2 if inlist(occup2, "36","60")
	
	**Professionals
	replace occup_e=2 if inlist(occup2, "00","02","05","07","86")
    replace occup_e=2 if inrange(occup2, "10","19")

	**Technicians and associate professionals
	replace occup_e=3 if inlist(occup2, "01","03","04","06","08","09")
	
	**Clerical support workers
	replace occup_e=4 if inrange(occup2, "32","35")
    replace occup_e=4 if inrange(occup2, "37","39")

	*Service and sales workers
	replace occup_e=5 if inrange(occup2, "40","59")
  
	*Skilled agricultural, forestry and fishery workers
	replace occup_e=6 if inrange(occup2, "61","68")

	*Craft and related trades workers
	replace occup_e=7 if inrange(occup2, "71","73")
	replace occup_e=7 if inrange(occup2, "75","82")
	replace occup_e=7 if inlist(occup2, "84","85")
	replace occup_e=7 if inrange(occup2, "92","95")

	
	*Plant and machine operators, and assemblers
	replace occup_e=8 if inlist(occup2, "74","83")
    replace occup_e=8 if inrange(occup2, "87","91")
	replace occup_e=8 if inrange(occup2, "96","98")
	
	*Elementary occupations
	replace occup_e=9 if occup2=="99"
	
	*other/unspecified
	replace occup_e=99 if inlist(occup2,"X0","X1","X9")

		   
	*Next occupations are classified as professionals 
	replace occup_e=2 if inlist(occup3, "084","085","085","087","088")
	
	*Next occupations are classified as Senior officials, Managers 
	replace occup_e=1 if inlist(occup3,"710","720","730","740","750","760","770","780","790")
	replace occup_e=1 if inlist(occup3,"800","810","820","830","840","850","860","870","880")
    replace occup_e=1 if inlist(occup3,"890","900","910","920","930","940","950","960","970")
	replace occup_e=1 if inlist(occup3,"980")

    drop  occup2 occup3 

	label var occup_e "1 digit occupational classification (main earner)"
	label define occup_e 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" ///
	5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" ///
	8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup_e occup_e

	
*</_occup_e_>

	note lstatus_e:"IND 1993" 	Data recolected only for main income earner of the household.
	note empstat_e:"IND 1993"	Data recolected only for main income earner of the household.
	note industry_e:"IND 1993" 	Data recolected only for main income earner of the household.
	note occup_e:"IND 1993"	Data recolected only for main income earner of the household.
	note _dta: "IND 1993" No information on second occupations for this survey.
	
/*****************************************************************************************************
*                                                                                                    *
                                            ASSETS 
*                                                                                                    *
*****************************************************************************************************/

** LAND PHONE
*<_landphone_>

	gen landphone=.
	label var landphone "Household has a land phone"
	la de lbllandphone 0 "No" 1 "Yes"
	label val landphone lbllandphone
*</_landphone_>


** CEL PHONE
*<_cellphone_>

	gen cellphone=.
	label var cellphone "Household has a cell phone"
	la de lblcellphone 0 "No" 1 "Yes"
	label val cellphone lblcellphone
*</_cellphone_>


** COMPUTER
*<_computer_>
	gen computer=.
	label var computer "Household has a computer"
	la de lblcomputer 0 "No" 1 "Yes"
	label val computer lblcomputer
*</_computer_>

** RADIO
*<_radio_>
	gen radio=!inlist(S1B91_v3711, 0, .)
	label var radio "household has a radio"
	la de lblradio 0 "No" 1 "Yes"
	label val radio lblradio
*</_radio_>

** TELEVISION
*<_television_>
	gen television=!inlist(S1B91_v3713, 0, .)
	label var television "Household has a television"
	la de lbltelevision 0 "No" 1 "Yes"
	label val television lbltelevision
*</_television>

** FAN
*<_fan_>
	gen fan=!inlist(S1B91_v3750, 0, .)
	label var fan "Household has a fan"
	la de lblfan 0 "No" 1 "Yes"
	label val fan lblfan
*</_fan>

** SEWING MACHINE
*<_sewingmachine_>
	gen sewingmachine=!inlist(S1B91_v3755, 0, .)
	label var sewingmachine "Household has a sewing machine"
	la de lblsewingmachine 0 "No" 1 "Yes"
	label val sewingmachine lblsewingmachine
*</_sewingmachine>

** WASHING MACHINE
*<_washingmachine_>
	gen washingmachine=!inlist(S1B91_v3756, 0, .)
	label var washingmachine "Household has a washing machine"
	la de lblwashingmachine 0 "No" 1 "Yes"
	label val washingmachine lblwashingmachine
*</_washingmachine>

** REFRIGERATOR
*<_refrigerator_>
	gen refrigerator=!inlist(S1B91_v3757, 0, .)
	label var refrigerator "Household has a refrigerator"
	la de lblrefrigerator 0 "No" 1 "Yes"
	label val refrigerator lblrefrigerator
*</_refrigerator>

** LAMP
*<_lamp_>
	gen lamp=!inlist(S1B91_v3761, 0, .)
	label var lamp "Household has a lamp"
	la de lbllamp 0 "No" 1 "Yes"
	label val lamp lbllamp
*</_lamp>

** BYCICLE
*<_bycicle_>
	gen bicycle=!inlist(S1B91_v3770, 0, .)
	label var bicycle "Household has a bicycle"
	la de lblbycicle 0 "No" 1 "Yes"
	label val bicycle lblbycicle
*</_bycicle>

** MOTORCYCLE
*<_motorcycle_>
	gen motorcycle=!inlist(S1B91_v3771, 0, .)
	label var motorcycle "Household has a motorcycle"
	la de lblmotorcycle 0 "No" 1 "Yes"
	label val motorcycle lblmotorcycle
*</_motorcycle>

** MOTOR CAR
*<_motorcar_>
	gen motorcar=!inlist(S1B91_v3772, 0, .)
	label var motorcar "household has a motor car"
	la de lblmotorcar 0 "No" 1 "Yes"
	label val motorcar lblmotorcar
*</_motorcar>

** COW
*<_cow_>
	gen cow=(S1B32_v4==2)
	label var cow "Household has a cow"
	la de lblcow 0 "No" 1 "Yes"
	label val cow lblcow
*</_cow>

** BUFFALO
*<_buffalo_>
	gen buffalo=(S1B32_v4==3)
	label var buffalo "Household has a buffalo"
	la de lblbuffalo 0 "No" 1 "Yes"
	label val buffalo lblbuffalo
*</_buffalo>

** CHICKEN
*<_chicken_>
	gen chicken=.
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
	gen spdef=pline
	la var spdef "Spatial deflator"
*</_spdef_>


** WELFARE
*<_welfare_>
	gen welfare=mpce_urp
	la var welfare "Welfare aggregate"
*</_welfare_>

*<_welfarenom_>
	gen welfarenom=mpce_urp
	la var welfarenom "Welfare aggregate in nominal terms"
*</_welfarenom_>

*<_welfaredef_>
	gen welfaredef=mpce_urp_real
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
	gen welfareother=mpce_mrp
	la var welfareother "Welfare Aggregate if different welfare type is used from welfare, welfarenom, welfaredef"
*</_welfareother_>

*<_welfareothertype_>
	gen welfareothertype="CON"
	la var welfareothertype "Type of welfare measure (income, consumption or expenditure) for welfareother"
*</_welfareothertype_>

*<_welfarenat_>
	gen welfarenat=mpce_mrp
	la var welfarenat "Welfare aggregate for national poverty"
*</_welfarenat_>	
/*****************************************************************************************************
*                                                                                                    *
                                   NATIONAL POVERTY
*                                                                                                    *
*****************************************************************************************************/


** POVERTY LINE (NATIONAL)
*<_pline_nat_>
	ren pline pline_nat
	label variable pline_nat "Poverty Line (National)"
*</_pline_nat_>


** HEADCOUNT RATIO (NATIONAL)
*<_poor_nat_>
	gen poor_nat=welfarenat<pline_nat & welfarenat!=.
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
	gen urb=urban
	merge m:1 countrycode year urb using "$pricedata", keepusing(countrycode year urb syear cpi`year'_w ppp`year')
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

	keep countrycode year survey idh idp wgt pop_wgt wgt_wdi strata psu vermast veralt urban int_month int_year  ///
	     subnatid1 subnatid2 subnatid3 gaul_adm1_code ownhouse landholding tenure water_orig water_jmp piped_water sar_improved_water electricity toilet_orig toilet_jmp sewage_toilet sar_improved_toilet internet ///
		 hsize relationharm relationcs male age soc marital ed_mod_age everattend ///
	     atschool electricity literacy educy educat4 educat5 educat7 lb_mod_age lstatus empstat njobs ///
	     ocusec nlfreason unempldur_l unempldur_u industry  occup firmsize_l firmsize_u whours wage ///
		 unitwage contract healthins socialsec union lstatus_e empstat_e industry_e_orig industry_e occup_e_orig occup_e  ///
		 landphone cellphone computer radio television fan sewingmachine washingmachine  ///
		 refrigerator lamp bicycle motorcycle motorcar cow buffalo chicken  ///
		 pline_nat pline_int poor_nat poor_int spdef cpi ppp cpiperiod welfare welfshprosperity welfarenom welfaredef ///
		 welfarenat welfareother welfaretype welfareothertype

** ORDER VARIABLES

	order countrycode year survey idh idp wgt pop_wgt wgt_wdi strata psu vermast veralt urban int_month int_year  ///
	      subnatid1 subnatid2 subnatid3 gaul_adm1_code ownhouse landholding tenure water_orig water_jmp piped_water sar_improved_water electricity toilet_orig toilet_jmp sewage_toilet sar_improved_toilet  internet ///
	      hsize relationharm relationcs male age soc marital ed_mod_age everattend ///
	      atschool electricity literacy educy educat4 educat5 educat7 lb_mod_age lstatus empstat njobs ///
	      ocusec nlfreason unempldur_l unempldur_u industry occup firmsize_l firmsize_u whours wage ///
		  unitwage contract healthins socialsec union lstatus_e empstat_e industry_e_orig industry_e  occup_e_orig occup_e  ///
		  landphone cellphone computer radio television fan sewingmachine washingmachine  ///
		  refrigerator lamp bicycle motorcycle motorcar cow buffalo chicken  ///
		  pline_nat pline_int poor_nat poor_int spdef cpi ppp cpiperiod welfare welfshprosperity welfarenom welfaredef ///
		  welfarenat welfareother welfaretype welfareothertype
	
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
	keep countrycode year survey idh idp wgt pop_wgt wgt_wdi strata psu vermast veralt subnatid1 `keep' *type
    sort idh idp

	saveold "`output'\Data\Harmonized\IND_1993_NSS50-SCH1.0_v01_M_v04_A_SARMD_IND.dta", replace version(12)
	saveold "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\IND_1993_NSS50-SCH1.0_v01_M_v04_A_SARMD_IND.dta", replace version(12)
	
	
	log close

******************************  END OF DO-FILE  *****************************************************/
