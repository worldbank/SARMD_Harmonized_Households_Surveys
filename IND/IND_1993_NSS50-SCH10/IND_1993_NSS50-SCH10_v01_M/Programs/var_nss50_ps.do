#delimit;
capture drop _all;
capture macro drop _all;
capture program drop _all;
set more off;
capture log close;
set mem 200m;

/*
global prg "S:\Pinaki\Stuff\Self_employ\se_nss50\Prg";
global dta "S:\Pinaki\Stuff\Self_employ\se_nss50\Dta";
global raw "S:\Pinaki\Wage_Salary\1993-94\Dta";
global log "S:\Pinaki\Stuff\Self_employ\se_nss50\Log";
*/

global prg  "C:\Users\pinaki\Desktop\Pinaki\Self_employ\se_nss50\Prg";
global dta  "C:\Users\pinaki\Desktop\Pinaki\Self_employ\se_nss50\Dta";
global raw1 "C:\Users\pinaki\Desktop\Pinaki\Wage_Salary\1993-94\Dta";
global raw2 "C:\Users\pinaki\Desktop\Pinaki\Adept_pinaki\NSS50_Sch1\Dta";
global log  "C:\Users\pinaki\Desktop\Pinaki\Self_employ\se_nss50\Log";

capture cd "$prg";
if _rc~=0 {;
global prg ;
global dta ;
global raw ;
global log ;
};

log using "$log\var_nss50_ps.log", replace;

#delimit cr

/**************************************** Region-wise Rates - Data Preparation ****************************************/
use "$dta\se_nss50.dta", clear
keep  hh_id prsn_no state sector region hh_wt sex age prn_wfp prn_sts prn_ind
order hh_id prsn_no state sector region hh_wt sex age prn_wfp prn_sts prn_ind

gen ind_ps=prn_ind
recode ind_ps (1=1) (2/9=2)
label define ind_ps 1 "Ag" 2 "Non-Ag"
label values ind_ps ind_ps

keep if age>=15 & age<=59

/*** % share of Non-Ag SE,Reg,Cas in R/U/T Population (Age:15~59) ***/
gen nag_r_se=1 if ind_ps==2  & sector==0  & prn_sts==1	/*Non-Ag, Self-employed - Rural*/
gen nag_r_rg=1 if ind_ps==2  & sector==0  & prn_sts==2	/*Non-Ag, Regular 	- Rural*/
gen nag_r_cs=1 if ind_ps==2  & sector==0  & prn_sts==3	/*Non-Ag, Casual 		- Rural*/
gen nag_u_se=1 if ind_ps==2  & sector==1  & prn_sts==1	/*Non-Ag, Self-employed - Urban*/
gen nag_u_rg=1 if ind_ps==2  & sector==1  & prn_sts==2	/*Non-Ag, Regular 	- Urban*/
gen nag_u_cs=1 if ind_ps==2  & sector==1  & prn_sts==3	/*Non-Ag, Casual 		- Urban*/
gen nag_t_se=1 if ind_ps==2 		      & prn_sts==1	/*Non-Ag, Self-employed - Total*/
gen nag_t_rg=1 if ind_ps==2 		      & prn_sts==2	/*Non-Ag, Regular 	- Total*/
gen nag_t_cs=1 if ind_ps==2 		      & prn_sts==3	/*Non-Ag, Casual 		- Total*/

/*** % share of Ag SE,Reg,Cas in R/U/T Population (Age:15~59) ***/
gen ag_r_se=1 if ind_ps==1  & sector==0  & prn_sts==1		/*Ag, Self-employed - Rural*/
gen ag_r_rg=1 if ind_ps==1  & sector==0  & prn_sts==2		/*Ag, Regular 	  - Rural*/
gen ag_r_cs=1 if ind_ps==1  & sector==0  & prn_sts==3		/*Ag, Casual 	  - Rural*/
gen ag_u_se=1 if ind_ps==1  & sector==1  & prn_sts==1		/*Ag, Self-employed - Urban*/
gen ag_u_rg=1 if ind_ps==1  & sector==1  & prn_sts==2		/*Ag, Regular 	  - Urban*/
gen ag_u_cs=1 if ind_ps==1  & sector==1  & prn_sts==3		/*Ag, Casual 	  - Urban*/
gen ag_t_se=1 if ind_ps==1 		     & prn_sts==1		/*Ag, Self-employed - Total*/
gen ag_t_rg=1 if ind_ps==1 		     & prn_sts==2		/*Ag, Regular 	  - Total*/
gen ag_t_cs=1 if ind_ps==1 		     & prn_sts==3		/*Ag, Casual 	  - Total*/

