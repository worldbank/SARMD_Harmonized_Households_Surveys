/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   LKA_2016_HIES_v01_M_v01_A_GMD_COR.do	</_Program name_>
<_Application_>    STATA 16.0	<_Application_>
<_Author(s)_>      Navishti Das and Javier Parada	</_Author(s)_>
<_Date created_>   03-03-2019	</_Date created_>
<_Date modified>    3 Mar 2020	</_Date modified_>
--------------------------------------------------------------------------------

<_Country_>                     LKA	</_Country_>
<_Survey Title_>                Household Income and Expenditure Survey 2016 </_Survey Title_>
<_Survey Year_>                 2016	</_Survey Year_>
<_Reference year_>              2016 </_Reference year_>
<_Study ID_>                    LKA_2016_HIES_v01_M </_Study ID_>
<_Data collection from (M/Y)_>  01-2016 </_Data collection from (M/Y)_>
<_Data collection to (M/Y)_>    12-2016 </_Data collection to (M/Y)_>
<_Source of dataset_>                   </_Source of dataset_>
<_Sample size (HH)_>            21,756  </_Sample size (HH)_>
<_Sample size (IND)_>           82,961  </_Sample size (IND)_>
<_Sampling method_>             Stratified two-stage </_Sampling method_>
<_Geographic coverage_>         National </_Geographic coverage_>
<_Geo_1_>                       Sector  </_Geo_1_>
<_Geo_2_>                       Province   </_Geo_2_>
<_PSU variable_>                psu     </_PSU variable_>
<_Number of food items_>        283     </_Number of food items_>
<_Food recall period(s)_>       7 days </_Food recall period(s)_>
<_Number of non-food items_>    212    </_Number of non-food items_>
<_Non-food recall period(s)_>   30 days/ 6 months/ 12 months </_Non-food recall period(s)_>
<_Currency_>                    Rs  </_Currency_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:	03-03-2019
File:	LKA_2016_HIES_v01_M_v01_A_GMD_COR.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>;
#delimit ;
clear all;
set more off;

local code         "LKA";
local year         "2016";
local survey       "HIES";
local vm           "01";
local va           "01";
local type         "SARMD";
local yearfolder   "LKA_2016_HIES";
local gmdfolder    "LKA_2016_HIES_v01_M_v01_A_GMD";
local filename     "LKA_2016_HIES_v01_M_v01_A_GMD_COR";
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

*<_countrycode_>;
*<_countrycode_note_> country code *</_countrycode_note_>;
*<_countrycode_note_> countrycode brought in from SARMD *</_countrycode_note_>;
*code;
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

*<_converfactor_>;
*<_converfactor_note_> Conversion factor *</_converfactor_note_>;
*<_converfactor_note_> converfactor brought in from CPI *</_converfactor_note_>;
gen converfactor=1;
*</_converfactor_>;

*<_cpi_>;
*<_cpi_note_> CPI ratio value of survey (rebased to 2005 on base 1) *</_cpi_note_>;
*<_cpi_note_> cpi brought in from CPI *</_cpi_note_>;
*cpi;
*</_cpi_>;

*<_cpiperiod_>;
*<_cpiperiod_note_> Periodicity of CPI (year, year&month, year&quarter, weighted) *</_cpiperiod_note_>;
*<_cpiperiod_note_> cpiperiod brought in from CPI *</_cpiperiod_note_>;
*cpiperiod;
*</_cpiperiod_>;

*<_harmonization_>;
*<_harmonization_note_> Type of harmonization *</_harmonization_note_>;
*<_harmonization_note_> harmonization brought in from CPI *</_harmonization_note_>;
gen harmonization="SARMD";
*</_harmonization_>;

*<_ppp_>;
*<_ppp_note_> PPP conversion factor *</_ppp_note_>;
*<_ppp_note_> ppp brought in from CPI *</_ppp_note_>;
*ppp;
*</_ppp_>;

*<_educat7_>;
*<_educat7_note_> Highest level of education completed (7 categories) *</_educat7_note_>;
*<_educat7_note_> educat7 brought in from SARMD *</_educat7_note_>;
replace educat7=. if educat7==8;
*</_educat7_>;

*<_educat5_>;
*<_educat5_note_> Highest level of education completed (5 categories) *</_educat5_note_>;
*<_educat5_note_> educat5 brought in from SARMD *</_educat5_note_>;
*educat5;
*</_educat5_>;

*<_educat4_>;
*<_educat4_note_> Highest level of education completed (4 categories) *</_educat4_note_>;
*<_educat4_note_> educat4 brought in from SARMD *</_educat4_note_>;
*educat4;
*</_educat4_>;

*<_educy_>;
*<_educy_note_> Years of completed education *</_educy_note_>;
*<_educy_note_> educy brought in from SARMD *</_educy_note_>;
replace educy=. if educy>=age & educy!=. & age!=.;
*</_educy_>;

*<_hsize_>;
*<_hsize_note_> Household size *</_hsize_note_>;
*<_hsize_note_> hsize brought in from SARMD *</_hsize_note_>;
*hsize;
*</_hsize_>;

