/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   AFG_2019_LCS_v01_M_v01_A_GMD_SARMD.do	</_Program name_>
<_Application_>    STATA 16.0	<_Application_>
<_Author(s)_>      jogreen@worldbank.org	</_Author(s)_>
<_Date created_>   05-25-2020	</_Date created_>
<_Modified by>     acastillocastill@worldbank.org	</_Date modified_>
<_Date modified>   06-30-2023	</_Date modified_>
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
cap log close 

local code         "AFG"
local year         "2019"
local survey       "LCS"
local vm           "01"
local va           "02"
local type         "SARMD"
local yearfolder   "`code'_`year'_`survey'"
local harmfolder    "`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'"
local filename      "`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'_IND"
	glo output "${rootdatalib}\\`code'\\`yearfolder'\\`harmfolder'\Data\Harmonized"
*</_Program setup_>

	log using "${rootdatalib}\\`code'\\`code'_`year'_`survey'\\`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD\Doc\Technical\\`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD.log", replace 
	
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

	*</_Folder creation_>
	
	*<_Datalibweb request_>
	use "${rootdatalib}\\`code'\\`code'_`year'_`survey'\\`code'_`year'_`survey'_v`vm'_M\Data\Stata\\`code'_`year'_`survey'_M.dta", clear 
	
	preserve 
	local dlw "dlw,  country(`code') year(`year') type(SARRAW) surveyid(`code'_`year'_`survey'_v`vm'_M) localpath(${rootdatalib}) local"
	local dlw "datalibweb, country(`code') year(`year') type(SARRAW) surveyid(`code'_`year'_`survey'_v`vm'_M)"
	`dlw' filename(household_male.dta)
	rename HH_ID hhid_orig
	tempfile individual_level_data
	save     `individual_level_data'	//NOTE: The poverty data is actually HH-level data, but will be merged into individual-level data in the next step.
	restore 
	
	merge m:1 hhid_orig using `individual_level_data', gen(m_household)
	
	preserve
	local dlw "datalibweb, country(`code') year(`year') type(SARRAW) surveyid(`code'_`year'_`survey'_v`vm'_M)"
	`dlw' filename(labour_male.dta)
	rename HH_ID hhid_orig
	tempfile labour_male
	save    `labour_male'
	restore 
	merge 1:1 hhid_orig Mem_ID using `labour_male', nogen
	
	*</_Datalibweb request_>
}


*<_countrycode_>
*<_countrycode_note_> country code *</_countrycode_note_>
*<_countrycode_note_> countrycode brought in from rawdata *</_countrycode_note_>
g countrycode = "`code'"
*</_countrycode_>

*<_countrycode_>
*<_countrycode_note_> country code *</_countrycode_note_>
*<_countrycode_note_> countrycode brought in from rawdata *</_countrycode_note_>
g code = "`code'"
*</_countrycode_>

gen survey="`survey'"


*<_veralt_>
*<_veralt_note_> Version number of adaptation to the master data file *</_veralt_note_>
*<_veralt_note_> veralt brought in from rawdata *</_veralt_note_>
gen veralt="`va'"
*</_veralt_>

*<_vermast_>
*<_vermast_note_> Version number of master data file *</_vermast_note_>
*<_vermast_note_> vermast brought in from rawdata *</_vermast_note_>
gen vermast="`vm'"
*</_vermast_>


*<_psu_>
*<_psu_note_> PSU *</_psu_note_>
*<_psu_note_> psu brought in from rawdata *</_psu_note_>
g psu = cluster_code
*</_psu_>

*<_strata_>
*<_strata_note_> Strata *</_strata_note_>
*<_strata_note_> strata brought in from rawdata *</_strata_note_>
g strata = province
*</_strata_>

