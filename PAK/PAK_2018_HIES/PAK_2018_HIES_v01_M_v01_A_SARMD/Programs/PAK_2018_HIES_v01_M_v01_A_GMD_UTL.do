/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   PAK_2018_PSLM_v_M_v_A_GMD_UTL.do	</_Program name_>
<_Application_>    STATA 16.0	<_Application_>
<_Author(s)_>      Navishti Das and Javier Parada	</_Author(s)_>
<_Date created_>   03-03-2019	</_Date created_>
<_Date modified>   18 Feb 2021	</_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        PAK	</_Country_>
<_Survey Title_>   PSLM	</_Survey Title_>
<_Survey Year_>    2018	</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:	03-03-2019
File:	PAK_2018_PSLM_v_M_v_A_GMD_UTL.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>;
#delimit ;
clear all;
set more off;

local code         "PAK";
local year         "2018";
local survey       "PSLM";
local vm           "";
local va           "";
local type         "SARMD";
local yearfolder   "PAK_2018_PSLM";
local gmdfolder    "PAK_2018_PSLM_v_M_v_A_GMD";
local filename     "PAK_2018_PSLM_v_M_v_A_GMD_UTL";
*</_Program setup_>;

*<_Folder creation_>;
cap mkdir "$rootdatalib\GMD";
cap mkdir "$rootdatalib\GMD\\`code'";
cap mkdir "$rootdatalib\GMD\\`code'\\`yearfolder'";
cap mkdir "$rootdatalib\GMD\\`code'\\`yearfolder'\\`gmdfolder'";
cap mkdir "$rootdatalib\GMD\\`code'\\`yearfolder'\\`gmdfolder'\Data";
cap mkdir "$rootdatalib\GMD\\`code'\\`yearfolder'\\`gmdfolder'\Data\Harmonized";
*</_Folder creation_>;

*<_Datalibweb request_>;
#delimit cr
datalibweb, country(`code') year(`year') type(`type') survey(`survey') vermast(`vm') veralt(`va') mod(IND) clear 
#delimit ;
*</_Datalibweb request_>;

*<_countrycode_>;
*<_countrycode_note_> country code *</_countrycode_note_>;
*<_countrycode_note_> countrycode brought in from SARMD *</_countrycode_note_>;
*replace code=countrycode;;
*</_countrycode_>;

*<_year_>;
*<_year_note_> Year *</_year_note_>;
*<_year_note_> year brought in from SARMD *</_year_note_>;
replace year=year;;
*</_year_>;

*<_hhid_>;
*<_hhid_note_> Household identifier  *</_hhid_note_>;
*<_hhid_note_> hhid brought in from SARMD *</_hhid_note_>;
clonevar hhid=idh;;
*</_hhid_>;

*<_pid_>;
*<_pid_note_> Personal identifier  *</_pid_note_>;
*<_pid_note_> pid brought in from rawdata *</_pid_note_>;
clonevar pid  = idp;;
*</_pid_>;

*<_weight_>;
*<_weight_note_> Household weight *</_weight_note_>;
*<_weight_note_> weight brought in from rawdata *</_weight_note_>;
clonevar  weights=wgt;;
*</_weight_>;

*<_weighttype_>;
*<_weighttype_note_> Weight type (frequency, probability, analytical, importance) *</_weighttype_note_>;
*<_weighttype_note_> weighttype brought in from rawdata *</_weighttype_note_>;
gen weighttype = "IW";;
*</_weighttype_>;

*<_cellphone_exp_>;
*<_cellphone_exp_note_> Total annual consumption of cell phone services *</_cellphone_exp_note_>;
*<_cellphone_exp_note_> cellphone_exp brought in from  *</_cellphone_exp_note_>;
gen cellphone_exp=.;
*</_cellphone_exp_>;

*<_central_acc_>;
*<_central_acc_note_> Access to central heating  *</_central_acc_note_>;
*<_central_acc_note_> central_acc brought in from  *</_central_acc_note_>;
gen central_acc=.;
*</_central_acc_>;

*<_central_exp_>;
*<_central_exp_note_> Total annual consumption of central heating *</_central_exp_note_>;
*<_central_exp_note_> central_exp brought in from  *</_central_exp_note_>;
gen central_exp=.;
*</_central_exp_>;

*<_coal_exp_>;
*<_coal_exp_note_> Total annual consumption of coal *</_coal_exp_note_>;
*<_coal_exp_note_> coal_exp brought in from  *</_coal_exp_note_>;
*gen coal_exp=coal_exp;
*</_coal_exp_>;

