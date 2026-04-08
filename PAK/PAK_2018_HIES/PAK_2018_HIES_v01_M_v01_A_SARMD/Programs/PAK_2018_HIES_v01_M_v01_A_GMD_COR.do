/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   PAK_2018_PSLM_v_M_v_A_GMD_COR.do	</_Program name_>
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
File:	PAK_2018_PSLM_v_M_v_A_GMD_COR.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>;
#delimit ;
clear all;
set more off;

local code         "PAK";
local year         "2018";
local survey       "PSLM";
local vm           "";
local va           "";
local type         "SARMD";
local yearfolder   "PAK_2018_PSLM";
local gmdfolder    "PAK_2018_PSLM_v_M_v_A_GMD";
local filename     "PAK_2018_PSLM_v_M_v_A_GMD_COR";
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
*replace code=countrycode;;
*</_countrycode_>;

*<_year_>;
*<_year_note_> Year *</_year_note_>;
*<_year_note_> year brought in from SARMD *</_year_note_>;
replace year=year;;
*</_year_>;

*<_hhid_>;
*<_hhid_note_> Household identifier  *</_hhid_note_>;
*<_hhid_note_> hhid brought in from SARMD *</_hhid_note_>;
clonevar hhid=idh;;
*</_hhid_>;

*<_pid_>;
*<_pid_note_> Personal identifier  *</_pid_note_>;
*<_pid_note_> pid brought in from rawdata *</_pid_note_>;
clonevar pid  = idp;;
*</_pid_>;

*<_weight_>;
*<_weight_note_> Household weight *</_weight_note_>;
*<_weight_note_> weight brought in from rawdata *</_weight_note_>;
clonevar  weights=wgt;;
*</_weight_>;

*<_weighttype_>;
*<_weighttype_note_> Weight type (frequency, probability, analytical, importance) *</_weighttype_note_>;
*<_weighttype_note_> weighttype brought in from rawdata *</_weighttype_note_>;
gen weighttype = "IW";;
*</_weighttype_>;

*<_converfactor_>;
*<_converfactor_note_> Conversion factor *</_converfactor_note_>;
*<_converfactor_note_> converfactor brought in from CPI *</_converfactor_note_>;
gen converfactor=1;
*</_converfactor_>;

*<_cpi_>;
*<_cpi_note_> CPI ratio value of survey (rebased to 2005 on base 1) *</_cpi_note_>;
*<_cpi_note_> cpi brought in from CPI *</_cpi_note_>;
*rename cpi cpi;
*</_cpi_>;

*<_cpiperiod_>;
*<_cpiperiod_note_> Periodicity of CPI (year, year&month, year&quarter, weighted) *</_cpiperiod_note_>;
*<_cpiperiod_note_> cpiperiod brought in from CPI *</_cpiperiod_note_>;
*gen cpiperiod=cpiperiod;
*</_cpiperiod_>;

*<_harmonization_>;
*<_harmonization_note_> Type of harmonization *</_harmonization_note_>;
*<_harmonization_note_> harmonization brought in from CPI *</_harmonization_note_>;
;
*</_harmonization_>;

*<_ppp_>;
*<_ppp_note_> PPP conversion factor *</_ppp_note_>;
*<_ppp_note_> ppp brought in from CPI *</_ppp_note_>;
*rename ppp ppp;
*</_ppp_>;

*<_educat7_>;
*<_educat7_note_> Highest level of education completed (7 categories) *</_educat7_note_>;
*<_educat7_note_> educat7 brought in from SARMD *</_educat7_note_>;
replace educat7=. if educat7==8;
*</_educat7_>;

*<_educat5_>;
*<_educat5_note_> Highest level of education completed (5 categories) *</_educat5_note_>;
*<_educat5_note_> educat5 brought in from SARMD *</_educat5_note_>;
*rename educat5 educat5;
*</_educat5_>;

*<_educat4_>;
*<_educat4_note_> Highest level of education completed (4 categories) *</_educat4_note_>;
*<_educat4_note_> educat4 brought in from SARMD *</_educat4_note_>;
*rename educat4 educat4;
*</_educat4_>;

*<_educy_>;
*<_educy_note_> Years of completed education *</_educy_note_>;
*<_educy_note_> educy brought in from SARMD *</_educy_note_>;
replace educy=. if educy>=age & educy!=. & age!=.;
*</_educy_>;

*<_hsize_>;
*<_hsize_note_> Household size *</_hsize_note_>;
*<_hsize_note_> hsize brought in from SARMD *</_hsize_note_>;
gen aux=1; drop hsize; egen hsize=sum(aux), by(hhid);
*</_hsize_>;

*<_literacy_>;
*<_literacy_note_> Individual can read and write *</_literacy_note_>;
*<_literacy_note_> literacy brought in from SARMD *</_literacy_note_>;
*rename literacy literacy;
*</_literacy_>;

