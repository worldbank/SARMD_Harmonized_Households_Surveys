/*------------------------------------------------------------------------------
  GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   	BGD_2016_HIES_v01_M_v07_A_SARMD_UTL.do	   </_Program name_>
<_Application_>    	STATA 17.0									 <_Application_>
<_Author(s)_>      	Leo Tornarolli <tornarolli@gmail.com>		  </_Author(s)_>
<_Date created_>   	10-2023									   </_Date created_>
<_Date modified>   	March 2024							      </_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        	BGD											    </_Country_>
<_Survey Title_>   	HIES								       </_Survey Title_>
<_Survey Year_>    	2016										</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:				03-2024
File:				BGD_2016_HIES_v01_M_v07_A_SARMD_UTL.do
First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>
clear all
set more off

local code         		"BGD"
local year         		"2016"
local survey       		"HIES"
local vm           		"01"
local va           		"07"
local type         		"SARMD"
global module       	"UTL"
local yearfolder    	"`code'_`year'_`survey'"
local SARMDfolder    	"`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'"
local filename      	"`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'_${module}"
global output       	"${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\\Data\Harmonized" 
*</_Program setup_>


*<_Datalibweb request_>
use   "${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata\\`yearfolder'_v`vm'_M.dta", clear
egen  idp = concat(hhid idp1), punct(-)
sort  hhid idp
merge 1:1 hhid idp using "${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\Data\Harmonized\\`yearfolder'_v`vm'_M_v`va'_A_`type'_IND.dta" 
*</_Datalibweb request_>


*<_countrycode_>
*<_countrycode_note_> country code *</_countrycode_note_>
/*<_countrycode_note_> iso3 code upper letter           *</_countrycode_note_>*/
*<_countrycode_note_> countrycode brought in from SARMD *</_countrycode_note_>
*</_countrycode_>

*<_year_>
*<_year_note_> Year *</_year_note_>
/*<_year_note_> field work start at       *</_year_note_>*/
*<_year_note_> year brought in from SARMD *</_year_note_>
*</_year_>

*<_idh_>
*<_idh_note_> Household identifier      *</_idh_note_>
*<_idh_note_> idh brought in from SARMD *</_idh_note_>
*</_idh_>

*<_idp_>
*<_idp_note_> Personal identifier       *</_idp_note_>
*<_idp_note_> idp brought in from SARMD *</_idp_note_>
*</_idp_>

*<_weight_>
*<_weight_note_> Household weight *</_weight_note_>
/*<_weight_note_> . *</_weight_note_>*/
*<_weight_note_> weight brought in from SARMD *</_weight_note_>
clonevar weight = wgt
*</_weight_>

*<_weighttype_>
*<_weighttype_note_> Weight type (frequency, probability, analytical, importance) *</_weighttype_note_>
/*<_weighttype_note_> . *</_weighttype_note_>*/
*<_weighttype_note_> weighttype brought in from SARMD *</_weighttype_note_>
*</_weighttype_>



***********************************************************************************************
*** UTILITIES EXPENDITURES
***********************************************************************************************

*<_pwater_exp_>
*<_pwater_exp_note_> Total annual consumption of water supply/piped water *</_pwater_exp_note_>
/*<_pwater_exp_note_>  *</_pwater_exp_note_>*/
*<_pwater_exp_note_> pwater_exp brought in from rawdata *</_pwater_exp_note_>
gen pwater_exp = .
*</_pwater_exp_>

*<_hwater_exp_>
*<_hwater_exp_note_> Total annual consumption of hot water supply *</_hwater_exp_note_>
/*<_hwater_exp_note_>  *</_hwater_exp_note_>*/
*<_hwater_exp_note_> hwater_exp brought in from rawdata *</_hwater_exp_note_>
gen hwater_exp = .
*</_hwater_exp_>

*<_water_exp_>
*<_water_exp_note_> Total annual consumption of water supply and hot water *</_water_exp_note_>
/*<_water_exp_note_> Rawdata variable: s9d2q01==393   *</_water_exp_note_>*/
*<_water_exp_note_> water_exp brought in from rawdata *</_water_exp_note_>
gen     water_exp = s9d2q01_393 
replace water_exp = .		if  water_exp==0
notes water_exp: original variable s9d2q01_393 is "water expenditure (bought bottle or delivered by water truck/water/sewage services)"
*</_water_exp_>


