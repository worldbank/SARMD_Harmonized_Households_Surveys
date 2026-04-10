clear

set mem 300m

local DataOrig "C:\Labor Flagship\BHUTAN\Bhutan 2003\Data\DataOrig"
local DataProc "C:\Labor Flagship\BHUTAN\Bhutan 2003\Data\DataProc"
local DataWaste "C:\Labor Flagship\BHUTAN\Bhutan 2003\Data\DataWaste"

use "`DataOrig'\DataOrig.dta", clear 

**************************************************************

gen str3 COUNTRY="BTN"

**************************************************************

gen YEAR=2003

**************************************************************
destring houseid_str , generate(HID)

format HID %10.0f


**************************************************************

cap gen INDID =  idno

*destring indid_str , generate(INDID)
*format INDID %12.0f


**************************************************************

gen REGION=  dzongkha

label values REGION dzongkha

cap gen REGION_broad = dzongkha 
recode REGION_broad (11 12 13 14 15 16 41 = 1) (17 21 22 23  42 43 44 = 2) (31 32 33 34 35 36 = 3), gen(region) 
cap label define region_broad 1 "Western" 2 "Central" 3 "Eastern" 
label values REGION_broad region_broad 


************************************************************

gen URBAN=.

replace URBAN=0 if stratum==2

replace URBAN=1 if stratum==1

label define urban 0 "Rural" 1 "Urban"

label values URBAN urban

************************************************************

gen MALE=.

replace MALE=0 if b21_q1==2

replace MALE=1 if b21_q1==1

label define male 0 "Female" 1 "Male"

label values MALE male

************************************************************

gen AGEY= b21_q3ag

replace AGEY=98 if b21_q3ag>98 & b21_q3ag<.

************************************************************

gen HEAD=0

replace HEAD=1 if  b21_q2==1

label define head 0 "Not head" 1 "Head of hh"

label values HEAD head

***********************************************************

gen HEAD_UNIQUE=HEAD

label values HEAD_UNIQUE head

**********************************************************

drop if   b21_q2==12 |   b21_q2==13

*Live-in servants and other non-relatives dropped from dataset
*232 obs dropped

by HID, sort: gen HHSIZE=_N

***********************************************************

gen ETHNICITY=.

***********************************************************

gen LANGUAGE=.

************************************************************

gen RELIGION=.

************************************************************

gen MARSTAT=.

replace MARSTAT=1 if b21_q4==2
replace MARSTAT=2 if b21_q4==1
replace MARSTAT=5 if b21_q4==3 | b21_q4==4
replace MARSTAT=6 if b21_q4==5



label define marstat_label 1 "Never Married"
label define marstat_label 2 "Married Monogamous", add
label define marstat_label 3 "Married Polygamous", add
label define marstat_label 4 "Common Law,Living Together,Union Coutumiere,Union Libre", add
label define marstat_label 5 "Divorced/Separated", add
label define marstat_label 6 "Widowed", add

label values MARSTAT marstat_label

************************************************************
gen ATTENDED_SCHOOL=.

replace ATTENDED_SCHOOL=0 if b22_q8==2
replace ATTENDED_SCHOOL=1 if b22_q8==1

label define attendedschool 0 "Not attended school" 1 "Attended school"
label values ATTENDED_SCHOOL attendschool

*************************************************************************

gen EDLEVEL=.

replace EDLEVEL=0 if b22_q8==2

replace EDLEVEL=1 if  (b22_q10==0 |  b22_q10==1 |  b22_q10==2 |  b22_q10==3 |  b22_q10==4 |  b22_q10==5 |  b22_q10==6) & b22_q9==1
replace EDLEVEL=1 if  (b22_q16==0 |  b22_q16==1 |  b22_q16==2 |  b22_q16==3 |  b22_q16==4 |  b22_q16==5)  & b22_q9==2

replace EDLEVEL=2 if  (b22_q10==7 |  b22_q10==8 |  b22_q10==9 |  b22_q10==10)  & b22_q9==1
replace EDLEVEL=2 if  (b22_q16==6 | b22_q16==7 |  b22_q16==8 |  b22_q16==9)   & b22_q9==2

replace EDLEVEL=3 if  (b22_q10==11 |  b22_q10==12) & b22_q9==1
replace EDLEVEL=3 if  (b22_q16==10 | b22_q16==11)  & b22_q9==2

replace EDLEVEL=4 if  (b22_q10==13 |  b22_q10==14 |  b22_q10==15)    & b22_q9==1
replace EDLEVEL=4 if  (b22_q16==12 | b22_q16==13 |  b22_q16==14 |  b22_q16==15)     & b22_q9==2

label define edlevelv 0 "No Education"
label define edlevelv 1 "Some Education, less than Primary", add
label define edlevelv 2 "Completed Primary, less than Lower Secondary", add
label define edlevelv 3 "Completed Lower Secondary, less than Senior Secondary", add
label define edlevelv 4 "Completed Senior Secondary or above", add

label values EDLEVEL edlevelv

***************************************************************

gen EDYEARS=.

replace EDYEARS=0 if  b22_q10==00 |  b22_q10==01 | b22_q16==00
replace EDYEARS=1 if  b22_q10==02  | b22_q16==01
replace EDYEARS=2 if  b22_q10==03 | b22_q16==02
replace EDYEARS=3 if  b22_q10==04 | b22_q16==03
replace EDYEARS=4 if  b22_q10==05 | b22_q16==04
replace EDYEARS=5 if  b22_q10==06 | b22_q16==05
replace EDYEARS=6 if  b22_q10==07 | b22_q16==06
replace EDYEARS=7 if  b22_q10==08 | b22_q16==07
replace EDYEARS=8 if  b22_q10==09 | b22_q16==08
replace EDYEARS=9 if  b22_q10==10 | b22_q16==09
replace EDYEARS=10 if  b22_q10==11 | b22_q16==010
replace EDYEARS=11 if  b22_q10==12 | b22_q16==011
replace EDYEARS=12 if  b22_q10==13 | b22_q16==012
replace EDYEARS=13 if  b22_q10==14 | b22_q16==013
replace EDYEARS=14 if  b22_q10==15 | b22_q16==014
replace EDYEARS=15 if  b22_q16==015
replace EDYEARS = 0 if b22_q8==2 & mi(EDYEARS)

****************************************************************************************
gen CONEDYEARS=.
replace CONEDYEARS=EDYEARS

local i = 1
while `i'<25 {
replace CONEDYEARS = `i' if AGEY == (`i'+4) & EDYEARS > `i' & EDYEARS~=.
local i = `i'+1
}
replace CONEDYEARS = 0 if b22_q8==2 & mi(CONEDYEARS)

*******************************************************************************************

