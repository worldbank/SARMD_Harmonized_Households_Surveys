/*----------------------------------------------------------------------------------
  SARMD Harmonization
------------------------------------------------------------------------------------
<_Program name_>   		IND_2022_HCES_v04_M_v01_SARMD_DWL.do	       </_Program name_>
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
File:					IND_2022_HCES_v04_M_v01_SARMD_DWL.do
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
global module       	"DWL"
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

*<_landphone_>
*<_landphone_note_> Ownership of a land phone (household) *</_landphone_note_>
/*<_landphone_note_> 1 "Yes" 0 "No" *</_landphone_note_>*/
*<_landphone_note_> no information on ownership of a landphone *</_landphone_note_>
gen landphone = .
notes landphone: missing variable (no direct information, only monthly expenditure on landline)
*</_landphone_>

*<_cellphone_>
*<_cellphone_note_> Ownership of a cell phone (household) *</_cellphone_note_>
/*<_cellphone_note_> 1 "Yes" 0 "No" *</_cellphone_note_>*/
*<_cellphone_note_> cellphone brought in from raw data *</_cellphone_note_>
gen   	cellphone = 0	if  b4pt34334!=1
replace cellphone = 1	if  b4pt34334==1
*</_cellphone_>

*<_cellphone_i_>
*<_cellphone_i_note_> Ownership of a cell phone (individual) *</_cellphone_i_note_>
/*<_cellphone_i_note_>  *</_cellphone_i_note_>*/
*<_cellphone_i_note_> no information on ownership of a cellphone at individual level *</_cellphone_i_note_>
gen cellphone_i = .
notes cellphone_i: missing variable, no information on cellphone ownership at individual level
*</_cellphone_i_>

*<_phone_>
*<_phone_note_> Ownership of a telephone (household) *</_phone_note_>
/*<_phone_note_> 1 "Yes" 0 "No" *</_phone_note_>*/
*<_phone_note_> phone brought in from raw data *</_phone_note_>
gen 	phone = 0		if  cellphone==0
replace phone = 1		if  cellphone==1
notes phone: variable only captures ownership of cellphone
*</_phone_>

*<_computer_>
*<_computer_note_> Ownership of a computer *</_computer_note_>
/*<_computer_note_> 1 "Yes" 0 "No" *</_computer_note_>*/
*<_computer_note_> computer brought in from raw data *</_computer_note_>
gen	    computer = 0	if  b4pt34333!=1
replace computer = 1	if  b4pt34333==1
*</_computer_>

*<_etablet_>
*<_etablet_note_> Ownership of a electronic tablet *</_etablet_note_>
/*<_etablet_note_> 1 "Yes" 0 "No" *</_etablet_note_>*/
*<_etablet_note_> no information on ownership of an electronic tablet *</_etablet_note_>
gen etablet = .
notes etablet: missing variable, no information on ownership of an electronic tablet
*</_etablet_>

*<_internet_>
*<_internet_note_>  Ownership of a internet *</_internet_note_>
/*<_internet_note_> 1 "Subscribed in the house" 2 "Accessible outside the house" 3 "Either" 4 "No internet" *</_internet_note_>*/
*<_internet_note_> internet brought in from raw data *</_internet_note_>
destring b3q9, replace
egen aux_internet = min(b3q9), by(hhid)
gen 	internet = 2	if  aux_internet==1
replace internet = 1	if  b4pt24211==1
replace internet = 4	if  b4pt24211==2 & internet==.
*</_internet_>

*<_radio_>
*<_radio_note_> Ownership of a radio *</_radio_note_>
/*<_radio_note_> 1 "Yes" 0 "No" *</_radio_note_>*/
*<_radio_note_> radio brought in from raw data *</_radio_note_>
gen     radio = 0		if  b4pt34332!=1
replace radio = 1		if  b4pt34332==1
*</_radio_>

*<_tv_>
*<_tv_note_> Ownership of a tv *</_tv_note_>
/*<_tv_note_> 1 "Yes" 0 "No" *</_tv_note_>*/
*<_tv_note_> tv brought in from raw data *</_tv_note_>
gen     tv = 0			if  b4pt34331!=1
replace tv = 1 			if  b4pt34331==1
*</_tv_>

*<_tv_cable_>
*<_tv_cable_note_> Ownership of a cable tv *</_tv_cable_note_>
/*<_tv_cable_note_> 1 "Yes" 0 "No" *</_tv_cable_note_>*/
*<_tv_cable_note_> tv_cable brought in from raw data *</_tv_cable_note_>
gen     tv_cable = 0	if  b4pt3434==1 | b4pt34331!=1
replace tv_cable = 1	if  b4pt3434==2 | b4pt3434==3		// cable tv + satellite tv
*</_tv_cable_>

