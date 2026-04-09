/*------------------------------------------------------------------------------
  SARMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   	LKA_2019_HIES_v01_M_v03_A_SARMD_IND.do	   </_Program name_>
<_Application_>    	STATA 17.0									 <_Application_>
<_Author(s)_>      	Leo Tornarolli <tornarolli@gmail.com>		  </_Author(s)_>
<_Date created_>   	12-2023									   </_Date created_>
<_Date modified>   	October 2024						      </_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        	LKA											    </_Country_>
<_Survey Title_>   	HIES									   </_Survey Title_>
<_Survey Year_>    	2019										</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:				10-2024
File:				LKA_2019_HIES_v01_M_v03_A_SARMD_IND.do
First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>
clear all
set more off

local code         		"LKA"
local year         		"2019"
local survey       		"HIES"
local vm           		"01"
local va          		"03"
local type         		"SARMD"
global module       	"IND"
local yearfolder    	"`code'_`year'_`survey'"
local SARMDfolder    	"`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'"
local filename      	"`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'_${module}"
global output      		"${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\\Data\Harmonized" 
global shares    		"$rootdofiles\_aux\"
*</_Program setup_>


*<_Datalibweb request_>
use   "${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata\\`yearfolder'_v`vm'_M.dta", clear
sort  hhid pid
merge 1:1 hhid pid using "${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\Data\Harmonized\\`yearfolder'_v`vm'_M_v`va'_A_`type'_INC.dta"
drop _merge
*</_Datalibweb request_>


*<_countrycode_> 
*<_countrycode_note_> Country code according to ISO-3166 Alpha-3 *</_countrycode_note_>
*</_countrycode_>

*<_code_> 
gen code = "`code'"  
*</_code_>

*<_year_>
*<_year_note_> 4-digit year of survey based on IHSN standards *</_year_note_>
*</_year_>

*<_survey_>
*<_survey_note_> Survey acronym *</_survey_note_>
gen str survey = "`survey'"
label var survey "Household Income and Expenditure Survey"
*</_survey_>

*<_veralt_>
*<_veralt_note_> Harmonization version *</_veralt_note_>
gen veralt = "`va'"
*</_veralt_>

*<_vermast_>
*<_vermast_note_> Master version *</_vermast_note_>
gen vermast = "`vm'"
*</_vermast_>

*<_int_year_>
*<_int_year_note_> Interview Year *</_int_year_note_>
gen int_year = 2019
*</_int_year_>

*<_int_month_>
*<_int_month_note_> Interview Month *</_int_month_note_>
*<_int_month_note_> 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December" *</_int_month_note_>
gen byte int_month = month
label define int_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
label values int_month int_month
*</_int_month_>

*<_idh_>
*<_idh_note_> Household identifier  *</_idh_note_>
notes  idh: household identifiers in raw data is variable hhid
*</_idh_>

*<_idh_orig_>
*<_idh_orig_note_> Household identifier variable in the raw data is HHID *</_idh_org_note_>
gen idh_orig = "hhid"
clonevar idh_org = idh_orig
*</_idh_orig_>

*<_idp_>
*<_idp_note_> Personal identifier variable in the raw data is PID *</_idp_note_>
notes idp: individual identifier (within household) in raw data is variable pid
*</_idp_>

*<_idp_orig_>
*<_idp_orig_note_> Personal identifier variables in the raw data depends on the module *</_idp_org_note_>
gen idp_orig = "hhid pid"
clonevar idp_org = idp_orig
*</_idp_orig_>

*<_wgt_>
*<_wgt_note_> Household weight  *</_wgt_note_>
/*<_wgt_note_> Survey specific information *</_wgt_note_>*/
clonevar weight = wgt
*</_wgt_>

*<_pop_wgt_>
*<_pop_wgt_note_> Population weight *</_pop_wgt_note_>
/*<_pop_wgt_note_> Survey specific information *</_pop_wgt_note_>*/
*<_pop_wgt_note_>  *</_pop_wgt_note_>
gen pop_wgt = wgt
*</_pop_wgt_>

*<_psu_>
*<_psu_note_> Primary sampling units *</_psu_note_>
*gen psu = psu
*</_psu_>

*<_strata_>
*<_strata_note_> Strata *</_strata_note_>
/*<_strata_note_> Survey specific information *</_strata_note_>*/
*<_strata_note_>  *</_strata_note_>
gen strata = district
*</_strata_>

*<_weighttype_>
*<_weighttype_note_> Weight type (frequency, probability, analytical, importance) *</_weighttype_note_>
*<_weighttype_note_> weighttype brought in from rawdata *</_weighttype_note_>
*gen weighttype = "PW"
*</_weighttype_>


****************************************************************
**** GEOGRAPHICAL VARIABLES
****************************************************************


*<_urban_>
*<_urban_note_> uban/rural *</_urban_note_>
/*<_urban_note_> Urban or rural location of households *</_urban_note_>*/
*<_urban_note_> 0 "Rural"  1 "Urban"  *</_urban_note_>
capture drop urban
gen 	urban = .
replace urban = 0	if  sector==2 | sector==3
replace urban = 1	if  sector==1
*</_urban_>

*<_subnatid1_>
*<_subnatid1_note_>  Subnational ID - highest level *</_subnatid1_note_>
/*<_subnatid1_note_> Subnational id - subnational regional identifiers at which survey is representative - highest level *</_subnatid1_note_>*/
*<_subnatid1_note_>  *</_subnatid1_note_>
gen aux_district = round(district/10)
label define aux_district 1 "1 – Western" 2 "2 – Central" 3 "3 – Southern" 4 "4 – Northern" 5 "5 – Eastern" 6 "6 – North-Western" 7 "7 – North-Central" 8 "8 – Uva" 9 "9 – Sabaragamuwa"
label values aux_district aux_district
decode aux_district, gen(subnatid1)
notes subnatid1: Province Level
notes subnatid1: Representative
*</_subnatid1_>

*<_subnatid2_>
*<_subnatid2_note_> Subnational ID - second highest level *</_subnatid2_note_>
/*<_subnatid2_note_> Subnational id - subnational regional identifiers at which survey is representative - second highest level *</_subnatid2_note_>*/
*<_subnatid2_note_>  *</_subnatid2_note_>
gen  aux_district2 = district
destring aux_district2, replace
label define aux_district2  11 "11 - Colombo" 12 "12 - Gampaha" 13 "13 - Kalutara" 21 "21 - Kandy" 22 "22 - Matale" 23 "23 - Nuwara-eliya" 31 "31 - Galle" 32 "32 - Matara" 33 "33 - Hambantota" 41 "41 - Jaffna" 42 "42 - Mannar" 43 "43 - Vavuniya" 44 "44 - Mullaitivu" 45 "45 - Kilinochchi" 51 "51 - Batticaloa" 52 "52 - Ampara" 53 "53 - Tricomalee" 61 "61 - Kurunegala" 62 "62 - Puttlam" 71 "71 - Anuradhapura" 72 "72 - Polonnaruwa" 81 "81 - Badulla" 82 "82 - Moneragala" 91 "91 - Ratnapura" 92 "92 - Kegalle"
label values aux_district2 aux_district2
decode aux_district2, gen(subnatid2)
notes subnatid2: District Level
notes subnatid2: Representative
*</_subnatid2_>

*<_subnatid3_>
*<_subnatid3_note_>  Subnational ID - third highest level *</_subnatid3_note_>
/*<_subnatid3_note_> Subnational id - subnational regional identifiers at which survey is representative - third highest level *</_subnatid3_note_>*/
*<_subnatid3_note_>  *</_subnatid3_note_>
gen   subnatid3 = ""
notes subnatid3: the survey does not have a smaller level of representativeness than district (used in subnatid2)
*</_subnatid3_>   

*<_subnatid4_>
*<_subnatid4_note_>  Subnational ID - third highest level *</_subnatid4_note_>
/*<_subnatid4_note_> Subnational id - subnational regional identifiers at which survey is representative - fourthhighest level *</_subnatid4_note_>*/
*<_subnatid4_note_>  *</_subnatid4_note_>
gen   subnatid4 = ""
notes subnatid4: the survey does not have a smaller level of representativeness than district (used in subnatid2)
*</_subnatid4_> 

*<_gaul_adm1_code_>
*<_gaul_adm1_code_note_> Gaul Code *</_gaul_adm1_code_note_>
/*<_gaul_adm1_code_note_> . *</_gaul_adm1_code_note_>*/
*<_gaul_adm1_code_note_> gaul_adm1_code brought in from rawdata *</_gaul_adm1_code_note_>
gen     gaul_adm1_code = .
replace gaul_adm1_code = 2744		if  aux_district==1
replace gaul_adm1_code = 2736		if  aux_district==2
replace gaul_adm1_code = 2742		if  aux_district==3
replace gaul_adm1_code = 2740		if  aux_district==4
replace gaul_adm1_code = 2737		if  aux_district==5
replace gaul_adm1_code = 2739		if  aux_district==6
replace gaul_adm1_code = 2738		if  aux_district==7
replace gaul_adm1_code = 2743		if  aux_district==8
replace gaul_adm1_code = 2741		if  aux_district==9
*</_gaul_adm1_code_>

*<_gaul_adm2_code_>
gen 	gaul_adm2_code = .
replace gaul_adm2_code = 25851 	if  district==11
replace gaul_adm2_code = 25852 	if  district==12
replace gaul_adm2_code = 25853 	if  district==13
replace gaul_adm2_code = 41748 	if  district==21
replace gaul_adm2_code = 25830 	if  district==22
replace gaul_adm2_code = 41749 	if  district==23
replace gaul_adm2_code = 25846 	if  district==31
replace gaul_adm2_code = 25848 	if  district==32
replace gaul_adm2_code = 25847 	if  district==33
replace gaul_adm2_code = 25839 	if  district==41
replace gaul_adm2_code = 25841 	if  district==42
replace gaul_adm2_code = 25843 	if  district==43
replace gaul_adm2_code = 25842 	if  district==44
replace gaul_adm2_code = 25840 	if  district==45
replace gaul_adm2_code = 25833 	if  district==51
replace gaul_adm2_code = 25832 	if  district==52
replace gaul_adm2_code = 25834 	if  district==53
replace gaul_adm2_code = 25837 	if  district==61
replace gaul_adm2_code = 25838 	if  district==62
replace gaul_adm2_code = 25835 	if  district==71
replace gaul_adm2_code = 25836 	if  district==72
replace gaul_adm2_code = 25849 	if  district==81
replace gaul_adm2_code = 25850 	if  district==82
replace gaul_adm2_code = 25845 	if  district==91
replace gaul_adm2_code = 25844 	if  district==92
*<_gaul_adm2_code_>

*<_subnatid1_sar_>
*<_subnatid1_sar_note_> Subnational ID - highest level *</_subnatid1_sar_note_>
/*<_subnatid1_sar_note_> Subnational id - subnational regional identifiers at which survey is representative - highest level *</_subnatid1_sar_note_>*/
*<_subnatid1_sar_note_>  *</_subnatid1_sar_note_>
gen   subnatid1_sar = subnatid1
notes subnatid1_sar: Province Level
notes subnatid1_sar: Representative
*</_subnatid1_sar_>

