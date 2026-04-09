/*------------------------------------------------------------------------------
  GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   	LKA_2019_HIES_v02_M_v01_A_SARMD_UTL.do	   </_Program name_>
<_Application_>    	STATA 17.0									 <_Application_>
<_Author(s)_>       Joe Green 		<jogreen@worldbank.org>		  </_Author(s)_>
<_Date created_>    06-2022	                                   </_Date created_>
<_Author(s)_>      	Leo Tornarolli 	<tornarolli@gmail.com>		  </_Author(s)_>
<_Date modified_>   10-2024									  </_Date modified_>
<_Date modified>    October 2024							  </_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        	LKA											    </_Country_>
<_Survey Title_>   	HIES									   </_Survey Title_>
<_Survey Year_>    	2019										</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:				10-2024
File:				LKA_2019_HIES_v01_M_v03_A_SARMD_UTL.do
First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>
clear all
set more off

local code         		"LKA"
local year         		"2019"
local survey       		"HIES"
local vm           		"01"
local va           		"03"
local type         		"SARMD"
global module       	"UTL"
local yearfolder    	"`code'_`year'_`survey'"
local SARMDfolder    	"`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'"
local filename      	"`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'_${module}"
glo output          	"${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\\Data\Harmonized" 
*</_Program setup_>


*<_Datalibweb request_>
use   "${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata\\`yearfolder'_v`vm'_M.dta", clear
sort  hhid pid
merge 1:1 hhid pid using "${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\Data\Harmonized\\`yearfolder'_v`vm'_M_v`va'_A_`type'_IND.dta" 
drop _merge
*</_Datalibweb request_>


*<_central_acc_>
*<_central_acc_note_> Access to central heating  *</_central_acc_note_>
gen central_acc = .
*</_central_acc_>

*<_cooksource_>
*<_cooksource_note_> Main cooking fuel *</_cooksource_note_>
*<_cooksource_note_> cooksource brought in from rawdata *</_cooksource_note_>
recode cooking_fuel (1=1) (2=2) (3=5) (4=4) (5/6 9=9) (*=.), g(cooksource)
*</_cooksource_>

*<_elec_acc_>
*<_elec_acc_note_> Connection to electricity in dwelling *</_elec_acc_note_>
*<_elec_acc_note_> elec_acc brought in from rawdata *</_elec_acc_note_>
gen		elec_acc = 1 	if  inlist(lite_source,1,2) | is_power_lines_near==1
replace	elec_acc = 3 	if  lite_source==4
recode  elec_acc (.=4) 	if  is_power_lines_near==2
note elec_acc: For LKA_2019_HIES, we used 2 variables as proxies: "Principle Type of Lighting", and "Do you have electricity supply (main line) nearby your area?".
*</_elec_acc_>

*<_elechr_acc_>
*<_elechr_acc_note_> Electricity availability (hr/day) *</_elechr_acc_note_>
gen elechr_acc = .
*</_elechr_acc_>

*<_electricity_>
*<_electricity_note_> Access to electricity in dwelling *</_electricity_note_>
*<_electricity_note_> electricity brought in from SARMD *</_electricity_note_>
* gen electricity = . 
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
gen heatsource = .
*</_heatsource_>

*<_gas_>
*<_gas_note_> Connection to gas/Usage of gas *</_gas_note_>
gen gas = .
*</_gas_>


*<_water_original_>
*<_water_original_note_> Original survey response in string for water_source variable *</_water_original_note_>
*<_water_original_note_> water_original brought in from SARMD *</_water_original_note_>
rename water_orig water_original 
*</_water_original_>

*<_water_source_>
*<_water_source_note_> Sources of drinking water *</_water_source_note_>
*<_water_source_note_> water_source brought in from rawdata *</_water_source_note_>
recode drinking_water (1=5) (2=10) (3=4) (4/7=1) (8/9=13) (10=7) (11=12) (12 99=14) (*=.), g(water_source)
* change to public tap if source is not on premises
recode water_source (1/2=3) if s8_6b1_inside_outside==2
*</_water_source_>

*<_watertype_quest_>
*<_watertype_quest_note_> Type of water questions used in the survey *</_watertype_quest_note_>
*<_watertype_quest_note_> watertype_quest brought in from rawdata *</_watertype_quest_note_>
gen watertype_quest = 1
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
gen 	pipedwater_acc = 0 		if  inlist(drinking_water,1,2,3,8,9,10,11,12,99) // Asuming other is not piped water
replace pipedwater_acc = 3 		if  inlist(drinking_water,4,5,6,7)
*</_pipedwater_acc_>

*<_piped_to_prem_>
*<_piped_to_prem_note_> Access to piped water on premises *<_piped_to_prem_note_> piped_to_prem brought in from rawdata 
recode drinking_water (1/3 8/12 99=0) (4/7=1) (*=.), g(piped_to_prem)
note piped_to_prem: For LKA_2019_HIES we used "tap water" as a proxy for piped water on premises, but it does not identify the location of the tap (communal or in-house).
*</_piped_to_prem_>

*<_w_30m_>
*<_w_30m_note_> Access to water within 30 minutes *</_w_30m_note_>
*<_w_30m_note_> w_30m brought in from rawdata *</_w_30m_note_>
gen 	w_30m = 1 		if  imp_wat_rec==1 & s8_6b1_inside_outside==1 | inrange(s8_6b2_premises_time,0,15)
recode w_30m (.=0) 		if  imp_wat_rec==1 & s8_6b1_inside_outside==2 & ~missing(s8_6b2_premises_time)
*</_w_30m_>

*<_w_avail_>
*<_w_avail_note_> Water is available when needed *</_w_avail_note_>
*<_w_avail_note_> w_avail brought in from rawdata *</_w_avail_note_>
gen		w_avail = 0 if imp_wat_rec==1 & (s8_6d_water_sufficency==1 | inrange(s8_6e1_water_sufficency_for_drio,0,11))
recode	w_avail (.=1) if imp_wat_rec==1 & (s8_6d_water_sufficency==2 | s8_6e1_water_sufficency_for_drio==12)
*</_w_avail_>


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
gen		toilet_acc = 0 if inlist(toilet_type,5,6,7,9)
replace	toilet_acc = 1 if inrange(toilet_type,1,4) & inlist(tioilet_use,1,2)
replace	toilet_acc = 2 if inrange(toilet_type,1,4) & inlist(tioilet_use,3,4)
*</_toilet_acc_>

*<_waste_>
*<_waste_note_> Main types of solid waste disposal *</_waste_note_>
*<_waste_note_> waste brought in from rawdata *</_waste_note_>
recode garbage_dumping (1=1) (2=6) (3=5) (4=9) (5/6=10) (*=.), g(waste)
*</_waste_>


*<_water_exp_>
*<_water_exp_note_> Total annual consumption of water supply and hot water *</_water_exp_note_>
*<_water_exp_note_> water_exp brought in from rawdata *</_water_exp_note_>
egen    water_exp = rsum(nf_value2003 nf_inkind_value2003), missing
replace water_exp = water_exp*12
*</_water_exp_>

*<_hwater_exp_>
*<_hwater_exp_note_> Total annual consumption of hot water supply *</_hwater_exp_note_>
*<_hwater_exp_note_> hwater_exp brought in from  *</_hwater_exp_note_>
gen hwater_exp = .
*</_hwater_exp_>

*<_pwater_exp_>
*<_pwater_exp_note_> Total annual consumption of water supply/piped water  *</_pwater_exp_note_>
*<_pwater_exp_note_> pwater_exp brought in from *</_pwater_exp_note_>
gen pwater_exp = .
*</_pwater_exp_>

*<_central_exp_>
*<_central_exp_note_> Total annual consumption of central heating *</_central_exp_note_>
*<_central_exp_note_> central_exp brought in from  *</_central_exp_note_>
gen central_exp = .
*</_central_exp_>

*<_heating_exp_>
*<_heating_exp_note_> Total annual consumption of heating *</_heating_exp_note_>
*<_heating_exp_note_> heating_exp brought in from  *</_heating_exp_note_>
egen heating_exp = rowtotal(central_exp hwater_exp), missing
*</_heating_exp_>

*<_coal_exp_>
*<_coal_exp_note_> Total annual consumption of coal *</_coal_exp_note_>
*<_coal_exp_note_> coal_exp brought in from  *</_coal_exp_note_>
gen coal_exp = .
*</_coal_exp_>

*<_ngas_exp _>
*<_ngas_exp _note_> Total annual consumption of network/natural gas *</_ngas_exp _note_>
*<_ngas_exp _note_> ngas_exp  brought in from  *</_ngas_exp _note_>
gen ngas_exp = .
*</_ngas_exp _>

*<_LPG_exp _>
*<_LPG_exp _note_> Total annual consumption of liquefied gas *</_LPG_exp _note_>
*<_LPG_exp _note_> LPG_exp  brought in from  *</_LPG_exp _note_>
egen    LPG_exp = rsum(nf_value2106 nf_inkind_value2106), missing
replace LPG_exp = LPG_exp*12
*</_LPG_exp _>

*<_gas_exp_>
*<_gas_exp_note_> Total annual consumption of network/natural and liquefied gas *</_gas_exp_note_>
*<_gas_exp_note_> gas_exp brought in from rawdata *</_gas_exp_note_>
egen gas_exp = rowtotal(ngas_exp LPG_exp), missing
*</_gas_exp_>

*<_othfuel_exp_>
*<_othfuel_exp_note_> Total annual consumption of all other fuels *</_othfuel_exp_note_>
*<_othfuel_exp_note_> othfuel_exp brought in from  *</_othfuel_exp_note_>
egen    othfuel_exp = rsum(nf_value2413 nf_inkind_value2413 nf_value2414 nf_inkind_value2414)
replace othfuel_exp = othfuel_exp*12 
*</_othfuel_exp_>

*<_othsol_exp _>
*<_othsol_exp _note_> Total annual consumption of other solid fuels *</_othsol_exp _note_>
*<_othsol_exp _note_> othsol_exp  brought in from  *</_othsol_exp _note_>
gen othsol_exp = . 
*</_othsol_exp _>

*<_peat_exp _>
*<_peat_exp _note_> Total annual consumption of peat *</_peat_exp _note_>
*<_peat_exp _note_> peat_exp  brought in from  *</_peat_exp _note_>
gen peat_exp = . 
*</_peat_exp _>

*<_wood_exp_>
*<_wood_exp_note_> Total annual consumption of firewood *</_wood_exp_note_>
*<_wood_exp_note_> wood_exp brought in from  *</_wood_exp_note_>
egen    wood_exp = rsum(nf_value2104 nf_inkind_value2104 nf_value2105 nf_inkind_value2105), missing
replace wood_exp = wood_exp*12
*</_wood_exp_>

*<_solid_exp _>
*<_solid_exp _note_> Total annual consumption of all solid fuels *</_solid_exp _note_>
*<_solid_exp _note_> solid_exp  brought in from  *</_solid_exp _note_>
egen solid_exp = rowtotal(wood_exp coal_exp peat_exp othsol_exp), missing
*</_solid_exp _>

*<_gasoline_exp _>
*<_gasoline_exp _note_> Total annual consumption of gasoline *</_gasoline_exp _note_>
*<_gasoline_exp _note_> gasoline_exp  brought in from  *</_gasoline_exp _note_>
egen    gasoline_exp = rsum(nf_value2411 nf_inkind_value2411), missing
replace gasoline_exp = gasoline_exp*12
*</_gasoline_exp _>

*<_diesel_exp _>
*<_diesel_exp _note_> Total annual consumption of diesel *</_diesel_exp _note_>
*<_diesel_exp _note_> diesel_exp  brought in from  *</_diesel_exp _note_>
egen    diesel_exp = rsum(nf_value2412 nf_inkind_value2412), missing
replace diesel_exp = diesel_exp*12
*</_diesel_exp _>

*<_kerosene_exp_>
*<_kerosene_exp_note_> Total annual consumption of kerosene *</_kerosene_exp_note_>
*<_kerosene_exp_note_> kerosene_exp brought in from rawdata *</_kerosene_exp_note_>
egen    kerosene_exp = rsum(nf_value2103 nf_inkind_value2103), missing
replace kerosene_exp = kerosene_exp*12
*</_kerosene_exp_>

*<_othliq_exp _>
*<_othliq_exp _note_> Total annual consumption of other liquid fuels *</_othliq_exp _note_>
*<_othliq_exp _note_> othliq_exp  brought in from  *</_othliq_exp _note_>
gen othliq_exp = .
*</_othliq_exp _>

*<_liquid_exp_>
*<_liquid_exp_note_> Total annual consumption of all liquid fuels *</_liquid_exp_note_>
*<_liquid_exp_note_> liquid_exp brought in from  *</_liquid_exp_note_>
egen liquid_exp = rowtotal(gasoline_exp diesel_exp kerosene_exp othliq_exp), missing
*</_liquid_exp_>

*<_transfuel_exp_>
*<_transfuel_exp_note_> Total annual consumption of fuels for personal transportation *</_transfuel_exp_note_>
*<_transfuel_exp_note_> transfuel_exp brought in from  *</_transfuel_exp_note_>
gen transfuel_exp = .
*</_transfuel_exp_>

*<_garbage_exp_>
*<_garbage_exp_note_> Total annual consumption of garbage collection *</_garbage_exp_note_>
*<_garbage_exp_note_> garbage_exp brought in from  *</_garbage_exp_note_>
gen garbage_exp = .
*</_garbage_exp_>

*<_sewage_exp_>
*<_sewage_exp_note_> Total annual consumption of sewage collection *</_sewage_exp_note_>
*<_sewage_exp_note_> sewage_exp brought in from  *</_sewage_exp_note_>
gen sewage_exp = .
*</_sewage_exp_>

*<_waste_exp _>
*<_waste_exp _note_> Total annual consumption of garbage and sewage collection *</_waste_exp _note_>
*<_waste_exp _note_> waste_exp  brought in from  *</_waste_exp _note_>
egen waste_exp = rowtotal(garbage_exp sewage_exp), missing
*</_waste_exp _>

*<_elec_exp_>
*<_elec_exp_note_> Total annual consumption of electricity *</_elec_exp_note_>
*<_elec_exp_note_> elec_exp brought in from rawdata *</_elec_exp_note_>
egen    elec_exp = rsum(nf_value2101 nf_inkind_value2101), missing
replace elec_exp = elec_exp*12
*</_elec_exp_>

*<_internet_exp_>
*<_internet_exp_note_> Total consumption of internet services  *</_internet_exp_note_>
*<_internet_exp_note_> internet_exp brought in from  *</_internet_exp_note_>
egen    internet_exp = rsum(nf_value2505 nf_inkind_value2505), missing
replace internet_exp = internet_exp*12
*</_internet_exp_>

*<_landphone_exp_>
*<_landphone_exp_note_> Total annual consumption of landline phone services *</_landphone_exp_note_>
*<_landphone_exp_note_> landphone_exp brought in from rawdata *</_landphone_exp_note_>
egen    landphone_exp = rsum(nf_value2502 nf_inkind_value2502), missing
replace landphone_exp = landphone_exp*12
*</_landphone_exp_>

*<_cellphone_exp_>
*<_cellphone_exp_note_> Total annual consumption of cell phone services *</_cellphone_exp_note_>
*<_cellphone_exp_note_> cellphone_exp brought in from  *</_cellphone_exp_note_>
egen    cellphone_exp = rsum(nf_value2503 nf_inkind_value2503), missing
replace cellphone_exp = cellphone_exp*12
*</_cellphone_exp_>

*<_tel_exp_>
*<_tel_exp_note_> Total consumption of all telephone services *</_tel_exp_note_>
*<_tel_exp_note_> tel_exp brought in from  *</_tel_exp_note_>
egen    temp = rsum(nf_value2504 nf_inkind_value2504), missing
replace temp = temp*12
egen tel_exp = rowtotal(landphone_exp cellphone_exp temp), missing
drop temp
*</_tel_exp_>

*<_telefax_exp_>
*<_telefax_exp_note_> Total consumption of telefax services  *</_telefax_exp_note_>
*<_telefax_exp_note_> telefax_exp brought in from  *</_telefax_exp_note_>
gen telefax_exp = .
*</_telefax_exp_>

*<_comm_exp_>
*<_comm_exp_note_> Total consumption of all telecommunication services  *</_comm_exp_note_>
*<_comm_exp_note_> comm_exp brought in from  *</_comm_exp_note_>
egen    temp = rsum(nf_value2501 nf_inkind_value2501 nf_value2509 nf_inkind_value2509), missing
replace temp = temp*12
egen comm_exp = rowtotal(landphone_exp cellphone_exp internet_exp telefax_exp temp), missing
drop temp
*</_comm_exp_>

*<_tv_exp_>
*<_tv_exp_note_> Total consumption of TV broadcasting services  *</_tv_exp_note_>
*<_tv_exp_note_> tv_exp brought in from  *</_tv_exp_note_>
egen    tv_exp = rsum(nf_value2711 nf_inkind_value2711), missing
replace tv_exp = tv_exp*12
*</_tv_exp_>

*<_tvintph_exp_>
*<_tvintph_exp_note_> Total consumption of tv, internet and telephone  *</_tvintph_exp_note_>
*<_tvintph_exp_note_> tvintph_exp brought in from  *</_tvintph_exp_note_>
egen tvintph_exp = rowtotal(internet_exp tel_exp tv_exp), missing
*</_tvintph_exp_>

*<_utl_exp_>
*<_utl_exp_note_> Total annual consumption of all utilities excluding telecom and other housing *</_utl_exp_note_>
*<_utl_exp_note_> utl_exp brought in from  *</_utl_exp_note_>
egen utl_exp = rowtotal(elec_exp gas_exp liquid_exp solid_exp central_exp water_exp waste_exp othfuel_exp), missing
*</_utl_exp_>

*<_othhousing_exp_>
*<_othhousing_exp_note_> Total annual consumption of dwelling repair/maintenance *</_othhousing_exp_note_>
*<_othhousing_exp_note_> othhousing_exp brought in from  *</_othhousing_exp_note_>
gen othhousing_exp = .
*</_othhousing_exp_>

*<_dwelmat_exp_>
*<_dwelmat_exp_note_> Total annual consumption of materials for the maintenance and repair of the dwelling *</_dwelmat_exp_note_>
*<_dwelmat_exp_note_> dwelmat_exp brought in from  *</_dwelmat_exp_note_>
gen dwelmat_exp = .
*</_dwelmat_exp_>

*<_dwelothsvc_exp_>
*<_dwelothsvc_exp_note_> Total annual consumption of other services relating to the dwelling *</_dwelothsvc_exp_note_>
*<_dwelothsvc_exp_note_> dwelothsvc_exp brought in from  *</_dwelothsvc_exp_note_>
gen dwelothsvc_exp = .
*</_dwelothsvc_exp_>

*<_dwelsvc_exp_>
*<_dwelsvc_exp_note_> Total annual consumption of services for the maintenance and repair of the dwelling *</_dwelsvc_exp_note_>
*<_dwelsvc_exp_note_> dwelsvc_exp brought in from rawdata *</_dwelsvc_exp_note_>
egen    dwelsvc_exp = rsum(nf_value3505 nf_inkind_value3505), missing
replace dwelsvc_exp = dwelsvc_exp*12
*</_dwelsvc_exp_>


*<_Keep variables_>
order countrycode year hhid pid weight weighttype
sort  hhid pid
*</_Keep variables_>


*<_Save data file_>
quietly do 	"$rootdofiles\_aux\Labels_GMD2.0.do"
save 		"$output\\`filename'.dta", replace
*</_Save data file_>