*<_video_>
*<_video_note_> Ownership of a video *</_video_note_>
/*<_video_note_> 1 "Yes" 0 "No" *</_video_note_>*/
*<_video_note_> no information on ownership of a video *</_video_note_>
gen   video = .
notes video: missing variable, no information on ownership of a video
*</_video_>

*<_fridge_>
*<_fridge_note_> Ownership of a refrigerator *</_fridge_note_>
/*<_fridge_note_> 1 "Yes" 0 "No" *</_fridge_note_>*/
*<_fridge_note_> fridge brought in from raw data *</_fridge_note_>
gen     fridge = 0 		if  b4pt343310!=1
replace fridge = 1		if  b4pt343310==1
*</_fridge_>

*<_sewmach_>
*<_sewmach_note_> Ownership of a sewing machine *</_sewmach_note_>
/*<_sewmach_note_> 1 "Yes" 0 "No" *</_sewmach_note_>*/
*<_sewmach_note_> no information on ownership of a sewing machine *</_sewmach_note_>
gen sewmach = .
notes sewmach: missing variable, no information on ownership of a sewing machine
*</_sewmach_>

*<_washmach_>
*<_washmach_note_> Ownership of a washing machine *</_washmach_note_>
/*<_washmach_note_> 1 "Yes" 0 "No" *</_washmach_note_>*/
*<_washmach_note_> washmach brought in from raw data *</_washmach_note_>
gen     washmach = 0	if  b4pt343311!=1
replace washmach = 1	if  b4pt343311==1
*</_washmach_>

*<_stove_>
*<_stove_note_> Ownership of a stove *</_stove_note_>
/*<_stove_note_> 1 "Yes" 0 "No" *</_stove_note_>*/
*<_stove_note_> no information on ownership of a stove *</_stove_note_>
gen stove = .
notes stove: missing variable, no information on ownership of a stove
*</_stove_>

*<_ricecook_>
*<_ricecook_note_> Ownership of a rice cooker *</_ricecook_note_>
/*<_ricecook_note_> 1 "Yes" 0 "No" *</_ricecook_note_>*/
*<_ricecook_note_> no information on ownership of a rice cooker *</_ricecook_note_>
gen ricecook = .
notes ricecook: missing variable, no information on ownership of a rice cooker
*</_ricecook_>

*<_fan_>
*<_fan_note_> Ownership of an electric fan *</_fan_note_>
/*<_fan_note_> 1 "Yes" 0 "No" *</_fan_note_>*/
*<_fan_note_> no information on ownership of an electric fan *</_fan_note_>
gen fan = .
notes fan: missing variable, no information on ownership of an electric fan
*</_fan_>

*<_ac_>
*<_ac_note_> Ownership of a central or wall air conditioner *</_ac_note_>
/*<_ac_note_> 1 "Yes" 0 "No" *</_ac_note_>*/
*<_ac_note_> ac brought in from raw data *</_ac_note_>
gen 	ac = 0		if  b4pt343312!=1
replace ac = 1		if  b4pt343312==1
*</_ac_>

*<_ewpump_>
*<_ewpump_note_> Ownership of a electric water pump *</_ewpump_note_>
/*<_ewpump_note_> 1 "Yes" 0 "No" *</_ewpump_note_>*/
*<_ewpump_note_> no information on ownership of an electric water pump *</_ewpump_note_>
gen ewpump = .
notes ewpump: missing variable, no information on ownership of an electric water pump
*</_ewpump_>

*<_car_>
*<_car_note_> Ownership of a car *</_car_>
/*<_car_note_> 1 "Yes" 0 "No" *</_car_note_>*/
*<_car_note_> car brought in from raw data *</_car_note_>
gen   	car = 0			if  b4pt34337!=1 & b4pt34338!=1
replace car = 1			if  b4pt34337==1 | b4pt34338==1
*</_car_>

*<_mcycle_>
*<_mcycle_note_> Ownership of a motorcycle *</_mcycle_note_>
/*<_mcycle_note_> 1 "Yes" 0 "No" *</_mcycle_note_>*/
*<_mcycle_note_> mcycle brought in from raw data *</_mcycle_note_>
gen 	mcycle = 0 		if  b4pt34336!=1 
replace mcycle = 1		if  b4pt34336==1
*</_mcycle_>

*<_bcycle_>
*<_bcycle_note_> Ownership of a bicycle *</_bcycle_note_>
/*<_bcycle_note_>  1 "Yes" 0 "No" *</_bcycle_note_>*/
*<_bcycle_note_> bcycle brought in from raw data *</_bcycle_note_>
gen 	bcycle = 0		if  b4pt34335!=1
replace bcycle = 1		if  b4pt34335==1
*</_bcycle_>

