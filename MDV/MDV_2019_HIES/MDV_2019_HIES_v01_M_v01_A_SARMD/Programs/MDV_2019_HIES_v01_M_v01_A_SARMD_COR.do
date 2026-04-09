
/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   MDV_2019_HIES_v01_M_v01_A_GMD_COR.do	</_Program name_>
<_Application_>    STATA 16.0	<_Application_>
<_Author(s)_>      Juan Segnana <jsegnana@worldbank.org>	</_Author(s)_>
<_Date created_>   05-03-2020	</_Date created_>
<_Date modified>    18 May 2021	</_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        MDV	</_Country_>
<_Survey Title_>   HIES	</_Survey Title_>
<_Survey Year_>    2019	</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:	05-03-2020
File:	MDV_2019_HIES_v01_M_v01_A_GMD_COR.do
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
local va           "01";
local type         "GMD";
local module 		"COR";
local yearfolder   "MDV_2019_HIES";
local gmdfolder    "MDV_2019_HIES_v01_M_v01_A_SARMD";
local filename     "MDV_2019_HIES_v01_M_v01_A_SARMD_COR";
*</_Program setup_>;

*<_Folder creation_>;
cap mkdir "$rootdatalib";
cap mkdir "$rootdatalib\\`code'";
cap mkdir "$rootdatalib\\`code'\\`yearfolder'";
cap mkdir "$rootdatalib\\`code'\\`yearfolder'\\`gmdfolder'";
cap mkdir "$rootdatalib\\`code'\\`yearfolder'\\`gmdfolder'\Data";
cap mkdir "$rootdatalib\\`code'\\`yearfolder'\\`gmdfolder'\Data\Harmonized";
*</_Folder creation_>;

**get cpi;
cap datalibweb, country(Support) year(2005) type(GMDRAW) surveyid(Support_2005_CPI_v06_M) filename(Final_CPI_PPP_to_be_used.dta);
keep if code=="`code'" & year==`year';
sum cpi2011;
local cpi2011=`r(mean)';
sum icp2011;
local ppp2011=`r(mean)';
* get Simple average of CPIs of Oct 19, Nov 19, Jan 20, Feb 20, Mar 20;
cap datalibweb, country(Support) year(2005) type(GMDRAW) surveyid(Support_2005_CPI_v06_M) filename(Monthly_CPI.dta);
keep if code=="`code'" & ((year==2019 & inrange(month,10,11)) | (year==2020 & month<=3));
sum monthly_cpi;
*136.857337032829;
local cpi2019=`r(mean)';
sum monthly_cpi if month==11;
local cpi2019m11=`r(mean)';
*136.84770931004

* get ppp;
cap datalibweb, country(Support) year(2005) type(GMDRAW) surveyid(Support_2005_CPI_v06_M) filename(Yearly_CPI_Final.dta);
keep if code=="`code'" & inlist(year,2011,2017);
sum ppp_2017;
local ppp2017=`r(mean)';
sum yearly_cpi if year==2011;
local cpi2017=`r(mean)';
sum yearly_cpi if year==2017;
local cpi2017=`cpi2011'*(`cpi2017'/`r(mean)');
**end cpi;

** DIRECTORY;
*<_Datalibweb request_>;
#delimit cr
*datalibweb, country(`code') year(`year') type(`type') survey(`survey') vermast(`vm') veralt(`va') mod(IND) clear 
#delimit ;
use "$rootdatalib\MDV\MDV_2019_HIES\MDV_2019_HIES_v01_M\Data\Stata\MDV_2019_HIES_v01_M.dta", clear;
drop countrycode year hhid pid;

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
note pid: pid=uqhhid - person_no  24,749 values;
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
*<_weighttype_note_> weighttype brought in from rawdata;
gen weighttype="PW";
note weighttype: "Probability Weight";
*</_weighttype_note_>;

*</_weighttype_>;

*<_converfactor_>;
*<_converfactor_note_> Conversion factor *</_converfactor_note_>;
*<_converfactor_note_> converfactor brought in from rawdata *</_converfactor_note_>;
gen converfactor=1;
label var converfactor "Conversion factor";
*</_converfactor_>;

