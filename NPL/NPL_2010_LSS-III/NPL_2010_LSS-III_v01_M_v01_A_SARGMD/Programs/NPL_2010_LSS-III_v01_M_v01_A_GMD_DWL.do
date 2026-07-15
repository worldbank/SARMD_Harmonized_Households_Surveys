/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   NPL_2010_LSS-III_v01_M_v01_A_GMD_DWL.do	</_Program name_>
<_Application_>    STATA 16.0	<_Application_>
<_Author(s)_>      Navishti Das and Javier Parada	</_Author(s)_>
<_Date created_>   03-03-2019	</_Date created_>
<_Date modified>    3 Mar 2020	</_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        NPL	</_Country_>
<_Survey Title_>   LSS-III	</_Survey Title_>
<_Survey Year_>    2010	</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:	03-03-2019
File:	NPL_2010_LSS-III_v01_M_v01_A_GMD_DWL.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Raw data_>;

tempfile raw1
datalibweb, country(NPL) year(2010) type(SARRAW) surveyid(NPL_2010_LSS-III_v01_M) filename(S06C.dta) clear
keep if inlist(v06c_idc, 501,503,504,505,506,507,508,512,513)
keep xhpsu xhnum v06c_idc v06_05
reshape wide v06_05, i(xhpsu xhnum) j(v06c_idc)
save `raw1'

tempfile raw2
datalibweb, country(NPL) year(2010) type(SARRAW) surveyid(NPL_2010_LSS-III_v01_M) filename(S06B.dta) clear
keep if inlist(v06b_idc, 314,317)
keep xhpsu xhnum v06b_idc v06_04
reshape wide v06_04, i(xhpsu xhnum) j(v06b_idc)
merge 1:1 xhpsu xhnum using `raw1'
drop _merge
save `raw2'

tempfile raw3
datalibweb, country(NPL) year(2010) type(SARRAW) surveyid(NPL_2010_LSS-III_v01_M) filename(S06A.dta) clear
keep if inlist(v06a_idc,211,212,213,214,232)
keep xhpsu xhnum v06a_idc v06_02b 
reshape wide v06_02b, i(xhpsu xhnum) j(v06a_idc)
merge 1:1 xhpsu xhnum using `raw2'
drop _merge
save `raw3'

tempfile raw4
datalibweb, country(NPL) year(2010) type(SARRAW) surveyid(NPL_2010_LSS-III_v01_M) filename(S13F.dta) clear
keep if v13f_ec == 6
keep xhpsu xhnum v13f_ec v13_75yn
reshape wide v13_75yn, i(xhpsu xhnum) j(v13f_ec)
merge 1:1 xhpsu xhnum using `raw3'
drop _merge
save `raw4'

tempfile raw5
datalibweb, country(NPL) year(2010) type(SARRAW) surveyid(NPL_2010_LSS-III_v01_M) filename(S13A1.dta) clear

gen agriland_orig = 1

* Variables for each area unit type converted to sq metres
gen rbsqmt =.
gen aksqmt =.
gen pdsqmt =.

* For bigha
replace rbsqmt = v13_04rb*6772.41 if v13_04u == 2
replace aksqmt = (v13_04ak/20)*6772.41 if v13_04u == 2
replace pdsqmt = ((v13_04pd/20)/20)*6772.41 if v13_04u == 2

* For ropani
replace rbsqmt = v13_04rb*508.74 if v13_04u == 1
replace aksqmt = (v13_04ak/16)*508.74 if v13_04u == 1
replace pdsqmt = ((v13_04pd/4)/16)*508.74 if v13_04u == 1

*Total area in sq metres
egen tsqmt = rowtotal(rbsqmt aksqmt pdsqmt), missing

*Total area in hectares
gen area_hectares = tsqmt/10000

*Rent out indicator
gen rentout = (v13_14 == 2 | v13_14 == 3 | v13_14 == 4 | v13_11 == 2 | v13_11 == 3 | v13_11 == 4 ) if v13_14 != . | v13_11 != .

bysort xhpsu xhnum: egen area_owned = total(area_hectares)
bysort xhpsu xhnum: egen area_rentout = total(area_hectares) if rentout == 1
gen n = _n
bysort xhpsu xhnum: mipolate area_rentout n ,groupwise gen(arrentout)

duplicates drop xhpsu xhnum, force

keep xhpsu xhnum arrentout area_owned

merge 1:1 xhpsu xhnum using `raw4'
drop _merge
save `raw5'

tempfile raw6
datalibweb, country(NPL) year(2010) type(SARRAW) surveyid(NPL_2010_LSS-III_v01_M) filename(S13A2.dta) clear

gen agriland_orig = 1

* Variables for each area unit type converted to sq metres
gen rbsqmt =.
gen aksqmt =.
gen pdsqmt =.

* For bigha
replace rbsqmt = v13_22rb*6772.41 if v13_22u == 2
replace aksqmt = (v13_22ak/20)*6772.41 if v13_22u == 2
replace pdsqmt = ((v13_22pd/20)/20)*6772.41 if v13_22u == 2

* For ropani
replace rbsqmt = v13_22rb*508.74 if v13_22u == 1
replace aksqmt = (v13_22ak/16)*508.74 if v13_22u == 1
replace pdsqmt = ((v13_22pd/4)/16)*508.74 if v13_22u == 1

*Total area in sq metres
egen tsqmt = rowtotal(rbsqmt aksqmt pdsqmt), missing

*Total area in hectares
gen area_hectares = tsqmt/10000

bysort xhpsu xhnum: egen arrentin = total(area_hectares)

keep xhpsu xhnum arrentin
duplicates drop xhpsu xhnum, force

merge 1:1 xhpsu xhnum using `raw5'
drop _merge
save `raw6'


tempfile raw7
datalibweb, country(NPL) year(2010) type(SARRAW) surveyid(NPL_2010_LSS-III_v01_M) filename(S02.dta) clear
merge 1:1 xhpsu xhnum using `raw6'
drop _merge
tostring xhpsu xhnum, replace
egen idh = concat(xhpsu xhnum), punct("-")
save `raw7'
*<_Raw data_>;


*<_Program setup_>;
#delimit ;
clear all;
set more off;

local code         "NPL";
local year         "2010";
local survey       "LSS-III";
local vm           "01";
local va           "04";
local type         "SARMD";
local yearfolder   "NPL_2010_LSS-III";
local gmdfolder    "NPL_2010_LSS-III_v01_M_v01_A_GMD";
local filename     "NPL_2010_LSS-III_v01_M_v01_A_GMD_DWL";
*</_Program setup_>;

*<_Folder creation_>;
cap mkdir "$rootdatalib\GMD";
cap mkdir "$rootdatalib\GMD\\`code'";
cap mkdir "$rootdatalib\GMD\\`code'\\`yearfolder'";
cap mkdir "$rootdatalib\GMD\\`code'\\`yearfolder'\\`gmdfolder'";
cap mkdir "$rootdatalib\GMD\\`code'\\`yearfolder'\\`gmdfolder'\Data";
cap mkdir "$rootdatalib\GMD\\`code'\\`yearfolder'\\`gmdfolder'\Data\Harmonized";
*</_Folder creation_>;

