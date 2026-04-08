clear all
****************************************************************************************************
								******IMPORTING ALL THE FILES******************
***************************************************************************************************
global comp "C:\Users\wb357339\Dropbox" 
*global comp "C:\Users\FF\Dropbox" 
global pricework "$comp\Shared Pak Poverty Work"
global data2013 "$pricework\PSLM 13-14\raw data"
global i2d2 "$pricework\I2D2"
global consump1314 "$pricework\PSLM 13-14\Consumption Checks\data files"



*---Getting the hh identifiers and weights from plist----*
	use "$data2013\plist.dta", clear
	rename weights weight
	collapse province region psu weight, by(hhcode)
	tempfile `plist13'
	save plist13, replace

*---Consumption Data is all in one file----*	
	use "$data2013\sec_6abcde.dta", clear
	isid hhcode itc
	merge m:1 hhcode province region psu using plist13
	drop _m
	tempfile `sec6_13'
	save sec6_13, replace

*----To find the equivalent adults in each household-----*

	use "$data2013\plist.dta", clear
	*everyone is a hh memeber, so we do not need two hh sizes by members and non-members
	keep hhcode idc age
	gen adult=0.8 if age<18
	recode adult .=1
	collapse (sum) eqadults=adult (count) hhsize=idc, by(hhcode)
	label var eqadults "Number of equivalent adults counting members & nonmembers"
	label var hhsize "Number of people in hh counting members & nonmembers"
	sort hhcode
	compress
	tempfile `eqadults13'
	saveold "eqadults13.dta", replace

	use "$data2013\plist.dta", clear
	rename s1aq11 member
	keep hhcode idc age member
	drop if member==2
	drop member
	gen adult=0.8 if age<18
	recode adult .=1
	collapse (sum) eqadultM=adult (count) hhsizeM=idc, by(hhcode)
	label var eqadultM "Number of equivalent adults counting only members"
	label var hhsizeM "Number of people in hh counting only members"
			******************************************************
			* Since all household member chooses member=1,      **
			* there is no difference between hhsizeM and hhsize  *
			******************************************************
	sort hhcode
	compress
	merge 1:1 hhcode using "eqadults13.dta"
	drop _m
	sort hhcode
	save "$consump1314\eqadults13.dta", replace

use sec6_13, clear
	*total expenditure and quantity
	egen expend  =rsum(v1 v2 v3 v4)
	egen quantity=rsum(q1 q2 q3 q4)	

	*section A (2 week recall)
	drop if inlist(itc, 1000, 1001, 1002, 1003)
	* as a check I always drop the totals rows
	drop if inlist(itc, 1100, 1200, 1300, 1400, 1500, 1600, 1700, 1800, 1900)
	
	replace expend=expend*2.17 if itc>=1101 & itc<=1903		/*items with 2-week recall*/
		
	*section L-B (1 month recall)
	drop if inlist(itc, 2000, 2001, 2002)
	* as a check I always drop the totals rows
	drop if inlist(itc, 2100, 2200, 2300, 2400, 2500, 2600, 2700, 2800, 2900, 3000)

	*section L-C (1 month recall)
	drop if itc==4000
	* as a check I always drop the totals rows
	drop if inlist(itc, 4100, 4200, 4300, 4400)

	*section L-D (1 month recall)
	drop if inlist(itc, 5000, 5001, 5002)
	drop if inlist(itc, 5407, 5702, 5703, 5704, 5901, 5902)
	* as a check I always drop the totals rows
	drop if inlist(itc, 5100, 5200, 5300, 5400, 5500, 5600, 5700, 5800, 5900)
	
	drop if itc>=6000	/*dropping all durables*/

	replace expend=expend/12 if itc>=5100 & itc<=5904		/*items with 1-year recall*/
	
	*verifying that rent is not reported more than once
	gen byte flag1=(itc>=5401 & itc<=5404)
	sort hhcode flag1 itc
	quietly by hhcode flag1: gen dup = cond(_N==1,0,_n)
	tab dup if flag1==1
	
	drop if flag1==1 & dup==2
	drop flag1 dup

	
	*check that the same household (with different items) have the same PSU province weight and region
	local var psu province region weight
	foreach v of local var{
		bys hhcode: egen `v'_min = min(`v')
		bys hhcode: egen `v'_max = max(`v')
		assert `v'_min == `v'_max
		drop `v'_min `v'_max
	}
	
	preserve
	collapse (mean) province region psu weight (sum) expend, by (hhcode)
	sort psu
	rename expend nomexpend
	label var nomexpend "Nominal Total Monthly Household Expenditure per Month"
	save "$consump1314\cons_agg_1314", replace
	restore

