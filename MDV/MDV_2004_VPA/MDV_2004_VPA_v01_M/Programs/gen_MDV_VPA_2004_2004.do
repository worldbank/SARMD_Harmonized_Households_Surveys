clear
cap log close
*set mem 500m
set more off

local dataorig "C:\Labor Flagship\MALDIVES\VPA2004\Data\DataOrig"
local dataproc "C:\Labor Flagship\MALDIVES\VPA2004\Data\DataProc"
local datawaste "C:\Labor Flagship\MALDIVES\VPA2004\Data\DataWaste"
local dopath "C:\Labor Flagship\MALDIVES\VPA2004\DoFiles"

log using "`dopath'\MDV_VPA2004_generate.log", text replace

*The original folder is MALDIVES\VPA 2\VPA-2 Paradox Tables(not raised)
*Stat-transfered 95 paradox files into Stata received on 14 April 2010


*prepare component files
use "`dataorig'\F02_Structure.dta"
sort  HH_serial
save "`datawaste'\F02_STRUC.dta", replace

use "`dataorig'\F03_Individual.dta"
sort  HH_serial  a1_Person
save "`datawaste'\F03_IND.dta", replace

use "`dataorig'\F04_Household.dta"
sort  HH_serial
save "`datawaste'\F04_HH.dta", replace

use "`dataorig'\F06_EmpInc.dta"
sort  HH_serial Person
save "`datawaste'\F06_EMP.dta", replace

use "`dataorig'\VPA2-00r-expenditure-by-household.dta"
sort  HH_serial
save "`datawaste'\F07_EXP.dta", replace


*recoding the variables in each component
use "`datawaste'\F02_STRUC.dta"
rename  a1_DwellingType f2a1_DwellingType
rename  a2_NumStoreys f2a2_NumStoreys
rename a3_Walls  f2a3_Walls
rename  a4_Roof  f2a4_Roof
rename  a5_Floor  f2a5_Floor
rename  a6_Ceiling  f2a6_Ceiling
rename  a7_HowOld  f2a7_HowOld
rename  a8_Area  f2a8_Area
rename  a9_SanitaryType  f2a9_SanitaryType
save "`datawaste'\F02_STRUC.dta", replace

use "`datawaste'\F03_IND.dta"
rename  a1_Person Person
sort  HH_serial Person
drop  a7_FatherAlive  a8_MotherAlive a9_MotherLvngInHshld a9_Mother
drop   a9_YesNoLiveBirths a9_FemLiveBirths a9_MaleLiveBirths a0_AgeAtFirstBirth a1_FemSurvived a1_MaleSurvived  a2_YesNoLiveBirthsLstYr a2_FemLiveBirthsLstYr a2_MaleLiveBirthsLstYr a3_FemSurvivedLstYr a3_MaleSurvivedLstYr
save "`datawaste'\F03_IND.dta", replace

use "`datawaste'\f04_hh"
renpfix a f4hh_a
save "`datawaste'\F04_HH", replace

use "`datawaste'\F06_EMP"
renpfix a f6a
destring  Person, replace
sort HH_serial Person 
save "`datawaste'\F06_EMP.dta", replace

use "`datawaste'\F07_EXP.dta"
drop  A01 A02 A03 A04 A05 A06 A07 A08 A09 A10 A11 A12 A13
save "`datawaste'\F07_EXP.dta", replace


*merging the component files
use "`datawaste'\F03_IND.dta"
joinby  HH_serial using "`datawaste'\F02_STRUC.dta"
save "`datawaste'\Merge1.dta", replace

joinby  HH_serial using "`datawaste'\F04_HH.dta"
sort HH_serial Person 
save "`datawaste'\Merge2.dta", replace

merge  HH_serial Person using "`datawaste'\F06_EMP.dta"
tab _merge
save "`datawaste'\Merge3", replace

use "`datawaste'\merge3"
joinby  HH_serial using "`datawaste'\F07_EXP.dta"
save "`datawaste'\Merge4", replace


*recoding the merged file
save "`dataproc'\MDV_VPA_2004_2004.dta", replace

generate _SAR_VAR=.
tab  _SAR_VAR

generate COUNTRY="MDV"
tab  COUNTRY

generate YEAR=2004
tab  YEAR

generate HID= HH_serial
*tab HID

generate INDID=Person
tab INDID

tab  Region
*tab  Island
generate REGION=Region
label define region 0 "Male'" 1 "North" 2 "Central North" 3 "Central" 4 "Central South" 5 "South"
label values REGION region
tab REGION

tab  MaleAtoll
generate URBAN=MaleAtoll
recode URBAN 2=0
label define urban 0 "Rural" 1 "Urban"
label values URBAN urban
tab URBAN

tab  a2_Sex
generate MALE= a2_Sex
recode MALE 1=0 2=1
label define male 0 "Female" 1 "Male"
label values MALE male
tab MALE

tab  a3_AgeYrs
tab  a4_ChldrnAgeMths
tab   a4_ChldrnAgeMths a3_AgeYrs
* one child aged 12 months recorded as 2 years
generate AGEY= a3_AgeYrs
recode  AGEY 99=98
replace AGEY=1 if a4_ChldrnAgeMths==12
tab   a4_ChldrnAgeMths AGEY
tab AGEY
*one 1 obs missing

tab  a0_RltnshpWHshldHd
sort HID INDID
by HID, sort: egen min_relation = min(a0_RltnshpWHshldHd)
gen one = 1
by HID, sort: egen num_heads = count(one) if a0_RltnshpWHshldHd == 1
recode num_heads . = 0
by HID, sort: egen min_id = min(INDID)
gen HEAD = .
replace HEAD = 1 if a0_RltnshpWHshldHd == 1
replace HEAD = 0 if a0_RltnshpWHshldHd != 1
replace HEAD = 0 if min_relation >= 2 | num_heads > 1
drop  min_id num_heads one min_relation

tab  HEAD  a0_RltnshpWHshldHd
generate HEAD_UNIQUE=.
* this dataset doesn't have multiple head in same HH

