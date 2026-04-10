#delimit;
capture drop _all;
capture macro drop _all;
capture program drop _all;
set more off;
capture log close;
set mem 200m;

global prg "S:\Pinaki\Stuff\Self_employ\se_nss50\Prg";
global dta "S:\Pinaki\Stuff\Self_employ\se_nss50\Dta";
global raw "S:\Pinaki\NSS50_Sch10";
global log "S:\Pinaki\Stuff\Self_employ\se_nss50\Log";

/*
global prg "C:\Users\pinaki\Desktop\Pinaki\Self_employ\se_nss50\Prg";
global dta "C:\Users\pinaki\Desktop\Pinaki\Self_employ\se_nss50\Dta";
global log "C:\Users\pinaki\Desktop\Pinaki\Self_employ\se_nss50\Log";
*/

capture cd "$prg";
if _rc~=0 {;
global prg ;
global dta ;
global raw ;
global log ;
};

log using "$log\se_nss50.log", replace;

#delimit cr

/*********************************************/
use "$raw\D240PR_U.dta", clear
gen hh_wt=mlt/100

/*********/
recode sts_prn (0=.) (4=.) (13=.) (57=.) (82=.)
recode sts_sub (11=11) (12=12) (21=21) (31=31) (41=41) (51=51) (else=.)

gen sts_all=sts_prn
replace sts_all=sts_sub if sts_prn>51 & sts_sub<=51

gen prn_sts=sts_prn
recode prn_sts (11/21=1) (31=2) (41/51=3) (81=4) (else=5)

gen sub_sts=sts_sub
recode sub_sts (11/21=1) (31=2) (41/51=3)

gen all_sts=sts_all
recode all_sts (11/21=1) (31=2) (41/51=3) (81=4) (else=5)

label define status 1 "Self-employed" 2 "Regular" 3 "Casual" 4 "Unemployed" 5 "out-LF"
label values prn_sts status
label values sub_sts status
label values all_sts status

/***********/
gen prn_lfp=.
replace prn_lfp=1 if prn_sts<=4
replace prn_lfp=2 if prn_sts>4
  
gen prn_wfp=.
replace prn_wfp=1 if prn_sts<=3
replace prn_wfp=2 if prn_sts>3

gen all_lfp=.
replace all_lfp=1 if all_sts<=4
replace all_lfp=2 if all_sts>4
  
gen all_wfp=.
replace all_wfp=1 if all_sts<=3
replace all_wfp=2 if all_sts>3

label define lfp 1 "in-LF" 2 "out-LF"
label define wfp 1 "in-WF" 2 "out-WF"
label values prn_lfp lfp
label values all_lfp lfp
label values prn_wfp wfp
label values all_wfp wfp

/***********/
gen self_prn=sts_prn
recode self_prn (11=1) (12=2) (21=3) (else=.)

gen self_sub=sts_sub
recode self_sub (11=1) (12=2) (21=3) (else=.)

gen self_all=sts_all
recode self_all (11=1) (12=2) (21=3) (else=.)

label define self 1 "Own-account" 2 "Employer" 3 "Helper"
label values self_prn self
label values self_sub self
label values self_all self

/***********/
gen nic_all=nic_prn
replace nic_all=nic_sub if nic_prn=="" & nic_sub~="" 
gen ind_p=substr(nic_prn,1,1)
gen ind_s=substr(nic_sub,1,1)
gen ind_a=substr(nic_all,1,1)
replace ind_p="10" if ind_p=="X"|ind_p=="x"|ind_p=="Y"
replace ind_s="10" if ind_s=="X"|ind_s=="x"|ind_s=="Y"
replace ind_a="10" if ind_a=="X"|ind_a=="x"|ind_a=="Y"

gen prn_ind=real(ind_p)
gen sub_ind=real(ind_s)
gen all_ind=real(ind_a)
recode prn_ind (0=1) (1=2) (2=3) (3=3) (4=4) (5=5) (6=6) (7=7) (8=8) (9=9) (10=10)
recode sub_ind (0=1) (1=2) (2=3) (3=3) (4=4) (5=5) (6=6) (7=7) (8=8) (9=9) (10=10)
recode all_ind (0=1) (1=2) (2=3) (3=3) (4=4) (5=5) (6=6) (7=7) (8=8) (9=9) (10=10)

drop ind_p ind_s ind_a
label define industry 1 "Ariculture, etc." 2 "Mining & Quarrying" 3 "Manufacturing" 4 "Electricity,Water,etc." /*
*/ 5 "Construction" 6 "Trade,Hotel & Restaurants" 7 "Transport,etc." 8 "Fin. Inter,Business act,etc." /*
*/ 9 "Pub Admn.,Edu,Commn.Services,etc." 10 "N.D"
label values prn_ind industry
label values sub_ind industry
label values all_ind industry