*<_cpi_>;
*<_cpi_note_> CPI ratio value of survey (rebased to 2005 on base 1) *</_cpi_note_>;
*<_cpi_note_> cpi brought in from rawdata *</_cpi_note_>;
gen cpi=`cpi2011';
gen cpi2017=`cpi2017';
lab var cpi "CPI ratio value of survey (rebased to 2011 on base 1)";
note cpi: cpi=Price Index;
*</_cpi_>;

*<_cpiperiod_>;
*<_cpiperiod_note_> Periodicity of CPI (year, year&month, year&quarter, weighted) *</_cpiperiod_note_>;
*<_cpiperiod_note_> cpiperiod brought in from rawdata *</_cpiperiod_note_>;
gen cpiperiod="2019m11";
lab var cpiperiod "rebased to 2019m11";
note cpi: cpi=2019;
*</_cpiperiod_>;

*<_harmonization_>;
*<_harmonization_note_> Type of harmonization *</_harmonization_note_>;
*<_harmonization_note_> harmonization brought in from rawdata *</_harmonization_note_>;
gen harmonization="GMD";
lab var harmonization "Type of harmonization";
*</_harmonization_>;

*<_ppp_>;
*<_ppp_note_> PPP conversion factor *</_ppp_note_>;
*<_ppp_note_> ppp brought in from rawdata *</_ppp_note_>;
gen ppp=`ppp2011';
gen ppp2017=`ppp2017';
*</_ppp_>;

*<_educat7_>;
*<_educat7_note_> Highest level of education completed (7 categories) *</_educat7_note_>;
*<_educat7_note_> educat7 brought in from rawdata *</_educat7_note_>;
gen educat7=.;
note educat7: no educat7, educat4 provided;
*</_educat7_>;

*<_educat5_>;
*<_educat5_note_> Highest level of education completed (5 categories) *</_educat5_note_>;
*<_educat5_note_> educat5 brought in from rawdata *</_educat5_note_>;
gen educat5=.;
note educat5: no educat5, educat4 provided;
*</_educat5_>;

*<_educat4_>;
*<_educat4_note_> Highest level of education completed (4 categories) *</_educat4_note_>;
*<_educat4_note_> educat4 brought in from rawdata *</_educat4_note_>;
gen educat4=.;;
	replace educat4 = 1 if edu_everattend==2 | Literate_mothertongue==2;
	replace educat4 = 2 if [ Edu_highestgrade == 0 | Edu_highestgrade == 1 | Edu_highestgrade == 2 | Edu_highestgrade == 3 |Edu_highestgrade == 4 | Edu_highestgrade == 5 | Edu_highestgrade == 6 ] | [Edu_levelattending == 0 | Edu_levelattending == 1 | Edu_levelattending == 2 | Edu_levelattending == 3 |Edu_levelattending == 4 | Edu_levelattending == 5 | Edu_levelattending == 6  ] | HighestCert==7;
	replace educat4 = 3 if [ Edu_highestgrade == 7 | Edu_highestgrade == 8 | Edu_highestgrade == 9 |Edu_highestgrade == 10 | Edu_highestgrade == 11 | Edu_highestgrade == 12 ] | [ Edu_levelattending == 7 | Edu_levelattending == 8 | Edu_levelattending == 9 |Edu_levelattending == 10 | Edu_levelattending == 11 | Edu_levelattending == 12 |  Edu_levelattending == 13 | Edu_levelattending == 14] | [HighestCert==0 | HighestCert==1];
	replace educat4 = 4 if [ HighestCert == 2 | HighestCert == 3 | HighestCert == 4 | HighestCert == 5 | HighestCert == 6 | Edu_levelattending == 15 | Edu_levelattending == 16 | Edu_levelattending == 17 | Edu_levelattending == 18];
	
	lab var educat4 educat4;
	lab define educat4 1 "No education" 2 "Incomplete or complete primary" 3 "Incomplete or complete secondary" 4 "Incomplete or complete tertiary";
	 note educat4: educat4 = Four educational categories;
*</_educat4_>;

