/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                              SOUTH ASIA MICRO DATABASE (SARMD)                                   **
**                                                                                                  **
** COUNTRY			Maldives
** COUNTRY ISO CODE	MDV
** YEAR				2016
** SURVEY NAME		Household Income and Expenditure Survey 2016
** SURVEY AGENCY	National Bureau of Statistics
** RESPONSIBLE		Francisco Javier Parada Gomez Urquiza
** DATE				03/22/2019
** MODIFIED         12/10/2019                                                                                   **
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
	local input   "\\Wbgmsbdat001\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\MDV\MDV_2016_HIES\MDV_2016_HIES_v01_M"
	local output  "\\Wbgmsbdat001\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\MDV\MDV_2016_HIES\MDV_2016_HIES_v01_M_v01_A_SARMD"
	glo pricedata "\\Wbgmsbdat001\SOUTH ASIA MICRO DATABASE\CPI\cpi_ppp_sarmd_weighted.dta"
	glo shares    "\\Wbgmsbdat001\SOUTH ASIA MICRO DATABASE\APPS\DATA CHECK\Food and non-food shares\MDV"
	glo fixlabels "\\Wbgmsbdat001\SOUTH ASIA MICRO DATABASE\APPS\DATA CHECK\Label fixing"

** LOG FILE
	log using "`output'\Doc\Technical\MDV_2016_HIES_v01_M_v01_A_SARMD.log",replace
	
/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/


/** DATABASE ASSEMBLENT */
	
	* Merge individual and housing data
	use "`input'\Data\Stata\F4.dta", clear
	merge m:1 Form_ID using "`input'\Data\Stata\F2.dta"
	drop _merge
	preserve

	* Merge with atolls
	use "`input'\Data\Stata\F3-Q12-Q23.dta", clear
	collapse (first) Atoll_Island IslandCode block HHSN surveyMonth Atoll Adjustedhouseholdweight, by(Form_ID)
	save "`input'\Data\Stata\Atolls.dta", replace
	restore
	merge m:1 Form_ID using "`input'\Data\Stata\Atolls.dta"
	drop _merge	
	preserve
	
	* Merge with assets
	use "`input'\Data\Stata\F2-Q30.dta" , clear
	keep Form_ID _Item _HaveAccess
	rename _HaveAccess access_
	recode access_ (1=1) (2 9=0)
	replace _Item="Car" if _Item=="Car/Jeep"
	replace _Item="Computer" if _Item=="Computer/Laptop"
	replace _Item="Radio" if _Item=="Radio/Set"
	reshape wide access_, i( Form_ID ) j( _Item ) string
	save "`input'\Data\Stata\Assets.dta", replace
	restore
	merge m:1 Form_ID using "`input'\Data\Stata\Assets.dta"
	drop _merge
	foreach var of varlist access_Bicycle-access_Telephone{
	replace `var'=0 if `var'==.
	}
	preserve
	
	* Merge total food expenditures
	use "`input'\Data\Stata\F7-Q3-Q5.dta", clear
	collapse (rawsum) exp, by(Form_ID)
	rename exp weekly_foodexp
	label var weekly_foodexp "7 day total household food expenditures"
	save "`input'\Data\Stata\Food.dta", replace
	restore
	merge m:1 Form_ID using "`input'\Data\Stata\Food.dta"
	drop _merge
	
	* Merge labor force module
	merge 1:1 Form_ID Id using "`input'\Data\Stata\F5.dta" 
	drop if _merge==2
	drop _merge
	merge 1:1 Form_ID Id using "`input'\Data\Stata\F6.dta" 
	drop if _merge==2
	drop _merge
	preserve

	* Merge welfare aggregate provided by Christina Wieser
	use  "`input'\Poverty and technical documents\World Bank\Christina Wieser\poverty.dta" , clear
	rename hhid Form_ID
	save "`input'\Data\Stata\Welfare.dta", replace 
	restore
	merge m:1 Form_ID using "`input'\Data\Stata\Welfare.dta", force
	drop _merge male
	
	egen tag=tag(Form_ID)

/*****************************************************************************************************
*                                                                                                    *
                                   * STANDARD SURVEY MODULE
*                                                                                                    *
*****************************************************************************************************/
	

** COUNTRY
*<_countrycode_>
	gen str4 countrycode="MDV"
	label var countrycode "Country code"
	note countrycode: countrycode=MDV
*<_countrycode_>

	
** YEAR
*<_year_>
	gen int year=2016
	label var year "Year of survey"
	note year: year=2016
*<_year_>
	
	
** SURVEY
*<_survey_>
	gen survey="HIES"
	label var survey "Survey acronym"
	note survey: survey=HIES
*<_survey_>


** INTERVIEW YEAR
*<_int_year_>
	gen int_year=2016
	label var int_year "Year of the interview"
	note int_year: int_year=2016
*<_int_year_>
	
	
** INTERVIEW MONTH
*<_int_month_>
	destring surveyMonth, replace
	gen int_month=surveyMonth
	la de lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value int_month lblint_month
	label var int_month "Month of the interview"
	note int_month: int_month=February-November 2016
*<_int_month_>


** HOUSEHOLD IDENTIFICATION NUMBER
*<_idh_>
	gen idh=Form_ID
	tostring idh, replace
	label var idh "Household id"
	note idh: idh=Form_ID  4,910 values
*<_idh_>
	