*<_comm_exp_>;
*<_comm_exp_note_> Total consumption of all telecommunication services  *</_comm_exp_note_>;
*<_comm_exp_note_> comm_exp brought in from  *</_comm_exp_note_>;
gen comm_exp=.;
*</_comm_exp_>;

*<_cooksource_>;
*<_cooksource_note_> Main cooking fuel *</_cooksource_note_>;
*<_cooksource_note_> cooksource brought in from  *</_cooksource_note_>;
*clonevar cooksource=cooksource;
*</_cooksource_>;

*<_diesel_exp _>;
*<_diesel_exp _note_> Total annual consumption of diesel *</_diesel_exp _note_>;
*<_diesel_exp _note_> diesel_exp  brought in from  *</_diesel_exp _note_>;
gen  diesel_exp =.;
*</_diesel_exp _>;

*<_dwelmat_exp_>;
*<_dwelmat_exp_note_> Total annual consumption of materials for the maintenance and repair of the dwelling *</_dwelmat_exp_note_>;
*<_dwelmat_exp_note_> dwelmat_exp brought in from  *</_dwelmat_exp_note_>;
gen dwelmat_exp=.;
*</_dwelmat_exp_>;

*<_dwelothsvc_exp_>;
*<_dwelothsvc_exp_note_> Total annual consumption of other services relating to the dwelling *</_dwelothsvc_exp_note_>;
*<_dwelothsvc_exp_note_> dwelothsvc_exp brought in from  *</_dwelothsvc_exp_note_>;
gen dwelothsvc_exp=.;
*</_dwelothsvc_exp_>;

*<_dwelsvc_exp_>;
*<_dwelsvc_exp_note_> Total annual consumption of services for the maintenance and repair of the dwelling *</_dwelsvc_exp_note_>;
*<_dwelsvc_exp_note_> dwelsvc_exp brought in from  *</_dwelsvc_exp_note_>;
gen dwelsvc_exp=.;
*</_dwelsvc_exp_>;

*<_elec_acc_>;
*<_elec_acc_note_> Connection to electricity in dwelling *</_elec_acc_note_>;
*<_elec_acc_note_> elec_acc brought in from  *</_elec_acc_note_>;
*gen elec_acc=elec_acc;
*</_elec_acc_>;

*<_elec_exp_>;
*<_elec_exp_note_> Total annual consumption of electricity *</_elec_exp_note_>;
*<_elec_exp_note_> elec_exp brought in from  *</_elec_exp_note_>;
*gen elec_exp=elec_exp;
*</_elec_exp_>;

*<_elechr_acc_>;
*<_elechr_acc_note_> Electricity availability (hr/day) *</_elechr_acc_note_>;
*<_elechr_acc_note_> elechr_acc brought in from  *</_elechr_acc_note_>;
gen elechr_acc=.;
*</_elechr_acc_>;

*<_electricity_>;
*<_electricity_note_> Access to electricity in dwelling *</_electricity_note_>;
*<_electricity_note_> electricity brought in from SARMD *</_electricity_note_>;
*rename elect  electricity ;
*</_electricity_>;

*<_electyp_>;
*<_electyp_note_> Lighting and/or electricity – type of *</_electyp_note_>;
*<_electyp_note_> electyp brought in from  *</_electyp_note_>;
*gen electyp=electyp;
*</_electyp_>;

*<_garbage_exp_>;
*<_garbage_exp_note_> Total annual consumption of garbage collection *</_garbage_exp_note_>;
*<_garbage_exp_note_> garbage_exp brought in from  *</_garbage_exp_note_>;
*gen garbage_exp=garbage_exp;
*</_garbage_exp_>;

*<_gas_>;
*<_gas_note_> Connection to gas/Usage of gas *</_gas_note_>;
*<_gas_note_> gas brought in from  *</_gas_note_>;
*gen gas=gas;
*</_gas_>;

*<_gas_exp_>;
*<_gas_exp_note_> Total annual consumption of network/natural and liquefied gas *</_gas_exp_note_>;
*<_gas_exp_note_> gas_exp brought in from  *</_gas_exp_note_>;
*gen  gas_exp=gas_exp;
*</_gas_exp_>;

*<_gasoline_exp _>;
*<_gasoline_exp _note_> Total annual consumption of gasoline *</_gasoline_exp _note_>;
*<_gasoline_exp _note_> gasoline_exp  brought in from  *</_gasoline_exp _note_>;
gen gasoline_exp =.;
*</_gasoline_exp _>;

