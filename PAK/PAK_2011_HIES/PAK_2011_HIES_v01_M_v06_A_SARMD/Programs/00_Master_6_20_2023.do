glo rootdofiles "P:\SARMD\SARDATABANK\SARMDdofiles"
*glo rootdatalib "P:\SARMD\SARDATABANK\SAR_DATABANK"
glo rootdatalib "P:\SARMD\SARDATABANK\WORKINGDATA"

clear all
set more off

local code         "AFG"
local year         "2019"
local survey       "LCS"
local vm           "01"
local va           "02"
local type         "SARMD"
local yearfolder   "`code'_`year'_`survey'"
local basefolder   "`code'_`year'_`survey'_v`vm'_M"
local gmdfolder    "`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD"

*Run master
local dopath1 "${rootdofiles}/`code'/`yearfolder'/`basefolder'"
local dopath2 "${rootdatalib}/`code'/`yearfolder'/`basefolder'/Programs"
shell robocopy "`dopath1'" "`dopath2'" /e
do "`dopath2'/`yearfolder'_v`vm'_M.do"


* Copy do-files from repo to datalibweb
local dopath1 "${rootdofiles}/`code'/`yearfolder'/`gmdfolder'"
local dopath2 "${rootdatalib}/`code'/`yearfolder'/`gmdfolder'/Programs"
shell robocopy "`dopath1'" "`dopath2'" /e

* Copy global labels do-file from repo to datalibweb
local doaux "${rootdofiles}/_aux"
shell robocopy "`doaux'" "`dopath2'" /e


*foreach mod in  "INC" "IND" "COR" { // For when INC is created
foreach mod in  "COR" "DEM" "IDN" "LBR" "GEO" "UTL" "DWL" "GMD" "IND"       { // For when GMD is run before IND 
*foreach mod in  "IND" "COR" "DEM" "IDN" "LBR" "GEO" "UTL" "DWL" "GMD"       { // For when IND is run before GMD
*foreach mod in  "IND" { // For when the year is previous than 2016
glo module "`mod'"
local filename     "`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD_`mod'"
do "`dopath2'/`filename'.do"
}

exit