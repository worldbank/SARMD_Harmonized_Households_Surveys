set more off

global dir "C:\Users\wb436991\Box Sync\WB\SAR_Maldives"
global out "${dir}\Data\Data_modified\"
global table "${dir}\Tables\"
global figure "${dir}\Figures\"

/*
*===============================================================================
* MALDIVES POVERTY OVER TIME
*===============================================================================
local years "2003 2010"
local pline "nat 125 200 250 400"
	foreach yr of local years{
	local i = 1
		foreach z of local pline{
			use "${out}/profile_`yr'.dta", clear
			povdeco y_`yr' [aw=wght_hh], varpline(z_`z')
			if `i'==1{
			matrix F_`yr' = r(fgt0) , r(fgt1) , r(fgt2)
			}
			else{
			matrix F_`yr' = F_`yr' \ r(fgt0) , r(fgt1) , r(fgt2)
			}		
		local ++i
		} // pline
	} //years
	matrix F = F_2003 , F_2010

#delimit ;
	matrix rownames F = "National poverty line"
						"125 US$2005 PPP"
						"200 US$2005 PPP"
						"250 US$2005 PPP"
						"400 US$2005 PPP";
	matrix colnames F = 	"headcount" "poverty gap" "squared poverty gap" 
							"headcount" "poverty gap" "squared poverty gap";
						
#delimit cr

putexcel B2= matrix(F, names) using "${table}/Tables_SCD.xlsx", sheet("National_Poverty") modify
mat drop _all

* MALE
*-------------------------------------------------------------------------------
local years "2003 2010"
local pline "nat 125 200 250 400"
	foreach yr of local years{
	local i = 1
		foreach z of local pline{
			use "${out}/profile_`yr'.dta", clear
			povdeco y_`yr' [aw=wght_hh] if reg2==1, varpline(z_`z')
			if `i'==1{
			matrix F_`yr' = r(fgt0) , r(fgt1) , r(fgt2)
			}
			else{
			matrix F_`yr' = F_`yr' \ r(fgt0) , r(fgt1) , r(fgt2)
			}		
		local ++i
		} // pline
	} //years
	matrix F = F_2003 , F_2010

#delimit ;
	matrix rownames F = "National poverty line"
						"125 US$2005 PPP"
						"200 US$2005 PPP"
						"250 US$2005 PPP"
						"400 US$2005 PPP";
	matrix colnames F = 	"headcount" "poverty gap" "squared poverty gap" 
							"headcount" "poverty gap" "squared poverty gap";
						
#delimit cr

putexcel B12= matrix(F, names) using "${table}/Tables_SCD.xlsx", sheet("National_Poverty") modify
mat drop _all

* ATOLLS
*-------------------------------------------------------------------------------
local years "2003 2010"
local pline "nat 125 200 250 400"
	foreach yr of local years{
	local i = 1
		foreach z of local pline{
			use "${out}/profile_`yr'.dta", clear
			povdeco y_`yr' [aw=wght_hh] if reg2==2, varpline(z_`z')
			if `i'==1{
			matrix F_`yr' = r(fgt0) , r(fgt1) , r(fgt2)
			}
			else{
			matrix F_`yr' = F_`yr' \ r(fgt0) , r(fgt1) , r(fgt2)
			}		
		local ++i
		} // pline
	} //years
	matrix F = F_2003 , F_2010

#delimit ;
	matrix rownames F = "National poverty line"
						"125 US$2005 PPP"
						"200 US$2005 PPP"
						"250 US$2005 PPP"
						"400 US$2005 PPP";
	matrix colnames F = 	"headcount" "poverty gap" "squared poverty gap" 
							"headcount" "poverty gap" "squared poverty gap";
						
#delimit cr

putexcel B22= matrix(F, names) using "${table}/Tables_SCD.xlsx", sheet("National_Poverty") modify
mat drop _all

* By Male - Atoll
*-------------------------------------------------------------------------------
local years "2003 2010"
local pline "nat 125 200 250 400"
	foreach yr of local years{
	local i = 1
		foreach z of local pline{
			use "${out}/profile_`yr'.dta", clear
			povdeco y_`yr' [aw=wght_hh], by(reg2) varpline(z_`z')
			if `i'==1{
#delimit;
			matrix F_`yr' = (r(fgt0_1) , r(fgt1_1) , r(v_1), r(fgt2_1), r(share0_1)) \ 
							(r(fgt0_2) , r(fgt1_2) , r(v_2), r(fgt2_2) , r(share0_2));
			} ;
			else{ ;
			matrix F_`yr' = F_`yr' \ 
							(r(fgt0_1) , r(fgt1_1) , r(v_1), r(fgt2_1), r(share0_1)) \ 
							(r(fgt0_2) , r(fgt1_2) , r(v_2), r(fgt2_2) , r(share0_2));
#delimit cr
			}		
		local ++i
		} // pline
	} //years
	matrix F = F_2003 , F_2010
	mat rownames F = Male Atolls Male Atolls Male Atolls Male Atolls Male Atolls
	mat colnames F = FGT0 FGT1 FGT2 POORSHARE0 POPSHARE FGT0 FGT1 FGT2 POORSHARE0 POPSHARE
	putexcel B2= matrix(F, names) using "${table}/Tables_SCD.xlsx", sheet("National_Poverty_Reg2") modify
mat drop _all

* By Regions
*-------------------------------------------------------------------------------
local years "2003 2010"
local pline "nat 125 200 250 400"
	foreach yr of local years{
	local i = 1
		foreach z of local pline{
			use "${out}/profile_`yr'.dta", clear
			povdeco y_`yr' [aw=wght_hh], by(region6) varpline(z_`z')
			if `i'==1{
#delimit;
			matrix F_`yr' = (r(fgt0_0) , r(fgt1_0) , r(fgt2_0) , r(v_0) , r(share0_0)) \ 
							(r(fgt0_1) , r(fgt1_1) , r(fgt2_1) , r(v_1) , r(share0_1))\ 
							(r(fgt0_2) , r(fgt1_2) , r(fgt2_2) , r(v_2) , r(share0_2))\ 
							(r(fgt0_3) , r(fgt1_3) , r(fgt2_3) , r(v_3) , r(share0_3))\ 
							(r(fgt0_4) , r(fgt1_4) , r(fgt2_4) , r(v_4) , r(share0_4))\ 
							(r(fgt0_5) , r(fgt1_5) , r(fgt2_5) , r(v_5) , r(share0_5))\ 
							(r(fgt0_6) , r(fgt1_6) , r(fgt2_6) , r(v_6) , r(share0_6));
			} ;
			else{ ;
			matrix F_`yr' = F_`yr' \ 
							(r(fgt0_0) , r(fgt1_0) , r(fgt2_0) , r(v_0) , r(share0_0)) \ 
							(r(fgt0_1) , r(fgt1_1) , r(fgt2_1) , r(v_1) , r(share0_1))\ 
							(r(fgt0_2) , r(fgt1_2) , r(fgt2_2) , r(v_2) , r(share0_2))\ 
							(r(fgt0_3) , r(fgt1_3) , r(fgt2_3) , r(v_3) , r(share0_3))\ 
							(r(fgt0_4) , r(fgt1_4) , r(fgt2_4) , r(v_4) , r(share0_4))\ 
							(r(fgt0_5) , r(fgt1_5) , r(fgt2_5) , r(v_5) , r(share0_5))\ 
							(r(fgt0_6) , r(fgt1_6) , r(fgt2_6) , r(v_6) , r(share0_6));			
#delimit cr
			}		
		local ++i
		} // pline
	} //years
	matrix F = F_2003 , F_2010 
#delimit;
	mat rownames F = 	Male North	"Central N"	Central	"Central S"	South ""
						Male North	"Central N"	Central	"Central S"	South ""
						Male North	"Central N"	Central	"Central S"	South ""
						Male North	"Central N"	Central	"Central S"	South ""
						Male North	"Central N"	Central	"Central S"	South "";
						
#delimit cr
	mat colnames F = FGT0 FGT1 FGT2 POORSHARE0 POPSHARE FGT0 FGT1 FGT2 POORSHARE0 POPSHARE

	putexcel B2= matrix(F, names) using "${table}/Tables_SCD.xlsx", sheet("National_Poverty_Reg6") modify
mat drop _all

*===============================================================================
* MALDIVES DISTRIBUTIONS
*===============================================================================
* Append two years together
*-------------------------------------------------------------------------------
use "${out}/profile_2003.dta", clear
append using "${out}/profile_2010.dta"
replace year=2010 if year==.
egen y = rowtotal(y_2003 y_2010)
 
* Generate log per capita consumption
*-------------------------------------------------------------------------------
gen ln_y_2003 = ln(y_2003)
gen ln_y_2010 = ln(y_2010)

* Find Upper Bounds for the graphs
*-------------------------------------------------------------------------------
local year "2003 2010"
foreach yr of local year{
sum y_`yr' [aw=wght_hh], det
gen p95_`yr' = r(p95)
}

* Density Function
*-------------------------------------------------------------------------------
sum z_nat
local z = r(mean)

#delimit ;
twoway 	(kdensity y_2003 	[aweight = wght_hh] if year==2003 & y_2003<=p95_2010, lwidth(thick)) ||
		(kdensity y_2010 	[aweight = wght_hh] if year==2010 & y_2010<=p95_2010, lwidth(thick)),
	 	graphregion(style(none) color(white) fcolor(white) lstyle(none) lcolor(white) lwidth(thin))
		scheme(economist)
		xline(`z', lcolor(ebblue) lwidth(thick))
		ytitle("Density (number of poor individuals)")
		xtitle("Monthly per capita MVR, 2010 prices")
		legend( 
				cols(1) 
				symxsize(4) 
				order(1 "2003" 2 "2010")
			ring(0) bplacement(ne) region(color(none))
			) ;
#delimit cr	
graph save Graph "${figure}/Density_2003_2010.gph", replace

* Density Function
*-------------------------------------------------------------------------------
sum z_nat
local z = r(mean)

#delimit ;
twoway 	(kdensity y_2010 	[aweight = wght_hh] if reg2==1 & y_2010<=p95_2010, lwidth(thick)) ||
		(kdensity y_2010 	[aweight = wght_hh] if reg2==2 & y_2010<=p95_2010, lwidth(thick)),
	 	graphregion(style(none) color(white) fcolor(white) lstyle(none) lcolor(white) lwidth(thin))
		scheme(economist)
		xline(`z', lcolor(ebblue) lwidth(thick))
		ytitle("Density (number of poor individuals)")
		xtitle("Monthly per capita MVR, 2010 prices")
		legend( 
				cols(1) 
				symxsize(4) 
				order(1 "Male'" 2 "Atolls")
			ring(0) bplacement(ne) region(color(none))
			) ;
#delimit cr	
graph save Graph "${figure}/Density_Male_Atolls.gph", replace

* Pen's Parade
*-------------------------------------------------------------------------------
* Over time
*-------------------------------------------------------------------------------
#delimit ;
alorenz y [pw=wght_hh] if y<p95_2010, points(100) gp angle45 format(%12.0f) by(year)
	 	graphregion(style(none) color(white) fcolor(white) lstyle(none) lcolor(white) lwidth(thin))
		scheme(economist)
		yline(787.5, lcolor(ebblue) lwidth(thick))
		yline(1266 , lcolor(ebblue) lwidth(thick))
		ytitle("Monthly per capita MVR, 2010 prices")
		xtitle("Population percentiles")
		text(787.5 102 "787.5", place(e))
		text(1266  102 "1266", place(e))
		title("")
		legend( 
				cols(1) 
				symxsize(4) 
				order(1 "2003" 2 "2010")
			ring(0) bplacement(nW) region(color(none))
			) ;
#delimit cr
graph save Graph "${figure}/Quantile_2003_2010.gph", replace

* Male' - Atolls
*-------------------------------------------------------------------------------

#delimit ;
alorenz y_2010 [pw=wght_hh] if y_2010<p95_2010, points(100) gp  by(reg2)
	 	graphregion(style(none) color(white) fcolor(white) lstyle(none) lcolor(white) lwidth(thin))
		scheme(economist)
		yline(787.5, lcolor(ebblue) lwidth(thick))
		yline(1266 , lcolor(ebblue) lwidth(thick))
		ytitle("Monthly per capita MVR, 2010 prices")
		xtitle("Population percentiles")
		text(787.5 102 "787.5", place(e))
		text(1266  102 "1,266", place(e))
		title("")
		legend( 
				cols(1) 
				symxsize(4) 
				order(1 "Male'" 2 "Atolls")
			ring(0) bplacement(nw) region(color(none))
			) ;
#delimit cr			
graph save Graph "${figure}/Quantile_Male_Atolls.gph", replace

* Male' - overtime
*-------------------------------------------------------------------------------

#delimit ;
alorenz y [pw=wght_hh] if y<p95_2010 & reg2==1, points(100) gp  by(year)
	 	graphregion(style(none) color(white) fcolor(white) lstyle(none) lcolor(white) lwidth(thin))
		scheme(economist)
		yline(787.5, lcolor(ebblue) lwidth(thick))
		yline(1266 , lcolor(ebblue) lwidth(thick))
		ytitle("Monthly per capita MVR, 2010 prices")
		xtitle("Population percentiles")
		text(787.5 102 "787.5", place(e))
		text(1266  102 "1,266", place(e))
		title("")
		legend( 
				cols(1) 
				symxsize(4) 
				order(1 "2003" 2 "2010")
			ring(0) bplacement(nw) region(color(none))
			) ;
#delimit cr			
graph save Graph "${figure}/Quantile_Male_2003_2010.gph", replace

* Atolls - overtime
*-------------------------------------------------------------------------------

#delimit ;
alorenz y [pw=wght_hh] if y<p95_2010 & reg2==2, points(100) gp  by(year)
	 	graphregion(style(none) color(white) fcolor(white) lstyle(none) lcolor(white) lwidth(thin))
		scheme(economist)
		yline(787.5, lcolor(ebblue) lwidth(thick))
		yline(1266 , lcolor(ebblue) lwidth(thick))
		ytitle("Monthly per capita MVR, 2010 prices")
		xtitle("Population percentiles")
		text(787.5 102 "787.5", place(e))
		text(1266  102 "1,266", place(e))
		title("")
		legend( 
				cols(1) 
				symxsize(4) 
				order(1 "2003" 2 "2010")
			ring(0) bplacement(nw) region(color(none))
			) ;
#delimit cr			
graph save Graph "${figure}/Quantile_Atolls_2003_2010.gph", replace


*===============================================================================
* GIC
*===============================================================================
* Overall
tempfile gic

use "${out}/profile_2003.dta", clear
#delimit;
gicurve using "${out}/profile_2010.dta" [aw=wght_hh],	
		var1(y_2003) var2(y_2010) yperiod(7) outputfile(`gic')
		np(500) meangr ci(100 95) minmax		
	 	graphregion(color(white) fcolor(white)) scheme(economist)
		subtitle("")
		legend( 
			cols(1) 
			symxsize(4) 
			order(2 "Growth Incidence" 1 "95% Confidence Interval" 3 "Mean growth rate")
			ring(0) bplacement(nw) region(color(none))
			) ;
#delimit cr	


graph save Graph "${figure}/MDV_gic_2003_2010.gph", replace
use `gic', clear
#delimit ;
export excel 	pctl pr_growth pg_ci_l pg_ci_u gr_in_mean gr_in_median intgrl1 mean_of_growth 
				using "${table}/Tables_SCD.xlsx", sheet("GIC_2003_2010") sheetmodify 
				firstrow(varlabels);
#delimit cr

* Male' / Atolls

tempfile gic
forvalues i=1(1)2{
use "${out}/profile_2003.dta", clear
sum y_2003, det
keep if y_2003<r(p99)
keep if reg2==`i'
tempfile data_2003_`i'
save `data_2003_`i''

use "${out}/profile_2010.dta", clear
keep if reg2==`i'
sum y_2010, det
keep if y_2010<r(p99)
tempfile data_2010_`i'
save `data_2010_`i''

use `data_2003_`i''
#delimit;
gicurve using `data_2010_`i'' [aw=wght_hh],	
		var1(y_2003) var2(y_2010) yperiod(7) outputfile(`gic')
		np(500) meangr ci(100 95) minmax		
	 	graphregion(color(white) fcolor(white)) scheme(economist)
		subtitle("")
		legend( 
			cols(1) 
			symxsize(4) 
			order(2 "Growth Incidence" 1 "95% Confidence Interval" 3 "Mean growth rate")
			ring(0) bplacement(nw) region(color(none))
			) ;
#delimit cr	

graph save Graph "${figure}/MDV_gic_2003_2010_`i'.gph", replace
use `gic', clear
#delimit ;
export excel 	pctl pr_growth pg_ci_l pg_ci_u gr_in_mean gr_in_median intgrl1 mean_of_growth 
				using "${table}/Tables_SCD.xlsx", sheet("GIC_2003_2010_`i'") sheetmodify 
				firstrow(varlabels);
#delimit cr
}

*===============================================================================
* Inequality
*===============================================================================
local year 2003 2010
foreach yr of local year{
use "${out}/profile_`yr'.dta", clear
	ineqdeco y_`yr' [aw=wght_hh]
	matrix I_`yr' = r(gini) \ r(ge1) \ r(p90p10) \ r(p75p25)
} // year
matrix I = I_2003 , I_2010

	matrix colnames I = 2003 2010
	matrix rownames I = Gini Theil p90_p10 p75_p25
	
putexcel B2= matrix(I, names) using "${table}/Tables_SCD.xlsx", sheet("Inequality") modify
matrix drop _all

*===============================================================================
* Datt-Ravallion Decomposition
*===============================================================================
local pline_nat = 787.4419
local pline_125 = 517.0833
local pline_200 = 821.25
local pline_250 = 1034.167
local pline_400 = 1642.5

local pline "nat 125 200 250 400"
foreach z of local pline{
	dfgtgr y_2003 y_2010 , alpha(0) pline(`pline_`z'') file1("${out}/profile_2003.dta") file2("${out}/profile_2010.dta") 
	matrix DR = e(c5) \ e(c6)
	matrix rownames DR = growth redistribution
	matrix colnames DR = "pline is `z'"
	putexcel B2=matrix(DR, names) using "${table}/Tables_SCD.xlsx", sheet("DR_`z'") modify
}


*===============================================================================
* Ravallion Huppi
*===============================================================================
* Prepare dataset
*-------------------------------------------------------------------------------
tempfile data_2003
tempfile data_2010

local year "2003 2010"
foreach yr of local year{
use "${out}/profile_`yr'.dta", clear
keep if head==1
replace ind_code = 13 if ind_code ==.
gen y = y_`yr'
svyset  [pw=wght_hh], strata(region) singleunit(certainty)
save `data_`yr''
}

dfgtg2d y y , alpha(0) pline(787.4419) file1(`data_2003') hsize1(hhsize) file2(`data_2010') hsize2(hhsize) hgroup(industry_short) ref(0)
dfgtg2d y y , alpha(0) pline(787.4419) file1(`data_2003') hsize1(hhsize) file2(`data_2010') hsize2(hhsize) hgroup(reg2) ref(0)
*/

