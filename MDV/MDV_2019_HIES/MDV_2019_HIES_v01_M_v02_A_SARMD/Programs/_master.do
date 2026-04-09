
********************************************************************************	
*Author:			Sandra Segovia
*				ssegoviajuarez@worldbank
*Modified for SAR by Laura Moreno
*Modified for SAR by Sizhen Fang ; June 2023
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

local rundofiles_master = 	"no" 	// runs the dofiles (from the previous step) to create a dta per module 
local rundofiles_modulos = 	"yes" 	// runs the dofiles (from the previous step) to create a dta per module 
local gmd15_aux = 		"yes" 	// Merge previous dtas to create a final version of the GMD 2.0
local sarmd_aux = 		"yes" 	// uses GMD 2.0 and add extra SAR variables

local type     "SARMD"  
local code     "MDV"    
local year     "2019"   
local survey   "HIES"
local vm       "01"  
local va       "02"    
local surveyf "`code'_`year'_`survey'"
local masterf "`surveyf'_v`vm'_M"
glo rootdofiles "P:\SARMD\SARDATABANK\SARMDdofiles"
* use SAR_DATABANK for the final data	
// glo rootdatalib "P:\SARMD\SARDATABANK\SAR_DATABANK"
// * use WORKINGDATA when revising the code making
glo rootdatalib "P:\SARMD\SARDATABANK\WORKINGDATA"

********************************************************************************
*    Run do files 
********************************************************************************

* master dta
if ("`rundofiles_master'"=="yes") {
    /*
    local dopath1 "${rootdofiles}/`code'/`surveyf'/`masterf'"
    local dopath "${rootdatalib}/`code'/`surveyf'/`masterf'/Programs"
    shell robocopy "`dopath1'" "`dopath'" /e
    */
    *Auxliar
    do "`dopath'\\`masterf'_aux.do"
    *No duplicates in terms of uqhh_id
    *Master
	do "`dopath'\\`masterf'.do"

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

local modules IDN COR DEM GEO UTL DWL LBR GMD IND

if ("`rundofiles_modulos'"=="yes") {
    /*
    cap mkdir "${rootdatalib}/`code'/`surveyf'"
    cap mkdir "${rootdatalib}/`code'/`surveyf'/`surveyf'_v`vm'_M_v`va'_A_SARMD"
    cap mkdir "${rootdatalib}/`code'/`surveyf'/`surveyf'_v`vm'_M_v`va'_A_SARMD/Programs"
    */
    * Copy do-files from repo to datalibweb
    local dopath1 "${rootdofiles}/`code'/`surveyf'/`surveyf'_SARMD"
    local dopath2 "${rootdatalib}/`code'/`surveyf'/`surveyf'_v`vm'_M_v`va'_A_SARMD/Programs"
    *noi di "`dopath1' -> `dopath2'"
    shell robocopy "`dopath1'" "`dopath2'" /e
    
    cd "`dopath2'"
    
    foreach mod of local modules {
             do "`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD_`mod'.do"
    }
}

exit


gen double welfare_ppp11_SM22=(12*welfare)/cpi/ppp/365
apoverty welfare_ppp11_SM22 [w=weight], line(1.9)
apoverty welfare_ppp11_SM22 [w=weight], line(3.2)
apoverty welfare_ppp11_SM22 [w=weight], line(5.5)
gen double welfare_ppp17_AM22=(12*welfare)/cpi2017/ppp2017/365
apoverty welfare_ppp17_AM22 [w=weight], line(2.15)
apoverty welfare_ppp17_AM22 [w=weight], line(3.65)
apoverty welfare_ppp17_AM22 [w=weight], line(6.85)

exit