*<_subnatid2_sar_>
*<_subnatid2_sar_note_> Subnational ID - second highest level *</_subnatid2_sar_note_>
/*<_subnatid2_sar_note_> Subnational id - subnational regional identifiers at which survey is representative - second highest level *</_subnatid2_sar_note_>*/
*<_subnatid2_sar_note_>  *</_subnatid2_sar_note_>
gen   subnatid2_sar = subnatid2
notes subnatid2_sar: District Level
notes subnatid2_sar: Representative
*</_subnatid2_sar_>

*<_subnatid3_sar_>
*<_subnatid3_sar_note_>  Subnational ID - third highest level *</_subnatid3_sar_note_>
/*<_subnatid3_sar_note_> Subnational id - subnational regional identifiers at which survey is representative - third highest level *</_subnatid3_sar_note_>*/
*<_subnatid3_sar_note_>  *</_subnatid3_sar_note_>
gen   subnatid3_sar = ""
notes subnatid3_sar: the survey does not have a smaller level of representativeness than division by urban and rural (used in subnatid2)
*</_subnatid3_sar_>   

*<_subnatid4_sar_>
*<_subnatid4_sar_note_>  Subnational ID - third highest level *</_subnatid4_sar_note_>
/*<_subnatid4_sar_note_> Subnational id - subnational regional identifiers at which survey is representative - fourth highest level *</_subnatid4_sar_note_>*/
*<_subnatid4_sar_note_>  *</_subnatid4_sar_note_>
gen   subnatid4_sar = ""
notes subnatid4_sar: the survey does not have a smaller level of representativeness than division by urban and rural (used in subnatid2)
*</_subnatid4_sar_>
 

****************************************************************
**** DWELLING CHARACTERISTICS
****************************************************************

*<_ownhouse_>
*<_ownhouse_note_> SARMD ownhouse variable *</_ownhouse_note_>
/*<_ownhouse_note_> Refers to ownership status of the dwelling unit by the household residing in it.     *</_ownhouse_note_>*/
*<_ownhouse_note_>  1 "Ownership/secure rights" 2 "Renting" 3 "Provided for free" 4 "Without permission" *</_ownhouse_note_>
gen byte ownhouse = .
replace ownhouse = 1 		if  ownership==1 | ownership==2		/* constructed/purchased or inherited												*/
replace ownhouse = 2 		if  ownership==7 | ownership==8		/* rent or lease																	*/
replace ownhouse = 3 		if  ownership>=3 & ownership<=6 		/* freely received/received as a gift or compensated or rent free or relief payment	*/
replace ownhouse = 4			if  ownership==9						/* encroached																		*/
notes   ownhouse: missing values are cases in which the raw data variables is "other"
*</_ownhouse_>

*<_typehouse_>
*<_typehouse_note_> GMD ownhouse variable *</_typehouse_note_>
*<_typehouse_note_> typehouse brought in from GMD *</_typehouse_note_>
clonevar typehouse = ownhouse
*</_typehouse_>

*<_tenure_>
gen 	tenure = .
replace tenure = 1 			if  ownership>=1 & ownership<=4
replace tenure = 2 			if  ownership>=5 & ownership<=8 
replace tenure = 3 			if  tenure==.
*</_tenure_>

*<_water_orig_>
*<_water_orig_note_> Source of Drinking Water-Original from raw file *</_water_orig_note_>
/*<_water_orig_note_> Original categories from source of drinking water *</_water_orig_note_>*/
*<_water_orig_note_>  *</_water_orig_note_>
label define drinking_water 1 "1 - Protected Well" 2 "2 - Unprotected Well" 3 "3 - Tubewell" 4 "4 - Tap Water (national water supply and drainage board)" 5 "5 - Tap Water (Community based water supply and management organizations)" 6 "6 - Tap Water (Local government institutions)" 7 "7 - Tap Water (Private water projects)" 8 "8 - River/Tank/Streams" 9 "9 - Rainwater" 10 "10 - Bottled Water" 11 "11 - Bowser" 12 "12 - Filter Water" 99 "99 - Other(Specify)"
label values drinking_water drinking_water
decode drinking_water, gen(water_orig)
*</_water_orig_>

*<_water_source_>
*<_water_source_note_> Sources of drinking water *</_water_source_note_>
/*<_water_source_note_> 1 "Piped water into dwelling" 2 "Piped water to yard/plot" 3 "Public tap or standpipe" 4 "Tube well or borehole" 5 "Protected dug well" 6 "Protected spring" 7 "Bottled water" 8 "Rainwater" 9 "Unprotected spring" 10 "Unprotected dug well" 11 "Cart with small tank/drum" 12 "Tanker-truck" 13 "Surface water" 14 "Other" *</_water_source_note_>*/
*<_water_source_note_> water_source brought in from rawdata *</_water_source_note_>
gen     water_source = .
replace water_source = 1			if  drinking_water>=4 & drinking_water<=7 & s8_6b1_inside_outside==1
replace water_source = 3			if  drinking_water>=4 & drinking_water<=7 & s8_6b1_inside_outside==2
replace water_source = 4			if  drinking_water==3
replace water_source = 5			if  drinking_water==1
replace water_source = 7			if  drinking_water==10  
replace water_source = 8			if  drinking_water==9
replace water_source = 10			if  drinking_water==2
replace water_source = 12			if  drinking_water==11
replace water_source = 13			if  drinking_water==8
replace water_source = 14			if  drinking_water==99 | drinking_water==12 
*</_water_source_>

*<_water_jmp_>
*<_water_jmp_note_> Source of drinking water, using Joint Monitoring Program categories *</_water_jmp_note_>
/*
/*<_water_jmp_note_> Variable taking categories based on JMP guidelines. This variable is created from question asking about main source of drinking water. Ambigous categories are classified as missing/other *</_water_jmp_note_>*/
*<_wate_jmp_note_> 1 "Piped into dwelling" 2 "Piped into compound, yard or plot" 3 "Public tap/standpipe" 4 "Tubewell, Borehole" 5 "Protected well" 6 "Unprotected well" 7 "Protected spring" 8 "Unprotected spring" 9 "Rain water" 10 "Tanker-truck or other vendor" 11 "Cart with small tank/drum" 12 "Surface water (river, stream, dam, lake, pond) 13 "Bottled water" 14 "Other" *</_wate_jmp_note_>
*/
gen 	water_jmp = .
replace water_jmp = 1 			if  drinking_water>=4 & drinking_water<=7 & s8_6b1_inside_outside==1
replace water_jmp = 3 			if  drinking_water>=4 & drinking_water<=7 & s8_6b1_inside_outside==2
replace water_jmp = 4 			if  drinking_water==3
replace water_jmp = 5 			if  drinking_water==1 
replace water_jmp = 6 			if  drinking_water==2
replace water_jmp = 9  			if  drinking_water==9
replace water_jmp = 10 			if  drinking_water==11
replace water_jmp = 12 			if  drinking_water==8
replace water_jmp = 13 			if  drinking_water==10 | drinking_water==12
replace water_jmp = 14 			if  drinking_water==99
*</_water_jmp_>

*<_piped_water_>
*<_piped_water_note_> Household has access to piped water *</_piped_water_note_>
/*<_piped_water_note_> Variable takes the value of 1 if household has access to piped water. *</_piped_water_note_>*/
*<_piped_water_note_>  1 "Yes" 0 "No" *</_piped_water_note_>
gen 	piped_water = .
replace piped_water = 0			if  drinking_water!=.
replace piped_water = 1			if  drinking_water>=4 & drinking_water<=7		
*</_piped_water_>

*<_pipedwater_acc_>
*<_pipedwater_acc_note_> Access to piped water *</_pipedwater_acc_note_>
/*<_pipedwater_acc_note_>  *</_pipedwater_acc_note_>*/
*<_pipedwater_acc_note_> piped  brought in from rawdata *</_pipedwater_acc_note_>
gen  	pipedwater_acc = 0		if  drinking_water!=.
replace pipedwater_acc = 1		if  drinking_water>=4 & drinking_water<=7 & s8_6b1_inside_outside==1
replace pipedwater_acc = 2		if  drinking_water>=4 & drinking_water<=7 & s8_6b1_inside_outside==2
*</_pipedwater_acc_>

*<_sar_improved_water_>
*<_sar_improved_water_note_> Improved source of drinking water-using country-specific definitions *</_sar_improved_water_note_>
/*<_sar_improved_water_note_> Dummy variable: 1=improved, 0=unimproved source following JMP guidelines *</_sar_improved_water_note_>*/
*<_sar_improved_water_note_>  1 "Yes" 0 "No" *</_sar_improved_water_note_>
gen  	sar_improved_water = .
replace sar_improved_water = 1	if (water_jmp>=1 & water_jmp<=5) | water_jmp==7 | water_jmp==9
replace sar_improved_water = 0	if  water_jmp==6 | water_jmp==8 | (water_jmp>=10 & water_jmp<=14)
*</_sar_improved_water_>

*<_improved_water_>
*<_improved_water_note_> Improved source of drinking water-using country-specific definitions *</_improved_water_note_>
/*<_improved_water_note_> Dummy variable: 1=improved, 0=unimproved source following JMP guidelines *</_improved_water_note_>*/
*<_improved_water_note_>  1 "Yes" 0 "No" *</_improved_water_note_>
gen improved_water = sar_improved_water
*</__improved_water_>

*<_watertype_quest_>
gen watertype_quest = 1
*</_watertype_quest_>

*<_toilet_orig_>
*<_toilet_orig_note_> sanitation facility original *</_toilet_orig_note_>
/*<_toilet_orig_note_> Original categories from access to toilet *</_toilet_orig_note_>*/
*<_toilet_orig_note_>  *</_toilet_orig_note_>
label define toilet_type 1 "1 - Water seal connected to septic tank" 2 "2 - Water seal connected to a pit" 3 "3 - Water seal connected to sewer system" 4 "4 - Water seal connected to a river or a drain" 5 "5 - Not water seal pit latrine with deck" 6 "6 - Not water seal open pit latrine without deck" 7 "7 - No facility, bush/field" 9 "9 - Other"
label values toilet_type toilet_type
decode toilet_type, gen(toilet_orig)
*</_toilet_orig_>

*<_sanitation_source_>
*<_sanitation_source_note_> Sources of sanitation facilities *</_sanitation_source_note_>
/*<_sanitation_source_note_> 1 "A flush toilet" 2 "A piped sewer system" 3 "A septic tank" 4 "Pit latrine" 5 "Ventilated improved pit latrine (VIP)" 6 "Pit latrine with slab" 7 "Composting toilet" 8 "Special case" 9 "A flush/pour flush to elsewhere" 10 "A pit latrine without slab" 11 "Bucket" 12 "Hanging toilet or hanging latrine" 13 "No facilities or bush or field" 14 "Other" *</_sanitation_source_note_>*/
*<_sanitation_source_note_> sanitation_source brought in from rawdata *</_sanitation_source_note_>
gen     sanitation_source = .
replace sanitation_source = 2		if  toilet_type==3
replace sanitation_source = 3		if  toilet_type==1
replace sanitation_source = 4		if  toilet_type==2
replace sanitation_source = 6		if  toilet_type==5
replace sanitation_source = 9		if  toilet_type==4
replace sanitation_source = 10	if  toilet_type==6
replace sanitation_source = 13	if  toilet_type==7
replace sanitation_source = 14	if  toilet_type==9
*</_sanitation_source_>

