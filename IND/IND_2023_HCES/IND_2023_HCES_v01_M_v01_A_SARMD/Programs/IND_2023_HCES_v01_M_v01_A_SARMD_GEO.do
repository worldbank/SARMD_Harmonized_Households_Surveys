/*----------------------------------------------------------------------------------
  SARMD Harmonization
------------------------------------------------------------------------------------
<_Program name_>   		IND_2023_HCES_v01_M_v01_SARMD_GEO.do		   </_Program name_>
<_Application_>    		STATA 17.0									 <_Application_>
<_Author(s)_>      		Leo Tornarolli <tornarolli@gmail.com>		  </_Author(s)_>
<_Date created_>   		02-2026									   </_Date created_>
<_Date modified>    	February 2026						 	  </_Date modified_>
------------------------------------------------------------------------------------
<_Country_>        		IND											    </_Country_>
<_Survey Title_>   		HCES									   </_Survey Title_>
<_Survey Year_>    		2023-2024									</_Survey Year_>
------------------------------------------------------------------------------------
<_Version Control_>
Date:					02-2026
File:					IND_2023_HCES_v01_M_v01_SARMD_GEO.do
First version
</_Version Control_>
----------------------------------------------------------------------------------*/

*<_Program setup_>
clear all
set more off

local code         		"IND"
local year         		"2023"
local survey       		"HCES"
local vm           		"01"
local va           		"01"
local type         		"SARMD"
global module       	"GEO"
local yearfolder    	"`code'_`year'_`survey'"
local SARMDfolder    	"`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'"
local filename      	"`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'_${module}"
cap mkdir				"${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'" 
cap mkdir				"${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\\Data" 
cap mkdir				"${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\\Data\Harmonized" 
global input      		"${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata"
glo output          	"${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\\Data\Harmonized" 
*</_Program setup_>


*<_Datalibweb request_>
use "${input}\\`yearfolder'_v`vm'_M.dta", clear
*</_Datalibweb request_>


*<_countrycode_> 
*<_countrycode_note_> Country code according to ISO-3166 Alpha-3 *</_countrycode_note_>
gen countrycode = "`code'"
gen code = countrycode
*</_countrycode_>

*<_year_>
*<_year_note_> 4-digit year of survey based on IHSN standards *</_year_note_>
capture drop year 
gen year = 2023
*</_year_>

*<_hhid_>
*<_hhid_note_> Household identifier  *</_hhid_note_>
/*<_hhid_note_> . *</_hhid_note_>*/
*<_hhid_note_> hhid brought in from rawdata *</_hhid_note_>
*</_hhid_>

*<_pid_>
*<_pid_note_> Personal identifier  *</_pid_note_>
/*<_pid_note_> country specific *</_pid_note_>*/
*<_pid_note_> pid brought in from rawdata *</_pid_note_>
*</_pid_>

*<_weight_>
*<_weight_note_> Household weight  *</_weight_note_>
/*<_weight_note_> Survey specific information *</_weight_note_>*/
clonevar weight = hhwt
clonevar weight_p = weight
*</_weight_>

*<_weighttype_>
*<_weighttype_note_> Weight type (frequency, probability, analytical, importance) *</_weighttype_note_>
*<_weighttype_note_> weighttype brought in from rawdata *</_weighttype_note_>
gen weighttype = "PW"
*</_weighttype_>

*<_subnatid1_>
*<_subnatid1_note_>  Subnational ID - highest level *</_subnatid1_note_>
/*<_subnatid1_note_> Subnational id - subnational regional identifiers at which survey is representative - highest level *</_subnatid1_note_>*/
*<_subnatid1_note_>  *</_subnatid1_note_>
destring State, replace 
gen   aux_state = round(State)
label define aux_state 1 "01 - Jammu & Kashmir" 2 "02 - Himachal Pradesh" 3 "03 - Punjab" 4 "04 - Chandigarh" 5 "05 - Uttarakhand" 6 "06 - Haryana" 7 "07 - Delhi" 8 "08 - Rajasthan" 9 "09 - Uttar Pradesh" 10 "10 - Bihar" 11 "11 - Sikkim" 12 "12 - Arunachal Pradesh" 13 "13 - Nagaland" 14 "14 - Manipur" 15 "15 - Mizoram" 16 "16 - Tripura" 17 "17 - Meghalaya" 18 "18 - Assam" 19 "19 - West Bengal" 20 "20 - Jharkhand" 21 "21 - Odisha" 22 "22 - Chhattisgarh" 23 "23 - Madhya Pradesh" 24 "24 - Gujarat" 25 "25 - Dadra & Nagar Haveli & Daman & Diu" 27 "27 - Maharastra" 28 "28 - Andhra Pradesh" 29 "29 - Karnataka" 30 "30 - Goa" 31 "31 - Lakshadweep" 32 "32 - Kerala" 33 "33 - Tamil Nadu" 34 "34 - Puduchery" 35 "35 - Andaman & Nicober" 36 "36 - Telangana" 37 "37 - Ladakh"                                    
label values aux_state aux_state
decode aux_state, gen(subnatid1)
notes subnatid1: State Level
notes subnatid1: Representative
*</_subnatid1_>

