/*------------------------------------------------------------------------------
  GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   	NPL_2022_LSS-IV_v01_M_v02_A_SARMD_INC.do	   </_Program name_>
<_Application_>    	STATA 17.0									 <_Application_>
<_Author(s)_>      	Lucía Rampirez <luciarleira@gmail.com>	      </_Author(s)_>
<_Date created_>   	08-2024									   </_Date created_>
<_Date modified>    August 2024							  </_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        	NPL											    </_Country_>
<_Survey Title_>   	LSS-IV									   </_Survey Title_>
<_Survey Year_>    	2022										</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:				08-2024
File:				NPL_2022_LSS-IV_v01_M_v02_A_SARMD_INC.do
First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>
clear all
set more off

local code         	"NPL"
local year         	"2022"
local survey       	"LSS-IV"
local vm           	"01"
local va           	"02"
local type         	"SARMD"
global module       	"INC"
local yearfolder    	"`code'_`year'_`survey'"
local SARMDfolder    	"`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'"
local filename      	"`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'_${module}"
glo output          	"${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\\Data\Harmonized" 
*</_Program setup_>


*<_Datalibweb request_>
use "${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata\\`yearfolder'_v`vm'_M.dta", clear
*</_Datalibweb request_>
*capture drop hhid

* COUNTRYCODE
*<_countrycode_>
*<_countrycode_note_> Country code according to ISO-3166 Alpha-3 *</_countrycode_note_>
gen str countrycode = "`code'"
*</_countrycode_>

* YEAR
*<_year_>
*<_year_note_> 4-digit year of survey based on IHSN standards *</_year_note_>
gen int year = `year'
*</_year_>

* HOUSEHOLD IDENTIFIER
*<_idh_>
*<_idh_note_> Household identifier  *</_idh_note_>
*egen idh = concat(psu hh_number), punct(-)
*</_idh_>

* PERSONAL IDENTIFIER
*<_idp_>
*<_idp_note_> Personal identifier  *</_idp_note_>
*egen idp = concat(idh com), punct(-)

*</_idp_>
*gen hhid = idh
*gen pid = idp
gen weighttype = "PW"

*<_wgt_>
*<_wgt_note_> Variables used to construct Household identifier  *</_wgt_note_>
*capture drop wgt
*gen wgt = base_hh_wt_adj
*</_wgt_>

**************************************************
*** INCOME Variables
**************************************************

*** FIRST ECONOMIC ACTIVITY
*<_isalp_m_>
*<_isalp_m_note_> Salaried income in the main occupation - monetary *</_isalp_m_note_>
egen isalp_m = rsum(daylab_cash_p longbasis_cash_p contract_cash_p), missing
*</_isalp_m_>

*<_isalp_nm_>
*<_isalp_nm_note_> Salaried income in the main occupation - non-monetary *</_isalp_nm_note_>
egen isalp_nm = rsum(daylab_kind_p longbasis_kind_p contract_kind_p ), missing
*</_isalp_nm_>

*<_isep_m_>
*<_isep_m_note_> Self-employed income in the main occupation - monetary *</_isep_m_note_>
egen    isep_m = rsum(inc_nonagric_se_p), missing
*</_isep_m_>

*<_isep_nm_>
*<_isep_nm_note_> Self-employed income in the main occupation - non-monetary *</_isep_nm_note_>
gen  isep_nm = .
*</_isep_nm_>

*<_iempp_m_>
*<_iempp_m_note_> Income by employer in the main occupation - monetary *</_iempp_m_note_>
egen 	iempp_m = rsum(inc_nonagric_emp_p), missing
*</_iempp_m_>

*<_iempp_nm_>
*<_iempp_nm_note_> Income by employer in the main occupation - non-monetary *</_iempp_nm_note_>
gen  iempp_nm = .
*</_iempp_nm_>

*<_iolp_m_>
*<_iolp_m_note_> Other labor income in the main occupation - monetary *</_iolp_m_note_>
egen aux = rsum(isalp_m isalp_nm isep_m isep_nm iempp_m iempp_nm), missing
gen agri_income_main = agri_income_tot if aux==0 | aux==.
gen agri_income_nomain = agri_income_tot if aux!=0 & aux==.
gen iolp_m = agri_income_main 

drop aux*
*</_iolp_m_>

*<_iolp_nm_>
*<_iolp_nm_note_> Other labor income in the main occupation - non-monetary *</_iolp_nm_note_>
gen  iolp_nm = .
*</_iolp_nm_>

*** SECOND AND OTHER ECONOMIC ACTIVITIES

*<_isalnp_m_>
*<_isalnp_m_note_> Salaried income in the non-principal occupation - monetary *</_isalnp_m_note_>
egen isalnp_m = rsum(daylab_cash_np longbasis_cash_np contract_cash_np), missing
*</_isalnp_m_>

*<_isalnp_nm_>
*<_isalnp_nm_note_> Salaried income in the non-principal occupation - non-monetary *</_isalnp_nm_note_>
egen isalnp_nm = rsum(daylab_kind_np longbasis_kind_np contract_kind_np), missing
*</_isalnp_nm_>

*<_isenp_m_>
*<_isenp_m_note_> Self-employed income in the non- principal occupation - monetary *</_isenp_m_note_>
egen isenp_m = rsum(inc_nonagric_se_np), missing
*</_isenp_m_>

*<_isenp_nm_>
*<_isenp_nm_note_> Self-employed income in the non- principal occupation - non-monetary *</_isenp_nm_note_>
gen  isenp_nm = .
*</_isenp_nm_>

*<_iempnp_m_>
*<_iempnp_m_note_> Income by employer in the non-principal occupation - monetary *</_iempnp_m_note_>
egen iempnp_m = rsum(inc_nonagric_emp_np), missing
*</_iempnp_m_>

*<_iempnp_nm_>
*<_iempnp_nm_note_> Income by employer in the non- principal occupation - non-monetary *</_iempnp_nm_note_>
gen  iempnp_nm = .
*</_iempnp_nm_>

*<_iolnp_m_>
*<_iolnp_m_note_> Other labor income in the non-principal - monetary occupation *</_iolnp_m_note_>
gen iolnp_m = agri_income_nomain
*</_iolnp_m_>

*<_iolnp_nm_>
*<_iolnp_nm_note_> Other labor income in the non-principal occupation - non-monetary *</_iolnp_nm_note_>
gen  iolnp_nm = nonfood_own
*</_iolnp_nm_>

*<_ijubi_con_>
*<_ijubi_con_note_> Income for retirement and contributory pensions *</_ijubi_con_note_>
*04	Employee Provident Fund/Citizen Investment Trust
replace inc_other_4 = .		if  q01_04!=1
gen  ijubi_con = inc_other_4
*</_ijubi_con_>

*<_ijubi_ncon_>
*<_ijubi_ncon_note_> Income for retirement and non-contributory pensions *</_ijubi_ncon_note_>
gen  ijubi_ncon = .
*</_ijubi_ncon_>

*<_ijubi_o_>
*<_ijubi_o_note_> Income for retirement and pensions (not identified if contributory or not) *</_ijubi_o_note_>
*05	Pension received from within country					
*06	Pension received from abroad
egen  ijubi_o =  rsum(inc_other_5 inc_other_6), missing
*</_ijubi_o_>

*<_icap_>
*<_icap_note_> Income from capital *</_icap_note_>
/*
INCOME ITEM                    								
01	Savings account							
02	Fixed deposit account							
03	Stocks, shares, treasury bills, etc.		
07	Commission fee, royalties, etc.		
*/
egen icap = rsum(inc_renting_assets inc_renting_housing inc_other_1 inc_other_2 inc_other_3 inc_other_7), missing
*</_icap_>