*===============================================================================
* Poverty Decomposition - Not applicable because we do not have income module
* in 2003
*===============================================================================


*===============================================================================
* PROFILING
*===============================================================================
local country "Maldives"
local year "2010"
local location 				"geo_male geo_atoll reg_1 reg_2 reg_3 reg_4 reg_5 reg_6 geo_overall"
local reference_pop 		"poor_nat poor_125 poor_200 poor_250 poor_400 b40 t60 d_1 d_2 d_3 d_4 d_5 d_6 d_7 d_8 d_9 d_10 overall"
local Demographic_var 		"age_014 age_1524 age_2565 age_6500 n_child_cap male female marstat_1 marstat_2 marstat_3 marstat_4"
local Education_var 		"edu_0_none_inc edu_1_prim edu_2_sec edu_3_voc edu_4_higher geo_overall"
local Labor_Industry_var 	"lfstat_emp lfstat_unemp lfstat_olf ind_1 ind_2 ind_3 ind_4 ind_5 ind_6 ind_7 ind_8 ind_9 ind_10 ind_11 ind_12"
local Income_var "inc_1 inc_2 inc_3 inc_4 inc_5 inc_6 inc_7 inc_8 inc_pens_tag inc_fami_tag inc_fama_tag inc_other_tag inc_wage_tag inc_bus_tag inc_prop_tag inc_gov_tag"
local Income_sh_var "sh_inc_wage sh_inc_bus sh_inc_fami sh_inc_fama sh_inc_gov sh_inc_pens sh_inc_prop sh_inc_other"
local Income_short_sh_var "  sh_inc_short_labor_hh sh_inc_short_tran_priv_hh sh_inc_short_tran_gov_hh sh_inc_short_prop_hh sh_inc_short_other_hh"
use "${out}/profile_2010.dta", clear


