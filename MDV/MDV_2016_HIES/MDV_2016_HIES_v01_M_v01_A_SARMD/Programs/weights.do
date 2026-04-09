
use "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\MDV\MDV_2016_HIES\MDV_2016_HIES_v01_M\Data\Stata\F3-Q12-Q23.dta", clear
keep if Exp_id==1
keep Form_ID id Atoll_Island IslandCode block HHSN surveyMonth Atoll Adjustedhouseholdweight
total Adjustedhouseholdweight


use "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\MDV\MDV_2016_HIES\MDV_2016_HIES_v01_M\Data\Stata\F3-Q24-Q30.dta", clear
keep if Exp_id==1
keep Form_ID id Atoll_Island IslandCode block HHSN surveyMonth Atoll Adjustedhouseholdweight
total Adjustedhouseholdweight

