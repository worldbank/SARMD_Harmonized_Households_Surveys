/*----------------------------------------------------------------------------------
  SARMD Harmonization
------------------------------------------------------------------------------------
<_Program name_>   		IND_2022_HCES_v04_M_v01_SARMD_UTL.do	   	   </_Program name_>
<_Application_>    		STATA 17.0									 <_Application_>
<_Author(s)_>      		Leo Tornarolli <tornarolli@gmail.com>		  </_Author(s)_>
<_Date created_>   		02-2026									   </_Date created_>
<_Date modified>    	February 2026						 	  </_Date modified_>
------------------------------------------------------------------------------------
<_Country_>        		IND											    </_Country_>
<_Survey Title_>   		HCES									   </_Survey Title_>
<_Survey Year_>    		2022-2023									</_Survey Year_>
------------------------------------------------------------------------------------
<_Version Control_>
Date:					02-2026
File:					IND_2022_HCES_v04_M_v01_SARMD_UTL.do
First version
</_Version Control_>
----------------------------------------------------------------------------------*/

*<_Program setup_>
clear all
set more off

local code         		"IND"
local year         		"2022"
local survey       		"HCES"
local vm           		"04"
local va           		"01"
local type         		"SARMD"
global module       	"UTL"
local yearfolder    	"`code'_`year'_`survey'"
local SARMDfolder    	"`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'"
local filename      	"`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'_${module}"
cap mkdir				"${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'" 
cap mkdir				"${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\\Data" 
cap mkdir				"${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\\Data\Harmonized" 
global input      		"${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata"
glo output          	"${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\\Data\Harmonized" 
*</_Program setup_>


*<_Datalibweb request_>
use "${input}\\`yearfolder'_v`vm'_M.dta", clear
*</_Datalibweb request_>


*<_countrycode_> 
*<_countrycode_note_> Country code according to ISO-3166 Alpha-3 *</_countrycode_note_>
gen countrycode = "`code'"
gen code = countrycode
*</_countrycode_>

*<_year_>
*<_year_note_> 4-digit year of survey based on IHSN standards *</_year_note_>
capture drop year 
gen year = 2022
*</_year_>

*<_hhid_>
*<_hhid_note_> Household identifier  *</_hhid_note_>
/*<_hhid_note_> . *</_hhid_note_>*/
*<_hhid_note_> hhid brought in from rawdata *</_hhid_note_>
*</_hhid_>

*<_pid_>
*<_pid_note_> Personal identifier  *</_pid_note_>
/*<_pid_note_> country specific *</_pid_note_>*/
*<_pid_note_> pid brought in from rawdata *</_pid_note_>
*</_pid_>

*<_weight_>
*<_weight_note_> Household weight  *</_weight_note_>
/*<_weight_note_> Survey specific information *</_weight_note_>*/
clonevar weight = hhwt
clonevar weight_p = weight
*</_weight_>

*<_weighttype_>
*<_weighttype_note_> Weight type (frequency, probability, analytical, importance) *</_weighttype_note_>
*<_weighttype_note_> weighttype brought in from rawdata *</_weighttype_note_>
gen weighttype = "PW"
*</_weighttype_>

*<_watertype_quest_>
*<_watertype_quest_note_> Type of water questions used in the survey *</_watertype_quest_note_>
/*<_watertype_quest_note_> 1 "Drinking water" 2 "General water" 3 "Both" 4 "Other" *</_watertype_quest_note_>*/
*<_watertype_quest_note_> watertype_quest brought in from raw data *</_watertype_quest_note_>
gen watertype_quest = 1
*</_watertype_quest_>

*<_water_original_>
*<_water_original_note_> Source of Drinking Water-Original from raw file *</_water_original_note_>
/*<_water_original_note_> Original categories from source of drinking water *</_water_original_note_>*/
*<_water_original_note_> water_original brought in from raw data *</_water_original_note_>
* Q4.23: What is the source of drinking water from which most of the drinking water is obtained by the household during last 365 days?
label define b4q4pt23 1 "01 - Bottled Water" 2 "02 - Piped Water into Dwelling" 3 "03 - Piped Water to Yard/Plot" 4 "04 - Piped Water from Neighbour" 5 "05 - Public Tap/Standpipe" 6 "06 - Tubewell" 7 "07 - Hand Pump" 8 "08 - Well: Protected" 9 "09 - Well: Unprotected" 10 "10 - Tanker-Truck: Public" 11 "11 - Tanker-Truck: Private" 12 "12 - Spring: Protected" 13 "13 - Spring: Unprotected" 14 "14 - Rainwater Collection" 15 "15 - Surface Water: Tank/Pond" 16 "16 - Other Surface Water (River/Dam/Stream)" 19 "19 - Other (Cart with Small Tank/Drum)"
label values b4q4pt23 b4q4pt23
decode b4q4pt23, gen(water_original)
*</_water_original_>