/*** % share of Ag SE,Reg,Cas in R/U/T Population (Age:15~59) ***/
gen r_se=1 if sector==0  & prn_sts==1 	/*Self-employed - Rural*/
gen r_rg=1 if sector==0  & prn_sts==2 	/*Regular 	    - Rural*/
gen r_cs=1 if sector==0  & prn_sts==3 	/*Casual 	    - Rural*/
gen u_se=1 if sector==1  & prn_sts==1 	/*Self-employed - Urban*/
gen u_rg=1 if sector==1  & prn_sts==2 	/*Regular 	    - Urban*/
gen u_cs=1 if sector==1  & prn_sts==3 	/*Casual 	    - Urban*/
gen t_se=1 			if prn_sts==1 	/*Self-employed - Total*/
gen t_rg=1     		if prn_sts==2 	/*Regular 	    - Total*/
gen t_cs=1     		if prn_sts==3 	/*Casual 	    - Total*/

for var nag_r_se-t_cs: recode X (1=100) (.=0)

gen industry = (prn_ind==3|prn_ind==4|prn_ind==5)

gen ind_r  = 1 if industry==1 & sector==0
gen ind_u  = 1 if industry==1 & sector==1
gen ind_t  = 1 if industry==1
for var ind_r-ind_t: recode X (1=100) (.=0)

keep hh_id prsn_no state sector region hh_wt nag_r_se-t_cs ind_r-ind_t
sort hh_id prsn_no
save "$dta\sts_ind_ps.dta", replace
clear

/*** (1) Region-wise Rate of SE, Reg & Cas in Ag/Non-Ag/Total and Industrialisation: Rural (15~59 yr) ***/
use "$dta\sts_ind_ps.dta", clear
keep if sector==0
sort hh_id prsn_no
collapse (mean) nag_r_se-nag_r_cs ag_r_se-ag_r_cs r_se-r_cs ind_r [aw=hh_wt], by (state region)
for var nag_r_se-ind_r: label var X ""
sort state region
save "$dta\sts_ind_r.dta", replace
clear
* Note: These rates stand for share (%) in total working age population (15~59 yr); not in the employed population.

/*** (2) Region-wise Rate of SE, Reg & Cas in Ag/Non-Ag/Total and Industrialisation: Urban (15~59 yr) ***/
use "$dta\sts_ind_ps.dta", clear
keep if sector==1
sort hh_id prsn_no
collapse (mean) nag_u_se-nag_u_cs ag_u_se-ag_u_cs u_se-u_cs ind_u [aw=hh_wt], by (state region)
for var nag_u_se-ind_u: label var X ""
sort state region
save "$dta\sts_ind_u.dta", replace
clear

/*** (3) Region-wise Rate of SE, Reg & Cas in Ag/Non-Ag/Total and Industrialisation: Total (15~59 yr) ***/
use "$dta\sts_ind_ps.dta", clear
sort hh_id prsn_no
collapse (mean) nag_t_se-nag_t_cs ag_t_se-ag_t_cs t_se-t_cs ind_t [aw=hh_wt], by (state region)
for var nag_t_se-ind_t: label var X ""
sort state region
save "$dta\sts_ind_t.dta", replace
clear

/**** Economic Diversity for  All & Non-Ag Industries (Herfindahl index): Rural/Urban/Total (15~59 yr) ****/
use "$dta\se_nss50.dta", clear
keep  hh_id prsn_no state region sector hh_wt age prn_wfp prn_ind
order hh_id prsn_no state region sector hh_wt age prn_wfp prn_ind