*<_garbage_exp_>
*<_garbage_exp_note_> Total annual consumption of garbage collection *</_garbage_exp_note_>
/*<_garbage_exp_note_>  *</_garbage_exp_note_>*/
*<_garbage_exp_note_> garbage_exp brought in from rawdata *</_garbage_exp_note_>
gen garbage_exp = .
*</_garbage_exp_>

*<_sewage_exp_>
*<_sewage_exp_note_> Total annual consumption of sewage collection *</_sewage_exp_note_>
/*<_sewage_exp_note_>  *</_sewage_exp_note_>*/
*<_sewage_exp_note_> sewage_exp brought in from rawdata *</_sewage_exp_note_>
gen sewage_exp = .
*</_sewage_exp_>

*<_waste_exp _>
*<_waste_exp _note_> Total annual consumption of garbage and sewage collection *</_waste_exp _note_>
/*<_waste_exp _note_>  *</_waste_exp _note_>*/
*<_waste_exp _note_> waste_exp  brought in from rawdata *</_waste_exp _note_>
egen waste_exp = rsum(garbage_exp sewage_exp), missing
*</_waste_exp _>


*<_dwelothsvc_exp_>
*<_dwelothsvc_exp_note_> Total annual consumption of other services relating to the dwelling *</_dwelothsvc_exp_note_>
/*<_dwelothsvc_exp_note_> Rawdata variable: s9d2q01==399   *</_dwelothsvc_exp_note_>*/
*<_dwelothsvc_exp_note_> dwelothsvc_exp brought in from rawdata *</_dwelothsvc_exp_note_>
gen     dwelothsvc_exp = s9d2q01_399
replace dwelothsvc_exp = .		if  dwelothsvc_exp==0
notes   dwelothsvc_exp: original variable s9d2q01_399 is "other related services/expenses"
*</_dwelothsvc_exp_>


*<_elec_exp_>
*<_elec_exp_note_> Total annual consumption of electricity *</_elec_exp_note_>
/*<_elec_exp_note_> Rawdata variable: s9cq03==247   *</_elec_exp_note_>*/
*<_elec_exp_note_> elec_exp brought in from rawdata *</_elec_exp_note_>
gen 	elec_exp = s9cq03_247*12
replace elec_exp = .			if  elec_exp==0
notes   elec_exp: original variable s9cq03_247 is "electricity"
*</_elec_exp_>


*<_ngas_exp _>
*<_ngas_exp _note_> Total annual consumption of network/natural gas *</_ngas_exp _note_>
/*<_ngas_exp _note_>  *</_ngas_exp _note_>*/
*<_ngas_exp _note_> ngas_exp brought in from rawdata *</_ngas_exp _note_>
gen ngas_exp = .
*</_ngas_exp _>

*<_LPG_exp _>
*<_LPG_exp _note_> Total annual consumption of liquefied gas *</_LPG_exp _note_>
/*<_LPG_exp _note_>  *</_LPG_exp _note_>*/
*<_LPG_exp _note_> LPG_exp brought in from rawdata  *</_LPG_exp _note_>
gen LPG_exp = .
*</_LPG_exp _>

*<_gas_exp_>
*<_gas_exp_note_> Total annual consumption of network/natural and liquefied gas *</_gas_exp_note_>
/*<_gas_exp_note_> Rawdata variable: s9cq03==246  *</_gas_exp_note_>*/
*<_gas_exp_note_> gas_exp brought in from rawdata *</_gas_exp_note_>
gen     gas_exp = s9cq03_246*12
replace gas_exp = .		if  gas_exp==0
notes   gas_exp: original variable s9cq03_246 is "gas (natural, biogas)/LPG"
*</_gas_exp_>