*<_sewage_toilet_>
*<_sewage_toilet_note_> Household has access to sewage toilet *</_sewage_toilet_note_>
/*<_sewage_toilet_note_> Variable takes the value of 1 if household has access to sewage toilet. *</_sewage_toilet_note_>*/
*<_sewage_toilet_note_>  1 "Yes" 0 "No" *</_sewage_toilet_note_>
gen     sewage_toilet = .
replace sewage_toilet = 0		if  toilet_type!=.
replace sewage_toilet = 1		if  toilet_type==3 	
*</_sewage_toilet_>

*<_toilet_jmp_>
*<_toilet_jmp_note_> Access to sanitation facility-using Joint Monitoring Program categories *</_toilet_jmp_note_>
/*<_toilet_jmp_note_> Variable taking categories based on JMP guidelines. This variable is created from question asking about toilet type. Ambigous categories are classified as missing/other *</_toilet_jmp_note_>*/
*<_toilet_jmp_note_> 1 "Flush to piped sewer system" 2 "Flush to septic tank" 3 "Flush to pit latrine" 4 "Flush to somewhere else" 5 "Flush, don't know where" 6 "Ventilated improved pit latrine" 7 "Pit latrine with slab" 8 "Pit latrine without slab/open pit" 9 "Composting toilet" 10 "Bucket toilet" 11 "Hanging toilet/Hanging latrine" 12 "No facility/bush/field" 13 "Other" *</_toilet_jmp_note_>
gen 	toilet_jmp = .
replace toilet_jmp = 1		if  toilet_type==3
replace toilet_jmp = 2		if  toilet_type==1
replace toilet_jmp = 3		if  toilet_type==2
replace toilet_jmp = 4		if  toilet_type==4
replace toilet_jmp = 7		if  toilet_type==5
replace toilet_jmp = 8		if  toilet_type==6
replace toilet_jmp = 12		if  toilet_type==7
replace toilet_jmp = 13		if  toilet_type==9
*</_toilet_jmp_>

*<_sar_improved_toilet_>
*<_sar_improved_toilet_note_> Improved type of sanitation facility-using country-specific definitions *</_sar_improved_toilet_note_>
/*<_sar_improved_toilet_note_> Dummy variable: 1=improved, 0=unimproved source following JMP guidelines *</_sar_improved_toilet_note_>*/
*<_sar_improved_toilet_note_>  1 "Yes" 0 "No" *</_sar_improved_toilet_note_>
gen 	sar_improved_toilet = .
replace sar_improved_toilet = 1	if (toilet_jmp>=1 & toilet_jmp<=3) | toilet_jmp==6 | toilet_jmp==7 | toilet_jmp==9
replace sar_improved_toilet = 0	if  toilet_jmp==4 | toilet_jmp==5 | (toilet_jmp>=8 & toilet_jmp<=13)
*</_sar_improved_toilet_>

*<_improved_sanitation_>
*<_improved_sanitation_note_> Improved type of sanitation facility-using country-specific definitions *</_improved_sanitation_note_>
/*<_improved_sanitation_note_> Dummy variable: 1=improved, 0=unimproved source following JMP guidelines *</_improved_sanitation_note_>*/
*<_improved_sanitation_note_>  1 "Yes" 0 "No" *</_improved_sanitation_note_>
clonevar improved_sanitation = sar_improved_toilet
*</_improved_sanitation_>

*<_toilet_acc_>
gen 	toilet_acc = 1 				if  improved_sanitation==1 & tioilet_use>=1 & tioilet_use<=2
replace toilet_acc = 2 				if  improved_sanitation==1 & tioilet_use>=3 & tioilet_use<=5
replace toilet_acc = 0 				if  improved_sanitation==0 
*</_toilet_acc_>

*<_shared_toilet_>
gen 	shared_toilet = 1 			if  tioilet_use==2 | tioilet_use==3 | tioilet_use==4
replace shared_toilet = 0 			if  tioilet_use==1 
replace shared_toilet = .				if  toilet_acc==0
*</_shared_toilet_>

*<_electricity_>
*<_electricity_note_> Access to electricity *</_electricity_note_>
/*<_electricity_note_> Refers to Public or quasi public service availability of electricity from mains. 
Note that having an electrical connection says nothing about the actual electrical service received by the household in a given country or area.
This variable must have the same value for all members of the household *</_electricity_note_>*/
*<_electricity_note_> 1 "Yes" 0 "No" *</_electricity_note_>
gen 	electricity = .
replace electricity = 0				if  lite_source!=.
replace electricity = 1				if  lite_source==1 | lite_source==2
*</_electricity_>

*<_lphone_>
*<_lphone_note_> Household has landphone *</_lphone_note_>
/*<_lphone_note_> Availability of landphones in household. Question on quantity or specific availability should be present *</_lphone_note_>*/
*<_lphone_note_>  1 "Yes" 0 "No" *</_lphone_note_>
gen 	lphone = .
replace lphone = 0					if  telephone==2
replace lphone = 1					if  telephone==1
clonevar landphone = lphone
*</_lphone_>

*<_cellphone_>
*<_cellphone_note_> Own mobile phone (at least one) *</_cellphone_note_>
/*<_cellphone_note_> Refers to cell phone availability in the household.
This variable is only constructed if there is an explicit question about cell phones availability.
This variable must have the same value for all members of the household. *</_cellphone_note_>*/
*<_cellphone_note_>  1 "Yes" 0 "No" *</_cellphone_note_>
gen 	cellphone = .
replace cellphone = 1				if  telephone_mobile==1
replace cellphone = 0				if  telephone_mobile==2
*</_cellphone_>

*<_computer_>
*<_computer_note_> Own Computer *</_computer_note_>
/*<_computer_note_> Presence of a computer. Refers to actual ownership of the asset irrespective of who owns it within the household and regardless of what condition the asset is in. 
This variable is only constructed if there is an explicit question about computer *</_computer_note_>*/
*<_computer_note_>  1 "Yes" 0 "No" *</_computer_note_>
gen 	computer = .
replace computer = 0					if  computers==2
replace computer = 1					if  computers==1
*</_computer_>

*<_internet_>
*<_internet_note_>  Internet connection *</_internet_note_>
/*<_internet_note_> Availability of internet connection. Refers to internet connection availability at home irrespective of who owns it within the household. 
This variable is only constructed if there is an explicit question about internet connection. 
This variab *</_internet_note_>*/
*<_internet_note_>  1 "Yes" 0 "No" *</_internet_note_>
gen   internet = .
notes internet: there is not an explicit question about Internet connection in the survey (although there is a question about availability of wifi router)
*</_internet_>


****************************************************************
**** DEMOGRAPHIC CHARACTERISTICS
****************************************************************

*<_hsize_>
*<_hsize_note_> Household size *</_hsize_note_>
/*<_hsize_note_> specifies varname for the household size number in the data file. It has to be compatible with the numbers of national and international poverty at household size when weights are used in any computation *</_hsize_note_>*/
*<_hsize_note_>  *</_hsize_note_>
gen hsize = hhsize
*</_hsize_>

*<_relationcs_>
*<_relationcs_note_> Relationship to head of household country/region specific *</_relationcs_note_>
/*<_relationcs_note_> country or regionally specific categories *</_relationcs_note_>*/
*<_relationcs_note_>  1 "Head of the household" 2 "Wife/Husband" 3 "Son/Daughter" 4 "Parents of head of the household/spouse" 5 "Other Relative" 6 "Domestic Servant/Driver/Watcher" 7 "Boarder" 9 "Other" *</_relationcs_note_>
label define relationship 1 "1 - Head of the household" 2 "2 - Wife/Husband" 3 "3 - Son/Daughter" 4 "4 - Parents of head of the household/spouse" 5 "5 - Other Relative" 6 "6 - Domestic Servant/Driver/Watcher" 7 "7 - Boarder" 9 "9 - Other"
label values relationship relationship
decode relationship, gen(relationcs)
*</_relationcs_>

*<_relationharm_>
*<_relationharm_note_> Relationship to head of household harmonized across all regions *</_relationharm_note_>
/*<_relationharm_note_> Harmonized categories across all regions. *</_relationharm_note_>*/
*<_relationharm_note_>  1 "Head" 2 "Spouse" 3 "Child" 4 "Parents" 5 "Other relative" 6 "Non-relative" *</_relationharm_note_>
gen 	relationharm = .
replace relationharm = 1		if  relationship==1
replace relationharm = 2		if  relationship==2
replace relationharm = 3		if  relationship==3
replace relationharm = 4		if  relationship==4
replace relationharm = 5		if  relationship==5 
replace relationharm = 6		if  relationship==6 | relationship==7 | relationship==9
notes relationharm: there 137 observations with missing values, they correspond to code = 99 ("other")
*</_relationharm_>

*<_age_>
*<_age_note_> Age of individual (continuous) *</_age_note_>
/*<_age_note_> Age is an important variable for most socio-economic analysis and must be established as accurately as possible. Especially for children aged less than 5 years, this is used to interpret Anthropometrics data. Ages >= 98 must be coded as 98.  (N *</_age_note_>*/
*<_age_note_>  *</_age_note_>
*</_age_>

*<_male_>
*<_male_note_> Sex of household member (male=1) *</_male_note_>
/*<_male_note_> specifies varname for sex of household member (head), where 1 = Male and 0 = Female. *</_male_note_>*/
*<_male_note_>  1 " Male" 0 "Female" *</_male_note_>
gen 	male = .
replace male = 0		if  sex==2
replace male = 1		if  sex==1
*</_male_>

*<_soc_>
*<_soc_note_> Social group *</_soc_note_>
/*<_soc_note_> The classification is country specific.
It not needs to be present for every country/year. *</_soc_note_>*/
*<_soc_note_>  *</_soc_note_>
gen 	soc = "."
replace soc = "1 - Sinhala"					if  ethnicity==1
replace soc = "2 - Sri Lanka Tamil"			if  ethnicity==2
replace soc = "3 - Indial Tamil"				if  ethnicity==3
replace soc = "4 - Sri Lanka Moors/Muslim"	if  ethnicity==4
replace soc = "5 - Burgher"					if  ethnicity==5
replace soc = "6 - Malay"					if  ethnicity==6
replace soc = "9 - Other"					if  ethnicity==9
*</_soc_>

*<_marital_>
*<_marital_note_> Marital status *</_marital_note_>
/*<_marital_note_> Do not impute.  Calculate only for those to whom the question was asked (in other words, the youngest age at which information is collected may differ depending on the survey). Living together includes common-law marriages, union coutumiere, uni *</_marital_note_>*/
*<_marital_note_>  1 "Married" 2 "Never married" 3 "Living together" 4 "Divorced/Separated" 5 "Widowed" *</_marital_note_>
gen 	marital = .
replace marital = 1							if  marital_status==2 | marital_status==3
replace marital = 2 							if  marital_status==1
replace marital = 4 							if  marital_status>=5 & marital_status<=7
replace marital = 5 							if  marital_status==4
*</_marital_>

*<_rbirth_juris_>
*<_rbirth_juris_note_>  Region of Birth Jurisdiction *</_rbirth_juris_note_>
/*<_rbirth_juris_note_> Variable is constructed for all persons administered this module in each questionnaire.  It identifies the level at which region of birth is coded in the survey  *</_rbirth_juris_note_>*/
*<_rbirth_juris_note_>  *</_rbirth_juris_note_>
gen   rbirth_juris = .
notes rbirth_juris: HIES does not collect the information needed to define this variable
*</_rbirth_juris_>

