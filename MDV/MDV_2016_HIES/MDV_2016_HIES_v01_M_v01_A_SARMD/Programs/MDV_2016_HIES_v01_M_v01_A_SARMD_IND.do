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
** MODIFIED         07/06/2023 by Adriana Castillo Castillo                                         **
******************************************************************************************************
*****************************************************************************************************/

/*****************************************************************************************************
*                                                                                                    *
                                   INITIAL COMMANDS
*                                                                                                    *
*****************************************************************************************************/


*<_Program setup_>
clear all
set more off
cap log close 

local code         "MDV"
local year         "2016"
local survey       "HIES"
local vm           "01"
local va           "01"
local type         "SARMD"
glo   module       "IND"
local yearfolder   "`code'_`year'_`survey'"
local gmdfolder    "`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD"
local filename     "`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD_${module}"

*</_Program setup_>

** DIRECTORY
	glo pricedata "\\Wbgmsbdat001\SOUTH ASIA MICRO DATABASE\CPI\cpi_ppp_sarmd_weighted.dta"
	glo shares    "\\Wbgmsbdat001\SOUTH ASIA MICRO DATABASE\APPS\DATA CHECK\Food and non-food shares\MDV"
	glo fixlabels "\\Wbgmsbdat001\SOUTH ASIA MICRO DATABASE\APPS\DATA CHECK\Label fixing"

** LOG FILE
	*log using "`output'\Doc\Technical\MDV_2016_HIES_v01_M_v01_A_SARMD.log",replace
	log using "${rootdatalib}\\`code'\\`code'_`year'_`survey'\\`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD\Doc\Technical\\`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD.log", replace 

	
/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/
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
	note countrycode: countrycode=MDV
*<_countrycode_>

clonevar code = countrycode

** YEAR
*<_year_>
	gen int year=`year'
	label var year "Year of survey"
	note year: year=2016
*<_year_>
	
	
** SURVEY
*<_survey_>
	gen survey="`survey'"
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
	
	clonevar idh_org = Form_ID

** INDIVIDUAL IDENTIFICATION NUMBER
*<_idp_>
	egen idp=concat(idh Id), punct(-)
	label var idp "Individual id"
	note idp: idp=Form_ID - Id  26,025 values
*<_idp_>

clonevar idp_org = Id

*<_hhid_>
*<_hhid_note_> Household identifier  *</_hhid_note_>
*<_hhid_note_> hhid brought in from rawdata *</_hhid_note_>
clonevar hhid = idh
*</_hhid_>

*<_pid_>
*<_pid_note_> Personal identifier  *</_pid_note_>
*<_pid_note_> pid brought in from rawdata *</_pid_note_>
clonevar pid = idp
*</_pid_>

	
** HOUSEHOLD WEIGHTS
*<_wgt_>
	gen double wgt=adj_wgt
	label var wgt "Household sampling weight"
	note wgt: wgt=adj_wgt
*<_wgt_>

clonevar weight = wgt 
	
clonevar finalweight=wgt 
	
** POPULATION WEIGHT
*<_pop_wgt_>
	gen pop_wgt=wgt*hhsize
	la var pop_wgt "Population weight"
	note pop_wgt: pop_wgt=adj_wgt*hhsize
*<_pop_wgt_>

gen weighttype="PW"

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
	gen vermast="`vm'"
	label var vermast "Master Version"
	note vermast: vermast=01
*<_vermast_>
	
	
** ALTERATION VERSION
*<_veralt_>
	gen veralt="`va'"
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

gen rbirth_juris=.
gen rbirth=.
gen rprevious_juris=.
gen rprevious=.
gen yrmove=.


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
	

** REGIONAL AREA 2 DIGIT ADMN LEVEL
*<_subnatid2_>
	gen subnatid2 = Atoll_Island
*<_subnatid2_>
	
	
* REGIONAL AREA 2 DIGIT ADMN LEVEL
	gen subnatid3= ""
	note subnatid3: subnatid3 = .

** HOUSE OWNERSHIP
*<_ownhouse_>
	gen ownhouse=ownedbyhhmember
	recode ownhouse (1 2=1) (3 4=0) (9=.) 
	label var ownhouse "House ownership"
	la de lblownhouse 0 "No" 1 "Yes"
	label values ownhouse lblownhouse
	note ownhouse: ownhouse= Yes if owned by a member of this hh/own place or owned by a relative not living here. No if arranged by the employer or other 
*<_ownhouse_>
	
clonevar typehouse = ownhouse

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

	cap gen  improved_sanitation=sar_improved_toilet
	
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

	cap gen improved_water=sar_improved_water

