/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   MDV_2019_HIES_v01_M_v01_A_GMD_DWL.do	</_Program name_>
<_Application_>    STATA 16.0	<_Application_>
<_Author(s)_>      Juan Segnana <jsegnana@worldbank.org>	</_Author(s)_>
<_Date created_>   05-03-2020	</_Date created_>
<_Date modified>    3 May 2021	</_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        MDV	</_Country_>
<_Survey Title_>   HIES	</_Survey Title_>
<_Survey Year_>    2019	</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:	05-03-2020
File:	MDV_2019_HIES_v01_M_v01_A_GMD_DWL.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>;
#delimit ;
clear all;
set more off;

local code         "MDV";
local year         "2019";
local survey       "HIES";
local vm           "01";
local va           "02";
local type         "SARMD";
local yearfolder   "`code'_`year'_`survey'";
local gmdfolder    "`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'";
local filename     "`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'_DWL";
*</_Program setup_>;

*<_Folder creation_>;
cap mkdir "$rootdatalib";
cap mkdir "$rootdatalib\\`code'";
cap mkdir "$rootdatalib\\`code'\\`yearfolder'";
cap mkdir "$rootdatalib\\`code'\\`yearfolder'\\`gmdfolder'";
cap mkdir "$rootdatalib\\`code'\\`yearfolder'\\`gmdfolder'\Data";
cap mkdir "$rootdatalib\\`code'\\`yearfolder'\\`gmdfolder'\Data\Harmonized";
*</_Folder creation_>;

