/*------------------------------------------------------------------------------
  SARMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   		PAK_2011_HIES_v02_M_v01_A_SAMRD_INC.do </_Program name_>
<_Application_>    		STATA 17.0							     <_Application_>
<_Author(s)_>      		tornarolli@gmail.com	          		  </_Author(s)_>
<_Date created_>   		03-17-2025	                           </_Date created_>
<_Date modified>   		03-17-2025	                          </_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        		PAK											</_Country_>
<_Survey Title_>   		HIES								   </_Survey Title_>
<_Survey Year_>    		2011									</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:					03-17-2025
File:					PAK_2011_HIES_v02_M_v01_A_SAMRD_INC.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>
clear all
set more off

local code         		"PAK"
local year         		"2011"
local survey       		"HIES"
local vm           		"02"
local va           		"01"
local type         		"SARMD"
global module       		"INC"
local yearfolder    		"`code'_`year'_`survey'"
local SARMDfolder    		"`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'"
local filename      		"`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'_${module}"
glo output          		"${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\\Data\Harmonized" 
*</_Program setup_>


*<_Datalibweb request_>
use "${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata\\`yearfolder'_v`vm'_M.dta", clear
*</_Datalibweb request_>
capture drop hhid

* COUNTRYCODE
*<_countrycode_>
*<_countrycode_note_> Country code according to ISO-3166 Alpha-3 *</_countrycode_note_>
gen str countrycode = "`code'"
*</_countrycode_>

* YEAR
*<_year_>
*<_year_note_> 4-digit year of survey based on IHSN standards *</_year_note_>
capture drop year
gen int year = `year'
*</_year_>

* HOUSEHOLD IDENTIFIER
*<_idh_>
*<_idh_note_> Household identifier  *</_idh_note_>
gen double idh_aux = hhcode
gen idh = string(idh_aux,"%16.0g")
*</_idh_>

* PERSONAL IDENTIFIER
*<_idp_>
*<_idp_note_> Personal identifier  *</_idp_note_>
gen double idp_aux= hhcode*100+idc
gen idp = string(idp_aux,"%16.0g")
*</_idp_>

gen hhid = idh
gen pid = idp
gen weighttype = "PW"

*<_wgt_>
*<_wgt_note_> Variables used to construct Household identifier  *</_wgt_note_>
capture drop wgt
gen wgt = weight
*</_wgt_>


**************************************************
*** INCOME Variables
**************************************************
*** FIRST ECONOMIC ACTIVITY
*<_isalp_m_>
*<_isalp_m_note_> Salaried income in the main occupation - monetary *</_isalp_m_note_>
* S1BQ08: How much money in cash, did you earn during the last month?
* S1BQ09: How many months, did you work during the last year?
* S1BQ10: How much money in cash, did you earn during the last year?
egen isalp_m = rsum(monthly_income annual_income)		if  s1bq06==4, missing
*</_isalp_m_>

*<_isalp_nm_>
*<_isalp_nm_note_> Salaried income in the main occupation - non-monetary *</_isalp_nm_note_>
* S1BQ19: How much earned or obtained by selling the “kind” received for wages & salaries during the last 1 year?
egen isalp_nm = rsum(inkind_income)					if  s1bq06==4, missing
*</_isalp_nm_>

*<_isep_m_>
*<_isep_m_note_> Self-employed income in the main occupation - monetary *</_isep_m_note_>
* S1BQ08: How much money in cash, did you earn during the last month?
* S1BQ09: How many months, did you work during the last year?
* S1BQ10: How much money in cash, did you earn during the last year?<
egen self_nagri = rsum(monthly_income annual_income)		if  s1bq06==3, missing	
egen self_agric = rsum(self_agriculture1)           	if  s1bq06>=6 & s1bq06<=9, missing
egen isep_m = rsum(self_nagri self_agric), missing
drop self_nagri self_agric
*</_isep_m_>

*<_isep_nm_>
*<_isep_nm_note_> Self-employed income in the main occupation - non-monetary *</_isep_nm_note_>
* S1BQ19: How much earned or obtained by selling the “kind” received for wages & salaries during the last 1 year?
egen isep_nm = rsum(inkind_income)						if  s1bq06==3, missing
*</_isep_nm_>

*<_iempp_m_>
*<_iempp_m_note_> Income by employer in the main occupation - monetary *</_iempp_m_note_>
* S1BQ08: How much money in cash, did you earn during the last month?
* S1BQ09: How many months, did you work during the last year?
* S1BQ10: How much money in cash, did you earn during the last year?
egen iempp_m = rsum(monthly_income annual_income)		if  s1bq06>=1 & s1bq06<=2, missing
*</_iempp_m_>

*<_iempp_nm_>
*<_iempp_nm_note_> Income by employer in the main occupation - non-monetary *</_iempp_nm_note_>
* S1BQ19: How much earned or obtained by selling the “kind” received for wages & salaries during the last 1 year?
egen iempp_nm = rsum(inkind_income) 					if  s1bq06>=1 & s1bq06<=2, missing
*</_iempp_nm_>

*<_iolp_m_>
*<_iolp_m_note_> Other labor income in the main occupation - monetary *</_iolp_m_note_>
* S1BQ08: How much money in cash, did you earn during the last month?
* S1BQ09: How many months, did you work during the last year?
* S1BQ10: How much money in cash, did you earn during the last year?
egen iolp_m = rsum(monthly_income annual_income)			if  s1bq06==5, missing
*</_iolp_m_>

*<_iolp_nm_>
*<_iolp_nm_note_> Other labor income in the main occupation - non-monetary *</_iolp_nm_note_>
egen  iolp_nm = rsum(inkind_income)					if  s1bq06==5, missing
*</_iolp_nm_>



*** SECOND AND OTHER ECONOMIC ACTIVITIES

*<_isalnp_m_>
*<_isalnp_m_note_> Salaried income in the non-principal occupation - monetary *</_isalnp_m_note_>
* S1BQ15: How much you earned in cash from this 2nd occupation, during the last year?
egen isalnp_m = rsum(second_income) 					if  s1bq14==4, missing
*</_isalnp_m_>

*<_isalnp_nm_>
*<_isalnp_nm_note_> Salaried income in the non-principal occupation - non-monetary *</_isalnp_nm_note_>
gen isalnp_nm = .
*</_isalnp_nm_>

*<_isenp_m_>
*<_isenp_m_note_> Self-employed income in the non- principal occupation - monetary *</_isenp_m_note_>
* S1BQ15: How much you earned in cash from this 2nd occupation, during the last year?
egen self_nagri2 = rsum(second_income)					if  s1bq14==3, missing	
egen self_agric2 = rsum(self_agriculture2)         		if  s1bq14>=6 & s1bq14<=9, missing
egen isenp_m = rsum(self_nagri2 self_agric2), missing
drop self_nagri2 self_agric2
*</_isenp_m_>

*<_isenp_nm_>
*<_isenp_nm_note_> Self-employed income in the non- principal occupation - non-monetary *</_isenp_nm_note_>
gen  isenp_nm = .
*</_isenp_nm_>

*<_iempnp_m_>
*<_iempnp_m_note_> Income by employer in the non-principal occupation - monetary *</_iempnp_m_note_>
* S1BQ15: How much you earned in cash from this 2nd occupation, during the last year?
egen iempnp_m = rsum(second_income) 					if s1bq14>=1 & s1bq14<=2, missing
*</_iempnp_m_>

*<_iempnp_nm_>
*<_iempnp_nm_note_> Income by employer in the non- principal occupation - non-monetary *</_iempnp_nm_note_>
gen  iempnp_nm = .
*</_iempnp_nm_>

*<_iolnp_m_>
*<_iolnp_m_note_> Other labor income in the non-principal - monetary occupation *</_iolnp_m_note_>
* S1BQ15: How much you earned in cash from this 2nd occupation, during the last year?
* S1BQ17: How much you earned in cash from these other jobs, during the last year?
replace s1bq17 = s1bq17/12
gen second_incom2 = second_income  					if  s1bq14==5
gen self_agric3 = self_agriculture3		
egen iolnp_m = rsum(self_agric3 second_incom2 s1bq17), missing
drop second_incom2 self_agric3
*</_iolnp_m_>

*<_iolnp_nm_>
*<_iolnp_nm_note_> Other labor income in the non-principal occupation - non-monetary *</_iolnp_nm_note_>
gen  iolnp_nm = .
*</_iolnp_nm_>


* Adjusting raw variables 
local variables "c02_802 c02_804 c02_805 c02_8061 c02_8062 c02_810 c02_811 c02_814 c02_815 c02_817 c02_953 c02_960 c02_962 s9aq04_901 s9aq04_902 s9aq04_903 s9aq04_904 s10c1_105 s10c1_197"
foreach var in `variables' { 
	replace `var' = `var'/12			/* monthly values */
	replace `var' = .	if s1aq02!=1 	/* household head */
	}

*<_ijubi_con_>
*<_ijubi_con_note_> Income for retirement and contributory pensions *</_ijubi_con_note_>
* S1BQ21: How much earned in cash, from pension and other benefits during the last year?
gen  ijubi_con = s1bq21/12
*</_ijubi_con_>

*<_ijubi_ncon_>
*<_ijubi_ncon_note_> Income for retirement and non-contributory pensions *</_ijubi_ncon_note_>
gen  ijubi_ncon = .
*</_ijubi_ncon_>

*<_ijubi_o_>
*<_ijubi_o_note_> Income for retirement and pensions (not identified if contributory or not) *</_ijubi_o_note_>
gen  ijubi_o = .
*</_ijubi_o_>



*<_icap_>
*<_icap_note_> Income from capital *</_icap_note_>
* S9AQ04_901: Agricultural Land, if rented out, what was the total net rent received, in (cash/kind) during the last 1 year?
* S9AQ04_902: Non-Agricultural Land, if rented out, what was the total net rent received, in (cash/kind) during the last 1 year?
* S9AQ04_903: Residential Building, if rented out, what was the total net rent received, in (cash/kind) during the last 1 year?
* S9AQ04_904: Commercial Building, if rented out, what was the total net rent received, in (cash/kind) during the last 1 year?
* S10C1_105: What was the total net value of rent (in cash and in kind) received for renting out land owned during Rabbi & Kharif?
* S10C1_197: What had you received if any agricultural equipment (tubewell, tractor, plough, thresher, harvester, truck) rented out during the last year?
* C02_953: How much profit did you receive from your all savings/deposits during the last 1 year?
* C02_960: How much dividends/profit received from these securities during the last one year?
* C02_962: How much money received from Provident fund during the last year?
egen icap = rsum(s9aq04_901 s9aq04_902 s9aq04_903 s9aq04_904 s10c1_105 s10c1_197 c02_953 c02_960 c02_962), missing
*</_icap_>


*<_icct_>
*<_icct_note_> Income from conditional cash transfer programs *</_icct_note_>
gen icct = .
*</_icct_>

*<_inocct_m_>
*<_inocct_m_note_> Income from public transfers not CCT - monetary *</_inocct_m_note_>
gen inocct_m = .
*</_inocct_m_>

*<_inocct_nm_>
*<_inocct_nm_note_> Income from public transfers not CCT - non-monetary *</_inocct_nm_note_>
gen inocct_nm = .
*</_inocct_nm_>

*<_itrane_ns_>
*<_itrane_ns_note_> Income from unspecified public transfers *</_itrane_ns_note_>
* 810: Zakat/Ushr received from public sector 
egen itrane_ns = rsum(c02_810), missing
*</_itrane_ns_>


*<_itranext_m_>
*<_itranext_m_note_> Income from foreign remittances - monetary *</_itranext_m_note_>
*  804: Remittances from outside Pakistan received through banks
*  805: Remittances from outside Pakistan received through book
* 8061: Remittances from outside Pakistan received through mobile banking
* 8062: Remittances from outside Pakistan received through other sources
egen itranext_m = rsum(c02_804 c02_805 c02_8061 c02_8062), missing
*</_itranext_m_>

*<_itranext_nm_>
*<_itranext_nm_note_> Revenue from remittances from abroad - non-monetary *</_itranext_nm_note_>
gen  itranext_nm = .
*</_itranext_nm_>

*<_itranint_m_>
*<_itranint_m_note_> Income by private transfers from the country - monetary *</_itranint_m_note_>
* 802: Remittances from within Pakistan
* 811: Zakat/Ushr received from private sector 
egen itranint_m = rsum(c02_802 c02_811), missing
*</_itranint_m_>

*<_itranint_nm_>
*<_itranint_nm_note_> Income by private transfers from the country - non-monetary *</_itranint_nm_note_>
* 817: Gifts, assistance, etc., received in-kind but sold?
egen itranint_nm = rsum(c02_817), missing
*</_itranint_nm_>

*<_itran_ns_>
*<_itran_ns_note_> Income from unspecified private transfers *</_itran_ns_note_>
gen itran_ns = .
*</_itran_ns_>

 
*<_inla_otro_>
*<_inla_otro_note_> Other non-labor income *</_inla_otro_note_>
* 814: Sadqa, inheritance, lottery winnings, etc.
* 815: Receipts from boarders or lodgers (in cash)
ta c02_814
sum c02_814 [w=wgt] 
replace c02_814 = .		if  c02_814>(r(mean)+(2.4*r(sd)))
egen inla_otro = rsum(c02_814 c02_815), missing
*</_inla_otro_>


*<_renta_imp_>
*<_renta_imp_note_> Imputed rent for own-housing *</_renta_imp_note_>
egen renta_imp = rsum(housing_rent) if s5q02!=3, missing
*</_renta_imp_>

*<_members_>
*<_members_note_> Number of members of the household *</_members_note_>
gen  uno = 1
egen members = sum(uno), by(hhid)
*</_members_>


gen month = month(date) 

*<_Save data file_>
do   "$rootdofiles\_aux\SecondOrder_INC.do"

********************************************************************************
**** SPATIAL ADJUSTMENT
********************************************************************************

* Mean PSUPIND
sum   psupind [aw=wgt] 
local mean_nat = r(mean)

* Mean income
sum   ipcf [aw=wgt] 
local avg = r(mean)

* Spatially adjusted income
gen     ipcf_alt = ipcf*`mean_nat'/psupind
sum     ipcf_alt [aw=wgt] 
local   avg2 = r(mean)
replace ipcf_alt = ipcf_alt*`avg'/`avg2'
sum     ipcf_alt [aw=wgt] 

