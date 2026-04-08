/*----------------------------------------------------------------------------------
  GMD Harmonization - Pakistan Social and Living Standards Measurement Survey (PSLM)
------------------------------------------------------------------------------------
<_Program name_>   	PAK_2018_HIES_v02_M_v01_A_SAMRD_IND.do	       </_Program name_>
<_Application_>    	STATA 17.0									     <_Application_>
<_Author(s)_>      	Adriana Castillo Castillo           		      </_Author(s)_>
<_Modified_by_>     Leo Tornarolli <tornarolli@gmail.com>		    </_Modified_by_>
<_Date created_>   	12-2021								           </_Date created_>
<_Date modified>   	04-2025						                  </_Date modified_>
------------------------------------------------------------------------------------
<_Country_>        	PAK											        </_Country_>
<_Survey Title_>   	HIES								           </_Survey Title_>
<_Survey Year_>    	2018										    </_Survey Year_>
------------------------------------------------------------------------------------
<_Version Control_>
Date:				04-2025
File:				PAK_2018_HIES_v02_M_v01_A_SAMRD_IND.do
First version
</_Version Control_>
----------------------------------------------------------------------------------*/

*<_Program setup_>
clear all
set more off

local code         		"PAK"
local cpiver       		"10"
local year         		"2018"
local survey       		"HIES"
local vm           		"02"
local va          		"01"
local type         		"SARMD"
global module       		"IND"
local yearfolder    		"`code'_`year'_`survey'"
local SARMDfolder    		"`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'"
local filename      		"`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'_${module}"
global output       		"${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\\Data\Harmonized" 
global shares    		"$rootdofiles\_aux\"
global support           "${rootdatalib}\\_CPIs"
*</_Program setup_>

*<_Datalibweb request_>
use   "${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata\\`yearfolder'_v`vm'_M.dta", clear
sort  hhcode idc
merge 1:1 hhcode idc using "${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\Data\Harmonized\\`yearfolder'_v`vm'_M_v`va'_A_`type'_INC.dta"
*</_Datalibweb request_>

	
/*****************************************************************************************************
* STANDARD SURVEY MODULE
*****************************************************************************************************/

*<_countrycode_>
*</_countrycode_>

*<_year_>
*</_year_>*/

*<_survey_>
gen str survey = "`survey'"
*</_survey_>

*<_int_year_> 
gen int_year = enum_year
*</_int_year_>

*<_int_month_> 
gen int_month = enum_month
label define lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
label value int_month lblint_month
capture gen month = int_month
*</_int_month_>

*<_fieldwork_> 
gen fieldwork = ym(int_year,int_month)
format %tm fieldwork
la var fieldwork "Date of fieldwork"
*<_/fieldwork_> 

*<_idh_>
gen idh_org = hhcode
*</_idh_>

*<_idp_>
gen idp_org = idc
*</_idp_>

*<_wgt_>
*</_wgt_>

*<_weight_>
*<_weight_note_> Household weight *</_weight_note_>
*<_weight_note_> weight brought in from rawdata *</_weight_note_>
*</_weight_>

*<_strata_>
*</_strata_>

*<_psu_>
*</_psu_>

*<_vermast_>
gen vermast = "`vm'"
*</_vermast_>
	
*<_veralt_>
gen veralt = "`va'"
*</_veralt_>	


/*****************************************************************************************************
* HOUSEHOLD CHARACTERISTICS MODULE                                                                                                   *
*****************************************************************************************************/

cap gen code = countrycode

*<_urban_>
gen byte urban = region
recode urban (2=1)(1=0)
*</_urban_>

*<_subnatid1_>
gen 	subnatid1 = "1 - Punjab" 			if  province==2
replace subnatid1 = "2 - Sindh"  			if  province==3
replace subnatid1 = "3 - Khyber Pakhtunkhwa" if  province==1
replace subnatid1 = "4 - Balochistan" 		if  province==4
*</_subnatid1_>

*<_subnatid2_>
gen subnatid2 = "."

*<_subnatid3_>
gen subnatid3 = "."
*</_subnatid3_>

*<_subnatid_sar_>
decode province, gen(subnatid1_sar)
gen subnatid2_sar = ""
gen subnatid3_sar = ""
gen subnatid4_sar = ""
*<_subnatid_sar_>

*<_gaul_adm1_code_>
gen 	gaul_adm1_code = .
replace gaul_adm1_code = 2019 	if  subnatid1=="1 - Punjab"
replace gaul_adm1_code = 2020 	if  subnatid1=="2 - Sindh" 
replace gaul_adm1_code = 2016 	if  subnatid1=="3 - Khyber Pakhtunkhwa"
replace gaul_adm1_code = 2015 	if  subnatid1=="4 - Balochistan" 
*<_gaul_adm1_code_>

*<_ownhouse_>
recode s5aq01 (1/2 = 1) (3/4 = 2) (5 = 3) (* = .), gen(ownhouse)
*</_ownhouse_>

*<_typehouse_>
recode s5aq01 (1/2 = 1) (3/4 = 2) (5 = 3) (* = .), gen(typehouse)
*</_typehouse_>

*<_tenure_>
gen 	tenure = .
replace tenure = 1 			if  s5aq01==1 | s5aq01==2
replace tenure = 2 			if  s5aq01==3
replace tenure = 3 			if  s5aq01==4 | s5aq01==5 
*</_tenure_>	

*<_lanholding_>
gen     landholding = 0		if  s9aq01_901==2 | s9aq01_902==2 
replace landholding = 1		if  s9aq01_901==1 | s9aq01_902==1 
notes landholding: "PAK 2018" this variable was generated if household owns at least one acre of agricultural or non-agricultural land
*</_landholding_>	

*<_water_original_>
clonevar j = s5aq11
label define lblwater_original 1 "Piped water" 2 "Hand pump" 3 "Bore Hole (Motor Pump)/Tube Well" 4 "Closed well" 5 "Open well" 6 "Protected Spring" 7 "Unprotected Spring" 8 "Piped Water/Public Tap/Standpipe (outside)" 9 "Hand pump (outside)" 10 "Motorized pumping/Tube well (outside)" 11 "Open well (outside)" 12 "Closed well (outside)" 13 "Spring (protected) (outside)" 14 "Spring (Unprotected) (outside)" 15 "Pond/Canal/River/Stream (outside)" 16 "Bottled (outside)" 17 "Tanker/Truck/water bearer (outside)" 18 "Filtration Plant (outside)" 19 "Others (outside)"
la val j lblwater_original		
decode j, gen(water_original)
drop j
*</_water_original_>

*<_water_source_>
gen 	water_source = s5aq11
replace water_source = 1  	if  s5aq11==1
replace water_source = 4   	if  s5aq11==2 | s5aq11==9 | s5aq11==3 | s5aq11==10
replace water_source = 5   	if  s5aq11==4 | s5aq11==12 | s5aq11==18
replace water_source = 6   	if  s5aq11==6 | s5aq11==13
replace water_source = 7   	if  s5aq11==16
replace water_source = 9   	if  s5aq11==7 | s5aq11==14
replace water_source = 10  	if  s5aq11==5 | s5aq11==11
replace water_source = 12  	if  s5aq11==17
replace water_source = 13  	if  s5aq11==15
replace water_source = 14  	if  s5aq11==8 | s5aq11==19
*</_water_source_>

*<_improved_water_>
gen 	improved_water = .
replace improved_water = 1 	if  inlist(water_source,1,2,3,4,5,6,7,12)
replace improved_water = 0 	if  inlist(water_source,8,9,10,11,13,14) // Asuming other is not improved water source
/* WASH team: Replace tanker as improved */
replace improved_water = 1 	if  s5aq11==17
*</_improved_water_>

*<_pipedwater_acc_>
gen 	pipedwater_acc = 0 	if  s5aq11!=1 & s5aq11!=8 // Asuming other is not piped water
replace pipedwater_acc = 1 	if  s5aq11==1
replace pipedwater_acc = 2 	if  s5aq11==8
*</_pipedwater_acc_>

*<_watertype_quest_>
gen watertype_quest = 1
*</_watertype_quest_>

*<_piped_water_>
gen piped_water = (inlist(s5aq11,1,8)) 	if inrange(s5aq11,1,19)
*</_piped_water_>

*<_water_jmp_>
gen 	water_jmp = .
replace water_jmp = 1 		if  inlist(s5aq11,1)
replace water_jmp = 4 		if  inlist(s5aq11,2,3,9,10)
replace water_jmp = 5 		if  inlist(s5aq11,4,12,18)
replace water_jmp = 6 		if  inlist(s5aq11,5,11)
replace water_jmp = 7 		if  inlist(s5aq11,6)
replace water_jmp = 8 		if  inlist(s5aq11,7)
replace water_jmp = 10 		if  inlist(s5aq11,17)
replace water_jmp = 12 		if  inlist(s5aq11,15)
replace water_jmp = 13 		if  inlist(s5aq11,16)
replace water_jmp = 14 		if  inlist(s5aq11,8,13,14,19)
*</_water_jmp_>
 