** INDIVIDUAL IDENTIFICATION NUMBER
*<_idp_>
	egen idp=concat(idh Id), punct(-)
	label var idp "Individual id"
	note idp: idp=Form_ID - Id  26,025 values
*<_idp_>

	
** HOUSEHOLD WEIGHTS
*<_wgt_>
	gen double wgt=adj_wgt
	label var wgt "Household sampling weight"
	note wgt: wgt=adj_wgt
*<_wgt_>

	
** POPULATION WEIGHT
*<_pop_wgt_>
	gen pop_wgt=wgt*hhsize
	la var pop_wgt "Population weight"
	note pop_wgt: pop_wgt=adj_wgt*hhsize
*<_pop_wgt_>


** STRATA
*<_strata_>
	gen strata=Atoll
	label var strata "Strata"
	note strata: strata=Male and 20 administrative atolls
*<_strata_>
	
	
** PSU
*<_psu_>
	gen psu=.
	label var psu "Primary sampling units"
	note psu: psu=?
*<_psu_>
	

** MASTER VERSION
*<_vermast_>
	gen vermast="01"
	label var vermast "Master Version"
	note vermast: vermast=01
*<_vermast_>
	
	
** ALTERATION VERSION
*<_veralt_>
	gen veralt="01"
	label var veralt "Alteration Version"
	note veralt: veralt=01
*<_veralt_>
	
	
/*****************************************************************************************************
*                                                                                                    *
                                   DEMOGRAPHIC MODULE
*                                                                                                    *
*****************************************************************************************************/


** HOUSEHOLD SIZE
*<_hsize_>
	gen hsize=hhsize
	label var hsize "Household size"
	bysort idh: gen count=_N
	note hsize: hsize equals count
*<_hsize_>

	
** AGE
*<_age_>
	gen age=Q406
	label var age "Individual age"
	note age: age=99 in 362 cases
*<_age_>

	
** GENDER
*<_male_>
	gen byte male=Q404
	recode male (1=0)(2=1)
	label var male "Sex of household member"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale
	note male: male =  47.49% of individuals
*<_male_>
	

** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
*<_relationharm_>
	gen byte relationharm=Q408
	recode relationharm (1=1) (2=2) (3/4=3) (6=4) (5 7 8 9 10 11 12 =5) (13=6) (99=.)
	label var relationharm "Relationship to the head of household"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Non-relatives"
	label values relationharm  lblrelationharm
	note relationharm: relationharm = 1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Non-relatives"
*<_relationharm_>

*<_relationcs_>
	gen byte relationcs=Q408
	la var relationcs "Relationship to the head of household country/region specific"
	label define lblrelationcs 1 "Household head" 2 "Spouse" 3 "Child" 4 "Step Child" 5 "Son/Daughter-in-law" 6 "Mother/father" 7 "Step Parents" 8 "Brother/Sister" 9 "Father/Mother-in-law" 10 "Brother-in-law/Sister-in-law" 11 "Grand child"  12 "Other relative" 13 "Non-relative"
	label values relationcs lblrelationcs
	note relationcs: relationcs = 1 "Household head" 2 "Spouse" 3 "Child" 4 "Step Child" 5 "Son/Daughter-in-law" 6 "Mother/father" 7 "Step Parents" 8 "Brother/Sister" 9 "Father/Mother-in-law" 10 "Brother-in-law/Sister-in-law" 11 "Grand child"  12 "Other relative" 13 "Non-relative"
*<_relationcs_>

	
** MARITAL STATUS
*<_marital_>
	gen marital=Q427
	recode marital (1=2) (2=1) (3=4) (4=5) (9=.)
	label var marital "Marital status"
	la de lblmarital 1 "Married" 2 "Never Married" 3 "Living Together" 4 "Divorced/separated" 5 "Widowed"
	label values marital lblmarital
	note marital: What is your marital status? Never married, married, divorced, widowed. 
*<_marital_>


** SOCIAL GROUP
*<_soc_>
	gen byte soc=Q407
	label var soc "Social group"
	la de lblsoc 1 "Maldivian" 2 "Foreigner" 9 "N/A"
	label values soc lblsoc
	note soc: soc = Maldivian or Foreigner
*<_soc_>

	
/*****************************************************************************************************
*                                                                                                    *
                                   HOUSEHOLD CHARACTERISTICS MODULE
*                                                                                                    *
*****************************************************************************************************/


** LOCATION (URBAN/RURAL)
*<_urban_>
	gen urban=0
	replace urb=1 if Atoll=="Male" 
	label var urban "Urban/Rural"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban
	note urban: urban = Male although urban/rural does not exist in the Maldives
*<_urban_>


