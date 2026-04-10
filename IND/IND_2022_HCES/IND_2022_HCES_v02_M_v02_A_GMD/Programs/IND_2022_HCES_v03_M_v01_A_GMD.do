/*------------------------------------------------------------------------------
  GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   		IND_2022-23_HCES_v03_M_v01_A.do		   </_Program name_>
<_Application_>    		STATA 17.0							     <_Application_>
<_Author(s)_>      		tornarolli@gmail.com	          		  </_Author(s)_>
<_Date created_>   		31-07-2025	                           </_Date created_>
<_Date modified>   		04-08-2025	                          </_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        		IND											</_Country_>
<_Survey Title_>   		HCES								   </_Survey Title_>
<_Survey Year_>    		2022-2023  								</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:					04-08-2025
File:					IND_2022-23_HCES_v03_M_v01_A.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>
clear all
set more off

local code         		"IND"
local year         		"2022"
local survey       		"HCES"
local vm           		"03"
local va            	"01"
local type         		"SARMD"
global module       	"GMD"
local yearfolder   		"`code'_`year'_`survey'"
local SARMDfolder   	"`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD"
cap mkdir				"${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'" 
cap mkdir				"${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\\Data" 
cap mkdir				"${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\\Data\Harmonized" 
global input      		"${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata"
local filename      	"`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'_${module}"
global output       	"${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\\Data\Harmonized" 
*</_Program setup_>


*<_Datalibweb request_>
use "${input}\\`yearfolder'_v`vm'_M.dta", clear
merge m:1 hhid using "${input}\\IND_PRIMUS_2022-23.dta", keepusing(sector state stratum welfarenom_base welfaredef_base pwt welfarenom_final welfaredef_final cpi_2022 cpi_2017 cpi_2021 hhwt hhsize)
drop _merge
*</_Datalibweb request_>


*****************************************************************
*** IDENTIFICATION VARIABLES 
*****************************************************************

*<_countrycode_> 
*<_countrycode_note_> Country code according to ISO-3166 Alpha-3 *</_countrycode_note_>
gen countrycode = "`code'"
gen code = countrycode
*</_countrycode_>

*<_year_>
*<_year_note_> 4-digit year of survey based on IHSN standards *</_year_note_>
capture drop year 
gen year = 2022
*</_year_>

*<_survey_>
*<_survey_note_> Survey acronym *</_survey_note_>
capture drop survey
gen str survey = "`survey'"
label var survey "Household Consumption Expenditure Survey: 2022-2023"
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
gen 	int_year = 2022		if  panel>=1 & panel<=5
replace int_year = 2023		if  panel>=6 & panel<=10
*</_int_year_>

*<_int_month_>
*<_int_month_note_> Interview Month *</_int_month_note_>
*<_int_month_note_> 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December" *</_int_month_note_>
gen 	int_month = 8		if  panel==1
replace int_month = 9		if  panel==2
replace int_month = 10		if  panel==3
replace int_month = 11		if  panel==4
replace int_month = 12		if  panel==5
replace int_month = 1		if  panel==6
replace int_month = 2		if  panel==7
replace int_month = 3		if  panel==8
replace int_month = 4		if  panel==9
replace int_month = 5		if  panel==10
label define int_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
label values int_month int_month
clonevar month = int_month
*</_int_month_>

*<_hhid_>
*<_hhid_note_> Household identifier  *</_hhid_note_>
/*<_hhid_note_> . *</_hhid_note_>*/
*<_hhid_note_> hhid brought in from SARMD *</_hhid_note_>
*</_hhid_>

*<_pid_>
*<_pid_note_> Personal identifier  *</_pid_note_>
/*<_pid_note_> country specific *</_pid_note_>*/
*<_pid_note_> pid brought in from SARMD *</_pid_note_>
*</_pid_>

*<_hhid_orig_>
*<_hhid_orig_note_> Household identifier variables in the raw data are FSU, B1Q1PT11, and B1Q1PT12 *</_hhid_org_note_>
gen hhid_orig = "FSU B1Q1PT11 B1Q1PT12"
*</_hhid_orig_>

*<_pid_orig_>
*<_pid_orig_note_> Personal identifier variables in the raw data are FSU, B1Q1PT11, B1Q1PT12, and B3Q1 *</_pid_org_note_>
gen pid_orig = "FSU B1Q1PT11 B1Q1PT12 B3Q1"
*</_pid_orig_>

*<_psu_>
*<_psu_note_> Primary sampling units *</_psu_note_>
destring fsu, replace
gen psu = fsu
*</_psu_>

*<_strata_>
*<_strata_note_> Strata *</_strata_note_>
/*<_strata_note_> Survey specific information *</_strata_note_>*/
*<_strata_note_>  *</_strata_note_>
* SECTOR + STATE + STRATUM????
gen strata = .
*</_strata_>

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


*****************************************************************
*** DEMOGRAPHIC VARIABLES 
*****************************************************************

*<_hsize_>
*<_hsize_note_> Household size *</_hsize_note_>
/*<_hsize_note_> specifies varname for the household size number in the data file. It has to be compatible with the numbers of national and international poverty at household size when weights are used in any computation *</_hsize_note_>*/
*<_hsize_note_>  *</_hsize_note_>
gen hsize = hhsize
*</_hsize_>

*<_age_>
*<_age_note_> Age of individual (continuous) *</_age_note_>
/*<_age_note_> Age is an important variable for most socio-economic analysis and must be established as accurately as possible. Especially for children aged less than 5 years, this is used to interpret Anthropometrics data. Ages >= 98 must be coded as 98.  (N *</_age_note_>*/
*<_age_note_>  *</_age_note_>
gen age = b3q5
*</_age_>

*<_male_>
*<_male_note_> Sex of household member (male=1) *</_male_note_>
/*<_male_note_> specifies varname for sex of household member (head), where 1 = Male and 0 = Female. *</_male_note_>*/
*<_male_note_>  1 " Male" 0 "Female" *</_male_note_>
gen 	male = .
replace male = 0					if  b3q4==2
replace male = 1					if  b3q4==1
replace male = 9					if  b3q4==3
notes   male: male = 9 refers to cases answering "Transgender"
*</_male_>

*<_relationcs_>
*<_relationcs_note_> Relationship to head of household country/region specific *</_relationcs_note_>
/*<_relationcs_note_> country or regionally specific categories *</_relationcs_note_>*/
*<_relationcs_note_>  1 "Head of the household" 2 "Wife/Husband" 3 "Son/Daughter" 4 "Parents of head of the household/spouse" 5 "Other Relative" 6 "Domestic Servant/Driver/Watcher" 7 "Boarder" 9 "Other" *</_relationcs_note_>
label define b3q3 1 "1 - Head of the household" 2 "2 - Spouse of the Head" 3 "3 - Married Child" 4 "4 - Spouse of Married Child" 5 "5 - Unmarried Child" 6 "6 - Geandchild" 7 "7 - Father/Mother/Father-in-law/Mother-in-law" 8 "8- Brother/Sister/Brother-in-law/Sister-in-law" 9 "9 - Servants/Employees/Other non-relatives"
label values b3q3 b3q3
decode b3q3, gen(relationcs)
*</_relationcs_>

*<_relationharm_>
*<_relationharm_note_> Relationship to head of household harmonized across all regions *</_relationharm_note_>
/*<_relationharm_note_> Harmonized categories across all regions. *</_relationharm_note_>*/
*<_relationharm_note_>  1 "Head" 2 "Spouse" 3 "Child" 4 "Parents" 5 "Other relative" 6 "Non-relative" *</_relationharm_note_>
gen 	relationharm = .
replace relationharm = 1			if  b3q3==1
replace relationharm = 2			if  b3q3==2
replace relationharm = 3			if  b3q3==3 | b3q3==5
replace relationharm = 4			if  b3q3==7
replace relationharm = 5			if  b3q3==4 | b3q3==6 | b3q3==8 
replace relationharm = 6			if  b3q3==9
*</_relationharm_>

*<_soc_>
*<_soc_note_> Social group *</_soc_note_>
/*<_soc_note_> The classification is country specific.
It not needs to be present for every country/year. *</_soc_note_>*/
*<_soc_note_>  *</_soc_note_>
destring b4q4pt12, replace
gen 	soc = "."
replace soc = "1 - Scheduled Tribe"			if  b4q4pt12==1
replace soc = "2 - Scheduled Caste"			if  b4q4pt12==2
replace soc = "3 - Other Backward Caste"		if  b4q4pt12==3
replace soc = "9 - Other"					if  b4q4pt12==9
notes   soc: missing values are cases where caste is not reported
*</_soc_>

*<_marital_>
*<_marital_note_> Marital status *</_marital_note_>
/*<_marital_note_> Do not impute.  Calculate only for those to whom the question was asked (in other words, the youngest age at which information is collected may differ depending on the survey). Living together includes common-law marriages, union coutumiere, uni *</_marital_note_>*/
*<_marital_note_>  1 "Married" 2 "Never married" 3 "Living together" 4 "Divorced/Separated" 5 "Widowed" *</_marital_note_>
gen 	marital = .
replace marital = 1				if  b3q6==2 
replace marital = 2 				if  b3q6==1
replace marital = 4 				if  b3q6==4 
replace marital = 5 				if  b3q6==3
*</_marital_>


*****************************************************************
*** GEOGRAPHICAL VARIABLES 
*****************************************************************

*<_urban_>
*<_urban_note_> uban/rural *</_urban_note_>
/*<_urban_note_> Urban or rural location of households *</_urban_note_>*/
*<_urban_note_> 0 "Rural"  1 "Urban"  *</_urban_note_>
capture drop urban
gen 	urban = .
replace urban = 0				if  sector==1 
replace urban = 1				if  sector==2
*</_urban_>

