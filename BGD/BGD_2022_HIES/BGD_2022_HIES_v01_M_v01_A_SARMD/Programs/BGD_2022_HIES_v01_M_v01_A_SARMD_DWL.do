/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   BGD_2022_HIES_v01_M_v01_A_SARMD_DWL.do	</_Program name_>
<_Application_>    STATA 16.0	<_Application_>
<_Author(s)_>      Leo Tornarolli <tornarolli@gmail.com>	</_Author(s)_>
<_Date created_>   04-2023	</_Date created_>
<_Date modified>    4 Apr 2023	</_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        BGD	</_Country_>
<_Survey Title_>   HIES	</_Survey Title_>
<_Survey Year_>    2022	</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:	04-2023
File:	BGD_2022_HIES_v01_M_v01_A_SARMD_DWL.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>

clear all
set more off

local code         "BGD"
local year         "2022"
local survey       "HIES"
local vm           "01"
local va           "01"
local type         "SARMD"
local yearfolder   "BGD_2022_HIES"
local gmdfolder    "BGD_2022_HIES_v01_M_v01_A_GMD"
local SARMDfolder  "BGD_2022_HIES_v01_M_v01_A_SARMD"
local filename     "BGD_2022_HIES_v01_M_v01_A_SARMD_DWL"
*</_Program setup_>

*<_Folder creation_>
cap mkdir "$rootdatalib\GMD"
cap mkdir "$rootdatalib\GMD\\`code'"
cap mkdir "$rootdatalib\GMD\\`code'\\`yearfolder'"
cap mkdir "$rootdatalib\GMD\\`code'\\`yearfolder'\\`gmdfolder'"
cap mkdir "$rootdatalib\GMD\\`code'\\`yearfolder'\\`gmdfolder'\Data"
cap mkdir "$rootdatalib\GMD\\`code'\\`yearfolder'\\`gmdfolder'\Data\Harmonized"
*</_Folder creation_>

*<_Datalibweb request_>

*datalibweb, country(`code') year(`year') type(`type') survey(`survey') vermast(`vm') veralt(`va') mod(IND) clear 
use "$rootdatalib\\`code'\\`yearfolder'\\`SARMDfolder'\Data\Harmonized\BGD_2022_HIES_v01_M_v01_A_SARMD_IND.dta", clear

*</_Datalibweb request_>

*<_countrycode_>
*<_countrycode_note_> country code *</_countrycode_note_>
/*<_countrycode_note_> iso3 code upper letter *</_countrycode_note_>*/
*<_countrycode_note_> countrycode brought in from SARMD *</_countrycode_note_>
*</_countrycode_>

*<_year_>
*<_year_note_> Year *</_year_note_>
/*<_year_note_> field work start at *</_year_note_>*/
*<_year_note_> year brought in from SARMD *</_year_note_>
*</_year_>

*<_hhid_>
*<_hhid_note_> Household identifier  *</_hhid_note_>
/*<_hhid_note_> . *</_hhid_note_>*/
*<_hhid_note_> hhid brought in from SARMD *</_hhid_note_>
*</_hhid_>

*<_pid_>
*<_pid_note_> Personal identifier  *</_pid_note_>
/*<_pid_note_> country specific *</_pid_note_>*/
*<_pid_note_> pid brought in from SARMD *</_pid_note_>
*</_pid_>

*<_weight_>
*<_weight_note_> Household weight *</_weight_note_>
/*<_weight_note_> . *</_weight_note_>*/
*<_weight_note_> weight brought in from SARMD *</_weight_note_>
gen weight=finalweight
*</_weight_>

*<_weighttype_>
*<_weighttype_note_> Weight type (frequency, probability, analytical, importance) *</_weighttype_note_>
/*<_weighttype_note_> . *</_weighttype_note_>*/
*<_weighttype_note_> weighttype brought in from SARMD *</_weighttype_note_>
*</_weighttype_>

