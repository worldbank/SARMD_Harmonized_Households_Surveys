#delimit; 

cd "C:\Labor Flagship\BHUTAN\Bhutan 2003\Data\DataProc"; 

use BTN_BLSS_2003_2003, clear;

replace YEAR_def = 2003;  

gen current_attend = 0 if !mi(b22_q8);
replace current_attend = 1 if  b22_q9==1;

replace CURRENT_ATTEND = current_attend;
replace ENROL_CHILDREN = CURRENT_ATTEND if inrange(AGEY, 5, 14);

drop current_attend ;

cap gen CONEDLEVEL_DAVID = .;

recode CONEDYEARS (0 = 0) (1/5 = 1) (6/11= 2) (12 = 3) (13/20 = 4), gen(edlevel_david); 
replace edlevel_david = 0 if b22_q8==2; 
replace CONEDLEVEL_DAVID = edlevel_david; 
drop edlevel_david; 
 
replace EDYEARS = 0 if b22_q8==2 & mi(EDYEARS); 
replace CONEDYEARS = 0 if b22_q8==2 & mi(CONEDYEARS);

cap gen REGION_mahesh = .; 
recode REGION (11/16 41 = 1) 
	(17 42/44 21/23 = 2) 
	(31/36 = 3), gen(region_mahesh); 
replace REGION_mahesh = region_mahesh; 
cap label define region_mahesh 1 "Western" 2 "Central" 3 "Eastern"; 
label values REGION_mahesh region_mahesh; 

drop region_mahesh; 
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

cap gen WHYINACTIVE_mahesh = .; 
recode WHYINACTIVE (3 4 7 10 11 = 6) (5 = 2) (6 = 3) (8 = 5) (9 = 4) , gen(whyin); 
replace WHYINACTIVE_mahesh = whyin; drop whyin; 
replace WHYINACTIVE_mahesh = 1 if DISCRGD==1; 

replace WHYINACTIVE_mahesh = . if !inlist(EMP_STAT, 3, 4); 
cap label define whyin 1 "Discouraged" 2 "Student/Education" 3 "HH duties" 
	4 "Illess/Disability" 5 "Old/Retired" 6 "Other"; 
label values WHYINACTIVE_mahesh whyin; 

cap gen EMPTYPE_SECOND = . ; 
recode b24_q43 (1 2 = 1) (3 = 3) (4 = 2) (5 6 = 4) (nonmiss = .), gen(emptype_sec); 
replace EMPTYPE_SECOND = emptype_sec if SECONDJOB==1; drop emptype_sec; 

cap gen SECTOR_SECOND = .; 
recode b24_q45 (6 7 = 6) (8 = 7) (9 10 = 8) (11 = 9) (12/14 = 10), gen(sector_sec); 
replace SECTOR_SECOND = sector_sec if SECONDJOB==1; drop sector_sec; 

qui compress;

save, replace; 
