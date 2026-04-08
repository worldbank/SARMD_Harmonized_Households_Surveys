/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                                   SOUTH ASIA MICRO DATABASE                                      **
**                                                                                                  **
** COUNTRY			Afghanistan
** COUNTRY ISO CODE	AFG
** YEAR				2007
** SURVEY NAME		National Risk and Vulnerability Assessment 2007-2008
** SURVEY AGENCY	Central Statistics Organization
** RESPONSIBLE		Triana Yentzen
** MODFIFIED BY 	Adriana Castillo Castillo
** Date: 			04/05/2023                                                                    **
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

glo   cpiver       "v09"
local code         "AFG"
local year         "2007"
local survey       "NRVA"
local vm           "02"
local va           "06"
local type         "SARMD"
glo   module       "IND"
local yearfolder   "`code'_`year'_`survey'"
local gmdfolder    "`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD"
local filename     "`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD_${module}"


*glo pricedata     "$rootdatalib\CPI\cpi_ppp_sarmd_weighted.dta"
glo shares         "P:\SARMD\SARDATABANK\APPS\DATA CHECK\Food and non-food shares\\`code'"
glo fixlabels      "P:\SARMD\SARDATABANK\APPS\DATA CHECK\Label fixing"
glo pricedata      "P:\SARMD\SARDATABANK\APPS\POVERTY\PovcalNet revisions\PovcalNet Spring 2016 revision\cpi_ppp_sarmd_weighted.dta"
local output       "$rootdatalib\\`code'\\`code'_`year'_`survey'\\`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD"
local input        "$rootdatalib\\`code'\\`code'_`year'_`survey'\\`code'_`year'_`survey'_v`vm'_M"
*</_Program setup_>

*<_Folder creation_>
cap mkdir "${rootdatalib}"
cap mkdir "${rootdatalib}\\`code'"
cap mkdir "${rootdatalib}\\`code'\\`yearfolder'"
cap mkdir "${rootdatalib}\\`code'\\`yearfolder'\\`gmdfolder'"
cap mkdir "${rootdatalib}\\`code'\\`yearfolder'\\`gmdfolder'\Data"
cap mkdir "${rootdatalib}\\`code'\\`yearfolder'\\`gmdfolder'\Data\Harmonized"
*</_Folder creation_>

	
	** LOG FILE
** LOG FILE
log using "`output'\Doc\Technical\\`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD.log",replace

/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/
** DATABASE ASSEMBLENT

use "${rootdatalib}\\`code'\\`code'_`year'_`survey'\\`code'_`year'_`survey'_v`vm'_M\Data\Stata\\`code'_`year'_`survey'_M.dta", clear 

	
	
	
/*****************************************************************************************************
*                                                                                                    *
                                   * STANDARD SURVEY MODULE
*                                                                                                    *
*****************************************************************************************************/

** COUNTRY
*<_countrycode_>
	gen str4 countrycode="`code'"	
	label var countrycode "Country code"
*</_countrycode_> 

** YEAR
*<_year_> 
	gen int year=`year'
	label var year "Year of survey"
*</_year_>
 
 
** SURVEY NAME 
*<_survey_>
	gen str survey="`survey'"
	label var survey "Survey Acronym"
*</_survey_>

	
** INTERVIEW YEAR
*<_int_year_> 
	split dateintr, gen(date) parse(/)
	destring date3, replace
	destring date1, replace
	gen int_year=date3
	label var int_year "Year of the interview"
*</_int_year_> 

** INTERVIEW MONTH
*<_int_month_> 
	destring date2, replace
	gen byte int_month=date2
	la de lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value int_month lblint_month
	label var int_month "Month of the interview"
*</_int_month_> 

**FIELD WORKD***
*<_fieldwork_> 
gen fieldwork=ym(date3, date2)
format %tm fieldwork
la var fieldwork "Date of fieldwork"
*<_/fieldwork_> 


** HOUSEHOLD IDENTIFICATION NUMBER
*<_idh_>
	gen double idh = hhid
	format idh %16.0f
	tostring idh, replace
	label var idh "Household id"
*</_idh_> 

** INDIVIDUAL IDENTIFICATION NUMBER
*<_idp_>
	egen idp=concat(hhid hhmemid), punct(-)
	label var idp "Individual id"
*</_idp_>

** HOUSEHOLD WEIGHTS
*<_wgt_>
	gen double wgt=hh_weight
	label var wgt "Household sampling weight"
*</_wgt_>

*<_weighttype_>
*<_weighttype_note_> Weight type (frequency, probability, analytical, importance) *</_weighttype_note_>
*<_weighttype_note_> weighttype brought in from rawdata *</_weighttype_note_>
g weighttype = "PW"
*</_weighttype_>

** STRATA
*<_strata_>
	gen strata=provincec
	label var strata "Strata"
*</_strata_>