*<_heating_exp_>;
*<_heating_exp_note_> Total annual consumption of heating *</_heating_exp_note_>;
*<_heating_exp_note_> heating_exp brought in from  *</_heating_exp_note_>;
gen heating_exp=.;
*</_heating_exp_>;

*<_heatsource_>;
*<_heatsource_note_> Main source of heating  *</_heatsource_note_>;
*<_heatsource_note_> heatsource brought in from  *</_heatsource_note_>;
gen heatsource=.;
*</_heatsource_>;

*<_hwater_exp_>;
*<_hwater_exp_note_> Total annual consumption of hot water supply *</_hwater_exp_note_>;
*<_hwater_exp_note_> hwater_exp brought in from  *</_hwater_exp_note_>;
*gen hwater_exp=hwater_exp;
*</_hwater_exp_>;

*<_imp_san_rec_>;
*<_imp_san_rec_note_> Improved sanitation facility recommended estimate (not considering sharing) *</_imp_san_rec_note_>;
*<_imp_san_rec_note_> imp_san_rec brought in from SARMD *</_imp_san_rec_note_>;
gen imp_san_rec=improved_sanitation;
*</_imp_san_rec_>;

*<_imp_wat_rec_>;
*<_imp_wat_rec_note_> Improved water recommended estimate *</_imp_wat_rec_note_>;
*<_imp_wat_rec_note_> imp_wat_rec brought in from SARMD *</_imp_wat_rec_note_>;
gen imp_wat_rec=improved_water;
*</_imp_wat_rec_>;

*<_internet_exp_>;
*<_internet_exp_note_> Total consumption of internet services  *</_internet_exp_note_>;
*<_internet_exp_note_> internet_exp brought in from  *</_internet_exp_note_>;
gen internet_exp=.;
*</_internet_exp_>;

*<_kerosene_exp_>;
*<_kerosene_exp_note_> Total annual consumption of kerosene *</_kerosene_exp_note_>;
*<_kerosene_exp_note_> kerosene_exp brought in from  *</_kerosene_exp_note_>;
*gen kerosene_exp=kerosene_exp;
*</_kerosene_exp_>;

*<_landphone_exp_>;
*<_landphone_exp_note_> Total annual consumption of landline phone services *</_landphone_exp_note_>;
*<_landphone_exp_note_> landphone_exp brought in from  *</_landphone_exp_note_>;
gen landphone_exp=.;
*</_landphone_exp_>;

*<_lightsource_>;
*<_lightsource_note_> Main source of lighting  *</_lightsource_note_>;
*<_lightsource_note_> lightsource brought in from  *</_lightsource_note_>;
*gen lightsource=lightsource;
*</_lightsource_>;

*<_liquid_exp_>;
*<_liquid_exp_note_> Total annual consumption of all liquid fuels *</_liquid_exp_note_>;
*<_liquid_exp_note_> liquid_exp brought in from  *</_liquid_exp_note_>;
gen liquid_exp=.;
*</_liquid_exp_>;

*<_LPG_exp _>;
*<_LPG_exp _note_> Total annual consumption of liquefied gas *</_LPG_exp _note_>;
*<_LPG_exp _note_> LPG_exp  brought in from  *</_LPG_exp _note_>;
*gen LPG_exp =LPG_exp;
*</_LPG_exp _>;

*<_ngas_exp _>;
*<_ngas_exp _note_> Total annual consumption of network/natural gas *</_ngas_exp _note_>;
*<_ngas_exp _note_> ngas_exp  brought in from  *</_ngas_exp _note_>;
*gen ngas_exp =ngas_exp;
*</_ngas_exp _>;

*<_open_def_>;
*<_open_def_note_> open defecation *</_open_def_note_>;
*<_open_def_note_> open_def brought in from  *</_open_def_note_>;
*gen open_def=open_def;
*</_open_def_>;

*<_othfuel_exp_>;
*<_othfuel_exp_note_> Total annual consumption of all other fuels *</_othfuel_exp_note_>;
*<_othfuel_exp_note_> othfuel_exp brought in from  *</_othfuel_exp_note_>;
gen othfuel_exp=.;
*</_othfuel_exp_>;

*<_othhousing_exp_>;
*<_othhousing_exp_note_> Total annual consumption of dwelling repair/maintenance *</_othhousing_exp_note_>;
*<_othhousing_exp_note_> othhousing_exp brought in from  *</_othhousing_exp_note_>;
gen othhousing_exp=.;
*</_othhousing_exp_>;