local INCOME "isalp_m isalp_nm isep_m isep_nm iempp_m iempp_nm iolp_m iolp_nm isalnp_m isalnp_nm isenp_m isenp_nm iempnp_m iempnp_nm iolnp_m iolnp_nm ijubi_con ijubi_ncon ijubi_o icap icct inocct_m inocct_nm itrane_ns itranext_m itranext_nm itranint_m itranint_nm itran_ns inla_otro renta_imp"
foreach var in `INCOME' {
		sum   `var'  [aw=wgt] 
		local avg = r(mean)

		gen `var'_adj = `var'*`mean_nat'/psupind
		sum `var'_adj [aw=wgt] 
		local avg2 = r(mean)
		replace `var'_adj = `var'_adj*`avg'/`avg2'
		}

* IF EMPLOYER
egen    iempp_adj = rsum(iempp_m_adj iempp_nm_adj), missing
replace iempp_adj = .  		if  iempp_adj==0 

* IF WAGE WORKER
egen    isalp_adj = rsum(isalp_m_adj isalp_nm_adj), missing
replace isalp_adj = .  		if  isalp_adj==0

* IF SELF-EMPLOYED
egen    isep_adj  = rsum(isep_m_adj isep_nm_adj), missing
replace isep_adj  = .  		if  isep_adj==0 