keep if prn_wfp==1
keep if age>=15 & age<=59

tab prn_ind if sector==0, gen(ind_r)
tab prn_ind if sector==1, gen(ind_u)
tab prn_ind, gen(ind_t)
for var ind_r1-ind_t9: label var X ""
for var ind_r1-ind_t9: recode X (1=100)
drop ind_r10 ind_u10 ind_t10

sort hh_id prsn_no
save "$dta\diverse.dta", replace
clear

/*** (4)Eco Diversity - All/Non-Ag Industry: Rural (15~59 YR) ***/
use "$dta\diverse.dta", clear
keep if sector==0
collapse (mean) ind_r1-ind_r9 [aw=hh_wt], by(state region)

for var ind_r1-ind_r9: replace X=X*X
egen eco_r_all = rsum(ind_r1-ind_r9)
egen eco_r_nag = rsum(ind_r2-ind_r9)

keep state region eco_r_all eco_r_nag
sort state region
save "$dta\diverse_rural.dta", replace
clear

/*** (5)Eco Diversity - All/Non-Ag Industry: Urban (15~59 YR) ***/
use "$dta\diverse.dta", clear
keep if sector==1
collapse (mean) ind_u1-ind_u9 [aw=hh_wt], by(state region)

for var ind_u1-ind_u9: replace X=X*X
egen eco_u_all = rsum(ind_u1-ind_u9)
egen eco_u_nag = rsum(ind_u2-ind_u9)

keep state region eco_u_all eco_u_nag
sort state region
save "$dta\diverse_urban.dta", replace
clear

/*** (6)Eco Diversity - All/Non-Ag Industry: Total (15~59 YR) ***/
use "$dta\diverse.dta", clear
collapse (mean) ind_t1-ind_t9 [aw=hh_wt], by(state region)

for var ind_t1-ind_t9: replace X=X*X
egen eco_t_all = rsum(ind_t1-ind_t9)
egen eco_t_nag = rsum(ind_t2-ind_t9)

keep state region eco_t_all eco_t_nag
sort state region
save "$dta\diverse_total.dta", replace
clear

* Note:Eco diversity is measured by Herfindahl inedex(H).Low value of H-->High is the economic diversity.
* Therefore, low value of ln(H)-->High is the economic diversity 

/**** Labour Supply & Demand - Rural/Urban/Total- Male/Female/Person ****/

/*** (7)Labour SS/DD R/U M/F ***/
use "$dta\se_nss50.dta", clear
keep hh_id prsn_no state region sector hh_wt sex age prn_lfp prn_wfp
keep if age>=15 & age<=59

for var prn_lfp prn_wfp: recode X (1=100) (2=0)

sort hh_id prsn_no
collapse (mean) prn_lfp prn_wfp [aw=hh_wt], by(state region sector sex)

gen 	  sector_s="Rural" if sector==0
replace sector_s="Urban" if sector==1
drop sector
rename sector_s sector

gen 	  sex_s="Male"   if sex==0
replace sex_s="Female" if sex==1
drop sex
rename sex_s sex

order state region sector sex
sort state region sector sex
drop if sex==""

reshape wide prn_lfp prn_wfp, i(state region sex) j(sector) str
reshape wide prn_lfpRural prn_wfpRural prn_lfpUrban prn_wfpUrban, i(state region) j(sex) str

rename prn_lfpRuralFemale ss_rf
rename prn_wfpRuralFemale dd_rf
rename prn_lfpUrbanFemale ss_uf
rename prn_wfpUrbanFemale dd_uf
rename prn_lfpRuralMale   ss_rm
rename prn_wfpRuralMale   dd_rm
rename prn_lfpUrbanMale   ss_um
rename prn_wfpUrbanMale   dd_um

for var ss_rf-dd_um: label var X ""

sort state region
save "$dta\ss_dd_ru_mf.dta", replace
clear

/*** (8)Labour SS/DD Total ***/
use "$dta\se_nss50.dta", clear
keep hh_id prsn_no state region sector hh_wt sex age prn_lfp prn_wfp
keep if age>=15 & age<=59

