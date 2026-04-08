/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                                   SOUTH ASIA MICRO DATABASE                                      **
**                                                                                                  **
** COUNTRY			Afghanistan
** COUNTRY ISO CODE	AFG
** YEAR				2016-2017
** SURVEY NAME		Afghanistan Living Condition Survey 
** SURVEY AGENCY	Central Statistics Organization
** RESPONSIBLE		Francisco Javier Parada Gomez Urquiza
** MODIFIED			Adriana Castillo Castillo 
**                                                                                                  **
******************************************************************************************************
*****************************************************************************************************/

/*****************************************************************************************************
*                                                                                                    *
                                   INITIAL COMMANDS
*                                                                                                    *
*****************************************************************************************************/

*<_Program setup_>
** INITIAL COMMANDS
	cap log close 
	clear
	set more off
	set mem 800m


** DIRECTORY
	*local input "${rootdatalib}\AFG\AFG_2016_LCS\AFG_2016_LCS_v01_M"
	*local output "${rootdatalib}\AFG\AFG_2016_LCS\AFG_2016_LCS_v01_M_v01_A_SARMD"
	glo pricedata "${rootdatalib}\CPI\cpi_ppp_sarmd_weighted"
	glo fixlabels "${rootdatalib}\APPS\DATA CHECK\Label fixing"
	*local temppov "${rootdatalib}\AFG\AFG_2019_LCS\AFG_2019_LCS_v01_M\Data\NoUSEDStata\temp_pov_2016_2019_consolidated"

** LOG FILE
local cpiver       "10"
local code         "AFG"
local year         "2016"
local survey       "LCS"
local vm           "01"
local va           "03"
local type         "SARMD"
local yearfolder   "`code'_`year'_`survey'"
local harmfolder    "`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'"
local filename      "`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'_IND"
	glo output "${rootdatalib}\\`code'\\`yearfolder'\\`harmfolder'\Data\Harmonized"
*</_Program setup_>

* global path on Joe's computer
if ("`c(username)'"=="sunquat") {
	glo basepath "/Users/`c(username)'/Projects/WORLD BANK/2023 SAR QCHECK/SARDATABANK/WORKINGDATA/`code'/`yearfolder'"
	glo input "${basepath}/`yearfolder'_v`vm'_M"
	glo output "${basepath}/`yearfolder'_v`vm'_M_v`va'_A_SARMD/Data/Harmonized"
	
	* load and merge relevant data (note: removed roster_male.dta and clusters.dta as it was not used in the updated WB computer code)
	cd "${input}/Data/Stata"
	* input data
	use "`code'_`year'_`survey'_M", clear
	* general data
	merge m:1 hh_id using "h_22_23", nogen assert(match)
}
* global paths on WB computer
else {
	*<_Folder creation_>
	cap mkdir "${rootdatalib}"
	cap mkdir "${rootdatalib}\\`code'"
	cap mkdir "${rootdatalib}\\`code'\\`yearfolder'"
	cap mkdir "${rootdatalib}\\`code'\\`yearfolder'\\`gmdfolder'"
	cap mkdir "${rootdatalib}\\`code'\\`yearfolder'\\`gmdfolder'\Data"
	cap mkdir "${rootdatalib}\\`code'\\`yearfolder'\\`gmdfolder'\Data\Harmonized"
	*</_Folder creation_>
	
		log using "${rootdatalib}\\`code'\\`code'_`year'_`survey'\\`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD\Doc\Technical\\`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD.log", replace 
		
	/*------------------------------------------------------------------------------*
	/*------------------------------------------------------------------------------*
	1. INPUT DATA 
	*------------------------------------------------------------------------------*/
	*------------------------------------------------------------------------------*/
	* input data
	use "${rootdatalib}\\`code'\\`code'_`year'_`survey'\\`code'_`year'_`survey'_v`vm'_M\Data\Stata\\`code'_`year'_`survey'_M.dta", clear
	tempfile individual_level_data
	save `individual_level_data'
	* general data
	datalibweb, country(`code') year(`year') type(SARRAW) surveyid(`code'_`year'_`survey'_v`vm'_M) filename(h_22_23.dta)
	* merge with input data
	merge 1:m hh_id using `individual_level_data', nogen assert(match)
}

/*****************************************************************************************************
*                                                                                                    *
                                   * STANDARD SURVEY MODULE
*                                                                                                    *
*****************************************************************************************************/
	
	
** COUNTRY
*<_code_>
	gen str4 code="`code'"
	label var code "Country code"
*</_code_>


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


** HOUSEHOLD IDENTIFICATION NUMBER
*<_idh_>
	clonevar idh=hh_id
	label var idh "Household id"
	clonevar idh_org=hh_id
*</_idh_>


** INDIVIDUAL IDENTIFICATION NUMBER
*<_idp_>
	clonevar idp=ind_id
	label var idp "Individual id"
	clonevar idp_org=ind_id
*</_idp_>


** HOUSEHOLD WEIGHTS
*<_wgt_>
	clonevar wgt=hh_weight
	label var wgt "Household sampling weight"
*</_wgt_>


**POPULATION WEIGHT
*<_pop_wgt_>
	clonevar pop_wgt=ind_weight
	la var pop_wgt "Population weight"
*</_pop_wgt_>


*<_weighttype_>
*<_weighttype_note_> Weight type (frequency, probability, analytical, importance) *</_weighttype_note_>
*<_weighttype_note_> weighttype brought in from rawdata *</_weighttype_note_>
g weighttype = "PW"
*</_weighttype_>

** STRATA
*<_strata_>
	gen strata= q_1_1
	label var strata "Strata"
*</_strata_>


** PSU
*<_psu_>
	gen psu= q_1_4
	label var psu "Primary sampling units"
*</_psu_>


** INTERVIEW YEAR
*<_int_year_>
	gen int_year=2016
	label var int_year "Year of the interview"
*</_int_year_>


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
                                   HOUSEHOLD CHARACTERISTICS MODULE
*                                                                                                    *
*****************************************************************************************************/

** LOCATION (URBAN/RURAL)
*<_urban_>
	clonevar urban=q_1_5
	recode urban (1=1)(2 3 =0)
	label var urban "Urban/Rural"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban
	notes urban: "AFG 2013" Kuchi replaced as rural
*</_urban_>


*<_subnatid2_>
	rename q_1_2 subnatid2
*<_subnatid2_>