* Demographic
*-------------------------------------------------------------------------------
local chapter 		"Demographic"

foreach ch of local chapter{ 
cap file open `ch' using "${table}/Tables_SCD_`ch'.csv", write text replace
local n 1
	if `n'==1{
		file write `ch' "country,year,chapter,"
		file write `ch' "denominator,reference_population,location,variable,"
		file write `ch' "mean,standard_deviation,Observations,Weighted_Obs "_n

			foreach p of local reference_pop {
				foreach l of local location {
					foreach v of local `ch'_var {
						sum `v' [aw=wght_ind] if head==1 & `p'==1 & `l'==1 
						local mean = r(mean) 	
						local N=r(N)
						local sum_w=r(sum_w)
						local sd = r(sd)
		file write `ch' "`country',`year',`ch',"
		file write `ch' "ind,`p',`l',`v',"
		file write `ch' "`mean',`sd',`N',`sum_w'" _n
					}
				}
			}
		local ++n
	}
	file close `ch'
}

* Education
*-------------------------------------------------------------------------------
local chapter 		"Education"

foreach ch of local chapter{ 
cap file open `ch' using "${table}/Tables_SCD_`ch'.csv", write text replace
local n 1
	if `n'==1{
		file write `ch' "country,year,chapter,"
		file write `ch' "denominator,reference_population,location,variable,"
		file write `ch' "mean,standard_deviation,Observations,Weighted_Obs "_n

			foreach p of local reference_pop {
				foreach l of local location {
					foreach v of local `ch'_var {
						sum `v' [aw=wght_ind] if head==1 & `p'==1 & `l'==1 
						local mean = r(mean) 	
						local N=r(N)
						local sum_w=r(sum_w)
						local sd = r(sd)
		file write `ch' "`country',`year',`ch',"
		file write `ch' "ind,`p',`l',`v',"
		file write `ch' "`mean',`sd',`N',`sum_w'" _n
					}
				}
			}
		local ++n
	}
	file close `ch'
}



* Labour Force Status and Industry
*-------------------------------------------------------------------------------
local chapter 		"Labor_Industry"

foreach ch of local chapter{ 
cap file open `ch' using "${table}/Tables_SCD_`ch'.csv", write text replace
local n 1
	if `n'==1{
		file write `ch' "country,year,chapter,"
		file write `ch' "denominator,reference_population,location,variable,"
		file write `ch' "mean,standard_deviation,Observations,Weighted_Obs "_n

			foreach p of local reference_pop {
				foreach l of local location {
					foreach v of local `ch'_var {
						sum `v' [aw=wght_ind] if head==1 & `p'==1 & `l'==1 & ind_code!=13
						local mean = r(mean) 	
						local N=r(N)
						local sum_w=r(sum_w)
						local sd = r(sd)
		file write `ch' "`country',`year',`ch',"
		file write `ch' "ind,`p',`l',`v',"
		file write `ch' "`mean',`sd',`N',`sum_w'" _n
					}
				}
			}
		local ++n
	}
	file close `ch'
}

* Income
*-------------------------------------------------------------------------------
local chapter 		"Income"
tab inc_max_hh_label, gen(inc_)

foreach ch of local chapter{ 
cap file open `ch' using "${table}/Tables_SCD_`ch'.csv", write text replace
local n 1
	if `n'==1{
		file write `ch' "country,year,chapter,"
		file write `ch' "denominator,reference_population,location,variable,"
		file write `ch' "mean,standard_deviation,Observations,Weighted_Obs "_n

			foreach p of local reference_pop {
				foreach l of local location {
					foreach v of local `ch'_var {
						sum `v' [aw=wght_ind] if head==1 & `p'==1 & `l'==1 
						local mean = r(mean) 	
						local N=r(N)
						local sum_w=r(sum_w)
						local sd = r(sd)
		file write `ch' "`country',`year',`ch',"
		file write `ch' "ind,`p',`l',`v',"
		file write `ch' "`mean',`sd',`N',`sum_w'" _n
					}
				}
			}
		local ++n
	}
	file close `ch'
}


* Income Shares
*-------------------------------------------------------------------------------
local chapter 		"Income_sh"

foreach ch of local chapter{ 
cap file open `ch' using "${table}/Tables_SCD_`ch'.csv", write text replace
local n 1
	if `n'==1{
		file write `ch' "country,year,chapter,"
		file write `ch' "denominator,reference_population,location,variable,"
		file write `ch' "mean,standard_deviation,Observations,Weighted_Obs "_n

			foreach p of local reference_pop {
				foreach l of local location {
					foreach v of local `ch'_var {
						sum `v' [aw=wght_ind] if head==1 & `p'==1 & `l'==1 
						local mean = r(mean) 	
						local N=r(N)
						local sum_w=r(sum_w)
						local sd = r(sd)
		file write `ch' "`country',`year',`ch',"
		file write `ch' "ind,`p',`l',`v',"
		file write `ch' "`mean',`sd',`N',`sum_w'" _n
					}
				}
			}
		local ++n
	}
	file close `ch'
}


* Income Shares Short
*-------------------------------------------------------------------------------
local chapter 		"Income_short_sh"

foreach ch of local chapter{ 
cap file open `ch' using "${table}/Tables_SCD_`ch'.csv", write text replace
local n 1
	if `n'==1{
		file write `ch' "country,year,chapter,"
		file write `ch' "denominator,reference_population,location,variable,"
		file write `ch' "mean,standard_deviation,Observations,Weighted_Obs "_n

			foreach p of local reference_pop {
				foreach l of local location {
					foreach v of local `ch'_var {
						sum `v' [aw=wght_ind] if head==1 & `p'==1 & `l'==1 
						local mean = r(mean) 	
						local N=r(N)
						local sum_w=r(sum_w)
						local sd = r(sd)
		file write `ch' "`country',`year',`ch',"
		file write `ch' "ind,`p',`l',`v',"
		file write `ch' "`mean',`sd',`N',`sum_w'" _n
					}
				}
			}
		local ++n
	}
	file close `ch'
}

* Import .csv in Stata
*-------------------------------------------------------------------------------
local chapter 		"Demographic Education Labor_Industry Income  Income_sh Income_short_sh"

foreach ch of local chapter{
import delimited "${table}/Tables_SCD_`ch'.csv", delimiter(, collapse) varnames(1) clear 
egen id=concat(reference location variable)
order id
export excel using "${table}/Tables_SCD.xlsx", sheet("`ch'_raw") sheetmodify firstrow(variables)
}

