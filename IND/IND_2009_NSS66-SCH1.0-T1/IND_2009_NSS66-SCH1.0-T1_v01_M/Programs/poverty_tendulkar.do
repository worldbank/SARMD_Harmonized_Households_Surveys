
**COMPUTES POVERTY MEASURES (BASED ON TENDULKAR POVERTY LINE USING MIXED RECALL PERIODS) FOR 2009-10, 2004-05 &1993-94
**POVERTY GAP BASED ON REVISED TENDULKAR POVERTY LINES
**RURAL& URBAN POVERTY LINES: TENDULKAR LINES STATEWISE
**(FILE USED FOR INDIA POVERTY UPDATE AND INDIA CPS)
*May 21st 2012- Maria Jos

clear
set mem 600m
global nsso "C:\Users\wb370975\Documents\NSS\NSS-66-Sch1-Type1"
*global nsso "M:\PREM\Staff no longer with PREM\Pinaki\Pinaki-StataData-S-Drive\Maria\NSS\NSS-66-Sch1-Type1"

set logtype text
capture log close
*log using "C:\Users\wb370975\Documents\Poverty\Poverty-Inequality-Update2012-13\poverty_inequality.txt", replace 


***************************************************************************************************
**2009-10
****************************************************************************************************
use "$nsso\Dta\final_datasets\nsso66ce1typ1",clear
keep hhid state sample sector nssreg district stratum substratum
merge 1:1 hhid using "$nsso\Dta\final_datasets\nsso66ce2typ1"
keep hhid state sample sector nssreg district stratum substratum  hhtype religion sgroup hhsize  landown landowntyp nic5 nic3 hhwt pwt
merge 1:1 hhid using "$nsso\Dta\final_datasets\nsso66ce3typ1"
drop _m

label var mpce_mrp "MRP: Monthly ind consumption (0.00)"
label var mpce_urp "URP: Monthly ind consumption (0.00)"
label define sector 1 "rural" 2 "urban"
label values sector sector

label define sgroup 1 "ST" 2 "SC" 3 "OBC" 9 "Other"
label values sgroup sgroup

label define religion 1 "Hinduism" 2 "Islam" 3 "Christianity" 4 "Sikhism" 5 "Jainism" 6 "Buddhism" 7 "Zoroastrianism" 9 "Other"
label values religion religion

*NOTE MPCE_URP & MPCE_MRP HAVE TWO DECIMAL PLACES
ren mpce_mrp mpce_mrp_org
gen mpce_mrp= mpce_mrp_org/100
label var mpce_mrp "MRP: MPCE (per capita)"

ren mpce_urp mpce_urp_org
gen mpce_urp= mpce_urp_org/100
label var mpce_urp "URP: MPCE (per capita)"

**POVERTY-LINES
*RURAL
gen pline=.
replace pline=693.8 if state==28 &sector==1
replace pline=773.7 if state==12 &sector==1
replace pline=691.7 if state==18 &sector==1
replace pline=655.6 if state==10 &sector==1
replace pline=617.3 if state==22 &sector==1
replace pline=747.8 if state==7 &sector==1
replace pline=931 if state==30 &sector==1
replace pline=725.9 if state==24 &sector==1
replace pline=791.6 if state==6 &sector==1
replace pline=708 if state==2 &sector==1
replace pline=722.9 if state==1 &sector==1
replace pline=616.3 if state==20 &sector==1
replace pline=629.4 if state==29 &sector==1
replace pline=775.3 if state==32 &sector==1
replace pline=631.9 if state==23 &sector==1
replace pline=743.7 if state==27 &sector==1
replace pline=871 if state==14 &sector==1
replace pline=686.9 if state==17 &sector==1
replace pline=850 if state==15 &sector==1
replace pline=1016.8 if state==13 &sector==1
replace pline=567.1 if state==21 &sector==1
replace pline=641 if state==34 &sector==1
replace pline=830 if state==3 &sector==1
replace pline=755 if state==8 &sector==1
replace pline=728.9 if state==11 &sector==1
replace pline=639 if state==33 &sector==1
replace pline=663.4 if state==16 &sector==1
replace pline=663.7 if state==9 &sector==1
replace pline=719.5 if state==5 &sector==1
replace pline=643.2 if state==19 &sector==1

