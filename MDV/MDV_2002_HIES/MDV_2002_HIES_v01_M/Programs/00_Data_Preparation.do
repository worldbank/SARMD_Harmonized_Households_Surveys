set more off

global dir "C:\Users\wb436991\Box Sync\WB\SAR_Maldives"
global out "${dir}\Data\Data_modified\"
global table "${dir}\Tables\"

*===============================================================================
* Data Preparation
*===============================================================================

local years "2003 2009"
	
	foreach yr of local years{
	use "${out}/wf`yr'.dta", clear
	
	gen overall=1
	
* Gender
*-------------------------------------------------------------------------------
	gen female = (sex==0)
	gen male   = (sex==1)
	
* Age
*-------------------------------------------------------------------------------
	gen age_014		= age<15
	gen age_1524	= (age>=15 & age<25)
	gen age_2565	= (age>=25 & age<65)
	gen age_6500	= age>=65

	gen 	age_group =1 if (age_014 ==1)
	replace age_group =2 if (age_1524==1)
	replace age_group =3 if (age_2565==1)
	replace age_group =4 if (age_6500==1)

	label define age_group 1"0-14" 2"15-24" 3"25-65" 4"65+"
	label values age_group age_group	


* Number of children (age<15)
*-------------------------------------------------------------------------------
	gen temp = (age<15)
	bysort hhid: egen n_child = sum(temp)
	drop temp
	gen n_child_short = n_child
	replace n_child_short =6 if n_child>6

	gen n_child_cap = n_child
	replace n_child_cap = 4 if n_child>4

* Marital status	
*-------------------------------------------------------------------------------
if `yr'==2009{
	tab marital, 	gen(marstat_)
}

* Geographic Location
*-------------------------------------------------------------------------------
if `yr'==2003{
	rename region6 region_old	
	gen region6 = .
	replace region6=0 if region_old==0  /*Male*/
	replace region6=1 if region_old==1 
	replace region6=2 if region_old==2 
	replace region6=3 if region_old==3
	replace region6=4 if region_old==4
	replace region6=5 if region_old==5
	
	# delimit;
	la def region6
	0 "Male (capital)"
	1 "North"
	2 "Central North"
	3 "Central"
	4 "Central South"
	5 "South", modify;
	label val region6 region6;
	# delimit cr
	
	drop region_old
}

else {
	* generate a 6-region variable consistent with regions in 2003
	gen  region6 = .
	replace region6=0 if region==8  /*Male*/
	replace region6=1 if region==1 
	replace region6=2 if region==2 
	replace region6=3 if region==3 & (atoll!=3201 & atoll!=3205 & atoll!=3604)
	replace region6=4 if (region==4 |region==5) | (atoll==3201 | atoll==3205 | atoll==3604)
	replace region6=5 if (region==6| region==7)
	
	# delimit;
	la def region6
	0 "Male (capital)"
	1 "North"
	2 "Central North"
	3 "Central"
	4 "Central South"
	5 "South", modify;
	label val region6 region6;
	# delimit cr
}
	tab region6, 	gen(reg_)
	gen geo_male 	= (reg2==1)
	gen geo_atoll 	= (reg2==2)
	gen geo_overall = 1
	

