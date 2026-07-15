/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   AFG_2019_LCS_v01_M_v01_A_GMD_UTL.do	</_Program name_>
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
File:	AFG_2019_LCS_v01_M_v01_A_GMD_UTL.do
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
local va           "03"
local type         "SARMD"
global module       	"UTL"
local yearfolder    "`code'_`year'_`survey'"
local SARMDfolder    "`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'"
local filename      "`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'_${module}"
glo output          "${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\\Data\Harmonized" 

*</_Program setup_>

* global path on Joe's computer
if ("`c(username)'"=="sunquat") {
	glo basepath "/Users/`c(username)'/Projects/WORLD BANK/2023 SAR QCHECK/SARDATABANK/WORKINGDATA/`code'/`yearfolder'"
	glo input "${basepath}/`yearfolder'_v`vm'_M"
	glo output "${basepath}/`yearfolder'_v`vm'_M_v`va'_A_SARMD/Data/Harmonized"
	
	* load and merge relevant data
	cd "${input}/Data/Stata"
	* IND data
	use "$output/`yearfolder'_v`vm'_M_v`va'_A_`type'_IND", clear
	clonevar hhid_orig=idh_org
	clonevar Mem_ID   =pid 
	* individual-level assebled data
	merge 1:m hhid_orig Mem_ID using "AFG_2019_LCS_M", nogen assert(match)
	drop HH_ID
	rename hhid_orig HH_ID
	* household data
	merge m:1 HH_ID using "household_male"
	rename HH_ID hhid_orig
}
* global paths on WB computer
else {
	*<_Folder creation_>
	*</_Folder creation_>
	
	*<_Datalibweb request_>
	use "${rootdatalib}\\`code'\\`code'_`year'_`survey'\\`code'_`year'_`survey'_v`vm'_M\Data\Stata\\`code'_`year'_`survey'_M.dta", clear 
	
	preserve
	use "${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\Data\Harmonized\\`yearfolder'_v`vm'_M_v`va'_A_`type'_IND.dta", clear
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
		
}

*<_countrycode_>
*<_countrycode_note_> country code *</_countrycode_note_>
*<_countrycode_note_> countrycode brought in from rawdata *</_countrycode_note_>
*g countrycode = "`code'"
*</_countrycode_>