*<_sar_improved_water_>
gen 	sar_improved_water = .
replace sar_improved_water = 1 	if  inlist(water_jmp,1,2,3,4,5,7,9,10,13)
replace sar_improved_water = 0 	if  inlist(water_jmp,6,8,11,12,14)
*</_sar_improved_water_>

*<_electricity_>
gen 	electricity = .
replace electricity = 1 			if  s5aq08==5 | s5aq09==2 | s5aq10==1
replace electricity = 0 			if  s5aq08!=5 & s5aq09!=2 & s5aq10!=1
note electricity: For PAK_2018_HIES this variable is generated if from fuel for cooking, lighting and heating.
*</_electricity_>

*<_toilet_orig_>
gen toilet_orig = s5aq21
label define lbltoilet_orig 1 "No Toilet" 2 "Flush connected to public sewerage" 3 "Flush connected to septic tank" 4 "Flush connected to pit" 5 "Flush connected to open drain" 6 "Dry raised latrine" 7 "Dry pit latrine" 8 "Composting toilet" 9 "Other (specify)"
label values toilet_orig lbltoilet_orig
*</_toilet_orig_>

*<_sewage_toilet_>
recode s5aq21 (1 3/9=0) (2=1), gen(sewage_toilet)
*</_sewage_toilet_>

*<_toilet_jmp_>
gen 	toilet_jmp = .
replace toilet_jmp = 1 			if  toilet_orig==2
replace toilet_jmp = 2 			if  toilet_orig==3
replace toilet_jmp = 3 			if  toilet_orig==4
replace toilet_jmp = 4 			if  toilet_orig==5
replace toilet_jmp = 8 			if  toilet_orig==7
replace toilet_jmp = 9 			if  toilet_orig==8
replace toilet_jmp = 12 			if  toilet_orig==1
replace toilet_jmp = 13 			if  inlist(toilet_orig,6,9)
*</_toilet_jmp_>

*<_sar_improved_toilet_>
gen 	sar_improved_toilet = .
replace sar_improved_toilet = 1 	if  inlist(toilet_jmp,1,2,3,6,7,9)
replace sar_improved_toilet = 0 	if  inlist(toilet_jmp,4,5,8,10,11,12,13)
*</_sar_improved_toilet_>

*<_sanitation_original_>
clonevar j = s5aq21
label define lblsanitation_original 1 "No Toilet" 2 "Flush connected to public sewerage" 3 "Flush connected to septic tank" 4 "Flush connected to pit" 5 "Flush connected to open drain" 6 "Dry raised latrine" 7 "Dry pit latrine" 8 "Composting toilet" 9 "Other (specify)"
label values j lblsanitation_original
decode j, gen(sanitation_original)
drop j
*</_sanitation_original_>

*<_sanitation_source_>
gen 	sanitation_source = .
replace sanitation_source = 2 		if  s5aq21==2
replace sanitation_source = 3 		if  s5aq21==3
replace sanitation_source = 4 		if  s5aq21==4
replace sanitation_source = 13 		if  s5aq21==6
replace sanitation_source = 10 		if  s5aq21==7
replace sanitation_source = 7 		if  s5aq21==8
replace sanitation_source = 9 		if  s5aq21==5
replace sanitation_source = 13 		if  s5aq21==1
replace sanitation_source = 14 		if  s5aq21==9
*</_sanitation_source_>

*<_improved_sanitation_>
gen 	improved_sanitation = .
replace improved_sanitation = 1 		if  inlist(sanitation_source,1,2,3,4,5,6,7,8)
replace improved_sanitation = 0 		if  inlist(sanitation_source,9,10,11,12,13,14)
*</_improved_sanitation_>
	
*<_toilet_acc_>
recode s5aq21 (2/5 = 3) (1 6/9 = 0), gen(toilet_acc)
*</_toilet_acc_>
	
*<_internet_>
gen byte internet = 1 		if  s5aq30_1a==1
replace internet = 0 		if  s5aq30_1a==2
*</_internet_>

	
/*****************************************************************************************************
* DEMOGRAPHIC MODULE
*****************************************************************************************************/

*<_hsize_>
gen byte hsize = hhsizeM 
gen n = 1 		if  s1aq02>=1 & s1aq02<=12
bys hhcode: egen hsize_p = total(n)
drop n
*</_hsize_>

*<_pop_wgt_>
gen pop_wgt = wgt*hsize
*</_pop_wgt_>

*<_relationharm_>
gen byte relationharm=s1aq02
recode relationharm (4 6 7 8 9 10 11 12 = 5) (5 = 4) (13 14 = 6)
ge z = 1 				if  s1aq02==1
bys idh: egen y = sum(z)
replace relationharm = 1 	if  idc==51 & y==0
*</_relationharm_>

*<_relationcs_>
gen byte relationcs = s1aq02
label define lblrelationcs 1 "Head" 2 "Spouse" 3 "Son/Daughter" 4 "Grandchild" 5 "Father/Mother" 6 "Brother/Sister" 7 "Nephew/Niece" 8 "Son/Daughter-in-law" 9 "Brother/Sister-in-law" 10 "Father/Mother-in-law" 11 "Gran Father/Mother" 12 "Real Uncle/Aunty" 13 "Servant/their relatives" 14 "Other"
label values relationcs lblrelationcs
*</_relationcs_>

*<_male_>
gen byte male = s1aq04
recode male (2=0)
*</_male_>

*<_age_>
replace age = 98 			if  age>=98 & age!=.
*</_age_>

*<_soc_>
gen byte soc = .
*</_soc_>

*<_marital_>
gen byte marital = 1 			if  s1aq07==2 | s1aq07==5
replace marital = 2 			if  s1aq07==1
replace marital = 4 			if  s1aq07==4
replace marital = 5 			if  s1aq07==3
*</_marital_>


/*****************************************************************************************************
* EDUCATION MODULE
*****************************************************************************************************/

** EDUCATION MODULE AGE
*<_ed_mod_age_>
gen byte ed_mod_age = 4
*</_ed_mod_age_>

*<_atschool_>
recode s2bq01 (3 = 1) (1 2 = 0), gen(atschool)
*</_atschool_>

*<_literacy_>
gen 	literacy = .
replace literacy = 1 	if  s2aq01==1 & s2aq02==1
replace literacy = 0 	if  s2aq01==2 | s2aq02==2
replace literacy = . 	if  age<ed_mod_age & age!=.
notes literacy: "PAK 2018" literacy questions are only asked to individuals aged 10 and older
*</_literacy_>

**<_educy_>
/*
code		level					years
 25,26,27   pre school              0
	1		class1					1
	2		class2					2
	3		class3					3
	4		class4					4
	5		class5					5
	6		class6					6
	7		class7					7
	8		class8					8
	9		class9					9
	10		class10					10
	11		polytechnic diploma		13
	12		fa/f.sc/icom			12
	13		ba/b.sc/b.com (2 yr)	14
	14  	B.ed/M.ed               14 
	15		ba/b.sc/b.com (4 yr)	16
	16		ma/msc (2 yr)			16
	17  	Degree in medicine      17
	18		degree in agriculture	16
	19		degree in law			16	
	20		degree in engineering	16
	21		degree in accountancy	16
	22		m.phil         			18
	23		Phd         			19
    24  	MS                      18
	28		other					NA */
* Substract 1 year to those currently studying before highschool
recode  s2bq05 (25 26 27 = 0) (11 = 13) (13 = 14) (15 18 19 20 21 = 16) (22 23 24 = 19) (28 = .), gen(educy1)

* Substract 1 year to those currently studying before highschool
gen 	educy2 = s2bq14
replace educy2 = educy2-1 		if  inrange(educy2,1,10)
* Substract 1 year to those currently attending after secondary
recode educy2 (25 26 27 = 0) (12 = 11) (11 = 12) (13 14  = 13) (15 16 18 19 20 21 = 15) (17 = 16) (22 23 24 = 18) 
gen 	educy = educy1 			if  educy1!=. & educy2==.
replace educy = educy2 			if  educy1==. & educy2!=.
replace educy = . 				if  age<ed_mod_age & age!=.
replace educy = . 				if  age<=educy & age!=. & educy!=.
replace educy = 0				if  s2bq14>=25 & s2bq14<=27
replace educy = 0				if  s2bq01==1
*</_educy_>

