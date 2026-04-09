use "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\MDV\MDV_2016_HIES\MDV_2016_HIES_v01_M\Data\Stata\F7-Q3-Q5.dta", clear
collapse (rawsum) exp, by( Form_ID)
rename exp weekly_foodexp
label var weekly_foodexp "7 day total household food expenditures"
save food
