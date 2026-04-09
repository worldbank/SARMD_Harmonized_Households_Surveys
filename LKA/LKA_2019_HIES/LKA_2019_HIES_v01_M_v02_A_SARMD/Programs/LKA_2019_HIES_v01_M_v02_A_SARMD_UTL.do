/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   LKA_2019_HIES_v01_M_v01_A_SARMD_UTL.do	</_Program name_>
<_Application_>    STATA 16.0	<_Application_>
<_Author(s)_>      jogreen@worldbank.org	</_Author(s)_>
<_Date created_>   06-26-2022	</_Date created_>
<_Date modified>   26 May 2022	</_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        LKA	</_Country_>
<_Survey Title_>   HIES	</_Survey Title_>
<_Survey Year_>    2019	</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:	06-26-2022
File:	LKA_2019_HIES_v01_M_v01_A_SARMD_UTL.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>
clear all
set more off
local code         "LKA"
local year         "2019"
local survey       "HIES"
local vm           "01"
local va           "02"
local type         "SARMD"
glo   module       "UTL"
local yearfolder   "`code'_`year'_`survey'"
local gmdfolder    "`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD"
local filename     "`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD_${module}"
local SARMDfolder    	"`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'"
tempfile			hh_level_data
*</_Program setup_>

/*------------------------------------------------------------------------------*
/*------------------------------------------------------------------------------*
1. INPUT DATA 
*------------------------------------------------------------------------------*/
*------------------------------------------------------------------------------*/
/*	*<_Raw data_>	
	*--------------------------------------------------------------------------*
	* Weigths
	*--------------------------------------------------------------------------*
	datalibweb, country(`code') year(`year') type(SARRAW) filename(weight_2019.dta)
	save `hh_level_data'
	*--------------------------------------------------------------------------*
	* Housing
	*--------------------------------------------------------------------------*
	datalibweb, country(`code') year(`year') type(SARRAW) filename(SEC_8_HOUSING.dta)
	*merge m:1 psu using `hh_level_data', nogen assert(match)
	tempfile SEC_8_HOUSING
	save `SEC_8_HOUSING'
	
	*--------------------------------------------------------------------------*
	* Basic facilities 
	*--------------------------------------------------------------------------*
	datalibweb, country(`code') year(`year') type(SARRAW) filename(SEC_7_BASIC_FACILITIES.dta)
	tempfile SEC_7_BASIC_FACILITIES
	save `SEC_7_BASIC_FACILITIES'
	*merge 1:1 hhid using `hh_level_data', nogen keep(match)
	*</_Datalibweb request_>
*/


*<_Datalibweb request_>
use   "${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata\\`yearfolder'_v`vm'_M.dta", clear
sort  hhid pid
merge 1:1 hhid pid using "${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\\Data\Harmonized\\`yearfolder'_v`vm'_M_v`va'_A_`type'_IND.dta"
drop _merge

*merge m:1 psu using  `SEC_8_HOUSING', nogen assert(match)
*merge 1:1 hhid using `SEC_7_BASIC_FACILITIES', nogen keep(match)

*</_Datalibweb request_>

/*******************************************************************************
*                                                                              *
                           STANDARD SURVEY MODULE
*                                                                              *
*******************************************************************************/
*<_countrycode_>
*<_countrycode_note_> country code *</_countrycode_note_>
*<_countrycode_note_> countrycode brought in from rawdata *</_countrycode_note_>
*gen countrycode=code
*</_countrycode_>

*<_year_>
*<_year_note_> Year *</_year_note_>
*<_year_note_> year brought in from rawdata *</_year_note_>
* NOTE: this variable already exists in harmonized form.
*</_year_>

*<_hhid_>
*<_hhid_note_> Household identifier  *</_hhid_note_>
*<_hhid_note_> hhid brought in from rawdata *</_hhid_note_>
* NOTE: this variable already exists in harmonized form.
*</_hhid_>

*<_weight_>
*<_weight_note_> Household weight *</_weight_note_>
*<_weight_note_> weight brought in from rawdata *</_weight_note_>
clonevar weight = finalweight
*</_weight_>