*<_educat7_>
gen 	educat7 = .
* Attended in the past 
replace educat7 = 1 		if s2bq01==1 | (s2bq05>=25 & s2bq05<=27) 	
replace educat7 = 2 		if s2bq05<5
replace educat7 = 3 		if s2bq05==5
replace educat7 = 4 		if s2bq05>=6 & s2bq05<10
replace educat7 = 5 		if s2bq05==10
replace educat7 = 6 		if s2bq05>=11 & s2bq05<=12  
replace educat7 = 7 		if inlist(s2bq05,13,14,15,16,17,18,19,20,21,22,23,24)
replace educat7 = 8 		if s2bq05==28
* Currently attending
replace educat7 = 1 		if  s2bq14>=25 & s2bq14<=27 & s2bq01==3
replace educat7 = 2 		if  s2bq14>=1 & s2bq14<=5 & s2bq01==3
replace educat7 = 4 		if  s2bq14>=6 & s2bq14<=10 & s2bq01==3
replace educat7 = 6 		if  s2bq14>=11 & s2bq14<=12 & s2bq01==3 
replace educat7 = 7 		if inlist(s2bq14,13,14,15,16,17,18,19,20,21,22,23,24)
replace educat7 = 8 		if  s2bq14==28 & s2bq01==3 & educat7==. 	//other
replace educat7 = .z 	if  s2bq03==3 | s2bq11==3  				//deeni madrissa
* Without the minimum age 
replace educat7 = . 		if  age<ed_mod_age & age!=.
* People with education years bigger than their age
replace educat7 = . 		if  educy>age & age!=. & educy!=.
replace educat7 = .		if  age<4
*</_educat7_>

*<_educat5_>
gen 	educat5 = .
replace educat5 = 1 		if  educat7==1
replace educat5 = 2 		if  educat7==2
replace educat5 = 3 		if  educat7==3 | educat7==4
replace educat5 = 4 		if  educat7==5
replace educat5 = 5 		if  educat7==6 | educat7==7
replace educat5 = .z 	if  educat7==.z
*</_educat5_>

*<_educat4_>
gen byte educat4 = .
replace educat4 = 1 		if  educat7==1 
replace educat4 = 2 		if  educat7==2 | educat7==3
replace educat4 = 3 		if  educat7==4 | educat7==5
replace educat4 = 4 		if  educat7==6 | educat7==7
replace educat4 = .z 	if  educat7==.z
*</_educat4_>

*<_everattend_>
recode s2bq01 (2 3 = 1) (1 = 0), gen(everattend)
replace educy = 0 		if  everattend==0
*</_everattend_>

replace educy = 0 		if  everattend==0
	

/*****************************************************************************************************
* LABOR MODULE
*****************************************************************************************************/

*<_lb_mod_age_>
gen byte lb_mod_age = 10
*</_lb_mod_age_>

*<_lstatus_>
* Reported in a monthly basis (not in a weekly basis)
gen   	lstatus = 1 			if  s1bq01==1 | s1bq03==1
replace lstatus = 2 			if  s1bq01==2 & s1bq03==2
replace lstatus = 3 			if  s1bq01==2 & s1bq03==3
replace lstatus = . 			if  age<lb_mod_age & age!=.
*</_lstatus_>

*<_lstatus_year_>
gen byte lstatus_year = .
replace lstatus_year = . 		if  age<lb_mod_age & age!=.
*</_lstatus_year_>

*<_empstat_>
gen byte empstat = 1 			if  s1bq06==4
replace empstat = 2 			if  s1bq06==5
replace empstat = 3 			if  s1bq06==1 | s1bq06==2
replace empstat = 4 			if  s1bq06==3 | s1bq06>=6 & s1bq06<=9
replace empstat = . 			if  lstatus!=1
*</_empstat_>

*<_empstat_year_>
gen byte empstat_year = .
*</_empstat_year_>

*<_njobs_>
gen byte njobs = .
*</_njobs_>

*<_njobs_year_>
gen byte njobs_year = .
*</_njobs_year_>

*<_ocusec_>
gen byte ocusec = .
*</_ocusec_>

*<_nlfreason_>
gen byte nlfreason = .
*</_nlfreason_>

*<_unempldur_l_>
gen byte unempldur_l = .
*</_unempldur_l_>

*<_unempldur_u_>
gen byte unempldur_u = .
*</_unempldur_u_>