*<_water_source_>
*<_water_source_note_> Sources of drinking water *</_water_source_note_>
/*<_water_source_note_> 1 "Piped water into dwelling" 2 "Piped water to yard/plot" 3 "Public tap or standpipe" 4 "Tube well or borehole" 5 "Protected dug well" 6 "Protected spring" 7 "Bottled water" 8 "Rainwater" 9 "Unprotected spring" 10 "Unprotected dug well" 11 "Cart with small tank/drum" 12 "Tanker-truck" 13 "Surface water" 14 "Other" *</_water_source_note_>*/
*<_water_source_note_> water_source brought in from raw data *</_water_source_note_>
* Q4.23: What is the source of drinking water from which most of the drinking water is obtained by the household during last 365 days?
gen     water_source = 1	if  b4q4pt23==2
replace water_source = 2	if  b4q4pt23==3
replace water_source = 3	if  b4q4pt23==5
replace water_source = 4	if  b4q4pt23==6 | b4q4pt23==7
replace water_source = 5	if  b4q4pt23==8
replace water_source = 6	if  b4q4pt23==12
replace water_source = 7	if  b4q4pt23==1
replace water_source = 8	if  b4q4pt23==14
replace water_source = 9	if  b4q4pt23==13
replace water_source = 10	if  b4q4pt23==9
replace water_source = 11	if  b4q4pt23==19
replace water_source = 12	if  b4q4pt23==10 | b4q4pt23==11
replace water_source = 13	if  b4q4pt23==15 | b4q4pt23==16
replace water_source = 14	if  b4q4pt23==4 
*</_water_source_>

*<_imp_wat_rec_>
*<_imp_wat_rec_note_> Improved water recommended estimate *</_imp_wat_rec_note_>
/*<_imp_wat_rec_note_> 1 "Yes" 0 "No" *</_imp_wat_rec_note_>*/
*<_imp_wat_rec_note_> imp_wat_rec defined from watersource *</_imp_wat_rec_note_>
recode water_source (1/8=1) (9/14=0),gen(imp_wat_rec) 
*</_imp_wat_rec_>

*<_piped_>
*<_piped_note_>  Access to piped water *</_piped_note_>
/*<_piped_note_>  *</_piped _note_>*/
*<_piped_note_> piped defined from watersource *</_piped_note_>
recode water_source (1/3=1) (4/14=0), gen(piped)
*</_piped_>

*<_piped_to_prem_>
*<_piped_to_prem_note_> Access to piped water on premises *</_piped_to_prem_note_>
/*<_piped_to_prem_note_> 1 "Yes" 0 "No" *</_piped_to_prem_note_>*/
*<_piped_to_prem_note_> piped_to_prem defined from watersource *</_piped_to_prem_note_>
recode water_source (1/2=1) (3/14=0), gen(piped_to_prem)
*</_piped_to_prem_>

*<_w_30m_>
*<_w_30m_note_> Access to water within 30 minutes *</_w_30m_note_>
/*<_w_30m_note_> 1 "Collection time of water source less than or equal to 30 mins" 0 "Collection time of water source more than 30 mins" *</_w_30m_note_>*/
*<_w_30m_note_> w_30m brought in from raw data *</_w_30m_note_>
destring b4q4pt24, replace
gen 	w_30m = 1	if  b4q4pt24>=0 & b4q4pt24<=30 
replace w_30m = 0	if  b4q4pt24>30 & b4q4pt24<. 
*</_w_30m_>

*<_w_avail_>
*<_w_avail_note_> Water is available when needed *</_w_avail_note_>
/*<_w_avail_note_> 1 "water is available continuously, reliable source" 0 "water source is unreliable" *</_w_avail_note_>*/
*<_w_avail_note_> no information in raw data to define w_avail *</_w_avail_note_>
gen w_avail = .
*</_w_avail_>

*<_sanitation_original_>
*<_sanitation_original_note_>  Original survey response in string for sanitation_source variable *</_sanitation_original_note_>
/*<_sanitation_original_note_> *</_sanitation_original_note_>*/
*<_sanitation_original_note_> sanitation_original brought in from raw data *</_sanitation_original_note_>
label define latrine_type2 1 "01 - Flush/Pour Flush to Piped Sewer System" 2 "02 - Flush/Pour Flush to Septic Tank" 3 "03 - Flush/Pour Flush to Twin Leach Pit" 4 "04 -Flush/Pour Flush to Single Leach Pit" 5 "05 - Flush/Pour Flush to Elsewhere" 6 "06 - Ventilated Improved Pit Latrine" 7 "07 - Pit Latrine with Slab" 8 "08 - Pit Latrine without Slab" 10 "10 - Composting Latrine" 11 "11 - Open Drain" 19 "19 - Others"
label values b4q4pt26 latrine_type2
decode b4q4pt26, gen(sanitation_original)
replace sanitation_original = "12 - No facilities"	if  b4q4pt25==5
*</_sanitation_original_>