*<_oxcart_>
*<_oxcart_note_> Ownership of an oxcart *</_oxcart_note_>
/*<_oxcart_note_> 1 "Yes" 0 "No" *</_oxcart_note_>*/
*<_oxcart_note_> oxcart brought in from raw data *</_oxcart_note_>
gen   	oxcart = 0 		if  b4pt34339!=1
replace oxcart = 1		if  b4pt34339==1
*</_oxcart_>

*<_boat_>
*<_boat_note_> Ownership of a boat *</_boat_note_>
/*<_boat_note_> 1 "Yes" 0 "No" *</_boat_note_>*/
*<_boat_note_>no information on ownership of a boat *</_boat_note_>
gen boat = .
notes boat: missing variable, no information on ownership of a boat
*</_boat_>

*<_canoe_>
*<_canoe_note_> Ownership of a canoes *</_canoe_note_>
/*<_canoe_note_> 1 "Yes" 0 "No" *</_canoe_note_>*/
*<_canoe_note_> no information on ownership of a canoe *</_canoe_note_>
gen canoe = .
notes canoe: missing variable, no information on ownership of a canoe
*</_canoe_>


*<_roofcs_>
*<_roofcs_note_> Main material used for roof *</_roofcs_note_>
/*<_roofcs_note_> *</_roofcs_note_>*/
*<_roofcs_note_> roof brought in from raw data *</_roofcs_note_>
gen 	roofcs = "1 - grass/straw/leaves/reeds/bamboo"				if  b4q4pt19==1
replace roofcs = "2 - mud/unburnt brick" 							if  b4q4pt19==2
replace roofcs = "3 - canvas/cloth" 								if  b4q4pt19==3
replace roofcs = "4 - other katcha" 								if  b4q4pt19==4
replace roofcs = "5 - tiles/slate" 									if  b4q4pt19==5
replace roofcs = "6 - burnt brick/stone/lime stone" 				if  b4q4pt19==6
replace roofcs = "7 - iron/zinc/other metal sheet/asbestos sheet" 	if  b4q4pt19==7
replace roofcs = "8 - cement/RBC/RCC" 								if  b4q4pt19==8
replace roofcs = "9 - other pucca" 									if  b4q4pt19==9
*</_roofcs_>

*<_roof_>
*<_roof_note_> Main material used for roof *</_roof_note_>
/*<_roof_note_> 1 "Natural–Thatch/palm leaf" 2 "Natural–Sod" 3 "Natural–Other" 4 "Rudimentary–Rustic mat" 5 "Rudimentary–Palm/bamboo" 6 "Rudimentary–Wood planks" 7 "Rudimentary-Other" 8 "Finished–Roofing" 9 "Finished–Asbestos" 10 "Finished–Tile" 11 "Finished–Concrete" 12 "Finished–Metal tile" 13 "Finished–Roofing shingles" 14 "Finished–Other" 15 "Other–Specific" *</_roof_note_>*/
*<_roof_note_> roof brought in from raw data *</_roof_note_>
gen     roof = 12		if  b4q4pt19==1						// grass-straw-leaves-reeds-bamboo-etc.			//
replace roof = 21		if  b4q4pt19==2						// mud-unburnt brick							//
replace roof = 24		if  b4q4pt19==3	| b4q4pt19==4		// canvas-cloth / other katcha					//
replace roof = 32		if  b4q4pt19==7						// iron-zinc-other metal sheet-asbestos sheet	//
replace roof = 33		if  b4q4pt19==5						// tiles-slate									//		
replace roof = 34		if  b4q4pt19==8						// cement-RBC-RCC								//
replace roof = 37		if  b4q4pt19==6 | b4q4pt19==9		// burnt brick-stone-lime stone	/ other pucca	//
notes roof: information refers to materials of outer exposed part of the roof
*</_roof_>

*<_wallcs_>
*<_wallcs_note_> Main material used for wall *</_wallcs_note_>
/*<_wallcs_note_> *</_wallcs_note_>*/
*<_wallcs_note_> wall brought in from raw data *</_wallcs_note_>
gen 	wallcs = "1 - grass/straw/leaves/reeds/bamboo"			if  b4q4pt18==1
replace wallcs = "2 - mud (with/without bamboo)/unburnt brick" 	if  b4q4pt18==2
replace wallcs = "3 - canvas/cloth" 							if  b4q4pt18==3
replace wallcs = "4 - other katcha" 							if  b4q4pt18==4
replace wallcs = "5 - timber" 									if  b4q4pt18==5
replace wallcs = "6 - burnt brick/stone/ lime stone" 			if  b4q4pt18==6
replace wallcs = "7 - iron or other metal sheet " 				if  b4q4pt18==7
replace wallcs = "8 - cement/RBC/RCC" 							if  b4q4pt18==8
replace wallcs = "9 - other pucca" 								if  b4q4pt18==9
*</_wallcs_>