*<_subnatid1_>
*<_subnatid1_note_>  Subnational ID - highest level *</_subnatid1_note_>
/*<_subnatid1_note_> Subnational id - subnational regional identifiers at which survey is representative - highest level *</_subnatid1_note_>*/
*<_subnatid1_note_>  *</_subnatid1_note_>
gen   aux_state = round(state)
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
gen   subnatid2 = ""
notes subnatid2: HCES 2022-23 does not have a smaller level of representativeness than state (used in subnatid1)
*</_subnatid2_>

*<_subnatid3_>
*<_subnatid3_note_>  Subnational ID - third highest level *</_subnatid3_note_>
/*<_subnatid3_note_> Subnational id - subnational regional identifiers at which survey is representative - third highest level *</_subnatid3_note_>*/
*<_subnatid3_note_>  *</_subnatid3_note_>
gen   subnatid3 = ""
notes subnatid3: HCES 2022-23 does not have a smaller level of representativeness than state (used in subnatid1)
*</_subnatid3_>   

*<_subnatid4_>
*<_subnatid4_note_>  Subnational ID - fourth highest level *</_subnatid4_note_>
/*<_subnatid4_note_> Subnational id - subnational regional identifiers at which survey is representative - fourth highest level *</_subnatid4_note_>*/
*<_subnatid4_note_>  *</_subnatid4_note_>
gen   subnatid4 = ""
notes subnatid4: HCES 2022-23 does not have a smaller level of representativeness than state (used in subnatid1)
*</_subnatid4_>   

*<_subnatidsurvey_>
gen subnatidsurvey = subnatid1
*<_subnatidsurvey_>

*<_subnatid1_prev>
gen subnatid1_prev = subnatid1
*<_subnatid1_prev_>

*<_subnatid1_prev>
gen subnatid2_prev = subnatid2
*<_subnatid1_prev_>

*<_subnatid1_prev>
gen subnatid3_prev = subnatid3
*<_subnatid1_prev_>

*<_subnatid1_prev>
gen subnatid4_prev = subnatid4
*<_subnatid1_prev_>

*<_gaul_adm1_code_>
*<_gaul_adm1_code_note_> Gaul Code *</_gaul_adm1_code_note_>
/*<_gaul_adm1_code_note_> . *</_gaul_adm1_code_note_>*/
*<_gaul_adm1_code_note_> gaul_adm1_code brought in from rawdata *</_gaul_adm1_code_note_>
gen 	gaul_adm1_code = .   
replace gaul_adm1_code = 75200					if  state==1 
replace gaul_adm1_code =  1493            	    if  state==2 
replace gaul_adm1_code =  1505            	    if  state==3 
replace gaul_adm1_code = 70074            	    if  state==4 
replace gaul_adm1_code = 70082            	    if  state==5 
replace gaul_adm1_code =  1492            	    if  state==6 
replace gaul_adm1_code =  1489            	    if  state==7 
replace gaul_adm1_code =  1506            	    if  state==8 
replace gaul_adm1_code = 70081            	    if  state==9 
replace gaul_adm1_code = 70073            	    if  state==10 
replace gaul_adm1_code =  1507            	    if  state==11 
replace gaul_adm1_code = 70072            	    if  state==12 
replace gaul_adm1_code =  1503            	    if  state==13 
replace gaul_adm1_code =  1500            	    if  state==14 
replace gaul_adm1_code =  1502            	    if  state==15 
replace gaul_adm1_code =  1509            	    if  state==16 
replace gaul_adm1_code =  1501            	    if  state==17 
replace gaul_adm1_code =  1487            	    if  state==18 
replace gaul_adm1_code =  1511            	    if  state==19 
replace gaul_adm1_code = 70078            	    if  state==20 
replace gaul_adm1_code =  1504            	    if  state==21 
replace gaul_adm1_code = 70075            	    if  state==22 
replace gaul_adm1_code = 70079            	    if  state==23 
replace gaul_adm1_code =  1491            	    if  state==24 
replace gaul_adm1_code = 70076 					if  state==25 
replace gaul_adm1_code =  1498            	    if  state==27 
replace gaul_adm1_code =  1485            	    if  state==28 
replace gaul_adm1_code =  1494            	    if  state==29 
replace gaul_adm1_code =  1490            	    if  state==30 
replace gaul_adm1_code =  1496            	    if  state==31 
replace gaul_adm1_code =  1495            	    if  state==32 
replace gaul_adm1_code =  1508            	    if  state==33 
replace gaul_adm1_code = 70080            	    if  state==34 
replace gaul_adm1_code =  1484            	    if  state==35 
*replace gaul_adm1_code = "36 - Telangana"       if  state==36 
*replace gaul_adm1_code = "37 - Ladakh"          if  state==37 
notes   gaul_adm1_code: There are not GAUL codes for "Telangana" and "Ladakh", probably because they are disputed territories
*</_gaul_adm1_code_>

*<_gaul_adm2_code_>
gen gaul_adm2_code = .
*<_gaul_adm2_code_>


*****************************************************************
*** EDUCATION VARIABLES 
*****************************************************************
/*
*<_atschool_>
*<_atschool_note_> Attending school *</_atschool_note_>
/*<_atschool_note_> Variable is constructed for all persons administered this module in each questionnaire, typically of primary age and older.  For this reason the lower age cutoff will vary from country to country. 
If person on short school holiday when intervie *</_atschool_note_>*/
*<_atschool_note_>  1 "Yes" 0 "No" *</_atschool_note_>
destring b4pt2423_2 b4pt2423_3, replace
gen   auxi_age = 1				if  b3q5>=6 & b3q5<=14
egen total_age_edu = sum(auxi_age), by(hhid)
egen total_in_edu = rsum(b4pt2423_2 b4pt2423_3)

gen 	atschool = .
replace atschool = 0				if  b3q5>=6 & b3q5<=14 & total_age_edu>total_in_edu
replace atschool = 1				if  b3q5>=6 & b3q5<=14 & total_in_edu>=total_age_edu
notes   atschool: variable defined for individuals aged between 6 and 14
*</_atschool_>
*/
*<_school_>
*<_school_note_> Currently enrolled in or attending school *</_school_note_>
/*<_school_note_>  1 "Yes" 0 "No" *</_school_note_>*/
*gen   school = atschool
gen   school = .
notes school: the HCES does not contain information to define this variable
*</_school_>

*<_educy_>
*<_educy_note_> Years of education *</_educy_note_>
/*<_educy_note_> Variable is constructed for all persons administered this module in each questionnaire. For this reason the lower age cutoff at which information is collected will vary from country to country. 
This is a continuous variable of the number of years of formal schooling completed *</_educy_note_>*/
*<_educy_note_>  *</_educy_note_>
replace b3q8 = 0			if   b3q7<=2 & b3q8==.
gen educy = b3q8 
*</_educy_>

*<_educat7_>
*<_educat7_note_> Level of education 7 categories *</_educat7_note_>
/*<_educat7_note_> Secondary is everything from the end of primary to before tertiary (for example, grade 7 through 12). Vocational training is country-specific and will be defined by each region.  *</_educat7_note_>*/
*<_educat7_note_>  1 "No education" 2 "Primary incomplete" 3 "Primary complete" 4 "Secondary incomplete" 5 "Secondary complete" 6 "Post secondary but not university" 7 "University" *</_educat7_note_>
gen educat7 = .
replace educat7 = 1 if  b3q7==1 | b3q7==2
replace educat7 = 2 if  b3q7==3
replace educat7 = 2 if  b3q7==4 & b3q8>=4 & b3q8<=6
replace educat7 = 3 if  b3q7==4 & b3q8>=7 & b3q8<=11
replace educat7 = 4 if  b3q7==5
replace educat7 = 4 if  b3q7==6 & b3q8>=10 & b3q8<=11
replace educat7 = 5 if (b3q7==6 & b3q8>=12 & b3q8<=18) | ((b3q7==8 | b3q7==10) & b3q8==12) 
replace educat7 = 5 if (b3q7==8 & b3q8>=8 & b3q8<=11) | (b3q7==10 & b3q8>=10 & b3q8<=11)
replace educat7 = 5 if  b3q7==7
replace educat7 = 6 if (b3q7==8 & b3q8>=13 & b3q8<=18) | (b3q7==10 & b3q8>=13 & b3q8<=18)
replace educat7 = 6 if  b3q7==11
replace educat7 = 7 if  b3q7==12 | b3q7==13
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


*****************************************************************
*** HOUSING VARIABLES 
*****************************************************************

*<_ownhouse_>
*<_ownhouse_note_> SARMD ownhouse variable *</_ownhouse_note_>
/*<_ownhouse_note_> Refers to ownership status of the dwelling unit by the household residing in it.     *</_ownhouse_note_>*/
*<_ownhouse_note_>  1 "Ownership/secure rights" 2 "Renting" 3 "Provided for free" 4 "Without permission" *</_ownhouse_note_>
gen     ownhouse = .
replace ownhouse = 1 			if  b4q4pt17==1 		/* owned		 */
replace ownhouse = 2 			if  b4q4pt17==2		/* hired		 */
notes   ownhouse: missing values are cases in which the raw data variables is "other"
*</_ownhouse_>

*<_typehouse_>
*<_typehouse_note_> GMD ownhouse variable *</_typehouse_note_>
*<_typehouse_note_> typehouse brought in from GMD *</_typehouse_note_>
clonevar typehouse = ownhouse
*</_typehouse_>

