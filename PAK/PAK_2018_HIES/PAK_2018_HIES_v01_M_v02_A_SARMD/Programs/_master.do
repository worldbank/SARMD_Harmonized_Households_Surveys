
********************************************************************************	
*Author:			Sandra Segovia
*				ssegoviajuarez@worldbank
*Modified for SAR by Laura Moreno
*Dependencies:		The World Bank
*Creation Date:		January, 2020
*Modification Date:  May, 2021
*Output:
********************************************************************************		

********************************************************************************
*    0. Set up
********************************************************************************
clear all
*set trace on
set checksum off, permanently 

local rundofiles_master = 	"no" 	// runs the dofiles (from the previous step) to create a dta per module 
local rundofiles_modulos = 	"yes" 	// runs the dofiles (from the previous step) to create a dta per module 
local gmd15_aux = 			"yes" 	// Merge previous dtas to create a final version of the GMD 2.0
local sarmd_aux = 			"no" 	// uses GMD 2.0 and add extra SAR variables

local type     "SARMD" // Collection used
local code     "PAK"    // Country ISO code
local year     "2018"   // Year of the survey
local survey   "HIES"
local vm       "01"     // Master version
local va       "02"     // Alternative version
local surveyf  "`code'_`year'_`survey'"
local masterf  "`surveyf'_v`vm'_M"

glo rootdatalib "P:\SARMD\SARDATABANK\SAR_DATABANK"
glo rootdatalib "P:\SARMD\SARDATABANK\WORKINGDATA"
glo dopath 		"${rootdatalib}\\`code'\\`surveyf'\\`masterf'\Programs"


********************************************************************************
*    Run do files 
********************************************************************************

********************************************************************************
*    Merge to create SARMD
********************************************************************************
if ("`sarmd_aux'"=="yes") {
    *cd "`folderf'\"
    do "${rootdatalib}\\`code'\\`surveyf'\\`masterf'_v`va'_A_`type'\\Programs\\`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD_IND.do"
}

* master dta
if ("`rundofiles_master'"=="yes") {
	
    *Master
	do "${dopath}\\`masterf'.do"

}

* RUn each GMD module
****MODULES definitions*********************************************************
*Module ID (IDN)
*Module Geography (GEO)
*Module Demography (DEM)
*Module Labor (LBR)
*Module Utilities (UTL)
*Module Assets and Dwellings (DWL)
*Module region variables
********************************************************************************
*set trace off
local modules DWL  /*IDN COR DEM GEO UTL DWL LBR*/

if ("`rundofiles_modulos'"=="yes") {

    local folderf "${rootdatalib}\\`code'\\`code'_`year'_`survey'\\`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD\Programs"
	
    cd "`folderf'"
	foreach mod of local modules {
		di "`folderf'" 
		di  "`folderf'\\`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD_`mod'.do"
	}
	
    
    foreach mod of local modules {
        * if ("`mod'"!="IND") {
            qui do "`folderf'\\`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD_`mod'.do"
            *shell copy "`folder'\\`file'" "`folderf'\\`file'"
        * }
    }
}
mmm
********************************************************************************
*    Merge to create GMD 1.5
********************************************************************************


if ("`gmd15_aux'"=="yes") {
*labels and other locals

cd "${rootdatalib}\\`code'\\`code'_`year'_`survey'\\`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD\Data\Harmonized\\"

*Merge do files
use "`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD_IDN.dta", clear 
sort hhid pid
cap rename weights weight 
drop subnatid1
local mods COR GEO DEM LBR DWL UTL 
*local mods COR
foreach mod of local mods {
    sort hhid pid
    cap rename subnatid1 subnatid_aux
	merge 1:1 hhid pid using "`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD_`mod'.dta"
    tab _merge
    *keep if _merge==3
    drop _merge       
}

include "${rootdatalib}\_aux\GMD2.0labels.do"
* cap gen gaul_adm3_code=.
*cap gen pipedwater_acc=.
*keep `gmd_2_0_vars'
order `gmd_2_0_vars' cpi*
compress
save "`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD_GMD.dta", replace

}



exit