*<_primarycomp_>;
*<_primarycomp_note_> Primary school completion *</_primarycomp_note_>;
*<_primarycomp_note_> primarycomp brought in from SARMD *</_primarycomp_note_>;
recode educat7 (1 2=0) (3 4 5 6 7=1) (8=.) if everattend==1, gen(primarycomp);
*</_primarycomp_>;

*<_school_>;
*<_school_note_> Currently enrolled in or attending school *</_school_note_>;
*<_school_note_> school brought in from SARMD *</_school_note_>;
ren atschool school;
*</_school_>;

*<_survey_>;
*<_survey_note_> Type of survey *</_survey_note_>;
*<_survey_note_> survey brought in from SARMD *</_survey_note_>;
*gen survey=.;
*</_survey_>;

*<_veralt_>;
*<_veralt_note_> Version number of adaptation to the master data file *</_veralt_note_>;
*<_veralt_note_> veralt brought in from SARMD *</_veralt_note_>;
*gen veralt=`va';
*</_veralt_>;

*<_vermast_>;
*<_vermast_note_> Version number of master data file *</_vermast_note_>;
*<_vermast_note_> vermast brought in from SARMD *</_vermast_note_>;
*gen vermast=`vm';
*</_vermast_>;

*<_welfare_>;
*<_welfare_note_> Welfare aggregate used for estimating international poverty (provided to PovcalNet) *</_welfare_note_>;
*<_welfare_note_> welfare brought in from SARMD *</_welfare_note_>;
replace welfare=12*welfare;
*</_welfare_>;

*<_welfaredef_>;
*<_welfaredef_note_> Welfare aggregate spatially deflated *</_welfaredef_note_>;
*<_welfaredef_note_> welfaredef brought in from SARMD *</_welfaredef_note_>;
replace welfaredef=12*welfaredef;
*</_welfaredef_>;

*<_welfarenom_>;
*<_welfarenom_note_> Welfare aggregate in nominal terms *</_welfarenom_note_>;
*<_welfarenom_note_> welfarenom brought in from SARMD *</_welfarenom_note_>;
replace welfarenom=12*welfarenom;
*</_welfarenom_>;

*<_welfareother_>;
*<_welfareother_note_> Welfare aggregate if different welfare type is used from welfare, welfarenom, welfaredef *</_welfareother_note_>;
*<_welfareother_note_> welfareother brought in from SARMD *</_welfareother_note_>;
replace welfareother=12*welfareother;
*</_welfareother_>;

*<_welfareothertype_>;
*<_welfareothertype_note_> Type of welfare measure (income, consumption or expenditure) for welfareother *</_welfareothertype_note_>;
*<_welfareothertype_note_> welfareothertype brought in from SARMD *</_welfareothertype_note_>;
replace welfareothertype=".";
*</_welfareothertype_>;

*<_welfaretype_>;
*<_welfaretype_note_> Type of welfare measure (income, consumption or expenditure) for welfare, welfarenom, welfaredef *</_welfaretype_note_>;
*<_welfaretype_note_> welfaretype brought in from SARMD *</_welfaretype_note_>;
*clonevar welfaretype=welfaretype;
*</_welfaretype_>;

*<_welfshprosperity_>;
*<_welfshprosperity_note_> Welfare aggregate for shared prosperity (if different from poverty) *</_welfshprosperity_note_>;
*<_welfshprosperity_note_> welfshprosperity brought in from SARMD *</_welfshprosperity_note_>;
*clonevar welfshprosperity=welfshprosperity;
*</_welfshprosperity_>;

*<_welfshprtype_>;
*<_welfshprtype_note_> Welfare type for shared prosperity indicator (income, consumption or expenditure) *</_welfshprtype_note_>;
*<_welfshprtype_note_> welfshprtype brought in from SARMD *</_welfshprtype_note_>;
*clonevar welfshprtype=welfshprtype;
*</_welfshprtype_>;

*<_spdef_>;
*<_spdef_note_> Spatial deflator (if one is used) *</_spdef_note_>;
*<_spdef_note_> spdef brought in from SARMD *</_spdef_note_>;
*gen spdef=spdef;
*</_spdef_>;

*<_Keep variables_>;
*keep countrycode year hhid pid weight weighttype converfactor cpi cpiperiod harmonization ppp educat7 educat5 educat4 educy hsize literacy primarycomp school survey veralt vermast welfare welfaredef welfarenom welfareother welfareothertype welfaretype welfshprosperity welfshprtype spdef;
order countrycode year hhid pid weights weighttype;
sort hhid pid ;
*</_Keep variables_>;

*<_Save data file_>;
save "$rootdatalib\GMD\\`code'\\`yearfolder'\\`gmdfolder'\Data\Harmonized\\`filename'.dta" , replace;
*</_Save data file_>;