*<_subnatid2_>
*<_subnatid2_note_> Subnational ID - second highest level *</_subnatid2_note_>
/*<_subnatid2_note_> Subnational id - subnational regional identifiers at which survey is representative - second highest level *</_subnatid2_note_>*/
*<_subnatid2_note_>  *</_subnatid2_note_>
gen   subnatid2 = "."
notes subnatid2: HCES 2023-24 does not have a smaller level of representativeness than state (used in subnatid1)
*</_subnatid2_>

*<_subnatid3_>
*<_subnatid3_note_>  Subnational ID - third highest level *</_subnatid3_note_>
/*<_subnatid3_note_> Subnational id - subnational regional identifiers at which survey is representative - third highest level *</_subnatid3_note_>*/
*<_subnatid3_note_>  *</_subnatid3_note_>
gen   subnatid3 = "."
notes subnatid3: HCES 2023-24 does not have a smaller level of representativeness than state (used in subnatid1)
*</_subnatid3_>

*<_subnatid4_>
*<_subnatid4_note_> Subnational ID - lowest level *</_subnatid4_note_>
/*<_subnatid4_note_> code-name *</_subnatid4_note_>*/
*<_subnatid4_note_> subnatid4 brought in from rawdata *</_subnatid4_note_>
gen   subnatid4 = "."
notes subnatid4: HCES 2023-24 does not have a smaller level of representativeness than state (used in subnatid1)
*</_subnatid4_>

*<_subnatidsurvey_>
*<_subnatidsurvey_note_> Survey representation of geographical units *</_subnatidsurvey_note_>
/*<_subnatidsurvey_note_> . *</_subnatidsurvey_note_>*/
*<_subnatidsurvey_note_> subnatidsurvey brought in from rawdata *</_subnatidsurvey_note_>
gen subnatidsurvey = subnatid1
*</_subnatidsurvey_>

*<_strata_>
*<_strata_note_> Strata *</_strata_note_>
/*<_strata_note_> . *</_strata_note_>*/
*<_strata_note_> strata brought in from rawdata *</_strata_note_>
egen strata = concat(State Sector Stratum Sub_stratum Second_Stage_Stratum_No), punct(-)
*</_strata_>

*<_psu_>
*<_psu_note_> PSU *</_psu_note_>
/*<_psu_note_> . *</_psu_note_>*/
*<_psu_note_> psu brought in from rawdata *</_psu_note_>
destring FSU, replace
gen psu = FSU
*</_psu_>

*<_subnatid1_prev_>
*<_subnatid1_prev_note_> Subnatid *</_subnatid1_prev_note_>
/*<_subnatid1_prev_note_> . *</_subnatid1_prev_note_>*/
*<_subnatid1_prev_note_> subnatid1_prev brought in from rawdata *</_subnatid1_prev_note_>
replace aux_state = 28	if  aux_state==36
replace aux_state = 1	if  aux_state==37
label drop aux_state
label define aux_state 1 "01 - Jammu & Kashmir" 2 "02 - Himachal Pradesh" 3 "03 - Punjab" 4 "04 - Chandigarh" 5 "05 - Uttarakhand" 6 "06 - Haryana" 7 "07 - Delhi" 8 "08 - Rajasthan" 9 "09 - Uttar Pradesh" 10 "10 - Bihar" 11 "11 - Sikkim" 12 "12 - Arunachal Pradesh" 13 "13 - Nagaland" 14 "14 - Manipur" 15 "15 - Mizoram" 16 "16 - Tripura" 17 "17 - Meghalaya" 18 "18 - Assam" 19 "19 - West Bengal" 20 "20 - Jharkhand" 21 "21 - Odisha" 22 "22 - Chhattisgarh" 23 "23 - Madhya Pradesh" 24 "24 - Gujarat" 25 "25 - Dadra & Nagar Haveli & Daman & Diu" 27 "27 - Maharastra" 28 "28 - Andhra Pradesh" 29 "29 - Karnataka" 30 "30 - Goa" 31 "31 - Lakshadweep" 32 "32 - Kerala" 33 "33 - Tamil Nadu" 34 "34 - Puduchery" 35 "35 - Andaman & Nicober"                                     
label values aux_state aux_state
decode aux_state, gen(subnatid1_prev)
notes subnatid1_prev: State Level
notes subnatid1_prev: Representative
notes subnatid1_prev: in previous rounds of the survey "Dadra & Nagar Haveli & Daman & Diu" were 2 different states: "Dadra & Nagar Haveli" and "Daman & Diu"    
*</_subnatid1_prev_>

