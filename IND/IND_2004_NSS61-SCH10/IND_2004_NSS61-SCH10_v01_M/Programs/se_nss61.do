#delimit;
capture drop _all;
capture macro drop _all;
capture program drop _all;
set more off;
capture log close;
set mem 300m;

global prg "S:\Pinaki\Stuff\Self_employ\se_nss61\Prg";
global dta "S:\Pinaki\Stuff\Self_employ\se_nss61\Dta";
global log "S:\Pinaki\Stuff\Self_employ\se_nss61\Log";

/*
global prg "C:\Users\pinaki\Desktop\Pinaki\Self_employ\se_nss61\Prg";
global dta "C:\Users\pinaki\Desktop\Pinaki\Self_employ\se_nss61\Dta";
global log "C:\Users\pinaki\Desktop\Pinaki\Self_employ\se_nss61\Log";
*/

capture cd "$prg";
if _rc~=0 {;
global prg ;
global dta ;
global raw ;
global log ;
};

log using "$log\se_nss61.log", replace;

#delimit cr

/********************************************************************/
use "$dta\iler_eus_61_rural_urban.dta", clear
drop empl_prn work_prn empl_all work_all all_nic ind_prn ind_all lfpr_prn all_nco lfpr_all mjr_stat age_grp qnt_mpce occp_prn occp_all edu1 filter_ edu2 age15 tech /*
*/ nic_p3 frm_nfrm

rename prn_sts sts_prn 
rename prn_nic nic_prn
rename prn_nco nco_prn
rename sbs_sts sts_sub 
rename sbs_nic nic_sub
rename sbs_nco nco_sub
rename id hh_id
rename attnd attend

drop nss nsc mlt_ss mlt_sr hh_mlt
rename mlt hh_wt 
sort hh_id

/***** Broad Employment Status (ps & all)****/
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

/***** Labourforce and Workforce (ps & all)******/
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

/****** Self-employment (ps & all) *****/
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

/***** Industry (ps & all)******/
gen nic_all=nic_prn
replace nic_all=nic_sub if nic_prn=="" & nic_sub~=""
gen nic_p5 = real(nic_prn) 
gen nic_s5 = real(nic_sub)
gen nic_a5 = real(nic_all)
gen nic_p2 = int(nic_p5/1000)
gen nic_s2 = int(nic_s5/1000)
gen nic_a2 = int(nic_a5/1000)

recode nic_p2 (1/5=1) (10/14=2) (15/37=3) (40/41=4) (45=5) (50/55=6) (60/64=7) (65/74=8) (75/99=9)
recode nic_s2 (1/5=1) (10/14=2) (15/37=3) (40/41=4) (45=5) (50/55=6) (60/64=7) (65/74=8) (75/99=9)
recode nic_a2 (1/5=1) (10/14=2) (15/37=3) (40/41=4) (45=5) (50/55=6) (60/64=7) (65/74=8) (75/99=9)
drop nic_p5 nic_s5 nic_a5
rename nic_p2 prn_ind
rename nic_s2 sub_ind
rename nic_a2 all_ind
label define industry 1 "Agriculture, etc." 2 "Mining & Quarrying" 3 "Manufacturing" 4 "Electricity,Water,etc." /*
*/ 5 "Construction" 6 "Trade,Hotel & Restaurants" 7 "Transport,etc." 8 "Fin. Inter,Business act,etc." /*
*/ 9 "Pub Admn.,Edu,Commn.Services,etc." 10 "N.D"
label values prn_ind industry
label values sub_ind industry
label values all_ind industry

/*** Industry - 3 groups ***/
gen    ind_ps  = prn_ind
recode ind_ps  (1=1) (2/5=2) (6/9=3)
gen    ind_ss  = sub_ind
recode ind_ss  (1=1) (2/5=2) (6/9=3)
gen    ind_us  = all_ind
recode ind_us  (1=1) (2/5=2) (6/9=3)

label define ind 1 "Primary" 2 "Secondary" 3 "Tertiary"
label values ind_ps ind
label values ind_ss ind
label values ind_us ind

