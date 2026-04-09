/* -----------------------------------------------------------------------------

     Poverty Trend in Maldives
          
     CONTACT: 
	 
	 Silvia Redaelli
	 sredaelli@worldbank.org

	 Giovanni Vecchi 
	 giovanni.vecchi@uniroma2.it
                    
     This version: May 1, 2015

----------------------------------------------------------------------------- */

	use $path/inputdata/A2r-Individual-info.dta, replace
	sort hhserial individual
	
	rename hhserial hhid
	sort hhid
	
	merge m:1 hhid  using  $path/outputdata/pce_2003.dta
	assert _m == 3
	drop _m
	
	rename individual id
	
	* bring in food SPI
	merge m:1 region6 using  $path/outputdata/spi6.dta
	assert _m == 3
	drop _m
	
	* create real (= food SPI adjusted) CA
	gen pcer = pce/(spi6/100)
	label var pcer "real PCE (Rf/person/month)"
	
	gen pcer_2009 = pcer*cpi2009
	label var pcer "real PCE (2009 Rf/person/month)"

	* create real (= food SPI adjusted) food expenditure
	gen food_pc_r = food_pc/(spi6/100)
	label var food_pc_r "real food expenditure (Rf/person/month)"
	
	gen food_pc_r_2009 = food_pc_r*cpi2009
	label var pcer "real food expenditure (2009 Rf/person/month)"

	* Create variables for poverty profile 
	
	gen byte head = (membershipstatus==1)
	label var head "=1 if household head, 0 otherwise"
	

	*Employment
	gen employed=(genincome==1) if genincome!=.
	
	
	gen ind_code =.
	replace ind_code =1  if actcd == "A" | actcd == "B"
	replace ind_code =2  if actcd == "C"
	replace ind_code =3  if actcd == "D"
	replace ind_code =4  if actcd == "E"
	replace ind_code =6  if actcd == "G"
	replace ind_code =7  if actcd == "H"
	replace ind_code =8  if actcd == "I"
	replace ind_code =9  if actcd == "J" | actcd == "K"
	replace ind_code =10 if actcd == "L"
	replace ind_code =11 if actcd == "M" | actcd == "N"
	replace ind_code =12 if actcd == "Z" | actcd == "P" | actcd == "Q" | actcd == "Z"

	#delimit ;
	label define ind_code 
		1 "Agriculture/fisheries" 
		2 "Mining" 
		3 "Manufacturing" 
		4 "Utility"
		5 "Construction" 
		6 "Trade" 
		7 "Hotel/restaurant" 
		8 "Transport etc" 
		9 "Finance & business"
		10 "Public admin" 
		11 "Education & health" 
		12 "Other services";
	label val ind_code ind_code;
	label var ind_code "economic sector of activity (12)";
	#delim cr

		* occupation code
	gen byte occup_cat = 9  if occgrp==110
	replace  occup_cat = 1  if occgrp == 1
	replace  occup_cat = 2  if occgrp == 2
	replace  occup_cat = 3  if occgrp == 3
	replace  occup_cat = 4  if occgrp == 4
	replace  occup_cat = 5  if occgrp == 5
	replace  occup_cat = 6  if occgrp == 6
	replace  occup_cat = 7  if occgrp == 7
	replace  occup_cat = 8  if occgrp == 8
	

	# delimit ;
	label def occup_cat 	
	1		"Professional, Technical workers"
	2		"Administrative workers"
	3		"Clerical workers, etc"
	4		"Sales workers"
	5		"Service workers"
	6		"Agriculture and fisheries workers, etc"
	7		"Production workers, etc"
	8		"Workers not classified"
	9	    "Armed forces";
	label val occup_cat occup_cat;
	label var occup_cat "occupational category (9)";
	# delimit cr

	
	/*
	
	Education
	Variables not found
	
	*/
	
	
	*Generate year variable
	gen year=2003
	
	save $path/outputdata/wf2003_tmp.dta, replace
	
	*Append 2009 wfile
	append using $path/outputdata/wf2009.dta
	
	replace year=2009 if year==.
	replace pce_2009=pce if year==2009
	replace pcer_2009=pcer if year==2009

	* Kernel densities for both years
	qui su pcer_2009, d
	local ub = r(p99)
	
	twoway kdensity pcer_2009 [aw=wght_ind] if year==2003 & pcer_2009<`ub', lw(medthick) lp(solid) || ///
		kdensity pcer_2009 [aw=wght_ind] if year==2009 & pcer_2009<`ub', lw(medthick) lp(dash) ///
		legend(label(1 "2003") label(2 "2009") ring(0) pos(2) col(1)) graphregion(fcolor(white)) ///
		xtit("Per Capita Expenditure (2009 Rf/person/month)") ytit("Density")
	
	
	* PCE descriptive statistics
	tabstat pce_2009 [aw=wght_hh], s(mean  p25 median p75) by(year) format(%9.0f)
	tabstat pcer_2009 [aw=wght_hh], s(mean  p25 median p75) by(year) format(%9.0f)
	
	
exit	
	