*<_wall_>
*<_wall_note_> Main material used for external walls *</_wall_note_>
/*<_wall_note_> 1 "Natural–Cane/palm/trunks" 2 "Natural–Dirt" 3 "Natural–Other" 4 "Rudimentary–Bamboo with mud" 5 "Rudimentary–Stone with mud" 6 "Rudimentary–Uncovered adobe" 7 "Rudimentary–Plywood" 8 "Rudimentary–Cardboard" 9 "Rudimentary–Reused wood" 10 "Rudimentary–Other" 11 "Finished–Woven Bamboo" 12 "Finished–Stone with lime/cement" 13 "Finished–Cement blocks"14 "Finished–Covered adobe" 15 "Finished–Wood planks/shingles" 16 "Finished–Plaster wire" 17 "Finished– GRC/Gypsum/Asbestos" 18 "Finished–Other" 19 "Other" *</_wall_note_>*/
*<_wall_note_> wall brought in from raw data *</_wall_note_>
gen 	wall = 12		if  b4q4pt18==1							// grass-straw-leaves-reeds-bamboo-etc.			//
replace wall = 21		if  b4q4pt18==2							// mud with or without bamboo-urburnt brick 	//
replace wall = 27		if  b4q4pt18==3	| b4q4pt18==4			// canvas-cloth / other katcha					//
replace wall = 35		if  b4q4pt18==5							// timber										//
replace wall = 32		if  b4q4pt18==6							// burnt brick-stone-lime stone					//
replace wall = 38		if  b4q4pt18==7 | b4q4pt18==9			// iron or other metal sheet / other pucca		//
replace wall = 33		if  b4q4pt18==8							// cement-RBC-RCC								//
*</_wall_>

*<_floorcs_>
*<_floorcs_note_> Main material used for floor *</_floorcs_note_>
/*<_floorcs_note_> *</_floorcs_note_>*/
*<_floorcs_note_> floor brought in from raw data *</_floorcs_note_>
gen 	floorcs = "1 - grass/straw/leaves/reeds/bamboo"				if  b4q4pt20==1	
replace floorcs = "2 - mud/unburnt brick"							if  b4q4pt20==2
replace floorcs = "3 - canvas"										if  b4q4pt20==3
replace floorcs = "4 - other katcha"								if  b4q4pt20==4
replace floorcs = "5 - tiles/slate"									if  b4q4pt20==5
replace floorcs = "6 - burnt brick/stone/lime stone"				if  b4q4pt20==6
replace floorcs = "7 - iron/zinc/other metal sheet/asbestos sheet"	if  b4q4pt20==7
replace floorcs = "8 - cement/RBC/RCC"								if  b4q4pt20==8
replace floorcs = "9 - other pucca"									if  b4q4pt20==9
*</_floorcs_>

*<_floor_>
*<_floor_note_> Main material used for floor *</_floor_note_>
/*<_floor_note_> 1 "Natural–Earth/sand" 2 "Natural–Dung" 3 "Natural–Other" 4 "Rudimentary–Wood planks" 5 "Rudimentary–Palm/bamboo" 6 "Rudimentary–Other" 7 "Finished–Parquet or polished wood" 8 "Finished–Vinyl or asphalt strips" 9 "Finished–Ceramic/marble/granite" 10 "Finished–Floor tiles/teraso" 11 "Finished–Cement/red bricks" 12 "Finished–Carpet" 13 "Finished–Other" 14 "Other–Specific" *</_floor_note_>*/
*<_floor_note_> floor brought in from raw data *</_floor_note_>
gen   	floor = 22		if  b4q4pt20==1							// grass-straw-leaves-reeds-bamboo-etc.						//
replace floor = 12		if  b4q4pt20==2							// mud-urburnt brick										//
replace floor = 23		if  b4q4pt20==3	| b4q4pt20==4			// canvas-cloth	/ other katcha								//
replace floor = 34		if  b4q4pt20==5							// tiles-slate												//
replace floor = 35		if  b4q4pt20==6	| b4q4pt20==8			// burnt brick-stone-limestone / cement-RBC-RCC 			//
replace floor = 37		if  b4q4pt20==7	| b4q4pt20==9			// iron-zinc-other metal sheet-asbestos sheet / other pucca	//
*</_floor_>