*<_water_orig_>
*<_water_orig_note_> Source of Drinking Water-Original from raw file *</_water_orig_note_>
/*<_water_orig_note_> Original categories from source of drinking water *</_water_orig_note_>*/
*<_water_orig_note_>  *</_water_orig_note_>
label define b4q4pt23 1 "01 - Bottled Water" 2 "02 - Piped Water into Dwelling" 3 "03 - Piped Water to Yard/Plot" 4 "04 - Piped Water from Neighbour" 5 "05 - Public Tap/Standpipe" 6 "06 - Tubewell" 7 "07 - Hand Pump" 8 "08 - Well: Protected" 9 "09 - Well: Unprotected" 10 "10 - Tanker Trunk: Public" 11 "11 - Tanker Trunk: Private" 12 "12 - Spring: Protected" 13 "13 - Spring: Unprotected" 14 "14 - Rainwater Collection" 15 "15 - Surface Water: Tank/Pond" 16 "16 - Other Surface Water (River/Dam/Stream)" 19 "19 - Other (Cart with Small Tank/Drum)"
label values b4q4pt23 b4q4pt23
decode b4q4pt23, gen(water_orig)
*</_water_orig_>

*<_water_source_>
*<_water_source_note_> Sources of drinking water *</_water_source_note_>
/*<_water_source_note_> 1 "Piped water into dwelling" 2 "Piped water to yard/plot" 3 "Public tap or standpipe" 4 "Tube well or borehole" 5 "Protected dug well" 6 "Protected spring" 7 "Bottled water" 8 "Rainwater" 9 "Unprotected spring" 10 "Unprotected dug well" 11 "Cart with small tank/drum" 12 "Tanker-truck" 13 "Surface water" 14 "Other" *</_water_source_note_>*/
*<_water_source_note_> water_source brought in from rawdata *</_water_source_note_>
gen     water_source = .
replace water_source = 1			if  b4q4pt23==2
replace water_source = 2			if  b4q4pt23==3
replace water_source = 3			if  b4q4pt23==5
replace water_source = 4			if  b4q4pt23==6 | b4q4pt23==7
replace water_source = 5			if  b4q4pt23==8
replace water_source = 6			if  b4q4pt23==12
replace water_source = 7			if  b4q4pt23==1
replace water_source = 8			if  b4q4pt23==14
replace water_source = 9			if  b4q4pt23==13
replace water_source = 10			if  b4q4pt23==9
replace water_source = 11			if  b4q4pt23==19
replace water_source = 12			if  b4q4pt23==10 | b4q4pt23==11
replace water_source = 13			if  b4q4pt23==15 | b4q4pt23==16
replace water_source = 14			if  b4q4pt23==4  
*</_water_source_>

*<_piped_>
*<_piped_note_>  Access to piped water *</_piped_note_>
/*<_piped_note_>  *</_piped _note_>*/
*<_piped_note_> piped  brought in from rawdata *</_piped_note_>
gen 	piped = 0
replace piped = 1				if  water_source>=1 & water_source<=3
*</_piped_>

*<_piped_to_prem_>
*<_piped_to_prem_note_> Access to piped water on premises *</_piped_to_prem_note_>
/*<_piped_to_prem_note_> 1 "Yes" 0 "No" *</_piped_to_prem_note_>*/
*<_piped_to_prem_note_> piped_to_prem brought in from rawdata *</_piped_to_prem_note_>
gen 	piped_to_prem = 0	
replace piped_to_prem = 1			if  water_source>=1 & water_source<=2
*</_piped_to_prem_>

*<_water_jmp_>
*<_water_jmp_note_> Source of drinking water, using Joint Monitoring Program categories *</_water_jmp_note_>
*<_wate_jmp_note_> 1 "Piped into dwelling" 2 "Piped into compound, yard or plot" 3 "Public tap/standpipe" 4 "Tubewell, Borehole" 5 "Protected well" 6 "Unprotected well" 7 "Protected spring" 8 "Unprotected spring" 9 "Rain water" 10 "Tanker-truck or other vendor" 11 "Cart with small tank/drum" 12 "Surface water (river, stream, dam, lake, pond) 13 "Bottled water" 14 "Other" *</_wate_jmp_note_>
gen 	water_jmp = .
replace water_jmp = 1 			if  water_source==1
replace water_jmp = 2 			if  water_source==2
replace water_jmp = 3 			if  water_source==3
replace water_jmp = 4 			if  water_source==4
replace water_jmp = 5 			if  water_source==5
replace water_jmp = 6 			if  water_source==10
replace water_jmp = 7 			if  water_source==6
replace water_jmp = 8 			if  water_source==9
replace water_jmp = 9 			if  water_source==8
replace water_jmp = 10 			if  water_source==12 
replace water_jmp = 11			if  water_source==11
replace water_jmp = 12			if  water_source==13
replace water_jmp = 13			if  water_source==7
replace water_jmp = 14			if  water_source==14
*</_water_jmp_>

*<_piped_water_>
*<_piped_water_note_> Household has access to piped water *</_piped_water_note_>
/*<_piped_water_note_> Variable takes the value of 1 if household has access to piped water. *</_piped_water_note_>*/
*<_piped_water_note_>  1 "Yes" 0 "No" *</_piped_water_note_>
gen 	piped_water = .
replace piped_water = 0			if  b4q4pt23!=.
replace piped_water = 1			if  b4q4pt23>=2 & b4q4pt23<=4		
*</_piped_water_>

*<_pipedwater_acc_>
*<_pipedwater_acc_note_> Access to piped water *</_pipedwater_acc_note_>
/*<_pipedwater_acc_note_>  *</_pipedwater_acc_note_>*/
*<_pipedwater_acc_note_> piped  brought in from rawdata *</_pipedwater_acc_note_>
gen  	pipedwater_acc = 0		if  b4q4pt23!=.
replace pipedwater_acc = 1		if  b4q4pt23==2
replace pipedwater_acc = 2		if  b4q4pt23>=3 & b4q4pt23<=4
*</_pipedwater_acc_>

*<_sar_improved_water_>
*<_sar_improved_water_note_> Improved source of drinking water-using country-specific definitions *</_sar_improved_water_note_>
/*<_sar_improved_water_note_> Dummy variable: 1=improved, 0=unimproved source following JMP guidelines *</_sar_improved_water_note_>*/
*<_sar_improved_water_note_>  1 "Yes" 0 "No" *</_sar_improved_water_note_>
gen  	sar_improved_water = .
replace sar_improved_water = 1	if (water_jmp>=1 & water_jmp<=5) | water_jmp==7 | water_jmp==9
replace sar_improved_water = 0	if  water_jmp==6 | water_jmp==8 | (water_jmp>=10 & water_jmp<=14)
*</_sar_improved_water_>

*<_imp_wat_rec_>
*<_imp_wat_rec_note_> Improved water recommended estimate *</_imp_wat_rec_note_>
/*<_imp_wat_rec_note_> 1 "Yes" 0 "No" *</_imp_wat_rec_note_>*/
*<_imp_wat_rec_note_> imp_wat_rec brought in from rawdata *</_imp_wat_rec_note_>
gen imp_wat_rec = sar_improved_water
*</_imp_wat_rec_>

*<_w_30m_>
*<_w_30m_note_> Access to water within 30 minutes *</_w_30m_note_>
/*<_w_30m_note_> 1 "Collection time of imp_wat_rec less than or equal to 30 mins" 0 "Collection time of imp_wat_rec more than 30 mins" *</_w_30m_note_>*/
*<_w_30m_note_> w_30m brought in from rawdata *</_w_30m_note_>
destring b4q4pt24, replace
gen 	w_30m = .
replace w_30m = 0				if  b4q4pt24>=0 & b4q4pt24<=30
replace w_30m = 1				if  b4q4pt24>30 & b4q4pt24<.
*</_w_30m_>

*<_w_avail_>
*<_w_avail_note_> Water is available when needed *</_w_avail_note_>
/*<_w_avail_note_> 1 "water is available continuously, reliable source" 0 "water source is unreliable" *</_w_avail_note_>*/
*<_w_avail_note_> w_avail brought in from rawdata *</_w_avail_note_>
gen   w_avail = .
notes w_avail: the HCES does not contain information to define this variable
*</_w_avail_>

*<_watertype_quest_>
gen watertype_quest = 1
*</_watertype_quest_>

*<_toilet_orig_>
*<_toilet_orig_note_> sanitation facility original *</_toilet_orig_note_>
/*<_toilet_orig_note_> Original categories from access to toilet *</_toilet_orig_note_>*/
*<_toilet_orig_note_>  *</_toilet_orig_note_>
label define latrine_type2 1 "01 - Flush/Pour Flush to Piped Sewer System" 2 "02 - Flush/Pour Flush to Septic Tank" 3 "03 - Flush/Pour Flush to Twin Leach Pit" 4 "04 -Flush/Pour Flush to Single Leach Pit" 5 "05 - Flush/Pour Flush to Elsewhere" 6 "06 - Ventilated Improved Pit Latrine" 7 "07 - Pit Latrine with Slab" 8 "08 - Pit Latrine without Slab" 10 "10 - Composting Latrine" 11 "11 - Open Drain" 19 "19 - Others"
label values b4q4pt26 latrine_type2
decode b4q4pt26, gen(toilet_orig)
replace toilet_orig = "12 - No facilities"		if  b4q4pt25==5
*</_toilet_orig_>

