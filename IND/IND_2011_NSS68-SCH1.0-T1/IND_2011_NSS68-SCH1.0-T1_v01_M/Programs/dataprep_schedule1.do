**COMPUTES POVERTY MEASURES (BASED ON TENDULKAR POVERTY LINE USING MIXED RECALL PERIODS) FOR 2011-12, 2009-10, 2004-05, 1993-94
**POVERTY GAP BASED ON REVISED TENDULKAR POVERTY LINES
**RURAL AND URBAN POVERTY LINES: TENDULKAR LINES STATEWISE
**(FILE USED FOR INDIA POVERTY UPDATE AND INDIA CPS)


***THE DATA FILES WERE CONSTRUCTED USING THE DO-FILE poverty_tendulkar.do 

clear
set mem 600m

set logtype text
capture log close
*log using "C:\Users\wb370975\Documents\Poverty\Poverty-Inequality-Update2012-13\poverty_inequality.txt", replace 

***************************************************************************************************
**2011-12
****************************************************************************************************

*global nsso "C:\Users\wb370975\Documents\NSS\NSS-68-Sch1-Type1"
global nsso "C:\Users\wb381047.WB\Dropbox\WB_Monica\SASEP\India\NSS\NSS-68-Sch1-Type1"

/**/

use "$nsso\Dta\final_datasets\nsso68ce1typ1.dta", clear
drop a18- a32
merge 1:1 hhid using "$nsso\Dta\final_datasets\nsso68ce2typ1.dta", keepusing(hhsize hhwt pwt religion sgroup landown landtot_ha nic5 nco3 hhtype)
drop _m
merge 1:1 hhid using "$nsso\Dta\final_datasets\nsso68ce3typ1.dta", keepusing (mpce_urp mpce_mrp cookmode lightmode dwellingcode salaryincome ceremony rationcard rationcard_type)
drop _m

*NOTE MPCE_URP & MPCE_MRP HAVE TWO DECIMAL PLACES
ren mpce_mrp mpce_mrp_org
gen mpce_mrp= mpce_mrp_org/100
label var mpce_mrp "MRP: MPCE (per capita)"

ren mpce_urp mpce_urp_org
gen mpce_urp= mpce_urp_org/100
label var mpce_urp "URP: MPCE (per capita)"

label define sector 1 "rural" 2 "urban"
label values sector sector

label define sgroup 1 "ST" 2 "SC" 3 "OBC" 9 "Other"
label values sgroup sgroup

label define religion 1 "Hinduism" 2 "Islam" 3 "Christianity" 4 "Sikhism" 5 "Jainism" 6 "Buddhism" 7 "Zoroastrianism" 9 "Other"
label values religion religion

gen pline=.
replace pline=880  if sector==1 & state==35
replace pline=860  if sector==1 & state==28
replace pline=930  if sector==1 & state==12
replace pline=828  if sector==1 & state==18
replace pline=778  if sector==1 & state==10
replace pline=1155 if sector==1 & state==4
replace pline=738  if sector==1 & state==22
replace pline=967  if sector==1 & state==26
replace pline=1090 if sector==1 & state==25
replace pline=1145 if sector==1 & state==7
replace pline=1090 if sector==1 & state==30
replace pline=932  if sector==1 & state==24
replace pline=1015 if sector==1 & state==6
replace pline=913  if sector==1 & state==2
replace pline=891  if sector==1 & state==1
replace pline=748  if sector==1 & state==20
replace pline=902  if sector==1 & state==29
replace pline=1018 if sector==1 & state==32
replace pline=1018 if sector==1 & state==31
replace pline=771  if sector==1 & state==23
replace pline=967  if sector==1 & state==27
replace pline=1118 if sector==1 & state==14
replace pline=888  if sector==1 & state==17
replace pline=1066 if sector==1 & state==15
replace pline=1270 if sector==1 & state==13
replace pline=695  if sector==1 & state==21
replace pline=1301 if sector==1 & state==34
replace pline=1054 if sector==1 & state==3
replace pline=905  if sector==1 & state==8
replace pline=930  if sector==1 & state==11
replace pline=880  if sector==1 & state==33
replace pline=798  if sector==1 & state==16
replace pline=768  if sector==1 & state==9
replace pline=880  if sector==1 & state==5
replace pline=783  if sector==1 & state==19

replace pline=937  if sector==2 & state==35
replace pline=1009 if sector==2 & state==28
replace pline=1060 if sector==2 & state==12
replace pline=1008 if sector==2 & state==18
replace pline=923  if sector==2 & state==10
replace pline=1155 if sector==2 & state==4
replace pline=849  if sector==2 & state==22
replace pline=1126 if sector==2 & state==26
replace pline=1134 if sector==2 & state==25
replace pline=1134 if sector==2 & state==7
replace pline=1134 if sector==2 & state==30
replace pline=1152 if sector==2 & state==24
replace pline=1169 if sector==2 & state==6
replace pline=1064 if sector==2 & state==2
replace pline=988  if sector==2 & state==1
replace pline=974  if sector==2 & state==20
replace pline=1089 if sector==2 & state==29
replace pline=987  if sector==2 & state==32
replace pline=987  if sector==2 & state==31
replace pline=897  if sector==2 & state==23
replace pline=1126 if sector==2 & state==27
replace pline=1170 if sector==2 & state==14
replace pline=1154 if sector==2 & state==17
replace pline=1155 if sector==2 & state==15
replace pline=1302 if sector==2 & state==13
replace pline=861  if sector==2 & state==21
replace pline=1309 if sector==2 & state==34
replace pline=1155 if sector==2 & state==3
replace pline=1002 if sector==2 & state==8
replace pline=1226 if sector==2 & state==11
replace pline=937  if sector==2 & state==33
replace pline=920  if sector==2 & state==16
replace pline=941  if sector==2 & state==9
replace pline=1082 if sector==2 & state==5
replace pline=981  if sector==2 & state==19

la var pline "Tendulkar Poverty Line 2011-12"

drop if mpce_mrp==.
drop if mpce_mrp==0
gen poor = (mpce_mrp<= pline)
la define poor 1 "Poor" 0 "Non-poor", modify
la values poor poor
la var poor "Poor:Tendulkar poverty line"

gen pline_double=2*pline
la var pline_double "Double Tendulkar Poverty Line 2011-12"
gen poor_double=(mpce_mrp<= pline_double)
label values poor_double poor
la var poor_double "Poor: Double Tendulkar poverty line"

gen pline_ind_11=.
replace pline_ind_11=816  if sector==1
replace pline_ind_11=1000 if sector==2
la var  pline_ind_11 "All-India-Tendulkar Poverty Line"

gen pline_ind_09=.
replace pline_ind_09=672.8 if sector==1
replace pline_ind_09=859.6 if sector==2

**REAL CONSUMPTION IN 2009-10 ALL INDIA RURAL RUPEES
gen real_mpce11=.
**FOR RURAL AREAS CONVERT CONSUMTPION TO 2009-10 ALL INDIA RURAL RUPEES
replace real_mpce11= (mpce_mrp*(pline_ind_11/pline))*(672.8/816) if sector==1
**FOR URBAN AREAS FIRST CONVERT CONSUMPTION TO 2009-10 ALL INDIA URBAN AND THEN TO 2009-10 ALL-INDIA RURAL RUPEES
replace real_mpce11= ((mpce_mrp*(pline_ind_11/pline))*(816/1000))*(672.8/816) if sector==2
la var real_mpce11 "Real-PC Monthly Cons-(in 2009-10 Rural Rs)"

xtile dec_mpce  = real_mpce11 [aw=pwt], nq(10)
la var dec_mpce "Real Consumption Deciles"
xtile dec_mpce2 = mpce_mrp [aw=pwt], nq(10)
la var dec_mpce2 "Nominal Consumption Deciles"

gen year=2011

gen lis=.
replace lis=1 if inlist(state,8,9,10,20,21,23,22)
replace lis=0 if lis==.
la define lis 0 "Not LIS" 1 "LIS"
la var lis lis

*3 decimals recorded in landtot_ha
replace landtot_ha=landtot_ha/1000
recode landtot_ha .=0              
*Only 2 decimals in landtot_ha variable in previous rounds, this makes definition comparable with earlier rounds
gen landowned=(landtot_ha>=0.005)
lab var landowned "Household owns land"

g 		landsize=landtot_ha
replace landsize=. if landowned==0
replace landsize=. if landowned==.
replace landsize=0 if (landtot_ha==0 & landowned==1)
replace landsize=. if (landtot_ha==. & landowned==1)
drop 	landtot_ha
lab var landsize "Total land owned in ha"

/*Per-capita Land*/
*gen pcland=(landtot_ha/hhsize)
*recode pcland .=0 

/*Percentage Irrigated Land*/
*gen prirri= landirrigate_ha/ landcult_ha

g 		cookingelec=0
*replace cookingelec=1 if cookmode==3
*replace cookingelec=1 if cookmode==4
replace cookingelec=1 if cookmode==8
replace cookingelec=. if cookmode==.
drop cookmode
lab var cookingelec "Primary source of energy for cooking is electricity"

g 		lightelec=0
*replace lightelec=1 if lightmode==3
replace lightelec=1 if lightmode==5
replace lightelec=. if lightmode==.
drop 	lightmode
lab var lightelec "Primary source of energy for lighting is electricity"

g 		dwellingowned=(dwellingcode==1)
replace dwellingowned=. if dwellingcode==.
drop 	dwellingcode
lab var dwellingowned "Dwelling owned by household"

g 		salary=(salaryincome==1)
replace salary=. if salaryincome==.
drop 	salaryincome
lab var salary "At least one household member is regular salary earner"

g 		ceremony1=(ceremony==1)
replace ceremony1=. if ceremony==.
drop 	ceremony
ren 	ceremony1 ceremony
lab var ceremony "Household performed ceremony during last 30 days"

g 		rationcard1=(rationcard==1)
replace rationcard1=. if rationcard==.
drop 	rationcard
ren 	rationcard1 rationcard

save "$nsso\Dta\constructed\borrar.dta", replace