*<_diesel_exp _>
*<_diesel_exp _note_> Total annual consumption of diesel *</_diesel_exp _note_>
/*<_diesel_exp _note_> Rawdata variable: s9cq03==293     *</_diesel_exp _note_>*/
*<_diesel_exp _note_> diesel_exp brought in from rawdata *</_diesel_exp _note_>
gen     diesel_exp = s9cq03_293*12
replace diesel_exp = .		if  diesel_exp==0
*</_diesel_exp _>

*<_kerosene_exp_>
*<_kerosene_exp_note_> Total annual consumption of kerosene *</_kerosene_exp_note_>
/*<_kerosene_exp_note_> Rawdata variable: s9cq03==244       *</_kerosene_exp_note_>*/
*<_kerosene_exp_note_> kerosene_exp brought in from rawdata *</_kerosene_exp_note_>
gen     kerosene_exp = s9cq03_244*12
replace kerosene_exp = .		if  kerosene_exp==0
*</_kerosene_exp_>

*<_gasoline_exp _>
*<_gasoline_exp _note_> Total annual consumption of gasoline  *</_gasoline_exp _note_>
/*<_gasoline_exp _note_> Rawdata variable: s9cq03==292        *</_gasoline_exp _note_>*/
*<_gasoline_exp _note_> gasoline_exp brought in from rawdata  *</_gasoline_exp _note_>
gen 	gasoline_exp = s9cq03_292*12
replace gasoline_exp = .		if  gasoline_exp==0
notes   gasoline_exp: original variable s9cq03_292 is "petrol"
*</_gasoline_exp _>

*<_othliq_exp _>
*<_othliq_exp _note_> Total annual consumption of other liquid fuels *</_othliq_exp _note_>
/*<_othliq_exp _note_> Rawdata variable: s9cq03==294      *</_othliq_exp _note_>*/
*<_othliq_exp _note_> othliq_exp brought in from rawdata  *</_othliq_exp _note_>
gen   	othliq_exp = s9cq03_294*12
replace othliq_exp = .		if  othliq_exp==0
notes 	othliq_exp: original variable s9cq03_294 is "motoroil/CNG, etc."
*</_othliq_exp _>

*<_liquid_exp_>
*<_liquid_exp_note_> Total annual consumption of all liquid fuels *</_liquid_exp_note_>
/*<_liquid_exp_note_>  *</_liquid_exp_note_>*/
*<_liquid_exp_note_> liquid_exp brought in from rawdata *</_liquid_exp_note_>
egen liquid_exp = rsum(diesel_exp kerosene_exp gasoline_exp othliq_exp), missing
*</_liquid_exp_>


*<_wood_exp_>
*<_wood_exp_note_> Total annual consumption of firewood *</_wood_exp_note_>
/*<_wood_exp_note_> Rawdata variable: s9cq03==241       *</_wood_exp_note_>*/
*<_wood_exp_note_> wood_exp brought in from rawdata     *</_wood_exp_note_>
gen 	wood_exp = s9cq03_241*12
replace wood_exp = .		if  wood_exp==0
*</_wood_exp_>

*<_coal_exp_>
*<_coal_exp_note_> Total annual consumption of coal *</_coal_exp_note_>
/*<_coal_exp_note_> Rawdata variable: s9cq03==248   *</_coal_exp_note_>*/
*<_coal_exp_note_> coal_exp brought in from rawdata *</_coal_exp_note_>
gen   	coal_exp = s9cq03_248*12
replace coal_exp = .		if  coal_exp==0
notes 	coal_exp: original variable s9cq03_248 is "pit coal/char coal/wood coal"
*</_coal_exp_>

*<_peat_exp _>
*<_peat_exp _note_> Total annual consumption of peat *</_peat_exp _note_>
/*<_peat_exp _note_>  *</_peat_exp _note_>*/
*<_peat_exp _note_> peat_exp  brought in from rawdata *</_peat_exp _note_>
gen peat_exp = .
*</_peat_exp _>

*<_othsol_exp _>
*<_othsol_exp _note_> Total annual consumption of other solid fuels *</_othsol_exp _note_>
/*<_othsol_exp _note_> Rawdata variable: s9cq03==242, s9cq03==243, s9cq03==245 & s9cq03==249 *</_othsol_exp _note_>*/
*<_othsol_exp _note_> othsol_exp  brought in from rawdata *</_othsol_exp _note_>
gen aux1 = s9cq03_242*12
gen aux2 = s9cq03_243*12
gen aux3 = s9cq03_245*12
gen aux4 = s9cq03_249*12