*<_sanitation_source_>
*<_sanitation_source_note_> Sources of sanitation facilities *</_sanitation_source_note_>
/*<_sanitation_source_note_> 1 "A flush toilet" 2 "A piped sewer system" 3 "A septic tank" 4 "Pit latrine" 5 "Ventilated improved pit latrine (VIP)" 6 "Pit latrine with slab" 7 "Composting toilet" 8 "Special case" 9 "A flush/pour flush to elsewhere" 10 "A pit latrine without slab" 11 "Bucket" 12 "Hanging toilet or hanging latrine" 13 "No facilities or bush or field" 14 "Other" *</_sanitation_source_note_>*/
*<_sanitation_source_note_> sanitation_source brought in from rawdata *</_sanitation_source_note_>
gen     sanitation_source = .
replace sanitation_source = 1			if  b4q4pt26==3 | b4q4pt26==4	
replace sanitation_source = 2			if  b4q4pt26==1 
replace sanitation_source = 3			if  b4q4pt26==2
replace sanitation_source = 5			if  b4q4pt26==6
replace sanitation_source = 6			if  b4q4pt26==7
replace sanitation_source = 7			if  b4q4pt26==10
replace sanitation_source = 9			if  b4q4pt26==5
replace sanitation_source = 10		if  b4q4pt26==8
replace sanitation_source = 13		if  b4q4pt26==11 | b4q4pt25==5
replace sanitation_source = 14		if  b4q4pt26==19
*</_sanitation_source_>

*<_sewage_toilet_>
*<_sewage_toilet_note_> Household has access to sewage toilet *</_sewage_toilet_note_>
/*<_sewage_toilet_note_> Variable takes the value of 1 if household has access to sewage toilet. *</_sewage_toilet_note_>*/
*<_sewage_toilet_note_>  1 "Yes" 0 "No" *</_sewage_toilet_note_>
gen     sewage_toilet = .
replace sewage_toilet = 0				if  b4q4pt26!=. | b4q4pt25==5
replace sewage_toilet = 1				if  b4q4pt26==1 	
*</_sewage_toilet_>

*<_toilet_jmp_>
*<_toilet_jmp_note_> Access to sanitation facility-using Joint Monitoring Program categories *</_toilet_jmp_note_>
*<_toilet_jmp_note_> 1 "Flush to piped sewer system" 2 "Flush to septic tank" 3 "Flush to pit latrine" 4 "Flush to somewhere else" 5 "Flush, don't know where" 6 "Ventilated improved pit latrine" 7 "Pit latrine with slab" 8 "Pit latrine without slab/open pit" 9 "Composting toilet" 10 "Bucket toilet" 11 "Hanging toilet/Hanging latrine" 12 "No facility/bush/field" 13 "Other" *</_toilet_jmp_note_>
gen 	toilet_jmp = .
replace toilet_jmp = 1				if  b4q4pt26==1
replace toilet_jmp = 2				if  b4q4pt26==2
replace toilet_jmp = 3				if  b4q4pt26==3 | b4q4pt26==4
replace toilet_jmp = 4				if  b4q4pt26==5
replace toilet_jmp = 6				if  b4q4pt26==6
replace toilet_jmp = 7				if  b4q4pt26==7
replace toilet_jmp = 8				if  b4q4pt26==8
replace toilet_jmp = 9				if  b4q4pt26==10
replace toilet_jmp = 12				if  b4q4pt26==11 | b4q4pt25==5
replace toilet_jmp = 13				if  b4q4pt26==19
*</_toilet_jmp_>

*<_sar_improved_toilet_>
*<_sar_improved_toilet_note_> Improved type of sanitation facility-using country-specific definitions *</_sar_improved_toilet_note_>
/*<_sar_improved_toilet_note_> Dummy variable: 1=improved, 0=unimproved source following JMP guidelines *</_sar_improved_toilet_note_>*/
*<_sar_improved_toilet_note_>  1 "Yes" 0 "No" *</_sar_improved_toilet_note_>
gen 	sar_improved_toilet = .
replace sar_improved_toilet = 1		if (toilet_jmp>=1 & toilet_jmp<=3) | toilet_jmp==6 | toilet_jmp==7 | toilet_jmp==9
replace sar_improved_toilet = 0		if  toilet_jmp==4 | toilet_jmp==5 | (toilet_jmp>=8 & toilet_jmp<=13)
replace sar_improved_toilet = 0		if  b4q4pt25!=1		/* shared facilities */
*</_sar_improved_toilet_>

*<_imp_san_rec_>
*<_imp_san_rec_note_> Improved sanitation facility recommended estimate (not considering sharing) *</_imp_san_rec_note_>
/*<_imp_san_rec_note_> 1 "Yes" 0 "No" *</_imp_san_rec_note_>*/
*<_imp_san_rec_note_> imp_san_rec brought in from rawdata *</_imp_san_rec_note_>
gen imp_san_rec = sar_improved_toilet
*</_imp_san_rec_>

*<_toilet_acc_>
*<_toilet_acc_> Access to flushed toilet *</_toilet_acc_note_>
gen 	toilet_acc = 3 				if  imp_wat_rec==1 & b4q4pt26>=1 & b4q4pt26<=5
replace toilet_acc = 0				if  imp_wat_rec==1 & b4q4pt26>=6 & b4q4pt26<=19
replace toilet_acc = 0 				if  imp_wat_rec==0 
*</_toilet_acc_>

*<_electricity_>
*<_electricity_note_> Access to electricity *</_electricity_note_>
/*<_electricity_note_> Refers to Public or quasi public service availability of electricity from mains. 
Note that having an electrical connection says nothing about the actual electrical service received by the household in a given country or area.
This variable must have the same value for all members of the household *</_electricity_note_>*/
*<_electricity_note_> 1 "Yes" 0 "No" *</_electricity_note_>
destring b4q4pt22, replace
gen 	electricity = .
replace electricity = 0				if  b4q4pt22!=.
replace electricity = 1				if  b4q4pt22==1
notes   electricity: it includes electricity generated by wind and solar power generators
*</_electricity_>

*<_roof_>
*<_roof_note_> Main material used for roof *</_roof_note_>
/*<_roof_note_> 1 "Natural–Thatch/palm leaf" 2 "Natural–Sod" 3 "Natural–Other" 4 "Rudimentary–Rustic mat" 5 "Rudimentary–Palm/bamboo" 6 "Rudimentary–Wood planks" 7 "Rudimentary-Other" 8 "Finished–Roofing" 9 "Finished–Asbestos" 10 "Finished–Tile" 11 "Finished–Concrete" 12 "Finished–Metal tile" 13 "Finished–Roofing shingles" 14 "Finished–Other" 15 "Other–Specific" *</_roof_note_>*/
*<_roof_note_> roof brought in from raw data *</_roof_note_>
gen     roof = .
replace roof = 1						if  b4q4pt19==1						// grass-straw-leaves-reeds-bamboo-etc.			//
replace roof = 4						if  b4q4pt19==2						// mud-unburnt brick							//
replace roof = 7						if  b4q4pt19==3	| b4q4pt19==4		// canvas-cloth / other katcha					//
replace roof = 9						if  b4q4pt19==7						// iron-zinc-other metal sheet-asbestos sheet	//
replace roof = 10					if  b4q4pt19==5						// tiles-slate									//		
replace roof = 11					if  b4q4pt19==8						// cement-RBC-RCC								//
replace roof = 14					if  b4q4pt19==6 | b4q4pt19==9			// burnt brick-stone-lime stone	/ other pucca	//
notes roof: information refers to materials of outer exposed part of the roof
*</_roof_>

*<_wall_>
*<_wall_note_> Main material used for external walls *</_wall_note_>
/*<_wall_note_> 1 "Natural–Cane/palm/trunks" 2 "Natural–Dirt" 3 "Natural–Other" 4 "Rudimentary–Bamboo with mud" 5 "Rudimentary–Stone with mud" 6 "Rudimentary–Uncovered adobe" 7 "Rudimentary–Plywood" 8 "Rudimentary–Cardboard" 9 "Rudimentary–Reused wood" 10 "Rudimentary–Other" 11 "Finished–Woven Bamboo" 12 "Finished–Stone with lime/cement" 13 "Finished–Cement blocks"14 "Finished–Covered adobe" 15 "Finished–Wood planks/shingles" 16 "Finished–Plaster wire" 17 "Finished– GRC/Gypsum/Asbestos" 18 "Finished–Other" 19 "Other" *</_wall_note_>*/
*<_wall_note_> wall brought in from raw data *</_wall_note_>
gen 	wall = .
replace wall = 1						if  b4q4pt18==1							// grass-straw-leaves-reeds-bamboo-etc.			//
replace wall = 4 					if  b4q4pt18==2							// mud with or without bamboo-urburnt brick 	//
replace wall = 10					if  b4q4pt18==3	| b4q4pt18==4			// canvas-cloth / other katcha					//
replace wall = 15					if  b4q4pt18==5							// timber										//
replace wall = 12					if  b4q4pt18==6							// burnt brick-stone-lime stone					//
replace wall = 18					if  b4q4pt18==7 | b4q4pt18==9				// iron or other metal sheet / other pucca		//
replace wall = 13					if  b4q4pt18==8							// cement-RBC-RCC								//
*</_wall_>

*<_floor_>
*<_floor_note_> Main material used for floor *</_floor_note_>
/*<_floor_note_> 1 "Natural–Earth/sand" 2 "Natural–Dung" 3 "Natural–Other" 4 "Rudimentary–Wood planks" 5 "Rudimentary–Palm/bamboo" 6 "Rudimentary–Other" 7 "Finished–Parquet or polished wood" 8 "Finished–Vinyl or asphalt strips" 9 "Finished–Ceramic/marble/granite" 10 "Finished–Floor tiles/teraso" 11 "Finished–Cement/red bricks" 12 "Finished–Carpet" 13 "Finished–Other" 14 "Other–Specific" *</_floor_note_>*/
*<_floor_note_> floor brought in from raw data *</_floor_note_>
gen   	floor = .
replace floor = 5					if  b4q4pt20==1							// grass-straw-leaves-reeds-bamboo-etc.						//
replace floor = 2					if  b4q4pt20==2							// mud-urburnt brick										//
replace floor = 6					if  b4q4pt20==3	| b4q4pt20==4			// canvas-cloth	/ other katcha								//
replace floor = 10					if  b4q4pt20==5							// tiles-slate												//
replace floor = 11					if  b4q4pt20==6	| b4q4pt20==8			// burnt brick-stone-limestone / cement-RBC-RCC 			//
replace floor = 13					if  b4q4pt20==7	| b4q4pt20==9			// iron-zinc-other metal sheet-asbestos sheet / other pucca	//
*</_floor_>