*** Merging budget shares

use "$nsso\Dta\final_datasets\nsso68ce11typ1.dta", clear

keep hhid itemno value

drop if (itemno==28 | itemno==29 | itemno==30 | itemno==31 | itemno==32 | itemno==33 | itemno==34 | itemno==35 | itemno==42 | itemno==43 | itemno==44 | itemno==46 | itemno==47 | itemno==48 | itemno==49)

replace value=0 if value==.

replace value=(value/365)*30 if (itemno>=36  & itemno<=41)

g 	str aux="food" 						if (itemno>=1  & itemno<=15)
replace aux="tobacco & intoxicants"     if (itemno>=16 & itemno<=17)
replace aux="non food"    				if (itemno==18)
replace aux="health"	   				if (itemno==19)
replace aux="entertainment"				if (itemno==20)
replace aux="durables"					if (itemno==21)
replace aux="non food"  			    if (itemno>=22 & itemno<=25)
replace aux="rent" 		 			    if (itemno==26)
replace aux="non food"  			    if (itemno==27)
replace aux="non food"  			    if (itemno>=36 & itemno<=38)
replace aux="education"					if (itemno==39)
replace aux="health"					if (itemno==40)
replace aux="durables"					if (itemno==41)
replace aux="total_mrp"					if (itemno==45)

g aux1=value if aux=="total_mrp"
bys hhid: egen total=max(aux1)
drop if aux=="total_mrp"
drop aux1

collapse (rawsum) value (mean) total, by(hhid aux)

*The total adds up almost perfectly except for decimals. For accuracy, I create my own total expenditure before constructing budget shares.

drop total

bysort hhid: egen total=sum(value)

g sdurables=(value/total)*100 		if aux=="durables"
g seducation=(value/total)*100 		if aux=="education"
g sentertainment=(value/total)*100  if aux=="entertainment"
g sfood=(value/total)*100 			if aux=="food"
g shealth=(value/total)*100 		if aux=="health"
g snonfood=(value/total)*100 		if aux=="non food"
g srent=(value/total)*100 			if aux=="rent"
g stobacco=(value/total)*100 		if aux=="tobacco & intoxicants"

drop aux

foreach var in sdurables seducation sentertainment sfood shealth snonfood srent stobacco {
	bys hhid: egen s`var'=max(`var')
	drop `var'
	ren s`var' `var'
	replace `var'=0 if `var'==.
	}

bysort hhid: keep if _n==1

g check=sdurables+seducation+sentertainment+sfood+shealth+snonfood+srent+stobacco
sum check
drop check

sort hhid
merge 1:1 hhid using "$nsso\Dta\constructed\borrar.dta"
tab _m
drop _m

save "$nsso\Dta\constructed\borrar1.dta", replace

erase "$nsso\Dta\constructed\borrar.dta"


*** Merging assets owned

use "$nsso\Dta\final_datasets\nsso68ce9typ1.dta", clear

keep hhid a4 a5

ren a4 itemno
ren a5 own

destring itemno, replace
destring own, replace

keep if (itemno==561 | itemno==562 | itemno==585 | itemno==586 | itemno==588 | itemno==591 | itemno==601 | itemno==602 | itemno==622 | itemno==623)

replace own=0 if own==2
replace own=0 if own==.

reshape wide own, i(hhid) j(itemno)

lab var own561 "Television"
lab var own562 "VCR/VCD/DVD player"
lab var own585 "Washing machine"
lab var own586 "Stove, gas burner"
lab var own588 "refrigerator"
lab var own591 "Electric appliances"
lab var own601 "Motor cycle, scooter"	
lab var own602 "Motor car, jeep" 	
lab var own622 "PC/laptop/other software" 
lab var own623 "Mobile handset"  			

ren own561 tv
ren own562 dvd
ren own585 wmachine
ren own586 stove
ren own588 refrigerator
ren own591 appliances
ren own601 motorcycle
ren own602 motorcar
ren own622 laptop
ren own623 mobile
sort hhid
merge 1:1 hhid using "$nsso\Dta\constructed\borrar1.dta"
tab _m
*(0.12% of sample, 122 households in master data but not in using data, these are hholds that do not own any of the above assets)
drop _m

foreach var in tv dvd wmachine stove refrigerator motorcycle motorcar laptop mobile {
	replace `var'=0 if `var'==.
	}

*** Creating million plus cities dummy for urban sector (27 million plus cities, codes come from documentation)
*** Documentation (Table 4) has an error for three cities (Ludhiana, Indore, Bhopal). This has been corrected below.

generate millionplus=0

replace millionplus=. if sector==1

*replace millionplus=1 if state == 3  & district == 20  & stratum == 20 & sector==2
replace millionplus=1 if state == 6  & district == 19  & stratum == 21 & sector==2 
replace millionplus=1 if state == 7  & district == 1   & stratum == 10 & sector==2
replace millionplus=1 if state == 8  & district == 12  & stratum == 33 & sector==2
replace millionplus=1 if state == 9  & district == 7   & stratum == 72 & sector==2 
replace millionplus=1 if state == 9  & district == 15  & stratum == 73 & sector==2 
replace millionplus=1 if state == 9  & district == 27  & stratum == 74 & sector==2 
replace millionplus=1 if state == 9  & district == 34  & stratum == 75 & sector==2 
replace millionplus=1 if state == 9  & district == 67  & stratum == 76 & sector==2 
replace millionplus=1 if state == 10 & district == 28  & stratum == 39 & sector==2
replace millionplus=1 if state == 19 & district == 16  & stratum == 20 & sector==2 
replace millionplus=1 if state == 19 & district == 17  & stratum == 21 & sector==2 
*replace millionplus=1 if state == 23 & district == 49  & stratum == 49 & sector==2 
*replace millionplus=1 if state == 23 & district == 50  & stratum == 50 & sector==2 
replace millionplus=1 if state == 24 & district == 7   & stratum == 26 & sector==2
replace millionplus=1 if state == 24 & district == 19  & stratum == 27 & sector==2 
replace millionplus=1 if state == 24 & district == 22  & stratum == 28 & sector==2 
replace millionplus=1 if state == 27 & district == 9   & stratum == 36 & sector==2 
replace millionplus=1 if state == 27 & district == 20  & stratum == 37 & sector==2 
replace millionplus=1 if state == 27 & district == 21  & stratum == 38 & sector==2 
replace millionplus=1 if state == 27 & district == 21  & stratum == 39 & sector==2 
replace millionplus=1 if state == 27 & district == 22  & stratum == 40 & sector==2
replace millionplus=1 if state == 27 & district == 25  & stratum == 41 & sector==2
replace millionplus=1 if state == 27 & district == 25  & stratum == 42 & sector==2
replace millionplus=1 if state == 28 & district == 5   & stratum == 24 & sector==2
replace millionplus=1 if state == 29 & district == 20  & stratum == 30 & sector==2 
replace millionplus=1 if state == 33 & district == 2   & stratum == 32 & sector==2

replace millionplus=1 if state == 3 & district == 9   & stratum == 21 & sector==2
replace millionplus=1 if state == 23 & district == 26  & stratum == 51 & sector==2 
replace millionplus=1 if state == 23 & district == 32  & stratum == 52 & sector==2

*** Creating region variable consistent across years

g str3 state_reg1 = string(state_reg,"%03.0f")
g str3 region=substr(state_reg1, 3, 1)
destring region, replace
drop state_reg1 
*drop state_reg

/*
*** Recoding region code to match region codes in NSS 55st (round not used in this analysis)

gen region_55=region
*AP
replace region_55=1 if state==28  & region==2
replace region_55=2 if state==28 & (region==3|region==4)
replace region_55=3 if state==28 & (district==21 |district==22)
replace region_55=4 if state==28 & (district==20 |district==23)
*ASSAM
replace region_55=1 if state==18 & inlist(district,4,5,7,9,11,21)
replace region_55=2 if state==18 & inlist(district,8,10,13,17,18,22,23,27)
replace region_55=3 if state==18 & inlist(district,1,19,20)
*BIHAR
replace region_55=2 if state==10 & region==1
replace region_55=3 if state==10 & region==2
*CHATTISGARH
replace region_55=1 if state==22
*GUJARAT
replace region_55=4 if state==24 & inlist(district,8,1,2)
replace region_55=3 if state==24 & inlist(district,17,19,21,24)
*HP
replace region_55=1 if state==2
*JHARKHAND
replace region_55=1 if state==20
*MP
replace region_55=2 if state==23 & region==1
replace region_55=3 if state==23 & region==2
replace region_55=4 if state==23 & region==3
replace region_55=5 if state==23 & region==4
replace region_55=6 if state==23 & region==5
replace region_55=7 if state==23 & region==6
*ORISSA
replace region_55=1 if state==21 & inlist(district,19,20) 
replace region_55=3 if state==21 & inlist(district,23,24) 
*PUNJAB
replace region_55=1 if state==3 & district==9
*RAJASTHAN
replace region_55=1 if state==8 & inlist(district,1,2,4,14)
replace region_55=2 if state==8 & inlist(district,5,13)
*UP
replace region_55=2 if state==9 & region==1
replace region_55=2 if state==9 & region==5
replace region_55=3 if state==9 & region==2
replace region_55=3 if state==9 & district==23
replace region_55=4 if state==9 & region==3
replace region_55=5 if state==9 & region==4
*WB
replace region_55=3 if state==19 & region==4
replace region_55=4 if state==19 & region==5

lab var region_55 "Region code in NSS 55st"
*/


*** Recoding district names to match district codes in NSS 61st (2004/05)

gen district_ii = state*1000 + region*100 + district
label var district_ii "district id code NSS61 (unique code: state+region+district)"

*CHECK FOR NO. OF UNIQUE VALUES\DISTRICTS
codebook district_ii
*626 DISTRICTS IN DATA-FILE. 