*<_dweltyp_>
*<_dweltyp_note_> Types of Dwelling *</_dweltyp_note_>
/*<_dweltyp_note_> 1 "Detached house" 2 "Multi-family house" 3 "Separate apartment" 4 "Communal apartment" 5 "Room in a larger dwelling" 6 "Several buildings connected" 7 "Several separate buildings" 8 "Improvised housing unit" 9 "Other" *</_dweltyp_note_>*/
*<_dweltyp_note_> missing variable, no information in the HCES to define dweltyp *</_dweltyp_note_>
gen dweltyp = .
notes dweltyp: the HCES does not contain information to define this variable
*</_dweltyp_>

*<_typlivqrt_>
*<_typlivqrt_note_> Types of living quarters *</_typlivqrt_note_>
/*<_typlivqrt_note_>  1 "Housing units, conventional dwelling with basic facilities" 2 "Housing units, conventional dwelling without basic facilities" 3 "Other" *</_typlivqrt_note_>*/
*<_typlivqrt_note_> missing variable, no information in the HCES to define typlivqrt *</_typlivqrt_note_>
gen typlivqrt = .
notes typlivqrt: the HCES does not contain information to define this variable
*</_typlivqrt_>

*<_kitchen_>
*<_kitchen_note_> Separate kitchen in the dwelling *</_kitchen_note_>
/*<_kitchen_note_> 1 "Yes" 0 "No" *</_kitchen_note_>*/
*<_kitchen_note_> missing variable, no information in the HCES to define kitchen *</_kitchen_note_>
gen kitchen = .
notes kitchen: the HCES does not contain information to define this variable
*</_kitchen_>

*<_bath_>
*<_bath_note_> Bathing facility in the dwelling *</_bath_note_>
/*<_bath_note_> 1 "Yes" 0 "No" *</_bath_note_>*/
*<_bath_note_> missing variable, no information in the HCES to define bath *</_bath_note_>
gen bath = .
notes bath: the HCES does not contain information to define this variable
*</_bath_>

*<_rooms_>
*<_rooms_note_> Number of habitable rooms *</_rooms_note_>
/*<_rooms_note_>  *</_rooms_note_>*/
*<_rooms_note_> missing variable, no information in the HCES to define rooms *</_rooms_note_>
gen rooms = .
notes rooms: the HCES does not contain information to define this variable
*</_rooms_>

*<_areaspace_>
*<_areaspace_note_> Area *</_areaspace_note_>
/*<_areaspace_note_>     *</_areaspace_note_>*/
*<_areaspace_note_> missing variable, no information in the HCES to define areaspace *</_areaspace_note_>
gen areaspace = .
notes areaspace: the HCES does not contain information to define this variable
*</_areaspace_>

*<_ybuilt_>
*<_ybuilt_note_> Year the dwelling built *</_ybuilt_note_>
/*<_ybuilt_note_>  *</_ybuilt_note_>*/
*<_ybuilt_note_> missing variable, no information in the HCES to define ybuilt *</_ybuilt_note_>
gen ybuilt = .
notes ybuilt: the HCES does not contain information to define this variable
*</_ybuilt_>

*<_ownhouse_>
*<_ownhouse_note_> SARMD ownhouse variable *</_ownhouse_note_>
/*<_ownhouse_note_> Refers to ownership status of the dwelling unit by the household residing in it.     *</_ownhouse_note_>*/
*<_ownhouse_note_>  1 "Ownership/secure rights" 2 "Renting" 3 "Provided for free" 4 "Without permission" *</_ownhouse_note_>
gen     ownhouse = 1 		if  b4q4pt17==1 		/* owned		 */
replace ownhouse = 2 		if  b4q4pt17==2			/* hired		 */
notes   ownhouse: missing values are cases in which the raw data variables is "other" or "does not have a dwelling unit"
*</_ownhouse_>

*<_acqui_house_>
*<_acqui_house_note_> Acquisition of house *</_acqui_house_note_>
/*<_acqui_house_note_> 1 "Purchased" 2 "Inherited" 3 "Other" *</_acqui_house_note_>*/
*<_acqui_house_note_> missing variable, no information in the HCES to define acqui_house *</_acqui_house_note_>
gen acqui_house = .
notes acqui_house: the HCES does not contain information to define this variable
*</_acqui_house_>

*<_dwelownlti_>
*<_dwelownlti_note_> Legal title for Ownership *</_dwelownlti_note_>
/*<_dwelownlti_note_> 1 "Yes" 0 "No" *</_dwelownlti_note_>*/
*<_dwelownlti_note_> missing variable, no information in the HCES to define dwelownlti *</_dwelownlti_note_>
gen dwelownlti = .
notes dwelownlti: the HCES does not contain information to define this variable
*</_dwelownlti_>

