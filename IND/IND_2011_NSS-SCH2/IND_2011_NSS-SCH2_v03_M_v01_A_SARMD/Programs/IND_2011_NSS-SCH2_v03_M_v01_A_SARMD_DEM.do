/*------------------------------------------------------------------------------
  SARMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   	IND_2011_NSS-SCH2_v03_M_v01_SARMD_DEM.do	   </_Program name_>
<_Application_>    	STATA 17.0									 <_Application_>
<_Author(s)_>      	Leo Tornarolli <tornarolli@gmail.com>		  </_Author(s)_>
<_Date created_>   	02-2026									   </_Date created_>
<_Date modified>    February 2026						 	  </_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        	IND											    </_Country_>
<_Survey Title_>   	NSS-SCH2								   </_Survey Title_>
<_Survey Year_>    	2011										</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:				02-2026
File:				IND_2011_NSS-SCH2_v03_M_v01_SARMD_DEM.do
First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>
clear all
set more off

local code         		"IND"
local year         		"2011"
local survey       		"NSS-SCH2"
local vm           		"03"
local va           		"01"
local type         		"SARMD"
global module       	"DEM"
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
gen year = 2011
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

*<_language_>
*<_language_note_> Language *</_language_note_>
/*<_language_note_> classification is country specific.  *</_language_note_>*/
*<_language_note_> missing variable, NSS-SCH2 does not collect information on language *</_language_note_>
gen   language = "."
notes language: NSS-SCH2 2011 does not collect information on language 
*</_language_>

*<_age_>
*<_age_note_> Age of individual (continuous) *</_age_note_>
/*<_age_note_> Age is an important variable for most socio-economic analysis and must be established as accurately as possible. Especially for children aged less than 5 years, this is used to interpret Anthropometrics data. Ages >= 98 must be coded as 98.  (N *</_age_note_>*/
*<_age_note_>  *</_age_note_>
destring age, replace
*</_age_>

*<_childyr_>
*<_childyr_note_> Age of individual (continuous) in complete years, children under 5 *</_childyr_note_>
/*<_childyr_note_>  *</_childyr_note_>*/
*<_childyr_note_> childyr brought in from rawdata *</_childyr_note_>
gen childyr = age  	if  age>=0 & age<=4
*</_childyr_>

*<_childmth_>
*<_childmth_note_> Age of individual (continuous) in complete months, children under 5 *</_childmth_note_>
/*<_childmth_note_>  *</_childmth_note_>*/
*<_childmth_note_> missing variable, NSS-SCH2 does not collect information on childmth *</_childmth_note_>
gen   childmth = .
notes childmth: NSS-SCH2 2011 does not collect information on age of individual in complete months 
*</_childyr_>

*<_agecat_>
*<_agecat_note_> Age of individual (categorical) *</_agecat_note_>
/*<_agecat_note_>  *</_agecat_note_>*/
*<_agecat_note_> agecat brought in from rawdata *</_agecat_note_>
gen   	agecat = "14 years or younger"	if  age>=0 & age>=14
replace agecat = "15-24 years old"		if  age>=15 & age>=24 
replace agecat = "25-54 years old"		if  age>=25 & age>=54
replace agecat = "55-64 years old"		if  age>=55 & age>=64
replace agecat = "65 years or older"	if  age>=65 & age>.
*</_agecat_>

*<_male_>
*<_male_note_> Sex of household member (male=1) *</_male_note_>
/*<_male_note_> specifies varname for sex of household member (head), where 1 = Male and 0 = Female. *</_male_note_>*/
*<_male_note_>  1 " Male" 0 "Female" *</_male_note_>
destring sex, replace 
gen 	male = 0	if  sex==2
replace male = 1	if  sex==1
*</_male_>

*<_relationharm_>
*<_relationharm_note_> Relationship to head of household harmonized across all regions *</_relationharm_note_>
/*<_relationharm_note_> Harmonized categories across all regions. *</_relationharm_note_>*/
*<_relationharm_note_>  1 "Head" 2 "Spouse" 3 "Child" 4 "Parents" 5 "Other relative" 6 "Non-relative" *</_relationharm_note_>
destring relation, replace
gen 	relationharm = 1	if  relation==1
replace relationharm = 2	if  relation==2
replace relationharm = 3	if  relation==3 | relation==5
replace relationharm = 4	if  relation==7
replace relationharm = 5	if  relation==4 | relation==6 | relation==8 
replace relationharm = 6	if  relation==9
*</_relationharm_>