*<_educy_>;
*<_educy_note_> Years of completed education *</_educy_note_>;
*<_educy_note_> educy brought in from rawdata *</_educy_note_>;
gen educy=Edu_yearsofschooling; 
replace educy=. if educy>=Age & educy!=. & Age!=.;
lab var educy "numeric, continuous, age in years";
note educy: educy=Number of years of schooling;
*</_educy_>;

*<_hsize_>;
*<_hsize_note_> Household size *</_hsize_note_>;
*<_hsize_note_> hsize brought in from rawdata *</_hsize_note_>;
gen hsize=hhsize;
label var hsize "Household size";
bysort hhid: gen count=_N;
note hsize: hsize equals count;
*</_hsize_>;

*<_literacy_>;
*<_literacy_note_> Individual can read and write *</_literacy_note_>;
*<_literacy_note_> literacy brought in from rawdata *</_literacy_note_>;
gen literacy=Literate_mothertongue; 
replace literacy=0 if literacy==2;
replace literacy=. if literacy==.a; 
lab var literacy "Individual can read and write";
note literacy: literacy=1 "Yes" - literacy=0 "No";
*</_literacy_>;

*<_primarycomp_>;
*<_primarycomp_note_> Primary school completion *</_primarycomp_note_>;
*<_primarycomp_note_> primarycomp brought in from rawdata *</_primarycomp_note_>;
gen primarycomp=.;
replace primarycomp=1 if high_edu==2;
replace primarycomp=0 if primarycomp==.;
lab var primarycomp "Primary school completion";
note primarycomp: primarycomp=1 if complete primary;
*</_primarycomp_>;

*<_school_>;
*<_school_note_> Currently enrolled in or attending school *</_school_note_>;
*<_school_note_> school brought in from rawdata *</_school_note_>;
gen school=Edu_schoolattendance; 
replace school=0 if school==2;
replace school=. if school==.a;
lab var school "Currently enrolled in or attending school";
note school: school=1 "Enrolled" - school=0 "Not enrolled";
*</_school_>;

*<_survey_>;
*<_survey_note_> Type of survey *</_survey_note_>;
*<_survey_note_> survey brought in from rawdata *</_survey_note_>;
gen survey="HIES";
label var survey "Survey acronym";
note survey: survey=HIES;
*</_survey_>;

*<_veralt_>;
*<_veralt_note_> Version number of adaptation to the master data file *</_veralt_note_>;
*<_veralt_note_> veralt brought in from rawdata *</_veralt_note_>;
gen veralt=`va';
lab var veralt "Version number of adaptation to the master data file";
*</_veralt_>;

*<_vermast_>;
*<_vermast_note_> Version number of master data file *</_vermast_note_>;
*<_vermast_note_> vermast brought in from rawdata *</_vermast_note_>;
gen vermast=`vm';
lab var vermast "Version number of master data file";
*</_vermast_>;

