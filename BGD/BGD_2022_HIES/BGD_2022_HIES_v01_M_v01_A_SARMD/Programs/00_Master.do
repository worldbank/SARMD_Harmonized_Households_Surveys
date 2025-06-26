glo rootdofiles "P:\SARMD\SARDATABANK\SARMDdofiles"
glo rootdatalib "P:\SARMD\SARDATABANK\SAR_DATABANK"
*glo rootdatalib "P:\SARMD\SARDATABANK\WORKINGDATA"

clear all
set more off
set trace off 

local code         "BGD"
local year         "2022"
local survey       "HIES"
local vm           "01"
local va           "01"
local type         "SARMD"
local yearfolder   "`code'_`year'_`survey'"

notes: lines from 18 to 21 are run when a database is created as a data preparation for the harmonization 

*Run master
local dopath1 "${rootdofiles}\\`code'\\`yearfolder'\\`yearfolder'_M"
local dopath2 "${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Programs"
shell robocopy "${rootdofiles}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M" "${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Programs" /e
do "`dopath2'/`yearfolder'_v`vm'_M.do"

* Copy do-files from repo to datalibweb
local dopath1 "${rootdofiles}\\`code'\\`yearfolder'\\`yearfolder'_SARMD"
local dopath2 "${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M_v`va'_A_SARMD\Programs"
shell robocopy "${rootdofiles}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M_v`va'_A_SARMD" "${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M_v`va'_A_SARMD\Programs" /e

* Copy global labels do-file from repo to datalibweb
local doaux "${rootdofiles}/_aux"
shell robocopy "${rootdofiles}\_aux" "${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M_v`va'_A_SARMD\Programs" /e

foreach mod in  "INC" "IND" "COR" "DEM" "IDN" "GEO" "DWL" "UTL" { //            "LBR"    "GMD"  For when INC is created
*foreach mod in  "COR" "DEM" "IDN" "LBR" "GEO" "UTL" "DWL" "GMD" "IND"       { // For when GMD is run before IND 
*foreach mod in  "IND" "COR"  "DEM" "IDN" "LBR" "GEO" "UTL" "DWL" "GMD"  { //            For when IND is run before GMD
*foreach mod in  "IND" { // For when the year is previous than 2016
glo module "`mod'"
local filename     "`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD_`mod'"
do "`dopath2'\\`filename'.do"
}

exit