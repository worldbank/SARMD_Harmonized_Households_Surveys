/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                                   SOUTH ASIA MICRO DATABASE                                      **
**                                                                                                  **
** COUNTRY			PAKISTAN
** COUNTRY ISO CODE	PAK
** YEAR				2001
** SURVEY NAME		PAKISTAN INTEGRATED HOUSEHOLD SURVEY (PIHS)
** SURVEY AGENCY	PAKISTAN FEDERAL BUREAU OF STATISTICS
** RESPONSIBLE		Adriana Castillo Castillo
** Modified by		Adriana Castillo Castillo
** Date:			12/17/2021
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

local cpiver       "10"
local code         "PAK"
local year         "2001"
local survey       "PIHS"
local vm           "01"
local va           "07"
local type         "SARMD"
glo   module       "IND"
local yearfolder   "`code'_`year'_`survey'"
local SARMDfolder    "`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD"
local filename     "`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD_${module}"
	
	
	
** DIRECTORY
* global path on Joe's computer
if ("`c(username)'"=="sunquat") {
	glo basepath "/Users/`c(username)'/Projects/WORLD BANK/2023 SAR QCHECK/SARDATABANK/WORKINGDATA/`code'/`yearfolder'"
	glo input "${basepath}/`yearfolder'_v`vm'_M"
	glo output "${basepath}/`yearfolder'_v`vm'_M_v`va'_A_SARMD/Data/Harmonized"
	
}
* global paths on WB computer
else {
	log using "${rootdatalib}/`code'/`code'_`year'_`survey'/`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD/Doc/Technical/`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD.log", replace 
	
	glo input			 "${rootdatalib}/`code'/`yearfolder'/`yearfolder'_v`vm'_M"
	glo output  		 "${rootdatalib}/`code'/`yearfolder'/`yearfolder'_v`vm'_M_v`va'_A_SARMD/Data/Harmonized"
	glo sarmd            "P:/SARMD/SOUTH ASIA MICRO DATABASE"
	global shares        "P:/SARMD/SARDATABANK/APPS/DATA CHECK/Food and non-food shares/PAK"
	
	*<_Folder creation_>
	cap mkdir "${output}"
	*</_Folder creation_>
}

** LOG FILE
	*log using "${output}/Doc/Technical/PAK_2001_PIHS_v01_M_v0`v'_A_SARMD.log",replace

/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/
use "${rootdatalib}/`code'/`code'_`year'_`survey'/`code'_`year'_`survey'_v`vm'_M/Data/Stata/`code'_`year'_`survey'_M.dta", clear 


		

/*****************************************************************************************************
*                                                                                                    *
                                   * STANDARD SURVEY MODULE
*                                                                                                    *
*****************************************************************************************************/

** COUNTRY
*<_countrycode_>
	gen str4 countrycode="PAK"
	label var countrycode "Country code"
*</_countrycode_>


** YEAR
*<_year_>
	cap drop year
	gen int year=2001
	label var year "Year of survey"
*</_year_>

** SURVEY NAME 
*<_survey_>
	gen str survey="PIHS"
	label var survey "Survey Acronym"
*</_survey_>


	
** INTERVIEW YEAR
	gen int_year=2000+fyear1
	label var int_year "Year of the interview"
*</_int_year_>

	
** INTERVIEW MONTH
	gen int_month=fmon1
	la de lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value int_month lblint_month
	label var int_month "Month of the interview"
*</_int_month_>

g month = int_month
	
**FIELD WORKD***
*<_fieldwork_> 
gen fieldwork=ym(int_year, int_month)
format %tm fieldwork
la var fieldwork "Date of fieldwork"
*<_/fieldwork_> 
	
	
** HOUSEHOLD IDENTIFICATION NUMBER
*<_idh_>
	gen double idh= hhcode
	label var idh "Household id"
*</_idh_>


** INDIVIDUAL IDENTIFICATION NUMBER
*<_idp_>

	gen double idp_= idh*100+idc
	gen idp=string(idp_,"%14.0g")
	isid idp
	label var idp "Individual id"
*</_idp_>
	tostring idh, replace

** HOUSEHOLD WEIGHTS
*<_wgt_>
	gen double wgt=weight
	drop if weight==.
	label var wgt "Household sampling weight"
*</_wgt_>

gen weighttype="PW"


** STRATA
*<_strata_>
gen strata=.
label var strata "Strata"
notes strata: variable strata is not generated in this version.
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
	gen byte urban=region
	recode urban (2=0)
	label var urban "Urban/Rural"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban
*</_urban_>


** REGIONAL AREA 2 DIGIT ADMN LEVEL
*<_subnatid1_>
	gen subnatid2=""
	label var subnatid2 "Region at 2 digit (ADMN2)"


** REGIONAL AREA 1 DIGIT ADMN LEVEL
*<_subnatid1_>
	gen byte subnatid1=province
	la de lblsubnatid1 1 "Punjab" 2 "Sindh" 3 "Khyber Pakhtunkhwa" 4 "Balochistan"
	label var subnatid1 "Region at 1 digit (ADMN1)"
	label values subnatid1 lblsubnatid1
	replace subnatid1=. if subnatid1>=5 
	label var subnatid1 "Region at 1 digit (ADMN1)"
	label values subnatid1 lblsubnatid1
		numlabel lblsubnatid1, remove
		numlabel lblsubnatid1, add mask("# - ")
		decode subnatid1, gen(subnatid1_temp)
		drop subnatid1
		rename subnatid1_temp subnatid1
*</_subnatid1_>

label values province lblsubnatid1
decode province, gen(subnatid1_sar)
g subnatid2_sar = ""
g subnatid3_sar = ""
g subnatid4_sar = ""


*<_gaul_adm1_code_>
	gen gaul_adm1_code=.
	label var gaul_adm1_code "GAUL code for admin1 level"
	replace gaul_adm1_code=2019 if subnatid1=="1 - Punjab"
	replace gaul_adm1_code=2020 if subnatid1=="2 - Sindh"
	replace gaul_adm1_code=2016 if subnatid1=="3 - Khyber Pakhtunkhwa"
	replace gaul_adm1_code=2015 if subnatid1=="4 - Balochistan"