/*
*===============================================================================
* POVERTY HEADCOUNTS AND SUBGROUPS DECOMPOSITION
*===============================================================================

* Age of the HH
*-------------------------------------------------------------------------------
local years "2010"
local pline "nat 125 200 250 400"
	foreach yr of local years{
	local i = 1
		foreach z of local pline{
			use "${out}/profile_`yr'.dta", clear
			povdeco y_`yr' [aw=wght_ind] if head==1, by(age_group) varpline(z_`z')
			if `i'==1{
#delimit;
			matrix P_`yr' = (r(fgt0_2) , r(fgt1_2) , r(fgt2_2) , r(v_2) , r(share0_2))\ 
							(r(fgt0_3) , r(fgt1_3) , r(fgt2_3) , r(v_3) , r(share0_3))\
							(r(fgt0_4) , r(fgt1_4) , r(fgt2_4) , r(v_4) , r(share0_4));
			} ;
			else{ ;
			matrix P_`yr' = P_`yr' \ 							 
							(r(fgt0_2) , r(fgt1_2) , r(fgt2_2) , r(v_2) , r(share0_2))\ 
							(r(fgt0_3) , r(fgt1_3) , r(fgt2_3) , r(v_3) , r(share0_3))\
							(r(fgt0_4) , r(fgt1_4) , r(fgt2_4) , r(v_4) , r(share0_4));
#delimit cr
			}		
		local ++i
		} // pline
	} //years

	matrix P = P_2010
#delimit;
	mat rownames P = 	"15-24" "25-65" "65+"
						"15-24" "25-65" "65+"
						"15-24" "25-65" "65+"
						"15-24" "25-65" "65+"
						"15-24" "25-65" "65+";
						
#delimit cr
	mat colnames P = FGT0 FGT1 FGT2  POPSHAREPOORSHARE0 

	putexcel B2= matrix(P, names) using "${table}/Tables_SCD.xlsx", sheet("Poor_age") modify
mat drop _all


* Education of the HH
*-------------------------------------------------------------------------------
local years "2010"
local pline "nat 125 200 250 400"
	foreach yr of local years{
	local i = 1
		foreach z of local pline{
			use "${out}/profile_`yr'.dta", clear
			replace edu_lev=1 if edu_lev==.
			povdeco y_`yr' [aw=wght_ind] if head==1, by(edu_lev) varpline(z_`z')
			if `i'==1{
#delimit;
			matrix P_`yr' = (r(fgt0_1) , r(fgt1_1) , r(fgt2_1) , r(v_1) , r(share0_1))\ 
							(r(fgt0_2) , r(fgt1_2) , r(fgt2_2) , r(v_2) , r(share0_2))\ 
							(r(fgt0_3) , r(fgt1_3) , r(fgt2_3) , r(v_3) , r(share0_3))\
							(r(fgt0_4) , r(fgt1_4) , r(fgt2_5) , r(v_4) , r(share0_4))\ 
							(r(fgt0_5) , r(fgt1_5) , r(fgt2_4) , r(v_5) , r(share0_5));
			} ;
			else{ ;
			matrix P_`yr' = P_`yr' \ 
							(r(fgt0_1) , r(fgt1_1) , r(fgt2_1) , r(v_1) , r(share0_1))\ 
							(r(fgt0_2) , r(fgt1_2) , r(fgt2_2) , r(v_2) , r(share0_2))\ 
							(r(fgt0_3) , r(fgt1_3) , r(fgt2_3) , r(v_3) , r(share0_3))\			
							(r(fgt0_4) , r(fgt1_4) , r(fgt2_5) , r(v_4) , r(share0_4))\ 
							(r(fgt0_5) , r(fgt1_5) , r(fgt2_4) , r(v_5) , r(share0_5));
#delimit cr
			}		
		local ++i
		} // pline
	} //years


	matrix P = P_2010
#delimit;
	mat rownames P = 	"None or Incomplete Primary" "Primary" "Lower Secondary" "Vocational" "Higher Secondary and Tertiary"
						"None or Incomplete Primary" "Primary" "Lower Secondary" "Vocational" "Higher Secondary and Tertiary"
						"None or Incomplete Primary" "Primary" "Lower Secondary" "Vocational" "Higher Secondary and Tertiary"
						"None or Incomplete Primary" "Primary" "Lower Secondary" "Vocational" "Higher Secondary and Tertiary"
						"None or Incomplete Primary" "Primary" "Lower Secondary" "Vocational" "Higher Secondary and Tertiary" ;
						
#delimit cr
	mat colnames P = FGT0 FGT1 FGT2 POPSHARE POORSHARE0 

	putexcel B2= matrix(P, names) using "${table}/Tables_SCD.xlsx", sheet("Poor_education") modify
mat drop _all


* Industry of employment of the household head
*-------------------------------------------------------------------------------
local years "2010"
local pline "nat 125 200 250 400"
	foreach yr of local years{
	local i = 1
		foreach z of local pline{
			use "${out}/profile_`yr'.dta", clear
			replace edu_lev=1 if edu_lev==.
			povdeco y_`yr' [aw=wght_ind] if head==1, by(ind_code_short) varpline(z_`z')
			if `i'==1{
#delimit;
			matrix P_`yr' = (r(fgt0_1) , r(fgt1_1) , r(fgt2_1) , r(v_1) , r(share0_1))\ 
							(r(fgt0_2) , r(fgt1_2) , r(fgt2_2) , r(v_2) , r(share0_2))\ 
							(r(fgt0_3) , r(fgt1_3) , r(fgt2_3) , r(v_3) , r(share0_3))\
							(r(fgt0_4) , r(fgt1_4) , r(fgt2_4) , r(v_4) , r(share0_4))\ 
							(r(fgt0_5) , r(fgt1_5) , r(fgt2_5) , r(v_5) , r(share0_5))\
							(r(fgt0_6) , r(fgt1_6) , r(fgt2_6) , r(v_6) , r(share0_6))\ 
							(r(fgt0_7) , r(fgt1_7) , r(fgt2_7) , r(v_7) , r(share0_7))\ 
							(r(fgt0_13) , r(fgt1_13) , r(fgt2_13) , r(v_13) , r(share0_13));
			} ;
			else{ ;
			matrix P_`yr' = P_`yr' \ 
							 (r(fgt0_1) , r(fgt1_1) , r(fgt2_1) , r(v_1) , r(share0_1))\ 
							(r(fgt0_2) , r(fgt1_2) , r(fgt2_2) , r(v_2) , r(share0_2))\ 
							(r(fgt0_3) , r(fgt1_3) , r(fgt2_3) , r(v_3) , r(share0_3))\
							(r(fgt0_4) , r(fgt1_4) , r(fgt2_4) , r(v_4) , r(share0_4))\ 
							(r(fgt0_5) , r(fgt1_5) , r(fgt2_5) , r(v_5) , r(share0_5))\
							(r(fgt0_6) , r(fgt1_6) , r(fgt2_6) , r(v_6) , r(share0_6))\ 
							(r(fgt0_7) , r(fgt1_7) , r(fgt2_7) , r(v_7) , r(share0_7))\ 
							(r(fgt0_13) , r(fgt1_13) , r(fgt2_13) , r(v_13) , r(share0_13));
#delimit cr
			}		
		local ++i
		} // pline
	} //years


	matrix P = P_2010
#delimit;
	mat rownames P = 	"Fisheries and Agriculture" "Manufacturing" "Construction" "Hotel/restaurant" "Public Administration" "Education and Health" "Other Services" "Not Employed" 
						"Fisheries and Agriculture" "Manufacturing" "Construction" "Hotel/restaurant" "Public Administration" "Education and Health" "Other Services" "Not Employed"						
						"Fisheries and Agriculture" "Manufacturing" "Construction" "Hotel/restaurant" "Public Administration" "Education and Health" "Other Services" "Not Employed"						
						"Fisheries and Agriculture" "Manufacturing" "Construction" "Hotel/restaurant" "Public Administration" "Education and Health" "Other Services" "Not Employed"						
						"Fisheries and Agriculture" "Manufacturing" "Construction" "Hotel/restaurant" "Public Administration" "Education and Health" "Other Services" "Not Employed";						
#delimit cr
	mat colnames P = FGT0 FGT1 FGT2 POPSHARE POORSHARE0

	putexcel B2= matrix(P, names) using "${table}/Tables_SCD.xlsx", sheet("Poor_industry") modify
mat drop _all


* Labor
*-------------------------------------------------------------------------------
local years "2010"
local pline "nat 125 200 250 400"
	foreach yr of local years{
	local i = 1
		foreach z of local pline{
			use "${out}/profile_`yr'.dta", clear
			povdeco y_`yr' [aw=wght_ind] if head==1, by(lfstat) varpline(z_`z')
			if `i'==1{
#delimit;
			matrix P_`yr' = (r(fgt0_1) , r(fgt1_1) , r(fgt2_1) , r(v_1) , r(share0_1))\ 
							(r(fgt0_2) , r(fgt1_2) , r(fgt2_2) , r(v_2) , r(share0_2))\ 
							(r(fgt0_3) , r(fgt1_3) , r(fgt2_3) , r(v_3) , r(share0_3));
			} ;
			else{ ;
			matrix P_`yr' = P_`yr' \ 
							(r(fgt0_1) , r(fgt1_1) , r(fgt2_1) , r(v_1) , r(share0_1))\ 
							(r(fgt0_2) , r(fgt1_2) , r(fgt2_2) , r(v_2) , r(share0_2))\ 
							(r(fgt0_3) , r(fgt1_3) , r(fgt2_3) , r(v_3) , r(share0_3));			
#delimit cr
			}		
		local ++i
		} // pline
	} //years

	matrix P = P_2010
#delimit;
	mat rownames P = 	Employed Unemployed	OLF
						Employed Unemployed	OLF
						Employed Unemployed	OLF
						Employed Unemployed	OLF
						Employed Unemployed	OLF;
						
#delimit cr
	mat colnames P = FGT0 FGT1 FGT2 POPSHAREPOORSHARE0 

	putexcel B2= matrix(P, names) using "${table}/Tables_SCD.xlsx", sheet("Poor_lfstat") modify
mat drop _all

* Male'
local years "2010"
local pline "nat 125 200 250 400"
	foreach yr of local years{
	local i = 1
		foreach z of local pline{
			use "${out}/profile_`yr'.dta", clear
			povdeco y_`yr' [aw=wght_ind] if head==1 & geo_male==1, by(lfstat) varpline(z_`z')
			if `i'==1{
#delimit;
			matrix P_`yr' = (r(fgt0_1) , r(fgt1_1) , r(fgt2_1) , r(v_1) , r(share0_1))\ 
							(r(fgt0_2) , r(fgt1_2) , r(fgt2_2) , r(v_2) , r(share0_2))\ 
							(r(fgt0_3) , r(fgt1_3) , r(fgt2_3) , r(v_3) , r(share0_3));
			} ;
			else{ ;
			matrix P_`yr' = P_`yr' \ 
							(r(fgt0_1) , r(fgt1_1) , r(fgt2_1) , r(v_1) , r(share0_1))\ 
							(r(fgt0_2) , r(fgt1_2) , r(fgt2_2) , r(v_2) , r(share0_2))\ 
							(r(fgt0_3) , r(fgt1_3) , r(fgt2_3) , r(v_3) , r(share0_3));			
#delimit cr
			}		
		local ++i
		} // pline
	} //years

	matrix P = P_2010
#delimit;
	mat rownames P = 	Employed Unemployed	OLF
						Employed Unemployed	OLF
						Employed Unemployed	OLF
						Employed Unemployed	OLF
						Employed Unemployed	OLF;
						
#delimit cr
	mat colnames P = FGT0 FGT1 FGT2 POORSHARE0 POPSHARE

	putexcel B22= matrix(P, names) using "${table}/Tables_SCD.xlsx", sheet("Poor_lfstat") modify
mat drop _all

* Atolls
local years "2010"
local pline "nat 125 200 250 400"
	foreach yr of local years{
	local i = 1
		foreach z of local pline{
			use "${out}/profile_`yr'.dta", clear
			povdeco y_`yr' [aw=wght_ind] if head==1 & geo_atoll==1, by(lfstat) varpline(z_`z')
			if `i'==1{
#delimit;
			matrix P_`yr' = (r(fgt0_1) , r(fgt1_1) , r(fgt2_1) , r(v_1) , r(share0_1))\ 
							(r(fgt0_2) , r(fgt1_2) , r(fgt2_2) , r(v_2) , r(share0_2))\ 
							(r(fgt0_3) , r(fgt1_3) , r(fgt2_3) , r(v_3) , r(share0_3));
			} ;
			else{ ;
			matrix P_`yr' = P_`yr' \ 
							(r(fgt0_1) , r(fgt1_1) , r(fgt2_1) , r(v_1) , r(share0_1))\ 
							(r(fgt0_2) , r(fgt1_2) , r(fgt2_2) , r(v_2) , r(share0_2))\ 
							(r(fgt0_3) , r(fgt1_3) , r(fgt2_3) , r(v_3) , r(share0_3));			
#delimit cr
			}		
		local ++i
		} // pline
	} //years

	matrix P = P_2010
#delimit;
	mat rownames P = 	Employed Unemployed	OLF
						Employed Unemployed	OLF
						Employed Unemployed	OLF
						Employed Unemployed	OLF
						Employed Unemployed	OLF;
						
#delimit cr
	mat colnames P = FGT0 FGT1 FGT2 POPSHARE POORSHARE0 

	putexcel B42= matrix(P, names) using "${table}/Tables_SCD.xlsx", sheet("Poor_lfstat") modify
mat drop _all



* Dependency
*-------------------------------------------------------------------------------
table ind_code_short reg2 if head==1 [aw=wght_hh], c(mean dep_ratio mean poor_nat)


*===============================================================================
* INCOME
*===============================================================================
local years "2010"
local pline "nat 125 200 250 400"
	foreach yr of local years{
	local i = 1
		foreach z of local pline{
			povdeco y_`yr' [aw=wght_ind] if head==1, by(inc_max_hh_label) varpline(z_`z')
			if `i'==1{
#delimit;
			matrix P_`yr' = (r(fgt0_1) , r(fgt1_1) , r(fgt2_1) , r(v_1) , r(share0_1))\ 
							(r(fgt0_2) , r(fgt1_2) , r(fgt2_2) , r(v_2) , r(share0_2))\ 
							(r(fgt0_3) , r(fgt1_3) , r(fgt2_3) , r(v_3) , r(share0_3))\
							(r(fgt0_4) , r(fgt1_4) , r(fgt2_4) , r(v_4) , r(share0_4))\ 
							(r(fgt0_5) , r(fgt1_5) , r(fgt2_5) , r(v_5) , r(share0_5))\
							(r(fgt0_6) , r(fgt1_6) , r(fgt2_6) , r(v_6) , r(share0_6))\ 
							(r(fgt0_7) , r(fgt1_7) , r(fgt2_7) , r(v_7) , r(share0_7))\ 
							(r(fgt0_8) , r(fgt1_8) , r(fgt2_8) , r(v_8) , r(share0_8));
			} ;
			else{ ;
			matrix P_`yr' = P_`yr' \ 
							 (r(fgt0_1) , r(fgt1_1) , r(fgt2_1) , r(v_1) , r(share0_1))\ 
							(r(fgt0_2) , r(fgt1_2) , r(fgt2_2) , r(v_2) , r(share0_2))\ 
							(r(fgt0_3) , r(fgt1_3) , r(fgt2_3) , r(v_3) , r(share0_3))\
							(r(fgt0_4) , r(fgt1_4) , r(fgt2_4) , r(v_4) , r(share0_4))\ 
							(r(fgt0_5) , r(fgt1_5) , r(fgt2_5) , r(v_5) , r(share0_5))\
							(r(fgt0_6) , r(fgt1_6) , r(fgt2_6) , r(v_6) , r(share0_6))\ 
							(r(fgt0_7) , r(fgt1_7) , r(fgt2_7) , r(v_7) , r(share0_7))\ 
							(r(fgt0_8) , r(fgt1_8) , r(fgt2_8) , r(v_8) , r(share0_8));
#delimit cr
			}		
		local ++i
		} // pline
	} //years


	matrix P = P_2010
#delimit;
	mat rownames P = 	"Wages" "Pensions" "Private Transfers" "Remittances" "Public Transfers" "Self-Employment" "Properties" "Other"
						"Wages" "Pensions" "Private Transfers" "Remittances" "Public Transfers" "Self-Employment" "Properties" "Other"						
						"Wages" "Pensions" "Private Transfers" "Remittances" "Public Transfers" "Self-Employment" "Properties" "Other"						
						"Wages" "Pensions" "Private Transfers" "Remittances" "Public Transfers" "Self-Employment" "Properties" "Other"						
						"Wages" "Pensions" "Private Transfers" "Remittances" "Public Transfers" "Self-Employment" "Properties" "Other";						
#delimit cr
	mat colnames P = FGT0 FGT1 FGT2 POPSHARE POORSHARE0

	putexcel B2= matrix(P, names) using "${table}/Tables_SCD.xlsx", sheet("Poor_Income_source") modify
mat drop _all

/*
* PROBIT
*-------------------------------------------------------------------------------
use "${out}/profile_2010.dta", clear
local demographic	"age age2 sex hhsize i.n_child marital"
local education		"edu_0_none_inc edu_1_prim edu_3_voc edu_4_higher"

replace n_child = 4 if n_child>4

keep if head==1
*svyset atoll [pweight=wght_hh], strata(region)
gen age2 = age^2
gen hhsize_cap = hhsize

logit poor_nat `demographic' i.geo_atoll i.industry_short `education'
margins, dydx(*)
estimates store m`yr', title("`yr'")
*/


use "${out}/profile_2010.dta", clear

* Average Income
*-------------------------------------------------------------------------------
matrix I =. , .
matrix B =. , .
forvalues i=1(1)7{
sum inc_wage_i if inc_wage_i!=0 & ind_code_short==`i' [aw=wght_hh]
matrix I = I \ r(mean) , r(N)
sum inc_bus_i if inc_bus_i!=0 & ind_code_short==`i' [aw=wght_hh]
matrix B = B \ r(mean) , r(N)
}

matrix rownames I = "Average mothly wage" "Fisheries and Agriculture" "Manufacturing" "Construction" "Hotel/restaurant" "Public Administration" "Education and Health" "Other Services"
matrix rownames B = "Average mothly profit" "Fisheries and Agriculture" "Manufacturing" "Construction" "Hotel/restaurant" "Public Administration" "Education and Health" "Other Services"
putexcel B2= matrix(I, names) using "${table}/Tables_SCD.xlsx", sheet("Income_wages") modify
putexcel B20= matrix(B, names) using "${table}/Tables_SCD.xlsx", sheet("Income_wages") modify

mat drop _all