*<_fem_dwelownlti_>
*<_fem_dwelownlti_note_> Legal title for Ownership - Female *</_fem_dwelownlti_note_>
/*<_fem_dwelownlti_note_> 1 "Yes" 0 "No" *</_fem_dwelownlti_note_>*/
*<_fem_dwelownlti_note_> missing variable, no information in the HCES to define fem_dwelownlti *</_fem_dwelownlti_note_>
gen fem_dwelownlti = .
notes fem_dwelownlti: the HCES does not contain information to define this variable
*</_fem_dwelownlti_>

*<_dwelownti_>
*<_dwelownti_note_> Type of Legal document *</_dwelownti_note_>
/*<_dwelownti_note_> 1 "Title, deed, freehold" 2 "Government issued leasehold" 3 "Occupancy certificate – govt issued" 4 "legal document in the name of group (community  cooperative)" 5 "condominium (apartment)" 6 "Other" *</_dwelownti_note_>*/
*<_dwelownti_note_> missing variable, no information in the HCES to define dwelownti *</_dwelownti_note_>
gen dwelownti = .
notes dwelownti: the HCES does not contain information to define this variable
*</_dwelownti_>

*<_selldwel_>
*<_selldwel_note_> Right to sell dwelling *</_selldwel_note_>
/*<_selldwel_note_> 1 "Yes" 0 "No" *</_selldwel_note_>*/
*<_selldwel_note_> missing variable, no information in the HCES to define selldwel *</_selldwel_note_>
gen selldwel = .
notes selldwel: the HCES does not contain information to define this variable
*</_selldwel_>

*<_transdwel_>
*<_transdwel_note_> Right to transfer dwelling *</_transdwel_note_>
/*<_transdwel_note_> 1 "Yes" 0 "No" *</_transdwel_note_>*/
*<_transdwel_note_> missing variable, no information in the HCES to define transdwel *</_transdwel_note_>
gen transdwel = .
notes transdwel: the HCES does not contain information to define this variable
*</_transdwel_>

*<_ownland_>
*<_ownland_note_> Ownership of land *</_ownland_note_>
/*<_ownland_note_> 1 "Yes" 0 "No" *</_ownland_note_>*/
*<_ownland_note_> ownland brought in from raw data *</_ownland_note_>
gen 	ownland = 0
replace ownland = 1			if  b4q4pt13==1 & b4q4pt14>=1 & b4q4pt14<=2
*</_ownland_>

*<_acqui_land_>
*<_acqui_land_note_> Acquisition of residential land *</_acqui_land_note_>
/*<_acqui_land_note_> 1 "Purchased" 2 "Inherited" 3 "Other" *</_acqui_land_note_>*/
*<_acqui_land_note_> missing variable, no information in the HCES to define acqui_land *</_acqui_land_note_>
gen acqui_land = .
notes acqui_land: the HCES does not contain information to define this variable
*</_acqui_land_>

*<_doculand_>
*<_doculand_note_> Legal document for residential land *</_doculand_note_>
/*<_doculand_note_> 1 "Yes" 0 "No" *</_doculand_note_>*/
*<_doculand_note_> missing variable, no information in the HCES to define doculand *</_doculand_note_>
gen doculand = .
notes doculand: the HCES does not contain information to define this variable
*</_doculand_>

*<_fem_doculand_>
*<_fem_doculand_note_> Legal document for residential land - female *</_fem_doculand_note_>
/*<_fem_doculand_note_> 1 "Yes" 0 "No" *</_fem_doculand_note_>*/
*<_fem_doculand_note_> missing variable, no information in the HCES to define fem_doculand *</_fem_doculand_note_>
gen fem_doculand = .
notes fem_doculand: the HCES does not contain information to define this variable
*</_fem_doculand_>

*<_landownti_>
*<_landownti_note_> Land Ownership *</_landownti_note_>
/*<_landownti_note_> 1 "Title deed" 2 "leasehold (govt issued)" 3 "Customary land certificate/plot level" 4 "Customary based/group right" 5 "Cooperative group right" 6 "Other" *</_landownti_note_>*/
*<_landownti_note_> missing variable, no information in the HCES to define landownti *</_landownti_note_>
gen landownti = .
notes landownti: the HCES does not contain information to define this variable
*</_landownti_>

*<_sellland_>
*<_sellland_note_> Right to sell land *</_sellland_note_>
/*<_sellland_note_> 1 "Yes" 0 "No" *</_sellland_note_>*/
*<_sellland_note_> missing variable, no information in the HCES to define sellland *</_sellland_note_>
gen sellland = .
notes sellland: the HCES does not contain information to define this variable
*</_sellland_>