*<_rbirth_>
*<_rbirth_note_>  Region of Birth *</_rbirth_note_>
/*<_rbirth_note_> Corresponds to reg01 if rbirth_juris=1, reg02 if rbirth_juris=2, reg03 if rbirth_juris=3, ISO 3166-1 if rbirth_juris=5, and original code if rbirth_juris=9 *</_rbirth_note_>*/
*<_rbirth_note_>  *</_rbirth_note_>
gen   rbirth = .
notes rbirth: HIES does not collect the information needed to define this variable
*</_rbirth_>

*<_rprevious_juris_>
*<_rprevious_juris_note_>  Region of previous residence *</_rprevious_juris_note_>
/*<_rprevious_juris_note_> Variable is constructed for all persons administered this module in each questionnaire.  It identifies the level at which previous region is coded in the survey  *</_rprevious_juris_note_>*/
*<_rprevious_juris_note_>  *</_rprevious_juris_note_>
gen   rprevious_juris = .
notes rprevious_juris: HIES does not collect the information needed to define this variable
*</_rprevious_juris_>

*<_rprevious_>
*<_rprevious_note_>  Region Previous Residence *</_rprevious_note_>
/*<_rprevious_note_> Corresponds to reg01 if rprevious_juris=1, reg02 if rprevious_juris=2, reg03 if rprevious_juris=3, ISO 3166-1 if rprevious_juris=5, and original code if rbitrh_juris=9 *</_rprevious_note_>*/
*<_rprevious_note_>  *</_rprevious_note_>
gen   rprevious = .
notes rprevious: HIES does not collect the information needed to define this variable
*</_rprevious_>

*<_yrmove_>
*<_yrmove_note_>  Year of most recent move *</_yrmove_note_>
/*<_yrmove_note_> Indicates year of most recent move from rprevious *</_yrmove_note_>*/
*<_yrmove_note_>  *</_yrmove_note_>
gen   yrmove = .
notes yrmove: HIES does not collect the information needed to define this variable
*</_yrmove_>


****************************************************************
**** EDUCATION VARIABLES
****************************************************************

*<_ed_mod_age_>
*<_ed_mod_age_note_> Education module application age *</_ed_mod_age_note_>
/*<_ed_mod_age_note_> Age at which the education module starts being applied *</_ed_mod_age_note_>*/
*<_ed_mod_age_note_>  *</_ed_mod_age_note_>
gen   ed_mod_age = 5
notes ed_mod_age: education module is applied to all persons 5 years and above
*</_ed_mod_age_>

*<_literacy_>
*<_literacy_note_> Individual can read and write *</_literacy_note_>
/*<_literacy_note_> Variable is constructed for all persons administered this module in each questionnaire.  For this reason the lower age cutoff at which information is collected will vary from country to country. Value must be missing for all others. No imputatio *</_literacy_note_>*/
*<_literacy_note_>  1 "Yes" 0 "No" *</_literacy_note_>
gen   literacy = .
notes literacy: HIES does not include information on this topic
*</_literacy_>

*<_atschool_>
*<_atschool_note_> Attending school *</_atschool_note_>
/*<_atschool_note_> Variable is constructed for all persons administered this module in each questionnaire, typically of primary age and older.  For this reason the lower age cutoff will vary from country to country. 
If person on short school holiday when interviewed *</_atschool_note_>*/
*<_atschool_note_>  1 "Yes" 0 "No" *</_atschool_note_>
gen 	atschool = .
replace atschool = 0			if  curr_educ==9 | curr_educ==1
replace atschool = 1			if  curr_educ>=2 & curr_educ<=6
*</_atschool_>

*<_educy_>
*<_educy_note_> Years of education *</_educy_note_>
/*<_educy_note_> Variable is constructed for all persons administered this module in each questionnaire. For this reason the lower age cutoff at which information is collected will vary from country to country. 
This is a continuous variable of the number of years of formal schooling completed *</_educy_note_>*/
*<_educy_note_>  *</_educy_note_>
gen 	educy = education
replace educy = .			if  educy==18
replace educy = 0			if  educy==19
replace educy = 0 			if  r2_school_edu==2 
replace educy = 17			if  education==15
replace educy = 19			if  education==16 | education==17
replace educy = . 			if  age<ed_mod_age
replace educy = . 			if  educy>age & educy!=. & age!=.
notes   educy: it was assumed that "Passed G.C.E.(O/L) or equivalent" is equivalent to 11 years of education 
notes   educy: it was assumed that "Passed G.C.E.(A/L) or equivalent" is equivalent to 13 years of education 
notes   educy: it was assumed that "Passed GAQ/GSQ or equivalent" is equivalent to 14 years of education 
notes   educy: it was assumed that "Passed Degree" is equivalent to 17 years of education 
notes   educy: it was assumed that "Passed Post-Graduate Degree/Diploma" is equivalent to 19 years of education 
notes   educy: it was assumed that "PHD" is equivalent to 19 years of education 
*</_educy_>


*<_educat7_>
*<_educat7_note_> Level of education 7 categories *</_educat7_note_>
/*<_educat7_note_> Secondary is everything from the end of primary to before tertiary (for example, grade 7 through 12). Vocational training is country-specific and will be defined by each region.  *</_educat7_note_>*/
*<_educat7_note_>  1 "No education" 2 "Primary incomplete" 3 "Primary complete" 4 "Secondary incomplete" 5 "Secondary complete" 6 "Post secondary but not university" 7 "University" *</_educat7_note_>
gen	 	educat7 = .
replace educat7 = 1		if  education==19 | r2_school_edu==2
replace educat7 = 2		if  education>=0  & education<=4
replace educat7 = 3		if  education==5
replace educat7 = 4		if  education>=6  & education<=10
replace educat7 = 5		if  education==11
replace educat7 = 6		if  education>=12 & education<=14
replace educat7 = 7		if  education>=15 & education<=17
*</_educat7_>

*<_educat5_>
*<_educat5_note_> Level of education 5 categories *</_educat5_note_>
/*<_educat5_note_> At least educat4 will have to be included (if it is unclear whether primary or secondary is completed or not). If educat5 is available, educat4 can be created. Secondary is everything from the end of primary to before tertiary (for example, grad *</_educat5_note_>*/
*<_educat5_note_>  1 "No education" 2 "Primary incomplete" 3 "Primary complete but Secondary incomplete" 4 "Secondary complete" 5 "Tertiary (completed or incomplete)" *</_educat5_note_>
recode educat7 (1=1) (2=2) (3 4=3) (5=4) (6 7=5), gen(educat5)
label define lbleducat5 1 "No education" 2 "Primary incomplete" 3 "Primary complete but secondary incomplete" 4 "Secondary complete" 5 "Some tertiary/post-secondary"
label values educat5 lbleducat5
label var educat5 "Level of education 5 categories"
*</_educat5_>

*<_educat4_>
*<_educat4_note_> Level of education 4 categories *</_educat4_note_>
/*<_educat4_note_> At least educat4 will have to be included (if it is unclear whether primary or secondary is completed or not). If educat5 is available, educat4 can be created. Secondary is everything from the end of primary to before tertiary (for example, grad *</_educat4_note_>*/
*<_educat4_note_>  1 "No education" 2 "Primary (complete or incomplete)" 3 "Secondary (complete or incomplete)" 4 "Tertiary (complete or incomplete)" *</_educat4_note_>
recode educat7 (1=1) (2 3=2) (4 5=3) (6 7=4), gen(educat4)
label define lbleducat4 1 "No education" 2 "Primary (complete or incomplete)" 3 "Secondary (complete or incomplete)" 4 "Tertiary (complete or incomplete)"
label values educat4 lbleducat4
label var educat4 "Level of education 4 categories"
*</_educat4_>

*<_everattend_>
*<_everattend_note_> Ever attended school *</_everattend_note_>
/*<_everattend_note_> All persons of primary school age or above. `Primary school age’ will vary by country. 
This is country-specific and depends on how school attendance is defined. Pre-school is not included here. Also, in some countries, ever attended is yes  *</_everattend_note_>*/
*<_everattend_note_>  1 "Yes" 0 "No" *</_everattend_note_>
gen 	everattend = .
replace everattend = 0	if  curr_educ==9 | curr_educ==1 | education==19
replace everattend = 1	if  curr_educ>=2 & curr_educ<=6
replace everattend = 1	if  education>=1 & education<=18
replace everattend = 1	if  atschool==1
*</_everattend_>