*===========ESTIMATE FOOD EXPENDITURES============*	
preserve
	keep if itc<2700
	collapse (mean) province region psu weight (sum) expend, by (hhcode)
	sort psu
	rename expend foodexpend
	label var foodexpend "Nominal Total Monthly Food Expenditure per Month"
	merge 1:1 hhcode using "$consump1314\cons_agg_1314"
	* 1 hhs does not have food expenditure *
	keep if _m==3
	drop _m
	save "$consump1314\cons_agg_withfoodexp_1314", replace
restore
	
*===========ESTIMATE NON FOOD EXPENDITURES============*	
	drop if itc<2700
	collapse (mean) province region psu weight (sum) expend, by (hhcode)
	sort psu
	rename expend nonfoodexpend
	label var nonfoodexpend "Nominal Total Monthly Non-Food Expenditure per Month"
	merge 1:1 hhcode using "$consump1314\cons_agg_withfoodexp_1314"
	* 1 hhs does not have non-food expenditure *
	keep if _m==3
	drop _m
	save "$consump1314\cons_agg_withfoodandnonfoodexp_1314", replace
	
	
	
*===========================RUN THE PAASCHE_PSU FILE HERE=========================================*

*============================ NOW RUN THE REST OF THE CODE ====================================*	

	use "$consump1314\cons_agg_withfoodandnonfoodexp_1314", clear
	merge m:1 psu using "$consump1314\psu_paasche_1314.dta"
	drop _m
	merge 1:1 hhcode using "$consump1314\eqadults13.dta"
	* 1 hhs dropped-not in the foodexp file *
	keep if _m==3
	drop _m

	gen texpend=nomexpend/psupind
	label var texpend "Total monthly exp normalized by Passche index"
	gen tfoodexp=foodexpend/psupind
	label var tfoodexp "Total monthly Food exp normalized by Passche index"
	gen tnonfoodexp=nonfoodexpend/psupind
	label var tnonfoodexp "Total monthly Non-Food exp normalized by Passche index"

	
	gen foodshare=(tfoodexp/texpend)*100
	label var foodshare "Share of Food in total Consumption (Nominals)"
	gen nonfoodshare=(tnonfoodexp/texpend)*100
	label var nonfoodshare "Share of Non-Food in total Consumption (Nominals)"
	
	gen peaexpM=texpend/eqadultM

	label var peaexpM "Per equiv adult expend of hh adjusted by psuindex"

	gen popwt = weight*hhsizeM
	label var popwt "Population weight-hhsizeM*weight"
	
	* 1937.075 * (189.58/162.57)
	gen pline = 2258.908
	label var pline "Poverty Line-based on per adult equivalent"
	
	gen poor = 1 if peaexpM<pline
	replace poor=0 if peaexpM>pline
	label var poor "Poverty Head Count-based on per adult equivalent"
	
	gen pgap = pline-peaexpM
	replace pgap=0 if pgap<0
	label var pgap "Poverty Gap- pline minus per adult equivalent exp"

	gen year = 2013
	label var year "Survey Year"
	label var hhcode "Unique Household Identifier"

	tabstat poor [w=popwt], by(province)
	xtile quintile=peaexpM [pw=popwt], nq(5) 

	save "$consump1314\poverty_1314", replace
	
/*Summary for variables: poor
     by categories of: province ((mean) province)

province |      mean
---------+----------
       1 |  .0608242
       2 |  .0829673
       3 |  .1052682
       4 |  .2239367
---------+----------
   Total |  .0929627
--------------------