*<_othliq_exp _>;
*<_othliq_exp _note_> Total annual consumption of other liquid fuels *</_othliq_exp _note_>;
*<_othliq_exp _note_> othliq_exp  brought in from  *</_othliq_exp _note_>;
gen othliq_exp =.;
*</_othliq_exp _>;

*<_othsol_exp _>;
*<_othsol_exp _note_> Total annual consumption of other solid fuels *</_othsol_exp _note_>;
*<_othsol_exp _note_> othsol_exp  brought in from  *</_othsol_exp _note_>;
*gen othsol_exp=othsol_exp;
*</_othsol_exp _>;

*<_peat_exp _>;
*<_peat_exp _note_> Total annual consumption of peat *</_peat_exp _note_>;
*<_peat_exp _note_> peat_exp  brought in from  *</_peat_exp _note_>;
*gen peat_exp=peat_exp;
*</_peat_exp _>;

*<_piped _>;
*<_piped _note_> Access to piped water  *</_piped _note_>;
*<_piped _note_> piped  brought in from  *</_piped _note_>;
gen piped =piped_water;
*</_piped _>;

*<_piped_to_prem_>;
*<_piped_to_prem_note_> Access to piped water on premises *</_piped_to_prem_note_>;
*<_piped_to_prem_note_> piped_to_prem brought in from  *</_piped_to_prem_note_>;
*gen piped_to_prem=piped_to_prem;
*</_piped_to_prem_>;

*<_pwater_exp_>;
*<_pwater_exp_note_> Total annual consumption of water supply/piped water  *</_pwater_exp_note_>;
*<_pwater_exp_note_> pwater_exp brought in from  *</_pwater_exp_note_>;
gen pwater_exp=.;
*</_pwater_exp_>;

*<_sanitation_original_>;
*<_sanitation_original_note_> Original survey response in string for sanitation_source variable *</_sanitation_original_note_>;
*<_sanitation_original_note_> sanitation_original brought in from SARMD *</_sanitation_original_note_>;
*gen sanitation_original=sanitation_original;
*</_sanitation_original_>;

*<_sanitation_source_>;
*<_sanitation_source_note_> Sources of sanitation facilities *</_sanitation_source_note_>;
*<_sanitation_source_note_> sanitation_source brought in from SARMD *</_sanitation_source_note_>;
*gen sanitation_source=sanitation_source;
*</_sanitation_source_>;

*<_sewage_exp_>;
*<_sewage_exp_note_> Total annual consumption of sewage collection *</_sewage_exp_note_>;
*<_sewage_exp_note_> sewage_exp brought in from  *</_sewage_exp_note_>;
gen sewage_exp=.;
*</_sewage_exp_>;

*<_sewer_>;
*<_sewer_note_> sewer *</_sewer_note_>;
*<_sewer_note_> sewer brought in from  *</_sewer_note_>;
*gen sewer=sewer;
*</_sewer_>;

*<_solid_exp _>;
*<_solid_exp _note_> Total annual consumption of all solid fuels *</_solid_exp _note_>;
*<_solid_exp _note_> solid_exp  brought in from  *</_solid_exp _note_>;
*gen solid_exp=solid_exp;
*</_solid_exp _>;

*<_tel_exp_>;
*<_tel_exp_note_> Total consumption of all telephone services *</_tel_exp_note_>;
*<_tel_exp_note_> tel_exp brought in from  *</_tel_exp_note_>;
*gen tel_exp=tel_exp;
*</_tel_exp_>;

*<_telefax_exp_>;
*<_telefax_exp_note_> Total consumption of telefax services  *</_telefax_exp_note_>;
*<_telefax_exp_note_> telefax_exp brought in from  *</_telefax_exp_note_>;
gen telefax_exp=.;
*</_telefax_exp_>;

*<_toilet_acc_>;
*<_toilet_acc_note_> Access to flushed toilet  *</_toilet_acc_note_>;
*<_toilet_acc_note_> toilet_acc brought in from SARMD *</_toilet_acc_note_>;
*gen toilet_acc=toilet_acc;
*</_toilet_acc_>;

*<_transfuel_exp_>;
*<_transfuel_exp_note_> Total annual consumption of fuels for personal transportation *</_transfuel_exp_note_>;
*<_transfuel_exp_note_> transfuel_exp brought in from  *</_transfuel_exp_note_>;
*gen transfuel_exp=transfuel_exp;
*</_transfuel_exp_>;