*<_weighttype_>
*<_weighttype_note_> Weight type (frequency, probability, analytical, importance) *</_weighttype_note_>
*<_weighttype_note_> weighttype brought in from rawdata *</_weighttype_note_>
*g weighttype = "PW"
*</_weighttype_>

/*******************************************************************************
*                                                                              *
                           HEATING, ELECTRICITY, GAS
*                                                                              *
*******************************************************************************/
*<_central_acc_>
*<_central_acc_note_> Access to central heating  *</_central_acc_note_>
*<_central_acc_note_> central_acc brought in from rawdata *</_central_acc_note_>
gen central_acc=.
*</_central_acc_>

*<_cooksource_>
*<_cooksource_note_> Main cooking fuel *</_cooksource_note_>
*<_cooksource_note_> cooksource brought in from rawdata *</_cooksource_note_>
recode cooking_fuel (1=1) (2=2) (3=5) (4=4) (5/6 9=9) (*=.), g(cooksource)
*</_cooksource_>

*<_elec_acc_>
*<_elec_acc_note_> Connection to electricity in dwelling *</_elec_acc_note_>
*<_elec_acc_note_> elec_acc brought in from rawdata *</_elec_acc_note_>
g		elec_acc = 1 if inlist(lite_source,1,2) | is_power_lines_near==1
replace	elec_acc = 3 if lite_source==4
recode elec_acc (.=4) if is_power_lines_near==2
note elec_acc: For LKA_2019_HIES, we used 2 variables as proxies: "Principle Type of Lighting", and "Do you have electricity supply (main line) nearby your area?".
*</_elec_acc_>

*<_elechr_acc_>
*<_elechr_acc_note_> Electricity availability (hr/day) *</_elechr_acc_note_>
*<_elechr_acc_note_> elechr_acc brought in from rawdata *</_elechr_acc_note_>
gen elechr_acc=.
*</_elechr_acc_>

*<_electricity_>
*<_electricity_note_> Access to electricity in dwelling *</_electricity_note_>
*<_electricity_note_> electricity brought in from rawdata *</_electricity_note_>
*recode elec_acc (1/3=1) (4=0), g(electricity)
*</_electricity_>

*<_electyp_>
*<_electyp_note_> Lighting and/or electricity – type of *</_electyp_note_>
*<_electyp_note_> electyp brought in from rawdata *</_electyp_note_>
recode lite_source (1/2=1) (3=3) (4/5 9=4) (*=.), g(electyp)
*</_electyp_>

*<_lightsource_>
*<_lightsource_note_> Main source of lighting  *</_lightsource_note_>
*<_lightsource_note_> lightsource brought in from rawdata *</_lightsource_note_>
recode lite_source (1/2=1) (3=2) (4/5 9=9) (*=.), g(lightsource)
*</_lightsource_>

*<_heatsource_>
*<_heatsource_note_> Main source of heating  *</_heatsource_note_>
*<_heatsource_note_> heatsource brought in from rawdata *</_heatsource_note_>
gen heatsource=.
*</_heatsource_>

*<_gas_>
*<_gas_note_> Connection to gas/Usage of gas *</_gas_note_>
*<_gas_note_> gas brought in from rawdata *</_gas_note_>
gen gas=.
*</_gas_>


/*******************************************************************************
*                                                                              *
                           WATER
*                                                                              *
*******************************************************************************/

*<_water_original_>
*<_water_original_note_> Original survey response in string for water_source variable *</_water_original_note_>
*<_water_original_note_> water_original brought in from rawdata *</_water_original_note_>
label define drinking_water 1 "Ground water: Protected well" 2 "Ground water: Unprotected well" 3 "Ground water: Tube well" 4 "Tap water: Tap water (National water supply and drainage board)" 5 "Tap water: Tap water (Community based water supply and management organizations)" 6 "Tap water: Tap water ( Local government institutions)" 7 "Tap water: Tap water ( Private water projects)" 8 "Other: River/ Tank / Streams" 9 "Other: Rain water" 10 "Other: Bottled water" 11 "Other: Bowser" 12 "Other: Filter Water" 99 "Other: Other(Specify)"
label values drinking_water drinking_water
decode drinking_water, g(water_original)
*</_water_original_>