*<_icct_>
*<_icct_note_> Income from conditional cash transfer programs *</_icct_note_>
gen  icct = inc_transfer_cct
*</_icct_>

*<_inocct_m_>
*<_inocct_m_note_> Income from public transfers not CCT - monetary *</_inocct_m_note_>
*08	Alimony and child support		
egen inocct_m = rsum(inc_transfer_ncct), missing
*</_inocct_m_>

*<_inocct_nm_>
*<_inocct_nm_note_> Income from public transfers not CCT - non-monetary *</_inocct_nm_note_>
gen inocct_nm = .
*</_inocct_nm_>

*<_itrane_ns_>
*<_itrane_ns_note_> Income from unspecified public transfers *</_itrane_ns_note_>
gen  itrane_ns = .
*</_itrane_ns_>

*<_itranext_m_>
*<_itranext_m_note_> Income from foreign remittances - monetary *</_itranext_m_note_>
egen itranext_m = rsum(inc_remit_absent_abroad_m inc_remit_other_abroad_m), missing

*</_itranext_m_>

*<_itranext_nm_>
*<_itranext_nm_note_> Revenue from remittances from abroad - non-monetary *</_itranext_nm_note_>
egen  itranext_nm = rsum(inc_remit_absent_abroad_nm inc_remit_other_abroad_nm), missing

