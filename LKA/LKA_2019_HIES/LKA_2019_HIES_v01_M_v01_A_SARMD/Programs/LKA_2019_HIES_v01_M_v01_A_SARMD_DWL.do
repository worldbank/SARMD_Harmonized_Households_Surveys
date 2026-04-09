/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   LKA_2019_HIES_v01_M_v01_A_SARMD_DWL.do	</_Program name_>
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
File:	LKA_2019_HIES_v01_M_v01_A_SARMD_DWL.do
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
local va           "01"
local type         "SARMD"
glo   module       "DWL"
local yearfolder   "`code'_`year'_`survey'"
local gmdfolder    "`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD"
local filename     "`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD_${module}"
*</_Program setup_>

* global path on Joe's computer
if ("`c(username)'"=="sunquat") {
	glo basepath "/Users/`c(username)'/Projects/WORLD BANK/SAR - GMD data harmonization/datalib/`code'/`yearfolder'"
	glo input "${basepath}/`yearfolder'_v`vm'_M"
	glo output "${basepath}/`yearfolder'_v`vm'_M_v`va'_A_SARGMD/Data/Harmonized"
	
	* load and merge relevant data
	cd "${input}/Data/Stata"
	* weight data
	use "weight_2019", clear
	* durable goods data
	merge 1:m psu using "SEC_6A_DURABLE_GOODS", nogen assert(match)
	* housing data
	merge 1:1 hhid using "SEC_8_HOUSING", nogen keep(match)
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

	*<_Datalibweb request_>
	* load and merge relevant data
	tempfile hh_level_data
	* weight data
	datalibweb, country(`code') year(`year') type(SARRAW) filename(weight_2019.dta)
	save `hh_level_data'
	* merge in durable goods data
	datalibweb, country(`code') year(`year') type(SARRAW) filename(SEC_6A_DURABLE_GOODS.dta)
	merge m:1 psu using `hh_level_data', nogen update assert(match)
	save `hh_level_data', replace
	* demographic data
	datalibweb, country(`code') year(`year') type(SARRAW) filename(SEC_8_HOUSING.dta)
	merge 1:1 hhid using `hh_level_data', nogen keep(match)
	*</_Datalibweb request_>
}

*<_countrycode_>
*<_countrycode_note_> country code *</_countrycode_note_>
*<_countrycode_note_> countrycode brought in from rawdata *</_countrycode_note_>
gen countrycode=code
*</_countrycode_>

*<_year_>
*<_year_note_> Year *</_year_note_>
*<_year_note_> year brought in from rawdata *</_year_note_>
* NOTE: this variable already exists in harmonized form
*</_year_>

*<_hhid_>
*<_hhid_note_> Household identifier  *</_hhid_note_>
*<_hhid_note_> hhid brought in from rawdata *</_hhid_note_>
* NOTE: this variable already exists in harmonized form
*</_hhid_>

*<_weight_>
*<_weight_note_> Household weight *</_weight_note_>
*<_weight_note_> weight brought in from rawdata *</_weight_note_>
clonevar weight = finalweight
*</_weight_>

*<_weighttype_>
*<_weighttype_note_> Weight type (frequency, probability, analytical, importance) *</_weighttype_note_>
*<_weighttype_note_> weighttype brought in from rawdata *</_weighttype_note_>
gen weighttype = "PW"
*</_weighttype_>

*<_landphone_>
*<_landphone_note_> Ownership of a land phone (household) *</_landphone_note_>
*<_landphone_note_> landphone brought in from rawdata *</_landphone_note_>
g landphone = (telephone==1) if inlist(telephone,1,2)
*</_landphone_>

*<_cellphone_>
*<_cellphone_note_> Ownership of a cell phone (household) *</_cellphone_note_>
*<_cellphone_note_> cellphone brought in from rawdata *</_cellphone_note_>
gen cellphone = (telephone_mobile==1) if inlist(telephone_mobile,1,2)
*</_cellphone_>

*<_phone_>
*<_phone_note_> Ownership of a telephone (household) *</_phone_note_>
*<_phone_note_> phone brought in from rawdata *</_phone_note_>
gen phone = .
*</_phone_>

*<_computer_>
*<_computer_note_> Ownership of a computer *</_computer_note_>
*<_computer_note_> computer brought in from rawdata *</_computer_note_>
gen computer = (computers==1) if inlist(computers,1,2)
note computer: LKA 2019 doesn't distinguish between "Personal Computers/ Laptop/ Tablet", so this variable includes all of those categories of computers.
*</_computer_>

*<_etablet_>
*<_etablet_note_> Ownership of a electronic tablet *</_etablet_note_>
*<_etablet_note_> etablet brought in from rawdata *</_etablet_note_>
gen etablet = (computers==1) if inlist(computers,1,2)
note etablet: LKA 2019 doesn't distinguish between "Personal Computers/ Laptop/ Tablet", so this variable includes all of those categories of etablets.
*</_etablet_>

*<_internet_>
*<_internet_note_> Ownership of a  internet *</_internet_note_>
*<_internet_note_> internet brought in from rawdata *</_internet_note_>
gen internet=.
*</_internet_>

*<_internet_mobile_>
*<_internet_mobile_note_> Ownership of a  internet (mobile 2G 3G LTE 4G 5G ) *</_internet_mobile_note_>
*<_internet_mobile_note_> internet_mobile brought in from rawdata *</_internet_mobile_note_>
gen internet_mobile=.
*</_internet_mobile_>

*<_internet_mobile4G_>
*<_internet_mobile4G_note_> Ownership of a  internet (mobile LTE 4G 5G ) *</_internet_mobile4G_note_>
*<_internet_mobile4G_note_> internet_mobile4G brought in from rawdata *</_internet_mobile4G_note_>
gen internet_mobile4G=.
*</_internet_mobile4G_>

*<_radio_>
*<_radio_note_> Ownership of a radio *</_radio_note_>
*<_radio_note_> radio brought in from rawdata *</_radio_note_>
recode radio (1=1) (2=0) (*=.)
note radio: LKA 2019 doesn't distinguish between "Radio / Cassette player", so this variable also includes cassette players.
*</_radio_>

*<_tv_>
*<_tv_note_> Ownership of a tv *</_tv_note_>
*<_tv_note_> tv brought in from rawdata *</_tv_note_>
recode tv (1=1) (2=0) (*=.)
*</_tv_>

*<_tv_cable_>
*<_tv_cable_note_> Ownership of a cable tv *</_tv_cable_note_>
*<_tv_cable_note_> tv_cable brought in from rawdata *</_tv_cable_note_>
gen tv_cable=.
*</_tv_cable_>

*<_video_>
*<_video_note_> Ownership of a video *</_video_note_>
*<_video_note_> video brought in from rawdata *</_video_note_>
g video = (vcd==1 | camera==1) if inlist(vcd,1,2) | inlist(camera,1,2)
note video: For LKA 2019 we used "V.C.D. / D.V.D." and "Camera / Video camera".
*</_video_>

*<_fridge_>
*<_fridge_note_> Ownership of a refrigerator *</_fridge_note_>
*<_fridge_note_> fridge brought in from rawdata *</_fridge_note_>
recode fridge (1=1) (2=0) (*=.)
*</_fridge_>

*<_sewmach_>
*<_sewmach_note_> Ownership of a sewing machine *</_sewmach_note_>
*<_sewmach_note_> sewmach brought in from rawdata *</_sewmach_note_>
recode sewingmechine (1=1) (2=0) (*=.), g(sewmach)
*</_sewmach_>

*<_washmach_>
*<_washmach_note_> Ownership of a washing machine *</_washmach_note_>
*<_washmach_note_> washmach brought in from rawdata *</_washmach_note_>
recode washing_mechine (1=1) (2=0) (*=.), g(washmach)
*</_washmach_>

*<_stove_>
*<_stove_note_> Ownership of a stove *</_stove_note_>
*<_stove_note_> stove brought in from rawdata *</_stove_note_>
recode cookers (1=1) (2=0) (*=.), g(stove)
*</_stove_>

*<_ricecook_>
*<_ricecook_note_> Ownership of a rice cooker *</_ricecook_note_>
*<_ricecook_note_> ricecook brought in from rawdata *</_ricecook_note_>
gen ricecook=.
*</_ricecook_>

*<_fan_>
*<_fan_note_> Ownership of an electric fan *</_fan_note_>
*<_fan_note_> fan brought in from rawdata *</_fan_note_>
recode electric_fans (1=1) (2=0) (*=.), g(fan)
*</_fan_>

*<_ac_>
*<_ac_note_> Ownership of a central or wall air conditioner *</_ac_note_>
*<_ac_note_> ac brought in from rawdata *</_ac_note_>
recode s6a_aircon (1=1) (2=0) (*=.), g(ac)
*</_ac_>

*<_ewpump_>
*<_ewpump_note_> Ownership of a electric water pump *</_ewpump_note_>
*<_ewpump_note_> ewpump brought in from rawdata *</_ewpump_note_>
gen ewpump=.
*</_ewpump_>

*<_bcycle_>
*<_bcycle_note_> Ownership of a bicycle *</_bcycle_note_>
*<_bcycle_note_> bcycle brought in from rawdata *</_bcycle_note_>
recode bicycle (1=1) (2=0) (*=.), g(bcycle)
*</_bcycle_>

*<_mcycle_>
*<_mcycle_note_> Ownership of a motorcycle *</_mcycle_note_>
*<_mcycle_note_> mcycle brought in from rawdata *</_mcycle_note_>
recode motor_bicycle (1=1) (2=0) (*=.), g(mcycle)
*</_mcycle_>

*<_oxcart_>
*<_oxcart_note_> Ownership of a oxcart *</_oxcart_note_>
*<_oxcart_note_> oxcart brought in from rawdata *</_oxcart_note_>
gen oxcart=.
*</_oxcart_>

*<_boat_>
*<_boat_note_> Ownership of a boat *</_boat_note_>
*<_boat_note_> boat brought in from rawdata *</_boat_note_>
recode boats (1=1) (2=0) (*=.), g(boat)
*</_boat_>

*<_car_>
*<_car_note_> Ownership of a Car *</_car_note_>
*<_car_note_> car brought in from rawdata *</_car_note_>
recode motor_car_van (1=1) (2=0) (*=.), g(car)
*</_car_>

*<_canoe_>
*<_canoe_note_> Ownership of a canoes *</_canoe_note_>
*<_canoe_note_> canoe brought in from rawdata *</_canoe_note_>
gen canoe=.
*</_canoe_>

*<_roof_>
*<_roof_note_> Main material used for roof *</_roof_note_>
*<_roof_note_> roof brought in from rawdata *</_roof_note_>
recode roof (1=10) (2=9) (3=11) (4=12) (5=14) (6=1) (9=15) (*=.)
*</_roof_>

*<_wall_>
*<_wall_note_> Main material used for external walls *</_wall_note_>
*<_wall_note_> wall brought in from rawdata *</_wall_note_>
recode walls (1=18) (2=13) (3/4=12) (5=10) (6=1) (7=17) (8=18) (9=19) (*=.), g(wall)
*</_wall_>

*<_floor_>
*<_floor_note_> Main material used for floor *</_floor_note_>
*<_floor_note_> floor brought in from rawdata *</_floor_note_>
recode floor (1 6=11) (2=13) (3 5=1) (4=4) (9=14) (*=.)
*</_floor_>

*<_kitchen_>
*<_kitchen_note_> Separate kitchen in the dwelling *</_kitchen_note_>
*<_kitchen_note_> kitchen brought in from rawdata *</_kitchen_note_>
gen kitchen=.
*</_kitchen_>

*<_bath_>
*<_bath_note_> Bathing facility in the dwelling *</_bath_note_>
*<_bath_note_> bath brought in from rawdata *</_bath_note_>
gen bath=.
*</_bath_>

*<_rooms_>
*<_rooms_note_> Number of habitable rooms *</_rooms_note_>
*<_rooms_note_> rooms brought in from rawdata *</_rooms_note_>
gen rooms=.
*</_rooms_>

*<_areaspace_>
*<_areaspace_note_> Area *</_areaspace_note_>
*<_areaspace_note_> areaspace brought in from rawdata *</_areaspace_note_>
recode area (1=50) (2=175) (3=375) (4=625) (5=875) (6=1250) (7=2250) (9=4000) (*=.), g(areaspace)
replace area = area/10.763910	//convert from sq ft to sq meters
*</_areaspace_>

*<_ybuilt_>
*<_ybuilt_note_> Year the dwelling built *</_ybuilt_note_>
*<_ybuilt_note_> ybuilt brought in from rawdata *</_ybuilt_note_>
gen ybuilt=.
*</_ybuilt_>

*<_ownhouse_>
*<_ownhouse_note_> Ownership of house *</_ownhouse_note_>
*<_ownhouse_note_> ownhouse brought in from rawdata *</_ownhouse_note_>
recode ownership (1/2=1) (3/6=3) (7/8=2) (9=4) (*=.), g(ownhouse)
*</_ownhouse_>

*<_acqui_house_>
*<_acqui_house_note_> Acquisition of house *</_acqui_house_note_>
*<_acqui_house_note_> acqui_house brought in from rawdata *</_acqui_house_note_>
recode ownership (1=1) (2=2) (*=.), g(acqui_house)
*</_acqui_house_>

*<_dwelownlti_>
*<_dwelownlti_note_> Legal title for Ownership *</_dwelownlti_note_>
*<_dwelownlti_note_> dwelownlti brought in from rawdata *</_dwelownlti_note_>
gen dwelownlti=.
*</_dwelownlti_>

*<_fem_dwelownlti_>
*<_fem_dwelownlti_note_> Legal title for Ownership - Female *</_fem_dwelownlti_note_>
*<_fem_dwelownlti_note_> fem_dwelownlti brought in from rawdata *</_fem_dwelownlti_note_>
gen fem_dwelownlti=.
*</_fem_dwelownlti_>

*<_dwelownti_>
*<_dwelownti_note_> Type of Legal document *</_dwelownti_note_>
*<_dwelownti_note_> dwelownti brought in from rawdata *</_dwelownti_note_>
gen dwelownti=.
*</_dwelownti_>

*<_selldwel_>
*<_selldwel_note_> Right to sell dwelling *</_selldwel_note_>
*<_selldwel_note_> selldwel brought in from rawdata *</_selldwel_note_>
gen selldwel=.
*</_selldwel_>

*<_transdwel_>
*<_transdwel_note_> Right to transfer dwelling *</_transdwel_note_>
*<_transdwel_note_> transdwel brought in from rawdata *</_transdwel_note_>
gen transdwel=.
*</_transdwel_>

*<_ownland_>
*<_ownland_note_> Ownership of land *</_ownland_note_>
*<_ownland_note_> ownland brought in from rawdata *</_ownland_note_>
gen ownland=.
*</_ownland_>

*<_acqui_land_>
*<_acqui_land_note_> Acquisition of residential land *</_acqui_land_note_>
*<_acqui_land_note_> acqui_land brought in from rawdata *</_acqui_land_note_>
gen acqui_land=.
*</_acqui_land_>

*<_doculand_>
*<_doculand_note_> Legal document for residential land *</_doculand_note_>
*<_doculand_note_> doculand brought in from rawdata *</_doculand_note_>
gen doculand=.
*</_doculand_>

*<_fem_doculand_>
*<_fem_doculand_note_> Legal document for residential land - female *</_fem_doculand_note_>
*<_fem_doculand_note_> fem_doculand brought in from rawdata *</_fem_doculand_note_>
gen fem_doculand=.
*</_fem_doculand_>

*<_landownti_>
*<_landownti_note_> Land Ownership *</_landownti_note_>
*<_landownti_note_> landownti brought in from rawdata *</_landownti_note_>
gen landownti=.
*</_landownti_>

*<_sellland_>
*<_sellland_note_> Right to sell land *</_sellland_note_>
*<_sellland_note_> sellland brought in from rawdata *</_sellland_note_>
gen sellland=.
*</_sellland_>

*<_transland_>
*<_transland_note_> Right to transfer land *</_transland_note_>
*<_transland_note_> transland brought in from rawdata *</_transland_note_>
gen transland=.
*</_transland_>

*<_agriland_>
*<_agriland_note_> Agriculture Land *</_agriland_note_>
*<_agriland_note_> agriland brought in from rawdata *</_agriland_note_>
gen agriland=.
*</_agriland_>

*<_area_agriland_>
*<_area_agriland_note_> Area of Agriculture land *</_area_agriland_note_>
*<_area_agriland_note_> area_agriland brought in from rawdata *</_area_agriland_note_>
gen area_agriland=.
*</_area_agriland_>

*<_ownagriland_>
*<_ownagriland_note_> Ownership of agriculture land *</_ownagriland_note_>
*<_ownagriland_note_> ownagriland brought in from rawdata *</_ownagriland_note_>
gen ownagriland=.
*</_ownagriland_>

*<_area_ownagriland_>
*<_area_ownagriland_note_> Area of agriculture land owned *</_area_ownagriland_note_>
*<_area_ownagriland_note_> area_ownagriland brought in from rawdata *</_area_ownagriland_note_>
gen area_ownagriland=.
*</_area_ownagriland_>

*<_purch_agriland_>
*<_purch_agriland_note_> Purchased agri land *</_purch_agriland_note_>
*<_purch_agriland_note_> purch_agriland brought in from rawdata *</_purch_agriland_note_>
gen purch_agriland=.
*</_purch_agriland_>

*<_areapurch_agriland_>
*<_areapurch_agriland_note_> Area of purchased agriculture land *</_areapurch_agriland_note_>
*<_areapurch_agriland_note_> areapurch_agriland brought in from rawdata *</_areapurch_agriland_note_>
gen areapurch_agriland=.
*</_areapurch_agriland_>

*<_inher_agriland_>
*<_inher_agriland_note_> Inherit agriculture land *</_inher_agriland_note_>
*<_inher_agriland_note_> inher_agriland brought in from rawdata *</_inher_agriland_note_>
gen inher_agriland=.
*</_inher_agriland_>

*<_areainher_agriland_>
*<_areainher_agriland_note_> Area of inherited agriculture land *</_areainher_agriland_note_>
*<_areainher_agriland_note_> areainher_agriland brought in from rawdata *</_areainher_agriland_note_>
gen areainher_agriland=.
*</_areainher_agriland_>

*<_rentout_agriland_>
*<_rentout_agriland_note_> Rent Out Land *</_rentout_agriland_note_>
*<_rentout_agriland_note_> rentout_agriland brought in from rawdata *</_rentout_agriland_note_>
gen rentout_agriland=.
*</_rentout_agriland_>

*<_arearentout_agriland_>
*<_arearentout_agriland_note_> Area of rent out agri land *</_arearentout_agriland_note_>
*<_arearentout_agriland_note_> arearentout_agriland brought in from rawdata *</_arearentout_agriland_note_>
gen arearentout_agriland=.
*</_arearentout_agriland_>

*<_rentin_agriland_>
*<_rentin_agriland_note_> Rent in Land *</_rentin_agriland_note_>
*<_rentin_agriland_note_> rentin_agriland brought in from rawdata *</_rentin_agriland_note_>
gen rentin_agriland=.
*</_rentin_agriland_>

*<_arearentin_agriland_>
*<_arearentin_agriland_note_> Area of rent in agri land *</_arearentin_agriland_note_>
*<_arearentin_agriland_note_> arearentin_agriland brought in from rawdata *</_arearentin_agriland_note_>
gen arearentin_agriland=.
*</_arearentin_agriland_>

*<_docuagriland_>
*<_docuagriland_note_> Documented Agri Land *</_docuagriland_note_>
*<_docuagriland_note_> docuagriland brought in from rawdata *</_docuagriland_note_>
gen docuagriland=.
*</_docuagriland_>

*<_area_docuagriland_>
*<_area_docuagriland_note_> Area of documented agri land *</_area_docuagriland_note_>
*<_area_docuagriland_note_> area_docuagriland brought in from rawdata *</_area_docuagriland_note_>
gen area_docuagriland=.
*</_area_docuagriland_>

*<_fem_agrilandownti_>
*<_fem_agrilandownti_note_> Ownership Agri Land - Female *</_fem_agrilandownti_note_>
*<_fem_agrilandownti_note_> fem_agrilandownti brought in from rawdata *</_fem_agrilandownti_note_>
gen fem_agrilandownti=.
*</_fem_agrilandownti_>

*<_agrilandownti_>
*<_agrilandownti_note_> Type Agri Land ownership doc *</_agrilandownti_note_>
*<_agrilandownti_note_> agrilandownti brought in from rawdata *</_agrilandownti_note_>
gen agrilandownti=.
*</_agrilandownti_>

*<_sellagriland_>
*<_sellagriland_note_> Right to sell agri land *</_sellagriland_note_>
*<_sellagriland_note_> sellagriland brought in from rawdata *</_sellagriland_note_>
gen sellagriland=.
*</_sellagriland_>

*<_transagriland_>
*<_transagriland_note_> Right to transfer agri land *</_transagriland_note_>
*<_transagriland_note_> transagriland brought in from rawdata *</_transagriland_note_>
gen transagriland=.
*</_transagriland_>

*<_dweltyp_>
*<_dweltyp_note_> Types of Dwelling *</_dweltyp_note_>
*<_dweltyp_note_> dweltyp brought in from rawdata *</_dweltyp_note_>
recode structure (1/3=1) (4 8=6) (5/7=3) (9=8) (99=9) (*=.), g(dweltyp)
*</_dweltyp_>

*<_typlivqrt_>
*<_typlivqrt_note_> Types of living quarters *</_typlivqrt_note_>
*<_typlivqrt_note_> typlivqrt brought in from rawdata *</_typlivqrt_note_>
gen typlivqrt=.
*</_typlivqrt_>

*<_Keep variables_>
*keep countrycode year hhid pid weight weighttype landphone cellphone cellphone_i phone computer etablet internet internet_mobile internet_mobile4G radio tv tv_cable video fridge sewmach washmach stove ricecook fan ac ewpump bcycle mcycle oxcart boat car canoe roof wall floor kitchen bath rooms areaspace ybuilt ownhouse acqui_house dwelownlti fem_dwelownlti dwelownti selldwel transdwel ownland acqui_land doculand fem_doculand landownti sellland transland agriland area_agriland ownagriland area_ownagriland purch_agriland areapurch_agriland inher_agriland areainher_agriland rentout_agriland arearentout_agriland rentin_agriland arearentin_agriland docuagriland area_docuagriland fem_agrilandownti agrilandownti sellagriland transagriland dweltyp typlivqrt
order countrycode year hhid pid weight weighttype
sort hhid pid 
*</_Keep variables_>

*<_Save data file_>
do "${rootdatalib}/`code'/`yearfolder'/`yearfolder'_v`vm'_M_v`va'_A_SARMD/Programs/Labels_GMD2.0.do"
compress
if ("`c(username)'"=="sunquat") save "${output}/`filename'", replace
else save "${rootdatalib}\\`code'\\`yearfolder'\\`gmdfolder'\Data\Harmonized\\`filename'.dta" , replace
*</_Save data file_>