*<_year_>
*<_year_note_> Year *</_year_note_>
*<_year_note_> year brought in from rawdata *</_year_note_>
*g year = `year'
*</_year_>

*<_hhid_>
*<_hhid_note_> Household identifier  *</_hhid_note_>
*<_hhid_note_> hhid brought in from rawdata *</_hhid_note_>
*clonevar hhid = hhid_orig
*</_hhid_>

*<_cellphone_exp_>
*<_cellphone_exp_note_> Total annual consumption of cell phone services *</_cellphone_exp_note_>
*<_cellphone_exp_note_> cellphone_exp brought in from rawdata *</_cellphone_exp_note_>
gen cellphone_exp = q515*12
*</_cellphone_exp_>

*<_central_acc_>
*<_central_acc_note_> Access to central heating  *</_central_acc_note_>
*<_central_acc_note_> central_acc brought in from rawdata *</_central_acc_note_>
gen central_acc=.
note central_acc: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_central_acc_>

*<_central_exp_>
*<_central_exp_note_> Total annual consumption of central heating *</_central_exp_note_>
*<_central_exp_note_> central_exp brought in from rawdata *</_central_exp_note_>
gen central_exp=.
note central_exp: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_central_exp_>

*<_coal_exp_>
*<_coal_exp_note_> Total annual consumption of coal *</_coal_exp_note_>
*<_coal_exp_note_> coal_exp brought in from rawdata *</_coal_exp_note_>
g coal_exp = q615d*12
note coal_exp: Variable q615d mixes firewood and coal, but Laura said it is OK to use anyway.
*</_coal_exp_>

*<_comm_exp_>
*<_comm_exp_note_> Total consumption of all telecommunication services  *</_comm_exp_note_>
*<_comm_exp_note_> comm_exp brought in from rawdata *</_comm_exp_note_>
egen comm_exp = rowtotal(q515 q516), missing
replace comm_exp = 12*comm_exp
note comm_exp: AFG_2019_LCS removed "fixed phone line" expenses, and now only includes mobile phone and internet service expenses.
*</_comm_exp_>

*<_cooksource_>
*<_cooksource_note_> Main cooking fuel *</_cooksource_note_>
*<_cooksource_note_> cooksource brought in from rawdata *</_cooksource_note_>
recode q613 (1 2 4 8=9) (3=1) (5=3) (6=5) (7=4), g(cooksource)
*</_cooksource_>

*<_diesel_exp _>
*<_diesel_exp _note_> Total annual consumption of diesel *</_diesel_exp _note_>
*<_diesel_exp _note_> diesel_exp  brought in from rawdata *</_diesel_exp _note_>
gen diesel_exp =.
note diesel_exp: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_diesel_exp _>

*<_dwelmat_exp_>
*<_dwelmat_exp_note_> Total annual consumption of materials for the maintenance and repair of the dwelling *</_dwelmat_exp_note_>
*<_dwelmat_exp_note_> dwelmat_exp brought in from rawdata *</_dwelmat_exp_note_>
gen dwelmat_exp = .
note dwelmat_exp: Survey collects combined house repair (materials and labour). Thus blank.
*</_dwelmat_exp_>

*<_dwelothsvc_exp_>
*<_dwelothsvc_exp_note_> Total annual consumption of other services relating to the dwelling *</_dwelothsvc_exp_note_>
*<_dwelothsvc_exp_note_> dwelothsvc_exp brought in from rawdata *</_dwelothsvc_exp_note_>
gen dwelothsvc_exp=.
note dwelothsvc_exp: Survey collects combined house repair (materials and labour). Thus blank.
*</_dwelothsvc_exp_>

*<_dwelsvc_exp_>
*<_dwelsvc_exp_note_> Total annual consumption of services for the maintenance and repair of the dwelling *</_dwelsvc_exp_note_>
*<_dwelsvc_exp_note_> dwelsvc_exp brought in from rawdata *</_dwelsvc_exp_note_>
gen dwelsvc_exp=.
note dwelsvc_exp: Survey collects combined house repair (materials and labour). Thus blank.
*</_dwelsvc_exp_>

*<_elec_acc_>
*<_elec_acc_note_> Connection to electricity in dwelling *</_elec_acc_note_>
*<_elec_acc_note_> elec_acc brought in from rawdata *</_elec_acc_note_>
gen elec_acc = 1 if q611a==1 | q611b==1	//1 = Yes, public/quasi-public
recode elec_acc (.=2) if q611c==1 | q611d==1 | q611e==1 | q611f==1	//2 = Yes, private
recode elec_acc (.=3) if q611g==1 | q611h==1 | q611i==1	//3 = Yes, source unstated
recode elec_acc (.=4) if q611a==2 | q611b==2 | q611c==2 | q611d==2 | q611e==2 | q611f==2 | q611g==2 | q611h==2 | q611i==2 	//4 = No
*</_elec_acc_>

*<_elec_exp_>
*<_elec_exp_note_> Total annual consumption of electricity *</_elec_exp_note_>
*<_elec_exp_note_> elec_exp brought in from rawdata *</_elec_exp_note_>
gen elec_exp = q615a*12
*</_elec_exp_>

*<_elechr_acc_>
*<_elechr_acc_note_> Electricity availability (hr/day) *</_elechr_acc_note_>
*<_elechr_acc_note_> elechr_acc brought in from rawdata *</_elechr_acc_note_>
gen elechr_acc = q611a1/7
*</_elechr_acc_>

*<_electricity_>
*<_electricity_note_> Access to electricity in dwelling *</_electricity_note_>
*<_electricity_note_> electricity brought in from rawdata *</_electricity_note_>
*egen electricity = anymatch(q611?), values(1)
*replace electricity = . if missing(q611a) & missing(q611b) & missing(q611c) & missing(q611d) & missing(q611e) & missing(q611f) & missing(q611g) & missing(q611h) & missing(q611i)
*clonevar electricity=electricity
*</_electricity_>

*<_garbage_exp_>
*<_garbage_exp_note_> Total annual consumption of garbage collection *</_garbage_exp_note_>
*<_garbage_exp_note_> garbage_exp brought in from rawdata *</_garbage_exp_note_>
gen garbage_exp=.
note garbage_exp: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_garbage_exp_>

*<_gas_>
*<_gas_note_> Connection to gas/Usage of gas *</_gas_note_>
*<_gas_note_> gas brought in from rawdata *</_gas_note_>
gen gas=.
note gas: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_gas_>

*<_gas_exp_>
*<_gas_exp_note_> Total annual consumption of network/natural and liquefied gas *</_gas_exp_note_>
*<_gas_exp_note_> gas_exp brought in from rawdata *</_gas_exp_note_>
gen gas_exp = q615b*12
*</_gas_exp_>

*<_gasoline_exp _>
*<_gasoline_exp _note_> Total annual consumption of gasoline *</_gasoline_exp _note_>
*<_gasoline_exp _note_> gasoline_exp  brought in from rawdata *</_gasoline_exp _note_>
gen gasoline_exp =.
note gasoline_exp: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_gasoline_exp _>

*<_heating_exp_>
*<_heating_exp_note_> Total annual consumption of heating *</_heating_exp_note_>
*<_heating_exp_note_> heating_exp brought in from rawdata *</_heating_exp_note_>
gen heating_exp=.
note heating_exp: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_heating_exp_>

*<_heatsource_>
*<_heatsource_note_> Main source of heating  *</_heatsource_note_>
*<_heatsource_note_> heatsource brought in from rawdata *</_heatsource_note_>
recode q614 (1=10) (2 4 5 9=9) (3=1) (6=3) (7=5) (8=4) (*=.), g(heatsource)
*</_heatsource_>

*<_hwater_exp_>
*<_hwater_exp_note_> Total annual consumption of hot water supply *</_hwater_exp_note_>
*<_hwater_exp_note_> hwater_exp brought in from rawdata *</_hwater_exp_note_>
gen hwater_exp=.
note hwater_exp: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_hwater_exp_>

*<_imp_san_rec_>
*<_imp_san_rec_note_> Improved sanitation facility recommended estimate (not considering sharing) *</_imp_san_rec_note_>
*<_imp_san_rec_note_> imp_san_rec brought in from rawdata *</_imp_san_rec_note_>
*g		imp_san_rec = (inrange(q619,1,8)) if inrange(q619,1,11)
*replace imp_san_rec = 0 if q620==1
clonevar imp_san_rec = improved_sanitation
*</_imp_san_rec_>

*<_imp_wat_rec_>
*<_imp_wat_rec_note_> Improved water recommended estimate *</_imp_wat_rec_note_>
*<_imp_wat_rec_note_> imp_wat_rec brought in from rawdata *</_imp_wat_rec_note_>
clonevar imp_wat_rec=improved_water
*</_imp_wat_rec_>

*<_internet_exp_>
*<_internet_exp_note_> Total consumption of internet services  *</_internet_exp_note_>
*<_internet_exp_note_> internet_exp brought in from rawdata *</_internet_exp_note_>
gen internet_exp = q516*12
*</_internet_exp_>

*<_kerosene_exp_>
*<_kerosene_exp_note_> Total annual consumption of kerosene *</_kerosene_exp_note_>
*<_kerosene_exp_note_> kerosene_exp brought in from rawdata *</_kerosene_exp_note_>
gen kerosene_exp=.
note kerosene_exp: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_kerosene_exp_>

*<_landphone_exp_>
*<_landphone_exp_note_> Total annual consumption of landline phone services *</_landphone_exp_note_>
*<_landphone_exp_note_> landphone_exp brought in from rawdata *</_landphone_exp_note_>
gen landphone_exp=.
note landphone_exp: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_landphone_exp_>

*<_lightsource_>
*<_lightsource_note_> Main source of lighting  *</_lightsource_note_>
*<_lightsource_note_> lightsource brought in from rawdata *</_lightsource_note_>
recode q612 (1=10) (2=1) (3=4) (4=3) (5=2) (6=9) (*=.), g(lightsource)
*</_lightsource_>

*<_electyp_>
*<_electyp_note_> Lighting and/or electricity – type of *</_electyp_note_>
*<_electyp_note_> electyp brought in from rawdata *</_electyp_note_>
gen		electyp=1 if cooksource==4 | lightsource==1
replace	electyp=2 if (cooksource==5 | lightsource==4) & mi(electyp)
replace	electyp=3 if (cooksource==2 | inlist(lightsource,2,3)) & mi(electyp)
replace	electyp=4 if inlist(cooksource,1,3,9) | lightsource==9 & mi(electyp)
replace	electyp=10 if cooksource==10 & lightsource==10
*</_electyp_>

*<_liquid_exp_>
*<_liquid_exp_note_> Total annual consumption of all liquid fuels *</_liquid_exp_note_>
*<_liquid_exp_note_> liquid_exp brought in from rawdata *</_liquid_exp_note_>
gen liquid_exp = q615c*12
*</_liquid_exp_>

*<_LPG_exp _>
*<_LPG_exp _note_> Total annual consumption of liquefied gas *</_LPG_exp _note_>
*<_LPG_exp _note_> LPG_exp  brought in from rawdata *</_LPG_exp _note_>
gen LPG_exp =.
note LPG_exp: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_LPG_exp _>

*<_ngas_exp _>
*<_ngas_exp _note_> Total annual consumption of network/natural gas *</_ngas_exp _note_>
*<_ngas_exp _note_> ngas_exp  brought in from rawdata *</_ngas_exp _note_>
gen ngas_exp =.
note ngas_exp: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_ngas_exp _>

*<_open_def_>
*<_open_def_note_> open defecation *</_open_def_note_>
*<_open_def_note_> open_def brought in from rawdata *</_open_def_note_>
gen open_def = (q619==10) if inrange(q619,1,11)
*</_open_def_>

*<_othfuel_exp_>
*<_othfuel_exp_note_> Total annual consumption of all other fuels *</_othfuel_exp_note_>
*<_othfuel_exp_note_> othfuel_exp brought in from rawdata *</_othfuel_exp_note_>
gen othfuel_exp=.
note othfuel_exp: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_othfuel_exp_>

*<_othhousing_exp_>
*<_othhousing_exp_note_> Total annual consumption of dwelling repair/maintenance *</_othhousing_exp_note_>
*<_othhousing_exp_note_> othhousing_exp brought in from rawdata *</_othhousing_exp_note_>
gen othhousing_exp=.
note othhousing_exp: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_othhousing_exp_>

*<_othliq_exp _>
*<_othliq_exp _note_> Total annual consumption of other liquid fuels *</_othliq_exp _note_>
*<_othliq_exp _note_> othliq_exp  brought in from rawdata *</_othliq_exp _note_>
gen othliq_exp =.
note othliq_exp: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_othliq_exp _>

*<_othsol_exp _>
*<_othsol_exp _note_> Total annual consumption of other solid fuels *</_othsol_exp _note_>
*<_othsol_exp _note_> othsol_exp  brought in from rawdata *</_othsol_exp _note_>
gen othsol_exp = q615e*12
*</_othsol_exp _>

*<_peat_exp _>
*<_peat_exp _note_> Total annual consumption of peat *</_peat_exp _note_>
*<_peat_exp _note_> peat_exp  brought in from rawdata *</_peat_exp _note_>
gen peat_exp =.
note peat_exp: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_peat_exp _>

*<_piped _>
*<_piped _note_> Access to piped water  *</_piped _note_>
*<_piped _note_> piped  brought in from rawdata *</_piped _note_>
gen piped = (inrange(q616,1,3)) if inrange(q616,1,11)
*</_piped _>

*<_piped_to_prem_>
*<_piped_to_prem_note_> Access to piped water on premises *</_piped_to_prem_note_>
*<_piped_to_prem_note_> piped_to_prem brought in from rawdata *</_piped_to_prem_note_>
gen piped_to_prem = (inlist(q616,1,2)) if inrange(q616,1,11)
*</_piped_to_prem_>

*<_pwater_exp_>
*<_pwater_exp_note_> Total annual consumption of water supply/piped water  *</_pwater_exp_note_>
*<_pwater_exp_note_> pwater_exp brought in from rawdata *</_pwater_exp_note_>
gen pwater_exp = q618*12
*</_pwater_exp_>

*<_sanitation_original_>
*<_sanitation_original_note_> Original survey response in string for sanitation_source variable *</_sanitation_original_note_>
*<_sanitation_original_note_> sanitation_original brought in from rawdata *</_sanitation_original_note_>
clonevar sanitation_original = toilet_orig
*</_sanitation_original_>

*<_sanitation_source_>
*<_sanitation_source_note_> Sources of sanitation facilities *</_sanitation_source_note_>
*<_sanitation_source_note_> sanitation_source brought in from rawdata *</_sanitation_source_note_>
recode q619 (1=6) (2=10) (3=5) (4=1) (5=3) (6=4) (7=9) (8 9 11=14) (10=13) (*=.), g(sanitation_source)
*</_sanitation_source_>

*<_sewage_exp_>
*<_sewage_exp_note_> Total annual consumption of sewage collection *</_sewage_exp_note_>
*<_sewage_exp_note_> sewage_exp brought in from rawdata *</_sewage_exp_note_>
gen sewage_exp=.
note sewage_exp: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_sewage_exp_>

*<_sewer_>
*<_sewer_note_> sewer *</_sewer_note_>
*<_sewer_note_> sewer brought in from rawdata *</_sewer_note_>
gen sewer = inlist(sanitation_source,1,2) if ~missing(sanitation_source)
*</_sewer_>

*<_solid_exp _>
*<_solid_exp _note_> Total annual consumption of all solid fuels *</_solid_exp _note_>
*<_solid_exp _note_> solid_exp  brought in from rawdata *</_solid_exp _note_>
gen solid_exp =.
note solid_exp: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_solid_exp _>

*<_tel_exp_>
*<_tel_exp_note_> Total consumption of all telephone services *</_tel_exp_note_>
*<_tel_exp_note_> tel_exp brought in from rawdata *</_tel_exp_note_>
gen tel_exp=.
note tel_exp: This is an aggregation of landphone_exp and cellphone_exp. Since we can't create landphone_exp for 2019, this is missing since it is not complete (and thus it would not be an accurate comparison to 2016, where we could create landphone_exp).
*</_tel_exp_>

*<_telefax_exp_>
*<_telefax_exp_note_> Total consumption of telefax services  *</_telefax_exp_note_>
*<_telefax_exp_note_> telefax_exp brought in from rawdata *</_telefax_exp_note_>
gen telefax_exp=.
note telefax_exp: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_telefax_exp_>

*<_toilet_acc_>
*<_toilet_acc_note_> Access to flushed toilet  *</_toilet_acc_note_>
*<_toilet_acc_note_> toilet_acc brought in from rawdata *</_toilet_acc_note_>
gen toilet_acc=.
note toilet_acc: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_toilet_acc_>

*<_transfuel_exp_>
*<_transfuel_exp_note_> Total annual consumption of fuels for personal transportation *</_transfuel_exp_note_>
*<_transfuel_exp_note_> transfuel_exp brought in from rawdata *</_transfuel_exp_note_>
gen transfuel_exp = q519*12
*</_transfuel_exp_>

*<_tv_exp_>
*<_tv_exp_note_> Total consumption of TV broadcasting services  *</_tv_exp_note_>
*<_tv_exp_note_> tv_exp brought in from rawdata *</_tv_exp_note_>
gen tv_exp=.
note tv_exp: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_tv_exp_>

*<_tvintph_exp_>
*<_tvintph_exp_note_> Total consumption of tv, internet and telephone  *</_tvintph_exp_note_>
*<_tvintph_exp_note_> tvintph_exp brought in from rawdata *</_tvintph_exp_note_>
gen tvintph_exp=.
note tvintph_exp: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_tvintph_exp_>

*<_utl_exp_>
*<_utl_exp_note_> Total annual consumption of all utilities excluding telecom and other housing *</_utl_exp_note_>
*<_utl_exp_note_> utl_exp brought in from rawdata *</_utl_exp_note_>
gen utl_exp=.
note utl_exp: The 2016 do file created this variable in the standard way by summing all the components, but the 2016 data does not contain some of the components (including central_exp), so it should be changed to missing since it is not a complete picture of utility expenses. Do you agree?
*</_utl_exp_>

*<_w_30m_>
*<_w_30m_note_> Access to water within 30 minutes *</_w_30m_note_>
*<_w_30m_note_> w_30m brought in from rawdata *</_w_30m_note_>
gen w_30m = (q617<=30) if ~missing(q617)
*</_w_30m_>

*<_w_avail_>
*<_w_avail_note_> Water is available when needed *</_w_avail_note_>
*<_w_avail_note_> w_avail brought in from rawdata *</_w_avail_note_>
gen w_avail=.
note w_avail: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_w_avail_>

*<_waste_>
*<_waste_note_> Main types of solid waste disposal *</_waste_note_>
*<_waste_note_> waste brought in from rawdata *</_waste_note_>
gen waste=.
note waste: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_waste_>

*<_waste_exp _>
*<_waste_exp _note_> Total annual consumption of garbage and sewage collection *</_waste_exp _note_>
*<_waste_exp _note_> waste_exp  brought in from rawdata *</_waste_exp _note_>
gen waste_exp =.
note waste_exp: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_waste_exp _>

*<_water_exp_>
*<_water_exp_note_> Total annual consumption of water supply and hot water *</_water_exp_note_>
*<_water_exp_note_> water_exp brought in from rawdata *</_water_exp_note_>
gen water_exp=.
note water_exp: I cannot find questions in the questionnaire or variables in the data to create this indicator.
*</_water_exp_>

*<_water_original_>
*<_water_original_note_> Original survey response in string for water_source variable *</_water_original_note_>
*<_water_original_note_> water_original brought in from rawdata *</_water_original_note_>
clonevar water_original = water_orig
*</_water_original_>

*<_water_source_>
*<_water_source_note_> Sources of drinking water *</_water_source_note_>
*<_water_source_note_> water_source brought in from rawdata *</_water_source_note_>
recode q616 (1=1) (2=2) (3=3) (4=4) (5=6) (6=9) (7=5) (8=10) (9=13) (10=12) (11=14) (*=.), g(water_source)
*</_water_source_>

*<_watertype_quest_>
*<_watertype_quest_note_> Type of water questions used in the survey *</_watertype_quest_note_>
*<_watertype_quest_note_> watertype_quest brought in from rawdata *</_watertype_quest_note_>
gen watertype_quest = 1
*</_watertype_quest_>

*<_wood_exp_>
*<_wood_exp_note_> Total annual consumption of firewood *</_wood_exp_note_>
*<_wood_exp_note_> wood_exp brought in from rawdata *</_wood_exp_note_>
gen wood_exp=.
note wood_exp: q615d combines firewood and coal, so we cannot accurately calculate firewood alone. However, Laura decided to use q615d for coal_exp.
*</_wood_exp_>

clonevar pipedwater_acc = piped

*<_Save data file_>
if ("`c(username)'"=="sunquat") global rootdofiles "/Users/`c(username)'/Projects/WORLD BANK/2023 SAR QCHECK/SARDATABANK/SARMDdofiles"
quietly do 	"$rootdofiles/_aux/Labels_GMD2.0.do"
save "$output/`filename'.dta", replace
*</_Save data file_>