*<_sanitation_original_>
	clonevar sanitation_original=typeseweragesystem
	label define lblsanitation_original 1 "1 - Toilet connected to sewerage system" 2 "2 - Toilet connected to sea" 3 "3 - Toilet connected to septic tank" 4 "4 - Gifili (without toilet bowls)" 
	label values sanitation_original lblsanitation_original
	label var sanitation_original "Original survey response in string for sanitation_source variable"
	note sanitation_original: Question 14. What type of sewerage system is in this housing unit? 1. Toilet connected to sewerage system; 2. Toilet connected to sea; 3. Toilet connected to septic tank; 4. Gifili (without toilet bowls)
*</_sanitation_original_>

*<_water_original_>
	clonevar water_original=drinkingwatersource
	label var water_original "Original survey response in string for water_source variable"
	note water_original: Question 19. What is the main source of drinking water used by most of the occupants of this household?
*</_water_original_>

*<_watertype_quest_>
	gen watertype_quest=3
	label var watertype_quest "Type of water questions used in the survey"
	note watertype_quest:
*</_watertype_quest_>


/*****************************************************************************************************
*                                                                                                    *
                                            ASSETS 
*                                                                                                    *
*****************************************************************************************************/

** LAND PHONE
*<_landphone_>
	gen byte lphone=access_Telephone
	note lphone: lphone only 3%
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
	

* SEWING MACHINE
*<_sewingmachine_>
	gen sewingmachine= .
	label var sewingmachine "Household has Sewing machine"
	la de lblsewingmachine 0 "No" 1 "Yes"
	label val sewingmachine lblsewingmachine
*</_sewingmachine>


** WASHING MACHINE
*<_washingmachine_>
	gen washingmachine= access_Washing_machine>0 if  access_Washing_machine!=.
	label var washingmachine "Household has Washing machine"
	la de lblwashingmachine 0 "No" 1 "Yes"
	label val washingmachine lblwashingmachine
*</_washingmachine>*/


* LAMP
*<_lamp_>
	gen lamp=.
	label var lamp "Household has Lamp"
	la de lbllamp 0 "No" 1 "Yes"
	label val lamp lbllamp
*</_lamp>*/


* COW
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
	
	
	gen internet=.
	

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
	ren Q509 activity
	ren Q519 searchforjob
	ren Q525 availability
	gen byte lstatus=1 if activity==1
	replace lstatus=2 if activity==2 & searchforjob==1
	replace lstatus=3 if activity==2 & searchforjob==2
	replace lstatus=3 if availability==2 & lstatus!=1
	*gen byte lstatus=3
	*replace lstatus=1 if Q509==1
	*replace lstatus=2 if Q519==1
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

gen empstat_year=.

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

gen unitwage_2=.

gen wage_2=. 

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

gen empstat_2_year=.

* NUMBER OF ADDITIONAL JOBS
	gen njobs=.
	replace njobs = 2 if Q626 == 1
	replace njobs = 3 if Q652 == 1 
	label var njobs "Number of additional jobs"


** FIRM SIZE
	gen byte firmsize_l=.
	label var firmsize_l "Firm size (lower bracket)"

	gen byte firmsize_u=.
	label var firmsize_u "Firm size (upper bracket)"
	
	
	gen industry=.
	
	gen industry_2=. 
	
	gen occup = . 
	
	gen ocusec = .
	replace ocusec = 1 if inlist(industry_orig, 1, 2, 4, 5)
	replace ocusec = 2 if inlist(industry_orig, 3, 6, 7, 9, 10)
	replace ocusec = 3 if industry_orig == 8
	
	
	*<_unempldur_l_>;
*<_unempldur_l_note_> Unemployment duration (months) lower bracket *</_unempldur_l_note_>;
*<_unempldur_l_note_> unempldur_l brought in from rawdata *</_unempldur_l_note_>;
gen unempldur_l=.
replace unempldur_l = 0 if Q521 == 1
replace unempldur_l = 1 if Q521 == 2
replace unempldur_l = 6 if Q521 == 3
replace unempldur_l = 12 if Q521 == 4
replace unempldur_l = 24 if Q521 == 5
replace unempldur_l = . if lstatus != 2
*</_unempldur_l_>;

*<_unempldur_u_>;
*<_unempldur_u_note_> Unemployment duration (months) upper bracket *</_unempldur_u_note_>;
*<_unempldur_u_note_> unempldur_u brought in from rawdata *</_unempldur_u_note_>;
gen unempldur_u=.
replace unempldur_u = 1 if Q521 == 1
replace unempldur_u = 6 if Q521 == 2
replace unempldur_u = 12 if Q521 == 3
replace unempldur_u = 24 if Q521 == 4
replace unempldur_u = . if Q521 == 5
replace unempldur_u = . if lstatus != 2
*</_unempldur_u_>;

** UNION MEMBERSHIP
	gen byte union=.
	label var union "Union membership"
	la de lblunion 0 "No member" 1 "Member"
	label values union lblunion
	
	
/** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
	recode typeofjob (1 2 5 6 = 1) (3 4 7 0 =2) (8=.), gen(ocusec)
	replace ocusec=. if lstatus==2 | lstatus==3
	label var ocusec "Sector of activity"
	la de lblocusec 1 "Public, state owned, government, army, NGO" 2 "Private"
	label values ocusec lblocusec



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

*<_spdef_>
*<_spdef_note_> Spatial deflator (if one is used) *</_spdef_note_>
*<_spdef_note_> spdef brought in from rawdata *</_spdef_note_>
gen spdef=. 
*</_spdef_>

** WELFARE 
*<_welfare_>
	gen welfare=pce_ts/12
	label var welfare "Per capita expenditure - temp and spatial def (MVR/person/month)"
*<_welfare_>

*<_welfaredef_>;
*<_welfaredef_note_> Welfare aggregate spatially deflated *</_welfaredef_note_>;
*<_welfaredef_note_> welfaredef brought in from SARMD *</_welfaredef_note_>;
gen welfaredef=welfare
*</_welfaredef_>;

*<_welfarenom_>;
*<_welfarenom_note_> Welfare aggregate in nominal terms *</_welfarenom_note_>;
*<_welfarenom_note_> welfarenom brought in from SARMD *</_welfarenom_note_>;
gen welfarenom=.
*</_welfarenom_>;

*<_welfareother_>;
*<_welfareother_note_> Welfare aggregate if different welfare type is used from welfare, welfarenom, welfaredef *</_welfareother_note_>;
*<_welfareother_note_> welfareother brought in from SARMD *</_welfareother_note_>;
gen welfareother=.
*</_welfareother_>;

*<_welfareothertype_>;
*<_welfareothertype_note_> Type of welfare measure (income, consumption or expenditure) for welfareother *</_welfareothertype_note_>;
*<_welfareothertype_note_> welfareothertype brought in from SARMD *</_welfareothertype_note_>;
gen welfareothertype=.
*</_welfareothertype_>;

*<_welfshprosperity_>;
*<_welfshprosperity_note_> Welfare aggregate for shared prosperity (if different from poverty) *</_welfshprosperity_note_>;
*<_welfshprosperity_note_> welfshprosperity brought in from SARMD *</_welfshprosperity_note_>;
gen welfshprosperity=welfare
*</_welfshprosperity_>;

gen welfarenat=.

** WELFARE TYPE
*<_welfaretype_>
	gen welfaretype="EXP"
	la var welfaretype "Type of welfare measure (income, consumption or expenditure) for welfare, welfarenom, welfaredef"
	*<_welfaretype_>
	
	*<_welfshprtype_>;
*<_welfshprtype_note_> Welfare type for shared prosperity indicator (income, consumption or expenditure) *</_welfshprtype_note_>;
*<_welfshprtype_note_> welfshprtype brought in from SARMD *</_welfshprtype_note_>;
clonevar welfshprtype=welfaretype
*</_welfshprtype_>;


	gen food_share=(food_ts/(food_ts+nonfood_ts))*100
	
	gen nfood_share = 100-food_share
	
	*<_quintile_cons_aggregate_>
*<_quintile_cons_aggregate_note_> Quintile of welfarenat *</_quintile_cons_aggregate_note_>
/*<_quintile_cons_aggregate_note_>  *</_quintile_cons_aggregate_note_>*/
*<_quintile_cons_aggregate_note_>  *</_quintile_cons_aggregate_note_>
*gen quintile_cons_aggregate = .a //change
_ebin welfare [aw=weight], gen(quintile_cons_aggregate) nq(5) 
*</_quintile_cons_aggregate_>

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
	gen cpiperiod=2016
*<_cpiperiod_>


/*
gen welf_ppp=welfare/cpi/ppp/365
gen poor=(welf_ppp<1.90) if welf_ppp!=.
sum poor [aw=wgt]
*/

local vars_ "shared_toilet industry_year industry_2_year industry_orig_year industry_orig_2_year occup_2 occup_year ocusec_year subnatid4 subnatid1_sar subnatid2_sar subnatid3_sar subnatid4_sar"
foreach v of local vars_ {
	gen `v'=.
}


/*****************************************************************************************************
*                                                                                                    *
                                   FINAL STEPS
*                                                                                                    *
*****************************************************************************************************/
*<_Keep variables_>
order countrycode year hhid pid weight weighttype 
sort  hhid pid
*</_Keep variables_>

*<_Save data file_>
do   "P:\SARMD\SARDATABANK\SARMDdofiles\_aux\Labels_SARMD.do"
*do   "$rootdatalib\\`code'\\`yearfolder'\\`SARMDfolder'\Programs\Labels_SARMD.do"
save "$rootdatalib\\`code'\\`yearfolder'\\`gmdfolder'\Data\Harmonized\\`filename'.dta" , replace
*</_Save data file_>

******************************  END OF DO-FILE  *****************************************************/