*<_landphone_>
*<_landphone_note_> Ownership of a land phone (household) *</_landphone_note_>
/*<_landphone_note_>  1 Â "Yes" Â 0 "No" *</_landphone_note_>*/
*<_landphone_note_> landphone brought in from rawdata *</_landphone_note_>
gen landphone=.a
*</_landphone_>

*<_cellphone_>
*<_cellphone_note_> Ownership of a cell phone (household) *</_cellphone_note_>
/*<_cellphone_note_>  1 Â "Yes" Â 0 "No" *</_cellphone_note_>*/
*<_cellphone_note_> cellphone brought in from raw data *</_cellphone_note_>
*gen cellphone=.a
*</_cellphone_>

*<_cellphone_i_>
*<_cellphone_i_note_> Ownership of a cell phone (individual) *</_cellphone_i_note_>
/*<_cellphone_i_note_>  *</_cellphone_i_note_>*/
*<_cellphone_i_note_> cellphone_i brought in from raw data *</_cellphone_i_note_>
gen cellphone_i=.a
*</_cellphone_i_>

*<_phone_>
*<_phone_note_> Ownership of a telephone (household) *</_phone_note_>
/*<_phone_note_>  1 Â "Yes" Â 0 "No" *</_phone_note_>*/
*<_phone_note_> phone brought in from raw data *</_phone_note_>
gen phone=.a
*</_phone_>

*<_computer_>
*<_computer_note_> Ownership of a computer *</_computer_note_>
/*<_computer_note_>  1 Â "Yes" Â 0 "No" *</_computer_note_>*/
*<_computer_note_> computer brought in from raw data *</_computer_note_>
*gen computer=.a
*</_computer_>

*<_etablet_>
*<_etablet_note_> Ownership of a electronic tablet *</_etablet_note_>
/*<_etablet_note_>  1 Â "Yes" Â 0 "No" *</_etablet_note_>*/
*<_etablet_note_> etablet brought in from raw data *</_etablet_note_>
gen etablet=.a
*</_etablet_>

*<_internet_>
*<_internet_note_> Ownership of a  internet *</_internet_note_>
/*<_internet_note_>  1 Â "Subscribed in the house" Â 2 Â "Accessible outside the house" Â 3 Â " Either" 4 Â "No internet" *</_internet_note_>*/
*<_internet_note_> internet brought in from raw data *</_internet_note_>
*gen internet=.a
*</_internet_>

*<_internet_mobile_>
*<_internet_mobile_note_> Ownership of a  internet (mobile 2G 3G LTE 4G 5G ) *</_internet_mobile_note_>
/*<_internet_mobile_note_>  *</_internet_mobile_note_>*/
*<_internet_mobile_note_> internet_mobile brought in from raw data *</_internet_mobile_note_>
gen internet_mobile=.a
*</_internet_mobile_>

*<_internet_mobile4G_>
*<_internet_mobile4G_note_> Ownership of a  internet (mobile LTE 4G 5G ) *</_internet_mobile4G_note_>
/*<_internet_mobile4G_note_>  *</_internet_mobile4G_note_>*/
*<_internet_mobile4G_note_> internet_mobile4G brought in from raw data *</_internet_mobile4G_note_>
gen internet_mobile4G=.a
*</_internet_mobile4G_>

*<_radio_>
*<_radio_note_> Ownership of a radio *</_radio_note_>
/*<_radio_note_>  1 Â "Yes" Â 0 "No" *</_radio_note_>*/
*<_radio_note_> radio brought in from raw data *</_radio_note_>
*gen radio=.a
*</_radio_>

*<_tv_>
*<_tv_note_> Ownership of a tv *</_tv_note_>
/*<_tv_note_>  1 Â "Yes" Â 0 "No" *</_tv_note_>*/
*<_tv_note_> tv brought in from television in SARMD *</_tv_note_>
gen tv=.a
*</_tv_>

*<_tv_cable_>
*<_tv_cable_note_> Ownership of a cable tv *</_tv_cable_note_>
/*<_tv_cable_note_>  1 Â "Yes" Â 0 "No" *</_tv_cable_note_>*/
*<_tv_cable_note_> tv_cable brought in from raw data *</_tv_cable_note_>
gen tv_cable=.a
*</_tv_cable_>

