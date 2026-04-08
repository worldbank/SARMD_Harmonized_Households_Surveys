/* 
this program adjusts mean of welfare variable to match PovcalNet mean in 2005 PPP
and then displays expenditure or income share by decile and the poverty headcount at 
default poverty line of $38/month PPP (or user specified line).
This should be checked against results from PovcalNet.

syntax: check varname [if] [aw pw], Meanpovcal(real) [Pline(real)]
varname is variable for nominal per capita expenditure or income
specifying poverty line is optional; default is $38/month PPP (i.e. 1.25 per day)
*/
   
cap program drop check
program check
	syntax varlist (min=1 max=1) [if] [aweight pweight], Meanpovcal(real) [Pline(real 38)]
	tempvar x decile xpoor xgap
	tempname Mtemp Mout Mtot Mshare tot Mstat 
	
	preserve
	
	cap keep `if'
	qui sum `varlist' [aw `exp']
	local m_nom=r(mean)
	mat `Mstat'= (0, r(mean))
	mat rown `Mstat'="mean (nominal)"
	mat `Mtemp'=(0, `meanpovcal'/`m_nom')
	mat rown `Mtemp'=conv_factor
	mat `Mstat'=`Mstat' \ `Mtemp'
	
	gen `x' = `varlist' * (`meanpovcal'/`m_nom')
	qui sum `x' [aw `exp']
	mat `Mtemp'= (0, r(mean))
	mat rown `Mtemp'="mean (adjusted)"
	mat `Mstat'=`Mstat' \ `Mtemp'
	
	xtile `decile'=`x' [aw `exp'], nq(10)
	forvalues i=1(1)10 {
		qui sum `x' [aw `exp'] if `decile'==`i'
		mat `Mtemp' =  (`i', r(sum))
		mat rown `Mtemp' = "decile share"
		mat `Mout' = (nullmat(`Mout')\ `Mtemp')
	}
	mat `Mtot'=(J(1,10,1))*(`Mout'[....,2])
	scalar `tot' = `Mtot'[1,1]
	mat `Mshare'=(`Mout'[....,2])/`tot'*100
	mat `Mout' =`Mout'[....,1] , `Mshare'
	mat coln `Mout' = "decile" "income share"
	mat list `Mout', noheader 
	
	gen `xpoor'=(`x'<`pline')
	gen `xgap'=(`pline'-`x')/`pline'*`xpoor'
	
	qui sum `xpoor' [aw `exp']
	di _new
	di "Headcount poverty at poverty line of $" `pline' "/month (PPP)"
	di " = " r(mean)*100 " %"	
	mat `Mtemp'= (0, r(mean)*100 )
	mat rown `Mtemp'=HC_`pline'
	mat `Mstat'=`Mstat' \ `Mtemp'
		
	qui sum `xgap' [aw `exp']
	di _new
	di "Poverty gap at poverty line of $" `pline' "/month (PPP)"
	di " = " r(mean)*100 " %"
	mat `Mtemp'=(0, r(mean)*100 )
	mat rown `Mtemp' = PG_`pline'
	mat `Mstat'=`Mstat' \ `Mtemp'
	
	di _new
	di "Conversion factor (mean povcalnet / mean from data) " 
	di " = "`meanpovcal'/`m_nom'

	mat Mcheck = `Mstat' \ `Mout'
	restore
end

/* sample command line
check pcexp [pw=popwt], mean(62.0) 

// with if statement
check pcexp [aw=popwt] if year==2000, m(62.0) 

// with poverty line, other than default $38/month (PPP)
check pcexp [aw=popwt] if year==2000, m(62.0) p(45)
*/