*<_sanitation_source_>
*<_sanitation_source_note_> Sources of sanitation facilities *</_sanitation_source_note_>
/*<_sanitation_source_note_> 1 "A flush toilet" 2 "A piped sewer system" 3 "A septic tank" 4 "Pit latrine" 5 "Ventilated improved pit latrine (VIP)" 6 "Pit latrine with slab" 7 "Composting toilet" 8 "Special case" 9 "A flush/pour flush to elsewhere" 10 "A pit latrine without slab" 11 "Bucket" 12 "Hanging toilet or hanging latrine" 13 "No facilities or bush or field" 14 "Other" *</_sanitation_source_note_>*/
*<_sanitation_source_note_> sanitation_source brought in from raw data *</_sanitation_source_note_>
gen     sanitation_source = 1	if  b4q4pt26==3 | b4q4pt26==4	
replace sanitation_source = 2	if  b4q4pt26==1 
replace sanitation_source = 3	if  b4q4pt26==2
replace sanitation_source = 5	if  b4q4pt26==6
replace sanitation_source = 6	if  b4q4pt26==7
replace sanitation_source = 7	if  b4q4pt26==10
replace sanitation_source = 9	if  b4q4pt26==5
replace sanitation_source = 10	if  b4q4pt26==8
replace sanitation_source = 13	if  b4q4pt26==11 | b4q4pt25==5
replace sanitation_source = 14	if  b4q4pt26==19
*</_sanitation_source_>

*<_toilet_acc_>
*<_toilet_acc_note_> Access to flushed toilet *</_toilet_acc_note_>
/*<_toilet_acc_note_> 0 "No" 1 "Yes, in premise" 2 "Yes, but not in premise including public toilet" 3 "Yes, unstated whether in or outside premise" *</_toilet_acc_note_>*/
*<_toilet_acc_note_> toilet_acc brought in from raw data *</_toilet_acc_note_>
gen 	toilet_acc = 0 	
replace toilet_acc = 3	if  b4q4pt26>=1 & b4q4pt26<=5
*</_toilet_acc_>

*<_sewer_>
*<_sewer_note_> sewer *</_sewer_note_>
/*<_sewer_note_> 0 "No" 1 "flush/pour flush to piped sewer system" *</_sewer_note_>*/
*<_sewer_note_> sewer brought in from raw data *</_sewer_note_>
gen     sewer = 0				
replace sewer = 1		if  b4q4pt26==1
*</_sewer_>

*<_open_def_>
*<_open_def_note_> open defecation *</_open_def_note_>
/*<_open_def_note_>  *</_open_def_note_>*/
*<_open_def_note_> open_def brought in from sanitation_source *</_open_def_note_>
gen 	open_def = 0				
replace open_def = 1	if  sanitation_source==13
*</_open_def_>

*<_imp_san_rec_>
*<_imp_san_rec_note_> Improved sanitation facility recommended estimate (not considering sharing) *</_imp_san_rec_note_>
/*<_imp_san_rec_note_> 1 "Yes" 0 "No" *</_imp_san_rec_note_>*/
*<_imp_san_rec_note_> imp_san_rec brought in from sanitation_source *</_imp_san_rec_note_>
gen 	imp_san_rec = 0				 
replace imp_san_rec = 1	if  sanitation_source>=1 & sanitation_source<=7
replace imp_san_rec = 0	if  b4q4pt25!=1		/* shared facilities */
*</_imp_san_rec_>

*<_waste_>
*<_waste_note_> Main types of solid waste disposal *</_waste_note_>
/*<_waste_note_> 1 "Solid waste collected on a regular basis by authorized collectors" 2 "Solid waste collected on an irregular basis by authorized collectors" 3 "Solid waste collected by self-appointed collectors" 4 "Occupants dispose of solid waste in a local dump supervised by authorities" 5 "Occupants dispose of solid waste in a local dump not supervised by authorities" 6 "Occupants burn solid waste" 7 "Occupants bury solid waste" 8 "Occupant dispose solid waste into river, sea, creek, pond" 9 "Occupants compost solid waste" 10 "Other arrangement" *</_waste_note_>*/
*<_waste_note_> no information in raw data to define waste *</_waste_note_>
gen waste = .
*</_waste_>

*<_central_acc_>
*<_central_acc_note_> Access to central heating *</_central_acc_note_>
/*<_central_acc_note_> 1 "Yes" 0 "No" *</_central_acc_note_>*/
*<_central_acc_note_> no information in raw data to define central_acc *</_central_acc_note_>
gen central_acc = .
*</_central_acc_>

