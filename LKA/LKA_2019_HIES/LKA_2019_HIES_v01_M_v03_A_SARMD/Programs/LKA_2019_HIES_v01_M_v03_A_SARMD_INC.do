/*------------------------------------------------------------------------------
  SARMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   	LKA_2019_HIES_v01_M_v03_A_SAMRD_INC.do	   </_Program name_>
<_Application_>    	STATA 17.0									 <_Application_>
<_Author(s)_>      	Leo Tornarolli <tornarolli@gmail.com>		  </_Author(s)_>
<_Date created_>   	11-2023									   </_Date created_>
<_Date modified>   	October 2024 							  </_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        	LKA											    </_Country_>
<_Survey Title_>   	HIES									   </_Survey Title_>
<_Survey Year_>    	2019										</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:				10-2024
File:				LKA_2019_HIES_v01_M_v03_A_SAMRD_INC.do
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
global module       	"INC"
local yearfolder    	"`code'_`year'_`survey'"
local SARMDfolder    	"`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'"
local filename      	"`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'_${module}"
glo output          	"${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\\Data\Harmonized" 
*</_Program setup_>


*<_Datalibweb request_>
use "${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata\\`yearfolder'_v`vm'_M.dta", clear
*</_Datalibweb request_>


* COUNTRYCODE
*<_countrycode_>
*<_countrycode_note_> Country code according to ISO-3166 Alpha-3 *</_countrycode_note_>
*gen str countrycode = "`code'"
*</_countrycode_>

* YEAR
*<_year_>
*<_year_note_> 4-digit year of survey based on IHSN standards *</_year_note_>
*gen int year = `year'
*</_year_>

* HOUSEHOLD IDENTIFIER
*<_idh_>
*<_idh_note_> Household identifier  *</_idh_note_>
gen idh = hhid
*</_idh_>

* PERSONAL IDENTIFIER
*<_idp_>
*<_idp_note_> Personal identifier  *</_idp_note_>
egen idp = concat(idh pid), punct(-)
*</_idp_>

gen weighttype = "PW"

*<_wgt_>
*<_wgt_note_> Variables used to construct Household identifier  *</_wgt_note_>
capture drop wgt
gen wgt = finalweight
*</_wgt_>


**************************************************
*** INCOME Variables
**************************************************

*** FIRST ECONOMIC ACTIVITY
*<_isalp_m_>
*<_isalp_m_note_> Salaried income in the main occupation - monetary *</_isalp_m_note_>
egen isalp_m = rsum(employment_income1), missing
*</_isalp_m_>

*<_isalp_nm_>
*<_isalp_nm_note_> Salaried income in the main occupation - non-monetary *</_isalp_nm_note_>
gen isalp_nm = .
*</_isalp_nm_>

*<_isep_m_>
*<_isep_m_note_> Self-employed income in the main occupation - monetary *</_isep_m_note_>
egen isep_m = rsum(agricultural_1 non_agricultural_1), missing
*</_isep_m_>

*<_isep_nm_>
*<_isep_nm_note_> Self-employed income in the main occupation - non-monetary *</_isep_nm_note_>
gen  isep_nm = .
*</_isep_nm_>

*<_iempp_m_>
*<_iempp_m_note_> Income by employer in the main occupation - monetary *</_iempp_m_note_>
gen iempp_m = .
*</_iempp_m_>

*<_iempp_nm_>
*<_iempp_nm_note_> Income by employer in the main occupation - non-monetary *</_iempp_nm_note_>
gen  iempp_nm = .
*</_iempp_nm_>

*<_iolp_m_>
*<_iolp_m_note_> Other labor income in the main occupation - monetary *</_iolp_m_note_>
gen iolp_m = .
*</_iolp_m_>

*<_iolp_nm_>
*<_iolp_nm_note_> Other labor income in the main occupation - non-monetary *</_iolp_nm_note_>
gen  iolp_nm = .
*</_iolp_nm_>


*** SECOND AND OTHER ECONOMIC ACTIVITIES

*<_isalnp_m_>
*<_isalnp_m_note_> Salaried income in the non-principal occupation - monetary *</_isalnp_m_note_>
egen isalnp_m = rsum(employment_income2), missing
*</_isalnp_m_>

*<_isalnp_nm_>
*<_isalnp_nm_note_> Salaried income in the non-principal occupation - non-monetary *</_isalnp_nm_note_>
gen isalnp_nm = .
*</_isalnp_nm_>

*<_isenp_m_>
*<_isenp_m_note_> Self-employed income in the non- principal occupation - monetary *</_isenp_m_note_>
egen isenp_m = rsum(agricultural_2 non_agricultural_2), missing
*</_isenp_m_>

*<_isenp_nm_>
*<_isenp_nm_note_> Self-employed income in the non- principal occupation - non-monetary *</_isenp_nm_note_>
gen  isenp_nm = .
*</_isenp_nm_>

*<_iempnp_m_>
*<_iempnp_m_note_> Income by employer in the non-principal occupation - monetary *</_iempnp_m_note_>
gen iempnp_m = .
*</_iempnp_m_>

*<_iempnp_nm_>
*<_iempnp_nm_note_> Income by employer in the non- principal occupation - non-monetary *</_iempnp_nm_note_>
gen  iempnp_nm = .
*</_iempnp_nm_>

*<_iolnp_m_>
*<_iolnp_m_note_> Other labor income in the non-principal - monetary occupation *</_iolnp_m_note_>
gen iolnp_m = .
*</_iolnp_m_>

*<_iolnp_nm_>
*<_iolnp_nm_note_> Other labor income in the non-principal occupation - non-monetary *</_iolnp_nm_note_>
gen  iolnp_nm = .
*</_iolnp_nm_>



*<_ijubi_con_>
*<_ijubi_con_note_> Income for retirement and contributory pensions *</_ijubi_con_note_>
gen  ijubi_con = .
*</_ijubi_con_>

*<_ijubi_ncon_>
*<_ijubi_ncon_note_> Income for retirement and non-contributory pensions *</_ijubi_ncon_note_>
gen  ijubi_ncon = .
*</_ijubi_ncon_>

*<_ijubi_o_>
*<_ijubi_o_note_> Income for retirement and pensions (not identified if contributory or not) *</_ijubi_o_note_>
gen  ijubi_o = pension
*</_ijubi_o_>



*<_icap_>
*<_icap_note_> Income from capital *</_icap_note_>
egen icap = rsum(dividends property_rents), missing
*</_icap_>



*<_icct_>
*<_icct_note_> Income from conditional cash transfer programs *</_icct_note_>
gen  icct = .
*</_icct_>

*<_inocct_m_>
*<_inocct_m_note_> Income from public transfers not CCT - monetary *</_inocct_m_note_>
egen inocct_m = rsum(disability_and_relief samurdhi elder tb scholar), missing
*</_inocct_m_>

*<_inocct_nm_>
*<_inocct_nm_note_> Income from public transfers not CCT - non-monetary *</_inocct_nm_note_>
egen inocct_nm = rsum(sc_lunch threeposha)
*</_inocct_nm_>

*<_itrane_ns_>
*<_itrane_ns_note_> Income from unspecified public transfers *</_itrane_ns_note_>
gen  itrane_ns = .
*</_itrane_ns_>



*<_itranext_m_>
*<_itranext_m_note_> Income from foreign remittances - monetary *</_itranext_m_note_>
egen itranext_m = rsum(income_forign), missing
*</_itranext_m_>

*<_itranext_nm_>
*<_itranext_nm_note_> Revenue from remittances from abroad - non-monetary *</_itranext_nm_note_>
gen  itranext_nm = .
*</_itranext_nm_>

*<_itranint_m_>
*<_itranint_m_note_> Income by private transfers from the country - monetary *</_itranint_m_note_>
egen itranint_m = rsum(income_local), missing
*</_itranint_m_>

*<_itranint_nm_>
*<_itranint_nm_note_> Income by private transfers from the country - non-monetary *</_itranint_nm_note_>
gen  itranint_nm = .
*</_itranint_nm_>

*<_itran_ns_>
*<_itran_ns_note_> Income from unspecified private transfers *</_itran_ns_note_>
gen  itran_ns =.
*</_itran_ns_>

 
*<_inla_otro_>
*<_inla_otro_note_> Other non-labor income *</_inla_otro_note_>
replace self_food = . 		if  relationship!=1
replace self_non_food = .	if  relationship!=1
egen inla_otro = rsum(other_income creditcard self_food self_non_food), missing
*</_inla_otro_>


*<_renta_imp_>
*<_renta_imp_note_> Imputed rent for own-housing *</_renta_imp_note_>
egen renta_imp = rsum(nf_inkind_value), missing
*</_renta_imp_>

gen     hogarsec = 0
replace hogarsec = 1		if  residence==2

*<_members_>
*<_members_note_> Number of members of the household *</_members_note_>
gen  uno = 1				if  hogarsec==0
egen members = sum(uno), by(hhid)
*</_members_>


*<_Save data file_>
do   "$rootdofiles\_aux\SecondOrder_INC.do"
save "$output\\`filename'.dta", replace
*</_Save data file_>