*<_year_>
*<_year_note_> Year *</_year_note_>
*<_year_note_> year brought in from rawdata *</_year_note_>
g year = `year'
*</_year_>

*<_int_month_>
*<_int_month_note_> interview month *</_int_month_note_>
*<_int_month_note_> int_month brought in from rawdata *</_int_month_note_>
g		int_month = 1 if yy==99 & ((mm==4 & inrange(dd,11,.)) | (mm==5 & inrange(dd,1,11)))
replace	int_month = 2 if yy==99 & ((mm==5 & inrange(dd,12,.)) | (mm==6 & inrange(dd,1,10)))
replace	int_month = 3 if (yy==99 & mm==6 & inrange(dd,10,.)) | (yy==98 & mm==7 & inrange(dd,1,11))
replace	int_month = 4 if yy==98 & ((mm==7 & inrange(dd,12,.)) | (mm==8 & inrange(dd,1,10)))
replace	int_month = 5 if yy==98 & ((mm==8 & inrange(dd,11,.)) | (mm==9 & inrange(dd,1,10)))
replace	int_month = 6 if yy==98 & ((mm==9 & inrange(dd,11,.)) | (mm==10 & inrange(dd,1,9)))
replace	int_month = 7 if yy==98 & ((mm==10 & inrange(dd,10,.)) | (mm==11 & inrange(dd,1,9)))
replace	int_month = 8 if yy==98 & ((mm==11 & inrange(dd,10,.)) | (mm==12 & inrange(dd,1,9)))
replace	int_month = 9 if (yy==98 & mm==12 & inrange(dd,10,.)) | (yy==99 & mm==1 & inrange(dd,1,8))
replace	int_month = 10 if yy==99 & ((mm==1 & inrange(dd,9,.)) | (mm==2 & inrange(dd,1,9)))
replace	int_month = 11 if yy==99 & ((mm==2 & inrange(dd,10,.)) | (mm==3 & inrange(dd,1,9)))
replace	int_month = 12 if yy==99 & ((mm==3 & inrange(dd,10,.)) | (mm==4 & inrange(dd,1,10)))
note int_month: The data uses the Solar Hijri calendar. The survey dates convert to 2020 and 2021 in the Gregorian calendar, with 17/4/1399 being January 1, 2021.
*</_int_month_>

*<_int_year_>
*<_int_year_note_> interview year *</_int_year_note_>
*<_int_year_note_> int_year brought in from rawdata *</_int_year_note_>
g		int_year = 2020 if yy==98 | (yy==99 & inrange(mm,1,3)) | (yy==99 & mm==4 & inrange(dd,1,16))
recode	int_year (.=2021) if ~missing(yy)
note int_year: The data uses the Solar Hijri calendar. The survey dates convert to 2020 and 2021 in the Gregorian calendar, with 17/4/1399 being January 1, 2021.
*</_int_year_>

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
clonevar finalweight = hh_weight
*</_weight_>

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

*<_urban_>
*<_urban_note_> Urban (1) or rural (0) *</_urban_note_>
*<_urban_note_> urban brought in from rawdata *</_urban_note_>
gen urban = (q15==1) if inlist(q15,1,2,3)
notes urban: `code' `year': Kuchi replaced as rural
*</_urban_>

*<_hsize_>
*<_hsize_note_> Household size *</_hsize_note_>
*<_hsize_note_> hsize brought in from rawdata *</_hsize_note_>
g hsize = hhsize
*</_hsize_>

*<_pop_wgt_>
gen pop_wgt=wgt*hsize
*</_pop_wgt_>


*<_subnatid1_>
*<_subnatid1_note_> Subnational ID - highest level *</_subnatid1_note_>
*<_subnatid1_note_> subnatid1 brought in from rawdata *</_subnatid1_note_>
recode province (6=10)	(7=12)	(8=33)	(9=16)	(10=32)	(11=6)	(12=7)	(13=8)	(14=9)	(15=11)	(16=13)	(17=14)	(18=15)	(19=17)	(20=18)	(21=19)	(22=21)	(23=31)	(24=34)	(25=30)	(26=29)	(27=28)	(28=20)	(29=22)	(30=27)	(31=23)	(32=24)	(33=25)	(34=26), gen(subnatid1)
la de lblsubnatid1 1 "Kabul" 2 "Kapisa" 3 "Parwan" 4 "Wardak" 5 "Logar" 6 "Ghazni" 7 "Paktika" 8 "Paktya" 9 "Khost" 10 "Nangarhar" 11 "Kunarha" 12 "Laghman" 13 "Nuristan" 14 "Badakhshan" 15 "Takhar" 16 "Baghlan" 17 "Kunduz" 18 "Samangan" 19 "Balkh" 20 "Jawzjan" 21 "Sar-I-Poul" 22 "Faryab" 23 "Badghis" 24 "Hirat" 25 "Farah" 26 "Nimroz" 27 "Helmand" 28 "Kandahar" 29 "Zabul" 30 "Uruzgan" 31 "Ghor" 32 "Bamyan" 33 "Panjsher" 34 "Daikindi"
label values subnatid1 lblsubnatid1
numlabel lblsubnatid1, add mask("# - ")
decode subnatid1, gen(subnatid1_temp)
drop subnatid1
rename subnatid1_temp subnatid1
*</_subnatid1_>

*<_subnatid2_>
*<_subnatid2_note_> Subnational ID - second highest level *</_subnatid2_note_>
*<_subnatid2_note_> subnatid2 brought in from rawdata *</_subnatid2_note_>
numlabel L_q12, add mask("# - ")
decode q12, g(subnatid2)
*</_subnatid2_>