**REGIONAL AREAS
** REGIONAL AREA 1 DIGIT ADMN LEVEL
*<_subnatid1_>

	recode  q_1_1a (6=10)	(7=12)	(8=33)	(9=16)	(10=32)	(11=6)	(12=7)	(13=8)	(14=9)	(15=11)	(16=13)	(17=14)	(18=15)	(19=17)	(20=18)	(21=19)	(22=21)	(23=31)	(24=34)	(25=30)	(26=29)	(27=28)	(28=20)	(29=22)	(30=27)	(31=23)	(32=24)	(33=25)	(34=26), gen(subnatid1)
	la de lblsubnatid1 1 "Kabul" 2 "Kapisa" 3 "Parwan" 4 "Wardak" 5 "Logar" 6 "Ghazni" 7 "Paktika" 8 "Paktya" 9 "Khost" 10 "Nangarhar" 11 "Kunarha" 12 "Laghman" 13 "Nuristan" 14 "Badakhshan" 15 "Takhar" 16 "Baghlan" 17 "Kunduz" 18 "Samangan" 19 "Balkh" 20 "Jawzjan" 21 "Sar-I-Poul" 22 "Faryab" 23 "Badghis" 24 "Hirat" 25 "Farah" 26 "Nimroz" 27 "Helmand" 28 "Kandahar" 29 "Zabul" 30 "Uruzgan" 31 "Ghor" 32 "Bamyan" 33 "Panjsher" 34 "Daikindi"
	label var subnatid1 "Region at 1 digit (ADMN1)"
	label values subnatid1 lblsubnatid1
		numlabel lblsubnatid1, add mask("# - ")
		decode subnatid1, gen(subnatid1_temp)
		drop subnatid1
		rename subnatid1_temp subnatid1
*</_subnatid1_>


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




** MACRO REGIONAL AREA
*<_subnatid0_>
	gen subnatid0=""
	label var subnatid0 "Macro regional areas"
	replace subnatid0="Central" if subnatid1=="1 - Kabul"
	replace subnatid0="Central" if subnatid1=="2 - Kapisa"
	replace subnatid0="Central" if subnatid1=="5 - Logar"
	replace subnatid0="Central" if subnatid1=="8 - Panjshir"
	replace subnatid0="Central" if subnatid1=="3 - Parwan"
	replace subnatid0="Central" if subnatid1=="4 - Wardak"
	replace subnatid0="South" if subnatid1=="11 - Ghazni"
	replace subnatid0="South" if subnatid1=="14 - Khost"
	replace subnatid0="South" if subnatid1=="12 - Paktika"
	replace subnatid0="South" if subnatid1=="13 - Paktya"
	replace subnatid0="East" if subnatid1=="15 - Kunar"
	replace subnatid0="East" if subnatid1=="7 - Laghman"
	replace subnatid0="East" if subnatid1=="6 - Nangarhar"
	replace subnatid0="East" if subnatid1=="16 - Nuristan"
	replace subnatid0="Northeast" if subnatid1=="17 - Badakhshan"
	replace subnatid0="Northeast" if subnatid1=="9 - Baghlan"
	replace subnatid0="Northeast" if subnatid1=="19 - Kunduz"
	replace subnatid0="Northeast" if subnatid1=="18 - Takhar"
	replace subnatid0="North" if subnatid1=="21 - Balkh"
	replace subnatid0="North" if subnatid1=="29 - Faryab"
	replace subnatid0="North" if subnatid1=="28 - Jawzjan"
	replace subnatid0="North" if subnatid1=="20 - Samangan"
	replace subnatid0="North" if subnatid1=="22 - Sari Pul"
	replace subnatid0="West" if subnatid1=="31 - Badghis"
	replace subnatid0="West" if subnatid1=="33 - Farah"
	replace subnatid0="West" if subnatid1=="32 - Herat"
	replace subnatid0="Southwest" if subnatid1=="30 - Hilmand"
	replace subnatid0="Southwest" if subnatid1=="27 - Kandahar"
	replace subnatid0="Southwest" if subnatid1=="34 - Nimroz"
	replace subnatid0="Southwest" if subnatid1=="25 - Uruzgan"
	replace subnatid0="Southwest" if subnatid1=="26 - Zabul"
	replace subnatid0="West Central" if subnatid1=="10 - Bamyan"
	replace subnatid0="West Central" if subnatid1=="24 - Daykundi"
	replace subnatid0="West Central" if subnatid1=="23 - Ghor"
*</_subnatid0_>

gen subnatid3=""

gen subnatid4=""

decode q_1_1a, gen(subnatid1_sar)
gen subnatid2_sar = ""
gen subnatid3_sar = ""
gen subnatid4_sar = ""


/*****************************************************************************************************
*                                                                                                    *
                                   DEMOGRAPHIC MODULE
*                                                                                                    *
*****************************************************************************************************/

** HOUSEHOLD SIZE
*<_hsize_>
	gen z=1 
	*replace z=0 if  q_3_3==11
	bys hh_id: egen hsize=sum(z) 
	label var hsize "Household size"
	note hsize: "AFG 2013" variable takes all categories since there is no way to identify paying boarders and domestic servants
*</_hsize_>


** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
*<_relationharm_>
	gen byte relationharm=q_3_3
	recode relationharm (6=4) (4 5 7 8 9 10=5) (11=6)
	label var relationharm "Relationship to the head of household"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Non-relatives"
	label values relationharm  lblrelationharm
*</_relationharm_>


** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
*<_relationcs_>
	gen byte relationcs=q_3_3
	la var relationcs "Relationship to the head of household country/region specific"
	la define lblrelationcs 1 "Household head" 2 "Wife or husband" 3 "Son or daugher" 4 "Son/daughter-in-law" 5 "Grandchild" 6 "Father or mother" 7 "Nephew or niece" 8 "Brother or sister" 9 "Brother/sister-in-law" 10 "Other relative" 11 "Unrelated member"
	label values relationcs lblrelationcs
*</_relationcs_>


** GENDER
*<_male_>
	gen byte male= q_3_5
	recode male (2=0)
	label var male "Sex of household member"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale
*</_male_>


** AGE
*<_age_>
	gen byte age= q_3_4
	replace age=98 if age>=98 & age!=.
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
	gen byte marital=  q_3_6
	recode marital (4 5=2) (3=4) (2= 5) 
	label var marital "Marital status"
	la de lblmarital 1 "Married" 2 "Never Married" 3 "Living Together" 4 "Divorced/separated" 5 "Widowed"
	label values marital lblmarital
*</_marital_>


/*****************************************************************************************************
*                                                                                                    *
                                   DISABILITY MODULE
*                                                                                                    *
*****************************************************************************************************/

label define eye_disability_label 1 "No – no difficulty"  2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all"
label define hear_disability_label 1 "No – no difficulty"  2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all"
label define walk_disability_label 1 "No – no difficulty"  2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all"
label define conc_disability_label 1 "No – no difficulty"  2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all"
label define slfcre_disability_label 1 "No – no difficulty"  2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all"
label define comm_disability_label 1 "No – no difficulty"  2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all"

