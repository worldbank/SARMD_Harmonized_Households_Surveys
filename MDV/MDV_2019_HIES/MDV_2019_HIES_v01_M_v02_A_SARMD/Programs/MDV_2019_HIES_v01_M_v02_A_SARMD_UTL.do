/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   MDV_2019_HIES_v01_M_v01_A_GMD_UTL.do	</_Program name_>
<_Application_>    STATA 16.0	<_Application_>
<_Author(s)_>      Juan Segnana <jsegnana@worldbank.org>	</_Author(s)_>
<_Date created_>   05-03-2020	</_Date created_>
<_Date modified>    3 May 2021	</_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        MDV	</_Country_>
<_Survey Title_>   HIES	</_Survey Title_>
<_Survey Year_>    2019	</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:	05-03-2020
File:	MDV_2019_HIES_v01_M_v01_A_GMD_UTL.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>;
#delimit ;
clear all;
set more off;

local code         "MDV";
local year         "2019";
local survey       "HIES";
local vm           "01";
local va           "02";
local type         "SARMD";
local yearfolder   "`code'_`year'_`survey'";
local gmdfolder    "`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'";
local filename     "`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'_UTL";
*</_Program setup_>;

*<_Folder creation_>;
cap mkdir "$rootdatalib";
cap mkdir "$rootdatalib\\`code'";
cap mkdir "$rootdatalib\\`code'\\`yearfolder'";
cap mkdir "$rootdatalib\\`code'\\`yearfolder'\\`gmdfolder'";
cap mkdir "$rootdatalib\\`code'\\`yearfolder'\\`gmdfolder'\Data";
cap mkdir "$rootdatalib\\`code'\\`yearfolder'\\`gmdfolder'\Data\Harmonized";
*</_Folder creation_>;

** DIRECTORY;
	use "$rootdatalib\MDV\MDV_2019_HIES\MDV_2019_HIES_v01_M\Data\Stata\MDV_2019_HIES_v01_M.dta", clear;
	drop year hhid pid;