/*****Household Principal Industry ******/
gen nic_h5 = real(hh_nic) 
gen nic_h2 = int(nic_h5/1000)
recode nic_h2 (1/5=1) (10/14=2) (15/37=3) (40/41=4) (45=5) (50/55=6) (60/64=7) (65/74=8) (75/99=9)
drop nic_h5
rename nic_h2 hh_ind
label values hh_ind industry

/***** Occupation (ps & all) ******/
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

/*** Enterrpise Characteristics (usual status) ***/

/*** Location ***/
gen all_lctn=prn_lctn
replace all_lctn=sbs_lctn if prn_lctn=="" & sbs_lctn!=""
gen nall_lctn=real(all_lctn)
drop all_lctn
rename nall_lctn all_lctn
recode all_lctn (21=11) (22=12) (23=13) (24=14) (25=15) (26=16) (27=17) (29=19) 
/*workers residing in rural areas with urban work location */ 
label define location 10 "no fixed place" 11 "own dwelling" 12 "own entrp/unit/off/shop-outside own dwelling" /*
*/ 13 "employer's dwelling" 14 "employer's entrp/unit/off/shop-outside dwelling" 15 "street-fixed place" /*
*/ 16 "street-no fixed place" 17 "construction site" 19 "others"
label values all_lctn location
label var all_lctn "Location"

/*** Enterprise type ***/
gen all_ent=prn_ent
replace all_ent=sbs_ent if prn_ent=="" & sbs_ent!=""
gen nall_ent=real(all_ent)
drop all_ent
rename nall_ent all_ent
label define enterprise 1 "proprietary-male" 2 "proprietary-female" 3 "partnership-same HH" 4 "partnership-diff HH" /*
*/ 5 "govt/pub" 6 "pub/pvt-ltd co" 7 "co-op/trust/non-profit" 8 "employer's HH" 9 "others"
label values all_ent enterprise
label var all_ent "Enterprise"

/*** Electricity ***/
gen all_pwr=prn_pwr
replace all_pwr=sbs_pwr if prn_pwr=="" & sbs_pwr!=""
gen nall_pwr=real(all_pwr)
drop all_pwr
rename nall_pwr all_pwr
label define power 1 "yes" 2 "no" 9 "not known"
label values all_pwr power
label var all_pwr "Use of Electricity for Production"

/*** # Worker ***/
gen all_wrk=prn_wrk
replace all_wrk=sbs_wrk if prn_wrk=="" & sbs_wrk!=""
gen nall_wrk=real(all_wrk)
drop all_wrk
rename nall_wrk all_wrk
label define no_worker 1 "less than 6" 2 "6-9" 3 "10-19" 4 "20 & >" 9 "not known"
label values all_wrk no_worker
label var all_wrk "# of Workers"

/*** Job Contract ***/
gen all_cnt=prn_cnt
replace all_cnt=sbs_cnt if prn_cnt=="" & sbs_cnt!=""
gen nall_cnt=real(all_cnt)
drop all_cnt
rename nall_cnt all_cnt
recode all_cnt (1=1) (2/4=2)
label define contract 1 "not written" 2 "written"
label values all_cnt contract
label var all_cnt "Contract"

/*** Paid Leave ***/
gen all_leav=prn_leav
replace all_leav=sbs_leav if prn_leav=="" & sbs_leav!=""
gen nall_leav=real(all_leav)
drop all_leav
rename nall_leav all_leav
label define leave 1 "yes" 2 "no"
label values all_leav leave
label var all_leav "Eligibility for Paid Leave"

/*** Social Secirity ***/
gen all_scrt=prn_scrt
replace all_scrt=sbs_scrt if prn_scrt=="" & sbs_scrt!=""
gen nall_scrt=real(all_scrt)
drop all_scrt
rename nall_scrt all_scrt
recode all_scrt (1/7=1) (8=2)
label define social 1 "yes" 2 "no"
label values all_scrt social
label var all_scrt "Eligibility for Social Security" 