*<_transland_>
*<_transland_note_> Right to transfer land *</_transland_note_>
/*<_transland_note_> 1 "Yes" 0 "No" *</_transland_note_>*/
*<_transland_note_> missing variable, no information in the HCES to define transland *</_transland_note_>
gen transland = .
notes transland: the HCES does not contain information to define this variable
*</_transland_>

*<_agriland_>
*<_agriland_note_> Agriculture Land *</_agriland_note_>
/*<_agriland_note_> 1 "Yes" 0 "No" *</_agriland_note_>*/
*<_agriland_note_> missing variable, no information in the HCES to define agriland *</_agriland_note_>
gen agriland = .
notes agriland: the HCES does not contain information to define this variable
*</_agriland_>

*<_area_agriland_>
*<_area_agriland_note_> Area of Agriculture land *</_area_agriland_note_>
/*<_area_agriland_note_> *</_area_agriland_note_>*/
*<_area_agriland_note_> missing variable, no information in the HCES to define area_agriland *</_area_agriland_note_>
gen area_agriland = .
notes area_agriland: the HCES does not contain information to define this variable
*</_area_agriland_>

*<_ownagriland_>
*<_ownagriland_note_> Ownership of agriculture land *</_ownagriland_note_>
/*<_ownagriland_note_> 1 "Yes" 0 "No" *</_ownagriland_note_>*/
*<_ownagriland_note_> ownagriland brought in from raw data *</_ownagriland_note_>
gen 	ownagriland = 0
replace ownagriland = 1		if  b4q4pt14>=2 & b4q4pt14<=3
notes ownagriland: = 1 if household owns "homestead and other land" or "other land" at the time of the survey
*</_ownagriland_>

*<_area_ownagriland_>
*<_area_ownagriland_note_> Area of agriculture land owned *</_area_ownagriland_note_>
/*<_area_ownagriland_note_> *</_area_ownagriland_note_>*/
*<_area_ownagriland_note_> area_ownagriland brought in from raw data *</_area_ownagriland_note_>
destring b4q4pt15, replace
gen area_ownagriland = b4q4pt15/2.471
*</_area_ownagriland_>

*<_purch_agriland_>
*<_purch_agriland_note_> Purchased agri land *</_purch_agriland_note_>
/*<_purch_agriland_note_> 1 "Yes" 0 "No" *</_purch_agriland_note_>*/
*<_purch_agriland_note_> missing variable, no information in the HCES to define purch_agriland *</_purch_agriland_note_>
gen purch_agriland = .
notes purch_agriland: the HCES does not contain information to define this variable
*</_purch_agriland_>

*<_areapurch_agriland_>
*<_areapurch_agriland_note_> Area of purchased agriculture land *</_areapurch_agriland_note_>
/*<_areapurch_agriland_note_>  *</_areapurch_agriland_note_>*/
*<_areapurch_agriland_note_> missing variable, no information in the HCES to define areapurch_agriland *</_areapurch_agriland_note_>
gen areapurch_agriland = .
notes areapurch_agriland: the HCES does not contain information to define this variable
*</_areapurch_agriland_>

*<_inher_agriland_>
*<_inher_agriland_note_> Inherit agriculture land *</_inher_agriland_note_>
/*<_inher_agriland_note_> 1 "Yes" 0 "No" *</_inher_agriland_note_>*/
*<_inher_agriland_note_> missing variable, no information in the HCES to define inher_agriland *</_inher_agriland_note_>
gen inher_agriland = .
notes inher_agriland: the HCES does not contain information to define this variable
*</_inher_agriland_>

*<_areainher_agriland_>
*<_areainher_agriland_note_> Area of inherited agriculture land *</_areainher_agriland_note_>
/*<_areainher_agriland_note_>  *</_areainher_agriland_note_>*/
*<_areainher_agriland_note_> missing variable, no information in the HCES to define areainher_agriland *</_areainher_agriland_note_>
gen areainher_agriland = .
notes areainher_agriland: the HCES does not contain information to define this variable
*</_areainher_agriland_>

*<_rentout_agriland_>
*<_rentout_agriland_note_> Rent Out Land *</_rentout_agriland_note_>
/*<_rentout_agriland_note_> 1 "Yes" 0 "No" *</_rentout_agriland_note_>*/
*<_rentout_agriland_note_> missing variable, no information in the HCES to define rentout_agriland *</_rentout_agriland_note_>
gen rentout_agriland = .
notes rentout_agriland: the HCES does not contain information to define this variable
*</_rentout_agriland_>