*<_water_source_>
*<_water_source_note_> Sources of drinking water *</_water_source_note_>
*<_water_source_note_> water_source brought in from rawdata *</_water_source_note_>
recode drinking_water (1=5) (2=10) (3=4) (4/7=1) (8/9=13) (10=7) (11=12) (12 99=14) (*=.), g(water_source)
* change to public tap if source is not on premises
recode water_source (1/2=3) if s8_6b1_inside_outside==2
#delimit
la de lblwater_source 1 "Piped water into dwelling" 	
					  2 "Piped water to yard/plot" 
					  3 "Public tap or standpipe" 
					  4 "Tubewell or borehole" 
					  5 "Protected dug well"
					  6 "Protected spring"
					  7 "Bottled water"
					  8 "Rainwater"
					  9 "Unprotected spring"
					  10 "Unprotected dug well"
					  11 "Cart with small tank/drum"
					  12 "Tanker-truck"
					  13 "Surface water"
					  14 "Other";
#delimit cr
la val water_source lblwater_source
la var water_source "Sources of drinking water"
*</_water_source_>

*<_watertype_quest_>
*<_watertype_quest_note_> Type of water questions used in the survey *</_watertype_quest_note_>
*<_watertype_quest_note_> watertype_quest brought in from rawdata *</_watertype_quest_note_>
g watertype_quest = 1
*</_watertype_quest_>

*<_imp_wat_rec_>
*<_imp_wat_rec_note_> Improved water recommended estimate 
*<_imp_wat_rec_note_> imp_wat_rec brought in from rawdata 
recode drinking_water (1 3 4 5 6 7 11 12=1) (2 8 9 10 99=0) (*=.), g(imp_wat_rec)
*</_imp_wat_rec_>

*<_piped _>
*<_piped _note_> Access to piped water  *</_piped _note_>
*<_piped _note_> piped  brought in from rawdata *</_piped _note_>
recode drinking_water (1/3 8/12 99=0) (4/7=1) (*=.), g(piped)
*</_piped _>

*<_pipedwater_acc_>
gen pipedwater_acc=0 if inlist(drinking_water,1,2,3,8,9,10,11,12,99) // Asuming other is not piped water
replace pipedwater_acc=3 if inlist(drinking_water,4,5,6,7)
#delimit 
la def lblpiped_water		0 "No"
							1 "Yes, in premise"
							2 "Yes, but not in premise"
							3 "Yes, unstated whether in or outside premise";
#delimit cr
la val pipedwater_acc lblpiped_water
la var pipedwater_acc "Household has access to piped water"
*</_pipedwater_acc_>

*<_piped_to_prem_>
*<_piped_to_prem_note_> Access to piped water on premises *<_piped_to_prem_note_> piped_to_prem brought in from rawdata 
recode drinking_water (1/3 8/12 99=0) (4/7=1) (*=.), g(piped_to_prem)
note piped_to_prem: For LKA_2019_HIES we used "tap water" as a proxy for piped water on premises, but it does not identify the location of the tap (communal or in-house).
*</_piped_to_prem_>

*<_w_30m_>
*<_w_30m_note_> Access to water within 30 minutes *</_w_30m_note_>
*<_w_30m_note_> w_30m brought in from rawdata *</_w_30m_note_>
gen w_30m = 1 if imp_wat_rec==1 & s8_6b1_inside_outside==1 | inrange(s8_6b2_premises_time,0,15)
recode w_30m (.=0) if imp_wat_rec==1 & s8_6b1_inside_outside==2 & ~missing(s8_6b2_premises_time)
*</_w_30m_>

*<_w_avail_>
*<_w_avail_note_> Water is available when needed *</_w_avail_note_>
*<_w_avail_note_> w_avail brought in from rawdata *</_w_avail_note_>
g		w_avail = 0 if imp_wat_rec==1 & (s8_6d_water_sufficency==1 | inrange(s8_6e1_water_sufficency_for_drio,0,11))
recode	w_avail (.=1) if imp_wat_rec==1 & (s8_6d_water_sufficency==2 | s8_6e1_water_sufficency_for_drio==12)
*</_w_avail_>