*NSS REGIONS VARY ACROSS YEARS.
*A&N
replace district_ii=35101 if district_ii==35103
*ANDHRA PRADESH
replace district_ii=28116 if district_ii==28216
replace district_ii=28117 if district_ii==28217
replace district_ii=28118 if district_ii==28218
replace district_ii=28119 if district_ii==28219
replace district_ii=28201 if district_ii==28301
replace district_ii=28202 if district_ii==28302
replace district_ii=28204 if district_ii==28304
replace district_ii=28205 if district_ii==28305
replace district_ii=28206 if district_ii==28306
replace district_ii=28207 if district_ii==28307
replace district_ii=28203 if district_ii==28403
replace district_ii=28208 if district_ii==28408
replace district_ii=28209 if district_ii==28409
replace district_ii=28210 if district_ii==28410
replace district_ii=28420 if district_ii==28520
replace district_ii=28321 if district_ii==28521
replace district_ii=28322 if district_ii==28522
replace district_ii=28423 if district_ii==28523
*ASSAM
replace district_ii=18121 if district_ii==18321
replace district_ii=18122 if district_ii==18322
replace district_ii=18123 if district_ii==18323
replace district_ii=18208 if district_ii==18408
replace district_ii=18209 if district_ii==18409
replace district_ii=18210 if district_ii==18410
replace district_ii=18211 if district_ii==18411
*BIHAR
replace district_ii=10220 if district_ii==10120
replace district_ii=10221 if district_ii==10121
*CHHATTI
replace district_ii=22103 if district_ii==22203
replace district_ii=22104 if district_ii==22204
replace district_ii=22105 if district_ii==22205
replace district_ii=22106 if district_ii==22206
replace district_ii=22107 if district_ii==22207
replace district_ii=22108 if district_ii==22208
replace district_ii=22109 if district_ii==22209
replace district_ii=22110 if district_ii==22210
replace district_ii=22111 if district_ii==22211
replace district_ii=22112 if district_ii==22212
replace district_ii=22113 if district_ii==22213
replace district_ii=22114 if district_ii==22214
replace district_ii=22115 if district_ii==22215
replace district_ii=22116 if district_ii==22216
*GUJARAT
*NOTE: FOR DISTRICTS IN GUJARAT SPLIT BTW DIFERENT REGIONS IN 2004-05 BUT COMBINED IN 2011-12, CODES USED IN WAGES_r61.do USED
*OTHERS CHANGED BELOW IF APPLICABLE
replace district_ii=24402 if district_ii==24302
replace district_ii=24105 if district_ii==24205
replace district_ii=24203 if district_ii==24303
replace district_ii=24408 if district_ii==24508
*HP
replace district_ii=2101 if district_ii==2201
replace district_ii=2103 if district_ii==2203
replace district_ii=2108 if district_ii==2208
replace district_ii=2109 if district_ii==2209
replace district_ii=2110 if district_ii==2210
replace district_ii=2111 if district_ii==2211
replace district_ii=2112 if district_ii==2212
*J&K
replace district_ii=1307 if district_ii==1407
replace district_ii=1308 if district_ii==1408
*JHARKH
replace district_ii=20103 if district_ii==20203
replace district_ii=20104 if district_ii==20204
replace district_ii=20105 if district_ii==20205
replace district_ii=20106 if district_ii==20206
replace district_ii=20107 if district_ii==20207
replace district_ii=20108 if district_ii==20208
replace district_ii=20109 if district_ii==20209
replace district_ii=20110 if district_ii==20210
replace district_ii=20111 if district_ii==20211
replace district_ii=20112 if district_ii==20212
replace district_ii=20113 if district_ii==20213
replace district_ii=20121 if district_ii==20221
*ORISSA
replace district_ii=21119 if district_ii==21219
replace district_ii=21120 if district_ii==21220
replace district_ii=21323 if district_ii==21223
replace district_ii=21324 if district_ii==21224
*PUNJAB
replace district_ii=3109 if district_ii==3209
*RAJASTHAN
replace district_ii=8101 if district_ii==8501
replace district_ii=8102 if district_ii==8502
replace district_ii=8104 if district_ii==8504
replace district_ii=8114 if district_ii==8514
replace district_ii=8205 if district_ii==8505
replace district_ii=8213 if district_ii==8513
*UP
replace district_ii=9111 if district_ii==9511
replace district_ii=9112 if district_ii==9512
replace district_ii=9113 if district_ii==9513
replace district_ii=9114 if district_ii==9514
replace district_ii=9115 if district_ii==9515
replace district_ii=9116 if district_ii==9516
replace district_ii=9117 if district_ii==9517
replace district_ii=9118 if district_ii==9518
replace district_ii=9119 if district_ii==9519
replace district_ii=9120 if district_ii==9520
replace district_ii=9121 if district_ii==9521
replace district_ii=9122 if district_ii==9522
replace district_ii=9223 if district_ii==9523
replace district_ii=9129 if district_ii==9529
replace district_ii=9130 if district_ii==9530
replace district_ii=9131 if district_ii==9531
replace district_ii=9132 if district_ii==9532
*WB
replace district_ii=19309 if district_ii==19409
replace district_ii=19312 if district_ii==19412
replace district_ii=19316 if district_ii==19416
replace district_ii=19413 if district_ii==19513
replace district_ii=19414 if district_ii==19514
replace district_ii=19415 if district_ii==19515
replace district_ii=19419 if district_ii==19519

gen district_nm=district_ii
label var district_nm "District Names"
**RUN DO FILE WITH LABELS FOR 2004-05 CODE BASED DISTRICT NAMES
do "$employment\dist_names.do"

save "$nsso\Dta\constructed\poverty68.dta", replace

erase "$nsso\Dta\constructed\borrar1.dta"


*** Merging individual level dataset

merge 1:m hhid using "$nsso\Dta\final_datasets\nsso68ce4typ1.dta", keepusing(a5 a6 a7 a8 a9 fsu hamlet secstratum indid)
tab _m
drop _m

drop year
g year=2011

ren a5 relation
ren a6 sex
ren a7 age
ren a8 marital
ren a9 education

destring fsu, replace
destring hamlet, replace
destring secstratum, replace
destring relation, replace
destring sex, replace
destring age, replace
destring marital, replace
destring education, replace

g 		education_yrs=.
replace education_yrs=0  if  education==1
replace education_yrs=2  if (education==2 | education==3 | education==4 | education==5)
replace education_yrs=5  if  education==6
replace education_yrs=8  if education==7
replace education_yrs=10 if (education==8 | education==10)
replace education_yrs=15 if (education==11 | education==12 | education==13)

g illiterate=(education_yrs==0)
replace illiterate=. if education_yrs==.

g belowprimary=(education_yrs<5)
replace belowprimary=. if education_yrs==.
replace belowprimary=0 if illiterate==1

g primary=(education_yrs==5)
replace primary=. if education_yrs==.

g middle=(education_yrs==8)
replace middle=. if education_yrs==.

g secondary=(education_yrs>8)
replace secondary=. if education_yrs==.

drop education

save "$nsso\Dta\constructed\poverty68_ind.dta", replace


use "$nsso\Dta\constructed\poverty68.dta"

di "2011-12"
ineqdeco real_mpce11 [aw=pwt]
di "RURAL"
ineqdeco real_mpce11 [aw=pwt] if sector==1
di "URBAN"
ineqdeco real_mpce11 [aw=pwt] if sector==2


**NOMINAL AND REAL CONSUMPTION MEANS
sum mpce_mrp real_mpce11 [aw=pwt]

**BOTTTOM 40 PERCENTILE MEAN MPCE REAL
sum  real_mpce11 [aw=pwt] if inrange(dec_mpce,1,4)

**BOTTTOM 40 PERCENTILE MEAN MPCE NOMINAL
sum  mpce_mrp [aw=pwt] if inrange(dec_mpce2,1,4)