*<_subnatid3_>
*<_subnatid3_note_> Subnational ID - third highest level *</_subnatid3_note_>
*<_subnatid3_note_> subnatid3 brought in from rawdata *</_subnatid3_note_>
gen subnatid3=.
note subnatid3: The data is not representative below the subnatid2 level.
*</_subnatid3_>

*<_subnatidsurvey_>
*<_subnatidsurvey_note_> Survey representation of geographical units *</_subnatidsurvey_note_>
*<_subnatidsurvey_note_> subnatidsurvey brought in from rawdata *</_subnatidsurvey_note_>
gen subnatidsurvey=.
*</_subnatidsurvey_>

*<_soc_>
*<_soc_note_> Social group *</_soc_note_>
*<_soc_note_> soc brought in from rawdata *</_soc_note_>
gen soc=.
*</_soc_>

*<_marital_>
*<_marital_note_> Marital status *</_marital_note_>
*<_marital_note_> marital brought in from rawdata *</_marital_note_>
recode q204 (1=1) (2=4) (3=5) (4/5=2) (*=.), g(marital)
*</_marital_>

*<_male_>
*<_male_note_> Sex of household member (male=1) *</_male_note_>
*<_male_note_> male brought in from rawdata *</_male_note_>
g male = (q203==1) if inlist(q203,1,2)
*</_male_>

*<_relationharm_>
*<_relationharm_note_> Relationship to head of household harmonized across all regions *</_relationharm_note_>
*<_relationharm_note_> relationharm brought in from rawdata *</_relationharm_note_>
recode q201r (1=1) (2=2) (3=3) (4/5 7/10=5) (6=4) (11=6) (*=.), g(relationharm)
*</_relationharm_>

*<_relationcs_>
*<_relationcs_note_> Original relationship to head of household *</_relationcs_note_>
*<_relationcs_note_> relationcs brought in from rawdata *</_relationcs_note_>
clonevar relationcs = q201r
*</_relationcs_>

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

*<_tv_>
*<_tv_note_> Ownership of a tv *</_tv_note_>
*<_tv_note_> tv brought in from rawdata *</_tv_note_>
g television = (inlist(q902_2,1,2,3)) if inrange(q902_2,0,3)
*</_tv_>

*<_bcycle_>
*<_bcycle_note_> Ownership of a bicycle *</_bcycle_note_>
*<_bcycle_note_> bcycle brought in from rawdata *</_bcycle_note_>
g bicycle = (q908k==1) if inlist(q908k,1,2)
*</_bcycle_>

*<_washmach_>
*<_washmach_note_> Ownership of a washing machine *</_washmach_note_>
*<_washmach_note_> washmach brought in from rawdata *</_washmach_note_>
g washingmachine = (q908a==1) if inlist(q908a,1,2)
*</_washmach_>

*<_computer_>
*<_computer_note_> Ownership of a computer *</_computer_note_>
*<_computer_note_> computer brought in from rawdata *</_computer_note_>
g computer = (inlist(q902_3,1,2,3)) if inrange(q902_3,0,3)
*</_computer_>

*<_fridge_>
*<_fridge_note_> Ownership of a refrigerator *</_fridge_note_>
*<_fridge_note_> fridge brought in from rawdata *</_fridge_note_>
g refrigerator = (inlist(q902_1,1,2,3)) if inrange(q902_1,0,3)
*</_fridge_>

*<_sewmach_>
*<_sewmach_note_> Ownership of a sewing machine *</_sewmach_note_>
*<_sewmach_note_> sewmach brought in from rawdata *</_sewmach_note_>
g sewingmachine = (inlist(q902_6,1,2,3)) if inrange(q902_6,0,3)
*</_sewmach_>

*<_radio_>
*<_radio_note_> Ownership of a radio *</_radio_note_>
*<_radio_note_> radio brought in from rawdata *</_radio_note_>
g radio = (q908h==1) if inlist(q908h,1,2)
*</_radio_>

*<_internet_>
*<_internet_note_> Ownership of a  internet *</_internet_note_>
*<_internet_note_> internet brought in from rawdata *</_internet_note_>
gen internet=.
note internet: AFG 2019 does not have any relevant questions or variables.
*</_internet_>

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

*<_improved_sanitation_>
*<_improved_sanitation_note_> Improved sanitation facility recommended estimate (not considering sharing) *</_improved_sanitation_note_>
*<_improved_sanitation_note_> improved_sanitation brought in from rawdata *</_improved_sanitation_note_>
*g		improved_sanitation = (inrange(q619,1,8)) if inrange(q619,1,11)
*replace improved_sanitation = 0 if q620==1
cap drop improved_sanitation
g		improved_sanitation = .
replace improved_sanitation = 1 if inlist(q619,1,3,4,5,6,8,9)
replace improved_sanitation = 0 if inlist(q619,2,7,10,11)
replace improved_sanitation = 0 if q620==1
notes improved_sanitation: `code' `year' improved_sanitation is classified as unimproved if the facility is shared.
*</_improved_sanitation_>