/*******************************************************************************
*                                                                              *
                           SANITATION
*                                                                              *
*******************************************************************************/
*<_sanitation_original_>
*<_sanitation_original_note_> Original survey response in string for sanitation_source variable *</_sanitation_original_note_>
*<_sanitation_original_note_> sanitation_original brought in from rawdata *</_sanitation_original_note_>
label define toilet_type 1 "Water seal with Connected to Septic Tank" 2 "Waterseal withConnectedtoa pit" 3 "Water seal with connected to sewer system" 4 "Water seal with connected to a river or a drain" 5 "Not water seal pit latrine with deck" 6 "Not water seal open pit latrine without deck" 7 "No facility. Use bush/ field" 9 "Other (Specify)"
label values toilet_type toilet_type
decode toilet_type, g(sanitation_original)
*</_sanitation_original_>

*<_sanitation_source_>
*<_sanitation_source_note_> Sources of sanitation facilities *</_sanitation_source_note_>
*<_sanitation_source_note_> sanitation_source brought in from rawdata *</_sanitation_source_note_>
recode toilet_type (1=3) (2=4) (3=2) (4=9) (5=6) (6=10) (7=13) (9=14) (*=.), g(sanitation_source)
*</_sanitation_source_>

*<_imp_san_rec_>
*<_imp_san_rec_note_> Improved sanitation facility recommended estimate (not considering sharing) *</_imp_san_rec_note_>
*<_imp_san_rec_note_> imp_san_rec brought in from rawdata *</_imp_san_rec_note_>
recode toilet_type (1 2=1) (3 4 5 6 7 9=0) (*=.), g(imp_san_rec)
*</_imp_san_rec_>

*<_open_def_>
*<_open_def_note_> open defecation *</_open_def_note_>
*<_open_def_note_> open_def brought in from rawdata *</_open_def_note_>
recode toilet_type (1/6=0) (7=1) (*=.), g(open_def)
*</_open_def_>

*<_sewer_>
*<_sewer_note_> sewer *</_sewer_note_>
*<_sewer_note_> sewer brought in from rawdata *</_sewer_note_>
recode toilet_type (1/3=1) (4/7=0) (*=.), g(sewer)
*</_sewer_>

*<_toilet_acc_>
*<_toilet_acc_note_> Access to flushed toilet  *</_toilet_acc_note_>
*<_toilet_acc_note_> toilet_acc brought in from rawdata *</_toilet_acc_note_>
g		toilet_acc = 0 if inlist(toilet_type,5,6,7,9)
replace	toilet_acc = 1 if inrange(toilet_type,1,4) & inlist(tioilet_use,1,2)
replace	toilet_acc = 2 if inrange(toilet_type,1,4) & inlist(tioilet_use,3,4)
*</_toilet_acc_>

*<_waste_>
*<_waste_note_> Main types of solid waste disposal *</_waste_note_>
*<_waste_note_> waste brought in from rawdata *</_waste_note_>
recode garbage_dumping (1=1) (2=6) (3=5) (4=9) (5/6=10) (*=.), g(waste)
*</_waste_>

/*******************************************************************************
*                                                                              *
                           EXPENDITURES
*                                                                              *
*******************************************************************************/

*  WATER    *
*___________*
*<_hwater_exp_>
*<_hwater_exp_note_> Total annual consumption of hot water supply *</_hwater_exp_note_>
*<_hwater_exp_note_> hwater_exp brought in from rawdata *</_hwater_exp_note_>
gen hwater_exp=.
*</_hwater_exp_>


*  HEATING  *
*___________*
*<_central_exp_>
*<_central_exp_note_> Total annual consumption of central heating *</_central_exp_note_>
*<_central_exp_note_> central_exp brought in from rawdata *</_central_exp_note_>
gen central_exp=.
*</_central_exp_>