** REGIONAL AREA 1 DIGIT ADMN LEVEL
*<_subnatid1_>
	clonevar subnatid1=Atoll
	label var subnatid1 "Region at 1 digit (ADMN1)"
	note subnatid1: subnatid1 = Male + 20 Atolls
	replace subnatid1="1 - Alif Alif" if Atoll=="AA"
	replace subnatid1="2 - Alif Dhaal" if Atoll=="Adh"
	replace subnatid1="3 - Baa" if Atoll=="B"
	replace subnatid1="4 - Dhaalu" if Atoll=="Dh"
	replace subnatid1="5 - Faafu" if Atoll=="F"
	replace subnatid1="6 - Gaafu Alif" if Atoll=="GA"
	replace subnatid1="7 - Gaafu Dhaalu" if Atoll=="GDh"
	replace subnatid1="8 - Gnaviyani" if Atoll=="Gn"
	replace subnatid1="9 - Haa Alif" if Atoll=="HA"
	replace subnatid1="10 - Haa Dhaalu" if Atoll=="HDh"
	replace subnatid1="11 - Kaafu" if Atoll=="K"
	replace subnatid1="12 - Laamu" if Atoll=="L"
	replace subnatid1="13 - Lhaviyani" if Atoll=="Lh"
	replace subnatid1="14 - Malé" if Atoll=="Male"
	replace subnatid1="15 - Meemu" if Atoll=="M"
	replace subnatid1="16 - Noonu" if Atoll=="N"
	replace subnatid1="17 - Raa" if Atoll=="R"
	replace subnatid1="18 - Seenu/Addu" if Atoll=="S"
	replace subnatid1="19 - Shaviyani" if Atoll=="Sh"
	replace subnatid1="20 - Thaa" if Atoll=="Th"
	replace subnatid1="21 - Vaavu" if Atoll=="V"
*<_subnatid1_>
	
*<_gaul_adm1_code_>
	gen gaul_adm1_code=.
	label var gaul_adm1_code "GAUL code for admin1 level"
	replace gaul_adm1_code=1990 if subnatid1=="1 - Alif Alif"
	replace gaul_adm1_code=1991 if subnatid1=="2 - Alif Dhaal"
	replace gaul_adm1_code=1992 if subnatid1=="3 - Baa"
	replace gaul_adm1_code=1993 if subnatid1=="4 - Dhaalu"
	replace gaul_adm1_code=1994 if subnatid1=="5 - Faafu"
	replace gaul_adm1_code=1995 if subnatid1=="6 - Gaafu Alif"
	replace gaul_adm1_code=1996 if subnatid1=="7 - Gaafu Dhaalu"
	replace gaul_adm1_code=. if subnatid1=="8 - Gnaviyani"
	replace gaul_adm1_code=1997 if subnatid1=="9 - Haa Alif"
	replace gaul_adm1_code=1998 if subnatid1=="10 - Haa Dhaalu"
	replace gaul_adm1_code=1999 if subnatid1=="11 - Kaafu"
	replace gaul_adm1_code=2000 if subnatid1=="12 - Laamu"
	replace gaul_adm1_code=2001 if subnatid1=="13 - Lhaviyani"
	replace gaul_adm1_code=2002 if subnatid1=="14 - Malé"
	replace gaul_adm1_code=2003 if subnatid1=="15 - Meemu"
	replace gaul_adm1_code=2004 if subnatid1=="16 - Noonu"
	replace gaul_adm1_code=2005 if subnatid1=="17 - Raa"
	replace gaul_adm1_code=2006 if subnatid1=="18 - Seenu/Addu"
	replace gaul_adm1_code=2007 if subnatid1=="19 - Shaviyani"
	replace gaul_adm1_code=2008 if subnatid1=="20 - Thaa"
	replace gaul_adm1_code=2009 if subnatid1=="21 - Vaavu"
*<_gaul_adm1_code_>


** REGIONAL AREA 2 DIGIT ADMN LEVEL
*<_subnatid2_>
	encode Atoll_Island, gen(subnatid2)
	label var subnatid2 "Region at 2 digit (ADMN2)"
	note subnatid2: subnatid2 = Islands
*<_subnatid2_>
	
	
/** REGIONAL AREA 2 DIGIT ADMN LEVEL
	gen subnatid3= .
	label var subnatid2 "Region at 2 digit (ADMN3)"
	note subnatid3: subnatid3 = .
*/	

** HOUSE OWNERSHIP
*<_ownhouse_>
	gen ownhouse=ownedbyhhmember
	recode ownhouse (1 2=1) (3 4=0) (9=.) 
	label var ownhouse "House ownership"
	la de lblownhouse 0 "No" 1 "Yes"
	label values ownhouse lblownhouse
	note ownhouse: ownhouse= Yes if owned by a member of this hh/own place or owned by a relative not living here. No if arranged by the employer or other 
*<_ownhouse_>
	
	
** ELECTRICITY PUBLIC CONNECTION
*<_electricity_>
	gen byte electricity=hourselectric
	recode electricity (24=1)
	label var electricity "Electricity main source"
	la de lblelectricity 0 "No" 1 "Yes"
	label values electricity lblelectricity
	note electricity: 24/7 electricity available to all households
*<_electricity_>

	
** TOILET PUBLIC CONNECTION
*<_toilet_orig_>
	clonevar  toilet_orig=typeseweragesystem 
	note toilet_orig: Toilet original categories
*<_toilet_orig_>


*<_sewage_toilet_>	
	gen byte sewage_toilet=toilet_orig
	recode sewage_toilet (1 =1) (2 3 4=0)
	label var sewage_toilet "Sewage Toilet facility"
	la de lbltoilet 0 "No" 1 "Yes"
	label values sewage_toilet lbltoilet
	note sewage_toilet: Toilet connected to sewage system
*<_sewage_toilet_>	


*<_toilet_jmp_>	
	gen toilet_jmp=toilet_orig
	recode toilet_jmp (1=1)(2=4) (3=2) (4=13)
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
	replace sar_improved_toilet=1 if inlist(toilet_jmp,1,2,3,4,7,8,11)
	replace sar_improved_toilet=0 if inlist(toilet_jmp,5,6,9,10,12,13)
	la def lblsar_improved_toilet 1 "Improved" 0 "Unimproved"
	la var sar_improved_toilet "Improved type of sanitation facility-using country-specific definitions"
	la val sar_improved_toilet lblsar_improved_toilet