*<_industry_orig_>
gen industry_orig = s1bq05
label define lblindustry_orig 111 `"growing of cereals (except rice), leguminous crops and oil seeds"', modify
label define lblindustry_orig 112 `"growing of rice"', modify
label define lblindustry_orig 113 `"growing of vegetables and melons, roots and tubers"', modify
label define lblindustry_orig 114 `"growing of sugar cane"', modify
label define lblindustry_orig 115 `"growing of tobacco"', modify
label define lblindustry_orig 116 `"growing of fibre crops"', modify
label define lblindustry_orig 119 `"growing of other non-perennial crops"', modify
label define lblindustry_orig 121 `"growing of grapes"', modify
label define lblindustry_orig 122 `"growing of tropical and subtropical fruits"', modify
label define lblindustry_orig 123 `"growing of citrus fruits"', modify
label define lblindustry_orig 124 `"growing of pome fruits and stone fruits"', modify
label define lblindustry_orig 125 `"growing of other tree and bush fruits and nuts"', modify
label define lblindustry_orig 126 `"growing of oleaginous fruits"', modify
label define lblindustry_orig 127 `"growing of beverage crops"', modify
label define lblindustry_orig 128 `"growing of spices, aromatic, drug and pharmaceutical crops"', modify
label define lblindustry_orig 129 `"growing of other perennial crops"', modify
label define lblindustry_orig 130 `"plant propagation"', modify
label define lblindustry_orig 141 `"raising of cattle and buffaloes"', modify
label define lblindustry_orig 142 `"raising of horses and other equines"', modify
label define lblindustry_orig 143 `"raising of camels and camelids"', modify
label define lblindustry_orig 144 `"raising of sheep and goats"', modify
label define lblindustry_orig 145 `"raising of swine/pigs"', modify
label define lblindustry_orig 146 `"raising of poultry"', modify
label define lblindustry_orig 149 `"raising of other animals"', modify
label define lblindustry_orig 150 `"mixed farming"', modify
label define lblindustry_orig 161 `"support activities for crop production"', modify
label define lblindustry_orig 162 `"support activities for animal production"', modify
label define lblindustry_orig 163 `"post-harvest crop activities"', modify
label define lblindustry_orig 164 `"seed processing for propagation"', modify
label define lblindustry_orig 170 `"hunting, trapping and related service activities"', modify
label define lblindustry_orig 210 `"silviculture and other forestry activities"', modify
label define lblindustry_orig 220 `"logging"', modify
label define lblindustry_orig 230 `"gathering of non-wood forest products"', modify
label define lblindustry_orig 240 `"support services to forestry"', modify
label define lblindustry_orig 311 `"marine fishing"', modify
label define lblindustry_orig 312 `"freshwater fishing"', modify
label define lblindustry_orig 321 `"marine aquaculture"', modify
label define lblindustry_orig 322 `"freshwater aquaculture"', modify
label define lblindustry_orig 510 `"mining of hard coal"', modify
label define lblindustry_orig 520 `"mining of lignite"', modify
label define lblindustry_orig 610 `"extraction of crude petroleum"', modify
label define lblindustry_orig 620 `"extraction of natural gas"', modify
label define lblindustry_orig 710 `"mining of iron ores"', modify
label define lblindustry_orig 721 `"mining of uranium and thorium ores"', modify
label define lblindustry_orig 729 `"mining of other non-ferrous metal ores"', modify
label define lblindustry_orig 810 `"quarrying of stone, sand and clay"', modify
label define lblindustry_orig 891 `"mining of chemical and fertilizer minerals"', modify
label define lblindustry_orig 892 `"extraction of peat"', modify
label define lblindustry_orig 893 `"extraction of salt"', modify
label define lblindustry_orig 899 `"other mining and quarrying n.e.c."', modify
label define lblindustry_orig 910 `"support activities for petroleum and natural gas extraction"', modify
label define lblindustry_orig 990 `"support activities for other mining and quarrying"', modify
label define lblindustry_orig 1010 `"processing and preserving of meat"', modify
label define lblindustry_orig 1020 `"processing and preserving of fish, crustaceans and molluscs"', modify
label define lblindustry_orig 1030 `"processing and preserving of fruit and vegetables"', modify
label define lblindustry_orig 1040 `"manufacture of vegetable and animal oils and fats"', modify
label define lblindustry_orig 1050 `"manufacture of dairy products"', modify
label define lblindustry_orig 1061 `"manufacture of grain mill products"', modify
label define lblindustry_orig 1062 `"manufacture of starches and starch products"', modify
label define lblindustry_orig 1071 `"manufacture of bakery products"', modify
label define lblindustry_orig 1072 `"manufacture of sugar"', modify
label define lblindustry_orig 1073 `"manufacture of cocoa, chocolate and sugar confectionery"', modify
label define lblindustry_orig 1074 `"manufacture of macaroni, noodles, couscous and similar farinaceous products"', modify
label define lblindustry_orig 1075 `"manufacture of prepared meals and dishes"', modify
label define lblindustry_orig 1079 `"manufacture of other food products n.e.c."', modify
label define lblindustry_orig 1080 `"manufacture of prepared animal feeds"', modify
label define lblindustry_orig 1101 `"distilling, rectifying and blending of spirits"', modify
label define lblindustry_orig 1102 `"manufacture of wines"', modify
label define lblindustry_orig 1103 `"manufacture of malt liquors and malt"', modify
label define lblindustry_orig 1104 `"manufacture of soft drinks; production of mineral waters and other bottled waters"', modify
label define lblindustry_orig 1200 `"manufacture of tobacco products"', modify
label define lblindustry_orig 1311 `"preparation and spinning of textile fibers"', modify
label define lblindustry_orig 1312 `"weaving of textiles"', modify
label define lblindustry_orig 1313 `"finishing of textiles"', modify
label define lblindustry_orig 1391 `"manufacture of knitted and crocheted fabrics"', modify
label define lblindustry_orig 1392 `"manufacture of made-up textile articles, except apparel"', modify
label define lblindustry_orig 1393 `"manufacture of carpets and rugs"', modify
label define lblindustry_orig 1394 `"manufacture of cordage, rope, twine and netting"', modify
label define lblindustry_orig 1399 `"manufacture of other textiles n.e.c."', modify
label define lblindustry_orig 1410 `"manufacture of wearing apparel, except fur apparel"', modify
label define lblindustry_orig 1420 `"manufacture of articles of fur"', modify
label define lblindustry_orig 1430 `"manufacture of knitted and crocheted apparel"', modify
label define lblindustry_orig 1511 `"tanning and dressing of leather; dressing and dyeing of fur"', modify
label define lblindustry_orig 1512 `"manufacture of luggage  handbags and the like, saddlery and harness"', modify
label define lblindustry_orig 1520 `"manufacture of footwear"', modify
label define lblindustry_orig 1610 `"sawmilling and planning of wood"', modify
label define lblindustry_orig 1621 `"manufacture of veneer sheets and wood-based panels"', modify
label define lblindustry_orig 1622 `"manufacture of buildersҠcarpentry and joinery"', modify
label define lblindustry_orig 1623 `"manufacture of wooden containers"', modify
label define lblindustry_orig 1629 `"manufacture of other products of wood; manufacture of articles of cork, straw and plaiting materials"', modify
label define lblindustry_orig 1701 `"manufacture of pulp, paper and paperboard"', modify
label define lblindustry_orig 1702 `"manufacture of corrugated paper and paperboard and of containers of paper and paperboard"', modify
label define lblindustry_orig 1709 `"manufacture of other articles of paper and paperboard"', modify
label define lblindustry_orig 1811 `"printing"', modify
label define lblindustry_orig 1812 `"service activities related to printing"', modify
label define lblindustry_orig 1820 `"reproduction of recorded media"', modify
label define lblindustry_orig 1910 `"manufacture of coke oven products"', modify
label define lblindustry_orig 1920 `"manufacture of refined petroleum products"', modify
label define lblindustry_orig 2011 `"manufacture of basic chemicals"', modify
label define lblindustry_orig 2012 `"manufacture of fertilizers and nitrogen compounds"', modify
label define lblindustry_orig 2013 `"manufacture of plastics and synthetic rubber in primary forms"', modify
label define lblindustry_orig 2021 `"manufacture of pesticides and other agrochemical products"', modify
label define lblindustry_orig 2022 `"manufacture of paints, varnishes and similar coatings, printing ink and mastics"', modify
label define lblindustry_orig 2023 `"manufacture of soap and detergents and cleaning and polishing preparations and perfumes and toilet preparations"', modify
label define lblindustry_orig 2029 `"manufacture of other chemical products n.e.c."', modify
label define lblindustry_orig 2030 `"manufacture of man-made fibres"', modify
label define lblindustry_orig 2100 `"manufacture of pharmaceuticals, medicinal chemical and botanical products"', modify
label define lblindustry_orig 2211 `"manufacture of rubber tyres and tubes;  retreating and rebuilding of rubber tyres"', modify
label define lblindustry_orig 2219 `"manufacture of other rubber products"', modify
label define lblindustry_orig 2220 `"manufacture of plastics products"', modify
label define lblindustry_orig 2310 `"manufacture of glass and glass products"', modify
label define lblindustry_orig 2391 `"manufacture of refractory products"', modify
label define lblindustry_orig 2392 `"manufacture of clay building materials"', modify
label define lblindustry_orig 2393 `"manufacture of other porcelain and ceramic products"', modify
label define lblindustry_orig 2394 `"manufacture of cement, lime and plaster"', modify
label define lblindustry_orig 2395 `"manufacture of articles of concrete, cement and plaster"', modify
label define lblindustry_orig 2396 `"cutting, shaping and finishing of stone"', modify
label define lblindustry_orig 2399 `"manufacture of other non-metallic mineral products n.e.c."', modify
label define lblindustry_orig 2410 `"manufacture of basic iron and steel"', modify
label define lblindustry_orig 2420 `"manufacture of basic precious and other non-ferrous metals"', modify
label define lblindustry_orig 2431 `"casting of iron and steel"', modify
label define lblindustry_orig 2432 `"casting of non-ferrous metals"', modify
label define lblindustry_orig 2511 `"manufacture of structural metal products"', modify
label define lblindustry_orig 2512 `"manufacture of tanks, reservoirs and containers of metal"', modify
label define lblindustry_orig 2513 `"manufacture of steam generators, except central heating hot water boilers"', modify
label define lblindustry_orig 2520 `"manufacture of weapons and ammunition"', modify
label define lblindustry_orig 2591 `"forging, pressing, stamping and roll-forming of metal; powder metallurgy"', modify
label define lblindustry_orig 2592 `"treatment and coating of metals; machining"', modify
label define lblindustry_orig 2593 `"manufacture of cutlery, hand tools and general hardware"', modify
label define lblindustry_orig 2599 `"manufacture of other fabricated metal products n.e.c."', modify
label define lblindustry_orig 2610 `"manufacture of electronic components and boards"', modify
label define lblindustry_orig 2620 `"manufacture of computers and peripheral equipment"', modify
label define lblindustry_orig 2630 `"manufacture of communication equipment"', modify
label define lblindustry_orig 2640 `"manufacture of consumer electronics"', modify
label define lblindustry_orig 2651 `"manufacture of measuring, testing, navigating and control equipment"', modify
label define lblindustry_orig 2652 `"manufacture of watches and clocks"', modify
label define lblindustry_orig 2660 `"manufacture of irradiation, electro-medical and electrotherapeutic equipment"', modify
label define lblindustry_orig 2670 `"manufacture of optical instruments and photographic equipment"', modify
label define lblindustry_orig 2680 `"manufacture of magnetic and optical media"', modify
label define lblindustry_orig 2710 `"manufacture of electric motors  and transformers and electricity distribution and control apparatus"', modify
label define lblindustry_orig 2720 `"manufacture of batteries and accumulators"', modify
label define lblindustry_orig 2731 `"manufacture of fibre optic cables"', modify
label define lblindustry_orig 2732 `"manufacture of other electronic and electric wires and cables"', modify
label define lblindustry_orig 2733 `"manufacture of wiring devices"', modify
label define lblindustry_orig 2740 `"manufacture of electric lighting equipment"', modify
label define lblindustry_orig 2750 `"manufacture of domestic appliances"', modify
label define lblindustry_orig 2790 `"manufacture of other electrical equipment"', modify
label define lblindustry_orig 2811 `"manufacture of engines and turbines, except aircraft, vehicle and cycle engines"', modify
label define lblindustry_orig 2812 `"manufacture of fluid power equipment"', modify
label define lblindustry_orig 2813 `"manufacture of other pumps, compressors, taps and valves"', modify
label define lblindustry_orig 2814 `"manufacture of bearings, gears, gearing and driving elements"', modify
label define lblindustry_orig 2815 `"manufacture of ovens, furnaces and furnace burners"', modify
label define lblindustry_orig 2816 `"manufacture of lifting and handling equipment"', modify
label define lblindustry_orig 2817 `"manufacture of office machinery and equipment (except computers and peripheral equipment)"', modify
label define lblindustry_orig 2818 `"manufacture of power-driven hand tools"', modify
label define lblindustry_orig 2819 `"manufacture of other general-purpose machinery"', modify
label define lblindustry_orig 2821 `"manufacture of agricultural and forestry machinery"', modify
label define lblindustry_orig 2822 `"manufacture of metal-forming machinery and machine tools"', modify
label define lblindustry_orig 2823 `"manufacture of machinery for metallurgy"', modify
label define lblindustry_orig 2824 `"manufacture of machinery for mining, quarrying and construction"', modify
label define lblindustry_orig 2825 `"manufacture of machinery for food, beverage and tobacco processing"', modify
label define lblindustry_orig 2826 `"manufacture of machinery for textile, apparel and leather production"', modify
label define lblindustry_orig 2829 `"manufacture of other special-purpose machinery"', modify
label define lblindustry_orig 2910 `"manufacture of motor vehicles"', modify
label define lblindustry_orig 2920 `"manufacture of bodies (coachwork) for motor vehicles  manufacture of trailers and semi-trailers"', modify
label define lblindustry_orig 2930 `"manufacture of parts and accessories for motor vehicles"', modify
label define lblindustry_orig 3011 `"building of ships and floating structures"', modify
label define lblindustry_orig 3012 `"building of pleasure and sporting boats"', modify
label define lblindustry_orig 3020 `"manufacture of railway locomotives and rolling stock"', modify
label define lblindustry_orig 3030 `"manufacture of air and spacecraft and related machinery"', modify
label define lblindustry_orig 3040 `"manufacture of military fighting vehicles"', modify
label define lblindustry_orig 3091 `"manufacture of motorcycles"', modify
label define lblindustry_orig 3092 `"manufacture of bicycles and invalid carriages"', modify
label define lblindustry_orig 3099 `"manufacture of other transport equipment n.e.c."', modify
label define lblindustry_orig 3100 `"manufacture of furniture"', modify
label define lblindustry_orig 3211 `"manufacture of jewelry and related articles"', modify
label define lblindustry_orig 3212 `"manufacture of imitation jewelry and related articles"', modify
label define lblindustry_orig 3220 `"manufacture of musical instruments"', modify
label define lblindustry_orig 3230 `"manufacture of sports goods"', modify
label define lblindustry_orig 3240 `"manufacture of games and toys"', modify
label define lblindustry_orig 3250 `"manufacture of medical and dental instruments and supplies"', modify
label define lblindustry_orig 3290 `"other manufacturing n.e.c."', modify
label define lblindustry_orig 3311 `"repair of fabricated metal products"', modify
label define lblindustry_orig 3312 `"repair of machinery"', modify
label define lblindustry_orig 3313 `"repair of electronic and optical equipment"', modify
label define lblindustry_orig 3314 `"repair of electrical equipment"', modify
label define lblindustry_orig 3315 `"repair of transport equipment, except motor vehicles"', modify
label define lblindustry_orig 3319 `"repair of other equipment"', modify
label define lblindustry_orig 3320 `"installation of industrial machinery and equipment"', modify
label define lblindustry_orig 3510 `"electric power generation, transmission and distribution"', modify
label define lblindustry_orig 3520 `"manufacture of gas; distribution of gaseous fuels through mains"', modify
label define lblindustry_orig 3530 `"steam and air conditioning supply"', modify
label define lblindustry_orig 3600 `"water collection, treatment and supply"', modify
label define lblindustry_orig 3700 `"sewerage"', modify
label define lblindustry_orig 3811 `"collection of non-hazardous waste"', modify
label define lblindustry_orig 3812 `"collection of hazardous waste"', modify
label define lblindustry_orig 3821 `"treatment and disposal of non-hazardous waste"', modify
label define lblindustry_orig 3822 `"treatment and disposal of hazardous waste"', modify
label define lblindustry_orig 3830 `"materials recovery"', modify
label define lblindustry_orig 3900 `"remediation activities and other waste management services"', modify
label define lblindustry_orig 4100 `"construction of buildings"', modify
label define lblindustry_orig 4210 `"construction of roads and railways"', modify
label define lblindustry_orig 4220 `"construction of utility projects"', modify
label define lblindustry_orig 4290 `"construction of other civil engineering projects"', modify
label define lblindustry_orig 4311 `"demolition"', modify
label define lblindustry_orig 4312 `"site preparation"', modify
label define lblindustry_orig 4321 `"electrical installation"', modify
label define lblindustry_orig 4322 `"plumbing, heat and air-conditioning installation"', modify
label define lblindustry_orig 4329 `"other construction installation"', modify
label define lblindustry_orig 4330 `"building completion and finishing"', modify
label define lblindustry_orig 4390 `"other specialized construction activities"', modify
label define lblindustry_orig 4510 `"sale of motor vehicles"', modify
label define lblindustry_orig 4520 `"maintenance and repair of motor vehicles"', modify
label define lblindustry_orig 4530 `"sale of motor vehicle parts and accessories"', modify
label define lblindustry_orig 4540 `"sale, maintenance and repair of motorcycles and related parts and accessories"', modify
label define lblindustry_orig 4610 `"wholesale on a fee or contract basis"', modify
label define lblindustry_orig 4620 `"wholesale of agricultural raw materials and live animals"', modify
label define lblindustry_orig 4630 `"wholesale of food, beverages and tobacco"', modify
label define lblindustry_orig 4641 `"wholesale of textiles, clothing and footwear"', modify
label define lblindustry_orig 4649 `"wholesale of other household goods"', modify
label define lblindustry_orig 4651 `"wholesale of computers, computer peripheral equipment and software"', modify
label define lblindustry_orig 4652 `"wholesale of electronic and telecommunications equipment and parts"', modify
label define lblindustry_orig 4653 `"wholesale of agricultural machinery, equipment and supplies"', modify
label define lblindustry_orig 4659 `"wholesale of other machinery and equipment"', modify
label define lblindustry_orig 4661 `"wholesale of solid, liquid and gaseous fuels and related products"', modify
label define lblindustry_orig 4662 `"wholesale of metals and metal ores"', modify
label define lblindustry_orig 4663 `"wholesale of construction materials and hardware and plumbing and heating equipment and supplies"', modify
label define lblindustry_orig 4669 `"wholesale of waste and scrap and other products n.e.c."', modify
label define lblindustry_orig 4690 `"non-specialized wholesale trade"', modify
label define lblindustry_orig 4711 `"retail sale in non-specialized stores with food, beverages or tobacco predominating"', modify
label define lblindustry_orig 4719 `"other retail sale in non-specialized stores"', modify
label define lblindustry_orig 4721 `"retail sale of food in specialized stores"', modify
label define lblindustry_orig 4722 `"retail sale of beverages in specialized stores"', modify
label define lblindustry_orig 4723 `"retail sale of tobacco products in specialized stores"', modify
label define lblindustry_orig 4730 `"retail sale of automotive fuel in specialized stores"', modify
label define lblindustry_orig 4741 `"retail sale of computers, peripheral units, software and telecommunications equipment in specialized stores"', modify
label define lblindustry_orig 4742 `"retail sale of audio and video equipment in specialized stores"', modify
label define lblindustry_orig 4751 `"retail sale of textiles in specialized stores"', modify
label define lblindustry_orig 4752 `"retail sale of hardware and paints and glass in specialized stores"', modify
label define lblindustry_orig 4753 `"retail sale of carpets and rugs and wall and floor coverings in specialized stores"', modify
label define lblindustry_orig 4759 `"retail sale of electrical household appliances and furniture and lighting equipment and other household articles in spec"', modify
label define lblindustry_orig 4761 `"retail sale of books, newspapers and stationary in specialized stores"', modify
label define lblindustry_orig 4762 `"retail sale of music and video recordings in specialized stores"', modify
label define lblindustry_orig 4763 `"retail sale of sporting equipment in specialized stores"', modify
label define lblindustry_orig 4764 `"retail sale of games and toys in specialized stores"', modify
label define lblindustry_orig 4771 `"retail sale of clothing, footwear and leather articles in specialized stores"', modify
label define lblindustry_orig 4772 `"retail sale of pharmaceutical and medical goods, cosmetic and toilet articles in specialized"', modify
label define lblindustry_orig 4773 `"other retail sale of new goods in specialized stores"', modify
label define lblindustry_orig 4774 `"retail sale of second-hand goods"', modify
label define lblindustry_orig 4781 `"retail sale via stalls and markets of food, beverages and tobacco products"', modify
label define lblindustry_orig 4782 `"retail sale via stalls and markets of textiles, clothing and footwear"', modify
label define lblindustry_orig 4789 `"retail sale via stalls and markets of other goods"', modify
label define lblindustry_orig 4791 `"retail sale via mail order houses or via internet"', modify
label define lblindustry_orig 4799 `"other retail sale not in stores or stalls or markets"', modify
label define lblindustry_orig 4911 `"passenger rail transport, interurban"', modify
label define lblindustry_orig 4912 `"freight rail transport"', modify
label define lblindustry_orig 4921 `"urban and suburban passenger land transport"', modify
label define lblindustry_orig 4922 `"other passenger land transport"', modify
label define lblindustry_orig 4923 `"freight transport by road"', modify
label define lblindustry_orig 4930 `"transport via pipeline"', modify
label define lblindustry_orig 5011 `"sea and coastal passenger water transport"', modify
label define lblindustry_orig 5012 `"sea and coastal freight water transport"', modify
label define lblindustry_orig 5021 `"inland passenger water transport"', modify
label define lblindustry_orig 5022 `"inland freight water transport"', modify
label define lblindustry_orig 5110 `"passenger air transport"', modify
label define lblindustry_orig 5120 `"freight air transport"', modify
label define lblindustry_orig 5210 `"warehousing and storage"', modify
label define lblindustry_orig 5221 `"service activities incidental to land transportation"', modify
label define lblindustry_orig 5222 `"service activities incidental to water transportation"', modify
label define lblindustry_orig 5223 `"service activities incidental to air transportation"', modify
label define lblindustry_orig 5224 `"cargo handling"', modify
label define lblindustry_orig 5229 `"other transportation support activities"', modify
label define lblindustry_orig 5310 `"postal activities"', modify
label define lblindustry_orig 5320 `"courier activities"', modify
label define lblindustry_orig 5510 `"short term accommodation activities"', modify
label define lblindustry_orig 5520 `"camping grounds, recreational vehicle parks and trailer parks"', modify
label define lblindustry_orig 5590 `"other accommodation"', modify
label define lblindustry_orig 5610 `"restaurants and mobile food service activities"', modify
label define lblindustry_orig 5621 `"event catering"', modify
label define lblindustry_orig 5629 `"other food service activities"', modify
label define lblindustry_orig 5630 `"beverage serving activities"', modify
label define lblindustry_orig 5811 `"book publishing"', modify
label define lblindustry_orig 5812 `"publishing of directories and mailing lists"', modify
label define lblindustry_orig 5813 `"publishing of newspapers, journals and periodicals"', modify
label define lblindustry_orig 5819 `"other publishing activities"', modify
label define lblindustry_orig 5820 `"software publishing"', modify
label define lblindustry_orig 5911 `"motion picture, video and television programme production activities"', modify
label define lblindustry_orig 5912 `"motion picture, video and television programme post-production activities"', modify
label define lblindustry_orig 5913 `"motion picture, video and television programme distribution activities"', modify
label define lblindustry_orig 5914 `"motion picture projection activities"', modify
label define lblindustry_orig 5920 `"sound recording and music publishing activities"', modify
label define lblindustry_orig 6010 `"radio broadcasting"', modify
label define lblindustry_orig 6020 `"television programming and broadcasting activities"', modify
label define lblindustry_orig 6110 `"wired telecommunications activities"', modify
label define lblindustry_orig 6120 `"wireless telecommunications activities"', modify
label define lblindustry_orig 6130 `"satellite telecommunications activities"', modify
label define lblindustry_orig 6190 `"other telecommunications activities"', modify
label define lblindustry_orig 6201 `"computer programming activities"', modify
label define lblindustry_orig 6202 `"computer consultancy and computer facilities management activities"', modify
label define lblindustry_orig 6209 `"other information technology and computer service activities"', modify
label define lblindustry_orig 6311 `"data processing, hosting and related activities"', modify
label define lblindustry_orig 6312 `"web portals"', modify
label define lblindustry_orig 6391 `"news agency activities"', modify
label define lblindustry_orig 6399 `"other information service activities n.e.c."', modify
label define lblindustry_orig 6411 `"central banking"', modify
label define lblindustry_orig 6419 `"other monetary intermediation"', modify
label define lblindustry_orig 6420 `"activities of holding companies"', modify
label define lblindustry_orig 6430 `"trusts, funds and similar financial entities"', modify
label define lblindustry_orig 6491 `"financial leasing"', modify
label define lblindustry_orig 6492 `"other credit granting"', modify
label define lblindustry_orig 6499 `"other financial service activities and except insurance and pension funding activities,"', modify
label define lblindustry_orig 6511 `"life insurance"', modify
label define lblindustry_orig 6512 `"non-life insurance"', modify
label define lblindustry_orig 6520 `"reinsurance"', modify
label define lblindustry_orig 6530 `"pension funding"', modify
label define lblindustry_orig 6611 `"administration of financial markets"', modify
label define lblindustry_orig 6612 `"security and commodity contracts brokerage"', modify
label define lblindustry_orig 6619 `"other activities auxiliary to financial service activities"', modify
label define lblindustry_orig 6621 `"risk and damage evaluation"', modify
label define lblindustry_orig 6622 `"activities of insurance agents and brokers"', modify
label define lblindustry_orig 6629 `"other activities auxiliary to insurance and pension funding"', modify
label define lblindustry_orig 6630 `"fund management activities"', modify
label define lblindustry_orig 6810 `"real estate activities with own or leased property"', modify
label define lblindustry_orig 6820 `"real estate activities on a fee or contract basis"', modify
label define lblindustry_orig 6910 `"legal activities"', modify
label define lblindustry_orig 6920 `"accounting, bookkeeping and auditing activities; tax consultancy"', modify
label define lblindustry_orig 7010 `"activities of head offices"', modify
label define lblindustry_orig 7020 `"management consultancy activities"', modify
label define lblindustry_orig 7110 `"architectural and engineering activities and related technical consultancy"', modify
label define lblindustry_orig 7120 `"technical testing and analysis"', modify
label define lblindustry_orig 7210 `"research and experimental development on natural sciences and engineering"', modify
label define lblindustry_orig 7220 `"research and experimental development on social sciences and humanities"', modify
label define lblindustry_orig 7310 `"advertising"', modify
label define lblindustry_orig 7320 `"market research and public opinion polling"', modify
label define lblindustry_orig 7410 `"specialized design activities"', modify
label define lblindustry_orig 7420 `"photographic activities"', modify
label define lblindustry_orig 7490 `"other professional, scientific and technical activities n.e.c."', modify
label define lblindustry_orig 7500 `"veterinary activities"', modify
label define lblindustry_orig 7710 `"renting and leasing of motor vehicles"', modify
label define lblindustry_orig 7721 `"renting and leasing of recreational and sports goods"', modify
label define lblindustry_orig 7722 `"renting of video tapes and disks"', modify
label define lblindustry_orig 7729 `"renting and leasing of other personal and household goods"', modify
label define lblindustry_orig 7730 `"renting and leasing of other machinery, equipment and tangible goods"', modify
label define lblindustry_orig 7740 `"leasing of intellectual property and similar products, except copyrighted works"', modify
label define lblindustry_orig 7810 `"activities of employment placement agencies"', modify
label define lblindustry_orig 7820 `"temporary employment agency activities"', modify
label define lblindustry_orig 7830 `"other human resources provision"', modify
label define lblindustry_orig 7911 `"travel agency activities"', modify
label define lblindustry_orig 7912 `"tour operator activities"', modify
label define lblindustry_orig 7990 `"other reservation service and related activities"', modify
label define lblindustry_orig 8010 `"private security activities"', modify
label define lblindustry_orig 8020 `"security systems service activities"', modify
label define lblindustry_orig 8030 `"investigation activities"', modify
label define lblindustry_orig 8110 `"combined facilities support activities"', modify
label define lblindustry_orig 8121 `"general cleaning of buildings"', modify
label define lblindustry_orig 8129 `"other building and industrial cleaning activities"', modify
label define lblindustry_orig 8130 `"landscape care and maintenance service activities"', modify
label define lblindustry_orig 8211 `"combined office administrative service activities"', modify
label define lblindustry_orig 8219 `"photocopying, document preparation and other specialized office support activities"', modify
label define lblindustry_orig 8220 `"activities of call centers"', modify
label define lblindustry_orig 8230 `"organization of conventions and trade shows"', modify
label define lblindustry_orig 8291 `"activities of collection agencies and credit bureaus"', modify
label define lblindustry_orig 8292 `"packaging activities"', modify
label define lblindustry_orig 8299 `"other business support service activities n.e.c."', modify
label define lblindustry_orig 8411 `"general public administration activities"', modify
label define lblindustry_orig 8412 `"regulation of the activities  health care & education & cultural services and other social services and excluding social"', modify
label define lblindustry_orig 8413 `"regulation of and contribution to more efficient operation of businesses"', modify
label define lblindustry_orig 8421 `"foreign affairs"', modify
label define lblindustry_orig 8422 `"defense activities"', modify
label define lblindustry_orig 8423 `"public order and safety activities"', modify
label define lblindustry_orig 8430 `"compulsory social security activities"', modify
label define lblindustry_orig 8510 `"pre-primary and primary education"', modify
label define lblindustry_orig 8521 `"general secondary education"', modify
label define lblindustry_orig 8522 `"technical and vocational secondary education"', modify
label define lblindustry_orig 8530 `"higher education"', modify
label define lblindustry_orig 8541 `"sports and recreation education"', modify
label define lblindustry_orig 8542 `"cultural education"', modify
label define lblindustry_orig 8549 `"other education n.e.c"', modify
label define lblindustry_orig 8550 `"educational support activities"', modify
label define lblindustry_orig 8610 `"hospital activities"', modify
label define lblindustry_orig 8620 `"medical and dental practice activities"', modify
label define lblindustry_orig 8690 `"other human health activities"', modify
label define lblindustry_orig 8710 `"residential nursing care facilities"', modify
label define lblindustry_orig 8720 `"residential care activities for mental retardation and mental health and substance abuse"', modify
label define lblindustry_orig 8730 `"residential care activities for the elderly and disabled"', modify
label define lblindustry_orig 8790 `"other residential care activities"', modify
label define lblindustry_orig 8810 `"social work activities without accommodation for the elderly and disabled"', modify
label define lblindustry_orig 8890 `"other social work activities without accommodation"', modify
label define lblindustry_orig 9000 `"creative, arts and entertainment activities"', modify
label define lblindustry_orig 9101 `"library and archives activities"', modify
label define lblindustry_orig 9102 `"museums activities and operation of historical sites and buildings"', modify
label define lblindustry_orig 9103 `"botanical and zoological gardens and nature reserves activities"', modify
label define lblindustry_orig 9200 `"gambling and betting activities"', modify
label define lblindustry_orig 9311 `"operation of sports facilities"', modify
label define lblindustry_orig 9312 `"activities of sports clubs"', modify
label define lblindustry_orig 9319 `"other sports activities"', modify
label define lblindustry_orig 9321 `"activities of amusement parks and theme parks"', modify
label define lblindustry_orig 9329 `"other amusement and recreation activities n.e.c."', modify
label define lblindustry_orig 9411 `"activities of business and employers membership organizations"', modify
label define lblindustry_orig 9412 `"activities of professional membership organizations"', modify
label define lblindustry_orig 9420 `"activities of trade unions"', modify
label define lblindustry_orig 9491 `"activities of religious organizations"', modify
label define lblindustry_orig 9492 `"activities of political organizations"', modify
label define lblindustry_orig 9499 `"activities of other membership organizations n.e.c."', modify
label define lblindustry_orig 9511 `"repair of computers and peripheral equipment"', modify
label define lblindustry_orig 9512 `"repair of communication equipment"', modify
label define lblindustry_orig 9521 `"repair of consumer electronics"', modify
label define lblindustry_orig 9522 `"repair of household appliances and home and garden equipment"', modify
label define lblindustry_orig 9523 `"repair of footwear and leather goods"', modify
label define lblindustry_orig 9524 `"repair of furniture and home furnishings"', modify
label define lblindustry_orig 9529 `"repair of other personal and household goods"', modify
label define lblindustry_orig 9601 `"washing and (dry-) cleaning of textile and fur products"', modify
label define lblindustry_orig 9602 `"hairdressing and other beauty treatment"', modify
label define lblindustry_orig 9603 `"funeral and related activities"', modify
label define lblindustry_orig 9609 `"other personal service activities n.e.c"', modify
label define lblindustry_orig 9700 `"activities of households as employers of domestic personnel"', modify
label define lblindustry_orig 9810 `"undifferentiated goods-producing activities of private households for own use"', modify
label define lblindustry_orig 9820 `"undifferentiated service-producing activities of private households for own use"', modify
label define lblindustry_orig 9900 `"activities of extraterritorial organizations and bodies"', modify
label values industry_orig lblindustry_orig
replace industry_orig = . 		if  lstatus!=1
*</_industry_orig_>

*<_industry_>
gen ind = int(s1bq05/100)
gen byte industrycat10 = 1 		if  ind>=1 & ind<5
replace industrycat10 = 2 		if  ind>=5 & ind<10
replace industrycat10 = 3 		if  ind>=10 & ind<=33
replace industrycat10 = 4 		if  ind>=35 & ind<41
replace industrycat10 = 5 		if  ind>=41 & ind<45
replace industrycat10 = 6 		if  ind>=45 & ind<=47
replace industrycat10 = 6 		if  ind==55 | ind==56
replace industrycat10 = 7 		if  ind>=49 & ind<55
replace industrycat10 = 8 		if  ind>=58 & ind<=82
replace industrycat10 = 9 		if  ind==84
replace industrycat10 = 10		if  ind>=85 & ind<=99
replace industrycat10=. 			if  lstatus!=1
*</_industry_>

*<_industrycat4_>
gen industrycat4 = industrycat10
recode industrycat4 (2/5 = 2) (6/9 = 3) (10 = 4)
*</_industrycat4_>

*<_occup_orig_>
gen occup_orig = s1bq04
labmask  occup_orig, val(s1bq04) lbl(lbloccup_orig) decode	 
replace occup_orig = . 		if  lstatus!=1
*</_occup_orig_>

*<_occup_>
gen ocup = int(s1bq04/100)
gen byte occup = .
replace occup = 10			if  ocup<10 & ocup!=.
replace occup = 1 			if  ocup>=11 & ocup<20
replace occup = 2 			if  ocup>=21 & ocup<30
replace occup = 3 			if  ocup>=31 & ocup<40
replace occup = 4 			if  ocup>=41 & ocup<50
replace occup = 5 			if  ocup>=51 & ocup<60
replace occup = 6 			if  ocup>=61 & ocup<70
replace occup = 7 			if  ocup>=71 & ocup<80
replace occup = 8 			if  ocup>=81 & ocup<90
replace occup = 9 			if  ocup>=91 & ocup<99
replace occup = . 			if  s1bq04==343
replace occup = . 			if  lstatus!=1
*</_occup_>

*<_firmsize_l_>
gen byte firmsize_l = .
*</_firmsize_l_>

*<_firmsize_u_>
gen byte firmsize_u = .
*</_firmsize_u_>

*<_whours_>
gen 	whours = .
*</_whours_>

*<_wage_>
gen double wage = .
replace wage = s1bq08 		if  s1bq08!=.
replace wage = s1bq10 		if  s1bq10!=.
replace wage = . 			if  lstatus!=1
notes wage: "PAK 2018" this variable is reported monthly and yearly
*</_wage_>

*<_unitwage_>
gen byte unitwage = .
replace unitwage = 5 				if  s1bq08!=.
replace unitwage = 8 				if  s1bq10!=.
replace unitwage = . 				if  lstatus!=1
notes unitwage: "PAK 2018" this variable is reported monthly and yearly
*</_wageunit_>

*<_empstat_2_year_>
gen byte empstat_2_year = .
*</_empstat_2_>

*<_empstat_2_>
gen byte empstat_2 = 1 				if  s1bq14==4
replace empstat_2 = 2 				if  s1bq14==5
replace empstat_2 = 3 				if  s1bq14==1 | s1bq14==2
replace empstat_2 = 4 				if  s1bq14==3 | s1bq14>=6 & s1bq14<=9
replace empstat_2 = . 				if  s1bq11!=1
*</_empstat_2_>

*<_industry_2_>
gen ind2 = int(s1bq13/100)
gen byte industry_2 = 1 				if  ind2>=1 & ind2<5
replace industry_2 = 2 				if  ind2>=5 & ind2<10
replace industry_2 = 3 				if  ind2>=10 & ind2<=33
replace industry_2 = 4 				if  ind2>=35 & ind2<41
replace industry_2 = 5 				if  ind2>=41 & ind2<45
replace industry_2 = 6 				if  ind2>=45 & ind2<=47
replace industry_2 = 6 				if  ind2==55 | ind2==56
replace industry_2 = 7 				if  ind2>=49 & ind2<55
replace industry_2 = 8 				if  ind2>=58 & ind2<=82
replace industry_2 = 9 				if  ind2==84
replace industry_2 = 10 				if  ind2>=85 & ind2<=99
replace industry_2 = . 				if  s1bq11!=1
*<_industry_2_>

*<_industry_orig_2_>
gen industry_orig_2 = s1bq13
*</_industry_orig_2>

*<_occup_2_>
gen ocup2 = int(s1bq12/100)
gen byte occup_2 = .
replace occup_2 = 10 				if  ocup2<10 & ocup2!=.
replace occup_2 = 1 					if  ocup2>=11 & ocup2<20
replace occup_2 = 2 					if  ocup2>=21 & ocup2<30
replace occup_2 = 3 					if  ocup2>=31 & ocup2<40
replace occup_2 = 4 					if  ocup2>=41 & ocup2<50
replace occup_2 = 5 					if  ocup2>=51 & ocup2<60
replace occup_2 = 6 					if  ocup2>=61 & ocup2<70
replace occup_2 = 7 					if  ocup2>=71 & ocup2<80
replace occup_2 = 8 					if  ocup2>=81 & ocup2<90
replace occup_2 = 9 					if  ocup2>=91 & ocup2<99
replace occup_2 = . 					if  s1bq04==343
replace occup_2 = . 					if  s1bq11!=1
*</_occup_2_>

*<_wage_2_>
gen  	wage_2 = s1bq15
replace wage_2 = . 					if  s1bq11!=1
*</_wage_2_>

*<_unitwage_2_>
gen     unitwage_2 = 8 				if  wage_2!=.
replace unitwage_2 = . 				if  s1bq11!=1
*</_unitwage_2_>

*<_contract_>
gen byte contract = .
*</_contract_>

*<_healthins_>
gen byte healthins = .
*</_healthins_>

*<_socialsec_>
gen byte socialsec = .
*</_socialsec_>

*<_union_>
gen byte union = .
*</_union_>

foreach var in lstatus lstatus_year empstat empstat_year njobs njobs_year ocusec nlfreason unempldur_l unempldur_u industry_orig occup_orig occup firmsize_l firmsize_u whours wage unitwage empstat_2 empstat_2_year industry_2 industry_orig_2 occup_2 wage_2 unitwage_2 contract healthins socialsec union{
replace `var'=. if age<lb_mod_age
}


