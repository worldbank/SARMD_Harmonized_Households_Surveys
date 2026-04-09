/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   LKA_2019_HIES_v01_M_v01_A_SARMD_SARMD.do	</_Program name_>
<_Application_>    STATA 16.0	<_Application_>
<_Author(s)_>      Adriana Castillo Castillo : acastillocastill@worldbank.org	</_Author(s)_>
<_Date created_>   06-26-2022	</_Date created_>
<_Date modified>   26 May 2022	</_Date modified_>
Modified by:       Adriana Castillo Castillo : acastillocastill@worldbank.org
--------------------------------------------------------------------------------
<_Country_>        LKA	</_Country_>
<_Survey Title_>   HIES	</_Survey Title_>
<_Survey Year_>    2019	</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:	06-26-2022
File:	LKA_2019_HIES_v01_M_v01_A_SARMD_IND.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/

/*------------------------------------------------------------------------------*
/*------------------------------------------------------------------------------*
0. SET UP 
*------------------------------------------------------------------------------*/
*------------------------------------------------------------------------------*/
*<_Program setup_>
clear all
set more off

glo   cpiver       "v08"
local code         "LKA"
local year         "2019"
local survey       "HIES"
local vm           "01"
local va           "01"
local type         "SARMD"
glo   module       "IND"
local yearfolder   "`code'_`year'_`survey'"
local gmdfolder    "`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD"
local filename     "`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD_${module}"
local filename_UTL "`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD_UTL"
local filename_DWL "`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD_DWL"
tempfile			individual_level_data
*</_Program setup_>


	*<_Folder creation_>
	cap mkdir "${rootdatalib}"
	cap mkdir "${rootdatalib}\\`code'"
	cap mkdir "${rootdatalib}\\`code'\\`yearfolder'"
	cap mkdir "${rootdatalib}\\`code'\\`yearfolder'\\`gmdfolder'"
	cap mkdir "${rootdatalib}\\`code'\\`yearfolder'\\`gmdfolder'\Data"
	cap mkdir "${rootdatalib}\\`code'\\`yearfolder'\\`gmdfolder'\Data\Harmonized"
	*</_Folder creation_>
	