*<_video_>
*<_video_note_> Ownership of a video *</_video_note_>
/*<_video_note_>  1 Â "Yes" Â 0 "No" *</_video_note_>*/
*<_video_note_> video brought in from raw data *</_video_note_>
gen video=.a
*</_video_>

*<_fridge_>
*<_fridge_note_> Ownership of a refrigerator *</_fridge_note_>
/*<_fridge_note_>  1 Â "Yes" Â 0 "No" *</_fridge_note_>*/
*<_fridge_note_> fridge brought in from refrigerator in SARMD *</_fridge_note_>
gen fridge=.a
*</_fridge_>

*<_sewmach_>
*<_sewmach_note_> Ownership of a sewing machine *</_sewmach_note_>
/*<_sewmach_note_>  1 Â "Yes" Â 0 "No" *</_sewmach_note_>*/
*<_sewmach_note_> sewmach brought in from sewingmachine in SARMD *</_sewmach_note_>
gen sewmach=.a
*</_sewmach_>

*<_washmach_>
*<_washmach_note_> Ownership of a washing machine *</_washmach_note_>
/*<_washmach_note_>  1 Â "Yes" Â 0 "No" *</_washmach_note_>*/
*<_washmach_note_> washmach brought in from washingmachine in SARMD *</_washmach_note_>
gen washmach=.a
*</_washmach_>

*<_stove_>
*<_stove_note_> Ownership of a stove *</_stove_note_>
/*<_stove_note_>  1 Â "Yes" Â 0 "No" *</_stove_note_>*/
*<_stove_note_> stove brought in from raw data *</_stove_note_>
gen stove=.a
*</_stove_>

*<_ricecook_>
*<_ricecook_note_> Ownership of a rice cooker *</_ricecook_note_>
/*<_ricecook_note_>  1 Â "Yes" Â 0 "No" *</_ricecook_note_>*/
*<_ricecook_note_> ricecook brought in from raw data *</_ricecook_note_>
gen ricecook=.a
*</_ricecook_>

*<_fan_>
*<_fan_note_> Ownership of an electric fan *</_fan_note_>
/*<_fan_note_>  1 Â "Yes" Â 0 "No" *</_fan_note_>*/
*<_fan_note_> fan brought in from raw data *</_fan_note_>
*gen fan=.a
*</_fan_>

*<_ac_>
*<_ac_note_> Ownership of a central or wall air conditioner *</_ac_note_>
/*<_ac_note_>  1 Â "Yes" Â 0 "No" *</_ac_note_>*/
*<_ac_note_> ac brought in from raw data *</_ac_note_>
gen ac=.a
*</_ac_>

*<_ewpump_>
*<_ewpump_note_> Ownership of a electric water pump *</_ewpump_note_>
/*<_ewpump_note_>  1 Â "Yes" Â 0 "No" *</_ewpump_note_>*/
*<_ewpump_note_> ewpump brought in from raw data *</_ewpump_note_>
gen ewpump=.a
*</_ewpump_>

*<_bcycle_>
*<_bcycle_note_> Ownership of a bicycle *</_bcycle_note_>
/*<_bcycle_note_>  1 Â "Yes" Â 0 "No" *</_bcycle_note_>*/
*<_bcycle_note_> bcycle brought in from bicycle in SARMD *</_bcycle_note_>
gen bcycle=.a
*</_bcycle_>

*<_mcycle_>
*<_mcycle_note_> Ownership of a motorcycle *</_mcycle_note_>
/*<_mcycle_note_>  1 Â "Yes" Â 0 "No" *</_mcycle_note_>*/
*<_mcycle_note_> mcycle brought in from motorcycle in SARMD *</_mcycle_note_>
gen mcycle=.a
*</_mcycle_>