*<_tv_exp_>;
*<_tv_exp_note_> Total consumption of TV broadcasting services  *</_tv_exp_note_>;
*<_tv_exp_note_> tv_exp brought in from  *</_tv_exp_note_>;
*gen tv_exp=tv_exp;
*</_tv_exp_>;

*<_tvintph_exp_>;
*<_tvintph_exp_note_> Total consumption of tv, internet and telephone  *</_tvintph_exp_note_>;
*<_tvintph_exp_note_> tvintph_exp brought in from  *</_tvintph_exp_note_>;
gen tvintph_exp=.;
*</_tvintph_exp_>;

*<_utl_exp_>;
*<_utl_exp_note_> Total annual consumption of all utilities excluding telecom and other housing *</_utl_exp_note_>;
*<_utl_exp_note_> utl_exp brought in from  *</_utl_exp_note_>;
*gen utl_exp=utl_exp;
*</_utl_exp_>;

*<_w_30m_>;
*<_w_30m_note_> Access to water within 30 minutes *</_w_30m_note_>;
*<_w_30m_note_> w_30m brought in from  *</_w_30m_note_>;
*gen w_30m=w_30m;
*</_w_30m_>;

*<_w_avail_>;
*<_w_avail_note_> Water is available when needed *</_w_avail_note_>;
*<_w_avail_note_> w_avail brought in from  *</_w_avail_note_>;
*gen w_avail=w_avail;
*</_w_avail_>;

*<_waste_>;
*<_waste_note_> Main types of solid waste disposal *</_waste_note_>;
*<_waste_note_> waste brought in from  *</_waste_note_>;
gen waste=.;
*</_waste_>;

*<_waste_exp _>;
*<_waste_exp _note_> Total annual consumption of garbage and sewage collection *</_waste_exp _note_>;
*<_waste_exp _note_> waste_exp  brought in from  *</_waste_exp _note_>;
*gen waste_exp =waste_exp;
*</_waste_exp _>;

*<_water_exp_>;
*<_water_exp_note_> Total annual consumption of water supply and hot water *</_water_exp_note_>;
*<_water_exp_note_> water_exp brought in from  *</_water_exp_note_>;
*gen water_exp=water_exp;
*</_water_exp_>;

*<_water_original_>;
*<_water_original_note_> Original survey response in string for water_source variable *</_water_original_note_>;
*<_water_original_note_> water_original brought in from SARMD *</_water_original_note_>;
*gen water_original=water_original;
*</_water_original_>;

*<_water_source_>;
*<_water_source_note_> Sources of drinking water *</_water_source_note_>;
*<_water_source_note_> water_source brought in from SARMD *</_water_source_note_>;
*gen water_source=water_source;
*</_water_source_>;

*<_watertype_quest_>;
*<_watertype_quest_note_> Type of water questions used in the survey *</_watertype_quest_note_>;
*<_watertype_quest_note_> watertype_quest brought in from SARMD *</_watertype_quest_note_>;
*gen watertype_quest=watertype_quest;
*</_watertype_quest_>;

*<_wood_exp_>;
*<_wood_exp_note_> Total annual consumption of firewood *</_wood_exp_note_>;
*<_wood_exp_note_> wood_exp brought in from  *</_wood_exp_note_>;
*gen wood_exp=wood_exp;
*</_wood_exp_>;

*<_Keep variables_>;
*keep countrycode year hhid pid weight weighttype cellphone_exp central_acc central_exp coal_exp comm_exp cooksource diesel_exp dwelmat_exp dwelothsvc_exp dwelsvc_exp elec_acc elec_exp elechr_acc electricity electyp garbage_exp gas gas_exp gasoline_exp heating_exp heatsource hwater_exp imp_san_rec imp_wat_rec internet_exp kerosene_exp landphone_exp lightsource liquid_exp LPG_exp ngas_exp open_def othfuel_exp othhousing_exp othliq_exp othsol_exp peat_exp piped piped_to_prem pwater_exp sanitation_original sanitation_source sewage_exp sewer solid_exp tel_exp telefax_exp toilet_acc transfuel_exp tv_exp tvintph_exp utl_exp w_30m w_avail waste waste_exp water_exp water_original water_source watertype_quest wood_exp;
order countrycode year hhid pid weights weighttype;
sort hhid pid ;
*</_Keep variables_>;

*<_Save data file_>;
save "$rootdatalib\GMD\\`code'\\`yearfolder'\\`gmdfolder'\Data\Harmonized\\`filename'.dta" , replace;
*</_Save data file_>;