/*------------------------------------------------------------------------------*
/*------------------------------------------------------------------------------*
1. INPUT DATA 
*------------------------------------------------------------------------------*/
*------------------------------------------------------------------------------*/

	*--------------------------------------------------------------------------*
	* CPI and PPP
	*--------------------------------------------------------------------------*
	*<_Datalibweb request_>
	datalibweb, country(Support) year(2005) type(GMDRAW) surveyid(Support_2005_CPI_${cpiver}_M) filename(Final_CPI_PPP_to_be_used.dta)
	keep if code=="`code'" & year==`year' 
	keep code year cpi2011 icp2011 cpi2017 icp2017 comparability
		rename cpi2011 cpi2011_${cpiver}
		rename cpi2017 cpi2017_${cpiver}
		rename icp2011 ppp_2011
		rename icp2017 ppp_2017
		gen cpiperiod=. 
	tempfile cpidata
	save `cpidata', replace
	
	*--------------------------------------------------------------------------*
	* weight data
	*--------------------------------------------------------------------------*
	datalibweb, country(`code') year(`year') type(SARRAW) surveyid(`code'_`year'_`survey'_v01_M) filename(weight_2019.dta)
	
	*--------------------------------------------------------------------------*
	* roster data
	*--------------------------------------------------------------------------*
	preserve 
	datalibweb, country(`code') year(`year') type(SARRAW) surveyid(`code'_`year'_`survey'_v01_M) filename(LKA_2019_HIES_v01_M.dta)
	tempfile LKA_2019_HIES_v01_M
	save `LKA_2019_HIES_v01_M'
	restore 
	merge 1:m psu using `LKA_2019_HIES_v01_M', nogen assert(match)
	save `individual_level_data', replace 

	*--------------------------------------------------------------------------*
	* Section 5.1 - Income from paid employments during last 4 weeks / last calendar month
	*--------------------------------------------------------------------------*
	datalibweb, country(`code') year(`year') type(SARRAW) surveyid(`code'_`year'_`survey'_v01_M) filename(SEC_5_1_EMP_INCOME.dta)
		reshape wide wages_salaries allowences bonus, i(hhid pid) j(pri_sec) //* reshape to wide format: 1 observation per person
		g section5_1 = 1 //* identify observations in this section
	merge 1:1 hhid pid using `individual_level_data', nogen assert(using match)
	save `individual_level_data', replace
	
	*--------------------------------------------------------------------------*
	* Section 5.2 - Income from agricultural activities - (Paddy, Other seasonal crops)
	*--------------------------------------------------------------------------*
	datalibweb, country(LKA) year(2019) type(SARRAW) surveyid(LKA_2019_HIES_v01_M) filename(SEC_5_2_AGRI_INCOME.dta)
		rename s52_col_* s52_col_*_ 
		reshape wide s52_col_5_-s52_col_13_, i(hhid pid) j(s52_col_4) //* reshape to wide format: 1 observation per person
		g section5_2 = 1 
	merge 1:1 hhid pid using `individual_level_data', nogen assert(using match)
	save `individual_level_data', replace
	
	*--------------------------------------------------------------------------*
	* Section 5.3 - Income from other agricultural activities (Non seasonal crops/ Livestock)
	*--------------------------------------------------------------------------*
	datalibweb, country(LKA) year(2019) type(SARRAW) surveyid(LKA_2019_HIES_v01_M) filename(SEC_5_3_OTHER_AGRI_INCOME.dta)
		rename *_5_3 *_5_3_
		rename fertilizes fertilizes_
		reshape wide acres_5_3_-fertilizes_, i(hhid pid) j(seasonal_crop) //* reshape to wide format: 1 observation per person
		g section5_3 = 1 //* identify observations in this section
	merge 1:1 hhid pid using `individual_level_data', nogen assert(using match)
	save `individual_level_data', replace
	
	*--------------------------------------------------------------------------*
	* Section 5.4 - Income Form Non - Agricultural activities (Income from industry, construction, trade and services)
	*--------------------------------------------------------------------------*
	datalibweb, country(LKA) year(2019) type(SARRAW) surveyid(LKA_2019_HIES_v01_M) filename(SEC_5_4_NON_AGRI_INCOME.dta)
		rename *_5_4 *_5_4_
		rename subsidies subsidies_ //* reshape to wide format: 1 observation per person
		reshape wide output_5_4-subsidies_, i(hhid pid) j(non_agri)
		g section5_4 = 1
	merge 1:1 hhid pid using `individual_level_data', nogen assert(using match)
	save `individual_level_data', replace
	
	* housing data
	datalibweb, country(`code') year(`year') type(SARRAW) filename(SEC_8_HOUSING.dta)
	drop pid 
	merge 1:m hhid using `individual_level_data', nogen keep(match using) 
	save `individual_level_data', replace
		
	* livestock owned
	datalibweb, country(`code') year(`year') type(SARRAW) filename(SECTION_9_2_OWNED_LIVESTOCKS.dta)
	drop pid 
	merge 1:m hhid using `individual_level_data', nogen assert(match)
	save `individual_level_data', replace
	
	* education data
	datalibweb, country(`code') year(`year') type(SARRAW) filename(SEC_2_SCHOOL_EDUCATION.dta)
	merge 1:1 hhid pid using `individual_level_data', nogen assert(using match)
	
	* durable goods data
	datalibweb, country(`code') year(`year') type(SARRAW) filename(SEC_6A_DURABLE_GOODS.dta)
	drop pid 
	merge 1:m hhid using `individual_level_data', nogen assert(using match)
	save `individual_level_data', replace
	
	* housing data
	datalibweb, country(`code') year(`year') type(SARRAW) filename(SEC_7_BASIC_FACILITIES.dta)
	drop pid 
	merge 1:m hhid using `individual_level_data', nogen keep(match using) 
	save `individual_level_data', replace
	*</_Datalibweb request_>
	
	*cpi and ppp
	merge m:1 code year using `cpidata', nogen

	*--------------------------------------------------------------------------*
	* Utilities from the GMD database 
	*--------------------------------------------------------------------------*
	merge m:1 hhid using "$rootdatalib\\`code'\\`yearfolder'\\`gmdfolder'\Data\Harmonized\\`filename_UTL'.dta" , nogen 
	
	*--------------------------------------------------------------------------*
	* Utilities from the GMD database 
	*--------------------------------------------------------------------------*
	preserve 
	use "$rootdatalib\\`code'\\`yearfolder'\\`gmdfolder'\Data\Harmonized\\`filename_DWL'.dta", clear 
	keep hhid ownhouse
	tempfile DWL
	save `DWL'
	restore 
	merge m:1 hhid using `DWL', nogen 
	
	
/*******************************************************************************
*                                                                              *
                           STANDARD SURVEY MODULE
*                                                                              *
*******************************************************************************/
*<_veralt_>
*<_veralt_note_> Version number of adaptation to the master data file *</_veralt_note_>
*<_veralt_note_> veralt brought in from rawdata *</_veralt_note_>
gen veralt=`va'
*</_veralt_>

*<_vermast_>
*<_vermast_note_> Version number of master data file *</_vermast_note_>
*<_vermast_note_> vermast brought in from rawdata *</_vermast_note_>
gen vermast=`vm'
*</_vermast_>

*<_countrycode_>
*<_countrycode_note_> country code *</_countrycode_note_>
*<_countrycode_note_> countrycode brought in from rawdata *</_countrycode_note_>
cap gen countrycode=code
*</_countrycode_>

*<_year_>
*<_year_note_> Year *</_year_note_>
*<_year_note_> year brought in from rawdata *</_year_note_>
* NOTE: this variable already exists in harmonized form
*</_year_>

*<_int_month_>
*<_int_month_note_> interview month *</_int_month_note_>
*<_int_month_note_> int_month brought in from rawdata *</_int_month_note_>
g int_month = month
*</_int_month_>

*<_strata_>
*<_strata_note_> Strata *</_strata_note_>
*<_strata_note_> strata brought in from rawdata *</_strata_note_>
gen strata=district
*</_strata_>

*<_int_year_>
*<_int_year_note_> interview year *</_int_year_note_>
*<_int_year_note_> int_year brought in from rawdata *</_int_year_note_>
g int_year = year
*</_int_year_>

*<_survey_>
*<_survey_note_> Type of survey *</_survey_note_>
*<_survey_note_> survey brought in from rawdata *</_survey_note_>
gen survey="`survey'"
*</_survey_>

*<_hhid_>
*<_hhid_note_> Household identifier  *</_hhid_note_>
*<_hhid_note_> hhid brought in from rawdata *</_hhid_note_>
* NOTE: this variable already exists in harmonized form
*</_hhid_>

*<_pid_>
*<_pid_note_> Personal identifier  *</_pid_note_>
*<_pid_note_> pid brought in from rawdata *</_pid_note_>
* NOTE: this variable already exists in harmonized form
*</_pid_>

*<_idh_>
*<_idh_note_> Household identifier  *</_idh_note_>
*<_idh_note_> idh brought in from GMD *</_idh_note_>
gen idh=hhid
*</_idh_>

*<_idh_org_>
*<_idh_org_note_> Household identifier in the raw data  *</_idh_org_note_>
*<_idh_org_note_> idh_org brought in from GMD *</_idh_org_note_>
gen idh_org=hhid
*</_idh_org_>

*<_idp_>
*<_idp_note_> Personal identifier  *</_idp_note_>
*<_idp_note_> idp brought in from GMD *</_idp_note_>
gen idp=pid
*</_idp_>

*<_idp_org_>
*<_idp_org_note_> Personal identifier in the raw data  *</_idp_org_note_>
*<_idp_org_note_> idp_org brought in from GMD *</_idp_org_note_>
gen idp_org=pid
*</_idp_org_>

*<_wgt_>
*<_wgt_note_> Variables used to construct Household identifier  *</_wgt_note_>
*<_wgt_note_> wgt brought in from GMD *</_wgt_note_>
gen wgt=weight
*</_wgt_>

*<_weight_>
*<_weight_note_> Household weight *</_weight_note_>
*<_weight_note_> weight brought in from rawdata *</_weight_note_>
cap clonevar weight = finalweight
*</_weight_>

/*****************************************************************************************************
*                                                                                                    *
                                   HOUSEHOLD CHARACTERISTICS MODULE
*                                                                                                    *
*****************************************************************************************************/
*<_urban_>
*<_urban_note_> Urban (1) or rural (0) *</_urban_note_>
*<_urban_note_> urban brought in from rawdata *</_urban_note_>
cap gen urban = 1   if sector==1
cap replace urban=0 if  sector==2 | sector==3
*</_urban_>

*<_subnatid1_>
*<_subnatid1_note_> Subnational ID - highest level *</_subnatid1_note_>
*<_subnatid1_note_> subnatid1 brought in from rawdata *</_subnatid1_note_>
g district1 = substr(string(district),1,1)
destring district1, replace
label define district1 1 "1 – Western" 2 "2 – Central" 3 "3 – Southern" 4 "4 – Northern" 5 "5 – Eastern" 6 "6 – North-western" 7 "7 – North-central" 8 "8 – Uva" 9 "9 – Sabaragamuwa"
label values district1 district1
decode district1, g(subnatid1)
*</_subnatid1_>

*<_gaul_adm1_code_>
*<_gaul_adm1_code_note_> Gaul Code *</_gaul_adm1_code_note_>
*<_gaul_adm1_code_note_> gaul_adm1_code brought in from rawdata *</_gaul_adm1_code_note_>
recode district1 (1=2744) (2=2736) (3=2742) (4=2740) (5=2737) (6=2739) (7=2738) (8=2743) (9=2741) (*=.), g(gaul_adm1_code)
*</_gaul_adm1_code_>

*<_gaul_adm2_code_>
*<_gaul_adm2_code_note_> Gaul Code *</_gaul_adm2_code_note_>
*<_gaul_adm2_code_note_> gaul_adm2_code brought in from rawdata *</_gaul_adm2_code_note_>
recode district (11=25851) (12=25852) (13=25853) (21=41748) (22=25830) (23=41749) (31=25846) (32=25848) (33=25847) (41=25839) (42=25841) (43=25843) (44=25842) (45=25840) (51=25833) (52=25832) (53=25834) (61=25837) (62=25838) (71=25835) (72=25836) (81=25849) (82=25850) (91=25845) (92=25844) (*=.), g(gaul_adm2_code)
*</_gaul_adm2_code_>

*<_subnatid2_>
*<_subnatid2_note_> Subnational ID - second highest level *</_subnatid2_note_>
*<_subnatid2_note_> subnatid2 brought in from rawdata *</_subnatid2_note_>
gen district2 = district
destring district2, replace
label define district2  11 "11 - Colombo" 12 "12 - Gampaha" 13 "13 - Kalutara" 21 "21 - Kandy" 22 "22 - Matale" 23 "23 - Nuwara-eliya" 31 "31 - Galle" 32 "32 - Matara" 33 "33 - Hambantota" 41 "41 - Jaffna" 42 "42 - Mannar" 43 "43 - Vavuniya" 44 "44 - Mullaitivu" 45 "45 - Kilinochchi" 51 "51 - Batticaloa" 52 "52 - Ampara" 53 "53 - Tricomalee" 61 "61 - Kurunegala" 62 "62 - Puttlam" 71 "71 - Anuradhapura" 72 "72 - Polonnaruwa" 81 "81 - Badulla" 82 "82 - Moneragala" 91 "91 - Ratnapura" 92 "92 - Kegalle"
label values district2 district2
decode district2, g(subnatid2)
*</_subnatid2_>

*<_subnatid2_>
gen subnatid3=""
*</_subnatid2_>

*<_ownhouse_>
*<_ownhouse_note_> Ownership of house *</_ownhouse_note_>
*<_ownhouse_note_> ownhouse brought in from rawdata *</_ownhouse_note_>
*clonevar ownhouse=ownhouse
*</_ownhouse_>

*<_typehouse_>
*<_typehouse_note_> GMD ownhouse variable *</_typehouse_note_>
*<_typehouse_note_> typehouse brought in from GMD *</_typehouse_note_>
recode ownership (1/2=1) (3/6=3) (7/8=2) (9=4) (*=.), g(typehouse)
*</_typehouse_>

** TENURE OF DWELLING
*<_tenure_>
gen tenure=.
replace tenure=1 if ownership>0 & ownership<=4
replace tenure=2 if ownership>4 & ownership<=7
replace tenure=3 if tenure!=1 & tenure!=2 & ownership<.
la de lbltenure 1 "Owner" 2"Renter" 3"Other"
la val tenure lbltenure
*</_tenure_>	

*<_water_orig_>
*<_water_orig_note_> Source of Drinking Water-Original from raw file *</_water_orig_note_>
*<_water_orig_note_> water_orig brought in from rawdata *</_water_orig_note_>
rename water_original water_orig
*</_water_orig_>

*<_improved_water_>
gen improved_water=imp_wat_rec
*</_improved_water_>

*<_improved_water_>
gen sar_improved_water=imp_wat_rec
*</_improved_water_>

*<_piped_water_>
*<_piped_water_note_> Household has access to piped water *</_piped_water_note_>
*<_piped_water_note_> piped_water brought in from rawdata *</_piped_water_note_>
rename piped piped_water
*</_piped_water_>

*<_water_jmp_>
*<_water_jmp_note_> Source of drinking water-using Joint Monitoring Program categories *</_water_jmp_note_>
*<_water_jmp_note_> water_jmp brought in from rawdata *</_water_jmp_note_>
gen water_jmp=.
replace water_jmp=5 if inlist(drinking_water,1)
replace water_jmp=6 if inlist(drinking_water,2)
replace water_jmp=4 if inlist(drinking_water,3)
replace water_jmp=3 if inlist(drinking_water,4,5,6,7)
replace water_jmp=12 if inlist(drinking_water,8)
replace water_jmp=9  if inlist(drinking_water,9)
replace water_jmp=13 if inlist(drinking_water,10,12)
replace water_jmp=10 if inlist(drinking_water,11)
replace water_jmp=14 if inlist(drinking_water,99)
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

*<_toilet_orig_>
*<_toilet_orig_note_> sanitation facility original *</_toilet_orig_note_>
*<_toilet_orig_note_> toilet_orig brought in from rawdata *</_toilet_orig_note_>
rename sanitation_original toilet_orig
*</_toilet_orig_>

*<_sar_improved_toilet_>
*<_sar_improved_toilet_note_> Improved type of sanitation facility-using country-specific definitions *</_sar_improved_toilet_note_>
*<_sar_improved_toilet_note_> sar_improved_toilet brought in from rawdata *</_sar_improved_toilet_note_>
rename imp_san_rec sar_improved_toilet
*</_sar_improved_toilet_>

*<_improved_sanitation_>
gen improved_sanitation=sar_improved_toilet
*</_improved_sanitation_>
	
*<_toilet_jmp_>
*<_toilet_jmp_note_> Access to sanitation facility-using Joint Monitoring Program categories *</_toilet_jmp_note_>
*<_toilet_jmp_note_> toilet_jmp brought in from rawdata *</_toilet_jmp_note_>
gen toilet_jmp=.
*</_toilet_jmp_>

*<_sewage_toilet_>
*<_sewage_toilet_note_> Household has access to sewage toilet *</_sewage_toilet_note_>
*<_sewage_toilet_note_> sewage_toilet brought in from rawdata *</_sewage_toilet_note_>
gen sewage_toilet=.
*</_sewage_toilet_>

*<_electricity_>
*<_electricity_note_> Access to electricity in dwelling *</_electricity_note_>
*<_electricity_note_> electricity brought in from rawdata *</_electricity_note_>
cap recode elec_acc (1/3=1) (4=0), g(electricity)
*</_electricity_>

*<_lphone_>
*<_lphone_note_> Household has landphone *</_lphone_note_>
*<_lphone_note_> lphone brought in from rawdata *</_lphone_note_>
g lphone = (telephone==1) if inlist(telephone,1,2)
*</_lphone_>

*<_cellphone_>
*<_cellphone_note_> Ownership of a cell phone (household) *</_cellphone_note_>
*<_cellphone_note_> cellphone brought in from rawdata *</_cellphone_note_>
gen cellphone = (telephone_mobile==1) if inlist(telephone_mobile,1,2)
*</_cellphone_>

*<_computer_>
*<_computer_note_> Ownership of a computer *</_computer_note_>
*<_computer_note_> computer brought in from rawdata *</_computer_note_>
gen computer = (computers==1) if inlist(computers,1,2)
note computer: LKA 2019 doesn't distinguish between "Personal Computers/ Laptop/ Tablet", so this variable includes all of those categories of computers.
*</_computer_>

*<_internet_>
*<_internet_note_> Ownership of a  internet *</_internet_note_>
*<_internet_note_> internet brought in from rawdata *</_internet_note_>
gen internet=.
*</_internet_>

*<_elec_acc_>
*<_elec_acc_note_> Connection to electricity in dwelling *</_elec_acc_note_>
*<_elec_acc_note_> elec_acc brought in from rawdata *</_elec_acc_note_>
cap gen elec_acc = 1 if inlist(lite_source,1,2) | is_power_lines_near==1
cap replace	elec_acc = 3 if lite_source==4
cap recode elec_acc (.=4) if is_power_lines_near==2
note elec_acc: For LKA_2019_HIES, we used 2 variables as proxies: "Principle Type of Lighting", and "Do you have electricity supply (main line) nearby your area?".
*</_elec_acc_>

/*****************************************************************************************************
*                                                                                                    *
                                   DEMOGRAPHIC MODULE
*                                                                                                    *
*****************************************************************************************************/
** HOUSEHOLD SIZE
*<_hsize_>
gen hsize=hhsize 
*</_hsize_>

*<_pop_wgt_>
*<_pop_wgt_note_> Population weight *</_pop_wgt_note_>
*<_pop_wgt_note_> pop_wgt brought in from rawdata *</_pop_wgt_note_>
gen pop_wgt = finalweight
*</_pop_wgt_>

*<_relationcs_>
*<_relationcs_note_> Original relationship to head of household *</_relationcs_note_>
*<_relationcs_note_> relationcs brought in from rawdata *</_relationcs_note_>
label define relationship 1 "Head of the household" 2 "Wife / Husband" 3 "Son / Daughter" 4 "Parents of head of the household/ spouse" 5 "Other Relative" 6 "Domestic Servant/ Driver/ Watcher" 7 "Boarder" 9 "Other"
label values relationship relationship
tostring relationship, g(relationcs)
*</_relationcs_>

*<_relationharm_>
*<_relationharm_note_> Relationship to head of household harmonized across all regions *</_relationharm_note_>
*<_relationharm_note_> relationharm brought in from rawdata *</_relationharm_note_>
recode relationship (1=1) (2=2) (3=3) (4=4) (5 9=5) (6/7=6) (*=.), g(relationharm)
*</_relationharm_>

*<_male_>
*<_male_note_> Sex of household member (male=1) *</_male_note_>
*<_male_note_> male brought in from rawdata *</_male_note_>
recode sex (1=1) (2=0) (*=.), g(male)
*</_male_>

*<_age_>
*<_age_note_> Age of individual (continuous) *</_age_note_>
*<_age_note_> age brought in from rawdata *</_age_note_>
* NOTE: this variable already exists in harmonized form.
*</_age_>

*<_soc_>
*<_soc_note_> Social group *</_soc_note_>
*<_soc_note_> soc brought in from rawdata *</_soc_note_>
g soc = ethnicity
label define soc 1 "Sinhala" 2 "Sri Lanka Tamil" 3 "Indian Tamil" 4 "Sri Lanka Moors/Muslim" 5 "Burgher" 6 "Malay" 9 "Other"
label values soc soc
*</_soc_>

*<_marital_>
*<_marital_note_> Marital status *</_marital_note_>
*<_marital_note_> marital brought in from rawdata *</_marital_note_>
recode marital_status (1=2) (2/3=1) (4=5) (5/7=4) (*=.), g(marital)
*</_marital_>

*<_rbirth_juris_>
*<_rbirth_juris_note_> Region of Birth Jurisdiction *</_rbirth_juris_note_>
*<_rbirth_juris_note_> rbirth_juris brought in from rawdata *</_rbirth_juris_note_>
gen rbirth_juris=.
*</_rbirth_juris_>

*<_rbirth_>
*<_rbirth_note_> Region of Birth *</_rbirth_note_>
*<_rbirth_note_> rbirth brought in from rawdata *</_rbirth_note_>
gen rbirth=.
*</_rbirth_>

*<_rprevious_juris_>
*<_rprevious_juris_note_> Region of previous residence *</_rprevious_juris_note_>
*<_rprevious_juris_note_> rprevious_juris brought in from rawdata *</_rprevious_juris_note_>
gen rprevious_juris=.
*</_rprevious_juris_>

*<_rprevious_>
*<_rprevious_note_> Region Previous Residence *</_rprevious_note_>
*<_rprevious_note_> rprevious brought in from rawdata *</_rprevious_note_>
gen rprevious=.
*</_rprevious_>

*<_yrmove_>
*<_yrmove_note_> Year of most recent move *</_yrmove_note_>
*<_yrmove_note_> yrmove brought in from rawdata *</_yrmove_note_>
gen yrmove=.
*</_yrmove_>

/*****************************************************************************************************
*                                                                                                    *
                                   EDUCATION MODULE
*                                                                                                    *
*****************************************************************************************************/
*<_ed_mod_age_>
*<_ed_mod_age_note_> Education module application age *</_ed_mod_age_note_>
*<_ed_mod_age_note_> ed_mod_age brought in from rawdata *</_ed_mod_age_note_>
g ed_mod_age = 5
*</_ed_mod_age_>

*<_atschool_>
*<_atschool_note_> Attending school *</_atschool_note_>
*<_atschool_note_> atschool brought in from rawdata *</_atschool_note_>
recode curr_educ (1 9=0) (2/6=1) (*=.), g(atschool)
*</_atschool_>

*<_literacy_>
*<_literacy_note_> Individual can read and write *</_literacy_note_>
*<_literacy_note_> literacy brought in from rawdata *</_literacy_note_>
gen literacy=.
*</_literacy_>

*<_educy_>
*<_educy_note_> Years of completed education *</_educy_note_>
*<_educy_note_> educy brought in from rawdata *</_educy_note_>
gen educy=.
replace educy=. if educy>=age & educy!=. & age!=.
*</_educy_>

*<_educat7_>
*<_educat7_note_> Highest level of education completed (7 categories) *</_educat7_note_>
*<_educat7_note_> educat7 brought in from rawdata *</_educat7_note_>
recode education (19=1) (0/5=2) (6=3) (7/10=4) (11/14=5) (15/17=7) (18=6) (*=.), g(educat7)
note educat7: Note that education = 18 "Special Education learning / learnt" was mapped to educat7 = 6 "Higher than secondary but not university" to be consistent with LKA 2016.
*</_educat7_>

*<_educat5_>
*<_educat5_note_> Highest level of education completed (5 categories) *</_educat5_note_>
*<_educat5_note_> educat5 brought in from rawdata *</_educat5_note_>
recode education (19=1) (0/5=2) (6/10=3) (11/14=4) (15/18=5) (*=.), g(educat5)
note educat5: Note that education = 18 "Special Education learning / learnt" was mapped to educat5 = 5 "Tertiary (completed or incomplete)" to be consistent with LKA 2016.
*</_educat5_>

*<_educat4_>
*<_educat4_note_> Highest level of education completed (4 categories) *</_educat4_note_>
*<_educat4_note_> educat4 brought in from rawdata *</_educat4_note_>
recode education (19=1) (0/6=2) (7/14=3) (15/18=4) (*=.), g(educat4)
note educat4: Note that education = 18 "Special Education learning / learnt" was mapped to educat4 = 4 "Tertiary (complete or incomplete)" to be consistent with LKA 2016.
*</_educat4_>

*<_everattend_>
*<_everattend_note_> Ever attended school *</_everattend_note_>
*<_everattend_note_> everattend brought in from rawdata *</_everattend_note_>
g		everattend = 0 if curr_educ==9 | education==19
replace	everattend = 1 if inrange(curr_educ,2,6) | inrange(education,0,18)
replace	everattend = . if age<5
*</_everattend_>

/*****************************************************************************************************
*                                                                                                    *
                                   LABOR MODULE
*                                                                                                    *
*****************************************************************************************************/
*<_lb_mod_age_>
*<_lb_mod_age_note_> Labor module application age *</_lb_mod_age_note_>
*<_lb_mod_age_note_> lb_mod_age brought in from rawdata *</_lb_mod_age_note_>
g lb_mod_age = 15
*</_lb_mod_age_>

*<_lstatus_>
*<_lstatus_note_> Labor status *</_lstatus_note_>
*<_lstatus_note_> lstatus brought in from rawdata *</_lstatus_note_>
g		lstatus = 1 if inlist(main_activity,1,2)
recode	lstatus (.=2) if main_activity==3
recode	lstatus (.=3) if inrange(main_activity,4,99)
replace lstatus = . if age<15
*</_lstatus_>

*<_empstat_>
*<_empstat_note_> Employment status *</_empstat_note_>
*<_empstat_note_> empstat brought in from rawdata *</_empstat_note_>
recode employment_status (1/3=1) (4=3) (5=4) (6=5) (*=.) if lstatus==1, g(empstat)
*</_empstat_>

*<_occup_>
*<_occup_note_> 1 digit occupational classification *</_occup_note_>
*<_occup_note_> occup brought in from rawdata *</_occup_note_>
tostring main_occupation, g(main_occupation_str)
replace main_occupation_str = "0" + main_occupation_str if length(main_occupation_str)==3
g occup = substr(main_occupation_str,1,1) if lstatus==1
destring occup, replace
*</_occup_>

*<_ocusec_>
*<_ocusec_note_> Sector of activity *</_ocusec_note_>
*<_ocusec_note_> ocusec brought in from rawdata *</_ocusec_note_>
recode employment_status (1=1) (2=3) (3/6=2) (*=.) if lstatus==1, g(ocusec)
*</_ocusec_>

*<_nlfreason_>
*<_nlfreason_note_> Reason not in the labor force *</_nlfreason_note_>
*<_nlfreason_note_> nlfreason brought in from rawdata *</_nlfreason_note_>
recode main_activity (4/6=3) (7=2) (8=1) (9=4) (99=5) (*=.) if lstatus==3, g(nlfreason)
*</_nlfreason_>

*<_industry_orig_>
*<_industry_orig_note_> original industry codes *</_industry_orig_note_>
*<_industry_orig_note_> industry_orig brought in from rawdata *</_industry_orig_note_>
g industry_orig = industry if lstatus==1
*</_industry_orig_>

*<_industrycat10_>
*<_industrycat10_note_> 1 digit industry classification *</_industrycat10_note_>
*<_industrycat10_note_> industrycat10 brought in from rawdata *</_industrycat10_note_>
/*
tostring industry, g(industry_str)
replace industry_str = "0" + industry_str if length(industry_str)==4
gen industrycat10 = substr(industry_str,1,1)
destring industrycat10, replace
replace industrycat10 = . if lstatus~=1
*/
gen ind=int(industry/1000)
drop industry
recode ind (1/3 = 1) (5/9 = 2) (10/33 = 3) (35/39 = 4) (41/43 = 5) ///
(45/47 = 6) (49/63 = 7) (64/82 = 8) (84 = 9) (85/99 = 10), gen(industry)
gen industrycat10= industry
replace industrycat10 = . if lstatus~=1
*</_industrycat10_>

*<_empstat_2_>
*<_empstat_2_note_> Employment status - second job *</_empstat_2_note_>
*<_empstat_2_note_> empstat_2 brought in from rawdata *</_empstat_2_note_>
gen empstat_2=.
*</_empstat_2_>

*<_empstat_2_year_>
*<_empstat_2_year_note_> Employment status - second job (12-mon ref period) *</_empstat_2_year_note_>
*<_empstat_2_year_note_> empstat_2_year brought in from rawdata *</_empstat_2_year_note_>
gen empstat_2_year=.
*</_empstat_2_year_>

*<_wage_>
*<_wage_note_> Last wage payment *</_wage_note_>
*<_wage_note_> wage brought in from rawdata *</_wage_note_>
g wage = wages_salaries1
*</_wage_>

*<_industry_2_>
*<_industry_2_note_> 1 digit industry classification - second job *</_industry_2_note_>
*<_industry_2_note_> industry_2 brought in from GMD *</_industry_2_note_>
gen industry_2 = .
*</_industry_2_>

*<_industry_orig_2_>
*<_industry_orig_2_note_> original industry codes second job *</_industry_orig_2_note_>
*<_industry_orig_2_note_> industry_orig_2 brought in from rawdata *</_industry_orig_2_note_>
gen industry_orig_2=.
*</_industry_orig_2_>

*<_whours_>
*<_whours_note_> Hours of work in last week *</_whours_note_>
*<_whours_note_> whours brought in from rawdata *</_whours_note_>
gen whours=.
*</_whours_>

*<_wage_2_>
*<_wage_2_note_> Last wage payment second job *</_wage_2_note_>
*<_wage_2_note_> wage_2 brought in from rawdata *</_wage_2_note_>
gen wage_2=.
*</_wage_2_>

*<_njobs_>
*<_njobs_note_> Total number of jobs *</_njobs_note_>
*<_njobs_note_> njobs brought in from rawdata *</_njobs_note_>
gen njobs=.
*</_njobs_>

*<_firmsize_l_year_>
*<_firmsize_l_year_note_> Firm size (lower bracket) (12-mon ref period) *</_firmsize_l_year_note_>
*<_firmsize_l_year_note_> firmsize_l_year brought in from rawdata *</_firmsize_l_year_note_>
gen firmsize_l=.
*</_firmsize_l>

*<_firmsize_u_year_>
*<_firmsize_u_year_note_> Firm size (upper bracket) (12-mon ref period) *</_firmsize_u_year_note_>
*<_firmsize_u_year_note_> firmsize_u_year brought in from rawdata *</_firmsize_u_year_note_>
gen firmsize_u=.
*</_firmsize_u_year_>

*<_unempldur_l_>
*<_unempldur_l_note_> Unemployment duration (months) lower bracket *</_unempldur_l_note_>
*<_unempldur_l_note_> unempldur_l brought in from rawdata *</_unempldur_l_note_>
gen unempldur_l=.
*</_unempldur_l_>

*<_unempldur_u_>
*<_unempldur_u_note_> Unemployment duration (months) upper bracket *</_unempldur_u_note_>
*<_unempldur_u_note_> unempldur_u brought in from rawdata *</_unempldur_u_note_>
gen unempldur_u=.
*</_unempldur_u_>

*<_union_>
*<_union_note_> Union membership *</_union_note_>
*<_union_note_> union brought in from rawdata *</_union_note_>
gen union=.
*</_union_>

*<_unitwage_>
*<_unitwage_note_> Last wages time unit *</_unitwage_note_>
*<_unitwage_note_> unitwage brought in from rawdata *</_unitwage_note_>
gen unitwage=.
*</_unitwage_>

*<_unitwage_>
*<_unitwage_note_> Last wages time unit *</_unitwage_note_>
*<_unitwage_note_> unitwage brought in from rawdata *</_unitwage_note_>
gen unitwage_2=.
*</_unitwage_>

*<_healthins_>
*<_healthins_note_> Health insurance *</_healthins_note_>
*<_healthins_note_> healthins brought in from rawdata *</_healthins_note_>
gen healthins=.
*</_healthins_>

*<_socialsec_>
*<_socialsec_note_> Social security *</_socialsec_note_>
*<_socialsec_note_> socialsec brought in from rawdata *</_socialsec_note_>
gen socialsec=.
*</_socialsec_>

*<_contract_>
*<_contract_note_> Contract *</_contract_note_>
*<_contract_note_> contract brought in from rawdata *</_contract_note_>
gen contract=.
*</_contract_> 

/*****************************************************************************************************
*                                                                                                    *
                                            ASSETS 
*                                                                                                    *
*****************************************************************************************************/
*<_television_>
*<_television_note_> Household has television *</_television_note_>
*<_television_note_> television brought in from GMD *</_television_note_>
recode tv (1=1) (2=0) (*=.), g(television)
*</_television_>

*<_radio_>
*<_radio_note_> Ownership of a radio *</_radio_note_>
*<_radio_note_> radio brought in from rawdata *</_radio_note_>
recode radio (1=1) (2=0) (*=.)
note radio: LKA 2019 doesn't distinguish between "Radio / Cassette player", so this variable also includes cassette players.
*</_radio_>

** FAN
*<_fan_>
recode electric_fans (1=1) (2=0) (*=.), g(fan)
label var fan "Household has a fan"
la de lblfan 0 "No" 1 "Yes"
label val fan lblfan
*</_fan>

*<_washingmachine_>
*<_washingmachine_note_> Household has washing machine *</_washingmachine_note_>
*<_washingmachine_note_> washingmachine brought in from GMD *</_washingmachine_note_>
recode washing_mechine (1=1) (2=0) (*=.), g(washingmachine)
*</_washingmachine_>

*<_refrigerator_>
*<_refrigerator_note_> Household has refrigerator *</_refrigerator_note_>
*<_refrigerator_note_> refrigerator brought in from GMD *</_refrigerator_note_>
recode fridge (1=1) (2=0) (*=.), g(refrigerator)
*</_refrigerator_>

*<_sewingmachine_>
*<_sewingmachine_note_> Household has sewing machine *</_sewingmachine_note_>
*<_sewingmachine_note_> sewingmachine brought in from GMD *</_sewingmachine_note_>
recode sewingmechine (1=1) (2=0) (*=.), g(sewingmachine)
*</_sewingmachine_>

*<_bicycle_>
*<_bicycle_note_> Household has bicycle *</_bicycle_note_>
*<_bicycle_note_> bicycle brought in from GMD *</_bicycle_note_>
recode bicycle (1=1) (2=0) (*=.)
*</_bicycle_>

*<_motorcar_>
*<_motorcar_note_> Household has motorcar *</_motorcar_note_>
*<_motorcar_note_> motorcar brought in from GMD *</_motorcar_note_>
recode motor_car_van (1=1) (2=0) (*=.), g(motorcar)
*</_motorcar_>

*<_motorcycle_>
*<_motorcycle_note_> Household has motorcycle *</_motorcycle_note_>
*<_motorcycle_note_> motorcycle brought in from GMD *</_motorcycle_note_>
recode motor_bicycle (1=1) (2=0) (*=.), g(motorcycle)
*</_motorcycle_>

*<_buffalo_>
*<_buffalo_note_> Household has buffalo *</_buffalo_note_>
*<_buffalo_note_> buffalo brought in from rawdata *</_buffalo_note_>
recode s9_cattle_buffaloes (1=1) (2=0) (*=.), g(buffalo)
note buffalo: LKA_2019_HEIS asks about cattle and buffaloes in the same question.
*</_buffalo_>

*<_chicken_>
*<_chicken_note_> Household has chicken *</_chicken_note_>
*<_chicken_note_> chicken brought in from rawdata *</_chicken_note_>
recode chickens (1=1) (2=0) (*=.), g(chicken)
*</_chicken_>

*<_cow_>
*<_cow_note_> Household has cow *</_cow_note_>
*<_cow_note_> cow brought in from rawdata *</_cow_note_>
recode s9_cattle_buffaloes (1=1) (2=0) (*=.), g(cow)
note cow: LKA_2019_HEIS asks about cattle and buffaloes in the same question.
*</_cow_>

/*****************************************************************************************************
*                                                                                                    *
                                   WELFARE MODULE
*                                                                                                    *
*****************************************************************************************************/
*<_weighttype_>
*<_weighttype_note_> Weight type (frequency, probability, analytical, importance) *</_weighttype_note_>
*<_weighttype_note_> weighttype brought in from rawdata *</_weighttype_note_>
cap g weighttype = "PW"
*</_weighttype_>

*<_spdef_>
*<_spdef_note_> Spatial deflator (if one is used) *</_spdef_note_>
*<_spdef_note_> spdef brought in from rawdata *</_spdef_note_>
clonevar spdef=lpindex1
*</_spdef_>

*<_welfarenat_>
*<_welfarenat_note_> Welfare aggregate for national poverty *</_welfarenat_note_>
*<_welfarenat_note_> welfarenat brought in from rawdata *</_welfarenat_note_>
g welfarenat = (hhexppm/hhsize)/lpindex1 if residence==1
*</_welfarenat_>

*<_welfarenom_>
*<_welfarenom_note_> Welfare aggregate in nominal terms *</_welfarenom_note_>
*<_welfarenom_note_> welfarenom brought in from rawdata *</_welfarenom_note_>
g welfarenom = hhexppm/hhsize if residence==1
*</_welfarenom_>

*<_welfaredef_>
*<_welfaredef_note_> Welfare aggregate spatially deflated *</_welfaredef_note_>
*<_welfaredef_note_> welfaredef brought in from rawdata *</_welfaredef_note_>
g double welfaredef=welfarenom/lpindex1 if residence==1
*</_welfaredef_>

*<_welfare_>
*<_welfare_note_> Welfare aggregate used for estimating international poverty (provided to PovcalNet) *</_welfare_note_>
*<_welfare_note_> welfare brought in from rawdata *</_welfare_note_>
g welfare = welfaredef
*</_welfare_>

*<_welfareother_>
*<_welfareother_note_> Welfare aggregate if different welfare type is used from welfare, welfarenom, welfaredef *</_welfareother_note_>
*<_welfareother_note_> welfareother brought in from rawdata *</_welfareother_note_>
gen welfareother=.
*</_welfareother_>

*<_welfareothertype_>
*<_welfareothertype_note_> Type of welfare measure (income, consumption or expenditure) for welfareother *</_welfareothertype_note_>
*<_welfareothertype_note_> welfareothertype brought in from rawdata *</_welfareothertype_note_>
gen welfareothertype=.
*</_welfareothertype_>

*<_welfaretype_>
*<_welfaretype_note_> Type of welfare measure (income, consumption or expenditure) for welfare, welfarenom, welfaredef *</_welfaretype_note_>
*<_welfaretype_note_> welfaretype brought in from rawdata *</_welfaretype_note_>
gen welfaretype="EXP"
*</_welfaretype_>

*<_welfshprosperity_>
*<_welfshprosperity_note_> Welfare aggregate for shared prosperity (if different from poverty) *</_welfshprosperity_note_>
*<_welfshprosperity_note_> welfshprosperity brought in from rawdata *</_welfshprosperity_note_>
gen welfshprosperity=.
*</_welfshprosperity_>

*<_poor_int_>
*<_poor_int_note_> People below Poverty Line (International) *</_poor_int_note_>
*<_poor_int_note_> poor_int brought in from rawdata *</_poor_int_note_>
gen poor_int=.
*</_poor_int_>

*<_pline_int_>
*<_pline_int_note_> Poverty line Povcalnet *</_pline_int_note_>
*<_pline_int_note_> pline_int brought in from rawdata *</_pline_int_note_>
gen pline_int=.
*</_pline_int_>

*<_food_share_>
gen food_share=(hhfoodexppm/hhexppm)*100
*</_food_share_>

*<_nfood_share_>
gen nfood_share = 100-food_share
*</_nfood_share_>

*<_quintile_cons_aggregate_>
_ebin welfare [aw=weight], gen(quintile_cons_aggregate) nq(5)
*</_quintile_cons_aggregate_>

/*****************************************************************************************************
*                                                                                                    *
                                   NATIONAL POVERTY
*                                                                                                    *
*****************************************************************************************************/
*<_pline_nat_>
*<_pline_nat_note_> Poverty line naPoverty Line (National) *</_pline_nat_note_>
*<_pline_nat_note_> pline_nat brought in from rawdata *</_pline_nat_note_>
gen pline_nat=.
*</_pline_nat_>

*<_poor_nat_>
*<_poor_nat_note_> People below Poverty Line (National) *</_poor_nat_note_>
*<_poor_nat_note_> poor_nat brought in from rawdata *</_poor_nat_note_>
gen poor_nat=.
*</_poor_nat_>

save `individual_level_data', replace



* WORK ON NON-FOOD-LEVEL DATA
*-------------------------------------------------------------------------------
* global path on Joe's computer
if ("`c(username)'"=="sunquat") {
	* 4.2: Household expenditure on Housing, Fuel & Light, Non-durable goods, Services & durable goods for main Household
	use "SEC_4_2_NONFOOD", clear
}
* global paths on WB computer
else {
	* 4.2: Household expenditure on Housing, Fuel & Light, Non-durable goods, Services & durable goods for main Household
	datalibweb, country(`code') year(`year') type(SARRAW) filename(SEC_4_2_NONFOOD.dta)
}

*<_lamp_>
*<_lamp_note_> Household has lamp *</_lamp_note_>
*<_lamp_note_> lamp brought in from rawdata *</_lamp_note_>
g lamp = (nf_quantity>0 & nf_quantity<.) if nf_code==3207
*</_lamp_>

* collapse to HH-level
collapse (max) lamp, by(hhid)

* merge with individual-level data
merge 1:m hhid using `individual_level_data', nogen assert(using match)

*<_Keep variables_>
/*
keep countrycode year hhid pid weight weighttype age idh idh_org idp idp_org wgt psu soc typehouse ownhouse sewage_toilet water_jmp toilet_orig water_orig buffalo bicycle chicken cow lamp motorcar motorcycle refrigerator sewingmachine television washingmachine atschool ed_mod_age everattend educat7 educat5 educat4 educy lphone cellphone computer piped_water sar_improved_water toilet_jmp sar_improved_toilet electricity pop_wgt industry industry_orig lb_mod_age wage industry_2 industry_orig_2 wage_2 rbirth_juris rbirth rprevious_juris rprevious yrmove pline_nat poor_nat welfarenat poor_int pline_int welf* improved* 
*/
order countrycode year hhid pid weight weighttype
sort hhid pid 
*</_Keep variables_>

*<_Save data file_>
do "${rootdatalib}/`code'/`yearfolder'/`yearfolder'_v`vm'_M_v`va'_A_SARMD/Programs/Labels_SARMD.do"
save "$rootdatalib\\`code'\\`yearfolder'\\`gmdfolder'\Data\Harmonized\\`filename'.dta" , replace
*</_Save data file_>