/*****************************************************************************************************
* MIGRATION MODULE
*****************************************************************************************************/

*<_rbirth_juris_>
gen byte rbirth_juris = .
*</_rbirth_juris_>

*<_rbirth_>
gen byte rbirth = .
*</_rbirth_>

*<_rprevious_juris_>
gen byte rprevious_juris = .
*</_rprevious_juris_>

*<_rprevious_>
gen byte rprevious = .
*</_rprevious_>

*<_yrmove_>
gen int yrmove = .
*</_yrmove_>


/*****************************************************************************************************
* ASSETS
*****************************************************************************************************/
* Notes: PAK 2018 information on assets comes from durables list, which states the number of items owned by hh at present and during the year.

*<_landphone_>
recode s5aq30_3a (1=1) (2=0), gen(landphone)
*</_landphone_>

*<_cellphone_>
recode s5aq30_2a (1=1) (2=0), gen(cellphone)
*</_cellphone_>

*<_computer_>
gen byte computer = 1 		if  s5aq30_4a==1 | s5aq30_5a==1
replace	 computer = 0 		if (s5aq30_4a==2 | s5aq30_5a==2) & computer!=1
*</_computer_>

*<_radio_>
gen radio = c02_701>=1 & c02_701<.
*</_radio_>

*<_television_>
gen television = c02_702>=1 & c02_702<.
*</_television>