*<_oxcart_>
*<_oxcart_note_> Ownership of a oxcart *</_oxcart_note_>
/*<_oxcart_note_>  1 Â "Yes" Â 0 "No" *</_oxcart_note_>*/
*<_oxcart_note_> oxcart brought in from raw data *</_oxcart_note_>
gen oxcart=.a
*</_oxcart_>

*<_boat_>
*<_boat_note_> Ownership of a boat *</_boat_note_>
/*<_boat_note_>  1 Â "Yes" Â 0 "No" *</_boat_note_>*/
*<_boat_note_> boat brought in from raw data *</_boat_note_>
gen boat=.a
*</_boat_>

*<_car_>
*<_car_note_> Ownership of a Car *</_car_note_>
/*<_car_note_>  1 Â "Yes" Â 0 "No" *</_car_note_>*/
*<_car_note_> car brought in from motorcar in SARMD *</_car_note_>
gen car=.a
*</_car_>

*<_canoe_>
*<_canoe_note_> Ownership of a canoes *</_canoe_note_>
/*<_canoe_note_>  1 Â "Yes" Â 0 "No" *</_canoe_note_>*/
*<_canoe_note_> canoe brought in from raw data *</_canoe_note_>
gen canoe=.a
*</_canoe_>

*<_roof_>
*<_roof_note_> Main material used for roof *</_roof_note_>
/*<_roof_note_>  1 Â "Natural â€“ Thatch/palm leaf" 2 Â "Natural â€“ Sod" Â 3 Â "Natural â€“ Other" Â 4 Â "Rudimentary â€“ Rustic mat" Â 5 "Rudimentary â€“ Palm/bamboo" 6 Â "Rudimentary â€“ Wood planks" Â 7 "Rudimentary â€“ Other" Â 8 Â "Finished â€“ Roofing" Â *</_roof_note_>*/
*<_roof_note_> roof brought in from raw data *</_roof_note_>
gen roof=.a
*</_roof_>

*<_wall_>
*<_wall_note_> Main material used for external walls *</_wall_note_>
/*<_wall_note_>  1 Â "Natural â€“ Cane/palm/trunks" 2 Â "Natural â€“ Dirt" 3 Â "Natural â€“ Other" 4 "Rudimentary â€“ Bamboo with mud" 5 Â "Rudimentary â€“ Stone with mud" Â 6 Â "Rudimentary â€“ Uncovered adobe" 7 Â "Rudimentary â€“ Plywood" 8 Â "Rudimentary â€ *</_wall_note_>*/
*<_wall_note_> wall brought in from raw data *</_wall_note_>
gen wall=.a
*</_wall_>

*<_floor_>
*<_floor_note_> Main material used for floor *</_floor_note_>
/*<_floor_note_>  1 Â "Natural â€“ Earth/sand" Â  2 Â "Natural â€“ Dung" 3 Â "Natural â€“Â¬ Other" Â 4 Â "Rudimentary â€“Â¬ Wood planks" Â 5 "Rudimentary â€“Â¬ Palm/bamboo" Â  Â 6"Rudimentary â€“ Other" Â 7 "Finished â€“ Parquet or polished wood" Â 8 "Finished â *</_floor_note_>*/
*<_floor_note_> floor brought in from raw data *</_floor_note_>
gen floor=.a
*</_floor_>

*<_kitchen_>
*<_kitchen_note_> Separate kitchen in the dwelling *</_kitchen_note_>
/*<_kitchen_note_>  1 Â "Yes" Â 0 "No" *</_kitchen_note_>*/
*<_kitchen_note_> kitchen brought in from raw data *</_kitchen_note_>
gen kitchen=.a
*</_kitchen_>

*<_bath_>
*<_bath_note_> Bathing facility in the dwelling *</_bath_note_>
/*<_bath_note_>  1 Â "Yes" Â 0 "No" *</_bath_note_>*/
*<_bath_note_> bath brought in from raw data *</_bath_note_>
gen bath=.a
*</_bath_>