*BY SECTOR
foreach num of numlist 1/2 {
	sum mpce_mrp real_mpce11 [aw=pwt] if sector==`num'
}


***************************************************************************************************
**2009-10
****************************************************************************************************

*global nsso "C:\Users\wb370975\Documents\NSS\NSS-66-Sch1-Type1"
global nsso "C:\Users\wb381047.WB\Dropbox\WB_Monica\SASEP\India\NSS\NSS-66-Sch1-Type1"

/**/

use "$nsso\Dta\final_datasets\nsso66ce1typ1",clear
keep hhid state sample sector nssreg district stratum substratum fsu 
merge 1:1 hhid using "$nsso\Dta\final_datasets\nsso66ce2typ1"
ren nic3 nco3
keep hhid state sample sector nssreg district stratum substratum fsu religion sgroup hhsize landown landowntyp hhwt pwt landtot_ha nic5 nco3 hhtype
merge 1:1 hhid using "$nsso\Dta\final_datasets\nsso66ce3typ1"
drop _m
ren nssreg state_reg

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

**POVERTY-LINES 2009
*RURAL
gen pline=.
replace pline=693.8  if state==28 & sector==1
replace pline=773.7  if state==12 & sector==1
replace pline=691.7  if state==18 & sector==1
replace pline=655.6  if state==10 & sector==1
replace pline=617.3  if state==22 & sector==1
replace pline=747.8  if state==7  & sector==1
replace pline=931    if state==30 & sector==1
replace pline=725.9  if state==24 & sector==1
replace pline=791.6  if state==6  & sector==1
replace pline=708    if state==2  & sector==1
replace pline=722.9  if state==1  & sector==1
replace pline=616.3  if state==20 & sector==1
replace pline=629.4  if state==29 & sector==1
replace pline=775.3  if state==32 & sector==1
replace pline=631.9  if state==23 & sector==1
replace pline=743.7  if state==27 & sector==1
replace pline=871    if state==14 & sector==1
replace pline=686.9  if state==17 & sector==1
replace pline=850    if state==15 & sector==1
replace pline=1016.8 if state==13 & sector==1
replace pline=567.1  if state==21 & sector==1
replace pline=641    if state==34 & sector==1
replace pline=830    if state==3  & sector==1
replace pline=755    if state==8  & sector==1
replace pline=728.9  if state==11 & sector==1
replace pline=639    if state==33 & sector==1
replace pline=663.4  if state==16 & sector==1
replace pline=663.7  if state==9  & sector==1
replace pline=719.5  if state==5  & sector==1
replace pline=643.2  if state==19 & sector==1

**UTS- POVERTY LINES OF NEIGHBOURING STATES AS THEY HAVE NO POVERTY LINES DEFINED (UTS STANDS FOR UNITARY TERRITORY SYSTEM)
*A&N--PLINE OF TN
replace pline=639 if state==35 & sector==1
*CHD- URBAN PLINE OF PUNJAB
replace pline=960.8 if state==4 & sector==1
*D&N- PLINE OF MAHARASHTRA
replace pline=743.7 if state==26 & sector==1
*D&D-PLINE OF GOA
replace pline=931 if state==25 & sector==1
**LKSHWDEEP- PLINE OF KERALA
replace pline=775.3 if state==31 & sector==1

*URBAN
replace pline=926.4  if state==28 & sector==2
replace pline=925.2  if state==12 & sector==2
replace pline=871    if state==18 & sector==2
replace pline=775.3  if state==10 & sector==2
replace pline=806.7  if state==22 & sector==2
replace pline=1040.3 if state==7  & sector==2
replace pline=1025.4 if state==30 & sector==2
replace pline=951.4  if state==24 & sector==2
replace pline=975.4  if state==6  & sector==2
replace pline=888.3  if state==2  & sector==2
replace pline=845.4  if state==1  & sector==2
replace pline=831.2  if state==20 & sector==2
replace pline=908    if state==29 & sector==2
replace pline=830.7  if state==32 & sector==2
replace pline=771.7  if state==23 & sector==2
replace pline=961.1  if state==27 & sector==2
replace pline=955    if state==14 & sector==2
replace pline=989.8  if state==17 & sector==2
replace pline=939.3  if state==15 & sector==2
replace pline=1147.6 if state==13 & sector==2
replace pline=736    if state==21 & sector==2
replace pline=777.7  if state==34 & sector==2
replace pline=960.8  if state==3  & sector==2
replace pline=846    if state==8  & sector==2
replace pline=1035.2 if state==11 & sector==2
replace pline=800.8  if state==33 & sector==2
replace pline=782.7  if state==16 & sector==2
replace pline=799.9  if state==9  & sector==2
replace pline=898.6  if state==5  & sector==2
replace pline=830.6  if state==19 & sector==2

**UTS- POVERTY LINES OF NEIGHBOURING STATES
*A&N--PLINE OF TN
replace pline=800.8 if state==35 & sector==2
**CHD- URBAN PLINE OF PUNJAB
replace pline=960.8 if state==4 & sector==2
**D&N- PLINE OF MAHARASHTRA
replace pline=961.1 if state==26 & sector==2
**D&D-PLINE OF GOA
replace pline=1025.4 if state==25 & sector==2
*LKSHWDEEP- PLINE OF KERALA
replace pline=830.7 if state==31 & sector==2

la var pline "Tendulkar Poverty Line 2009-10"

drop if mpce_mrp==.
drop if mpce_mrp==0
gen poor = (mpce_mrp<= pline)
la define poor 1 "Poor" 0 "Not-poor", modify
la values poor poor
la var poor "Poor: Tendulkar poverty line"

gen pline_double=2*pline
la var pline_double "Double Tendulkar Poverty Line 2009-10"
gen poor_double = (mpce_mrp<= pline_double)
label values poor_double poor
la var poor_double "Poor: Double Tendulkar poverty line"

**REAL CONSUMPTION IN 2009-10 ALL INDIA RURAL RUPEES
gen pline_ind_09=.
replace pline_ind_09=672.8 if sector==1
replace pline_ind_09=859.6 if sector==2
la var pline_ind_09 "All-India-Tendulkar Poverty Line"

gen real_mpce09=.
**FOR RURAL AREAS CONVERT CONSUMTPION TO 2009-10 ALL INDIA RURAL RUPEES
replace real_mpce09= mpce_mrp*(pline_ind_09/pline) if sector==1
**FOR URBAN AREAS FIRST CONVERT CONSUMPTION TO 2009-10 ALL INDIA URBAN AND THEN TO 2009-10 ALL-INDIA RURAL RUPEES
replace real_mpce09= (mpce_mrp*(pline_ind_09/pline))*(672.8/859.6) if sector==2

la var real_mpce09 "Real-PC Monthly Cons-(in 2009-10 Rural Rs)"

xtile dec_mpce  = real_mpce09 [aw=pwt], nq(10)
la var dec_mpce "Real Consumption Deciles"
xtile dec_mpce2 = mpce_mrp [aw=pwt], nq(10)
la var dec_mpce2 "Nominal Consumption Deciles"

gen year=2009
drop level a1 a3 a13 a14 a15 a16 a17

gen lis=.
replace lis=1 if inlist(state,8,9,10,20,21,23,22)
replace lis=0 if lis==.
la define lis 0 "Not LIS" 1 "LIS"
la var lis lis

*3 decimals recorded in landtot_ha
replace landtot_ha=landtot_ha/1000
recode landtot_ha .=0              
*Only 2 decimals in landtot_ha variable in previous rounds, this makes definition comparable with earlier rounds
gen landowned=(landtot_ha>=0.005)
lab var landowned "Household owns land"

g 		landsize=landtot_ha
replace landsize=. if landowned==0
replace landsize=. if landowned==.
replace landsize=0 if (landtot_ha==0 & landowned==1)
replace landsize=. if (landtot_ha==. & landowned==1)
drop 	landtot_ha
lab var landsize "Total land owned in ha"


g 		cookingelec=0
*replace cookingelec=1 if cookmode==3
*replace cookingelec=1 if cookmode==4
replace cookingelec=1 if cookmode==8
replace cookingelec=. if cookmode==.
drop cookmode
lab var cookingelec "Primary source of energy for cooking is electricity"

g 		lightelec=0
*replace lightelec=1 if lightmode==3
replace lightelec=1 if lightmode==5
replace lightelec=. if lightmode==.
drop 	lightmode
lab var lightelec "Primary source of energy for lighting is electricity"

g 		dwellingowned=(dwellingcode==1)
replace dwellingowned=. if dwellingcode==.
drop 	dwellingcode
lab var dwellingowned "Dwelling owned by household"

g 		salary=(salaryincome==1)
replace salary=. if salaryincome==.
drop 	salaryincome
lab var salary "At least one household member is regular salary earner"

g 		ceremony1=(ceremony==1)
replace ceremony1=. if ceremony==.
drop 	ceremony
ren 	ceremony1 ceremony
lab var ceremony "Household performed ceremony during last 30 days"

g 		rationcard=.

save "$nsso\Dta\constructed\borrar.dta", replace


*** Merging budget shares

use "$nsso\Dta\final_datasets\nsso66ce10typ1.dta", clear

keep hhid itemno value

drop if (itemno==27 | itemno==28 | itemno==29 | itemno==30 | itemno==31 | itemno==32 | itemno==33 | itemno==34 | itemno==41 |itemno==42 | itemno==43 | itemno==45 | itemno==46 | itemno==47 | itemno==48)

replace value=0 if value==.

replace value=(value/365)*30 if (itemno>=35  & itemno<=40)

g 	str aux="food" 						if (itemno>=1  & itemno<=14)
replace aux="tobacco & intoxicants"     if (itemno>=15 & itemno<=16)
replace aux="non food"    				if (itemno==17)
replace aux="health"	   				if (itemno==18)
replace aux="entertainment"				if (itemno==19)
replace aux="durables"					if (itemno==20)
replace aux="non food"  			    if (itemno>=21 & itemno<=24)
replace aux="rent" 		 			    if (itemno==25)
replace aux="non food"  			    if (itemno==26)
replace aux="non food"  			    if (itemno>=35 & itemno<=37)
replace aux="education"					if (itemno==38)
replace aux="health"					if (itemno==39)
replace aux="durables"					if (itemno==40)
replace aux="total_mrp"					if (itemno==44)

g aux1=value if aux=="total_mrp"
bys hhid: egen total=max(aux1)
drop if aux=="total_mrp"
drop aux1

collapse (rawsum) value (mean) total, by(hhid aux)

*The total adds up almost perfectly except for decimals. For accuracy, I create my own total expenditure before constructing budget shares.

drop total

bysort hhid: egen total=sum(value)

g sdurables=(value/total)*100 		if aux=="durables"
g seducation=(value/total)*100 		if aux=="education"
g sentertainment=(value/total)*100  if aux=="entertainment"
g sfood=(value/total)*100 			if aux=="food"
g shealth=(value/total)*100 		if aux=="health"
g snonfood=(value/total)*100 		if aux=="non food"
g srent=(value/total)*100 			if aux=="rent"
g stobacco=(value/total)*100 		if aux=="tobacco & intoxicants"

drop aux

foreach var in sdurables seducation sentertainment sfood shealth snonfood srent stobacco {
	bys hhid: egen s`var'=max(`var')
	drop `var'
	ren s`var' `var'
	replace `var'=0 if `var'==.
	}

bysort hhid: keep if _n==1

g check=sdurables+seducation+sentertainment+sfood+shealth+snonfood+srent+stobacco
sum check
drop check

sort hhid
merge 1:1 hhid using "$nsso\Dta\constructed\borrar.dta"
tab _m
drop _m

save "$nsso\Dta\constructed\borrar1.dta", replace

erase "$nsso\Dta\constructed\borrar.dta"



*** Merging assets owned

use "$nsso\Dta\final_datasets\nsso66ce9typ1.dta", clear

keep hhid item possess

ren item itemno
ren possess own

keep if (itemno==561 | itemno==562 | itemno==584 | itemno==585 | itemno==587 | itemno==590 | itemno==601 | itemno==602 | itemno==622 | itemno==623)

replace own=0 if own==2
replace own=0 if own==.

reshape wide own, i(hhid) j(itemno)