*<_heatsource_>
*<_heatsource_note_> Main source of heating *</_heatsource_note_>
/*<_heatsource_note_> 1 "Firewood" 2 "Kerosene" 3 "Charcoal" 4 "Electricity" 5 "Gas" 6 "Central" 9 "Other" 10 "No heating" *</_heatsource_note_>*/
*<_heatsource_note_> no information in raw data to define heatsource *</_heatsource_note_>
gen heatsource = .
*</_heatsource_>

*<_gas_>
*<_gas_note_> Connection to gas/Usage of gas *</_gas_note_>
/*<_gas_note_> 0 "No" 1 "Yes, piped gas (LNG)" 2 "Yes, bottled gas (LPG)" 3 "Yes, but dont know"  *</_gas_note_>*/
*<_gas_note_> gas brought in from raw data *</_gas_note_>
* Q4.21: What is the primary source of energy of the household for cooking?
gen 	gas = 0			
replace gas = 1		if  b4q4pt21==2
replace gas = 2		if  b4q4pt21==3
replace gas = 3		if  b4q4pt21==7 | b4q4pt21==8
notes gas: variable defined using information of the main fuel used for cooking
*</_gas_>

*<_cooksource_>
*<_cooksource_note_> Main cooking fuel *</_cooksource_note_>
/*<_cooksource_note_> 1 "Firewood" 2 "Kerosene" 3 "Charcoal" 4 "Electricity" 5 "Gas" 9 "Other" 10 "No cook source" *</_cooksource_note_>*/
*<_cooksource_note_> cooksource brought in from raw data *</_cooksource_note_>
gen 	cooksource = 1		if  b4q4pt21==1												// firewood and chips 									//
replace cooksource = 2		if  b4q4pt21==5												// kerosene 											//
replace cooksource = 3		if  b4q4pt21==6 | b4q4pt21==10								// coke-coal / charcoal									//
replace cooksource = 4 		if  b4q4pt21==11											// Electricity											//
replace cooksource = 5		if  b4q4pt21==2 | b4q4pt21==3 | b4q4pt21==7 | b4q4pt21==8	// LPG / other natural gas / gobar gas / other biogas	//
replace cooksource = 9		if  b4q4pt21==4 | b4q4pt21==9								// dung cake / Other									//  
replace cooksource = 10		if  b4q4pt21==12											// no cooking arrangement								//
notes 	cooksource: cooksource==4 ("charcoal") includes coke-coal and charcoal 
notes   cooksource: cooksource==9 ("other") includes dung cake, and other
*</_cooksource_>

*<_lightsource_>
*<_lightsource_note_> Main source of lighting  *</_lightsource_note_>
/*<_lightsource_note_> 1 "Electricity" 2 "Kerosene" 3 "Candles" 4 "Gas" 9 "Other" 10 "No light source" *</_lightsource_note_>*/
*<_lightsource_note_> lightsource brought in from raw data *</_lightsource_note_
destring b4q4pt22, replace
gen 	lightsource = 1		if  b4q4pt22==1						// electricity (including generated by wind and solar power generators	// 
replace lightsource = 2		if  b4q4pt22==2						// kerosene																//
replace lightsource = 3		if  b4q4pt22==5						// candles 																//
replace lightsource = 4		if  b4q4pt22==4						// gas																	//
replace lightsource = 9		if  b4q4pt22==3 | b4q4pt22==9		// other oil / other													//
replace lightsource = 10	if  b4q4pt22==6						// no lighting arrangement												//
notes lightsource: lightsource==9 ("other") includes other oil and other
*</_lightsource_>

*<_elec_acc_>
*<_elec_acc_note_> Connection to electricity in dwelling *</_elec_acc_note_>
/*<_elec_acc_note_> 1 "Yes, public/quasi-public" 2 "Yes, private" 3 "Yes, source unstated" 4 "No" *</_elec_acc_note_>*/
*<_elec_acc_note_> elec_acc brought in from raw data *</_elec_acc_note_>
gen     elec_acc = 4			
replace elec_acc = 3		if  b4q4pt22==1	
*</_elec_acc_>

*<_electricity_>
*<_electricity_note_> Access to electricity *</_electricity_note_>
/*<_electricity_note_> Refers to Public or quasi public service availability of electricity from mains. 
Note that having an electrical connection says nothing about the actual electrical service received by the household in a given country or area.
This variable must have the same value for all members of the household *</_electricity_note_>*/
*<_electricity_note_> electricity brought in from raw data *</_electricity_note_>
gen 	electricity = 0		if  b4q4pt22!=.
replace electricity = 1		if  b4q4pt22==1
*</_electricity_>