clonevar sar_improved_toilet=improved_sanitation

*<_imp_wat_rec_>
*<_imp_wat_rec_note_> Improved water recommended estimate *</_imp_wat_rec_note_>
*<_imp_wat_rec_note_> imp_wat_rec brought in from rawdata *</_imp_wat_rec_note_>
g improved_water = (inlist(q616,1,2,3,4,5,7,10)) if inrange(q616,1,11)
*</_imp_wat_rec_>

clonevar sar_improved_water=improved_water

*<_piped _>
*<_piped _note_> Access to piped water  *</_piped _note_>
*<_piped _note_> piped  brought in from rawdata *</_piped _note_>
gen piped_water = (inrange(q616,1,3)) if inrange(q616,1,11)
*</_piped _>


*<_cellphone_i_>
*<_cellphone_i_note_> Ownership of a cell phone (individual) *</_cellphone_i_note_>
*<_cellphone_i_note_> cellphone_i brought in from rawdata *</_cellphone_i_note_>
gen cellphone_i=.
note cellphone_i: AFG 2019 asks about cell phone ownership at the HH-level only.
*</_cellphone_i_>

*</_motorcycle_>
gen motorcycle=(q902_8>1) & !mi(q902_8)
*</_motorcycle_>

*<_fan_>
*<_fan_note_> Ownership of an electric fan *</_fan_note_>
*<_fan_note_> fan brought in from rawdata *</_fan_note_>
g fan = (q908g==1) if inlist(q908g,1,2)
*</_fan_>

*</_electricity_>;
*electricity any source
egen electricity_all=rmin(q611a q611b q611c q611d q611e q611f q611g q611h)
recode electricity_all (2=0)
* electrecity public connection
egen electricity=rmin(q611a q611b)
recode electricity (2=0)
replace electricity=0 if mi(electricity) & !mi(electricity_all)
note electricity: electricity from public source electric grid or government generator
*</_electricity_>;

*<_electricity_other_>
*electricity by source
recode q611a (2=0), gen(elect_grid)
recode q611b (2=0), gen(elect_govgen)
egen elect_engine=rmin(q611c q611e)
recode elect_engine (2=0)
egen elect_hidro=rmin(q611d q611f)
recode elect_hidro (2=0)
recode q611g (2=0), gen(elect_solar)
recode q611h (2=0), gen(elect_wind) 
*</_electricity_other>

*</_ed_mod_age_>
gen ed_mod_age=6
*</_ed_mod_age_>

*</_everattend_>
clonevar everattend=q214
*</_everattend_>

*<_literacy_>
*<_literacy_note_> Individual can read and write *</_literacy_note_>
*<_literacy_note_> literacy brought in from rawdata *</_literacy_note_>
g literacy = (q213==1) if inlist(q213,1,2)
*</_literacy_>

*<_school_>
*<_school_note_> Currently enrolled in or attending school *</_school_note_>
*<_school_note_> school brought in from rawdata *</_school_note_>
gen byte atschool= q217
	recode atschool (2=0)
	replace atschool=0 if q214==2
	replace atschool = . if age < 6
	replace atschool = . if age > 24
*gen school = (q217==1) if inlist(q217,1,2)
*</_school_>

*<_educy_>
*<_educy_note_> Years of completed education *</_educy_note_>
*<_educy_note_> educy brought in from rawdata *</_educy_note_>
g educy = q215g
replace educy=. if educy>=age
*</_educy_>


*<_educat7_>
*<_educat7_note_> Highest level of education completed (7 categories) *</_educat7_note_>
*<_educat7_note_> educat7 brought in from rawdata *</_educat7_note_>
gen		educat7 = 1 if q214==2
replace	educat7 = 1 if q215g==0 & q215g==1
replace	educat7 = 2 if q215e==1 & inrange(q215g,1,5)
replace	educat7 = 3 if q215e==1 & q215g==6
replace	educat7 = 4 if q215e==2 | (q215e==3 & inrange(q215g,10,11))
replace	educat7 = 5 if q215e==3 & q215g==12
replace	educat7 = 6 if inlist(q215e,4,5)
replace	educat7 = 7 if inlist(q215e,6,7)
replace educat7 = .z if q215e==8
* impose survey-specific age limits
replace educat7 = .0 if age<6
note educat7: `code' `year' variable q215e "level completed" = 8 "Islamic school" not categorized, given special missing value (.z).
note educat7: `code' `year' under 6 years old, given special missing value (.0).