egen  	othsol_exp = rsum(aux1 aux2 aux3 aux4), missing
replace othsol_exp = .		if  othsol_exp==0
notes 	othsol_exp: original variable s9cq03_242 is "cow dung/cakes/bhushi/wood-powder"
notes 	othsol_exp: original variable s9cq03_243 is "jute sticks"
notes 	othsol_exp: original variable s9cq03_245 is "agri byproducts fuel: paddy, hag, pressed sugarcane and dried com plants, etc."
notes 	othsol_exp: original variable s9cq03_249 is "other fuels and light (e.g. matches and candles, etc.)"
drop aux1-aux4
*</_othsol_exp _>

*<_solid_exp _>
*<_solid_exp _note_> Total annual consumption of all solid fuels *</_solid_exp _note_>
/*<_solid_exp _note_>  *</_solid_exp _note_>*/
*<_solid_exp _note_> solid_exp  brought in from rawdata *</_solid_exp _note_>
egen solid_exp = rsum(wood_exp coal_exp peat_exp othsol_exp), missing
*</_solid_exp _>


*<_othfuel_exp_>
*<_othfuel_exp_note_> Total annual consumption of all other fuels *</_othfuel_exp_note_>
/*<_othfuel_exp_note_>  *</_othfuel_exp_note_>*/
*<_othfuel_exp_note_> othfuel_exp brought in from rawdata *</_othfuel_exp_note_>
gen othfuel_exp= . 
*</_othfuel_exp_>


*<_central_exp_>
*<_central_exp_note_> Total annual consumption of central heating *</_central_exp_note_>
/*<_central_exp_note_>  *</_central_exp_note_>*/
*<_central_exp_note_> central_exp brought in from rawdata *</_central_exp_note_>
gen central_exp = .
*</_central_exp_>

*<_heating_exp_>
*<_heating_exp_note_> Total annual consumption of heating *</_heating_exp_note_>
/*<_heating_exp_note_>  *</_heating_exp_note_>*/
*<_heating_exp_note_> heating_exp brought in from rawdata *</_heating_exp_note_>
egen heating_exp = rsum(central_exp hwater_exp), missing
*</_heating_exp_>


*<_utl_exp_>
*<_utl_exp_note_> Total annual consumption of all utilities excluding telecom and other housing *</_utl_exp_note_>
/*<_utl_exp_note_>  *</_utl_exp_note_>*/
*<_utl_exp_note_> utl_exp brought in from rawdata *</_utl_exp_note_>
egen utl_exp = rsum(elec_exp gas_exp liquid_exp solid_exp central_exp water_exp waste_exp othfuel_exp), missing
*</_utl_exp_>


*<_dwelmat_exp_>
*<_dwelmat_exp_note_> Total annual consumption of materials for the maintenance and repair of the dwelling *</_dwelmat_exp_note_>
/*<_dwelmat_exp_note_>  *</_dwelmat_exp_note_>*/
*<_dwelmat_exp_note_> dwelmat_exp brought in from rawdata *</_dwelmat_exp_note_>
gen dwelmat_exp = .
*</_dwelmat_exp_>

*<_dwelsvc_exp_>
*<_dwelsvc_exp_note_> Total annual consumption of services for the maintenance and repair of the dwelling *</_dwelsvc_exp_note_>
/*<_dwelsvc_exp_note_>  *</_dwelsvc_exp_note_>*/
*<_dwelsvc_exp_note_> dwelsvc_exp brought in from rawdata *</_dwelsvc_exp_note_>
gen dwelsvc_exp = .
*</_dwelsvc_exp_>