*<_elechr_acc_>
*<_elechr_acc_note_> Electricity availability (hr/day) *</_elechr_acc_note_>
/*<_elechr_acc_note_>  *</_elechr_acc_note_>*/
*<_elechr_acc_note_> no information in raw data to define elechr_acc *</_elechr_acc_note_>
gen elechr_acc = .
*</_elechr_acc_>

*<_electyp_>
*<_electyp_note_> Lighting and/or electricity – type of *</_electyp_note_>
/*<_electyp_note_> 1 "Electricity" 2 "Gas" 3 "Lamp" 4 "Others" 10 "No cook and light source" *</_electyp_note_>*/
*<_electyp_note_> electyp brought in from cooksource and lightsource *</_electyp_note_>
gen 	electyp = 1 	if  cooksource==4 | lightsource==1
replace electyp = 2 	if (cooksource==5 | lightsource==4) & mi(electyp)
replace electyp = 3 	if (cooksource==2 | inlist(lightsource,2,3)) & mi(electyp)
replace electyp = 4 	if (inlist(cooksource,1,3,9) | lightsource==9) & mi(electyp)
replace electyp = 10 	if  cooksource==10 & lightsource==10
*</_electyp_>


*<_pwater_exp_>
*<_pwater_exp_note_> Total annual consumption of water supply/piped water *</_pwater_exp_note_>
/*<_pwater_exp_note_> Rawdata variable: missing variable *</_pwater_exp_note_>*/
*<_pwater_exp_note_> pwater_exp brought in from raw data *</_pwater_exp_note_>
gen pwater_exp = .
notes pwater_exp: HCES does not include information on this type of expenditure
*</_pwater_exp_>

*<_hwater_exp_>
*<_hwater_exp_note_> Total annual consumption of hot water supply *</_hwater_exp_note_>
/*<_hwater_exp_note_> Rawdata variable: missing variable *</_hwater_exp_note_>*/
*<_hwater_exp_note_> hwater_exp brought in from raw data *</_hwater_exp_note_>
gen hwater_exp = .
notes hwater_exp: HCES does not include information on this type of expenditure
*</_hwater_exp_>

*<_water_exp_>
*<_water_exp_note_> Total annual consumption of water supply and hot water *</_water_exp_note_>
/*<_water_exp_note_> exp540 (water charges) *</_water_exp_note_>*/
*<_water_exp_note_> water_exp brought in from raw data *</_water_exp_note_>
egen    water_exp = rsum(exp540), missing
replace water_exp = water_exp*12
notes water_exp: HCES only includes information on "water charges", without detailed information on the type of water
*</_water_exp_>

*<_garbage_exp_>
*<_garbage_exp_note_> Total annual consumption of garbage collection *</_garbage_exp_note_>
/*<_garbage_exp_note_> Rawdata variable: missing variable *</_garbage_exp_note_>*/
*<_garbage_exp_note_> garbage_exp brought in from raw data *</_garbage_exp_note_>
gen garbage_exp = .
notes garbage_exp: HCES does not include information on this type of expenditure
*</_garbage_exp_>

*<_sewage_exp_>
*<_sewage_exp_note_> Total annual consumption of sewage collection *</_sewage_exp_note_>
/*<_sewage_exp_note_> Rawdata variable: missing variable *</_sewage_exp_note_>*/
*<_sewage_exp_note_> sewage_exp brought in from raw data *</_sewage_exp_note_>
gen sewage_exp = .
notes sewage_exp: HCES does not include information on this type of expenditure
*</_sewage_exp_>

*<_waste_exp _>
*<_waste_exp _note_> Total annual consumption of garbage and sewage collection *</_waste_exp _note_>
/*<_waste_exp _note_>  *</_waste_exp _note_>*/
*<_waste_exp _note_> waste_exp  brought in from raw data *</_waste_exp _note_>
egen waste_exp = rsum(garbage_exp sewage_exp), missing
notes waste_exp: HCES does not include information on this type of expenditure
*</_waste_exp _>

*<_dwelothsvc_exp_>
*<_dwelothsvc_exp_note_> Total annual consumption of other services relating to the dwelling *</_dwelothsvc_exp_note_>
/*<_dwelothsvc_exp_note_> Rawdata variable: missing variable *</_dwelothsvc_exp_note_>*/
*<_dwelothsvc_exp_note_> dwelothsvc_exp brought in from raw data *</_dwelothsvc_exp_note_>
gen dwelothsvc_exp = .
notes dwelothsvc_exp: HCES does not include information on this type of expenditure
*</_dwelothsvc_exp_>