/*** Payment ***/
gen all_pmnt=prn_pmnt
replace all_pmnt=sbs_pmnt if prn_pmnt=="" & sbs_pmnt!=""
gen nall_pmnt=real(all_pmnt)
drop all_pmnt
rename nall_pmnt all_pmnt
label define payment 1 "regular monthly salary" 2 "regular weekly payment" 3 "daily payment" 4 "piece rate payment" /*
*/ 5 "others"
label values all_pmnt payment
label var all_pmnt "Method of Payment"

/*** Org-Uorg - Enterprise & Employment (us) ***/
gen ent_uorg=.
replace ent_uorg=1 if (all_wfp==1 & all_ind==1 & all_ent==. & (nic_all!="01116"|nic_all!="01131"|nic_all!="01132"))
replace ent_uorg=2 if (all_wfp==1 & all_ent==. & (nic_all=="01116"|nic_all=="01131"|nic_all=="01132"))
/* Classifying Ag workers, without enterpirse information, in Unorg-Org Enterprise - NCEUS*/
replace ent_uorg=1 if (all_ent!=. & all_ent<=4 & all_wrk<=2)
replace ent_uorg=1 if (all_ent==8|all_ent==9)
replace ent_uorg=2 if (all_ent!=. & all_ent<=4 & all_wrk>2) 
replace ent_uorg=2 if (all_ent==5|all_ent==6|all_ent==7)
replace ent_uorg=1 if (all_wfp==1 & ent_uorg==.)
/* Classifying Ag & Non-Ag workers, with enterpirse information, in Unorg-Org Enterprise - NCEUS*/

gen wrk_uorg=.
replace wrk_uorg=1 if ent_uorg==1
replace wrk_uorg=2 if ent_uorg==2
replace wrk_uorg=1 if (ent_uorg==2 & all_scrt==2)
replace wrk_uorg=2 if (ent_uorg==1  & (all_sts==2 & all_scrt==1))
/* NCEUS definition for Unorg-Org employment */
 
label define org 1 "Unorg" 2 "Org"
label values ent_uorg org
label values wrk_uorg org
label var ent_uorg "Enterprise-Org/Unorg"
label var wrk_uorg "Worker-Org/Unorg"

/*************** Consumption quintiles ************/
xtile qnt_mpce_r = mpce if sector=="1" [aw=hh_wt], nq(5) 
xtile qnt_mpce_u = mpce if sector=="2" [aw=hh_wt], nq(5) 

label drop qnt_mpce
gen qnt_mpce=.
replace qnt_mpce=qnt_mpce_r if sector=="1"
replace qnt_mpce=qnt_mpce_u if sector=="2"
drop qnt_mpce_r qnt_mpce_u
label define qnt_mpce 1 "Q1(lowest)" 2 "Q2" 3 "Q3" 4 "Q4" 5 "Q5(highest)"
label values qnt_mpce qnt_mpce

/***** Sex, Education, Head-relation, Caste, Religion, HH-type ********/
gen sector_n=real(sector)
drop sector
rename sector_n sector
recode sector (1=0) (2=1)
label define sector 0 "Rural" 1 "Urban"
label values sector sector

gen sex_n = real(sex)
drop sex
rename sex_n sex
recode sex (1=0) (2=1)
label define sex 0 "Male" 1 "Female"
label values sex sex

gen hh_head = real(relation)
recode hh_head (1=1) (else=0)
label define relation 1 "Head-hh" 0 "Others"
label values hh_head relation

gen edu = real(gen_edu)
recode edu (.=0) (1=1) (2/6=2) (7=3) (8/11=4) (12/13=5)
label define edu 0 "N.D" 1 "Illiterate" 2 "Literate & upto Primary" 3 "Middle" 4 "Secondary & HS" 5 "Graduate & above" 
label values edu edu

gen attend_n = real(attend)
drop attend
rename attend_n attend
gen crnt_atnd=attend
recode crnt_atnd (.=1) (1/15=1) (21/40=2)
label define crnt_atnd 1 "not attending" 2 "currently attending"
label values crnt_atnd crnt_atnd