lab var own561 "Television"
lab var own562 "VCR/VCD/DVD player"
lab var own584 "Washing machine"
lab var own585 "Stove, gas burner"
lab var own587 "refrigerator"
lab var own590 "Electric appliances"
lab var own601 "Motor cycle, scooter"	
lab var own602 "Motor car, jeep" 	
lab var own622 "PC/laptop/other software" 
lab var own623 "Mobile handset"  			

ren own561 tv
ren own562 dvd
ren own584 wmachine
ren own585 stove
ren own587 refrigerator
ren own590 appliances
ren own601 motorcycle
ren own602 motorcar
ren own622 laptop
ren own623 mobile

sort hhid
merge 1:1 hhid using "$nsso\Dta\constructed\borrar1.dta"
tab _m
*(2.58% of sample, 2,598 households in master data but not in using data, these are hholds that do not own any of the above assets)
drop _m

foreach var in tv dvd wmachine stove refrigerator motorcycle motorcar laptop mobile {
	replace `var'=0 if `var'==.
	}


*** Creating million plus cities dummy for urban sector (27 million plus cities, codes come from documentation)

generate millionplus=0

replace millionplus=. if sector==1

replace millionplus=1 if state == 28 & district == 5   & stratum == 24 & sector==2 
replace millionplus=1 if state == 10 & district == 28  & stratum == 39 & sector==2 
replace millionplus=1 if state == 7  & district == 1   & stratum == 10 & sector==2 
replace millionplus=1 if state == 24 & district == 7   & stratum == 26 & sector==2 
replace millionplus=1 if state == 24 & district == 22  & stratum == 28 & sector==2 
replace millionplus=1 if state == 24 & district == 19  & stratum == 27 & sector==2 
replace millionplus=1 if state == 6  & district == 19  & stratum == 21 & sector==2 
replace millionplus=1 if state == 29 & district == 20  & stratum == 28 & sector==2 
replace millionplus=1 if state == 23 & district == 32  & stratum == 50 & sector==2 
replace millionplus=1 if state == 23 & district == 26  & stratum == 49 & sector==2
replace millionplus=1 if state == 27 & district == 22  & stratum == 40 & sector==2 
replace millionplus=1 if state == 27 & district == 21  & stratum == 38 & sector==2 
replace millionplus=1 if state == 27 & district == 9   & stratum == 36 & sector==2 
replace millionplus=1 if state == 27 & district == 20  & stratum == 37 & sector==2 
replace millionplus=1 if state == 27 & district == 25  & stratum == 41 & sector==2 
replace millionplus=1 if state == 27 & district == 25  & stratum == 42 & sector==2 
replace millionplus=1 if state == 27 & district == 21  & stratum == 39 & sector==2 
replace millionplus=1 if state == 3  & district == 9   & stratum == 19 & sector==2 
replace millionplus=1 if state == 8  & district == 12  & stratum == 33 & sector==2 
replace millionplus=1 if state == 33 & district == 2   & stratum == 32 & sector==2 
replace millionplus=1 if state == 9  & district == 15  & stratum == 72 & sector==2 
replace millionplus=1 if state == 9  & district == 34  & stratum == 74 & sector==2
replace millionplus=1 if state == 9  & district == 27  & stratum == 73 & sector==2
replace millionplus=1 if state == 9  & district == 7   & stratum == 71 & sector==2
replace millionplus=1 if state == 9  & district == 67  & stratum == 75 & sector==2 
replace millionplus=1 if state == 19 & district == 16  & stratum == 20 & sector==2 
replace millionplus=1 if state == 19 & district == 17  & stratum == 21 & sector==2 


*** Creating region variable consistent across years

g str3 state_reg1 = string(state_reg,"%03.0f")
g str3 region=substr(state_reg1, 3, 1)
destring region, replace
drop state_reg1 
*drop state_reg

*** Recoding district names to match district codes in NSS 61st (2004/05)

gen district_ii = state*1000 + region*100 + district
label var district_ii "district id code NSS61 (unique code: state+region+district)"

*CHECK FOR NO. OF UNIQUE VALUES\DISTRICTS
codebook district_ii
*612 DISTRICTS IN DATA-FILE. 

*NSS REGIONS VARY ACROSS YEARS.
*A&N
replace district_ii=35101 if district_ii==35103
*ANDHRA PRADESH
replace district_ii=28116 if district_ii==28216
replace district_ii=28117 if district_ii==28217
replace district_ii=28118 if district_ii==28218
replace district_ii=28119 if district_ii==28219
replace district_ii=28201 if district_ii==28301
replace district_ii=28202 if district_ii==28302
replace district_ii=28204 if district_ii==28304
replace district_ii=28205 if district_ii==28305
replace district_ii=28206 if district_ii==28306
replace district_ii=28207 if district_ii==28307
replace district_ii=28203 if district_ii==28403
replace district_ii=28208 if district_ii==28408
replace district_ii=28209 if district_ii==28409
replace district_ii=28210 if district_ii==28410
replace district_ii=28420 if district_ii==28520
replace district_ii=28321 if district_ii==28521
replace district_ii=28322 if district_ii==28522
replace district_ii=28423 if district_ii==28523
*ASSAM
replace district_ii=18121 if district_ii==18321
replace district_ii=18122 if district_ii==18322
replace district_ii=18123 if district_ii==18323
replace district_ii=18208 if district_ii==18408
replace district_ii=18209 if district_ii==18409
replace district_ii=18210 if district_ii==18410
replace district_ii=18211 if district_ii==18411
*BIHAR
replace district_ii=10220 if district_ii==10120
replace district_ii=10221 if district_ii==10121
*CHHATTI
replace district_ii=22103 if district_ii==22203
replace district_ii=22104 if district_ii==22204
replace district_ii=22105 if district_ii==22205
replace district_ii=22106 if district_ii==22206
replace district_ii=22107 if district_ii==22207
replace district_ii=22108 if district_ii==22208
replace district_ii=22109 if district_ii==22209
replace district_ii=22110 if district_ii==22210
replace district_ii=22111 if district_ii==22211
replace district_ii=22112 if district_ii==22212
replace district_ii=22113 if district_ii==22213
replace district_ii=22114 if district_ii==22214
replace district_ii=22115 if district_ii==22215
replace district_ii=22116 if district_ii==22216
*GUJARAT
*NOTE: FOR DISTRICTS IN GUJARAT SPLIT BTW DIFERENT REGIONS IN 2004-05 BUT COMBINED IN 2009-10, CODES USED IN WAGES_r61.do USED
*OTHERS CHANGED BELOW IF APPLICABLE
replace district_ii=24402 if district_ii==24302
replace district_ii=24105 if district_ii==24205
replace district_ii=24203 if district_ii==24303
replace district_ii=24408 if district_ii==24508
*HP
replace district_ii=2101 if district_ii==2201
replace district_ii=2103 if district_ii==2203
replace district_ii=2108 if district_ii==2208
replace district_ii=2109 if district_ii==2209
replace district_ii=2110 if district_ii==2210
replace district_ii=2111 if district_ii==2211
replace district_ii=2112 if district_ii==2212
*J&K
replace district_ii=1307 if district_ii==1407
replace district_ii=1308 if district_ii==1408
*JHARKH
replace district_ii=20103 if district_ii==20203
replace district_ii=20104 if district_ii==20204
replace district_ii=20105 if district_ii==20205
replace district_ii=20106 if district_ii==20206
replace district_ii=20107 if district_ii==20207
replace district_ii=20108 if district_ii==20208
replace district_ii=20109 if district_ii==20209
replace district_ii=20110 if district_ii==20210
replace district_ii=20111 if district_ii==20211
replace district_ii=20112 if district_ii==20212
replace district_ii=20113 if district_ii==20213
replace district_ii=20121 if district_ii==20221
*ORISSA
replace district_ii=21119 if district_ii==21219
replace district_ii=21120 if district_ii==21220
replace district_ii=21323 if district_ii==21223
replace district_ii=21324 if district_ii==21224
*PUNJAB
replace district_ii=3109 if district_ii==3209
*RAJASTHAN
replace district_ii=8101 if district_ii==8501
replace district_ii=8102 if district_ii==8502
replace district_ii=8104 if district_ii==8504
replace district_ii=8114 if district_ii==8514
replace district_ii=8205 if district_ii==8505
replace district_ii=8213 if district_ii==8513
*UP
replace district_ii=9111 if district_ii==9511
replace district_ii=9112 if district_ii==9512
replace district_ii=9113 if district_ii==9513
replace district_ii=9114 if district_ii==9514
replace district_ii=9115 if district_ii==9515
replace district_ii=9116 if district_ii==9516
replace district_ii=9117 if district_ii==9517
replace district_ii=9118 if district_ii==9518
replace district_ii=9119 if district_ii==9519
replace district_ii=9120 if district_ii==9520
replace district_ii=9121 if district_ii==9521
replace district_ii=9122 if district_ii==9522
replace district_ii=9223 if district_ii==9523
replace district_ii=9129 if district_ii==9529
replace district_ii=9130 if district_ii==9530
replace district_ii=9131 if district_ii==9531
replace district_ii=9132 if district_ii==9532
*WB
replace district_ii=19309 if district_ii==19409
replace district_ii=19312 if district_ii==19412
replace district_ii=19316 if district_ii==19416
replace district_ii=19413 if district_ii==19513
replace district_ii=19414 if district_ii==19514
replace district_ii=19415 if district_ii==19515
replace district_ii=19419 if district_ii==19519

gen district_nm=district_ii
label var district_nm "District Names"
**RUN DO FILE WITH LABELS FOR 2004-05 CODE BASED DISTRICT NAMES
do "$employment\dist_names.do"


save "$nsso\Dta\constructed\poverty66.dta", replace

erase "$nsso\Dta\constructed\borrar1.dta"


*** Merging individual level dataset

merge 1:m hhid using "$nsso\Dta\final_datasets\nsso66ce4typ1.dta", keepusing(relation sex age marstat edugen fsu hamlet secstratum pid)
tab _m
drop _m

ren pid indid

drop year
g year=2009

ren marstat marital

* Education is recoded to match other waves data coding

ren edugen education