** PSU
*<_psu_>
	gen psu=cid
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

	** Urban rural variable according to CSO's definition
	** There are 26 cluster of settled HH where "urbrur" is missing
	** Identify using " Block_No", the value always be 0 in rural area
	replace urbrur = 1 if  Block_No!=0 & Block_No!=.
	replace urbrur = 0 if  Block_No==0
	gen byte urban=urbrur
	label var urban "Urban/Rural"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban
*</_urban_>

*MACRO REGIONAL AREAS
*<_subnatid0_>
gen subnatid0=region
	la de lblsubnatid0 1 "Central" 2 "South" 3 "East" 4 "Northeast" 5 "North" 6 "West" 7 "Southwest" 8 "West-Central"
	label var subnatid0 "Macro regional areas"
	label values subnatid0 lblsubnatid0
*</_subnatid0_>


** REGIONAL AREA 1 DIGIT ADMN LEVEL
*<_subnatid2_>
	gen byte subnatid1=provincec
	la de lblsubnatid1 1 "Kabul" 2 "Kapisa" 3 "Parwan" 4 "Wardak" 5 "Logar" 6 "Ghazni" 7 "Paktika" 8 "Paktya" 9 "Khost" 10 "Nangarhar" 11 "Kunarha" 12 "Laghman" 13 "Nuristan" 14 "Badakhshan" 15 "Takhar" 16 "Baghlan" 17 "Kunduz" 18 "Samangan" 19 "Balkh" 20 "Jawzjan" 21 "Sar-I-Poul" 22 "Faryab" 23 "Badghis" 24 "Hirat" 25 "Farah" 26 "Nimroz" 27 "Helmand" 28 "Kandahar" 29 "Zabul" 30 "Uruzgan" 31 "Ghor" 32 "Bamyan" 33 "Panjsher" 34 "Daikindi"
	label var subnatid1 "Region at 1 digit (ADMN1)"
	label values subnatid1 lblsubnatid1
	numlabel lblsubnatid1, add mask("# - ")
*</_subnatid2_>

**REGIONAL AREAS
** REGIONAL AREA 2 DIGIT ADMN LEVEL
*<_subnatid1_>
	gen byte subnatid2=.
	label var subnatid1 "Region at 2 digit (ADMN2)"
	label values subnatid2 lblsubnatid2
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

	
** REGIONAL AREA 3 DIGIT ADMN LEVEL
*<_subnatid3_>
	gen byte subnatid3=.
	label var subnatid3 "Region at 3 digit (ADMN3)"
	label values subnatid3 lblsubnatid3
*</_subnatid3_>
	
	
** HOUSE OWNERSHIP
*<_ownhouse_>
	gen byte ownhouse=.
	replace ownhouse=1 if inlist(q_2_9,1,2,3,4,5)
	replace ownhouse=0 if inlist(q_2_9,6,7,8,9,10)
	label var ownhouse "House ownership"
	la de lblownhouse 0 "No" 1 "Yes"
	label values ownhouse lblownhouse
*</_ownhouse_>


** TENURE OF DWELLING
*<_tenure_>
   gen tenure=.
   replace tenure=1 if inlist(q_2_9,1,2,3,4,5)
   replace tenure=2 if q_2_9==6
   replace tenure=3 if tenure!=1 & tenure!=2 & q_2_9!=.
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
gen water_orig=.
loc j=0
foreach i in q_2_31a q_2_31b q_2_31c q_2_31d q_2_31e q_2_31f q_2_31g q_2_31h q_2_31i ///
 q_2_31j q_2_31k q_2_31l q_2_31m q_2_31n q_2_31o q_2_31p q_2_31q q_2_31r q_2_31s q_2_31t ///
 q_2_31u {

 cap gen water_orig=.
 replace  water_orig=1+`j' if `i'==1 
 loc j=`j'+1
 loc a:  variable label `i'
 loc e "Main-drinking water (30 days)-"
 loc c: list a - e
 la def lblwater_orig `j' "`c'", add 

 }
 
 label define lblwater_orig 1 "Shallow open wells-public" ///
 2 "Shallow open wells-in compound" 3 "Hand pump- Public" 4 "Hand pump- In compound" ///
 5 "Bored wells- hand pump" 6 "Bored wells- motorized" 7 "Spring- unprotected" 8 ///
 "Spring protected" 9 "Pipe scheme - gravity" 10 "Pipe scheme- motorized" 11 ///
 "Piped municipal" 12 "Arhad" 13 "Kariz" 14 "River, Lake, Channel" 15 "Kanda" ///
 16 "Nawar Dan Dam" 17 "Pool Howz" 18 "Drainage" 19 "Bowser/ Water tanker" ///
 20 "water Bottled water/ mineral" 21 " Other (specify)", replace
 la var water_orig "Source of Drinking Water-Original from raw file"

la val water_orig lblwater_orig
*</_water_orig_>


*PIPED SOURCE OF WATER
*<_piped_water_>
gen piped_water=.
replace piped_water=1 if inlist(water_orig,9,10,11)
replace piped_water=0 if piped_water!=1 & water_orig<.
la var piped_water "Household has access to piped water"
la def lblpiped_water 1 "Yes" 0 "No"
la val piped_water lblpiped_water
*</_piped_water_>