*<_gaul_adm1_code_>

	
** REGIONAL AREA 3 DIGIT ADMN LEVEL
*<_subnatid3_>
	gen subnatid3=""
	label var subnatid3 "Region at 3 digit (ADMN3)"
*</_subnatid3_>


** REGIONAL AREA 4 DIGIT ADMN LEVEL
*<_subnatid4_>
	gen byte subnatid4=.
	label var subnatid4 "Region at 4 digit (ADMN4)"
*</_subnatid4_>

	
** HOUSE OWNERSHIP
*<_ownhouse_>
	recode s5q02 (1/2=1) (3/4=2) (5=3) (*=.), g(ownhouse)
	label var ownhouse "House ownership"
	la de lblownhouse 0 "No" 1 "Yes"
	label values ownhouse lblownhouse
*</_ownhouse_>

clonevar typehouse=ownhouse


** TENURE OF DWELLING
*<_tenure_>
   gen tenure=.
   replace tenure=1 if  s5q02==1 | s5q02==2
   replace tenure=2 if s5q02==3
   replace tenure=3 if s5q02==4 |s5q02==5
   label var tenure "Tenure of Dwelling"
   la de lbltenure 1 "Owner" 2"Renter" 3"Other"
   la val tenure lbltenure
*</_tenure_>	

** LANDHOLDING
*<_lanholding_>
   gen landholding=inlist(1, s9aq01901, s9aq01902, s9aq01903, s9aq01904) if !mi(s9aq01901, s9aq01902, s9aq01903, s9aq01904)
   la def a 1 ".a", replace
   label var landholding "Household owns any land"
	la de lbllandholding 0 "No" 1 "Yes"
   la val landholding lbllandholding
*</_landholding_>	


*ORIGINAL WATER CATEGORIES
*<_water_orig_>
gen water_orig=s5q05
la var water_orig "Source of Drinking Water-Original from raw file"
#delimit
la def lblwater_orig 1 "Piped water"   
					 2 "Hand pump" 
					 3  "Motorized pumping / Tube well" 
					 4	"Open well"  
					 5	"Closed well"  
					 6	"Pond"  
					 7	"Canal / River / Stream"  
					 8	"Spring"  
					 9	"Other";
#delimit cr
la val water_orig lblwater_orig
*</_water_orig_>


*PIPED SOURCE OF WATER
*<_piped_water_>
gen piped_water=.
replace piped_water=1 if s5q05==1
replace piped_water=0 if inlist(s5q05,2,3,4,5,6,7,8,9)
la var piped_water "Household has access to piped water"
la def lblpiped_water 1 "Yes" 0 "No"
la val piped_water lblpiped_water
*</_piped_water_>


**INTERNATIONAL WATER COMPARISON (Joint Monitoring Program)
*<_water_jmp_>
gen water_jmp=.
replace water_jmp=1 if inlist(s5q05,1)
replace water_jmp=4 if inlist(s5q05,2,3)
replace water_jmp=6 if inlist(s5q05,4)
replace water_jmp=5 if inlist(s5q05,5)
replace water_jmp=12 if inlist(s5q05,6,7)
replace water_jmp=14 if inlist(s5q05,8,9)
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
note water_jmp: "PAK 2001" Category 'Spring' from raw data is coded as OTHER, given that it is an ambigous category to 'protected spring' 'unprotected spring'
 *</_water_jmp_>


*ORIGINAL WATER CATEGORIES
*<_water_original_>
clonevar j=s5q05
#delimit
la def lblwater_original 	1 "Piped water"   
							2 "Hand pump" 
							3 "Motorized pumping / Tube well" 
							4 "Open well"  
							5 "Closed well"  
							6 "Pond"  
							7 "Canal / River / Stream"  
							8 "Spring"  
							9 "Other";
#delimit cr
la val j lblwater_original		
decode j, gen(water_original)
drop j
la var water_original "Source of Drinking Water-Original from raw file"
*</_water_original_>


	** WATER SOURCE
	*<_water_source_>
		recode s5q05 (2/3=4) (4=10) (5=5) (6/7=13) (8=9) (9=14) (*=.), g(water_source)
		replace water_source = 1 if s5q05==1 & s5q09==0
		replace water_source = 3 if s5q05==1 & inrange(s5q09,1,5)
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
		recode s5q05 (1/3 5=1) (4 6/9=0) (*=.), g(improved_water)
	*</_improved_water_>
	
	*SAR improved source of drinking water
	*<_sar_improved_water_>
		gen sar_improved_water = improved_water
	*</_sar_improved_water_>



	** PIPED SOURCE OF WATER ACCESS
	*<_pipedwater_acc_>
		gen pipedwater_acc=0 if inrange(s5q05,2,9) // Asuming other is not piped water
		replace pipedwater_acc=1 if s5q05==1 & s5q09==0
		replace pipedwater_acc=2 if s5q05==1 & inrange(s5q09,1,5)
		replace pipedwater_acc=3 if s5q05==1 & missing(s5q09)
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
	gen byte electricity=.
	replace electricity=1 if s5q04a==1 | s5q04a==2
	replace electricity=0 if s5q04a==3
	label var electricity "Electricity main source"
	la de lblelectricity 0 "No" 1 "Yes"
	label values electricity lblelectricity
	notes electricity: "PAK 2001" this variable is generated if hh has electrical connection and extension.
*</_electricity_>


*ORIGINAL TOILET CATEGORIES
*<_toilet_orig_>
gen toilet_orig=s5q14
la var toilet_orig "Access to sanitation facility-Original from raw file"
#delimit
la def lbltoilet_orig 1 "Flush connected to public sewerage" 
					  2	 "Flush connected to pit" 
					  3	 "Flush conn. to open drain"  
					  4	 "Dry raised latrine"   
					  5  "Dry pit latrine" 
					  6	 "No toilet in the household";
#delimit cr
la val toilet_orig lbltoilet_orig
*</_toilet_orig_>


*SEWAGE TOILET
*<_sewage_toilet_>
gen sewage_toilet=s5q14
recode sewage_toilet (1=1)(2=0)(3=0)(4=0)(5=0)(6=0)
la var sewage_toilet "Household has access to sewage toilet"
la def lblsewage_toilet 1 "Yes" 0 "No"
la val sewage_toilet lblsewage_toilet
*</_sewage_toilet_>