*<_literacy_>;
*<_literacy_note_> Individual can read and write *</_literacy_note_>;
*<_literacy_note_> literacy brought in from SARMD *</_literacy_note_>;
gen literacy = .;
*</_literacy_>;

*<_primarycomp_>;
*<_primarycomp_note_> Primary school completion *</_primarycomp_note_>;
*<_primarycomp_note_> primarycomp brought in from SARMD *</_primarycomp_note_>;
recode educat7 (1 2=0) (3 4 5 6 7=1) (8=.) if everattend==1, gen(primarycomp);
*</_primarycomp_>;

*<_school_>;
*<_school_note_> Currently enrolled in or attending school *</_school_note_>;
*<_school_note_> school brought in from SARMD *</_school_note_>;
clonevar school = atschool;
*</_school_>;

*<_survey_>;
*<_survey_note_> Type of survey *</_survey_note_>;
*<_survey_note_> survey brought in from SARMD *</_survey_note_>;
*survey ;
*</_survey_>;

*<_veralt_>;
*<_veralt_note_> Version number of adaptation to the master data file *</_veralt_note_>;
*<_veralt_note_> veralt brought in from SARMD *</_veralt_note_>;
*veralt;
*</_veralt_>;

*<_vermast_>;
*<_vermast_note_> Version number of master data file *</_vermast_note_>;
*<_vermast_note_> vermast brought in from SARMD *</_vermast_note_>;
*vermast;
*</_vermast_>;

*<_welfare_>;
*<_welfare_note_> Welfare aggregate used for estimating international poverty (provided to PovcalNet) *</_welfare_note_>;
*<_welfare_note_> welfare brought in from SARMD *</_welfare_note_>;
replace welfare= welfare*12;
*</_welfare_>;

*<_welfaredef_>;
*<_welfaredef_note_> Welfare aggregate spatially deflated *</_welfaredef_note_>;
*<_welfaredef_note_> welfaredef brought in from SARMD *</_welfaredef_note_>;
replace welfaredef=welfaredef*12;
*</_welfaredef_>;

*<_welfarenom_>;
*<_welfarenom_note_> Welfare aggregate in nominal terms *</_welfarenom_note_>;
*<_welfarenom_note_> welfarenom brought in from SARMD *</_welfarenom_note_>;
replace welfarenom=welfarenom*12;
*</_welfarenom_>;

*<_welfareother_>;
*<_welfareother_note_> Welfare aggregate if different welfare type is used from welfare, welfarenom, welfaredef *</_welfareother_note_>;
*<_welfareother_note_> welfareother brought in from SARMD *</_welfareother_note_>;
*welfareother;
*</_welfareother_>;

*<_welfareothertype_>;
*<_welfareothertype_note_> Type of welfare measure (income, consumption or expenditure) for welfareother *</_welfareothertype_note_>;
*<_welfareothertype_note_> welfareothertype brought in from SARMD *</_welfareothertype_note_>;
* welfareothertype;
*</_welfareothertype_>;

*<_welfaretype_>;
*<_welfaretype_note_> Type of welfare measure (income, consumption or expenditure) for welfare, welfarenom, welfaredef *</_welfaretype_note_>;
*<_welfaretype_note_> welfaretype brought in from SARMD *</_welfaretype_note_>;
*welfaretype;
*</_welfaretype_>;

*<_welfshprosperity_>;
*<_welfshprosperity_note_> Welfare aggregate for shared prosperity (if different from poverty) *</_welfshprosperity_note_>;
*<_welfshprosperity_note_> welfshprosperity brought in from SARMD *</_welfshprosperity_note_>;
gen welfshprosperity=welfare;
*</_welfshprosperity_>;

*<_welfshprtype_>;
*<_welfshprtype_note_> Welfare type for shared prosperity indicator (income, consumption or expenditure) *</_welfshprtype_note_>;
*<_welfshprtype_note_> welfshprtype brought in from SARMD *</_welfshprtype_note_>;
clonevar welfshprtype=welfaretype;
*</_welfshprtype_>;

*<_spdef_>;
*<_spdef_note_> Spatial deflator (if one is used) *</_spdef_note_>;
*<_spdef_note_> spdef brought in from SARMD *</_spdef_note_>;
*spdef;
*</_spdef_>;

*<_Keep variables_>;
*keep countrycode year hhid pid weight weighttype converfactor cpi cpiperiod harmonization ppp educat7 educat5 educat4 educy hsize literacy primarycomp school survey veralt vermast welfare welfaredef welfarenom welfareother welfareothertype welfaretype welfshprosperity welfshprtype spdef;
order countrycode year hhid pid weight weighttype;
sort hhid pid ;
*</_Keep variables_>;

*<_Save data file_>;
save "$rootdatalib\GMD\\`code'\\`yearfolder'\\`gmdfolder'\Data\Harmonized\\`filename'.dta" , replace;
*</_Save data file_>;