*</_educat7_>

*<_educat5_>
*<_educat5_note_> Highest level of education completed (5 categories) *</_educat5_note_>
*<_educat5_note_> educat5 brought in from rawdata *</_educat5_note_>
recode educat7 (4=3) (5=4) (6 7=5), gen(educat5)
*</_educat5_>

*<_educat4_>
*<_educat4_note_> Highest level of education completed (4 categories) *</_educat4_note_>
*<_educat4_note_> educat4 brought in from rawdata *</_educat4_note_>
recode educat7 (3=2) (4 5=3) (6 7=4), gen(educat4)
*</_educat4_>

*<_lb_mod_age_>
*<_lb_mod_age_note_> Labor module application age *</_lb_mod_age_note_>
*<_lb_mod_age_note_> lb_mod_age brought in from rawdata *</_lb_mod_age_note_>
g lb_mod_age = 14
*</_lb_mod_age_>

*<_lstatus_>
*<_lstatus_note_> Labor status *</_lstatus_note_>
*<_lstatus_note_> lstatus brought in from rawdata *</_lstatus_note_>
g		lstatus = 1	if q304==1 | q305==1 | q306==1 | q307==1	 //2 Employed if working
replace	lstatus = 1 if q309==1	//2 Employed if they did any activity, even for 1 hour
replace	lstatus = 1 if q310==1	//2 Employed if temporarily absent
replace	lstatus = 1 if inlist(q314,6,7,9)	//2 Employed if an apprentice, in miliary service, or temporarily laid off
replace	lstatus = 3 if inlist(q314,1,2,3,5,11,13,14)	//3 Not in labor force if student, housekeeper, retired/too old, handicapped, did not want to work, family does not allow, other
recode	lstatus (.=2) if (q304==2 | q305==2 | q306==2 | q307==2) & (q312==1 | q313==1 | inlist(q314,4,8,10,12))
*2-Unemployed= (Did not did an activity last week) AND (seek job last four weeks OR if did not seek a job is not because they are out of the labor market)
recode lstatus (.=3) if  age>=lb_mod_age
*</_lstatus_>

*<_nlfreason_>
*<_nlfreason_note_> Reason not in the labor force *</_nlfreason_note_>
*<_nlfreason_note_> nlfreason brought in from rawdata *</_nlfreason_note_>
g		nlfreason = 1 if q314==1	//1= Student (a person currently studying.)
replace	nlfreason = 2 if q314==2	//2= Housewife (a person who takes care of the house, older people, or children)
replace nlfreason = 3 if q314==3	//3= Retired
replace nlfreason = 4 if q314==5	//4 = Disabled (a person who cannot work due to physical conditions)
recode nlfreason (.=5) if lstatus==3	//5 = Other (a person does not work for any other reason)
replace nlfreason = . if lstatus~=3
*</_nlfreason_>

*<_empstat_>
*<_empstat_note_> Employment status *</_empstat_note_>
*<_empstat_note_> empstat brought in from rawdata *</_empstat_note_>
recode q316 (1/3=1) (4=4) (5=3) (6=2) (*=.), g(empstat)
replace empstat = . if lstatus~=1
*</_empstat_>

*<_empstat_2_>
*<_empstat_2_note_> Employment status - second job *</_empstat_2_note_>
*<_empstat_2_note_> empstat_2 brought in from rawdata *</_empstat_2_note_>
recode q322b (1/3=1) (4=4) (5=3) (6=2) (*=.), g(empstat_2)
replace empstat_2 = . if lstatus~=1
*</_empstat_2_>

*<_empstat_year_>
*<_empstat_year_note_> Employment status, primary job (12-mon ref period) *</_empstat_year_note_>
*<_empstat_year_note_> empstat_year brought in from rawdata *</_empstat_year_note_>
gen empstat_year=.
note empstat_year: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_empstat_year_>

*<_empstat_2_year_>
*<_empstat_2_year_note_> Employment status - second job (12-mon ref period) *</_empstat_2_year_note_>
*<_empstat_2_year_note_> empstat_2_year brought in from rawdata *</_empstat_2_year_note_>
gen empstat_2_year=.
note empstat_2_year: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_empstat_2_year_>

*<_industry_orig_>
*<_industry_orig_note_> original industry codes *</_industry_orig_note_>
*<_industry_orig_note_> industry_orig brought in from rawdata *</_industry_orig_note_>
gen industrycat10 = substr(q319,1,1)
destring industrycat10, replace
recode industrycat10 (0=10)
replace industrycat10 = . if lstatus~=1
clonevar industry = industrycat10
*</_industry_orig_>