*<_elec_exp_>
*<_elec_exp_note_> Total annual consumption of electricity *</_elec_exp_note_>
/*<_elec_exp_note_> Rawdata variable: exp332 (electricity) *</_elec_exp_note_>*/
*<_elec_exp_note_> elec_exp brought in from raw data *</_elec_exp_note_>
egen 	elec_exp = rsum(exp332), missing 
replace elec_exp = elec_exp*12
*</_elec_exp_>

*<_ngas_exp _>
*<_ngas_exp _note_> Total annual consumption of network/natural gas *</_ngas_exp _note_>
/*<_ngas_exp _note_> Rawdata variable: exp340 (other natural gas) *</_ngas_exp _note_>*/
*<_ngas_exp _note_> ngas_exp brought in from raw data *</_ngas_exp _note_>
egen 	ngas_exp = rsum(exp340), missing
replace ngas_exp = ngas_exp*12 
*</_ngas_exp _>

*<_LPG_exp _>
*<_LPG_exp _note_> Total annual consumption of liquefied gas *</_LPG_exp _note_>
/*<_LPG_exp _note_> Rawdata variable: exp338 (LPG, exclude conveyance) *</_LPG_exp _note_>*/
*<_LPG_exp _note_> LPG_exp brought in from raw data  *</_LPG_exp _note_>
egen 	LPG_exp = rsum(exp338), missing
replace LPG_exp = LPG_exp*12
*</_LPG_exp _>

*<_gas_exp_>
*<_gas_exp_note_> Total annual consumption of network/natural and liquefied gas *</_gas_exp_note_>
/*<_gas_exp_note_>  *</_gas_exp_note_>*/
*<_gas_exp_note_> gas_exp brought in from raw data *</_gas_exp_note_>
egen gas_exp = rsum(ngas_exp LPG_exp), missing
*</_gas_exp_>

*<_gasoline_exp _>
*<_gasoline_exp _note_> Total annual consumption of gasoline *</_gasoline_exp _note_>
/*<_gasoline_exp _note_> Rawdata variable: exp344 (petrol) - exp512 (petrol for vehicle) *</_gasoline_exp _note_>*/
*<_gasoline_exp _note_> gasoline_exp  brought in from raw data *</_gasoline_exp _note_>
egen 	gasoline_exp = rsum(exp344 exp512), missing 
replace gasoline_exp = gasoline_exp*12
*</_gasoline_exp _>

*<_diesel_exp _>
*<_diesel_exp _note_> Total annual consumption of diesel *</_diesel_exp _note_>
/*<_diesel_exp _note_> Rawdata variable: exp345 (diesel) - exp513 (diesel for vehicle) *</_diesel_exp _note_>*/
*<_diesel_exp _note_> diesel_exp brought in from raw data *</_diesel_exp _note_>
egen 	diesel_exp = rsum(exp345 exp513), missing 
replace diesel_exp = diesel_exp*12
*</_diesel_exp _>

*<_kerosene_exp_>
*<_kerosene_exp_note_> Total annual consumption of kerosene *</_kerosene_exp_note_>
/*<_kerosene_exp_note_> Rawdata variable: exp334 (kerosene PDS) - exp335 (kerosene, other sources) *</_kerosene_exp_note_>*/
*<_kerosene_exp_note_> kerosene_exp brought in from raw data *</_kerosene_exp_note_>
egen 	kerosene_exp = rsum(exp334 exp335), missing 
replace kerosene_exp = kerosene_exp*12
*</_kerosene_exp_>

*<_othliq_exp _>
*<_othliq_exp _note_> Total annual consumption of other liquid fuels *</_othliq_exp _note_>
/*<_othliq_exp _note_> Rawdata variable: missing variable *</_othliq_exp _note_>*/
*<_othliq_exp _note_> othliq_exp  brought in from raw data *</_othliq_exp _note_>
gen othliq_exp = .
notes othliq_exp: HCES does not include information on this type of expenditure
*</_othliq_exp _>

*<_liquid_exp_>
*<_liquid_exp_note_> Total annual consumption of all liquid fuels *</_liquid_exp_note_>
/*<_liquid_exp_note_>  *</_liquid_exp_note_>*/
*<_liquid_exp_note_> liquid_exp brought in from raw data *</_liquid_exp_note_>
egen liquid_exp = rsum(diesel_exp kerosene_exp gasoline_exp othliq_exp), missing
*</_liquid_exp_>

*<_wood_exp_>
*<_wood_exp_note_> Total annual consumption of firewood *</_wood_exp_note_>
/*<_wood_exp_note_> Rawdata variable: exp331 (firewood and chips) *</_wood_exp_note_>*/
*<_wood_exp_note_> wood_exp brought in from raw data *</_wood_exp_note_>
egen 	wood_exp = rsum(exp331), missing
replace wood_exp = wood_exp*12
*</_wood_exp_>