g 		education_yrs=.
replace education_yrs=0  if  education==1
replace education_yrs=2  if (education==2 | education==3 | education==4 | education==5)
replace education_yrs=5  if  education==6
replace education_yrs=8  if education==7
replace education_yrs=10 if (education==8 | education==10)
replace education_yrs=15 if (education==11 | education==12 | education==13)

g illiterate=(education_yrs==0)
replace illiterate=. if education_yrs==.

g belowprimary=(education_yrs<5)
replace belowprimary=. if education_yrs==.
replace belowprimary=0 if illiterate==1

g primary=(education_yrs==5)
replace primary=. if education_yrs==.

g middle=(education_yrs==8)
replace middle=. if education_yrs==.

g secondary=(education_yrs>8)
replace secondary=. if education_yrs==.

drop education

save "$nsso\Dta\constructed\poverty66_ind.dta", replace



use "$nsso\Dta\constructed\poverty66.dta"

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

*BY SECTOR
foreach num of numlist 1/2 {
	sum mpce_mrp real_mpce09 [aw=pwt] if sector==`num'
}



**********************************************************************
*2004-05
**********************************************************************

clear
*global nsso "C:\Users\wb370975\Documents\NSS\NSS-61-Sch1"
global nsso "C:\Users\wb381047.WB\Dropbox\WB_Monica\SASEP\India\NSS\NSS-61-Sch1"

/**/

use "$nsso\Dta\final_datasets\nsso61ce1", clear
keep  hhid-hhserial nss nsc mlt hhwt state state_reg fsu
**use the file for taking the weights across rounds  
save "$nsso\Dta\constructed\id_wt", replace

use "$nsso\Dta\final_datasets\nsso61ce2",clear
keep hhid hhsize hhtype religion sgroup a10 a16 nic5 nco3 hhtype
ren a10 landown 
ren a16 landtot_ha
merge 1:1 hhid using "$nsso\Dta\constructed\id_wt"
gen pwt=hhwt*hhsize
label var pwt "Population Weight"
order  hhid fsu hamlet sec_stratum hhserial round schedule sample sector state_reg district stratum sub_stratum sub_round sub_sample fod_subregion *
destring (fsu hamlet sec_stratum hhserial round schedule sample district stratum sub_stratum sub_round sub_sample fod_subregion), replace
drop _m
save "$nsso\Dta\constructed\id_wt", replace

use "$nsso\Dta\final_datasets\nsso61ce3",clear

keep hhid a16- mpce365 a4 a5 a6	a7 a8 a9 a14
ren a4 dwellingcode
ren a5 cookmode
ren a6 lightmode
ren a7 salaryincome
ren a8 rationcard
ren a9 rationcard_type
ren a14 ceremony

merge 1:1 hhid using "$nsso\Dta\constructed\id_wt"
drop _m
replace mpce365=mpce365/hhsize
ren mpce365 mpce_mrp
label var mpce_mrp "MRP: MPCE (per capita)"
label define sector 1 "rural" 2 "urban"
label values sector sector

*STATE &SECTOR-WISE POVERTY LINES. 

gen pline=.
replace pline=433.43 if state==28 & sector==1
replace pline=547.14 if state==12 & sector==1
replace pline=478 if state==18    & sector==1
replace pline=433.43 if state==10 & sector==1
replace pline=398.92 if state==22 & sector==1
replace pline=541.39 if state==7  & sector==1
replace pline=608.76 if state==30 & sector==1
replace pline=501.58 if state==24 & sector==1
replace pline=529.42 if state==6  & sector==1
replace pline=520.4 if state==2   & sector==1
replace pline=522.3 if state==1   & sector==1
replace pline=404.79 if state==20 & sector==1
replace pline=417.84 if state==29 & sector==1
replace pline=537.31 if state==32 & sector==1
replace pline=408.41 if state==23 & sector==1
replace pline=484.89 if state==27 & sector==1
replace pline=578.11 if state==14 & sector==1
replace pline=503.32 if state==17 & sector==1
replace pline=639.27 if state==15 & sector==1
replace pline=687.3 if state==13  & sector==1
replace pline=407.78 if state==21 & sector==1
replace pline=385.45 if state==34 & sector==1
replace pline=543.51 if state==3  & sector==1
replace pline=478 if state==8     & sector==1
replace pline=531.5 if state==11  & sector==1
replace pline=441.69 if state==33 & sector==1
replace pline=450.49 if state==16 & sector==1
replace pline=435.14 if state==9  & sector==1
replace pline=486.24 if state==5  & sector==1
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

gen lis=.
replace lis=1 if inlist(state,8,9,10,20,21,23,22)
replace lis=0 if lis==.
la define lis 0 "Not LIS" 1 "LIS"
la var lis lis

*3 decimals recorded in landtot_ha
replace landtot_ha=landtot_ha/1000
recode landtot_ha .=0              
*Only 2 decimals in landtot_ha variable in previous rounds, this makes definition comparable with earlier rounds
gen landowned=(landtot_ha>=0.005)
lab var landowned "Household owns land"

g 		landsize=landtot_ha
replace landsize=. if landowned==0
replace landsize=. if landowned==.
replace landsize=0 if (landtot_ha==0 & landowned==1)
replace landsize=. if (landtot_ha==. & landowned==1)
drop 	landtot_ha
lab var landsize "Total land owned in ha"


destring cookmode, replace
g 		cookingelec=0
*replace cookingelec=1 if cookmode==3
*replace cookingelec=1 if cookmode==4
replace cookingelec=1 if cookmode==8
replace cookingelec=. if cookmode==.
drop cookmode
lab var cookingelec "Primary source of energy for cooking is electricity"

destring lightmode, replace
g 		lightelec=0
*replace lightelec=1 if lightmode==3
replace lightelec=1 if lightmode==5
replace lightelec=. if lightmode==.
drop 	lightmode
lab var lightelec "Primary source of energy for lighting is electricity"

destring dwellingcode, replace
g 		dwellingowned=(dwellingcode==1)
replace dwellingowned=. if dwellingcode==.
drop 	dwellingcode
lab var dwellingowned "Dwelling owned by household"

destring salaryincome, replace
g 		salary=(salaryincome==1)
replace salary=. if salaryincome==.
drop 	salaryincome
lab var salary "At least one household member is regular salary earner"

destring ceremony, replace
g 		ceremony1=(ceremony==1)
replace ceremony1=. if ceremony==.
drop 	ceremony
ren 	ceremony1 ceremony
lab var ceremony "Household performed ceremony during last 30 days"

destring rationcard, replace
g 		rationcard1=(rationcard==1)
replace rationcard1=. if rationcard==.
drop 	rationcard
ren 	rationcard1 rationcard


*** Merging budget shares

*Data has not been pre-processed

save "$nsso\Dta\constructed\borrar1.dta", replace

*erase "$nsso\Dta\constructed\borrar.dta"


*** Merging assets owned

use "$nsso\Dta\final_datasets\nsso61ce9.dta", clear

keep hhid item possess

ren item itemno
ren possess own

keep if (itemno==562 | itemno==563 | itemno==595 | itemno==596 | itemno==598 | itemno==600 | itemno==611 | itemno==612 | itemno==632 | itemno==633)

replace own=0 if own==2
replace own=0 if own==.

reshape wide own, i(hhid) j(itemno)

lab var own562 "Television"
lab var own563 "VCR/VCD/DVD player"
lab var own595 "Washing machine"
lab var own596 "Stove, gas burner"
lab var own598 "refrigerator"
lab var own600 "Electric appliances"
lab var own611 "Motor cycle, scooter"	
lab var own612 "Motor car, jeep" 	
lab var own632 "PC/laptop/other software" 
lab var own633 "Mobile handset"  			

ren own562 tv
ren own563 dvd
ren own595 wmachine
ren own596 stove
ren own598 refrigerator
ren own600 appliances
ren own611 motorcycle
ren own612 motorcar
ren own632 laptop
ren own633 mobile

sort hhid
merge 1:1 hhid using "$nsso\Dta\constructed\borrar1.dta"
tab _m
*(6.79% of sample, 8,463 households in master data but not in using data, these are hholds that do not own any of the above assets)
drop _m

foreach var in tv dvd wmachine stove refrigerator motorcycle motorcar laptop mobile {
	replace `var'=0 if `var'==.
	}

ren sec_stratum secstratum

*** Creating million plus cities dummy for urban sector (27 million plus cities, codes come from documentation)

generate millionplus=0

replace millionplus=. if sector==1

replace millionplus=1 if state == 9  & district == 15 & stratum == 72 & sector==2
replace millionplus=1 if state == 24 & district == 7  & stratum == 26 & sector==2 
replace millionplus=1 if state == 29 & district == 20 & stratum == 28 & sector==2 
replace millionplus=1 if state == 23 & district == 32 & stratum == 47 & sector==2 
replace millionplus=1 if state == 33 & district == 2  & stratum == 31 & sector==2 
replace millionplus=1 if state == 6  & district == 19 & stratum == 20 & sector==2 
replace millionplus=1 if state == 19 & district == 16 & stratum == 19 & sector==2 
replace millionplus=1 if state == 28 & district == 5  & stratum == 24 & sector==2 
replace millionplus=1 if state == 23 & district == 26 & stratum == 46 & sector==2
replace millionplus=1 if state == 8  & district == 12 & stratum == 33 & sector==2 
replace millionplus=1 if state == 27 & district == 21 & stratum == 38 & sector==2 
replace millionplus=1 if state == 9  & district == 34 & stratum == 74 & sector==2 
replace millionplus=1 if state == 19 & district == 17 & stratum == 20 & sector==2 
replace millionplus=1 if state == 9  & district == 27 & stratum == 73 & sector==2 
replace millionplus=1 if state == 3  & district == 9  & stratum == 18 & sector==2 
replace millionplus=1 if state == 9  & district == 7  & stratum == 71 & sector==2 
replace millionplus=1 if state == 27 & district == 22 & stratum == 40 & sector==2 
replace millionplus=1 if state == 27 & district == 9  & stratum == 36 & sector==2 
replace millionplus=1 if state == 27 & district == 20 & stratum == 37 & sector==2 
replace millionplus=1 if state == 10 & district == 28 & stratum == 38 & sector==2 
replace millionplus=1 if state == 27 & district == 25 & stratum == 41 & sector==2
replace millionplus=1 if state == 27 & district == 25 & stratum == 42 & sector==2
replace millionplus=1 if state == 27 & district == 21 & stratum == 39 & sector==2 
replace millionplus=1 if state == 9  & district == 67 & stratum == 75 & sector==2 
replace millionplus=1 if state == 24 & district == 19 & stratum == 27 & sector==2 
replace millionplus=1 if state == 24 & district == 22 & stratum == 28 & sector==2 
replace millionplus=1 if state == 7  & district == 99 & sector==2 