*<_arearentout_agriland_>
*<_arearentout_agriland_note_> Area of rent out agri land *</_arearentout_agriland_note_>
/*<_arearentout_agriland_note_> *</_arearentout_agriland_note_>*/
*<_arearentout_agriland_note_> missing variable, no information in the HCES to define arearentout_agriland *</_arearentout_agriland_note_>
gen arearentout_agriland = .
notes arearentout_agriland: the HCES does not contain information to define this variable
*</_arearentout_agriland_>

*<_rentin_agriland_>
*<_rentin_agriland_note_> Rent in Land *</_rentin_agriland_note_>
/*<_rentin_agriland_note_> 1 "Yes" 0 "No" *</_rentin_agriland_note_>*/
*<_rentin_agriland_note_> missing variable, no information in the HCES to define rentin_agriland *</_rentin_agriland_note_>
gen rentin_agriland = .
notes rentin_agriland: the HCES does not contain information to define this variable
*</_rentin_agriland_>

*<_arearentin_agriland_>
*<_arearentin_agriland_note_> Area of rent in agri land *</_arearentin_agriland_note_>
/*<_arearentin_agriland_note_>  *</_arearentin_agriland_note_>*/
*<_arearentin_agriland_note_> missing variable, no information in the HCES to define arearentin_agriland *</_arearentin_agriland_note_>
gen arearentin_agriland = .
notes arearentin_agriland: the HCES does not contain information to define this variable
*</_arearentin_agriland_>

*<_docuagriland_>
*<_docuagriland_note_> Documented Agri Land *</_docuagriland_note_>
/*<_docuagriland_note_> 1 "Yes" 0 "No" *</_docuagriland_note_>*/
*<_docuagriland_note_> missing variable, no information in the HCES to define docuagriland *</_docuagriland_note_>
gen docuagriland = .
notes docuagriland: the HCES does not contain information to define this variable
*</_docuagriland_>

*<_area_docuagriland_>
*<_area_docuagriland_note_> Area of documented agri land *</_area_docuagriland_note_>
/*<_area_docuagriland_note_>  *</_area_docuagriland_note_>*/
*<_area_docuagriland_note_> missing variable, no information in the HCES to define area_docuagriland *</_area_docuagriland_note_>
gen area_docuagriland = .
notes area_docuagriland: the HCES does not contain information to define this variable
*</_area_docuagriland_>

*<_fem_agrilandownti_>
*<_fem_agrilandownti_note_> Ownership Agri Land - Female *</_fem_agrilandownti_note_>
/*<_fem_agrilandownti_note_> 1 "Yes" 0 "No" *</_fem_agrilandownti_note_>*/
*<_fem_agrilandownti_note_> missing variable, no information in the HCES to define fem_agrilandownti *</_fem_agrilandownti_note_>
gen fem_agrilandownti = .
notes fem_agrilandownti: the HCES does not contain information to define this variable
*</_fem_agrilandownti_>

*<_agrilandownti_>
*<_agrilandownti_note_> Type Agri Land ownership doc *</_agrilandownti_note_>
/*<_agrilandownti_note_> 1 "Title  deed" 2 "Leasehold (govt issued)" 3 "Customary land certificate/plot level" 4 "Customary based / group right" 5 "Cooperative" 6 "Other" *</_agrilandownti_note_>*/
*<_agrilandownti_note_> missing variable, no information in the HCES to define agrilandownti *</_agrilandownti_note_>
gen agrilandownti = .
notes agrilandownti: the HCES does not contain information to define this variable
*</_agrilandownti_>

*<_sellagriland_>
*<_sellagriland_note_> Right to sell agri land *</_sellagriland_note_>
/*<_sellagriland_note_> 1 "Yes" 0 "No" *</_sellagriland_note_>*/
*<_sellagriland_note_> missing variable, no information in the HCES to define sellagriland *</_sellagriland_note_>
gen sellagriland = .
notes sellagriland: the HCES does not contain information to define this variable
*</_sellagriland_>

*<_transagriland_>
*<_transagriland_note_> Right to transfer agri land *</_transagriland_note_>
/*<_transagriland_note_> 1 "Yes" 0 "No" *</_transagriland_note_>*/
*<_transagriland_note_> missing variable, no information in the HCES to define transagriland *</_transagriland_note_>
gen transagriland = .
notes transagriland: the HCES does not contain information to define this variable
*</_transagriland_>


*<_Keep variables_>
order countrycode year hhid pid weight weighttype
sort  hhid pid
*</_Keep variables_>

*<_Save data file_>
compress
quietly do 	"$rootdofiles\_aux\Labels_GMD3.0.do"
save 		"$output\\`filename'.dta", replace
*</_Save data file_>
 
 