*<_coal_exp_>
*<_coal_exp_note_> Total annual consumption of coal *</_coal_exp_note_>
/*<_coal_exp_note_> Rawdata variable: exp337 (coal) - exp341 (charcoal) *</_coal_exp_note_>*/
*<_coal_exp_note_> coal_exp brought in from raw data *</_coal_exp_note_>
egen 	coal_exp = rsum(exp337 exp341), missing 
replace coal_exp = coal_exp*12
*</_coal_exp_>

*<_peat_exp _>
*<_peat_exp _note_> Total annual consumption of peat *</_peat_exp _note_>
/*<_peat_exp _note_>  *</_peat_exp _note_>*/
*<_peat_exp _note_> peat_exp  brought in from raw data *</_peat_exp _note_>
gen peat_exp = .
notes peat_exp: HCES does not include information on this type of expenditure
*</_peat_exp _>

*<_othsol_exp _>
*<_othsol_exp _note_> Total annual consumption of other solid fuels *</_othsol_exp _note_>
/*<_othsol_exp _note_> Rawdata variable: exp333 (dung cake) *</_othsol_exp _note_>*/
*<_othsol_exp _note_> othsol_exp  brought in from raw data *</_othsol_exp _note_>
egen 	othsol_exp = rsum(exp333), missing 
replace othsol_exp = othsol_exp*12
*</_othsol_exp _>

*<_solid_exp _>
*<_solid_exp _note_> Total annual consumption of all solid fuels *</_solid_exp _note_>
/*<_solid_exp _note_>  *</_solid_exp _note_>*/
*<_solid_exp _note_> solid_exp  brought in from raw data *</_solid_exp _note_>
egen solid_exp = rsum(wood_exp coal_exp peat_exp othsol_exp), missing
*</_solid_exp _>

*<_othfuel_exp_>
*<_othfuel_exp_note_> Total annual consumption of all other fuels *</_othfuel_exp_note_>
/*<_othfuel_exp_note_> exp342 (candles) - exp343 (biogas / gobar gas) - exp346 (other)  *</_othfuel_exp_note_>*/
*<_othfuel_exp_note_> othfuel_exp brought in from raw data *</_othfuel_exp_note_>
egen 	othfuel_exp = rsum(exp342 exp343 exp346), missing 
replace othfuel_exp = othfuel_exp*12
*</_othfuel_exp_>

*<_central_exp_>
*<_central_exp_note_> Total annual consumption of central heating *</_central_exp_note_>
/*<_central_exp_note_>  *</_central_exp_note_>*/
*<_central_exp_note_> central_exp brought in from raw data *</_central_exp_note_>
gen central_exp = .
notes central_exp: HCES does not include information on this type of expenditure
*</_central_exp_>

*<_heating_exp_>
*<_heating_exp_note_> Total annual consumption of heating *</_heating_exp_note_>
/*<_heating_exp_note_>  *</_heating_exp_note_>*/
*<_heating_exp_note_> heating_exp brought in from raw data *</_heating_exp_note_>
egen heating_exp = rsum(central_exp hwater_exp), missing
*</_heating_exp_>


*<_utl_exp_>
*<_utl_exp_note_> Total annual consumption of all utilities excluding telecom and other housing *</_utl_exp_note_>
/*<_utl_exp_note_>  *</_utl_exp_note_>*/
*<_utl_exp_note_> utl_exp brought in from raw data *</_utl_exp_note_>
egen utl_exp = rsum(elec_exp gas_exp liquid_exp solid_exp central_exp water_exp waste_exp othfuel_exp), missing
*</_utl_exp_>


*<_dwelmat_exp_>
*<_dwelmat_exp_note_> Total annual consumption of materials for the maintenance and repair of the dwelling *</_dwelmat_exp_note_>
/*<_dwelmat_exp_note_>  *</_dwelmat_exp_note_>*/
*<_dwelmat_exp_note_> dwelmat_exp brought in from raw data *</_dwelmat_exp_note_>
gen dwelmat_exp = .
notes dwelmat_exp: HCES does not include information on this type of expenditure
*</_dwelmat_exp_>

*<_dwelsvc_exp_>
*<_dwelsvc_exp_note_> Total annual consumption of services for the maintenance and repair of the dwelling *</_dwelsvc_exp_note_>
/*<_dwelsvc_exp_note_>  *</_dwelsvc_exp_note_>*/
*<_dwelsvc_exp_note_> dwelsvc_exp brought in from raw data *</_dwelsvc_exp_note_>
gen dwelsvc_exp = .
notes dwelsvc_exp: HCES does not include information on this type of expenditure
*</_dwelsvc_exp_>