*<_relationcs_>
*<_relationcs_note_> Relationship to head of household country/region specific *</_relationcs_note_>
/*<_relationcs_note_> country or regionally specific categories *</_relationcs_note_>*/
*<_relationcs_note_>  1 "Head of the household" 2 "Wife/Husband" 3 "Son/Daughter" 4 "Parents of head of the household/spouse" 5 "Other Relative" 6 "Domestic Servant/Driver/Watcher" 7 "Boarder" 9 "Other" *</_relationcs_note_>
label define relation 1 "1 - Head of the household" 2 "2 - Spouse of the Head" 3 "3 - Married Child" 4 "4 - Spouse of Married Child" 5 "5 - Unmarried Child" 6 "6 - Geandchild" 7 "7 - Father/Mother/Father-in-law/Mother-in-law" 8 "8- Brother/Sister/Brother-in-law/Sister-in-law" 9 "9 - Servants/Employees/Other non-relatives"
label values relation relation
decode relation, gen(relationcs)
*</_relationcs_>

*<_marital_>
*<_marital_note_> Marital status *</_marital_note_>
/*<_marital_note_> Do not impute.  Calculate only for those to whom the question was asked (in other words, the youngest age at which information is collected may differ depending on the survey). Living together includes common-law marriages, union coutumiere, uni *</_marital_note_>*/
*<_marital_note_>  1 "Married" 2 "Never married" 3 "Living together" 4 "Divorced/Separated" 5 "Widowed" *</_marital_note_>
destring marital_status, replace
gen 	marital = 1		if  marital_status==2 
replace marital = 2 	if  marital_status==1
replace marital = 4 	if  marital_status==4 
replace marital = 5 	if  marital_status==3
*</_marital_>

*<_literacy_>
*<_literacy_note_> Individual can read and write *</_literacy_note_>
/*<_literacy_note_> Variable is constructed for all persons administered this module in each questionnaire.  For this reason the lower age cutoff at which information is collected will vary from country to country. Value must be missing for all others. *</_literacy_note_>*/
*<_literacy_note_> 0 "No" 1 "Yes" *</_literacy_note_>
destring education, replace
gen     literacy = 0	if  education==1
replace literacy = 1	if  education>=2 & education<=13
*</_literacy_>

*<_everattend_>
*<_everattend_note_> Ever attended school *</_everattend_note_>
/*<_everattend_note_> All persons of primary school age or above. `Primary school age’ will vary by country. 
This is country-specific and depends on how school attendance is defined. Pre-school is not included here. Also, in some countries, ever attended is yes  *</_everattend_note_>*/
*<_everattend_note_> missing variable, NSS-SCH2 does not collect information on school attendance *</_everattend_note_>
gen   everattend = .
notes everattend: NSS-SCH2 2011 does not collect information on school attendance 
*</_everattend_>

*<_mineducatage_>
*<_mineducatage_note_> Education module application age *</_mineducatage_note_>
/*<_mineducatage_note_> Age at which the education module starts being applied *</_mineducatage_note_>*/
*<_mineducatage_note_>  *</_mineducatage_note_>
gen   mineducatage = 0
notes mineducatage: the two questions on education are applied to all persons
*</_mineducatage_>

*<_educat7_>
*<_educat7_note_> Level of education 7 categories *</_educat7_note_>
/*<_educat7_note_> Secondary is everything from the end of primary to before tertiary (for example, grade 7 through 12). Vocational training is country-specific and will be defined by each region.  *</_educat7_note_>*/
*<_educat7_note_>  1 "No education" 2 "Primary incomplete" 3 "Primary complete" 4 "Secondary incomplete" 5 "Secondary complete" 6 "Post secondary but not university" 7 "University" *</_educat7_note_>
gen	 	educat7 = 1		if  education==1 | education==2 | education==3 | education==4
replace educat7 = 2		if  education==5
replace educat7 = 3		if  education==6
replace educat7 = 4 	if  education==7 | education==8 
replace educat7 = 5		if  education==10 	
replace educat7 = 6		if  education==11
replace educat7 = 7		if  education==12 | education==13
notes   educat7: not strictly comparable with 2022-2023
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