*</_itranext_nm_>

*<_itranint_m_>
*<_itranint_m_note_> Income by private transfers from the country - monetary *</_itranint_m_note_>
*08	Alimony and child support			
egen itranint_m = rsum(inc_remit_absent_nat_m inc_remit_other_nat_m inc_other_8), missing

*</_itranint_m_>

*<_itranint_nm_>
*<_itranint_nm_note_> Income by private transfers from the country - non-monetary *</_itranint_nm_note_>
egen  itranint_nm = rsum(inc_remit_absent_nat_nm inc_remit_other_nat_nm), missing

*</_itranint_nm_>

*<_itran_ns_>
*<_itran_ns_note_> Income from unspecified private transfers *</_itran_ns_note_>
egen  itran_ns = rsum(food_inkind travel_inkind), missing

*</_itran_ns_>

 
*<_inla_otro_>
*<_inla_otro_note_> Other non-labor income *</_inla_otro_note_>
*09	Other income		
egen inla_otro = rsum(inc_other_9 scholarship), missing
*</_inla_otro_>


*<_renta_imp_>
*<_renta_imp_note_> Imputed rent for own-housing *</_renta_imp_note_>
gen renta_imp = implicit_rent
replace renta_imp = . if q01_04!=1
*</_renta_imp_>

* --------------------------------------
*   Spatial and temporal adjustment   *
* --------------------------------------

gen deflator = .
replace deflator = 1.01 if domain ==11
replace deflator = 0.76 if domain ==12
replace deflator = 0.73 if domain ==21
replace deflator = 0.65 if domain ==22
replace deflator = 1.78 if domain ==30
replace deflator = 1.13 if domain ==31
replace deflator = 0.88 if domain ==32
replace deflator = 1.26 if domain ==41
replace deflator = 0.89 if domain ==42
replace deflator = 1.03 if domain ==51
replace deflator = 0.84 if domain ==52
replace deflator = 0.85 if domain ==61
replace deflator = 0.76 if domain ==62
replace deflator = 0.93 if domain ==71
replace deflator = 0.77 if domain ==72


foreach i of varlist isalp_m isalp_nm isep_m isep_nm iempp_m iempp_nm iolp_m iolp_nm isalnp_m isalnp_nm isenp_m isenp_nm iempnp_m iempnp_nm iolnp_m iolnp_nm ijubi_con ijubi_ncon ijubi_o icap icct inocct_m inocct_nm itrane_ns itranext_m itranext_nm itranint_m itranint_nm itran_ns inla_otro renta_imp { 
                          replace `i' = `i' / deflator  
                          } 

*/

*<_members_>
*<_members_note_> Number of members of the household *</_members_note_>
gen  uno = 1
egen members = sum(uno), by(hhid)
*</_members_>

*<_Save data file_>
do   "$rootdofiles\_aux\SecondOrder_INC.do"
sort hhid com
save "$output\\`filename'.dta", replace
*</_Save data file_>