tab  a3_HshldMmbrshpStatus
drop if  a3_HshldMmbrshpStatus != 1
egen HHSIZE = max(Person), by(HID)
tab HHSIZE

tab a6_Nationality
generate ETHNICITY=a6_Nationality
label define ethnicity 1 "Maldivian" 2 "Foreigner"
label values ETHNICITY ethnicity
tab ETHNICITY
* ethnicity info not collected other than whether the respondent is maldivian or not

tab a8_LngDhivehi
tab a8_LngEng
tab a8_LngOthr
tab a8_LngNone
generate LANGUAGE=.
* language is not collected in this syrvey, literacy in specific language was collected instead

generate RELIGION = .
*not collected.

generate MARSTAT= a6_MaritalStatus
* this info was collected for person aged 15 years and above
tab MARSTAT
recode MARSTAT 0=. 3=5 4=6
tab AGEY MARSTAT
tab  a8_Wives
recode MARSTAT 2 = 3 if a8_Wives > 1 & a8_Wives <.
tab MARSTAT
* Married polygamy is only applicable here for males
label define marstat 1 "Never Married" 2 "Married Monog" 3 "Married Poly" 5 "Divorced/Separated" 6 "Widowed"
label values MARSTAT marstat
tab MARSTAT

gen _EDUCATION_ = .

*gen inter_edlevel = a7_EdctnLvlAchvd

gen inter_edlevel = a6_EdctnLvlCrnt - 1 if a5_AttndEdctnInsttNow == 1 
replace inter_edlevel = . if a6_EdctnLvlCrnt == 13
replace inter_edlevel = a7_EdctnLvlAchvd if inter_edlevel == .
replace inter_edlevel = 0 if inlist(a5_AttndEdctnInsttNow, 0, 2) & inter_edlevel == .


gen EDLEVEL = .
replace EDLEVEL = 0 if inter_edlevel == 0 | inter_edlevel == 20
replace EDLEVEL = 1 if inter_edlevel >= 1 & inter_edlevel < 7
replace EDLEVEL = 2 if inter_edlevel >= 7 & inter_edlevel < 10
replace EDLEVEL = 3 if inter_edlevel >= 10 & inter_edlevel < 12 | inter_edlevel == 16 | inter_edlevel == 17
replace EDLEVEL = 4 if inter_edlevel >= 12 & inter_edlevel < 16
replace EDLEVEL = 0 if inter_edlevel == 18 | inter_edlevel == 19
label define edlevel 0 "No education" 1 "Primary" 2 "Junior Secondary" 3 "Senior Secondary" 4 "Pre-University and  Above"
label values EDLEVEL edlevel


gen EDYEARS = inter_edlevel
replace EDYEARS = 0 if inter_edlevel == 0 | inter_edlevel == 20
replace EDYEARS = 11 if inter_edlevel == 16 | inter_edlevel == 17
replace EDYEARS = 13 if inter_edlevel == 14
replace EDYEARS = 16 if inter_edlevel == 15
replace EDYEARS = . if inter_edlevel == 18 | inter_edlevel == 19
replace EDYEARS = 0 if inter_edlevel < 0
* local certificate "17" or vocational training local "16" in set to have EDYEARS = 11 (instead of 13)
* diploma level "14" is set to have EDYEARS = 13 (instead of 14)


gen EDLEVEL_DAVID = .
replace EDLEVEL_DAVID = 0 if inter_edlevel == 0 | inter_edlevel == 20
replace EDLEVEL_DAVID = 1 if inter_edlevel >= 1 & inter_edlevel < 7
replace EDLEVEL_DAVID = 2 if inter_edlevel >= 7 & inter_edlevel <= 11 | inter_edlevel == 16 | inter_edlevel == 17
replace EDLEVEL_DAVID = 3 if inter_edlevel  == 12
replace EDLEVEL_DAVID = 4 if inter_edlevel > 12 & inter_edlevel < 16
replace EDLEVEL_DAVID = 3 if a7_EdctnLvlAchvd == 13
replace EDLEVEL_DAVID = 0 if inter_edlevel == 18 | inter_edlevel == 19

label define edlevel_david 0 "No Education" 1 "Some Primary, but not completed" 2 "Completed Primary" 3 "Completed Secondary" 4 "Completed Tertiary"
label values EDLEVEL_DAVID edlevel_david
tab EDLEVEL_DAVID


gen CONEDLEVEL = .

gen CONEDYEARS = EDYEARS
scalar count = 1
while count < 20 {
  replace CONEDYEARS = count if AGEY == ( count + 4) & EDYEARS > count & EDYEARS != .
	scalar count = count + 1
}


recode CONEDYEARS (0 =0) (1/6 = 1) (7/9 = 2) (10/11 = 3) (12/23 = 4), gen (condlevel)
replace condlevel = 3 if inlist(inter_edlevel, 16, 17)
replace condlevel = 0 if inlist(inter_edlevel, 18, 19)
replace CONEDLEVEL = condlevel
label values CONEDLEVEL edlevel


gen CONEDLEVEL_DAVID = CONEDYEARS
recode CONEDLEVEL_DAVID (0 = 0) (1/6 = 1) (7/11 = 2) (12 = 3) (13/23 = 4)
replace CONEDLEVEL_DAVID = 3 if a7_EdctnLvlAchvd ==13
replace CONEDLEVEL_DAVID = 0 if inlist(inter_edlevel, 18, 19)
replace CONEDLEVEL_DAVID = 2 if inlist(inter_edlevel, 16, 17)


label define conedlevel_david 0 "No Education" 1 "Some Primary, but not completed" 2 "Completed Primary" 3 "Completed Secondary" 4 "Completed Tertiary"
label values CONEDLEVEL_DAVID conedlevel_david
tab CONEDLEVEL_DAVID

gen _EMPLOYMENT_ = .

tab a9_ActvtyMstEnggd
tab a0_IncmGnrtngActvty
tab a3_RsnForNotWrkng
tab a1_AvlblForWork
tab a9_ActvtyMstEnggd a3_RsnForNotWrkng
tab a9_ActvtyMstEnggd  a1_AvlblForWork
tab a3_RsnForNotWrkng  a1_AvlblForWork
tab f6a1_EmpStatus
generate EMP_STAT=.