*<_rooms_>
*<_rooms_note_> Number of habitable rooms *</_rooms_note_>
/*<_rooms_note_>  *</_rooms_note_>*/
*<_rooms_note_> rooms brought in from raw data *</_rooms_note_>
gen rooms=.a
*</_rooms_>

*<_areaspace_>
*<_areaspace_note_> Area *</_areaspace_note_>
/*<_areaspace_note_>  *</_areaspace_note_>*/
*<_areaspace_note_> areaspace brought in from raw data *</_areaspace_note_>
gen areaspace=.a
*</_areaspace_>

*<_ybuilt_>
*<_ybuilt_note_> Year the dwelling built *</_ybuilt_note_>
/*<_ybuilt_note_>  *</_ybuilt_note_>*/
*<_ybuilt_note_> ybuilt brought in from raw data *</_ybuilt_note_>
gen ybuilt=.a
*</_ybuilt_>

*<_ownhouse_>
*<_ownhouse_note_> Ownership of house *</_ownhouse_note_>
/*<_ownhouse_note_>  1 Â "Ownership/secure rights" Â 2 "Renting" 3 "Provided for free" 4 "Without permission" *</_ownhouse_note_>*/
*<_ownhouse_note_> ownhouse brought in from typehouse in SARMD *</_ownhouse_note_>
*gen ownhouse=.a
*</_ownhouse_>

*<_acqui_house_>
*<_acqui_house_note_> Acquisition of house *</_acqui_house_note_>
/*<_acqui_house_note_>  1 Â "Purchased" Â 2 Â "Inherited" Â 3 "Other" *</_acqui_house_note_>*/
*<_acqui_house_note_> acqui_house brought in from raw data *</_acqui_house_note_>
gen acqui_house=.a
*</_acqui_house_>

*<_dwelownlti_>
*<_dwelownlti_note_> Legal title for Ownership *</_dwelownlti_note_>
/*<_dwelownlti_note_>  1 Â "Yes" Â 0 "No" *</_dwelownlti_note_>*/
*<_dwelownlti_note_> dwelownlti brought in from raw data *</_dwelownlti_note_>
gen dwelownlti=.a
*</_dwelownlti_>

*<_fem_dwelownlti_>
*<_fem_dwelownlti_note_> Legal title for Ownership - Female *</_fem_dwelownlti_note_>
/*<_fem_dwelownlti_note_>  1 Â "Yes" Â 0 "No" *</_fem_dwelownlti_note_>*/
*<_fem_dwelownlti_note_> fem_dwelownlti brought in from raw data *</_fem_dwelownlti_note_>
gen fem_dwelownlti=.a
*</_fem_dwelownlti_>

*<_dwelownti_>
*<_dwelownti_note_> Type of Legal document *</_dwelownti_note_>
/*<_dwelownti_note_>  1 Â "Title, deed, freehold" Â 2 "Government issued leasehold" 3 Â "Occupancy certificate â€“ govt issued" 4 "legal document in the name of group (community  cooperative)" 5 "condominium (apartment)" 6 "Other" *</_dwelownti_note_>*/
*<_dwelownti_note_> dwelownti brought in from raw data *</_dwelownti_note_>
gen dwelownti=.a
*</_dwelownti_>

*<_selldwel_>
*<_selldwel_note_> Right to sell dwelling *</_selldwel_note_>
/*<_selldwel_note_>  1 Â "Yes" Â 0 "No" *</_selldwel_note_>*/
*<_selldwel_note_> selldwel brought in from raw data *</_selldwel_note_>
gen selldwel=.a
*</_selldwel_>

*<_transdwel_>
*<_transdwel_note_> Right to transfer dwelling *</_transdwel_note_>
/*<_transdwel_note_>  1 Â "Yes" Â 0 "No" *</_transdwel_note_>*/
*<_transdwel_note_> transdwel brought in from raw data *</_transdwel_note_>
gen transdwel=.a
*</_transdwel_>