*<_fan_>
gen fan = c02_710>=1 & c02_710<.
*</_fan>

*<_sewingmachine_>
gen sewingmachine = c02_714>=1 & c02_714<.
*</_sewingmachine>

*<_washingmachine_>
gen washingmachine = c02_706>=1 & c02_706<.
*</_washingmachine>

*<_refrigerator_>
gen refrigerator = c02_704>=1 & c02_704<.
*</_refrigerator>

*<_lamp_>
gen lamp = .
*</_lamp>

*<_bycicle_>
gen bicycle = c02_727>=1 & c02_727<.
*</_bycicle>

*<_motorcycle_>
gen motorcycle = c02_728>=1 & c02_728<.
*</_motorcycle>

*<_motorcar_>
gen motorcar = c02_730>=1 & c02_730<.
*</_motorcar>

*<_cow_>
gen cow = .
*</_cow>

*<_buffalo_>
gen buffalo = .
*</_buffalo>

*<_chicken_>
gen chicken = .
*</_chicken>


/*****************************************************************************************************
* WELFARE MODULE
*****************************************************************************************************/

*<_spdef_>
gen spdef = psupind
*</_spdef_>

*<_welfare_>
gen welfare = (nomexpend/hsize)/psupindm_n 
*</_welfare_>

*<_welfarenom_>
gen welfarenom = nomexpend/hsize
*</_welfarenom_>