/***********/
gen nco_all=nco_prn
replace nco_all=nco_sub if nco_prn=="" & nco_sub~=""
gen nco_p1 = substr(nco_prn,1,1)
gen nco_s1 = substr(nco_sub,1,1)
gen nco_a1 = substr(nco_all,1,1)
replace nco_p1="10" if nco_p1=="X"
replace nco_s1="10" if nco_s1=="X"
replace nco_a1="10" if nco_a1=="X"
gen prn_ocp = real(nco_p1)
gen sub_ocp = real(nco_s1)
gen all_ocp = real(nco_a1)

recode prn_ocp (0=1) (1=1) (2=2) (3=3) (4=4) (5=5) (6=6) (7=7) (8=7) (9=7) (10=8)
recode sub_ocp (0=1) (1=1) (2=2) (3=3) (4=4) (5=5) (6=6) (7=7) (8=7) (9=7) (10=8)
recode all_ocp (0=1) (1=1) (2=2) (3=3) (4=4) (5=5) (6=6) (7=7) (8=7) (9=7) (10=8)
drop nco_p1 nco_s1 nco_a1
label define ocp 1 "Professional, Tech.,etc." 2 "Adm., Manager, etc." 3 "Clecrk" 4 "Sales" 5 "Service" /*
*/ 6 "Farmers, etc." 7 "Production, Labour,etc" 8 "N.C"
label values prn_ocp ocp
label values sub_ocp ocp
label values all_ocp ocp

/***********/
replace state=34 if state==5 & region==1
replace state=35 if state==13 & region==1
replace state=36 if state==25 & region==1 

label define state 2 "Andhra Pradesh"  3 "Arunachal Pradesh" 4 "Assam" 5 "Bihar" 6 "Goa" 7 "Gujarat" /* 
*/ 8 "Haryana" 9 "Himachal Pradesh" 10 "Jammu & Kashmir" 11 "Karnataka" 12 "Kerala" 13 "Madhya Pradesh" /* 
*/ 14 "Maharashtra" 15 "manipur" 16 "Meghalaya" 17 "Mizoram" 18 "Nagaland" 19 "Orissa" 20 "Punjab" 21 "Rajasthan" /* 
*/ 22 "Sikkim" 23 "Tamil Nadu" 24 "Tripura" 25 "Uttar Pradesh" 26 "West Bengal" 27 "A & N islands" 28 "Chandigarh" /* 
*/ 29 "D & N Haveli" 30 "Daman & Diu" 31 "Delhi" 32 "Lakshadweep" 33 "Pondicherry" 34 "Jharkhand" /*
*/ 35 "Chattisgarh" 36 "Uttarakhand" 99 "Others"
label values state state

gen state_cd=state
replace state_cd=99 if (state_cd==3|state_cd==6|state_cd==10|state_cd==15|state_cd==16|state_cd==17|state_cd==18|/*
*/ state_cd==22|state_cd==24|state_cd==27|state_cd==28|state_cd==29|state_cd==30|state_cd==31|state_cd==32|state_cd==33)
label values state_cd state

/***********/
gen mpce = hh_pce/100

xtile qnt_mpce_r = mpce if sector==1 [aw=hh_wt], nq(5) 
xtile qnt_mpce_u = mpce if sector==2 [aw=hh_wt], nq(5) 

gen qnt_mpce=.
replace qnt_mpce=qnt_mpce_r if sector==1
replace qnt_mpce=qnt_mpce_u if sector==2
drop qnt_mpce_r qnt_mpce_u
label define qnt_mpce 1 "Q1(lowest)" 2 "Q2" 3 "Q3" 4 "Q4" 5 "Q5(highest)"
label values qnt_mpce qnt_mpce

/***********/
sort hh_id
gen flag=1
egen hh_size=sum(flag),by(hh_id)
drop flag

recode sector (1=0) (2=1)
label define sector 0 "Rural" 1 "Urban"
label values sector sector

gen sex_n = real(sex)
order hh_id-sex sex_n
drop sex
rename sex_n sex
recode sex (1=0) (2=1)
label define sex 0 "Male" 1 "Female"
label values sex sex

gen hh_head=relation
recode hh_head (1=1) (else=0)
label define relation 1 "Head-hh" 0 "Others"
label values hh_head relation

gen edu=gen_edu
recode edu (.=0) (2/6=2) (7=3) (8/9=4) (10/13=5)
label define edu 0 "N.D" 1 "Illiterate" 2 "Literate & upto Primary" 3 "Middle" 4 "Secondary & HS" 5 "Graduate & above" 
label values edu edu

gen crnt_atnd=attend
recode crnt_atnd (.=1) (1=1) (2/19=2)
label define crnt_atnd 1 "not attending" 2 "currently attending"
label values crnt_atnd crnt_atnd

