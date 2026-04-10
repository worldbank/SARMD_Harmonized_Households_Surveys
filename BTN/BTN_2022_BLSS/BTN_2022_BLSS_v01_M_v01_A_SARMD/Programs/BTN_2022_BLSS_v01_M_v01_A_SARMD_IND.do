/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   BTN_2022_BLSS_v01_M_v01_A_SARMD_IND.do	</_Program name_>
<_Application_>    STATA 16.0	<_Application_>
<_Author(s)_>      jogreen@worldbank.org	</_Author(s)_>
<_Modified_by_>    acastillo@worldbank@worldbank.org	</__>
<_Date created_>   11-28-2022	</_Date created_>
<_Date modified>   11-28-2022	</_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        BTN	</_Country_>
<_Survey Title_>   BLSS	</_Survey Title_>
<_Survey Year_>    2022	</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:	11-28-2022
File:	BTN_2022_BLSS_v01_M_v01_A_SARMD_IND.do
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

glo   cpiver       "v09"
local code         "BTN"
local year         2022
local survey       "BLSS"
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

* global path on Joe's computer
if ("`c(username)'"=="sunquat") {
	glo rootdatalib "/Users/`c(username)'/Projects/WORLD BANK/SAR - GMD data harmonization/datalib"
	glo basepath "$rootdatalib/`code'/`yearfolder'"
	glo input "${basepath}/`yearfolder'_v`vm'_M"
	glo output "${basepath}/`yearfolder'_v`vm'_M_v`va'_A_SARGMD/Data/Harmonized"
	
	* load and merge data
	use "${rootdatalib}/BTN/BTN_2022_BLSS/BTN_2022_BLSS_v01_M/Data/Stata/BTN_2022_BLSS_v01_M.dta", clear
	* The weights variable in the BTN_2022_BLSS_v01_M file is the old weights variable, so remove it.
	drop weight weights
	* merge in the "Final HH weights" variable
	merge m:1 interview__id using "${rootdatalib}/BTN/BTN_2022_BLSS/BTN_2022_BLSS_v01_M/Data/Stata/weights", nogen assert(match)
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
	
	*<_Datalibweb request_>
	* load and merge relevant data
	tempfile individual_level_data
	* weights
	datalibweb, country(`code') year(`year') type(SARRAW) filename(weights) local localpath(${rootdatalib})
	save `individual_level_data', replace
	
	* merge in main data
	datalibweb, country(`code') year(`year') type(SARRAW) filename(`yearfolder'_v`vm'_M.dta) local localpath(${rootdatalib})
	
	* The weights variable in the BTN_2022_BLSS_v01_M file is the old weights variable, so remove it.
	drop weight weights
	merge m:1 interview__id using `individual_level_data', nogen assert(match)
	save `individual_level_data', replace
	
	* merge with CPI data 
	/*
	datalibweb, country(Support) year(2005) type(GMDRAW) surveyid(Support_2005_CPI_${cpiver}_M) filename(Final_CPI_PPP_to_be_used.dta)
	keep if code=="`code'" & year==`year' 
	keep code year cpi2011 icp2011 cpi2017 icp2017 comparability
		rename cpi2011 cpi2011_${cpiver}
		rename cpi2017 cpi2017_${cpiver}
		rename icp2011 ppp_2011
		rename icp2017 ppp_2017
		tempfile cpidata
	save `cpidata', replace
	merge m:1 code year using `cpidata', keep(match)
	*/
	
	*<_cpi_>
	*<_cpi_note_> CPI ratio value of survey (rebased to 2005 on base 1) *</_countrycode_note_>
	*<_cpi_note_> cpi brought in from rawdata *</_countrycode_note_>
	g cpi2017_${cpiver} = 1.255452394485474
	*</_cpi_>

	*<_cpiperiod_>
	*<_cpiperiod_note_> Periodicity of CPI (year, year&month, year&quarter, weighted) *</_countrycode_note_>
	*<_cpiperiod_note_> cpiperiod brought in from rawdata *</_countrycode_note_>
	g cpiperiod = "2022m01-2022m08"
	*</_cpiperiod_>

	*<_ppp_>
	*<_ppp_note_> PPP conversion factor *</_countrycode_note_>
	*<_ppp_note_> ppp brought in from rawdata *</_countrycode_note_>
	g ppp_2017 = 20.4737873077393
	*</_ppp_>
	

	* merge with GMD
	*datalibweb, country(`code') year(`year') type(SARMD) mod(GMD)  local localpath(${rootdatalib})	
	*merge 1:1 hhid pid using `individual_level_data', nogen assert(match)
	*save `individual_level_data', replace

	*</_Datalibweb request_>
	
}
	

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
gen countrycode="`code'"
*</_countrycode_>

*<_year_>
*<_year_note_> Year *</_year_note_>
*<_year_note_> year brought in from rawdata *</_year_note_>
confirm var year
*</_year_>

*<_int_month_>
*<_int_month_note_> interview month *</_int_month_note_>
*<_int_month_note_> int_month brought in from rawdata *</_int_month_note_>
g int_month = .
*</_int_month_>

*<_strata_>
*<_strata_note_> Strata *</_strata_note_>
*<_strata_note_> strata brought in from rawdata *</_strata_note_>
gen strata = stratum44
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
confirm var hhid
*</_hhid_>

*<_pid_>
*<_pid_note_> Personal identifier  *</_pid_note_>
*<_pid_note_> pid brought in from rawdata *</_pid_note_>
confirm var pid
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

*<_weight_>
*<_weight_note_> Household weight *</_weight_note_>
*<_weight_note_> weight brought in from rawdata *</_weight_note_>
g weight = weights
*</_weight_>

*<_wgt_>
*<_wgt_note_> Variables used to construct Household identifier  *</_wgt_note_>
*<_wgt_note_> wgt brought in from GMD *</_wgt_note_>
gen wgt=weights
*</_wgt_>
clonevar finalweight = weight 


/*****************************************************************************************************
*                                                                                                    *
                                   HOUSEHOLD CHARACTERISTICS MODULE
*                                                                                                    *
*****************************************************************************************************/
*<_urban_>
*<_urban_note_> Urban (1) or rural (0) *</_urban_note_>
*<_urban_note_> urban brought in from rawdata *</_urban_note_>
gen urban = (area==1)
*</_urban_>

*<_subnatid1_>
*<_subnatid1_note_> Subnational ID - highest level *</_subnatid1_note_>
*<_subnatid1_note_> subnatid1 brought in from rawdata *</_subnatid1_note_>
label define dcode 1 "21 - Bumthang" 2 "11 - Chukha" 3 "44 - Dagana" 4 "16 - Gasa" 5 "12 - Ha" 6 "31 - Lhuntshi" 7 "32 - Mongar" 8 "13 - Paro" 9 "35 - Pemagatshel" 10 "15 - Punakha" 11 "36 - Samdrup Jongkhar" 12 "41 - Samtse" 13 "42 - Sarpang" 14 "14 - Thimphu" 15 "33 - Trashigang" 16 "34 - Tashi Yangtse" 17 "22 - Trongsa" 18 "43 - Tsirang" 19 "17 - Wangdi Phodrang" 20 "23 - Zhemgang", replace
decode dcode, g(subnatid1)
*</_subnatid1_>

*<_gaul_adm1_code_>
*<_gaul_adm1_code_note_> Gaul Code *</_gaul_adm1_code_note_>
*<_gaul_adm1_code_note_> gaul_adm1_code brought in from rawdata *</_gaul_adm1_code_note_>
recode dcode (1=2105) (2=2106) (3=2107) (4=2108) (5=2109) (6=2110) (7=2111) (8=2112) (9=2113) (10=2114) (11=2115) (12=2116) (13=2117) (14=2118) (15=2119) (16=2120) (17=2121) (18=2122) (19=2123) (20=2124) (*=.), g(gaul_adm1_code)
*</_gaul_adm1_code_>

*<_gaul_adm2_code_>
*<_gaul_adm2_code_note_> Gaul Code *</_gaul_adm2_code_note_>
*<_gaul_adm2_code_note_> gaul_adm2_code brought in from rawdata *</_gaul_adm2_code_note_>
*from GMD-GEO
*</_gaul_adm2_code_>

*<_subnatid2_>
gen subnatid2=""
*</_subnatid2_>

*<_subnatid2_>
gen subnatid3=""
*</_subnatid2_>

*<_typehouse_>
*<_typehouse_note_> GMD ownhouse variable *</_typehouse_note_>
*<_typehouse_note_> typehouse brought in from GMD *</_typehouse_note_>
g		typehouse = 1 if hs2==1
replace	typehouse = 2 if inlist(hs3,1,2)
replace	typehouse = 3 if hs3==3
note typehouse: For BTN_2022_BLSS, we categorized "not owning" (HS2=2) AND "not paying rent" (HS3=3) as 3 "Provided for free" rather than 4 "Without permission".
*</_typehouse_>

*<_ownhouse_>
*<_ownhouse_note_> Ownership of house *</_ownhouse_note_>
*<_ownhouse_note_> ownhouse brought in from rawdata *</_ownhouse_note_>
gen		ownhouse = 1 if hs2==1
replace	ownhouse = 2 if inlist(hs3,1,2)
replace	ownhouse = 3 if hs3==3
note ownhouse: For BTN_2022_BLSS, there were no response options related to ownhouse = 4 "Without permission".
*</_ownhouse_>

** TENURE OF DWELLING
*<_tenure_>
gen tenure=.
*</_tenure_>	

*<_water_orig_>
*<_water_orig_note_> Source of Drinking Water-Original from raw file *</_water_orig_note_>
*<_water_orig_note_> water_orig brought in from rawdata *</_water_orig_note_>
decode hs19, g(water_orig)
*</_water_orig_>

*<_sar_improved_water_>
recode hs19 (1/5 7 9 11 13=1) (6 8 10 12=0) (*=.), g(sar_improved_water)
*</_sar_improved_water_>

*<_improved_water_>
gen improved_water=sar_improved_water
*</_improved_water_>
	
*<_water_source_>
*<_water_source_note_> Sources of drinking water *</_water_source_note_>
*<_water_source_note_> water_source brought in from rawdata *</_water_source_note_>
recode hs19 (1=1) (2=2) (3=3) (4=4) (5=5) (6=10) (7=6) (8=9) (9/10=8) (11=12) (12=13) (13=7) (96=14) (*=.), g(water_source)
*</_water_source_>

*<_piped_water_>
*<_piped_water_note_> Household has access to piped water *</_piped_water_note_>
*<_piped_water_note_> piped_water brought in from rawdata *</_piped_water_note_>
*recode hs19 (1=1) (2=2) (3=3) (4=4) (5=5) (6=10) (7=6) (8=9) (9/10=8) (11=12) (12=13) (13=7) (96=14) (*=.), g(water_source)
recode water_source (1/3=1) (4/14=0), g(piped_water)
*</_piped_water_>

*<_water_jmp_>
*<_water_jmp_note_> Source of drinking water-using Joint Monitoring Program categories *</_water_jmp_note_>
*<_water_jmp_note_> water_jmp brought in from rawdata *</_water_jmp_note_>
gen water_jmp=.
*</_water_jmp_>

*<_toilet_orig_>
*<_toilet_orig_note_> sanitation facility original *</_toilet_orig_note_>
*<_toilet_orig_note_> toilet_orig brought in from rawdata *</_toilet_orig_note_>
decode hs24, g(toilet_orig)
*</_toilet_orig_>

*<_sar_improved_toilet_>
*<_sar_improved_toilet_note_> Improved type of sanitation facility-using country-specific definitions *</_sar_improved_toilet_note_>
*<_sar_improved_toilet_note_> sar_improved_toilet brought in from rawdata *</_sar_improved_toilet_note_>
recode hs24 (1/6=1) (7/8=0) (*=.), g(sar_improved_toilet)
replace sar_improved_toilet = 0 if hs25==1
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
recode hs24 (1=1) (2/8=0) (*=.), g(sewage_toilet)
*</_sewage_toilet_>

*<_electricity_>
*<_electricity_note_> Access to electricity in dwelling *</_electricity_note_>
*<_electricity_note_> electricity brought in from rawdata *</_electricity_note_>
recode hs27 (1/3=1) (4=0) (*=.), g(electricity)
*</_electricity_>

*<_lphone_>
*<_lphone_note_> Household has landphone *</_lphone_note_>
*<_lphone_note_> lphone brought in from rawdata *</_lphone_note_>
gen lphone=.
*</_lphone_>

*<_cellphone_>
*<_cellphone_note_> Ownership of a cell phone (household) *</_cellphone_note_>
*<_cellphone_note_> cellphone brought in from rawdata *</_cellphone_note_>
gen cellphone = ((hs14>0 & hs14<.) | inlist(1,as1__109,as1__110)) if ~missing(hs14) | ~missing(as1__109) | ~missing(as1__110)
*</_cellphone_>


*<_computer_>
*<_computer_note_> Ownership of a computer *</_computer_note_>
*<_computer_note_> computer brought in from rawdata *</_computer_note_>
gen computer = as1__111
*</_computer_>

*<_internet_>
*<_internet_note_> Ownership of a  internet *</_internet_note_>
*<_internet_note_> internet brought in from rawdata *</_internet_note_>
g		internet = 1 if hs17__1==1 | hs17__3==1
replace internet = 3 if hs17__2==1 | hs17__4==1 | (hs15>0 & hs15<.)
recode	internet (.=4) if hs17__1==0 & hs17__2==0 & hs17__3==0 & hs17__4==0 & hs15==0
*</_internet_>

*<_elec_acc_>
*<_elec_acc_note_> Connection to electricity in dwelling *</_elec_acc_note_>
*<_elec_acc_note_> elec_acc brought in from rawdata *</_elec_acc_note_>
recode hs27 (1=1) (2/3=2) (4=4) (*=.), g(elec_acc)
*</_elec_acc_>

/*****************************************************************************************************
*                                                                                                    *
                                   DEMOGRAPHIC MODULE
*                                                                                                    *
*****************************************************************************************************/
** HOUSEHOLD SIZE
*<_hsize_>
gen hsize = hhsize 
*</_hsize_>

*<_pop_wgt_>
*<_pop_wgt_note_> Population weight *</_pop_wgt_note_>
*<_pop_wgt_note_> pop_wgt brought in from rawdata *</_pop_wgt_note_>
gen pop_wgt = weights
*</_pop_wgt_>

*<_relationcs_>
*<_relationcs_note_> Original relationship to head of household *</_relationcs_note_>
*<_relationcs_note_> relationcs brought in from rawdata *</_relationcs_note_>
clonevar relationcs = d2
*</_relationcs_>

*<_relationharm_>
*<_relationharm_note_> Relationship to head of household harmonized across all regions *</_relationharm_note_>
*<_relationharm_note_> relationharm brought in from rawdata *</_relationharm_note_>
recode d2 (1=1) (2=2) (3/4=3) (5/6=4) (7/31=5) (32/33=6) (*=.), g(relationharm)
*</_relationharm_>

*<_male_>
*<_male_note_> Sex of household member (male=1) *</_male_note_>
*<_male_note_> male brought in from rawdata *</_male_note_>
recode d1 (1=1) (2=0) (*=.), g(male)
*</_male_>

*<_age_>
*<_age_note_> Age of individual (continuous) *</_age_note_>
*<_age_note_> age brought in from rawdata *</_age_note_>
confirm var  age
*</_age_>

*<_soc_>
*<_soc_note_> Social group *</_soc_note_>
*<_soc_note_> soc brought in from rawdata *</_soc_note_>
g soc = .
*</_soc_>

*<_marital_>
*<_marital_note_> Marital status *</_marital_note_>
*<_marital_note_> marital brought in from rawdata *</_marital_note_>
recode d4 (1=2) (2=3) (3=1) (4/5=4) (6=5) (*=.), g(marital)
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
g ed_mod_age = 2
*</_ed_mod_age_>

*<_atschool_>
*<_atschool_note_> Attending school *</_atschool_note_>
*<_atschool_note_> atschool brought in from rawdata *</_atschool_note_>
recode ed2 (1=1) (2/4=0), g(atschool)
*</_atschool_>

*<_literacy_>
*<_literacy_note_> Individual can read and write *</_literacy_note_>
*<_literacy_note_> literacy brought in from rawdata *</_literacy_note_>
egen literacy = rowmax(ed1__?)
*</_literacy_>

*<_educy_>
*<_educy_note_> Years of completed education *</_educy_note_>
*<_educy_note_> educy brought in from rawdata *</_educy_note_>
*from GMD
recode ed3 (1=0) (2=1) (3=2) (4=3) (5=4) (6=5) (7=6) (8=7) (9=8) (10=9) (11=10) (12=11) (13=12) (14=13) (15=14) (16=15) (17=16) (19=0), g(educy)
recode ed11 (13=14) (18=19) (19=0), g(educy_ed11)
replace educy = educy_ed11 if ~missing(educy_ed11)
replace educy=. if educy>=age & educy!=. & age!=.
*</_educy_>

*<_educat7_>
*<_educat7_note_> Highest level of education completed (7 categories) *</_educat7_note_>
*<_educat7_note_> educat7 brought in from rawdata *</_educat7_note_>
recode ed11 (0 19=1) (1/8=2) (6=3) (7/11=4) (12=5) (13/14=6) (15/18=7) (*=.), g(educat7)
replace educat7 = 1 if inlist(ed3,0,19)
replace educat7 = 2 if inrange(ed3,1,9)
replace educat7 = 4 if inrange(ed3,7,12)
replace educat7 = 5 if inrange(ed3,13,14)
replace educat7 = 7 if inrange(ed3,15,18)
*</_educat7_>

*<_educat5_>
*<_educat5_note_> Highest level of education completed (5 categories) *</_educat5_note_>
*<_educat5_note_> educat5 brought in from rawdata *</_educat5_note_>
recode educat7 (1=1) (2=2) (3/4=3) (5=4) (6/7=5), g(educat5)
*</_educat5_>

*<_educat4_>
*<_educat4_note_> Highest level of education completed (4 categories) *</_educat4_note_>
*<_educat4_note_> educat4 brought in from rawdata *</_educat4_note_>
recode educat7 (1=1) (2/3=2) (4/5=3) (6/7=4), g(educat4)
*</_educat4_>

*<_everattend_>
*<_everattend_note_> Ever attended school *</_everattend_note_>
*<_everattend_note_> everattend brought in from rawdata *</_everattend_note_>
g everattend = (inlist(ed2,1,2,3)) if inrange(ed2,1,4)
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
g		lstatus = .
*</_lstatus_>

*<_empstat_>
*<_empstat_note_> Employment status *</_empstat_note_>
*<_empstat_note_> empstat brought in from rawdata *</_empstat_note_>
gen empstat=.
*</_empstat_>

*<_occup_>
*<_occup_note_> 1 digit occupational classification *</_occup_note_>
*<_occup_note_> occup brought in from rawdata *</_occup_note_>
g occup = .
*</_occup_>

*<_ocusec_>
*<_ocusec_note_> Sector of activity *</_ocusec_note_>
*<_ocusec_note_> ocusec brought in from rawdata *</_ocusec_note_>
gen ocusec=.
*</_ocusec_>

*<_nlfreason_>
*<_nlfreason_note_> Reason not in the labor force *</_nlfreason_note_>
*<_nlfreason_note_> nlfreason brought in from rawdata *</_nlfreason_note_>
gen nlfreason=.
*</_nlfreason_>

*<_industrycat10_>
*<_industrycat10_note_> 1 digit industry classification *</_industrycat10_note_>
*<_industrycat10_note_> industrycat10 brought in from rawdata *</_industrycat10_note_>
*gen industrycat10 = .
*</_industrycat10_>

*<_industry_orig_>
*<_industry_orig_note_> original industry codes second job *</_industry_orig_note_>
*<_industry_orig_note_> industry_orig brought in from rawdata *</_industry_orig_note_>
*g industry_orig = ""
*</_industry_orig_>

*<_industry_>
*<_industry_note_> 1 digit industry classification *</_industry_note_>
*<_industry_note_> industry brought in from GMD *</_industry_note_>
gen industry=.
*</_industry_>

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
g wage = .
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
gen television = as1__108
*</_television_>

*<_radio_>
*<_radio_note_> Ownership of a radio *</_radio_note_>
*<_radio_note_> radio brought in from rawdata *</_radio_note_>
gen radio =. 
*</_radio_>

** FAN
*<_fan_>
gen fan=.
*</_fan>

*<_washingmachine_>
*<_washingmachine_note_> Household has washing machine *</_washingmachine_note_>
*<_washingmachine_note_> washingmachine brought in from GMD *</_washingmachine_note_>
g washingmachine = as1__106
*</_washingmachine_>

*<_refrigerator_>
*<_refrigerator_note_> Household has refrigerator *</_refrigerator_note_>
*<_refrigerator_note_> refrigerator brought in from GMD *</_refrigerator_note_>
g refrigerator = as1__104
*</_refrigerator_>

*<_sewingmachine_>
*<_sewingmachine_note_> Household has sewing machine *</_sewingmachine_note_>
*<_sewingmachine_note_> sewingmachine brought in from GMD *</_sewingmachine_note_>
g sewingmachine = as1__129
*</_sewingmachine_>

*<_bicycle_>
*<_bicycle_note_> Household has bicycle *</_bicycle_note_>
*<_bicycle_note_> bicycle brought in from GMD *</_bicycle_note_>
g bicycle = as1__123
*</_bicycle_>

*<_motorcar_>
*<_motorcar_note_> Household has motorcar *</_motorcar_note_>
*<_motorcar_note_> motorcar brought in from GMD *</_motorcar_note_>
g motorcar = as1__121
*</_motorcar_>

*<_motorcycle_>
*<_motorcycle_note_> Household has motorcycle *</_motorcycle_note_>
*<_motorcycle_note_> motorcycle brought in from GMD *</_motorcycle_note_>
g motorcycle = as1__122
*</_motorcycle_>

*<_buffalo_>
*<_buffalo_note_> Household has buffalo *</_buffalo_note_>
*<_buffalo_note_> buffalo brought in from rawdata *</_buffalo_note_>
g buffalo = (as2__7>0 & as2__7<.) if as2__7>=0 & ~missing(as2__7)
*</_buffalo_>

*<_chicken_>
*<_chicken_note_> Household has chicken *</_chicken_note_>
*<_chicken_note_> chicken brought in from rawdata *</_chicken_note_>
g chicken = (as2__8>0 & as2__8<.) if as2__8>=0 & ~missing(as2__8)
*</_chicken_>

*<_cow_>
*<_cow_note_> Household has cow *</_cow_note_>
*<_cow_note_> cow brought in from rawdata *</_cow_note_>
g cow = (as2__3>0 & as2__3<.) if as2__3>=0 & ~missing(as2__3)
*</_cow_>

/*****************************************************************************************************
*                                                                                                    *
                                   WELFARE MODULE
*                                                                                                    *
*****************************************************************************************************/
*<_weighttype_>
*<_weighttype_note_> Weight type (frequency, probability, analytical, importance) *</_weighttype_note_>
*<_weighttype_note_> weighttype brought in from rawdata *</_weighttype_note_>
confirm var weighttype
*</_weighttype_>

*<_spdef_>
*<_spdef_note_> Spatial deflator (if one is used) *</_spdef_note_>
g spdef = paasche_res
*<_spdef_note_> spdef brought in from rawdata *</_spdef_note_>

*</_spdef_>

*<_welfarenat_>
*<_welfarenat_note_> Welfare aggregate for national poverty *</_welfarenat_note_>
*<_welfarenat_note_> welfarenat brought in from rawdata *</_welfarenat_note_>
g welfarenat = .
*</_welfarenat_>

*<_welfarenom_>
*<_welfarenom_note_> Welfare aggregate in nominal terms *</_welfarenom_note_>
*<_welfarenom_note_> welfarenom brought in from rawdata *</_welfarenom_note_>
g welfarenom = .z
replace welfarenom=pce
*</_welfarenom_>

*<_welfaredef_>
*<_welfaredef_note_> Welfare aggregate spatially deflated *</_welfaredef_note_>
*<_welfaredef_note_> welfaredef brought in from rawdata *</_welfaredef_note_>
g double welfaredef=.z
replace welfaredef=pcer
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
gen food_share=.
*</_food_share_>

*<_nfood_share_>
gen nfood_share = 100-food_share
*</_nfood_share_>

*<_quintile_cons_aggregate_>
_ebin welfare [aw=weight], gen(quintile_cons_aggregate) nq(5)
*gen quintile_cons_aggregate=.
*</_quintile_cons_aggregate_>

*gen welfshprtype="EXP"


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

*<_lamp_>
*<_lamp_note_> Household has lamp *</_lamp_note_>
*<_lamp_note_> lamp brought in from rawdata *</_lamp_note_>
g lamp = .
*</_lamp_>


*<_Keep variables_>
/*
keep countrycode year hhid pid weight weighttype age idh idh_org idp idp_org wgt psu soc typehouse ownhouse sewage_toilet water_jmp toilet_orig water_orig buffalo bicycle chicken cow lamp motorcar motorcycle refrigerator sewingmachine television washingmachine atschool ed_mod_age everattend educat7 educat5 educat4 educy lphone cellphone computer piped_water sar_improved_water toilet_jmp sar_improved_toilet electricity pop_wgt industry industry_orig lb_mod_age wage industry_2 industry_orig_2 wage_2 rbirth_juris rbirth rprevious_juris rprevious yrmove pline_nat poor_nat welfarenat poor_int pline_int welf* improved* 
*/
order countrycode year hhid pid weight weighttype
sort hhid pid
isid hhid pid
*</_Keep variables_>

*<_Save data file_>
do "${rootdatalib}/`code'/`yearfolder'/`yearfolder'_v`vm'_M_v`va'_A_SARMD/Programs/Labels_SARMD.do"
compress
if ("`c(username)'"=="sunquat") save "${output}/`filename'", replace
else save "$rootdatalib\\`code'\\`yearfolder'\\`gmdfolder'\Data\Harmonized\\`filename'.dta" , replace
*</_Save data file_>