*<_welfaredef_>
gen welfaredef = texpend/hsize
*</_welfaredef_>

*<_welfshprosperity_>
gen welfshprosperity = .
*</_welfshprosperity_>

*<_welfaretype_>
gen welfaretype = "EXP"
*</_welfaretype_>

*<_welfareother_>
gen welfareother = nomexpend/hsize_p
*</_welfareother_>

*<_welfareothertype_>
gen welfareothertype = "EXP"
*</_welfareothertype_>

*<_welfarenat_>
gen welfarenat = peaexpM
*</_welfarenat_>

* QUINTILE, DECILE AND FOOD/NON-FOOD SHARES OF CONSUMPTION AGGREGATE
* levelsof year, loc(y)
* merge m:1 idh using "$shares/PAK_fnf_`y'", keepusing (food_share nfood_share quintile_cons_aggregate decile_cons_aggregate) gen(_merge2)
* drop _merge2


/*****************************************************************************************************
* NATIONAL POVERTY
******************************************************************************************************/

* ADULT EQUIVALENCY
gen eqadult = eqadultM

*<_pline_nat_>
gen pline_nat = 3776.06
*</_pline_nat_>

*<_poor_nat_>
gen poor_nat = welfarenat<pline_nat 	if  welfarenat!=. & pline_nat!=.
*</_poor_nat_>



