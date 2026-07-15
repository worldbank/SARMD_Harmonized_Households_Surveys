/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   AFG_2019_LCS_v01_M_v01_A_GMD_SARMD.do	</_Program name_>
<_Application_>    STATA 16.0	<_Application_>
<_Author(s)_>      jogreen@worldbank.org	</_Author(s)_>
<_Date created_>   05-25-2020	</_Date created_>
<_Date modified>   08-08-2021	</_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        AFG	</_Country_>
<_Survey Title_>   LCS	</_Survey Title_>
<_Survey Year_>    2019	</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:	08-08-2021
File:	AFG_2019_LCS_v01_M_v01_A_GMD_SARMD.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>
clear all
set more off

local code         "AFG"
local year         "2019"
local survey       "LCS"
local vm           "01"
local va           "01"
local type         "SARMD"
local yearfolder   "`code'_`year'_`survey'"
local harmfolder    "`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'"
local filename      "`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'_IND"
*</_Program setup_>

* global path on Joe's computer
if ("`c(username)'"=="dekopon") {
	glo basepath "/Users/dekopon/Projects/WORLD BANK/SAR - GMD data harmonization/datalib/`code'/`yearfolder'"
	glo input "${basepath}/`yearfolder'_v`vm'_M"
	glo output "${basepath}/`yearfolder'_v`vm'_M_v`va'_A_SARGMD/Data/Harmonized"
	
	* load and merge relevant data
	cd "${input}/Data/Stata"
	* roster data
	use "roster_male.dta", clear
	* household data
	merge m:1 HH_ID using "household_male", nogen assert(match)
	rename HH_ID hhid_orig
	destring hhid, g(HH_ID)	//note: need to fill in hhid if subsequent merged data contains umatched observations.
	* weight data
	merge m:1 HH_ID using "clusters", nogen assert(match)
}
* global paths on WB computer
else {
	*<_Folder creation_>
	cap mkdir "${rootdatalib}"
	cap mkdir "${rootdatalib}\\`code'"
	cap mkdir "${rootdatalib}\\`code'\\`yearfolder'"
	cap mkdir "${rootdatalib}\\`code'\\`yearfolder'\\`harmfolder'"
	cap mkdir "${rootdatalib}\\`code'\\`yearfolder'\\`harmfolder'\Data"
	cap mkdir "${rootdatalib}\\`code'\\`yearfolder'\\`harmfolder'\Data\Harmonized"
	glo output "${rootdatalib}\\`code'\\`yearfolder'\\`harmfolder'\Data\Harmonized"
	*</_Folder creation_>
	
	*<_Datalibweb request_>
	* poverty data
	tempfile individual_level_data
	local dlw "datalibweb, country(`code') year(`year') type(SARRAW) surveyid(`code'_`year'_`survey'_v`vm'_M)"
	qui `dlw' filename(temp_pov_2016_2019_consolidated.dta)
	
	keep if year==`year'
	drop year
	tabstat poor [aw= ind_weight ]
	*  .4709674
	gen aux_weight=ind_weight

	rename hhid HH_ID
	save `individual_level_data'	//NOTE: The poverty data is actually HH-level data, but will be merged into individual-level data in the next step.
	* roster data
	* NOTE: some individuals do not have poverty data. 
	qui `dlw' filename(roster_male.dta)
	merge m:1 HH_ID using `individual_level_data', gen(m_pov_roster) 
	save `individual_level_data', replace
	tabstat poor [aw= hh_weight ]
	* .4709674

	* household data
	qui `dlw' filename(household_male.dta)
	merge 1:m HH_ID using `individual_level_data', gen(m_household)

	rename HH_ID hhid_orig
	destring hhid_orig, g(HH_ID)	//note: need to fill in hhid if subsequent merged data contains umatched observations.
	save `individual_level_data', replace

	* weight data
	qui `dlw' filename(clusters.dta)
	merge 1:m HH_ID using `individual_level_data', gen(clusters) update replace
	*</_Datalibweb request_>

}

*<_countrycode_>
*<_countrycode_note_> country code *</_countrycode_note_>
*<_countrycode_note_> countrycode brought in from rawdata *</_countrycode_note_>
g countrycode = "`code'"
*</_countrycode_>

*<_year_>
*<_year_note_> Year *</_year_note_>
*<_year_note_> year brought in from rawdata *</_year_note_>
g year = `year'
*</_year_>

*<_hhid_>
*<_hhid_note_> Household identifier  *</_hhid_note_>
*<_hhid_note_> hhid brought in from rawdata *</_hhid_note_>
clonevar hhid = hhid_orig
*</_hhid_>

*<_pid_>
*<_pid_note_> Personal identifier  *</_pid_note_>
*<_pid_note_> pid brought in from rawdata *</_pid_note_>
clonevar pid = Mem_ID
*</_pid_>

*<_weight_>
*<_weight_note_> Household weight *</_weight_note_>
*<_weight_note_> weight brought in from rawdata *</_weight_note_>
clonevar weight = hh_weight
*</_weight_>

*<_weighttype_>
*<_weighttype_note_> Weight type (frequency, probability, analytical, importance) *</_weighttype_note_>
*<_weighttype_note_> weighttype brought in from rawdata *</_weighttype_note_>
g weighttype = "PW"
*</_weighttype_>

*<_age_>
*<_age_note_> Age of individual (continuous) *</_age_note_>
*<_age_note_> age brought in from rawdata *</_age_note_>
gen age = q202
*</_age_>

*<_idh_>
*<_idh_note_> Household identifier  *</_idh_note_>
*<_idh_note_> idh brought in from GMD *</_idh_note_>
gen idh=hhid
*</_idh_>

*<_idh_org_>
*<_idh_org_note_> Household identifier in the raw data  *</_idh_org_note_>
*<_idh_org_note_> idh_org brought in from GMD *</_idh_org_note_>
gen idh_org=hhid_orig
*</_idh_org_>

*<_idp_>
*<_idp_note_> Personal identifier  *</_idp_note_>
*<_idp_note_> idp brought in from GMD *</_idp_note_>
gen idp=pid
*</_idp_>

*<_idp_org_>
*<_idp_org_note_> Personal identifier in the raw data  *</_idp_org_note_>
*<_idp_org_note_> idp_org brought in from GMD *</_idp_org_note_>
gen idp_org=Mem_ID
*</_idp_org_>

*<_wgt_>
*<_wgt_note_> Variables used to construct Household identifier  *</_wgt_note_>
*<_wgt_note_> wgt brought in from GMD *</_wgt_note_>
gen wgt=weight
*</_wgt_>

*<_soc_>
*<_soc_note_> Social group *</_soc_note_>
*<_soc_note_> soc brought in from rawdata *</_soc_note_>
gen soc=.
*</_soc_>

*<_typehouse_>
*<_typehouse_note_> GMD ownhouse variable *</_typehouse_note_>
*<_typehouse_note_> typehouse brought in from GMD *</_typehouse_note_>
recode q606 (1/3 5=1) (4 6/7=3) (8=2) (*=.), g(typehouse)
*</_typehouse_>

*<_ownhouse_>
*<_ownhouse_note_> SARMD ownhouse variable *</_ownhouse_note_>
*<_ownhouse_note_> ownhouse brought in from GMD *</_ownhouse_note_>
recode typehouse (1=1 "Yes") (2 3 4=0 "No"), g(ownhouse)
*</_ownhouse_>

*<_sewage_toilet_>
*<_sewage_toilet_note_> Household has access to sewage toilet *</_sewage_toilet_note_>
*<_sewage_toilet_note_> sewage_toilet brought in from rawdata *</_sewage_toilet_note_>
gen sewage_toilet=.
*</_sewage_toilet_>

*<_water_jmp_>
*<_water_jmp_note_> Source of drinking water-using Joint Monitoring Program categories *</_water_jmp_note_>
*<_water_jmp_note_> water_jmp brought in from rawdata *</_water_jmp_note_>
gen water_jmp=.
*</_water_jmp_>

*<_toilet_orig_>
*<_toilet_orig_note_> sanitation facility original *</_toilet_orig_note_>
*<_toilet_orig_note_> toilet_orig brought in from rawdata *</_toilet_orig_note_>
clonevar toilet_orig_num = q619
numlabel L_q619, add mask("# - ")
decode toilet_orig_num, g(toilet_orig)
*</_toilet_orig_>

*<_water_orig_>
*<_water_orig_note_> Source of Drinking Water-Original from raw file *</_water_orig_note_>
*<_water_orig_note_> water_orig brought in from rawdata *</_water_orig_note_>
clonevar water_orig_num = q616
numlabel L_q616, add mask("# - ")
decode water_orig_num, g(water_orig)
*</_water_orig_>

*<_cellphone_i_>
*<_cellphone_i_note_> Ownership of a cell phone (individual) *</_cellphone_i_note_>
*<_cellphone_i_note_> cellphone_i brought in from rawdata *</_cellphone_i_note_>
gen cellphone_i=.
note cellphone_i: AFG 2019 asks about cell phone ownership at the HH-level only.
*</_cellphone_i_>

*</_motorcycle_>
gen motorcycle=(q902_8>1) & !mi(q902_8)
*</_motorcycle_>

*</_ed_mod_age_>
gen ed_mod_age=6
*</_ed_mod_age_>

*</_everattend_>
clonevar everattend=q214
*</_everattend_>

*</_national poverty_>
clonevar pline_nat=pline 
clonevar pline_natfood=fline 
clonevar poor_nat=poor 
clonevar poor_natfood=fpoor 
clonevar welfarenat=pcexall_adj   
clonevar welfarenatfood=pcexf_adj   
*</_national poverty_>
 
*</_merge_GMD_>
tempfile extraSARMD
save `extraSARMD', replace
use "${output}/`harmfolder'_GMD.dta", clear
clonevar idh=hhid
clonevar idh_org=hhid_orig
clonevar idp=pid 
clonevar idp_org=pid_orig 
rename fridge refrigerator 
rename tv television
rename washmach washingmachine
rename bcycle bicycle
rename school atschool
rename sewmach sewingmachine
rename industrycat10 industry
rename industrycat10_2 industry_2
rename piped piped_water
rename minlaborage lb_mod_age
rename t_wage_total_aux wage

merge 1:1 hhid pid using `extraSARMD', nogen

*</_merge_GMD_>
*<_Keep variables_>
*no in this data: buffalo chicken cow lamp motorcar lphone sar_improved_water sar_improved_toilet  toilet_jmp rbirth_juris rbirth rprevious_juris rprevious yrmove
local sarmdvar10 "idh idh_org idp idp_org wgt age educat7 educat4 urban male soc typehouse ownhouse sewage_toilet water_jmp toilet_orig water_orig  bicycle motorcycle   refrigerator sewingmachine television washingmachine soc atschool ed_mod_age everattend  water_orig water_jmp piped_water  sewage_toilet  toilet_orig industry industry_orig lb_mod_age wage industry_2 industry_orig_2  pline_nat poor_nat welfarenat electricity imp_wat_rec imp_san_rec" 
local sarmdvar20 "cellphone_i"
foreach var of local sarmdvar10 {
cap gen `var'==.
}
keep countrycode year hhid pid weight weighttype `sarmdvar10' `sarmdvar20' pline_natfood welfarenatfood poor_natfood
gen code=countrycode
order countrycode year hhid pid weight weighttype `sarmdvar10' `sarmdvar20'
sort hhid pid 
*</_Keep variables_>

*<_Save data file_>
compress
if ("`c(username)'"=="dekopon") save "${output}/`filename'", replace
else save "${output}/`filename'.dta" , replace
*</_Save data file_>





exit