* WHEN UNKNOW
egen    iolp_adj  = rsum(iolp_m_adj iolp_nm_adj), missing
replace iolp_adj  = .  		if  iolp_adj==0

* MAIN ACTIVITY INCOME  
egen ip_adj 	  = rsum(iempp_adj isalp_adj isep_adj iolp_adj), missing
egen ip_m_adj 	  = rsum(iempp_m_adj isalp_m_adj isep_m_adj iolp_m_adj), missing
 
* IF EMPLOYER
egen    iempnp_adj = rsum(iempnp_m_adj iempnp_nm_adj), missing
replace iempnp_adj = .  		if  iempnp_adj==0

* IF WAGE WORKER
egen    isalnp_adj = rsum(isalnp_m_adj isalnp_nm_adj), missing
replace isalnp_adj = .  		if  isalnp_adj==0

* IF SELF-EMPLOYED
egen    isenp_adj  = rsum(isenp_m_adj isenp_nm_adj), missing
replace isenp_adj  = .  		if  isenp_adj==0

* WHEN UNKNOW
egen    iolnp_adj  = rsum(iolnp_m_adj iolnp_nm_adj), missing
replace iolnp_adj  = .  		if  iolnp_adj==0

* OTHER ACTIVITIES INCOME  
egen inp_adj 	  = rsum(iempnp_adj isalnp_adj isenp_adj iolnp_adj), missing
egen inp_m_adj 	  =	rsum(iempnp_m_adj isalnp_m_adj isenp_m_adj iolnp_m_adj), missing


