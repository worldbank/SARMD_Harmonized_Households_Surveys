
*CALCULATES INDUSTRY WISE JOBS CREATED, LFPR, UNEMPLOYMENT RATES & WAGES ACROSS CATEGORIES*
*CALCULATES LFPR, WPR, IND STATS, SECTOR FOR ORISSA
clear
set mem 600m
set more off
global nsso "C:\Users\wb370975\Documents\NSS\NSS-66-Sch10"

************************************************************************
*CREATES PS &SS DATASET
************************************************************************
use "$nsso\Dta\final_datasets\nsso66eu4", clear
keep hhid indid  relhhead sex age marstat edugen edutech attnd typ_inst empl_exg  vocatnl field duration degree scheme
save "$nsso\Dta\constructed\emp_66.dta", replace

use "$nsso\Dta\final_datasets\nsso66eu5", clear
foreach var in wrk_lctn ent_typ ent_elec ent_wrk contract leave benefit pay_mthd {
	renpfix `var' prn_`var'
}
keep hhid indid  prn_sts prn_nic prn_nco sbs_yes  prn_wrk_lctn prn_ent_typ prn_ent_elec prn_ent_wrk prn_contract prn_leave prn_benefit prn_pay_mthd 
dmerge indid using "$nsso\Dta\constructed\emp_66.dta"
tab _m
drop _m
save "$nsso\Dta\constructed\emp_66.dta", replace

use "$nsso\Dta\final_datasets\nsso66eu6", clear
keep indid hhid  sbs_sts sbs_nic sbs_nco
dmerge indid using "$nsso\Dta\constructed\emp_66.dta"
tab _m
drop _m
save "$nsso\Dta\constructed\emp_66.dta", replace

use "$nsso\Dta\final_datasets\nsso66eu1", clear
keep  roundcentre round  subround subsample sector statereg state region district hhid hhwt
dmerge hhid using "$nsso\Dta\constructed\emp_66.dta"
tab _m
drop _m
*gen state=substr(statereg, 1,2)
save "$nsso\Dta\constructed\emp_66.dta", replace

use "$nsso\Dta\final_datasets\nsso66eu2", clear
keep  hhid hhsize hhtype religion sgroup landown landposs landcult
dmerge hhid using "$nsso\Dta\constructed\emp_66.dta"
tab _m
drop _m
order hhid indid state*
label var state "State"
destring ( statereg -subsample), replace

label define sector 1"rural" 2"urban"
label values sector sector

label define sgroup 1 "ST" 2 "SC" 3 "OBC" 9 "Other"
label values sgroup sgroup

label define religion 1 "Hinduism" 2 "Islam" 3 "Christianity" 4 "Sikhism" 5 "Jainism" 6 "Buddhism" 7 "Zoroastrianism" 9 "Other"
label values religion religion
gen pwt=hhwt*hhsize

label define state 1 "Jammu & Kashmir", modify
label define state 2 "Himachal Pradesh", modify
label define state 3 "Punjab", modify
label define state 4 "Chandigarh", modify
label define state 5 "Uttaranchal", modify
label define state 6 "Haryana", modify
label define state 7 "Delhi", modify
label define state 8 "Rajasthan", modify
label define state 9 "Uttar Pradesh", modify
label define state 10 "Bihar", modify
label define state 11 "Sikkim", modify
label define state 12 "Arunachal Pradesh", modify
label define state 13 "Nagaland", modify
label define state 14 "Manipur", modify
label define state 15 "Mizoram", modify
label define state 16 "Tripura", modify
label define state 17 "Meghalaya", modify
label define state 18 "Assam", modify
label define state 19 "West Bengal", modify
label define state 20 "Jharkhand", modify
label define state 21 "Orissa", modify
label define state 22 "Chattisgarh", modify
label define state 23 "Madhya Pradesh", modify
label define state 24 "Gujarat", modify
label define state 25 "Daman & Diu", modify
label define state 26 "D & N Haveli", modify
label define state 27 "Maharastra", modify
label define state 28 "Andhra Pradesh", modify
label define state 29 "Karnataka", modify
label define state 30 "Goa", modify
label define state 31 "Lakshadweep", modify
label define state 32 "Kerala", modify
label define state 33 "Tamil Nadu", modify
label define state 34 "Pondicherry", modify
label define state 35 "A & N Islands", modify
label values state state

