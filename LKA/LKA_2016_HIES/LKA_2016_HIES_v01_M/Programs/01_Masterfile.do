*******************************************************************************
* Project: Sri Lanka HIES 2016
* This project generates the consumption aggregate and other related variables using HIES 2016 data
* Author: Fernando Enrique Morales Velandia (based on the do file created by Ani Rudra Silwal)
* Date: November 29, 2017
*******************************************************************************

* Define Directories
local code         "LKA"
local year         "2016"
local survey       "HIES"
local vm           "01"
local va           "04"
local type         "SARMD"
local yearfolder   "`code'_`year'_`survey'"

global root   "${rootdatalib}\\`code'\\`code'_`year'_`survey'\\`code'_`year'_`survey'_v`vm'_M"
global do     "${root}\Programs"
global output "${root}\Data\Stata"

* Convert raw data from DCS in .csv format into .dta format for subsequent analysis
do "$do\02_Convert_csv2dta.do"