*</_sar_improved_toilet_>

	
** WATER JMP
*<_water_orig_>
	clonevar water_orig=drinkingwatersource 
	label var water_orig "Source of drinking water (original)"
	note water_orig: 1 piped water, 2 well, 3 rainwater, 4 bottled water, 5 other, 9 not stated 
*<_water_orig_>
	
	
*PIPED SOURCE OF WATER
*<_piped_water_>
	gen piped_water=cookingwatersource
	recode piped_water (1=1) (2/9=0) 
	replace piped_water=1 if water_orig==1
	la var piped_water "Household has access to piped water"
	la def lblpiped_water 1 "Yes" 0 "No"
	la val piped_water lblpiped_water
*</_piped_water_>

	
**INTERNATIONAL WATER COMPARISON (Joint Monitoring Program)
*<_water_jmp_>
	gen water_jmp=water_orig
	recode water_jmp (1=1)(2=5)(3=9)(4=13)(5=14)(9=.)
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
	replace sar_improved_water=1 if inlist(water_jmp,1,2,3,4,5,7,9)
	replace sar_improved_water=0 if inlist(water_jmp,6,8,10,11,12,13,14) 
	la def lblsar_improved_water 1 "Improved" 0 "Unimproved"
	la var sar_improved_water "Improved source of drinking water-using country-specific definitions"
	la val sar_improved_water lblsar_improved_water
*</_sar_improved_water_>

* NEW!

*<_sanitation_original_>
	clonevar sanitation_original=typeseweragesystem
	label define lblsanitation_original 1 "1 - Toilet connected to sewerage system" 2 "2 - Toilet connected to sea" 3 "3 - Toilet connected to septic tank" 4 "4 - Gifili (without toilet bowls)" 
	label values sanitation_original lblsanitation_original
	label var sanitation_original "Original survey response in string for sanitation_source variable"
	note sanitation_original: Question 14. What type of sewerage system is in this housing unit? 1. Toilet connected to sewerage system; 2. Toilet connected to sea; 3. Toilet connected to septic tank; 4. Gifili (without toilet bowls)
*</_sanitation_original_>


*<_sanitation source_>
	clonevar sanitation_source=typeseweragesystem
	recode sanitation_source (1=1)(2=9)(3=3)(4=13)
	label define lblsanitation_source 1 "A flush toilet" 2 "A piped sewer system" 3 "A septic tank" 4 "Pit latrine" 5 "Ventilated improved pit latrine (VIP)" 6 "Pit latrine with slab" 7 "Composting toilet" 8 "Special case" 9 "A flush/pour flush to elsewhere" 10 "A pit latrine without slab" 11 "Bucket" 12 "Hanging toilet or hanging latrine" 13 "No facilities or bush or field" 14 "Other"
	label values sanitation_source lblsanitation_source
	label var sanitation_source "Sources of sanitation facilities"
	note sanitation_source: Question 14. What type of sewerage system is in this housing unit? 1. Toilet connected to sewerage system; 2. Toilet connected to sea; 3. Toilet connected to septic tank; 4. Gifili (without toilet bowls)
*</_sanitation source_>


*<_pipedwater_acc_>
	clonevar pipedwater_acc=drinkingwatersource
	recode pipedwater_acc (1=1)(2 3 4 5 9=0)
	label define lblpipedwater_acc 0 "No" 1 "Yes, in premise" 2 "Yes , but not in premise including public toilet" 3 "Yes, unstated whether in or outside premise"
	label var pipedwater_acc "Access to piped water"
	note pipedwater_acc:
*</_pipedwater_acc_>


*<_toilet_acc_>
	gen toilet_acc=toiletfacilities
	recode toilet_acc (1=1)(2=0)(9=.)
	label define lbltoilet_acc 0 "No" 1 "Yes, in premise" 2 "Yes , but not in premise including public toilet" 3 "Yes, unstated whether in or outside premise"
	label values toilet_acc lbltoilet_acc
	label var toilet_acc "Access to flushed toilet"
	note toilet_acc: Question 13. Does this household have toilet facilities within the housing unit?
*</_toilet_acc_>


*<_water_original_>
	clonevar water_original=drinkingwatersource
	label var water_original "Original survey response in string for water_source variable"
	note water_original: Question 19. What is the main source of drinking water used by most of the occupants of this household?
*</_water_original_>


