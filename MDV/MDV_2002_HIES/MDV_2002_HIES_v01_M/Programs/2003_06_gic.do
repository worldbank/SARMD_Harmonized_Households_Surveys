/* -----------------------------------------------------------------------------

     Poverty Trend in Maldives
          
     CONTACT: 
	 
	 Silvia Redaelli
	 sredaelli@worldbank.org

	 Giovanni Vecchi 
	 giovanni.vecchi@uniroma2.it
                    
     This version: May 1, 2015

----------------------------------------------------------------------------- */

	
	* create pooled sample
	use $path/outputdata/wf2003.dta, clear
	
	append using $path/outputdata/wf2009.dta
	
	replace year = 2009 if mi(year)
	
	replace pcerr_2009 = pcerr if year == 2009 & mi(pcerr_2009)
	
	save $path/outputdata/wfpooled.dta, replace
	
	tempfile povt1 povt2
	
	* initial year
	
	local t1 2003
	preserve
	keep if year == `t1'
	keep if reg2==2
	save `povt1', replace
	restore

	* final year
	local t2 2009
	preserve
	keep if year == `t2'
	keep if reg2==2
	save `povt2', replace
	restore

	local delta = `t2'-`t1'

	use `povt1', clear
	gicurve using `povt2' [aw=wght_hh], var1(pcerr_2009) var2(pcerr_2009) yperiod(`delta') np(100) ginmean /* ci(500 95) */ ///
		ylab(,angle(0) labsize(*.7) grid glp(shortdash) gmax format(%9.1f)) ytit("Average yearly growth rate" "(%)", size(*.7)) ///	
		graphregion(fcolor(white)) legend(off) lw(medthick medthick) lp(shortdash) lc(red dkgreen) ///
		xlab(0(10)100, labsize(*.7) ) xtit("2009 real PCE percentiles", size(*.7)) /*ci(200 95)*/

	
	* CDF of REAL pce
	use $path/outputdata/wfpooled.dta, clear
	cumul pcerr_2009 [aw= wght_hh] if year == 2003 & pcerr_2009 <10000, gen(Fpcer1)
	cumul pcerr_2009 [aw= wght_hh] if year == 2009 & pcerr_2009 <10000, gen(Fpcer2)
	replace Fpcer1 = Fpcer1 * 100
	replace Fpcer2 = Fpcer2 * 100
	label var Fpcer1 "2003"
	label var Fpcer2 "2009"

	* first-order stochastic dominance
	twoway (line Fpcer1 pcerr_2009 if year == 2003 & pcerr_2009 <10000, lc(red*1.2) lp(solid) lw(medthick) sort) ///
       (line Fpcer2 pcerr_2009  if year == 2009 & pcer <10000, lc(black) lp(-) lw(medthick) sort) ///
       , scheme(sj)  legend(col(1) ring(0) pos(5)) ///
       graphregion(fcolor(white)) ///
       ylab(,angle(0)) ytit("population" "(%)") ///
       xtick(0(500)10000) xtit("PCE" "(Rf/person/month)") xlab(0(2000)10000)

	
	* Shared Prosperity Indicator

	use $path/outputdata/wfpooled.dta, clear
	
	prosperity pcerr_2009 [w=wght_hh], period(year)
	
	
	exit