*<_industry_orig_>
*<_industry_orig_note_> original industry codes *</_industry_orig_note_>
*<_industry_orig_note_> industry_orig brought in from rawdata *</_industry_orig_note_>
g industrycat10_2 = substr(q322e,1,1)
destring industrycat10_2, replace
recode industrycat10_2 (0=10)
replace industrycat10_2 = . if lstatus~=1
clonevar industry_2=industrycat10_2
*</_industry_orig_>

*<_industry_orig_>
*<_industry_orig_note_> original industry codes *</_industry_orig_note_>
*<_industry_orig_note_> industry_orig brought in from rawdata *</_industry_orig_note_>
clonevar industry_orig = q319
*</_industry_orig_>

*<_industry_orig_2_>
*<_industry_orig_2_note_> original industry codes for second job *</_industry_orig_2_note_>
*<_industry_orig_2_note_> industry_orig_2 brought in from rawdata *</_industry_orig_2_note_>
clonevar industry_orig_2 = q322e
*</_industry_orig_2_>

*<_socialsec_>
*<_socialsec_note_> Social security *</_socialsec_note_>
*<_socialsec_note_> socialsec brought in from rawdata *</_socialsec_note_>
gen socialsec=.
note socialsec: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_socialsec_>

*<_njobs_>
*<_njobs_note_> Total number of jobs *</_njobs_note_>
*<_njobs_note_> njobs brought in from rawdata *</_njobs_note_>
gen njobs=.
note njobs: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_njobs_>

*<_occup_orig_>
*<_occup_orig_note_> original occupation code *</_occup_orig_note_>
*<_occup_orig_note_> occup_orig brought in from rawdata *</_occup_orig_note_>
gen occup = substr(q320,1,1)
destring occup, replace
recode occup (0=10)
replace occup = . if lstatus~=1
*</_occup_orig_>

*<_occup_2_>
*<_occup_2_note_> 1 digit occupational classification for second job *</_occup_2_note_>
*<_occup_2_note_> occup_2 brought in from rawdata *</_occup_2_note_>
gen occup_2 = substr(q322f,1,1)
destring occup_2, replace
recode occup_2 (0=10)
replace occup_2 = . if lstatus~=1
*</_occup_2_>

*<_ocusec_year_>
*<_ocusec_year_note_> Sector of activity, primary job (12-mon ref period) *</_ocusec_year_note_>
*<_ocusec_year_note_> ocusec_year brought in from rawdata *</_ocusec_year_note_>
gen ocusec_year=.
note ocusec_year: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_ocusec_year_>

*<_occup_orig_year_>
*<_occup_orig_year_note_> Original occupational classification, primary job (12-mon ref period) *</_occup_orig_year_note_>
*<_occup_orig_year_note_> occup_orig_year brought in from rawdata *</_occup_orig_year_note_>
gen occup_orig_year=.
note occup_orig_year: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_occup_orig_year_>

*<_occup_year_>
*<_occup_year_note_> 1 digit occupational classification, primary job (12-mon ref period) *</_occup_year_note_>
*<_occup_year_note_> occup_year brought in from rawdata *</_occup_year_note_>
gen occup_year=.
note occup_year: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_occup_year_>


*<_contract_>
*<_contract_note_> Contract *</_contract_note_>
*<_contract_note_> contract brought in from rawdata *</_contract_note_>
gen contract=.
note contract: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_contract_>

*<_firmsize_l_>
*<_firmsize_l_note_> Firm size (lower bracket) *</_firmsize_l_note_>
*<_firmsize_l_note_> firmsize_l brought in from rawdata *</_firmsize_l_note_>
gen firmsize_l=.
note firmsize_l: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_firmsize_l_>

*<_firmsize_u_>
*<_firmsize_u_note_> Firm size (upper bracket) *</_firmsize_u_note_>
*<_firmsize_u_note_> firmsize_u brought in from rawdata *</_firmsize_u_note_>
gen firmsize_u=.
note firmsize_u: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_firmsize_u_>

*<_healthins_>
*<_healthins_note_> Health insurance *</_healthins_note_>
*<_healthins_note_> healthins brought in from rawdata *</_healthins_note_>
gen healthins=.
note healthins: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_healthins_>

*<_unempldur_l_>
*<_unempldur_l_note_> Unemployment duration (months) lower bracket *</_unempldur_l_note_>
*<_unempldur_l_note_> unempldur_l brought in from rawdata *</_unempldur_l_note_>
gen unempldur_l=.
note unempldur_l: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_unempldur_l_>

*<_unempldur_u_>
*<_unempldur_u_note_> Unemployment duration (months) upper bracket *</_unempldur_u_note_>
*<_unempldur_u_note_> unempldur_u brought in from rawdata *</_unempldur_u_note_>
gen unempldur_u=.
note unempldur_u: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_unempldur_u_>

