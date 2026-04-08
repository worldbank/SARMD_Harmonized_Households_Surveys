/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   `code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'_DWL.do	</_Program name_>
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
File:	`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'_DWL.do
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
global module       	"DWL"
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
	*datalibweb, country(AFG) year(2016) type(SARRAW) surveyid(`code'_`year'_`survey'_v01_M) filename(h_04_10.dta) localpath(${rootdatalib}) local
	datalibweb, country(AFG) year(2016) type(SARRAW) surveyid(AFG_2016_LCS_v01_M) filename(h_04_10.dta)
	ren hh_id idh
	save `raw'
	*</_Raw data_>
	
	*<_Datalibweb request_>
	
	*datalibweb, country(`code') year(`year') type(`type') survey(`survey') vermast(`vm') veralt(`va') mod(IND) clear localpath(${rootdatalib}) local
	use "${rootdatalib}\\`code'\\`yearfolder'\\`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD\Data\Harmonized\\`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD_IND.dta", clear
	
	*</_Datalibweb request_>
	
	*<_Merge_>
	merge m:1 idh using `raw', nogen assert(match)
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
*<_pid_note_> pid brought in from rawdata *</_pid_note_>
cap clonevar pid  = idp
*</_pid_>

*<_weight_>
*<_weight_note_> Household weight *</_weight_note_>
*<_weight_note_> weight brought in from rawdata *</_weight_note_>
clonevar  weight = wgt
*</_weight_>

*<_weighttype_>
*<_weighttype_note_> Weight type (frequency, probability, analytical, importance) *</_weighttype_note_>
*<_weighttype_note_> weighttype brought in from rawdata *</_weighttype_note_>
*gen weighttype = "PW"
*</_weighttype_>

*<_landphone_>
*<_landphone_note_> Ownership of a land phone *</_landphone_note_>
*<_landphone_note_> landphone brought in from SARMD *</_landphone_note_>
gen byte landphone=.
note landphone: AFG_2016_LCS does not have any relevant questions or variables.
*</_landphone_>

*<_cellphone_>
*<_cellphone_note_> Ownership of a cell phone *</_cellphone_note_>
*<_cellphone_note_> cellphone brought in from SARMD *</_cellphone_note_>
*cellphone
*</_cellphone_>

*<_phone_>
*<_phone_note_> Ownership of a telephone *</_phone_note_>
*<_phone_note_> phone brought in from SARMD *</_phone_note_>
gen phone=.
*</_phone_>

*<_computer_>
*<_computer_note_> Ownership of a computer *</_computer_note_>
*<_computer_note_> computer brought in from SARMD *</_computer_note_>
*computer
*</_computer_>

*<_etablet_>
*<_etablet_note_> Ownership of a electronic tablet *</_etablet_note_>
*<_etablet_note_> etablet brought in from *</_etablet_note_>
gen etablet= .
*</_etablet_>

*<_internet_>
*<_internet_note_> Ownership of a  internet *</_internet_note_>
*<_internet_note_> internet brought in from SARMD *</_internet_note_>
*internet
*</_internet_>

*<_radio_>
*<_radio_note_> Ownership of a radio *</_radio_note_>
*<_radio_note_> radio brought in from SARMD *</_radio_note_>
*radio
*</_radio_>

*<_tv_>
*<_tv_note_> Ownership of a tv *</_tv_note_>
*<_tv_note_> tv brought in from SARMD *</_tv_note_>
clonevar tv = television
*</_tv_>

*<_tv_cable_>
*<_tv_cable_note_> Ownership of a cable tv *</_tv_cable_note_>
*<_tv_cable_note_> tv_cable brought in from *</_tv_cable_note_>
recode q_7_6_e (0=0) (1/8=1) (*=.) if tv==1, g(tv_cable)
*</_tv_cable_>

*<_video_>
*<_video_note_> Ownership of a video *</_video_note_>
*<_video_note_> video brought in from rawdata *</_video_note_>
gen video= (q_7_1_m  > 0) if !missing(q_7_1_m ) 
*</_video_>

*<_fridge_>
*<_fridge_note_> Ownership of a refrigerator *</_fridge_note_>
*<_fridge_note_> fridge brought in from SARMD *</_fridge_note_>
clonevar fridge = refrigerator
*</_fridge_>

*<_sewmach_>
*<_sewmach_note_> Ownership of a sewing machine *</_sewmach_note_>
*<_sewmach_note_> sewmach brought in from SARMD *</_sewmach_note_>
clonevar sewmach = sewingmachine
*</_sewmach_>

*<_washmach_>
*<_washmach_note_> Ownership of a washing machine *</_washmach_note_>
*<_washmach_note_> washmach brought in from SARMD *</_washmach_note_>
clonevar washmach = washingmachine
*</_washmach_>

*<_stove_>
*<_stove_note_> Ownership of a stove *</_stove_note_>
*<_stove_note_> stove brought in from SARMD *</_stove_note_>
gen byte stove=q_7_1_f
	recode   stove (0=0) (1/max=1)
*</_stove_>

*<_ricecook_>
*<_ricecook_note_> Ownership of a rice cooker *</_ricecook_note_>
*<_ricecook_note_> ricecook brought in from SARMD *</_ricecook_note_>
gen ricecook = .
*</_ricecook_>

*<_fan_>
*<_fan_note_> Ownership of an electric fan *</_fan_note_>
*<_fan_note_> fan brought in from SARMD *</_fan_note_>
cap gen byte fan=q_7_1_j
cap recode   fan (0=0) (1/max=1)
*</_fan_>

*<_ac_>
*<_ac_note_> Ownership of a central or wall air conditioner *</_ac_note_>
*<_ac_note_> ac brought in from *</_ac_note_>
gen ac=. 
*</_ac_>

*<_ewpump_>
*<_ewpump_note_> Ownership of a electric water pump *</_ewpump_note_>
*<_ewpump_note_> ewpump brought in from SARMD *</_ewpump_note_>
gen ewpump=.
*</_ewpump_>

*<_bcycle_>
*<_bcycle_note_> Ownership of a bicycle *</_bcycle_note_>
*<_bcycle_note_> bcycle brought in from SARMD *</_bcycle_note_>
clonevar bcycle = bicycle
*</_bcycle_>

*<_mcycle_>
*<_mcycle_note_> Ownership of a motorcycle *</_mcycle_note_>
*<_mcycle_note_> mcycle brought in from SARMD *</_mcycle_note_>
gen mcycle = motorcycle
*</_mcycle_>

*<_oxcart_>
*<_oxcart_note_> Ownership of a oxcart *</_oxcart_note_>
*<_oxcart_note_> oxcart brought in from SARMD *</_oxcart_note_>
gen oxcart=.
*</_oxcart_>

*<_boat_>
*<_boat_note_> Ownership of a boat *</_boat_note_>
*<_boat_note_> boat brought in from SARMD *</_boat_note_>
gen boat=. 
*</_boat_>

*<_car_>
*<_car_note_> Ownership of a Car *</_car_note_>
*<_car_note_> car brought in from SARMD *</_car_note_>
clonevar car = motorcar
*</_car_>

*<_canoe_>
*<_canoe_note_> Ownership of a canoes *</_canoe_note_>
*<_canoe_note_> canoe brought in from SARMD *</_canoe_note_>
gen canoe=. 
*</_canoe_>

*<_roof_>
*<_roof_note_> Main material used for roof *</_roof_note_>
*<_roof_note_> roof brought in from SARMD *</_roof_note_>
gen byte roof=q_4_3
recode roof (1=34) (2=23) (3=35) (4=21) (5=24) (6=37)
label values roof . 
recode roof (21=4) (23=6) (24=7) (34=11) (35=12) (37=14) (.a=.)
*</_roof_>
*</_roof_>

*<_wall_>
*<_wall_note_> Main material used for external walls *</_wall_note_>
*<_wall_note_> wall brought in from SARMD *</_wall_note_>
gen byte wall=q_4_2
	recode wall (1=32) (2=34) (3=22) (4=22) (5=27) 
label values wall . 
recode wall (22=5) (27=10) (32=12) (34=13) (.a=.)
*</_wall_>

*<_floor_>
*<_floor_note_> Main material used for floor *</_floor_note_>
*<_floor_note_> floor brought in from SARMD *</_floor_note_>
gen byte floor=q_4_4
	recode floor (1=12) (2=34) (3=37)
label values floor . 
recode floor (12=2) (34=10) (37=13) (.a=.)
*</_floor_>

*<_kitchen_>
*<_kitchen_note_> Separate kitchen in the dwelling *</_kitchen_note_>
*<_kitchen_note_> kitchen brought in from SARMD *</_kitchen_note_>
recode q_4_12 (1=1) (2/5=0) (*=.), g(kitchen)
*</_kitchen_>

*<_bath_>
*<_bath_note_> Bathing facility in the dwelling *</_bath_note_>
*<_bath_note_> bath brought in from SARMD *</_bath_note_>
g bath = .
*</_bath_>

*<_rooms_>
*<_rooms_note_> Number of habitable rooms *</_rooms_note_>
*<_rooms_note_> rooms brought in from SARMD *</_rooms_note_>
gen byte rooms=q_4_13
*</_rooms_>

*<_areaspace_>
*<_areaspace_note_> Area *</_areaspace_note_>
*<_areaspace_note_> areaspace brought in from SARMD *</_areaspace_note_>
gen areaspace=.
*</_areaspace_>

*<_ybuilt_>
*<_ybuilt_note_> Year the dwelling built *</_ybuilt_note_>
*<_ybuilt_note_> ybuilt brought in from *</_ybuilt_note_>
gen ybuilt=.
notes ybuilt: Original survey collects year house was constructed in categories. Recorded in ybuilt_orig variable
*</_ybuilt_>

*<_ybuilt_orig_>
*<_ybuilt_note_> Year the dwelling built - from original survey *</_ybuilt_note_>
*<_ybuilt_note_> ybuilt brought in from rawdata *</_ybuilt_note_>
gen ybuilt_orig = q_4_5
notes ybuilt_orig: Original survey collects year constructed in categories
*</_ybuilt_>

*<_ownhouse_>
*<_ownhouse_note_> Ownership of house *</_ownhouse_note_>
*<_ownhouse_note_> ownhouse brought in from SARMD *</_ownhouse_note_>
*ownhouse
*</_ownhouse_>

*<_acqui_house_>
*<_acqui_house_note_> Acquisition of house *</_acqui_house_note_>
*<_acqui_house_note_> acqui_house brought in from SARMD *</_acqui_house_note_>
*ren acqui_house acqui_house_sarmd
recode q_4_6  (1=2) (2=1) (3=3) (4 5 6 7 8 9 .a = .) , gen(acqui_house)
*</_acqui_house_>

*<_dwelownlti_>
*<_dwelownlti_note_> Legal title for Ownership *</_dwelownlti_note_>
*<_dwelownlti_note_> dwelownlti brought in from SARMD *</_dwelownlti_note_>
gen dwelownlti= q_4_9 
recode dwelownlti (2 3 5=0) (4 .a=.)
*</_dwelownlti_>

*<_fem_dwelownlti_>
*<_fem_dwelownlti_note_> Legal title for Ownership - Female *</_fem_dwelownlti_note_>
*<_fem_dwelownlti_note_> fem_dwelownlti brought in from SARMD *</_fem_dwelownlti_note_>
gen fem_dwelownlti=.
*</_fem_dwelownlti_>

*<_dwelownti_>
*<_dwelownti_note_> Type of Legal document *</_dwelownti_note_>
*<_dwelownti_note_> dwelownti brought in from SARMD *</_dwelownti_note_>
gen dwelownti= 1
*</_dwelownti_>

*<_selldwel_>
*<_selldwel_note_> Right to sell dwelling *</_selldwel_note_>
*<_selldwel_note_> selldwel brought in from SARMD *</_selldwel_note_>
gen selldwel=.
*</_selldwel_>

*<_transdwel_>
*<_transdwel_note_> Right to transfer dwelling *</_transdwel_note_>
*<_transdwel_note_> transdwel brought in from SARMD *</_transdwel_note_>
gen transdwel=.
*</_transdwel_>

*<_ownland_>
*<_ownland_note_> Ownership of land *</_ownland_note_>
*<_ownland_note_> ownland brought in from*</_ownland_note_>
gen ownland= .
*</_ownland_>

*<_acqui_land_>
*<_acqui_land_note_> Acquisition of residential land *</_acqui_land_note_>
*<_acqui_land_note_> acqui_land brought in from SARMD *</_acqui_land_note_>
gen acqui_land=.
*</_acqui_land_>

*<_doculand_>
*<_doculand_note_> Legal document for residential land *</_doculand_note_>
*<_doculand_note_> doculand brought in from SARMD *</_doculand_note_>
gen doculand=.
*</_doculand_>

*<_fem_doculand_>
*<_fem_doculand_note_> Legal document for residential land - female *</_fem_doculand_note_>
*<_fem_doculand_note_> fem_doculand brought in from SARMD *</_fem_doculand_note_>
gen fem_doculand=.
*</_fem_doculand_>

*<_landownti_>
*<_landownti_note_> Land Ownership *</_landownti_note_>
*<_landownti_note_> landownti brought in from SARMD *</_landownti_note_>
gen landownti=.
*</_landownti_>

*<_sellland_>
*<_sellland_note_> Right to sell land *</_sellland_note_>
*<_sellland_note_> sellland brought in from SARMD *</_sellland_note_>
gen sellland=.
*</_sellland_>

*<_transland_>
*<_transland_note_> Right to transfer land *</_transland_note_>
*<_transland_note_> transland brought in from SARMD *</_transland_note_>
gen transland=.
*</_transland_>

*<_agriland_>
*<_agriland_note_> Agriculture Land *</_agriland_note_>
*<_agriland_note_> agriland brought in from rawdata *</_agriland_note_>
gen agriland= (q_6_1 == 1 | q_6_28 == 1 | q_6_5 == 1 | q_6_32 == 1) if q_6_1!=. | q_6_28!=. | q_6_5!=. | q_6_32!=.
*</_agriland_>

*<_area_agriland_>
*<_area_agriland_note_> Area of Agriculture land *</_area_agriland_note_>
*<_area_agriland_note_> area_agriland brought in from SARMD *</_area_agriland_note_>
egen area_agriland= rowtotal(q_6_2 q_6_6_a q_6_6_b q_6_6_c q_6_6_d q_6_29), missing
replace area_agriland = area_agriland/5
*</_area_agriland_>

*<_ownagriland_>
*<_ownagriland_note_> Ownership of agriculture land *</_ownagriland_note_>
*<_ownagriland_note_> ownagriland brought in from SARMD *</_ownagriland_note_>
gen ownagriland = (q_6_1 == 1 | q_6_28 == 1) if q_6_1!=. | q_6_28!=.
*</_ownagriland_>

*<_area_ownagriland_>
*<_area_ownagriland_note_> Area of agriculture land owned *</_area_ownagriland_note_>
*<_area_ownagriland_note_> area_ownagriland brought in from SARMD *</_area_ownagriland_note_>
egen area_ownagriland= rowtotal(q_6_2 q_6_29), missing 
replace area_ownagriland = area_ownagriland/5  
*</_area_ownagriland_>

*<_purch_agriland_>
*<_purch_agriland_note_> Purchased agri land *</_purch_agriland_note_>
*<_purch_agriland_note_> purch_agriland brought in from SARMD *</_purch_agriland_note_>
gen purch_agriland=.
*</_purch_agriland_>

*<_areapurch_agriland_>
*<_areapurch_agriland_note_> Area of purchased agriculture land *</_areapurch_agriland_note_>
*<_areapurch_agriland_note_> areapurch_agriland brought in from SARMD *</_areapurch_agriland_note_>
gen areapurch_agriland=.
*</_areapurch_agriland_>

*<_inher_agriland_>
*<_inher_agriland_note_> Inherit agriculture land *</_inher_agriland_note_>
*<_inher_agriland_note_> inher_agriland brought in from SARMD *</_inher_agriland_note_>
gen inher_agriland=.
*</_inher_agriland_>

*<_areainher_agriland_>
*<_areainher_agriland_note_> Area of inherited agriculture land *</_areainher_agriland_note_>
*<_areainher_agriland_note_> areainher_agriland brought in from SARMD *</_areainher_agriland_note_>
gen areainher_agriland=.
*</_areainher_agriland_>

*<_rentout_agriland_>
*<_rentout_agriland_note_> Rent Out Land *</_rentout_agriland_note_>
*<_rentout_agriland_note_> rentout_agriland brought in from SARMD *</_rentout_agriland_note_>
gen rentout_agriland= ( q_6_4_a > 0 | q_6_4_c > 0) if  q_6_4_a != . | q_6_4_c != .
*</_rentout_agriland_>

*<_arearentout_agriland_>
*<_arearentout_agriland_note_> Area of rent out agri land *</_arearentout_agriland_note_>
*<_arearentout_agriland_note_> arearentout_agriland brought in from SARMD *</_arearentout_agriland_note_>
egen arearentout_agriland= rowtotal(q_6_4_a q_6_4_c), missing
replace arearentout_agriland = arearentout_agriland/5
*</_arearentout_agriland_>

*<_rentin_agriland_>
*<_rentin_agriland_note_> Rent in Land *</_rentin_agriland_note_>
*<_rentin_agriland_note_> rentin_agriland brought in from SARMD *</_rentin_agriland_note_>
gen rentin_agriland= ( q_6_6_a > 0 | q_6_6_c > 0) if  q_6_6_a != . | q_6_6_c != .
*</_rentin_agriland_>

*<_arearentin_agriland_>
*<_arearentin_agriland_note_> Area of rent in agri land *</_arearentin_agriland_note_>
*<_arearentin_agriland_note_> arearentin_agriland brought in from SARMD *</_arearentin_agriland_note_>
egen arearentin_agriland= rowtotal(q_6_6_a q_6_6_c), missing
replace arearentin_agriland = arearentin_agriland/5
*</_arearentin_agriland_>

*<_docuagriland_>
*<_docuagriland_note_> Documented Agri Land *</_docuagriland_note_>
*<_docuagriland_note_> docuagriland brought in from SARMD *</_docuagriland_note_>
gen docuagriland=.
*</_docuagriland_>

*<_area_docuagriland_>
*<_area_docuagriland_note_> Area of documented agri land *</_area_docuagriland_note_>
*<_area_docuagriland_note_> area_docuagriland brought in from SARMD *</_area_docuagriland_note_>
gen area_docuagriland=.
*</_area_docuagriland_>

*<_fem_agrilandownti_>
*<_fem_agrilandownti_note_> Ownership Agri Land - Female *</_fem_agrilandownti_note_>
*<_fem_agrilandownti_note_> fem_agrilandownti brought in from SARMD *</_fem_agrilandownti_note_>
gen fem_agrilandownti=.
*</_fem_agrilandownti_>

*<_agrilandownti_>
*<_agrilandownti_note_> Type Agri Land ownership doc *</_agrilandownti_note_>
*<_agrilandownti_note_> agrilandownti brought in from SARMD *</_agrilandownti_note_>
gen agrilandownti=.
*</_agrilandownti_>

*<_sellagriland_>
*<_sellagriland_note_> Right to sell agri land *</_sellagriland_note_>
*<_sellagriland_note_> sellagriland brought in from SARMD *</_sellagriland_note_>
gen sellagriland=.
*</_sellagriland_>

*<_transagriland_>
*<_transagriland_note_> Right to transfer agri land *</_transagriland_note_>
*<_transagriland_note_> transagriland brought in from SARMD *</_transagriland_note_>
gen transagriland=.
*</_transagriland_>

*<_dweltyp_>
*<_dweltyp_note_> Types of Dwelling *</_dweltyp_note_>
*<_dweltyp_note_> dweltyp brought in from SARMD *</_dweltyp_note_>
gen byte dweltyp= q_4_1
	recode dweltyp (1=1) (2=2) (3=3) (4=8) (5=8) (6=9)
*</_dweltyp_>

*<_typlivqrt_>
*<_typlivqrt_note_> Types of living quarters *</_typlivqrt_note_>
*<_typlivqrt_note_> typlivqrt brought in from SARMD *</_typlivqrt_note_>
gen typlivqrt=.
*</_typlivqrt_>

*<_Keep variables_>
duplicates drop hhid, force
*keep countrycode year hhid pid weight weighttype landphone cellphone phone computer etablet internet radio tv tv_cable video fridge sewmach washmach stove ricecook fan ac ewpump bcycle mcycle oxcart boat car canoe roof wall floor kitchen bath rooms areaspace ybuilt ownhouse acqui_house dwelownlti fem_dwelownlti dwelownti selldwel transdwel ownland acqui_land doculand fem_doculand landownti sellland transland agriland area_agriland ownagriland area_ownagriland purch_agriland areapurch_agriland inher_agriland areainher_agriland rentout_agriland arearentout_agriland rentin_agriland arearentin_agriland docuagriland area_docuagriland fem_agrilandownti agrilandownti sellagriland transagriland dweltyp typlivqrt
order countrycode year hhid pid weight weighttype
sort hhid pid 
*</_Keep variables_>
*exit
*<_Save data file_>
if ("`c(username)'"=="sunquat") global rootdofiles "/Users/`c(username)'/Projects/WORLD BANK/2023 SAR QCHECK/SARDATABANK/SARMDdofiles"
quietly do "$rootdofiles/_aux/Labels_GMD2.0.do"
save "$output/`filename'.dta", replace
*</_Save data file_>