*<_ownland_>
*<_ownland_note_> Ownership of land *</_ownland_note_>
/*<_ownland_note_>  1 Â "Yes" Â 0 "No" *</_ownland_note_>*/
*<_ownland_note_> ownland brought in from raw data *</_ownland_note_>
gen ownland=.a
*</_ownland_>

*<_acqui_land_>
*<_acqui_land_note_> Acquisition of residential land *</_acqui_land_note_>
/*<_acqui_land_note_>  1 Â "Purchased" Â 2 Â "Inherited" Â 3 "Other" *</_acqui_land_note_>*/
*<_acqui_land_note_> acqui_land brought in from raw data *</_acqui_land_note_>
gen acqui_land=.a
*</_acqui_land_>

*<_doculand_>
*<_doculand_note_> Legal document for residential land *</_doculand_note_>
/*<_doculand_note_>  1 Â "Yes" Â 0 "No" *</_doculand_note_>*/
*<_doculand_note_> doculand brought in from raw data *</_doculand_note_>
gen doculand=.a
*</_doculand_>

*<_fem_doculand_>
*<_fem_doculand_note_> Legal document for residential land - female *</_fem_doculand_note_>
/*<_fem_doculand_note_>  1 Â "Yes" Â 0 "No" *</_fem_doculand_note_>*/
*<_fem_doculand_note_> fem_doculand brought in from raw data *</_fem_doculand_note_>
gen fem_doculand=.a
*</_fem_doculand_>

*<_landownti_>
*<_landownti_note_> Land Ownership *</_landownti_note_>
/*<_landownti_note_>  1 Â "Title  deed" Â 2 Â "leasehold (govt issued)" Â 3 Â "Customary land certificate/plot level" Â 4 Â  "Customary based/group right" Â  5 Â "Cooperative group right" Â  6 Â "Other" *</_landownti_note_>*/
*<_landownti_note_> landownti brought in from raw data *</_landownti_note_>
gen landownti=.a
*</_landownti_>

*<_sellland_>
*<_sellland_note_> Right to sell land *</_sellland_note_>
/*<_sellland_note_>  1 Â "Yes" Â 0 "No" *</_sellland_note_>*/
*<_sellland_note_> sellland brought in from raw data *</_sellland_note_>
gen sellland=.a
*</_sellland_>

*<_transland_>
*<_transland_note_> Right to transfer land *</_transland_note_>
/*<_transland_note_>  1 Â "Yes" Â 0 "No" *</_transland_note_>*/
*<_transland_note_> transland brought in from raw data *</_transland_note_>
gen transland=.a
*</_transland_>

*<_agriland_>
*<_agriland_note_> Agriculture Land *</_agriland_note_>
/*<_agriland_note_>  1 Â "Yes" Â 0 "No" *</_agriland_note_>*/
*<_agriland_note_> agriland brought in from raw data *</_agriland_note_>
gen agriland=.a
*</_agriland_>

*<_area_agriland_>
*<_area_agriland_note_> Area of Agriculture land *</_area_agriland_note_>
/*<_area_agriland_note_>  *</_area_agriland_note_>*/
*<_area_agriland_note_> area_agriland brought in from raw data *</_area_agriland_note_>
gen area_agriland=.a
*</_area_agriland_>

*<_ownagriland_>
*<_ownagriland_note_> Ownership of agriculture land *</_ownagriland_note_>
/*<_ownagriland_note_>  1 Â "Yes" Â 0 "No" *</_ownagriland_note_>*/
*<_ownagriland_note_> ownagriland brought in from raw data *</_ownagriland_note_>
gen ownagriland=.a
*</_ownagriland_>

*<_area_ownagriland_>
*<_area_ownagriland_note_> Area of agriculture land owned *</_area_ownagriland_note_>
/*<_area_ownagriland_note_>  *</_area_ownagriland_note_>*/
*<_area_ownagriland_note_> area_ownagriland brought in from raw data *</_area_ownagriland_note_>
gen area_ownagriland=.a
*</_area_ownagriland_>