destring( sbs_nco prn_nco), replace
label define sex 1 "male"  2 "female"
label values sex sex

save "$nsso\Dta\constructed\emp_66.dta", replace

stop

**************************************************************************
use "$nsso\Dta\constructed\emp_66.dta", clear

*USUAL STATUS & BROAD INDUSTRY CATEGORIES
*PS: PRINCIPAL STATUS SS: SUBSIDIARY STATUS US:USUAL STATUS

rename prn_sts sts_prn 
rename prn_nic nic_prn
rename prn_nco nco_prn
rename sbs_sts sts_sub 
rename sbs_nic nic_sub
rename sbs_nco nco_sub

gen sts_all=sts_prn
replace sts_all=sts_sub if sts_prn>51 & sts_sub<=51

gen prn_sts=sts_prn
recode prn_sts (11/21=1) (31=2) (41/51=3) (81=4) (else=5)
label var prn_sts "Broad principal status"

gen sub_sts=sts_sub
recode sub_sts (11/21=1) (31=2) (41/51=3)
label var sub_sts "Broad subsidiary status"

gen all_sts=sts_all
recode all_sts (11/21=1) (31=2) (41/51=3) (81=4) (else=5)
label var all_sts "Broad usual status"

label define status 1 "Self-employed" 2 "Regular" 3 "Casual" 4 "Unemployed" 5 "out-LF"
label values prn_sts status
label values sub_sts status
label values all_sts status

*LFPR &WPR
gen prn_lfp=.
replace prn_lfp=1 if prn_sts<=4
replace prn_lfp=0 if prn_sts>4
label var prn_lfp "LFPR: Principal status"
  
gen prn_wfp=.
replace prn_wfp=1 if prn_sts<=3
replace prn_wfp=0 if prn_sts>3
label var prn_wfp "WFP: Principal status"

gen all_lfp=.
replace all_lfp=1 if all_sts<=4
replace all_lfp=0 if all_sts>4
label var all_lfp "LFPR:Usual status"
 
gen all_wfp=.
replace all_wfp=1 if all_sts<=3
replace all_wfp=0 if all_sts>3
label var all_wfp "WFP:Usual status"

label define lfp 1 "in-LF" 0 "out-LF"
label define wfp 1 "in-WF" 0 "out-WF"
label values prn_lfp lfp
label values all_lfp lfp
label values prn_wfp wfp
label values all_wfp wfp

*INDUSTRY 
gen nic_all=nic_prn
replace nic_all=nic_sub if nic_prn==. & nic_sub!=.

gen nic_p2 = int(nic_prn/1000)
gen nic_s2 = int(nic_sub/1000)
gen nic_a2 = int(nic_all/1000)

recode nic_p2 (1/5=1) (10/14=2) (15/37=3) (40/41=4) (45=5) (50/55=6) (60/64=7) (65/74=8) (75/99=9)
recode nic_s2 (1/5=1) (10/14=2) (15/37=3) (40/41=4) (45=5) (50/55=6) (60/64=7) (65/74=8) (75/99=9)
recode nic_a2 (1/5=1) (10/14=2) (15/37=3) (40/41=4) (45=5) (50/55=6) (60/64=7) (65/74=8) (75/99=9)

