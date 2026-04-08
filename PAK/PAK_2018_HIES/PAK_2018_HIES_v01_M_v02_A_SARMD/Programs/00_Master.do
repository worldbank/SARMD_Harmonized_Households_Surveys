glo rootdofiles "P:\SARMD\SARDATABANK\SARMDdofiles"
glo rootdatalib "P:\SARMD\SARDATABANK\SAR_DATABANK"
*glo rootdatalib "P:\SARMD\SARDATABANK\WORKINGDATA"
#delimit ;
clear all;
set more off;

local code         "PAK";
local year         "2018";
local survey       "HIES";
local vm           "01";
local va           "02";
local type         "SARMD";
local yearfolder   "`code'_`year'_`survey'";
local gmdfolder    "`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD";

/*Run master;
local dopath1 "${rootdofiles}/`code'/`yearfolder'/`yearfolder'_M";
local dopath2 "${rootdatalib}/`code'/`yearfolder'/`yearfolder'_v`vm'_M/Programs";
shell robocopy "`dopath1'" "`dopath2'" /e;
do "`dopath2'/`yearfolder'_v`vm'_M.do";
*/;

* Copy do-files from repo to datalibweb;
local dopath1 "${rootdofiles}/`code'/`yearfolder'/`yearfolder'_SARMD";
local dopath2 "${rootdatalib}/`code'/`yearfolder'/`yearfolder'_v`vm'_M_v`va'_A_SARMD/Programs";
shell robocopy "`dopath1'" "`dopath2'" /e;

* Copy global labels do-file from repo to datalibweb;
local doaux "${rootdofiles}/_aux";
shell robocopy "`doaux'" "`dopath2'" /e;

* Run modules;
foreach mod in "IND" "IDN" "COR" "GEO" "DWL" "DEM" "UTL" "LBR" "GMD"  {;
local filename     "`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD_`mod'";
do "`dopath2'/`filename'.do";
};