recode s_grp (9=3)
label define s_grp 0 "N.D" 1 "ST" 2 "SC" 3 "Others" 
label values s_grp s_grp

recode religion (5/9=5)
label define religion 0 "N.D" 1 "Hindu" 2 "Muslim" 3 "Christian" 4 "Sikh" 5 "Others"
label values religion religion

gen hhtype_r = hh_type if sector==0
gen hhtype_u = hh_type if sector==1
recode hhtype_r (0=.)
recode hhtype_u (0=.)
label define type_r 1 "Self Employed-NonAg" 2 "Ag Labour" 3 "Other Labour" 4 "Self Employed-Ag" 9 "Others"
label define type_u 1 "Self Employed" 2 "Regular" 3 "Casual" 9 "Others"
label values hhtype_r type_r
label values hhtype_u type_u

gen group_age = age
recode group_age (0/4=1) (5/9=2) (10/14=3) (15/19=4) (20/24=5) (25/29=6) (30/34=7) (35/39=8) (40/44=9) (45/49=10) /*
*/ (50/54=11) (55/59=12) (60/64=13) (else=14)
label define group_age 1 "0-4" 2 "5-9" 3 "10-14" 4 "15-19" 5 "20-24" 6 "25-29" 7 "30-34" 8 "35-39" 9 "40-44" 10 "45-49" /*
*/ 11 "50-54" 12 "55-59" 13 "60-64" 14 "65+"
label values group_age group_age

gen worker_all=sts_prn
replace worker_all=sts_sub if sts_prn>51 & sts_sub<=51
recode worker_all (11=1) (12=2) (21=3) (31=4) (41=5) (51=6) (else=.)

label define worker 1 "Own-account" 2 "Employer" 3 "Helper" 4 "Regular" 5 "Casual:Pub" 6 "Casual:Non-pub"
label values worker_all worker

gen agnag_all = (all_ind>1)
replace agnag_all=. if all_ind==.

sort hh_id
save "$dta\se_nss50.dta", replace
clear

/*****/
sort sector
by sector: tab all_sts sex if all_sts<=3 [aw=hh_wt], nof col
by sector: tab worker_all sex if worker_all<=3 [aw=hh_wt], nof col
by sector: tab worker_all sex if worker_all>=5 [aw=hh_wt], nof col

replace agnag_all = agnag_all*100

sort sector
by sector: table all_sts sex if all_sts<=3 [aw=hh_wt], c(mean agnag_all)

recode agnag_all (100=1)
by sector: tab worker_all sex if agnag_all==1 & worker_all<=3 [aw=hh_wt], nof col
by sector: tab worker_all sex if agnag_all==1 & worker_all>=5 [aw=hh_wt], nof col

/***/
sort sex
by sex : tab worker_all sector [aw=hh_wt], nof col
tab worker_all sector [aw=hh_wt], nof col

sort sex
by sex : tab all_sts sector if all_sts<4 [aw=hh_wt], nof col
tab all_sts sector if all_sts<4 [aw=hh_wt], nof col

/***/
sort sex
by sex: tab worker_all sector if agnag_all==1 [aw=hh_wt], nof col
tab worker_all sector if agnag_all==1 [aw=hh_wt], nof col

sort sex
by sex: tab all_sts sector if all_sts<4 & agnag_all==1  [aw=hh_wt], nof col
tab all_sts sector if all_sts<4 & agnag_all==1 [aw=hh_wt], nof col


/***Labourforce, Workforce & Unemployment**/
sort sector
by sector: tab prn_lfp sex [aw=hh_wt], nof col
by sector: tab all_lfp sex [aw=hh_wt], nof col
by sector: tab prn_wfp sex [aw=hh_wt], nof col
by sector: tab all_wfp sex [aw=hh_wt], nof col

tab prn_sts sector if prn_wfp==1 [aw=hh_wt],nof col 
tab all_sts sector if all_wfp==1 [aw=hh_wt],nof col 


/************************************/
use "$dta\se_nss50.dta", clear

label define agnag 0 "Ag" 1 "Non-Ag"
label values agnag_all agnag 

tab agnag_all sector if all_wfp==1 [aw=hh_wt], nof col

sort hh_id
save "$dta\se_nss50.dta", replace
clear
log close

/***********************/
use "$dta\se_nss50.dta", clear

tab self_all sector if agnag_all==1 [aw=hh_wt], nof col
clear
log close


/***********************/
use "$dta\se_nss50.dta", clear

gen age_grp=age
recode age_grp (0/14=0) (15/59=100) (60/99=0)

*Step1: Share of 15-59 in the Workforce
table sector sex if all_wfp==1 [aw=hh_wt], c(mean age_grp) row col 

tab all_ind sector if all_wfp==1 & age_grp==100 & all_ind!=10 [aw=hh_wt], nof col

clear
log close