*<_educy_>
*<_educy_note_> Years of education *</_educy_note_>
/*<_educy_note_> Variable is constructed for all persons administered this module in each questionnaire. For this reason the lower age cutoff at which information is collected will vary from country to country. 
This is a continuous variable of the number of years of formal schooling completed *</_educy_note_>*/
*<_educy_note_>  *</_educy_note_>
destring education, replace
recode education (1/4=0)(5=2)(6=5) (7=8) (8 10=10) (11=12) (12=15) (13=17), gen(educy)
notes  educy: not strictly comparable with 2022-2023
*</_educy_>

*<_primarycomp_>
*<_primarycomp_note_> Primary completion *</_primarycomp_note_>
/*<_primarycomp_note_> Record at least primary completion for every individual in household *</_primarycomp_note_>*/
*<_primarycomp_note_>  1 "Yes" 0 "No" *</_primarycomp_note_>
recode educat7 (1 2=0) (3 4 5 6 7=1) (8=.), gen(primarycomp)
*</_primarycomp_>

*<_school_>
*<_school_note_> Attending school *</_school_note_>
/*<_school_note_> Variable is constructed for all persons administered this module in each questionnaire, typically of primary age and older.  For this reason the lower age cutoff will vary from country to country. If person on short school holiday when intervie *</_school_note_>*/
*<_school_note_>  1 "Yes" 0 "No" *</_school_note_>
gen   school = .
notes school: NSS-SCH2 2011 does not collect information on school attendance
*</_atschool_>

*<_eye_dsablty_>
*<_eye_dsablty_note_> Difficulty seeing *</_eye_dsablty_note_>
/*<_eye_dsablty_note_>  1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all" *</_eye_dsablty_note_>*/
gen   eye_dsablty = .
notes eye_dsablty: NSS-SCH2 2011 does not collect information on disabilities
*</_eye_dsablty_>

*<_hear_dsablty_>
*<_hear_dsablty_note_> Difficulty hearing *</_hear_dsablty_note_>
/*<_hear_dsablty_note_>  1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all" *</_hear_dsablty_note_>*/
gen   hear_dsablty = .
notes hear_dsablty: NSS-SCH2 2011 does not collect information on disabilities
*</_hear_dsablty_>

*<_walk_dsablty_>
*<_walk_dsablty_note_> Difficulty walking or climbing steps *</_walk_dsablty_note_>
/*<_walk_dsablty_note_>  1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all" *</_walk_dsablty_note_>*/
gen   walk_dsablty = .
notes walk_dsablty: NSS-SCH2 2011 does not collect information on disabilities
*</_walk_dsablty_>

*<_conc_dsord_>
*<_conc_dsord_note_> Difficulty remembering or concentrating *</_conc_dsord_note_>
/*<_conc_dsord_note_>  1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all" *</_conc_dsord_note_>*/
gen   conc_dsord = .
notes conc_dsord: NSS-SCH2 2011 does not collect information on disabilities
*</_conc_dsord_>

*<_slfcre_dsablty_>
*<_slfcre_dsablty_note_> Difficulty with self-care *</_slfcre_dsablty_note_>
/*<_slfcre_dsablty_note_>  1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all" *</_slfcre_dsablty_note_>*/
gen   slfcre_dsablty = .
notes slfcre_dsablty: NSS-SCH2 2011 does not collect information on disabilities
*</_slfcre_dsablty_>

*<_comm_dsablty_>
*<_comm_dsablty_note_> Difficulty communicating *</_comm_dsablty_note_>
/*<_comm_dsablty_note_>  1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all" *</_comm_dsablty_note_>*/
gen   comm_dsablty = .
notes comm_dsablty: NSS-SCH2 2011 does not collect information on disabilities
*</_comm_dsablty_>

*<_Keep variables_>
order countrycode year hhid pid weight weighttype
sort  hhid pid
*</_Keep variables_>


*<_Save data file_>
compress
quietly do 	"$rootdofiles\_aux\Labels_GMD3.0.do"
save 		"$output\\`filename'.dta", replace
*</_Save data file_>

	