for var prn_lfp prn_wfp: recode X (1=100) (2=0)

sort hh_id prsn_no
collapse (mean) prn_lfp prn_wfp [aw=hh_wt], by(state region)

rename prn_lfp labr_ss
rename prn_wfp labr_dd
for var labr_ss labr_dd: label var X ""

sort state region
save "$dta\ss_dd_t.dta", replace
clear

/*** (9)Weekly Unemployment Rate for Educated (Secondary & above) Population (15 yr+): Rural/Urban ***/
use "$raw1\un_wk_dly_wage50.dta", replace
recode wkl_broad (1=0) (2=100) (else=.)
sort hh_id prsn_no
collapse (mean) wkl_broad if gen_edu>=4 & age>=15 & act_no==1 [aw=hh_wt], by (state region sector)

sort state region sector
reshape wide wkl_broad, i(state region) j(sector)

rename wkl_broad1 wk_un_r
rename wkl_broad2 wk_un_u
for var wk_un_r wk_un_u: label var X ""

sort state region
save "$dta\wk_un_ru.dta", replace
clear

/*** (10)Weekly Unemployment Rate for Educated (Secondary & above) Population (15 yr+): Total ***/
use "$raw1\un_wk_dly_wage50.dta", replace
recode wkl_broad (1=0) (2=100) (else=.)
sort hh_id prsn_no
collapse (mean) wkl_broad if gen_edu>=4 & age>=15 & act_no==1 [aw=hh_wt], by (state region)

rename wkl_broad wk_un_t
for var wk_un_t: label var X ""

sort state region
save "$dta\wk_un_t.dta", replace
clear

/*** (11)Daily Unemployment Rate for Youth (15~29yr): Rural/Urban/Total ***/
use "$raw1\un_wk_dly_wage50.dta", replace
keep  hh_id prsn_no state region sector hh_wt sex age act_no dly_broad days
order hh_id prsn_no state region sector hh_wt sex age act_no dly_broad days

sort hh_id prsn_no state region sector hh_wt sex age act_no
qui by hh_id prsn_no state region sector hh_wt sex age act_no: gen flag=_n 
tab flag
keep if flag==1
drop flag

reshape wide dly_broad days, i(hh_id prsn_no state region sector sex age hh_wt) j(act_no)

for num 1/4: gen emp_dayX = daysX if dly_broadX==1
for num 1/4: gen  un_dayX = daysX if dly_broadX==2

egen emp_day = rsum(emp_day1 - emp_day4)
egen  un_day = rsum(un_day1  - un_day4)

drop dly_broad1-un_day4

sort hh_id prsn_no
collapse (sum) emp_day un_day if age>=15 & age<=29 [iw=hh_wt], by (state region sector)

gen 	  sector_s="Rural" if sector==1
replace sector_s="Urban" if sector==2
drop sector
rename sector_s sector
order state region sector

reshape wide emp_day un_day, i(state region) j(sector) str

egen emp_dayTotal = rsum(emp_dayRural emp_dayUrban)
egen  un_dayTotal = rsum(un_dayRural un_dayUrban)

gen dl_un_r = un_dayRural/(emp_dayRural+un_dayRural)*100
gen dl_un_u = un_dayUrban/(emp_dayUrban+un_dayUrban)*100
gen dl_un_t = un_dayTotal/(emp_dayTotal+un_dayTotal)*100

keep state region dl_un_r-dl_un_t
sort state region
save "$dta\dly_un.dta", replace
clear

/*** (12) Daily Earning Median in 93-94 Prices (Rs.) for Regular/Casual for Ag.Ind/Services (15~59yr) ****/
use "$raw1\un_wk_dly_wage50.dta", replace

replace real_wage = real_wage*(205.84/281.35) if sector==2

keep  hh_id prsn_no state region sector hh_wt sex age act_no sts_dly ind_dly real_wage
order hh_id prsn_no state region sector hh_wt sex age act_no sts_dly ind_dly real_wage