*<_Datalibweb request_>;
#delimit cr
datalibweb, country(`code') year(`year') type(`type') survey(`survey') vermast(`vm') veralt(`va') mod(IND) clear 
#delimit ;
*</_Datalibweb request_>;

*<_Merge_>;
merge m:1 idh using `raw7';
drop _merge;
*</_Merge_>;

*<_countrycode_>;
*<_countrycode_note_> country code *</_countrycode_note_>;
*<_countrycode_note_> countrycode brought in from SARMD *</_countrycode_note_>;
*countrycode;
*</_countrycode_>;

*<_year_>;
*<_year_note_> Year *</_year_note_>;
*<_year_note_> year brought in from SARMD *</_year_note_>;
*year;
*</_year_>;

*<_hhid_>;
*<_hhid_note_> Household identifier  *</_hhid_note_>;
*<_hhid_note_> hhid brought in from SARMD *</_hhid_note_>;
clonevar hhid = idh;
*</_hhid_>;

*<_pid_>;
*<_pid_note_> Personal identifier  *</_pid_note_>;
*<_pid_note_> pid brought in from rawdata *</_pid_note_>;
clonevar pid  = idp;
*</_pid_>;

*<_weight_>;
*<_weight_note_> Household weight *</_weight_note_>;
*<_weight_note_> weight brought in from rawdata *</_weight_note_>;
clonevar  weight = wgt;
*</_weight_>;

*<_weighttype_>;
*<_weighttype_note_> Weight type (frequency, probability, analytical, importance) *</_weighttype_note_>;
*<_weighttype_note_> weighttype brought in from rawdata *</_weighttype_note_>;
gen weighttype = "PW";
*</_weighttype_>;

*<_landphone_>;
*<_landphone_note_> Ownership of a land phone *</_landphone_note_>;
*<_landphone_note_> landphone brought in from SARMD *</_landphone_note_>;
*landphone;
*</_landphone_>;

*<_cellphone_>;
*<_cellphone_note_> Ownership of a cell phone *</_cellphone_note_>;
*<_cellphone_note_> cellphone brought in from SARMD *</_cellphone_note_>;
*cellphone;
*</_cellphone_>;

*<_phone_>;
*<_phone_note_> Ownership of a telephone *</_phone_note_>;
*<_phone_note_> phone brought in from SARMD *</_phone_note_>;
gen phone=.;
*</_phone_>;

*<_computer_>;
*<_computer_note_> Ownership of a computer *</_computer_note_>;
*<_computer_note_> computer brought in from SARMD *</_computer_note_>;
*computer;
*</_computer_>;

*<_etablet_>;
*<_etablet_note_> Ownership of a electronic tablet *</_etablet_note_>;
*<_etablet_note_> etablet brought in from SARMD *</_etablet_note_>;
gen etablet=.;
*</_etablet_>;

*<_internet_>;
*<_internet_note_> Ownership of a  internet *</_internet_note_>;
*<_internet_note_> internet brought in from SARMD *</_internet_note_>;
recode internet (0=4) (1=3);
*</_internet_>;

*<_radio_>;
*<_radio_note_> Ownership of a radio *</_radio_note_>;
*<_radio_note_> radio brought in from SARMD *</_radio_note_>;
*radio;
*</_radio_>;

*<_tv_>;
*<_tv_note_> Ownership of a tv *</_tv_note_>;
*<_tv_note_> tv brought in from SARMD *</_tv_note_>;
clonevar tv = television;
*</_tv_>;

*<_tv_cable_>;
*<_tv_cable_note_> Ownership of a cable tv *</_tv_cable_note_>;
*<_tv_cable_note_> tv_cable brought in from rawdata *</_tv_cable_note_>;
gen tv_cable= v02_31c;
recode tv_cable (2=0);
*</_tv_cable_>;

*<_video_>;
*<_video_note_> Ownership of a video *</_video_note_>;
*<_video_note_> video brought in from SARMD *</_video_note_>;
gen video=.;
notes video: Survey combines VCR question with TV, thus blank;
*</_video_>;

*<_fridge_>;
*<_fridge_note_> Ownership of a refrigerator *</_fridge_note_>;
*<_fridge_note_> fridge brought in from SARMD *</_fridge_note_>;
clonevar fridge = refrigerator;
*</_fridge_>;

*<_sewmach_>;
*<_sewmach_note_> Ownership of a sewing machine *</_sewmach_note_>;
*<_sewmach_note_> sewmach brought in from SARMD *</_sewmach_note_>;
clonevar sewmach=sewingmachine; 
*</_sewmach_>;

*<_washmach_>;
*<_washmach_note_> Ownership of a washing machine *</_washmach_note_>;
*<_washmach_note_> washmach brought in from SARMD *</_washmach_note_>;
clonevar washmach=washingmachine; 
*</_washmach_>;

*<_stove_>;
*<_stove_note_> Ownership of a stove *</_stove_note_>;
*<_stove_note_> stove brought in from SARMD *</_stove_note_>;
gen stove=. ;
*</_stove_>;

*<_ricecook_>;
*<_ricecook_note_> Ownership of a rice cooker *</_ricecook_note_>;
*<_ricecook_note_> ricecook brought in from SARMD *</_ricecook_note_>;
gen ricecook = .;
*</_ricecook_>;

*<_fan_>;
*<_fan_note_> Ownership of an electric fan *</_fan_note_>;
*<_fan_note_> fan brought in from SARMD *</_fan_note_>;
*fan;
*</_fan_>;

*<_ac_>;
*<_ac_note_> Ownership of a central or wall air conditioner *</_ac_note_>;
*<_ac_note_> ac brought in from SARMD *</_ac_note_>;
gen ac=. ;
*</_ac_>;

*<_ewpump_>;
*<_ewpump_note_> Ownership of a electric water pump *</_ewpump_note_>;
*<_ewpump_note_> ewpump brought in from rawdata *</_ewpump_note_>;
gen ewpump= v13_75yn6;
recode ewpump (2=0);
*</_ewpump_>;

*<_bcycle_>;
*<_bcycle_note_> Ownership of a bicycle *</_bcycle_note_>;
*<_bcycle_note_> bcycle brought in from SARMD *</_bcycle_note_>;
clonevar bcycle = bicycle;
*</_bcycle_>;

*<_mcycle_>;
*<_mcycle_note_> Ownership of a motorcycle *</_mcycle_note_>;
*<_mcycle_note_> mcycle brought in from SARMD *</_mcycle_note_>;
clonevar mcycle = motorcycle;
*</_mcycle_>;

*<_oxcart_>;
*<_oxcart_note_> Ownership of a oxcart *</_oxcart_note_>;
*<_oxcart_note_> oxcart brought in from SARMD *</_oxcart_note_>;
gen oxcart=.;
*</_oxcart_>;

*<_boat_>;
*<_boat_note_> Ownership of a boat *</_boat_note_>;
*<_boat_note_> boat brought in from SARMD *</_boat_note_>;
gen boat=. ;
*</_boat_>;

*<_car_>;
*<_car_note_> Ownership of a Car *</_car_note_>;
*<_car_note_> car brought in from SARMD *</_car_note_>;
clonevar car = motorcar;
*</_car_>;

*<_canoe_>;
*<_canoe_note_> Ownership of a canoes *</_canoe_note_>;
*<_canoe_note_> canoe brought in from SARMD *</_canoe_note_>;
gen canoe=. ;
*</_canoe_>;

*<_roof_>;
*<_roof_note_> Main material used for roof *</_roof_note_>;
*<_roof_note_> roof brought in from rawdata *</_roof_note_>;
gen roof= v02_06;
recode roof (2=3) (3=6) (4=12) (5=11) (6=10) (7=15);
*</_roof_>;

*<_wall_>;
*<_wall_note_> Main material used for external walls *</_wall_note_>;
*<_wall_note_> wall brought in from rawdata *</_wall_note_>;
gen wall= v02_04 ;
recode wall (1=12) (2=5) (3=15) (5=10) (6 7=19);
*</_wall_>;

*<_floor_>;
*<_floor_note_> Main material used for floor *</_floor_note_>;
*<_floor_note_> floor brought in from SARMD *</_floor_note_>;
gen floor=.;
*</_floor_>;

*<_kitchen_>;
*<_kitchen_note_> Separate kitchen in the dwelling *</_kitchen_note_>;
*<_kitchen_note_> kitchen brought in from rawdata *</_kitchen_note_>;
gen kitchen= (v02_02b > 0) if !missing(v02_02b);
*</_kitchen_>;

*<_bath_>;
*<_bath_note_> Bathing facility in the dwelling *</_bath_note_>;
*<_bath_note_> bath brought in from SARMD *</_bath_note_>;
gen bath=.;
*</_bath_>;

*<_rooms_>;
*<_rooms_note_> Number of habitable rooms *</_rooms_note_>;
*<_rooms_note_> rooms brought in from rawdata *</_rooms_note_>;
egen rooms= rowtotal(v02_02d v02_02e v02_02g v02_02h), missing;
*</_rooms_>;

*<_areaspace_>;
*<_areaspace_note_> Area *</_areaspace_note_>;
*<_areaspace_note_> areaspace brought in from rawdata*</_areaspace_note_>;
gen areaspace= v02_09/10.764 ;
*</_areaspace_>;

*<_ybuilt_>;
*<_ybuilt_note_> Year the dwelling built *</_ybuilt_note_>;
*<_ybuilt_note_> ybuilt brought in from rawdata *</_ybuilt_note_>;
gen ybuilt= v02_10;
*</_ybuilt_>;

*<_ownhouse_>;
*<_ownhouse_note_> Ownership of house *</_ownhouse_note_>;
*<_ownhouse_note_> ownhouse brought in from SARMD *</_ownhouse_note_>;
ren ownhouse ownhouse_sarmd;
recode v02_16 (1=2) (2=3) (3=4), gen(ownhouse);
replace ownhouse = 1 if v02_11 == 1;
*</_ownhouse_>;

*<_acqui_house_>;
*<_acqui_house_note_> Acquisition of house *</_acqui_house_note_>;
*<_acqui_house_note_> acqui_house brought in from SARMD *</_acqui_house_note_>;
gen acqui_house=.;
*</_acqui_house_>;

*<_dwelownlti_>;
*<_dwelownlti_note_> Legal title for Ownership *</_dwelownlti_note_>;
*<_dwelownlti_note_> dwelownlti brought in from SARMD *</_dwelownlti_note_>;
gen dwelownlti=.;
*</_dwelownlti_>;

*<_fem_dwelownlti_>;
*<_fem_dwelownlti_note_> Legal title for Ownership - Female *</_fem_dwelownlti_note_>;
*<_fem_dwelownlti_note_> fem_dwelownlti brought in from SARMD *</_fem_dwelownlti_note_>;
gen fem_dwelownlti=.;
*</_fem_dwelownlti_>;

*<_dwelownti_>;
*<_dwelownti_note_> Type of Legal document *</_dwelownti_note_>;
*<_dwelownti_note_> dwelownti brought in from SARMD *</_dwelownti_note_>;
gen dwelownti=.;
*</_dwelownti_>;

*<_selldwel_>;
*<_selldwel_note_> Right to sell dwelling *</_selldwel_note_>;
*<_selldwel_note_> selldwel brought in from SARMD *</_selldwel_note_>;
gen selldwel=.;
*</_selldwel_>;

*<_transdwel_>;
*<_transdwel_note_> Right to transfer dwelling *</_transdwel_note_>;
*<_transdwel_note_> transdwel brought in from SARMD *</_transdwel_note_>;
gen transdwel=.;
*</_transdwel_>;

*<_ownland_>;
*<_ownland_note_> Ownership of land *</_ownland_note_>;
*<_ownland_note_> ownland brought in from SARMD *</_ownland_note_>;
gen ownland=.;
*</_ownland_>;

*<_acqui_land_>;
*<_acqui_land_note_> Acquisition of residential land *</_acqui_land_note_>;
*<_acqui_land_note_> acqui_land brought in from SARMD *</_acqui_land_note_>;
gen acqui_land=.;
*</_acqui_land_>;

*<_doculand_>;
*<_doculand_note_> Legal document for residential land *</_doculand_note_>;
*<_doculand_note_> doculand brought in from SARMD *</_doculand_note_>;
gen doculand=.;
*</_doculand_>;

*<_fem_doculand_>;
*<_fem_doculand_note_> Legal document for residential land - female *</_fem_doculand_note_>;
*<_fem_doculand_note_> fem_doculand brought in from SARMD *</_fem_doculand_note_>;
gen fem_doculand=.;
*</_fem_doculand_>;

*<_landownti_>;
*<_landownti_note_> Land Ownership *</_landownti_note_>;
*<_landownti_note_> landownti brought in from SARMD *</_landownti_note_>;
gen landownti=.;
*</_landownti_>;

*<_sellland_>;
*<_sellland_note_> Right to sell land *</_sellland_note_>;
*<_sellland_note_> sellland brought in from SARMD *</_sellland_note_>;
gen sellland=.;
*</_sellland_>;

*<_transland_>;
*<_transland_note_> Right to transfer land *</_transland_note_>;
*<_transland_note_> transland brought in from SARMD *</_transland_note_>;
gen transland=.;
*</_transland_>;

*<_agriland_>;
*<_agriland_note_> Agriculture Land *</_agriland_note_>;
*<_agriland_note_> agriland brought in from rawdata*</_agriland_note_>;
gen agriland= (area_owned != . | arrentin != .);
*</_agriland_>;

*<_area_agriland_>;
*<_area_agriland_note_> Area of Agriculture land *</_area_agriland_note_>;
*<_area_agriland_note_> area_agriland brought in from rawdata *</_area_agriland_note_>;
egen area_agriland= rowtotal(arrentin area_owned), missing;
*</_area_agriland_>;

*<_ownagriland_>;
*<_ownagriland_note_> Ownership of agriculture land *</_ownagriland_note_>;
*<_ownagriland_note_> ownagriland brought in from rawdata *</_ownagriland_note_>;
gen ownagriland= (area_owned != .);
*</_ownagriland_>;

*<_area_ownagriland_>;
*<_area_ownagriland_note_> Area of agriculture land owned *</_area_ownagriland_note_>;
*<_area_ownagriland_note_> area_ownagriland brought in from rawdata *</_area_ownagriland_note_>;
gen area_ownagriland= area_owned;
*</_area_ownagriland_>;

*<_purch_agriland_>;
*<_purch_agriland_note_> Purchased agri land *</_purch_agriland_note_>;
*<_purch_agriland_note_> purch_agriland brought in from SARMD *</_purch_agriland_note_>;
gen purch_agriland=.;
*</_purch_agriland_>;

*<_areapurch_agriland_>;
*<_areapurch_agriland_note_> Area of purchased agriculture land *</_areapurch_agriland_note_>;
*<_areapurch_agriland_note_> areapurch_agriland brought in from SARMD *</_areapurch_agriland_note_>;
gen areapurch_agriland=.;
*</_areapurch_agriland_>;

*<_inher_agriland_>;
*<_inher_agriland_note_> Inherit agriculture land *</_inher_agriland_note_>;
*<_inher_agriland_note_> inher_agriland brought in from SARMD *</_inher_agriland_note_>;
gen inher_agriland=.;
*</_inher_agriland_>;

*<_areainher_agriland_>;
*<_areainher_agriland_note_> Area of inherited agriculture land *</_areainher_agriland_note_>;
*<_areainher_agriland_note_> areainher_agriland brought in from SARMD *</_areainher_agriland_note_>;
gen areainher_agriland=.;
*</_areainher_agriland_>;

*<_rentout_agriland_>;
*<_rentout_agriland_note_> Rent Out Land *</_rentout_agriland_note_>;
*<_rentout_agriland_note_> rentout_agriland brought in from SARMD *</_rentout_agriland_note_>;
gen rentout_agriland= (arrentout != .);
*</_rentout_agriland_>;

*<_arearentout_agriland_>;
*<_arearentout_agriland_note_> Area of rent out agri land *</_arearentout_agriland_note_>;
*<_arearentout_agriland_note_> arearentout_agriland brought in from SARMD *</_arearentout_agriland_note_>;
gen arearentout_agriland= arrentout;
*</_arearentout_agriland_>;

*<_rentin_agriland_>;
*<_rentin_agriland_note_> Rent in Land *</_rentin_agriland_note_>;
*<_rentin_agriland_note_> rentin_agriland brought in from SARMD *</_rentin_agriland_note_>;
gen rentin_agriland= (arrentin != .);
*</_rentin_agriland_>;

*<_arearentin_agriland_>;
*<_arearentin_agriland_note_> Area of rent in agri land *</_arearentin_agriland_note_>;
*<_arearentin_agriland_note_> arearentin_agriland brought in from SARMD *</_arearentin_agriland_note_>;
gen arearentin_agriland= arrentin;
*</_arearentin_agriland_>;

*<_docuagriland_>;
*<_docuagriland_note_> Documented Agri Land *</_docuagriland_note_>;
*<_docuagriland_note_> docuagriland brought in from SARMD *</_docuagriland_note_>;
gen docuagriland=.;
*</_docuagriland_>;

*<_area_docuagriland_>;
*<_area_docuagriland_note_> Area of documented agri land *</_area_docuagriland_note_>;
*<_area_docuagriland_note_> area_docuagriland brought in from SARMD *</_area_docuagriland_note_>;
gen area_docuagriland=.;
*</_area_docuagriland_>;

*<_fem_agrilandownti_>;
*<_fem_agrilandownti_note_> Ownership Agri Land - Female *</_fem_agrilandownti_note_>;
*<_fem_agrilandownti_note_> fem_agrilandownti brought in from SARMD *</_fem_agrilandownti_note_>;
gen fem_agrilandownti=.;
*</_fem_agrilandownti_>;

*<_agrilandownti_>;
*<_agrilandownti_note_> Type Agri Land ownership doc *</_agrilandownti_note_>;
*<_agrilandownti_note_> agrilandownti brought in from SARMD *</_agrilandownti_note_>;
gen agrilandownti=.;
*</_agrilandownti_>;

*<_sellagriland_>;
*<_sellagriland_note_> Right to sell agri land *</_sellagriland_note_>;
*<_sellagriland_note_> sellagriland brought in from SARMD *</_sellagriland_note_>;
gen sellagriland=.;
*</_sellagriland_>;

*<_transagriland_>;
*<_transagriland_note_> Right to transfer agri land *</_transagriland_note_>;
*<_transagriland_note_> transagriland brought in from SARMD *</_transagriland_note_>;
gen transagriland=.;
*</_transagriland_>;

*<_dweltyp_>;
*<_dweltyp_note_> Types of Dwelling *</_dweltyp_note_>;
*<_dweltyp_note_> dweltyp brought in from SARMD *</_dweltyp_note_>;
gen dweltyp=.;
*</_dweltyp_>;

*<_typlivqrt_>;
*<_typlivqrt_note_> Types of living quarters *</_typlivqrt_note_>;
*<_typlivqrt_note_> typlivqrt brought in from SARMD *</_typlivqrt_note_>;
gen typlivqrt=.;
*</_typlivqrt_>;

*<_Keep variables_>;
keep countrycode year hhid pid weight weighttype landphone cellphone phone computer etablet internet radio tv tv_cable video fridge sewmach washmach stove ricecook fan ac ewpump bcycle mcycle oxcart boat car canoe roof wall floor kitchen bath rooms areaspace ybuilt ownhouse acqui_house dwelownlti fem_dwelownlti dwelownti selldwel transdwel ownland acqui_land doculand fem_doculand landownti sellland transland agriland area_agriland ownagriland area_ownagriland purch_agriland areapurch_agriland inher_agriland areainher_agriland rentout_agriland arearentout_agriland rentin_agriland arearentin_agriland docuagriland area_docuagriland fem_agrilandownti agrilandownti sellagriland transagriland dweltyp typlivqrt;
order countrycode year hhid pid weight weighttype;
sort hhid pid ;
*</_Keep variables_>;
*<_Save data file_>;
save "$rootdatalib\GMD\\`code'\\`yearfolder'\\`gmdfolder'\Data\Harmonized\\`filename'.dta" , replace;
*</_Save data file_>;