**INTERNATIONAL WATER COMPARISON (Joint Monitoring Program)
*<_water_jmp_>
gen water_jmp=.
replace water_jmp=1 if inlist(1,q_2_31i,q_2_31j)
replace water_jmp=3 if inlist(1,q_2_31k)
replace water_jmp=4 if inlist(1,q_2_31c, q_2_31d, q_2_31e, q_2_31f)
replace water_jmp=5 if inlist(1,q_2_31m,q_2_31o, q_2_31q)
replace water_jmp=6 if inlist(1,q_2_31l,q_2_31a, q_2_31b)
replace water_jmp=7 if inlist(1,q_2_31h)
replace water_jmp=8 if inlist(1,q_2_31g)
replace water_jmp=10 if inlist(1,q_2_31s)
replace water_jmp=12 if inlist(1,q_2_31p,q_2_31r, q_2_31n)
replace water_jmp=13 if inlist(1,q_2_31t)
replace water_jmp=14 if inlist(1, q_2_31u)
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

*ORIGINAL WATER CATEGORIES
*<_water_original_>
clonevar j=water_orig
#delimit
la def lblwater_original 	1 "Shallow open wells-public" 
							2 "Shallow open wells-in compound" 
							3 "Hand pump- Public" 
							4 "Hand pump- In compound" 
							5 "Bored wells- hand pump" 
							6 "Bored wells- motorized" 
							7 "Spring- unprotected" 
							8 "Spring protected" 
							9 "Pipe scheme - gravity" 
							10 "Pipe scheme- motorized" 
							11 "Piped municipal" 
							12 "Arhad" 
							13 "Kariz" 
							14 "River, Lake, Channel" 
							15 "Kanda" 
							16 "Nawar Dan Dam" 
							17 "Pool Howz" 
							18 "Drainage" 
							19 "Bowser/ Water tanker" 
							20 "water Bottled water/ mineral" 
							21 " Other (specify)";
#delimit cr
la val j lblwater_original		
decode j, gen(water_original)
drop j
la var water_original "Source of Drinking Water-Original from raw file"
*</_water_original_>

 
 *SAR improved source of drinking water
*<_sar_improved_water_>
gen sar_improved_water=.
replace sar_improved_water=1 if inlist(water_orig,3,4,5,6,8,9,10,11,12,13)
replace sar_improved_water=0 if inlist(water_orig,1,2,7,14,15,16,17,18,19,20,21)
replace water_jmp=.
la def lblsar_improved_water 1 "Improved" 0 "Unimproved"
la var sar_improved_water "Improved source of drinking water-using country-specific definitions"
la val sar_improved_water lblsar_improved_water
*</_sar_improved_water_>

 
	** WATER SOURCE
	*<_water_source_>
		gen water_source=.
		replace water_source=10 if water_orig==1
		replace water_source=10 if water_orig==2
		replace water_source=4 if water_orig==3
		replace water_source=4 if water_orig==4
		replace water_source=4 if water_orig==5
		replace water_source=4 if water_orig==6
		replace water_source=9 if water_orig==7
		replace water_source=6 if water_orig==8
		replace water_source=1 if water_orig==9
		replace water_source=1 if water_orig==10
		replace water_source=3 if water_orig==11
		replace water_source=10 if water_orig==12
		replace water_source=5 if water_orig==13
		replace water_source=13 if water_orig==14
		replace water_source=5 if water_orig==15
		replace water_source=13 if water_orig==16
		replace water_source=5 if water_orig==17
		replace water_source=13 if water_orig==18
		replace water_source=12 if water_orig==19
		replace water_source=7 if water_orig==20
		replace water_source=14 if water_orig==21
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
		cap clonevar improved_water=sar_improved_water
	*</_improved_water_>



	** PIPED SOURCE OF WATER ACCESS
	*<_pipedwater_acc_>
		gen pipedwater_acc=0 if inlist(water_orig,1,2,3,4,5,6,7,8,11,12,13,14,15,16,17,18,19,20,21) // Asuming other is not piped water
		replace pipedwater_acc=3 if inlist(water_orig,9,10)
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
*electricity any source
egen electricity_all=rmin(q_2_20_1 q_2_20_2 q_2_20_3 q_2_20_4 q_2_20_5 q_2_20_6 q_2_20_7 q_2_20_8)
recode electricity_all (2=0)
* electrecity public connection
egen electricity=rmin(q_2_20_1 q_2_20_2)
recode electricity (2=0)
replace electricity=0 if mi(electricity) & !mi(electricity_all)
note electricity: electricity from public source electric grid or government generator