gen caste = real(s_grp)
drop s_grp
rename caste s_grp
recode s_grp (.=0) (9=3)
label define s_grp 0 "N.D" 1 "ST" 2 "SC" 3 "Others" 
label values s_grp s_grp

gen relgn = real(religion)
drop religion
rename relgn religion
recode religion (.=0) (5/9=5)
label define religion 0 "N.D" 1 "Hindu" 2 "Muslim" 3 "Christian" 4 "Sikh" 5 "Others"
label values religion religion

gen hhtype_n = real(hh_type)
drop hh_type
rename hhtype_n hh_type
gen hhtype_r = hh_type if sector==0
gen hhtype_u = hh_type if sector==1
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
rename group_age age_grp

/********* State & Region *********/
gen state_n = real(state)
drop state
rename state_n state

recode state (28=2) (12=3) (18=4) (10=5) (30=6) (24=7) (6=8) (2=9) (1=10) (29=11) (32=12) (23=13) (27=14)/*
*/ (14=15) (17=16) (15=17) (13=18) (21=19) (3=20) (8=21) (11=22) (33=23) (16=24) (9=25) (19=26) (35=27)/* 
*/ (4=28) (26=29) (25=30) (7=31) (31=32) (34=33) (20=34) (22=35) (5=36)   

label define state 2 "Andhra Pradesh"  3 "Arunachal Pradesh" 4 "Assam" 5 "Bihar" 6 "Goa" 7 "Gujarat" 8 "Haryana" 9 "Himachal Pradesh" 10 "Jammu & Kashmir" 11 "Karnataka" /*
*/ 12 "Kerala" 13 "Madhya Pradesh" 14 "Maharashtra" 15 "manipur" 16 "Meghalaya" 17 "Mizoram" 18 "Nagaland" 19 "Orissa" 20 "Punjab" 21 "Rajasthan" 22 "Sikkim" /*
*/ 23 "Tamil Nadu" 24 "Tripura" 25 "Uttar Pradesh" 26 "West Bengal" 27 "A & N islands" 28 "Chandigarh" 29 "D & N Haveli" 30 "Daman & Diu" 31 "Delhi" 32 "Lakshadweep" /*
*/ 33 "Pondicherry" 34 "Jharkhand" 35 "Chhattisgarh" 36 "Uttarakhand" 99 "Others"
label values state state

gen state_cd=state
replace state_cd=99 if (state_cd==3|state_cd==6|state_cd==10|state_cd==15|state_cd==16|state_cd==17|state_cd==18|/*
*/ state_cd==22|state_cd==24|state_cd==27|state_cd==28|state_cd==29|state_cd==30|state_cd==31|state_cd==32|state_cd==33)
label values state_cd state

gen region_n = real(region)
drop region
rename region_n region
recode region (1=2) (2=3) if state_cd==5
recode region (1=2) (2=3) (3=4) (4=5) (5=6) (6=7) if state_cd==13
recode region (1=2) (2=3) (3=4) (4=5) if state_cd==25
gen state_reg = state*10+region

/******* Important Var ********/ 
gen worker_all=sts_prn
replace worker_all=sts_sub if sts_prn>51 & sts_sub<=51
recode worker_all (11=1) (12=2) (21=3) (31=4) (41=5) (51=6) (else=.)
label define worker 1 "Own-account" 2 "Employer" 3 "Helper" 4 "Regular" 5 "Casual:Pub" 6 "Casual:Non-pub"
label values worker_all worker

/***************************/
order hh_id prsn_no state state_cd sector region state_reg hh_size s_grp religion hh_type hhtype_r hhtype_u hh_nic hh_nco hh_ind l_ownd l_posd l_cult hh_wt mpce qnt_mpce /*
*/ hh_head sex age age_grp relation mrtl_sts edu tech_edu crnt_atnd prn_lfp all_lfp prn_wfp all_wfp sts_prn sts_sub prn_sts sub_sts all_sts self_prn self_sub self_all /*
*/ prn_ind sub_ind all_ind ind_ps ind_ss ind_us prn_ocp sub_ocp all_ocp all_lctn-wrk_uorg
drop level-attend