foreach v of varlist educat7 educat5 educat4 educy atschool literacy everattend { 
	replace `v'=. if age<ed_mod_age 
}


****************************************************************
**** LABOR VARIABLES
****************************************************************

*<_lb_mod_age_>
*<_lb_mod_age_note_> Labor module application age *</_lb_mod_age_note_>
/*<_lb_mod_age_note_> Age at which the labor module starts being applied (working age: people at which can start legally working) *</_lb_mod_age_note_>*/
*<_lb_mod_age_note_>  *</_lb_mod_age_note_>
gen   lb_mod_age = 15
notes lb_mod_age: the general questions on employment are applied to persons 15 years and above
*</_lb_mod_age_>

*<_lstatus_>
*<_lstatus_note_> Labor Force Status *</_lstatus_note_>
/*<_lstatus_note_> Variable is constructed for all persons administered this module in each questionnaire.  For this reason the lower age cutoff (and perhaps upper age cutoff) at which information is collected will vary from country to country. 
All persons are co *</_lstatus_note_>*/
*<_lstatus_note_>  1 "Employed" 2 "Unemployed" 3 "Not in labor force" *</_lstatus_note_>
gen 	lstatus = .
replace lstatus = 1		if  main_activity>=1 & main_activity<=2 
replace lstatus = 2		if  main_activity==3
replace lstatus = 3		if  main_activity>=4 & main_activity<=99
replace lstatus = 1		if  is_active==1
replace lstatus = 3		if  is_active==2 & lstatus==1
notes   lstatus: period of reference is the last week 
*</_lstatus_>

*<_nlfreason_>
*<_nlfreason_note_> Reason not in the labor force *</_nlfreason_note_>
/*<_nlfreason_note_> This variable is constructed for all those who are not presently employed and are not looking for work (lstatus=3) and missing otherwise.
Student, the person is studying. 
Housekeeping is the person takes care of the house, older people, or chil *</_nlfreason_note_>*/
*<_nlfreason_note_> 1 "Student" 2 "Housewife" 3 "Retired" 4 "Disabled" 5 "Others" *</_nlfreason_note_>
gen 	nlfreason = .
replace nlfreason = 1	if  main_activity==8
replace nlfreason = 2	if  main_activity==7
replace nlfreason = 4	if  main_activity>=4 & main_activit<=6
replace nlfreason = 3	if  main_activity==9
replace nlfreason = 5	if  main_activity==99
replace nlfreason = .	if  lstatus!=3
notes   nlfreason: period of reference is the last week
*</_nlfreason_>

*<_njobs_>
*<_njobs_note_>  Number of total jobs *</_njobs_note_>
/*<_njobs_note_> Number of jobs besides the main one coming from main occupation *</_njobs_note_>*/
gen 	njobs = .
replace njobs = aux_jobs
drop aux*
*</_njobs_>

*<_unempldur_l_>
*<_unempldur_l_note_> Unemployment duration (months) lower bracket *</_unempldur_l_note_>
/*<_unempldur_l_note_> Variable is constructed for all persons who are unemployed (lstatus=2, otherwise missing). If continuous records the numbers of months in unemployment. If the variable is categorical it records the lower boundary of the bracket. *</_unempldur_l_note_>*/
*<_unempldur_l_note_>  *</_unempldur_l_note_>
gen   unempldur_l = .
notes unempldur_l: the HIES does not contain the information needed to define this variable
*</_unempldur_l_>

*<_unempldur_u_>
*<_unempldur_u_note_> Unemployment duration (months) upper bracket *</_unempldur_u_note_>
/*<_unempldur_u_note_> Variable is constructed for all persons who are unemployed (lstatus=2, otherwise missing). If continuous records the numbers of months in unemployment. If the variable is categorical it records the upper boundary of the bracket. If the right bra *</_unempldur_u_note_>*/
*<_unempldur_u_note_>  *</_unempldur_u_note_>
gen   unempldur_u = .
notes unempldur_u: the HIES does not contain the information needed to define this variable
*</_unempldur_u_>

*<_industry_orig_>
*<_industry_orig_note_> Original industry codes - main job - last 7 days *</_industry_orig_note_>
/*<_industry_orig_note_>  *</_industry_orig_note_>*/
*<_industry_orig_note_>   *</_industry_orig_note_>
gen     industry_orig = industry
replace industry_orig = .		if  lstatus!=1
*</_industry_orig_>

*<_industry_>
*<_industry_note_> 1 digit industry classification - main job - last 7 days *</_industry_note_>
/*<_industry_note_> Variable is constructed for all persons administered this module in each questionnaire. For this reason the lower age cutoff (and perhaps upper age cutoff) at which information is collected will vary from country to country. Classifies the main job of any individual with a job (lstatus=1) and is missing otherwise. The codes for the main job are given here based on the UN-ISIC (Rev. 3.1). The main categories subsume the following codes: 1 = Agriculture, Hunting, Fishing and Forestry 2 = Mining 3 = Manufacturing 4 = Electricity and Utilities 5 = Construction 6 = Commerce 7 = Transportation, Storage and Communication 8 = Financial, Insurance and Real Estate 9 = Public Administration 10 = Other Services. In the case of different classifications, recoding has been done to best match the ISIC-31 codes. Code 10 is also assigned for unspecified categories or items. *</_industry_note_>*/
*<_industry_note_>  *</_industry_note_>
rename industry industry_hies
gen aux_industry = round(industry_hies/1000)

gen 	industry = .
replace industry = 1			if   aux_industry>=1  & aux_industry<=3
replace industry = 2			if   aux_industry>=5  & aux_industry<=9
replace industry = 3			if   aux_industry>=10 & aux_industry<=33
replace industry = 4			if   aux_industry>=35 & aux_industry<=39
replace industry = 5			if   aux_industry>=41 & aux_industry<=44
replace industry = 6			if   aux_industry>=45 & aux_industry<=48
replace industry = 7			if   aux_industry>=49 & aux_industry<=63
replace industry = 8			if   aux_industry>=64 & aux_industry<=83
replace industry = 9			if   aux_industry==84
replace industry = 10		if   aux_industry>=85 & aux_industry<=100
replace industry = .			if   lstatus!=1
*</_industry_>

*<_industry_orig_year_>
*<_industry_orig_year_note_> Original industry codes - main job - last 12 months *</_industry_orig_year_note_>
/*<_industry_orig_year_note_>  *</_industry_orig_year_note_>*/
*<_industry_orig_year_note_>   *</_industry_orig_year_note_>
gen   industry_orig_year = .
notes industry_orig_year: the HIES does not contain the information needed to define this variable
*</_industry_orig_year_>

*<_industry_year_>
*<_industry_year_note_> 1 digit industry classification - main job - last 12 months *</_industry_year_note_>
/*<_industry_year_note_> Variable is constructed for all persons administered this module in each questionnaire. For this reason the lower age cutoff (and perhaps upper age cutoff) at which information is collected will vary from country to country. Classifies the main job of any individual with a job (lstatus=1) and is missing otherwise. The codes for the main job are given here based on the UN-ISIC (Rev. 3.1). The main categories subsume the following codes: 1 = Agriculture, Hunting, Fishing and Forestry 2 = Mining 3 = Manufacturing 4 = Electricity and Utilities 5 = Construction 6 = Commerce 7 = Transportation, Storage and Communication 8 = Financial, Insurance and Real Estate 9 = Public Administration 10 = Other Services. In the case of different classifications, recoding has been done to best match the ISIC-31 codes. Code 10 is also assigned for unspecified categories or items. *</_industry_year_note_>*/
*<_industry_year_note_>  *</_industry_year_note_>
gen   industry_year = .
notes industry_year: the HIES does not contain the information needed to define this variable
*</_industry_year_>

*<_industry_orig_2_>
*<_industry_orig_2_note_> Original industry codes - second job - last 7 days *</_industry_orig_2_note_>
/*<_industry_orig_2_note_> This variable correspond to whatever is in the original file with no recoding *</_industry_orig_2_note_>*/
*<_industry_orig_2_note_>  *</_industry_orig_2_note_>
gen   industry_orig_2 = .
notes industry_orig_2: the HIES does not contain the information needed to define this variable
*</_industry_orig_2_>

*<_industry_2_>
*<_industry_2_note_>  1 digit industry classification - second job - last 7 days *</_industry_2_note_>
/*<_industry_2_note_> Variable is constructed for all persons administered this module in each questionnaire. For this reason the lower age cutoff (and perhaps upper age cutoff) at which information is collected will vary from country to country.
Classifies the seco *</_industry_2_note_>*/
*<_industry_2_note_>  *</_industry_2_note_>
gen   industry_2 = .
notes industry_2: the HIES does not contain the information needed to define this variable
*</_industry_2_>

*<_industry_orig_2_year_>
*<_industry_orig_2_year_note_> Original industry codes - second job - last 12 months *</_industry_orig_2_year_note_>
/*<_industry_orig_2_year_note_> This variable correspond to whatever is in the original file with no recoding *</_industry_orig_2_year_note_>*/
*<_industry_orig_2_year_note_>  *</_industry_orig_2_year_note_>
gen   industry_orig_2_year = .
notes industry_orig_2_year: the HIES does not contain the information needed to define this variable
*</_industry_orig_2_year_>

*<_industry_2_year_>
*<_industry_2_year_note_>  1 digit industry classification - second job - last 12 months *</_industry_2_year_note_>
/*<_industry_2_year_note_> Variable is constructed for all persons administered this module in each questionnaire. For this reason the lower age cutoff (and perhaps upper age cutoff) at which information is collected will vary from country to country.
Classifies the seco *</_industry_2_year_note_>*/
*<_industry_2_year_note_>  *</_industry_2_year_note_>
gen   industry_2_year = .
notes industry_2_year: the HIES does not contain the information needed to define this variable
*</_industry_2_year_>

*<_occup_>
*<_occup_note_> 1 digit occupational classification - main job - last 7 days *</_occup_note_>
/*<_occup_note_> Variable is constructed for all persons administered this module in each questionnaire. For this reason the lower age cutoff (and perhaps upper age cutoff) at which information is collected will vary from country to country. Classifies the main job of any indiviudal with a job (lstatus=1) and is missing otherwise. The classification is based on the International Standard Classification of Occupations (ISCO) 88. In the case of different classifications re-coding has been done to best match the ISCO-88. *</_occup_note_>*/
*<_occup_note_> 1 "Managers" 2 "Professionals" 3 "Technicians and associate professionals" 4 "Clerical support workers" 5 "Service and sales workers" 6 "Skilled agricultural, forestry and fishery workers" 7 "Craft and related trades workers" 8 "Plant and machine operators, and assemblers" 9 "Elementary occupations" 10 "Armed forces occupations" 99 "Other/unspecified" *</_occup_note_>
gen     occup = .
replace occup = 1		if  main_occupation>=1111 & main_occupation<=1439
replace occup = 2		if  main_occupation>=2111 & main_occupation<=2659
replace occup = 3		if  main_occupation>=3111 & main_occupation<=3522
replace occup = 4		if  main_occupation>=4110 & main_occupation<=4419
replace occup = 5		if  main_occupation>=5111 & main_occupation<=5419
replace occup = 6		if  main_occupation>=6111 & main_occupation<=6340
replace occup = 7		if  main_occupation>=7111 & main_occupation<=7549
replace occup = 8		if  main_occupation>=8111 & main_occupation<=8350
replace occup = 9		if  main_occupation>=9111 & main_occupation<=9629
replace occup = 10		if   main_occupation>=110 & main_occupation<=310
replace occup = .		if  lstatus!=1
*</_occup_>

*<_occup_2_>
*<_occup_2_note_> 1 digit occupational classification - main job - last 7 days *</_occup_2_note_>
/*<_occup_2_note_> Variable is constructed for all persons administered this module in each questionnaire. For this reason the lower age cutoff (and perhaps upper age cutoff) at which information is collected will vary from country to country. Classifies the main job of any indiviudal with a job (lstatus=1) and is missing otherwise. The classification is based on the International Standard Classification of Occupations (ISCO) 88. In the case of different classifications re-coding has been done to best match the ISCO-88. *</_occup_2_note_>*/
*<_occup_2_note_> 1 "Managers" 2 "Professionals" 3 "Technicians and associate professionals" 4 "Clerical support workers" 5 "Service and sales workers" 6 "Skilled agricultural, forestry and fishery workers" 7 "Craft and related trades workers" 8 "Plant and machine operators, and assemblers" 9 "Elementary occupations" 10 "Armed forces occupations" 99 "Other/unspecified" *</_occup_2_note_>
gen   occup_2 = .
notes occup_2: the HIES does not contain the information needed to define this variable
*</_occup_2_>

*<_occup_year_>
*<_occup_year_note_> 1 digit occupational classification *</_occup_year_note_>
/*<_occup_year_note_> Variable is constructed for all persons administered this module in each questionnaire. For this reason the lower age cutoff (and perhaps upper age cutoff) at which information is collected will vary from country to country. Classifies the main job of any indiviudal with a job (lstatus=1) and is missing otherwise. The classification is based on the International Standard Classification of Occupations (ISCO) 88. In the case of different classifications re-coding has been done to best match the ISCO-88. *</_occup_year_note_>*/
*<_occup_year_note_> 1 "Managers" 2 "Professionals" 3 "Technicians and associate professionals" 4 "Clerical support workers" 5 "Service and sales workers" 6 "Skilled agricultural, forestry and fishery workers" 7 "Craft and related trades workers" 8 "Plant and machine operators, and assemblers" 9 "Elementary occupations" 10 "Armed forces occupations" 99 "Other/unspecified" *</_occup_year_note_>
gen   occup_year = .
notes occup_year: the HIES does not contain the information needed to define this variable
*</_occup_>

*<_empstat_>
*<_empstat_note_>  Employment status - main job - last 7 days *</_empstat_note_>
/*<_empstat_note_> Variable is constructed for all persons administered this module in each questionnaire. For this reason the lower age cutoff (and perhaps upper age cutoff) at which information is collected will vary from country to country. Definitions taken from the ILO’s Classification of Status in Employment with some revisions to take into account the data available. Classifies the main job employment status of any individual with a job (lstatus=1) and is missing otherwise.  
Paid employee includes anyone whose basic remuneration is not directly dependent on the revenue of the unit they work for, typically remunerated by wages and salaries but may be paid for piece work or in-kind. The ‘continuous’ criteria used in the ILO definition is not used here as data are often absent and due to country specificity. 
Non paid employee includes contributing family workers are those workers who hold a self-employment job in a market-oriented establishment operated by a related person living in the same households who cannot be regarded as a partner because of their degree of commitment to the operation of the establishment, in terms of working time or other factors, is not at a level comparable to that of the head of the establishment. 
Employer is a business owner (whether alone or in partnership) with employees. If the only people working in the business are the owner and ‘contributing family workers, the person is not considered an employer (as has no employees) and is, instead classified as own account. 
Own account or self-employment includes jobs are those where remuneration is directly dependent from the goods and service produced (where home consumption is considered to be part of the profits) and have not engaged any permanent employees to work for them on a continuous basis during the reference period. 
Members of producers’ cooperatives are workers who hold a self-employment job in a cooperative producing goods and services in which each member takes part on an equal footing with other members in determining the organization of production, sales and/or other work of the establishment, the investments and the distribution of the proceeds of the establishment amongst the members. 
Other, workers not classifiable by status include those for whom insufficient relevant information is available and/or who cannot be included in any of the preceding categories. *</_empstat_note_>*/
*<_empstat_note_> 1 "Paid Employee" 2 "Non-Paid Employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status" *</_empstat_note_>
gen     empstat = .
replace empstat = 1		if  employment_status>=1 & employment_status<=3
replace empstat = 2		if  employment_status==6
replace empstat = 3		if  employment_status==4
replace empstat = 4		if  employment_status==5
replace empstat = .		if  lstatus!=1
*</_empstat_>

*<_empstat_year_>
*<_empstat_year_note_>  Employment status - main job - last 12 months *</_empstat_year_note_>
/*<_empstat_year_note_> Variable is constructed for all persons administered this module in each questionnaire. For this reason the lower age cutoff (and perhaps upper age cutoff) at which information is collected will vary from country to country. Definitions taken from the ILO’s Classification of Status in Employment with some revisions to take into account the data available. Classifies the main job employment status of any individual with a job (lstatus=1) and is missing otherwise.  
Paid employee includes anyone whose basic remuneration is not directly dependent on the revenue of the unit they work for, typically remunerated by wages and salaries but may be paid for piece work or in-kind. The ‘continuous’ criteria used in the ILO definition is not used here as data are often absent and due to country specificity. 
Non paid employee includes contributing family workers are those workers who hold a self-employment job in a market-oriented establishment operated by a related person living in the same households who cannot be regarded as a partner because of their degree of commitment to the operation of the establishment, in terms of working time or other factors, is not at a level comparable to that of the head of the establishment. 
Employer is a business owner (whether alone or in partnership) with employees. If the only people working in the business are the owner and ‘contributing family workers, the person is not considered an employer (as has no employees) and is, instead classified as own account. 
Own account or self-employment includes jobs are those where remuneration is directly dependent from the goods and service produced (where home consumption is considered to be part of the profits) and have not engaged any permanent employees to work for them on a continuous basis during the reference period. 
Members of producers’ cooperatives are workers who hold a self-employment job in a cooperative producing goods and services in which each member takes part on an equal footing with other members in determining the organization of production, sales and/or other work of the establishment, the investments and the distribution of the proceeds of the establishment amongst the members. 
Other, workers not classifiable by status include those for whom insufficient relevant information is available and/or who cannot be included in any of the preceding categories. *</_empstat_year_note_>*/
*<_empstat_year_note_> 1 "Paid Employee" 2 "Non-Paid Employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status" *</_empstat_year_note_>
gen   empstat_year = .
notes empstat_year: the HIES does not contain the information needed to define this variable
*</_empstat_year_>

*<_empstat_2_>
*<_empstat_2_note_>  Employment status - second job - last 7 days *</_empstat_2_note_>
/*<_empstat_2_note_> Variable is constructed for all persons administered this module in each questionnaire. For this reason the lower age cutoff (and perhaps upper age cutoff) at which information is collected will vary from country to country. Definitions taken from the ILO’s Classification of Status in Employment with some revisions to take into account the data available. Classifies the main job employment status of any individual with a job (lstatus=1) and is missing otherwise.  
Paid employee includes anyone whose basic remuneration is not directly dependent on the revenue of the unit they work for, typically remunerated by wages and salaries but may be paid for piece work or in-kind. The ‘continuous’ criteria used in the ILO definition is not used here as data are often absent and due to country specificity. 
Non paid employee includes contributing family workers are those workers who hold a self-employment job in a market-oriented establishment operated by a related person living in the same households who cannot be regarded as a partner because of their degree of commitment to the operation of the establishment, in terms of working time or other factors, is not at a level comparable to that of the head of the establishment. 
Employer is a business owner (whether alone or in partnership) with employees. If the only people working in the business are the owner and ‘contributing family workers, the person is not considered an employer (as has no employees) and is, instead classified as own account. 
Own account or self-employment includes jobs are those where remuneration is directly dependent from the goods and service produced (where home consumption is considered to be part of the profits) and have not engaged any permanent employees to work for them on a continuous basis during the reference period. 
Members of producers’ cooperatives are workers who hold a self-employment job in a cooperative producing goods and services in which each member takes part on an equal footing with other members in determining the organization of production, sales and/or other work of the establishment, the investments and the distribution of the proceeds of the establishment amongst the members. 
Other, workers not classifiable by status include those for whom insufficient relevant information is available and/or who cannot be included in any of the preceding categories. *</_empstat_2_note_>*/
*<_empstat_2_note_> 1 "Paid Employee" 2 "Non-Paid Employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status" *</_empstat_2_note_>
gen   empstat_2 = .
notes empstat_2: the HIES does not contain the information needed to define this variable
*</_empstat_2_>

*<_empstat_2_year_>
*<_empstat_2_year_note_>  Employment status - second job - last 12 months *</_empstat_2_year_note_>
/*<_empstat_2_year_note_> Variable is constructed for all persons administered this module in each questionnaire. For this reason the lower age cutoff (and perhaps upper age cutoff) at which information is collected will vary from country to country. Definitions taken from the ILO’s Classification of Status in Employment with some revisions to take into account the data available. Classifies the main job employment status of any individual with a job (lstatus=1) and is missing otherwise.  
Paid employee includes anyone whose basic remuneration is not directly dependent on the revenue of the unit they work for, typically remunerated by wages and salaries but may be paid for piece work or in-kind. The ‘continuous’ criteria used in the ILO definition is not used here as data are often absent and due to country specificity. 
Non paid employee includes contributing family workers are those workers who hold a self-employment job in a market-oriented establishment operated by a related person living in the same households who cannot be regarded as a partner because of their degree of commitment to the operation of the establishment, in terms of working time or other factors, is not at a level comparable to that of the head of the establishment. 
Employer is a business owner (whether alone or in partnership) with employees. If the only people working in the business are the owner and ‘contributing family workers, the person is not considered an employer (as has no employees) and is, instead classified as own account. 
Own account or self-employment includes jobs are those where remuneration is directly dependent from the goods and service produced (where home consumption is considered to be part of the profits) and have not engaged any permanent employees to work for them on a continuous basis during the reference period. 
Members of producers’ cooperatives are workers who hold a self-employment job in a cooperative producing goods and services in which each member takes part on an equal footing with other members in determining the organization of production, sales and/or other work of the establishment, the investments and the distribution of the proceeds of the establishment amongst the members. 
Other, workers not classifiable by status include those for whom insufficient relevant information is available and/or who cannot be included in any of the preceding categories. *</_empstat_2_year_note_>*/
*<_empstat_2_year_note_> 1 "Paid Employee" 2 "Non-Paid Employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status" *</_empstat_2_year_note_>
gen   empstat_2_year = .
notes empstat_2_year: the HIES does not contain the information needed to define this variable
*</_empstat_2_year_>

*<_ocusec_>
*<_ocusec_note_>  Sector of activity - main job - last 7 days *</_ocusec_note_>
/*<_ocusec_note_> Variable is constructed for all persons administered this module in each questionnaire. Classifies the main job's sector of activity of any individual with a job (lstatus=1) and is missing otherwise. Public sector includes non-governmental organizations and armed forces. Private sector is that part of the economy which is both run for private profit and is not controlled by the state. State owned includes para-statal firms and all others in which the government has control (participation over 50%). *</_ocusec_note_>*/
*<_ocusec_note_> 1 "Public sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish" *</_ocusec_note_>
gen     ocusec = .
replace ocusec = 1		if  employment_status==1
replace ocusec = 2		if  employment_status>=3 & employment_status<=6
replace ocusec = 3 		if  employment_status==2
replace ocusec = .		if  lstatus!=1
*</_ocusec_>

*<_ocusec_year_>
*<_ocusec_year_note_>  Sector of activity - main job - last 12 months *</_ocusec_year_note_>
/*<_ocusec_year_note_> Variable is constructed for all persons administered this module in each questionnaire. Classifies the main job's sector of activity of any individual with a job (lstatus=1) and is missing otherwise. Public sector includes non-governmental organizations and armed forces. Private sector is that part of the economy which is both run for private profit and is not controlled by the state. State owned includes para-statal firms and all others in which the government has control (participation over 50%). *</_ocusec_year_note_>*/
*<_ocusec_year_note_> 1 "Public sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish" *</_ocusec_year_note_>
gen   ocusec_year = .
notes ocusec_year: the HIES does not contain the information needed to define this variable
*</_ocusec_year_>

*<_firmsize_l_>
*<_firmsize_l_note_>  Firm size (lower bracket) *</_firmsize_l_note_>
/*<_firmsize_l_note_> Variable is constructed for all persons who are employed. If continuous records the number of people working for the same employer. If the variable is categorical it records the lower boundary of the bracket. *</_firmsize_l_note_>*/
*<_firmsize_l_note_>  *</_firmsize_l_note_>
gen   firmsize_l = .
notes firmsize_l: the HIES does not contain the information needed to define this variable
*</_firmsize_l_>

*<_firmsize_u_>
*<_firmsize_u_note_>  Firm size (upper bracket) *</_firmsize_u_note_>
/*<_firmsize_u_note_> Variable is constructed for all persons who are employed. If continuous records the number of people working for the same employer. If the variable is categorical it records the upper boundary of the bracket. *</_firmsize_u_note_>*/
*<_firmsize_u_note_>  *</_firmsize_u_note_>
gen   firmsize_u = .
notes firmsize_u: the HIES does not contain the information needed to define this variable
*</_firmsize_u_>

*<_contract_>
*<_contract_note_>  Contract *</_contract_note_>
/*<_contract_note_> Variable is constructed for all persons administered this module in each questionnaire.  Indicates if a person has a signed (formal) contract, regardless of duration. For this reason the lower age cutoff (and perhaps upper age cutoff) at which information is collected will vary from country to country. Classifies the contract status of any individual with a job (lstatus=1) and is missing otherwise. This variable is only constructed if there is an explicit question about contracts. *</_contract_note_>*/
*<_contract_note_>  1 "Yes" 0 "No" *</_contract_note_>
gen   contract = .
notes contract: the HIES does not contain the information needed to define this variable
*</_contract_>

*<_healthins_>
*<_healthins_note_>  Health insurance *</_healthins_note_>
/*<_healthins_note_> Variable is constructed for all persons administered this module in each questionnaire. For this reason the lower age cutoff (and perhaps upper age cutoff) at which information is collected will vary from country to country. Classifies the social security status of any individual with a job (lstatus=1) and is missing otherwise. This variable is only constructed if there is an explicit question about health security. *</_healthins_note_>*/
*<_healthins_note_>  1 "Yes" 0 "No" *</_healthins_note_>
gen   healthins = .
notes healthins: the HIES does not contain the information needed to define this variable
*</_healthins_>

*<_socialsec_>
*<_socialsec_note_>  Social security *</_socialsec_note_>
/*<_socialsec_note_> Variable is constructed for all persons administered this module in each questionnaire.  For this reason the lower age cutoff (and perhaps upper age cutoff) at which information is collected will vary from country to country. Classifies the social security status of any individual with a job (lstatus=1) and is missing otherwise. This variable is only constructed if there is an explicit question about pension plans or social security. *</_socialsec_note_>*/
*<_socialsec_note_>  1 "Yes" 0 "No" *</_socialsec_note_>
gen   socialsec = .
notes socialsec: the HIES does not contain the information needed to define this variable
*</_socialsec_>

*<_union_>
*<_union_note_> Union membership *</_union_note_>
/*<_union_note_> Variable is constructed for all persons administered this module in each questionnaire.  For this reason the lower age cutoff (and perhaps upper age cutoff) at which information is collected will vary from country to country. Classifies the union membership status of any individual with a job (lstatus=1) and is missing otherwise. This variable is only constructed if there is an explicit question about trade unions. *</_union_note_>*/
*<_union_note_> 1 "Yes" 0 "No" *</_union_note_>
gen   union = .
notes union: the HIES does not contain the information needed to define this variable
*</_union_>

*<_wage_>
*<_wage_note_>  Last wage payment *</_wage_note_>
/*<_wage_note_> Variable is constructed for all persons administered this module in each questionnaire. For this reason the lower age cutoff (and perhaps upper age cutoff) will vary from country to country. States the main job's wage earner of any individual (lstatus=1 & empstat<=4) and is missing otherwise. Wage from main job. This excludes tips, bonuses, and other payments. For all those with self-employment or owners of own businesses, this should be net revenues (net of all costs EXCEPT for tax payments) or the amount of salary taken from the business. Due to the almost complete lack of information on taxes, the wage from main job is NOT net of taxes. By definition non-paid employees (empstat=2) should have wage=0. *</_wage_note_>*/
*<_wage_note_> *</_wage_note_>
egen  wage = rsum(employment_income1 agricultural_1 non_agricultural_1), missing
*</_wage_>

*<_wage_2_>
*<_wage_2_note_>  Last wage payment second job *</_wage_2_note_>
/*<_wage_2_note_> Variable is constructed for all persons administered this module in each questionnaire. For this reason the lower age cutoff (and perhaps upper age cutoff) will vary from country to country. States the second job's wage earner of any individual (lstatus=1 & empstat_2<=4) and is missing otherwise. Wage from second job. This excludes tips, bonuses, and other payments. For all those with self-employment or owners of own businesses, this should be net revenues (net of all costs EXCEPT for tax payments) or the amount of salary taken from the business.  Due to the almost complete lack of information on taxes, the wage from second job is NOT net of taxes. By definition non-paid employees (empstat_2=2) should have wage=0. *</_wage_2_note_>*/
*<_wage_2_note_> *</_wage_2_note_>
egen  wage_2 = rsum(employment_income2 agricultural_2 non_agricultural_2), missing
*</_wage_2_>

*<_unitwage_>
*<_unitwage_note_>  Last wages time unit - main job *</_unitwage_note_>
/*<_unitwage_note_> Type of reference for the wage variable. States the main job's wage earner time unit measurement of any individual (lstatus=1 & empstat<=4) and is missing otherwise. *</_unitwage_note_>*/
*<_unitwage_note_> 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Every two months" 5 "Monthly" 6 "Quarterly" 7 "Every six months" 8 "Annually" 9 "Hourly" 10 "Other" *</_unitwage_note_>
gen   unitwage = 5			if  wage!=.
notes unitwage: variable WAGE was defined using a monthly basis
*</_unitwage_>

*<_unitwage_2_>
*<_unitwage_2_note_>  Last wages time unit - second job *</_unitwage_2_note_>
/*<_unitwage_2_note_> Type of reference for the wage variable. States the second job's wage earner time unit measurement of any individual (lstatus=1 & empstat_2<=4) and is missing otherwise. *</_unitwage_2_note_>*/
*<_unitwage_2_note_> 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Every two months" 5 "Monthly" 6 "Quarterly" 7 "Every six months" 8 "Annually" 9 "Hourly" 10 "Other" *</_unitwage_2_note_>
gen   unitwage_2 = 5			if  wage_2!=.
notes unitwage_2: variable WAGE_2 was defined using a monthly basis
*</_unitwage_2_>

*<_whours_>
*<_whours_note_>  Hours of work in last week *</_whours_note_>
/*<_whours_note_> Variable is constructed for all persons administered this module in each questionnaire. For this reason the lower age cutoff (and perhaps upper age cutoff) at which information is collected will vary from country to country. Classifies the main job of any individual with a job (lstatus=1) and is missing otherwise. This is the number of hours worked in the last 7 days or the reference week in the person’s main job. Main job defined as that occupation to which the person dedicated more time. For persons absent from their job in the week preceding the survey due to holidays, vacation or sick leave, the time worked in the last week the person worked is recorded. For individuals who only give information on how many hours they work per day and no information on number of days worked a week, multiply the hours by 5 days. In the case of a question that has hours worked per month, divide by 4.2 to get weekly hours. *</_whours_note_>*/
*<_whours_note_>  *</_whours_note_>
gen   whours = .
notes whours: the HIES does not contain the information needed to define this variable
*</_whours_>

foreach var in lstatus nlfreason unempldur_l unempldur_u njobs industry industry_orig industry_2 industry_orig_2 industry_year industry_orig_year industry_2_year industry_orig_2_year occup occup_2 occup_year empstat empstat_year empstat_2 empstat_2_year ocusec ocusec_year firmsize_l firmsize_u contract healthins socialsec union wage wage_2 unitwage unitwage_2 whours {
	replace `var'=. if age<lb_mod_age
	}
	