keep if real_wage!=.
keep if sts_dly==2|sts_dly==4
keep if age>=15 & age<=59
drop age 

label drop industry
recode ind_dly (1=1) (2=2) (3/5=3) (6/9=4)
label define ind  1 "Ag" 2 "Other Pry" 3 "Industry" 4 "Services"
label values ind_dly ind

sort    hh_id prsn_no state region sector hh_wt sex act_no 
qui by  hh_id prsn_no state region sector hh_wt sex act_no: gen flag=_n 
tab flag
drop if flag==2
drop flag

reshape wide sts_dly ind_dly real_wage, i(hh_id prsn_no state region sector hh_wt sex) j(act_no)

for num 1/4: gen cas_agX   = real_wageX if sts_dlyX==4 & ind_dlyX==1
for num 1/4: gen cas_indX  = real_wageX if sts_dlyX==4 & ind_dlyX==3
for num 1/4: gen cas_servX = real_wageX if sts_dlyX==4 & ind_dlyX==4
for num 1/4: gen casX      = real_wageX if sts_dlyX==4

for num 1/4: gen reg_agX   = real_wageX if sts_dlyX==2 & ind_dlyX==1
for num 1/4: gen reg_indX  = real_wageX if sts_dlyX==2 & ind_dlyX==3
for num 1/4: gen reg_servX = real_wageX if sts_dlyX==2 & ind_dlyX==4
for num 1/4: gen regX      = real_wageX if sts_dlyX==2

for num 1/4: gen agX   = real_wageX if ind_dlyX==1
for num 1/4: gen indX  = real_wageX if ind_dlyX==3
for num 1/4: gen servX = real_wageX if ind_dlyX==4

egen wg_cas_ag   = rmean(cas_ag1 - cas_ag4)
egen wg_cas_ind  = rmean(cas_ind1 - cas_ind4)
egen wg_cas_serv = rmean(cas_serv1 - cas_serv4)
egen wg_cas	     = rmean(cas1 - cas4)

egen wg_reg_ag   = rmean(reg_ag1 - reg_ag4)
egen wg_reg_ind  = rmean(reg_ind1 - reg_ind4)
egen wg_reg_serv = rmean(reg_serv1 - reg_serv4)
egen wg_reg	     = rmean(reg1 - reg4)

egen wg_ag   = rmean(ag1 - ag4)
egen wg_ind  = rmean(ind1 - ind4)
egen wg_serv = rmean(serv1 - serv4)
egen wg_all  = rmean(real_wage1 real_wage2 real_wage3 real_wage4)

drop sts_dly1-serv4
sort hh_id prsn_no

* Note: repeat the above process and then collapse without 'sector' to get the total daily wage

/*** for Rural & Urban seperately ***/
collapse (median) wg_cas_ag-wg_all [aw=hh_wt], by (state region sector)
for var wg_cas_ag-wg_all: label var X ""

sort state region
reshape wide wg_cas_ag-wg_all, i(state region) j(sector)

rename wg_cas_ag1 	cas_ag_r
rename wg_cas_ind1	cas_ind_r 
rename wg_cas_serv1 	cas_srv_r
rename wg_cas1 		cas_r
rename wg_reg_ag1		reg_ag_r 
rename wg_reg_ind1	reg_ind_r 
rename wg_reg_serv1	reg_srv_r 
rename wg_reg1 		reg_r
rename wg_ag1		agri_r 
rename wg_ind1		indus_r 
rename wg_serv1		serv_r 
rename wg_all1		wage_r

rename wg_cas_ag2 	cas_ag_u
rename wg_cas_ind2	cas_ind_u 
rename wg_cas_serv2 	cas_srv_u
rename wg_cas2 		cas_u
rename wg_reg_ag2		reg_ag_u 
rename wg_reg_ind2	reg_ind_u 
rename wg_reg_serv2	reg_srv_u 
rename wg_reg2 		reg_u
rename wg_ag2		agri_u 
rename wg_ind2		indus_u 
rename wg_serv2		serv_u 
rename wg_all2		wage_u

for var cas_ag_r-wage_u: label var X ""
sort state region
save "$dta\daily_wage_ru.dta", replace
clear