*<_welfare_>;
*<_welfare_note_> Welfare aggregate used for estimating international poverty (provided to PovcalNet) *</_welfare_note_>;
*<_welfare_note_> welfare brought in from rawdata *</_welfare_note_>;
gen double welfare=(pcer/12)*`cpi2019m11'/`cpi2019';
lab var welfare "Welfare aggregate used for estimating international poverty (provided to PovcalNet)";
note welfare: welfare=Real yearly per capita expenditure 2019m11;
gen double welfare_ppp11_SM22=(12/365)*welfare/cpi/ppp;
gen double welfare_ppp17_AM22=(12/365)*welfare/cpi2017/ppp2017;
apoverty welfare_ppp11_SM22 [w=weight], line(1.9);
return list;
apoverty welfare_ppp11_SM22 [w=weight], line(3.2);
return list;
apoverty welfare_ppp11_SM22 [w=weight], line(5.5);
return list;
apoverty welfare_ppp17_AM22 [w=weight], line(2.15);
return list;
apoverty welfare_ppp17_AM22 [w=weight], line(3.65);
return list;
apoverty welfare_ppp17_AM22 [w=weight], line(6.85);
return list;
gen double pcer_ppp11=(1/365)*pcer*(111.2734146118164/`cpi2019')/ppp;
apoverty pcer_ppp11 [w=weight], line(5.5);

*</_welfare_>;

*<_welfaredef_>;
*<_welfaredef_note_> Welfare aggregate spatially deflated *</_welfaredef_note_>;
*<_welfaredef_note_> welfaredef brought in from rawdata *</_welfaredef_note_>;
gen welfaredef=(pcer/12);
lab var welfaredef "Welfare aggregate spatially deflated";
note welfaredef: welfaredef=Real yearly per capita expenditure (2019m10-2019m11, 2020m1-2020m3) ;
*</_welfaredef_>;

*<_welfarenom_>;
*<_welfarenom_note_> Welfare aggregate in nominal terms *</_welfarenom_note_>;
*<_welfarenom_note_> welfarenom brought in from rawdata *</_welfarenom_note_>;
gen welfarenom=pce/12;
lab var welfarenom "Welfare aggregate in nominal terms";
note welfarenom: welfarenom=Nominal yearly per capita expenditure;
*</_welfarenom_>;

*<_welfareother_>;
*<_welfareother_note_> Welfare aggregate if different welfare type is used from welfare, welfarenom, welfaredef *</_welfareother_note_>;
*<_welfareother_note_> welfareother brought in from rawdata *</_welfareother_note_>;
gen welfareother=.;
note welfareother: not different from other welfare measure;
*</_welfareother_>;

*<_welfareothertype_>;
*<_welfareothertype_note_> Type of welfare measure (income, consumption or expenditure) for welfareother *</_welfareothertype_note_>;
*<_welfareothertype_note_> welfareothertype brought in from rawdata *</_welfareothertype_note_>;
gen welfareothertype=.;
note welfareothertype: N/A;
*</_welfareothertype_>;

*<_welfaretype_>;
*<_welfaretype_note_> Type of welfare measure (income, consumption or expenditure) for welfare, welfarenom, welfaredef *</_welfaretype_note_>;
*<_welfaretype_note_> welfaretype brought in from rawdata *</_welfaretype_note_>;
gen welfaretype="EXP";
lab var welfaretype "Type of welfare measure (income, consumption or expenditure) for welfare, welfarenom, welfaredef";
note welfaretype: welfaretype=Expenditure;
*</_welfaretype_>;

*<_welfshprosperity_>;
*<_welfshprosperity_note_> Welfare aggregate for shared prosperity (if different from poverty) *</_welfshprosperity_note_>;
*<_welfshprosperity_note_> welfshprosperity brought in from rawdata *</_welfshprosperity_note_>;
gen welfshprosperity=.;
note welfshprosperity: not different from the welfare aggregate used for poverty;
*</_welfshprosperity_>;

*<_welfshprtype_>;
*<_welfshprtype_note_> Welfare type for shared prosperity indicator (income, consumption or expenditure) *</_welfshprtype_note_>;
*<_welfshprtype_note_> welfshprtype brought in from rawdata *</_welfshprtype_note_>;
gen welfshprtype=.;
note welfshprtype: N/A;
*</_welfshprtype_>;

*<_spdef_>;
*<_spdef_note_> Spatial deflator (if one is used) *</_spdef_note_>;
*<_spdef_note_> spdef brought in from rawdata *</_spdef_note_>;
gen spdef=paasche;
*</_spdef_>;

*<_Keep variables_>;
keep countrycode year hhid pid weight weighttype converfactor cpi* cpiperiod harmonization ppp* educat7 educat5 educat4 educy hsize literacy primarycomp school survey veralt vermast welfare welfaredef welfarenom welfareother welfareothertype welfaretype welfshprosperity welfshprtype spdef;
order countrycode year hhid pid weight weighttype;
sort hhid pid ;
*</_Keep variables_>;

*<_Save data file_>;
glo module="COR";
include "${rootdatalib}\_aux\GMD2.0labels.do";
save "$rootdatalib\\`code'\\`yearfolder'\\`gmdfolder'\Data\Harmonized\\`filename'.dta", replace;
*</_Save data file_>;

exit;