*conedlevel
gen CONEDLEVEL=.
replace CONEDLEVEL=EDLEVEL
replace CONEDLEVEL = 1 if CONEDYEARS > 0 & CONEDYEARS <=5
replace CONEDLEVEL = 2 if CONEDYEARS >=6 & CONEDYEARS <10
replace CONEDLEVEL = 3 if CONEDYEARS >=10 & CONEDYEARS <12
replace CONEDLEVEL = 4 if CONEDYEARS >=12 & CONEDYEARS <.

label values CONEDLEVEL edlevelv

****************************************************************************************

gen emp_stat = .  
replace emp_stat = 1 if inlist(1,  b24_q33w, b24_q34w, b24_q35w)
replace emp_stat = 2 if  inlist(b24_q37, 1, 2) & mi(emp_stat )
replace emp_stat = 2 if  b24_q36==1 & mi(emp_stat)
replace emp_stat = 3 if inlist(b24_q37, 4) & mi(emp_stat)
replace emp_stat = 4 if mi(emp_stat) & AGEY>=10
replace emp_stat = . if AGEY<10 

gen EMP_STAT = emp_stat

label define emp_stat_label 1 "Employed" 2 "Unemployed" 3 "Discouraged" 4 "Inactive"
label values EMP_STAT emp_stat_label

**********************************************************