****************************************************************
**** ASSETS
****************************************************************

*<_television_>
*<_television_note_> Household has television *</_television_note_>
/*<_television_note_> Availability of televisions in household. Question on quantity or specific availability should be present *</_television_note_>*/
*<_television_note_>  1 "Yes" 0 "No" *</_television_note_>
gen 	television = 0
replace television = 1  		if  tv==1 
*</_television_>

*<_radio_>
*<_radio_note_> Household has radio *</_radio_note_>
/*<_radio_note_> Availability of radios in household. Question on quantity or specific availability should be present *</_radio_note_>*/
*<_radio_note_>  1 "Yes" 0 "No" *</_radio_note_>
rename radio radio_hies
gen     radio = 0
replace radio = 1			if  radio_hies==1
notes   radio: it includes "radio/cassette player"
*</_radio_>

*<_fan_>
*<_fan_note_> Household has fan *</_fan_note_>
/*<_fan_note_> Availability of fans in household. Question on quantity or specific availability should be present *</_fan_note_>*/
*<_fan_note_>  1 "Yes" 0 "No" *</_fan_note_>
gen 	fan = 0
replace fan = 1				if  electric_fans==1
*</_fan_>

*<_sewingmachine_>
*<_sewingmachine_note_> Household has sewing machine *</_sewingmachine_note_>
/*<_sewingmachine_note_> Availability of sewing machines  in household. Question on quantity or specific availability should be present *</_sewingmachine_note_>*/
*<_sewingmachine_note_>  1 "Yes" 0 "No" *</_sewingmachine_note_>
gen 	sewingmachine = 0
replace sewingmachine = 1  	if  sewingmechine==1 
*</_sewingmachine_>

