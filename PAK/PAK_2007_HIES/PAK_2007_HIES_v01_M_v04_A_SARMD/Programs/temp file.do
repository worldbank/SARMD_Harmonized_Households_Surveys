
use "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\PAK_2013_PSLM_v01_M_v04_A_SARMD_IND.dta", clear

bys idh: keep if _n==1

mean poor_nat [pw=pop_wgt]
gen nomexpend = welfare*hsize
gen welfare_eqa = nomexpend/eqadult

mean poor_int* [pw=pop_wgt]

drop pline_int poor_int
** POVERTY LINE (POVCALNET)
	gen pline_int=1.90*cpi*ppp*365/12
	label variable pline_int "Poverty Line"
	
	gen pline_int1=3.20*cpi*ppp*365/12
	label variable pline_int1 "Poverty Line at 3.20"

	gen pline_int2=5.50*cpi*ppp*365/12
	label variable pline_int2 "Poverty Line at 5.50"

	gen poor_int=welfare<pline_int & welfare!=.
	gen poor_int1=welfare<pline_int1 & welfare!=.
	gen poor_int2=welfare<pline_int2 & welfare!=.

	
** HEADCOUNT RATIO welfare aggregate based on spatially deflated per capita aggregate **
	gen poor_int_def=welfaredef<pline_int & welfaredef!=.
	gen poor_int1_def=welfaredef<pline_int1 & welfaredef!=.
	gen poor_int2_def=welfaredef<pline_int2 & welfaredef!=.
	
** HEADCOUNT RATIO welfare aggregate based on adult equivalent-not spetially deflated**
	gen poor_int_eqa=welfare_eqa<pline_int & welfare_eqa!=.
	gen poor_int1_eqa=welfare_eqa<pline_int1 & welfare_eqa!=.
	gen poor_int2_eqa=welfare_eqa<pline_int2 & welfare_eqa!=.

** HEADCOUNT RATIO welfare aggregate based on adult equivalent-AND spetially deflated**
	gen welfare_eqa_spd = (welfaredef*hsize)/eqadult
	sum welfare_eqa_spd welfarenat [aw=pop_wgt], d

	gen poor_int_eqa_spd=welfare_eqa_spd<pline_int & welfare_eqa_spd!=.
	gen poor_int1_eqa_spd=welfare_eqa_spd<pline_int1 & welfare_eqa_spd!=.
	gen poor_int2_eqa_spd=welfare_eqa_spd<pline_int2 & welfare_eqa_spd!=.

	mean poor_int* [pw=pop_wgt]

	ineqdeco welfare [w=pop_wgt]
	ineqdeco welfaredef [w=pop_wgt]
	ineqdeco welfare_eqa [w=pop_wgt]
	ineqdeco welfare_eqa_spd [w=pop_wgt]