*<_othhousing_exp_>
*<_othhousing_exp_note_> Total annual consumption of dwelling repair/maintenance *</_othhousing_exp_note_>
/*<_othhousing_exp_note_>  *</_othhousing_exp_note_>*/
*<_othhousing_exp_note_> othhousing_exp brought in from rawdata *</_othhousing_exp_note_>
egen    othhousing_exp = rsum(s9d2q01_394 s9d2q01_395 s9d2q01_396 s9d2q01_397), missing
replace othhousing_exp = .		if  othhousing_exp==0
notes 	othhousing_exp: original variable s9d2q01_394 is "home additions/improvements"
notes 	othhousing_exp: original variable s9d2q01_395 is "painting"
notes 	othhousing_exp: original variable s9d2q01_396 is "disaster-related maintenance/repair"
notes 	othhousing_exp: original variable s9d2q01_397 is "other routine maintenance/repair"
*</_othhousing_exp_>


*<_transfuel_exp_>
*<_transfuel_exp_note_> Total annual consumption of fuels for personal transportation *</_transfuel_exp_note_>
/*<_transfuel_exp_note_>  *</_transfuel_exp_note_>*/
*<_transfuel_exp_note_> transfuel_exp brought in from rawdata *</_transfuel_exp_note_>
gen transfuel_exp = .
*</_transfuel_exp_>


*<_landphone_exp_>
*<_landphone_exp_note_> Total annual consumption of landline phone services *</_landphone_exp_note_>
/*<_landphone_exp_note_>  *</_landphone_exp_note_>*/
*<_landphone_exp_note_> landphone_exp brought in from rawdata *</_landphone_exp_note_>
gen landphone_exp = .
*</_landphone_exp_>

*<_cellphone_exp_>
*<_cellphone_exp_note_> Total annual consumption of cellphone services *</_cellphone_exp_note_>
/*<_cellphone_exp_note_>  *</_cellphone_exp_note_>*/
*<_cellphone_exp_note_> cellphone_exp brought in from rawdata *</_cellphone_exp_note_>
gen cellphone_exp = .
*</_cellphone_exp_>

*<_tel_exp_>
*<_tel_exp_note_> Total consumption of all telephone services *</_tel_exp_note_>
/*<_tel_exp_note_>  *</_tel_exp_note_>*/
*<_tel_exp_note_> tel_exp brought in from rawdata *</_tel_exp_note_>
egen tel_exp = rsum(landphone_exp cellphone_exp), missing
*</_tel_exp_>


*<_internet_exp_>
*<_internet_exp_note_> Total consumption of internet services *</_internet_exp_note_>
/*<_internet_exp_note_>  *</_internet_exp_note_>*/
*<_internet_exp_note_> internet_exp brought in from rawdata   *</_internet_exp_note_>
gen internet_exp = .
*</_internet_exp_>


*<_telefax_exp_>
*<_telefax_exp_note_> Total consumption of telefax services *</_telefax_exp_note_>
/*<_telefax_exp_note_>  *</_telefax_exp_note_>*/
*<_telefax_exp_note_> telefax_exp brought in from rawdata *</_telefax_exp_note_>
gen telefax_exp = .
*</_telefax_exp_>


*<_comm_exp_>
*<_comm_exp_note_> Total consumption of all telecommunication services *</_comm_exp_note_>
/*<_comm_exp_note_>  *</_comm_exp_note_>*/
*<_comm_exp_note_> comm_exp brought in from rawdata *</_comm_exp_note_>
gen   	comm_exp = s9cq03_296*12
replace comm_exp = .		if  comm_exp==0
notes 	comm_exp: original variable s9cq03_296 is "telephone bill/ charges/mobile/internet bill"
*</_comm_exp_>


*<_tv_exp_>
*<_tv_exp_note_> Total consumption of TV broadcasting services *</_tv_exp_note_>
/*<_tv_exp_note_>  *</_tv_exp_note_>*/
*<_tv_exp_note_> tv_exp brought in from rawdata *</_tv_exp_note_>
gen tv_exp = .
*</_tv_exp_>


*<_tvintph_exp_>
*<_tvintph_exp_note_> Total consumption of tv, internet and telephone  *</_tvintph_exp_note_>
/*<_tvintph_exp_note_>  *</_tvintph_exp_note_>*/
*<_tvintph_exp_note_> tvintph_exp brought in from rawdata *</_tvintph_exp_note_>
egen tvintph_exp = rsum(internet_exp tel_exp tv_exp), missing
*</_tvintph_exp_>



