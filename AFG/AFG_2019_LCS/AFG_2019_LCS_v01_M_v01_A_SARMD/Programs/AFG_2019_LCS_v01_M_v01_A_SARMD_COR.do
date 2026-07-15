/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   `code'_`year'_`survey'_v01_M_v01_A_GMD_COR.do	</_Program name_>
<_Application_>    STATA 16.0	<_Application_>
<_Author(s)_>      jogreen@worldbank.org	</_Author(s)_>
<_Date created_>   05-25-2021	</_Date created_>
<_Date modified>   09-08 2021	</_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        `code'	</_Country_>
<_Survey Title_>   `survey'	</_Survey Title_>
<_Survey Year_>    `year'	</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:	05-25-2020
File:	`code'_`year'_`survey'_v01_M_v01_A_`type'_COR.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>
clear all
set more off

local code         "AFG"
local year         "2019"
local survey       "LCS"
local vm           "01"
local va           "01"
local type         "SARMD"
local yearfolder   "`code'_`year'_`survey'"
local harmfolder    "`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'"
local filename     "`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'_COR"
*</_Program setup_>

* global path on Joe's computer
if ("`c(username)'"=="dekopon") {
	glo basepath "/Users/dekopon/Projects/WORLD BANK/SAR - GMD data harmonization/datalib/`code'/`yearfolder'"
	glo input "${basepath}/`yearfolder'_v`vm'_M"
	glo output "${basepath}/`yearfolder'_v`vm'_M_v`va'_A_`type'/Data/_`type'_"
	
	* load and merge relevant data
	cd "${input}/Data/Stata"
	* poverty data
	use "temp_pov_2016_`year'_consolidated" if year==`year', clear
	* remove variables defined in the main section below
	drop year
	rename hhid HH_ID
	* roster data
	* NOTE: some individuals do not have poverty data.
	merge 1:m HH_ID using "roster_male.dta", nogen assert(using match)
	* disability data
	merge 1:1 HH_ID Mem_ID using "disability", nogen assert(match)
	rename HH_ID hhid_orig
	destring hhid_orig, g(HH_ID)	//note: need to fill in hhid if subsequent merged data contains umatched observations.
	* weight data
	merge m:1 HH_ID using "clusters", nogen assert(match)
}
* global paths on WB computer
else {
	*<_Folder creation_>
	cap mkdir "${rootdatalib}"
	cap mkdir "${rootdatalib}\\`code'"
	cap mkdir "${rootdatalib}\\`code'\\`yearfolder'"
	cap mkdir "${rootdatalib}\\`code'\\`yearfolder'\\`harmfolder'"
	cap mkdir "${rootdatalib}\\`code'\\`yearfolder'\\`harmfolder'\Data"
	cap mkdir "${rootdatalib}\\`code'\\`yearfolder'\\`harmfolder'\Data\Harmonized"
	glo output "${rootdatalib}\\`code'\\`yearfolder'\\`harmfolder'\Data\Harmonized"
	*</_Folder creation_>
	
	*<_Datalibweb request_>
	* load and merge relevant data
	* poverty data
	tempfile individual_level_data
	local dlw "datalibweb, country(`code') year(`year') type(SARRAW) surveyid(`code'_`year'_`survey'_v`vm'_M)"
	qui `dlw' filename(temp_pov_2016_2019_consolidated.dta)
	keep if year==`year'
	drop year
	rename hhid HH_ID
	save `individual_level_data'	//NOTE: The poverty data is actually HH-level data, but will be merged into individual-level data in the next step.
	* roster data
	* NOTE: some individuals do not have poverty data. 
	qui `dlw' filename(roster_male.dta)
	merge m:1 HH_ID using `individual_level_data', gen(m_pov_roster) 
	save `individual_level_data', replace
	* disability data
	qui `dlw' filename(disability.dta)
	merge 1:1 HH_ID Mem_ID using `individual_level_data', nogen 
	rename HH_ID hhid_orig
	destring hhid_orig, g(HH_ID)	//note: need to fill in hhid if subsequent merged data contains umatched observations.
	save `individual_level_data', replace
	* weight data
	qui `dlw' filename(clusters.dta)
	merge 1:m HH_ID using `individual_level_data', nogen  update replace
	*</_Datalibweb request_>
}

* create age for conditions on variables below
g age = q202

*<_countrycode_>
*<_countrycode_note_> country code *</_countrycode_note_>
*<_countrycode_note_> countrycode brought in from rawdata *</_countrycode_note_>
g countrycode = "`code'"
*</_countrycode_>

*<_year_>
*<_year_note_> Year *</_year_note_>
*<_year_note_> year brought in from rawdata *</_year_note_>
g year = `year'
*</_year_>

*<_hhid_>
*<_hhid_note_> Household identifier  *</_hhid_note_>
*<_hhid_note_> hhid brought in from rawdata *</_hhid_note_>
clonevar hhid = hhid_orig
*</_hhid_>

*<_pid_>
*<_pid_note_> Personal identifier  *</_pid_note_>
*<_pid_note_> pid brought in from rawdata *</_pid_note_>
clonevar pid = Mem_ID
*</_pid_>

*<_weight_>
*<_weight_note_> Household weight *</_weight_note_>
*<_weight_note_> weight brought in from rawdata *</_weight_note_>
clonevar weight = hh_weight
*</_weight_>

*<_weighttype_>
*<_weighttype_note_> Weight type (frequency, probability, analytical, importance) *</_weighttype_note_>
*<_weighttype_note_> weighttype brought in from rawdata *</_weighttype_note_>
g weighttype = "PW"
*</_weighttype_>

*<_converfactor_>
*<_converfactor_note_> Conversion factor *</_converfactor_note_>
*<_converfactor_note_> converfactor brought in from rawdata *</_converfactor_note_>
gen converfactor=1
*</_converfactor_>

*<_cpi_>
*<_cpi_note_> CPI ratio value of survey (rebased to 2005 on base 1) *</_cpi_note_>
*<_cpi_note_> cpi brought in from rawdata *</_cpi_note_>
gen cpi=.
*</_cpi_>

*<_cpiperiod_>
*<_cpiperiod_note_> Periodicity of CPI (year, year&month, year&quarter, weighted) *</_cpiperiod_note_>
*<_cpiperiod_note_> cpiperiod brought in from rawdata *</_cpiperiod_note_>
gen cpiperiod=.
*</_cpiperiod_>

*<_harmonization_>
*<_harmonization_note_> Type of harmonization *</_harmonization_note_>
*<_harmonization_note_> harmonization brought in from rawdata *</_harmonization_note_>
gen harmonization="GMD"
*</_harmonization_>

*<_ppp_>
*<_ppp_note_> PPP conversion factor *</_ppp_note_>
*<_ppp_note_> ppp brought in from rawdata *</_ppp_note_>
gen ppp=.
*</_ppp_>

*<_educat7_>
*<_educat7_note_> Highest level of education completed (7 categories) *</_educat7_note_>
*<_educat7_note_> educat7 brought in from rawdata *</_educat7_note_>
gen		educat7 = 1 if q214==2
replace	educat7 = 1 if q215g==0 & q215g==1
replace	educat7 = 2 if q215e==1 & inrange(q215g,1,5)
replace	educat7 = 3 if q215e==1 & q215g==6
replace	educat7 = 4 if q215e==2 | (q215e==3 & inrange(q215g,10,11))
replace	educat7 = 5 if q215e==3 & q215g==12
replace	educat7 = 6 if inlist(q215e,4,5)
replace	educat7 = 7 if inlist(q215e,6,7)
replace educat7 = .2 if q215e==8
* impose survey-specific age limits
replace educat7 = .0 if age<6
note educat7: `code' `year' variable q215e "level completed" = 8 "Islamic school" not categorized, given special missing value (.2).
note educat7: `code' `year' under 6 years old, given special missing value (.0).

*</_educat7_>

*<_educat5_>
*<_educat5_note_> Highest level of education completed (5 categories) *</_educat5_note_>
*<_educat5_note_> educat5 brought in from rawdata *</_educat5_note_>
recode educat7 (4=3) (5=4) (6 7=5), gen(educat5)
*</_educat5_>

*<_educat4_>
*<_educat4_note_> Highest level of education completed (4 categories) *</_educat4_note_>
*<_educat4_note_> educat4 brought in from rawdata *</_educat4_note_>
recode educat7 (3=2) (4 5=3) (6 7=4), gen(educat4)
*</_educat4_>

*<_educy_>
*<_educy_note_> Years of completed education *</_educy_note_>
*<_educy_note_> educy brought in from rawdata *</_educy_note_>
g educy = q215g
replace educy=. if educy>=age
*</_educy_>

*<_hsize_>
*<_hsize_note_> Household size *</_hsize_note_>
*<_hsize_note_> hsize brought in from rawdata *</_hsize_note_>
g hsize = hhsize
*</_hsize_>

*<_literacy_>
*<_literacy_note_> Individual can read and write *</_literacy_note_>
*<_literacy_note_> literacy brought in from rawdata *</_literacy_note_>
g literacy = (q213==1) if inlist(q213,1,2)
*</_literacy_>

*<_primarycomp_>
*<_primarycomp_note_> Primary school completion *</_primarycomp_note_>
*<_primarycomp_note_> primarycomp brought in from rawdata *</_primarycomp_note_>
recode educat7 (1/2=0) (3/7=1) (*=.), gen(primarycomp)
*</_primarycomp_>

*<_school_>
*<_school_note_> Currently enrolled in or attending school *</_school_note_>
*<_school_note_> school brought in from rawdata *</_school_note_>
gen school = (q217==1) if inlist(q217,1,2)
*</_school_>

*<_survey_>
*<_survey_note_> Type of survey *</_survey_note_>
*<_survey_note_> survey brought in from rawdata *</_survey_note_>
g survey = "`survey'"
*</_survey_>

*<_veralt_>
*<_veralt_note_> Version number of adaptation to the master data file *</_veralt_note_>
*<_veralt_note_> veralt brought in from rawdata *</_veralt_note_>
gen veralt=`va'
*</_veralt_>

*<_vermast_>
*<_vermast_note_> Version number of master data file *</_vermast_note_>
*<_vermast_note_> vermast brought in from rawdata *</_vermast_note_>
gen vermast=`vm'
*</_vermast_>

*<_welfare_>
*<_welfare_note_> Welfare aggregate used for estimating international poverty (provided to PovcalNet) *</_welfare_note_>
*<_welfare_note_> welfare brought in from rawdata *</_welfare_note_>
g welfare = pcexall_adj
*</_welfare_>

*<_welfaredef_>
*<_welfaredef_note_> Welfare aggregate spatially deflated *</_welfaredef_note_>
*<_welfaredef_note_> welfaredef brought in from rawdata *</_welfaredef_note_>
gen welfaredef = pcexall_adj
*</_welfaredef_>

*<_welfarenom_>
*<_welfarenom_note_> Welfare aggregate in nominal terms *</_welfarenom_note_>
*<_welfarenom_note_> welfarenom brought in from rawdata *</_welfarenom_note_>
egen hexnom = rowtotal(hexnom_f hexnom_n hexnom_d hexnom_r), missing
gen welfarenom = hexnom/hh_size
*</_welfarenom_>

*<_welfareother_>
*<_welfareother_note_> Welfare aggregate if different welfare type is used from welfare, welfarenom, welfaredef *</_welfareother_note_>
*<_welfareother_note_> welfareother brought in from rawdata *</_welfareother_note_>
gen welfareother = pcexf_adj
*</_welfareother_>

*<_welfareothertype_>
*<_welfareothertype_note_> Type of welfare measure (income, consumption or expenditure) for welfareother *</_welfareothertype_note_>
*<_welfareothertype_note_> welfareothertype brought in from rawdata *</_welfareothertype_note_>
gen welfareothertype="FOOD"
*</_welfareothertype_>

*<_welfaretype_>
*<_welfaretype_note_> Type of welfare measure (income, consumption or expenditure) for welfare, welfarenom, welfaredef *</_welfaretype_note_>
*<_welfaretype_note_> welfaretype brought in from rawdata *</_welfaretype_note_>
gen welfaretype = "CON"
*</_welfaretype_>

*<_welfshprosperity_>
*<_welfshprosperity_note_> Welfare aggregate for shared prosperity (if different from poverty) *</_welfshprosperity_note_>
*<_welfshprosperity_note_> welfshprosperity brought in from rawdata *</_welfshprosperity_note_>
gen welfshprosperity=.
*</_welfshprosperity_>

*<_welfshprtype_>
*<_welfshprtype_note_> Welfare type for shared prosperity indicator (income, consumption or expenditure) *</_welfshprtype_note_>
*<_welfshprtype_note_> welfshprtype brought in from rawdata *</_welfshprtype_note_>
gen welfshprtype=.
*</_welfshprtype_>

*<_spdef_>
*<_spdef_note_> Spatial deflator (if one is used) *</_spdef_note_>
*<_spdef_note_> spdef brought in from rawdata *</_spdef_note_>
gen spdef=Laspeyres_z
*</_spdef_>

*<_tetempmpdef_>
*<_tempdef_note_> Temporal deflator (if one is used) *</_spdef_note_>
*<_def_note_> base is 1st Q *</_spdef_note_>
gen tempdef=adj_fact_nf
*</_tempdef_>

*<_Keep variables_>
keep countrycode year hhid pid weight weighttype converfactor cpi cpiperiod harmonization ppp educat7 educat5 educat4 educy hsize literacy primarycomp school survey veralt vermast welfare welfaredef welfarenom welfareother welfareothertype welfaretype welfshprosperity welfshprtype spdef tempdef
order countrycode year hhid pid weight weighttype
sort hhid pid
*</_Keep variables_>

*<_Save data file_>
compress
if ("`c(username)'"=="dekopon") save "${output}/`filename'", replace
else save "${output}/`filename'.dta" , replace
*</_Save data file_>