**UTS- POVERTY LINES OF NEIGHBOURING STATES
*A&N--PLINE OF TN
replace pline=639 if state==35 &sector==1
*CHD- URBAN PLINE OF PUNJAB
replace pline=960.8 if state==4 &sector==1
*D&N- PLINE OF MAHARASHTRA
replace pline=743.7 if state==26 &sector==1
*D&D-PLINE OF GOA
replace pline=931 if state==25 &sector==1
**LKSHWDEEP- PLINE OF KERALA
replace pline=775.3 if state==31 &sector==1

*URBAN
replace pline=926.4 if state==28 &sector==2
replace pline=925.2 if state==12 &sector==2
replace pline=871 if state==18 &sector==2
replace pline=775.3 if state==10 &sector==2
replace pline=806.7 if state==22 &sector==2
replace pline=1040.3 if state==7 &sector==2
replace pline=1025.4 if state==30 &sector==2
replace pline=951.4 if state==24 &sector==2
replace pline=975.4 if state==6 &sector==2
replace pline=888.3 if state==2 &sector==2
replace pline=845.4 if state==1 &sector==2
replace pline=831.2 if state==20 &sector==2
replace pline=908 if state==29 &sector==2
replace pline=830.7 if state==32 &sector==2
replace pline=771.7 if state==23 &sector==2
replace pline=961.1 if state==27 &sector==2
replace pline=955 if state==14 &sector==2
replace pline=989.8 if state==17 &sector==2
replace pline=939.3 if state==15 &sector==2
replace pline=1147.6 if state==13 &sector==2
replace pline=736 if state==21 &sector==2
replace pline=777.7 if state==34 &sector==2
replace pline=960.8 if state==3 &sector==2
replace pline=846 if state==8 &sector==2
replace pline=1035.2 if state==11 &sector==2
replace pline=800.8 if state==33 &sector==2
replace pline=782.7 if state==16 &sector==2
replace pline=799.9 if state==9 &sector==2
replace pline=898.6 if state==5 &sector==2
replace pline=830.6 if state==19 &sector==2

**UTS- POVERTY LINES OF NEIGHBOURING STATES
*A&N--PLINE OF TN
replace pline=800.8 if state==35 &sector==2
**CHD- URBAN PLINE OF PUNJAB
replace pline=960.8 if state==4 &sector==2
**D&N- PLINE OF MAHARASHTRA
replace pline=961.1 if state==26 &sector==2
**D&D-PLINE OF GOA
replace pline=1025.4 if state==25 &sector==2
*LKSHWDEEP- PLINE OF KERALA
replace pline=830.7 if state==31 &sector==2

la var pline "Tendulkar Poverty Line 2009-10"

drop if mpce_mrp==.
drop if mpce_mrp==0
gen poor = (mpce_mrp<= pline)
la define poor 1 "Poor" 0 "Not-poor", modify
la values poor poor
la var poor "Poor:Tendulkar poverty line"

gen pline_double=2*pline
la var pline_double "Double Tendulkar Poverty Line 2009-10"
gen poor_double = (mpce_mrp<= pline_double)
label values poor_double poor
la var poor_double "Poor:Double Tendulkar poverty line"

**REAL CONSUMPTION IN 2009-10 ALL INDIA RURAL RUPEES
gen pline_ind_09=.
replace pline_ind_09=672.8 if sector==1
replace pline_ind_09=859.6 if sector==2
la var pline_ind_09 "All-India-Tendulkar Poverty Line"

gen real_mpce09=.
**FOR RURAL AREAS CONVERT CONSUMTPION TO 2009-10 ALL INDIA RURAL RUPEES
replace real_mpce09= mpce_mrp*(pline_ind_09/pline) if sector==1
**FOR URBAN AREAS FIRST CONVERST CONSUMPTION TO 2009-10 ALL INDIA URBAN AND THEN TO 2009-10 ALL-INDIA RURAL RUPEES
replace real_mpce09= (mpce_mrp*(pline_ind_09/pline))*(672.8/859.6) if sector==2