gen emp_stat = .  

replace emp_stat = 1 if a9_ActvtyMstEnggd==1 
replace emp_stat = 1 if a0_Incm==1 
replace emp_stat = 2 if a1_Avlbl==1 & mi(emp_stat)
replace emp_stat = 4 if inlist(a3_RsnFor, 2, 3, 4, 5, 6) 
replace emp_stat = 4 if mi(emp_stat) & AGEY>=15 
recode EMP_STAT 1 = . if   AGEY <15
replace EMP_STAT =emp_stat
drop emp_stat 

label define emp_stat 1 "Employed" 2 "Unemployed" 3 "Discouraged"  4 "Inactive"
label values EMP_STAT emp_stat


tokenize "EMPLOYED UNEMPLYD DISCRGD INACTIVE" 
forval i = 1/4{ 
	gen ``i'' = .
	replace ``i'' = . 
	replace ``i'' = EMP_STAT==`i' if !mi(EMP_STAT)
} 


generate WHYINACTIVE=9 if EMP_STAT==4
recode WHYINACTIVE 9=1 if a3_RsnForNotWrkng==1
recode WHYINACTIVE 9=2 if a3_RsnForNotWrkng==2
recode WHYINACTIVE 9=3 if a3_RsnForNotWrkng==3
recode WHYINACTIVE 9=4 if a3_RsnForNotWrkng==4
recode WHYINACTIVE 9=5 if a3_RsnForNotWrkng==5
recode WHYINACTIVE 9=6 if a3_RsnForNotWrkng==6
tab  WHYINACTIVE a9_ActvtyMstEnggd
recode WHYINACTIVE 9=6 if a9_ActvtyMstEnggd==2 | a9_ActvtyMstEnggd==3 | a9_ActvtyMstEnggd==4
tab  WHYINACTIVE 
tab  WHYINACTIVE  a0_IncmGnrtngActvty
tab  WHYINACTIVE  a1_AvlblForWork
recode WHYINACTIVE 6=6 if a9_ActvtyMstEnggd==2 
recode WHYINACTIVE 6=7 if a9_ActvtyMstEnggd==3
recode WHYINACTIVE 6=8 if a9_ActvtyMstEnggd==4
tab  WHYINACTIVE
label define whyinactive 1 "Unable to find suitable work" 2 "Parents/spouse disapprove" 3 "Poor health" 4 "Family  responsibility" 5 "Income recipient" 6 "Studying/training" 7"Doing housework" 8 "Doing nothing specific" 9 "Other"
label values WHYINACTIVE whyinactive
tab  WHYINACTIVE


cap gen WHYINACTIVE_mahesh = . 
recode WHYINACTIVE (1 2 5 8 9 = 6) (3 = 4) (4 7 = 3) (6 = 2), gen(whyin) 
replace WHYINACTIVE_mahesh = whyin 
drop whyin 
replace WHYINACTIVE_mahesh = 1 if DISCRGD==1
replace WHYINACTIVE_mahesh = 2 if a9_ActvtyMstEnggd==2 & mi(WHYINACTIVE_mahesh) 
replace WHYINACTIVE_mahesh = 3 if  a9_ActvtyMstEnggd==3 & mi(WHYINACTIVE_mahesh) 
replace WHYINACTIVE_mahesh = 6 if  a9_ActvtyMstEnggd==4 & mi(WHYINACTIVE_mahesh) 

replace WHYINACTIVE_mahesh = . if !inlist(EMP_STAT, 3, 4) 
cap label define whyin 1 "Discouraged" 2 "Student/Education" 3 "HH duties" 4 "Illess/Disability" 5 "Old/Retired" 6 "Other" 
label values WHYINACTIVE_mahesh whyin 



*ISIC codes (Revision 3.1) are used from http://unstats.un.org/unsd/cr/registry/regcst.asp?Cl=17
* tab f6a3_isic
generate SECTOR_MAIN=.
replace SECTOR_MAIN=1 if f6a3_isic =="52" | f6a3_isic =="111" | f6a3_isic =="112" | f6a3_isic =="113" | f6a3_isic  =="121" | f6a3_isic =="122" | f6a3_isic =="200" | f6a3_isic =="500"
replace SECTOR_MAIN=2 if f6a3_isic =="1410"
replace SECTOR_MAIN=3 if f6a3_isic =="1511" | f6a3_isic =="1512" | f6a3_isic =="1513" | f6a3_isic =="1514" |  f6a3_isic =="1520" | f6a3_isic =="1532" | f6a3_isic =="1541" | f6a3_isic =="1542" | f6a3_isic =="1543" | f6a3_isic  =="1544" | f6a3_isic =="1549" | f6a3_isic =="1554" | f6a3_isic =="1600" | f6a3_isic =="1723" | f6a3_isic =="1729" |  f6a3_isic =="1810" | f6a3_isic =="2022" | f6a3_isic =="2029" | f6a3_isic =="2102" | f6a3_isic =="2212" | f6a3_isic  =="2511" | f6a3_isic =="2520" | f6a3_isic =="2695" | f6a3_isic =="2811" | f6a3_isic =="2892" | f6a3_isic =="2893" |  f6a3_isic =="2919" | f6a3_isic =="3190" | f6a3_isic =="3511" | f6a3_isic =="3520" | f6a3_isic =="3610" | f6a3_isic  =="3691" | f6a3_isic =="3699"
replace SECTOR_MAIN=4 if f6a3_isic =="4010" | f6a3_isic =="4020" | f6a3_isic =="4100"
replace SECTOR_MAIN=5 if f6a3_isic =="4510" | f6a3_isic =="4520" | f6a3_isic =="4530" | f6a3_isic =="4540"
replace SECTOR_MAIN=6 if f6a3_isic =="5010" | f6a3_isic =="5020" | f6a3_isic =="5040" | f6a3_isic =="5121" |  f6a3_isic =="5122" | f6a3_isic =="5141" | f6a3_isic =="5143" | f6a3_isic =="5150" | f6a3_isic =="5190" | f6a3_isic  =="5211" | f6a3_isic =="5219" | f6a3_isic =="5220" | f6a3_isic =="5231" | f6a3_isic =="5232" | f6a3_isic =="5233" |  f6a3_isic =="5234" | f6a3_isic =="5239" | f6a3_isic =="5251" | f6a3_isic =="5252" | f6a3_isic =="5259" | f6a3_isic  =="5260" | f6a3_isic =="5510" | f6a3_isic =="5520"
replace SECTOR_MAIN=7 if f6a3_isic =="6022" | f6a3_isic =="6110" | f6a3_isic =="6120" | f6a3_isic =="6210" |  f6a3_isic =="6220" | f6a3_isic =="6301" | f6a3_isic =="6303" | f6a3_isic =="6304" | f6a3_isic =="6309" | f6a3_isic  =="6411" | f6a3_isic =="6412" | f6a3_isic =="6420"
replace SECTOR_MAIN=8 if f6a3_isic =="6511" | f6a3_isic =="6519" | f6a3_isic =="6603" | f6a3_isic =="6720" |  f6a3_isic =="7112" | f6a3_isic =="7122" | f6a3_isic =="7129" | f6a3_isic =="7250" | f6a3_isic =="7290" | f6a3_isic  =="7411" | f6a3_isic =="7412" | f6a3_isic =="7413" | f6a3_isic =="7421" | f6a3_isic =="7491" | f6a3_isic =="7492" |  f6a3_isic =="7493" | f6a3_isic =="7494" | f6a3_isic =="7499"
replace SECTOR_MAIN=9 if f6a3_isic =="7511" | f6a3_isic =="7522" | f6a3_isic =="7523"
replace SECTOR_MAIN=10 if f6a3_isic =="8010" | f6a3_isic =="8021" | f6a3_isic =="8022" | f6a3_isic =="8030" |  f6a3_isic =="8090" | f6a3_isic =="8511" | f6a3_isic =="8512" | f6a3_isic =="8519" | f6a3_isic =="8531" | f6a3_isic  =="8532" | f6a3_isic =="9000" | f6a3_isic =="9112" | f6a3_isic =="9191" | f6a3_isic =="9199" | f6a3_isic =="9211" |  f6a3_isic =="9213" | f6a3_isic =="9214" | f6a3_isic =="9219" | f6a3_isic =="9231" | f6a3_isic =="9241" | f6a3_isic  =="9301" | f6a3_isic =="9302" | f6a3_isic =="9309" | f6a3_isic =="9500" | f6a3_isic =="9900" | f6a3_isic =="9999"
tab  SECTOR_MAIN
label define sector_main 1 "Agriculture & fishing" 2 "Mining" 3 "Manufacturing" 4 "Electricity & utilities" 5  "Construction" 6 "Commerce" 7"Transportation, storage & communication" 8 "Financial, insurance & real estate" 9  "Public administration" 10 "Other services"
label values SECTOR_MAIN sector_main
tab  SECTOR_MAIN



*ISCO-88 codes are used from the LMMD codebook - PLEASE CHECK THE CODINGS BELOW
* tab f6a4_isco
destring(f6a4_isco), replace
generate OCC_MAIN=.
replace OCC_MAIN=1 if f6a4_isco >=1000 & f6a4_isco <2000
replace OCC_MAIN=2 if f6a4_isco >=2000 & f6a4_isco <3000
replace OCC_MAIN=3 if f6a4_isco >=3000 & f6a4_isco <4000
replace OCC_MAIN=4 if f6a4_isco >=4000 & f6a4_isco <5000
replace OCC_MAIN=5 if f6a4_isco >=5000 & f6a4_isco <6000
replace OCC_MAIN=6 if f6a4_isco >=6000 & f6a4_isco <7000
replace OCC_MAIN=7 if f6a4_isco >=7000 & f6a4_isco <8000
replace OCC_MAIN=8 if f6a4_isco >=8000 & f6a4_isco <9000
replace OCC_MAIN=9 if f6a4_isco >=9000 & f6a4_isco <9999
replace OCC_MAIN=99 if f6a4_isco ==9999
label define occ_main 1 "Legislators, senior officials & managers" 2 "Professionals" 3 "Technicians & associated  professionals" 4 "Clerks" 5 "Service workers & shop & market sales" 6 "Skilled agricultural and fishery workers"  7"Craft & related trades" 8 "Plant & machine operators & assemblers" 9 "Elementary occupations" 99  "Other/unspecified"
label values OCC_MAIN occ_main
tab  OCC_MAIN

tab f6a5_EstbType
generate PUBLIC= f6a5_EstbType
recode PUBLIC 1=1 2=1 0=0 3=0 4=1 5=0 6=0 7=0
tab PUBLIC

tab f6a1_EmpStatus
gen emptype_main = real(f6a1_EmpStatus)
recode emptype_main (1 = 2) (2 = 1) (4 5 = 4) 
gen EMPTYPE_MAIN = emptype_main
drop emptype_main

label define emptype_main 1 "Wage & salaried worker" 2 "Employer" 3 "Individual self-employed worker" 4 "Household  enterprise worker"
label values EMPTYPE_MAIN emptype_main
tab EMPTYPE_MAIN


tab f6a8_ScndryOccptn
generate SECONDJOB= f6a8_ScndryOccptn
*there exists a value outside question's range
recode  SECONDJOB 1=1 2=0 3=0
tab  SECONDJOB

cap gen EMPTYPE_SECOND = . 
recode f6a9_EmpStatus (1 = 2) (2 = 1) ( 4 5 = 4), gen(emptype_sec)
replace EMPTYPE_SECOND = emptype_sec if SECONDJOB==1
label values EMPTYPE_SECOND emptype_main
drop emptype_sec 


cap gen SECTOR_SECOND = .
gen sect_sec = int(real(f6a1_isic)/100) 
recode sect_sec (0/5 = 1) (10/14 = 2) (15/37 = 3) (40 41 = 4) (45 = 5) (50/55 = 6) (60/64 = 7) (65/74 = 8) (75 = 9) (80/99 = 10)
replace SECTOR_SECOND = sect_sec if SECONDJOB==1
label values SECTOR_SECOND sector_main 
drop sect_sec


generate NUMJOBS12MO=.
*MDV VPA 2004 did not collect info on this

generate AG_WRK_MAIN=(SECTOR_MAIN==1)
replace  AG_WRK_MAIN=. if  SECTOR_MAIN==.
tab  AG_WRK_MAIN

generate CASUAL_OR_WAGE = .

cap gen INFORMAL =. 
cap gen FORMAL = . 
replace FORMAL = . 
replace INFORMAL = . 

gen informal = 1 if EMPTYPE_MAIN==4 
replace informal = inlist(CONEDLEVEL, 0, 1, 2, 3) if EMPTYPE_MAIN==3 
replace informal = 1 if CASUAL_OR_WAGE==1 & EMPTYPE_MAIN==1
replace informal = 0 if PUBLIC ==1 & EMPTYPE_MAIN==1 & mi(informal)

replace informal = 1 if AG_WRK_MAIN==1 

replace INFORMAL = informal==1 if EMPLOYED==1
replace FORMAL = informal==0 if EMPLOYED==1 
drop informal 



* tab  f6a6_NumHrs
* tab  f6a4_NumHrs
destring(f6a6_NumHrs), replace
destring(f6a4_NumHrs), replace
recode  f6a4_NumHrs .=0 if  f6a6_NumHrs !=.

gen hrs_main =  f6a6_NumHrs 
gen hrs_sec =  f6a4_NumHrs
egen tot_hrs = rowtotal(hrs_main hrs_sec), mi

* 9.25% respondents stated the total working hours to exceed 96 per week
generate wrkhr_prop_m=hrs_main/ tot_hrs
generate wrkhr_prop_s=hrs_sec/ tot_hrs


generate HOURWRKMAIN= hrs_main*52
replace HOURWRKMAIN = 96* wrkhr_prop_m*52 if  tot_hrs>= 96

generate HOURWRKSEC= hrs_main*52
replace HOURWRKSEC = 96* wrkhr_prop_s*52 if  tot_hrs>= 96

generate HOURWRKTOT=tot_hrs*52
replace HOURWRKTOT = 4992 if  tot_hrs>= 96 & !mi(tot_hrs)

generate HOURWRKMAIN_mon=HOURWRKMAIN/12
generate HOURWRKSEC_mon = HOURWRKSEC/12
generate HOURWRKTOT_mon=HOURWRKTOT/12

generate HOURWRKMAIN_week=HOURWRKMAIN/52
generate HOURWRKSEC_week = HOURWRKSEC/52
generate HOURWRKTOT_week=HOURWRKTOT/52

foreach v in "" _week _mon {
	replace HOURWRKSEC`v' = . if SECONDJOB !=1
}

