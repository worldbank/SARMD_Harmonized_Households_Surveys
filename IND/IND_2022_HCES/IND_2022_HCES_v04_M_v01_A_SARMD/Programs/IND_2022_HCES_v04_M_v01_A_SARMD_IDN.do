/*----------------------------------------------------------------------------------
  SARMD Harmonization
------------------------------------------------------------------------------------
<_Program name_>   		IND_2022_HCES_v04_M_v01_SARMD_IDN.do	       </_Program name_>
<_Application_>    		STATA 17.0									 <_Application_>
<_Author(s)_>      		Leo Tornarolli <tornarolli@gmail.com>		  </_Author(s)_>
<_Date created_>   		02-2026									   </_Date created_>
<_Date modified>    	February 2026						 	  </_Date modified_>
------------------------------------------------------------------------------------
<_Country_>        		IND											    </_Country_>
<_Survey Title_>   		HCES									   </_Survey Title_>
<_Survey Year_>    		2022-2023									</_Survey Year_>
------------------------------------------------------------------------------------
<_Version Control_>
Date:					02-2026
File:					IND_2022_HCES_v04_M_v01_SARMD_IDN.do
First version
</_Version Control_>
----------------------------------------------------------------------------------*/

*<_Program setup_>
clear all
set more off

local code         		"IND"
local year         		"2022"
local survey       		"HCES"
local vm           		"04"
local va           		"01"
local type         		"SARMD"
global module       	"IDN"
local yearfolder    	"`code'_`year'_`survey'"
local SARMDfolder    	"`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'"
local filename      	"`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'_${module}"
cap mkdir				"${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'" 
cap mkdir				"${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\\Data" 
cap mkdir				"${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\\Data\Harmonized" 
global input      		"${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata"
glo output          	"${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\\Data\Harmonized" 
*</_Program setup_>


*<_Datalibweb request_>
use "${input}\\`yearfolder'_v`vm'_M.dta", clear
*</_Datalibweb request_>


*<_countrycode_> 
*<_countrycode_note_> Country code according to ISO-3166 Alpha-3 *</_countrycode_note_>
gen countrycode = "`code'"
gen code = countrycode
*</_countrycode_>

*<_year_>
*<_year_note_> 4-digit year of survey based on IHSN standards *</_year_note_>
capture drop year 
gen year = 2022
*</_year_>

*<_int_year_>
*<_int_year_note_> Interview Year *</_int_year_note_>
gen 	int_year = 2022		if  panel>=1 & panel<=5
replace int_year = 2023		if  panel>=6 & panel<=10
*</_int_year_>

*<_int_month_>
*<_int_month_note_> Interview Month *</_int_month_note_>
*<_int_month_note_> 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December" *</_int_month_note_>
gen 	int_month = 8		if  panel==1
replace int_month = 9		if  panel==2
replace int_month = 10		if  panel==3
replace int_month = 11		if  panel==4
replace int_month = 12		if  panel==5
replace int_month = 1		if  panel==6
replace int_month = 2		if  panel==7
replace int_month = 3		if  panel==8
replace int_month = 4		if  panel==9
replace int_month = 5		if  panel==10
label define int_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
label values int_month int_month
clonevar month = int_month
*</_int_month_>

*<_hhid_>
*<_hhid_note_> Household identifier  *</_hhid_note_>
/*<_hhid_note_> . *</_hhid_note_>*/
*<_hhid_note_> hhid brought in from SARMD *</_hhid_note_>
*</_hhid_>

*<_hhid_orig_>
*<_hhid_orig_note_> Household identifier variables in the raw data are FSU, B1Q1PT11, and B1Q1PT12 *</_hhid_org_note_>
gen hhid_orig = "FSU B1Q1PT11 B1Q1PT12"
*</_hhid_orig_>

*<_pid_>
*<_pid_note_> Personal identifier  *</_pid_note_>
/*<_pid_note_> country specific *</_pid_note_>*/
*<_pid_note_> pid brought in from SARMD *</_pid_note_>
*</_pid_>

*<_pid_orig_>
*<_pid_orig_note_> Personal identifier variables in the raw data are FSU, B1Q1PT11, B1Q1PT12, and B3Q1 *</_pid_org_note_>
gen pid_orig = "FSU B1Q1PT11 B1Q1PT12 B3Q1"
*</_pid_orig_>

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


*<_Keep variables_>
order countrycode year hhid pid weight weighttype
sort  hhid pid 
*</_Keep variables_>


*<_Save data file_>
compress
quietly do 	"$rootdofiles\_aux\Labels_GMD3.0.do"
save 		"$output\\`filename'.dta", replace
*</_Save data file_>
	
	