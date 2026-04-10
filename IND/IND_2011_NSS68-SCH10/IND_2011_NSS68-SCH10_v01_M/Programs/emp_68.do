
*CALCULATES INDUSTRY WISE JOBS CREATED, LFPR, UNEMPLOYMENT RATES & WAGES ACROSS CATEGORIES*
clear
set mem 600m
set more off
global nsso "C:\Users\wb370975\Documents\NSS\NSS-68-Sch10"

************************************************************************
*CREATES PS &SS DATASET
************************************************************************
use "$nsso\Dta\final_datasets\nsso68eu3", clear
keep hhid indid  relhhead sex age marstat edugen edutech attnd typ_inst empl_exg  vocatnl field  
save "$nsso\Dta\constructed\emp_68.dta", replace

use "$nsso\Dta\final_datasets\nsso68eu4", clear
foreach var in wrk_lctn ent_typ ent_elec ent_wrk contract leave benefit pay_mthd {
	renpfix `var' prn_`var'
}
keep hhid indid  prn_sts prn_nic prn_nco sbs_yes  prn_wrk_lctn prn_ent_typ prn_ent_elec prn_ent_wrk prn_contract prn_leave prn_benefit prn_pay_mthd 
merge 1:1 indid using "$nsso\Dta\constructed\emp_68.dta"
tab _m
drop _m
save "$nsso\Dta\constructed\emp_68.dta", replace

use "$nsso\Dta\final_datasets\nsso68eu5", clear
keep indid hhid  sbs_sts sbs_nic sbs_nco
merge 1:1 indid using "$nsso\Dta\constructed\emp_68.dta"
tab _m
drop _m
save "$nsso\Dta\constructed\emp_68.dta", replace

use "$nsso\Dta\final_datasets\nsso68eu1", clear
keep  roundcentre round  subround subsample sector statereg state region district hhid hhwt
merge 1:m hhid using "$nsso\Dta\constructed\emp_68.dta"
tab _m
drop _m
*gen state=substr(statereg, 1,2)
save "$nsso\Dta\constructed\emp_68.dta", replace

use "$nsso\Dta\final_datasets\nsso68eu2", clear
keep  hhid hhsize hhtype religion sgroup landown landposs landcult
merge 1:m hhid using "$nsso\Dta\constructed\emp_68.dta"
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

save "$nsso\Dta\constructed\emp_68.dta", replace

use "$nsso\Dta\final_datasets\nsso68eu9", clear
keep if itemno==40
keep hhid cons30 
ren cons30 hhcons_mrp
merge 1:m hhid using "$nsso\Dta\constructed\emp_68.dta"
gen mpce_mrp= hhcons_mrp/ hhsize

*DEFINING QUINTILES

gen pline=.
replace pline=880 if sector==1 &state==35
replace pline=860 if sector==1 &state==28
replace pline=930 if sector==1 &state==12
replace pline=828 if sector==1 &state==18
replace pline=778 if sector==1 &state==10
replace pline=1155 if sector==1 &state==4
replace pline=738 if sector==1 &state==22
replace pline=967 if sector==1 &state==26
replace pline=1090 if sector==1 &state==25
replace pline=1145 if sector==1 &state==7
replace pline=1090 if sector==1 &state==30
replace pline=932 if sector==1 &state==24
replace pline=1015 if sector==1 &state==6
replace pline=913 if sector==1 &state==2
replace pline=891 if sector==1 &state==1
replace pline=748 if sector==1 &state==20
replace pline=902 if sector==1 &state==29
replace pline=1018 if sector==1 &state==32
replace pline=1018 if sector==1 &state==31
replace pline=771 if sector==1 &state==23
replace pline=967 if sector==1 &state==27
replace pline=1118 if sector==1 &state==14
replace pline=888 if sector==1 &state==17
replace pline=1066 if sector==1 &state==15
replace pline=1270 if sector==1 &state==13
replace pline=695 if sector==1 &state==21
replace pline=1301 if sector==1 &state==34
replace pline=1054 if sector==1 &state==3
replace pline=905 if sector==1 &state==8
replace pline=930 if sector==1 &state==11
replace pline=880 if sector==1 &state==33
replace pline=798 if sector==1 &state==16
replace pline=768 if sector==1 &state==9
replace pline=880 if sector==1 &state==5
replace pline=783 if sector==1 &state==19

replace pline=937 if sector==2 &state==35
replace pline=1009 if sector==2 &state==28
replace pline=1060 if sector==2 &state==12
replace pline=1008 if sector==2 &state==18
replace pline=923 if sector==2 &state==10
replace pline=1155 if sector==2 &state==4
replace pline=849 if sector==2 &state==22
replace pline=1126 if sector==2 &state==26
replace pline=1134 if sector==2 &state==25
replace pline=1134 if sector==2 &state==7
replace pline=1134 if sector==2 &state==30
replace pline=1152 if sector==2 &state==24
replace pline=1169 if sector==2 &state==6
replace pline=1064 if sector==2 &state==2
replace pline=988 if sector==2 &state==1
replace pline=974 if sector==2 &state==20
replace pline=1089 if sector==2 &state==29
replace pline=987 if sector==2 &state==32
replace pline=987 if sector==2 &state==31
replace pline=897 if sector==2 &state==23
replace pline=1126 if sector==2 &state==27
replace pline=1170 if sector==2 &state==14
replace pline=1154 if sector==2 &state==17
replace pline=1155 if sector==2 &state==15
replace pline=1302 if sector==2 &state==13
replace pline=861 if sector==2 &state==21
replace pline=1309 if sector==2 &state==34
replace pline=1155 if sector==2 &state==3
replace pline=1002 if sector==2 &state==8
replace pline=1226 if sector==2 &state==11
replace pline=937 if sector==2 &state==33
replace pline=920 if sector==2 &state==16
replace pline=941 if sector==2 &state==9
replace pline=1082 if sector==2 &state==5
replace pline=981 if sector==2 &state==19

gen pline_ind_11=.
replace pline_ind_11=816  if sector==1
replace pline_ind_11=1000 if sector==2
la var  pline_ind_11 "All-India-Tendulkar Poverty Line"

gen real_mpce11=.
**FOR RURAL AREAS CONVERT CONSUMTPION TO 2011-12 ALL INDIA RURAL RUPEES
replace real_mpce11= mpce_mrp*(pline_ind_11/pline) if sector==1
**FOR URBAN AREAS FIRST CONVERST CONSUMPTION TO 2011-12 ALL INDIA URBAN AND THEN TO 2011-12 ALL-INDIA RURAL RUPEES
replace real_mpce11= (mpce_mrp*(pline_ind_11/pline))*(816/1000) if sector==2

la var real_mpce11 "Real-PC Monthly Cons-(in 2011-12 Rural Rs)"

save "$nsso\Dta\constructed\emp_68.dta", replace

stop

**************************************************************************
use "$nsso\Dta\constructed\emp_68.dta", clear

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

recode nic_p2 (1/3=1) (5/9=2) (10/33=3) (35/39=4) (41/44=5) (45/48=6) (49/63=7) (64/82=8) (84/99=9)
recode nic_s2 (1/3=1) (5/9=2) (10/33=3) (35/39=4) (41/44=5) (45/48=6) (49/63=7) (64/82=8) (84/99=9)
recode nic_a2 (1/3=1) (5/9=2) (10/33=3) (35/39=4) (41/44=5) (45/48=6) (49/63=7) (64/82=8) (84/99=9)

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