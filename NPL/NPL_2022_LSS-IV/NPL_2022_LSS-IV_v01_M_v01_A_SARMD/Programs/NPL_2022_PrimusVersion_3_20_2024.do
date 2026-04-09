
	use "P:\SARMD\SARDATABANK\WORKINGDATA\NPL\NPL_2022_NLSSIV\NPL_2022_NLSSIV_v01_M_v01_A_SARMD\Data\Harmonized\Primus_3_20_2024Version_99_NLSSIV_wgts_pcep.dta", clear
	
	rename psu_number psu 
	rename prov       subnatid1
	rename ind_wt     wgt 
	rename pcep       welfare_orig
	
	clonevar welfare = welfare_orig
	replace  welfare = welfare/12
	
	gen country = "Nepal"
	gen code    = "NPL"
	gen year    = 2022
	
	gen urban =.
	replace urban = 1 if domain ==11 | domain==21 | domain==30 | domain==31 | domain==41 | domain==51 | domain==61 | domain==71
	replace urban = 0 if domain ==12 | domain==22 | domain==32 | domain==42 | domain==52 | domain==62 | domain==72
	
	drop   hh_number znat welfare_orig domain 
	
	gen welfaretype  ="EXP"
	gen weighttype   ="PW"
	gen welfshprtype ="EXP"
	
	gen welfshprosperity=. 
	
	levelsof welfaretype,  local(welfaretype)
	levelsof weighttype,   local(weighttype)
	levelsof welfshprtype, local(welfshprtype)

	save "P:\SARMD\SARDATABANK\WORKINGDATA\NPL\NPL_2022_NLSSIV\NPL_2022_NLSSIV_v01_M_v01_A_SARMD\Data\Harmonized\NPL_2022_NLSSIV_v01_M_v01_A_SARMD_IND.dta", replace 
	
	rename  wgt weight 
	replace welfare = welfare*12
	
	save "P:\SARMD\SARDATABANK\WORKINGDATA\NPL\NPL_2022_NLSSIV\NPL_2022_NLSSIV_v01_M_v01_A_SARMD\Data\Harmonized\NPL_2022_NLSSIV_v01_M_v01_A_SARMD_GMD.dta", replace 
	