***********************************************************************************************
*** ACCESS TO UTILITIES SERVICES
***********************************************************************************************

*<_sanitation_original_>
*<_sanitation_original_note_>  Original survey response in string for sanitation_source variable *</_sanitation_original_note_>
/*<_sanitation_original_note_> *</_sanitation_original_note_>*/
*<_sanitation_original_note_> sanitation_original brought in from rawdata *</_sanitation_original_note_>
gen sanitation_original = toilet_orig
*</_sanitation_original_>

*<_sanitation_source_>
*<_sanitation_source_note_> Sources of sanitation facilities *</_sanitation_source_note_>
/*<_sanitation_source_note_> 1 "A flush toilet" 2 "A piped sewer system" 3 "A septic tank" 4 "Pit latrine" 5 "Ventilated improved pit latrine (VIP)" 6 "Pit latrine with slab" 7 "Composting toilet" 8 "Special case" 9 "A flush/pour flush to elsewhere" 10 "A pit latrine without slab" 11 "Bucket" 12 "Hanging toilet or hanging latrine" 13 "No facilities or bush or field" 14 "Other" *</_sanitation_source_note_>*/
*<_sanitation_source_note_> sanitation_source brought in from rawdata *</_sanitation_source_note_>
gen sanitation_source = .
*</_sanitation_source_>

*<_imp_san_rec_>
*<_imp_san_rec_note_> Improved sanitation facility recommended estimate (not considering sharing) *</_imp_san_rec_note_>
/*<_imp_san_rec_note_> 1 "Yes" 0 "No" *</_imp_san_rec_note_>*/
*<_imp_san_rec_note_> imp_san_rec brought in from rawdata *</_imp_san_rec_note_>
gen imp_san_rec = sar_improved_toilet
*</_imp_san_rec_>

*<_toilet_acc_>
*<_toilet_acc_note_> Access to flushed toilet *</_toilet_acc_note_>
/*<_toilet_acc_note_> 0 "No" 1 "Yes, in premise" 2 "Yes, but not in premise including public toilet" 3 "Yes, unstated whether in or outside premise" *</_toilet_acc_note_>*/
*<_toilet_acc_note_> toilet_acc brought in from rawdata *</_toilet_acc_note_>
gen 	toilet_acc = 3 				if  improved_sanitation==1
replace toilet_acc = 0 				if  improved_sanitation==0 
*</_toilet_acc_>

*<_sewer_>
*<_sewer_note_> sewer *</_sewer_note_>
/*<_sewer_note_> 0 "No" 1 "flush/pour flush to piped sewer system" *</_sewer_note_>*/
*<_sewer_note_> sewer brought in from rawdata *</_sewer_note_>
gen     sewer = .
*</_sewer_>

*<_open_def_>
*<_open_def_note_> open defecation *</_open_def_note_>
/*<_open_def_note_>  *</_open_def_note_>*/
*<_open_def_note_> open_def brought in from rawdata *</_open_def_note_>
gen 	open_def = .
replace open_def = 0					if  s6aq10>=1 & s6aq10<=5
replace open_def = 1					if  s6aq10==6
*</_open_def_>

*<_water_original_>
*<_water_original_note_> Original survey response in string for water_source variable *</_water_original_note_>
/*<_water_original_note_>  *</_water_original_note_>*/
*<_water_original_note_> water_original brought in from rawdata *</_water_original_note_>
gen water_original = water_orig
*</_water_original_>

*<_water_source_>
*<_water_source_note_> Sources of drinking water *</_water_source_note_>
/*<_water_source_note_> 1 "Piped water into dwelling" 2 "Piped water to yard/plot" 3 "Public tap or standpipe" 4 "Tube well or borehole" 5 "Protected dug well" 6 "Protected spring" 7 "Bottled water" 8 "Rainwater" 9 "Unprotected spring" 10 "Unprotected dug well" 11 "Cart with small tank/drum" 12 "Tanker-truck" 13 "Surface water" 14 "Other" *</_water_source_note_>*/
*<_water_source_note_> water_source brought in from rawdata *</_water_source_note_>
gen     water_source = .
*</_water_source_>