/*** for Total seperately ***/
collapse (median) wg_cas_ag-wg_all [aw=hh_wt], by (state region)
for var wg_cas_ag-wg_all: label var X ""

rename wg_cas_ag 		cas_ag_t
rename wg_cas_ind		cas_ind_t 
rename wg_cas_serv 	cas_srv_t
rename wg_cas 		cas_t
rename wg_reg_ag		reg_ag_t 
rename wg_reg_ind		reg_ind_t 
rename wg_reg_serv	reg_srv_t 
rename wg_reg 		reg_t
rename wg_ag		agri_t
rename wg_ind		indus_t 
rename wg_serv		serv_t 
rename wg_all		wage_t

sort state region
save "$dta\daily_wage_t.dta", replace
clear

/************************ Region-wise Welfare & Inequality Indicators *************************/
* use "S:\Pinaki\ADePT\Adept_pinaki\NSS50_Sch1\Dta\adept_nss50_hh.dta", clear
* use "C:\Users\pinaki\Desktop\Pinaki\Adept_pinaki\NSS50_Sch1\Dta\adept_nss50_hh.dta", clear

* use "$raw2\adept_nss50_hh.dta", clear

gen poor = (mpce<=state_pl)
recode poor (1=100)
drop if mpce==0
gen state_reg = state*10+region

replace real_mpce93 = real_mpce93*(205.84/281.35) if sector==1

order hh_id state sector region state_reg poor real_mpce93 hh_wt pop_wt
keep  hh_id state sector region state_reg poor real_mpce93 hh_wt pop_wt

sort hh_id
save "$dta\welfare50.dta", replace
clear

/*** (13) Median MPCE (Real, 93-94 preice) & Poverty Rate - Rural/Urban by Region ***/
forvalues j=0/1 {
	use "$dta\welfare50.dta", clear
	sort hh_id state region
	collapse (median) real_mpce93 (mean) poor if sector==`j' [aw=pop_wt], by(state region)
	rename real_mpce cons_`j'
	rename poor	     poor_`j'
	sort state region
	save "$dta\welfare_`j'.dta", replace
	clear
	}

/*** (14) Median MPCE (Real, 93-94 preice) & Poverty Rate -  Total by Region ***/
use "$dta\welfare50.dta", clear
sort hh_id state region
collapse (median) real_mpce93 (mean) poor [aw=pop_wt], by(state region)
rename real_mpce cons_t
rename poor      poor_t
sort state region
save "$dta\welfare_t.dta", replace
clear

/*** (15) Gini for Real MPCE -  Rural/Urban/Total by Region ***/
use "$dta\welfare50.dta", clear
keep if sector==0
ineqdeco real_mpce93 [aw=pop_wt], by(state_reg)
clear

use "$dta\welfare50.dta", clear
keep if sector==1
ineqdeco real_mpce93 [aw=pop_wt], by(state_reg)
clear

use "$dta\welfare50.dta", clear
ineqdeco real_mpce93 [aw=pop_wt], by(state_reg)
clear

* Note: Copy & Paste the Gini values for Rural, Urban & Total Regions in excel, then import the excel data to STATA 
* state_reg 31, 51 181, & 321 for rural & 43 & 291 for urban do't have real_mpce 93 

gen state = int(state_reg/10)
gen region = state_reg - state*10
drop state_reg
order state region gini_r gini_u gini_t
for var gini_r gini_u gini_t: replace X = X*100

sort state region
save "$dta\gini50.dta", replace
clear

/***(16) Merge All Welfare Indicators (Medain Cons, Poverty Rates & Gini) ***/
use "$dta\welfare_0.dta", clear
sort state region
merge state region using "$dta\welfare_1.dta"
tab _m
drop _m
sort state region
merge state region using "$dta\welfare_t.dta"
tab _m
drop _m
sort state region
merge state region using "$dta\gini50.dta"
tab _m
drop _m
sort state region

rename cons_0 cons_r
rename cons_1 cons_u
rename poor_0 poor_r
rename poor_1 poor_u
for var cons_r-gini_t: label var X ""