*<_Datalibweb request_>;
#delimit cr
datalibweb, country(`code') year(`year') type(SARRAW) surveyid(`code'_`year'_`survey'_v`vm'_M) filename(`code'_`year'_`survey'_v`vm'_M.dta) clear 
#delimit ;
drop year hhid pid;
*</_Datalibweb request_>;

*<_countrycode_>;
*<_countrycode_note_> country code *</_countrycode_note_>;
*<_countrycode_note_> countrycode brought in from rawdata *</_countrycode_note_>;
gen countrycode="MDV";
note countrycode: countrycode=MDV;
*</_countrycode_>;

*<_year_>;
*<_year_note_> Year *</_year_note_>;
*<_year_note_> year brought in from rawdata *</_year_note_>;
gen year=2019;
note year: year=2019;
*</_year_>;

*<_hhid_>;
*<_hhid_note_> Household identifier  *</_hhid_note_>;
*<_hhid_note_> hhid brought in from rawdata *</_hhid_note_>;
gen hhid=uqhhid;
tostring hhid, replace;
label var hhid "Household id";
note hhid: hhid=uqhhid  4,721 values;
*</_hhid_>;

*<_pid_>;
*<_pid_note_> Personal identifier  *</_pid_note_>;
*<_pid_note_> pid brought in from rawdata *</_pid_note_>;
egen pid=concat (uqhhid person_no), punct(-);
note pid: pid=uqhhid - person_no  24,845 values;
*</_pid_>;

*<_weight_>;
*<_weight_note_> Household weight *</_weight_note_>;
*<_weight_note_> weight brought in from rawdata *</_weight_note_>;
gen weight=wgt;
note weight: weight=wgt;
*</_weight_>;

*<_weighttype_>;
*<_weighttype_note_> Weight type (frequency, probability, analytical, importance) *</_weighttype_note_>;
*<_weighttype_note_> weighttype brought in from rawdata *</_weighttype_note_>;
gen weighttype="PW";
note weighttype: "Probability weight";
*</_weighttype_>;

*<_cellphone_exp_>;
*<_cellphone_exp_note_> Total annual consumption of cell phone services *</_cellphone_exp_note_>;
*<_cellphone_exp_note_> cellphone_exp brought in from rawdata *</_cellphone_exp_note_>;
gen cellphone_exp=(MobPhonebill*12);
note cellphone_exp: Total annual consumption of cell phone services;
*</_cellphone_exp_>;

*<_central_acc_>;
*<_central_acc_note_> Access to central heating  *</_central_acc_note_>;
*<_central_acc_note_> central_acc brought in from rawdata *</_central_acc_note_>;
gen central_acc=.;
note central_acc: N/A;
*</_central_acc_>;

*<_central_exp_>;
*<_central_exp_note_> Total annual consumption of central heating *</_central_exp_note_>;
*<_central_exp_note_> central_exp brought in from rawdata *</_central_exp_note_>;
gen central_exp=.;
note central_exp: N/A;
*</_central_exp_>;

*<_coal_exp_>;
*<_coal_exp_note_> Total annual consumption of coal *</_coal_exp_note_>;
*<_coal_exp_note_> coal_exp brought in from rawdata *</_coal_exp_note_>;
gen coal_exp=.;
note coal_exp: N/A;
*</_coal_exp_>;

*<_comm_exp_>;
*<_comm_exp_note_> Total consumption of all telecommunication services  *</_comm_exp_note_>;
*<_comm_exp_note_> comm_exp brought in from rawdata *</_comm_exp_note_>;
gen comm_exp=.;
*egen comm_exp=rowtotal(exp_08_comm);
*replace comm_exp=comm_exp*12;
*note comm_exp: Total consumption of all information and telecommunication services;
*</_comm_exp_>;

*<_cooksource_>;
*<_cooksource_note_> Main cooking fuel *</_cooksource_note_>;
*<_cooksource_note_> cooksource brought in from rawdata *</_cooksource_note_>;
gen cooksource=.;
replace cooksource=1 if hh_ckfuel_typ==1;
replace cooksource=2 if hh_ckfuel_typ==2;
replace cooksource=4 if hh_ckfuel_typ==4;
replace cooksource=5 if hh_ckfuel_typ==3;
replace cooksource=9 if hh_ckfuel_typ==-96;
note cooksource: Main cooking fuel;
*</_cooksource_>;

*<_diesel_exp _>;
*<_diesel_exp _note_> Total annual consumption of diesel *</_diesel_exp _note_>;
*<_diesel_exp _note_> diesel_exp  brought in from rawdata *</_diesel_exp _note_>;
gen diesel_exp =(ex_amnt_3Diesel*12);
note diesel_exp: Total annual consumption of diesel;
*</_diesel_exp _>;

*<_dwelmat_exp_>;
*<_dwelmat_exp_note_> Total annual consumption of materials for the maintenance and repair of the dwelling *</_dwelmat_exp_note_>;
*<_dwelmat_exp_note_> dwelmat_exp brought in from rawdata *</_dwelmat_exp_note_>;
gen dwelmat_exp=hh_repcost;
note dwelmat_exp: Total annual consumption of materials for the maintenance and repair of the dwelling;
*</_dwelmat_exp_>;

*<_dwelothsvc_exp_>;
*<_dwelothsvc_exp_note_> Total annual consumption of other services relating to the dwelling *</_dwelothsvc_exp_note_>;
*<_dwelothsvc_exp_note_> dwelothsvc_exp brought in from rawdata *</_dwelothsvc_exp_note_>;
gen dwelothsvc_exp=.;
note dwelothsvc_exp: N/A;
*</_dwelothsvc_exp_>;

*<_dwelsvc_exp_>;
*<_dwelsvc_exp_note_> Total annual consumption of services for the maintenance and repair of the dwelling *</_dwelsvc_exp_note_>;
*<_dwelsvc_exp_note_> dwelsvc_exp brought in from rawdata *</_dwelsvc_exp_note_>;
gen dwelsvc_exp=.;
note dwelsvc_exp: N/A;
*</_dwelsvc_exp_>;

*<_elec_acc_>;
*<_elec_acc_note_> Connection to electricity in dwelling *</_elec_acc_note_>;
*<_elec_acc_note_> elec_acc brought in from rawdata *</_elec_acc_note_>;
gen elec_acc=.;
note elec_acc: N/A;
*</_elec_acc_>;

*<_elec_exp_>;
*<_elec_exp_note_> Total annual consumption of electricity *</_elec_exp_note_>;
*<_elec_exp_note_> elec_exp brought in from rawdata *</_elec_exp_note_>;
gen elec_exp=(cost_item_servElectricity);
replace elec_exp=elec_exp*12;
note elec_exp: Total annual consumption of electricity;
*</_elec_exp_>;

*<_elechr_acc_>;
*<_elechr_acc_note_> Electricity availability (hr/day) *</_elechr_acc_note_>;
*<_elechr_acc_note_> elechr_acc brought in from rawdata *</_elechr_acc_note_>;
gen elechr_acc=.;
note elechr_acc: N/A;
*</_elechr_acc_>;

*<_electricity_>;
*<_electricity_note_> Access to electricity in dwelling *</_electricity_note_>;
*<_electricity_note_> electricity brought in from rawdata *</_electricity_note_>;
gen electricity=(hh_ckfuel_typ==4 | other_bills_exp__4510001==1);
note electricity: Access to electricity in dwelling determined by household paying an electricity bill and/or using electricity to cook;
*</_electricity_>;

*<_electyp_>;
*<_electyp_note_> Lighting and/or electricity – type of *</_electyp_note_>;
*<_electyp_note_> electyp brought in from rawdata *</_electyp_note_>;
gen electyp=.;
note electyp: N/A;
*</_electyp_>;

*<_garbage_exp_>;
*<_garbage_exp_note_> Total annual consumption of garbage collection *</_garbage_exp_note_>;
*<_garbage_exp_note_> garbage_exp brought in from rawdata *</_garbage_exp_note_>;
gen garbage_exp=.;
note garbage_exp: N/A;
*</_garbage_exp_>;

*<_gas_>;
*<_gas_note_> Connection to gas/Usage of gas *</_gas_note_>;
*<_gas_note_> gas brought in from rawdata *</_gas_note_>;
gen gas=.;
note gas: N/A;
*</_gas_>;

*<_gas_exp_>;
*<_gas_exp_note_> Total annual consumption of network/natural and liquefied gas *</_gas_exp_note_>;
*<_gas_exp_note_> gas_exp brought in from rawdata *</_gas_exp_note_>;
gen gas_exp=.;
note gas_exp: N/A;
*</_gas_exp_>;

*<_gasoline_exp _>;
*<_gasoline_exp _note_> Total annual consumption of gasoline *</_gasoline_exp _note_>;
*<_gasoline_exp _note_> gasoline_exp  brought in from rawdata *</_gasoline_exp _note_>;
gen gasoline_exp =.;
note gasoline_exp: N/A;
*</_gasoline_exp _>;

*<_heating_exp_>;
*<_heating_exp_note_> Total annual consumption of heating *</_heating_exp_note_>;
*<_heating_exp_note_> heating_exp brought in from rawdata *</_heating_exp_note_>;
gen heating_exp=.;
note heating_exp: N/A;
*</_heating_exp_>;

*<_heatsource_>;
*<_heatsource_note_> Main source of heating  *</_heatsource_note_>;
*<_heatsource_note_> heatsource brought in from rawdata *</_heatsource_note_>;
gen heatsource=.;
note heatsource: N/A;
*</_heatsource_>;

*<_hwater_exp_>;
*<_hwater_exp_note_> Total annual consumption of hot water supply *</_hwater_exp_note_>;
*<_hwater_exp_note_> hwater_exp brought in from rawdata *</_hwater_exp_note_>;
gen hwater_exp=.;
note hwater_exp: N/A;
*</_hwater_exp_>;

*<_imp_san_rec_>;
*<_imp_san_rec_note_> Improved sanitation facility recommended estimate (not considering sharing) *</_imp_san_rec_note_>;
*<_imp_san_rec_note_> imp_san_rec brought in from rawdata *</_imp_san_rec_note_>;
gen imp_san_rec=.;
replace imp_san_rec=1 if inlist(hh_sewer_typ,1,3);
replace imp_san_rec=0 if inlist(hh_sewer_typ,2,4);
replace imp_san_rec=1 if Male==1;
note imp_san_rec: N/A;
*</_imp_san_rec_>;

*<_imp_wat_rec_>;
*<_imp_wat_rec_note_> Improved water recommended estimate *</_imp_wat_rec_note_>;
*<_imp_wat_rec_note_> imp_wat_rec brought in from rawdata *</_imp_wat_rec_note_>;
gen imp_wat_rec=.;
replace imp_wat_rec=1 if inlist(hh_drkwater,1,2,3,5,6,7);
replace imp_wat_rec=0 if inlist(hh_drkwater,4);
note imp_wat_rec: N/A;
*</_imp_wat_rec_>;

*<_internet_exp_>;
*<_internet_exp_note_> Total consumption of internet services  *</_internet_exp_note_>;
*<_internet_exp_note_> internet_exp brought in from rawdata *</_internet_exp_note_>;
gen internet_exp=(ex_amnt_6Internet*12);
note internet_exp: Total consumption of internet services;
*</_internet_exp_>;

*<_kerosene_exp_>;
*<_kerosene_exp_note_> Total annual consumption of kerosene *</_kerosene_exp_note_>;
*<_kerosene_exp_note_> kerosene_exp brought in from rawdata *</_kerosene_exp_note_>;
gen kerosene_exp=cost_item_servKerosene;
note kerosene_exp: Total annual consumption of kerosene;
*</_kerosene_exp_>;

*<_landphone_exp_>;
*<_landphone_exp_note_> Total annual consumption of landline phone services *</_landphone_exp_note_>;
*<_landphone_exp_note_> landphone_exp brought in from rawdata *</_landphone_exp_note_>;
gen landphone_exp=(cost_item_servLand_line_bill*12);
note landphone_exp: Total annual consumption of landline;
*</_landphone_exp_>;

*<_lightsource_>;
*<_lightsource_note_> Main source of lighting  *</_lightsource_note_>;
*<_lightsource_note_> lightsource brought in from rawdata *</_lightsource_note_>;
gen lightsource=.;
note lightsource: N/A;
*</_lightsource_>;

*<_liquid_exp_>;
*<_liquid_exp_note_> Total annual consumption of all liquid fuels *</_liquid_exp_note_>;
*<_liquid_exp_note_> liquid_exp brought in from rawdata *</_liquid_exp_note_>;
gen liquid_exp=.;
note liquid_exp: N/A;
*</_liquid_exp_>;

*<_LPG_exp _>;
*<_LPG_exp _note_> Total annual consumption of liquefied gas *</_LPG_exp _note_>;
*<_LPG_exp _note_> LPG_exp  brought in from rawdata *</_LPG_exp _note_>;
gen LPG_exp =.;
note LPG_exp: N/A;
*</_LPG_exp _>;

*<_ngas_exp _>;
*<_ngas_exp _note_> Total annual consumption of network/natural gas *</_ngas_exp _note_>;
*<_ngas_exp _note_> ngas_exp  brought in from rawdata *</_ngas_exp _note_>;
gen ngas_exp =(cost_item_servGas*12);
note ngas_exp: Natural gas expenditure;
*</_ngas_exp _>;

*<_open_def_>;
*<_open_def_note_> open defecation *</_open_def_note_>;
*<_open_def_note_> open_def brought in from rawdata *</_open_def_note_>;
gen open_def=.;
note open_def: N/A;
*</_open_def_>;

*<_othfuel_exp_>;
*<_othfuel_exp_note_> Total annual consumption of all other fuels *</_othfuel_exp_note_>;
*<_othfuel_exp_note_> othfuel_exp brought in from rawdata *</_othfuel_exp_note_>;
gen othfuel_exp=.;
note othfuel_exp: N/A;
*</_othfuel_exp_>;

*<_othhousing_exp_>;
*<_othhousing_exp_note_> Total annual consumption of dwelling repair/maintenance *</_othhousing_exp_note_>;
*<_othhousing_exp_note_> othhousing_exp brought in from rawdata *</_othhousing_exp_note_>;
gen othhousing_exp=tot_hh_rep;
note othhousing_exp: Total annual consumption of dwelling repair/maintenance;
*</_othhousing_exp_>;

*<_othliq_exp _>;
*<_othliq_exp _note_> Total annual consumption of other liquid fuels *</_othliq_exp _note_>;
*<_othliq_exp _note_> othliq_exp  brought in from rawdata *</_othliq_exp _note_>;
gen othliq_exp =.;
note othliq_exp: N/A;
*</_othliq_exp _>;

*<_othsol_exp _>;
*<_othsol_exp _note_> Total annual consumption of other solid fuels *</_othsol_exp _note_>;
*<_othsol_exp _note_> othsol_exp  brought in from rawdata *</_othsol_exp _note_>;
gen othsol_exp =.;
note othsol_exp: N/A;
*</_othsol_exp _>;

*<_peat_exp _>;
*<_peat_exp _note_> Total annual consumption of peat *</_peat_exp _note_>;
*<_peat_exp _note_> peat_exp  brought in from rawdata *</_peat_exp _note_>;
gen peat_exp =.;
note peat_exp: N/A;
*</_peat_exp _>;

*<_piped _>;
*<_piped _note_> Access to piped water  *</_piped _note_>;
*<_piped _note_> piped  brought in from rawdata *</_piped _note_>;
gen piped =(hh_drkwater==1 | hh_ckwater==1);
note piped: Only able to determine if the HH has access to piped water but not possible to say it doesn't have;
*</_piped _>;

*<_piped_to_prem_>;
*<_piped_to_prem_note_> Access to piped water on premises *</_piped_to_prem_note_>;
*<_piped_to_prem_note_> piped_to_prem brought in from rawdata *</_piped_to_prem_note_>;
gen piped_to_prem=piped;
note piped_to_prem: Only able to determine if the HH has access to piped water but not possible to say it doesn't have;
*</_piped_to_prem_>;

*<_pipedwater_acc>;
*<_pipedwater_acc_note_> Access to piped water on premises *</_piped_to_prem_note_>;
*<_pipedwater_acc_note_> piped_to_prem brought in from rawdata *</_piped_to_prem_note_>;
gen pipedwater_acc=piped;
note pipedwater_acc: Only able to determine if the HH has access to piped water but not possible to say it doesn't have;
*</_pipedwater_acc>;

*<_pwater_exp_>;
*<_pwater_exp_note_> Total annual consumption of water supply/piped water  *</_pwater_exp_note_>;
*<_pwater_exp_note_> pwater_exp brought in from rawdata *</_pwater_exp_note_>;
gen pwater_exp=(cost_item_servWater*12);
note pwater_exp: Total annual consumption of water supply/piped water;
*</_pwater_exp_>;

*<_sanitation_original_>;
*<_sanitation_original_note_> Original survey response in string for sanitation_source variable *</_sanitation_original_note_>;
*<_sanitation_original_note_> sanitation_original brought in from rawdata *</_sanitation_original_note_>;
gen sanitation_original=hh_sewer_typ;
tostring sanitation_original, replace;
replace sanitation_original="1 - Toilet connected to sewerage system" if sanitation_original=="1" | atoll_str=="Male";
replace sanitation_original="2 - Toilet connected to sea" if sanitation_original=="2";
replace sanitation_original="3 - Toilet connected to septic tank" if sanitation_original=="3";
replace sanitation_original="4 - Gifili (without toilet bowl)" if sanitation_original=="4";
note sanitation_original: Original survey response in string for sanitation_source variable;
*</_sanitation_original_>;

*<_sanitation_source_>;
*<_sanitation_source_note_> Sources of sanitation facilities *</_sanitation_source_note_>;
*<_sanitation_source_note_> sanitation_source brought in from rawdata *</_sanitation_source_note_>;
gen sanitation_source=(hh_sewer_typ==1);
replace sanitation_source=14 if sanitation_source==0;
note sanitation_source: Sources of sanitation facilities;
*</_sanitation_source_>;

*<_sewage_exp_>;
*<_sewage_exp_note_> Total annual consumption of sewage collection *</_sewage_exp_note_>;
*<_sewage_exp_note_> sewage_exp brought in from rawdata *</_sewage_exp_note_>;
gen sewage_exp=.;
note sewage_exp: N/A;
*</_sewage_exp_>;

*<_sewer_>;
*<_sewer_note_> sewer *</_sewer_note_>;
*<_sewer_note_> sewer brought in from rawdata *</_sewer_note_>;
gen sewer=.;
note sewer: N/A;
*</_sewer_>;

*<_solid_exp _>;
*<_solid_exp _note_> Total annual consumption of all solid fuels *</_solid_exp _note_>;
*<_solid_exp _note_> solid_exp  brought in from rawdata *</_solid_exp _note_>;
gen solid_exp =.;
note solid_exp: N/A;
*</_solid_exp _>;

*<_tel_exp_>;
*<_tel_exp_note_> Total consumption of all telephone services *</_tel_exp_note_>;
*<_tel_exp_note_> tel_exp brought in from rawdata *</_tel_exp_note_>;
gen tel_exp=MobPhonebill*12;
note tel_exp: Total consumption of all telephone services;
*</_tel_exp_>;

*<_telefax_exp_>;
*<_telefax_exp_note_> Total consumption of telefax services  *</_telefax_exp_note_>;
*<_telefax_exp_note_> telefax_exp brought in from rawdata *</_telefax_exp_note_>;
gen telefax_exp=.;
note telefax_exp: N/A;
*</_telefax_exp_>;

*<_toilet_acc_>;
*<_toilet_acc_note_> Access to flushed toilet  *</_toilet_acc_note_>;
*<_toilet_acc_note_> toilet_acc brought in from rawdata *</_toilet_acc_note_>;
gen toilet_acc=.;
note toilet_acc: N/A;
*</_toilet_acc_>;

*<_transfuel_exp_>;
*<_transfuel_exp_note_> Total annual consumption of fuels for personal transportation *</_transfuel_exp_note_>;
*<_transfuel_exp_note_> transfuel_exp brought in from rawdata *</_transfuel_exp_note_>;
gen transfuel_exp=(ex_amnt_3Petrol*12);
note transfuel_exp: N/A;
*</_transfuel_exp_>;

*<_tv_exp_>;
*<_tv_exp_note_> Total consumption of TV broadcasting services  *</_tv_exp_note_>;
*<_tv_exp_note_> tv_exp brought in from rawdata *</_tv_exp_note_>;
gen tv_exp=(ex_amnt_6Cable*12);
note tv_exp: Total consumption of TV broadcasting services;
*</_tv_exp_>;

*<_tvintph_exp_>;
*<_tvintph_exp_note_> Total consumption of tv, internet and telephone  *</_tvintph_exp_note_>;
*<_tvintph_exp_note_> tvintph_exp brought in from rawdata *</_tvintph_exp_note_>;
gen tvintph_exp=(tv_exp + tel_exp + internet_exp);
note tvintph_exp: Total consumption of tv, internet and telephone;
*</_tvintph_exp_>;

*<_utl_exp_>;
*<_utl_exp_note_> Total annual consumption of all utilities excluding telecom and other housing *</_utl_exp_note_>;
*<_utl_exp_note_> utl_exp brought in from rawdata *</_utl_exp_note_>;
gen utl_exp=.;
note utl_exp: N/A;
*</_utl_exp_>;

*<_w_30m_>;
*<_w_30m_note_> Access to water within 30 minutes *</_w_30m_note_>;
*<_w_30m_note_> w_30m brought in from rawdata *</_w_30m_note_>;
gen w_30m=.;
note w_30m: N/A;
*</_w_30m_>;

*<_w_avail_>;
*<_w_avail_note_> Water is available when needed *</_w_avail_note_>;
*<_w_avail_note_> w_avail brought in from rawdata *</_w_avail_note_>;
gen w_avail=.;
note w_avail: N/A;
*</_w_avail_>;

*<_waste_>;
*<_waste_note_> Main types of solid waste disposal *</_waste_note_>;
*<_waste_note_> waste brought in from rawdata *</_waste_note_>;
gen waste=.;
replace waste=8 if hh_wstdisp==2 | hh_wstdisp==4;
replace waste=6 if hh_wstdisp==6;
replace waste=7 if hh_wstdisp==5;
replace waste=10 if hh_wstdisp==3 | hh_wstdisp==7 | hh_wstdisp==-96;
replace waste=12 if hh_wstdisp==8;
replace waste=11 if hh_wstdisp==1;
note waste: We added two categories to those provided by GMD - waste=11 "Garbage compound (set waste disposal site)" - waste=12 "Garbage collection (e.g. WAMCO, Island Council)";
*</_waste_>;

*<_waste_exp _>;
*<_waste_exp _note_> Total annual consumption of garbage and sewage collection *</_waste_exp _note_>;
*<_waste_exp _note_> waste_exp  brought in from rawdata *</_waste_exp _note_>;
gen waste_exp =(cost_item_servWaste*12);
note waste_exp: N/A;
*</_waste_exp _>;

*<_water_exp_>;
*<_water_exp_note_> Total annual consumption of water supply and hot water *</_water_exp_note_>;
*<_water_exp_note_> water_exp brought in from rawdata *</_water_exp_note_>;
gen water_exp=(cost_item_servWater*12);
note water_exp: Total annual consumption of water supply and hot water;
*</_water_exp_>;

*<_water_original_>;
*<_water_original_note_> Original survey response in string for water_source variable *</_water_original_note_>;
*<_water_original_note_> water_original brought in from rawdata *</_water_original_note_>;
gen water_original=hh_drkwater;
tostring water_original, replace;
replace water_original="1 - Desalinated water - piped into dwelling" if hh_drkwater==1;
replace water_original="2 - Desalinated water - public tap/standpipe" if hh_drkwater==2;
replace water_original="3 - Well water - protected well (Covered with lid)" if hh_drkwater==3;
replace water_original="4 - Well water - unprotected well" if hh_drkwater==4;
replace water_original="5 - Rainwater - tank in compound" if hh_drkwater==5;
replace water_original="6 - Rainwater - public or community tank" if hh_drkwater==6;
replace water_original="7 - Bottled water" if hh_drkwater==7;
replace water_original="-96 - Other (Specify)" if hh_drkwater==-96;
note water_original: Original survey response in string for water_source variable;
*</_water_original_>;

*<_water_source_>;
*<_water_source_note_> Sources of drinking water *</_water_source_note_>;
*<_water_source_note_> water_source brought in from rawdata *</_water_source_note_>;
cap gen water_source=.;
replace water_source=1  if hh_drkwater==1;
replace water_source=3  if hh_drkwater==2;
replace water_source=5  if hh_drkwater==3;
replace water_source=10 if hh_drkwater==4;
replace water_source=8  if hh_drkwater==5 | hh_drkwater==6;
replace water_source=7  if hh_drkwater==7;
replace water_source=14 if hh_drkwater==-96;
note water_source: Sources of drinking water;
*</_water_source_>;

*<_watertype_quest_>;
*<_watertype_quest_note_> Type of water questions used in the survey *</_watertype_quest_note_>;
*<_watertype_quest_note_> watertype_quest brought in from rawdata *</_watertype_quest_note_>;
gen watertype_quest=.;
note watertype_quest: N/A;
*</_watertype_quest_>;

*<_wood_exp_>;
*<_wood_exp_note_> Total annual consumption of firewood *</_wood_exp_note_>;
*<_wood_exp_note_> wood_exp brought in from rawdata *</_wood_exp_note_>;
gen wood_exp=.;
note wood_exp: N/A;
*</_wood_exp_>;

*<_Keep variables_>;
keep countrycode year hhid pid weight weighttype cellphone_exp central_acc central_exp coal_exp comm_exp cooksource diesel_exp dwelmat_exp dwelothsvc_exp dwelsvc_exp elec_acc elec_exp elechr_acc electricity electyp garbage_exp gas gas_exp gasoline_exp heating_exp heatsource hwater_exp imp_san_rec imp_wat_rec internet_exp kerosene_exp landphone_exp lightsource liquid_exp LPG_exp ngas_exp open_def othfuel_exp othhousing_exp othliq_exp othsol_exp peat_exp piped piped_to_prem pipedwater_acc pwater_exp sanitation_original sanitation_source sewage_exp sewer solid_exp tel_exp telefax_exp toilet_acc transfuel_exp tv_exp tvintph_exp utl_exp w_30m w_avail waste waste_exp water_exp water_original water_source watertype_quest wood_exp;
order countrycode year hhid pid weight weighttype;
sort hhid pid ;
*</_Keep variables_>;

*<_Save data file_>;
glo module="UTL";
include "${rootdatalib}\_aux\GMD2.0labels.do";
save "$rootdatalib\\`code'\\`yearfolder'\\`gmdfolder'\Data\Harmonized\\`filename'.dta" , replace;
*</_Save data file_>;