** 1. Do you have difficulty seeing, even if wearing glasses?	
	gen eye_dsablty = q_24_2
	label values eye_dsablty eye_disability_label
	label var eye_dsablty "eye_dsablty is a numerical variable that indicates whether an individual has any difficulty in seeing, even when wearing glasses."

** 2. Do you have difficulty hearing, even if using a hearing aid?	
	gen hear_dsablty = q_24_4
	label values hear_dsablty hear_disability_label
	label var hear_dsablty "hear_dsablty is a numerical variable that indicates whether an individual has any difficulty in hearing even when using a hearing aid."

** 3. Do you have difficulty walking or climbing steps?	
	gen walk_dsablty = q_24_6
	label values walk_dsablty walk_disability_label
	label var walk_dsablty "walk_dsablty is a numerical variable that indicates whether an individual has any difficulty in walking or climbing steps."

** 4. Do you have difficulty remembering or concentrating?	
	gen conc_dsord = q_24_10
	label values conc_dsord conc_disability_label
	label var conc_dsord "conc_dsord is a numerical variable that indicates whether an individual has any difficulty concentrating or remembering."

** 5. Do you have difficulty (with self-care such as) washing all over or dressing?	
	gen slfcre_dsablty = q_24_8 
	label values slfcre_dsablty slfcre_disability_label
	label var slfcre_dsablty "slfcre_dsablty is a numerical variable that indicates whether an individual has any difficulty with self-care such as washing all over or dressing."

** 6. Using your usual (customary) language, do you have difficulty communicating, for example understanding or being understood?
	gen comm_dsablty = q_24_12
	label values comm_dsablty comm_disability_label
	label var comm_dsablty "comm_dsablty is a numerical variable that indicates whether an individual has any difficulty communicating or understanding usual (customary) language."

replace eye_dsablty=. if eye_dsablty != 1 & eye_dsablty != 2 & eye_dsablty != 3 & eye_dsablty != 4
replace hear_dsablty=. if hear_dsablty != 1 & hear_dsablty != 2 & hear_dsablty != 3 & hear_dsablty != 4
replace walk_dsablty=. if walk_dsablty != 1 & walk_dsablty != 2 & walk_dsablty != 3 & walk_dsablty != 4
replace conc_dsord=. if conc_dsord != 1 & conc_dsord != 2 & conc_dsord != 3 & conc_dsord != 4
replace slfcre_dsablty=. if slfcre_dsablty != 1 & slfcre_dsablty != 2 & slfcre_dsablty != 3 & slfcre_dsablty != 4
replace comm_dsablty=. if comm_dsablty != 1 & comm_dsablty != 2 & comm_dsablty != 3 & comm_dsablty != 4

/*****************************************************************************************************
*                                                                                                    *
                                   EDUCATION MODULE
*                                                                                                    *
*****************************************************************************************************/

** EDUCATION MODULE AGE
*<_ed_mod_age_>
	gen byte ed_mod_age=6
	label var ed_mod_age "Education module application age"
*</_ed_mod_age_>


** CURRENTLY AT SCHOOL
*<_atschool_>
	gen byte atschool= q11_9
	recode atschool (2=0)
	replace atschool=0 if q11_5==2
	replace atschool = . if age < 6
	replace atschool = . if age > 24
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool
	notes atschool: "AFG 2013" question related to attendance to school was used
	notes atschool: "AFG 2013" the upper range of age for attendace was set in the questionnaire
*</_atschool_>


** CAN READ AND WRITE
*<_literacy_>
	gen byte literacy= q11_2
	recode literacy (2=0)
	replace literacy = 1 if (q11_7==1 & inrange(q11_8,1,19)) | inrange(q11_7,2,6)	//completed any school
	replace literacy=.f if age<6
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
*</_literacy_>


** YEARS OF EDUCATION COMPLETED
*<_educy_>
	gen  educy = q11_8
	label var educy "Years of education"
*</_educy_>

** EDUCATION LEVEL 7 CATEGORIES
*<_educat7_>
	gen educat7=.
	replace educat7=1 if q11_5!=1
	replace educat7=2 if q11_7==1 & q11_8<6
	replace educat7=3 if q11_7==1 & q11_8==6
	replace educat7=4 if q11_7==2 
	replace educat7=4 if q11_7==3 & q11_8<12
	replace educat7=5 if q11_7==3 & q11_8==12
	replace educat7=6 if q11_7==4 
	replace educat7=7 if q11_7==5 | q11_7==6
	replace educat7=.z if q11_7==7
	la var educat7 "Level of education 7 categories"
	label define lbleducat7 1 "No education" 2 "Primary incomplete" 3 "Primary complete" ///
	4 "Secondary incomplete" 5 "Secondary complete" 6 "Higher than secondary but not university" /// 
	7 "University incomplete or complete" 8 "Other" 9 "Not classified"
	label values educat7 lbleducat7
	notes educat7: `code' `year' q11_7 q215e "level completed" = 7 "Islamic school" not categorized, given special missing value (.z). 
*</_educat7_>


** EDUCATION LEVEL 5 CATEGORIES
*<_educat5_>
	recode educat7 (9 1=1) (2=2) (3 4=3) (5=4) (6 7=5), gen(educat5)
	label define lbleducat5 1 "No education" 2 "Primary incomplete" ///
	3 "Primary complete but secondary incomplete" 4 "Secondary complete" ///
	5 "Some tertiary/post-secondary"
	label values educat5 lbleducat5
*</_educat5_>

	la var educat5 "Level of education 5 categories"


** EDUCATION LEVEL 4 CATEGORIES
*<_educat4_>
	recode educat7 (9 1=1) (2 3=2) (4 5=3) (6 7=4), gen(educat4)
	label var educat4 "Level of education 4 categories"
	label define lbleducat4 1 "No education" 2 "Primary (complete or incomplete)" ///
	3 "Secondary (complete or incomplete)" 4 "Tertiary (complete or incomplete)"
	label values educat4 lbleducat4
*</_educat4_>

*/
** EVER ATTENDED SCHOOL
*<_everattend_>
	gen byte everattend= q11_5
	replace everattend = 1 if atschool==1
	recode everattend (2=0)
	replace everattend = . if age < 6
	label var everattend "Ever attended school"
	la de lbleverattend 0 "No" 1 "Yes"
	label values everattend lbleverattend
*</_everattend_>