*<_imp_wat_rec_>
*<_imp_wat_rec_note_> Improved water recommended estimate *</_imp_wat_rec_note_>
/*<_imp_wat_rec_note_> 1 "Yes" 0 "No" *</_imp_wat_rec_note_>*/
*<_imp_wat_rec_note_> imp_wat_rec brought in from rawdata *</_imp_wat_rec_note_>
gen imp_wat_rec = sar_improved_water
*</_imp_wat_rec_>

*<_piped_>
*<_piped_note_>  Access to piped water *</_piped_note_>
/*<_piped_note_>  *</_piped _note_>*/
*<_piped_note_> piped  brought in from rawdata *</_piped_note_>
gen 	piped = 0
replace piped = 1				if  water_source>=1 & water_source<=3
*</_piped_>

*<_pipedwater_acc_>
*<_pipedwater_acc_note_> Access to piped water *</_pipedwater_acc_note_>
/*<_pipedwater_acc_note_>  *</_pipedwater_acc_note_>*/
*<_pipedwater_acc_note_> piped  brought in from rawdata *</_pipedwater_acc_note_>
gen pipedwater_acc = .
*</_piped _>


*<_piped_to_prem_>
*<_piped_to_prem_note_> Access to piped water on premises *</_piped_to_prem_note_>
/*<_piped_to_prem_note_> 1 "Yes" 0 "No" *</_piped_to_prem_note_>*/
*<_piped_to_prem_note_> piped_to_prem brought in from rawdata *</_piped_to_prem_note_>
gen 	piped_to_prem = 0	
replace piped_to_prem = 1			if  water_source>=1 & water_source<=2
*</_piped_to_prem_>

*<_w_30m_>
*<_w_30m_note_> Access to water within 30 minutes *</_w_30m_note_>
/*<_w_30m_note_> 1 "Collection time of imp_wat_rec less than or equal to 30 mins" 0 "Collection time of imp_wat_rec more than 30 mins" *</_w_30m_note_>*/
*<_w_30m_note_> w_30m brought in from rawdata *</_w_30m_note_>
gen   w_30m = .
notes w_30: the HIES 2016 does not contain information to define this variable

*</_w_30m_>

*<_w_avail_>
*<_w_avail_note_> Water is available when needed *</_w_avail_note_>
/*<_w_avail_note_> 1 "water is available continuously, reliable source" 0 "water source is unreliable" *</_w_avail_note_>*/
*<_w_avail_note_> w_avail brought in from rawdata *</_w_avail_note_>
gen   w_avail = .
notes w_avail: the HIES 2016 does not contain information to define this variable
*</_w_avail_>

*<_watertype_quest_>
*<_watertype_quest_note_> Type of water questions used in the survey *</_watertype_quest_note_>
/*<_watertype_quest_note_> 1 "Drinking water" 2 "General water" 3 "Both" 4 "Other" *</_watertype_quest_note_>*/
*<_watertype_quest_note_> watertype_quest brought in from rawdata *</_watertype_quest_note_>
gen   watertype_quest = 1
notes watertype_quest: there is another question (variable s6aq16) about source of water for other use
*</_watertype_quest_>

*<_central_acc_>
*<_central_acc_note_> Access to central heating *</_central_acc_note_>
/*<_central_acc_note_> 1 "Yes" 0 "No" *</_central_acc_note_>*/
*<_central_acc_note_> central_acc brought in from rawdata *</_central_acc_note_>
gen   central_acc = .
notes central_acc: the HIES 2016 does not contain information to define this variable
*</_central_acc_>

*<_heatsource_>
*<_heatsource_note_> Main source of heating *</_heatsource_note_>
/*<_heatsource_note_> 1 "Firewood" 2 "Kerosene" 3 "Charcoal" 4 "Electricity" 5 "Gas" 6 "Central" 9 "Other" 10 "No heating" *</_heatsource_note_>*/
*<_heatsource_note_> heatsource brought in from rawdata *</_heatsource_note_>
gen   heatsource = .
notes heatsource: the HIES 2016 does not contain information to define this variable
*</_heatsource_>