*electricity by source
recode q_2_20_1 (2=0), gen(elect_grid)
recode q_2_20_2 (2=0), gen(elect_govgen)
egen elect_engine=rmin(q_2_20_3 q_2_20_5)
recode elect_engine (2=0)
egen elect_hidro=rmin(q_2_20_4 q_2_20_6)
recode elect_hidro (2=0)
recode q_2_20_7 (2=0), gen(elect_solar)
recode q_2_20_8 (2=0), gen(elect_wind)
*electricity number of days
egen electricity_days=rmean(q_2_21_1a q_2_21_2a q_2_21_3a q_2_21_4a q_2_21_5a q_2_21_6a q_2_21_7a q_2_21_8a)
egen electricity_hour=rmean(q_2_21_1b q_2_21_2b q_2_21_3b q_2_21_4b q_2_21_5b q_2_21_6b q_2_21_7b q_2_21_8b)
*</_electricity_>


*ORIGINAL TOILET CATEGORIES
*<_toilet_orig_>
gen toilet_orig=q_2_26
la var toilet_orig "Access to sanitation facility-Original from raw file"
#delimit
la def lbltoilet_orig 1 "None (open field, bush) or Sahrahi"
           2 "Dearan (area inside or outside compound but not pit)"
           3 "Open pit"
           4 "Traditional covered latrine"
           5 "Improved latrine"
           6 "Flush latrine"
           7 "Other (specify)"
;
#delimit cr
la val toilet_orig lbltoilet_orig
*</_toilet_orig_>


*SEWAGE TOILET
*<_sewage_toilet_>
 recode q_2_26 (1=0)(2 3=0)(4 5=0)(6=1)(7=0), gen(sewage_toilet)
la var sewage_toilet "Household has access to sewage toilet"
la def lblsewage_toilet 1 "Yes" 0 "No"
la val sewage_toilet lblsewage_toilet
*</_sewage_toilet_>


**INTERNATIONAL SANITATION COMPARISON (Joint Monitoring Program)
*<_toilet_jmp_>
gen toilet_jmp=.
replace toilet_jmp=12 if q_2_26==1
replace toilet_jmp=4 if q_2_26==2
replace toilet_jmp=8 if q_2_26==3
replace toilet_jmp=7 if q_2_26==4
replace toilet_jmp=6 if q_2_26==5
replace toilet_jmp=3 if q_2_26==6
replace toilet_jmp=13 if q_2_26==7

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
replace sar_improved_toilet=1 if inlist(toilet_orig,4,5,6)
replace sar_improved_toilet=0 if inlist(toilet_orig,1,2,3,7)
clonevar sar_improved_toilet_nofilter=sar_improved_toilet
replace sar_improved_toilet=0 if q_2_28==1
notes sar_improved_toilet: `code' `year' imp_san_rec is classified as unimproved if the facility is shared.
replace toilet_jmp=.
la def lblsar_improved_toilet 1 "Improved" 0 "Unimproved"
la var sar_improved_toilet "Improved type of sanitation facility-using country-specific definitions"
la val sar_improved_toilet lblsar_improved_toilet
*</_sar_improved_toilet_>


	** ORIGINAL SANITATION CATEGORIES 
	*<_sanitation_original_>
		clonevar j=q_2_26
		#delimit
		la def lblsanitation_original   1 "None (open field, bush) or Sahrahi"
										2 "Dearan (area inside or outside compound but not pit)"
										3 "Open pit"
										4 "Traditional covered latrine"
										5 "Improved latrine"
										6 "Flush latrine"
										7 "Other (specify)";
		#delimit cr
		la val j lblsanitation_original
		decode j, gen(sanitation_original)
		drop j
		la var sanitation_original "Access to sanitation facility-Original from raw file"
	*</_sanitation_original_>


	** SANITATION SOURCE
	*<_sanitation_source_>
		gen sanitation_source=.
		replace sanitation_source=13 if q_2_26==1
		replace sanitation_source=9 if q_2_26==2
		replace sanitation_source=10 if q_2_26==3
		replace sanitation_source=6 if q_2_26==4
		replace sanitation_source=5 if q_2_26==5
		replace sanitation_source=4 if q_2_26==6
		replace sanitation_source=14 if q_2_26==7
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
		clonevar improved_sanitation= sar_improved_toilet
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
	*replace z=0 if q_1_1==15
	egen byte hsize=sum(z), by(idh)
	la var hsize "Household size"
	note hsize: "AFG 2007" variable takes all categories since there is no way to identify paying boarders and domestic servants
*</_hsize_>

**POPULATION WEIGHT
*<_pop_wgt_>
	gen pop_wgt=wgt*hsize
	la var pop_wgt "Population weight"
*</_pop_wgt_>



** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
*<_relationharm_>
	gen byte relationharm=q_1_1 
	recode relationharm (17 = 3) (7 16 =4) (4 5 6 7 8 9 10 11 12 13 14 18= 5) (15=6)
	label var relationharm "Relationship to the head of household"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Non-relatives"

	gen head=relationharm==1
	bys hhid: egen heads=total(head)

	replace q_1_1=14 if heads!=1 & hhmemid>1 & hhmemid!=. & q_1_1==1
	replace relationharm=5 if heads!=1 & q_1_1==1

	replace q_1_1=1 if heads==0
	replace relationharm=1 if heads==0
	drop head heads
	
	label values relationharm  lblrelationharm