*<_cooksource_>
*<_cooksource_note_> Main cooking fuel *</_cooksource_note_>
/*<_cooksource_note_>  1 "Firewood" 2 "Kerosene" 3 "Charcoal" 4 "Electricity" 5 "Gas" 9 "Other" 10 "No cook source" *</_cooksource_note_>*/
*<_cooksource_note_> cooksource brought in from rawdata *</_cooksource_note_>
gen 	cooksource = .
replace cooksource = 1				if  b4q4pt21==1											// firewood and chips 							//
replace cooksource = 2				if  b4q4pt21==5											// kerosene 									//
replace cooksource = 3				if  b4q4pt21==6 | b4q4pt21==10							// coke-coal / charcoal							//
replace cooksource = 4 				if  b4q4pt21==11											// Electricity									//
replace cooksource = 5				if  b4q4pt21==2 | b4q4pt21==3								// LPG / other natural gas 						//
replace cooksource = 9				if  b4q4pt21==4 | b4q4pt21==7 | b4q4pt21==8 | b4q4pt21==9	// dung cake / gobar gas / other biogas	/ Other	//  
replace cooksource = 10				if  b4q4pt21==12											// no cooking arrangement						//
notes 	cooksource: cooksource==4 ("charcoal") includes coke-coal and charcoal 
notes   cooksource: cooksource==9 ("other") includes dung cake, gobar gas, other biogas and other
*</_cooksource_>

*<_heatsource_>
*<_heatsource_note_> Main source of heating *</_heatsource_note_>
/*<_heatsource_note_> 1 "Firewood" 2 "Kerosene" 3 "Charcoal" 4 "Electricity" 5 "Gas" 6 "Central" 9 "Other" 10 "No heating" *</_heatsource_note_>*/
*<_heatsource_note_> heatsource brought in from rawdata *</_heatsource_note_>
gen   heatsource = .
notes heatsource: the HCES does not contain the information needed to define this variable
*</_heatsource_>

*<_lightsource_>
*<_lightsource_note_> Main source of lighting  *</_lightsource_note_>
/*<_lightsource_note_> 1 "Electricity" 2 "Kerosene" 3 "Candles" 4 "Gas" 9 "Other" 10 "No light source" *</_lightsource_note_>*/
*<_lightsource_note_> lightsource brought in from rawdata *</_lightsource_note_>
gen 	lightsource = .
replace lightsource = 1				if  b4q4pt22==1						// electricity (including generated by wind and solar power generators	// 
replace lightsource = 2				if  b4q4pt22==2						// kerosene																//
replace lightsource = 3				if  b4q4pt22==5						// candles 																//
replace lightsource = 4				if  b4q4pt22==4						// gas																	//
replace lightsource = 9				if  b4q4pt22==3 | b4q4pt22==9			// other oil / other													//
replace lightsource = 10				if  b4q4pt22==6						// no lighting arrangement												//
notes lightsource: cooksource==9 ("other") includes other oil and other
*</_lightsource_>


*****************************************************************
*** LABOR VARIABLES 
*****************************************************************

*<_minlaborage_>
*<_minlaborage_note_> Labor module application age *</_minlaborage_note_>
/*<_minlaborage_note_>  *</_minlaborage_note_>*/
*<_minlaborage_note_> lb_mod_age brought in from SARMD *</_minlaborage_note_>
gen   minlaborage = .
notes minlaborage: the HCES does not contain a labor module
*</_minlaborage_>

*<_lstatus_>
*<_lstatus_note_> Labor Force Status *</_lstatus_note_>
/*<_lstatus_note_> Variable is constructed for all persons administered this module in each questionnaire.  For this reason the lower age cutoff (and perhaps upper age cutoff) at which information is collected will vary from country to country. 
All persons are co *</_lstatus_note_>*/
*<_lstatus_note_>  1 "Employed" 2 "Unemployed" 3 "Not in labor force" *</_lstatus_note_>
gen   lstatus = .
notes lstatus: the HCES does not contain a labor module
*</_lstatus_>

*<_lstatus_year_>
*<_lstatus_year_note_> Labor status (12-mon ref period) *</_lstatus_year_note_>
/*<_lstatus_year_note_> 1 "Employed" 2 "Unemployed" 3 "Not in labor force" *</_lstatus_year_note_>*/
*<_lstatus_year_note_> lstatus_year brought in from rawdata *</_lstatus_year_note_>
gen   lstatus_year = .
notes lstatus_year: the HCES does not contain a labor module
*</_lstatus_year_>

*<_empstat_>
*<_empstat_note_> Employment status *</_empstat_note_>
/*<_empstat_note_> 1 "Paid Employee" 2 "Non-Paid Employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status" *</_empstat_note_>*/
*<_empstat_note_> empstat brought in from SARMD *</_empstat_note_>
gen   empstat = .
notes empstat: the HCES does not contain a labor module
*</_empstat_>

*<_empstat_year_>
*<_empstat_year_note_> Employment status, primary job (12-mon ref period) *</_empstat_year_note_>
/*<_empstat_year_note_> 1 "Paid Employee" 2 "Non-Paid Employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status" *</_empstat_year_note_>*/
*<_empstat_year_note_> empstat_year brought in from SARMD *</_empstat_year_note_>
gen   empstat_year = .
notes empstat_year: the HCES does not contain a labor module
*</_empstat_year_>

*<_ocusec_>
*<_ocusec_note_> Sector of activity *</_ocusec_note_>
/*<_ocusec_note_> 1 "Public sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish" *</_ocusec_note_>*/
*<_ocusec_note_> ocusec brought in from SARMD *</_ocusec_note_>
gen   ocusec = .
notes ocusec: the HCES does not contain a labor module
*</_ocusec_>

*<_ocusec_year_>
*<_ocusec_year_note_> Sector of activity, primary job (12-mon ref period) *</_ocusec_year_note_>
/*<_ocusec_year_note_> 1 "Public sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish" *</_ocusec_year_note_>*/
*<_ocusec_year_note_> ocusec_year brought in from SARMD *</_ocusec_year_note_>
gen   ocusec_year = .
notes ocusec_year: the HCES does not contain a labor module
*</_ocusec_year_>

*<_industrycat10_>
*<_industrycat10_note_> 1 digit industry classification *</_industrycat10_note_>
/*<_industrycat10_note_> 1 "Agriculture, Hunting, Fishing, etc." 2 "Mining" 3 "Manufacturing" 4 "Public Utility Services" 5 "Construction" 6 "Commerce" 7 "Transport and Communications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Others *</_industrycat10_note_>*/
*<_industrycat10_note_> industrycat10 brought in from rawdata *</_industrycat10_note_>
gen   industrycat10 = .
notes industrycat10: the HCES does not contain a labor module
*</_industrycat10_>

*<_industrycat4_>
*<_industrycat4_note_> 1 digit industry classification (Broad Economic Activities) *</_industrycat4_note_>
/*<_industrycat4_note_> 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other" *</_industrycat4_note_>*/
*<_industrycat4_note_> industrycat4 brought in from rawdata *</_industrycat4_note_>
gen   industrycat4 = .
notes industrycat4: the HCES does not contain a labor module
*</_industrycat4_>

*<_industrycat10_year_>
*<_industrycat10_year_note_> 1 digit industry classification, primary job (12-mon ref period) *</_industrycat10_year_note_>
/*<_industrycat10_year_note_> 1 "Agriculture, Hunting, Fishing, etc." 2 "Mining" 3 "Manufacturing" 4 "Public Utility Services" 5 "Construction" 6 "Commerce" 7 "Transport and Communications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Others *</_industrycat10_year_note_>*/
*<_industrycat10_year_note_> industrycat10_year brought in from SARMD *</_industrycat10_year_note_>
gen   industrycat10_year = .
notes industrycat10_year: the HCES does not contain a labor module
*</_industrycat10_year_>

*<_industrycat4_year_>
*<_industrycat4_year_note_> 4-category industry classification primary job (12-mon ref period) *</_industrycat4_year_note_>
/*<_industrycat4_year_note_> 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other" *</_industrycat4_year_note_>*/
*<_industrycat4_year_note_> industrycat4_year brought in from rawdata *</_industrycat4_year_note_>
gen   industrycat4_year = .
notes industrycat4_year: the HCES does not contain a labor module
*</_industrycat4_year_>

*<_occup_>
*<_occup_note_> 1 digit occupational classification *</_occup_note_>
/*<_occup_note_> 1 "Managers" 2 "Professionals" 3 "Technicians and associate professionals" 4 "Clerical support workers" 5 "Service and sales workers" 6 "Skilled agricultural, forestry and fishery workers" 7 "Craft and related trades workers" 8 "Plant and machine operators, and assemblers" 9 "Elementary occupations" 10 "Armed forces occupations" 99 "Other/unspecified"  *</_occup_note_>*/
*<_occup_note_> occup brought in from SARMD *</_occup_note_>
gen   occup = .
notes occup: the HCES does not contain a labor module
*</_occup_>

