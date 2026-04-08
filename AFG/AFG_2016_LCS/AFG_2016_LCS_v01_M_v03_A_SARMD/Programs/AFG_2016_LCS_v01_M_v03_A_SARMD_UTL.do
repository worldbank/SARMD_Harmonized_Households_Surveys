/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   `code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'_UTL.do	</_Program name_>
<_Application_>    STATA 16.0	<_Application_>
<_Author(s)_>      Navishti Das and Javier Parada	</_Author(s)_>
<_Date created_>   03-03-2019	</_Date created_>
<_Date modified>    3 Mar 2020	</_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        AFG	</_Country_>
<_Survey Title_>   LCS	</_Survey Title_>
<_Survey Year_>    2016	</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:	03-03-2019
File:	`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'_UTL.do	
- First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>

clear all
set more off

local code         "AFG"
local year         "2016"
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
	* input data
	use "${output}/`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD_IND", clear
	rename idh hh_id
	rename idp ind_id
	* individual-level assembled data
	merge 1:1 hh_id ind_id using "AFG_2016_LCS_M", nogen assert(match)
	* general data
	merge m:1 hh_id using "h_04_10", nogen assert(match)
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
	
	*<_Raw data_>
	tempfile raw
	datalibweb, country(AFG) year(2016) type(SARRAW) surveyid(`code'_`year'_`survey'_v`vm'_M) filename(h_04_10.dta)
	ren hh_id idh
	save `raw'
	*</_Raw data_>
	
	*<_Datalibweb request_>
	
	*datalibweb, country(`code') year(`year') type(`type') survey(`survey') vermast(`vm') veralt(`va') mod(IND) clear
	use "${rootdatalib}\\`code'\\`yearfolder'\\`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD\Data\Harmonized\\`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD_IND.dta", clear
	*</_Datalibweb request_>
	
	*<_Merge_>
	merge m:1 idh using `raw'
	drop _merge
	*</_Merge_>
}

*<_countrycode_>
*<_countrycode_note_> country code *</_countrycode_note_>
*<_countrycode_note_> countrycode brought in from SARMD *</_countrycode_note_>
*countrycode
*</_countrycode_>

*<_year_>
*<_year_note_> Year *</_year_note_>
*<_year_note_> year brought in from SARMD *</_year_note_>
*year
*</_year_>

*<_hhid_>
*<_hhid_note_> Household identifier  *</_hhid_note_>
*<_hhid_note_> hhid brought in from SARMD *</_hhid_note_>
cap clonevar hhid = idh
*</_hhid_>

*<_pid_>
*<_pid_note_> Personal identifier  *</_pid_note_>
*<_pid_note_> pid brought in from SARMD *</_pid_note_>
cap clonevar pid  = idp
*</_pid_>

*<_weight_>
*<_weight_note_> Household weight *</_weight_note_>
*<_weight_note_> weight brought in from SARMD *</_weight_note_>
clonevar  weight = wgt
*</_weight_>

*<_weighttype_>
*<_weighttype_note_> Weight type (frequency, probability, analytical, importance) *</_weighttype_note_>
*<_weighttype_note_> weighttype brought in from *</_weighttype_note_>
*gen weighttype = "PW"
*</_weighttype_>

*<_cellphone_exp_>
*<_cellphone_exp_note_> Total annual consumption of cell phone services *</_cellphone_exp_note_>
*<_cellphone_exp_note_> cellphone_exp brought in from  *</_cellphone_exp_note_>
gen cellphone_exp= q_9_16*12
notes cellphone_exp: Multiplied by 12 to annualize
*</_cellphone_exp_>

*<_central_acc_>
*<_central_acc_note_> Access to central heating  *</_central_acc_note_>
*<_central_acc_note_> central_acc brought in from  *</_central_acc_note_>
gen central_acc=.
*</_central_acc_>

*<_central_exp_>
*<_central_exp_note_> Total annual consumption of central heating *</_central_exp_note_>
*<_central_exp_note_> central_exp brought in from  *</_central_exp_note_>
gen central_exp=.
*</_central_exp_>

*<_coal_exp_>
*<_coal_exp_note_> Total annual consumption of coal *</_coal_exp_note_>
*<_coal_exp_note_> coal_exp brought in from  *</_coal_exp_note_>
gen coal_exp=.
*</_coal_exp_>

*<_cooksource_>
*<_cooksource_note_> Main cooking fuel *</_cooksource_note_>
*<_cooksource_note_> cooksource brought in from  *</_cooksource_note_>
gen cooksource= q_4_16
recode cooksource (1 2 4 8=9) (3=1) (5=3) (6=5) (7=4)
*</_cooksource_>

*<_diesel_exp _>
*<_diesel_exp _note_> Total annual consumption of diesel *</_diesel_exp _note_>
*<_diesel_exp _note_> diesel_exp  brought in from  *</_diesel_exp _note_>
gen  diesel_exp =.
*</_diesel_exp _>

*<_dwelmat_exp_>
*<_dwelmat_exp_note_> Total annual consumption of materials for the maintenance and repair of the dwelling *</_dwelmat_exp_note_>
*<_dwelmat_exp_note_> dwelmat_exp brought in from  *</_dwelmat_exp_note_>
gen dwelmat_exp=.
*</_dwelmat_exp_>

*<_dwelothsvc_exp_>
*<_dwelothsvc_exp_note_> Total annual consumption of other services relating to the dwelling *</_dwelothsvc_exp_note_>
*<_dwelothsvc_exp_note_> dwelothsvc_exp brought in from  *</_dwelothsvc_exp_note_>
gen dwelothsvc_exp=.
*</_dwelothsvc_exp_>

*<_dwelsvc_exp_>
*<_dwelsvc_exp_note_> Total annual consumption of services for the maintenance and repair of the dwelling *</_dwelsvc_exp_note_>
*<_dwelsvc_exp_note_> dwelsvc_exp brought in from rawdata *</_dwelsvc_exp_note_>
gen dwelsvc_exp= .
notes dwelsvc_exp: Survey collects this combined with cost of construction which is meant to be excluded. Thus blank. 
*</_dwelsvc_exp_>

*<_elec_acc_>
*<_elec_acc_note_> Connection to electricity in dwelling *</_elec_acc_note_>
*<_elec_acc_note_> elec_acc brought in from rawdata *</_elec_acc_note_>
gen elec_acc= .
*</_elec_acc_>

*<_elec_exp_>
*<_elec_exp_note_> Total annual consumption of electricity *</_elec_exp_note_>
*<_elec_exp_note_> elec_exp brought in from rawdata *</_elec_exp_note_>
gen elec_exp= q_4_18_a*12
notes elec_exp: Multiplied by 12 to annualize
*</_elec_exp_>

*<_elechr_acc_>
*<_elechr_acc_note_> Electricity availability (hr/day) *</_elechr_acc_note_>
*<_elechr_acc_note_> elechr_acc brought in from *</_elechr_acc_note_>
gen elechr_acc= .
*</_elechr_acc_>

*<_electricity_>
*<_electricity_note_> Access to electricity in dwelling *</_electricity_note_>
*<_electricity_note_> electricity brought in from SARMD *</_electricity_note_>
drop electricity
egen electricity = anymatch(q_4_14_?), values(1)
replace electricity = . if missing(q_4_14_a) & missing(q_4_14_b) & missing(q_4_14_c) & missing(q_4_14_d) & missing(q_4_14_e) & missing(q_4_14_f) & missing(q_4_14_g) & missing(q_4_14_h) & missing(q_4_14_i)
*</_electricity_>

*<_lightsource_>
*<_lightsource_note_> Main source of lighting  *</_lightsource_note_>
*<_lightsource_note_> lightsource brought in from rawdata *</_lightsource_note_>
gen lightsource= q_4_15
recode lightsource (1=10) (2=1) (3=4) (4=3) (5=2) (6=9)
*</_lightsource_>

*<_electyp_>
*<_electyp_note_> Lighting and/or electricity – type of *</_electyp_note_>
*<_electyp_note_> electyp brought in from  *</_electyp_note_>
gen electyp=.
replace electyp = 1 if cooksource == 4 | lightsource == 1
replace electyp = 2 if (cooksource == 5 | lightsource == 4) & mi(electyp)
replace electyp = 3 if (cooksource == 2 | inlist(lightsource,2,3)) & mi(electyp)
replace electyp = 4 if inlist(cooksource,1,3,9) | lightsource == 9 & mi(electyp)
replace electyp = 10 if cooksource == 10 & lightsource==10
*</_electyp_>

*<_garbage_exp_>
*<_garbage_exp_note_> Total annual consumption of garbage collection *</_garbage_exp_note_>
*<_garbage_exp_note_> garbage_exp brought in from  *</_garbage_exp_note_>
gen garbage_exp= .
*</_garbage_exp_>

*<_gas_>
*<_gas_note_> Connection to gas/Usage of gas *</_gas_note_>
*<_gas_note_> gas brought in from  *</_gas_note_>
gen gas=.
*</_gas_>

*<_gasoline_exp _>
*<_gasoline_exp _note_> Total annual consumption of gasoline *</_gasoline_exp _note_>
*<_gasoline_exp _note_> gasoline_exp  brought in from  *</_gasoline_exp _note_>
gen gasoline_exp =.
*</_gasoline_exp _>

*<_heatsource_>
*<_heatsource_note_> Main source of heating  *</_heatsource_note_>
*<_heatsource_note_> heatsource brought in from rawdata *</_heatsource_note_>
gen heatsource= q_4_17  
recode heatsource (1=10) (3=1) (2 4 5=9) (6=3) (7=5) (8=4)
*</_heatsource_>

*<_hwater_exp_>
*<_hwater_exp_note_> Total annual consumption of hot water supply *</_hwater_exp_note_>
*<_hwater_exp_note_> hwater_exp brought in from  *</_hwater_exp_note_>
gen hwater_exp=.
*</_hwater_exp_>

*<_heating_exp_>
*<_heating_exp_note_> Total annual consumption of heating *</_heating_exp_note_>
*<_heating_exp_note_> heating_exp brought in from  *</_heating_exp_note_>
egen heating_exp= rowtotal(central_exp hwater_exp), missing
*</_heating_exp_>

*<_imp_san_rec_>
*<_imp_san_rec_note_> Improved sanitation facility recommended estimate (not considering sharing) *</_imp_san_rec_note_>
*<_imp_san_rec_note_> imp_san_rec brought in from SARMD *</_imp_san_rec_note_>
clonevar imp_san_rec = improved_sanitation
label values imp_san_rec .
*</_imp_san_rec_>

*<_imp_wat_rec_>
*<_imp_wat_rec_note_> Improved water recommended estimate *</_imp_wat_rec_note_>
*<_imp_wat_rec_note_> imp_wat_rec brought in from SARMD *</_imp_wat_rec_note_>
clonevar imp_wat_rec = improved_water
*</_imp_wat_rec_>

*<_internet_exp_>
*<_internet_exp_note_> Total consumption of internet services  *</_internet_exp_note_>
*<_internet_exp_note_> internet_exp brought in from  *</_internet_exp_note_>
gen internet_exp=.
*</_internet_exp_>

*<_kerosene_exp_>
*<_kerosene_exp_note_> Total annual consumption of kerosene *</_kerosene_exp_note_>
*<_kerosene_exp_note_> kerosene_exp brought in from rawdata *</_kerosene_exp_note_>
gen kerosene_exp=.
*</_kerosene_exp_>

*<_landphone_exp_>
*<_landphone_exp_note_> Total annual consumption of landline phone services *</_landphone_exp_note_>
*<_landphone_exp_note_> landphone_exp brought in from rawdata *</_landphone_exp_note_>
gen landphone_exp= q_9_15*12
notes landphone_exp: Multiplied by 12 to annualize
*</_landphone_exp_>

*<_comm_exp_>
*<_comm_exp_note_> Total consumption of all telecommunication services  *</_comm_exp_note_>
*<_comm_exp_note_> comm_exp brought in from  *</_comm_exp_note_>
egen comm_exp= rowtotal(landphone_exp cellphone_exp q_9_17), missing
replace comm_exp = comm_exp*12
notes comm_exp: Multiplied by 12 to annualize. Incl combined expense of internet and fax, aside from landphone and cellphone.
*</_comm_exp_>


*<_LPG_exp _>
*<_LPG_exp _note_> Total annual consumption of liquefied gas *</_LPG_exp _note_>
*<_LPG_exp _note_> LPG_exp  brought in from  *</_LPG_exp _note_>
gen LPG_exp =.
*</_LPG_exp _>

*<_ngas_exp _>
*<_ngas_exp _note_> Total annual consumption of network/natural gas *</_ngas_exp _note_>
*<_ngas_exp _note_> ngas_exp  brought in from  *</_ngas_exp _note_>
gen ngas_exp =.
*</_ngas_exp _>

*<_othfuel_exp_>
*<_othfuel_exp_note_> Total annual consumption of all other fuels *</_othfuel_exp_note_>
*<_othfuel_exp_note_> othfuel_exp brought in from  *</_othfuel_exp_note_>
gen othfuel_exp=.
*</_othfuel_exp_>

*<_othhousing_exp_>
*<_othhousing_exp_note_> Total annual consumption of dwelling repair/maintenance *</_othhousing_exp_note_>
*<_othhousing_exp_note_> othhousing_exp brought in from  *</_othhousing_exp_note_>
gen othhousing_exp=.
*</_othhousing_exp_>

*<_othliq_exp _>
*<_othliq_exp _note_> Total annual consumption of other liquid fuels *</_othliq_exp _note_>
*<_othliq_exp _note_> othliq_exp  brought in from  *</_othliq_exp _note_>
gen othliq_exp =.
*</_othliq_exp _>

*<_othsol_exp _>
*<_othsol_exp _note_> Total annual consumption of other solid fuels *</_othsol_exp _note_>
*<_othsol_exp _note_> othsol_exp  brought in from  *</_othsol_exp _note_>
gen othsol_exp= q_4_18_e*12
notes othsol_exp: Multiplied by 12 to annualize
*</_othsol_exp _>

*<_peat_exp _>
*<_peat_exp _note_> Total annual consumption of peat *</_peat_exp _note_>
*<_peat_exp _note_> peat_exp  brought in from  *</_peat_exp _note_>
gen peat_exp=. 
*</_peat_exp _>

*<_pwater_exp_>
*<_pwater_exp_note_> Total annual consumption of water supply/piped water  *</_pwater_exp_note_>
*<_pwater_exp_note_> pwater_exp brought in from rawdata *</_pwater_exp_note_>
gen pwater_exp= q_4_23*12 
notes pwater_exp: Multiplied by 12 to annualize
*</_pwater_exp_>

*<_sanitation_original_>
*<_sanitation_original_note_> Original survey response in string for sanitation_source variable *</_sanitation_original_note_>
*<_sanitation_original_note_> sanitation_original brought in from SARMD *</_sanitation_original_note_>
clonevar sanitation_original=toilet_orig
*</_sanitation_original_>

*<_sanitation_source_>
*<_sanitation_source_note_> Sources of sanitation facilities *</_sanitation_source_note_>
*<_sanitation_source_note_> sanitation_source brought in from SARMD *</_sanitation_source_note_>
gen sanitation_source = q_4_19
recode sanitation_source (1=6) (2=10) (3=5) (4=1) (5=3) (6=4) (7=9) (8 9=14) (10=13) (11=14)
*</_sanitation_source_>

*<_open_def_>
*<_open_def_note_> open defecation *</_open_def_note_>
*<_open_def_note_> open_def brought in from  *</_open_def_note_>
recode q_4_19 (10=1) (1/9 11=0) (*=.), g(open_def)
*</_open_def_>

*<_sewage_exp_>
*<_sewage_exp_note_> Total annual consumption of sewage collection *</_sewage_exp_note_>
*<_sewage_exp_note_> sewage_exp brought in from  *</_sewage_exp_note_>
gen sewage_exp=.
*</_sewage_exp_>

*<_sewer_>
*<_sewer_note_> sewer *</_sewer_note_>
*<_sewer_note_> sewer brought in from SARMD *</_sewer_note_>
gen sewer= inlist(sanitation_source,1,2) if sanitation_source!=.
*</_sewer_>

*<_tel_exp_>
*<_tel_exp_note_> Total consumption of all telephone services *</_tel_exp_note_>
*<_tel_exp_note_> tel_exp brought in from  *</_tel_exp_note_>
egen tel_exp= rowtotal(landphone_exp cellphone_exp), missing
*</_tel_exp_>

*<_telefax_exp_>
*<_telefax_exp_note_> Total consumption of telefax services  *</_telefax_exp_note_>
*<_telefax_exp_note_> telefax_exp brought in from  *</_telefax_exp_note_>
gen telefax_exp=.
*</_telefax_exp_>

*<_toilet_acc_>
*<_toilet_acc_note_> Access to flushed toilet  *</_toilet_acc_note_>
*<_toilet_acc_note_> toilet_acc brought in from SARMD *</_toilet_acc_note_>
gen toilet_acc=.
*</_toilet_acc_>

*<_transfuel_exp_>
*<_transfuel_exp_note_> Total annual consumption of fuels for personal transportation *</_transfuel_exp_note_>
*<_transfuel_exp_note_> transfuel_exp brought in from  *</_transfuel_exp_note_>
gen transfuel_exp= q_9_19*12
notes transfuel_exp: Multiplied by 12 to annualize
*</_transfuel_exp_>

*<_tv_exp_>
*<_tv_exp_note_> Total consumption of TV broadcasting services  *</_tv_exp_note_>
*<_tv_exp_note_> tv_exp brought in from  *</_tv_exp_note_>
gen tv_exp=.
*</_tv_exp_>

*<_tvintph_exp_>
*<_tvintph_exp_note_> Total consumption of tv, internet and telephone  *</_tvintph_exp_note_>
*<_tvintph_exp_note_> tvintph_exp brought in from  *</_tvintph_exp_note_>
egen tvintph_exp= rowtotal(internet_exp tel_exp tv_exp), missing
*</_tvintph_exp_>

*<_w_30m_>
*<_w_30m_note_> Access to water within 30 minutes *</_w_30m_note_>
*<_w_30m_note_> w_30m brought in from rawdata *</_w_30m_note_>
gen w_30m= (inlist(q_4_21,1,2) | q_4_22<=30) if imp_wat_rec==1 & (inlist(q_4_21,1,2) | ~missing(q_4_22))
*</_w_30m_>

*<_w_avail_>
*<_w_avail_note_> Water is available when needed *</_w_avail_note_>
*<_w_avail_note_> w_avail brought in from *</_w_avail_note_>
gen w_avail= .
*</_w_avail_>

*<_waste_>
*<_waste_note_> Main types of solid waste disposal *</_waste_note_>
*<_waste_note_> waste brought in from *</_waste_note_>
gen waste= .
*</_waste_>

*<_water_original_>
*<_water_original_note_> Original survey response in string for water_source variable *</_water_original_note_>
*<_water_original_note_> water_original brought in from SARMD *</_water_original_note_>
clonevar water_original= water_orig
*</_water_original_>

*<_water_source_>
*<_water_source_note_> Sources of drinking water *</_water_source_note_>
*<_water_source_note_> water_source brought in from rawdata *</_water_source_note_>
gen water_source = q_4_21
recode water_source (5=6) (6=9) (7=5) (8=10) (9=13) (10=12) (11=14)
*</_water_source_>

*<_watertype_quest_>
*<_watertype_quest_note_> Type of water questions used in the survey *</_watertype_quest_note_>
*<_watertype_quest_note_> watertype_quest brought in from SARMD *</_watertype_quest_note_>
gen watertype_quest = 1
*</_watertype_quest_>

*<_piped _>
*<_piped _note_> Access to piped water *</_piped _note_>
*<_piped _note_> piped  brought in from  *</_piped _note_>
gen piped = 1 if inlist(water_source,1,2,3)
replace piped =  0 if water_source != . & piped == . 
*</_piped _>

*<_piped_to_prem_>
*<_piped_to_prem_note_> Access to piped water on premises *</_piped_to_prem_note_>
*<_piped_to_prem_note_> piped_to_prem brought in from *</_piped_to_prem_note_>
gen piped_to_prem = 1 if inlist(water_source,1,2)
replace piped_to_prem =  0 if water_source != . & piped_to_prem == .
*</_piped_to_prem_>

*<_pipedwater_acc_>
gen pipedwater_acc=.
replace pipedwater_acc=1 if q_4_21==1
replace pipedwater_acc=3 if q_4_21==2 | q_4_21==3
replace pipedwater_acc=0 if inlist(q_4_21,4,5,6,7,8,9,10,11)
*#delimit 
*la def lblpiped_water		0 "No"
*							1 "Yes, in premise"
*							2 "Yes, but not in premise"
*							3 "Yes, unstated whether in or outside premise"
*
*</_pipedwater_acc_>


*<_wood_exp_>
*<_wood_exp_note_> Total annual consumption of firewood *</_wood_exp_note_>
*<_wood_exp_note_> wood_exp brought in from  *</_wood_exp_note_>
gen wood_exp = q_4_18_d*12
notes wood_exp: Multiplied by 12 to annualize
*</_wood_exp_>

*<_water_exp_>
*<_water_exp_note_> Total annual consumption of water supply and hot water *</_water_exp_note_>
*<_water_exp_note_> water_exp brought in from rawdata *</_water_exp_note_>
egen water_exp= rowtotal(pwater_exp hwater_exp), missing
*</_water_exp_>

*<_waste_exp _>
*<_waste_exp _note_> Total annual consumption of garbage and sewage collection *</_waste_exp _note_>
*<_waste_exp _note_> waste_exp  brought in from  *</_waste_exp _note_>
egen waste_exp = rowtotal(garbage_exp sewage_exp), missing
*</_waste_exp _>

*<_gas_exp_>
*<_gas_exp_note_> Total annual consumption of network/natural and liquefied gas *</_gas_exp_note_>
*<_gas_exp_note_> gas_exp brought in from rawdata *</_gas_exp_note_>
gen gas_exp= q_4_18_b
notes gas_exp: Multiplied by 12 to annualize
*</_gas_exp_>

*<_liquid_exp_>
*<_liquid_exp_note_> Total annual consumption of all liquid fuels *</_liquid_exp_note_>
*<_liquid_exp_note_> liquid_exp brought in from  *</_liquid_exp_note_>
gen liquid_exp= q_4_18_c*12
notes liquid_exp: Multiplied by 12 to annualize
*</_liquid_exp_>

*<_solid_exp _>
*<_solid_exp _note_> Total annual consumption of all solid fuels *</_solid_exp _note_>
*<_solid_exp _note_> solid_exp  brought in from  *</_solid_exp _note_>
egen solid_exp= rowtotal(wood_exp coal_exp peat_exp othsol_exp), missing
*</_solid_exp _>

*<_utl_exp_>
*<_utl_exp_note_> Total annual consumption of all utilities excluding telecom and other housing *</_utl_exp_note_>
*<_utl_exp_note_> utl_exp brought in from  *</_utl_exp_note_>
egen utl_exp= rowtotal(elec_exp gas_exp liquid_exp solid_exp central_exp water_exp waste_exp othfuel_exp), missing
*</_utl_exp_>

*<_Keep variables_>
duplicates drop hhid, force
*keep countrycode year hhid pid weight weighttype cellphone_exp central_acc central_exp coal_exp comm_exp cooksource diesel_exp dwelmat_exp dwelothsvc_exp dwelsvc_exp elec_acc elec_exp elechr_acc electricity electyp garbage_exp gas gas_exp gasoline_exp heating_exp heatsource hwater_exp imp_san_rec imp_wat_rec internet_exp kerosene_exp landphone_exp lightsource liquid_exp LPG_exp ngas_exp open_def othfuel_exp othhousing_exp othliq_exp othsol_exp peat_exp piped piped_to_prem pwater_exp sanitation_original sanitation_source sewage_exp sewer solid_exp tel_exp telefax_exp toilet_acc transfuel_exp tv_exp tvintph_exp utl_exp w_30m w_avail waste waste_exp water_exp water_original water_source watertype_quest wood_exp
order countrycode year hhid pid weight weighttype
sort hhid pid 
*</_Keep variables_>
*exit 
  
*<_Save data file_>
if ("`c(username)'"=="sunquat") global rootdofiles "/Users/`c(username)'/Projects/WORLD BANK/2023 SAR QCHECK/SARDATABANK/SARMDdofiles"
quietly do "$rootdofiles/_aux/Labels_GMD2.0.do"
save "$output/`filename'.dta", replace
*</_Save data file_>
