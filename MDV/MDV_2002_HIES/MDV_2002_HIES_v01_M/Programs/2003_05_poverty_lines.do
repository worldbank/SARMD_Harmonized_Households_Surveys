/* -----------------------------------------------------------------------------

     Poverty Trend in Maldives
          
     CONTACT:
	 
	 Silvia Redaelli
	 sredaelli@worldbank.org
	 
	 Giovanni Vecchi 
	 giovanni.vecchi@uniroma2.it
                    		
     This version: May 1, 2015

----------------------------------------------------------------------------- */

	
	use $path/outputdata/wf2003_tmp.dta, clear
	
	* non food allowances are calculated separately by male' and atolls (reg2)
	gen nonfood_pc_r_2009 = pcer_2009 - food_pc_r_2009
	label var nonfood_pc_r "real non-food allowances (2009 Rf/person/month)"
	*tabstat food_pc_r nonfood_pc_r pcer [aw=wght_ind], s(median) by(region) format(%9.1f)
	
	* food budget shares
	gen wfood = food_pc_r/pcer

	* upper bound
	gen up = zfood*1.2
	gen low = zfood*.8
	
	* nonfood allowance for Male'
	su  wfood [aw=wght_hh] if food_pc_r_2009 >= low & food_pc_r_2009 <= up & reg2 == 1, d
	su  nonfood_pc_r_2009 [aw=wght_hh] if food_pc_r_2009 >= low & food_pc_r_2009 <= up & reg2 == 1, d
	local nfa1 = r(p50)
	* nonfood allowance for Atolls
	su  wfood [aw=wght_hh] if food_pc_r_2009 >= low & food_pc_r_2009 <= up & reg2 == 2, d
	su  nonfood_pc_r_2009 [aw=wght_hh] if food_pc_r_2009 >= low & food_pc_r_2009 <= up & reg2 == 2, d
	local nfa2 = r(p50)
	
	gen nfa = . 
	replace nfa = `nfa1' if reg2 == 1
	replace nfa = `nfa2' if reg2 == 2
	
	tabstat nfa [aw=wght_hh], s(median) by(reg2) format(%9.1f)
	
	gen ztot = zfood + nfa
	label var ztot "national poverty line (Rf/person/month)" 

	tabstat zfood nfa ztot [aw=wght_hh], s(median) by(reg2) format(%9.1f)
	
	povdeco pcer_2009 [aw= wght_ind], varpl(ztot) by(reg2)


* ---------------------------- *	
* generate implicit total SPI
* ---------------------------- *	
	
	preserve
		collapse ztot, by(reg2)
		format ztot %9.1f

		l, noo sep(0)

		qui su ztot
		local meanzt = r(mean)
	restore
	
	gen spi2 = . 	
	forvalue r=1/2 {
		replace spi2 = 100*(ztot/`meanzt') if reg2==`r'
	}	
	label var spi2 "implicit total spatial price index (maldives = 100)"
	
	tabstat spi2, s(median) by(reg2) format(%9.1f)

	* generate national food poverty line
	gen zt = `meanzt'
	label var zt "national real poverty line (Rf/person/month)" 	
	
	su zt

	* real PCE
	gen pcerr_2009 = pcer_2009/(spi2/100)
	label var pcerr_2009 "real PCE (2009 Rf/person/month)"
	
	*

	su pcer_2009 [aw= wght_hh], d
	su pcerr_2009 [aw= wght_hh], d
	local max = r(p99)
		
	kdensity pcer_2009 [aw= wght_hh] if pcer_2009<`max', lp(-) lw(medthick) ///
 		addplot(kdensity pcerr_2009 [aw= wght_hh] if pcerr_2009<`max',  note("") xtit("Real Per Capita Expenditure" "(2009 Rf/month/person)")) ///
		graphregion(fcolor(white)) legend(label(1 "Food SPI-adjusted PCE") label(2 "Real (double-deflated) PCE") col(1) ring(0) pos(2)) ///
         ytit ("Number of people" "(density)") note("") ///
		 ylab(, angle(h) labsize(*.8)) tit("")



	* CDF of REAL pce
	cumul pcerr_2009 [aw= wght_hh] if reg2 == 1 & pcerr_2009 <10000, gen(Fpcerr1)
	cumul pcerr_2009 [aw= wght_hh] if reg2 == 2 & pcerr_2009 <10000, gen(Fpcerr2)
	replace Fpcerr1 = Fpcerr1 * 100
	replace Fpcerr2 = Fpcerr2 * 100
	label var Fpcerr1 "Male'"
	label var Fpcerr2 "Atolls"

	* first-order stochastic dominance
	twoway (line Fpcerr1 pcerr_2009 if reg2 == 1 & pcerr_2009 <10000, lc(red*1.2) lp(solid) lw(medthick) sort) ///
       (line Fpcerr2 pcerr_2009 if reg2 == 2 & pcerr_2009 <10000, lc(black) lp(-) lw(medthick) sort) ///
       , scheme(sj)  legend(col(1) ring(0) pos(5)) ///
       graphregion(fcolor(white)) ///
       ylab(,angle(0)) ytit("population" "(%)") ///
       xtick(0(500)10000) xtit("PCE" "(Rf/person/month)") xlab(0(2000)10000)
	   
	* Below: international poverty lines should already be in 2009 Rf
	
	* 1.25 dollar-a-day poverty line
	* source p. 18 DNP's report
	gen z_one=17*365/12
	label var z_one "1.25 dollar-a-day poverty line"
	
	* 2 dollar-a-day poverty line
	* source p. 18 DNP's report
	gen z_two=27*365/12
	label var z_two "2 dollar-a-day poverty line"

	tabstat z_* zt, s(median) format(%9.1f)
	povdeco pcerr_2009 [aw= wght_hh], varpl(z_one) by(reg2)
	povdeco pcerr_2009 [aw= wght_hh], varpl(z_two) by(reg2)
	povdeco pcerr_2009 [aw= wght_hh], varpl(zt) by(reg2)
	povdeco pcerr_2009 [aw= wght_hh], varpl(zt) by(region6)
	
	* Poverty profile tables
	
	povdeco pcerr_2009 [aw= wght_hh], varpl(zt) by(ind_code)
	povdeco pcerr_2009 [aw= wght_hh], varpl(zt) by(sex)
	*povdeco pcerr_2009 [aw= wght_hh], varpl(zt) by(age)

	* ventiles, deciles and quantiles based on the real PCE
	xtile pcerven = pcerr_2009 [aw=wght_hh], nq(20)
	xtile pcerdec = pcerr_2009 [aw=wght_hh], nq(10)
	xtile pcerqui = pcerr_2009 [aw=wght_hh], nq(5)
	
	* budget shares, food expenditures, calories and proteins by PCE deciles
	
	* food budget shares
	table pcerdec reg2 [aw=wght_ind], c(median wfood) row col format(%9.4f)
	* food expenditure
	table pcerdec reg2 [aw=wght_ind], c(median food_pc_r_2009) row col format(%9.0f)
	
	save $path/outputdata/wf2003.dta, replace
	erase $path/outputdata/wf2003_tmp.dta

	exit