tab	millionplus	if sector==2 [aw=pwt],	m


*** Creating region variable consistent across years

g str3 state_reg1 = string(state_reg,"%03.0f")
g str3 region=substr(state_reg1, 3, 1)
destring region, replace
drop state_reg1 
*drop state_reg

*** Recoding district names to match district codes in NSS 61st (2004/05)

gen district_ii = state*1000 + region*100 + district
label var district_ii "district id code NSS61 (unique code: state+region+district)"

*CHECK FOR NO. OF UNIQUE VALUES\DISTRICTS
codebook district_ii
*597 DISTRICTS IN DATA-FILE. 

* REPLACE DISTRICTS TO MATCH NSS APPENDIX II					   
replace district_ii = 8202  if district_ii == 8102
replace district_ii = 7102  if district_ii == 7198
replace district_ii = 7104  if district_ii == 7199
replace district_ii = 18222 if district_ii == 18122
replace district_ii = 18223 if district_ii == 18123
replace district_ii = 18110 if district_ii == 18210
replace district_ii = 18111 if district_ii == 18211
replace district_ii = 24105 if district_ii == 24205
replace district_ii = 24117 if district_ii == 24317
replace district_ii = 24118 if district_ii == 24318
replace district_ii = 24119 if district_ii == 24319
replace district_ii = 24121 if district_ii == 24321
replace district_ii = 24122 if district_ii == 24322
replace district_ii = 24124 if district_ii == 24324
replace district_ii = 24203 if district_ii == 24403
replace district_ii = 24203 if district_ii == 24303
replace district_ii = 24215 if district_ii == 24115
replace district_ii = 24511 if district_ii == 24211
replace district_ii = 29215 if district_ii == 29415

gen district_nm=district_ii
label var district_nm "District Names"
**RUN DO FILE WITH LABELS FOR 2004-05 CODE BASED DISTRICT NAMES
do "$employment\dist_names.do"

save "$nsso\Dta\constructed\poverty61.dta", replace

erase "$nsso\Dta\constructed\borrar1.dta"

*** Merging individual level dataset

preserve

use "$nsso\Dta\final_datasets\nsso61ce4", clear
destring fsu, replace
destring hamlet, replace
destring sec_stratum, replace
ren sec_stratum secstratum
destring a4, replace
save "$poverty\Output\borrar61.dta", replace

restore 

merge 1:m hhid using "$poverty\Output\borrar61.dta", keepusing(a5 a6 a7 a8 a9 fsu hamlet secstratum a4)

erase "$poverty\Output\borrar61.dta"

tab _m
drop _m

ren a4 indid

drop year
g year=2004

ren a5 relation
ren a6 sex
ren a7 age
ren a8 marital
ren a9 education

destring relation, replace
destring sex, replace
destring age, replace
destring marital, replace
destring education, replace

g 		education_yrs=.
replace education_yrs=0  if  education==1
replace education_yrs=2  if (education==2 | education==3)
replace education_yrs=5  if  education==4
replace education_yrs=8  if education==5
replace education_yrs=10 if (education==6 | education==7)
replace education_yrs=15 if (education==8 | education==10 | education==11)
*replace education_yrs=17 if education==0


g illiterate=(education_yrs==0)
replace illiterate=. if education_yrs==.

g belowprimary=(education_yrs<5)
replace belowprimary=. if education_yrs==.
replace belowprimary=0 if illiterate==1

g primary=(education_yrs==5)
replace primary=. if education_yrs==.

g middle=(education_yrs==8)
replace middle=. if education_yrs==.

g secondary=(education_yrs>8)
replace secondary=. if education_yrs==.

drop education

save "$nsso\Dta\constructed\poverty61_ind.dta", replace


use "$nsso\Dta\constructed\poverty61.dta", replace

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

*BY SECTOR
foreach num of numlist 1/2 {
sum mpce_mrp real_mpce04 [aw=pwt] if sector==`num'
}



****************************************************************************************************
**1993-94
****************************************************************************************************

clear
*global nsso "C:\Users\wb370975\Documents\NSS\NSS-50-Sch1"
global nsso "C:\Users\wb381047.WB\Dropbox\WB_Monica\SASEP\India\NSS\NSS-50-Sch1"

/* */
use "$nsso\Dta\hh-adjustmpce.dta", clear
label var mpce_mrp "MRP: Monthly hhold consumption (0.00)"

ren subsam subsample
ren ownland landown
ren land_totposs landtot_ha
ren src_cook cookmode
ren src_light lightmode
ren house_type dwellingcode
ren income_ration rationcard
ren prnic nic5
ren prnco nco3
   
keep idhhd state region sector stratum subrnd fsu secondstage hhno svy_seq respondent_relation svy_code hhsize mult hhgrp headage headsex mpce_mrp mpce_urp* landown landtot_ha cookmode lightmode dwellingcode rationcard nic5 nco3 hhtype

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
label define sgroup 1 "ST" 2 "SC" 3 "OBC" 9 "Other"
label values sgroup sgroup
replace sgroup=. if sgroup==5
label var sgroup "Social Group"

gen pline=244.1 if state==2      & sector==1
replace pline=285.1 if state==3  & sector==1
replace pline=266.3 if state==4  & sector==1
replace pline=236.1 if state==5  & sector==1
replace pline=229.1 if state==35 & sector==1
replace pline=315.4 if state==31 & sector==1
replace pline=316.2 if state==6  & sector==1
replace pline=279.4 if state==7  & sector==1
replace pline=294.1 if state==8  & sector==1
replace pline=272.7 if state==9  & sector==1
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


replace pline=282 if state==2    & sector==2
replace pline=297.1 if state==3  & sector==2
replace pline=306.8 if state==4  & sector==2
replace pline=266.9 if state==5  & sector==2
replace pline=283.5 if state==35 & sector==2
replace pline=320.3 if state==31 & sector==2
replace pline=306 if state==6    & sector==2
replace pline=320.7 if state==7  & sector==2
replace pline=312.1 if state==8  & sector==2
replace pline=316 if state==9    & sector==2
replace pline=281.1 if state==10 & sector==2
replace pline=304.1 if state==34 & sector==2
replace pline=294.8 if state==11 & sector==2
replace pline=289.2 if state==12 & sector==2
replace pline=274.5 if state==13 & sector==2
replace pline=329 if state==14   & sector==2
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

la var idhhd "Household id"
la var state "State"
la var region "Region"
la var poor "Poor-Tendulkar Mthd"
la var mpce_mrp "MPCE: Mixed Recall(30-365)"
la var mpce_urp "MPCE:Uniform Recall(30)"

order idhhd  state region sector stratum subrnd fsu secondstage hhno svy_seq respondent_relation svy_code hhsize hhwt pwt sgroup headage headsex  mpce_mrp mpce_urp*

xtile dec_mpce = real_mpce93 [aw=pwt], nq(10)

xtile dec_mpce2 = mpce_mrp [aw=pwt], nq(10)
la var dec_mpce2 "Nominal Consumption Deciles"

gen year=1993

gen lis=.
replace lis=1 if inlist(state,5,25,13,21,34,35,19)
replace lis=0 if lis==.
la define lis 0 "Not LIS" 1 "LIS"
la var lis lis

* State coding is different in round 50 compared to waves 61, 66 and 68. This is adjusted to make them comparable.
* Recoding States to 61st, 66th, and 68th state values

*recode state (27=35) (2=28) (3=12) (4=18) (5=10) (28=4) (35=22) (29=26) (30=25) (31=7) (6=30) (7=24) (8=6) (9=2) (10=1) (34=20) (11=29) (12=32) (32=31) (13=23) (14=27) (15=14) (16=17) (17=15) (18=13) (19=21) (33=34) (20=3) (21=8) (22=11) (23=33) (24=16) (25=9) (36=5) (26=19) 

ren state state_50

g 		state=.
replace state=35 if state_50==27
replace state=28 if state_50==2
replace state=12 if state_50==3
replace state=18 if state_50==4
replace state=10 if state_50==5
replace state=4 if state_50==28
replace state=22 if state_50==35
replace state=26 if state_50==29
replace state=25 if state_50==30
replace state=7 if state_50==31
replace state=30 if state_50==6
replace state=24 if state_50==7
replace state=6 if state_50==8
replace state=2 if state_50==9
replace state=1 if state_50==10
replace state=20 if state_50==34
replace state=29 if state_50==11
replace state=32 if state_50==12
replace state=31 if state_50==32
replace state=23 if state_50==13
replace state=27 if state_50==14
replace state=14 if state_50==15
replace state=17 if state_50==16
replace state=15 if state_50==17
replace state=13 if state_50==18
replace state=21 if state_50==19
replace state=34 if state_50==33
replace state=3 if state_50==20
replace state=8 if state_50==21
replace state=11 if state_50==22
replace state=33 if state_50==23
replace state=16 if state_50==24
replace state=9 if state_50==25
replace state=5 if state_50==36
replace state=19 if state_50==26
lab var state "State recoded to 61st, 66th, and 68th state values"

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

la drop state
la val state state

ren idhhd hhid

*2 decimals recorded in landtot_ha
recode landtot_ha .=0              
gen landowned=(landtot_ha>=0.005)
lab var landowned "Household owns land"

g 		landsize=landtot_ha
replace landsize=. if landowned==0
replace landsize=. if landowned==.
replace landsize=0 if (landtot_ha==0 & landowned==1)
replace landsize=. if (landtot_ha==. & landowned==1)
drop 	landtot_ha
lab var landsize "Total land owned in ha"

*g 		cookingelec=0
*replace cookingelec=1 if cookmode==3
*replace cookingelec=1 if cookmode==4
*replace cookingelec=1 if cookmode==8
*replace cookingelec=. if cookmode==.
*drop cookmode
*lab var cookingelec "Primary source of energy for cooking is electricity or gas"

g 		lightelec=0
*replace lightelec=1 if lightmode==3
replace lightelec=1 if lightmode==5
replace lightelec=. if lightmode==.
drop 	lightmode
lab var lightelec "Primary source of energy for lighting is electricity"

g 		dwellingowned=(dwellingcode==1)
replace dwellingowned=. if dwellingcode==.
drop 	dwellingcode
lab var dwellingowned "Dwelling owned by household"

*Salary is only asked for urban households, rural classification does not include a salary category (ins66chap1_f1.doc)
g 		salary=.
lab var salary "At least one household member is regular salary earner"

*Ceremonies is asked in the questionnaire in Block 12 but variable could not be tracked down in raw data
g 		ceremony=.
lab var ceremony "Household performed ceremony during last 30 days"

g 		rationcard1=(rationcard==1)
replace rationcard1=. if rationcard==.
drop 	rationcard
ren 	rationcard1 rationcard


*** Merging budget shares

*Data has not been pre-processed



*** Creating million plus cities dummy for urban sector (27 million plus cities, codes come from documentation)
*** Documentation (Table 4) has an error for three cities (Ludhiana, Indore, Bhopal). This has been corrected below.

generate millionplus=0

replace millionplus=. if sector==1

replace millionplus=1 if sector==2 & (stratum>=6 & stratum<=9)


/*
*Rinku's code used in previous work
gen town_class = 1 if stratum==1
replace town_class=2 if stratum>1 & stratum<6
replace town_class=3 if stratum>5

label define town_class 1 "Small towns" 2 "Medium towns" 3 "Large towns"
label values town_class town_class
/*Note :Town class 1 (< 50K)--> Small; Town class 2 (>=50K & <1 ml)--> Medium; Town class 4 (>1 ml)--> Large*/

gen metro=(town_class==3)
*/


*** Creating region variable consistent across years
*Already created in raw data


*** Recoding district names to match district codes in NSS 61st (2004/05)
*Block 0 data was never released for NSS 50th round so district codes are not available

save "$nsso\Dta\constructed\poverty50.dta", replace


*** Merging individual level dataset

merge 1:m hhid using "$nsso\Dta\block4", keepusing(relation sex age marital gened fsu sector stratum pid)

tab _m
*There are 5 households distrbuted acrss 260 individuals in the individual level dataset that belong to households not present in the household level dataset
drop if _merge==2
drop _m

drop year
g year=1993

ren gened education

ren pid indid

g 		education_yrs=.
replace education_yrs=0  if  education==1
replace education_yrs=2  if (education==2 | education==3 | education==4 | education==5)
replace education_yrs=5  if  education==6
replace education_yrs=8  if education==7
replace education_yrs=10 if (education==8 | education==9)
replace education_yrs=15 if (education==10 | education==11 | education==12 | education==13)
*replace education_yrs=17 if education==0

g illiterate=(education_yrs==0)
replace illiterate=. if education_yrs==.

g belowprimary=(education_yrs<5)
replace belowprimary=. if education_yrs==.
replace belowprimary=0 if illiterate==1

g primary=(education_yrs==5)
replace primary=. if education_yrs==.

g middle=(education_yrs==8)
replace middle=. if education_yrs==.

g secondary=(education_yrs>8)
replace secondary=. if education_yrs==.

drop education

save "$nsso\Dta\constructed\poverty50_ind.dta", replace



use "$nsso\Dta\constructed\poverty50.dta", clear

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

*BY SECTOR
foreach num of numlist 1/2 {
sum mpce_mrp real_mpce93 [aw=pwt] if sector==`num'
}

