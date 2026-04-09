#delimit; 

cd "C:\Labor Flagship\MALDIVES\VPA2004\Data\DataProc"; 

use MDV_VPA_2004_2004, clear;

recode  a7_EdctnLvlAchvd (1/4 = 1) (5/7 = 2) (8/11 = 3) (12/15 = 4) (18/20 0 = 0) (16 17 = 4), gen(comped); 
replace comped = 0 if mi(comped) &  a4_AttndEdctnInsttPast==2; 

replace CONEDLEVEL = comped; drop comped; 
replace CONEDYEARS = 0 if mi(CONEDYEARS) & CONEDLEVEL==0; 

cap gen INFORMAL =.; 
cap gen FORMAL = .; 
replace FORMAL = .; 
replace INFORMAL = .; 


gen informal = 1 if EMPTYPE_MAIN==4; 
replace informal = inlist(CONEDLEVEL, 0, 1, 2, 3) if EMPTYPE_MAIN==3; 
replace informal = 1 if CASUAL_OR_WAGE==1 & EMPTYPE_MAIN==1;
replace informal = 0 if PUBLIC ==1 & EMPTYPE_MAIN==1 & mi(informal);

replace informal = 1 if AG_WRK_MAIN==1; 

replace INFORMAL = informal==1 if EMPLOYED==1;
replace FORMAL = informal==0 if EMPLOYED==1; 
drop informal; 

cap gen WHYINACTIVE_mahesh = .; 
recode WHYINACTIVE (1 2 5 8 9 = 6) (3 = 4) (4 7 = 3) (6 = 2), gen(whyin); 
replace WHYINACTIVE_mahesh = whyin; drop whyin; 
replace WHYINACTIVE_mahesh = 1 if DISCRGD==1;
replace WHYINACTIVE_mahesh = 2 if a9_ActvtyMstEnggd==2 & mi(WHYINACTIVE_mahesh); 
replace WHYINACTIVE_mahesh = 3 if  a9_ActvtyMstEnggd==3 & mi(WHYINACTIVE_mahesh); 
replace WHYINACTIVE_mahesh = 6 if  a9_ActvtyMstEnggd==4 & mi(WHYINACTIVE_mahesh); 

replace WHYINACTIVE_mahesh = . if !inlist(EMP_STAT, 3, 4); 
cap label define whyin 1 "Discouraged" 2 "Student/Education" 3 "HH duties" 
	4 "Illess/Disability" 5 "Old/Retired" 6 "Other"; 
label values WHYINACTIVE_mahesh whyin; 

cap gen EMPTYPE_SECOND = . ; 
recode f6a9_EmpStatus (1 = 2) (2 = 1) ( 4 5 = 4), gen(emptype_sec); 
replace EMPTYPE_SECOND = emptype_sec if SECONDJOB==1; drop emptype_sec; 

cap gen SECTOR_SECOND = .; 
gen sect_sec = int(real(f6a1_isic)/100); 
recode sect_sec (0/5 = 1) (10/14 = 2) (15/37 = 3) (40 41 = 4) (45 = 5) 
	(50/55 = 6) (60/64 = 7) (65/74 = 8) (75 = 9) (80/99 = 10); 
replace SECTOR_SECOND = sect_sec if SECONDJOB==1; drop sect_sec; 

qui compress;
save, replace; 