********************  LABOR INCOME ALL ACTIVITIES
* IF EMPLOYER
egen iemp_adj   	= rsum(iempp_adj   iempnp_adj),  missing
egen iemp_m_adj 	= rsum(iempp_m_adj iempnp_m_adj), missing

* IF WAGE WORKER
egen isal_adj   	= rsum(isalp_adj   isalnp_adj),  missing
egen isal_m_adj 	= rsum(isalp_m_adj isalnp_m_adj), missing

* IF SELF-EMPLOYED
egen ise_adj   		= rsum(isep_adj   isenp_adj),  missing
egen ise_m_adj 		= rsum(isep_m_adj isenp_m_adj), missing

* TOTAL INCOME
egen ila_adj	  	= rsum(iemp_adj isal_adj ise_adj iolp_adj iolnp_adj), missing
egen ila_m_adj 		= rsum(iemp_m_adj isal_m_adj ise_m_adj iolp_m_adj iolnp_m_adj), missing


******************** NON-LABOR INCOME
* PENSIONS
egen ijubi_adj 	= rsum(ijubi_con_adj ijubi_ncon_adj ijubi_o_adj), missing

* PRIVATE TRANSFERS
egen itranp_adj		= rsum(itranext_m_adj itranext_nm_adj itranint_m_adj itranint_nm_adj itran_ns_adj), missing
egen itranp_m_adj	= rsum(itranext_m_adj itranint_m_adj), missing