*</_relationharm_>

** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
*<_relationcs_>
	gen byte relationcs=q_1_1
	la var relationcs "Relationship to the head of household country/region specific"
	label define lblrelationcs 1 "Household Head" 2 "Husband/Wife" 3 "Son/Daughter" 4 "Son-in-law/Daughter-in-law" 5 "Grandchild" 6 "Nephew/Niece" 7 "Father/Mother" 8 "Father-in-law/Mother-in-law" 9 "Grandfather/Grandmother" 10 "Brother/Sister" 11 "Brother-in-law/Sister-in-law" 12 "Uncle/Aunt" 13 "Amboq" 14 "Other relatives" 15 "Unrelated male/female" 16 "Stepfather/stepmother" 17 "Stepdaughter/Stepson" 18 "Step-sister/step-brother"
	label values relationcs lblrelationcs
*</_relationcs_>


** GENDER
*<_male_>
	gen byte male=q_1_2
	recode male (2=0)
	label var male "Sex of household member"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale
*</_male_>

	
** AGE
*<_age_>
	gen byte age=q_1_3
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
	gen byte marital=q_1_4
	recode marital (4 5 = 2) (3=5) (2=4)
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
	*** recode to missing the education variables for individuals who should not have respondend to these questions
	replace q_6_2 = . if  age < 6 
	replace q_6_3 = . if  age < 6 
	replace q_6_4 = . if  age < 6 
	replace q_6_5_l = . if  age < 6 
	replace q_6_5_y = . if  age < 6 
	replace q_6_6 = . if  age < 6 
	replace q_6_8 = . if  age < 6 |  age > 18 
	replace q_6_9 = . if  age < 6 |  age > 18 
	replace q_6_10 = . if  age < 6 |  age > 18 
	replace q_6_11_1 = . if  age < 6 |  age > 18 
	replace q_6_11_2 = . if  age < 6 |  age > 18 
*</_ed_mod_age_>


** CURRENTLY AT SCHOOL
*<_atschool_>
	gen byte atschool=q_6_8
	recode atschool (2=0)
	replace atschool = 0 if q_6_3 == 2
	replace atschool = . if age < 6
	replace atschool = . if age > 18
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool
	notes atschool: "AFG 2007" question related to enrollment to school was used
	notes atschool: "AFG 2007" the upper range of age for attendace was set in the questionnaire
*</_atschool_>


** CAN READ AND WRITE
*<_literacy_>
	gen byte literacy=q_6_2
	recode literacy (2=0)
	replace literacy=. if age<6
	replace literacy = 1 if q_6_5_l >= 2 & q_6_5_l <.
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
*</_literacy_>


** YEARS OF EDUCATION COMPLETED
*<_educy_>
	gen  educy = . 
	*** assign a zero to those who never attended school ***
	replace  educy = 0 if q_6_3 == 2 

	* calculate years based on highest level and years attended or attending ***
	replace  educy = 0 + q_6_5_y if q_6_5_l == 1 
	replace  educy = 6 + q_6_5_y if q_6_5_l == 2 
	replace  educy = 9 + q_6_5_y if q_6_5_l == 3 
	replace  educy = 12 + q_6_5_y if q_6_5_l == 4 
	replace  educy = 12 + q_6_5_y if q_6_5_l == 5 
	replace  educy = 16 + q_6_5_y if q_6_5_l == 6 

	*** subtract one year for those who are currently attending school ***
	replace  educy =  educy - 1 if q_6_8 == 1 

	*** correct for any negative years ***
	replace  educy = 0 if  educy < 0 

	*** correct for age lower than years of education
	replace educy=. if age+1<educy & educy!=. & age!=.
	label var educy "Years of education"
	notes educy: "AFG 2007" No " highest grade attained" question, and variable was imputed following I2D2 dictionary
*</_educy_>


** EDUCATION LEVEL 4 CATEGORIES
*<_educat4_>
	gen byte educat4=q_6_5_l
	recode educat4 (1 = 2 ) (2 3 =3) (4 5 6 7=4) (0=.)
	replace educat4=1 if q_6_3 == 2 
	replace educat4=.z if q_6_5_l==8
	note educat4: `code' `year' variable q_6_5_l "level completed" = 8 "Islamic school" not categorized, given special missing value (.z).
	label var educat4 "Level of education 4 categories"
	label define lbleducat4 1 "No education" 2 "Primary (complete or incomplete)" ///
	3 "Secondary (complete or incomplete)" 4 "Tertiary (complete or incomplete)"
	label values educat4 lbleducat4
*</_educat4_>