*<_purch_agriland_>
*<_purch_agriland_note_> Purchased agri land *</_purch_agriland_note_>
/*<_purch_agriland_note_>  1 Â "Yes" Â 0 "No" *</_purch_agriland_note_>*/
*<_purch_agriland_note_> purch_agriland brought in from raw data *</_purch_agriland_note_>
gen purch_agriland=.a
*</_purch_agriland_>

*<_areapurch_agriland_>
*<_areapurch_agriland_note_> Area of purchased agriculture land *</_areapurch_agriland_note_>
/*<_areapurch_agriland_note_>  *</_areapurch_agriland_note_>*/
*<_areapurch_agriland_note_> areapurch_agriland brought in from raw data *</_areapurch_agriland_note_>
gen areapurch_agriland=.a
*</_areapurch_agriland_>

*<_inher_agriland_>
*<_inher_agriland_note_> Inherit agriculture land *</_inher_agriland_note_>
/*<_inher_agriland_note_>  1 Â "Yes" Â 0 "No" *</_inher_agriland_note_>*/
*<_inher_agriland_note_> inher_agriland brought in from raw data *</_inher_agriland_note_>
gen inher_agriland=.a
*</_inher_agriland_>

*<_areainher_agriland_>
*<_areainher_agriland_note_> Area of inherited agriculture land *</_areainher_agriland_note_>
/*<_areainher_agriland_note_>  *</_areainher_agriland_note_>*/
*<_areainher_agriland_note_> areainher_agriland brought in from raw data *</_areainher_agriland_note_>
gen areainher_agriland=.a
*</_areainher_agriland_>

*<_rentout_agriland_>
*<_rentout_agriland_note_> Rent Out Land *</_rentout_agriland_note_>
/*<_rentout_agriland_note_>  1 Â "Yes" Â 0 "No" *</_rentout_agriland_note_>*/
*<_rentout_agriland_note_> rentout_agriland brought in from raw data *</_rentout_agriland_note_>
gen rentout_agriland=.a
*</_rentout_agriland_>

*<_arearentout_agriland_>
*<_arearentout_agriland_note_> Area of rent out agri land *</_arearentout_agriland_note_>
/*<_arearentout_agriland_note_>  *</_arearentout_agriland_note_>*/
*<_arearentout_agriland_note_> arearentout_agriland brought in from raw data *</_arearentout_agriland_note_>
gen arearentout_agriland=.a
*</_arearentout_agriland_>

*<_rentin_agriland_>
*<_rentin_agriland_note_> Rent in Land *</_rentin_agriland_note_>
/*<_rentin_agriland_note_>  1 Â "Yes" Â 0 "No" *</_rentin_agriland_note_>*/
*<_rentin_agriland_note_> rentin_agriland brought in from raw data *</_rentin_agriland_note_>
gen rentin_agriland=.a
*</_rentin_agriland_>

*<_arearentin_agriland_>
*<_arearentin_agriland_note_> Area of rent in agri land *</_arearentin_agriland_note_>
/*<_arearentin_agriland_note_>  *</_arearentin_agriland_note_>*/
*<_arearentin_agriland_note_> arearentin_agriland brought in from raw data *</_arearentin_agriland_note_>
gen arearentin_agriland=.a
*</_arearentin_agriland_>

*<_docuagriland_>
*<_docuagriland_note_> Documented Agri Land *</_docuagriland_note_>
/*<_docuagriland_note_>  1 Â "Yes" Â 0 "No" *</_docuagriland_note_>*/
*<_docuagriland_note_> docuagriland brought in from raw data *</_docuagriland_note_>
gen docuagriland=.a
*</_docuagriland_>

*<_area_docuagriland_>
*<_area_docuagriland_note_> Area of documented agri land *</_area_docuagriland_note_>
/*<_area_docuagriland_note_>  *</_area_docuagriland_note_>*/
*<_area_docuagriland_note_> area_docuagriland brought in from raw data *</_area_docuagriland_note_>
gen area_docuagriland=.a
*</_area_docuagriland_>