la var real_mpce09 "Real-PC Monthly Cons-(in 2009-10 Rural Rs)"

xtile dec_mpce  = real_mpce09 [aw=pwt], nq(10)
la var dec_mpce "Real Consumption Deciles"
xtile dec_mpce2 = mpce_mrp [aw=pwt], nq(10)
la var dec_mpce2 "Nominal Consumption Deciles"

gen year=2009
drop level a1 a3 a13 a14 a15 a16 a17
save "$nsso\Dta\constructed\poverty66.dta", replace

**MEAN MPCE BY QUINTILE

/*
table  dec_mpce_rur  [aw=pwt] if sector==1, c(mean real_mpce09) row col
table  dec_mpce_urb  [aw=pwt] if sector==2, c(mean real_mpce09) row col

povdeco mpce_mrp [aw=pwt], varpl(pline)
povdeco mpce_mrp [aw=pwt] if sector==1,  varpl(pline)
povdeco mpce_mrp [aw=pwt] if sector==2,  varpl(pline)
table state sector [aw=pwt], c(mean poor) row col
table state sector [aw=pwt], c(mean poor_double) row col

ineqdeco real_mpce09 [aw=pwt], by(state)
di "RURAL"
ineqdeco real_mpce09 [aw=pwt] if sector==1, by(state)
di "URBAN"
ineqdeco real_mpce09 [aw=pwt] if sector==2, by(state)
*/

di "2009-10"
ineqdeco real_mpce09 [aw=pwt]
di "RURAL"
ineqdeco real_mpce09 [aw=pwt] if sector==1
di "URBAN"
ineqdeco real_mpce09 [aw=pwt] if sector==2

**NOMINAL AND REAL CONSUMPTION MEANS
sum mpce_mrp real_mpce09 [aw=pwt]

**BOTTTOM 40 PERCENTILE MEAN MPCE REAL
sum  real_mpce09 [aw=pwt] if inrange(dec_mpce,1,4)

**BOTTTOM 40 PERCENTILE MEAN MPCE NOMINAL
sum  mpce_mrp [aw=pwt] if inrange(dec_mpce2,1,4)

**REPLICATING SHAOHUA'S ESTIMATES
gen adj_mpce_urp=1.45* mpce_urp if sector==1
replace adj_mpce_urp=mpce_urp if sector==2
ineqdeco adj_mpce_urp [aw=pwt], by (sector)


**********************************************************************
*2004-05
**********************************************************************
clear
global nsso "C:\Users\wb370975\Documents\NSS\NSS-61-Sch1"
*global nsso "M:\PREM\Staff no longer with PREM\Pinaki\Pinaki-StataData-S-Drive\Maria\NSS\NSS-61-Sch1"

use "$nsso\Dta\final_datasets\nsso61ce1", clear
keep  hhid- hhserial nss nsc mlt hhwt state
**use the file for taking the weights across rounds  
save "$nsso\Dta\constructed\id_wt", replace

use "$nsso\Dta\final_datasets\nsso61ce2",clear
keep hhid hhsize hhtype religion sgroup 
merge 1:1 hhid using "$nsso\Dta\constructed\id_wt"
gen pwt=hhwt*hhsize
label var pwt "Population Weight"
order  hhid fsu hamlet sec_stratum hhserial round schedule sample sector state_reg district stratum sub_stratum sub_round sub_sample fod_subregion *
destring (fsu hamlet sec_stratum hhserial round schedule sample district stratum sub_stratum sub_round sub_sample fod_subregion), replace
drop _m
save "$nsso\Dta\constructed\id_wt", replace

use "$nsso\Dta\final_datasets\nsso61ce3",clear
keep hhid a16- mpce365
merge 1:1 hhid using "$nsso\Dta\constructed\id_wt"
replace mpce365=mpce365/hhsize
ren mpce365 mpce_mrp
label var mpce_mrp "MRP: MPCE (per capita)"
label define sector 1 "rural" 2 "urban"
label values sector sector

*STATE &SECTOR-WISE POVERTY LINES. 