*<_union_>
*<_union_note_> Union membership *</_union_note_>
*<_union_note_> union brought in from rawdata *</_union_note_>
gen union=.
note union: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_union_>

*<_unitwage_>
*<_unitwage_note_> Last wages time unit *</_unitwage_note_>
*<_unitwage_note_> unitwage brought in from rawdata *</_unitwage_note_>
gen unitwage=.
note unitwage: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_unitwage_>

*<_unitwage_2_>
*<_unitwage_2_note_> Last wages time unit second job *</_unitwage_2_note_>
*<_unitwage_2_note_> unitwage_2 brought in from rawdata *</_unitwage_2_note_>
gen unitwage_2=.
note unitwage_2: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_unitwage_2_>

*<_whours_>
*<_whours_note_> Hours of work in last week *</_whours_note_>
*<_whours_note_> whours brought in from rawdata *</_whours_note_>
gen whours= q317*q318
replace whours = . if lstatus~=1
*</_whours_>

	** CPI VARIABLE //proposal 
		*ren cpi${year}_w cpi
		gen cpi=.
		la var cpi "CPI (Base ${cpiyear}=1)"
	*</_cpi_>
		
		
	** PPP VARIABLE //proposal 
	*<_ppp_>
		*ren ppp${year}	ppp
		gen ppp=.
		la var ppp "PPP ${cpiyear}"
	*</_ppp_>

		 
	** CPI PERIOD //proposal 
	*<_cpiperiod_>
		*gen cpiperiod=syear
		gen cpiperiod=.
		la var cpiperiod "Periodicity of CPI (year, year&month, year&quarter, weighted)"
	*</_cpiperiod_>	


*<_welfare_>
*<_welfare_note_> Welfare aggregate used for estimating international poverty (provided to PovcalNet) *</_welfare_note_>
*<_welfare_note_> welfare brought in from rawdata *</_welfare_note_>
g welfare = pcexall_adj
*</_welfare_>


*<_welfaredef_>
*<_welfaredef_note_> Welfare aggregate spatially deflated *</_welfaredef_note_>
*<_welfaredef_note_> welfaredef brought in from rawdata *</_welfaredef_note_>
gen welfaredef = pcexall_adj
*</_welfaredef_>

*<_welfarenom_>
*<_welfarenom_note_> Welfare aggregate in nominal terms *</_welfarenom_note_>
*<_welfarenom_note_> welfarenom brought in from rawdata *</_welfarenom_note_>
egen hexnom = rowtotal(hexnom_f hexnom_n hexnom_d hexnom_r), missing
gen welfarenom = hexnom/hh_size
*</_welfarenom_>

*<_welfareother_>
*<_welfareother_note_> Welfare aggregate if different welfare type is used from welfare, welfarenom, welfaredef *</_welfareother_note_>
*<_welfareother_note_> welfareother brought in from rawdata *</_welfareother_note_>
gen welfareother = pcexf_adj
*</_welfareother_>

*<_welfareothertype_>
*<_welfareothertype_note_> Type of welfare measure (income, consumption or expenditure) for welfareother *</_welfareothertype_note_>
*<_welfareothertype_note_> welfareothertype brought in from rawdata *</_welfareothertype_note_>
gen welfareothertype="FOOD"
*</_welfareothertype_>

*<_welfaretype_>
*<_welfaretype_note_> Type of welfare measure (income, consumption or expenditure) for welfare, welfarenom, welfaredef *</_welfaretype_note_>
*<_welfaretype_note_> welfaretype brought in from rawdata *</_welfaretype_note_>
gen welfaretype = "CON"
*</_welfaretype_>

*<_welfshprosperity_>
*<_welfshprosperity_note_> Welfare aggregate for shared prosperity (if different from poverty) *</_welfshprosperity_note_>
*<_welfshprosperity_note_> welfshprosperity brought in from rawdata *</_welfshprosperity_note_>
gen welfshprosperity=.
*</_welfshprosperity_>

*<_welfshprtype_>
*<_welfshprtype_note_> Welfare type for shared prosperity indicator (income, consumption or expenditure) *</_welfshprtype_note_>
*<_welfshprtype_note_> welfshprtype brought in from rawdata *</_welfshprtype_note_>
gen welfshprtype=.
*</_welfshprtype_>

*<_spdef_>
*<_spdef_note_> Spatial deflator (if one is used) *</_spdef_note_>
*<_spdef_note_> spdef brought in from rawdata *</_spdef_note_>
gen spdef=Laspeyres_z
*</_spdef_>