**INTERNATIONAL SANITATION COMPARISON (Joint Monitoring Program)
*<_toilet_jmp_>
gen toilet_jmp=.
replace toilet_jmp=1 if toilet_orig==1
replace toilet_jmp=3 if toilet_orig==2
replace toilet_jmp=4 if toilet_orig==3
replace toilet_jmp=12 if toilet_orig==6
replace toilet_jmp=13 if inlist(toilet_orig,4,5)
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
la def lblsar_improved_toilet 1 "Improved" 0 "Unimproved"
la var sar_improved_toilet "Improved type of sanitation facility-using country-specific definitions"
la val sar_improved_toilet lblsar_improved_toilet
*</_sar_improved_toilet_>


	** ORIGINAL SANITATION CATEGORIES 
	*<_sanitation_original_>
		clonevar j=s5q14
		#delimit
		la def lblsanitation_original   1 "Flush connected to public sewerage"
										2 "Flush connected to pit"
										3 "Flush connected to open drain"
										4 "Dry raised latrine"
										5 "Dry pit latrine"
										6 "No toilet in the household" ;
		#delimit cr
		la val j lblsanitation_original
		decode j, gen(sanitation_original)
		drop j
		la var sanitation_original "Access to sanitation facility-Original from raw file"
	*</_sanitation_original_>


	** SANITATION SOURCE
	*<_sanitation_source_>
		gen sanitation_source=.
		replace sanitation_source=2 if s5q14==1
		replace sanitation_source=4 if s5q14==2
		replace sanitation_source=9 if s5q14==3
		replace sanitation_source=14 if s5q14==4
		replace sanitation_source=14 if s5q14==5
		replace sanitation_source=13 if s5q14==6
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
		recode s5q14 (1/3=3) (4/6=0), g(toilet_acc)
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
	gen byte hsize=hhsizeM
		g aux=1
	egen hsize2=sum(aux), by(idh)
	sort idh idp
	replace hsize=hsize2 if hsize==. 
	assert hsize==hsize2
	drop aux hsize2
	
	la var hsize "Household size"
*</_hsize_>


**POPULATION WEIGHT
*<_pop_wgt_>
	gen pop_wgt=wgt*hsize
	la var pop_wgt "Population weight"
*</_pop_wgt_>

** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
*<_relationharm_>
	gen byte relationharm=s1aq02
	recode relationharm (4 6 7 8 9 10 =5) (5=4) (11 12 = 6)
	label var relationharm "Relationship to the head of household"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Non-relatives"
	label values relationharm  lblrelationharm
*</_relationharm_>

** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
*<_relationcs_>

	gen byte relationcs=s1aq02
	la var relationcs "Relationship to the head of household country/region specific"
	label define lblrelationcs 1 "Head" 2 "Spouse" 3 "Son/Daughter" 4 "Grandchild" 5 "Father/Mother" 6 "Brother/Sister" 7 "Nephew/Niece" 8 "Son/Daughter-in-law" 9 "Brother/sister-in-law" 10 "Father/Mother-in-law" 11 "Servant/their relatives" 12 "Other"
	label values relationcs lblrelationcs
*</_relationcs_>


** GENDER
*<_male_>
	gen byte male= sex
	recode male (2=0)
	label var male "Sex of household member"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale
*</_male_>


** AGE
*<_age_>
	*gen byte age=age
	label var age "Age of individual"
	replace age=98 if age>=98 & age!=.
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
	gen byte marital=mstatus
	recode marital ( 2 5 =1) (1=2) (4=4) (3=5)
	label var marital "Marital status"
	la de lblmarital 1 "Married" 2 "Never Married" 3 "Living Together" 4 "Divorced/separated" 5 "Widowed"
	label values marital lblmarital
*</_marital_>


**Make adjustments
replace landholding=. if landholding==1 & hsize==. & relationharm==6
replace ownhouse=. if ownhouse==1 & hsize==. & relationharm==6

/*****************************************************************************************************
*                                                                                                    *
                                   EDUCATION MODULE
*                                                                                                    *
*****************************************************************************************************/
** EDUCATION MODULE AGE
*<_ed_mod_age_>
	gen byte ed_mod_age=4
	label var ed_mod_age "Education module application age"
*</_ed_mod_age_>


** CURRENTLY AT SCHOOL
*<_atschool_>
	gen byte atschool=s2bq01
	recode atschool (3=1) (2 1=0)
	replace atschool=. if age<ed_mod_age
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool
note atschool: "PAK 2001" Attendance question is used	
*</_atschool_>


** CAN READ AND WRITE
*<_literacy_>
	gen byte literacy=1 if s2aq21==1 & s2aq22==1
	replace literacy=0 if s2aq21==2 | s2aq22==2
	replace literacy=. if age<ed_mod_age
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
	notes literacy: "PAK 2001" literacy questions are only asked to individuals 10 years or older
	replace literacy=. if age<10
*</_literacy_>

** YEARS OF EDUCATION COMPLETED
*<_educy_>
			/*
			===========================================
			code	level						years
			===========================================
			1		class 1						1
			2		class 2						2
			3		class 3						3
			4		class 4						4
			5		class 5						5
			6		class 6						6
			7		class 7						7
			8		class 8						8
			9		class 9						9
			10		class 10					10
			11		class 11					11
			12		class 12					12
			13		class 13					13
			17		diploma						13
			14		b.a/b.sc.					14
			15		class 15					15
			16		post graduate (m.a/m.sc.)	16
			18		degree in engineering		16
			20		degree in agriculture		16
			21		degree in law				16
			19		degree in medicine			17
			22		m. phil, ph.d				19
			23		other						NA
			=============================================
*/

	recode s2bq06 (17=13) (14=14) (18=16) (19=17) (20=16) (16=16) (21=16) (22=19) (23=.), gen(educy1)
	*Substract 1 year to those currently studying before highschool
	gen educy2=s2bq16
	replace educy2=s2bq16-1 if s2bq06==. & s2bq16<=12
	replace educy2=0 if educy2<0 
	*Substract 1 year to those currently attending after secondary
	recode educy2 (17=12) (14=13) (18=15) (19=16) (20=15) (16=15) (21=15) (22=18) (23=.) if  s2bq06==. & s2bq16!=.
	gen educy=.
	replace educy=educy1 if educy2==.
	replace educy=educy2 if educy1==.
	replace educy=. if age<ed_mod_age & age!=.
	replace educy=. if educy>age & age!=. & educy!=.
	label var educy "Years of education"
	
	
	replace educy = . if  age<ed_mod_age
	replace educy = . if  educy>age & educy!=. & age!=.
	replace educy = . if educy==age & educy!=.