*<_gas_>
*<_gas_note_> Connection to gas/Usage of gas *</_gas_note_>
/*<_gas_note_>  *</_gas_note_>*/
*<_gas_note_> gas brought in from rawdata *</_gas_note_>
gen   gas = .
notes gas: the HIES 2016 does not contain information to define this variable
*</_gas_>

*<_cooksource_>
*<_cooksource_note_> Main cooking fuel *</_cooksource_note_>
/*<_cooksource_note_>  1 "Firewood" 2 "Kerosene" 3 "Charcoal" 4 "Electricity" 5 "Gas" 9 "Other" 10 "No cook source" *</_cooksource_note_>*/
*<_cooksource_note_> cooksource brought in from rawdata *</_cooksource_note_>
gen   cooksource = .
notes cooksource: the HIES 2016 does not contain information to define this variable
*</_cooksource_>

*<_electricity_>
*<_electricity_note_> Access to electricity in dwelling *</_electricity_note_>
/*<_electricity_note_> 1 "Yes" 0 "No" *</_electricity_note_>*/
*<_electricity_note_> electricity brought in from SARMD *</_electricity_note_>
*</_electricity_>

*<_lightsource_>
*<_lightsource_note_> Main source of lighting  *</_lightsource_note_>
/*<_lightsource_note_> 1 "Electricity" 2 "Kerosene" 3 "Candles" 4 "Gas" 9 "Other" 10 "No light source" *</_lightsource_note_>*/
*<_lightsource_note_> lightsource brought in from rawdata *</_lightsource_note_>
gen   lightsource = .
notes lightsource: the HIES 2016 does not contain information to define this variable
*</_lightsource_>

*<_electyp_>
*<_electyp_note_> Lighting and/or electricity – type of *</_electyp_note_>
/*<_electyp_note_> 1 "Electricity" 2 "Gas" 3 "Lamp" 4 "Others" 10 "No cook and light source" *</_electyp_note_>*/
*<_electyp_note_> electyp brought in from rawdata *</_electyp_note_>
gen   electyp = .
notes electyp: the HIES 2016 does not contain information to define this variable
*</_electyp_>

*<_elec_acc_>
*<_elec_acc_note_> Connection to electricity in dwelling *</_elec_acc_note_>
/*<_elec_acc_note_> 1 "Yes, public/quasi-public" 2 "Yes, private" 3 "Yes, source unstated" 4 "No" *</_elec_acc_note_>*/
*<_elec_acc_note_> elec_acc brought in from rawdata *</_elec_acc_note_>
gen     elec_acc = .
replace elec_acc = 3			if  electricity==1
replace elec_acc = 4			if  electricity==0
*</_elec_acc_>

*<_elechr_acc_>
*<_elechr_acc_note_> Electricity availability (hr/day) *</_elechr_acc_note_>
/*<_elechr_acc_note_>  *</_elechr_acc_note_>*/
*<_elechr_acc_note_> elechr_acc brought in from rawdata *</_elechr_acc_note_>
gen elechr_acc = s6aq18
*</_elechr_acc_>

*<_waste_>
*<_waste_note_> Main types of solid waste disposal *</_waste_note_>
/*<_waste_note_> 1 "Solid waste collected on a regular basis by authorized collectors" 2 "Solid waste collected on an irregular basis by authorized collectors" 3 "Solid waste collected by self-appointed collectors" 4 "Occupants dispose of solid waste in a local dump supervised by authorities" 5 "Occupants dispose of solid waste in a local dump not supervised by authorities" 6 "Occupants burn solid waste" 7 "Occupants bury solid waste" 8 "Occupant dispose solid waste into river, sea, creek, pond" 9 "Occupants compost solid waste" 10 "Other arrangement" *</_waste_note_>*/
*<_waste_note_> waste brought in from rawdata *</_waste_note_>
gen   waste = .
notes waste: the HIES 2016 does not contain information to define this variable
*</_waste_>


*<_Keep variables_>
order countrycode year hhid pid weight weighttype
sort  hhid pid
*</_Keep variables_>


*<_Save data file_>
quietly do 	"$rootdofiles\_aux\Labels_GMD2.0.do"
save 		"$output\\`filename'.dta", replace
*</_Save data file_>