*<_tetempmpdef_>
*<_tempdef_note_> Temporal deflator (if one is used) *</_spdef_note_>
*<_def_note_> base is 1st Q *</_spdef_note_>
gen tempdef=adj_fact_nf
*</_tempdef_>

*<_quintile_cons_aggregate_>
*<_quintile_cons_aggregate_note_> Quintile of welfarenat *</_quintile_cons_aggregate_note_>
/*<_quintile_cons_aggregate_note_>  *</_quintile_cons_aggregate_note_>*/
*<_quintile_cons_aggregate_note_>  *</_quintile_cons_aggregate_note_>
*gen quintile_cons_aggregate = .a //change
_ebin welfare [aw=weight], gen(quintile_cons_aggregate) nq(5) 
*</_quintile_cons_aggregate_>

*<_food_share_>
*<_food_share_note_> Food share *</_food_share_note_>
/*<_food_share_note_>  *</_food_share_note_>*/
*<_food_share_note_>  *</_food_share_note_>
gen food_share = (hexnom_f/hexnom)*100
*</_food_share_>

*<_nfood_share_>
*<_nfood_share_note_> Non-food share *</_nfood_share_note_>
/*<_nfood_share_note_>  *</_nfood_share_note_>*/
*<_nfood_share_note_>  *</_nfood_share_note_>
*gen nfood_share = .a //change
gen nfood_share =  (hexnom_n/hexnom)*100 //proposal 
*</_nfood_share_>

*<_pline_int_>
*<_pline_int_note_>  Poverty line Povcalnet. *</_pline_int_note_>
/*<_pline_int_note_> Poverty line constructed based on international comparison program standards (ICP). *</_pline_int_note_>*/
*<_pline_int_note_>  *</_pline_int_note_>
*gen pline_int = .a //change
gen pline_int=. //proposal 
*</_pline_int_>

*<_poor_int_>
*<_poor_int_note_>  People below Poverty Line (International). *</_poor_int_note_>
/*<_poor_int_note_> People below poverty line based on PovCalnet methodology. May not be equal to standard country definition. *</_poor_int_note_>*/
*<_poor_int_note_>  *</_poor_int_note_>
*gen poor_int = .a //change 
gen poor_int = welfare<pline_int if welfare!=. //proposal
*</_poor_int_>

notes: no available in this data: buffalo chicken cow lamp motorcar lphone toilet_jmp rbirth_juris rbirth rprevious_juris rprevious yrmove wage_2
local var_notfound "buffalo chicken cow lamp motorcar lphone toilet_jmp rbirth_juris rbirth rprevious_juris rprevious yrmove wage_2"
foreach v of local var_notfound  {
	gen `v'=.
}

*</_national poverty_>
clonevar pline_nat=pline 
clonevar pline_natfood=fline 
clonevar poor_nat=poor 
clonevar poor_natfood=fpoor 
clonevar welfarenat=pcexall_adj   
clonevar welfarenatfood=pcexf_adj   
*</_national poverty_>
 
/*
*</_merge_GMD_>
tempfile extraSARMD
save `extraSARMD', replace
use "${output}/`harmfolder'_GMD.dta", clear
clonevar idh=hhid
clonevar idh_org=hhid_orig
clonevar idp=pid 
clonevar idp_org=pid_orig 
rename t_wage_total_aux wage
merge 1:1 hhid pid using `extraSARMD', nogen
*/

*</_merge_GMD_>

local sarmdvar10 "idh idh_org idp idp_org wgt age educat7 educat4 urban male soc typehouse ownhouse sewage_toilet water_jmp toilet_orig water_orig  bicycle motorcycle   refrigerator sewingmachine television washingmachine soc atschool ed_mod_age everattend  water_orig water_jmp piped_water  sewage_toilet  toilet_orig industry industry_orig lb_mod_age wage industry_2 industry_orig_2  pline_nat poor_nat welfarenat electricity imp_wat_rec improved_sanitation" 
local sarmdvar20 "cellphone_i"
foreach var of local sarmdvar10 {
*cap gen `var'==.
}

*<_Keep variables_>
global keepextra "electricity_all"
order  countrycode year hhid pid weight weighttype //change: variable countrycode, year, weight, weighttype weren't created before. So this gave an error. I will create them up in the do file. 
sort   hhid pid
*</_Keep variables_>

*<_Save data file_>
do   "P:\SARMD\SARDATABANK\SARMDdofiles\_aux\Labels_SARMD.do"
*do   "$rootdatalib\\`code'\\`yearfolder'\\`SARMDfolder'\Programs\Labels_SARMD.do"
save "$rootdatalib\\`code'\\`yearfolder'\\`harmfolder'\Data\Harmonized\\`filename'.dta" , replace
*</_Save data file_>

cap log close 