****************************************************************************************************
** Merging all four waves (household level dataset) into one dataset
****************************************************************************************************

*global nsso "C:\Users\wb370975\Documents\NSS\NSS-50-Sch1"
global nsso "C:\Users\wb381047.WB\Dropbox\WB_Monica\SASEP\India\NSS\NSS-50-Sch1"
use "$nsso\Dta\constructed\poverty50.dta", clear
capture destring(hhid), replace
ren pwt pwt93
keep hhid year real_mpce93 pwt93 state* sector sgroup lis poor pline pline_double pline_ind_93 mpce_mrp landowned landsize lightelec dwellingowned salary ceremony rationcard hhsize region fsu nic5 nco3 hhtype
tempfile mpce93
save `mpce93', replace

*global nsso "C:\Users\wb370975\Documents\NSS\NSS-61-Sch1"
global nsso "C:\Users\wb381047.WB\Dropbox\WB_Monica\SASEP\India\NSS\NSS-61-Sch1"
use "$nsso\Dta\constructed\poverty61.dta", clear
capture destring(hhid), replace
ren pwt pwt04
keep hhid year real_mpce04 pwt04 state sector sgroup lis poor pline pline_double pline_ind_04 mpce_mrp landowned landsize cookingelec lightelec dwellingowned salary ceremony rationcard tv dvd wmachine stove refrigerator appliances motorcycle motorcar laptop mobile hhsize state_reg fsu hamlet secstratum nic5 nco3 hhtype millionplus
tempfile mpce04
save `mpce04', replace

*global nsso "C:\Users\wb370975\Documents\NSS\NSS-66-Sch1-Type1"
global nsso "C:\Users\wb381047.WB\Dropbox\WB_Monica\SASEP\India\NSS\NSS-66-Sch1-Type1"
use "$nsso\Dta\constructed\poverty66.dta", clear
capture destring(hhid), replace
ren pwt pwt09
keep hhid year real_mpce09 pwt09 state sector sgroup lis poor pline pline_double pline_ind_09 mpce_mrp landowned landsize cookingelec lightelec dwellingowned salary ceremony rationcard sdurables seducation sentertainment sfood shealth snonfood srent stobacco tv dvd wmachine stove refrigerator appliances motorcycle motorcar laptop mobile hhsize state_reg fsu hamlet secstratum nic5 nco3 hhtype millionplus
tempfile mpce09
save `mpce09', replace

*global nsso "C:\Users\wb370975\Documents\NSS\NSS-68-Sch1-Type1"
global nsso "C:\Users\wb381047.WB\Dropbox\WB_Monica\SASEP\India\NSS\NSS-68-Sch1-Type1"
use "$nsso\Dta\constructed\poverty68.dta", clear
capture destring(hhid), replace
ren pwt pwt11
keep hhid year real_mpce11 pwt11 state sector sgroup lis poor pline pline_double pline_ind_11 mpce_mrp landowned landsize cookingelec lightelec dwellingowned salary ceremony rationcard sdurables seducation sentertainment sfood shealth snonfood srent stobacco tv dvd wmachine stove refrigerator appliances motorcycle motorcar laptop mobile hhsize state_reg fsu hamlet secstratum nic5 nco3 hhtype millionplus
tempfile mpce11
save `mpce11', replace

use `mpce93', clear
dmerge hhid year using `mpce04'
tab _m
drop _m
dmerge hhid year using `mpce09'
tab _m
drop _m
dmerge hhid year using `mpce11'
tab _m
drop _m

compress
*save "$poverty\Output\cons_series", replace

****************************************************************************************************
** Merging all four waves (individual level dataset) into one dataset
****************************************************************************************************

* Note: it is not necessary to merge dataset by individual ID as these are just appends - plus there is no individual ID created in datasets

global nsso "C:\Users\wb381047.WB\Dropbox\WB_Monica\SASEP\India\NSS\NSS-50-Sch1"
use "$nsso\Dta\constructed\poverty50_ind.dta", clear
tempfile mpce93
save `mpce93', replace

global nsso "C:\Users\wb381047.WB\Dropbox\WB_Monica\SASEP\India\NSS\NSS-61-Sch1"
use "$nsso\Dta\constructed\poverty61_ind.dta", clear
destring hhid, replace
tempfile mpce04
save `mpce04', replace

global nsso "C:\Users\wb381047.WB\Dropbox\WB_Monica\SASEP\India\NSS\NSS-66-Sch1-Type1"
use "$nsso\Dta\constructed\poverty66_ind.dta", clear
destring hhid, replace
tempfile mpce09
save `mpce09', replace

global nsso "C:\Users\wb381047.WB\Dropbox\WB_Monica\SASEP\India\NSS\NSS-68-Sch1-Type1"
use "$nsso\Dta\constructed\poverty68_ind.dta", clear
destring hhid, replace
tempfile mpce11
save `mpce11', replace

use `mpce93', clear
dmerge hhid year using `mpce04'
tab _m
drop _m
dmerge hhid year using `mpce09'
tab _m
drop _m
dmerge hhid year using `mpce11'
tab _m
drop _m

* Labeling the State variable across waves

la drop state
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
la val state state

* Error in MP regional code
replace region=1 if region==2 & year==1993 & state==23
replace region=2 if region==3 & year==1993 & state==23
replace region=3 if region==4 & year==1993 & state==23
replace region=4 if region==5 & year==1993 & state==23
replace region=5 if region==6 & year==1993 & state==23
replace region=6 if region==7 & year==1993 & state==23
lab var region "Region variable consistent across years"

compress

replace substratum=sub_stratum if year==2004
drop sub_stratum

/*
*Different sampling frane in 1993 so no substrata available
g substratum_93=subsample if year==1993
drop subsample
lab var substratum_93 "Different sampling frame, no substratum but subsample"
*/

drop secondstage sub_round sub_sample subrnd subround svy_code svy_seq subsample

order year hhid indid hhwt pwt state region district sector stratum fsu relation nic5 nco3 hhtype 

sort year state region district sector stratum hhid indid state_50

save "$poverty\Output\dataprep_ind", replace