** EDUCATION LEVEL 5 CATEGORIES
*<_educat5_>
	gen educat5=.
	replace educat5=1 if educat4==1
	replace educat5=2 if q_6_5_l==1 & q_6_5_y<6 &q_6_5_y!=.
	replace educat5=3 if (q_6_5_l==1 & q_6_5_y==6 ) | q_6_5_l==2 | (q_6_5_l==3 & q_6_5_y<3 & q_6_5_y!=.)
	replace educat5=4 if q_6_5_l==3 & q_6_5_y==3
	replace educat5=5 if q_6_5_l>3 & q_6_5_l!=.
	replace educat5=.z if q_6_5_l==8
	note educat5: `code' `year' variable q_6_5_l "level completed" = 8 "Islamic school" not categorized, given special missing value (.z).
	label define lbleducat5 1 "No education" 2 "Primary incomplete" ///
	3 "Primary complete but secondary incomplete" 4 "Secondary complete" ///
	5 "Some tertiary/post-secondary"
	label values educat5 lbleducat5
*</_educat5_>

	la var educat5 "Level of education 5 categories"

** EDUCATION LEVEL 7 CATEGORIES
*<_educat7_>
	gen educat7=.
	replace educat7=1 if educat4==1
	replace educat7=2 if q_6_5_l==1 & q_6_5_y<6 &q_6_5_y!=.
	replace educat7=3 if (q_6_5_l==1 & q_6_5_y==6 ) 
	replace educat7=4 if q_6_5_l==2 | (q_6_5_l==3 & q_6_5_y<3 & q_6_5_y!=.)
	replace educat7=5 if q_6_5_l==3 & q_6_5_y==3
	replace educat7=6 if q_6_5_l==4
	replace educat7=7 if q_6_5_l>4 & q_6_5_l<7
	replace educat7=.z if q_6_5_l==8
	note educat7: `code' `year' variable q_6_5_l "level completed" = 8 "Islamic school" not categorized, given special missing value (.z).
	la var educat7 "Level of education 7 categories"
	label define lbleducat7 1 "No education" 2 "Primary incomplete" 3 "Primary complete" ///
	4 "Secondary incomplete" 5 "Secondary complete" 6 "Higher than secondary but not university" /// 
	7 "University incomplete or complete" 8 "Other" 9 "Not classified"
	label values educat7 lbleducat7
*</_educat7_>


	
** EVER ATTENDED SCHOOL
*<_everattend_>
	gen byte everattend=q_6_3
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
notes _dta: "AFG 2007" No comparability in labor market outcomes from following years. Changes in screening process and recall period of variables