gen pline=.
replace pline=433.43 if state==28 & sector==1
replace pline=547.14 if state==12 & sector==1
replace pline=478 if state==18 & sector==1
replace pline=433.43 if state==10 & sector==1
replace pline=398.92 if state==22 & sector==1
replace pline=541.39 if state==7 & sector==1
replace pline=608.76 if state==30 & sector==1
replace pline=501.58 if state==24 & sector==1
replace pline=529.42 if state==6 & sector==1
replace pline=520.4 if state==2 & sector==1
replace pline=522.3 if state==1 & sector==1
replace pline=404.79 if state==20 & sector==1
replace pline=417.84 if state==29 & sector==1
replace pline=537.31 if state==32 & sector==1
replace pline=408.41 if state==23 & sector==1
replace pline=484.89 if state==27 & sector==1
replace pline=578.11 if state==14 & sector==1
replace pline=503.32 if state==17 & sector==1
replace pline=639.27 if state==15 & sector==1
replace pline=687.3 if state==13 & sector==1
replace pline=407.78 if state==21 & sector==1
replace pline=385.45 if state==34 & sector==1
replace pline=543.51 if state==3 & sector==1
replace pline=478 if state==8 & sector==1
replace pline=531.5 if state==11 & sector==1
replace pline=441.69 if state==33 & sector==1
replace pline=450.49 if state==16 & sector==1
replace pline=435.14 if state==9 & sector==1
replace pline=486.24 if state==5 & sector==1
replace pline=445.38 if state==19 & sector==1

**UTS- POVERTY LINES OF NEIGHBOURING STATES
*A&N--PLINE OF TN
replace pline=441.69 if state==35 & sector==1
*CHD- URBAN PLINE OF PUNJAB
replace pline=642.51 if state==4 & sector==1
**D&N- PLINE OF MAHARASHTRA
replace pline=484.89 if state==26 & sector==1
**D&D-PLINE OF GOA
replace pline=608.76 if state==25 & sector==1
*LKSHWDEEP- PLINE OF KERALA
replace pline=537.31 if state==31 & sector==1


*URBAN
replace pline=563.16 if state==28 & sector==2
replace pline=618.45 if state==12 & sector==2
replace pline=600.03 if state==18 & sector==2
replace pline=526.18 if state==10 & sector==2
replace pline=513.7 if state==22 & sector==2
replace pline=642.47 if state==7 & sector==2
replace pline=671.15 if state==30 & sector==2
replace pline=659.18 if state==24 & sector==2
replace pline=626.41 if state==6 & sector==2
replace pline=605.74 if state==2 & sector==2
replace pline=602.89 if state==1 & sector==2
replace pline=531.35 if state==20 & sector==2
replace pline=588.06 if state==29 & sector==2
replace pline=584.7 if state==32 & sector==2
replace pline=532.26 if state==23 & sector==2
replace pline=631.85 if state==27 & sector==2
replace pline=641.13 if state==14 & sector==2
replace pline=745.73 if state==17 & sector==2
replace pline=699.75 if state==15 & sector==2
replace pline=782.93 if state==13 & sector==2
replace pline=497.31 if state==21 & sector==2
replace pline=506.17 if state==34 & sector==2
replace pline=642.51 if state==3 & sector==2
replace pline=568.15 if state==8 & sector==2
replace pline=741.68 if state==11 & sector==2
replace pline=559.77 if state==33 & sector==2
replace pline=555.79 if state==16 & sector==2
replace pline=532.12 if state==9 & sector==2
replace pline=602.39 if state==5 & sector==2
replace pline=572.51 if state==19 & sector==2

**UTS- POVERTY LINES OF NEIGHBOURING STATES
*A&N--PLINE OF TN
replace pline=559.77 if state==35 & sector==2
*CHD- URBAN PLINE OF PUNJAB
replace pline=642.51 if state==4 & sector==2
**D&N- PLINE OF MAHARASHTRA
replace pline=631.85 if state==26 & sector==2
**D&D-PLINE OF GOA
replace pline=671.15 if state==25 & sector==2
*LKSHWDEEP- PLINE OF KERALA
replace pline=584.7 if state==31 & sector==2