generate HOURWRKTYPE = 1
replace  HOURWRKTYPE=. if  HOURWRKTOT==.
tab  HOURWRKTYPE

drop hrs_main hrs_sec tot_hrs wrkhr_prop_m wrkhr_prop_s


******************************************************
*************DEFLATORS*******************************
*****************************************************

* It was decided that spatial deflator is not needed for Maldives.
* NOTE: For VPA1, regional price deflator kept as 1 (Ref: Francis Rowe’s mail on 22 October 2010). 

gen SPATIALDEF = 1

***PPP05DEFLATOR***
scalar PPP05 = 9.737
scalar cpi2004 = 98.54667
scalar cpi2005 = 101.8583

gen PPP05DEFLATOR = PPP05 *(cpi2004/cpi2005)

gen LCUDEFLATOR = 1/PPP05



*************************************************

save "`dataproc'\MDV_VPA_2004_2004.dta", replace

#delimit ;

tempfile wageinc; 
use "`dataorig'\VPA2-A6r-Incomes-by-Type", clear;

keep if inrange(IncomeCode, 1, 13); 
ren HH_Serial HID; 
ren Individual INDID; 
gen categ = .; 
replace categ = 1 if inrange(IncomeCode, 1, 6); 
replace categ = 2 if inrange(IncomeCode, 7, 12); 
replace categ = 3 if IncomeCode ==13; 
replace Amount = Amount/12; 