*<_subnatid2_prev_>
*<_subnatid2_prev_note_> Subnatid *</_subnatid2_prev_note_>
/*<_subnatid2_prev_note_> . *</_subnatid2_prev_note_>*/
*<_subnatid2_prev_note_> subnatid2_prev brought in from rawdata *</_subnatid2_prev_note_>
gen   subnatid2_prev = "."
notes subnatid2_prev: missing variable
*</_subnatid2_prev_>

*<_subnatid3_prev_>
*<_subnatid3_prev_note_> Subnatid *</_subnatid3_prev_note_>
/*<_subnatid3_prev_note_> . *</_subnatid3_prev_note_>*/
*<_subnatid3_prev_note_> subnatid3_prev brought in from rawdata *</_subnatid3_prev_note_>
gen   subnatid3_prev = "."
notes subnatid3_prev: missing variable
*</_subnatid3_prev_>

*<_subnatid4_prev_>
*<_subnatid4_prev_note_> Subnatid *</_subnatid4_prev_note_>
/*<_subnatid4_prev_note_> . *</_subnatid4_prev_note_>*/
*<_subnatid4_prev_note_> subnatid4_prev brought in from rawdata *</_subnatid4_prev_note_>
gen   subnatid4_prev = "."
notes subnatid4_prev: missing variable
*</_subnatid4_prev_>

*<_gaul_adm1_code_>
*<_gaul_adm1_code_note_> Gaul Code *</_gaul_adm1_code_note_>
/*<_gaul_adm1_code_note_> . *</_gaul_adm1_code_note_>*/
*<_gaul_adm1_code_note_> gaul_adm1_code brought in from rawdata *</_gaul_adm1_code_note_>
gen 	gaul_adm1_code = .   
replace gaul_adm1_code = 75200								if  State==1 | State==37
replace gaul_adm1_code = 1493      							if  State==2 
replace gaul_adm1_code = 1505      							if  State==3 
replace gaul_adm1_code = 70074     							if  State==4 
replace gaul_adm1_code = 70082    							if  State==5 
replace gaul_adm1_code = 1492      							if  State==6 
replace gaul_adm1_code = 1489      							if  State==7 
replace gaul_adm1_code = 1506      							if  State==8 
replace gaul_adm1_code = 70081      						if  State==9 
replace gaul_adm1_code = 70073      						if  State==10 
replace gaul_adm1_code = 1507      							if  State==11 
replace gaul_adm1_code = 70072     							if  State==12 
replace gaul_adm1_code = 1503      							if  State==13 
replace gaul_adm1_code = 1500      							if  State==14 
replace gaul_adm1_code = 1502      							if  State==15 
replace gaul_adm1_code = 1509      							if  State==16 
replace gaul_adm1_code = 1501     							if  State==17 
replace gaul_adm1_code = 1487      							if  State==18 
replace gaul_adm1_code = 1511      							if  State==19 
replace gaul_adm1_code = 70078						      	if  State==20 
replace gaul_adm1_code = 1504      							if  State==21 
replace gaul_adm1_code = 70075      						if  State==22 
replace gaul_adm1_code = 70079     							if  State==23 
replace gaul_adm1_code = 1491      							if  State==24 
replace gaul_adm1_code = 70077 								if  State==25 
replace gaul_adm1_code = 70076								if  State==26
replace gaul_adm1_code = 1498      							if  State==27 
replace gaul_adm1_code = 1485      							if  State==28 | State==36 
replace gaul_adm1_code = 1494     							if  State==29 
replace gaul_adm1_code = 1490      							if  State==30 
replace gaul_adm1_code = 1496      							if  State==31 
replace gaul_adm1_code = 1495      							if  State==32 
replace gaul_adm1_code = 1508      							if  State==33 
replace gaul_adm1_code = 70080     							if  State==34 
replace gaul_adm1_code = 1484     							if  State==35 
*</_gaul_adm1_code_>
*</_gaul_adm1_code_>

*<_gaul_adm2_code_>
gen   gaul_adm2_code = .
notes gaul_adm2_code: missing variable
*<_gaul_adm2_code_>

*<_urban_>
*<_urban_note_> uban/rural *</_urban_note_>
/*<_urban_note_> Urban or rural location of households *</_urban_note_>*/
*<_urban_note_> 0 "Rural"  1 "Urban"  *</_urban_note_>
capture drop urban
destring Sector, replace
gen 	urban = 0	if  Sector==1 
replace urban = 1	if  Sector==2
*</_urban_>

*<_Keep variables_>
order countrycode year hhid pid weight weighttype
sort  hhid pid
*</_Keep variables_>


*<_Save data file_>
compress
quietly do 	"$rootdofiles\_aux\Labels_GMD3.0.do"
save 		"$output\\`filename'.dta", replace
*</_Save data file_>
	
	