foreach var in atschool literacy educy everattend educat4 educat5 educat7 {
replace `var'=.f if age<ed_mod_age
}


/*****************************************************************************************************
*                                                                                                    *
                                   UTILITIES MODULE
*                                                                                                    *
*****************************************************************************************************/


** ORIGINAL WATER CATEGORIES
*<_water_orig_>
	clonevar water_orig=q_4_21
	la var water_orig "Source of Drinking Water-Original from raw file"
*</_water_orig_>


** SAR IMPROVED SOURCE OF DRINKING WATER
*<_improved_water_>
	g improved_water = (inlist(q_4_21,1,2,3,4,5,7,10)) if inrange(q_4_21,1,11)
	la def lblimproved_water 1 "Improved" 0 "Unimproved"
	la val improved_water lblimproved_water
	la var improved_water "Improved access to drinking water"
*</_improved_water_>

clonevar sar_improved_water=improved_water

*ORIGINAL TOILET CATEGORIES
*<_toilet_orig_>
	clonevar sanitation_orig=q_4_19
	la var sanitation_orig "Access to sanitation facility-Original from raw file"
*</_toilet_orig_>

clonevar toilet_orig= sanitation_orig 

**INTERNATIONAL SANITATION COMPARISON (Joint Monitoring Program)
*<_toilet_jmp_>
recode q_4_19 (1=7) (2=8) (3=6) (4=1) (5=2) (6=3) (7=4) (8/9=9) (10=12) (11=13) (*=.), g(toilet_jmp)

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

** SAR IMPROVED SANITATION 
*<_improved_sanitation_>
	gen improved_sanitation=.
	replace improved_sanitation=1 if inlist(sanitation_orig,1,3,4,5,6,8,9)
	replace improved_sanitation=0 if inlist(sanitation_orig,2,7,10,11)
	la def lblimproved_sanitation 1 "Improved" 0 "Unimproved"
	la val improved_sanitation lblimproved_sanitation
	la var improved_sanitation "Improved type of sanitation facility-using country-specific definitions"
	replace improved_sanitation=0 if q_4_20==1
	notes improved_sanitation: `code' `year' imp_san_rec is classified as unimproved if the facility is shared.
*</_improved_sanitation_>
  
clonevar sar_improved_toilet=improved_sanitation

gen sewage_toilet=.
replace sewage_toilet=1 if  toilet_orig==4
replace sewage_toilet=0 if  toilet_orig!=4 & toilet_orig!=.
 
*</_electricity_>;
*electricity any source
egen electricity_all=rmin(q_4_14_a q_4_14_b q_4_14_c q_4_14_d q_4_14_e q_4_14_f q_4_14_g q_4_14_h)
recode electricity_all (2=0)
* electrecity public connection
egen electricity=rmin(q_4_14_a q_4_14_b q_4_14_e q_4_14_f)
recode electricity (2=0)
replace electricity=0 if mi(electricity) & !mi(electricity_all)
note electricity: electricity from public source electric grid or government generator
*</_electricity_>;

*<_electricity_other_>
*electricity by source
recode q_4_14_a (2=0), gen(elect_grid)
recode q_4_14_b (2=0), gen(elect_govgen)
egen elect_engine=rmin(q_4_14_c q_4_14_e)
recode elect_engine (2=0)
egen elect_hidro=rmin(q_4_14_d q_4_14_f)
recode elect_hidro (2=0)
recode q_4_14_g (2=0), gen(elect_solar)
recode q_4_14_h (2=0), gen(elect_wind) 
*</_electricity_other>



*</_cow_>
g cow = (q_5_2_a>0) if ~missing(q_5_2_a)
*</_cow_>

*</_lb_mod_age_>
g lb_mod_age = 14
*</_lb_mod_age_>

*</_water_jmp_>
recode q_4_21 (1=1) (2=2) (3=3) (4=4) (5=7) (6=8) (7=5) (8=6) (9=12) (10=10) (11=14) (*=.), g(water_jmp)
*</_water_jmp_>

gen shared_toilet=.
replace shared_toilet=1 if q_4_20==1
replace shared_toilet=0 if q_4_20==2



/*****************************************************************************************************
*                                                                                                    *
                                            ASSETS 
*     numlabel , add                                                                                               *
*****************************************************************************************************/
numlabel , add  
** LANDPHONE
*<_landphone_>
 
	gen byte landphone=.
	note landphone: AFG_2016-LCS does not have any relevant questions or variables. Question 9.15 is about expenditure, but that is not sufficient as some may have a landphone for free.
	label var landphone "Ownership of a land phone"
	la de lbllandphone 0 "No" 1 "Yes"
	label values landphone lbllandphone
*</_landphone_>
 
** CELLPHONE
*<_cellphone_>

	gen byte cellphone=q_7_6_a
	recode   cellphone (0=0) (1/max=1)
	label var cellphone "Ownership of a cell phone"
	la de lblcellphone 0 "No" 1 "Yes"
	label values cellphone lblcellphone
*</_cellphone_>
 
** PHONE
*<_phone_>
 
	gen byte phone=.
	label var phone "Ownership of a telephone"
	la de lblphone 0 "No" 1 "Yes"
	label values phone lblphone
*</_phone_>
 
** COMPUTER
*<_computer_>
 
	gen byte computer=q_7_1_n
	recode   computer (0=0) (1/max=1)
	label var computer "Ownership of a computer"
	la de lblcomputer 0 "No" 1 "Yes"
	label values computer lblcomputer
*</_computer_>
 
** INTERNET
*<_internet_>
 
	gen byte internet=q_7_11
	recode   internet (1=1) (2 9=4)
	label var internet "Ownership of internet"
	la de lblinternet 1 "Subscribed in the house" 2 "Accessible outside the house" 3 "Either" 4 "No internet"
	label values internet lblinternet
*</_internet_>
 
** RADIO
*<_radio_>
 
	gen byte radio=q_7_1_k
	recode   radio (0=0) (1/max=1)
	label var radio "Ownership of a radio"
	la de lblradio 0 "No" 1 "Yes"
	label values radio lblradio
*</_radio_>
 
** TV
*<_television_>
 
	gen byte television=q_7_1_l
	recode   television (0=0) (1/max=1)
	label var television "Ownership of a television"
	la de lbltelevision 0 "No" 1 "Yes"
	label values television lbltelevision
*</_television_>
 
** TV_CABLE
*<_tv_cable_>
 
	gen byte tv_cable=.
	label var tv_cable "Ownership of a cable tv"
	la de lbltv_cable 0 "No" 1 "Yes"
	label values tv_cable lbltv_cable
*</_tv_cable_>
 
** VIDEO
*<_video_>
 
	gen byte video=.
	label var video "Ownership of a video"
	la de lblvideo 0 "No" 1 "Yes"
	label values video lblvideo
*</_video_>
 
** REFRIGERATOR
*<_refrigerator_>
 
	gen byte refrigerator=q_7_1_a
	recode   refrigerator (0=0) (1/max=1)
	label var refrigerator "Ownership of a refrigerator"
	la de lblrefrigerator 0 "No" 1 "Yes"
	label values refrigerator lblrefrigerator
*</_refrigerator_>

 
** SEWMACH
*<_sewingmachine_>
 
	gen byte sewingmachine=q_7_1_h
	recode   sewingmachine (0=0) (1/max=1)
	label var sewingmachine "Ownership of a sewing machine"
	la de lblsewingmachine 0 "No" 1 "Yes"
	label values sewingmachine lblsewingmachine
*</_sewingmachine_>
 
** WASHMACH
*<_washingmachine_>
 
	gen byte washingmachine=q_7_1_b
	recode   washingmachine (0=0) (1/max=1)
	label var washingmachine "Ownership of a washing machine"
	la de lblwashingmachine 0 "No" 1 "Yes"
	label values washingmachine lblwashingmachine
*</_washingmachine_>
 
** STOVE
*<_stove_>
 
	gen byte stove=q_7_1_f
	recode   stove (0=0) (1/max=1)
	label var stove "Ownership of a stove"
	la de lblstove 0 "No" 1 "Yes"
	label values stove lblstove
*</_stove_>
 
** RICECOOK
*<_ricecook_>
 
	gen byte ricecook=.
	label var ricecook "Ownership of a rice cooker"
	la de lblricecook 0 "No" 1 "Yes"
	label values ricecook lblricecook
*</_ricecook_>
 
** FAN
*<_fan_>
 
	gen byte fan=q_7_1_j
	recode   fan (0=0) (1/max=1)
	label var fan "Ownership of an electric fan"
	la de lblfan 0 "No" 1 "Yes"
	label values fan lblfan
*</_fan_>
 
** AC
*<_ac_>
 
	gen byte ac=.
	label var ac "Ownership of a central or wall air conditioner"
	la de lblac 0 "No" 1 "Yes"
	label values ac lblac
*</_ac_>
 
** ETABLET
*<_etablet_>
 
	gen byte etablet=.
	label var etablet "Ownership of a electronic tablet"
	la de lbletablet 0 "No" 1 "Yes"
	label values etablet lbletablet
*</_etablet_>
 
** EWPUMP
*<_ewpump_>
 
	gen byte ewpump=.
	label var ewpump "Ownership of a electric water pump"
	la de lblewpump 0 "No" 1 "Yes"
	label values ewpump lblewpump
*</_ewpump_>
 
** BICYCLE
*<_bicycle_>
 
	gen byte bicycle=q_7_1_o
	recode   bicycle (0=0) (1/max=1)
	label var bicycle "Ownership of a bicycle"
	la de lblbicycle 0 "No" 1 "Yes"
	label values bicycle lblbicycle
*</_bicycle_>
 
** MOTORCYLE
*<_motorcycle_>

	gen byte motorcycle=q_7_1_p
	recode   motorcycle (0=0) (1/max=1)
	label var motorcycle "Ownership of a motorcycle"
	la de lblmotorcycle 0 "No" 1 "Yes"
	label values motorcycle lblmotorcycle
*</_motorcycle_>
 
** OXCART
*<_oxcart_>
 
	gen byte oxcart=.
	label var oxcart "Ownership of a oxcart"
	la de lbloxcart 0 "No" 1 "Yes"
	label values oxcart lbloxcart
*</_oxcart_>
 
** BOAT
*<_boat_>
 
	gen byte boat=.
	label var boat "Ownership of a boat"
	la de lblboat 0 "No" 1 "Yes"
	label values boat lblboat
*</_boat_>
 
** CAR
*<_motorcar_>
 
	gen byte motorcar=q_7_1_q
	recode   motorcar (0=0) (1/max=1)
	label var motorcar "Ownership of a motorcar"
	la de lblmotorcar 0 "No" 1 "Yes"
	label values motorcar lblmotorcar
*</_motorcar_>
 
** CANOE
*<_canoe_>
 
	gen byte canoe=.
	label var canoe "Ownership of a canoes"
	la de lblcanoe 0 "No" 1 "Yes"
	label values canoe lblcanoe
*</_canoe_>
 
** ROOF
*<_roof_>
 
	gen byte roof=q_4_3
	recode roof (1=34) (2=23) (3=35) (4=21) (5=24) (6=37)
	label var roof "Main material used for roof"
	la de lblroof 12 "Natural – Thatch/palm leaf" 13 "Natural – Sod" 14 "Natural – Other" 21 "Rudimentary – Rustic mat" 22 "Rudimentary – Palm/bamboo" 23 "Rudimentary – Wood planks" 24 "Rudimentary – Other" 31 "Finished – Roofing" 32 "Finished – Asbestos" 33 "Finished – Tile" 34 "Finished – Concrete" 35 "Finished – Metal tile" 36 "Finished – Roofing shingles" 37 "Finished – Other" 96 "Other – “Specific”"
	label values roof lblroof
	
/*
12 = Natural – Thatch/palm leaf
13 = Natural – Sod
14 = Natural – Other
21 = Rudimentary – Rustic mat
22 = Rudimentary – Palm/bamboo
23 = Rudimentary – Wood planks
24 = Rudimentary – Other
31 = Finished – Roofing
32 = Finished – Asbestos
33 = Finished – Tile
34 = Finished – Concrete
35 = Finished – Metal tile
36 = Finished – Roofing shingles
37 = Finished – Other
96 = Other – “Specific”"
*/
*</_roof_>
 
** WALL
*<_wall_>
 
	gen byte wall=q_4_2
	recode wall (1=32) (2=34) (3=22) (4=22) (5=27) 
	label var wall "Main material used for external walls"
	la de lblwall 12 "Natural – Cane/palm/trunks" 13 "Natural – Dirt" 14 "Natural – Other" 21 "Rudimentary – Bamboo with mud" 22 "Rudimentary – Stone with mud" 23 "Rudimentary – Uncovered adobe" 24 "Rudimentary – Plywood" 25 "Rudimentary – Cardboard" 26 "Rudimentary – Reused wood" 27 "Rudimentary – Other" 31 "Finished – Woven Bamboo" 32 "Finished – Stone with lime/cement" 34 "Finished – Cement blocks" 35 "Finished – Covered adobe" 36 "Finished – Wood planks/shingles" 37 "Finished – Plaster wire" 38 "Finished – GRC/Gypsum/Asbestos" 39 "Finished – Other" 96 "Other – “Specific”"
	label values wall lblwall
	
/*
12 = Natural – Cane/palm/trunks
13 = Natural – Dirt
14 = Natural – Other
21 = Rudimentary – Bamboo with mud
22 = Rudimentary – Stone with mud
23 = Rudimentary – Uncovered adobe
24 = Rudimentary – Plywood
25 = Rudimentary – Cardboard
26 = Rudimentary – Reused wood
27 = Rudimentary – Other
31 = Finished – Woven Bamboo
32 = Finished – Stone with lime/cement
34 = Finished – Cement blocks
35 = Finished – Covered adobe
36 = Finished – Wood planks/shingles
37 = Finished – Plaster wire
38 = Finished – GRC/Gypsum/Asbestos
39 = Finished – Other
96 = Other – “Specific”"
*/
*</_wall_>
 
** FLOOR
*<_floor_>
 
	gen byte floor=q_4_4
	recode floor (1=12) (2=34) (3=37) 
	label var floor "Main material used for floor"
	la de lblfloor 11 "Natural – Earth/sand" 12 "Natural – Dung" 13 "Natural –¬ Other" 21 "Rudimentary –¬ Wood planks " 22 "Rudimentary –¬ Palm/bamboo" 23 "Rudimentary – Other" 31 "Finished – Parquet or polished wood" 32 "Finished – Vinyl or asphalt strips" 33 "Finished – Ceramic/marble/granite" 34 "Finished – Floor tiles/teraso" 35 "Finished – Cement/red bricks" 36 "Finished – Carpet" 37 "Finished – Other" 96 "Other – Specific"
	label values floor lblfloor
	
/*
11 = Natural – Earth/sand;
12 = Natural – Dung;
13 = Natural –¬ Other
21 = Rudimentary –¬ Wood planks
22 = Rudimentary –¬ Palm/bamboo
23 = Rudimentary – Other
31 = Finished – Parquet or polished wood
32 = Finished – Vinyl or asphalt strips
33 = Finished – Ceramic/marble/granite
34 = Finished – Floor tiles/teraso
35 = Finished – Cement/red bricks
36 = Finished – Carpet
37 = Finished – Other
96 = Other – "Specific"
*/
*</_floor_>
 
** KITCHEN
*<_kitchen_>
 
	gen byte kitchen=q_4_12
	recode kitchen (1=1) (2=0) (3=1) (4=0) (5=0)
	label var kitchen "Separate kitchen in the dwelling"
	la de lblkitchen 0 "No" 1 "Yes"
	label values kitchen lblkitchen
*</_kitchen_>
 
** BATH
*<_bath_>
 
	gen byte bath=q_4_19
	recode bath (1=0) (2=0) (3=0) (4=0) (5=0) (6=0) (7=0) (8=0) (9=0) (10=0) (11=0)
	label var bath "Bathing facility in the dwelling"
	la de lblbath 0 "No" 1 "Yes"
	label values bath lblbath
*</_bath_>
 
** ROOMS
*<_rooms_>
 
	gen byte rooms=q_4_13
	label var rooms "Number of habitable rooms"
*</_rooms_>
 
** AREASPACE
*<_areaspace_>
 
	gen byte areaspace=.
	label var areaspace "Area"
*</_areaspace_>
 
** OWNHOUSE
*<_ownhouse_>
	recode q_4_6 (1/3 5=1) (4 6/7=3) (8=2) (*=.), g(ownhouse)
*</_ownhouse_>

 
** ACQUI_HOUSE
*<_acqui_house_>
 
	gen byte acqui_house=q_4_6
	recode acqui_house (1=2) (2=1) (3=1) (4=1) (5=1) (6=1) (7=1) (8=3) (9=1) 
	label var acqui_house "Acquisition of house"
	la de lblacqui_house  1 "Purchased" 2 "Inherited" 3 "Rental" 4 "Other"
	label values acqui_house lblacqui_house
*</_acqui_house_>
 
** ACQUI_LAND
*<_acqui_land_>
 
	gen byte acqui_land=.
	label var acqui_land "Acquisition of residential land"
	la de lblacqui_land 1 "Purchased" 2 "Inherited" 3 "Rental" 4 "Other"
	label values acqui_land lblacqui_land
*</_acqui_land_>
 
** DWELOWNLTI
*<_dwelownlti_>
 
	gen byte dwelownlti=.
	label var dwelownlti "Legal title for Ownership"
	la de lbldwelownlti 0 "No" 1 "Yes"
	label values dwelownlti lbldwelownlti
*</_dwelownlti_>
 
** FEM_DWELOWNLTI
*<_fem_dwelownlti_>
 
	gen byte fem_dwelownlti=.
	label var fem_dwelownlti "Legal title for Ownership - Female"
	la de lblfem_dwelownlti 0 "No" 1 "Yes"
	label values fem_dwelownlti lblfem_dwelownlti
*</_fem_dwelownlti_>
 
** DWELOWNTI
*<_dwelownti_>
 
	gen byte dwelownti=.
	label var dwelownti "Type of Legal document"
	la de lbldwelownti 1 "Owner-occupied" 2 "Publicly owned" 3 "Privately owned" 4 "Communally owned" 5 "Cooperatively owned" 6 "Other, non-owner-occupied"
	label values dwelownti lbldwelownti
*</_dwelownti_>
 
** SELLDWEL
*<_selldwel_>
 
	gen byte selldwel=.
	label var selldwel "Right to sell dwelling"
	la de lblselldwel 0 "No" 1 "Yes"
	label values selldwel lblselldwel
*</_selldwel_>
 
** TRANSDWEL
*<_transdwel_>
 
	gen byte transdwel=.
	label var transdwel "Right to transfer dwelling"
	la de lbltransdwel 0 "No" 1 "Yes"
	label values transdwel lbltransdwel
*</_transdwel_>
 
** OWNLAND
*<_ownland_>
 
	gen byte ownland=.
	label var ownland "Ownership of land"
	la de lblownland 0 "No" 1 "Yes"
	label values ownland lblownland
*</_ownland_>
 
** DOCULAND
*<_doculand_>
 
	gen byte doculand=.
	label var doculand "Legal document for residential land"
	la de lbldoculand 0 "No" 1 "Yes"
	label values doculand lbldoculand
*</_doculand_>
 
** FEM_DOCULAND
*<_fem_doculand_>
 
	gen byte fem_doculand=.
	label var fem_doculand "Legal document for residential land - female"
	la de lblfem_doculand 0 "No" 1 "Yes"
	label values fem_doculand lblfem_doculand
*</_fem_doculand_>
 
** LANDOWNTI
*<_landownti_>
 
	gen byte landownti=.
	label var landownti "Land Ownership"
	la de lbllandownti 1 "Title; deed" 2 "leasehold (govt issued)" 3 "Customary land certificate/plot level" 4 "Customary based / group right" 5 "Cooperative group right" 6 "Other"
	label values landownti lbllandownti
*</_landownti_>
 
** SELLLAND
*<_sellland_>
 
	gen byte sellland=.
	label var sellland "Right to sell land"
	la de lblsellland 0 "No" 1 "Yes"
	label values sellland lblsellland
*</_sellland_>
 
** TRANSLAND
*<_transland_>
 
	gen byte transland=.
	label var transland "Right to transfer land"
	la de lbltransland 0 "No" 1 "Yes"
	label values transland lbltransland
*</_transland_>
 
** AGRILAND
*<_agriland_>
 
	gen byte agriland=.
	label var agriland "Agriculture Land"
	la de lblagriland 0 "No" 1 "Yes"
	label values agriland lblagriland
*</_agriland_>
 
** AREA_AGRILAND
*<_area_agriland_>
 
	gen byte area_agriland=.
	label var area_agriland "Area of Agriculture land"
*</_area_agriland_>
 
** OWNAGRILAND
*<_ownagriland_>
	 
	gen byte ownagriland=.
	label var ownagriland "Ownership of agriculture land"
	la de lblownagriland 0 "No" 1 "Yes"
	label values ownagriland lblownagriland
*</_ownagriland_>
 
** AREA_OWNAGRILAND
*<_area_ownagriland_>
	 
	gen byte area_ownagriland=.
	label var area_ownagriland "Area of agriculture land owned"
*</_area_ownagriland_>
 
** PURCH_AGRILAND
*<_purch_agriland_>
 
	gen byte purch_agriland=.
	label var purch_agriland "Purchased agri land"
	la de lblpurch_agriland 0 "No" 1 "Yes"
	label values purch_agriland lblpurch_agriland
*</_purch_agriland_>
 
** AREAPURCH_AGRILAND
*<_areapurch_agriland_>
 
	gen byte areapurch_agriland=.
	label var areapurch_agriland "Area of purchased agriculture land"
*</_areapurch_agriland_>
 
** INHER_AGRILAND
*<_inher_agriland_>
 
	gen byte inher_agriland=.
	label var inher_agriland "Inherit agriculture land"
	la de lblinher_agriland 0 "No" 1 "Yes"
	label values inher_agriland lblinher_agriland
*</_inher_agriland_>
 
** AREAINHER_AGRILAND
*<_areainher_agriland_>
 
	gen byte areainher_agriland=.
	label var areainher_agriland "Area of inherited agriculture land"
*</_areainher_agriland_>
 
** RENTOUT_AGRILAND
*<_rentout_agriland_>
 
	gen byte rentout_agriland=.
	label var rentout_agriland "Rent Out Land"
	la de lblrentout_agriland 0 "No" 1 "Yes"
	label values rentout_agriland lblrentout_agriland
*</_rentout_agriland_>
 
** AREARENTOUT_AGRILAND
*<_arearentout_agriland_>
	 
	gen byte arearentout_agriland=.
	label var arearentout_agriland "Area of rent out agri land"
*</_arearentout_agriland_>
 
** RENTIN_AGRILAND
*<_rentin_agriland_>
 
	gen byte rentin_agriland=.
	label var rentin_agriland "Rent in Land"
	la de lblrentin_agriland 0 "No" 1 "Yes"
	label values rentin_agriland lblrentin_agriland
*</_rentin_agriland_>
 
** AREARENTIN_AGRILAND
*<_arearentin_agriland_>
 
	gen byte arearentin_agriland=.
	label var arearentin_agriland "Area of rent in agri land"
*</_arearentin_agriland_>
 
** DOCUAGRILAND
*<_docuagriland_>
 
	gen byte docuagriland=.
	label var docuagriland "Documented Agri Land"
	la de lbldocuagriland 0 "No" 1 "Yes"
	label values docuagriland lbldocuagriland
*</_docuagriland_>
 
** AREA_DOCUAGRILAND
*<_area_docuagriland_>
 
	gen byte area_docuagriland=.
	label var area_docuagriland "Area of documented agri land"
*</_area_docuagriland_>
 
** FEM_AGRILANDOWNTI
*<_fem_agrilandownti_>
 
	gen byte fem_agrilandownti=.
	label var fem_agrilandownti "Ownership Agri Land - Female"
	la de lblfem_agrilandownti 0 "No" 1 "Yes"
	label values fem_agrilandownti lblfem_agrilandownti
*</_fem_agrilandownti_>
 
** AGRILANDOWNTI
*<_agrilandownti_>
 
	gen byte agrilandownti=.
	label var agrilandownti "Type Agri Land ownership doc" 
	la de lblagrilandownti 1 "Title; deed" 2 "Leasehold (govt issued)" 3 "Customary land certificate/plot level" 4 "Customary based / group right" 5 "Cooperative" 6 "Other"
	label values agrilandownti lblagrilandownti
*</_agrilandownti_>
 
** SELLAGRILAND
*<_sellagriland_>
 
	gen byte sellagriland=.
	label var sellagriland "Right to sell agri land"
	la de lblsellagriland 0 "No" 1 "Yes"
	label values sellagriland lblsellagriland
*</_sellagriland_>
 
** TRANSAGRILAND
*<_transagriland_>
 
	gen byte transagriland=.
	label var transagriland "Right to transfer agri land"
	la de lbltransagriland 0 "No" 1 "Yes"
	label values transagriland lbltransagriland
*</_transagriland_>
 
** TYPLIVQRT
*<_typlivqrt_>
 
	gen byte typlivqrt=.
	label var typlivqrt "Types of living quarters"
	la de lbltyplivqrt 1 "Housing units, conventional dwelling with basic facilities" 2 "Housing units, conventional dwelling without basic facilities" 3 "Other housing units" 4 "Collective living quarters, hotels, rooming houses and other lodging houses" 5 "Collective living quarters, institutions" 6 "Collective living quarters, camps and workers' quarters" 7 "Other collective living quarters"
	label values typlivqrt lbltyplivqrt
*</_typlivqrt_>
 
** DWELTYP
*<_dweltyp_>
 
	gen byte dweltyp= q_4_1
	recode dweltyp (1=1) (2=2) (3=3) (4=8) (5=8) (6=9)
	label var dweltyp "Types of Dwelling"
	la de lbldweltyp 1 "Detached house" 2 "Multi-family house" 3 "Separate apartment" 4 "Communal apartment" 5 "Room in a larger dwelling" 6 "Several buildings connected" 7 "Several separate buildings" 8 "Improvised housing unit" 9 "Other"
	label values dweltyp lbldweltyp
*</_dweltyp_>
 
** YBUILT
*<_ybuilt_>
	gen byte ybuilt=.
	label var ybuilt "Year the dwelling built"
*</_ybuilt_>


/*****************************************************************************************************
*                                                                                                    *
                                            LABOR  
*     numlabel , add                                                                                               *
*****************************************************************************************************/

*</_empstat_>;
recode q12_13 (1 2 3=1) (5=3) (6=2), gen(empstat)
*</_empstat_>;

*</_lstatus_>;
recode activity_status (2=1) (3=2) (4=3), gen(lstatus)
*</_lstatus_>

*</_nlfreason_>
recode q12_12 (5=4) (6=1) (7/14=5) , gen(nlfreason)
*</_nlfreason_>

*</_occup_>
recode q12_17_b (0=10), gen(occup)
*</_occup_>

*</_industry_>
g industry = q12_16_b if lstatus==1
*</_industry_>

*</_industry_orig_>
decode q12_16, g(industry_orig)
replace industry_orig = string(q12_16) + industry_orig
*</_industry_orig_>



/*****************************************************************************************************
*                                                                                                    *
                                            WELFARE  
*     numlabel , add                                                                                               *
*****************************************************************************************************/
*</_national poverty_>
clonevar pline_nat=pline 
clonevar pline_natfood=fline 
clonevar poor_nat=poor 
clonevar poor_natfood=fpoor 
clonevar welfare=pcexall_adj
clonevar welfarenat=pcexall_adj   
clonevar welfarenatfood=pcexf_adj   
*</_national poverty_>

clonevar spdef = Laspeyres_z

*<_welfaredef_>
*<_welfaredef_note_> Welfare aggregate spatially deflated *</_welfaredef_note_>
*<_welfaredef_note_> welfaredef brought in from rawdata *</_welfaredef_note_>
gen welfaredef = pcexall_adj
*</_welfaredef_>

*<_welfarenom_note_> Welfare aggregate in nominal terms *</_welfarenom_note_>
*<_welfarenom_note_> welfarenom brought in from rawdata *</_welfarenom_note_>
egen hexnom = rowtotal(hexnom_f hexnom_n hexnom_d hexnom_r), missing
gen welfarenom = hexnom/hh_size
*</_welfarenom_>

gen welfareother=.
note welfareother: For AFG_2016_LCS, I did not have a sufficient understanding of how `var_notfound' is defined from the SAR team, so it was created as missing.

gen welfareothertype=""
note welfareothertype: For AFG_2016_LCS, I did not have a sufficient understanding of how `var_notfound' is defined from the SAR team, so it was created as missing.

gen welfaretype="CON"

gen welfshprosperity=.
note welfshprosperity: For AFG_2016_LCS, I did not have a sufficient understanding of how `var_notfound' is defined from the SAR team, so it was created as missing.

preserve
* global path on Joe's computer
if ("`c(username)'"=="sunquat") {
	use "Support_2005_GMDRAW_Support_2005_CPI_v10_M_Yearly_CPI_Final", clear
}
* global path on WB computer
else {
	datalibweb, country(Support) year(2005) type(GMDRAW) surveyid(Support_2005_CPI_v`cpiver'_M) filename(Yearly_CPI_Final.dta)
}
drop cpi*
keep if code=="`code'" 
keep if year==`year' | year==2017

gen cpi_year_2017=yearly_cpi if year==2017
egen cpi_year_2017_m=max(cpi_year_2017) 
gen  cpi = yearly_cpi/cpi_year_2017_m
drop if year==2017
rename ppp_2017 ppp 
notes: these cpi and ppp indicators are not weighted as they are for 2011 and before. 
tempfile cpi 
save `cpi'
restore 
cap drop _merge
merge m:1 year code using `cpi', nogen

	 
	** CPI PERIOD //proposal 
	*<_cpiperiod_>
		*gen cpiperiod=syear
		gen cpiperiod=.
		la var cpiperiod "Periodicity of CPI (year, year&month, year&quarter, weighted)"
	*</_cpiperiod_>	

gen food_share =(hexnom_f/hexnom_n)*100
gen nfood_share=100-food_share


*<_quintile_cons_aggregate_>
*<_quintile_cons_aggregate_note_> Quintile of welfarenat *</_quintile_cons_aggregate_note_>
/*<_quintile_cons_aggregate_note_>  *</_quintile_cons_aggregate_note_>*/
*<_quintile_cons_aggregate_note_>  *</_quintile_cons_aggregate_note_>
*gen quintile_cons_aggregate = .a //change
_ebin welfare [aw=wgt], gen(quintile_cons_aggregate) nq(5) 
*</_quintile_cons_aggregate_>

*</_chicken_>
recode q_22_1 (1/max=1) (0=0), g(chicken)																															
*</_chicken_>

*</_piped_water_>
recode q_4_21 (1/3=1) (4/11=0) (*=.), g(piped_water)																														
*</_piped_water_>

*<_typehouse_>
*<_typehouse_note_> GMD ownhouse variable *</_typehouse_note_>
*<_typehouse_note_> typehouse brought in from GMD *</_typehouse_note_>
recode q_4_6 (1/3 5=1) (4 6/7=3) (8=2) (*=.), g(typehouse)
*</_typehouse_>

cap clonevar hhid=idh
	cap clonevar pid=idp
	cap clonevar countrycode=code
	cap gen finalweight=.
	compress
	glo keepextra poor_natfood poor_nat electricity_all elect_grid elect_govgen elect_engine elect_hidro elect_solar elect_wind
	

* create variables that were not in questionnaire as missing 
foreach var_notfound in buffalo lamp lphone contract wage wage_2 empstat_2 empstat_2_year firmsize_l firmsize_u healthins industry_orig_2 industry_orig_year industry_orig_2_year njobs occup_2 occup_year ocusec ocusec_year socialsec unempldur_l unempldur_u union unitwage unitwage_2 whours {
	if strmatch("`var_notfound'","*_orig*") g `var_notfound' = ""
	else g int `var_notfound' = .
	note `var_notfound': AFG_2016_LCS does not have any relevant questions or variables.
}
g int_month = .
note int_month: For AFG_2016_LCS, interview date was provided in terms of the Afghan calendar, but we did not have time to convert them to Gregorian dates.

* create variables that do not have sufficient definitions from the SAR team
foreach var_notknown in industry_year industry_2_year rbirth rbirth_juris rprevious rprevious_juris yrmove empstat_year month pline_int poor_int {
	g `var_notknown'=.
	note `var_notknown': For AFG_2016_LCS, I did not have a sufficient understanding of how `var_notfound' is defined from the SAR team, so it was created as missing.
}
	
*<_Save data file_>
if ("`c(username)'"=="sunquat") global rootdofiles "/Users/`c(username)'/Projects/WORLD BANK/2023 SAR QCHECK/SARDATABANK/SARMDdofiles"
quietly do "$rootdofiles/_aux/Labels_SARMD.do"
save "$output/`filename'.dta", replace
*</_Save data file_>

