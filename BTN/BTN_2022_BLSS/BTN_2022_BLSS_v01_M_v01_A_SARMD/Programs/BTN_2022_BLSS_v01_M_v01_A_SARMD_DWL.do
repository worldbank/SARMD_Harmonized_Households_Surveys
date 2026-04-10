/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   BTN_2022_BLSS_v01_M_v01_A_SARMD_DWL.do	</_Program name_>
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
File:	BTN_2022_BLSS_v01_M_v01_A_SARMD_DWL.do
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
local va           "01"
local type         "SARMD"
glo   module       "DWL"
local yearfolder   "`code'_`year'_`survey'"
local gmdfolder    "`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD"
local filename     "`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD_${module}"
*</_Program setup_>

* global path on Joe's computer
if ("`c(username)'"=="sunquat") {
	glo rootdatalib "/Users/sunquat/Projects/WORLD BANK/SAR - GMD data harmonization/datalib"
	glo output "${rootdatalib}/`code'/`yearfolder'/`yearfolder'_v`vm'_M_v`va'_A_SARGMD/Data/Harmonized"
	
	* load and merge data
	use "${rootdatalib}/BTN/BTN_2022_BLSS/BTN_2022_BLSS_v01_M/Data/Stata/BTN_2022_BLSS_v01_M.dta", clear
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
	* main data
	datalibweb, country(`code') year(`year') type(SARRAW) filename(`yearfolder'_v`vm'_M.dta) local localpath(${rootdatalib})
	* The weights variable in the BTN_2022_BLSS_v01_M file is the old weights variable, so remove it.
	drop weight weights
	tempfile individual_level_data
	save `individual_level_data' //, replace
	
	use "$rootdatalib\\`code'\\`yearfolder'\\`gmdfolder'\Data\Harmonized\\`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD_IND.dta", clear
	merge 1:1 hhid pid using `individual_level_data'
	*</_Datalibweb request_>
	
}

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

*<_landphone_>
*<_landphone_note_> Ownership of a land phone (household) *</_landphone_note_>
*<_landphone_note_> landphone brought in from rawdata *</_landphone_note_>
g landphone = .
*</_landphone_>

*<_cellphone_>
*<_cellphone_note_> Ownership of a cell phone (household) *</_cellphone_note_>
*<_cellphone_note_> cellphone brought in from rawdata *</_cellphone_note_>
cap gen cellphone = ((hs14>0 & hs14<.) | inlist(1,as1__109,as1__110)) if ~missing(hs14) | ~missing(as1__109) | ~missing(as1__110)
*</_cellphone_>

*<_cellphone_i_>
*<_cellphone_i_note_> Ownership of a cell phone (individual) *</_cellphone_i_note_>
*<_cellphone_i_note_> cellphone_i brought in from rawdata *</_cellphone_i_note_>
gen cellphone_i=.
*</_cellphone_i_>

*<_phone_>
*<_phone_note_> Ownership of a telephone (household) *</_phone_note_>
*<_phone_note_> phone brought in from rawdata *</_phone_note_>
gen phone = .
*</_phone_>

*<_computer_>
*<_computer_note_> Ownership of a computer *</_computer_note_>
*<_computer_note_> computer brought in from rawdata *</_computer_note_>
cap gen computer = as1__111
*</_computer_>

*<_etablet_>
*<_etablet_note_> Ownership of a electronic tablet *</_etablet_note_>
*<_etablet_note_> etablet brought in from rawdata *</_etablet_note_>
gen etablet = .
*</_etablet_>

*<_internet_>
*<_internet_note_> Ownership of a  internet *</_internet_note_>
*<_internet_note_> internet brought in from rawdata *</_internet_note_>
*g		internet = 1 if hs17__1==1 | hs17__3==1
*replace internet = 3 if hs17__2==1 | hs17__4==1 | (hs15>0 & hs15<.)
*recode	internet (.=4) if hs17__1==0 & hs17__2==0 & hs17__3==0 & hs17__4==0 & hs15==0
*</_internet_>

*<_internet_mobile_>
*<_internet_mobile_note_> Ownership of a  internet (mobile 2G 3G LTE 4G 5G ) *</_internet_mobile_note_>
*<_internet_mobile_note_> internet_mobile brought in from rawdata *</_internet_mobile_note_>
gen internet_mobile = (hs17__2==1 | hs17__4==1 | (hs15>0 & hs15<.)) if ~missing(hs17__2) | ~missing(hs17__4) | hs15<.
*</_internet_mobile_>

*<_internet_mobile4G_>
*<_internet_mobile4G_note_> Ownership of a  internet (mobile LTE 4G 5G ) *</_internet_mobile4G_note_>
*<_internet_mobile4G_note_> internet_mobile4G brought in from rawdata *</_internet_mobile4G_note_>
gen internet_mobile4G=.
*</_internet_mobile4G_>

*<_radio_>
*<_radio_note_> Ownership of a radio *</_radio_note_>
*<_radio_note_> radio brought in from rawdata *</_radio_note_>
*g radio = .
*</_radio_>

*<_tv_>
*<_tv_note_> Ownership of a tv *</_tv_note_>
*<_tv_note_> tv brought in from rawdata *</_tv_note_>
g tv = as1__108
*</_tv_>

*<_tv_cable_>
*<_tv_cable_note_> Ownership of a cable tv *</_tv_cable_note_>
*<_tv_cable_note_> tv_cable brought in from rawdata *</_tv_cable_note_>
gen tv_cable = (hs18__1==1 | hs18__2==1 | hs18__3==1) if tv==1
note tv_cable: For BTN_2022_BLSS, some households said they had a TV connection (HS18) but said they did not have a TV. I assumed what they said is correct - that although they did have a TV connection, they did not have a TV.
*</_tv_cable_>

*<_video_>
*<_video_note_> Ownership of a video *</_video_note_>
*<_video_note_> video brought in from rawdata *</_video_note_>
g video = .
*</_video_>

*<_fridge_>
*<_fridge_note_> Ownership of a refrigerator *</_fridge_note_>
*<_fridge_note_> fridge brought in from rawdata *</_fridge_note_>
g fridge = as1__104
*</_fridge_>

*<_sewmach_>
*<_sewmach_note_> Ownership of a sewing machine *</_sewmach_note_>
*<_sewmach_note_> sewmach brought in from rawdata *</_sewmach_note_>
g sewmach = as1__129
*</_sewmach_>

*<_washmach_>
*<_washmach_note_> Ownership of a washing machine *</_washmach_note_>
*<_washmach_note_> washmach brought in from rawdata *</_washmach_note_>
g washmach = as1__106
*</_washmach_>

*<_stove_>
*<_stove_note_> Ownership of a stove *</_stove_note_>
*<_stove_note_> stove brought in from rawdata *</_stove_note_>
g stove = (as1__101==1 | as1__102==1 | as1__105==1 | as1__107==1)
*</_stove_>

*<_ricecook_>
*<_ricecook_note_> Ownership of a rice cooker *</_ricecook_note_>
*<_ricecook_note_> ricecook brought in from rawdata *</_ricecook_note_>
g ricecook = as1__101
*</_ricecook_>

*<_fan_>
*<_fan_note_> Ownership of an electric fan *</_fan_note_>
*<_fan_note_> fan brought in from rawdata *</_fan_note_>
cap g fan = as1__118
*</_fan_>

*<_ac_>
*<_ac_note_> Ownership of a central or wall air conditioner *</_ac_note_>
*<_ac_note_> ac brought in from rawdata *</_ac_note_>
g ac = as1__120
*</_ac_>

*<_ewpump_>
*<_ewpump_note_> Ownership of a electric water pump *</_ewpump_note_>
*<_ewpump_note_> ewpump brought in from rawdata *</_ewpump_note_>
gen ewpump=.
*</_ewpump_>

*<_bcycle_>
*<_bcycle_note_> Ownership of a bicycle *</_bcycle_note_>
*<_bcycle_note_> bcycle brought in from rawdata *</_bcycle_note_>
gen bcycle = as1__123
*</_bcycle_>

*<_mcycle_>
*<_mcycle_note_> Ownership of a motorcycle *</_mcycle_note_>
*<_mcycle_note_> mcycle brought in from rawdata *</_mcycle_note_>
gen mcycle = as1__122
*</_mcycle_>

*<_oxcart_>
*<_oxcart_note_> Ownership of a oxcart *</_oxcart_note_>
*<_oxcart_note_> oxcart brought in from rawdata *</_oxcart_note_>
gen oxcart=.
*</_oxcart_>

*<_boat_>
*<_boat_note_> Ownership of a boat *</_boat_note_>
*<_boat_note_> boat brought in from rawdata *</_boat_note_>
gen boat=.
*</_boat_>

*<_car_>
*<_car_note_> Ownership of a Car *</_car_note_>
*<_car_note_> car brought in from rawdata *</_car_note_>
gen car = as1__121
*</_car_>

*<_canoe_>
*<_canoe_note_> Ownership of a canoes *</_canoe_note_>
*<_canoe_note_> canoe brought in from rawdata *</_canoe_note_>
gen canoe=.
*</_canoe_>

*<_roof_>
*<_roof_note_> Main material used for roof *</_roof_note_>
*<_roof_note_> roof brought in from rawdata *</_roof_note_>
recode hs12 (1=12) (2=1) (3=5) (4=13) (5=7) (6=10) (7=14) (8=11) (9=12) (96=15) (*=.), g(roof)
*</_roof_>

*<_wall_>
*<_wall_note_> Main material used for external walls *</_wall_note_>
*<_wall_note_> wall brought in from rawdata *</_wall_note_>
recode hs11 (1=13) (2=5) (3=15) (4=4) (5=12) (6 12/13=18) (7/8=1) (9=7) (10=2) (11=17) (96=19) (*=.), g(wall)
*</_wall_>

*<_floor_>
*<_floor_note_> Main material used for floor *</_floor_note_>
*<_floor_note_> floor brought in from rawdata *</_floor_note_>
recode hs13 (1 10=4) (2 6=7) (3=11) (4=13) (5=1) (7=10) (8=9) (9=5) (96=14) (*=.), g(floor)
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
gen rooms = hs10
note rooms: For BTN_2022_BLSS, this variable includes rooms used for family enterprise as it was not separated.
*</_rooms_>

*<_areaspace_>
*<_areaspace_note_> Area *</_areaspace_note_>
*<_areaspace_note_> areaspace brought in from rawdata *</_areaspace_note_>
gen areaspace=.
*</_areaspace_>

*<_ybuilt_>
*<_ybuilt_note_> Year the dwelling built *</_ybuilt_note_>
*<_ybuilt_note_> ybuilt brought in from rawdata *</_ybuilt_note_>
gen ybuilt=.
*</_ybuilt_>

*<_ownhouse_>
*<_ownhouse_note_> Ownership of house *</_ownhouse_note_>
*<_ownhouse_note_> ownhouse brought in from rawdata *</_ownhouse_note_>
cap clonevar ownhouse= ownhouse
*</_ownhouse_>

*<_acqui_house_>
*<_acqui_house_note_> Acquisition of house *</_acqui_house_note_>
*<_acqui_house_note_> acqui_house brought in from rawdata *</_acqui_house_note_>
gen acqui_house=.
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
g agriland = 0
foreach agriland_var in as3a as3d as4a as4d as5 {
	replace agriland = 1 if `agriland_var'>0 & `agriland_var'<.
}
*</_agriland_>

*<_area_agriland_>
*<_area_agriland_note_> Area of Agriculture land *</_area_agriland_note_>
*<_area_agriland_note_> area_agriland brought in from rawdata *</_area_agriland_note_>
egen area_agriland = rowtotal(as3a as3d as4a as4d as5), missing
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
g rentout_agriland = ((as3b>0 & as3b<.) | (as4b>0 & as4b<.))
*</_rentout_agriland_>

*<_arearentout_agriland_>
*<_arearentout_agriland_note_> Area of rent out agri land *</_arearentout_agriland_note_>
*<_arearentout_agriland_note_> arearentout_agriland brought in from rawdata *</_arearentout_agriland_note_>
egen arearentout_agriland = rowtotal(as3b as4b) if rentout_agriland==1, missing
* convert acres to hectares
replace arearentout_agriland = arearentout_agriland/2.471054
*</_arearentout_agriland_>

*<_rentin_agriland_>
*<_rentin_agriland_note_> Rent in Land *</_rentin_agriland_note_>
*<_rentin_agriland_note_> rentin_agriland brought in from rawdata *</_rentin_agriland_note_>
g rentin_agriland = ((as3d>0 & as3d<.) | (as4d>0 & as4d<.))
*</_rentin_agriland_>

*<_arearentin_agriland_>
*<_arearentin_agriland_note_> Area of rent in agri land *</_arearentin_agriland_note_>
*<_arearentin_agriland_note_> arearentin_agriland brought in from rawdata *</_arearentin_agriland_note_>
egen arearentin_agriland = rowtotal(as3d as4d) if rentin_agriland==1, missing
* convert acres to hectares
replace arearentin_agriland = arearentin_agriland/2.471054
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
recode hs1 (1=1) (2=3) (4=2) (96=9) (*=.), g(dweltyp)
*</_dweltyp_>

*<_typlivqrt_>
*<_typlivqrt_note_> Types of living quarters *</_typlivqrt_note_>
*<_typlivqrt_note_> typlivqrt brought in from rawdata *</_typlivqrt_note_>
gen typlivqrt=.
*</_typlivqrt_>

*<_Keep variables_>
* collapse variables to HH-level
collapse	(firstnm) areaspace area_agriland area_ownagriland areapurch_agriland areainher_agriland arearentout_agriland arearentin_agriland area_docuagriland	///
			(max) landphone cellphone cellphone_i phone computer etablet internet_mobile internet_mobile4G radio tv tv_cable video fridge sewmach washmach stove ricecook fan ac ewpump bcycle mcycle oxcart boat car canoe roof wall floor kitchen bath rooms ybuilt ownhouse acqui_house dwelownlti fem_dwelownlti dwelownti selldwel transdwel ownland acqui_land doculand fem_doculand landownti sellland transland agriland ownagriland purch_agriland inher_agriland rentout_agriland rentin_agriland docuagriland fem_agrilandownti agrilandownti sellagriland transagriland dweltyp typlivqrt	///
			(min) internet	///
			, by(countrycode year hhid)
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
do "${rootdatalib}/`code'/`yearfolder'/`yearfolder'_v`vm'_M_v`va'_A_SARMD/Programs/Labels_GMD2.0.do"
compress
if ("`c(username)'"=="sunquat") save "${output}/`filename'", replace
else save "${rootdatalib}\\`code'\\`yearfolder'\\`gmdfolder'\Data\Harmonized\\`filename'.dta" , replace
*</_Save data file_>