gen poor = (mpce_mrp<=pline)
label define poor 1 "Poor" 0 "Not-poor", modify
label values poor poor

gen pline_double=2*pline
gen poor_double = (mpce_mrp<= pline_double)
label values poor_double poor

**REAL CONSUMPTION IN 2009-10 ALL INDIA RURAL RUPEES
gen pline_ind_04=.
replace pline_ind_04=446.68 if sector==1
replace pline_ind_04=578.8 if sector==2

gen pline_ind_09=.
replace pline_ind_09=672.8 if sector==1
replace pline_ind_09=859.6 if sector==2

gen real_mpce04=.
**FOR RURAL AREAS CONVERT CONSUMTPION TO 2009-10 ALL INDIA RURAL RUPEES
replace real_mpce04= (mpce_mrp*(pline_ind_04/pline))*(672.8/446.68) if sector==1
**FOR URBAN AREAS FIRST CONVERT CONSUMPTION TO 20004-05 ALL INDIA URBAN; SECOND TO 2004-05 ALL-INDIA RURAL RUPEES; AND THIRD TO 2009-10 ALL INDIA RURAL RUPEES
replace real_mpce04= ((mpce_mrp*(pline_ind_04/pline))*(446.68/578.8))*(672.8/446.68) if sector==2
la var real_mpce04 "Real-PC Monthly Cons-(in 2009-10 Rural Rs)"

**TEMPORAL CORRECTION WITH RURAL CPI
gen real_mpce04_cpi=.
replace real_mpce04_cpi= (mpce_mrp*(pline_ind_04/pline))*(1.51) if sector==1
replace real_mpce04_cpi= ((mpce_mrp*(pline_ind_04/pline))*(446.68/578.8))*(1.51) if sector==2
la var real_mpce04_cpi "Real-PC Monthly Cons-(in 2009-10 Rural Rs with CPI-AL)"

order hhid - centre  state pline  mpce_mrp mpce hhwt pwt poor 

xtile dec_mpce = real_mpce04 [aw=pwt], nq(10)

xtile dec_mpce2 = mpce_mrp [aw=pwt], nq(10)
la var dec_mpce2 "Nominal Consumption Deciles"

gen year=2004

save "$nsso\Dta\constructed\poverty61.dta", replace

/*
table state sector [aw=pwt], c(mean poor) row col
table state sector [aw=pwt], c(mean poor_double) row col

ineqdeco real_mpce09 [aw=pwt], by(state)
di "RURAL"
ineqdeco real_mpce09 [aw=pwt] if sector==1, by(state)
di "URBAN"
ineqdeco real_mpce09 [aw=pwt] if sector==2, by(state)
*/

di "2004-05"
ineqdeco real_mpce04 [aw=pwt]
di "RURAL"
ineqdeco real_mpce04 [aw=pwt] if sector==1
di "URBAN"
ineqdeco real_mpce04 [aw=pwt] if sector==2

sum mpce_mrp real_mpce04 [aw=pwt]

*BOTTTOM 40 PERCENTILE--MEAN-REAL
sum  real_mpce04 [aw=pwt] if inrange(dec_mpce,1,4)

*BOTTTOM 40 PERCENTILE--MEAN-NOMINAL
sum  mpce_mrp [aw=pwt] if inrange(dec_mpce2,1,4)

clear
global nsso "C:\Users\wb370975\Documents\NSS\NSS-50-Sch1"
*global nsso "M:\PREM\Staff no longer with PREM\Pinaki\Pinaki-StataData-S-Drive\Maria\NSS\NSS-50-Sch1"

****************************************************************************************************
**1993-94
****************************************************************************************************

use "$nsso\Dta\hh-adjustmpce.dta", clear
label var mpce_mrp "MRP: Monthly hhold consumption (0.00)"

gen hhwt = mult/100
gen pwt = hhwt*hhsize
label var hhwt "Household Weight"
label var pwt "Population Weight"

*STATE AND REGION
*REDIFINING STATES BASED ON REGIONS TO INCLUDE THREE NEW STATES CREATED POST SURVEY IN 2001
*destring state region sector, replace