*<_othhousing_exp_>
*<_othhousing_exp_note_> Total annual consumption of dwelling repair/maintenance *</_othhousing_exp_note_>
/*<_othhousing_exp_note_>  *</_othhousing_exp_note_>*/
*<_othhousing_exp_note_> othhousing_exp brought in from raw data *</_othhousing_exp_note_>
egen othhousing_exp = rsum(dwelmat_exp dwelsvc_exp), missing
*</_othhousing_exp_>


*<_transfuel_exp_>
*<_transfuel_exp_note_> Total annual consumption of fuels for personal transportation *</_transfuel_exp_note_>
/*<_transfuel_exp_note_>  *</_transfuel_exp_note_>*/
*<_transfuel_exp_note_> transfuel_exp brought in from raw data *</_transfuel_exp_note_>
gen transfuel_exp = .
notes transfuel_exp: HCES does not include information on this type of expenditure
*</_transfuel_exp_>

*<_landphone_exp_>
*<_landphone_exp_note_> Total annual consumption of landline phone services *</_landphone_exp_note_>
/*<_landphone_exp_note_> Rawdata variable: exp487 (landline phone) *</_landphone_exp_note_>*/
*<_landphone_exp_note_> landphone_exp brought in from raw data *</_landphone_exp_note_>
egen    landphone_exp = rsum(exp487), missing 
replace landphone_exp = landphone_exp*12 
*</_landphone_exp_>

*<_cellphone_exp_>
*<_cellphone_exp_note_> Total annual consumption of cellphone services *</_cellphone_exp_note_>
/*<_cellphone_exp_note_> Rawdata variable: exp488 (mobile phone) *</_cellphone_exp_note_>*/
*<_cellphone_exp_note_> cellphone_exp brought in from raw data *</_cellphone_exp_note_>
egen 	cellphone_exp = rsum(exp488), missing 
replace cellphone_exp = cellphone_exp*12
*</_cellphone_exp_>

*<_tel_exp_>
*<_tel_exp_note_> Total consumption of all telephone services *</_tel_exp_note_>
/*<_tel_exp_note_>  *</_tel_exp_note_>*/
*<_tel_exp_note_> tel_exp brought in from raw data *</_tel_exp_note_>
egen tel_exp = rsum(landphone_exp cellphone_exp), missing
*</_tel_exp_>

*<_internet_exp_>
*<_internet_exp_note_> Total consumption of internet services *</_internet_exp_note_>
/*<_internet_exp_note_> Rawdata variable: exp496 (internet) *</_internet_exp_note_>*/
*<_internet_exp_note_> internet_exp brought in from raw data   *</_internet_exp_note_>
egen internet_exp = rsum(exp496), missing
replace internet_exp = internet_exp*12
*</_internet_exp_>

*<_telefax_exp_>
*<_telefax_exp_note_> Total consumption of telefax services *</_telefax_exp_note_>
/*<_telefax_exp_note_> Rawdata variable: missing variable *</_telefax_exp_note_>*/
*<_telefax_exp_note_> telefax_exp brought in from raw data *</_telefax_exp_note_>
gen telefax_exp = .
notes telefax_exp: HCES does not include information on this type of expenditure
*</_telefax_exp_>

*<_comm_exp_>
*<_comm_exp_note_> Total consumption of all telecommunication services *</_comm_exp_note_>
/*<_comm_exp_note_>  *</_comm_exp_note_>*/
*<_comm_exp_note_> comm_exp brought in from raw data *</_comm_exp_note_>
egen comm_exp = rsum(tel_exp internet_exp), missing
*</_comm_exp_>

*<_tv_exp_>
*<_tv_exp_note_> Total consumption of TV broadcasting services *</_tv_exp_note_>
/*<_tv_exp_note_> Rawdata variable: missing variable *</_tv_exp_note_>*/
*<_tv_exp_note_> tv_exp brought in from raw data *</_tv_exp_note_>
gen tv_exp = .
notes tv_exp: HCES does not include information on this type of expenditure
*</_tv_exp_>

*<_tvintph_exp_>
*<_tvintph_exp_note_> Total consumption of tv, internet and telephone  *</_tvintph_exp_note_>
/*<_tvintph_exp_note_>  *</_tvintph_exp_note_>*/
*<_tvintph_exp_note_> tvintph_exp brought in from raw data *</_tvintph_exp_note_>
egen tvintph_exp = rsum(internet_exp tel_exp tv_exp), missing
notes tvintph_exp: only includes internet and telephone expenditures
*</_tvintph_exp_>


*<_Keep variables_>
order countrycode year hhid pid weight weighttype
sort  hhid pid
*</_Keep variables_>

*<_Save data file_>
compress
quietly do 	"$rootdofiles\_aux\Labels_GMD3.0.do"
save 		"$output\\`filename'.dta", replace
*</_Save data file_>

 