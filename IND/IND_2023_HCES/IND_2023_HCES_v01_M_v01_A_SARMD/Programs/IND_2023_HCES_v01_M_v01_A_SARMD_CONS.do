/*----------------------------------------------------------------------------------
  SARMD Harmonization
------------------------------------------------------------------------------------
<_Program name_>   		IND_2023_HCES_v01_M_v01_SARMD_DWL.do	  	   </_Program name_>
<_Application_>    		STATA 17.0									 <_Application_>
<_Author(s)_>      		Leo Tornarolli <tornarolli@gmail.com>		  </_Author(s)_>
<_Date created_>   		02-2026									   </_Date created_>
<_Date modified>    	February 2026						 	  </_Date modified_>
------------------------------------------------------------------------------------
<_Country_>        		IND											    </_Country_>
<_Survey Title_>   		HCES									   </_Survey Title_>
<_Survey Year_>    		2023-2024									</_Survey Year_>
------------------------------------------------------------------------------------
<_Version Control_>
Date:					02-2026
File:					IND_2023_HCES_v01_M_v01_SARMD_DWL.do
First version
</_Version Control_>
----------------------------------------------------------------------------------*/

*<_Program setup_>
clear all
set more off

local code         		"IND"
local year         		"2023"
local survey       		"HCES"
local vm           		"01"
local va           		"01"
local type         		"SARMD"
global module       	"CONS"
local yearfolder    	"`code'_`year'_`survey'"
local SARMDfolder    	"`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'"
local filename      	"`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'_${module}"
glo output          	"${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\\Data\Harmonized" 
*</_Program setup_>


*<_Datalibweb request_>
use "${input}\\`yearfolder'_v`vm'_M.dta", clear
*merge m:1 hhid using "${input}\\IND_PRIMUS_2023-24.dta", keepusing(sector state stratum welfarenom_base welfaredef_base pwt welfarenom_final welfaredef_final cpi_2022 cpi_2017 cpi_2021 hhwt hhsize)
*drop _merge
*</_Datalibweb request_>


*<_countrycode_> 
*<_countrycode_note_> Country code according to ISO-3166 Alpha-3 *</_countrycode_note_>
gen countrycode = "`code'"
gen code = countrycode
*</_countrycode_>

*<_year_>
*<_year_note_> 4-digit year of survey based on IHSN standards *</_year_note_>
capture drop year 
gen year = 2023
*</_year_>

*<_hhid_>
*<_hhid_note_> Household identifier  *</_hhid_note_>
/*<_hhid_note_> . *</_hhid_note_>*/
*<_hhid_note_> hhid brought in from rawdata *</_hhid_note_>
*</_hhid_>

*<_pid_>
*<_pid_note_> Personal identifier  *</_pid_note_>
/*<_pid_note_> country specific *</_pid_note_>*/
*<_pid_note_> pid brought in from rawdata *</_pid_note_>
*</_pid_>

*<_weight_>
*<_weight_note_> Household weight  *</_weight_note_>
/*<_weight_note_> Survey specific information *</_weight_note_>*/
clonevar weight = hhwt
clonevar weight_p = weight
*</_weight_>

*<_weighttype_>
*<_weighttype_note_> Weight type (frequency, probability, analytical, importance) *</_weighttype_note_>
*<_weighttype_note_> weighttype brought in from rawdata *</_weighttype_note_>
gen weighttype = "PW"
*</_weighttype_>

*<_hhsize_>
*<_hhsize_note_> Total number of residents (regular members) in the household, excluding maids and servants *</_hhsize_note_>
/*<_hhsize_note_>  *</_hhsize_note_>*/
*<_hhsize_note_> hhsize brought in from rawdata *</_hhsize_note_>
*</_hhsize_>

*<_ctry_adq_>
*<_ctry_adq_note_> Country-specific adult equivalent scale *</_ctry_adq_note_>
/*<_ctry_adq_note_> *</_ctry_adq_note_>*/
*<_ctry_adq_note_> ctry_adq brought in from rawdata *</_ctry_adq_note_>
gen ctry_adq = .
*</_ctry_adq_>