replace state=34 if state==5 & region==1
replace state=35 if state==13 & region==1
replace state=36 if state==25 & region==1 

label drop state

label define state 2 "Andhra Pradesh"  3 "Arunachal Pradesh" 4 "Assam" 5 "Bihar" 6 "Goa" 7 "Gujarat" 8 "Haryana" 9 "Himachal Pradesh" 10 "Jammu & Kashmir" 11 "Karnataka" 12 "Kerala" 13 "Madhya Pradesh" 14 "Maharashtra" 15 "manipur" 16 "Meghalaya" 17 "Mizoram" 18 "Nagaland" 19 "Orissa" 20 "Punjab" 21 "Rajasthan" 22 "Sikkim" 23 "Tamil Nadu" 24 "Tripura" 25 "Uttar Pradesh" 26 "West Bengal" 27 "A & N islands" 28 "Chandigarh" 29 "D & N Haveli" 30 "Daman & Diu" 31 "Delhi" 32 "Lakshadweep" 33 "Pondicherry" 34 "Jharkhand" 35 "Chattisgarh" 36 "Uttarakhand" 99 "Others"
label values state state

label define sector 1 "rural" 2 "urban"
label values sector sector

rename hhgrp sgroup
recode sgroup (9=3)
label define sgroup 0 "N.D" 1 "ST" 2 "SC" 3 "Others" 
label values sgroup sgroup
replace sgroup=. if sgroup==5
label var sgroup "Social Group"

gen pline=244.1 if state==2 & sector==1
replace pline=285.1 if state==3 & sector==1
replace pline=266.3 if state==4 & sector==1
replace pline=236.1 if state==5 & sector==1
replace pline=229.1 if state==35 & sector==1
replace pline=315.4 if state==31 & sector==1
replace pline=316.2 if state==6 & sector==1
replace pline=279.4 if state==7 & sector==1
replace pline=294.1 if state==8 & sector==1
replace pline=272.7 if state==9 & sector==1
replace pline=289.1 if state==10 & sector==1
replace pline=227.7 if state==34 & sector==1
replace pline=266.9 if state==11 & sector==1
replace pline=286.5 if state==12 & sector==1
replace pline=232.5 if state==13 & sector==1
replace pline=268.6 if state==14 & sector==1
replace pline=322.3 if state==15 & sector==1
replace pline=284.1 if state==16 & sector==1
replace pline=316.5 if state==17 & sector==1
replace pline=381.7 if state==18 & sector==1
replace pline=224.2 if state==19 & sector==1
replace pline=220.3 if state==33 & sector==1
replace pline=286.9 if state==20 & sector==1
replace pline=271.9 if state==21 & sector==1
replace pline=266.6 if state==22 & sector==1
replace pline=252.6 if state==23 & sector==1
replace pline=275.8 if state==24 & sector==1
replace pline=244.3 if state==25 & sector==1
replace pline=249.5 if state==36 & sector==1
replace pline=235.5 if state==26 & sector==1

*NEW STATES 
replace pline=229.1 if state==35 & sector==1
replace pline=227.7 if state==34 & sector==1
replace pline=249.5 if state==36 & sector==1

*&UTS-NEIGHBOURING STATE'S PLINES
*A&N--PLINE OF TN
replace pline=252.6 if state==27 & sector==1
*CHD- URBAN PLINE OF PUNJAB
replace pline=342.3 if state==28 & sector==1
**D&N- PLINE OF MAHARASHTRA
replace pline=268.6 if state==29 & sector==1
**D&D-PLINE OF GOA
replace pline=316.2 if state==30 & sector==1
*LKSHWDEEP- PLINE OF KERALA
replace pline=286.5 if state==32 & sector==1