*<_water_source_>
	clonevar water_source=drinkingwatersource
	recode water_source (1=1)(2=5)(3=8)(4=7)(5 9=14)
	label define lblwater_source 1 "Piped water into dwelling" 2 "Piped water to yard/plot" 3 "Public tap or standpipe" 4 "Tubewell or borehole" 5 "Protected dug well" 6 "Protected spring" 7 "Bottled water" 8 "Rainwater" 9 "Unprotected spring" 10 "Unprotected dug well" 11 "Cart with small tank/drum" 12 "Tanker-truck" 13 "Surface water" 14 "Other"
	label values water_source lblwater_source
	numlabel lblwater_source, add mask(# - )
	label var water_source "Sources of drinking water"
	note water_source: Question 19. What is the main source of drinking water used by most of the occupants of this household?
*</_water_source_>


*<_watertype_quest_>
	gen watertype_quest=3
	label var watertype_quest "Type of water questions used in the survey"
	note watertype_quest:
*</_watertype_quest_>


*<_imp_san_rec_>
	clonevar imp_san_rec=typeseweragesystem
	recode imp_san_rec (1 2 3 =1)(4=0)
	replace imp_san_rec=0 if toiletfacilities==2
	label define lblimp_san_rec 1 "Improved" 0 "Unimproved"
	label values imp_san_rec lblimp_san_rec
	label var imp_san_rec "Improved access to sanitation facilities"
	note imp_san_rec:
*</_imp_san_rec_>

tab   typeseweragesystem imp_san_rec

*<_imp_wat_rec_>
	clonevar imp_wat_rec=drinkingwatersource
	recode imp_wat_rec (1 2 3 4 =1)(5 9=0)
	label define lblimp_wat_rec 1 "Improved" 0 "Unimproved"
	label values imp_wat_rec lblimp_wat_rec
	label var imp_wat_rec "Improved access to drinking water"
	note imp_wat_rec:
*</_imp_wat_rec_>

tab   drinkingwatersource imp_wat_rec



/*****************************************************************************************************
*                                                                                                    *
                                            ASSETS 
*                                                                                                    *
*****************************************************************************************************/

** LAND PHONE
*<_landphone_>
	gen byte landphone=access_Telephone
	label var landphone "Household has landphone"
	la de lbllandphone 0 "No" 1 "Yes"
	label values landphone lbllandphone
	note landphone: landphone only 3%
*<_landphone_>
	

** CELL PHONE
*<_cellphone_>
	recode  Q4261 (1=1)(2=0)(9=.)
	bysort Form_ID: egen cellphone=sum(Q4261)
	replace cellphone=1 if cellphone>1
	label var cellphone "Household has cellphone"
	la de lblcellphone 0 "No" 1 "Yes"
	label values cellphone lblcellphone
	note cellphone: cellphone=1 if at least one cellphone in household (99% of individuals)
*<_cellphone_>

	
** MOTORCYCLE
*<_motorcycle_>
	recode  Q4262 (1=1)(2=0)(9=.)
	bysort Form_ID: egen motorcycle=sum(Q4262)
	replace motorcycle=1 if motorcycle>1
	label var motorcycle "Household has Motorcycle"
	la de lblmotorcycle 0 "No" 1 "Yes"
	label val motorcycle lblmotorcycle
	note motorcycle: motorcycle=1 if at least one motorcycle in household (42% of individuals)
*<_motorcycle_>

	
** BICYCLE
*<_bicycle_>
	gen byte bicycle=access_Bicycle
	label var bicycle "Household has Bicycle"
	la de lblbycicle 0 "No" 1 "Yes"
	label val bicycle lblbycicle
	note bicycle: bicycle owned by 50%
*<_bicycle_>


** MOTOR CAR
*<_motorcar_>
	gen byte motorcar=access_Car 
	label var motorcar "Household has Motor car"
	la de lblmotorcar 0 "No" 1 "Yes"
	label val motorcar lblmotorcar
	note motorcar: motorcar owned by 4%
*<_motorcar_>

	
** COMPUTER
*<_computer_>
	gen byte computer=access_Computer
	label var computer "Household has computer"
	la de lblcomputer 0 "No" 1 "Yes"
	label values computer lblcomputer
	note computer: computer=Computer/Laptop owned by 64%
*<_computer_>
	

** RADIO
*<_radio_>
	gen byte radio=access_Radio 
	label var radio "Household has radio"
	la de lblradio 0 "No" 1 "Yes"
	label val radio lblradio
	note radio: radio owned by 57%
*<_radio_>


** REFRIGERATOR
*<_refrigerator_>
	gen byte refrigerator=access_Refrigerator 
	label var refrigerator "Household has Refrigerator"
	la de lblrefrigerator 0 "No" 1 "Yes"
	label val refrigerator lblrefrigerator
	note refrigerator: refrigertaor owned by 95%
*<_refrigerator_>
	

** TELEVISION
*<_television_>
	gen byte television=access_TV
	label var television "Household has Television"
	la de lbltelevision 0 "No" 1 "Yes"
	label val television lbltelevision
	note television: television owned by 93%
*<_television_>


** FAN
*<_fan_>
	gen byte fan=access_Fan 
	label var fan "Household has Fan"
	la de lblfan 0 "No" 1 "Yes"
	label val fan lblfan
	note fan: fan owned by 99%
*<_fan_>
	

/** SEWING MACHINE
*<_sewingmachine_>
	gen sewingmachine= numbitSEWING_MACHINE>0 if  numbitSEWING_MACHINE<.
	label var sewingmachine "Household has Sewing machine"
	la de lblsewingmachine 0 "No" 1 "Yes"
	label val sewingmachine lblsewingmachine
*</_sewingmachine>


** WASHING MACHINE
*<_washingmachine_>
	gen washingmachine= numbitWASHING_MACHINE>0 if  numbitWASHING_MACHINE<.
	label var washingmachine "Household has Washing machine"
	la de lblwashingmachine 0 "No" 1 "Yes"
	label val washingmachine lblwashingmachine
*</_washingmachine>*/


/** LAMP
*<_lamp_>
	gen lamp=.
	label var lamp "Household has Lamp"
	la de lbllamp 0 "No" 1 "Yes"
	label val lamp lbllamp
*</_lamp>*/


/** COW
*<_cow_>
	gen cow=.
	label var cow "Household has Cow"
	la de lblcow 0 "No" 1 "Yes"
	label val cow lblcow
*</_cow>


** BUFFALO
*<_buffalo_>
	gen buffalo=.
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
	*/
	
	
	
	

/*****************************************************************************************************
*                                                                                                    *
                                   EDUCATION MODULE
*                                                                                                    *
*****************************************************************************************************/


** EDUCATION MODULE AGE
*<_ed_mod_age_>
	gen byte ed_mod_age=5
	label var ed_mod_age "Education module application age"
	note ed_mod_age: ed_mod_age = 5
*<_ed_mod_age_>
	

** CURRENTLY AT SCHOOL
*<_atschool_>
	gen byte atschool=Q422
	recode atschool (1=1)(2 9 =0)
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool
	note atschool: Are you currently studying?
*<_atschool_>

	
** CAN READ AND WRITE
*<_literacy_>
	gen byte literacy=Q417
	recode literacy (1=1)(2 9 =0)
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
	note literacy: Can you read and write in your mother tongue? 95% Yes
*<_literacy_>
	

** YEARS OF EDUCATION COMPLETED
*<_educy_>
	gen byte educy=Q421
	replace educy=. if educy>30
	label var educy "Years of education"
	note educy: How many years spent in school
*<_educy_>

	
/** EDUCATIONAL LEVEL 7 CATEGORIES
*<_educat7_>
	gen byte educat7=Q424
	recode educat7 (1 2=3) (6/11=4) (12=5) (14 16 17 =6) (13 15=7)
	replace educat7=1 if educy==0
	label define lbleducat7 1 "No education" 2 "Primary incomplete" 3 "Primary complete" ///
	4 "Secondary incomplete" 5 "Secondary complete" 6 "Higher than secondary but not university" /// 
	7 "University incomplete or complete" 8 "Other" 9 "Not classified"
	label values educat7 lbleducat7
	la var educat7 "Level of education 7 categories"
	note educat7: educat7
*<_educat7_>
*/


** EDUCATION LEVEL 7 CATEGORIES
*<_educat7_>
	gen byte educat7=educy
	recode educat7 (0=1) (1/4=2) (5=3) (6/11=4) (12=5) (13/22=6)
	replace educat=7 if inrange(Q424,3,7) & educy>12
	label define lbleducat7 1 "No education" 2 "Primary incomplete" 3 "Primary complete" ///
	4 "Secondary incomplete" 5 "Secondary complete" 6 "Higher than secondary but not university" /// 
	7 "University incomplete or complete" 8 "Other" 9 "Not classified"
	label values educat7 lbleducat7
	la var educat7 "Level of education 7 categories"
	note educat7: educat7
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
	note educat5: educat5
*<_educat5_>
	
	
** EDUCATION LEVEL 4 CATEGORIES
*<_educat4_>
	gen byte educat4=educat7
	recode educat4 (1=1) (2/3=2) (4/5=3) (6/7 =4)
	replace educat4=1 if educy==0
	label var educat4 "Level of education 4 categories"
	label define lbleducat4 1 "No education" 2 "Primary (complete or incomplete)" ///
	3 "Secondary (complete or incomplete)" 4 "Tertiary (complete or incomplete)"
	label values educat4 lbleducat4
	note educat4: educat4
*<_educat4_>


** EVER ATTENDED SCHOOL
*<_everattend_>
	gen byte everattend=Q419
	recode everattend (1=1)(2 9 =0)
	label var everattend "Ever attended school"
	la de lbleverattend 0 "No" 1 "Yes"
	label values everattend lbleverattend
	note everattend: Have you ever attender school/ training institution?
	
	replace  educy=0 if everattend==0
	replace  educat4=1 if everattend==0
	replace  educat5=1 if everattend==0
	replace  educat7=1 if everattend==0


	local ed_var "everattend atschool literacy educy educat4 educat5 educat7 "
	foreach v in `ed_var'{
	replace `v'=. if( age<ed_mod_age & age!=.)
	}
	