/*************************/
sort hh_id prsn_no
save "$dta\se_nss61.dta", replace
clear

/*********************/
use "$dta\se_nss61.dta", clear

sort sector
by sector: tab all_sts sex if all_sts<4 [aw=hh_wt], nof col
by sector: tab worker_all sex if worker_all<=3 [aw=hh_wt], nof col

gen agnag_all = (all_ind>1)

replace agnag_all = agnag_all*100
table all_sts sex sector if all_sts<=3 [aw=hh_wt], c(mean agnag_all) row col scol

recode agnag_all (100=1)
sort sector
by sector: tab worker_all sex if worker_all<=3 & agnag_all==1 [aw=hh_wt], nof col
by sector: tab worker_all sex if worker_all>=5 & agnag_all==1 [aw=hh_wt], nof col

/*** Distribution (%) by Detailed Status ***/
sort sex
by sex: tab worker_all sector [aw=hh_wt], nof col
tab worker_all sector [aw=hh_wt], nof col

sort sex
by sex: tab all_sts sector if all_sts<4 [aw=hh_wt], nof col
tab all_sts sector if all_sts<4 [aw=hh_wt], nof col

/*** Distribution (%) by Detailed Status in Non-Ag ***/
sort sex
by sex: tab worker_all sector if agnag_all==1 [aw=hh_wt], nof col
tab worker_all sector if agnag_all==1 [aw=hh_wt], nof col

sort sex
by sex: tab all_sts sector if all_sts<4 & agnag_all==1 [aw=hh_wt], nof col
tab all_sts sector if all_sts<4 & agnag_all==1 [aw=hh_wt], nof col

clear

/******************************** Features of Self-employment *****************************************/
use "$dta\se_nss61.dta", clear

gen agnag_all = (all_ind>1)
replace agnag_all=. if all_wfp==2

label define agnag 0 "Ag" 1 "Non-Ag"
label values agnag_all agnag

keep if all_wfp==1

/*** Demographic ***/
tab sex 	 sector if all_sts==1 & agnag_all==1 		   [aw=hh_wt], nof col
tab age_grp  sector if all_sts==1 & agnag_all==1 		   [aw=hh_wt], nof col
tab s_grp 	 sector if all_sts==1 & agnag_all==1 & s_grp!=0    [aw=hh_wt], nof col
tab religion sector if all_sts==1 & agnag_all==1 & religion!=0 [aw=hh_wt], nof col
tab edu	 sector if all_sts==1 & agnag_all==1 & edu!=0      [aw=hh_wt], nof col

/*** Employment ***/
tab all_ind	 sector if all_sts==1 & agnag_all==1 		  [aw=hh_wt], nof col
tab all_ocp  sector if all_sts==1 & agnag_all==1 & all_ocp!=8 [aw=hh_wt], nof col
tab all_lctn sector if all_sts==1 & agnag_all==1 		  [aw=hh_wt], nof col
tab all_pwr  sector if all_sts==1 & agnag_all==1 & all_pwr!=9 [aw=hh_wt], nof col


/*******/
tab agnag_all sector if all_wfp==1 [aw=hh_wt], nof col

sort hh_id
save, replace
clear
log close

/***********************/
use "$dta\se_nss61.dta", clear

tab self_all sector if agnag_all==1 [aw=hh_wt], nof col
clear
log close


/***********************/
use "$dta\se_nss61.dta", clear

gen age_grp2=age
recode age_grp2 (0/14=1) (15/59=2) (60/115=3)

label define age_grp2 1 "<15" 2 "15~59" 3 ">=60"
label values age_grp2 age_grp2

tab age_grp2 sector if all_wfp==1 [aw=hh_wt], nof col

clear
log close


/***********************/
use "$dta\se_nss61.dta", clear

