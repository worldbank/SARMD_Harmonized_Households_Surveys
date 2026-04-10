/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   BTN_2022_BLSS_v01_M_v01_A_SARMD_UTL.do	</_Program name_>
<_Application_>    STATA 16.0	<_Application_>
<_Author(s)_>      jogreen@worldbank.org	</_Author(s)_>
<_Date created_>   11-28-2022	</_Date created_>
<_Date modified>   11-28-2022	</_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        BTN	</_Country_>
<_Survey Title_>   BLSS	</_Survey Title_>
<_Survey Year_>    2022	</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:	11-28-2022
File:	BTN_2022_BLSS_v01_M_v01_A_SARMD_UTL.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>
clear all
set more off
local code         "BTN"
local year         "2022"
local survey       "BLSS"
local vm           "01"
local va           "02"
local type         "SARMD"
global module       	"UTL"
local yearfolder    "`code'_`year'_`survey'"
local SARMDfolder    "`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'"
local filename      "`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'_${module}"
glo output          "${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\\Data\Harmonized" 
tempfile			hh_level_data


use "${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata\block6_pro_cleaned.dta", clear
tempfile household_level_data
save `household_level_data'

* merge in main data
datalibweb, country(`code') year(`year') type(SARRAW) filename(`yearfolder'_v`vm'_M.dta) local localpath(${rootdatalib})
merge m:1 interview__id using `household_level_data', nogen assert(match)
tempfile individual_level_data
save `individual_level_data' 
	
use "${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\Data\Harmonized\\`yearfolder'_v`vm'_M_v`va'_A_`type'_IND.dta" 
merge 1:1 hhid pid using `individual_level_data', nogen



/*******************************************************************************
*                                                                              *
                           STANDARD SURVEY MODULE
*                                                                              *
*******************************************************************************/
*<_countrycode_>
*<_countrycode_note_> country code *</_countrycode_note_>
*<_countrycode_note_> countrycode brought in from rawdata *</_countrycode_note_>
cap gen countrycode="`code'"
*</_countrycode_>

*<_year_>
*<_year_note_> Year *</_year_note_>
*<_year_note_> year brought in from rawdata *</_year_note_>
confirm var year
*</_year_>

*<_hhid_>
*<_hhid_note_> Household identifier  *</_hhid_note_>
*<_hhid_note_> hhid brought in from rawdata *</_hhid_note_>
confirm var hhid
*</_hhid_>


*******************************************************************************
/*******************************************************************************
*                                                                              *
                           ALL UTILITIES
*                                                                              *
*******************************************************************************/

*<_cooksource_>
*<_cooksource_note_> Main cooking fuel *</_cooksource_note_>
*<_cooksource_note_> cooksource brought in from rawdata *</_cooksource_note_>
g		cooksource = 1 if hs31__3==1
replace	cooksource = 2 if hs31__5==1
replace	cooksource = 3 if hs31__4==1
replace	cooksource = 4 if hs31__2==1
replace	cooksource = 5 if hs31__1==1
recode	cooksource (.=9) if hs31__6==1 | hs31__7==1 | hs31__96==1
*</_cooksource_>

*<_dwelmat_exp_>
*<_dwelmat_exp_note_> Total annual consumption of materials for the maintenance and repair of the dwelling *</_dwelmat_exp_note_>
*<_dwelmat_exp_note_> dwelmat_exp brought in from rawdata *</_dwelmat_exp_note_>
gen dwelmat_exp = hs37a
note dwelmat_exp: For BTN_2022_BLSS, associated labor wages were included in this figure.
*</_dwelmat_exp_>

*<_elec_acc_>
*<_elec_acc_note_> Connection to electricity in dwelling *</_elec_acc_note_>
*<_elec_acc_note_> elec_acc brought in from rawdata *</_elec_acc_note_>
cap gen elec_acc=elec_acc
recode hs27 (1=1) (2/3=2) (4=4) (*=.), g(elec_acc)
*</_elec_acc_>

*<_elechr_acc_>
*<_elechr_acc_note_> Electricity availability (hr/day) *</_elechr_acc_note_>
*<_elechr_acc_note_> elechr_acc brought in from rawdata *</_elechr_acc_note_>
* convert to availability/day = 24 total hours - (24 hours of max interruption * (% of months affected * % of hours affected each day of those months))
recode hs28b (25/72=24), g(avg_interruption)
gen			elechr_acc = 24 - (24 * (hs28a/12 * avg_interruption/24)) if inrange(hs28a,1,12)
replace		elechr_acc = 24 if inlist(hs28a,-13,0)
* note some 116 households didn't respond to hs28a "months of significant interruptions", so their availability could not be calculated.
*</_elechr_acc_>

*<_electricity_>
*<_electricity_note_> Access to electricity in dwelling *</_electricity_note_>
*<_electricity_note_> electricity brought in from rawdata *</_electricity_note_>
cap gen electricity=electricity
*</_electricity_>

*<_electyp_>
*<_electyp_note_> Lighting and/or electricity – type of *</_electyp_note_>
*<_electyp_note_> electyp brought in from rawdata *</_electyp_note_>
recode hs30 (1=1) (2=3) (3/4 6=4) (5=2) (96=4), g(electyp)
replace electyp = 4 if hs31__3==1 | hs31__4==1 | hs31__6==1 | hs31__7==1 | hs31__96==1
replace electyp = 2 if hs30Oth=="Diesel" | hs31__1==1 | hs31__5==1
replace electyp = 1 if hs31__2==1
*</_electyp_>

*<_lightsource_>
*<_lightsource_note_> Main source of lighting  *</_lightsource_note_>
*<_lightsource_note_> lightsource brought in from rawdata *</_lightsource_note_>
recode hs30 (1 4 5=1) (2=2) (3=9) (6=3) (96=9) (*=.), g(lightsource)
*</_lightsource_>

*<_gas_>
*<_gas_note_> Connection to gas/Usage of gas *</_gas_note_>
*<_gas_note_> gas brought in from rawdata *</_gas_note_>
g gas = 2 if pr3__4==1 | hs31__1==1 | hs32==4 | hs33__4==1
*</_gas_>

*<_LPG_exp _>
*<_LPG_exp _note_> Total annual consumption of liquefied gas *</_LPG_exp _note_>
*<_LPG_exp _note_> LPG_exp  brought in from rawdata *</_LPG_exp _note_>
gen LPG_exp = hs33e
note LPG_exp: For BTN_2022_BLSS, expenditure on LPG gas was only asked in the context of cooking gas.
*</_LPG_exp _>

*<_heatsource_>
*<_heatsource_note_> Main source of heating  *</_heatsource_note_>
*<_heatsource_note_> heatsource brought in from rawdata *</_heatsource_note_>
recode hs32 (1 6=1) (2=4) (3=2) (4=5) (5=9) (7=10) (96=9) (*=.), g(heatsource)
*</_heatsource_>

*<_imp_san_rec_>
*<_imp_san_rec_note_> Improved sanitation facility recommended estimate (not considering sharing) *</_imp_san_rec_note_>
*<_imp_san_rec_note_> imp_san_rec brought in from rawdata *</_imp_san_rec_note_>
clonevar imp_san_rec=sar_improved_toilet
*</_imp_san_rec_>

*<_imp_wat_rec_>
*<_imp_wat_rec_note_> Improved water recommended estimate 
*<_imp_wat_rec_note_> imp_wat_rec brought in from rawdata 
clonevar imp_wat_rec=sar_improved_water
*</_imp_wat_rec_>

*<_open_def_>
*<_open_def_note_> open defecation *</_open_def_note_>
*<_open_def_note_> open_def brought in from rawdata *</_open_def_note_>
recode hs24 (1/7=0) (8=1) (*=.), g(open_def)
*</_open_def_>

*<_water_source_>
*<_water_source_note_> Sources of drinking water *</_water_source_note_>
*<_water_source_note_> water_source brought in from rawdata *</_water_source_note_>
recode hs19 (1=1) (2=2) (3=3) (4=4) (5=5) (6=10) (7=6) (8=9) (9/10=8) (11=12) (12=13) (13=7) (96=14) (*=.), g(water_source)
*</_water_source_>

*<_piped _>
*<_piped _note_> Access to piped water  *</_piped _note_>
*<_piped _note_> piped  brought in from rawdata *</_piped _note_>
recode water_source (1/3=1) (4/14=0), g(piped)
*</_piped _>

*<_piped_to_prem_>
*<_piped_to_prem_note_> Access to piped water on premises *<_piped_to_prem_note_> piped_to_prem brought in from rawdata 
recode water_source (1/2=1) (3/14=0), g(piped_to_prem)
*</_piped_to_prem_>

*<_sanitation_source_>
*<_sanitation_source_note_> Sources of sanitation facilities *</_sanitation_source_note_>
*<_sanitation_source_note_> sanitation_source brought in from rawdata *</_sanitation_source_note_>
recode hs24 (1=1) (2=3) (3=4) (4=9) (5=5) (6=6) (7=10) (8=13) (96=14) (*=.), g(sanitation_source)
*</_sanitation_source_>

*<_sanitation_original_>
*<_sanitation_original_note_> Original survey response in string for sanitation_source variable *</_sanitation_original_note_>
*<_sanitation_original_note_> sanitation_original brought in from rawdata *</_sanitation_original_note_>
clonevar sanitation_original=toilet_orig
*</_sanitation_original_>

*<_sewer_>
*<_sewer_note_> sewer *</_sewer_note_>
*<_sewer_note_> sewer brought in from rawdata *</_sewer_note_>
recode hs24 (1=1) (2/8 96=0), g(sewer)
*</_sewer_>

*<_toilet_acc_>
*<_toilet_acc_note_> Access to flushed toilet  *</_toilet_acc_note_>
*<_toilet_acc_note_> toilet_acc brought in from rawdata *</_toilet_acc_note_>
recode hs24 (1/4=3) (5/8 96=0) (*=.), g(toilet_acc)
*</_toilet_acc_>

*<_w_30m_>
*<_w_30m_note_> Access to water within 30 minutes *</_w_30m_note_>
*<_w_30m_note_> w_30m brought in from rawdata *</_w_30m_note_>
g		w_30m = 1 if imp_wat_rec==1 & inlist(hs19,1,2) | inrange(hs20b,0,30)
replace	w_30m = 0 if imp_wat_rec==1 & hs20b>30 & ~missing(hs20b)
*</_w_30m_>

*<_w_avail_>
*<_w_avail_note_> Water is available when needed *</_w_avail_note_>
*<_w_avail_note_> w_avail brought in from rawdata *</_w_avail_note_>
g		w_avail = 1 if imp_wat_rec==1 & hs22==1
replace	w_avail = 0 if imp_wat_rec==1 & hs22==2
*</_w_avail_>

*<_water_original_>
*<_water_original_note_> Original survey response in string for water_source variable *</_water_original_note_>
*<_water_original_note_> water_original brought in from rawdata *</_water_original_note_>
clonevar water_original=water_orig
*</_water_original_>

*<_watertype_quest_>
*<_watertype_quest_note_> Type of water questions used in the survey *</_watertype_quest_note_>
*<_watertype_quest_note_> watertype_quest brought in from rawdata *</_watertype_quest_note_>
g watertype_quest = 1
*</_watertype_quest_>

*<_wood_exp_>
*<_wood_exp_note_> Total annual consumption of firewood *</_wood_exp_note_>
*<_wood_exp_note_> wood_exp brought in from rawdata *</_wood_exp_note_>
g backload_wood_exp = hs34a*hs34b*12
g truckload_wood_exp = hs34c*hs34d
egen wood_exp = rowtotal(backload_wood_exp truckload_wood_exp), miss
replace wood_exp = 0 if hs34==4
*</_wood_exp_>


* collapse variables to HH-level
collapse	(firstnm) cooksource dwelmat_exp elec_acc elechr_acc electricity electyp lightsource gas LPG_exp heatsource imp_san_rec imp_wat_rec open_def water_source piped piped_to_prem sanitation_source sanitation_original sewer toilet_acc w_30m w_avail water_original watertype_quest wood_exp	///
			, by(countrycode year hhid)

tempfile all_hh_level_vars
save `all_hh_level_vars'


*-------------------------------------------------------------------------------
* block 9: non-food data
if ("`c(username)'"=="sunquat") {
	use "${rootdatalib}/BTN/BTN_2022_BLSS/BTN_2022_BLSS_v01_M/Data/Stata/block9_nonfood", clear
}
else {
	*<_Datalibweb request_>
	datalibweb, country(`code') year(`year') type(SARRAW) filename(block9_nonfood.dta) local localpath(${rootdatalib})
	*</_Datalibweb request_>
}
	


*<_comm_exp_>
*<_comm_exp_note_> Total consumption of all telecommunication services  *</_comm_exp_note_>
*<_comm_exp_note_> comm_exp brought in from rawdata *</_comm_exp_note_>
gen comm_exp = value if code==3125
replace comm_exp = 12*value if period==2
*</_comm_exp_>

*<_transfuel_exp_>
*<_transfuel_exp_note_> Total annual consumption of fuels for personal transportation *</_transfuel_exp_note_>
*<_transfuel_exp_note_> transfuel_exp brought in from rawdata *</_transfuel_exp_note_>
gen transfuel_exp = value if code==3119
replace transfuel_exp = 12*value if period==2
*</_transfuel_exp_>

*<_tv_exp_>
*<_tv_exp_note_> Total consumption of TV broadcasting services  *</_tv_exp_note_>
*<_tv_exp_note_> tv_exp brought in from rawdata *</_tv_exp_note_>
gen tv_exp = value if code==3325
replace tv_exp = 12*value if period==2
*</_tv_exp_>

* aggregate to HH-level
rename interview__id hhid
collapse (sum) comm_exp transfuel_exp tv_exp, by(hhid)
* merge with other HH-level harmonized variables
merge 1:1 hhid using `all_hh_level_vars', nogen assert(match)


/*******************************************************************************
*                                                                              *
				ALL OTHER VARIABLES THAT CANNOT BE CREATED
*                                                                              *
*******************************************************************************/
*<_pipedwater_acc_>
*<_pipedwater_acc_note_> Access to piped water   *</_pipedwater_acc_note_>
*<_pipedwater_acc_note_> pipedwater_acc brought in from rawdata *</_pipedwater_acc_note_>
gen pipedwater_acc=.a
*</_pipedwater_accs_>

*<_central_acc_>
*<_central_acc_note_> Access to central heating  *</_central_acc_note_>
*<_central_acc_note_> central_acc brought in from rawdata *</_central_acc_note_>
gen central_acc=.b
*</_central_acc_>

*<_waste_>
*<_waste_note_> Main types of solid waste disposal *</_waste_note_>
*<_waste_note_> waste brought in from rawdata *</_waste_note_>
gen waste=.b
*</_waste_>

*<_hwater_exp_>
*<_hwater_exp_note_> Total annual consumption of hot water supply *</_hwater_exp_note_>
*<_hwater_exp_note_> hwater_exp brought in from rawdata *</_hwater_exp_note_>
gen hwater_exp=.b
*</_hwater_exp_>

*<_central_exp_>
*<_central_exp_note_> Total annual consumption of central heating *</_central_exp_note_>
*<_central_exp_note_> central_exp brought in from rawdata *</_central_exp_note_>
gen central_exp=.b
*</_central_exp_>

*<_heating_exp_>
*<_heating_exp_note_> Total annual consumption of heating *</_heating_exp_note_>
*<_heating_exp_note_> heating_exp brought in from rawdata *</_heating_exp_note_>
gen heating_exp=.b
*</_heating_exp_>

*<_coal_exp_>
*<_coal_exp_note_> Total annual consumption of coal *</_coal_exp_note_>
*<_coal_exp_note_> coal_exp brought in from rawdata *</_coal_exp_note_>
gen coal_exp=.b
*</_coal_exp_>

*<_gas_exp _>
*<_gas_exp _note_> Total annual consumption of network/natural and liquefied gas *</_gas_exp _note_>
*<_gas_exp _note_> gas_exp  brought in from rawdata *</_gas_exp _note_>
gen gas_exp =.b
*</_gas_exp _>

*<_ngas_exp _>
*<_ngas_exp _note_> Total annual consumption of network/natural gas *</_ngas_exp _note_>
*<_ngas_exp _note_> ngas_exp  brought in from rawdata *</_ngas_exp _note_>
gen ngas_exp =.b
*</_ngas_exp _>

*<_garbage_exp_>
*<_garbage_exp_note_> Total annual consumption of garbage collection *</_garbage_exp_note_>
*<_garbage_exp_note_> garbage_exp brought in from rawdata *</_garbage_exp_note_>
gen garbage_exp=.b
*</_garbage_exp_>

*<_othfuel_exp_>
*<_othfuel_exp_note_> Total annual consumption of all other fuels *</_othfuel_exp_note_>
*<_othfuel_exp_note_> othfuel_exp brought in from rawdata *</_othfuel_exp_note_>
gen othfuel_exp=.b
*</_othfuel_exp_>

*<_othliq_exp _>
*<_othliq_exp _note_> Total annual consumption of other liquid fuels *</_othliq_exp _note_>
*<_othliq_exp _note_> othliq_exp  brought in from rawdata *</_othliq_exp _note_>
gen othliq_exp =.b
*</_othliq_exp _>

*<_othsol_exp _>
*<_othsol_exp _note_> Total annual consumption of other solid fuels *</_othsol_exp _note_>
*<_othsol_exp _note_> othsol_exp  brought in from rawdata *</_othsol_exp _note_>
gen othsol_exp =.b
*</_othsol_exp _>

*<_peat_exp _>
*<_peat_exp _note_> Total annual consumption of peat *</_peat_exp _note_>
*<_peat_exp _note_> peat_exp  brought in from rawdata *</_peat_exp _note_>
gen peat_exp =.b
*</_peat_exp _>

*<_sewage_exp_>
*<_sewage_exp_note_> Total annual consumption of sewage collection *</_sewage_exp_note_>
*<_sewage_exp_note_> sewage_exp brought in from rawdata *</_sewage_exp_note_>
gen sewage_exp=.b
*</_sewage_exp_>

*<_waste_exp _>
*<_waste_exp _note_> Total annual consumption of garbage and sewage collection *</_waste_exp _note_>
*<_waste_exp _note_> waste_exp  brought in from rawdata *</_waste_exp _note_>
gen waste_exp =.b
*</_waste_exp _>

*<_tvintph_exp_>
*<_tvintph_exp_note_> Total consumption of tv, internet and telephone  *</_tvintph_exp_note_>
*<_tvintph_exp_note_> tvintph_exp brought in from rawdata *</_tvintph_exp_note_>
gen tvintph_exp=.b
*</_tvintph_exp_>
	
*<_cellphone_exp_>
*<_cellphone_exp_note_> Total annual consumption of cell phone services *</_cellphone_exp_note_>
*<_cellphone_exp_note_> cellphone_exp brought in from rawdata *</_cellphone_exp_note_>
gen cellphone_exp =.b
*</_cellphone_exp_>

*<_diesel_exp _>
*<_diesel_exp _note_> Total annual consumption of diesel *</_diesel_exp _note_>
*<_diesel_exp _note_> diesel_exp  brought in from rawdata *</_diesel_exp _note_>
gen diesel_exp = .b
*</_diesel_exp _>

*<_elec_exp_>
*<_elec_exp_note_> Total annual consumption of electricity *</_elec_exp_note_>
*<_elec_exp_note_> elec_exp brought in from rawdata *</_elec_exp_note_>
gen elec_exp = .b
*</_elec_exp_>

*<_gasoline_exp _>
*<_gasoline_exp _note_> Total annual consumption of gasoline *</_gasoline_exp _note_>
*<_gasoline_exp _note_> gasoline_exp  brought in from rawdata *</_gasoline_exp _note_>
gen gasoline_exp = .b
*</_gasoline_exp _>

*<_internet_exp_>
*<_internet_exp_note_> Total consumption of internet services  *</_internet_exp_note_>
*<_internet_exp_note_> internet_exp brought in from rawdata *</_internet_exp_note_>
gen internet_exp = .b
*</_internet_exp_>

*<_kerosene_exp_>
*<_kerosene_exp_note_> Total annual consumption of kerosene *</_kerosene_exp_note_>
*<_kerosene_exp_note_> kerosene_exp brought in from rawdata *</_kerosene_exp_note_>
gen kerosene_exp = .b
*</_kerosene_exp_>

*<_landphone_exp_>
*<_landphone_exp_note_> Total annual consumption of landline phone services *</_landphone_exp_note_>
*<_landphone_exp_note_> landphone_exp brought in from rawdata *</_landphone_exp_note_>
gen landphone_exp = .b
*</_landphone_exp_>

*<_othhousing_exp_>
*<_othhousing_exp_note_> Total annual consumption of dwelling repair/maintenance *</_othhousing_exp_note_>
*<_othhousing_exp_note_> othhousing_exp brought in from rawdata *</_othhousing_exp_note_>
gen othhousing_exp = .b
*</_othhousing_exp_>

*<_pwater_exp_>
*<_pwater_exp_note_> Total annual consumption of water supply/piped water  *</_pwater_exp_note_>
*<_pwater_exp_note_> pwater_exp brought in from rawdata *</_pwater_exp_note_>
gen pwater_exp1 = .b
*</_pwater_exp_>

*<_tel_exp_>
*<_tel_exp_note_> Total consumption of all telephone services *</_tel_exp_note_>
*<_tel_exp_note_> tel_exp brought in from rawdata *</_tel_exp_note_>
gen tel_exp = .b
*</_tel_exp_>

*<_telefax_exp_>
*<_telefax_exp_note_> Total consumption of telefax services  *</_telefax_exp_note_>
*<_telefax_exp_note_> telefax_exp brought in from rawdata *</_telefax_exp_note_>
gen telefax_exp = .b
*</_telefax_exp_>

*<_dwelothsvc_exp_>
*<_dwelothsvc_exp_note_> Total annual consumption of other services relating to the dwelling *</_dwelothsvc_exp_note_>
*<_dwelothsvc_exp_note_> dwelothsvc_exp brought in from rawdata *</_dwelothsvc_exp_note_>
gen dwelothsvc_exp = .b
*</_dwelothsvc_exp_>

*<_dwelsvc_exp_>
*<_dwelsvc_exp_note_> Total annual consumption of services for the maintenance and repair of the dwelling *</_dwelsvc_exp_note_>
*<_dwelsvc_exp_note_> dwelsvc_exp brought in from rawdata *</_dwelsvc_exp_note_>
gen dwelsvc_exp = .b
*</_dwelsvc_exp_>

*<_liquid_exp_>
*<_liquid_exp_note_> Total annual consumption of all liquid fuels *</_liquid_exp_note_>
*<_liquid_exp_note_> liquid_exp brought in from rawdata *</_liquid_exp_note_>
gen liquid_exp = .b
*</_liquid_exp_>

*<_water_exp_>
*<_water_exp_note_> Total annual consumption of water supply and hot water *</_water_exp_note_>
*<_water_exp_note_> water_exp brought in from rawdata *</_water_exp_note_>
g water_exp = .b
*</_water_exp_>

*<_solid_exp _>
*<_solid_exp _note_> Total annual consumption of all solid fuels *</_solid_exp _note_>
*<_solid_exp _note_> solid_exp  brought in from  *</_solid_exp _note_>
gen solid_exp= .b
*</_solid_exp _>

*<_utl_exp_>
*<_utl_exp_note_> Total annual consumption of all utilities excluding telecom and other housing *</_utl_exp_note_>
*<_utl_exp_note_> utl_exp brought in from rawdata *</_utl_exp_note_>
gen utl_exp=.b
*</_utl_exp_>



/*******************************************************************************
*                                                                              *
                           FINAL CLEANING 
*                                                                              *
*******************************************************************************/

*<_Keep variables_>
*keep countrycode year hhid pid weight weighttype cellphone_exp central_acc central_exp coal_exp comm_exp cooksource diesel_exp dwelmat_exp dwelothsvc_exp dwelsvc_exp elec_acc elec_exp elechr_acc electricity electyp garbage_exp gas gas_exp gasoline_exp heating_exp heatsource hwater_exp imp_san_rec imp_wat_rec internet_exp kerosene_exp landphone_exp lightsource liquid_exp LPG_exp ngas_exp open_def othfuel_exp othhousing_exp othliq_exp othsol_exp peat_exp piped piped_to_prem pwater_exp sanitation_original sanitation_source sewage_exp sewer solid_exp tel_exp telefax_exp toilet_acc transfuel_exp tv_exp tvintph_exp utl_exp w_30m w_avail waste waste_exp water_exp water_original water_source watertype_quest wood_exp pipedwater_acc
order countrycode year hhid
sort hhid 
isid hhid
gen relationharm=1
gen pid="01"
*--------------------------------------
	preserve
	tempfile individual_level_data
	* weights
	datalibweb, country(`code') year(`year') type(SARRAW) filename(weights.dta) local localpath(${rootdatalib})
	gen hhid=interview__id
	save `individual_level_data', replace
	restore
	merge 1:1 hhid using `individual_level_data', nogen assert(match)
*</_Keep variables_>

*<_Save data file_>
quietly do 	"$rootdofiles\_aux\Labels_GMD2.0.do"
save "$output\\`filename'.dta", replace
*</_Save data file_>
