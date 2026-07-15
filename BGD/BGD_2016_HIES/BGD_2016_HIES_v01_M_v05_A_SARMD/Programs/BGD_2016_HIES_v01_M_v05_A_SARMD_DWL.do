/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   BGD_2016_HIES_v01_M_v01_A_GMD_DWL.do	</_Program name_>
<_Application_>    STATA 16.0	<_Application_>
<_Author(s)_>      Navishti Das and Javier Parada	</_Author(s)_>
<_Date created_>   03-03-2019	</_Date created_>
<_Date modified>    3 Mar 2020	</_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        BGD	</_Country_>
<_Survey Title_>   HIES	</_Survey Title_>
<_Survey Year_>    2016	</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:	03-03-2019
File:	BGD_2016_HIES_v01_M_v01_A_GMD_DWL.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Raw data setup_>

datalibweb, country(BGD) year(2016) type(SARRAW) surveyid(BGD_2016_HIES_v01_M) filename(HH_SEC_9E.dta)
 	** ASSESTS (MATERIAL)
	tempfile assets
	drop if s9eq00==.
	gen assets=1 if s9eq01b=="X"
	replace assets=0 if s9eq01a=="X"
	replace assets=1 if s9eq02!=.
	*Some cases of mismatch data (the data doesn't allows us to classify if the person has the asset)
	replace assets=. if s9eq01b=="X" & s9eq01a=="X"  // Mark both Yes and No
	replace assets=. if s9eq01a=="X" & s9eq02!=.	 // Mark No but have number of items
	replace assets=. if assets==1 & s9eq02==.		 // Mark Yes but doesn't have the number
	
	keep psu hhid assets s9eq00
	 	 
	reshape wide assets, i(hhid) j(s9eq00)
	duplicates report hhid
	egen idh=concat(psu hhid), punct(-)
	drop hhid
	save `assets', replace 

datalibweb, country(BGD) year(2016) type(SARRAW) surveyid(BGD_2016_HIES_v01_M) filename(HH_SEC_6A.dta)
 	tempfile housing
	egen idh=concat(psu hhid), punct(-)
	drop hhid
	save `housing'

datalibweb, country(BGD) year(2016) type(SARRAW) surveyid(BGD_2016_HIES_v01_M) filename(HH_SEC_7A.dta)
 	tempfile land
	egen idh=concat(psu hhid), punct(-)
	drop hhid
	save `land'
*</_Raw data setup_>

	
*<_Program setup_>
clear all
set more off

local code         "BGD"
local year         "2016"
local survey       "HIES"
local vm           "01"
local va           "05"
local type         "SARMD"
local yearfolder   "`code'_`year'_`survey'"
local SARMDfolder  "`yearfolder'_v`vm'_M_v`va'_A_SARMD"
local filename     "`yearfolder'_v`vm'_M_v`va'_A_SARMD_DWL"
*</_Program setup_>

*<_Folder creation_>
*</_Folder creation_>

*<_Datalibweb request_>
use "$rootdatalib\\`code'\\`yearfolder'\\`SARMDfolder'\Data\Harmonized\\`yearfolder'_v`vm'_M_v`va'_A_SARMD_IND.dta", clear
*</_Datalibweb request_>

*<_Merge in raw data_>
merge m:1 idh using `assets'
drop _merge
merge m:1 idh using `housing'
drop _merge
merge m:1 idh using `land'
drop _merge
*</_Merge in raw data_>

drop if hhid==.

*<_countrycode_>
*<_countrycode_note_> country code *</_countrycode_note_>
*<_countrycode_note_> countrycode brought in from SARMD *</_countrycode_note_>
*clonevar countrycode = code
*</_countrycode_>

*<_year_>
*<_year_note_> Year *</_year_note_>
*<_year_note_> year brought in from SARMD *</_year_note_>
*year
*</_year_>

*<_hhid_>
*<_hhid_note_> Household identifier  *</_hhid_note_>
*<_hhid_note_> hhid brought in from SARMD *</_hhid_note_>
*clonevar hhid = idh
*</_hhid_>

*<_pid_>
*<_pid_note_> Personal identifier  *</_pid_note_>
*<_pid_note_> pid brought in from SARMD *</_pid_note_>
*clonevar pid  = idp
*</_pid_>

*<_weight_>
*<_weight_note_> Household weight *</_weight_note_>
*<_weight_note_> weight brought in from SARMD *</_weight_note_>
clonevar  weight = wgt
*</_weight_>

*<_weighttype_>
*<_weighttype_note_> Weight type (frequency, probability, analytical, importance) *</_weighttype_note_>
*<_weighttype_note_> weighttype brought in from rawdata *</_weighttype_note_>
*gen weighttype = "PW"
*</_weighttype_>

*<_landphone_>
*<_landphone_note_> Ownership of a land phone *</_landphone_note_>
*<_landphone_note_> landphone brought in from SARMD*</_landphone_note_>
clonevar landphone=lphone 
*</_landphone_>

*<_cellphone_>
*<_cellphone_note_> Ownership of a cell phone *</_cellphone_note_>
*<_cellphone_note_> cellphone brought in from SARMD *</_cellphone_note_>
*cellphone
*</_cellphone_>

*<_phone_>
*<_phone_note_> Ownership of a telephone *</_phone_note_>
*<_phone_note_> phone brought in from *</_phone_note_>
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
gen etablet=.
*</_etablet_>

*<_internet_>
*<_internet_note_> Ownership of a  internet *</_internet_note_>
*<_internet_note_> internet brought in from SARMD *</_internet_note_>
recode internet (0=4) (1=3)
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
*<_tv_cable_note_> tv_cable brought in from rawdata *</_tv_cable_note_>
gen tv_cable= assets584
replace tv_cable = . if tv == 0
*</_tv_cable_>

*<_video_>
*<_video_note_> Ownership of a video *</_video_note_>
*<_video_note_> video brought in from rawdata *</_video_note_>
gen video= assets583
*</_video_>

*<_fridge_>
*<_fridge_note_> Ownership of a refrigerator *</_fridge_note_>
*<_fridge_note_> fridge brought in from SARMD *</_fridge_note_>
clonevar fridge = refrigerator
*</_fridge_>

*<_sewmach_>
*<_sewmach_note_> Ownership of a sewing machine *</_sewmach_note_>
*<_sewmach_note_> sewmach brought in from SARMD *</_sewmach_note_>
clonevar sewmach=sewingmachine 
*</_sewmach_>

*<_washmach_>
*<_washmach_note_> Ownership of a washing machine *</_washmach_note_>
*<_washmach_note_> washmach brought in from SARMD *</_washmach_note_>
clonevar washmach=washingmachine
*</_washmach_>


** STOVE
*<_stove_>
gen byte stove=s6aq06
recode stove (1=0)(2 3 4 5 6 7=1)
*</_stove_>

*<_ricecook_>
*<_ricecook_note_> Ownership of a rice cooker *</_ricecook_note_>
*<_ricecook_note_> ricecook brought in from *</_ricecook_note_>
gen ricecook = .
*</_ricecook_>

*<_fan_>
*<_fan_note_> Ownership of an electric fan *</_fan_note_>
*<_fan_note_> fan brought in from SARMD *</_fan_note_>
*fan
*</_fan_>

*<_ac_>
*<_ac_note_> Ownership of a central or wall air conditioner *</_ac_note_>
*<_ac_note_> ac brought in from *</_ac_note_>
gen ac=. 
*</_ac_>

*<_ewpump_>
*<_ewpump_note_> Ownership of a electric water pump *</_ewpump_note_>
*<_ewpump_note_> ewpump brought in from *</_ewpump_note_>
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
clonevar mcycle = motorcycle
*</_mcycle_>

*<_oxcart_>
*<_oxcart_note_> Ownership of a oxcart *</_oxcart_note_>
*<_oxcart_note_> oxcart brought in from *</_oxcart_note_>
gen oxcart=.
*</_oxcart_>

** BOAT
*<_boat_>
gen byte boat=assets576
*</_boat_>
*<_car_>
*<_car_note_> Ownership of a Car *</_car_note_>
*<_car_note_> car brought in from SARMD *</_car_note_>
clonevar car = motorcar
*</_car_>

*<_canoe_>
*<_canoe_note_> Ownership of a canoes *</_canoe_note_>
*<_canoe_note_> canoe brought in from *</_canoe_note_>
gen canoe=. 
*</_canoe_>

*<_roof_>
*<_roof_note_> Main material used for roof *</_roof_note_>
*<_roof_note_> roof brought in from SARMD *</_roof_note_>
gen byte roof=s6aq08
recode roof (12=1) (31=13) (34=11) (96=15)
recode roof (1=12) (2=31) (3=31) (4=34) (5 6 9=96)
*</_roof_>

** WALL
*<_wall_>
gen byte wall=s6aq07
recode wall (1=12) (2=22) (3=27) (4=36) (5=34) (6 7=96)
recode wall (12=1) (22=5) (27=10) (34=13) (36=15) (96=19)
*</_wall_>

** FLOOR
*<_floor_>
gen byte floor=.
*</_floor_>

** KITCHEN
*<_kitchen_>
gen byte kitchen=s6aq04
recode kitchen (1=1) (0 2 3=0)
*</_kitchen_>

** BATH
*<_bath_>
gen byte bath=s6aq10
recode bath (1 2 3 4 5=1) (6=0) 
*</_bath_>

** ROOMS
*<_rooms_>
gen byte rooms=s6aq02
replace rooms=0 if rooms<0
*</_rooms_>

** AREASPACE
*<_areaspace_>
gen byte areaspace=s6aq09
*</_areaspace_>

*<_ybuilt_>
*<_ybuilt_note_> Year the dwelling built *</_ybuilt_note_>
*<_ybuilt_note_> ybuilt brought in from *</_ybuilt_note_>
gen ybuilt=.
*</_ybuilt_>

*<_ownhouse_>
*<_ownhouse_note_> Ownership of house *</_ownhouse_note_>
*<_ownhouse_note_> ownhouse brought in from rawdata *</_ownhouse_note_>
ren ownhouse ownhouse_sarmd
gen ownhouse = s6aq23
recode ownhouse (5=.)
*</_ownhouse_>

** ACQUI_HOUSE
*<_acqui_house_>
gen byte acqui_house=s6aq23
recode acqui_house (1=1) (2=3) (3 5=4)
*</_acqui_house_>

*<_dwelownlti_>
*<_dwelownlti_note_> Legal title for Ownership *</_dwelownlti_note_>
*<_dwelownlti_note_> dwelownlti brought in from *</_dwelownlti_note_>
gen dwelownlti=.
*</_dwelownlti_>

*<_fem_dwelownlti_>
*<_fem_dwelownlti_note_> Legal title for Ownership - Female *</_fem_dwelownlti_note_>
*<_fem_dwelownlti_note_> fem_dwelownlti brought in from *</_fem_dwelownlti_note_>
gen fem_dwelownlti=.
*</_fem_dwelownlti_>

*<_dwelownti_>
*<_dwelownti_note_> Type of Legal document *</_dwelownti_note_>
*<_dwelownti_note_> dwelownti brought in from *</_dwelownti_note_>
gen dwelownti=.
*</_dwelownti_>

*<_selldwel_>
*<_selldwel_note_> Right to sell dwelling *</_selldwel_note_>
*<_selldwel_note_> selldwel brought in from *</_selldwel_note_>
gen selldwel=.
*</_selldwel_>

*<_transdwel_>
*<_transdwel_note_> Right to transfer dwelling *</_transdwel_note_>
*<_transdwel_note_> transdwel brought in from *</_transdwel_note_>
gen transdwel=.
*</_transdwel_>

*<_ownland_>
*<_ownland_note_> Ownership of land *</_ownland_note_>
*<_ownland_note_> ownland brought in from rawdata *</_ownland_note_>
gen ownland= (s7aq02 > 0) if !missing(s7aq02)
*</_ownland_>

*<_acqui_land_>
*<_acqui_land_note_> Acquisition of residential land *</_acqui_land_note_>
*<_acqui_land_note_> acqui_land brought in from *</_acqui_land_note_>
gen acqui_land=.
*</_acqui_land_>

*<_doculand_>
*<_doculand_note_> Legal document for residential land *</_doculand_note_>
*<_doculand_note_> doculand brought in from *</_doculand_note_>
gen doculand=.
*</_doculand_>

*<_fem_doculand_>
*<_fem_doculand_note_> Legal document for residential land - female *</_fem_doculand_note_>
*<_fem_doculand_note_> fem_doculand brought in from *</_fem_doculand_note_>
gen fem_doculand=.
*</_fem_doculand_>

*<_landownti_>
*<_landownti_note_> Land Ownership *</_landownti_note_>
*<_landownti_note_> landownti brought in from *</_landownti_note_>
gen landownti=.
*</_landownti_>

*<_sellland_>
*<_sellland_note_> Right to sell land *</_sellland_note_>
*<_sellland_note_> sellland brought in from *</_sellland_note_>
gen sellland=.
*</_sellland_>

*<_transland_>
*<_transland_note_> Right to transfer land *</_transland_note_>
*<_transland_note_> transland brought in from *</_transland_note_>
gen transland=.
*</_transland_>

*<_agriland_>
*<_agriland_note_> Agriculture Land *</_agriland_note_>
*<_agriland_note_> agriland brought in from rawdata *</_agriland_note_>
gen agriland= (s7aq01 > 0 | s7aq04 > 0 | s7aq05 > 0 ) if !missing(s7aq01,s7aq04,s7aq05)
*</_agriland_>

*<_area_agriland_>
*<_area_agriland_note_> Area of Agriculture land *</_area_agriland_note_>
*<_area_agriland_note_> area_agriland brought in from rawdata *</_area_agriland_note_>
egen area_agriland_acre = rowtotal(s7aq01 s7aq04 s7aq05) if agriland == 1
gen area_agriland = area_agriland_acre/2.471
drop area_agriland_acre
*</_area_agriland_>

*<_ownagriland_>
*<_ownagriland_note_> Ownership of agriculture land *</_ownagriland_note_>
*<_ownagriland_note_> ownagriland brought in from rawdata *</_ownagriland_note_>
gen ownagriland= (s7aq01 > 0) if !missing(s7aq01)
*</_ownagriland_>

*<_area_ownagriland_>
*<_area_ownagriland_note_> Area of agriculture land owned *</_area_ownagriland_note_>
*<_area_ownagriland_note_> area_ownagriland brought in from rawdata *</_area_ownagriland_note_>
gen area_ownagriland= s7aq01/2.471
*</_area_ownagriland_>

*<_purch_agriland_>
*<_purch_agriland_note_> Purchased agri land *</_purch_agriland_note_>
*<_purch_agriland_note_> purch_agriland brought in from *</_purch_agriland_note_>
gen purch_agriland=.
*</_purch_agriland_>

*<_areapurch_agriland_>
*<_areapurch_agriland_note_> Area of purchased agriculture land *</_areapurch_agriland_note_>
*<_areapurch_agriland_note_> areapurch_agriland brought in from *</_areapurch_agriland_note_>
gen areapurch_agriland=.
*</_areapurch_agriland_>

*<_inher_agriland_>
*<_inher_agriland_note_> Inherit agriculture land *</_inher_agriland_note_>
*<_inher_agriland_note_> inher_agriland brought in from *</_inher_agriland_note_>
gen inher_agriland=.
*</_inher_agriland_>

*<_areainher_agriland_>
*<_areainher_agriland_note_> Area of inherited agriculture land *</_areainher_agriland_note_>
*<_areainher_agriland_note_> areainher_agriland brought in from *</_areainher_agriland_note_>
gen areainher_agriland=.
*</_areainher_agriland_>

*<_rentout_agriland_>
*<_rentout_agriland_note_> Rent Out Land *</_rentout_agriland_note_>
*<_rentout_agriland_note_> rentout_agriland brought in from rawdata *</_rentout_agriland_note_>
gen rentout_agriland= (s7aq05 > 0) if !missing(s7aq05)
*</_rentout_agriland_>

*<_arearentout_agriland_>
*<_arearentout_agriland_note_> Area of rent out agri land *</_arearentout_agriland_note_>
*<_arearentout_agriland_note_> arearentout_agriland brought in from SARMD *</_arearentout_agriland_note_>
gen arearentout_agriland= s7aq05/2.471
*</_arearentout_agriland_>

*<_rentin_agriland_>
*<_rentin_agriland_note_> Rent in Land *</_rentin_agriland_note_>
*<_rentin_agriland_note_> rentin_agriland brought in from rawdata *</_rentin_agriland_note_>
gen rentin_agriland= (s7aq04 > 0) if !missing(s7aq04)
*</_rentin_agriland_>

*<_arearentin_agriland_>
*<_arearentin_agriland_note_> Area of rent in agri land *</_arearentin_agriland_note_>
*<_arearentin_agriland_note_> arearentin_agriland brought in from rawdata *</_arearentin_agriland_note_>
gen arearentin_agriland= s7aq04/2.471
*</_arearentin_agriland_>

*<_docuagriland_>
*<_docuagriland_note_> Documented Agri Land *</_docuagriland_note_>
*<_docuagriland_note_> docuagriland brought in from *</_docuagriland_note_>
gen docuagriland=.
*</_docuagriland_>

*<_area_docuagriland_>
*<_area_docuagriland_note_> Area of documented agri land *</_area_docuagriland_note_>
*<_area_docuagriland_note_> area_docuagriland brought in from *</_area_docuagriland_note_>
gen area_docuagriland=.
*</_area_docuagriland_>

*<_fem_agrilandownti_>
*<_fem_agrilandownti_note_> Ownership Agri Land - Female *</_fem_agrilandownti_note_>
*<_fem_agrilandownti_note_> fem_agrilandownti brought in from *</_fem_agrilandownti_note_>
gen fem_agrilandownti=.
*</_fem_agrilandownti_>

*<_agrilandownti_>
*<_agrilandownti_note_> Type Agri Land ownership doc *</_agrilandownti_note_>
*<_agrilandownti_note_> agrilandownti brought in from *</_agrilandownti_note_>
gen agrilandownti=.
*</_agrilandownti_>

*<_sellagriland_>
*<_sellagriland_note_> Right to sell agri land *</_sellagriland_note_>
*<_sellagriland_note_> sellagriland brought in from *</_sellagriland_note_>
gen sellagriland=.
*</_sellagriland_>

*<_transagriland_>
*<_transagriland_note_> Right to transfer agri land *</_transagriland_note_>
*<_transagriland_note_> transagriland brought in from *</_transagriland_note_>
gen transagriland=.
*</_transagriland_>

*<_dweltyp_>
*<_dweltyp_note_> Types of Dwelling *</_dweltyp_note_>
*<_dweltyp_note_> dweltyp brought in from *</_dweltyp_note_>
gen dweltyp=.
*</_dweltyp_>

*<_typlivqrt_>
*<_typlivqrt_note_> Types of living quarters *</_typlivqrt_note_>
*<_typlivqrt_note_> typlivqrt brought in from *</_typlivqrt_note_>
gen typlivqrt=.
*</_typlivqrt_>

do   "P:\SARMD\SARDATABANK\SARMDdofiles\_aux\Labels_GMD2.0.do"
save "${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\Data\Harmonized\\`filename'.dta" , replace