replace pline=282 if state==2 & sector==2
replace pline=297.1 if state==3 & sector==2
replace pline=306.8 if state==4 & sector==2
replace pline=266.9 if state==5 & sector==2
replace pline=283.5 if state==35 & sector==2
replace pline=320.3 if state==31 & sector==2
replace pline=306 if state==6 & sector==2
replace pline=320.7 if state==7 & sector==2
replace pline=312.1 if state==8 & sector==2
replace pline=316 if state==9 & sector==2
replace pline=281.1 if state==10 & sector==2
replace pline=304.1 if state==34 & sector==2
replace pline=294.8 if state==11 & sector==2
replace pline=289.2 if state==12 & sector==2
replace pline=274.5 if state==13 & sector==2
replace pline=329 if state==14 & sector==2
replace pline=366.3 if state==15 & sector==2
replace pline=393.4 if state==16 & sector==2
replace pline=355.7 if state==17 & sector==2
replace pline=409.6 if state==18 & sector==2
replace pline=279.3 if state==19 & sector==2
replace pline=264.3 if state==33 & sector==2
replace pline=342.3 if state==20 & sector==2
replace pline=300.5 if state==21 & sector==2
replace pline=362.2 if state==22 & sector==2
replace pline=288.2 if state==23 & sector==2
replace pline=316.6 if state==24 & sector==2
replace pline=281.3 if state==25 & sector==2
replace pline=306.7 if state==36 & sector==2
replace pline=295.2 if state==26 & sector==2

*NEW STATES 
replace pline=283.5 if state==35 & sector==2
replace pline=304.1 if state==34 & sector==2
replace pline=306.7 if state==36 & sector==2

*&UTS-NEIGHBOURING STATE'S PLINES
*A&N--PLINE OF TN
replace pline=288.2 if state==27 & sector==2
*CHD- URBAN PLINE OF PUNJAB
replace pline=342.3 if state==28 & sector==2
**D&N- PLINE OF MAHARASHTRA
replace pline=329 if state==29 & sector==2
**D&D-PLINE OF GOA
replace pline=306 if state==30 & sector==2
*LKSHWDEEP- PLINE OF KERALA
replace pline=289.2 if state==32 & sector==2


label var pline "Tendulkar Poverty Line (93-94)"
gen poor = (mpce_mrp<= pline)
label define poor 1 "Poor" 0 "Not-poor"
label values poor poor

gen pline_double=2*pline
gen poor_double = (mpce_mrp<= pline_double)
label values poor_double poor

**REAL CONSUMPTION IN 2009-10 ALL INDIA RURAL RUPEES

**ALL INDIA POVERTY LINES FOR 1993-94 ESTIMATED AS CONSUMPTION CORRESPONDING TO 50TH AND 32ND PERCENTILE FOR RURAL AND URBAN AREAS RESPECIVELY.
/*
_pctile mpce_mrp if sector==1 [aw=pwt], p(50)
return list
scalars:
r(r1) =  250.4722230434418

_pctile mpce_mrp if sector==2 [aw=pwt], p(32)
return list
scalars:
r(r1) =  297.339989566803
*/

gen pline_ind_93=.
replace pline_ind_93=250.47 if sector==1
replace pline_ind_93=297.34 if sector==2

gen pline_ind_09=.
replace pline_ind_09=672.8 if sector==1
replace pline_ind_09=859.6 if sector==2

gen real_mpce93=.
**FOR RURAL AREAS CONVERT CONSUMPTION TO 2009-10 ALL INDIA RURAL RUPEES
replace real_mpce93= (mpce_mrp*(pline_ind_93/pline))*(672.8/250.47) if sector==1
**FOR URBAN AREAS FIRST CONVERT CONSUMPTION TO 1993-94 ALL INDIA URBAN; SECOND TO 1993-94 ALL-INDIA RURAL RUPEES; AND THIRD TO 2009-10 ALL INDIA RURAL RUPEES
replace real_mpce93= ((mpce_mrp*(pline_ind_93/pline))*(250.47/297.34))*(672.8/250.47) if sector==2
la var real_mpce93 "Real-PC Monthly Cons-(in 2009-10 Rural Rs)"

**TEMPORAL CORRECTION WITH RURAL CPI
gen real_mpce93_cpi=.
replace real_mpce93_cpi= (mpce_mrp*(pline_ind_93/pline))*(2.7) if sector==1
replace real_mpce93_cpi= ((mpce_mrp*(pline_ind_93/pline))*(250.47/297.34)*(2.7)) if sector==2
la var real_mpce93_cpi "Real-PC Monthly Cons-(in 2009-10 Rural Rs with CPI-AL)"