*<_occup_year_>
*<_occup_year_note_> 1 digit occupational classification, primary job (12-mon ref period) *</_occup_year_note_>
/*<_occup_year_note_> 1 "Managers" 2 "Professionals" 3 "Technicians and associate professionals" 4 "Clerical support workers" 5 "Service and sales workers" 6 "Skilled agricultural, forestry and fishery workers" 7 "Craft and related trades workers" 8 "Plant and machine operators, and assemblers" 9 "Elementary occupations" 10 "Armed forces occupations" 99 "Other/unspecified"  *</_occup_year_note_>*/
*<_occup_year_note_> occup_year brought in from SARMD *</_occup_year_note_>
gen   occup_year = .
notes occup_year: the HCES does not contain a labor module
*</_occup_year_>

*<_healthins_>
*<_healthins_note_> Health insurance *</_healthins_note_>
/*<_healthins_note_> 1 "Yes" 0 "No" *</_healthins_note_>*/
*<_healthins_note_> healthins brought in from SARMD *</_healthins_note_>
gen   healthins = .
notes healthins: the HCES does not contain a labor module
*</_healthins_>

*<_socialsec_>
*<_socialsec_note_> Social security *</_socialsec_note_>
/*<_socialsec_note_> 1 "Yes" 0 "No" *</_socialsec_note_>*/
*<_socialsec_note_> socialsec brought in from SARMD *</_socialsec_note_>
gen   socialsec = .
notes socialsec: the HCES does not contain a labor module
*</_socialsec_>


*****************************************************************
*** ASSETS VARIABLES 
*****************************************************************

*<_landphone_>
*<_landphone_note_> Ownership of a land phone (household) *</_landphone_note_>
/*<_landphone_note_> 1 "Yes" 0 "No" *</_landphone_note_>*/
*<_landphone_note_> landphone brought in from rawdata *</_landphone_note_>
gen   landphone = .
notes landphone: the HCES only collects information on expendidure on landline phone in the last 365 days
*</_landphone_>

*<_cellphone_>
*<_cellphone_note_> Ownership of a cell phone (household) *</_cellphone_note_>
/*<_cellphone_note_> 1 "Yes" 0 "No" *</_cellphone_note_>*/
*<_cellphone_note_> cellphone brought in from raw data *</_cellphone_note_>
gen   	cellphone = .
replace cellphone = 0		if  b4pt34334!=1
replace cellphone = 1		if  b4pt34334==1
*</_cellphone_>

*<_computer_>
*<_computer_note_> Ownership of a computer *</_computer_note_>
/*<_computer_note_> 1 "Yes" 0 "No" *</_computer_note_>*/
*<_computer_note_> computer brought in from raw data *</_computer_note_>
gen	    computer = .
replace computer = 0			if  b4pt34333!=1
replace computer = 1			if  b4pt34333==1
*</_computer_>

*<_etablet_>
*<_etablet_note_> Ownership of a electronic tablet *</_etablet_note_>
/*<_etablet_note_> 1 "Yes" 0 "No" *</_etablet_note_>*/
*<_etablet_note_> etablet brought in from raw data *</_etablet_note_>
gen   etablet = .
notes etablet: the HCES only collects information on expendidure for the purchase of PC/laptop/tablet in the last 365 days
*</_etablet_>

*<_internet_>
*<_internet_note_>  Ownership of a internet *</_internet_note_>
/*<_internet_note_> 1 "Subscribed in the house" 2 "Accessible outside the house" 3 "Either" 4 "No internet" *</_internet_note_>*/
*<_internet_note_> internet brought in from raw data *</_internet_note_>
gen 	internet = .
replace internet = 1			if  b4pt24211==1
replace internet = 4			if  b4pt24211==2
notes   internet: 1 = household has internet facility, 4 = household does not have internet facility
*</_internet_>

*<_radio_>
*<_radio_note_> Ownership of a radio *</_radio_note_>
/*<_radio_note_> 1 "Yes" 0 "No" *</_radio_note_>*/
*<_radio_note_> radio brought in from raw data *</_radio_note_>
gen     radio = .
replace radio = 0			if  b4pt34332!=1
replace radio = 1			if  b4pt34332==1
*</_radio_>

*<_tv_>
*<_tv_note_> Ownership of a tv *</_tv_note_>
/*<_tv_note_> 1 "Yes" 0 "No" *</_tv_note_>*/
*<_tv_note_> tv brought in from raw data *</_tv_note_>
gen     tv = .
replace tv = 0				if  b4pt34331!=1
replace tv = 1 				if  b4pt34331==1
*</_tv_>

*<_tv_cable_>
*<_tv_cable_note_> Ownership of a cable tv *</_tv_cable_note_>
/*<_tv_cable_note_> 1 "Yes" 0 "No" *</_tv_cable_note_>*/
*<_tv_cable_note_> tv_cable brought in from raw data *</_tv_cable_note_>
gen     tv_cable = .
replace tv_cable = 0			if  b4pt3434==1 | b4pt34331!=1
replace tv_cable = 1			if  b4pt3434==2 | b4pt3434==3
*</_tv_cable_>