*<_washingmachine_>
*<_washingmachine_note_> Household has washing machine *</_washingmachine_note_>
/*<_washingmachine_note_> Availability of washing machines in household. Question on quantity or specific availability should be present *</_washingmachine_note_>*/
*<_washingmachine_note_>  1 "Yes" 0 "No" *</_washingmachine_note_>
gen 	washingmachine = 0
replace washingmachine = 1  	if  washing_mechine==1 
*</_washingmachine_>

*<_refrigerator_>
*<_refrigerator_note_> Household has refrigerator *</_refrigerator_note_>
/*<_refrigerator_note_> Availability of refrigerator  in household. Question on quantity or specific availability should be present *</_refrigerator_note_>*/
*<_refrigerator_note_>  1 "Yes" 0 "No" *</_refrigerator_note_>
gen 	refrigerator = 0
replace refrigerator = 1  	if  fridge==1 
*</_refrigerator_>

*<_lamp_>
*<_lamp_note_> Household has lamp *</_lamp_note_>
/*<_lamp_note_> Availability of lamp in household. Question on quantity or specific availability should be present *</_lamp_note_>*/
*<_lamp_note_>  1 "Yes" 0 "No" *</_lamp_note_>
gen   lamp = .
notes lamp: the HIES does not contain the information needed to define this variable
*</_lamp_>

*<_bicycle_>
*<_bicycle_note_> Household has bicycle *</_bicycle_note_>
/*<_bicycle_note_> Availability of bicycle in household. Question on quantity or specific availability should be present *</_bicycle_note_>*/
*<_bicycle_note_>  1 "Yes" 0 "No" *</_bicycle_note_>
rename bicycle bicycle_hies
gen 	bicycle = 0
replace bicycle = 1  		if  bicycle_hies==1 
*</_bicycle_>

*<_motorcycle_>
*<_motorcycle_note_> Household has motorcycle *</_motorcycle_note_>
/*<_motorcycle_note_> Availability of motor cycles (bikes) in household. Question on quantity or specific availability should be present *</_motorcycle_note_>*/
*<_motorcycle_note_>  1 "Yes" 0 "No" *</_motorcycle_note_>
gen 	motorcycle = 0
replace motorcycle = 1  		if  motor_bicycle==1 
*</_motorcycle_>

*<_motorcar_>
*<_motorcar_note_> Household has motorcar *</_motorcar_note_>
/*<_motorcar_note_> Availability of motorcars in household. Question on quantity or specific availability should be present *</_motorcar_note_>*/
*<_motorcar_note_>  1 "Yes" 0 "No" *</_motorcar_note_>
gen 	motorcar = 0
replace motorcar = 1  		if  motor_car_van==1 
*</_motorcar_>

*<_buffalo_>
*<_buffalo_note_> Household has buffalo *</_buffalo_note_>
/*<_buffalo_note_> Availability of buffalos in household. Question on quantity or specific availability should be present *</_buffalo_note_>*/
*<_buffalo_note_>  1 "Yes" 0 "No" *</_buffalo_note_>
gen   buffalo = .
notes buffalo: buffaloes are included together with cows
*</_buffalo_>