*<_fdtexp_own_>
*<_fdtexp_own_note_> Total nominal annual household own food consumption *</_fdtexp_own_note_>
/*<_fdtexp_own_note_> *</_fdtexp_own_note_>*/
*<_fdtexp_own_note_> fdtexp_own brought in from rawdata *</_fdtexp_own_note_>
gen fdtexp_own = .
*</_fdtexp_own_>

*<_fdtexp_buy_>
*<_fdtexp_buy_note_> Total nominal annual household food actual purchases *</_fdtexp_buy_note_>
/*<_fdtexp_buy_note_> *</_fdtexp_buy_note_>*/
*<_fdtexp_buy_note_> fdtexp_buy brought in from rawdata *</_fdtexp_buy_note_>
gen fdtexp_buy = .
*</_fdtexp_buy_>

*<_fdtexp_>
*<_fdtexp_note_> Total nominal annual household food expenditures *</_fdtexp_note_>
/*<_fdtexp_note_> *</_fdtexp_note_>*/
*<_fdtexp_note_> fdtexp brought in from rawdata *</_fdtexp_note_>
gen fdtexp = .
*</_fdtexp_>

*<_nfdtexp_>
*<_nfdtexp_note_> Total nominal annual household non-food expenditures *</_nfdtexp_note_>
/*<_nfdtexp_note_> *</_nfdtexp_note_>*/
*<_nfdtexp_note_> nfdtexp brought in from rawdata *</_nfdtexp_note_>
gen nfdtexp = .
*</_nfdtexp_>

*<_totexp_>
*<_totexp_note_> Total nominal annual household non-food expenditures *</_totexp_note_>
/*<_totexp_note_> *</_totexp_note_>*/
*<_totexp_note_> totexp brought in from rawdata *</_totexp_note_>
gen totexp = .
*</_totexp_>

*<_fdpindex_>
*<_fdpindex_note_> Country-specific food price index *</_fdpindex_note_>
/*<_fdpindex_note_> *</_fdpindex_note_>*/
*<_fdpindex_note_> fdpindex brought in from rawdata *</_fdpindex_note_>
gen fdpindex = .
*</_fdpindex_>

*<_nfdpindex_>
*<_nfdpindex_note_> Country-specific non-food price index *</_nfdpindex_note_>
/*<_nfdpindex_note_> *</_nfdpindex_note_>*/
*<_nfdpindex_note_> nfdpindex brought in from rawdata *</_nfdpindex_note_>
gen nfdpindex = .
*</_nfdpindex_>

*<_pindex_>
*<_pindex_note_> Country-specific price index *</_pindex_note_>
/*<_pindex_note_> *</_pindex_note_>*/
*<_pindex_note_> pindex brought in from rawdata *</_pindex_note_>
gen pindex = .
*</_pindex_>

*<_ctry_totexp_>
*<_ctry_totexp_note_> Welfare measure used to measure poverty *</_ctry_totexp_note_>
/*<_ctry_totexp_note_> *</_ctry_totexp_note_>*/
*<_ctry_totexp_note_> ctry_totexp brought in from IND *</_ctry_totexp_note_>
gen ctry_totexp = .		// welfaredef_final
*</_ctry_totexp_>

*<_pl_ext_>
*<_pl_ext_note_> Country-specific extreme poverty line *</_pl_ext_note_>
/*<_pl_ext_note_> *</_pl_ext_note_>*/
*<_pl_ext_note_> pl_ext brought in from IND *</_pl_ext_note_>
gen pl_ext = .
*</_pl_ext_>

*<_pl_abs_>
*<_pl_abs_note_> Absolute or overall poverty line *</_pl_abs_note_>
/*<_pl_abs_note_> *</_pl_abs_note_>*/
*<_pl_abs_note_> pl_abs brought in from IND *</_pl_abs_note_>
gen pl_abs = .
*</_pl_abs_>

*gen uno = 1
*egen hhsize = sum(uno), by(hhid)

*<_Keep variables_>
order countrycode year hhid pid weight weighttype
sort  hhid pid
*</_Keep variables_>


*<_Save data file_>
compress
quietly do 	"$rootdofiles\_aux\Labels_GMD3.0.do"
save 		"$output\\`filename'.dta", replace
*</_Save data file_>
 
 