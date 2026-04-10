
*CALCULATES INDUSTRY WISE JOBS CREATED, LFPR, UNEMPLOYMENT RATES & WAGES ACROSS CATEGORIES*
*CALCULATES LFPR, WPR, IND STATS, SECTOR FOR ORISSA
*USES A CONSTRUCTED DTA FILE CREATED EARLIER (CHECK THE PROGRAMS se_nss61.do & var_nss61_ps.do IN DO & PINAKI'S S- DRIVE"
clear
set mem 600m
global nsso "C:\Users\wb370975\Documents\NSS\NSS-50-Sch10"

****************************************************************************************************************
use "$nsso\Dta\constructed\se_nss50.dta", clear
label var state "State"
label var sector "Sector"
label var prn_sts "Broad principal status"
label var sub_sts "Broad subsidiary status"
label var all_sts "Broad usual status"
label var prn_lfp "LFPR: Principal status"
label var prn_wfp "WFP: Principal status"
label var all_lfp "LFPR:Usual status"
label var all_wfp "WFP:Usual status"
label var prn_ind "Principal industry"
label var sub_ind "Subsidiary industry"
label var all_ind "Usual status industry"

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
ren hh_wt hhwt

foreach var in prn_lfp all_lfp prn_wfp all_wfp {
	recode `var' (2=0)
	}

label define lfp 1 "in-LF" 0 "out-LF", modify
label define wfp 1 "in-WF" 0 "out-WF", modify
label values prn_lfp lfp
label values all_lfp lfp
label values prn_wfp wfp
label values all_wfp wfp
label var prn_sector "Principal sector"
label var sub_sector "Subsidiary sector"
label var all_sector "Usual status sector"
recode sex (1=2) (0=1)
recode sector (1=2) (0=1)
label define sex 1 "male"  2 "female", modify
label define sector 1"rural" 2"urban", modify
label values sex sex
label values sector sector

label define nssreg 1 "Coastal" 2 "Southern" 3 "Northern"
label values region nssreg

*UNEMPLOYMENT RATE
gen all_ue=100 if all_sts==4
replace all_ue=0 if (all_sts==1| all_sts==2| all_sts==3)
label var all_ue "Unemployed:Usual Status"

gen prn_ue=100 if prn_sts==4
replace prn_ue=0 if (prn_sts==1| prn_sts==2| prn_sts==3)
label var prn_ue "Unemployed:Principal Status"

label define nssreg 1 "Coastal" 2 "Southern" 3 "Northern"
label values region nssreg

set logtype text
log using "$nsso\Log\emp_50.txt", replace

*CHECK WITH PUBLISHED RESULTS: MATCHES
tab  all_lfp [aw=hhwt] if sex==1 & sector==1
tab  all_lfp [aw=hhwt] if sex==1 & sector==2
tab  all_lfp [aw=hhwt] if sex==2 &sector==1

*NOTE STATE CODES FROM EARLIER ROUND USED: ORISSA:19
tab  all_lfp [aw=hhwt] if sex==1 & sector==1 & state==19
tab  all_lfp [aw=hhwt] if sex==2 & sector==1 &state==19

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
	tab `var' sex [aw=hhwt] if sector==1 & state==19, nof col
	di "`var'"
	di "Urban"
	tab `var' sex [aw=hhwt] if sector==2 & state==19, nof col
	di "`var'"
	di "Rural+ urban"
	tab `var' sex[aw=hhwt] if state==19 , nof col
	}

*STATUS OF EMPLOYMENT
foreach var in all prn {
	di "`var'"
	di "Rural"
	tab `var'_sts sex [aw=hhwt] if sector==1 & `var'_wfp==1 & state==19, nof col
	di "`var'"
	di "Urban"
	tab `var'_sts sex [aw=hhwt] if sector==2 & `var'_wfp==1 & state==19, nof col
	di "`var'"
	di "Rural+ urban"
	tab `var'_sts sex[aw=hhwt] if `var'_wfp==1 & state==19 , nof col
	}	

*INDUSTRY &SECTOR
foreach var in all prn {
	di "`var'"
	tab  `var'_ind sector [aw=hhwt] if `var'_wfp==1& state==19, nof col
	tab  `var'_sector [aw=hhwt] if `var'_wfp==1 & state==19
	}

*ORISSA: BY REGION
foreach var in all_wfp prn_wfp all_lfp prn_lfp {
	di "`var'"
	table region sector [aw=hhwt] if state==19, c(mean `var') row col
	}

*UNEMPLOYMENT: R,U & BY REGION
foreach var in all_ue prn_ue {
	di "`var'"
	table sex sector [aw=hhwt] if state==19, c(mean `var') row col
	di "`var'"
	table region sector [aw=hhwt] if state==19, c(mean `var') row col
	}
log close

***STATEWISE LFPR
di "RURAL"
table state sex  [aw=hhwt] if sector==1, c(mean all_lfp ) row col
di "URBAN"
table state sex  [aw=hhwt] if sector==2, c(mean all_lfp ) row col
di "RURAL+ URBAN"
table state sex  [aw=hhwt], c(mean all_lfp ) row col

**SELF-EMP, REG
di "RURAL"
tab state all_sts  [aw=hhwt] if all_wfp==1 & sector==1, row nofreq
di "URBAN"
tab state all_sts  [aw=hhwt] if all_wfp==1 & sector==2, row nofreq
di "RURAL+ URBAN"
tab state all_sts  [aw=hhwt] if all_wfp==1, row nofreq