*</_educy_>
	 
/*
** EDUCATION LEVEL 7 CATEGORIES
*<_educat7_>
	gen byte educat7=1 if educy==0
	replace educat7=2 if educy >0 & educy<8
	replace educat7=3 if educy==8
	replace educat7=4 if educy>8 &  educy<12
	replace educat7=5 if educy==12
	replace educat7=7 if educy>12 & educy<=22
	replace educat7=8 if s2bq06==23 | s2bq16==23 
	replace educat7=. if age<ed_mod_age & age!=.
	replace educat7=.z if s2bq04==3 | s2bq13==3
	label define lbleducat7 1 "No education" 2 "Primary incomplete" 3 "Primary complete" ///
	4 "Secondary incomplete" 5 "Secondary complete" 6 "Higher than secondary but not university" /// 
	7 "University incomplete or complete" 8 "Other" 9 "Not classified"
	label values educat7 lbleducat7
	la var educat7 "Level of education 7 categories"
*</_educat7_>
*/

** EDUCATION LEVEL 7 CATEGORIES
*<_educat7_>
	gen educat7 = .
	*Highest level attended in the past 
	replace educat7 = 1 if s2bq01 == 1
	replace educat7 = 2 if s2bq06 < 5
	replace educat7 = 3 if s2bq06 == 5
	replace educat7 = 4 if s2bq06 >= 6  & s2bq06 < 10  & s2bq06 != . 
	replace educat7 = 5 if s2bq06 == 10
	replace educat7 = 6 if s2bq06 >= 11 & s2bq06 <= 12  
	replace educat7 = 7 if inlist(s2bq06,13,14,15,16,17,18,19,20,21,22)
	replace educat7 = 8 if s2bq06 == 23
	*Grade currently attending
	replace educat7 = 1 if (s2bq16 == 0 ) & s2bq01==3
	replace educat7 = 2 if (s2bq16 >= 1   & s2bq16 <= 5)  & s2bq01==3
	replace educat7 = 3 if (s2bq16 >= 6   & s2bq16 <= 9)  & s2bq01==3
	replace educat7 = 4 if (s2bq16 == 10) & s2bq01==3
	replace educat7 = 5 if (s2bq16 >= 11  & s2bq16 <= 12) & s2bq01==3 
	replace educat7 = 7 if inlist(s2bq16,13,14,15,16,17,18,19,20,21,22)
	replace educat7 = 8 if (s2bq16 == 23 ) & s2bq01==3    & educat7==.
	replace educat7 =.z if s2bq04==3 | s2bq13==3
	*Without the minimum age 
	replace educat7=. if age<ed_mod_age & age!=.
	*People with education years bigger than their age
	replace educat7=. if educy>age & age!=.  & educy!=.
	label define lbleducat7 					///
	1 "No education" 							///
	2 "Primary incomplete" 						///
	3 "Primary complete" 						///
	4 "Secondary incomplete" 					///
	5 "Secondary complete" 						 ///
	6 "Higher than secondary but not university" /// 
	7 "University incomplete or complete"  		 ///
	8 "Other" 9 "Not classified" 				 
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
	replace educat5=.z if  educat7==.z
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
	replace educat4=.z if  educat7==.z
	label var educat4 "Level of education 4 categories"
	label define lbleducat4 1 "No education" 2 "Primary (complete or incomplete)" ///
	3 "Secondary (complete or incomplete)" 4 "Tertiary (complete or incomplete)"
	label values educat4 lbleducat4
*</_educat4_>

** EVER ATTENDED SCHOOL
*<_everattend_>
	gen byte everattend=.
	replace everattend=0 if s2bq01==1
	replace everattend=1 if s2bq01==2 | s2bq01==3
	replace everattend=. if age<ed_mod_age
	label var everattend "Ever attended school"
	la de lbleverattend 0 "No" 1 "Yes"
	label values everattend lbleverattend
*</_everattend_>

	replace educy=0 	if everattend==0
	replace educat7=1 	if everattend==0
	replace educat5=1 	if everattend==0
	replace educat4=1 	if everattend==0

