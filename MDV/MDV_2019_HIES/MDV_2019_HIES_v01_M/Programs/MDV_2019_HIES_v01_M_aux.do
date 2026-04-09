/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   MDV_2019_HIES_v01_M_aux.do	</_Program name_>
<_Application_>    STATA 16.0	<_Application_>
<_Author(s)_>      Juan Segnana <jsegnana@worldbank.org>	</_Author(s)_>
<_Date created_>   05-03-2021	</_Date created_>
<_Date modified>    06-10-2021	</_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        MDV	</_Country_>
<_Survey Title_>   HIES	</_Survey Title_>
<_Survey Year_>    2019	</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:	06-10-2021
File:	MDV_2019_HIES_v01_M_aux.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/
*glo rootdatalib "P:\SARMD\SARDATABANK\SAR_DATABANK"
*<_Program setup_>;
#delimit ;
clear all;
set more off;

local code         "MDV";
local year         "2019";
local survey       "HIES";
local vm           "01";
local type         "SARMDRAW";
local yearfolder   "MDV_2019_HIES";
local filename     "MDV_2019_HIES_v01_M";
*</_Program setup_>;

*<_Folder creation_>;
cap mkdir "${rootdatalib}";
cap mkdir "${rootdatalib}\\`code'";
cap mkdir "${rootdatalib}\\`code'\\`yearfolder'";
cap mkdir "${rootdatalib}\\`code'\\`yearfolder'\\`filename'";
cap mkdir "${rootdatalib}\\`code'\\`yearfolder'\\`filename'\Data";
cap mkdir "${rootdatalib}\\`code'\\`yearfolder'\\`filename'\Data\Stata";
glo rawstata "${rootdatalib}\\`code'\\`yearfolder'\\`filename'\Data\Stata";
glo original "${rootdatalib}\\`code'\\`yearfolder'\\`filename'\Data\Original_pre";
*</_Folder creation_>;

/*****************************************************************************************************;
*                                                                                                    *;
                                   * ASSEMBLE DATABASE;
*                                                                                                    *;
*****************************************************************************************************/;


/** DATABASE ASSEMBLENT */;
	* Merge data;
#delimit cr    
clear all

*Reshape and merge expenditure databases


use "${original}\ex_30d_6", clear
keep if ex_pchsedrcvd_6__1==1

decode ex_30d_6__id, gen (item)

keep ex_amnt_6 uqhh__id expunit2__id item


replace item = "Cable" if item == "Cable TV and like"
replace item = "Internet" if item == "Internet bill (fixed broadband / Data sim / Dongle)"


reshape wide ex_amnt_6 , i(uqhh__id expunit2__id) j(item) s

collapse (sum) ex_amnt_6Cable (sum) ex_amnt_6Internet, by(uqhh__id)

tempfile cable
save `cable'

use "${original}\ex_30d_3", clear

decode ex_30d_3__id, gen (item)
keep if item == "Diesel / Engine Oil" | item == "Petrol"
replace item = "Diesel" if item=="Diesel / Engine Oil"

keep uqhh__id item ex_amnt_3 expunit2__id

reshape wide ex_amnt_3 , i(uqhh__id expunit2__id) j(item) s

collapse (sum) ex_amnt_3Diesel (sum) ex_amnt_3Petrol, by(uqhh__id)

tempfile diesel
save `diesel'



use "${original}\other_exp", clear


keep if other_purchdRcvd__1==1

decode other_exp__id, gen (item)

replace item = "Water" if item=="Water bill"
replace item = "Waste" if item=="Waste disposal"
replace item = "Electricity" if item=="Electricity bill"
replace item = "Land_line_bill" if item=="Land line bill"

keep uqhh__id item cost_item_serv

drop if item=="Domestic servant (Casual and full-time)"

reshape wide cost_item_serv , i(uqhh__id) j(item) s

tempfile services
save `services'

merge 1:1 uqhh__id using `diesel'
drop _merge

merge 1:1 uqhh__id using `cable'
drop _merge

*<_Save data file_>;
save "${rootdatalib}\\`code'\\`yearfolder'\\`filename'\Data\Stata\exp_harm_GMD.dta" , replace
*</_Save data file_>;

exit