** LABOR MODULE AGE
*<_lb_mod_age_>
 gen byte lb_mod_age=16
	label var lb_mod_age "Labor module application age"

	***recode to missing the income variables for individuals who should not have respondend to these questions
	***child labor is NOT included

	forval i=9/26{
	replace q_9_`i' = . if age < 16 
	}
*</_lb_mod_age_>

** LABOR STATUS
*<_lstatus_>
	gen  lstatus = 1 if  inlist(1, q_9_12, q_9_13, q_9_9, q_9_10, q_9_11)  
	replace  lstatus = 1 if q_9_15==1 & mi( lstatus) 
	replace  lstatus = 2 if q_9_16==1 & mi( lstatus)  
	replace  lstatus = 2 if inlist(q_9_17, 6, 7) & mi( lstatus)  
	replace  lstatus = 3 if inlist(q_9_17, 10, 11) & mi( lstatus)  
	replace  lstatus = 4 if mi( lstatus ) & age >=16  
	recode lstatus (4=3)
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non LF"
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
	gen byte empstat = q_9_19
	recode empstat (1 2 3 = 1)  (6=2) (5=3) (4=4)
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
	gen byte ocusec=1 if q_9_19==3
	replace ocusec=2 if q_9_19==2
	replace ocusec=. if lstatus!=1
	label var ocusec "Sector of activity"
	la de lblocusec 1 "Public, state owned, NGO, government, army" 2 "Private"
	label values ocusec lblocusec
*</_ocusec_>


** REASONS NOT IN THE LABOR FORCE
*<_nlfreason_>
	gen byte nlfreason=.
	replace nlfreason=1 if q_9_17==1
	replace nlfreason=2 if q_9_17==2
	replace nlfreason=4 if q_9_17==4
	replace nlfreason=3 if q_9_17==3
	replace nlfreason=5 if inlist(q_9_17, 5,6,7,8,9,10,11,12)
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
gen industry_orig=q_9_18
label define lblindustry_orig 1 `"Agriculture/ livestock"', modify
label define lblindustry_orig 2 `"Mining & Quarrying"', modify
label define lblindustry_orig 3 `"Road construction"', modify
label define lblindustry_orig 4 `"Construction"', modify
label define lblindustry_orig 5 `"Manufacturing"', modify
label define lblindustry_orig 6 `"Transportat., communic."', modify
label define lblindustry_orig 7 `"Wholesale trade"', modify
label define lblindustry_orig 8 `"Retail trade"', modify
label define lblindustry_orig 9 `"Health"', modify
label define lblindustry_orig 10 `"Education"', modify
label define lblindustry_orig 11 `"Other services"', modify
label define lblindustry_orig 12 `"Public admin/gov't"', modify
label val industry_orig lblindustry_orig
replace industry_orig=. if lstatus!=1
la var industry_orig "Original industry code"
*</_industry_orig_>


** INDUSTRY CLASSIFICATION
*<_industry_>
	gen byte industry=q_9_18
	recode  industry (3 = 5) (4 = 5) (5 = 3) (6 = 7) (7 = 6) (8 = 6) (9 = 10) (11 = 10) (12 = 9)
	replace industry=. if lstatus!=1
	label var industry "1 digit industry classification"
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industry lblindustry
*</_industry_>


**ORIGINAL OCCUPATION CLASSIFICATION
*<_occup_orig_>
gen occup_orig=.
la var occup_orig "Original occupation code"
*</_occup_orig_>


** OCCUPATION CLASSIFICATION
*<_occup_>
	gen byte occup=.
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
	gen whours = (q_9_24 * q_9_23)/4.2 
	replace whours = . if lstatus != 1
	replace whours  = 96 if whours  > 96 & whours < .
	replace whours = . if whours  > 168
	label var whours "Hours of work in last week"
*</_whours_>


** WAGES
*<_wage_>
	gen double wage=q_9_21
	replace wage=. if lstatus!=1
	replace wage=0 if empstat==2
	label var wage "Last wage payment"
*</_wage_>


** WAGES TIME UNIT
*<_unitwage_>
	gen byte unitwage=1
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
	label var landphone " Household has landphone"
	la de lbllandphone 0 "No" 1 "Yes"
	label values landphone lbllandphone
*</_landphone_>


** CEL PHONE
*<_cellphone_>

	gen byte cellphone=q_5_7_1>0 if q_5_7_1<.
	label var cellphone " Household has Cell phone"
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
	gen radio=q_5_1_5>0 if q_5_1_5<.
	label var radio "Household has radio"
	la de lblradio 0 "No" 1 "Yes"
	label val radio lblradio
*</_radio_>

** TELEVISION
*<_television_>
	gen television=q_5_1_6>0 if q_5_1_6<.
	label var television "Household has Television"
	la de lbltelevision 0 "No" 1 "Yes"
	label val television lbltelevision
*</_television>

** FAN
*<_fan_>
	gen fan=.
	label var fan "Household has Fan"
	la de lblfan 0 "No" 1 "Yes"
	label val fan lblfan
*</_fan>

** SEWING MACHINE
*<_sewingmachine_>
	gen sewingmachine=q_5_1_3>0 if q_5_1_3<.
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
	gen refrigerator=q_5_1_1>0 if q_5_1_1<.
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
	gen bicycle=q_5_1_9>0 if q_5_1_9<.
	label var bicycle "Household has Bicycle"
	la de lblbycicle 0 "No" 1 "Yes"
	label val bicycle lblbycicle
*</_bycicle>

** MOTORCYCLE
*<_motorcycle_>
	gen motorcycle=q_5_1_10>0 if q_5_1_10<.
	label var motorcycle "Household has Motorcycle"
	la de lblmotorcycle 0 "No" 1 "Yes"
	label val motorcycle lblmotorcycle
*</_motorcycle>

** MOTOR CAR
*<_motorcar_>
	gen motorcar=q_5_1_11>0 if q_5_1_11<.
	label var motorcar "Household has Motor car"
	la de lblmotorcar 0 "No" 1 "Yes"
	label val motorcar lblmotorcar
*</_motorcar>

** COW
*<_cow_>
	gen cow=.
	label var cow "Household has Cow "
	la de lblcow 0 "No" 1 "Yes"
	label val cow lblcow
*</_cow>

** BUFFALO
*<_buffalo_>
	gen buffalo=.
	label var buffalo "Household has Buffalo "
	la de lblbuffalo 0 "No" 1 "Yes"
	label val buffalo lblbuffalo
*</_buffalo>

** CHICKEN
*<_chicken_>
	gen chicken=q_3_2_h>0 if q_3_2_h<.
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
	*gen spdef=pexnom_t/ pexadj_t
	gen spdef=.
	la var spdef "Spatial deflator"
*</_spdef_>

** WELFARE
*<_welfare_>
g welfare = pcexall_adj_survey_prices
*</_welfare_>

*<_welfarenom_>
	gen welfarenom=.
	la var welfarenom "Welfare aggregate in nominal terms"
*</_welfarenom_>

*<_welfaredef_>
	gen welfaredef=pcexall_adj_survey_prices
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
	gen welfarenat=welfare
	la var welfarenat "Welfare aggregate for national poverty"
*</_welfarenat_>

*QUINTILE, DECILE AND FOOD/NON-FOOD SHARES OF CONSUMPTION AGGREGATE
cap drop _merge 
	levelsof year, loc(y)
	merge m:1 idh using "$shares\\AFG_fnf_`y'", keepusing (food_share nfood_share quintile_cons_aggregate decile_cons_aggregate) nogen
	cap drop _merge

/*****************************************************************************************************
*                                                                                                    *
                                   NATIONAL POVERTY
*                                                                                                    *
*****************************************************************************************************/

** POVERTY LINE (NATIONAL)
*<_pline_nat_>
	sum pline [w=hh_weight]  /*no need to restrict the sample as all data for all provinces were used for the pline estimation*/
	clonevar pline_nat=pline
	label variable pline_nat "Poverty Line (National)"
*</_pline_nat_>

	
** HEADCOUNT RATIO (NATIONAL)
*<_poor_nat_>
	gen poor_nat=.
	replace poor_nat=1 if welfare<pline_nat  & !mi(welfare)
	replace poor_nat=0 if welfare>=pline_nat & !mi(welfare)
	la var poor_nat "People below Poverty Line (National)"
	la define poor_nat 0 "Not Poor" 1 "Poor"
	la values poor_nat poor_nat
	*replace poor_nat=. if poor==0 | poor==.
*</_poor_nat_>


/*****************************************************************************************************
*                                                                                                    *
                                   INTERNATIONAL POVERTY
*                                                                                                    *
*****************************************************************************************************/


	local year_cpi=2011
	
** USE SARMD CPI AND PPP
*<_cpi_>
	capture drop _merge
	gen urb=.
	merge m:1 countrycode year urb using "$pricedata", ///
	keepusing(countrycode year urb syear cpi`year_cpi'_w ppp`year_cpi')
	drop urb
	drop if _merge!=3
	drop _merge
	
	
** CPI VARIABLE
	ren cpi`year_cpi'_w cpi
	label variable cpi "CPI (Base `year'=1)"
*</_cpi_>
	
	
** PPP VARIABLE
*<_ppp_>
	ren ppp`year_cpi' 	ppp
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
	replace poor_int=. if poor==0 | poor==.
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

cap gen buffalo=.
cap gen chicken=.
cap gen contract=. 
cap gen cow =.
cap gen empstat_2=. 
cap gen empstat_2_year=. 
cap gen healthins=.
cap gen int_month=.
cap gen lamp=.
cap gen lphone=.
cap gen ocusec=.
cap gen piped_water=.
cap gen quintile_cons_aggregate=.
cap clonevar sar_improved_toilet=improved_sanitation
cap clonevar sar_improved_water=improved_water
cap gen sewage_toilet=.
cap gen socialsec=.
cap gen toilet_jmp=.
cap gen typehouse=. 
cap gen union=.
cap gen unitwage=.  
cap gen unitwage_2=. 
cap gen water_jmp=.
cap gen firmsize_l=.
cap gen food_share=.
cap gen industry=.
cap gen industry_2=.
cap gen industry_orig=.
cap gen industry_orig_2=.
cap gen lb_mod_age=.
cap gen month=. 
cap gen nfood_share=. 
cap gen njobs=. 
cap gen poor_int=.
cap gen rbirth =.
cap gen rbirth_juris=.
cap gen rprevious_juris=. 
cap gen pline_int=.
cap gen spdef=.
cap gen subnatid3=.
cap gen unempldur_l=.
cap gen unempldur_u=.
cap gen wage=.
cap gen wage_2=. 
cap gen welfare=.
cap gen welfaredef=.
cap gen welfarenom=.
cap gen welfareother=.
cap gen welfareothertype=.
cap gen welfaretype=.
cap gen welfshprosperity=. 
cap gen whours=. 
cap gen yrmove=. 
cap clonevar toilet_orig= sanitation_orig
	cap clonevar hhid=idh
	cap clonevar idh_org=hhid
	cap clonevar pid=idp
	cap clonevar idp_org=pid
	cap clonevar countrycode=code
	cap gen cpi=.
	cap gen ppp=.
	cap gen finalweight=.
	cap gen cpiperiod=""
	cap gen code="`code'"
	
	

glo keepextra "nfline fline pline poor fpoor pcexf_adj_survey_prices pcexd_adj_survey_prices pcexr_adj_survey_prices pcexn_adj_survey_prices pcexall_adj_survey_prices pcexf_adj_19prices pcexn_adj_19prices pcexd_adj_19prices pcexr_adj_19prices pcexall_adj_19prices pline_nat poor_nat electricity_all elect_grid elect_govgen elect_engine elect_hidro elect_solar elect_wind"
	
*<_Save data file_>
*do "${rootdatalib}/`code'/`yearfolder'/`yearfolder'_v`vm'_M_v`va'_A_SARMD/Programs/Labels_SARMD.do"
do   "P:\SARMD\SARDATABANK\SARMDdofiles\_aux\Labels_SARMD.do"
save "$rootdatalib\\`code'\\`yearfolder'\\`gmdfolder'\Data\Harmonized\\`filename'.dta" , replace
*</_Save data file_>


exit 
		
******************************  END OF DO-FILE  *****************************************************/