*<_everattend_>


/*****************************************************************************************************
*                                                                                                    *
                                   MIGRATION
*                                                                                                    *
*****************************************************************************************************/


/*****************************************************************************************************
*                                                                                                    *
                                   LABOR MODULE
*                                                                                                    *
*****************************************************************************************************/


** LABOR MODULE AGE
*<_lb_mod_age_>
	gen byte lb_mod_age=15
	label var lb_mod_age "Labor module application age"
	note lb_mod_age: Employment and Income Module only for > 15 years 
*<_lb_mod_age_>


** LABOR STATUS
*<_lstatus_>
* compare to emp_status
	gen byte lstatus=3
	replace lstatus=1 if Q509==1
	replace lstatus=2 if Q519==1
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
	note lstatus: Employed if worked even for an hour, unemployed if searched for a job in the last month
*<_lstatus_>


** REASONS NOT IN THE LABOR FORCE
*<_nlfreason_>
	gen nlfreason=Q526
	recode nlfreason (1=1)(3 4=2)(10 11=3)(9 12=4)(2 5 6 7 8 13 14 99=5)
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housewife" 3 "Retired" 4 "Disabled" 5 "Other"
	label values nlfreason lblnlfreason
*<_nlfreason_>


**ORIGINAL INDUSTRY CLASSIFICATION
*<_industry_orig_>
	rename Q602 industry_orig
*<_industry_orig_>


**ORIGINAL INDUSTRY CLASSIFICATION
*<_industry_orig_2_>
	rename Q628 industry_orig_2