*<_video_>
*<_video_note_> Ownership of a video *</_video_note_>
/*<_video_note_> 1 "Yes" 0 "No" *</_video_note_>*/
*<_video_note_> video brought in from raw data *</_video_note_>
gen   video = .
notes video: the HCES only collects information on expendidure for the purchase of goods for recreation (including VCR/VCD/DVD in the last 365 days
*</_video_>

*<_fridge_>
*<_fridge_note_> Ownership of a refrigerator *</_fridge_note_>
/*<_fridge_note_> 1 "Yes" 0 "No" *</_fridge_note_>*/
*<_fridge_note_> fridge brought in from raw data *</_fridge_note_>
gen     fridge = .
replace fridge = 0 			if  b4pt343310!=1
replace fridge = 1			if  b4pt343310==1
*</_fridge_>

*<_sewmach_>
*<_sewmach_note_> Ownership of a sewing machine *</_sewmach_note_>
/*<_sewmach_note_> 1 "Yes" 0 "No" *</_sewmach_note_>*/
*<_sewmach_note_> sewmach brought in from raw data *</_sewmach_note_>
gen   sewmach = .
notes sewmach: the HCES only collects information on expendidure for the purchase of sewing machines in the last 365 days
*</_sewmach_>

*<_washmach_>
*<_washmach_note_> Ownership of a washing machine *</_washmach_note_>
/*<_washmach_note_> 1 "Yes" 0 "No" *</_washmach_note_>*/
*<_washmach_note_> washmach brought in from raw data *</_washmach_note_>
gen     washmach = .
replace washmach = 0			if  b4pt343311!=1
replace washmach = 1			if  b4pt343311==1
*</_washmach_>

*<_stove_>
*<_stove_note_> Ownership of a stove *</_stove_note_>
/*<_stove_note_> 1 "Yes" 0 "No" *</_stove_note_>*/
*<_stove_note_> stove brought in from raw data *</_stove_note_>
gen   stove = .
notes stove: the HCES only collects information on expendidure for the purchase of stoves in the last 365 days
*</_stove_>

*<_ricecook_>
*<_ricecook_note_> Ownership of a rice cooker *</_ricecook_note_>
/*<_ricecook_note_> 1 "Yes" 0 "No" *</_ricecook_note_>*/
*<_ricecook_note_> ricecook brought in from raw data *</_ricecook_note_>
gen   ricecook = .
notes ricecook: the HCES does not contain the information needed to define this variable
*</_ricecook_>

*<_fan_>
*<_fan_note_> Ownership of an electric fan *</_fan_note_>
/*<_fan_note_> 1 "Yes" 0 "No" *</_fan_note_>*/
*<_fan_note_> fan brought in from raw data *</_fan_note_>
gen   fan = .
notes fan: the HCES only collects information on expendidure for the purchase of electric fans in the last 365 days
*</_fan_>

*<_ac_>
*<_ac_note_> Ownership of a central or wall air conditioner *</_ac_note_>
/*<_ac_note_> 1 "Yes" 0 "No" *</_ac_note_>*/
*<_ac_note_> ac brought in from raw data *</_ac_note_>
gen 	ac = .
replace ac = 0				if  b4pt343312!=1
replace ac = 1				if  b4pt343312==1
*</_ac_>

*<_ewpump_>
*<_ewpump_note_> Ownership of a electric water pump *</_ewpump_note_>
/*<_ewpump_note_> 1 "Yes" 0 "No" *</_ewpump_note_>*/
*<_ewpump_note_> ewpump brought in from raw data *</_ewpump_note_>
gen   ewpump = .
notes ewpump: the HCES does not contain the information needed to define this variable
*</_ewpump_>

*<_car_>
*<_car_note_> Ownership of a car *</_car_>
/*<_car_note_> 1 "Yes" 0 "No" *</_car_note_>*/
*<_car_note_> car brought in from raw data *</_car_note_>
gen   	car = .
replace car = 0				if  b4pt34337!=1
replace car = 1				if  b4pt34337==1
*</_ewpump_>


*<_bcycle_>
*<_bcycle_note_> Ownership of a bicycle *</_bcycle_note_>
/*<_bcycle_note_>  1 "Yes" 0 "No" *</_bcycle_note_>*/
*<_bcycle_note_> bcycle brought in from raw data *</_bcycle_note_>
gen 	bcycle = .
replace bcycle = 0			if  b4pt34335!=1
replace bcycle = 1			if  b4pt34335==1
*</_bcycle_>

*<_mcycle_>
*<_mcycle_note_> Ownership of a motorcycle *</_mcycle_note_>
/*<_mcycle_note_> 1 "Yes" 0 "No" *</_mcycle_note_>*/
*<_mcycle_note_> mcycle brought in from raw data *</_mcycle_note_>
gen 	mcycle = .
replace mcycle = 0 			if  b4pt34336!=1 
replace mcycle = 1			if  b4pt34336==1
*</_mcycle_>


*****************************************************************
*** DISABILITIES VARIABLES 
*****************************************************************

*<_eye_dsablty_>
*<_eye_dsablty_note_> Difficulty seeing *</_eye_dsablty_note_>
/*<_eye_dsablty_note_>  1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all" *</_eye_dsablty_note_>*/
gen   eye_dsablty = .
notes eye_dsablty: the HCES does not contain a module on disabilities
*</_eye_dsablty_>

*<_hear_dsablty_>
*<_hear_dsablty_note_> Difficulty hearing *</_hear_dsablty_note_>
/*<_hear_dsablty_note_>  1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all" *</_hear_dsablty_note_>*/
gen   hear_dsablty = .
notes hear_dsablty: the HCES does not contain a module on disabilities
*</_hear_dsablty_>

*<_walk_dsablty_>
*<_walk_dsablty_note_> Difficulty walking or climbing steps *</_walk_dsablty_note_>
/*<_walk_dsablty_note_>  1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all" *</_walk_dsablty_note_>*/
gen   walk_dsablty = .
notes walk_dsablty: the HCES does not contain a module on disabilities
*</_walk_dsablty_>

*<_conc_dsord_>
*<_conc_dsord_note_> Difficulty remembering or concentrating *</_conc_dsord_note_>
/*<_conc_dsord_note_>  1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all" *</_conc_dsord_note_>*/
gen   conc_dsord = .
notes conc_dsord: the HCES does not contain a module on disabilities
*</_conc_dsord_>

*<_slfcre_dsablty_>
*<_slfcre_dsablty_note_> Difficulty with self-care *</_slfcre_dsablty_note_>
/*<_slfcre_dsablty_note_>  1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all" *</_slfcre_dsablty_note_>*/
gen   slfcre_dsablty = .
notes slfcre_dsablty: the HCES does not contain a module on disabilities
*</_slfcre_dsablty_>

*<_comm_dsablty_>
*<_comm_dsablty_note_> Difficulty communicating *</_comm_dsablty_note_>
/*<_comm_dsablty_note_>  1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all" *</_comm_dsablty_note_>*/
gen   comm_dsablty = .
notes comm_dsablty: the HCES does not contain a module on disabilities
*</_comm_dsablty_>


*****************************************************************
*** WELFARE VARIABLES 
*****************************************************************

*<_welfare_>
*<_welfare_note_>  Welfare aggregate used for estimating international poverty (provided to PovcalNet). *</_welfare_note_>
/*<_welfare_note_> Specifies varname for the welfare aggregate (e.g. per capita consumption) in the data file that is provided to Povcalnet as input into the estimation of international poverty. This variable should be annual and in LCU at current prices. The variables welfare, welfarenom, and welfaredef have to be in the same welfare type (either income, consumption or expenditure) and two of these three welfare aggregates will be the same. *</_welfare_note_>*/
*<_welfare_note_>  *</_welfare_note_>
gen welfare = welfaredef_final*12
*</_welfare_>

*<_welfarenom_>
*<_welfarenom_note_>  Welfare aggregate in nominal terms. *</_welfarenom_note_>
/*<_welfarenom_note_> Specifies varname for the welfare aggregate (e.g. per capita consumption) in the data file in nominal terms. This variable should be annual and in LCU at current prices. The variables welfare, welfarenom, and welfaredef have to be in the same welfare type (either income, consumption or expenditure) and two of thes three welfare aggregates will be the same. *</_welfarenom_note_>*/
*<_welfarenom_note_>  *</_welfarenom_note_>
gen welfarenom = welfarenom_final*12
*</_welfarenom_>

*<_welfaredef_>
*<_welfaredef_note_>  Welfare aggregate spatially deflated. *</_welfaredef_note_>
/*<_welfaredef_note_> Specifies varname for the welfare aggregate (e.g. per capita consumption) in the data file spatially deflated (spatial or within year inflaction adjustment).  This variable should be annual and in LCU at current prices. The variables welfare, welfarenom, and welfaredef have to be in the same welfare type (either income, consumption or expenditure) and two of thes three welfare aggregates will be the same. *</_welfaredef_note_>*/
*<_welfaredef_note_>  *</_welfaredef_note_>
gen welfaredef = welfaredef_final*12
*</_welfaredef_>

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
gen welfareother = .
*</_welfareother_>

*<_welfareothertype_>
*<_welfareothertype_note_>  Type of welfare measure (income, consumption or expenditure) for welfareother. *</_welfareothertype_note_>
/*<_welfareothertype_note_> Specifies the type of welfare measure for the variable welfareother. Accepted values are: INC for income, CONS for consumption, or EXP for expenditure. This variable is only entered if the type of welfare is different from what is provided in welfare, welfarenom, and welfaredef. For example, if consumption is used for welfare, welfarenom and welfaredef but income also exists, it could be included here. Welfaretype is case-sensitive and upper case has to be used. *</_welfareothertype_note_>*/
*<_welfareothertype_note_>  *</_welfareothertype_note_>
gen welfareothertype = ""
*</_welfareothertype_>

*<_quintile_cons_aggregate_>
*<_quintile_cons_aggregate_note_> Quintile of welfarenat *</_quintile_cons_aggregate_note_>
/*<_quintile_cons_aggregate_note_>  *</_quintile_cons_aggregate_note_>*/
*<_quintile_cons_aggregate_note_>  *</_quintile_cons_aggregate_note_>
_ebin welfare [aw=weight], gen(quintile_cons_aggregate) nq(5) 
*</_quintile_cons_aggregate_>

*<_welfarenat_>
*<_welfarenat_note_>  Welfare aggregate for national poverty. *</_welfarenat_note_>
/*<_welfarenat_note_> Welfare aggregate for national poverty. *</_welfarenat_note_>*/
*<_welfarenat_note_>  1 "Yes" 0 "No" *</_welfarenat_note_>
gen welfarenat = welfare
gen natwelfare = welfarenat 
*</_welfarenat_>

*<_pline_nat_>
*<_pline_nat_note_>  Poverty line (National). *</_pline_nat_note_>
/*<_pline_nat_note_> Poverty line based on the national methodology. *</_pline_nat_note_>*/
*<_pline_nat_note_>  *</_pline_nat_note_>
gen pline_nat = .
gen natpovline_ext = .
gen natpovline_abs = .
gen natweight_p = .
*</_pline_nat_>

* Observations without data on food expenditure
count 		if  fdq==. & relationharm==1 							// 321
gen aux = 1 	if  fdq==. & relationharm==1
bysort hhid: egen fdq_miss_head = total(aux)
drop aux

* Random selection criteria for the member to replace the head
set seed 12345
sort hhid pid
gen random = uniform() 	if  !inlist(relationharm,1,2) & fdq==1
bysort hhid (random): gen byte select = _n==1 	if random!=.

* New FDQ // Should be 321 cases in each replace
destring fdq, replace
clonevar fdq_new = fdq
	
replace fdq_new = 1 		if  fdq_new==. & relationharm==1 			// 321
replace fdq_new = . 		if  fdq_miss_head==1 & select==1 			// 301
	
* Note: In 20 households the only possible other member is the partner, then the partner will be excluded only for those 20 households
bysort hhid: egen n_fdq_or = count(fdq)
bysort hhid: egen n_fdq_new = count(fdq_new)
replace fdq_new = . 		if  fdq_miss_head==1 & (n_fdq_new>n_fdq_or) & relationharm==2 	// 20

* Adjust welfare using new FDQ
for any welfare welfaredef welfarenom welfareother hsize: replace X = . if fdq_new==.
drop welfaredef_final welfarenom_base welfaredef_base welfarenom_final


*<_spdef_>
cap drop spdef rdef
gen spdef = welfarenom / welfaredef
*<_spdef_>

*<_rdef_>
preserve
	collapse rdef=spdef [aw=weight], by(subnatid1 urban)
	tempfile rdef
	save `rdef'
restore

merge m:1 subnatid1 urban using `rdef', nogen
*<_rdef_>

/*
preserve
use "${rootdatalib}\\Final_CPI_PPP_to_be_used.dta", clear
keep if code=="IND"
tempfile CPIs
gen 	urban = 0	if  datalevel==0
replace urban = 1	if  datalevel==1
save `CPIs'
restore

merge m:1 code year urban using `CPIs'
drop if _merge==2
gen wgt = weight
replace cpi2021 = 1.1019059
replace icp2021 = 19.46895

gen pline_int_300 = 3.00*cpi2021*icp2021*365/12
gen 	poor_int_300 = welfare<pline_int_300
replace poor_int_300 = .				if  welfare==.
sum 	poor_int_300 [aw=wgt] 		if  !mi(poor_int_300)

gen pline_int_420 = 4.20*cpi2021*icp2021*365/12
gen 	poor_int_420 = welfare<pline_int_420 
replace poor_int_420 = .				if  welfare==.
sum 	poor_int_420 [aw=wgt] 		if  !mi(poor_int_420)

gen pline_int_830 = 8.30*cpi2021*icp2021*365/12
gen 	poor_int_830 = welfare<pline_int_830
replace poor_int_830 = .				if  welfare==.
sum 	poor_int_830 [aw=wgt] 		if  !mi(poor_int_830)	
 */
 
*<_welfshprosperity_>
*<_welfshprosperity_note_>  Welfare aggregate for shared prosperity (if different from poverty) *</_welfshprosperity_note_>
/*<_welfshprosperity_note_> specifies varname for the welfare variable used to compute the shared prosperity indicator (e.g. per capita consumption) in the data file. This variable should be annual and in LCU at current prices. This variable is either the same as welfare ( *</_welfshprosperity_note_>*/
*<_welfshprosperity_note_>  *</_welfshprosperity_note_>
gen welfshprosperity = welfare
*</_welfshprosperity_>

gen welfshprtype = "EXP"

cap lab var countrycode "country code"
cap lab var year "4-digit year of survey based on IHSN standards"
cap lab var weight "Household weight"
cap lab var weighttype "Weight type (frequency, probability, analytical, importance)"
cap lab var hhid "Household identifier "
cap lab var pid "Personal identifier "
cap lab var soc "Social group" 
cap lab var typehouse "GMD ownhouse variable" 
cap lab var ownhouse "SARMD ownhouse variable" 
cap lab var age "Age of individual (continuous)" 
cap lab var educat4 "Level of education 4 categories" 
cap lab var educat5 "Level of education 5 categories" 
cap lab var educat7 "Level of education 7 categories" 
cap lab var educy "Years of education" 
cap lab var electricity "Access to electricity"  
cap lab var male "Sex of household member (male=1)" 
cap lab var marital "Marital status" 
cap lab var relationcs "Relationship to head of household country/region specific" 
cap lab var relationharm "Relationship to head of household harmonized across all regions" 
cap lab var subnatid1 "Subnational ID - highest level"
cap lab var subnatid1_prev "Subnational ID of most recent previous survey – highest level"
cap lab var subnatid2 "Subnational ID - second highest level"
cap lab var subnatid2_prev "Subnational ID of most recent previous survey – second highest level"
cap lab var subnatid3 "Subnational ID - third highest level"
cap lab var subnatid3_prev "Subnational ID of most recent previous survey – third highest level"
cap lab var survey "Survey name" 
cap lab var urban "uban/rural" 
cap lab var veralt "Harmonization version" 
cap lab var vermast "Master version" 
cap lab var welfare "Welfare aggregate used for estimating international poverty (provided to PovcalNet)" 
cap lab var welfaredef "Welfare aggregate spatially deflated" 
cap lab var welfarenom "Welfare aggregate in nominal terms" 
cap lab var welfareother "Welfare aggregate if different welfare type is used from welfare, welfarenom, welfaredef" 
cap lab var welfareothertype "Type of welfare measure (income, consumption or expenditure) for welfareother" 
cap lab var welfaretype "Type of welfare measure (income, consumption or expenditure) for welfare, welfarenom, welfaredef" 
cap lab var year "Year" 
cap lab var quintile_cons_aggregate "Quintile of welfarenat"
cap lab var improved_water "Improved source of drinking water-using country-specific definitions" 
cap lab var improved_sanitation "Improved type of sanitation facility-using country-specific definitions" 
cap lab var hsize "Household size"
cap lab var subnatidsurvey "Survey representation for geographical units"
cap lab var gaul_adm1_code "GAUL code for admin1 level"
cap lab var gaul_adm2_code "GAUL code for admin2 level"	
cap lab var strata "Stratum"
cap lab var psu "Primary Sampling Unit"	
cap lab var bcycle "Ownership of a bicycle"
cap lab var car "Ownership of a car"
cap lab var cellphone "Ownership of a cell phone"
cap lab var computer "Ownership of a computer"
cap lab var etablet "Ownership of a electronic tablet"
cap lab var ewpump "Ownership of a electric water pump"
cap lab var fan "Ownership of an electric fan"
cap lab var fridge "Ownership of a refrigerator"
cap lab var cooksource "Main cooking fuel"
cap lab var lightsource "Main source of lighting"
cap lab var heatsource "Main source of heating "
cap lab var imp_san_rec "Improved sanitation facility"
cap lab var imp_wat_rec "Improved water"
cap lab var internet "Access to internet"
cap lab var landphone "Ownership of a land phone"
cap lab var mcycle "Ownership of a motorcycle"
cap lab var piped  "Access to piped water"
cap lab var piped_to_prem "Access to piped water on premises"	
cap lab var radio "Ownership of a radio"
cap lab var roof "Main material used for roof"
cap lab var stove "Ownership of a stove"
cap lab var tv "Ownership of a television"
cap lab var tv_cable "Ownership of a cable television"
cap lab var video "Ownership of a video"
cap lab var w_30m "Household has access to improved water within 30 minutes"
cap lab var w_avail "Improved water is available when needed"
cap lab var wall "Main material used for external walls"
cap lab var washmach "Ownership of a washing machine"	
cap lab var comm_dsablty "Difficulty communicating"
cap lab var conc_dsord "Difficulty remembering or concentrating"
cap lab var eye_dsablty "Difficulty seeing"
cap lab var hear_dsablty "Difficulty hearing"
cap lab var slfcre_dsablty "Difficulty with self-care"
cap lab var walk_dsablty "Difficulty walking or climbing steps"
cap lab var empstat "Employment status, primary job (7-day ref period)"
cap lab var empstat_year "Employment status, primary job (12-mon ref period)"
cap lab var healthins "Health insurance (7-day ref period)"
cap lab var industrycat10 "1 digit industry classification, primary job (7-day ref period)"
cap lab var industrycat10_year "1 digit industry classification, primary job (12-mon ref period)"
cap lab var industrycat4 "4-category industry classification, primary job (7-day ref period)"
cap lab var industrycat4_year "4-category industry classification, primary job (12-mon ref period)"
cap lab var lstatus "Labor status (7-day ref period)"
cap lab var lstatus_year "Labor status (12-mon ref period)"
cap lab var minlaborage "Labor module application age (7-day ref period)"	
cap lab var occup "1 digit occupational classification, primary job (7-day ref period)"
cap lab var occup_year "1 digit occupational classification, primary job (12-mon ref period)"
cap lab var ocusec "Sector of activity, primary job (7-day ref period)"	
cap lab var socialsec "Social security (7-day ref period)"
cap lab var countrycode "country code"
cap lab var survey "Type of survey"
cap lab var floor "Main material used for floor"
cap lab var sewmach "Ownership of a sewing machine"
cap lab var ac "Ownership of a central or wall air conditioner"
cap lab var ricecook "Ownership of a rice cooker"
cap lab var toilet_acc "Access to flushed toilet "

	
* Define value labels
cap lab def urban 0 "Rural" 1 "Urban" , replace
cap lab def typehouse 1 "Ownership/secure rights"  2 "Renting" 3 "Provided for free" 4 "Without permission", replace
cap lab def imp_wat_rec 1 "Yes"  0 "No", replace
cap lab def imp_san_rec 1 "Yes"  0 "No", replace
cap lab def relationharm 1 "Head" 2 "Spouse" 3 "Child" 4 "Parents" 5 "Other relative" 6 "Non-relative", replace
cap lab def piped 1 "Yes"  0 "No", replace
cap lab def ownhouse 1 "Ownership/secure rights"  2 "Renting" 3 "Provided for free" 4 "Without permission", replace
cap lab def marital 1 "Married"  2 "Never married"  3 "Living together" 4 "Divorced/Separated"  5 "Widowed", replace
cap lab def male 1  " Male"  0  "Female", replace
cap lab def electricity 1 "Yes"  0 "No", replace
cap lab def educat7 1 "No education"  2 "Primary incomplete"  3 "Primary complete"  4 "Secondary incomplete"  5 "Secondary complete"  6 "Post secondary but not university"  7 "University", replace
cap lab def educat5 1 "No education"  2 "Primary incomplete"  3 "Primary complete but Secondary incomplete" 4 "Secondary complete"  5 "Tertiary (completed or incomplete)", replace
cap lab def educat4 1 "No education"  2 "Primary (complete or incomplete)"  3 "Secondary (complete or incomplete)" 4 "Tertiary (complete or incomplete)", replace
cap lab def relationcs 1 "Head of the household" 2 "Wife / Husband" 3 "Son / Daughter" 4 "Parents of head of the household/ spouse" 5 "Other Relative" 6 "Domestic Servant/ Driver/ Watcher" 7 "Boarder" 9 "Other"

keep  countrycode code year survey int_year int_month hhid hhid_orig pid pid_orig strata psu weight weight_p veralt vermast age male hsize relationharm marital urban subnatid1 subnatid2 subnatid3 subnatid4 subnatidsurvey gaul_adm1_code gaul_adm2_code subnatid1_prev subnatid2_prev subnatid3_prev subnatid4_prev school educat7 educat5 educat4 imp_wat_rec w_30m w_avail piped piped_to_prem imp_san_rec toilet_acc electricity roof wall floor cooksource heatsource lightsource lstatus lstatus_year minlaborage empstat empstat_year industrycat10 industrycat10_year industrycat4 industrycat4_year occup occup_year ocusec socialsec healthins landphone cellphone computer etablet internet radio tv tv_cable video fridge sewmach washmach stove ricecook fan ac ewpump car bcycle mcycle eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty natwelfare natpovline* natweight_p welfare* weighttype spdef welfs* rdef

order countrycode year survey int_year int_month hhid hhid_orig pid pid_orig strata psu weight weight_p veralt vermast age male hsize relationharm marital urban subnatid1 subnatid2 subnatid3 subnatidsurvey gaul_adm1_code gaul_adm2_code subnatid1_prev subnatid2_prev subnatid3_prev school educat7 educat5 educat4 imp_wat_rec w_30m w_avail piped piped_to_prem imp_san_rec toilet_acc electricity roof wall floor cooksource heatsource lightsource lstatus lstatus_year minlaborage empstat empstat_year industrycat10 industrycat10_year industrycat4 industrycat4_year occup occup_year ocusec socialsec healthins landphone cellphone computer etablet internet radio tv tv_cable video fridge sewmach washmach stove ricecook fan ac ewpump car bcycle mcycle eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty natwelfare natpovline* natweight_p welfare*

*<_Save data file_>
save "$output\\`filename'.dta", replace
*</_Save data file_>

	
	