*<_fem_agrilandownti_>
*<_fem_agrilandownti_note_> Ownership Agri Land - Female *</_fem_agrilandownti_note_>
/*<_fem_agrilandownti_note_>  1 Â "Yes" Â 0 "No" *</_fem_agrilandownti_note_>*/
*<_fem_agrilandownti_note_> fem_agrilandownti brought in from raw data *</_fem_agrilandownti_note_>
gen fem_agrilandownti=.a
*</_fem_agrilandownti_>

*<_agrilandownti_>
*<_agrilandownti_note_> Type Agri Land ownership doc *</_agrilandownti_note_>
/*<_agrilandownti_note_>  1 Â "Title  deed" 2 Â "Leasehold (govt issued)" Â 3 Â "Customary land certificate/plot level" 4 "Customary based / group right" Â 5 Â "Cooperative" Â 6 Â "Other" *</_agrilandownti_note_>*/
*<_agrilandownti_note_> agrilandownti brought in from raw data *</_agrilandownti_note_>
gen agrilandownti=.a
*</_agrilandownti_>

*<_sellagriland_>
*<_sellagriland_note_> Right to sell agri land *</_sellagriland_note_>
/*<_sellagriland_note_>  1 Â "Yes" Â 0 "No" *</_sellagriland_note_>*/
*<_sellagriland_note_> sellagriland brought in from raw data *</_sellagriland_note_>
gen sellagriland=.a
*</_sellagriland_>

*<_transagriland_>
*<_transagriland_note_> Right to transfer agri land *</_transagriland_note_>
/*<_transagriland_note_>  1 Â "Yes" Â 0 "No" *</_transagriland_note_>*/
*<_transagriland_note_> transagriland brought in from raw data *</_transagriland_note_>
gen transagriland=.a
*</_transagriland_>

*<_dweltyp_>
*<_dweltyp_note_> Types of Dwelling *</_dweltyp_note_>
/*<_dweltyp_note_>  1 Â "Detached house" 2 "Multi-family house" 3 "Separate apartment" 4 "Communal apartment" 5 "Room in a larger dwelling" 6 "Several buildings connected" 7 "Several separate buildings" 8 "Improvised housing unit" 9 "Other" *</_dweltyp_note_>*/
*<_dweltyp_note_> dweltyp brought in from raw data *</_dweltyp_note_>
gen dweltyp=.a
*</_dweltyp_>

*<_typlivqrt_>
*<_typlivqrt_note_> Types of living quarters *</_typlivqrt_note_>
/*<_typlivqrt_note_>  1 Â "Housing units, conventional dwelling with basic facilities" 2 "Housing units, conventional dwelling without basic facilities" 3 "Other" *</_typlivqrt_note_>*/
*<_typlivqrt_note_> typlivqrt brought in from raw data *</_typlivqrt_note_>
gen typlivqrt=.a
*</_typlivqrt_>

*<_Keep variables_>
*keep countrycode year hhid pid weight weighttype landphone cellphone cellphone_i phone computer etablet internet internet_mobile internet_mobile4G radio tv tv_cable video fridge sewmach washmach stove ricecook fan ac ewpump bcycle mcycle oxcart boat car canoe roof wall floor kitchen bath rooms areaspace ybuilt ownhouse acqui_house dwelownlti fem_dwelownlti dwelownti selldwel transdwel ownland acqui_land doculand fem_doculand landownti sellland transland agriland area_agriland ownagriland area_ownagriland purch_agriland areapurch_agriland inher_agriland areainher_agriland rentout_agriland arearentout_agriland rentin_agriland arearentin_agriland docuagriland area_docuagriland fem_agrilandownti agrilandownti sellagriland transagriland dweltyp typlivqrt
order countrycode year hhid pid weight weighttype
sort hhid pid 
*</_Keep variables_>

*<_Save data file_>
do 	 "$rootdatalib\\`code'\\`yearfolder'\\`SARMDfolder'\Programs\Labels_GMD2.0.do"
save "${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\Data\Harmonized\\`filename'.dta" , replace
*</_Save data file_>