*<_heating_exp_>
*<_heating_exp_note_> Total annual consumption of heating *</_heating_exp_note_>
*<_heating_exp_note_> heating_exp brought in from rawdata *</_heating_exp_note_>
egen heating_exp=rowtotal(central_exp hwater_exp), missing
*</_heating_exp_>


*  COOKING - OTHERS *
*___________*
*<_coal_exp_>
*<_coal_exp_note_> Total annual consumption of coal *</_coal_exp_note_>
*<_coal_exp_note_> coal_exp brought in from rawdata *</_coal_exp_note_>
gen coal_exp=.
*</_coal_exp_>

*<_ngas_exp _>
*<_ngas_exp _note_> Total annual consumption of network/natural gas *</_ngas_exp _note_>
*<_ngas_exp _note_> ngas_exp  brought in from rawdata *</_ngas_exp _note_>
gen ngas_exp =.
*</_ngas_exp _>

*<_garbage_exp_>
*<_garbage_exp_note_> Total annual consumption of garbage collection *</_garbage_exp_note_>
*<_garbage_exp_note_> garbage_exp brought in from rawdata *</_garbage_exp_note_>
gen garbage_exp=.
*</_garbage_exp_>

*<_othfuel_exp_>
*<_othfuel_exp_note_> Total annual consumption of all other fuels *</_othfuel_exp_note_>
*<_othfuel_exp_note_> othfuel_exp brought in from rawdata *</_othfuel_exp_note_>
gen othfuel_exp=.
*</_othfuel_exp_>

*<_othliq_exp _>
*<_othliq_exp _note_> Total annual consumption of other liquid fuels *</_othliq_exp _note_>
*<_othliq_exp _note_> othliq_exp  brought in from rawdata *</_othliq_exp _note_>
gen othliq_exp =.
*</_othliq_exp _>

*<_othsol_exp _>
*<_othsol_exp _note_> Total annual consumption of other solid fuels *</_othsol_exp _note_>
*<_othsol_exp _note_> othsol_exp  brought in from rawdata *</_othsol_exp _note_>
gen othsol_exp =.
*</_othsol_exp _>

*<_peat_exp _>
*<_peat_exp _note_> Total annual consumption of peat *</_peat_exp _note_>
*<_peat_exp _note_> peat_exp  brought in from rawdata *</_peat_exp _note_>
gen peat_exp =.
*</_peat_exp _>

*  WASTE    *
*___________*

*<_sewage_exp_>
*<_sewage_exp_note_> Total annual consumption of sewage collection *</_sewage_exp_note_>
*<_sewage_exp_note_> sewage_exp brought in from rawdata *</_sewage_exp_note_>
gen sewage_exp=.
*</_sewage_exp_>

*<_waste_exp _>
*<_waste_exp _note_> Total annual consumption of garbage and sewage collection *</_waste_exp _note_>
*<_waste_exp _note_> waste_exp  brought in from rawdata *</_waste_exp _note_>
egen waste_exp =rowtotal(garbage_exp sewage_exp), missing
*</_waste_exp _>



*  ENTERTEIMENT    *
*___________*
*<_tv_exp_>
*<_tv_exp_note_> Total consumption of TV broadcasting services  *</_tv_exp_note_>
*<_tv_exp_note_> tv_exp brought in from rawdata *</_tv_exp_note_>
gen tv_exp=.
*</_tv_exp_>

*<_tvintph_exp_>
*<_tvintph_exp_note_> Total consumption of tv, internet and telephone  *</_tvintph_exp_note_>
*<_tvintph_exp_note_> tvintph_exp brought in from rawdata *</_tvintph_exp_note_>
gen tvintph_exp=.
*</_tvintph_exp_>

