
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
set checksum off, permanently 

local rundofiles_master = 	"yes" 	// runs the dofiles (from the previous step) to create a dta per module 
local rundofiles_modulos = 	"yes" 	// runs the dofiles (from the previous step) to create a dta per module 
local gmd15_aux = 		"yes" 	// Merge previous dtas to create a final version of the GMD 2.0
local sarmd_aux = 		"yes" 	// uses GMD 2.0 and add extra SAR variables

local type     "SARMD"  // Collection used
local code     "MDV"    // Country ISO code
local year     "2019"   // Year of the survey
local survey   "HIES"
local vm       "01"     // Master version
local va       "01"     // Alternative version
local surveyf "`code'_`year'_`survey'"
local masterf "`surveyf'_v`vm'_M"
glo rootdatalib "P:\SARMD\SARDATABANK\SAR_DATABANK"

********************************************************************************
*    Run do files 
********************************************************************************

* master dta
if ("`rundofiles_master'"=="yes") {
	glo dopath "P:\SARMD\SARDATABANK\SAR_DATABANK\\`code'\\`surveyf'\\`masterf'\Programs"

    *Auxliar
    do "${dopath}\\`masterf'_aux.do"
    *No duplicates in terms of uqhh_id
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
set trace off

local modules IDN COR DEM GEO UTL DWL LBR

if ("`rundofiles_modulos'"=="yes") {

    local folderf "${rootdatalib}\\`code'\\`code'_`year'_`survey'\\`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD\Programs"

    cd "`folderf'"
    
    foreach mod of local modules {
         if ("`mod'"!="IND") {
             do "`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD_`mod'.do"
            *shell copy "`folder'\\`file'" "`folderf'\\`file'"
         }
    }
}

********************************************************************************
*    Merge to create GMD 1.5
********************************************************************************


if ("`gmd15_aux'"=="yes") {
*labels and other locals

cd "${rootdatalib}\\`code'\\`code'_`year'_`survey'\\`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD\Data\Harmonized\\"

*Merge do files
use "`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD_IDN.dta"
sort hhid pid

local mods COR GEO DEM LBR DWL UTL 
foreach mod of local mods {
    sort hhid pid
    merge 1:1 hhid pid using "`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD_`mod'.dta"
    tab _merge
    keep if _merge==3
    drop _merge       
}

include "${rootdatalib}\_aux\GMD2.0labels.do"
* cap gen gaul_adm3_code=.
*cap gen pipedwater_acc=.
*keep `gmd_2_0_vars'
order `gmd_2_0_vars'
save "`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD_ALL.dta", replace
compress
save "`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD_GMD.dta", replace

}

********************************************************************************
*    Merge to create SARMD
********************************************************************************
if ("`sarmd_aux'"=="yes") {
    cd "`folderf'"
    do "`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD_IND.do"
}

gen double welfare_ppp11_SM22=(12*welfare)/cpi/ppp/365
apoverty welfare_ppp11_SM22 [w=weight], line(1.9)
apoverty welfare_ppp11_SM22 [w=weight], line(3.2)
apoverty welfare_ppp11_SM22 [w=weight], line(5.5)
gen double welfare_ppp17_AM22=(12*welfare)/cpi2017/ppp2017/365
apoverty welfare_ppp17_AM22 [w=weight], line(2.15)
apoverty welfare_ppp17_AM22 [w=weight], line(3.65)
apoverty welfare_ppp17_AM22 [w=weight], line(6.85)

exit