la var  idhhd "Household id"
la var state "State"
la var region "Region"
la var poor "Poor-Tendulkar Mthd"
la var mpce_mrp "MPCE: Mixed Recall(30-365)"
la var mpce_urp "MPCE:Uniform Recall(30)"

order idhhd  state region sector stratum subrnd fsu secondstage hhno svy_seq respondent_relation svy_code hhsize hhwt pwt sgroup headage headsex  mpce_mrp mpce_urp*

drop  oldpc exp5_30 mpcecd landposscd1  mult_subsam- exp10_365  mexp6_365 mexp7_365 mexp10_365 wt mexpedmed_365 respondent_relation  adult_m adult_f child_m child_f consumerunit entcd land_own- land_irr cropprod otherprod_enterprise house_area-  meals_tot

xtile dec_mpce = real_mpce93 [aw=pwt], nq(10)

xtile dec_mpce2 = mpce_mrp [aw=pwt], nq(10)
la var dec_mpce2 "Nominal Consumption Deciles"

gen year=1993

save "$nsso\Dta\constructed\poverty50.dta", replace

/*table state sector [aw=pwt], c(mean poor) row col
table state sector [aw=pwt], c(mean poor_double) row col
*svy: mean poor, over(rururb)

ineqdeco real_mpce09 [aw=pwt], by(state)
di "RURAL"
ineqdeco real_mpce09 [aw=pwt] if sector==1, by(state)
di "URBAN"
ineqdeco real_mpce09 [aw=pwt] if sector==2, by(state)
*/

di "1993-94"
ineqdeco real_mpce93 [aw=pwt]
di "RURAL"
ineqdeco real_mpce93 [aw=pwt] if sector==1
di "URBAN"
ineqdeco real_mpce93 [aw=pwt] if sector==2

sum mpce_mrp real_mpce93 [aw=pwt]

*BOTTTOM 40 PERCENTILE--MEAN-REAL
sum  real_mpce93 [aw=pwt] if inrange(dec_mpce,1,4)

*BOTTTOM 40 PERCENTILE--MEAN-NOMINAL
sum  mpce_mrp [aw=pwt] if inrange(dec_mpce2,1,4)

capture log close

************************************************************************************************************
global nsso "C:\Users\wb370975\Documents\NSS\NSS-50-Sch1"
use "$nsso\Dta\constructed\poverty50.dta", clear
ren idhhd hhid
capture destring(hhid), replace
ren pwt pwt93
keep hhid year real_mpce93 pwt93
tempfile mpce93
save `mpce93', replace

global nsso "C:\Users\wb370975\Documents\NSS\NSS-61-Sch1"
use "$nsso\Dta\constructed\poverty61.dta", clear
capture destring(hhid), replace
ren pwt pwt04
keep hhid year real_mpce04 pwt04
tempfile mpce04
save `mpce04', replace

global nsso "C:\Users\wb370975\Documents\NSS\NSS-66-Sch1-Type1"
use "$nsso\Dta\constructed\poverty66.dta", clear
capture destring(hhid), replace
ren pwt pwt09
keep hhid year real_mpce09 pwt09
tempfile mpce09
save `mpce09', replace

use `mpce93', clear
dmerge hhid year using `mpce04'
tab _m
drop _m
dmerge hhid year using `mpce09'
tab _m
drop _m

save "C:\Users\WB370975\Documents\Poverty\Poverty-Inequality-Update2012-13\cons_series.dta", replace

glcurve real_mpce09 [aw=pwt09], gl(g09) p(p09)
glcurve real_mpce04 [aw=pwt04], gl(g04) p(p04)
glcurve real_mpce93 [aw=pwt93], gl(g93) p(p93)

twoway (line g09 p09, sort lpattern(dash)) (line g04 p04, sort) (line g93 p93, sort), legend(position(12) ring(0)order(1 "2009-10" 2 "2004-05" 3 "1993-94"))  title("Generalized Lorenz Curve")

**EQUATION FOR A 45 DEGREE LINE  (function y=1000*x , range(0 1))