rename nic_p2 prn_ind
label var prn_ind "Principal industry"
rename nic_s2 sub_ind
label var sub_ind "Subsidiary industry"
rename nic_a2 all_ind
label var all_ind "Usual status industry"
label define industry 1 "Agriculture, forestry,fishing " 2 "Mining & Quarrying" 3 "Manufacturing" 4 "Electricity,Water,etc." 5 "Construction" 6 "Trade,Hotel& Restaurants" 7 "Transport,Communication" 8 "Fin Serv,Real Estate,Other business" 9 "Pub Admn.,Edu,health,other services." 10 "N.D"
label values prn_ind industry
label values sub_ind industry
label values all_ind industry

*INDUSTRY TO SECTOR
gen	   prn_sector  = prn_ind
recode prn_sector  (1=1) (2/5=2) (6/9=3)
gen    sub_sector  = sub_ind
recode sub_sector  (1=1) (2/5=2) (6/9=3)
gen    all_sector  = all_ind
recode all_sector  (1=1) (2/5=2) (6/9=3)

label define ind 1 "Agriculture & allied" 2 "Industry" 3 "Services"
label values prn_sector ind
label values sub_sector ind
label values all_sector ind

*UNEMPLOYMENT RATE
gen all_ue=100 if all_sts==4
replace all_ue=0 if (all_sts==1| all_sts==2| all_sts==3)
label var all_ue "Unemployed:Usual Status"

gen prn_ue=100 if prn_sts==4
replace prn_ue=0 if (prn_sts==1| prn_sts==2| prn_sts==3)
label var prn_ue "Unemployed:Principal Status"

label define nssreg 211 "Coastal" 212 "Southern" 213 "Northern"
label values statereg nssreg


*****************************************************************************************************
*RESULTS FOR TABLES
*****************************************************************************************************
set logtype text
log using "$nsso\Log\emp_66.txt", replace

*CHECK WITH PUBLISHED RESULTS: MATCHES :)
tab  all_lfp [aw=hhwt] if age>=15 & age<=59
tab  all_lfp [aw=hhwt] if age>=15 & age<=59 & sex==1
tab  all_lfp [aw=hhwt] if age>=15 & age<=59 & sex==2

tab  all_lfp [aw=hhwt] if age>=15 & age<=59 & sex==1 & state==21
tab  all_lfp [aw=hhwt] if age>=15 & age<=59 & sex==2 & state==21
tab  all_lfp [aw=hhwt] if age>=15 & age<=59 & state==21

*INDIA TABLES
*LFPR, WPR (PS & US): INDIA
foreach var in all_wfp prn_wfp all_lfp prn_lfp {
	di "`var'"
	di "Rural"
	tab `var' sex [aw=hhwt] if sector==1, nof col
	di "`var'"
	di "Urban"
	tab `var' sex [aw=hhwt] if sector==2, nof col
	di "`var'"
	di "Rural+ urban"
	tab `var' sex[aw=hhwt] , nof col
	}

*STATUS OF EMPLOYMENT
foreach var in all prn {
	di "`var'"
	di "Rural"
	tab `var'_sts sex [aw=hhwt] if sector==1 & `var'_wfp==1 , nof col
	di "`var'"
	di "Urban"
	tab `var'_sts sex [aw=hhwt] if sector==2 & `var'_wfp==1, nof col
	di "`var'"
	di "Rural+ urban"
	tab `var'_sts sex[aw=hhwt] if `var'_wfp==1 , nof col
	}	

*INDUSTRY &SECTOR
foreach var in all prn {
	di "`var'"
	tab  `var'_ind sector [aw=hhwt] if `var'_wfp==1, nof col
	tab  `var'_sector [aw=hhwt] if `var'_wfp==1
	}