* Industry	
*-------------------------------------------------------------------------------
	replace ind_code = 13 if ind_code==.
	label define ind_code 13"Not employed", modify
	
	if `yr'==2003{
	gen 	industry_short = 1 if ind_code==1
	replace industry_short = 2 if ind_code==2 | ind_code==3
	replace industry_short = 3 if ind_code==4 | ind_code==5 |ind_code==6 |ind_code==7 | ind_code==8 | ind_code==11
	replace industry_short = 4 if ind_code==9 | ind_code==10
	replace industry_short = 5 if ind_code==.
	gen ind_code_short = ind_code
	recode ind_code_short (3=2)(4=7)(5=3)(6=7)(7=4)(8=7)(10=5)(9=7)(11=6)(12=7)   
	label define ind_code_short 1"Fisheries and Agriculture" 2"Manufacturing" 3"Construction" 4"Hotel/restaurant" 5"Public Administration" 6"Education and Health" 7"Other Services"
	label values ind_code_short ind_code_short
	}
	
	else{
	gen 	industry_short = 1 if ind_code==1
	replace industry_short = 2 if ind_code==2 | ind_code==3
	replace industry_short = 3 if ind_code==4 | ind_code==5 |ind_code==6 | ind_code==7 | ind_code==8 | ind_code==9 | ind_code==12
	replace industry_short = 4 if ind_code==10 | ind_code==11
	replace industry_short = 5 if ind_code==.
	gen ind_code_short = ind_code
	recode ind_code_short (3=2)(4=7)(5=3)(6=7)(7=4)(8=7)(10=5)(9=7)(11=6)(12=7)   
	label define ind_code_short 1"Fisheries and Agriculture" 2"Manufacturing" 3"Construction" 4"Hotel/restaurant" 5"Public Administration" 6"Education and Health" 7"Other Services"
	label values ind_code_short ind_code_short
	}
	
	label define industry_short 1"Agriculture" 2"Manufacturing" 3"Services" 4"PA, Education and Health" 5"OLF"
	label values industry_short industry_short
	tab ind_code, 	gen(ind_)

* Labor Force Status
*-------------------------------------------------------------------------------
if `yr'==2003{
	gen lfstat_olf =(employidentify==3)
	gen lfstat_emp = (employidentify==1)
	gen lfstat_unemp = (employidentify==2)
	mvencode lfstat*, mv(0) overr

	gen lfstat = 1 if lfstat_emp==1
	replace lfstat = 2 if lfstat_unemp ==1
	replace lfstat = 3 if lfstat_olf ==1

	label define lfstat 1"Employed" 2"Unemployed" 3"OLF"
	label values lfstat lfstat
}

else{
	gen lfstat_olf =(active==0)
	gen lfstat_emp = employed
	gen lfstat_unemp = unemployed
	mvencode lfstat*, mv(0) overr

	gen lfstat = 1 if lfstat_emp==1
	replace lfstat = 2 if lfstat_unemp ==1
	replace lfstat = 3 if lfstat_olf ==1

	label define lfstat 1"Employed" 2"Unemployed" 3"OLF"
	label values lfstat lfstat
}

* Dependency Ratio
*-------------------------------------------------------------------------------
gen wa_pop = (age>=15 & age<=65)
gen emp 	= wa_pop==1 & lfstat_emp==1
gen nemp 	= wa_pop==1 & lfstat_emp==0

bysort hhid: egen n_emp 	= sum(emp) 
bysort hhid: egen n_nemp 	= sum(nemp) 

gen dep_ratio = n_nemp / n_emp