*<_chicken_>
*<_chicken_note_> Household has chicken *</_chicken_note_>
/*<_chicken_note_> Availability of chicken in household. Question on quantity or specific availability should be present *</_chicken_note_>*/
*<_chicken_note_>  1 "Yes" 0 "No" *</_chicken_note_>
gen 	chicken = 0
replace chicken = 1			if  chickens==1
*</_chicken_>

*<_cow_>
*<_cow_note_> Household has cow *</_cow_note_>
/*<_cow_note_> Availability of cows in household. Question on quantity or specific availability should be present *</_cow_note_>*/
*<_cow_note_>  1 "Yes" 0 "No" *</_cow_note_>
gen 	cow = 0
replace cow = 1				if  cows==1
notes cow: it includes "cattle/buffaloes"
*</_cow_>


***************************************************************************
**** WELFARE MODULE 
***************************************************************************

*<_spdef_>
*<_spdef_note_>  Spatial deflator. *</_spdef_note_>
/*<_spdef_note_> Specifies varname for a spatial deflator if one is used. This variable can only be used in combination with a subnational ID. *</_spdef_note_>*/
*<_spdef_note_>  *</_spdef_note_>
gen spdef = lpindex1
*</_spdef_>

*<_welfare_>
*<_welfare_note_>  Welfare aggregate used for estimating international poverty (provided to PovcalNet). *</_welfare_note_>
/*<_welfare_note_> Specifies varname for the welfare aggregate (e.g. per capita consumption) in the data file that is provided to Povcalnet as input into the estimation of international poverty. This variable should be annual and in LCU at current prices. The variables welfare, welfarenom, and welfaredef have to be in the same welfare type (either income, consumption or expenditure) and two of these three welfare aggregates will be the same. *</_welfare_note_>*/
*<_welfare_note_>  *</_welfare_note_>
gen welfare = (hhexppm/hhsize)/spdef
*</_welfare_>

*<_welfarenom_>
*<_welfarenom_note_>  Welfare aggregate in nominal terms. *</_welfarenom_note_>
/*<_welfarenom_note_> Specifies varname for the welfare aggregate (e.g. per capita consumption) in the data file in nominal terms. This variable should be annual and in LCU at current prices. The variables welfare, welfarenom, and welfaredef have to be in the same welfare type (either income, consumption or expenditure) and two of thes three welfare aggregates will be the same. *</_welfarenom_note_>*/
*<_welfarenom_note_>  *</_welfarenom_note_>
gen welfarenom = hhexppm/hhsize
*</_welfarenom_>

*<_welfaredef_>
*<_welfaredef_note_>  Welfare aggregate spatially deflated. *</_welfaredef_note_>
/*<_welfaredef_note_> Specifies varname for the welfare aggregate (e.g. per capita consumption) in the data file spatially deflated (spatial or within year inflaction adjustment).  This variable should be annual and in LCU at current prices. The variables welfare, welfarenom, and welfaredef have to be in the same welfare type (either income, consumption or expenditure) and two of thes three welfare aggregates will be the same. *</_welfaredef_note_>*/
*<_welfaredef_note_>  *</_welfaredef_note_>
gen welfaredef = welfarenom/spdef
*</_welfaredef_>

*<_welfshprosperity_>
*<_welfshprosperity_note_>  Welfare aggregate for shared prosperity (if different from poverty) *</_welfshprosperity_note_>
/*<_welfshprosperity_note_> specifies varname for the welfare variable used to compute the shared prosperity indicator (e.g. per capita consumption) in the data file. This variable should be annual and in LCU at current prices. This variable is either the same as welfare ( *</_welfshprosperity_note_>*/
*<_welfshprosperity_note_>  *</_welfshprosperity_note_>
gen welfshprosperity = .a
*</_welfshprosperity_>

*<_welfaretype_>
*<_welfaretype_note_>  Type of welfare measure (income, consumption or expenditure) for welfare, welfarenom, welfaredef. *</_welfaretype_note_>
/*<_welfaretype_note_> Specifies the type of welfare measure for the variables welfare, welfarenom and welfaredef. Accepted values are: INC for income, CONS for consumption, or EXP for expenditure. Welfaretype is case-sensitive and upper case has to be used. *</_welfaretype_note_>*/
*<_welfaretype_note_>  *</_welfaretype_note_>
gen welfaretype = "EXP"
*</_welfaretype_>

*<_welfareother_>
*<_welfareother_note_>  Welfare aggregate if different welfare type is used from welfare, welfarenom, welfaredef. *</_welfareother_note_>
/*<_welfareother_note_> Specifies varname for the welfare aggregate in the data file if a different welfare type is used from the variables welfare, welfarenom, welfaredef. For example, if consumption is used for welfare, welfarenom and welfaredef but income also exists, it could be included here. This variable should be annual and in LCU at current prices. *</_welfareother_note_>*/
*<_welfareother_note_>  *</_welfareother_note_>
gen   welfareother = ipcf*12
notes welfareother: variable is defined as household per capita income
*</_welfareother_>

*<_welfareothertype_>
*<_welfareothertype_note_>  Type of welfare measure (income, consumption or expenditure) for welfareother. *</_welfareothertype_note_>
/*<_welfareothertype_note_> Specifies the type of welfare measure for the variable welfareother. Accepted values are: INC for income, CONS for consumption, or EXP for expenditure. This variable is only entered if the type of welfare is different from what is provided in welfare, welfarenom, and welfaredef. For example, if consumption is used for welfare, welfarenom and welfaredef but income also exists, it could be included here. Welfaretype is case-sensitive and upper case has to be used. *</_welfareothertype_note_>*/
*<_welfareothertype_note_>  *</_welfareothertype_note_>
gen welfareothertype = "INC"
*</_welfareothertype_>

*<_welfarenat_>
*<_welfarenat_note_>  Welfare aggregate for national poverty. *</_welfarenat_note_>
/*<_welfarenat_note_> Welfare aggregate for national poverty. *</_welfarenat_note_>*/
*<_welfarenat_note_>  1 "Yes" 0 "No" *</_welfarenat_note_>
gen welfarenat = welfare
*</_welfarenat_>

*<_quintile_cons_aggregate_>
*<_quintile_cons_aggregate_note_> Quintile of welfarenat *</_quintile_cons_aggregate_note_>
/*<_quintile_cons_aggregate_note_>  *</_quintile_cons_aggregate_note_>*/
*<_quintile_cons_aggregate_note_>  *</_quintile_cons_aggregate_note_>
_ebin welfare [aw=weight], gen(quintile_cons_aggregate) nq(5) 
*</_quintile_cons_aggregate_>

*<_food_share_>
*<_food_share_note_> Food share *</_food_share_note_>
/*<_food_share_note_>  *</_food_share_note_>*/
*<_food_share_note_>  *</_food_share_note_>
gen food_share = (hhfoodexppm/hhexppm)*100
*</_food_share_>

*<_nfood_share_>
*<_nfood_share_note_> Non-food share *</_nfood_share_note_>
/*<_nfood_share_note_>  *</_nfood_share_note_>*/
*<_nfood_share_note_>  *</_nfood_share_note_>
gen nfood_share =  100-food_share 
*</_nfood_share_>


****************************************************************
**** NATIONAL POVERTY
****************************************************************

*<_pline_nat_>
*<_pline_nat_note_>  Poverty line (National). *</_pline_nat_note_>
/*<_pline_nat_note_> Poverty line based on the national methodology. *</_pline_nat_note_>*/
*<_pline_nat_note_>  *</_pline_nat_note_>
gen pline_nat = 4830
gen pline_nat2 = 6966
*</_pline_nat_>

*<_poor_nat_>
*<_poor_nat_note_>  People below Poverty Line (National). *</_poor_nat_note_>
/*<_poor_nat_note_> People below Poverty Line (National). *</_poor_nat_note_>*/
*<_poor_nat_note_>  *</_poor_nat_note_>
gen   poor_nat = welfarenat<pline_nat 		if  welfarenat!=. 
notes poor_nat: poor people identified using old poverty line (based on 2002 data)
gen   poor_nat2 = welfarenat<pline_nat2 	if  welfarenat!=. 
notes poor_nat2: poor people identified using updated poverty line (based on 2012/2013 data)
*</_poor_nat_>
preserve
keep idh idp pline_nat2 poor_nat2
tempfile poverty 
save `poverty', replace
restore

****************************************************************
**** INTERNATIONAL POVERTY
****************************************************************
	
** USE SARMD CPI AND PPP 
*<_cpi_>
gen cpi = .
*</_cpi_>	

** PPP VARIABLE 
*<_ppp_>
gen ppp = .
*</_ppp_>

** CPI PERIOD  
*<_cpiperiod_>
gen cpiperiod = .
*</_cpiperiod_>	

*<_pline_int_>
*<_pline_int_note_>  Poverty line Povcalnet. *</_pline_int_note_>
/*<_pline_int_note_> Poverty line constructed based on international comparison program standards (ICP). *</_pline_int_note_>*/
*<_pline_int_note_>  *</_pline_int_note_>
gen pline_int = . 
*</_pline_int_>

*<_poor_int_>
*<_poor_int_note_>  People below Poverty Line (International). *</_poor_int_note_>
/*<_poor_int_note_> People below poverty line based on PovCalnet methodology. May not be equal to standard country definition. *</_poor_int_note_>*/
*<_poor_int_note_>  *</_poor_int_note_>
gen poor_int = welfare<pline_int 	if welfare!=. 
*</_poor_int_>


******************************************************************
cap gen converfactor= .

gen gaul_adm3_code = .
 
gen 	agecat = ""
replace agecat = "15 years or younger" 	if  age<=15
replace agecat = "15-24 years old" 		if  age>15 & age<=24
replace agecat = "25-54 years old" 		if  age>24 & age<=54
replace agecat = "55-64 years old" 		if  age>54 & age<=64
replace agecat = "65 years or older" 	if  age>64

gen harmonization	= "`type'"
gen countryname	= "`code'"

clonevar minlaborage   	= lb_mod_age
clonevar industrycat10 	= industry
gen      industrycat4  	= industrycat10
recode   industrycat4    (2/5=2) (6/9=3) (10=4)
clonevar school        	= atschool
recode   educat7        (1 2=0) (3 4 5 6 7=1) (8=.) 	if everattend==1, gen(primarycomp)
clonevar imp_wat_rec   	= improved_water 
clonevar imp_san_rec   	= improved_sanitation 
rename   sector sector_hies
gen      sector = .

*<_occup_orig_>
*<_occup_orig_note_> original occupation code *</_occup_orig_note_>
/*<_occup_orig_note_>  *</_occup_orig_note_>*/
*<_occup_orig_note_> occup_orig brought in from rawdata *</_occup_orig_note_>
gen   occup_orig = main_occupation
notes occup_orig: the HIES does not collect information on this topic
*</_occup_orig_>

gen welfshprtype = "EXP"


*<_Keep variables_>
order countrycode year hhid pid weight weighttype
sort  hhid pid
*</_Keep variables_>

*<_Save data file_>
preserve
do   "$rootdofiles\_aux\Labels_GMD_All.do"
save "$output\\`filename'_GMD_ALL.dta", replace
restore
*</_Save data file_>

*<_Save data file_>
preserve
do   "$rootdofiles\_aux\Labels_SARMD.do"
merge 1:1 idh idp using `poverty'
drop _merge
save "$output\\`filename'.dta", replace
restore
*</_Save data file_>