/*****************************************************************************************************
* INTERNATIONAL POVERTY
*****************************************************************************************************/
local year = 2011
/*	
*<_cpi_>
preserve
use   "${support}\\Monthly_CPI.dta", clear
keep if inlist(code,"PAK")
keep code year month yearly_cpi monthly_cpi
keep if month==1 

gen jan_nextyear = monthly_cpi[_n+1] 
foreach x of numlist 11 17 {
	egen yearly_cpi20`x' = mean(yearly_cpi) 		if  year==20`x' 
    egen m_yearly_cpi20`x' = mean(yearly_cpi20`x')
    drop yearly_cpi20`x'
    rename m_yearly_cpi20`x' yearly_cpi20`x'
	gen cpi20`x'_06 = (jan_nextyear/yearly_cpi20`x') 
	}
keep code year cpi20*
tempfile cpibasedata_M_PAK_06
save `cpibasedata_M_PAK_06'
restore 
merge m:1 year using `cpibasedata_M_PAK_06', nogen keep(match)
label variable cpi2011_06 "CPI (CPI from January 2019 base 2011)"
label variable cpi2017_06 "CPI (CPI from January 2019 base 2017)"
*</_cpi_>

*<_ppp_>
preserve
use   "${support}\\Final_CPI_PPP_to_be_used.dta", clear
keep if inlist(code,"PAK") 
replace ppp_2011 = icp2011
replace ppp_2017 = icp2017
collapse (mean) ppp_2011 ppp_2017, by(countryname code ppp_domain_value)
tempfile pppdata
save `pppdata', replace
restore 
merge m:1 code using `pppdata', nogen keep(match)
label variable cpi2011_06 "PPP (base 2011)"
label variable cpi2017_06 "PPP (base 2017)"
*</_ppp_>

*<_cpiperiod_>
gen cpiperiod = "2019m1"
*</_cpiperiod_>	
	
*<_pline_int_>
gen pline_int_215 = 2.15*cpi2017_06*ppp_2017*365/12
*</_pline_int_>

*<_poor_int_>
gen poor_int_215 = welfare<pline_int_215 & welfare!=.
tab poor_int_215 [aw=wgt] 	if !mi(poor_int_215)
*</_poor_int_>

*<_pline_int_>
gen pline_int_365 = 3.65*cpi2017_06*ppp_2017*365/12
*</_pline_int_>

*<_poor_int_>
gen poor_int_365 = welfare<pline_int_365 & welfare!=.
tab poor_int_365 [aw=wgt] 	if !mi(poor_int_365)
*</_poor_int_>

*<_pline_int_>
gen pline_int_685 = 6.85*cpi2017_06*ppp_2017*365/12
*</_pline_int_>

*<_poor_int_>
gen poor_int_685 = welfare<pline_int_685 & welfare!=.
tab poor_int_685 [aw=wgt] 	if !mi(poor_int_685)
*</_poor_int_>
*/
** GINI COEFFICIENT
ainequal welfare [aw=wgt] 

*<_shared_toilet_>
gen shared_toilet = (s5aq21==1 | s5aq23==1) if s5aq21==1 | inlist(s5aq23,1,2)
*</_shared_toilet_>

*<_industry_>
gen industry = industrycat10
*</_industry_>

*<_lphone_>
recode s5aq30_3a (1=1) (2=0), gen(lphone)
*</_lphone_>

*<_weighttype_>
*<_weighttype_note_> Weight type (frequency, probability, analytical, importance) *</_weighttype_note_>
*<_weighttype_note_> weighttype brought in from rawdata *</_weighttype_note_>
capture drop weighttype
gen weighttype = "IW"
*</_weighttype_>


/*****************************************************************************************************
* FINAL STEPS
*****************************************************************************************************/
	
* create variables that were not in questionnaire as missing 
foreach var_notfound in industry_year industry_2_year industry_orig_year industry_orig_2_year occup_year ocusec_year subnatid4 {
	if strmatch("`var_notfound'","*_orig*") g `var_notfound' = ""
	else g `var_notfound' = .
	note `var_notfound': PAK_2018_HIES does not have any relevant questions or variables.
}

* create variables that do not have sufficient definitions from the SAR team
foreach var_notfound in food_share nfood_share pline_int poor_int quintile_cons_aggregate {
	gen `var_notfound'=.
	note `var_notfound': For PAK_2018_HIES, I did not have a sufficient understanding of how `var_notfound' is defined from the SAR team, so it was created as missing.
}

*<_Save data file_>
do    "$rootdofiles\_aux\Labels_SARMD.do"
save  "$output\\`filename'.dta", replace
*</_Save data file_>	
/*
preserve
use "C:\datalib\SARMD\Final_CPI_PPP_to_be_used.dta", clear
keep if code=="PAK"
tempfile CPIs
save `CPIs'
restore 	
	
merge m:1 code year using `CPIs'

gen pline_int_300 = 3.00*cpi2021*icp2021*365/12
gen poor_int_300 = welfare<pline_int_300 & welfare!=.
sum poor_int_300 [aw=wgt] 		if  !mi(poor_int_300)

gen pline_int_420 = 4.20*cpi2021*icp2021*365/12
gen poor_int_420 = welfare<pline_int_420 & welfare!=.
sum poor_int_420 [aw=wgt] 		if  !mi(poor_int_420)

gen pline_int_830 = 8.30*cpi2021*icp2021*365/12
gen poor_int_830 = welfare<pline_int_830 & welfare!=.
sum poor_int_830 [aw=wgt] 		if  !mi(poor_int_830)	
	