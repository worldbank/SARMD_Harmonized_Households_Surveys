/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   PAK_2018_PSLM_v_M_v_A_GMD_DWL.do	</_Program name_>
<_Application_>    STATA 16.0	<_Application_>
<_Author(s)_>      Navishti Das and Javier Parada	</_Author(s)_>
<_Date created_>   03-03-2019	</_Date created_>
<_Date modified>   18 Feb 2021	</_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        PAK	</_Country_>
<_Survey Title_>   PSLM	</_Survey Title_>
<_Survey Year_>    2018	</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:	03-03-2019
File:	PAK_2018_PSLM_v_M_v_A_GMD_DWL.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>
*#delimit 
clear all
set more off

local code         "PAK"
local year         "2018"
local survey       "HIES"
local vm           "01"
local va           "02"
local type         "SARMD"
local yearfolder   "`code'_`year'_`survey'"
local gmdfolder    "`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD"
local filename     "`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD_DWL"
*</_Program setup_>


*<_Raw data_>
tempfile raw1
cap datalibweb, country(`code') year(`year') type(SARRAW) surveyid(`code'_`year'_PSLM_v01_M) filename(sec_9a.dta) 
if _rc!=0 {
	use "$rootdatalib\\`code'\\`code'_`year'_`survey'\\`code'_`year'_`survey'_v`vm'_M\Data\Stata\sec_9a.dta", clear 
}
keep if inlist(code,901,902)
replace s9aq02 = 0 if s9aq01 == 2 & s9aq02 == .
keep hhcode code s9aq02 s9aq2a s9aq04
reshape wide s9aq02 s9aq2a s9aq04, i(hhcode) j(code)
save `raw1'

tempfile raw2
cap datalibweb, country(`code') year(`year') type(SARRAW) surveyid(`code'_`year'_PSLM_v01_M) filename(sec_10a.dta) 
if _rc!=0 {
	use "$rootdatalib\\`code'\\`code'_`year'_`survey'\\`code'_`year'_`survey'_v`vm'_M\Data\Stata\sec_10a.dta", clear 
}
keep if inlist(codes,101,102,103,104,109)
keep hhcode codes s10c1 s10c2 s10c3
reshape wide s10c1 s10c2 s10c3, i(hhcode) j(codes)
drop s10c2101 s10c3101 s10c2102 s10c3102 s10c3103 s10c2103 s10c2104 s10c3104
merge 1:1 hhcode using `raw1'
drop _merge
save `raw2'

tempfile raw3
cap datalibweb, country(`code') year(`year') type(SARRAW) surveyid(`code'_`year'_PSLM_v01_M) filename(sec_5a.dta) 
if _rc!=0 {
	use "$rootdatalib\\`code'\\`code'_`year'_`survey'\\`code'_`year'_`survey'_v`vm'_M\Data\Stata\sec_5a.dta", clear 
}
merge 1:1 hhcode using `raw2'
tostring hhcode, gen(idh)
drop _merge
save `raw3'

tempfile raw4
cap datalibweb, country(`code') year(`year') type(SARRAW) surveyid(`code'_`year'_PSLM_v01_M) filename(sec_7a.dta) 
if _rc!=0 {
	use "$rootdatalib\\`code'\\`code'_`year'_`survey'\\`code'_`year'_`survey'_v`vm'_M\Data\Stata\sec_7a.dta", clear 
}
keep if inlist(code,701,702,704,706,714,711,710,727,728,732)
drop c01 c03
keep hhcode psu code c02
decode code, gen (itc1)
	gen itc11=code
	tostring itc11, replace 
	gen var_="_"
	egen itc2=concat( itc11 var_ itc1 )
	replace itc2=strtoname(itc2)
	replace itc2=substr(itc2, 1,20)
keep hhcode psu itc2 c02
	*ren v1 numdur
	duplicates report hhcode itc2 
	reshape wide c02, i( hhcode ) j( itc2 ) string

merge 1:1 hhcode using `raw3'
*tostring hhcode, gen(idh)
drop _merge
save `raw4'
*</_Raw data_>


*<_Datalibweb request_>
*#delimit cr
cap datalibweb, country(`code') year(`year') type(`type') survey(`survey') vermast(`vm') veralt(`va') mod(IND) clear 
if _rc!=0 {
	use "$rootdatalib\\`code'\\`code'_`year'_`survey'\\`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD\Data\Harmonized\\`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD_IND", clear 
}
*#delimit 
*</_Datalibweb request_>

*#delimit 
*<_Merge_>
merge m:1 idh using `raw4'
drop _merge
*</_Merge_>


*<_countrycode_>
*<_countrycode_note_> country code *</_countrycode_note_>
*<_countrycode_note_> countrycode brought in from SARMD *</_countrycode_note_>
*replace code=countrycode
*</_countrycode_>

*<_year_>
*<_year_note_> Year *</_year_note_>
*<_year_note_> year brought in from SARMD *</_year_note_>
replace year=year
*</_year_>

*<_hhid_>
*<_hhid_note_> Household identifier  *</_hhid_note_>
*<_hhid_note_> hhid brought in from SARMD *</_hhid_note_>
clonevar hhid=idh
*</_hhid_>

*<_pid_>
*<_pid_note_> Personal identifier  *</_pid_note_>
*<_pid_note_> pid brought in from rawdata *</_pid_note_>
clonevar pid  = idp
*</_pid_>

*<_weight_>
*<_weight_note_> Household weight *</_weight_note_>
*<_weight_note_> weight brought in from rawdata *</_weight_note_>
clonevar  weights=wgt
*</_weight_>

*<_weighttype_>
*<_weighttype_note_> Weight type (frequency, probability, analytical, importance) *</_weighttype_note_>
*<_weighttype_note_> weighttype brought in from rawdata *</_weighttype_note_>
gen weighttype = "IW"
*</_weighttype_>

*<_landphone_>
*<_landphone_note_> Ownership of a land phone *</_landphone_note_>
*<_landphone_note_> landphone brought in from SARMD *</_landphone_note_>
*rename landphone landphone
*</_landphone_>

*<_cellphone_>
*<_cellphone_note_> Ownership of a cell phone *</_cellphone_note_>
*<_cellphone_note_> cellphone brought in from SARMD *</_cellphone_note_>
*rename cellphone cellphone
*</_cellphone_>

*<_phone_>
*<_phone_note_> Ownership of a telephone *</_phone_note_>
*<_phone_note_> phone brought in from SARMD *</_phone_note_>
gen phone =.
*</_phone_>

*<_computer_>
*<_computer_note_> Ownership of a computer *</_computer_note_>
*<_computer_note_> computer brought in from SARMD *</_computer_note_>
*rename computer computer
*</_computer_>

*<_etablet_>
*<_etablet_note_> Ownership of a electronic tablet *</_etablet_note_>
*<_etablet_note_> etablet brought in from SARMD *</_etablet_note_>
gen etablet=s5aq30_6a
replace etablet=0 if s5aq30_6a==2
*</_etablet_>

*<_internet_>
*<_internet_note_> Ownership of a  internet *</_internet_note_>
*<_internet_note_> internet brought in from SARMD *</_internet_note_>
*rename internet internet
*</_internet_>

*<_radio_>
*<_radio_note_> Ownership of a radio *</_radio_note_>
*<_radio_note_> radio brought in from SARMD *</_radio_note_>
gen radio =.
replace radio =1 if c02_701_radio>=1
replace radio =0 if c02_701_radio==.
*</_radio_>

*<_tv_>
*<_tv_note_> Ownership of a tv *</_tv_note_>
*<_tv_note_> tv brought in from SARMD *</_tv_note_>
gen tv=.
replace tv =1 if c02_702_televsion>=1
replace tv =0 if c02_702_televsion==.
*</_tv_>

*<_tv_cable_>
*<_tv_cable_note_> Ownership of a cable tv *</_tv_cable_note_>
*<_tv_cable_note_> tv_cable brought in from SARMD *</_tv_cable_note_>
gen tv_cable=.
*</_tv_cable_>

*<_video_>
*<_video_note_> Ownership of a video *</_video_note_>
*<_video_note_> video brought in from SARMD *</_video_note_>
gen video=.
*</_video_>

*<_fridge_>
*<_fridge_note_> Ownership of a refrigerator *</_fridge_note_>
*<_fridge_note_> fridge brought in from SARMD *</_fridge_note_>
gen fridge=.
replace fridge =1 if c02_704_refrigerator>=1
replace fridge =0 if c02_704_refrigerator==.
*</_fridge_>

*<_sewmach_>
*<_sewmach_note_> Ownership of a sewing machine *</_sewmach_note_>
*<_sewmach_note_> sewmach brought in from SARMD *</_sewmach_note_>
gen sewmach=.
replace sewmach =1 if c02_714_sewing_machine>=1
replace sewmach =0 if c02_714_sewing_machine==.
*</_sewmach_>

*<_washmach_>
*<_washmach_note_> Ownership of a washing machine *</_washmach_note_>
*<_washmach_note_> washmach brought in from SARMD *</_washmach_note_>
gen washmach=.
replace washmach =1 if c02_706_washing>=1
replace washmach =0 if c02_706_washing==.
*</_washmach_>

*<_stove_>
*<_stove_note_> Ownership of a stove *</_stove_note_>
*<_stove_note_> stove brought in from SARMD *</_stove_note_>
gen stove=.
replace stove =1 if c02_711_stove>=1
replace stove =0 if c02_711_stove==.
*</_stove_>

*<_ricecook_>
*<_ricecook_note_> Ownership of a rice cooker *</_ricecook_note_>
*<_ricecook_note_> ricecook brought in from SARMD *</_ricecook_note_>
gen ricecook=.
*</_ricecook_>

*<_fan_>
*<_fan_note_> Ownership of an electric fan *</_fan_note_>
*<_fan_note_> fan brought in from SARMD *</_fan_note_>
gen fan=.
replace fan =1 if c02_710_fan>=1
replace fan =0 if c02_710_fan==.
*</_fan_>

*<_ac_>
*<_ac_note_> Ownership of a central or wall air conditioner *</_ac_note_>
*<_ac_note_> ac brought in from SARMD *</_ac_note_>
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
gen bcycle=.
replace bcycle =1 if c02_727_bi_cycle>=1
replace bcycle =0 if c02_727_bi_cycle==.
*</_bcycle_>

*<_mcycle_>
*<_mcycle_note_> Ownership of a motorcycle *</_mcycle_note_>
*<_mcycle_note_> mcycle brought in from SARMD *</_mcycle_note_>
gen mcycle=.
replace mcycle =1 if c02_728_motor_cycle__sc>=1
replace mcycle =0 if c02_728_motor_cycle__sc==.
*</_mcycle_>

*<_oxcart_>
*<_oxcart_note_> Ownership of a oxcart *</_oxcart_note_>
*<_oxcart_note_> oxcart brought in from SARMD *</_oxcart_note_>
gen oxcart =. 
*</_oxcart_>

*<_boat_>
*<_boat_note_> Ownership of a boat *</_boat_note_>
*<_boat_note_> boat brought in from SARMD *</_boat_note_>
gen boat =.
replace boat =1 if c02_732_boat>=1
replace boat =0 if c02_732_boat==.
*</_boat_>

*<_car_>
*<_car_note_> Ownership of a Car *</_car_note_>
*<_car_note_> car brought in from SARMD *</_car_note_>
gen car=.
*</_car_>

*<_canoe_>
*<_canoe_note_> Ownership of a canoes *</_canoe_note_>
*<_canoe_note_> canoe brought in from SARMD *</_canoe_note_>
gen canoe=.
*</_canoe_>

*<_roof_>
*<_roof_note_> Main material used for roof *</_roof_note_>
*<_roof_note_> roof brought in from SARMD *</_roof_note_>
gen roof=.
*1 = Natural – Thatch/palm leaf
*2 = Natural – Sod
*3 = Natural – Other
*4 = Rudimentary – Rustic mat
*5 = Rudimentary – Palm/bamboo
*6 = Rudimentary – Wood planks
*7 = Rudimentary – Other
*8 = Finished – Wood
*9 = Finished – Asbestos
*10 = Finished – Tile
*11 = Finished – Concrete
*12 = Finished – Metal
*13 = Finished – Roofing shingles
*14 = Finished – Other
*15 = Other
**** Survey values
*1. RCC/RBC (Reinforcement with concrete & Cement, Reinforcement with Bricks & Cement), 
*2. Wood/Bamboo, 3. Sheet/cement/iron, 4. Grader/T iron, 5.others (specify).
replace roof=14 if s5aq06==1
replace roof=7 if s5aq06==2
replace roof=14 if s5aq06==3
replace roof=14 if s5aq06==4
replace roof=15 if s5aq06==5
*</_roof_>

*<_wall_>
*<_wall_note_> Main material used for external walls *</_wall_note_>
*<_wall_note_> wall brought in from SARMD *</_wall_note_>
gen wall=.
*1 = Natural – Cane/palm/trunks
*2 = Natural – Dirt
*3 = Natural – Other
*4 = Rudimentary – Bamboo with mud
*5 = Rudimentary – Stone with mud
*6 = Rudimentary – Uncovered adobe
*7 = Rudimentary – Plywood
*8 = Rudimentary – Cardboard
*9 = Rudimentary – Reused wood
*10 = Rudimentary – Other
*11 = Finished – Woven Bamboo
*12 = Finished – Stone with lime/cement
*13 = Finished – Cement blocks
*14 = Finished – Covered adobe
*15 = Finished – Wood planks/shingles
*16 = Finished – Plaster wire
*17 = Finished – GRC/Gypsum/Asbestos
*18 = Finished – Other
*19 = Other
**** Survey values
*1. Burnt Bricks/Blocks, 2.Mud Bricks/Mud, 3.Wood/Bamboo, 
*4. Ply wood or Card Board, 5 .Stones, 6.Others(Specify…….) .
replace wall=18 if s5aq07==1
replace wall=10 if s5aq07==2
replace wall=11 if s5aq07==3
replace wall=10 if s5aq07==4
replace wall=12 if s5aq07==5
replace wall=19 if s5aq07==6
*</_wall_>

*<_floor_>
*<_floor_note_> Main material used for floor *</_floor_note_>
*<_floor_note_> floor brought in from SARMD *</_floor_note_>
*1 = Natural – Earth/sand;
*2 = Natural – Dung;
*3 = Natural – Other
*4 = Rudimentary – Wood planks
*5 = Rudimentary – Palm/bamboo
*6 = Rudimentary – Other
*7 = Finished – Parquet or polished wood
*8 = Finished – Vinyl or asphalt strips
*9 = Finished – Ceramic/marble/granite
*10 = Finished – Floor tiles/terrazzo
*11 = Finished – Cement/red bricks
*12 = Finished – Carpet
*13 = Finished – Other
*14 = Other
*---- 
*s5aq05
*1. Earth/Sand, 2. Dung, 3. Ceramic tiles/Marbles, 4. Parquets/Polished Wood
*5. Cement/ Cement Tiles, 6. Bricks, 7. Others (Specify.....)

gen floor=.
replace floor=1 if s5aq05==1
replace floor=2 if s5aq05==2
replace floor=9 if s5aq05==3
replace floor=10 if s5aq05==4
replace floor=11 if s5aq05==5
replace floor=11 if s5aq05==6
replace floor=14 if s5aq05==7

*</_floor_>
*<_kitchen_>
*<_kitchen_note_> Separate kitchen in the dwelling *</_kitchen_note_>
*<_kitchen_note_> kitchen brought in from SARMD *</_kitchen_note_>
gen kitchen=.
*</_kitchen_>

*<_bath_>
*<_bath_note_> Bathing facility in the dwelling *</_bath_note_>
*<_bath_note_> bath brought in from SARMD *</_bath_note_>
gen bath=.
*</_bath_>

*<_rooms_>
*<_rooms_note_> Number of habitable rooms *</_rooms_note_>
*<_rooms_note_> rooms brought in from SARMD *</_rooms_note_>
gen rooms=s5aq04
*</_rooms_>

*<_areaspace_>
*<_areaspace_note_> Area *</_areaspace_note_>
*<_areaspace_note_> areaspace brought in from SARMD *</_areaspace_note_>
gen areaspace=.
*</_areaspace_>

*<_ybuilt_>
*<_ybuilt_note_> Year the dwelling built *</_ybuilt_note_>
*<_ybuilt_note_> ybuilt brought in from SARMD *</_ybuilt_note_>
gen ybuilt=.
*</_ybuilt_>

*<_ownhouse_>
*<_ownhouse_note_> Ownership of house *</_ownhouse_note_>
*<_ownhouse_note_> ownhouse brought in from SARMD *</_ownhouse_note_>
drop ownhouse
gen ownhouse=s5aq01
recode ownhouse (1 2=1) (3 4=2) (5=3)
*</_ownhouse_>

*<_acqui_house_>
*<_acqui_house_note_> Acquisition of house *</_acqui_house_note_>
*<_acqui_house_note_> acqui_house brought in from SARMD *</_acqui_house_note_>
gen acqui_house=.
*</_acqui_house_>

*<_dwelownlti_>
*<_dwelownlti_note_> Legal title for Ownership *</_dwelownlti_note_>
*<_dwelownlti_note_> dwelownlti brought in from SARMD *</_dwelownlti_note_>
gen dwelownlti=.
*</_dwelownlti_>

*<_fem_dwelownlti_>
*<_fem_dwelownlti_note_> Legal title for Ownership - Female *</_fem_dwelownlti_note_>
*<_fem_dwelownlti_note_> fem_dwelownlti brought in from SARMD *</_fem_dwelownlti_note_>
gen fem_dwelownlti=.
*</_fem_dwelownlti_>

*<_dwelownti_>
*<_dwelownti_note_> Type of Legal document *</_dwelownti_note_>
*<_dwelownti_note_> dwelownti brought in from SARMD *</_dwelownti_note_>
gen dwelownti=.
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
*<_ownland_note_> ownland brought in from SARMD *</_ownland_note_>
gen ownland=(s9aq02902==1) if !missing(s9aq02902)
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
*<_agriland_note_> agriland brought in from SARMD *</_agriland_note_>
gen agriland=.
*</_agriland_>

*<_area_agriland_>
*<_area_agriland_note_> Area of Agriculture land *</_area_agriland_note_>
*<_area_agriland_note_> area_agriland brought in from SARMD *</_area_agriland_note_>
gen area_agriland=.
*</_area_agriland_>

*<_ownagriland_>
*<_ownagriland_note_> Ownership of agriculture land *</_ownagriland_note_>
*<_ownagriland_note_> ownagriland brought in from SARMD *</_ownagriland_note_>
recode s10c1101 (2=0), gen(ownagriland)
*</_ownagriland_>

*<_area_ownagriland_>
*<_area_ownagriland_note_> Area of agriculture land owned *</_area_ownagriland_note_>
*<_area_ownagriland_note_> area_ownagriland brought in from SARMD *</_area_ownagriland_note_>
gen area_ownagriland=.
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
gen rentout_agriland=s10c1103
replace rentout_agriland=0 if rentout_agriland==2
*</_rentout_agriland_>

*<_arearentout_agriland_>
*<_arearentout_agriland_note_> Area of rent out agri land *</_arearentout_agriland_note_>
*<_arearentout_agriland_note_> arearentout_agriland brought in from SARMD *</_arearentout_agriland_note_>
gen arearentout_agriland=.
*</_arearentout_agriland_>

*<_rentin_agriland_>
*<_rentin_agriland_note_> Rent in Land *</_rentin_agriland_note_>
*<_rentin_agriland_note_> rentin_agriland brought in from SARMD *</_rentin_agriland_note_>
gen rentin_agriland=.
*</_rentin_agriland_>

*<_arearentin_agriland_>
*<_arearentin_agriland_note_> Area of rent in agri land *</_arearentin_agriland_note_>
*<_arearentin_agriland_note_> arearentin_agriland brought in from SARMD *</_arearentin_agriland_note_>
egen arearentin_agriland=rowtotal(s10c2109 s10c3109 ), missing
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
gen dweltyp=s5aq03
recode dweltyp (2=3) (3=4) (4=7)(5=9)
*</_dweltyp_>

*<_typlivqrt_>
*<_typlivqrt_note_> Types of living quarters *</_typlivqrt_note_>
*<_typlivqrt_note_> typlivqrt brought in from SARMD *</_typlivqrt_note_>
gen typlivqrt=.
*</_typlivqrt_>

*<_Keep variables_>
*keep countrycode year hhid pid weight weighttype landphone cellphone phone computer etablet internet radio tv tv_cable video fridge sewmach washmach stove ricecook fan ac ewpump bcycle mcycle oxcart boat car canoe roof wall floor kitchen bath rooms areaspace ybuilt ownhouse acqui_house dwelownlti fem_dwelownlti dwelownti selldwel transdwel ownland acqui_land doculand fem_doculand landownti sellland transland agriland area_agriland ownagriland area_ownagriland purch_agriland areapurch_agriland inher_agriland areainher_agriland rentout_agriland arearentout_agriland rentin_agriland arearentin_agriland docuagriland area_docuagriland fem_agrilandownti agrilandownti sellagriland transagriland dweltyp typlivqrt
order countrycode year hhid pid weights weighttype
sort hhid pid 
*</_Keep variables_>

*<_Save data file_>
include "${rootdatalib}\_aux\GMD2.0labels.do"
save "$rootdatalib\\`code'\\`yearfolder'\\`gmdfolder'\Data\Harmonized\\`filename'.dta" , replace
*save "$rootdatalib\GMD\\`code'\\`yearfolder'\\`gmdfolder'\Data\Harmonized\\`filename'.dta" , replace
*</_Save data file_>