*<_industry_orig_>


** HOURS WORKED LAST WEEK
*<_whours_>
	gen whours=Q606*Q607 
	replace whours=. if lstatus==2 | lstatus==3
	label var whours "Hours of work in last week"
*</_whours_>


** EMPLOYMENT STATUS
*<_empstat_>
	gen empstat= Q610 
	recode empstat (1=1) (2=3) (3 4 5 6= 4) (9=.)
	replace empstat=. if lstatus==2 | lstatus==3
	label var empstat "Employment status"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other"
	label values empstat lblempstat
*</_empstat_>


** EMPLOYMENT STATUS
*<_empstat_2_>
	gen empstat_2= Q636 
	recode empstat_2 (1=1) (2=3) (3 4 5 6= 4) (9=.)
	replace empstat_2=. if lstatus==2 | lstatus==3
	label var empstat_2 "Employment status"
	la de lblempstat2 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other"
	label values empstat_2 lblempstat2
*</_empstat_>


** CONTRACT
*<_contract_>
	gen byte contract=Q618
	recode contract (1=1)(2/4=0)(9=.)
	label var contract "Contract"
	la de lblcontract 0 "Without contract" 1 "With contract"
	label values contract lblcontract
*</_contract_>


** WAGES
*<_wage_>
	gen double wage=Q6251Amount
	replace wage=. if lstatus==2 | lstatus==3
	replace wage=0 if empstat==2
	label var wage "Last wage payment"
*</_wage_>


** WAGES TIME UNIT
*<_unitwage_>
	gen byte unitwage=5
	label var unitwage "Last wages time unit"
	replace unitwage=. if lstatus==2 | lstatus==3
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Quarterly" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage lblunitwage
*</_wageunit_>



** HEALTH INSURANCE
	gen byte healthins=Q623
	recode healthins (1=1) (2=0) (3/9=.)
	label var healthins "Health insurance"
	la de lblhealthins 0 "Without health insurance" 1 "With health insurance"
	label values healthins lblhealthins


** SOCIAL SECURITY
	gen byte socialsec=Q621
	recode socialsec (1=1) (2=0) (3/9=.)
	label var socialsec "Social security"
	la de lblsocialsec 1 "With" 0 "Without"
	label values socialsec lblsocialsec


/** NUMBER OF ADDITIONAL JOBS
	recode otherjob (2=0), gen(njobs)
	label var njobs "Number of additional jobs"


** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
	recode typeofjob (1 2 5 6 = 1) (3 4 7 0 =2) (8=.), gen(ocusec)
	replace ocusec=. if lstatus==2 | lstatus==3
	label var ocusec "Sector of activity"
	la de lblocusec 1 "Public, state owned, government, army, NGO" 2 "Private"
	label values ocusec lblocusec


** UNEMPLOYMENT DURATION: MONTHS LOOKING FOR A JOB
	gen byte unempldur_l=.
	label var unempldur_l "Unemployment duration (months) lower bracket"
	gen byte unempldur_u=.
	label var unempldur_u "Unemployment duration (months) upper bracket"


** INDUSTRY CLASSIFICATION

	replace industry="" if industry=="Q17" | industry=="Q18" | industry=="Q19"
	destring industry, replace
	replace industry=int(industry/100)
	recode industry (0=10) (1/5=1) (10/14=2) (15/37=3) (40/41=4) (45=5) (50/55=6) (60/64=7) (65/74=8) (75=9) (80/99=10)
	label var industry "1 digit industry classification"
	replace industry=. if lstatus==2 | lstatus==3
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transports and comnunications" 8 "Financial and business-oriented services" 9 "Public Administration" 10 "Other services, Unspecified"
	label values industry lblindustry


** OCCUPATION CLASSIFICATION
	replace occupation="" if occupation=="Q17" | occupation=="Q18" | occupation=="Q19"
	destring occupation, replace
	gen byte occup=int(occupation/100)
	recode occup (0/10=10) (11/19=1) (21/29=2) (31/39=3) (41/49=4) (51/59=5) (61/69=6) (71/79=7) (81/89=8) (91/99=9)
	label var occup "1 digit occupational classification"
	replace occup=. if lstatus==2 | lstatus==3
	la de lbloccup 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup lbloccup


** FIRM SIZE
	gen byte firmsize_l=.
	label var firmsize_l "Firm size (lower bracket)"

	gen byte firmsize_u=.
	label var firmsize_u "Firm size (upper bracket)"


** UNION MEMBERSHIP
	gen byte union=.
	label var union "Union membership"
	la de lblunion 0 "No member" 1 "Member"
	label values union lblunion

	local lb_var "lstatus empstat njobs ocusec nlfreason unempldur_l unempldur_u industry occup firmsize_l firmsize_u whours wage unitwage contract healthins socialsec union"
	foreach v in `lb_var'{
	di "check `v' only for age>=lb_mod_age"

	replace `v'=. if( age<lb_mod_age & age!=.)
	}

*/
/*****************************************************************************************************
*                                                                                                    *
                                   WELFARE MODULE
*                                                                                                    *
*****************************************************************************************************/


** WELFARE 
*<_welfare_>
	gen welfare=pce_ts/12
	label var welfare "Per capita expenditure - temp and spatial def (MVR/person/month)"
*<_welfare_>