tokenize "EMPLOYED UNEMPLYD DISCRGD INACTIVE"
forval i = 1/4{
	gen ``i'' = EMP_STAT==`i' if !mi(EMP_STAT)
}


label define employed 0 "Not employed" 1 "Employed"
label values EMPLOYED employed

label define unemployed 0 "Not unemployed" 1 "Unemployed"
label values UNEMPLYD unemployed

label define discouraged 0 "Not discouraged" 1 "Discouraged"
label values DISCRGD discouraged

label define inactive 0 "Not inactive" 1 "Inactive"
label values INACTIVE inactive

*****************************************************************************************


gen EMP_STAT_CHILD=.

replace EMP_STAT_CHILD=2 if UNEMPLYD==1
replace EMP_STAT_CHILD=2 if UNEMPLYD==2 & (b24_q37==1 | b24_q37==2)

replace EMP_STAT_CHILD=4 if UNEMPLYD==2 & EMP_STAT!=2

replace EMP_STAT_CHILD=1 if EMPLOYED==1
replace EMP_STAT_CHILD=. if AGEY>14


***************************************************************

gen WHYINACTIVE=.
replace WHYINACTIVE= b24_q37 if EMP_STAT==4

//some people who reported themselves as employed and also inactive, 
//have only been considered employed and not included in the above variable.

label define whyinactive 01 "Waiting for a job to start"
label define whyinactive 02 "Awaiting employer's reply", add
label define whyinactive 03 "Waiting for seasonal work", add
label define whyinactive 04 "No job available", add
label define whyinactive 05 "Studying", add
label define whyinactive 06 "Taking care of home", add
label define whyinactive 07 "Waiting for a job to start", add
label define whyinactive 08 "Too old or disabled", add
label define whyinactive 09 "Not healthy", add
label define whyinactive 10 "Doesn't want to work", add
label define whyinactive 11 "Other", add

label values WHYINACTIVE whyinactive

****************************************************************************************

gen AGE_CATEG=.

replace AGE_CATEG=1 if AGEY>=0 & AGEY<=10
replace AGE_CATEG=2 if AGEY>=11 & AGEY<=20
replace AGE_CATEG=3 if AGEY>=21 & AGEY<=30
replace AGE_CATEG=4 if AGEY>=31 & AGEY<=40
replace AGE_CATEG=5 if AGEY>=41 & AGEY<=50
replace AGE_CATEG=6 if AGEY>=51 & AGEY<=60
replace AGE_CATEG=7 if AGEY>=61 & AGEY<=70
replace AGE_CATEG=8 if AGEY>=71 & AGEY<=80
replace AGE_CATEG=9 if AGEY>=81 & AGEY<=90
replace AGE_CATEG=10 if AGEY>=91 & AGEY<=100

label define age_categ 1 "0-10"
label define age_categ 2 "11-20" , add
label define age_categ 3 "21-30", add
label define age_categ 4 "31-40", add
label define age_categ 5 "41-50", add
label define age_categ 6 "51-60", add
label define age_categ 7 "61-70", add
label define age_categ 8 "71-80", add
label define age_categ 9 "81-90", add
label define age_categ 10 "91-100", add
label values AGE_CATEG age_categ
********************************************************************

gen SECTOR_MAIN=.

replace SECTOR_MAIN=1 if  b24_q40==1
replace SECTOR_MAIN=2 if  b24_q40==2
replace SECTOR_MAIN=3 if  b24_q40==3
replace SECTOR_MAIN=4 if  b24_q40==4
replace SECTOR_MAIN=5 if  b24_q40==5
replace SECTOR_MAIN=6 if  b24_q40==6 | b24_q40==7
replace SECTOR_MAIN=7 if  b24_q40==8
replace SECTOR_MAIN=8 if  b24_q40==9 | b24_q40==10
replace SECTOR_MAIN=9 if  b24_q40==11
replace SECTOR_MAIN=10 if  b24_q40==12 | b24_q40==13 | b24_q40==14 

replace SECTOR_MAIN=. if AGEY<15

label define sector_label 1 "Agriculture and Fishing"
label define sector_label 2 "Mining", add
label define sector_label 3 "Manufacturing", add
label define sector_label 4 "Electricity and Utilities", add
label define sector_label 5 "Construction", add
label define sector_label 6 "Commerce", add
label define sector_label 7 "Transportation, Storage and Communication", add
label define sector_label 8 "Financial, Insurance and Real Estate", add
label define sector_label 9 "Public Administration", add
label define sector_label 10 "Other Services", add
label define sector_label 11 "Unspecified", add

label values SECTOR_MAIN sector_label
*************************************************************

gen OCC_MAIN=.

gen str3 occmain= string(  b24_q39,"%03.0f") 

gen occmain_str=substr(occmain,1,2) 

drop occmain

destring occmain_str, generate(occmain)


replace OCC_MAIN=10 if occmain==1

replace OCC_MAIN=1 if occmain==11 | occmain==12 | occmain==13

replace OCC_MAIN=2 if occmain==21 | occmain==22 | occmain==23 | occmain==24

replace OCC_MAIN=3 if occmain==31 | occmain==32 | occmain==33 | occmain==34

replace OCC_MAIN=4 if occmain==41 | occmain==42 

replace OCC_MAIN=5 if occmain==51 | occmain==52 

replace OCC_MAIN=6 if occmain==61 | occmain==62 

replace OCC_MAIN=7 if occmain==71 | occmain==72 | occmain==73 | occmain==74

replace OCC_MAIN=8 if occmain==81 | occmain==82 | occmain==83 | occmain==88

replace OCC_MAIN=9 if occmain==91 | occmain==92 | occmain==93 

replace OCC_MAIN=99 if occmain==97 | occmain==98 | occmain==99 


replace OCC_MAIN=. if AGEY<15


label define occupation_label 1 "Legislators, Senior Officials, Managers"
label define occupation_label 2 "Professionals", add
label define occupation_label 3 "Technicians and Associate Professionals", add
label define occupation_label 4 "Clerks", add
label define occupation_label 5 "Service Workers and Shop and Market Sales", add
label define occupation_label 6 "Skilled Agricultural and Fishery Workers", add
label define occupation_label 7 "Craft and Related Trades", add
label define occupation_label 8 "Plant and Machine Operators and Assemblers", add
label define occupation_label 9 "Elementary Occupations", add
label define occupation_label 10 "Armed Forces", add
label define occupation_label 99 "Other/Unspecified", add

label values OCC_MAIN occupation_label

**************************************************************************
gen PUBLIC=.

replace PUBLIC=0 if b24_q41!=.

replace PUBLIC=1 if b24_q41== 1 | b24_q41==2

replace PUBLIC=. if OCC_MAIN==.

replace PUBLIC=. if AGEY<15

label define public_label 0 "Not Public Employee" 1 "Public Employee"

label values PUBLIC public_label

***************************************************************************

gen EMPTYPE_MAIN=.

replace EMPTYPE_MAIN=1 if  b24_q38==1 |  b24_q38==2 
replace EMPTYPE_MAIN=2 if  b24_q38==4
replace EMPTYPE_MAIN=3 if  b24_q38==3
replace EMPTYPE_MAIN=4 if  b24_q38==5 |  b24_q38==6

replace EMPTYPE_MAIN =. if OCC_MAIN==.
replace EMPTYPE_MAIN=. if AGEY<15


*employees and members of a cooperative included in this
label define emptype_main_label 1 "Wage and Salaried Worker"
label define emptype_main_label 2 "Employer", add
label define emptype_main_label 3 "Individual Self-employed Worker", add

*collective farmer and family workers considered here. No other types mentioned in dataset.
label define emptype_main_label 4 "Household Enterprise Worker", add

label values EMPTYPE_MAIN emptype_main_label

****************************************************************************
gen SECONDJOB=.

replace SECONDJOB=0 if b24_q42==2

replace SECONDJOB=1 if  b24_q42==1

replace SECONDJOB=. if  EMPLOYED!=1

label define secondjob_label 0 "No Second Job" 1 "Have Second Job"

label values SECONDJOB secondjob_label 

****************************************************************************

gen NUMJOBS12MO=.

******************************************************************************

#delimit ;

cap gen EMPTYPE_SECOND = . ; 
recode b24_q43 (1 2 = 1) (3 = 3) (4 = 2) (5 6 = 4) (nonmiss = .), gen(emptype_sec); 
replace EMPTYPE_SECOND = emptype_sec if SECONDJOB==1; drop emptype_sec; 

cap gen SECTOR_SECOND = .; 
recode b24_q45 (6 7 = 6) (8 = 7) (9 10 = 8) (11 = 9) (12/14 = 10), gen(sector_sec); 
replace SECTOR_SECOND = sector_sec if SECONDJOB==1; drop sector_sec; 

#delimit cr


*********************************************************************************

*ag_wrk_main is the main job is agriculture and fisheries

gen AG_WRK_MAIN=.

replace AG_WRK_MAIN=1 if SECTOR_MAIN==1

replace AG_WRK_MAIN=0 if SECTOR_MAIN!=1 & SECTOR_MAIN!=.

label define agriwork_label 0 "Main Job not in Agriculture/Fisheries" 1 "Main Job in Agriculture/Fisheries"

label values AG_WRK_MAIN agriwork_label 

gen CASUAL_OR_WAGE=.

#delimit ;
cap gen INFORMAL =.; 
cap gen FORMAL = .; 
replace FORMAL = .; 
replace INFORMAL = .; 

gen informal = 1 if EMPTYPE_MAIN==4; 
replace informal = inlist(CONEDLEVEL, 0, 1, 2, 3) if EMPTYPE_MAIN==3; 
replace informal = 1 if CASUAL_OR_WAGE==1 & EMPTYPE_MAIN==1;
replace informal = 0 if PUBLIC ==1 & EMPTYPE_MAIN==1;
replace informal = 1 if AG_WRK_MAIN==1; 

replace INFORMAL = informal==1 if EMPLOYED==1;
replace FORMAL = informal==0 if EMPLOYED==1; 
drop informal; 

#delimit cr


****************************************************************

* tab b24_q47m
* 0.72% respondents stated the total working hours to exceed 96 per week

cap gen HOURWRKMAIN = .
cap gen HOURWRKMAIN_week = .
cap gen HOURWRKMAIN_mon =.
cap gen HOURWRKTOT = .
cap gen HOURWRKTOT_week = .
cap gen HOURWRKTOT_mon =.
cap gen HOURWRKSEC = .
cap gen HOURWRKSEC_week = .
cap gen HOURWRKSEC_mon =.


gen hoursmain=.
replace hoursmain=  b24_q47m

gen hourssec=.
replace hourssec=  b24_q47s

egen tothours = rowtotal(hoursmain hourssec), mi
replace tothours=hoursmain if hoursmain!=. & hourssec==.


replace HOURWRKMAIN_week = hoursmain
replace HOURWRKMAIN_week = 96*(b24_q47m/tothours) if tothours > 96 & tothours<. & !mi(HOURWRKMAIN_week)
replace HOURWRKMAIN_week = . if EMPLOYED==0
replace HOURWRKMAIN = HOURWRKMAIN_week*52 
replace HOURWRKMAIN_mon = HOURWRKMAIN_week*52/12

replace HOURWRKSEC_week = hourssec
replace HOURWRKSEC_week = 96*(b24_q47s/tothours) if tothours > 96 & tothours<. & !mi(HOURWRKSEC_week)
replace HOURWRKSEC_week = . if EMPLOYED==0
replace HOURWRKSEC_week = . if SECONDJOB !=1
replace HOURWRKSEC = HOURWRKSEC_week*52 
replace HOURWRKSEC_mon = HOURWRKSEC_week*52/12

replace HOURWRKTOT_week = tothours
replace HOURWRKTOT_week = 96 if tothours > 96 & tothours<. & !mi(HOURWRKTOT_week)
replace HOURWRKTOT_week = . if EMPLOYED==0
replace HOURWRKTOT = HOURWRKTOT_week*52
replace HOURWRKTOT_mon = HOURWRKTOT_week*52/12

drop hoursmain hourssec tothours

********************************************************************

gen HOURWRKTYPE=.

replace HOURWRKTYPE=1 if HOURWRKMAIN!=.

label define hourwrktype 1 "Last week" 

label values HOURWRKTYPE hourwrktype



*******************************************************************
************************DEFLATORS**********************************
*******************************************************************

/*
* Codes to generate paachse index at district level by rural and urban and save as a different file.

preserve
gen count =1
collapse (mean) paachse (sum) pop=count [iw=weight], by( dzongkha stratum)
sum paachse [aw=pop]
gen natl_base = r(mean)
gen spatialdef_dzongkha = paachse/natl_base
rename paachse paachse_dzongkha 
sort dzongkha stratum
save "`DataWaste'\spat_def_btn, replace
restore

*/

* SPATIAL/REGIONAL Deflators are median of household-level Paasche indices from Bhutan Poverty Analysis Report 2003.

gen SPATIALDEF = .

replace SPATIALDEF = 0.96 if REGION==11 & URBAN==1
replace SPATIALDEF = 0.91 if REGION==11 & URBAN==0
replace SPATIALDEF = 1.03 if REGION==12 & URBAN==1
replace SPATIALDEF = 0.98 if REGION==12 & URBAN==0
replace SPATIALDEF = 1.07 if REGION==13 & URBAN==1
replace SPATIALDEF = 1.04 if REGION==13 & URBAN==0
replace SPATIALDEF = 1.11 if REGION==14 & URBAN==1
replace SPATIALDEF = 1.07 if REGION==14 & URBAN==0
replace SPATIALDEF = 1.06 if REGION==15 & URBAN==1
replace SPATIALDEF = 1.04 if REGION==15 & URBAN==0
replace SPATIALDEF = 1.06 if REGION==16 & URBAN==1
replace SPATIALDEF = 0.99 if REGION==16 & URBAN==0
replace SPATIALDEF = 1.06 if REGION==17 & URBAN==1
replace SPATIALDEF = 1.01 if REGION==17 & URBAN==0
replace SPATIALDEF = 1.26 if REGION==21 & URBAN==1
replace SPATIALDEF = 1.16 if REGION==21 & URBAN==0
replace SPATIALDEF = 1.14 if REGION==22 & URBAN==1
replace SPATIALDEF = 1.02 if REGION==22 & URBAN==0
replace SPATIALDEF = 1.08 if REGION==23 & URBAN==1
replace SPATIALDEF = 0.96 if REGION==23 & URBAN==0
replace SPATIALDEF = 1.09 if REGION==31 & URBAN==1
replace SPATIALDEF = 0.98 if REGION==31 & URBAN==0
replace SPATIALDEF = 1.07 if REGION==32 & URBAN==1
replace SPATIALDEF = 0.97 if REGION==32 & URBAN==0
replace SPATIALDEF = 1.14 if REGION==33 & URBAN==1
replace SPATIALDEF = 0.99 if REGION==33 & URBAN==0
replace SPATIALDEF = 1.12 if REGION==34 & URBAN==1
replace SPATIALDEF = 0.99 if REGION==34 & URBAN==0
replace SPATIALDEF = 1.05 if REGION==35 & URBAN==1
replace SPATIALDEF = 0.89 if REGION==35 & URBAN==0
replace SPATIALDEF = 0.94 if REGION==36 & URBAN==1
replace SPATIALDEF = 0.94 if REGION==36 & URBAN==0
replace SPATIALDEF = 0.90 if REGION==41 & URBAN==1
replace SPATIALDEF = 0.82 if REGION==41 & URBAN==0
replace SPATIALDEF = 0.93 if REGION==42 & URBAN==1
replace SPATIALDEF = 0.93 if REGION==42 & URBAN==0
replace SPATIALDEF = 1.00 if REGION==43 & URBAN==1
replace SPATIALDEF = 1.00 if REGION==43 & URBAN==0
replace SPATIALDEF = 1.08 if REGION==44 & URBAN==1
replace SPATIALDEF = 1.05 if REGION==44 & URBAN==0


******PREVIOUS*****
*gen cpi2005=119.14    
*gen cpi2003=108.18    
*gen PPP05=18.464

****WDI****
gen cpi2005 = 100
gen cpi2003 = 90.78516903

cap gen PPP05DEFLATOR = 18.464*(cpi2003/cpi2005)
*PPP05 from 2005 WDI

drop cpi2005 cpi2003

gen LCU05DEFLATOR =  1 /18.464


**************************************************************************************
************************GENERATING INCOME VARIABLES***********************************
**************************************************************************************

cap gen INCOME_MAIN_mon_PPP05 = .
cap gen INCOME_SEC_mon_PPP05 = .
cap gen INCOME_TOT_mon_PPP05 = .
cap gen HHINCOME_TOT_mon_PPP05 = .
*Info about income amount is not included in the survey

*Convert monthly incomes to monthly PPP incomes
foreach v in INCOME_MAIN_mon_PPP05 INCOME_TOT_mon_PPP05 HHINCOME_TOT_mon_PPP05 {
	replace `v' = `v' /SPATIALDEF
	qui summ `v', d
	replace `v' = r(p50) if !inrange(`v', r(p50) - 3*r(sd), r(p50) + 3*r(sd)) & !mi(`v')
	replace `v' = `v'/PPP05DEFLATOR
	}
	
*Create local currency variations

foreach v in INCOME_MAIN INCOME_TOT HHINCOME_TOT {
	foreach y in _mon_def _week_def _def _mon_PPP05 _week_PPP05 _PPP05 _mon_LCU05 _week_LCU05 _LCU05 {
		cap gen `v'`y' = .
		}
		
		replace `v'_mon_def = `v'_mon_PPP05 * PPP05DEFLATOR	
		replace `v'_week_def = `v'_mon_PPP05 * PPP05DEFLATOR * 12/52
		replace `v'_def = `v'_mon_PPP05 * PPP05DEFLATOR * 12
		
		*********************Create PPP variations
		foreach y in _week _mon "" {
			replace `v'`y'_PPP05 = `v'`y'_def/PPP05DEFLATOR
			}
		
		**********************Create Local Currency (2005 prices) variations
		foreach y in _week _mon "" {
			replace `v'`y'_LCU05 = `v'`y'_PPP05/LCU05DEFLATOR
			}
		}			
		
***************************************************************************************
cap generate NONLBRINC_mon_def=.
cap generate XNONLBRINC_mon_def = .
cap generate NONLBRINC_def = .
cap generate XNONLBRINC_def = .
cap generate NONLBRINC_PPP05 = .
cap generate XNONLBRINC_PPP05 = .

cap generate XINCOME_MAIN_mon_def=.
cap generate XINCOME_MAIN_def=.
cap generate XINCOME_MAIN_PPP05=.
cap generate XINCOME_TOT_mon_def=.
cap generate XINCOME_TOT_def=.
cap generate XINCOME_TOT_PPP05 =.

*imp_fm_rent_def : implicit farm rental value
cap generate IMP_FM_RENT_def=.
cap generate IMP_FM_RENT_mon_def=.

*Above INCOME variables are not relevant for BLSS 2003
		
****************************************************************


generate adeq = 1 if HEAD==1
replace adeq = .5 if AGEY>=15 & mi(adeq)
replace adeq = .3 if AGEY<15 & mi(adeq)
egen ADEQ = sum(adeq), by(HID)
tab ADEQ
drop adeq


********************************************************************
************GENERATING CONSUMPTION VARIABLES************************
********************************************************************

gen _CONSUMPTION_ = .

cap gen TOTCONS_def = .
cap gen CONS_PC_def = .
cap gen CONS_PEQA_def = .
cap gen TOTCONS_mon_def	= .
cap gen CONS_PC_mon_def = .
cap gen CONS_PEQA_mon_def = .
cap gen TOTCONS_mon_PPP05  = .
cap gen CONS_PC_mon_PPP05 = .
cap gen CONS_PEQA_mon_PPP05 = .


replace TOTCONS_def = hhc_t_mo

replace TOTCONS_def = TOTCONS_def/SPATIALDEF
replace CONS_PC_def = TOTCONS_def/HHSIZE
replace CONS_PEQA_def = TOTCONS_def/ADEQ

foreach v in CONS_PC_def CONS_PEQA_def {
	qui summ `v', d
	replace `v' = r(p50) if !inrange(`v', r(p50) - 3*r(sd), r(p50) + 3*r(sd)) & !mi(`v')
	replace `v' = `v' * 12
}

replace TOTCONS_def = CONS_PC_def * HHSIZE

foreach v in TOTCONS CONS_PC CONS_PEQA {
	cap gen `v'_PPP05 = .
	cap gen `v'_LCU05 = .
	replace `v'_PPP05 = `v'_def/PPP05DEFLATOR
	replace `v'_LCU05 = `v'_PPP05/LCU05DEFLATOR
}			


***********************************************************************
***************GENERATING POVERTY LINES********************************
***********************************************************************

cap gen REGPLINE_ann = povline_month*12
cap gen REGPLINE_mon = povline_month
cap gen EXTPLINE_ann = povline_month*12
cap gen EXTPLINE_mon = povline_month
cap gen INTPLINE_ann = 1.25*PPP05DEFLATOR*365
cap gen INTPLINE_mon = 1.25*PPP05DEFLATOR*365/12

cap gen REGPLINE_ann_PPP05 = REGPLINE_ann /PPP05DEFLATOR
cap gen REGPLINE_mon_PPP05 = REGPLINE_mon /PPP05DEFLATOR
cap gen EXTPLINE_ann_PPP05 = EXTPLINE_ann /PPP05DEFLATOR
cap gen EXTPLINE_mon_PPP05 = EXTPLINE_mon /PPP05DEFLATOR
cap gen INTPLINE_ann_PPP05 = INTPLINE_ann /PPP05DEFLATOR
cap gen INTPLINE_mon_PPP05 = INTPLINE_mon /PPP05DEFLATOR


cap gen REGPLINE_ann_LCU05 = REGPLINE_ann_PPP05/LCU05DEFLATOR
cap gen REGPLINE_mon_LCU05 = REGPLINE_mon_PPP05/LCU05DEFLATOR
cap gen EXTPLINE_ann_LCU05 = EXTPLINE_ann_PPP05/LCU05DEFLATOR
cap gen EXTPLINE_mon_LCU05 = EXTPLINE_mon_PPP05/LCU05DEFLATOR
cap gen INTPLINE_ann_LCU05 = INTPLINE_ann_PPP05/LCU05DEFLATOR
cap gen INTPLINE_mon_LCU05 = INTPLINE_mon_PPP05/LCU05DEFLATOR

***********************************************************************

cap generate STRATA = .

cap generate PSU =  .

cap generate WEIGHT = weight

cap generate YEAR_def = 2003



*****************************************************************************
**************************************************************************************
**************************************************************************************
**************************************************************************************
**************************************************************************************
**************************************************************************************
**************************************************************************************
*********************************DAVID'S VARIABLES************************************
**************************************************************************************
**************************************************************************************
**************************************************************************************
**************************************************************************************
**************************************************************************************
**************************************************************************************



gen EDLEVEL_VT=.

****************************************************************************************
gen TRAINING=.

replace TRAINING=b22_q17

label values TRAINING b22_q17
****************************************************************************************
gen SCHOOL_LEAVE=.

***************************************************************************************
gen CURRENT_ATTEND=.

*currently attending

gen current_attend = 0 if !mi(b22_q8)
replace current_attend = 1 if  b22_q9==1

replace CURRENT_ATTEND = current_attend




label define current_attend_label 0 "Currently Not Attending"
label define current_attend_label 1 "Currently Attending", add

label values CURRENT_ATTEND current_attend_label 

cap drop current_attend emp_stat

**************************************************************************************

gen DURATION_UNEMP=.

**************************************************************************************



gen AGE_CATEG3=.

replace AGE_CATEG3=0 if AGEY>=0 & AGEY<15

replace AGE_CATEG3=1 if AGEY>=15 & AGEY<=65

replace AGE_CATEG3=2 if AGEY>65 & AGEY<.

label define age_categ_label 0 "0-14 yrs" 1 "15-65 yrs" 2 ">65 yrs"

label values AGE_CATEG3 age_categ_label 

***************************************************************************************
* no_adult=1 if age is between 15 and 65; 0 if not
by HID, sort: egen NO_ADULT = sum(AGEY >= 15 & AGEY <= 64)

***************************************************************************************
* no_children=1 if age is between 0 and 14; 0 if not
by HID, sort: egen NO_CHILDREN = sum(AGEY >= 0 & AGEY <= 14)

***************************************************************************************
* no_elderly=1 if age>65; 0 if not
by HID, sort: egen NO_ELDERLY = sum(AGEY >= 65 & AGEY < .)

*************************************************************************************

gen ENROL_CHILDREN=. 

replace ENROL_CHILDREN = CURRENT_ATTEND if inrange(AGEY, 5, 14)

label define enrol_children_label 0 "Not Enrolled" 1 "Enrolled"

label values ENROL_CHILDREN enrol_children_label 
*************************************************************************************
gen REASON_NOT_ATTENDING=.

replace REASON_NOT_ATTENDING=b22_q20

label values  REASON_NOT_ATTENDING b22_q20



*********************************************************************************


gen SCHOOL_DIST=.

replace SCHOOL_DIST=b22_q12

label values SCHOOL_DIST b22_q12


*In terms of time taken to reach

*************************************************************************************



gen SOCIAL_SECURITY=.


***************************************************************************

gen HH_DUTIES=.

gen EMPSTAT_HH=.

gen EMPTYPE_MAIN_EXTENDED =.

*******************************************************************************
 cap drop  indid_str idno_str merge7 merge6 merge5 merge3 merge2 houseid_str houseno_str block_str town_str dzongkha_str stratum_str hhvar tothours hourssec hoursmain occmain occmain_str unemployed employed employed3 employed2 employed1

*compress

*******************************************************************************************


gen EDLEVEL_DAVID=.

*No info. on those that didn't get educated.

replace EDLEVEL_DAVID=0 if b22_q8==2

replace EDLEVEL_DAVID=1 if  (b22_q10==0 |  b22_q10==1 |  b22_q10==2 |  b22_q10==3 |  b22_q10==4 |  b22_q10==5 |  b22_q10==6) & b22_q9==1
replace EDLEVEL_DAVID=1 if  (b22_q16==0 |  b22_q16==1 |  b22_q16==2 |  b22_q16==3 |  b22_q16==4 |  b22_q16==5)  & b22_q9==2



replace EDLEVEL_DAVID=2 if  (b22_q10==7 |  b22_q10==8 |  b22_q10==9 |  b22_q10==10 | b22_q10==11 |  b22_q10==12)  & b22_q9==1
replace EDLEVEL_DAVID=2 if  (b22_q16==6 | b22_q16==7 |  b22_q16==8 |  b22_q16==9 | b22_q16==10 | b22_q16==11)   & b22_q9==2



replace EDLEVEL_DAVID=3 if  (b22_q10==13 |  b22_q10==14) & b22_q9==1
replace EDLEVEL_DAVID=3 if  (b22_q16==12)  & b22_q9==2

 

replace EDLEVEL_DAVID=4 if  (b22_q10==15)    & b22_q9==1
replace EDLEVEL_DAVID=4 if  (b22_q16==13 |  b22_q16==14 |  b22_q16==15)     & b22_q9==2


label define edlevelv_DAVID 0 "No Education"
label define edlevelv_DAVID 1 "Some Education, less than Primary", add
label define edlevelv_DAVID 2 "Completed Primary, less than Lower Secondary", add
label define edlevelv_DAVID 3 "Completed Senior Secondary, less than Tertiary", add
label define edlevelv_DAVID 4 "Completed Tertiary or above", add


label values EDLEVEL_DAVID edlevelv_DAVID


*******************************************************************************************

*conedlevel
gen CONEDLEVEL_DAVID=.
replace CONEDLEVEL_DAVID=EDLEVEL_DAVID
replace CONEDLEVEL_DAVID = 1 if CONEDYEARS > 0 & CONEDYEARS <=5 & CONEDLEVEL_DAVID!=1
replace CONEDLEVEL_DAVID = 2 if CONEDYEARS >=6 & CONEDYEARS <12 & CONEDLEVEL_DAVID!=2
replace CONEDLEVEL_DAVID = 3 if CONEDYEARS >=12 & CONEDYEARS <15 & CONEDLEVEL_DAVID!=3
replace CONEDLEVEL_DAVID = 4 if CONEDYEARS >=15 & CONEDYEARS <. & CONEDLEVEL_DAVID!=4


recode CONEDYEARS (0 = 0) (1/5 = 1) (6/11= 2) (12 = 3) (13/20 = 4), gen(edlevel_david) 
replace edlevel_david = 0 if b22_q8==2

replace CONEDLEVEL_DAVID = edlevel_david 
drop edlevel_david

label values CONEDLEVEL_DAVID edlevelv_DAVID


drop occmain_str occmain

*********************************************************************

label var HID      		"Household identifier"
label var INDID    		"Individual identifier"
label var REGION   		"Region"
label var URBAN    		"Urban: 1, Rural:0"
label var MALE		      	"Gender"
label var AGEY			"Age in Completed years"
label var HEAD			"Household head"
label var HEAD_UNIQUE		"Household head unique"
label var HHSIZE		"Household size"
label var ETHNICITY		"Ethnicity"
label var LANGUAGE		"Language"
label var RELIGION		"Religion"
label var MARSTAT		"Marital Status"

label var EDLEVEL		"Level of education"
label var EDYEARS		"Years of education"
label var CONEDLEVEL		"Constructed level of education"
label var CONEDYEARS		"Constructed years of education"
label var EMP_STAT		"Employment Status"
label var WHYINACTIVE		"Reasons for inactivity"
label var EMPLOYED		"Employed"
label var DISCRGD		"Discouraged"
label var INACTIVE		"Inactive"
label var SECTOR_MAIN		"Int Stand Ind Class-Main Job-expanded"
label var OCC_MAIN		"Int Stand Class Occ-Main Job-ISCO88" 
label var PUBLIC		"Public employee"
label var EMPTYPE_MAIN		"Work category for main job"
label var SECONDJOB		"Second job"
label var NUMJOBS12MO		"Num of jobs worked last 12 mon"
label var AG_WRK_MAIN		"Agricultural job"
label var HOURWRKMAIN		"Hrs wrk by ind main job (annual)"
label var HOURWRKMAIN_mon		"Hrs wrk by ind main job (monthly)"
label var HOURWRKTOT		"Hrs wrk by ind in all jobs (ann)"
label var HOURWRKTOT_mon		"Hrs wrk by ind in all jobs (monthly)"
label var HOURWRKTYPE		"Type of hours worked"
label var INCOME_MAIN_def	"Def annual income fr main job"
label var INCOME_MAIN_mon_def	"Def monthly income fr main job"

label var INCOME_TOT_def	"Def annual income fr all jobs"
label var INCOME_TOT_mon_def	"Def monthly income fr all jobs"

label var NONLBRINC_def		"Def annual non labor income-HH"
label var NONLBRINC_mon_def		"Def monthly non labor income-HH"

label var XINCOME_MAIN_def	"Def totai income at HH in year"
label var XINCOME_MAIN_mon_def	"Def monthly income at HH in year"

label var XINCOME_TOT_def	"Adjust Def annual income fr ind main job"
label var XINCOME_TOT_mon_def	"Adjust Def monthly income fr ind main job"

label var XNONLBRINC_def	"Adjust Def annual non labor income HH"
label var XNONLBRINC_mon_def	"Adjust Def monthly non labor income HH"

label var IMP_FM_RENT_def	"Implicit farm rental value"
label var IMP_FM_RENT_mon_def	"Implicit farm rental value, monthly"

label var TOTCONS_def		"Def annual tot consumption HH"
label var TOTCONS_mon_def		"Def monthly tot consumption HH"

label var CONS_PC_def		"Def annual tot consumption pc"
label var CONS_PC_mon_def		"Def monthly tot consumption pc"

label var CONS_PEQA_def		"Def annual tot consumptin per adult equ"
label var CONS_PEQA_mon_def		"Def monthly tot consumptin per adult equ"

label var ADEQ			"HH sixe in adult equi"
label var REGPLINE_ann		"Regular poverty line, annual"
label var REGPLINE_mon		"Regular poverty line, monthly"

label var EXTPLINE_ann		"Extreme poverty line, annual"
label var EXTPLINE_mon		"Extreme poverty line, monthly"


label var INTPLINE_ann		"Int poverty line"
label var INTPLINE_mon		"Int poverty line, monthly"


label var STRATA		"Sampling strata ID"
label var PSU			"Primary sampling unit"
label var WEIGHT		"Household weights"
label var SPATIALDEF		"Deflator"
label var YEAR_def		"Deflator base year"
label var PPP05DEFLATOR		"PPP Def for consum in 2005"
label var LCU05DEFLATOR		"Local Currency Def for consum in 2005"


label var INCOME_MAIN_PPP05	"PPP05 Def ann income from Main job"
label var INCOME_MAIN_mon_PPP05	"PPP05 Def monthly income from Main job"

label var INCOME_TOT_PPP05	"PPP05 Def ann income from all jobs"
label var INCOME_TOT_mon_PPP05	"PPP05 Def monthly income from Main job"

*label var NONLBRINC_PPP05	"PPP05 Def ann non labor income HH"
*label var TOTCONS_PPP05	"PPP05 Def ann tot consum for HH"
*label var CONS_PC_PPP05	"PPP05 Def ann tot consum per cap"
*label var CONS_PEQA_PPP05	"PPP05 Def ann tot consum per adul equi"
//label var HHINCOME_TOT_PPP05	"PPP05 Def tot income at HH in year"
*label var XINCOME_MAIN_PPP05	"PPP05 Adjs Def ann income from main job"
*label var XINCOME_TOT_PPP05	"PPP05 Adjs Def ann income from all jobs"
*label var XNONLBRINC_PPP05	"PPP05 Adjs Def ann non labor income HH"

label var REGPLINE_ann_PPP05	"PPP05 Def regular poverty line, annual"
label var REGPLINE_mon_PPP05	"PPP05 Def regular poverty line, monthly"

label var EXTPLINE_ann_PPP05	"PPP05 Def ann extreme poverty line"
label var EXTPLINE_mon_PPP05	"PPP05 Def monthly extreme poverty line"

label var EDLEVEL_VT		"Education categories"
label var SCHOOL_LEAVE		"School leaving age"
label var CURRENT_ATTEND	"Attendance status" 
label var DURATION_UNEMP	"Duration of unemployment"
*label var CASUAL_OR_WAGE	"Casual or wage work"
label var NO_ADULT		"Number of adults"
label var NO_CHILDREN		"Number of children"
label var NO_ELDERLY		"Number of elderly"
label var ENROL_CHILDREN	"Children present Currently attending to school"
label var SCHOOL_DIST		"Distance to school"
label	variable	UNEMPLYD 	"0:Not Unemployed, 1: Unemployed"
label	variable	EMPTYPE_MAIN_EXTENDED 	"Work category for main job (inc. HH duties)"
label	variable	TOTCONS_PPP05 	"Deflated Annual Total Household Cons. (PPP 2005 $)"
label	variable	CONS_PC_PPP05 	"Deflated Annual Per Capita Household Cons. (PPP 2005 $)"
label	variable	CONS_PEQA_PPP05 	"Deflated Annual Per Adult Equivalent Household Cons. (PPP 2005 $)"

label	variable	TOTCONS_mon_PPP05 	"Deflated Monthly Total Household Cons. (PPP 2005 $)"
label	variable	CONS_PC_mon_PPP05 	"Deflated Monthly Per Capita Household Cons. (PPP 2005 $)"
label	variable	CONS_PEQA_mon_PPP05 	"Deflated Monthly Per Adult Equivalent Household Cons. (PPP 2005 $)"
label	variable	CASUAL_OR_WAGE 	"Whether Casual or Wage worker"
label	variable	AGE_CATEG 	"Age Category of Individual"
label	variable	SOCIAL_SECURITY 	"Type of Social Security"


cap 	label	var	INFORMAL	"	Informal Sector (==1)	"
cap 	label	var	FORMAL	"	Formal Sector (==1)	"
cap 	label	var	WORK_CATEG	"	Work Category (RWS, Employer, Self-employed, etc)	"
cap 	label	var	HOURWRKMAIN	"	Hours worked in main job (annual)	"
cap 	label	var	HOURWRKMAIN_mon	"	Hours worked in main job (monthly)	"
cap 	label	var	HOURWRKMAIN_week	"	Hours worked in main job (weekly)	"
cap 	label	var	HOURWRKTOT	"	Total hours worked in all jobs (annual)	"
cap 	label	var	HOURWRKTOT_mon	"	Total hours worked in all jobs (monthly)	"
cap 	label	var	HOURWRKTOT_week	"	Total hours worked in all jobs (weekly)	"
cap 	label	var	HOURWRKSEC	"	Hours worked in secondary job (annual)	"
cap 	label	var	HOURWRKSEC_mon	"	Hours worked in secondary job (monthly)	"
cap 	label	var	HOURWRKSEC_week	"	Hours worked in secondary job (weekly)	"
cap 	label	var	INCOME_MAIN_def	"	Deflated income from main job national survey yr price(annual)	"
cap 	label	var	INCOME_MAIN_mon_def	"	Deflated income from main job national survey yr price(monthly)	"
cap 	label	var	INCOME_MAIN_week_def	"	Deflated income from main job national survey yr price(weekly)	"
cap 	label	var	INCOME_MAIN_PPP05	"	PPP 2005 deflated income from main job (annual)	"
cap 	label	var	INCOME_MAIN_mon_PPP05	"	PPP 2005 deflated income from main job (monthly)	"
cap 	label	var	INCOME_MAIN_week_PPP05	"	PPP 2005 deflated income from main job (weekly)	"
cap 	label	var	INCOME_MAIN_LCU05	"	Local currency 2005 deflated income from main job (annual)	"
cap 	label	var	INCOME_MAIN_mon_LCU05	"	Local currency 2005 deflated income from main job (monthly)	"
cap 	label	var	INCOME_MAIN_week_LCU05	"	Local currency 2005 deflated income from main job (weekly)	"
cap 	label	var	INCOME_TOT_def	"	Deflated total income in national survey yr price(annual)	"
cap 	label	var	INCOME_TOT_mon_def	"	Deflated total income in  national survey yr price(monthly)	"
cap 	label	var	INCOME_TOT_week_def	"	Deflated total income in national survey yr price(weekly)	"
cap 	label	var	INCOME_TOT_PPP05	"	PPP 2005 total deflated income (annual)	"
cap 	label	var	INCOME_TOT_mon_PPP05	"	PPP 2005 total deflated income (monthly)	"
cap 	label	var	INCOME_TOT_week_PPP05	"	PPP 2005 total deflated income (weekly)	"
cap 	label	var	INCOME_TOT_LCU05	"	Local currency 2005 total deflated income (annual)	"
cap 	label	var	INCOME_TOT_mon_LCU05	"	Local currency 2005 total deflated income (monthly)	"
cap 	label	var	INCOME_TOT_week_LCU05	"	Local currency 2005 total deflated income (weekly)	"
cap 	label	var	INCOME_SEC_def	"	Deflated income from secondary job national survey yr price(annual)	"
cap 	label	var	INCOME_SEC_mon_def	"	Deflated income from secondary job national survey yr price(monthly)	"
cap 	label	var	INCOME_SEC_week_def	"	Deflated income from secondary job national survey yr price(weekly)	"
cap 	label	var	INCOME_SEC_PPP05	"	PPP 2005 deflated income from secondary job (annual)	"
cap 	label	var	INCOME_SEC_mon_PPP05	"	PPP 2005 deflated income from secondary job (monthly)	"
cap 	label	var	INCOME_SEC_week_PPP05	"	PPP 2005 deflated income from secondary job (weekly)	"
cap 	label	var	INCOME_SEC_LCU05	"	Local currency 2005 deflated income from secondary job (annual)	"
cap 	label	var	INCOME_SEC_mon_LCU05	"	Local currency 2005 deflated income from secondary job (monthly)	"
cap 	label	var	INCOME_SEC_week_LCU05	"	Local currency 2005 deflated income from secondary job (weekly)	"
cap 	label	var	HHINCOME_TOT_def	"	Deflated total household income in national survey yr price(annual)	"
cap 	label	var	HHINCOME_TOT_mon_def	"	Deflated total household income in  national survey yr price(monthly)	"
cap 	label	var	HHINCOME_TOT_week_def	"	Deflated total household income in national survey yr price(weekly)	"
cap 	label	var	HHINCOME_TOT_PPP05	"	PPP 2005 deflated total household income(annual)	"
cap 	label	var	HHINCOME_TOT_mon_PPP05	"	PPP 2005 deflated total household income(monthly)	"
cap 	label	var	HHINCOME_TOT_week_PPP05	"	PPP 2005 deflated total household income(weekly)	"
cap 	label	var	HHINCOME_TOT_LCU05	"	Local currency 2005 deflated total household income(annual)	"
cap 	label	var	HHINCOME_TOT_mon_LCU05	"	Local currency 2005 deflated total household income(monthly)	"
cap 	label	var	HHINCOME_TOT_week_LCU05	"	Local currency 2005 deflated total household income(weekly)	"
cap 	label	var	TOTCONS_def	"	Deflated total consumption (annual)	"
cap 	label	var	TOTCONS_mon_def	"	Deflated total consumption (monthly)	"
cap 	label	var	TOTCONS_PPP05	"	PPP 2005 deflated total consumption (annual)	"
cap 	label	var	TOTCONS_LCU05	"	Local currency 2005 deflated total consumption (annual)	"
cap 	label	var	TOTCONS_mon_PPP05	"	PPP 2005 deflated total consumption (monthly)	"
cap 	label	var	TOTCONS_mon_LCU05	"	Local currency 2005 deflated total consumption (monthly)	"
cap 	label	var	CONS_PC_def	"	Deflated per capita consumption (annual)	"
cap 	label	var	CONS_PC_mon_def	"	Deflated per capita consumption (monthly)	"
cap 	label	var	CONS_PC_PPP05	"	PPP 2005 deflated per capita consumption (annual)	"
cap 	label	var	CONS_PC_mon_PPP05	"	PPP 2005 deflated per capita consumption (monthly)	"
cap 	label	var	CONS_PC_LCU05	"	Local currency 2005 deflated per capita consumption (annual)	"
cap 	label	var	CONS_PC_mon_LCU05	"	Local currency 2005 deflated per capita consumption (monthly)	"
cap 	label	var	CONS_PEQA_def	"	Deflated consumption per adualt equivalent (annual)	"
cap 	label	var	CONS_PEQA_mon_def	"	Deflated consumption per adualt equivalent (monthly)	"
cap 	label	var	CONS_PEQA_PPP05	"	PPP 2005 deflated consumption per adult equivalent (annual)	"
cap 	label	var	CONS_PEQA_mon_PPP05	"	PPP 2005 deflated consumption per adult equivalent (monthly)	"
cap 	label	var	CONS_PEQA_LCU05	"	Local currency 2005 deflated consumption per adult equivalent (annual)	"
cap 	label	var	CONS_PEQA_mon_LCU05	"	Local currency 2005 deflated consumption per adult equivalent (monthly)	"
cap 	label	var	REGPLINE_mon	"	Regular poverty line (monthly)	"
cap 	label	var	EXTPLINE_mon	"	Extreme poverty line (monthly)	"
cap 	label	var	REGPLINE_ann_PPP05	"	PPP 2005 deflated regular poverty line (annual)	"
cap 	label	var	EXTPLINE_ann_PPP05	"	PPP 2005 deflated extreme poverty line (annual)	"
cap 	label	var	REGPLINE_mon_PPP05	"	PPP 2005 deflated regular poverty line (monthly)	"
cap 	label	var	EXTPLINE_mon_PPP05	"	PPP 2005 deflated extreme poverty line (monthly)	"
cap 	label	var	IMP_FM_RENT_PPP05 	"	PPP 2005 deflated implicit farm rental value (annual)	"
cap 	label	var	REGPLINE_ann_LCU05	"	Local currency 2005 deflated regular poverty line (annual)	"
cap 	label	var	EXTPLINE_ann_LCU05	"	Local currency 2005 deflated extreme poverty line (annual)	"
cap 	label	var	REGPLINE_mon_LCU05	"	Local currency 2005 deflated regular poverty line (monthly)	"
cap 	label	var	EXTPLINE_mon_LCU05	"	Local currency 2005 deflated extreme poverty line (monthly)	"
cap 	label	var	IMP_FM_RENT_LCU05 	"	Local currency 2005 deflated implicit farm rental value (annual)	"
cap 	label	var	IMP_FM_RENT_LCU05	"	Local currency 2005 deflated implicit farm rental value (annual)	"
cap 	label	var	EDLEVEL_DAVID	"	Level of education (w/ tertiary completed group)	"
cap 	label	var	CONEDLEVEL_DAVID	"	constructed level of education (w/ tertiary completed group)	"
cap 	label	var	CASUAL_OR_WAGE	"	Casual or regular wage work	"
cap 	label	var	LCUDEFLATOR	"	Local Currency 2005 deflator	"
cap 	label	var	TOTCONS_week_def	"	Deflated total consumption (weekly)	"
cap 	label	var	TOTCONS_week_PPP05	"	PPP 2005 deflated total consumption (weekly)	"
cap 	label	var	TOTCONS_week_LCU05	"	Local currency 2005 deflated total consumption (weekly)	"
cap 	label	var	CONS_PC_week_def	"	Deflated per capita consumption (weekly)	"
cap 	label	var	CONS_PC_week_PPP05	"	PPP 2005 deflated per capita consumption (weekly)	"
cap 	label	var	CONS_PC_week_LCU05	"	Local currency 2005 deflated per capita consumption (weekly)	"
cap 	label	var	CONS_PEQA_week_def	"	Deflated consumption per adualt equivalent (weekly)	"
cap 	label	var	CONS_PEQA_week_PPP05	"	PPP 2005 deflated consumption per adult equivalent (weekly)	"
cap 	label	var	CONS_PEQA_week_LCU05	"	Local currency 2005 deflated consumption per adult equivalent (weekly)	"
cap	label	var	WHYINACTIVE_mahesh	"	Reason for being inactive (6 categoties)	" 


qui compress

save "`DataProc'\BTN_BLSS_2003_2003.dta", replace