* Education
*-------------------------------------------------------------------------------
if `yr' ==2009{
	clonevar edu_lev = edu
	recode edu_lev (2=1) (3=1) (4=2) (5=3) (7=4) (6=5) (8=5)
	label define edu_lev 1"None or incomplete primary" 2"Primary" 3"Lower Secondary" 4"Vocational" 5"Higher Secondary and Tertiary"
	label values edu_lev edu_lev

	gen edu_0_none_inc 		= (edu_lev ==1)
	gen edu_1_prim			= (edu_lev ==2)
	gen edu_2_sec			= (edu_lev ==3)
	gen edu_3_voc			= (edu_lev ==4)
	gen edu_4_higher 		= (edu_lev ==5)
}

* Poverty Lines
*-------------------------------------------------------------------------------
	gen z_nat = 787.4419
	gen z_125 = 17*365/12
	gen z_200 = 27*365/12
	gen z_250 = 34*365/12
	gen z_400 = 54*365/12
	

	label var z_nat "National poverty line"
	label var z_125 "1.25 US$ PPP a day"
	label var z_200 "2.00 US$ PPP a day"
	label var z_250 "2.50 US$ PPP a day"
	label var z_400 "4.00 US$ PPP a day"

* Incomes
*-------------------------------------------------------------------------------
	if `yr'==2003{
	gen y_2003 = pcerr_2009
	label var y_2003 "Per capita Consumption Aggregate, 2010 prices"
	}
	
	else{
	gen y_2009 = pcerr
	label var y_2009 "Per capita Consumption Aggregate, 2010 prices"

	egen inc_wage = rowtotal(inc_wag1 inc_wag2)
	egen inc_tot_i = rowtotal(inc_pens inc_fami inc_fama inc_other inc_wage inc_bus inc_prop inc_gov)

	local income "inc_pens inc_fami inc_fama inc_other inc_wage inc_bus inc_prop inc_gov"
	foreach i of local income{
	rename `i'  `i'_i
	bysort hhid: egen `i'_hh = sum(`i')
	gen `i'_pc =`i'_hh / hhsize_off
	gen `i'_tag = (`i'_hh!=0)
	}

	bysort hhid: egen inc_tot_hh = sum(inc_tot_i)

	egen inc_max_hh = rowmax(inc_pens_hh inc_fami_hh inc_fama_hh inc_other_hh inc_wage_hh inc_bus_hh inc_prop_hh inc_gov_hh)

	gen 	inc_max_hh_label = 1 if inc_max_hh==inc_wage_hh
	replace inc_max_hh_label = 2 if inc_max_hh==inc_bus_hh 
	replace inc_max_hh_label = 3 if inc_max_hh==inc_fami_hh
	replace inc_max_hh_label = 4 if inc_max_hh==inc_fama_hh
	replace inc_max_hh_label = 5 if inc_max_hh==inc_gov_hh
	replace inc_max_hh_label = 6 if inc_max_hh==inc_pens_hh
	replace inc_max_hh_label = 7 if inc_max_hh==inc_prop_hh
	replace inc_max_hh_label = 8 if inc_max_hh==inc_other_hh

	label define income_max_hh 1"Wages" 2"Self-Employment" 3"Private Transfers" 4"Remittances" 5"Public Transfers" 6"Pensions" 7"Properties" 8"Other"
	label values inc_max_hh_label income_max_hh
	
	local income "inc_wage inc_bus inc_fami inc_fama inc_gov inc_pens inc_prop inc_other"
	foreach i of local income{
	gen sh_`i' = `i'_hh / inc_tot_hh
	}

	egen inc_short_labor_hh  = rowtotal(inc_wage_hh inc_bus_hh )
	egen inc_short_tran_priv_hh  = rowtotal(inc_fami_hh  inc_fama_hh )
	egen inc_short_tran_gov_hh  = rowtotal(inc_gov_hh  inc_pens_hh )
	gen inc_short_prop_hh  = inc_prop_hh 
	gen inc_short_other_hh  = inc_other_hh 
	
	local income_short "inc_short_labor_hh inc_short_tran_priv_hh inc_short_tran_gov_hh inc_short_prop_hh inc_short_other_hh"
	foreach i of local income_short{
	gen sh_`i' = `i' / inc_tot_hh	
	}
	}

* Poor
*-------------------------------------------------------------------------------
	local pline "nat 125 200 250 400"
	foreach z of local pline{
	gen poor_`z' = y_`yr' <z_`z'
	cap drop decile 
	cap drop b40
	cap drop t60
	xtile decile= y_`yr' [aw=wght_hh], nq(10)
	gen b40 = (decile==1 | decile==2 |decile==3 | decile==4)
	gen t60 = (b40==0)
	}	
	tab decile, gen(d_)


* Svyset
*-------------------------------------------------------------------------------
if `yr'==2003{	
	drop if y_2003 ==.
	svyset  [w=wght_hh], strata(region)	
	save "${out}/profile_2003.dta", replace
	}

else{
	rename y_2009 y_2010
	drop if y_2010 ==.
	svyset atoll [w=wght_hh], strata(region)
	save "${out}/profile_2010.dta", replace
	}
}