collapse (sum) Amount, by(HID INDID categ); 
reshape wide Amount, i(HID INDID) j(categ); 

ren Amount1 income_main; 
ren Amount2 income_sec; 
ren Amount3 income_se; 
save `wageinc';


use "`dataproc'\MDV_VPA_2004_2004.dta", clear; 


tab _merge ;
cap drop _merge; 

joinby HID INDID using `wageinc', unm(master); tab _m; drop _m; 


save "`dataproc'\MDV_VPA_2004_2004.dta", replace ;


******************************* ;


gen __INCOME__ = . ;

gen INCOME_MAIN_mon_PPP05 = income_main if EMP_STAT==1; 
gen INCOME_SEC_mon_PPP05 = income_sec if SECONDJOB==1; 

foreach v in income_se INCOME_SEC_mon_PPP05 INCOME_MAIN_mon_PPP05{;
	replace `v'= `v'/SPATIALDEF; 
	replace `v' = . if `v'==0;
	qui summ `v', d; 
	replace `v'= r(p50) 
		if !inrange(`v', r(p50) - 3 * r(sd), r(p50) + 3*r(sd)) & !mi(`v'); 
	replace `v'= `v'/PPP05DEFLATOR; 	 
};
egen INCOME_TOT_mon_PPP05 = rowtotal(INCOME_MAIN_mon_PPP05 INCOME_SEC_mon_PPP05), mi;
replace INCOME_TOT_mon_PPP05 = income_se if mi(INCOME_TOT_mon_PPP05);

gen INCOME_MAIN_PPP05 = INCOME_MAIN_mon_PPP05*12;
gen INCOME_SEC_PPP05 = INCOME_SEC_mon_PPP05*12;
gen INCOME_TOT_PPP05 = INCOME_TOT_mon_PPP05*12;

gen INCOME_MAIN_week_PPP05 = INCOME_MAIN_mon_PPP05*(12/52);
gen INCOME_SEC_week_PPP05 = INCOME_SEC_mon_PPP05*(12/52);
gen INCOME_TOT_week_PPP05 = INCOME_TOT_mon_PPP05*(12/52);



foreach v in INCOME_MAIN INCOME_SEC INCOME_TOT INCOME_MAIN_mon INCOME_SEC_mon INCOME_TOT_mon 
			INCOME_MAIN_week INCOME_SEC_week INCOME_TOT_week{ ;
	cap gen `v'_def = `v'_PPP05*PPP05DEFLATOR ;
};


foreach v in INCOME_TOT INCOME_SEC INCOME_MAIN INCOME_TOT_mon INCOME_SEC_mon INCOME_MAIN_mon 
				INCOME_MAIN_week INCOME_SEC_week INCOME_TOT_week{;
	cap gen `v'_LCU05 = . ;
	replace `v'_LCU05 = `v'_PPP05/LCUDEFLATOR ;
}; 

# delimit cr


**************************************************		
******** USING UNRAISED DATA**********************

des  f6a7_Sales1 f6a7_Sales2 f6a7_Sales3 f6a4_Sales1 f6a4_Sales2 f6a4_Sales3 f6a1_RcvdFrmPdEmplymnt  f6a1_1_WagesPrmry f6a1_1_WagesOthr f6a1_2_OvrtmPrmry f6a1_2_OvrtmOthr f6a1_3_UniformPrmry f6a1_3_UniformOthr  f6a1_4_TravelPrmry f6a1_4_TravelOthr f6a1_5_SrvcsPrmry f6a1_5_SrvcsOthr f6a1_6_GoodsPrmry f6a1_6_GoodsOthr  f6a1_GdsInKindPrmry1 f6a1_GdsInKindPrmry2 f6a1_GdsInKindScndry1 f6a1_GdsInKindScndry2 f6a4_RcvAsPrft f6a5_Dividend  f6a5_RntGds f6a5_RntBldng f6a5_RntLnd f6a6_GovtAsstnc f6a6_Pension f6a6_IncomeInMaleRsrt f6a6_Alimony  f6a6_OthrAsstnc f6a6_FrndlyAsstnc f6a6_Zakath f6a6_OtherSrcs f6a8_CostMtrls f6a8_CostRprs f6a8_CostLbr  f6a0_Trnsprtn f6a1_Dealer f6a5_CostMtrls f6a5_CostRprs f6a5_CostLbr f6a7_Trnsprtn f6a8_Dealer
destring( f6a4_Sales2), replace
destring( f6a7_Sales3), replace
destring(f6a1_RcvdFrmPdEmplymnt), replace
destring( f6a1_1_WagesPrmry), replace
destring( f6a1_3_UniformPrmry), replace
destring( f6a1_5_SrvcsOthr), replace
destring( f6a1_GdsInKindScndry1), replace
destring(  f6a5_Dividend), replace
destring( f6a6_GovtAsstnc), replace
destring( f6a5_CostLbr), replace


gen inc_prod_main = f6a7_Sales1 + f6a7_Sales2 + f6a7_Sales3 -  f6a8_CostMtrls - f6a8_CostRprs - f6a8_CostLbr  - f6a0_Trnsprtn - f6a1_Dealer 
gen inc_prod_sec =  f6a4_Sales1 + f6a4_Sales2 + f6a4_Sales3 -  f6a5_CostMtrls - f6a5_CostRprs - f6a5_CostLbr  - f6a7_Trnsprtn - f6a8_Dealer 
gen inc_emp_main =  f6a1_1_WagesPrmry + f6a1_2_OvrtmPrmry + f6a1_3_UniformPrmry + f6a1_4_TravelPrmry +  f6a1_5_SrvcsPrmry + f6a1_6_GoodsPrmry 
gen inc_emp_sec =  f6a1_1_WagesOthr + f6a1_2_OvrtmOthr + f6a1_3_UniformOthr + f6a1_4_TravelOthr +  f6a1_5_SrvcsOthr + f6a1_6_GoodsOthr 

**************************************************

generate inc_prop =  f6a5_Dividend + f6a5_RntGds +  f6a5_RntBldng +  f6a5_RntLnd
generate inc_other =  f6a6_GovtAsstnc +  f6a6_Pension +  f6a6_IncomeInMaleRsrt +  f6a6_Alimony +  f6a6_OthrAsstnc +  f6a6_FrndlyAsstnc + f6a6_Zakath + f6a6_OtherSrcs
generate NONLBRINC = (inc_prop + inc_other)*12

gen NONLBRINC_def = NONLBRINC/SPATIALDEF


*outlier correction
foreach v in NONLBRINC_def  {
qui summ `v', d
  replace `v' = r(p50) if !inrange(`v', r(p50) - 3 * r(sd), r(p50) + 3*r(sd)) & !mi(`v')
}


gen NONLBRINC_mon_def = NONLBRINC_def/12

foreach v in NONLBRINC NONLBRINC_mon {
	gen `v'_PPP05 = `v'_def/PPP05DEFLATOR
	gen `v'_LCU05 = `v'_PPP05/LCUDEFLATOR
	
	}


generate inc_tot = INCOME_TOT_def + NONLBRINC_def
egen HHINCOME_TOT_def = sum(inc_tot), by(HID)

gen HHINCOME_TOT_mon_def = HHINCOME_TOT_def/12
gen HHINCOME_TOT_week_def = HHINCOME_TOT_def/52

foreach v in HHINCOME_TOT HHINCOME_TOT_mon HHINCOME_TOT_week {
	gen `v'_PPP05 = `v'_def/PPP05DEFLATOR
	gen `v'_LCU05 = `v'_def/LCUDEFLATOR

	}
	
			
drop  inc_prod_main inc_emp_main inc_prop inc_other inc_tot



generate XINCOME_MAIN_def=.
generate XINCOME_TOT_def=.
generate XNONLBRINC_def=.
generate IMP_FM_RENT_def=.

* above variables are not relevant for MDV, as info on implicit land rental cost not collected

gen _CONSUMPTION_ = .

sum  NumHHolds_RF_ NumPeople NumMale NumFemale NumbExpTrans NumbFoodTrans TotalExpendDay TotalPurchDay  TotalOwnProdDay TotalWageInKindDay TotalGiftsDay TotalRentDay TotalExpDayXrent TenureType ActualRentDay  ImputedRentDay TotalHHIncome Exppppd Rentpppd ExpXrentpppd Giftspppd Caloriepppd HHIncomepppd TotalCalorieDay  CalorieNeed CalorieRatio

* VPA2-00r-expenditure-by-household.dta was available in the original (non-raised) data folder, which was merged.  Variable "TotalExpendDay"
* is assumed to be TOTAL EXPENDITURE PER DAY, "Exppppd" is assumed to be EXPENDITURE PER  PERSON PER DAY, and "Rentpppd" is assumed to be RENT PER PERSON PER DAY - all of these variables are at household  level
* Variables Exppppd and Rentpppd are used

* tab TotalExpendDay
* tab Exppppd
* tab Rentpppd

generate TOTCONS = (Exppppd + Rentpppd)*365*HHSIZE 
generate TOTCONS_def =  TOTCONS/SPATIALDEF

* tab  TOTCONS_def
*outlier correction
foreach v in TOTCONS_def {
qui summ `v', d
  replace `v' = r(p50) if !inrange(`v', r(p50) - 3 * r(sd), r(p50) + 3*r(sd)) & !mi(`v')
}

generate CONS_PC_def =TOTCONS_def/HHSIZE
* tab  CONS_PC_def


generate adeq = 1 if HEAD==1
replace adeq = .5 if AGEY>=15 & mi(adeq)
replace adeq = .3 if AGEY<15 & mi(adeq)
tab adeq 
egen ADEQ = sum(adeq), by(HID)
tab ADEQ
drop adeq
* reversed the sequence of ADEQ and CONS_PEQA_def

generate CONS_PEQA_def = TOTCONS_def/ADEQ
* tab CONS_PEQA_def 

gen TOTCONS_mon_def =  TOTCONS_def /12
gen CONS_PC_mon_def = CONS_PC_def /12
gen CONS_PEQA_mon_def = CONS_PEQA_def /12


foreach v in TOTCONS CONS_PC CONS_PEQA TOTCONS_mon CONS_PC_mon CONS_PEQA_mon {
	
	gen `v'_PPP05 = `v'_def/PPP05DEFLATOR
	gen `v'_LCU05 = `v'_PPP05/LCUDEFLATOR
	
	}



* for regular and extreme poverty lines, 7.5 and 15 rufiyaa per person per day were used (from VPA2 main report,  page 51

generate REGPLINE_ann = 15*365

generate EXTPLINE_ann = 7.5*365


generate INTPLINE_ann = 1.25*PPP05DEFLATOR*365
tab INTPLINE_ann
* VPA-2 report used international poverty line (p51) to be 4.34 rifiyaa per person per day

* tab  Island
generate STRATA = .
generate PSU =  Island
* should Island be used as STRATA? not clear fromt the main report (p195 - 206)

* tab  NumHHolds_RF_
generate WEIGHT =  NumHHolds_RF_


generate YEAR_def = 2004


foreach v in  XINCOME_MAIN XINCOME_TOT  XNONLBRINC{
gen `v'_PPP05 = `v'_def/PPP05DEFLATOR
}

foreach v in REGPLINE_ann EXTPLINE_ann{
gen `v'_PPP05 = `v'/PPP05DEFLATOR
gen `v'_LCU05 = `v'_PPP05/LCUDEFLATOR
}


generate _SKILLS_=.

tab a7_EdctnLvlAchvd
generate TRAINING = (a7_EdctnLvlAchvd == 16)
replace TRAINING = . if a7_EdctnLvlAchvd == .
tab TRAINING

generate EDLEVEL_VT = CONEDLEVEL if TRAINING == 1
label values EDLEVEL_VT edlevel
tab  EDLEVEL_VT

generate VT_CATEG = .

generate SCHOOL_LEAVE = .

tab a5_AttndEdctnInsttNow TRAINING
* a5_AttndEdctnInsttNow has additional response (0) outside YES/NO
generate CURRENT_ATTEND = (TRAINING == 1 & a5_AttndEdctnInsttNow != 2)
replace CURRENT_ATTEND = . if TRAINING == . | TRAINING == 0
tab  CURRENT_ATTEND

generate DURATION_UNEMP = .
* info not available


egen NO_ADULT = sum(AGEY >= 15 & AGEY <= 64), by(HID)
tab NO_ADULT

egen NO_CHILDREN = sum(AGEY >= 0 & AGEY <= 14), by(HID)
tab NO_CHILDREN

egen NO_ELDERLY = sum(AGEY >= 65 & AGEY < .), by(HID)
tab NO_ELDERLY 

gen ENROL_CHILDREN = CURRENT_ATTEND==1 if AGEY >= 5 & AGEY <= 14

gen SCHOOL_DIST = .

* tab f6a6_Pension
generate PENSION = (f6a6_Pension >= 50 & f6a6_Pension <= 2400)
replace PENSION = . if f6a6_Pension == .
tab PENSION

generate PENSION_INCOME = f6a6_Pension
tab PENSION_INCOME

generate CONTRIBUTORY_HEALTH = .
* no info on health insurance

xtile HHINCOME_DECILE =  HHINCOME_TOT_def, nq(10)
tab HHINCOME_DECILE

gen PCHHINCOME_TOT_def = HHINCOME_TOT_def / HHSIZE
*tab PCHHINCOME_TOT_def

xtile DEC_PCHHINCOME_TOT_def =  PCHHINCOME_TOT_def, nq(10)
tab  DEC_PCHHINCOME_TOT_def 

generate PC_CONSUMPTION = CONS_PC_def

xtile DECILES_PC_CONSUMPTION =  PC_CONSUMPTION, nq(10)
tab  DECILES_PC_CONSUMPTION  

gen TRANSFER_TYPE = .
* not sure about the definition - alimony (f6a6_Alimony) and Zakath (f6a6_Zakath)?

gen TENURE = .


drop  inter_edlevel inc_prod_sec inc_emp_sec NONLBRINC TOTCONS



**************** labelling the created variables
label var COUNTRY 		  "Country Name / Code"
label var YEAR 			  "Survey Year"
label var HID 			  "Household Identifier"
label var INDID			  "Individual Identifier"
label var REGION                "Region / Province"
label var URBAN                 "Urban or rural location"
label var MALE                  "Gender"
label var AGEY                  "Age in Completed years"
label var HEAD                  "Household head"
label var HEAD_UNIQUE   	  "Household head unique"
label var HHSIZE                "Household size"
label var ETHNICITY             "Ethnicity"
label var LANGUAGE              "Language"
label var RELIGION              "Religion"
label var MARSTAT               "Marital Status"
label var EDLEVEL               "Level of education"
label var EDYEARS               "Years of education"
label var CONEDLEVEL     	  "Constructed level of education"
label var CONEDYEARS		  "Constructed years of education"
label var EMP_STAT              "Employment Status"
label var WHYINACTIVE 	 	  "Reasons for inactivity"
label var EMPLOYED              "Employed"
label var UNEMPLYD              "Unemployed"
label var DISCRGD               "Discouraged"
label var INACTIVE              "Inactive"
label var SECTOR_MAIN   	  "Int Stand Ind Class-Main Job-expanded"
label var OCC_MAIN              "Int Stand Class Occ-Main Job-ISCO88"
label var PUBLIC                "Public employee"
label var EMPTYPE_MAIN          "Work category for main job"
label var SECONDJOB             "Second job"
label var NUMJOBS12MO   	  "Num of jobs worked last 12 mon"
label var AG_WRK_MAIN           "Agricultural job"
label var HOURWRKMAIN           "Hrs wrk by ind main job (annual)"
label var HOURWRKTOT            "Hrs wrk by ind in all jobs (ann)"
label var HOURWRKTYPE           "Type of hours worked"
label var INCOME_MAIN_def       "Def annual income fr main job"
label var INCOME_TOT_def        "Def annual income fr all jobs"
label var NONLBRINC_def         "Def annual non labor income-HH"
label var HHINCOME_TOT_def      "Def annual tot income of HH in year"
label var XINCOME_MAIN_def      "Def totai income at HH in year"
label var XINCOME_TOT_def       "Adjust Def annual income fr ind main job"
label var XNONLBRINC_def        "Adjust Def annual non labor income HH"
label var IMP_FM_RENT_def       "Implicit farm rental value"
label var TOTCONS_def           "Def annual tot consumption HH"
label var CONS_PC_def           "Def annual tot consumption pc"
label var CONS_PEQA_def         "Def annual tot consumptin per adult equ"
label var ADEQ                  "HH sixe in adult equi"
label var REGPLINE_ann          "Regular poverty line, annual"
label var EXTPLINE_ann          "Extreme poverty line, annual"
label var INTPLINE_ann          "Int poverty line"
label var STRATA                "Sampling strata ID"
label var PSU                   "Primary sampling unit"
label var WEIGHT                "Household weights"
label var SPATIALDEF            "Regional deflator"
label var YEAR_def              "Deflator base year"
label var PPP05DEFLATOR         "PPP Def for consum in 2005"
label var LCUDEFLATOR         "Local currency Def for consum in 2005"
label var INCOME_MAIN_PPP05     "PPP05 Def ann income from Main job"
label var INCOME_TOT_PPP05      "PPP05 Def ann income from all jobs"
label var NONLBRINC_PPP05       "PPP05 Def ann non labor income HH"
label var TOTCONS_PPP05 	  "PPP05 Def ann tot consum for HH"
label var CONS_PC_PPP05 	  "PPP05 Def ann tot consum per cap"
label var CONS_PEQA_PPP05       "PPP05 Def ann tot consum per adul equi"
label var HHINCOME_TOT_PPP05    "PPP05 Def tot income at HH in year"
label var XINCOME_MAIN_PPP05    "PPP05 Adjs Def ann income from main job"
label var XINCOME_TOT_PPP05     "PPP05 Adjs Def ann income from all jobs"
label var XNONLBRINC_PPP05      "PPP05 Adjs Def ann non labor income HH"
label var REGPLINE_ann_PPP05    "PPP05 Def regular poverty line, annual"
label var EXTPLINE_ann_PPP05    "PPP05 Def ann extreme poverty line"
label var TRAINING              "If vocational/tech training"
label var EDLEVEL_VT            "Education categories"
label var VT_CATEG              "Vocational/Tech edu"
label var SCHOOL_LEAVE          "School leaving age"
label var CURRENT_ATTEND        "Attendance status" 
label var DURATION_UNEMP        "Duration of unemployment"
label var CASUAL_OR_WAGE        "Casual or wage work"
label var NO_ADULT              "Number of adults"
label var NO_CHILDREN           "Number of children"
label var NO_ELDERLY            "Number of elderly"
label var ENROL_CHILDREN        "Children present Currently attending to school"
label var SCHOOL_DIST		"Distance of nearest school"
label var PENSION               "Whether enrolled in a formal pension sys"
label var PENSION_INCOME        "Money received from pension"
label var CONTRIBUTORY_HEALTH   "Whether enrolled in a contri health insurance"
label var HHINCOME_DECILE       "Income deciles"
label var PCHHINCOME_TOT_def    "Per capita hh total income Def"
label var DEC_PCHHINCOME_TOT_def	"Per capita hh income deciles"
label var PC_CONSUMPTION        "Per capita consumption"
label var DECILES_PC_CONSUMPTION "Deciles of per capita consumption"
label var TRANSFER_TYPE          "Transfer type"
label var TENURE                 "Tenure"


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
cap 	label	var	 EMPTYPE_SECOND	"	Work category for secondary job	"
cap 	label	var	 SECTOR_SECOND	"	sector classification for secondary job	"
cap	label	var	 OCC_SEC	"	ISCO-88 occupation classification for main job	" 


qui compress
save "`dataproc'\MDV_VPA_2004_2004.dta", replace
log close