** WELFARE TYPE
*<_welfaretype_>
	gen welfaretype="EXP"
	la var welfaretype "Type of welfare measure (income, consumption or expenditure) for welfare, welfarenom, welfaredef"
	*<_welfaretype_>
	

/*****************************************************************************************************
*                                                                                                    *
                                   NATIONAL POVERTY
*                                                                                                    *
*****************************************************************************************************/


** POVERTY LINE (NATIONAL)
*<_pline_nat_>
	gen pline_nat = rpl_2 /12
	label var pline_nat "Poverty Line (National)"
*<_pline_nat_>


** HEADCOUNT RATIO (NATIONAL)
*<_poor_nat_>
	gen poor_nat=(welfare<pline_nat) if welfare!=.
	label var poor_nat "Headcount (National)"
	la define lblpoor_nat 0 "Not-Poor" 1 "Poor"
	la values poor_nat lblpoor_nat
*<_poor_nat_>

	
/*****************************************************************************************************
*                                                                                                    *
                                   INTERNATIONAL POVERTY
*                                                                                                    *
*****************************************************************************************************/
	
	
** POVERTY LINE	
*<_pline_int_>	
	gen pline_int=umicpl/5.50*1.90/12
	label variable pline_int "Poverty Line 1.90"
*<_pline_int_>	


** HEADCOUNT RATIO
*<_poor_int_>	
	gen poor_int=welfare<pline_int & welfare!=.
	la var poor_int "People below Poverty Line (Povcalnet)"
	la define poor_int 0 "Not Poor" 1 "Poor"
	la values poor_int poor_int
*<_poor_int_>	

	
** PPP VARIABLE
*<_ppp_>
	gen ppp=10.67605
	label var ppp "PPP 2011"
*<_ppp_>


** CPI VARIABLE
*<_cpi_>
	*gen cpi=1.192638
	gen cpi=1.192615
*<_cpi_>


** CPI VARIABLE
*<_cpiperiod_>
	*gen cpiperiod=.
*<_cpiperiod_>


/*
gen welf_ppp=welfare/cpi/ppp/365
gen poor=(welf_ppp<1.90) if welf_ppp!=.
sum poor [aw=wgt]
*/
/*****************************************************************************************************
*                                                                                                    *
                                   FINAL STEPS
*                                                                                                    *
*****************************************************************************************************/


** KEEP VARIABLES - ALL
do "$fixlabels\fixlabels", nostop 

keep countrycode year survey int_year int_month idh idp wgt pop_wgt strata psu vermast veralt  ///
	hsize age male relationharm relationcs marital soc ///
	urban subnatid1 subnatid2 gaul_adm1_code ownhouse electricity sewage_toilet toilet_jmp toilet_orig sar_improved_toilet sar_improved_water piped_water water_jmp water_orig /// /* internet */ 
	imp_san_rec imp_wat_rec pipedwater_acc sanitation_original sanitation_source toilet_acc water_original water_source watertype_quest ///
	landphone cellphone motorcycle bicycle motorcar computer radio refrigerator television fan ///
	ed_mod_age atschool literacy educy educat7 educat5 educat4 everattend ///
	lb_mod_age lstatus nlfreason whours empstat empstat_2 contract wage unitwage healthins socialsec industry_orig industry_orig_2 /// /* spdef */ 
	welfare welfaretype poor_nat pline_nat pline_int poor_int ppp cpi /* welfarenom welfaredef welfareother welfaretype welfareothertype */
	
** ORDER VARIABLES

order countrycode year survey int_year int_month idh idp wgt pop_wgt strata psu vermast veralt  ///
	hsize age male relationharm relationcs marital soc ///
	urban subnatid1 subnatid2 gaul_adm1_code ownhouse electricity sewage_toilet toilet_jmp toilet_orig sar_improved_toilet sar_improved_water piped_water water_jmp water_orig /// /* internet */ 
	imp_san_rec imp_wat_rec pipedwater_acc sanitation_original sanitation_source toilet_acc water_original water_source watertype_quest ///
	landphone cellphone motorcycle bicycle motorcar computer radio refrigerator television fan ///
	ed_mod_age atschool literacy educy educat7 educat5 educat4 everattend ///
	lb_mod_age lstatus nlfreason whours empstat empstat_2 contract wage unitwage healthins socialsec industry_orig industry_orig_2 /// /* spdef */ 
	welfare welfaretype poor_nat pline_nat pline_int poor_int ppp cpi /* welfarenom welfaredef welfareother welfaretype welfareothertype */
	
	compress

	
/** DELETE MISSING VARIABLES

	local keep ""
	qui levelsof countrycode, local(cty)
	foreach var of varlist urban - welfare {
	qui sum `var'
	scalar sclrc = r(mean)
	if sclrc==. {
	     display as txt "Variable " as result "`var'" as txt " for countrycode " as result `cty' as txt " contains all missing values -" as error " Variable Deleted"
	}
	else {
	     local keep `keep' `var'
	}
	}
	
	foreach w in welfare welfare{
	qui su `w'
	if r(N)==0{
	drop `w'type
}
}
	keep countrycode year idh idp wgt survey strata psu vermast veralt `keep' 
*/
	compress


	saveold "`output'\Data\Harmonized\MDV_2016_HIES_v01_M_v01_A_SARMD_IND.dta", replace version(13)
	saveold "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\MDV_2016_HIES_v01_M_v01_A_SARMD_IND.dta", replace version(13)
	
	
	log close












******************************  END OF DO-FILE  *****************************************************/