foreach var in atschool literacy educy everattend educat4 educat5 educat7{
replace `var'=. if age<ed_mod_age
}

recode   educat7  (1/2=0) (3/7=1) (*=.) if everattend==1, gen(primarycomp)


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
	gen byte lstatus=.
	replace lstatus=1 if s1bq01==1
	replace lstatus=1 if s1bq03==1
	replace lstatus=2 if s1bq01==2 & s1bq03==2
	replace lstatus=3 if s1bq01==2 & s1bq03==3
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
	gen byte empstat=s1bq06
	recode empstat (4=1) (5=2) (1 2=3) (3 6 7 8 9=4) 
	replace empstat=. if lstatus!=1
	label var empstat "Employment status"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed"
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
	gen byte ocusec=.
	label var ocusec "Sector of activity"
	la de lblocusec 1 "Public, state owned, government, army" 2 "NGO" 3 "Private"
	label values ocusec lblocusec
*</_ocusec_>


** REASONS NOT IN THE LABOR FORCE
*<_nlfreason_>
	gen byte nlfreason=.
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
	gen industry_orig=s1bq05
	label define lblindustry_orig 0 `"activities not adequately defined"', modify
	label define lblindustry_orig 11 `"agriculture, livestock and hunting"', modify
	label define lblindustry_orig 12 `"forestry and logging"', modify
	label define lblindustry_orig 13 `"fishing"', modify
	label define lblindustry_orig 21 `"coal mining"', modify
	label define lblindustry_orig 22 `"crude petroleum and natural gas"', modify
	label define lblindustry_orig 23 `"crude metal or mining"', modify
	label define lblindustry_orig 29 `"other mining"', modify
	label define lblindustry_orig 31 `"manufacture of food, beverages"', modify
	label define lblindustry_orig 32 `"manufacture of textile,"', modify
	label define lblindustry_orig 33 `"manufacture of wood products, including furniture"', modify
	label define lblindustry_orig 34 `"manufacture of paper"', modify
	label define lblindustry_orig 35 `"manufacture of chemicals"', modify
	label define lblindustry_orig 36 `"manufacture of non-metallic mineral"', modify
	label define lblindustry_orig 37 `"basic metal industries"', modify
	label define lblindustry_orig 38 `"manufacture of fabricated metal"', modify
	label define lblindustry_orig 39 `"other manufacturing industries"', modify
	label define lblindustry_orig 41 `"electricity, gas and steam"', modify
	label define lblindustry_orig 42 `"water work and supplies"', modify
	label define lblindustry_orig 51 `"building construction"', modify
	label define lblindustry_orig 52 `"construction,repair,maintenance of streets"', modify
	label define lblindustry_orig 53 `"construction,repair,maintenance of irrigation"', modify
	label define lblindustry_orig 54 `"construction,repair,maintenance of docks"', modify
	label define lblindustry_orig 55 `"construction, repair, maintenance of sports"', modify
	label define lblindustry_orig 56 `"construction, repair, maintenance of sewerage"', modify
	label define lblindustry_orig 57 `"construction, repair, maintenance of pipe line"', modify
	label define lblindustry_orig 59 `"construction project n.e.c"', modify
	label define lblindustry_orig 61 `"wholesale trade"', modify
	label define lblindustry_orig 62 `"retail trade"', modify
	label define lblindustry_orig 63 `"restaurants and hotels"', modify
	label define lblindustry_orig 71 `"transport and storage"', modify
	label define lblindustry_orig 72 `"communication"', modify
	label define lblindustry_orig 81 `"financial institutions"', modify
	label define lblindustry_orig 82 `"insurance"', modify
	label define lblindustry_orig 83 `"real estate and business"', modify
	label define lblindustry_orig 91 `"public administration and defense services"', modify
	label define lblindustry_orig 92 `"sanitary and similar services"', modify
	label define lblindustry_orig 93 `"social and related community services"', modify
	label define lblindustry_orig 94 `"recreational and cultural services"', modify
	label define lblindustry_orig 95 `"personal and household services"', modify
	label define lblindustry_orig 96 `"international and other"', modify
	la val industry_orig lblindustry_orig
	replace industry_orig=. if lstatus!=1
	la var industry_orig "Original industry code"
*</_industry_orig_>

** INDUSTRY CLASSIFICATION
*<_industry_>
	gen byte industry=.
	replace industry=1 if s1bq05>=11 & s1bq05<=13
	replace industry=2 if s1bq05>=21 & s1bq05<=29
	replace industry=3 if s1bq05>=31 & s1bq05<=39
	replace industry=4 if s1bq05>=41 & s1bq05<=42
	replace industry=5 if s1bq05>=51 & s1bq05<=59
	replace industry=6 if s1bq05>=61 & s1bq05<=63
	replace industry=7 if s1bq05>=71 & s1bq05<=72
	replace industry=8 if s1bq05>=81 & s1bq05<=83
	replace industry=9 if s1bq05==91
	replace industry=10 if s1bq05>=92 & s1bq05<=96
	replace industry=10 if s1bq05==0
	replace industry=. if lstatus!=1
	label var industry "1 digit industry classification"
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industry lblindustry
*</_industry_>


g industrycat10 = industry
recode industrycat10 (2/5=2) (6/9=3) (10=4), g(industrycat4)


**ORIGINAL OCCUPATION CLASSIFICATION
*<_occup_orig_>
	gen occup_orig=s1bq04
	label define lbloccup_orig 1 `"armed forces"', modify
	label define lbloccup_orig 11 `"legislators and senior officials"', modify
	label define lbloccup_orig 12 `"cooperate managers"', modify
	label define lbloccup_orig 13 `"general managers"', modify
	label define lbloccup_orig 21 `"physical, mathematical"', modify
	label define lbloccup_orig 22 `"life science and health"', modify
	label define lbloccup_orig 23 `"teaching professionals"', modify
	label define lbloccup_orig 24 `"other professionals"', modify
	label define lbloccup_orig 31 `"physical and engineering science"', modify
	label define lbloccup_orig 32 `"life science and health associate"', modify
	label define lbloccup_orig 33 `"teaching associate professionals"', modify
	label define lbloccup_orig 34 `"other associate professionals"', modify
	label define lbloccup_orig 41 `"office clerks"', modify
	label define lbloccup_orig 42 `"customer services clerks"', modify
	label define lbloccup_orig 51 `"personal and protective"', modify
	label define lbloccup_orig 52 `"models, salespersons"', modify
	label define lbloccup_orig 61 `"market-oriented skilled agricultural"', modify
	label define lbloccup_orig 62 `"subsistence agricultural"', modify
	label define lbloccup_orig 71 `"extraction and building"', modify
	label define lbloccup_orig 72 `"Metal, Machinery And Related Trades Workers ( Metal Moulders, Welders, Sheet-Metal Workers,Structural-Metal, etc)"', modify 
	label define lbloccup_orig 73 `"precision, handicraft, printing"', modify
	label define lbloccup_orig 74 `"other craft and related trades workers"', modify
	label define lbloccup_orig 81 `"stationary-plant and related operators"', modify
	label define lbloccup_orig 82 `"machine operators and assemblers"', modify
	label define lbloccup_orig 83 `"drivers and mobile-plant operators"', modify
	label define lbloccup_orig 91 `"sales and services elementary"', modify
	label define lbloccup_orig 92 `"agricultural, fishery and related labourers"', modify
	label define lbloccup_orig 93 `"labourers in mining, construction,"', modify
	la val occup_orig lbloccup_orig
	replace occup_orig=. if lstatus!=1
	la var occup_orig "Original occupation code"
*</_occup_orig_>


** OCCUPATION CLASSIFICATION
*<_occup_>
	gen byte occup=.
	replace occup=10 if s1bq04==1
	replace occup=1 if s1bq04>=11 & s1bq04<=13
	replace occup=2 if s1bq04>=21 & s1bq04<=24
	replace occup=3 if s1bq04>=31 & s1bq04<=34
	replace occup=4 if s1bq04>=41 & s1bq04<=42
	replace occup=5 if s1bq04>=51 & s1bq04<=52
	replace occup=6 if s1bq04>=61 & s1bq04<=62
	replace occup=7 if s1bq04>=71 & s1bq04<=74
	replace occup=8 if s1bq04>=81 & s1bq04<=83
	replace occup=9 if s1bq04>=91 & s1bq04<=93
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
	gen whours=.
	label var whours "Hours of work in last week"
*</_whours_>


** WAGES
*<_wage_>
	gen double wage=.
	replace wage=s1bq08 if s1bq08!=.
	replace wage=s1bq10 if s1bq10!=.
	replace wage=. if lstatus!=1
	label var wage "Last wage payment"
	notes wage: "PAK 2001" this variable is reported monthly and yearly
*</_wage_>


** WAGES TIME UNIT
*<_unitwage_>
	gen byte unitwage=.
	replace unitwage=5 if s1bq08!=.
	replace unitwage=8 if s1bq10!=.
	replace unitwage=. if lstatus!=1

	label var unitwage "Last wages time unit"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Quarterly" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage lblunitwage
	notes unitwage: "PAK 2001" this variable is reported monthly and yearly
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
	gen byte empstat_2_year=s1bq14
	recode empstat_2_year (4=1) (5=2) (1 2=3) (3 6 7 8 9=4) 
	replace empstat_2_year=. if s1bq11!=1
	label var empstat_2_year "Employment status - second job"
	la de lblempstat_2_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_2_year lblempstat_2_year
*</_empstat_2_>

** INDUSTRY CLASSIFICATION - SECOND JOB
*<_industry_2_>
	gen byte industry_2=.
	replace industry_2=1 if s1bq13>=11 & s1bq13<=13
	replace industry_2=2 if s1bq13>=21 & s1bq13<=29
	replace industry_2=3 if s1bq13>=31 & s1bq13<=39
	replace industry_2=4 if s1bq13>=41 & s1bq13<=42
	replace industry_2=5 if s1bq13>=51 & s1bq13<=59
	replace industry_2=6 if s1bq13>=61 & s1bq13<=63
	replace industry_2=7 if s1bq13>=71 & s1bq13<=72
	replace industry_2=8 if s1bq13>=81 & s1bq13<=83
	replace industry_2=9 if s1bq13==91
	replace industry_2=10 if s1bq13>=92 & s1bq13<=96
	replace industry_2=10 if s1bq13==0
	replace industry_2=. if s1bq11!=1

	label var industry_2 "1 digit industry classification - second job"
	la de lblindustry_2 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industry_2 lblindustry_2
*<_industry_2_>


**SURVEY SPECIFIC INDUSTRY CLASSIFICATION - SECOND JOB
*<_industry_orig_2_>
	gen industry_orig_2=s1bq13
	replace industry_orig_2=. if s1bq11!=1
	label var industry_orig_2 "Original Industry Codes - Second job"
	la de lblindustry_orig_2 1""
	label values industry_orig_2 lblindustry_orig_2
*</_industry_orig_2>


** OCCUPATION CLASSIFICATION - SECOND JOB
*<_occup_2_>
	gen byte occup_2=.
	replace occup_2=10 if s1bq12==1
	replace occup_2=1 if s1bq12>=11 & s1bq12<=13
	replace occup_2=2 if s1bq12>=21 & s1bq12<=24
	replace occup_2=3 if s1bq12>=31 & s1bq12<=34
	replace occup_2=4 if s1bq12>=41 & s1bq12<=42
	replace occup_2=5 if s1bq12>=51 & s1bq12<=52
	replace occup_2=6 if s1bq12>=61 & s1bq12<=62
	replace occup_2=7 if s1bq12>=71 & s1bq12<=74
	replace occup_2=8 if s1bq12>=81 & s1bq12<=83
	replace occup_2=9 if s1bq12>=91 & s1bq12<=93
	replace occup_2=. if s1bq11!=1
	
	label var occup_2 "1 digit occupational classification - second job"
	la de lbloccup_2 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup_2 lbloccup_2
*</_occup_2_>


** WAGES - SECOND JOB
*<_wage_2_>
	gen  wage_2=s1bq15
	replace wage_2=. if s1bq11!=1
	label var wage_2 "Last wage payment - Second job"
*</_wage_2_>


** WAGES TIME UNIT - SECOND JOB
*<_unitwage_2_>
	gen  unitwage_2=8 if wage_2!=.
	replace unitwage_2=. if s1bq11!=1
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

foreach var in lstatus lstatus_year empstat empstat_year njobs njobs_year ocusec nlfreason unempldur_l unempldur_u industry_orig industry occup_orig occup firmsize_l firmsize_u whours wage unitwage empstat_2 empstat_2_year industry_2 industry_orig_2 occup_2 wage_2 unitwage_2 contract healthins socialsec union{
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

notes _dta: "PAK 2001" information on assets comes from durables list, which states the number of items owned by hh at present
notes _dta: "PAK 2001" The relevant question from module 10B only provides information on exepected values from owned animals, not quantities. This would hinder comparability of measurement with other countries.  

** LAND PHONE
*<_landphone_>
	gen byte landphone=. 
	replace landphone=1 if s5q04c==1 | s5q04c==2
	replace landphone=0 if s5q04c==3
	label var landphone "Household has landphone"
	la de lbllandphone 0 "No" 1 "Yes"
	label values landphone lbllandphone
	notes landphone: "PAK 2001" variable is generated if hh has connection or extention of telephone.
*</_landphone_>

clonevar lphone=landphone

** CEL PHONE
*<_cellphone_>

	gen cellphone=.
	label var cellphone "Household has Cell phone"
	la de lblcellphone 0 "No" 1 "Yes"
	label values cellphone lblcellphone
*</_cellphone_>


** COMPUTER
*<_computer_>
	gen byte computer = (numdur_722personal_co>0 & numdur_722personal_co<.)
	label var computer "Household has computer"
	la de lblcomputer 0 "No" 1 "Yes"
	label values computer lblcomputer
*</_computer_>

** RADIO
*<_radio_>
	gen radio= numdur_718radio_casse>0 & numdur_718radio_casse<.
	label var radio "Household has radio"
	la de lblradio 0 "No" 1 "Yes"
	label val radio lblradio
*</_radio_>

** TELEVISION
*<_television_>
	gen television=numdur_716tv>0 & numdur_716tv<.
	label var television "Household has Television"
	la de lbltelevision 0 "No" 1 "Yes"
	label val television lbltelevision
*</_television>

** FAN
*<_fan_>
	gen fan=numdur_705fan__ceilin>0 & numdur_705fan__ceilin<.
	label var fan "Household has Fan"
	la de lblfan 0 "No" 1 "Yes"
	label val fan lblfan
*</_fan>

** SEWING MACHINE
*<_sewingmachine_>
	gen sewingmachine= numdur_721sewing_knit>0 & numdur_721sewing_knit<.
	label var sewingmachine "Household has Sewing machine"
	la de lblsewingmachine 0 "No" 1 "Yes"
	label val sewingmachine lblsewingmachine
*</_sewingmachine>

** WASHING MACHINE
*<_washingmachine_>
	gen washingmachine= numdur_707washing_mac>0 & numdur_707washing_mac<.
	label var washingmachine "Household has Washing machine"
	la de lblwashingmachine 0 "No" 1 "Yes"
	label val washingmachine lblwashingmachine
*</_washingmachine>

** REFRIGERATOR
*<_refrigerator_>
	gen refrigerator= numdur_701refrigerato>0 & numdur_701refrigerato<.
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
	gen bicycle= numdur_713bicycle>0 & numdur_713bicycle<.
	label var bicycle "Household has Bicycle"
	la de lblbycicle 0 "No" 1 "Yes"
	label val bicycle lblbycicle
*</_bycicle>

** MOTORCYCLE
*<_motorcycle_>
	gen motorcycle= numdur_715motorcycle_>0 & numdur_715motorcycle_<.
	label var motorcycle "Household has Motorcycle"
	la de lblmotorcycle 0 "No" 1 "Yes"
	label val motorcycle lblmotorcycle
*</_motorcycle>

** MOTOR CAR
*<_motorcar_>
	gen motorcar= numdur_714car_vehicle>0 & numdur_714car_vehicle<.
	label var motorcar "Household has Motor car"
	la de lblmotorcar 0 "No" 1 "Yes"
	label val motorcar lblmotorcar
*</_motorcar>

** COW
*<_cow_>
	gen cow=.
	la val cow a
	label var cow "Household has Cow"
	*la de lblcow 0 "No" 1 "Yes"
	*label val cow lblcow
*</_cow>

** BUFFALO
*<_buffalo_>
	gen buffalo=.
	la val buffalo a

	label var buffalo "Household has Buffalo"
	*la de lblbuffalo 0 "No" 1 "Yes"
	*label val buffalo lblbuffalo
*</_buffalo>

** CHICKEN
*<_chicken_>
	gen chicken=.
	la val chicken a
	label var chicken "Household has Chicken"
	*la de lblchicken 0 "No" 1 "Yes"
	*label val chicken lblchicken
*</_chicken>

/*****************************************************************************************************
*                                                                                                    *
                                   WELFARE MODULE
*                                                                                                    *
*****************************************************************************************************/


** SPATIAL DEFLATOR
*<_spdef_>
	gen spdef=psupind
	la var spdef "Spatial deflator"
*</_spdef_>


** WELFARE
*<_welfare_>
	gen welfare=(nomexpend/hsize)/psupindm_n //Change
	gen welfare_old=nomexpend/hsize
	la var welfare "Welfare aggregate"
*</_welfare_>

*<_welfarenom_>
	gen welfarenom=nomexpend/hsize
	la var welfarenom "Welfare aggregate in nominal terms"
*</_welfarenom_>

*<_welfaredef_>
	gen welfaredef=texpend/hsize
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
	gen welfareother=peaexpM
	la var welfareother "Welfare Aggregate if different welfare type is used from welfare, welfarenom, welfaredef"
*</_welfareother_>

*<_welfareothertype_>
	gen welfareothertype="CON"
	la var welfareothertype "Type of welfare measure (income, consumption or expenditure) for welfareother"
*</_welfareothertype_>

*<_welfarenat_>
	gen welfarenat=peaexpM
	la var welfarenat "Welfare aggregate for national poverty"
*</_welfarenat_>

gen welfshprtype = "EXP"

*QUINTILE, DECILE AND FOOD/NON-FOOD SHARES OF CONSUMPTION AGGREGATE
	levelsof year, loc(y)
	* path on Joe's computer
	if ("`c(username)'"=="sunquat") {
		merge m:1 idh using "${input}/Data/Stata/PAK_fnf_`y'", keepusing(food_share nfood_share quintile_cons_aggregate decile_cons_aggregate) nogen
	}
	* global paths on WB computer
	else {
		merge m:1 idh using "$shares/PAK_fnf_`y'", keepusing(food_share nfood_share quintile_cons_aggregate decile_cons_aggregate) nogen
	}


/*****************************************************************************************************
*                                                                                                    *
                                   NATIONAL POVERTY
*                                                                                                    *
*****************************************************************************************************/

	
**ADULT EQUIVALENCY
	gen eqadult=eqadultM
	label var eqadult "Adult Equivalent (Household)"


** POVERTY LINE (NATIONAL)
*<_pline_nat_>
	gen pline_nat=new_pline
	label variable pline_nat "Poverty Line (National)"
*</_pline_nat_>


** HEADCOUNT RATIO (NATIONAL)
*<_poor_nat_>
	gen poor_nat=welfarenat<pline_nat if welfarenat!=. & pline_nat!=.
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
    cap drop cpi* icp* ppp* 
	
** CPI VARIABLE 
*<_cpi_>
	/*
	capture drop _merge
	gen urb=.
	merge m:1 countrycode year urb using "$pricedata", ///
	keepusing(countrycode year urb syear cpi`year'_w ppp`year')
	drop urb
	drop if _merge!=3
	drop _merge
	*/
	
	preserve 
	* global path on Joe's computer
	if ("`c(username)'"=="sunquat") {
		use "${input}/Data/Stata/Monthly_CPI", clear
	}
	* global path on WB computer
	else {
		datalibweb, country(Support) year(2005) type(GMDRAW) surveyid(Support_2005_CPI_v`cpiver'_M) filename(Monthly_CPI.dta)
	}
	*old: datalibweb, country(Support) year(2005) type(GMDRAW) surveyid(Support_2005_CPI_v06_M) filename(Monthly_CPI.dta)
    keep if inlist(code,"PAK")
	keep code year month yearly_cpi monthly_cpi
    keep if month==6 
    
    foreach x of numlist 11 17 {
     egen yearly_cpi20`x'    =mean(yearly_cpi) if year==20`x' 
     egen m_yearly_cpi20`x'  =mean(yearly_cpi20`x')
     drop yearly_cpi20`x'
     rename m_yearly_cpi20`x' yearly_cpi20`x'
	 gen cpi20`x'_`cpiver'=(monthly_cpi/yearly_cpi20`x') 
	}
    keep code year cpi20*
    tempfile cpibasedata_M_PAK_`cpiver'
    save `cpibasedata_M_PAK_`cpiver''
	restore 
	merge m:1 year using `cpibasedata_M_PAK_`cpiver'', nogen keep(match)
	
	*ren cpi`year'_w cpi
	label variable cpi2011_`cpiver' "CPI (CPI from June 2001 base 2011)"
	label variable cpi2017_`cpiver' "CPI (CPI from June 2001 base 2017)"
*</_cpi_>
	
	
** PPP VARIABLE
*<_ppp_>
    preserve
	* global path on Joe's computer
	if ("`c(username)'"=="sunquat") {
		use "${input}/Data/Stata/Support_2005_GMDRAW_Support_2005_CPI_v10_M_Yearly_CPI_Final", clear
	}
	* global path on WB computer
	else {
		datalibweb, country(Support) year(2005) type(GMDRAW) surveyid(Support_2005_CPI_v`cpiver'_M) filename(Yearly_CPI_Final.dta)
	}
	*old: datalibweb, country(Support) year(2005) type(GMDRAW) surveyid(Support_2005_CPI_v05_M) filename(Yearly_CPI_Final.dta)
    keep if inlist(code,"PAK") 
    collapse (mean) ppp_2011 ppp_2017, by(countryname code ppp_domain_value)
    *replace ppp_domain=0 if ppp_domain_value==2
    *rename ppp_domain_value datalevel
    *replace datalevel=2 if datalevel==1 & code!="IND"
    tempfile pppdata
    save `pppdata', replace
	restore 
	merge m:1 code using `pppdata', nogen keep(match)
	
	*ren ppp`year' 	ppp
	label variable cpi2011_`cpiver' "PPP (base 2011)"
	label variable cpi2017_`cpiver' "PPP (base 2017)"
*</_ppp_>

	
** CPI PERIOD
*<_cpiperiod_>
	gen cpiperiod="2001m6"
	*label var cpiperiod "Periodicity of CPI (year, year&month, year&quarter, weighted)"
*</_cpiperiod_>	
	
	

** POVERTY LINE (POVCALNET) 1.9
*<_pline_int_>
	gen pline_int_19=1.90*cpi2011_`cpiver'*ppp_2011*365/12
	label variable pline_int "Poverty Line 1.9 (Povcalnet)"
*</_pline_int_>
		
*<_poor_int_>
	gen poor_int_19=welfare<pline_int_19 if welfare!=.
	la var poor_int_19 "People below Poverty Line (Povcalnet)"
	la define poor_int_19 0 "Not Poor" 1 "Poor"
	la values poor_int_19 poor_int_19
	tab poor_int_19 [aw= pop_wgt] if !mi(poor_int_19)
	
	gen	welfare_ppp2= (12/365)*welfaredef/cpi2011_`cpiver'/ppp_2011
	apoverty welfare_ppp2 [w=popwt], line(1.9) 
	
	gen poor_int_19_b=welfare<=pline_int_19 
	tab poor_int_19_b [aw= weight] if !mi(poor_int_19)
	
	
*</_poor_int_>
	
	
** POVERTY LINE (POVCALNET) 3.2
*<_pline_int_>
	gen pline_int_32=3.20*cpi2011_`cpiver'*ppp_2011*365/12
	label variable pline_int_32 "Poverty Line 1.9 (Povcalnet)"
*</_pline_int_>
		
*<_poor_int_>
	gen poor_int_32=welfare<pline_int_32 if welfare!=.
	la var poor_int_32 "People below Poverty Line (Povcalnet)"
	la define poor_int_32 0 "Not Poor" 1 "Poor"
	la values poor_int_32 poor_int_32 
	tab poor_int_32 [aw= pop_wgt] if !mi(poor_int_32)
*</_poor_int_>


** POVERTY LINE (POVCALNET) 5.5
*<_pline_int_>
	gen pline_int_55=5.50*cpi2011_`cpiver'*ppp_2011*365/12
	label variable pline_int_55 "Poverty Line 1.9 (Povcalnet)"
*</_pline_int_>
		
*<_poor_int_>
	gen poor_int_55=welfare<pline_int_55 if welfare!=.
	la var poor_int_55 "People below Poverty Line (Povcalnet)"
	la define poor_int_55 0 "Not Poor" 1 "Poor"
	la values poor_int_55 poor_int_55
	tab poor_int_55 [aw= pop_wgt] if !mi(poor_int_55)
*</_poor_int_>
 
 
    ainequal welfare [w=pop_wgt]


clonevar hhid=idh
clonevar idh_org=hhid
clonevar pid=idp
clonevar idp_org=pid

g	harmonization	=	"SARMD"
g	imp_san_rec		=	improved_sanitation
g	imp_wat_rec		=	improved_water 
g	school			=	atschool


/*****************************************************************************************************
*                                                                                                    *
                                   FINAL STEPS
*                                                                                                    *
*****************************************************************************************************/
* create variables that were not in questionnaire as missing 
foreach var_notfound in shared_toilet industry_year industry_2_year industry_orig_year industry_orig_2_year occup_year ocusec_year {
	if strmatch("`var_notfound'","*_orig*") g `var_notfound' = ""
	else g `var_notfound' = .
	note `var_notfound': PAK_2001_PIHS does not have any relevant questions or variables.
}


* create variables that do not have sufficient definitions from the SAR team
foreach var_notfound in converfactor gaul_adm2_code gaul_adm3_code sector pline_int poor_int {
	g `var_notfound'=.
	note `var_notfound': For PAK_2001_PIHS, I did not have a sufficient understanding of how `var_notfound' is defined from the SAR team, so it was created as missing.
}

*drop if welfare==.

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

cap log close


******************************  END OF DO-FILE  *****************************************************/