* save for merging with other harmonized variables
save `hh_level_data', replace


*-------------------------------------------------------------------------------
* WORK ON NON-FOOD-LEVEL DATA
*-------------------------------------------------------------------------------
*<_cellphone_exp_>
*<_cellphone_exp_note_> Total annual consumption of cell phone services *</_cellphone_exp_note_>
*<_cellphone_exp_note_> cellphone_exp brought in from rawdata *</_cellphone_exp_note_>
egen cellphone_exp = rowtotal(nf_value nf_inkind_value) if nf_code==2503, missing
replace cellphone_exp = cellphone_exp * 12
*</_cellphone_exp_>

*<_comm_exp_>
*<_comm_exp_note_> Total consumption of all telecommunication services  *</_comm_exp_note_>
*<_comm_exp_note_> comm_exp brought in from rawdata *</_comm_exp_note_>
egen comm_exp = rowtotal(nf_value nf_inkind_value) if inrange(nf_code,2501,2509), missing
replace comm_exp = comm_exp * 12
*</_comm_exp_>

*<_diesel_exp _>
*<_diesel_exp _note_> Total annual consumption of diesel *</_diesel_exp _note_>
*<_diesel_exp _note_> diesel_exp  brought in from rawdata *</_diesel_exp _note_>
egen diesel_exp = rowtotal(nf_value nf_inkind_value) if nf_code==2412, missing
replace diesel_exp = diesel_exp * 12
*</_diesel_exp _>

*<_elec_exp_>
*<_elec_exp_note_> Total annual consumption of electricity *</_elec_exp_note_>
*<_elec_exp_note_> elec_exp brought in from rawdata *</_elec_exp_note_>
egen elec_exp = rowtotal(nf_value nf_inkind_value) if nf_code==2101, missing
replace elec_exp = elec_exp * 12
*</_elec_exp_>

*<_gasoline_exp _>
*<_gasoline_exp _note_> Total annual consumption of gasoline *</_gasoline_exp _note_>
*<_gasoline_exp _note_> gasoline_exp  brought in from rawdata *</_gasoline_exp _note_>
egen gasoline_exp = rowtotal(nf_value nf_inkind_value) if nf_code==2411, missing
replace gasoline_exp = gasoline_exp * 12
*</_gasoline_exp _>

*<_internet_exp_>
*<_internet_exp_note_> Total consumption of internet services  *</_internet_exp_note_>
*<_internet_exp_note_> internet_exp brought in from rawdata *</_internet_exp_note_>
egen internet_exp = rowtotal(nf_value nf_inkind_value) if nf_code==2505, missing
replace internet_exp = internet_exp * 12
*</_internet_exp_>

*  COOKING  *
*___________*
*<_kerosene_exp_>
*<_kerosene_exp_note_> Total annual consumption of kerosene *</_kerosene_exp_note_>
*<_kerosene_exp_note_> kerosene_exp brought in from rawdata *</_kerosene_exp_note_>
egen kerosene_exp = rowtotal(nf_value nf_inkind_value) if nf_code==2103, missing
replace kerosene_exp = kerosene_exp * 12
*</_kerosene_exp_>

*<_landphone_exp_>
*<_landphone_exp_note_> Total annual consumption of landline phone services *</_landphone_exp_note_>
*<_landphone_exp_note_> landphone_exp brought in from rawdata *</_landphone_exp_note_>
egen landphone_exp = rowtotal(nf_value nf_inkind_value) if nf_code==2502, missing
replace landphone_exp = landphone_exp * 12
*</_landphone_exp_>

*<_LPG_exp _>
*<_LPG_exp _note_> Total annual consumption of liquefied gas *</_LPG_exp _note_>
*<_LPG_exp _note_> LPG_exp  brought in from rawdata *</_LPG_exp _note_>
egen LPG_exp = rowtotal(nf_value nf_inkind_value) if nf_code==2106, missing
replace LPG_exp = LPG_exp * 12
*</_LPG_exp _>

*<_gas_exp_>
*<_gas_exp_note_> Total annual consumption of network/natural and liquefied gas *</_gas_exp_note_>
*<_gas_exp_note_> gas_exp brought in from rawdata *</_gas_exp_note_>
g gas_exp = LPG_exp
note gas_exp: LKA_2019_HIES does not have ngas_exp, so it is not included in this variable. However, LKA might not consume natural gas at all: https://data.nasdaq.com/data/BP/GAS_CONSUM_D_LKA-natural-gas-consumption-daily-average-sri-lanka
*</_gas_exp_>

*<_othhousing_exp_>
*<_othhousing_exp_note_> Total annual consumption of dwelling repair/maintenance *</_othhousing_exp_note_>
*<_othhousing_exp_note_> othhousing_exp brought in from rawdata *</_othhousing_exp_note_>
egen othhousing_exp = rowtotal(nf_value nf_inkind_value) if nf_code==3505, missing
replace othhousing_exp = othhousing_exp * 12
*</_othhousing_exp_>

*<_pwater_exp_>
* NOTE: PART 1 OF 2
*<_pwater_exp_note_> Total annual consumption of water supply/piped water  *</_pwater_exp_note_>
*<_pwater_exp_note_> pwater_exp brought in from rawdata *</_pwater_exp_note_>
egen pwater_exp1 = rowtotal(nf_value nf_inkind_value) if nf_code==2003, missing
replace pwater_exp1 = pwater_exp1 * 12
*</_pwater_exp_>

*<_tel_exp_>
*<_tel_exp_note_> Total consumption of all telephone services *</_tel_exp_note_>
*<_tel_exp_note_> tel_exp brought in from rawdata *</_tel_exp_note_>
egen tel_exp = rowtotal(nf_value nf_inkind_value) if inrange(nf_code,2502,2504), missing
replace tel_exp = tel_exp * 12
*</_tel_exp_>

*<_telefax_exp_>
*<_telefax_exp_note_> Total consumption of telefax services  *</_telefax_exp_note_>
*<_telefax_exp_note_> telefax_exp brought in from rawdata *</_telefax_exp_note_>
egen telefax_exp = rowtotal(nf_value nf_inkind_value) if nf_code==2501, missing
replace telefax_exp = telefax_exp * 12
*</_telefax_exp_>

*<_transfuel_exp_>
*<_transfuel_exp_note_> Total annual consumption of fuels for personal transportation *</_transfuel_exp_note_>
*<_transfuel_exp_note_> transfuel_exp brought in from rawdata *</_transfuel_exp_note_>
egen transfuel_exp = rowtotal(nf_value nf_inkind_value) if inlist(nf_code,2411,2412,2414), missing
replace transfuel_exp = transfuel_exp * 12
*</_transfuel_exp_>

*<_wood_exp_>
*<_wood_exp_note_> Total annual consumption of firewood *</_wood_exp_note_>
*<_wood_exp_note_> wood_exp brought in from rawdata *</_wood_exp_note_>
egen wood_exp = rowtotal(nf_value nf_inkind_value) if inlist(nf_code,2104,2105), missing
replace wood_exp = wood_exp * 12
*</_wood_exp_>

*<_dwelmat_exp_>
*<_dwelmat_exp_note_> Total annual consumption of materials for the maintenance and repair of the dwelling *</_dwelmat_exp_note_>
*<_dwelmat_exp_note_> dwelmat_exp brought in from rawdata *</_dwelmat_exp_note_>
egen dwelmat_exp = rowtotal(nf_value nf_inkind_value) if inlist(nf_code,3505), missing
replace dwelmat_exp = dwelmat_exp * 12
note dwelmat_exp: For LKA_2019_HIES, we used "Section 4.2 group 16. Other adhoc (rarely) expenses: 5. Maintenance & Repairing (Houses)".
*</_dwelmat_exp_>

*<_dwelothsvc_exp_>
*<_dwelothsvc_exp_note_> Total annual consumption of other services relating to the dwelling *</_dwelothsvc_exp_note_>
*<_dwelothsvc_exp_note_> dwelothsvc_exp brought in from rawdata *</_dwelothsvc_exp_note_>
egen dwelothsvc_exp = rowtotal(nf_value nf_inkind_value) if inlist(nf_code,3506), missing
replace dwelothsvc_exp = dwelothsvc_exp * 12
note dwelothsvc_exp: For LKA_2019_HIES, we used "Section 4.2 group 16. Other adhoc (rarely) expenses: 6. Purchased properties House".
*</_dwelothsvc_exp_>

*<_dwelsvc_exp_>
*<_dwelsvc_exp_note_> Total annual consumption of services for the maintenance and repair of the dwelling *</_dwelsvc_exp_note_>
*<_dwelsvc_exp_note_> dwelsvc_exp brought in from rawdata *</_dwelsvc_exp_note_>
egen dwelsvc_exp = rowtotal(nf_value nf_inkind_value) if inlist(nf_code,2909), missing
replace dwelsvc_exp = dwelsvc_exp * 12
note dwelsvc_exp: For LKA_2019_HIES, we used "Section 4.2 group 10. Household Services: 7. Payments for other household services".
*</_dwelsvc_exp_>

*<_liquid_exp_>
*<_liquid_exp_note_> Total annual consumption of all liquid fuels *</_liquid_exp_note_>
*<_liquid_exp_note_> liquid_exp brought in from rawdata *</_liquid_exp_note_>
egen liquid_exp = rowtotal(gasoline_exp diesel_exp kerosene_exp), mis
note liquid_exp: For LKA_2019_HIES, othliq_exp could not be created and is not included in this variable.
*</_liquid_exp_>

* sum expenditures to HH level and merge with other harmonized variables
*collapse (sum) *_exp pwater_exp1, by(countrycode year hhid)
*merge 1:1 hhid using `hh_level_data', assert(using match)
/*save `hh_level_data', replace
*/
tempfile hh_level_data
save `hh_level_data'

/*
* WORK ON FOOD-LEVEL DATA
*-------------------------------------------------------------------------------
* global path on Joe's computer
if ("`c(username)'"=="sunquat") {
	* housing data
	use "SEC_4_1_FOOD_EXP", clear
}
* global paths on WB computer
else {
	*<_Datalibweb request_>
	* housing data
	datalibweb, country(`code') year(`year') type(SARRAW) filename(SEC_4_1_FOOD_EXP.dta)
	*</_Datalibweb request_>
}
*/

*<_pwater_exp_>
* NOTE: PART 2 OF 2
*<_pwater_exp_note_> Total annual consumption of water supply/piped water  *</_pwater_exp_note_>
*<_pwater_exp_note_> pwater_exp brought in from rawdata *</_pwater_exp_note_>
*egen pwater_exp2 = rowtotal(value inkind_value) if code==1812, missing
*replace pwater_exp2 = pwater_exp2 * 12
gen pwater_exp2=.
*</_pwater_exp_>

* sum expenditures to HH level and merge with other harmonized variables
*collapse (sum) pwater_exp2, by(countrycode year hhid)
*merge 1:1 hhid using `hh_level_data', nogen assert(match)
* combine 2 components of pwater_exp
egen pwater_exp = rowtotal(pwater_exp1 pwater_exp2), missing

*<_water_exp_>
*<_water_exp_note_> Total annual consumption of water supply and hot water *</_water_exp_note_>
*<_water_exp_note_> water_exp brought in from rawdata *</_water_exp_note_>
g water_exp = pwater_exp
note water_exp: For LKA_2019_HIES, hwater_exp is not asked in the questionnaire, and is not included in this variable.
*</_water_exp_>

*<_solid_exp _>
*<_solid_exp _note_> Total annual consumption of all solid fuels *</_solid_exp _note_>
*<_solid_exp _note_> solid_exp  brought in from  *</_solid_exp _note_>
egen solid_exp= rowtotal(wood_exp coal_exp peat_exp othsol_exp), missing
*</_solid_exp _>

*  OTHERS    *
*___________*
*<_utl_exp_>
*<_utl_exp_note_> Total annual consumption of all utilities excluding telecom and other housing *</_utl_exp_note_>
*<_utl_exp_note_> utl_exp brought in from rawdata *</_utl_exp_note_>
egen utl_exp=rowtotal(elec_exp gas_exp liquid_exp solid_exp central_exp water_exp waste_exp othfuel_exp), missing
*</_utl_exp_>



/*******************************************************************************
*                                                                              *
                           FINAL CLEANING 
*                                                                              *
*******************************************************************************/

*<_Keep variables_>
order countrycode year hhid weight weighttype
sort hhid 
*</_Keep variables_>

*<_Save data file_>
quietly do 	"$rootdofiles/_aux/Labels_GMD2.0.do"
save "$output/`filename'.dta", replace
*</_Save data file_>