** DIRECTORY;
*<_Datalibweb request_>;
#delimit cr
datalibweb, country(`code') year(`year') type(SARRAW) surveyid(`code'_`year'_`survey'_v`vm'_M) filename(`code'_`year'_`survey'_v`vm'_M.dta) clear 
#delimit ;
drop year hhid pid;
*</_Datalibweb request_>;

*<_countrycode_>;
*<_countrycode_note_> country code *</_countrycode_note_>;
*<_countrycode_note_> countrycode brought in from rawdata *</_countrycode_note_>;
gen countrycode="MDV";
label var countrycode "Country code";
note countrycode: countrycode=MDV;
*</_countrycode_>;

*<_year_>;
*<_year_note_> Year *</_year_note_>;
*<_year_note_> year brought in from rawdata *</_year_note_>;
gen int year=2019;
label var year "Year of survey";
note year: year=2019;
*</_year_>;

*<_hhid_>;
*<_hhid_note_> Household identifier  *</_hhid_note_>;
*<_hhid_note_> hhid brought in from rawdata *</_hhid_note_>;
gen hhid=uqhhid;
tostring hhid, replace;
label var hhid "Household id";
note hhid: hhid=uqhhid  4,721 values;
*</_hhid_>;

*<_pid_>;
*<_pid_note_> Personal identifier  *</_pid_note_>;
*<_pid_note_> pid brought in from rawdata *</_pid_note_>;
egen pid=concat(uqhhid person_no), punct(-);
label var pid "Individual id";
note pid: pid=uqhhid - person_no  24,845 values;
*</_pid_>;

*<_weight_>;
*<_weight_note_> Household weight *</_weight_note_>;
*<_weight_note_> weight brought in from rawdata *</_weight_note_>;
gen double weight=wgt;
label var weight "Household sampling weight";
note weight: weight=wgt;
*</_weight_>;

*<_weighttype_>;
*<_weighttype_note_> Weight type (frequency, probability, analytical, importance) *</_weighttype_note_>;
*<_weighttype_note_> weighttype brought in from rawdata *</_weighttype_note_>;
gen weighttype="PW";
note weighttype: "Probability weight";
*</_weighttype_>;

*<_landphone_>;
*<_landphone_note_> Ownership of a land phone (household) *</_landphone_note_>;
*<_landphone_note_> landphone brought in from rawdata *</_landphone_note_>;
gen landphone=.;
note landphone: N/A;
*</_landphone_>;

*<_cellphone_>;
*<_cellphone_note_> Ownership of a cell phone (household) *</_cellphone_note_>;
*<_cellphone_note_> cellphone brought in from rawdata *</_cellphone_note_>;
gen cellphone=Mobile;
replace cellphone=0 if Mobile==2;
replace cellphone=. if cellphone==.a;
note cellphone: Ownership of a cell phone (household);
*</_cellphone_>;

*<_cellphone_i_>;
*<_cellphone_i_note_> Ownership of a cell phone (individual) *</_cellphone_i_note_>;
*<_cellphone_i_note_> cellphone_i brought in from rawdata *</_cellphone_i_note_>;
gen cellphone_i=.;
note cellphone_i: N/A;
*</_cellphone_i_>;

*<_phone_>;
*<_phone_note_> Ownership of a telephone (household) *</_phone_note_>;
*<_phone_note_> phone brought in from rawdata *</_phone_note_>;
gen phone=.;
note phone: N/A;
*</_phone_>;

*<_computer_>;
*<_computer_note_> Ownership of a computer *</_computer_note_>;
*<_computer_note_> computer brought in from rawdata *</_computer_note_>;
gen computer=LaptopComp;
replace computer=0 if LaptopComp==2;
replace computer=. if computer==.a;
note computer: Ownership of a computer, either desktop or laptop;
*</_computer_>;

*<_etablet_>;
*<_etablet_note_> Ownership of a electronic tablet *</_etablet_note_>;
*<_etablet_note_> etablet brought in from rawdata *</_etablet_note_>;
gen etablet=Tabletipad;
replace etablet=0 if Tabletipad==2;
note etablet: Ownership of an electronic tablet;
*</_etablet_>;

*<_internet_>;
*<_internet_note_> Ownership of a  internet *</_internet_note_>;
*<_internet_note_> internet brought in from rawdata *</_internet_note_>;
gen internet=.;
replace internet=3 if other_bills_exp__8310001==1;
*</_internet_>;

*<_internet_mobile_>;
*<_internet_mobile_note_> Ownership of a  internet (mobile 2G 3G LTE 4G 5G ) *</_internet_mobile_note_>;
*<_internet_mobile_note_> internet_mobile brought in from rawdata *</_internet_mobile_note_>;
gen internet_mobile=.;
note internet_mobile: N/A;
*</_internet_mobile_>;

*<_internet_mobile4G_>;
*<_internet_mobile4G_note_> Ownership of a  internet (mobile LTE 4G 5G ) *</_internet_mobile4G_note_>;
*<_internet_mobile4G_note_> internet_mobile4G brought in from rawdata *</_internet_mobile4G_note_>;
gen internet_mobile4G=.;
note internet_mobile4G: N/A;
*</_internet_mobile4G_>;

*<_radio_>;
*<_radio_note_> Ownership of a radio *</_radio_note_>;
*<_radio_note_> radio brought in from rawdata *</_radio_note_>;
gen radio=(hh_cons_hh__8140004==1);
note radio: Ownership of a radio;
*</_radio_>;

*<_tv_>;	
*<_tv_note_> Ownership of a tv *</_tv_note_>;
*<_tv_note_> tv brought in from rawdata *</_tv_note_>;
gen tv=(Owned_HHTV==1);
note tv: Ownership of a tv;
*</_tv_>;

*<_tv_cable_>;
*<_tv_cable_note_> Ownership of a cable tv *</_tv_cable_note_>;
*<_tv_cable_note_> tv_cable brought in from rawdata *</_tv_cable_note_>;
gen tv_cable=(hh_cablNetfilx==1);
note tv_cable: Ownership of a cable tv;
*</_tv_cable_>;

*<_video_>;
*<_video_note_> Ownership of a video *</_video_note_>;
*<_video_note_> video brought in from rawdata *</_video_note_>;
gen video=.;
note video: N/A;
*</_video_>;

*<_fridge_>;
*<_fridge_note_> Ownership of a refrigerator *</_fridge_note_>;
*<_fridge_note_> fridge brought in from rawdata *</_fridge_note_>;
gen fridge=(Owned_HHREFRIGERATOR==1);
note fridge: Ownership of a refrigerator;
*</_fridge_>;

*<_sewmach_>;
*<_sewmach_note_> Ownership of a sewing machine *</_sewmach_note_>;
*<_sewmach_note_> sewmach brought in from rawdata *</_sewmach_note_>;
gen sewmach=.;
note sewmach: N/A;
*</_sewmach_>;

*<_washmach_>;
*<_washmach_note_> Ownership of a washing machine *</_washmach_note_>;
*<_washmach_note_> washmach brought in from rawdata *</_washmach_note_>;
gen washmach=(Owned_HHWASHINGMACHINE_A==1);
note washmach: Ownership of a washing machine;
*</_washmach_>;

*<_stove_>;
*<_stove_note_> Ownership of a stove *</_stove_note_>;
*<_stove_note_> stove brought in from rawdata *</_stove_note_>;
gen stove=(hh_cons_purch__5311005==1);
note stove: Ownership of a stove;
*</_stove_>;

*<_ricecook_>;
*<_ricecook_note_> Ownership of a rice cooker *</_ricecook_note_>;
*<_ricecook_note_> ricecook brought in from rawdata *</_ricecook_note_>;
gen ricecook=(hh_cons_hh__5312001==1);
note ricecook: Ownership of a rice cooker;
*</_ricecook_>;

*<_fan_>;
*<_fan_note_> Ownership of an electric fan *</_fan_note_>;
*<_fan_note_> fan brought in from rawdata *</_fan_note_>;
rename Owned_HHFAN fan;
note fan: Ownership of a fan;
*</_fan_>;

*<_ac_>;
*<_ac_note_> Ownership of a central or wall air conditioner *</_ac_note_>;
*<_ac_note_> ac brought in from rawdata *</_ac_note_>;
gen ac=(hh_cons_hh__5313001==1);
note ac: Ownership of a central or wall air conditioner;
*</_ac_>;

*<_ewpump_>;
*<_ewpump_note_> Ownership of a electric water pump *</_ewpump_note_>;
*<_ewpump_note_> ewpump brought in from rawdata *</_ewpump_note_>;
gen ewpump=(hh_cons_hh__7130001==1);
note ewpump: Ownership of an electric water pump;
*</_ewpump_>;

*<_bcycle_>;
*<_bcycle_note_> Ownership of a bicycle *</_bcycle_note_>;
*<_bcycle_note_> bcycle brought in from rawdata *</_bcycle_note_>;
gen bcycle=(hh_cons_hh__8110001==1);
note bcycle: Ownership of a bicycle;
*</_bcycle_>;

*<_mcycle_>;
*<_mcycle_note_> Ownership of a motorcycle *</_mcycle_note_>;
*<_mcycle_note_> mcycle brought in from rawdata *</_mcycle_note_>;
gen mcycle=(hh_cons_hh__7111001==1);
note mcycle: Ownership of a motorcycle;
*</_mcycle_>;

*<_oxcart_>;
*<_oxcart_note_> Ownership of a oxcart *</_oxcart_note_>;
*<_oxcart_note_> oxcart brought in from rawdata *</_oxcart_note_>;
gen oxcart=.;
note oxcart: N/A;
*</_oxcart_>;

*<_boat_>;
*<_boat_note_> Ownership of a boat *</_boat_note_>;
*<_boat_note_> boat brought in from rawdata *</_boat_note_>;
gen boat=(hh_cons_hh__1111111==1);
note boat: Ownership of a speed boat;
*</_boat_>;

*<_car_>;
*<_car_note_> Ownership of a Car *</_car_note_>;
*<_car_note_> car brought in from rawdata *</_car_note_>;
gen car=(hh_cons_hh__9123002==1);
note car: Ownership of a car;
*</_car_>;

*<_canoe_>;
*<_canoe_note_> Ownership of a canoes *</_canoe_note_>;
*<_canoe_note_> canoe brought in from rawdata *</_canoe_note_>;
gen canoe=.;
note canoe: N/A;
*</_canoe_>;

*<_roof_>;
*<_roof_note_> Main material used for roof *</_roof_note_>;
*<_roof_note_> roof brought in from rawdata *</_roof_note_>;
gen roof=hh_roof_material;
recode roof (1 = 12) (2 = 1) (3 = 10) (4 = 11) (5 = 8) (96 = 15) (9 = .);
note roof: Main material used for roof;
*</_roof_>;

*<_wall_>;
*<_wall_note_> Main material used for external walls *</_wall_note_>;
*<_wall_note_> wall brought in from rawdata *</_wall_note_>;
gen wall=hh_const_material;
recode wall (1 2 = 12) (3 = 15) (4 = 7) (5 = 1) (6 = 18) (96 = 19) (9 = .);
note wall: Main material used for external walls;
*</_wall_>;

*<_floor_>;
*<_floor_note_> Main material used for floor *</_floor_note_>;
*<_floor_note_> floor brought in from rawdata *</_floor_note_>;
gen floor=hh_flr_material;
recode floor (1 3 = 11) (2 = 10) (4 5 = 7) (6 = 1) (96 = 14) (9 = .);
note floor: Main material used for floor;
*</_floor_>;

*<_kitchen_>;
*<_kitchen_note_> Separate kitchen in the dwelling *</_kitchen_note_>;
*<_kitchen_note_> kitchen brought in from rawdata *</_kitchen_note_>;
gen kitchen=(hh_kitch_typ==1);
note kitchen: Separate kitchen in the dwelling;
*</_kitchen_>;

*<_bath_>;
*<_bath_note_> Bathing facility in the dwelling *</_bath_note_>;
*<_bath_note_> bath brought in from rawdata *</_bath_note_>;
gen bath=(hh_toilet_fac==1);
note bath: Bathing facility in the dwelling;
*</_bath_>;

*<_rooms_>;
*<_rooms_note_> Number of habitable rooms *</_rooms_note_>;
*<_rooms_note_> rooms brought in from rawdata *</_rooms_note_>;
cap drop rooms;
rename hh_nrmslp rooms;
note rooms: Number of habitable rooms;
*</_rooms_>;

*<_areaspace_>;
*<_areaspace_note_> Area *</_areaspace_note_>;
*<_areaspace_note_> areaspace brought in from rawdata *</_areaspace_note_>;
gen areaspace=.;
note areaspace: N/A;
*</_areaspace_>;

*<_ybuilt_>;
*<_ybuilt_note_> Year the dwelling built *</_ybuilt_note_>;
*<_ybuilt_note_> ybuilt brought in from rawdata *</_ybuilt_note_>;
gen ybuilt=.;
note ybuilt: N/A;
*</_ybuilt_>;

*<_ownhouse_>;
*<_ownhouse_note_> Ownership of house *</_ownhouse_note_>;
*<_ownhouse_note_> ownhouse brought in from rawdata *</_ownhouse_note_>;
gen ownhouse=(hh_build_ownshp==1);
note ownhouse: Ownership of house;
*</_ownhouse_>;

*<_acqui_house_>;
*<_acqui_house_note_> Acquisition of house *</_acqui_house_note_>;
*<_acqui_house_note_> acqui_house brought in from rawdata *</_acqui_house_note_>;
gen acqui_house=.;
note acqui_house: N/A;
*</_acqui_house_>;

*<_dwelownlti_>;
*<_dwelownlti_note_> Legal title for Ownership *</_dwelownlti_note_>;
*<_dwelownlti_note_> dwelownlti brought in from rawdata *</_dwelownlti_note_>;
gen dwelownlti=.;
note dwelownlti: Legal title for Ownership;
*</_dwelownlti_>;

*<_fem_dwelownlti_>;
*<_fem_dwelownlti_note_> Legal title for Ownership - Female *</_fem_dwelownlti_note_>;
*<_fem_dwelownlti_note_> fem_dwelownlti brought in from rawdata *</_fem_dwelownlti_note_>;
gen fem_dwelownlti=.;
note fem_dwelownlti: N/A;
*</_fem_dwelownlti_>;

*<_dwelownti_>;
*<_dwelownti_note_> Type of Legal document *</_dwelownti_note_>;
*<_dwelownti_note_> dwelownti brought in from rawdata *</_dwelownti_note_>;
gen dwelownti=.;
note dwelownti: N/A;
*</_dwelownti_>;

*<_selldwel_>;
*<_selldwel_note_> Right to sell dwelling *</_selldwel_note_>;
*<_selldwel_note_> selldwel brought in from rawdata *</_selldwel_note_>;
gen selldwel=.;
note selldwel: N/A;
*</_selldwel_>;

*<_transdwel_>;
*<_transdwel_note_> Right to transfer dwelling *</_transdwel_note_>;
*<_transdwel_note_> transdwel brought in from rawdata *</_transdwel_note_>;
gen transdwel=.;
note transdwel: N/A;
*</_transdwel_>;

*<_ownland_>;
*<_ownland_note_> Ownership of land *</_ownland_note_>;
*<_ownland_note_> ownland brought in from rawdata *</_ownland_note_>;
gen ownland=.;
note ownland: N/A;
*</_ownland_>;

*<_acqui_land_>;
*<_acqui_land_note_> Acquisition of residential land *</_acqui_land_note_>;
*<_acqui_land_note_> acqui_land brought in from rawdata *</_acqui_land_note_>;
gen acqui_land=.;
note acqui_land:N/A;
*</_acqui_land_>;

*<_doculand_>;
*<_doculand_note_> Legal document for residential land *</_doculand_note_>;
*<_doculand_note_> doculand brought in from rawdata *</_doculand_note_>;
gen doculand=.;
note doculand: N/A;
*</_doculand_>;

*<_fem_doculand_>;
*<_fem_doculand_note_> Legal document for residential land - female *</_fem_doculand_note_>;
*<_fem_doculand_note_> fem_doculand brought in from rawdata *</_fem_doculand_note_>;
gen fem_doculand=.;
note fem_doculand: N/A;
*</_fem_doculand_>;

*<_landownti_>;
*<_landownti_note_> Land Ownership *</_landownti_note_>;
*<_landownti_note_> landownti brought in from rawdata *</_landownti_note_>;
gen landownti=.;
note landownti: N/A;
*</_landownti_>;

*<_sellland_>;
*<_sellland_note_> Right to sell land *</_sellland_note_>;
*<_sellland_note_> sellland brought in from rawdata *</_sellland_note_>;
gen sellland=.;
note sellland: N/A;
*</_sellland_>;

*<_transland_>;
*<_transland_note_> Right to transfer land *</_transland_note_>;
*<_transland_note_> transland brought in from rawdata *</_transland_note_>;
gen transland=.;
note transland: N/A;
*</_transland_>;

*<_agriland_>;
*<_agriland_note_> Agriculture Land *</_agriland_note_>;
*<_agriland_note_> agriland brought in from rawdata *</_agriland_note_>;
gen agriland=.;
note agriland: Household is using agricultural land;
*</_agriland_>;

*<_area_agriland_>;
*<_area_agriland_note_> Area of Agriculture land *</_area_agriland_note_>;
*<_area_agriland_note_> area_agriland brought in from rawdata *</_area_agriland_note_>;
gen area_agriland=.;
note area_agriland: N/A;
*</_area_agriland_>;

*<_ownagriland_>;
*<_ownagriland_note_> Ownership of agriculture land *</_ownagriland_note_>;
*<_ownagriland_note_> ownagriland brought in from rawdata *</_ownagriland_note_>;
gen ownagriland=.;
note ownagriland: N/A;
*</_ownagriland_>;

*<_area_ownagriland_>;
*<_area_ownagriland_note_> Area of agriculture land owned *</_area_ownagriland_note_>;
*<_area_ownagriland_note_> area_ownagriland brought in from rawdata *</_area_ownagriland_note_>;
gen area_ownagriland=.;
note area_ownagriland: N/A;
*</_area_ownagriland_>;

*<_purch_agriland_>;
*<_purch_agriland_note_> Purchased agri land *</_purch_agriland_note_>;
*<_purch_agriland_note_> purch_agriland brought in from rawdata *</_purch_agriland_note_>;
gen purch_agriland=.;
note purch_agriland: N/A;
*</_purch_agriland_>;

*<_areapurch_agriland_>;
*<_areapurch_agriland_note_> Area of purchased agriculture land *</_areapurch_agriland_note_>;
*<_areapurch_agriland_note_> areapurch_agriland brought in from rawdata *</_areapurch_agriland_note_>;
gen areapurch_agriland=.;
note areapurch_agriland: N/A;
*</_areapurch_agriland_>;

*<_inher_agriland_>;
*<_inher_agriland_note_> Inherit agriculture land *</_inher_agriland_note_>;
*<_inher_agriland_note_> inher_agriland brought in from rawdata *</_inher_agriland_note_>;
gen inher_agriland=.;
note inher_agriland: N/A;
*</_inher_agriland_>;

*<_areainher_agriland_>;
*<_areainher_agriland_note_> Area of inherited agriculture land *</_areainher_agriland_note_>;
*<_areainher_agriland_note_> areainher_agriland brought in from rawdata *</_areainher_agriland_note_>;
gen areainher_agriland=.;
note areainher_agriland: N/A;
*</_areainher_agriland_>;

*<_rentout_agriland_>;
*<_rentout_agriland_note_> Rent Out Land *</_rentout_agriland_note_>;
*<_rentout_agriland_note_> rentout_agriland brought in from rawdata *</_rentout_agriland_note_>;
gen rentout_agriland=(otherIncomeYn__3==1);
note rentout_agriland: Some agricultural land the household uses is rented out;
*</_rentout_agriland_>;

*<_arearentout_agriland_>;
*<_arearentout_agriland_note_> Area of rent out agri land *</_arearentout_agriland_note_>;
*<_arearentout_agriland_note_> arearentout_agriland brought in from rawdata *</_arearentout_agriland_note_>;
gen arearentout_agriland=.;
note arearentout_agriland: N/A;
*</_arearentout_agriland_>;

*<_rentin_agriland_>;
*<_rentin_agriland_note_> Rent in Land *</_rentin_agriland_note_>;
*<_rentin_agriland_note_> rentin_agriland brought in from rawdata *</_rentin_agriland_note_>;
gen rentin_agriland=.;
note rentin_agriland: N/A;
*</_rentin_agriland_>;

*<_arearentin_agriland_>;
*<_arearentin_agriland_note_> Area of rent in agri land *</_arearentin_agriland_note_>;
*<_arearentin_agriland_note_> arearentin_agriland brought in from rawdata *</_arearentin_agriland_note_>;
gen arearentin_agriland=.;
note arearentin_agriland: N/A;
*</_arearentin_agriland_>;

*<_docuagriland_>;
*<_docuagriland_note_> Documented Agri Land *</_docuagriland_note_>;
*<_docuagriland_note_> docuagriland brought in from rawdata *</_docuagriland_note_>;
gen docuagriland=.;
note docuagriland: N/A;
*</_docuagriland_>;

*<_area_docuagriland_>;
*<_area_docuagriland_note_> Area of documented agri land *</_area_docuagriland_note_>;
*<_area_docuagriland_note_> area_docuagriland brought in from rawdata *</_area_docuagriland_note_>;
gen area_docuagriland=.;
note area_docuagriland: N/A;
*</_area_docuagriland_>;

*<_fem_agrilandownti_>;
*<_fem_agrilandownti_note_> Ownership Agri Land - Female *</_fem_agrilandownti_note_>;
*<_fem_agrilandownti_note_> fem_agrilandownti brought in from rawdata *</_fem_agrilandownti_note_>;
gen fem_agrilandownti=.;
note fem_agrilandownti: N/A;
*</_fem_agrilandownti_>;

*<_agrilandownti_>;
*<_agrilandownti_note_> Type Agri Land ownership doc *</_agrilandownti_note_>;
*<_agrilandownti_note_> agrilandownti brought in from rawdata *</_agrilandownti_note_>;
gen agrilandownti=.;
note agrilandownti: N/A;
*</_agrilandownti_>;

*<_sellagriland_>;
*<_sellagriland_note_> Right to sell agri land *</_sellagriland_note_>;
*<_sellagriland_note_> sellagriland brought in from rawdata *</_sellagriland_note_>;
gen sellagriland=.;
note sellagriland: N/A;
*</_sellagriland_>;

*<_transagriland_>;
*<_transagriland_note_> Right to transfer agri land *</_transagriland_note_>;
*<_transagriland_note_> transagriland brought in from rawdata *</_transagriland_note_>;
gen transagriland=.;
note transagriland: N/A;
*</_transagriland_>;

*<_dweltyp_>;
*<_dweltyp_note_> Types of Dwelling *</_dweltyp_note_>;
*<_dweltyp_note_> dweltyp brought in from rawdata *</_dweltyp_note_>;
gen dweltyp= hh_dwell_typ;
recode dweltyp (2 = 3) (3 = 4);
note dweltyp: Type of dwelling;
*</_dweltyp_>;

*<_typlivqrt_>;
*<_typlivqrt_note_> Types of living quarters *</_typlivqrt_note_>;
*<_typlivqrt_note_> typlivqrt brought in from rawdata *</_typlivqrt_note_>;
gen typlivqrt=.;
note typlivqrt: N/A;
*</_typlivqrt_>;

*<_Keep variables_>;
keep countrycode year hhid pid weight weighttype landphone cellphone cellphone_i phone computer etablet internet internet_mobile internet_mobile4G radio tv tv_cable video fridge sewmach washmach stove ricecook fan ac ewpump bcycle mcycle oxcart boat car canoe roof wall floor kitchen bath rooms areaspace ybuilt ownhouse acqui_house dwelownlti fem_dwelownlti dwelownti selldwel transdwel ownland acqui_land doculand fem_doculand landownti sellland transland agriland area_agriland ownagriland area_ownagriland purch_agriland areapurch_agriland inher_agriland areainher_agriland rentout_agriland arearentout_agriland rentin_agriland arearentin_agriland docuagriland area_docuagriland fem_agrilandownti agrilandownti sellagriland transagriland dweltyp typlivqrt;
order countrycode year hhid pid weight weighttype;
sort hhid pid ;
*</_Keep variables_>;

*<_Save data file_>;
glo module="DWL";
include "${rootdatalib}\_aux\GMD2.0labels.do";
save "$rootdatalib\\`code'\\`yearfolder'\\`gmdfolder'\Data\Harmonized\\`filename'.dta" , replace;
*</_Save data file_>;