order state region cons_r cons_u cons_t poor_r poor_u poor_t gini_r gini_u gini_t
sort state region
save "$dta\region_welfare50.dta", replace
clear

/**************************** Socio & Demograhic Indicators by Region ****************************/
use "$dta\se_nss50.dta", clear

order hh_id prsn_no sector state region  s_grp religion sex age edu hh_wt
keep  hh_id prsn_no sector state region  s_grp religion sex age edu hh_wt

gen rural = (sector==0)
gen urban = (sector==1)
gen total = 1 

gen age14    = (age>=0 & age<=14)
gen age15_59 = (age>=15 & age<=59)
gen age60    = (age>=60 & age!=.)

recode s_grp (0=.)
tab s_grp, gen (caste)
rename caste1 st
rename caste2 sc
rename caste3 oth_caste

gen hindu        = (religion==1)
gen muslim 	     = (religion==2)
gen oth_religion = (religion==3|religion==4|religion==5)

recode edu (0=.)
gen illiterate = (edu==1) if age>=6
gen primary    = (edu>=2 & edu<=5)
gen secondary  = (edu==4|edu==5)	

keep hh_id prsn_no state sector region rural urban total age14 age15_59 age60 st sc oth_caste hindu muslim /*
*/ oth_religion illiterate primary secondary hh_wt

sort hh_id prsn_no
save "$dta\soc_demo.dta", replace
clear

/*** (17) Population (R/U/T) & Urbanization ***/
use "$dta\soc_demo.dta", clear
sort hh_id prsn_no
collapse (sum) rural urban total [iw=hh_wt], by (state region)
for var rural urban total: label var X ""
for var rural urban total: replace X = X/1000
gen urban_rt = urban/total*100

sort state region
save "$dta\pop_urban_rt.dta", replace
clear

/*** (18) Dependency Rate: R/U/T ***/
use "$dta\soc_demo.dta", clear
sort hh_id prsn_no
collapse (sum) age14 age15_59 age60 [iw=hh_wt], by (state region sector)
for var age14 age15_59 age60: label var X ""
for var age14 age15_59 age60: replace X = X/1000

sort state region
reshape wide age14 age15_59 age60, i(state region) j(sector)

rename age140    pop_14r
rename age15_590 pop15_59r
rename age600    pop_60r
rename age141    pop_14u
rename age15_591 pop15_59u
rename age601    pop_60u
for var pop_14r-pop_60u: label var X ""

egen pop_14t   = rsum(pop_14r pop_14u)
egen pop15_59t = rsum(pop15_59r pop15_59u)
egen pop_60t   = rsum(pop_60r pop_60u)

gen depend_r = ((pop_14r+ pop_60r)/pop15_59r)*100
gen depend_u = ((pop_14u+ pop_60u)/pop15_59u)*100
gen depend_t = ((pop_14t+ pop_60t)/pop15_59t)*100

for var depend_r depend_u depend_t: recode X (0=.)
keep state region depend_r depend_u depend_t

sort state region
save "$dta\dependency.dta", replace
clear

/*** (19) Concentration of Caste & Religious Groups and Education Categories: Rural/Urban ***/
use "$dta\soc_demo.dta", clear
drop rural-age60
for var st-secondary: label var X ""
for var st-secondary: recode X (1=100) (else=0)

sort hh_id prsn_no
collapse (mean) st-secondary [aw=hh_wt], by (state region sector)
for var st-secondary: label var X ""
sort state region
reshape wide st-secondary, i(state region) j(sector)

rename st0 		   st_r
rename sc0 		   sc_r
rename oth_caste0    oth_caste_r
rename hindu0 	   hindu_r
rename muslim0 	   muslim_r
rename oth_religion0 oth_rlgn_r
rename illiterate0   ilrt_r
rename primary0      pry_r
rename secondary0    scndry_r
rename st1 		   st_u
rename sc1 		   sc_u
rename oth_caste1    oth_caste_u
rename hindu1 	   hindu_u
rename muslim1 	   muslim_u
rename oth_religion1 oth_rlgn_u
rename illiterate1   ilrt_u
rename primary1      pry_u
rename secondary1    scndry_u

