/*------------------------------------------------------------------------------
  GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   	LKA_2019_HIES_v01_M_v03_A_SARMD_COR.do	   </_Program name_>
<_Application_>    	STATA 17.0									 <_Application_>
<_Author(s)_>       Joe Green 		<jogreen@worldbank.org>		  </_Author(s)_>
<_Date created_>    06-2022	                                   </_Date created_>
<_Author(s)_>      	Leo Tornarolli 	<tornarolli@gmail.com>		  </_Author(s)_>
<_Date modified_>   10-2024									  </_Date modified_>
<_Date modified>    October 2024							  </_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        	LKA											    </_Country_>
<_Survey Title_>   	HIES									   </_Survey Title_>
<_Survey Year_>    	2019										</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:				10-2024
File:				LKA_2019_HIES_v01_M_v03_A_SARMD_COR.do
First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>
clear all
set more off

local code         		"LKA"
local year         		"2019"
local survey       		"HIES"
local vm           		"01"
local va           		"03"
local type         		"SARMD"
global module       	"COR"
local yearfolder    	"`code'_`year'_`survey'"
local SARMDfolder    	"`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'"
local filename      	"`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'_${module}"
glo output          	"${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\\Data\Harmonized" 
*</_Program setup_>

*<_Datalibweb request_>
use   "${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata\\`yearfolder'_v`vm'_M.dta", clear
sort  hhid pid
merge 1:1 hhid pid using "${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\Data\Harmonized\\`yearfolder'_v`vm'_M_v`va'_A_`type'_IND.dta" 
drop _merge
*</_Datalibweb request_>

*<_countrycode_>
*<_countrycode_note_> country code *</_countrycode_note_>
*<_countrycode_note_> countrycode brought in from rawdata *</_countrycode_note_>
*gen countrycode = code
* NOTE: this variable already exists in harmonized form
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

*<_pid_>
*<_pid_note_> Personal identifier  *</_pid_note_>
*<_pid_note_> pid brought in from rawdata *</_pid_note_>
* NOTE: this variable already exists in harmonized form
*</_pid_>

*<_weight_>
*<_weight_note_> Household weight *</_weight_note_>
*<_weight_note_> weight brought in from rawdata *</_weight_note_>
clonevar weight = finalweight
*</_weight_>

*<_weighttype_>
*<_weighttype_note_> Weight type (frequency, probability, analytical, importance) *</_weighttype_note_>
*<_weighttype_note_> weighttype brought in from rawdata *</_weighttype_note_>
*gen weighttype = "PW"
*</_weighttype_>

*<_converfactor_>
*<_converfactor_note_> Conversion factor *</_converfactor_note_>
*<_converfactor_note_> converfactor brought in from rawdata *</_converfactor_note_>
gen converfactor = 1
*</_converfactor_>

*<_cpi_>
*<_cpi_note_> CPI ratio value of survey (rebased to 2005 on base 1) *</_cpi_note_>
*<_cpi_note_> cpi brought in from datalibweb cpi *</_cpi_note_>
sum cpi*
*</_cpi_>

*<_cpiperiod_>
*<_cpiperiod_note_> Periodicity of CPI (year, year&month, year&quarter, weighted) *</_cpiperiod_note_>
*<_cpiperiod_note_> cpiperiod brought in from rawdata *</_cpiperiod_note_>
replace cpiperiod = 2019
*</_cpiperiod_>

*<_harmonization_>
*<_harmonization_note_> Type of harmonization *</_harmonization_note_>
*<_harmonization_note_> harmonization brought in from rawdata *</_harmonization_note_>
gen harmonization = "GMD"
*</_harmonization_>

*<_ppp_>
*<_ppp_note_> PPP conversion factor *</_ppp_note_>
*<_ppp_note_> ppp brought in from datalibweb cpi *</_ppp_note_>
sum ppp*
*</_ppp_>

*<_educat7_>
*<_educat7_note_> Highest level of education completed (7 categories) *</_educat7_note_>
*<_educat7_note_> educat7 brought in from rawdata *</_educat7_note_>
*</_educat7_>

*<_educat5_>
*<_educat5_note_> Highest level of education completed (5 categories) *</_educat5_note_>
*<_educat5_note_> educat5 brought in from rawdata *</_educat5_note_>
*</_educat5_>

*<_educat4_>
*<_educat4_note_> Highest level of education completed (4 categories) *</_educat4_note_>
*<_educat4_note_> educat4 brought in from rawdata *</_educat4_note_>
*</_educat4_>

*<_educy_>
*<_educy_note_> Years of completed education *</_educy_note_>
*<_educy_note_> educy brought in from rawdata *</_educy_note_>
*</_educy_>

*<_hsize_>
*<_hsize_note_> Household size *</_hsize_note_>
*<_hsize_note_> hsize brought in from rawdata *</_hsize_note_>
*</_hsize_>

*<_literacy_>
*<_literacy_note_> Individual can read and write *</_literacy_note_>
*<_literacy_note_> literacy brought in from rawdata *</_literacy_note_>
*gen literacy=.
*</_literacy_>

*<_everattend_>
*<_everattend_note_> Ever attended school *</_everattend_note_>
*<_everattend_note_> everattend brought in from rawdata *</_everattend_note_>
*</_everattend_>

*<_primarycomp_>
*<_primarycomp_note_> Primary school completion *</_primarycomp_note_>
*<_primarycomp_note_> primarycomp brought in from rawdata *</_primarycomp_note_>
recode educat7 (1 2=0) (3/7=1)  (8=.) if everattend==1, gen(primarycomp)
*</_primarycomp_>

*<_school_>
*<_school_note_> Currently enrolled in or attending school *</_school_note_>
*<_school_note_> school brought in from rawdata *</_school_note_>
recode curr_educ (1 9=0) (2/6=1) (*=.), g(school)
*</_school_>

*<_survey_>
*<_survey_note_> Type of survey *</_survey_note_>
*<_survey_note_> survey brought in from rawdata *</_survey_note_>
*</_survey_>

*<_veralt_>
*<_veralt_note_> Version number of adaptation to the master data file *</_veralt_note_>
*<_veralt_note_> veralt brought in from rawdata *</_veralt_note_>
*</_veralt_>

*<_vermast_>
*<_vermast_note_> Version number of master data file *</_vermast_note_>
*<_vermast_note_> vermast brought in from rawdata *</_vermast_note_>
*</_vermast_>

*<_welfarenom_>
*<_welfarenom_note_> Welfare aggregate in nominal terms *</_welfarenom_note_>
*<_welfarenom_note_> welfarenom brought in from rawdata *</_welfarenom_note_>
*</_welfarenom_>

*<_welfaredef_>
*<_welfaredef_note_> Welfare aggregate spatially deflated *</_welfaredef_note_>
*<_welfaredef_note_> welfaredef brought in from rawdata *</_welfaredef_note_>
*</_welfaredef_>

*<_welfare_>
*<_welfare_note_> Welfare aggregate used for estimating international poverty (provided to PovcalNet) *</_welfare_note_>
*<_welfare_note_> welfare brought in from rawdata *</_welfare_note_>
*</_welfare_>

*<_welfareother_>
*<_welfareother_note_> Welfare aggregate if different welfare type is used from welfare, welfarenom, welfaredef *</_welfareother_note_>
*<_welfareother_note_> welfareother brought in from rawdata *</_welfareother_note_>
*</_welfareother_>

*<_welfareothertype_>
*<_welfareothertype_note_> Type of welfare measure (income, consumption or expenditure) for welfareother *</_welfareothertype_note_>
*<_welfareothertype_note_> welfareothertype brought in from rawdata *</_welfareothertype_note_>
*</_welfareothertype_>

*<_welfaretype_>
*<_welfaretype_note_> Type of welfare measure (income, consumption or expenditure) for welfare, welfarenom, welfaredef *</_welfaretype_note_>
*<_welfaretype_note_> welfaretype brought in from rawdata *</_welfaretype_note_>
*</_welfaretype_>

*<_welfshprosperity_>
*<_welfshprosperity_note_> Welfare aggregate for shared prosperity (if different from poverty) *</_welfshprosperity_note_>
*<_welfshprosperity_note_> welfshprosperity brought in from rawdata *</_welfshprosperity_note_>
*</_welfshprosperity_>

*<_welfshprtype_>
*<_welfshprtype_note_> Welfare type for shared prosperity indicator (income, consumption or expenditure) *</_welfshprtype_note_>
*<_welfshprtype_note_> welfshprtype brought in from rawdata *</_welfshprtype_note_>
gen welfshprtype = .
*</_welfshprtype_>

*<_spdef_>
*<_spdef_note_> Spatial deflator (if one is used) *</_spdef_note_>
*<_spdef_note_> spdef brought in from rawdata *</_spdef_note_>
*</_spdef_>


*<_Keep variables_>
order countrycode year hhid pid weight weighttype
sort  hhid pid
*</_Keep variables_>


*<_Save data file_>
quietly do 	"$rootdofiles\_aux\Labels_GMD2.0.do"
save 		"$output\\`filename'.dta", replace
*</_Save data file_>