* PUBLIC TRANSFER
egen itrane_adj   	= rsum(icct_adj inocct_m_adj inocct_nm_adj itrane_ns_adj), missing
egen itrane_m_adj 	= rsum(icct_adj inocct_m_adj), missing

* PUBLIC AND PRIVATE TRANSFER
egen itran_adj   	= rsum(itrane_adj   itranp_adj), missing
egen itran_m_adj 	= rsum(itrane_m_adj itranp_m_adj), missing

* TOTAL NON-LABOR INCOME
egen inla_adj   	= rsum(ijubi_adj icap_adj itran_adj   inla_otro_adj), missing 
egen inla_m_adj 	= rsum(ijubi_adj icap_adj itran_m_adj inla_otro_adj), missing

 ******************** TOTAL INDIVIDUAL INCOME
* MONETARY
egen ii_adj	 	= rsum(ila_adj inla_adj), missing
* NON-MONETARY
egen ii_m_adj 	= rsum(ila_m_adj inla_m_adj), missing


* LABOR INCOME PER HOUSEHOLD 
egen ilf_m_adj = sum(ila_m_adj)  	if  hogarsec==0, by(hhid)
egen ilf_adj   = sum(ila_adj)  		if  hogarsec==0, by(hhid)

* NON-LABOR INCOME PER HOURHOLD
egen inlaf_m_adj = sum(inla_m_adj) 	if  hogarsec==0, by(hhid)
egen inlaf_adj   = sum(inla_adj) 	if  hogarsec==0, by(hhid)

* TOTAL MONETARY INCOME PER HOUSEHOLD
egen itf_m_adj = sum(ii_m_adj)  	if  hogarsec==0, by(hhid)

* HOUSEHOLD INCOME BEFORE IMPUTED RENT
egen itf_sin_ri_adj = sum(ii_adj) 	if  hogarsec==0, by(hhid)

* HOUSEHOLD INCOME WITH IMPUTED RENT
egen    itf_adj = rsum(itf_sin_ri_adj renta_imp_adj) 
replace itf_adj = .  			if  itf_sin_ri_adj==.
replace itf_adj = 0				if  itf_sin_ri_adj<0

* PER CAPITA HOUSEHOLD INCOME 
gen ipcf_adj = itf_adj/members


save "$output\\`filename'.dta", replace
*</_Save data file_>