*UNEMPLOYMENT RATES
foreach var in all_ue prn_ue {
	di "`var'"
	table sex sector [aw=hhwt] , c(mean `var') row col
	}

*ORISSA TABLES
*LFPR, WPR (PS & US): ORISSA
foreach var in all_wfp prn_wfp all_lfp prn_lfp {
	di "`var'"
	di "Rural"
	tab `var' sex [aw=hhwt] if sector==1 & state==21, nof col
	di "`var'"
	di "Urban"
	tab `var' sex [aw=hhwt] if sector==2 & state==21, nof col
	di "`var'"
	di "Rural+ urban"
	tab `var' sex[aw=hhwt] if state==21 , nof col
	}

*STATUS OF EMPLOYMENT
foreach var in all prn {
	di "`var'"
	di "Rural"
	tab `var'_sts sex [aw=hhwt] if sector==1 & `var'_wfp==1 & state==21, nof col
	di "`var'"
	di "Urban"
	tab `var'_sts sex [aw=hhwt] if sector==2 & `var'_wfp==1 & state==21, nof col
	di "`var'"
	di "Rural+ urban"
	tab `var'_sts sex[aw=hhwt] if `var'_wfp==1 & state==21 , nof col
	}	

*INDUSTRY &SECTOR
foreach var in all prn {
	di "`var'"
	tab  `var'_ind sector [aw=hhwt] if `var'_wfp==1& state==21, nof col
	tab  `var'_sector [aw=hhwt] if `var'_wfp==1 & state==21
	}

*ORISSA: BY REGION
foreach var in all_wfp prn_wfp all_lfp prn_lfp {
	di "`var'"
	table statereg sector [aw=hhwt] if state==21, c(mean `var') row col
	}

*UNEMPLOYMENT: R,U & BY REGION
foreach var in all_ue prn_ue {
	di "`var'"
	table sex sector [aw=hhwt] if state==21, c(mean `var') row col
	di "`var'"
	table statereg sector [aw=hhwt] if state==21, c(mean `var') row col
	}
	
log close


tab all_sts all_ind  [aw=hhwt] if all_wfp==1
tab all_sts all_ind  [aw=hhwt] if all_wfp==1, nof col
tab all_ind all_sts  [aw=hhwt] if all_wfp==1
tab all_ind all_sts  [aw=hhwt] if all_wfp==1, nof col
tab all_ind all_sts if all_wfp==1
tab all_ind all_sts
tab prn_ind prn_sts
tab prn_ind prn_sts, nof col
tab sub_ind sub_sts, nof col
tab sub_ind sub_sts


set logtype text
log using "$nsso\Log\state_lf.txt",replace

***STATEWISE LFPR
di "RURAL"
table state sex  [aw=hhwt] if sector==1, c(mean all_lfp ) row col
di "URBAN"
table state sex  [aw=hhwt] if sector==2, c(mean all_lfp ) row col
di "RURAL+ URBAN"
table state sex  [aw=hhwt], c(mean all_lfp ) row col

**SECTOR 
di "RURAL+ URBAN"
table state [aw=hhwt] , c(mean all_wfp ) row col

di "RURAL+ URBAN"
tab state all_sector  [aw=hhwt] if all_wfp==1, row nofreq

**SELF-EMP, REG
di "RURAL"
tab state all_sts  [aw=hhwt] if all_wfp==1 & sector==1, row nofreq
di "URBAN"
tab state all_sts  [aw=hhwt] if all_wfp==1 & sector==2, row nofreq
di "RURAL+ URBAN"
tab state all_sts  [aw=hhwt] if all_wfp==1, row nofreq

log close

label define state 11 "Sikkim", modify
label define state 12 "Arunachal Pradesh", modify
label define state 13 "Nagaland", modify
label define state 14 "Manipur", modify
label define state 15 "Mizoram", modify
label define state 16 "Tripura", modify
label define state 17 "Meghalaya", modify
label define state 18 "Assam", modify

gen state_ne=state
recode state_ne (11 12 13 14 15 16 17 18= 40)
la define 40 "NE", add
la val state_ne state

**USUAL STATUS UNEMPLOYMENT RATES AMONG YOUTH (15-29 YEARS)
table state sex [aw=hhwt] if age>=15 & age<=29 , c(mean all_ue ) row col
table state_ne sex [aw=hhwt] if age>=15 & age<=29 , c(mean all_ue ) row col