for var st_r-scndry_u: label var X ""

sort state region
save "$dta\caste_rlgn_edu_ru.dta", replace
clear

/*** (20) Concentration of Caste & Religious Groups and Education Categories: Total ***/
use "$dta\soc_demo.dta", clear
drop rural-age60
for var st-secondary: label var X ""
for var st-secondary: recode X (1=100) (else=0)

sort hh_id prsn_no
collapse (mean) st-secondary [aw=hh_wt], by (state region)
for var st-secondary: label var X ""

rename st 		  st_t
rename sc 		  sc_t
rename oth_caste    oth_caste_t
rename hindu 	  hindu_t
rename muslim 	  muslim_t
rename oth_religion oth_rlgn_t
rename illiterate   ilrt_t
rename primary      pry_t
rename secondary    scndry_t

sort state region
save "$dta\caste_rlgn_edu_t.dta", replace
clear

/********************************* Merging All Regional Indicator Data Files **********************************/
use "$dta\pop_urban_rt.dta", clear
sort state region
merge state region using "$dta\dependency.dta"
tab _m
drop _m
sort state region
merge state region using "$dta\caste_rlgn_edu_ru.dta"
tab _m
drop _m
sort state region
merge state region using "$dta\caste_rlgn_edu_t.dta"
tab _m
drop _m
sort state region
merge state region using "$dta\region_welfare50.dta"
tab _m
drop _m
sort state region
merge state region using "$dta\sts_ind_r.dta"
tab _m
drop _m
sort state region
merge state region using "$dta\sts_ind_u.dta"
tab _m
drop _m
sort state region
merge state region using "$dta\sts_ind_t.dta"
tab _m
drop _m
sort state region
merge state region using "$dta\diverse_rural.dta"
tab _m
drop _m
sort state region
merge state region using "$dta\diverse_urban.dta"
tab _m
drop _m
sort state region
merge state region using "$dta\diverse_total.dta"
tab _m
drop _m
sort state region
merge state region using "$dta\ss_dd_ru_mf.dta"
tab _m
drop _m
sort state region
merge state region using "$dta\ss_dd_t.dta"
tab _m
drop _m
sort state region
merge state region using "$dta\wk_un_ru.dta"
tab _m
drop _m
sort state region
merge state region using "$dta\wk_un_t.dta"
tab _m
drop _m
sort state region
merge state region using "$dta\dly_un.dta"
tab _m
drop _m
sort state region
merge state region using "$dta\daily_wage_ru.dta"
tab _m
drop _m
sort state region
merge state region using "$dta\daily_wage_t.dta"
tab _m
drop _m

sort state region
save "$dta\var_nss50_ps.dta", replace
clear

/*************************** Deleting Created Individual Data Files ****************************************/
erase "$dta\pop_urban_rt.dta"
erase "$dta\dependency.dta"
erase "$dta\caste_rlgn_edu_ru.dta"
erase "$dta\caste_rlgn_edu_t.dta"
erase "$dta\welfare50.dta"
erase "$dta\welfare_0.dta"
erase "$dta\welfare_1.dta"
erase "$dta\welfare_t.dta"
erase "$dta\sts_ind_r.dta"
erase "$dta\sts_ind_u.dta"
erase "$dta\sts_ind_t.dta"
erase "$dta\diverse_rural.dta"
erase "$dta\diverse_urban.dta"
erase "$dta\diverse_total.dta"
erase "$dta\ss_dd_ru_mf.dta"
erase "$dta\ss_dd_t.dta"
erase "$dta\wk_un_ru.dta"
erase "$dta\wk_un_t.dta"
erase "$dta\dly_un.dta"
erase "$dta\daily_wage_ru.dta"
erase "$dta\daily_wage_t.dta"
erase "$dta\sts_ind_ps.dta"
erase "$dta\diverse.dta"
erase "$dta\gini50.dta"
erase "$dta\soc_demo.dta"


/************************/
log close
stop
