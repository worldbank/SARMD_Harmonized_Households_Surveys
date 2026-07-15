/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   AFG_2019_LCS_v01_M_v01_A_GMD_DWL.do	</_Program name_>
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
File:	AFG_2019_LCS_v01_M_v01_A_GMD_DWL.do
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
local va           "02"
local type         "SARMD"
local yearfolder   "`code'_`year'_`survey'"
local harmfolder   "`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'"
local filename     "`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'_DWL"
glo output "${rootdatalib}\\`code'\\`yearfolder'\\`harmfolder'\Data\Harmonized"
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
	* disability data
	merge 1:1 HH_ID Mem_ID using "disability", nogen assert(match)
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
	use "$rootdatalib\\`code'\\`yearfolder'\\`harmfolder'\Data\Harmonized\\`yearfolder'_v`vm'_M_v`va'_A_SARMD_IND.dta", clear
	clonevar hhid_orig=idh_org
	clonevar Mem_ID   =pid 
	tempfile SARMDIND
	save     `SARMDIND'	
	restore 
	merge m:1 hhid_orig Mem_ID using `SARMDIND', gen(m_IND)
	
	* household data
	preserve
	local dlw "datalibweb, country(`code') year(`year') type(SARRAW) surveyid(`code'_`year'_`survey'_v`vm'_M)"
	qui `dlw' filename(household_male.dta)
	rename HH_ID hhid_orig
	tempfile household_male
	save     `household_male'	
	restore 
	merge m:1 hhid_orig using `household_male', gen(m_household_male)
	
	/*
	tempfile individual_level_data
	local dlw "datalibweb, country(`code') year(`year') type(SARRAW) surveyid(`code'_`year'_`survey'_v`vm'_M)"
	*`dlw' filename(temp_pov_2016_2019_consolidated.dta)
	use "${rootdatalib}\\`code'\\`code'_`year'_`survey'\\`code'_`year'_`survey'_v01_M\Data\Stata\temp_pov_2016_2019_consolidated.dta", clear 
	keep if year==`year'
	drop year
	rename hhid HH_ID
	save `individual_level_data'	//NOTE: The poverty data is actually HH-level data, but will be merged into individual-level data in the next step.
	
	* roster data
	* NOTE: some individuals do not have poverty data. 
	local dlw "datalibweb, country(`code') year(`year') type(SARRAW) surveyid(`code'_`year'_`survey'_v`vm'_M)"
	`dlw' filename(roster_male.dta)
	merge m:1 HH_ID using `individual_level_data', gen(m_pov_roster) 
	save `individual_level_data', replace
	
	* disability data
	local dlw "datalibweb, country(`code') year(`year') type(SARRAW) surveyid(`code'_`year'_`survey'_v`vm'_M)"
	`dlw' filename(disability.dta)
	merge 1:1 HH_ID Mem_ID using `individual_level_data', nogen 
	save `individual_level_data', replace
	
	* household data
	local dlw "datalibweb, country(`code') year(`year') type(SARRAW) surveyid(`code'_`year'_`survey'_v`vm'_M)"
	`dlw' filename(household_male.dta)
	merge 1:m HH_ID using `individual_level_data', nogen 
	rename HH_ID hhid_orig
	destring hhid_orig, g(HH_ID)	//note: need to fill in hhid if subsequent merged data contains umatched observations.
	save `individual_level_data', replace
	
	* weight data
	local dlw "datalibweb, country(`code') year(`year') type(SARRAW) surveyid(`code'_`year'_`survey'_v`vm'_M)"
	`dlw' filename(clusters.dta)
	merge 1:m HH_ID using `individual_level_data', nogen update replace
	**/
	*</_Datalibweb request_>
}

*<_countrycode_>
*<_countrycode_note_> country code *</_countrycode_note_>
*<_countrycode_note_> countrycode brought in from rawdata *</_countrycode_note_>
*clonevar countrycode = "`code'"
*</_countrycode_>

*<_year_>
*<_year_note_> Year *</_year_note_>
*<_year_note_> year brought in from rawdata *</_year_note_>
*clonevar year = `year'
*</_year_>

*<_hhid_>
*<_hhid_note_> Household identifier  *</_hhid_note_>
*<_hhid_note_> hhid brought in from rawdata *</_hhid_note_>
*clonevar hhid = hhid_orig
*</_hhid_>

*<_weight_>
*<_weight_note_> Household weight *</_weight_note_>
*<_weight_note_> weight brought in from rawdata *</_weight_note_>
clonevar weight = wgt
*</_weight_>

*<_weighttype_>
*<_weighttype_note_> Weight type (frequency, probability, analytical, importance) *</_weighttype_note_>
*<_weighttype_note_> weighttype brought in from rawdata *</_weighttype_note_>
*clonevar weighttype = "PW"
*</_weighttype_>

*<_landphone_>
*<_landphone_note_> Ownership of a land phone (household) *</_landphone_note_>
*<_landphone_note_> landphone brought in from rawdata *</_landphone_note_>
clonevar landphone=lphone
note landphone: AFG 2019 does not have any relevant questions or variables.
*</_landphone_>

*<_cellphone_>
*<_cellphone_note_> Ownership of a cell phone (household) *</_cellphone_note_>
*<_cellphone_note_> cellphone brought in from rawdata *</_cellphone_note_>
g cellphone = (q908l==1 | q908m==1) if inlist(q908l,1,2) | inlist(q908m,1,2)
g smartphone= (q908m==1) if inlist(q908m,1,2)
*</_cellphone_>

*<_phone_>
*<_phone_note_> Ownership of a telephone (household) *</_phone_note_>
*<_phone_note_> phone brought in from rawdata *</_phone_note_>
gen phone=.
note phone: AFG 2019 does distinguish between cell landlines and cell phones.
*</_phone_>

*<_computer_>
*<_computer_note_> Ownership of a computer *</_computer_note_>
*<_computer_note_> computer brought in from rawdata *</_computer_note_>
*clonevar computer = computer
*</_computer_>

*<_etablet_>
*<_etablet_note_> Ownership of a electronic tablet *</_etablet_note_>
*<_etablet_note_> etablet brought in from rawdata *</_etablet_note_>
g etablet = (inlist(q902_4,1,2,3)) if inrange(q902_4,0,3)
*</_etablet_>

*<_internet_>
*<_internet_note_> Ownership of a  internet *</_internet_note_>
*<_internet_note_> internet brought in from rawdata *</_internet_note_>
*clonevar internet=internet
note internet: AFG 2019 does not have any relevant questions or variables.
*</_internet_>

*<_internet_mobile_>
*<_internet_mobile_note_> Ownership of a  internet (mobile 2G 3G LTE 4G 5G ) *</_internet_mobile_note_>
*<_internet_mobile_note_> internet_mobile brought in from rawdata *</_internet_mobile_note_>
g internet_mobile =. 
*</_internet_mobile_>

*<_internet_mobile4G_>
*<_internet_mobile4G_note_> Ownership of a  internet (mobile LTE 4G 5G ) *</_internet_mobile4G_note_>
*<_internet_mobile4G_note_> internet_mobile4G brought in from rawdata *</_internet_mobile4G_note_>
gen internet_mobile4G=.
note internet_mobile4G: AFG 2019 does not have any relevant questions or variables.
*</_internet_mobile4G_>

*<_radio_>
*<_radio_note_> Ownership of a radio *</_radio_note_>
*<_radio_note_> radio brought in from rawdata *</_radio_note_>
*clonevar radio = radio 
*</_radio_>

*<_tv_>
*<_tv_note_> Ownership of a tv *</_tv_note_>
*<_tv_note_> tv brought in from rawdata *</_tv_note_>
clonevar tv = television
*</_tv_>

*<_tv_cable_>
*<_tv_cable_note_> Ownership of a cable tv *</_tv_cable_note_>
*<_tv_cable_note_> tv_cable brought in from rawdata *</_tv_cable_note_>
g tv_cable = (q908i==1) if inlist(q908i,1,2)
*</_tv_cable_>

*<_video_>
*<_video_note_> Ownership of a video *</_video_note_>
*<_video_note_> video brought in from rawdata *</_video_note_>
g video = (q908j==1) if inlist(q908j,1,2)
*</_video_>

*<_fridge_>
*<_fridge_note_> Ownership of a refrigerator *</_fridge_note_>
*<_fridge_note_> fridge brought in from rawdata *</_fridge_note_>
clonevar fridge = refrigerator

*<_sewmach_>
*<_sewmach_note_> Ownership of a sewing machine *</_sewmach_note_>
*<_sewmach_note_> sewmach brought in from rawdata *</_sewmach_note_>
clonevar sewmach = sewingmachine
*</_sewmach_>

*<_washmach_>
*<_washmach_note_> Ownership of a washing machine *</_washmach_note_>
*<_washmach_note_> washmach brought in from rawdata *</_washmach_note_>
clonevar washmach = washingmachine
*</_washmach_>

*<_stove_>
*<_stove_note_> Ownership of a stove *</_stove_note_>
*<_stove_note_> stove brought in from rawdata *</_stove_note_>
g stove = (inlist(q902_5,1,2,3)) if inrange(q902_5,0,3)
*</_stove_>

*<_ricecook_>
*<_ricecook_note_> Ownership of a rice cooker *</_ricecook_note_>
*<_ricecook_note_> ricecook brought in from rawdata *</_ricecook_note_>
gen ricecook=.
note ricecook: AFG 2019 does not have any relevant questions or variables.
*</_ricecook_>

*<_fan_>
*<_fan_note_> Ownership of an electric fan *</_fan_note_>
*<_fan_note_> fan brought in from rawdata *</_fan_note_>
*clonevar fan = fan
*</_fan_>

*<_ac_>
*<_ac_note_> Ownership of a central or wall air conditioner *</_ac_note_>
*<_ac_note_> ac brought in from rawdata *</_ac_note_>
gen ac=.
note ac: AFG 2019 does not have any relevant questions or variables.
*</_ac_>

*<_ewpump_>
*<_ewpump_note_> Ownership of a electric water pump *</_ewpump_note_>
*<_ewpump_note_> ewpump brought in from rawdata *</_ewpump_note_>
gen ewpump=.
note ewpump: AFG 2019 does not have any relevant questions or variables.
*</_ewpump_>

*<_bcycle_>
*<_bcycle_note_> Ownership of a bicycle *</_bcycle_note_>
*<_bcycle_note_> bcycle brought in from rawdata *</_bcycle_note_>
clonevar bcycle = bicycle
*</_bcycle_>

*<_mcycle_>
*<_mcycle_note_> Ownership of a motorcycle *</_mcycle_note_>
*<_mcycle_note_> mcycle brought in from rawdata *</_mcycle_note_>
clonevar mcycle = motorcycle
*</_mcycle_>

*<_oxcart_>
*<_oxcart_note_> Ownership of a oxcart *</_oxcart_note_>
*<_oxcart_note_> oxcart brought in from rawdata *</_oxcart_note_>
gen oxcart=.
note oxcart: AFG 2019 does not have any relevant questions or variables.
*</_oxcart_>

*<_boat_>
*<_boat_note_> Ownership of a boat *</_boat_note_>
*<_boat_note_> boat brought in from rawdata *</_boat_note_>
gen boat=.
note boat: AFG 2019 does not have any relevant questions or variables.
*</_boat_>

*<_car_>
*<_car_note_> Ownership of a Car *</_car_note_>
*<_car_note_> car brought in from rawdata *</_car_note_>
g car = (inlist(q902_9,1,2,3)) if inrange(q902_9,0,3)
*</_car_>

*<_canoe_>
*<_canoe_note_> Ownership of a canoes *</_canoe_note_>
*<_canoe_note_> canoe brought in from rawdata *</_canoe_note_>
gen canoe = .
note canoe: AFG 2019 does not have any relevant questions or variables.
*</_canoe_>

*<_roof_>
*<_roof_note_> Main material used for roof *</_roof_note_>
*<_roof_note_> roof brought in from rawdata *</_roof_note_>
recode q603 (1=11) (2=6) (3=12) (4=14) (5=2) (6=15) (*=.), g(roof)
*</_roof_>

*<_wall_>
*<_wall_note_> Main material used for external walls *</_wall_note_>
*<_wall_note_> wall brought in from rawdata *</_wall_note_>
recode q602 (1 4=5) (2=12) (3=4) (5=19) (*=.), g(wall)
*</_wall_>

*<_floor_>
*<_floor_note_> Main material used for floor *</_floor_note_>
*<_floor_note_> floor brought in from rawdata *</_floor_note_>
recode q604 (1=1) (2=11) (3=14) (*=.), g(floor)
*</_floor_>

*<_kitchen_>
*<_kitchen_note_> Separate kitchen in the dwelling *</_kitchen_note_>
*<_kitchen_note_> kitchen brought in from rawdata *</_kitchen_note_>
g kitchen = (q609==1) if inrange(q609,1,5)
*</_kitchen_>

*<_bath_>
*<_bath_note_> Bathing facility in the dwelling *</_bath_note_>
*<_bath_note_> bath brought in from rawdata *</_bath_note_>
gen bath=.
note bath: AFG 2019 does not have any relevant questions or variables.
*</_bath_>

*<_rooms_>
*<_rooms_note_> Number of habitable rooms *</_rooms_note_>
*<_rooms_note_> rooms brought in from rawdata *</_rooms_note_>
g rooms = q610 if inrange(q610,1,60)
*</_rooms_>

*<_areaspace_>
*<_areaspace_note_> Area *</_areaspace_note_>
*<_areaspace_note_> areaspace brought in from rawdata *</_areaspace_note_>
gen areaspace=.
note areaspace: AFG 2019 does not have any relevant questions or variables.
*</_areaspace_>

*<_ybuilt_>
*<_ybuilt_note_> Year the dwelling built *</_ybuilt_note_>
*<_ybuilt_note_> ybuilt brought in from rawdata *</_ybuilt_note_>
g		ybuilt = 2019 - 1 if q605==1
replace	ybuilt = 2019 - 3 if q605==2
replace	ybuilt = 2019 - 7 if q605==3
replace	ybuilt = 2019 - 15 if q605==4
replace	ybuilt = 2019 - 25 if q605==5
replace	ybuilt = 2019 - 35 if q605==6
note ybuilt: AFG 2019 used "years ago" ranges for when dwellings were built. We subtracted the mean of those ranges from the survey year 2019 to get year built.
note ybuilt: Ranges for q605: 1 "Less than 2 years ago" (used 1 year ago), 2 "2-4 years ago" (used 3), 3 "5-9 years ago" (used 7), 4 "10-19 years ago" (used 15), 5 "20-29 years ago" (used 25), 6 "More than 30 years ago" (used 35).
*</_ybuilt_>

*<_ownhouse_>
*<_ownhouse_note_> Ownership of house *</_ownhouse_note_>
*<_ownhouse_note_> ownhouse brought in from rawdata *</_ownhouse_note_>
*clonevar ownhouse = ownhouse
*</_ownhouse_>

*<_acqui_house_>
*<_acqui_house_note_> Acquisition of house *</_acqui_house_note_>
*<_acqui_house_note_> acqui_house brought in from rawdata *</_acqui_house_note_>
recode q606 (1 5=2) (2=1) (3 7=3) (*=.), g(acqui_house)
*</_acqui_house_>

*<_dwelownlti_>
*<_dwelownlti_note_> Legal title for Ownership *</_dwelownlti_note_>
*<_dwelownlti_note_> dwelownlti brought in from rawdata *</_dwelownlti_note_>
gen dwelownlti=.
note dwelownlti: AFG 2019 does not have any relevant questions or variables.
*</_dwelownlti_>

*<_fem_dwelownlti_>
*<_fem_dwelownlti_note_> Legal title for Ownership - Female *</_fem_dwelownlti_note_>
*<_fem_dwelownlti_note_> fem_dwelownlti brought in from rawdata *</_fem_dwelownlti_note_>
gen fem_dwelownlti=.
note fem_dwelownlti: AFG 2019 does not have any relevant questions or variables.
*</_fem_dwelownlti_>

*<_dwelownti_>
*<_dwelownti_note_> Type of Legal document *</_dwelownti_note_>
*<_dwelownti_note_> dwelownti brought in from rawdata *</_dwelownti_note_>
gen dwelownti=.
note dwelownti: AFG 2019 does not have any relevant questions or variables.
*</_dwelownti_>

*<_selldwel_>
*<_selldwel_note_> Right to sell dwelling *</_selldwel_note_>
*<_selldwel_note_> selldwel brought in from rawdata *</_selldwel_note_>
gen selldwel=.
note selldwel: AFG 2019 does not have any relevant questions or variables.
*</_selldwel_>

*<_transdwel_>
*<_transdwel_note_> Right to transfer dwelling *</_transdwel_note_>
*<_transdwel_note_> transdwel brought in from rawdata *</_transdwel_note_>
gen transdwel=.
note transdwel: AFG 2019 does not have any relevant questions or variables.
*</_transdwel_>

*<_ownland_>
*<_ownland_note_> Ownership of land *</_ownland_note_>
*<_ownland_note_> ownland brought in from rawdata *</_ownland_note_>
gen ownland=.
note ownland: AFG 2019 question 8.01 asks about irrigated farmland, which does not capture everything that should be included in this variable.
*</_ownland_>

*<_acqui_land_>
*<_acqui_land_note_> Acquisition of residential land *</_acqui_land_note_>
*<_acqui_land_note_> acqui_land brought in from rawdata *</_acqui_land_note_>
gen acqui_land=.
note acqui_land: AFG 2019 question 8.01 asks about irrigated farmland, which does not capture everything that should be included in this variable.
*</_acqui_land_>

*<_doculand_>
*<_doculand_note_> Legal document for residential land *</_doculand_note_>
*<_doculand_note_> doculand brought in from rawdata *</_doculand_note_>
gen doculand=.
note doculand: AFG 2019 question 8.01 asks about irrigated farmland, which does not capture everything that should be included in this variable.
*</_doculand_>

*<_fem_doculand_>
*<_fem_doculand_note_> Legal document for residential land - female *</_fem_doculand_note_>
*<_fem_doculand_note_> fem_doculand brought in from rawdata *</_fem_doculand_note_>
gen fem_doculand=.
note fem_doculand: AFG 2019 question 8.01 asks about irrigated farmland, which does not capture everything that should be included in this variable.
*</_fem_doculand_>

*<_landownti_>
*<_landownti_note_> Land Ownership *</_landownti_note_>
*<_landownti_note_> landownti brought in from rawdata *</_landownti_note_>
gen landownti=.
note landownti: AFG 2019 question 8.01 asks about irrigated farmland, which does not capture everything that should be included in this variable.
*</_landownti_>

*<_sellland_>
*<_sellland_note_> Right to sell land *</_sellland_note_>
*<_sellland_note_> sellland brought in from rawdata *</_sellland_note_>
gen sellland=.
note sellland: AFG 2019 question 8.01 asks about irrigated farmland, which does not capture everything that should be included in this variable.
*</_sellland_>

*<_transland_>
*<_transland_note_> Right to transfer land *</_transland_note_>
*<_transland_note_> transland brought in from rawdata *</_transland_note_>
gen transland=.
note transland: AFG 2019 question 8.01 asks about irrigated farmland, which does not capture everything that should be included in this variable.
*</_transland_>

*<_agriland_>
*<_agriland_note_> Agriculture Land *</_agriland_note_>
*<_agriland_note_> agriland brought in from rawdata *</_agriland_note_>
g agriland = (q803==1) if inlist(q803,1,2)
*</_agriland_>

*<_area_agriland_>
*<_area_agriland_note_> Area of Agriculture land *</_area_agriland_note_>
*<_area_agriland_note_> area_agriland brought in from rawdata *</_area_agriland_note_>
g area_agriland = q804/5 if q804~=9999
*</_area_agriland_>

*<_ownagriland_>
*<_ownagriland_note_> Ownership of agriculture land *</_ownagriland_note_>
*<_ownagriland_note_> ownagriland brought in from rawdata *</_ownagriland_note_>
g ownagriland = (q801==1 | q805==1) if inlist(q801,1,2) | inlist(q805,1,2)
*</_ownagriland_>

*<_area_ownagriland_>
*<_area_ownagriland_note_> Area of agriculture land owned *</_area_ownagriland_note_>
*<_area_ownagriland_note_> area_ownagriland brought in from rawdata *</_area_ownagriland_note_>
g area_ownirrland = q802/5 if q802~=9999
g area_ownrainland = q806/5 if q806~=9999
egen area_ownagriland = rowtotal(area_ownirrland area_ownrainland), missing
*</_area_ownagriland_>

*<_purch_agriland_>
*<_purch_agriland_note_> Purchased agri land *</_purch_agriland_note_>
*<_purch_agriland_note_> purch_agriland brought in from rawdata *</_purch_agriland_note_>
gen purch_agriland=.
note purch_agriland: AFG 2019 does not have any relevant questions or variables.
*</_purch_agriland_>

*<_areapurch_agriland_>
*<_areapurch_agriland_note_> Area of purchased agriculture land *</_areapurch_agriland_note_>
*<_areapurch_agriland_note_> areapurch_agriland brought in from rawdata *</_areapurch_agriland_note_>
gen areapurch_agriland=.
note areapurch_agriland: AFG 2019 does not have any relevant questions or variables.
*</_areapurch_agriland_>

*<_inher_agriland_>
*<_inher_agriland_note_> Inherit agriculture land *</_inher_agriland_note_>
*<_inher_agriland_note_> inher_agriland brought in from rawdata *</_inher_agriland_note_>
gen inher_agriland=.
note inher_agriland: AFG 2019 does not have any relevant questions or variables.
*</_inher_agriland_>

*<_areainher_agriland_>
*<_areainher_agriland_note_> Area of inherited agriculture land *</_areainher_agriland_note_>
*<_areainher_agriland_note_> areainher_agriland brought in from rawdata *</_areainher_agriland_note_>
gen areainher_agriland=.
note areainher_agriland: AFG 2019 does not have any relevant questions or variables.
*</_areainher_agriland_>

*<_rentout_agriland_>
*<_rentout_agriland_note_> Rent Out Land *</_rentout_agriland_note_>
*<_rentout_agriland_note_> rentout_agriland brought in from rawdata *</_rentout_agriland_note_>
gen rentout_agriland=.
note rentout_agriland: AFG 2019 does not have any relevant questions or variables.
*</_rentout_agriland_>

*<_arearentout_agriland_>
*<_arearentout_agriland_note_> Area of rent out agri land *</_arearentout_agriland_note_>
*<_arearentout_agriland_note_> arearentout_agriland brought in from rawdata *</_arearentout_agriland_note_>
gen arearentout_agriland=.
note arearentout_agriland: AFG 2019 does not have any relevant questions or variables.
*</_arearentout_agriland_>

*<_rentin_agriland_>
*<_rentin_agriland_note_> Rent in Land *</_rentin_agriland_note_>
*<_rentin_agriland_note_> rentin_agriland brought in from rawdata *</_rentin_agriland_note_>
gen rentin_agriland=.
note rentin_agriland: AFG 2019 does not have any relevant questions or variables.
*</_rentin_agriland_>

*<_arearentin_agriland_>
*<_arearentin_agriland_note_> Area of rent in agri land *</_arearentin_agriland_note_>
*<_arearentin_agriland_note_> arearentin_agriland brought in from rawdata *</_arearentin_agriland_note_>
gen arearentin_agriland=.
note arearentin_agriland: AFG 2019 does not have any relevant questions or variables.
*</_arearentin_agriland_>

*<_docuagriland_>
*<_docuagriland_note_> Documented Agri Land *</_docuagriland_note_>
*<_docuagriland_note_> docuagriland brought in from rawdata *</_docuagriland_note_>
gen docuagriland=.
note docuagriland: AFG 2019 does not have any relevant questions or variables.
*</_docuagriland_>

*<_area_docuagriland_>
*<_area_docuagriland_note_> Area of documented agri land *</_area_docuagriland_note_>
*<_area_docuagriland_note_> area_docuagriland brought in from rawdata *</_area_docuagriland_note_>
gen area_docuagriland=.
note area_docuagriland: AFG 2019 does not have any relevant questions or variables.
*</_area_docuagriland_>

*<_fem_agrilandownti_>
*<_fem_agrilandownti_note_> Ownership Agri Land - Female *</_fem_agrilandownti_note_>
*<_fem_agrilandownti_note_> fem_agrilandownti brought in from rawdata *</_fem_agrilandownti_note_>
gen fem_agrilandownti=.
note fem_agrilandownti: AFG 2019 does not have any relevant questions or variables.
*</_fem_agrilandownti_>

*<_agrilandownti_>
*<_agrilandownti_note_> Type Agri Land ownership doc *</_agrilandownti_note_>
*<_agrilandownti_note_> agrilandownti brought in from rawdata *</_agrilandownti_note_>
gen agrilandownti=.
note agrilandownti: AFG 2019 does not have any relevant questions or variables.
*</_agrilandownti_>

*<_sellagriland_>
*<_sellagriland_note_> Right to sell agri land *</_sellagriland_note_>
*<_sellagriland_note_> sellagriland brought in from rawdata *</_sellagriland_note_>
gen sellagriland=.
note sellagriland: AFG 2019 does not have any relevant questions or variables.
*</_sellagriland_>

*<_transagriland_>
*<_transagriland_note_> Right to transfer agri land *</_transagriland_note_>
*<_transagriland_note_> transagriland brought in from rawdata *</_transagriland_note_>
gen transagriland=.
note transagriland: AFG 2019 does not have any relevant questions or variables.
*</_transagriland_>

*<_dweltyp_>
*<_dweltyp_note_> Types of Dwelling *</_dweltyp_note_>
*<_dweltyp_note_> dweltyp brought in from rawdata *</_dweltyp_note_>
recode q601 (1=1) (2=2) (3=3) (4/6=9) (*=.), g(dweltyp)
*</_dweltyp_>

*<_typlivqrt_>
*<_typlivqrt_note_> Types of living quarters *</_typlivqrt_note_>
*<_typlivqrt_note_> typlivqrt brought in from rawdata *</_typlivqrt_note_>
g typlivqrt = .
*</_typlivqrt_>

*<_Keep variables_>
duplicates drop hhid, force
*keep countrycode year hhid weight weighttype landphone cellphone smartphone phone computer etablet internet internet_mobile internet_mobile4G radio tv tv_cable video fridge sewmach washmach stove ricecook fan ac ewpump bcycle mcycle oxcart boat car canoe roof wall floor kitchen bath rooms areaspace ybuilt ownhouse acqui_house dwelownlti fem_dwelownlti dwelownti selldwel transdwel ownland acqui_land doculand fem_doculand landownti sellland transland agriland area_agriland ownagriland area_ownagriland purch_agriland areapurch_agriland inher_agriland areainher_agriland rentout_agriland arearentout_agriland rentin_agriland arearentin_agriland docuagriland area_docuagriland fem_agrilandownti agrilandownti sellagriland transagriland dweltyp typlivqrt
order countrycode year hhid weight weighttype
sort hhid 
*</_Keep variables_>

*<_Save data file_>
do   "P:\SARMD\SARDATABANK\SARMDdofiles\_aux\Labels_GMD2.0.do"
*do 	 "$rootdatalib\\`code'\\`yearfolder'\\`SARMDfolder'\Programs\Labels_GMD2.0.do"
save "${rootdatalib}\\`code'\\`yearfolder'\\`harmfolder'\Data\Harmonized\\`filename'.dta" , replace
*</_Save data file_>
