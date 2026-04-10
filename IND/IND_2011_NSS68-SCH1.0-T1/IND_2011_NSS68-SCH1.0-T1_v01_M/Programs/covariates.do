**Creates covariates to be used in consumption regressions


use "$poverty\Output\dataprep_ind", clear

*****************************************************************
** Population weights
*****************************************************************

g 		pwt93=pwt if year==1993
g 		pwt04=pwt if year==2004
g 		pwt09=pwt if year==2009
g 		pwt11=pwt if year==2011

*****************************************************************
** Rural indicator
*****************************************************************

g rural=(sector==1)


*****************************************************************
** Urban indicator
*****************************************************************

g urban=(sector==2)


*****************************************************************
** Poor
*****************************************************************

g poor93=poor*100 if year==1993
g poor04=poor*100 if year==2004
g poor09=poor*100 if year==2009
g poor11=poor*100 if year==2011

replace poor=poor*100

*****************************************************************
** Vulnerable 
*****************************************************************

g pline200= 2.00*pline

g poor200=(mpce_mrp<= pline200)*100

g poor200_93=poor200 if year==1993
g poor200_04=poor200 if year==2004
g poor200_09=poor200 if year==2009
g poor200_11=poor200 if year==2011

*****************************************************************
** Real MPCE
*****************************************************************

g 		real_mpce=.
replace real_mpce=real_mpce93 if year==1993
replace real_mpce=real_mpce04 if year==2004
replace real_mpce=real_mpce09 if year==2009
replace real_mpce=real_mpce11 if year==2011

ren real_mpce93 real_mpce1993
ren real_mpce04 real_mpce2004
ren real_mpce09 real_mpce2009
ren real_mpce11 real_mpce2011

lab var real_mpce "Real-PC Monthly Cons-(in 2009-10 Rural Rs)"
lab var mpce_mrp "Nominal-PC Monthly Cons"


*****************************************************************
** Poverty line
*****************************************************************

g 		pline_ind=pline_ind_93 if  year==1993
replace pline_ind=pline_ind_04 if  year==2004
replace pline_ind=pline_ind_09 if  year==2009
replace pline_ind=pline_ind_11 if  year==2011

*****************************************************************
** UP indicator
*****************************************************************

g up=(state==9)
replace up=. if lis==0
lab var up "1=UP, 0=Rest of low income States"

*****************************************************************
** ST_SC indicator
*****************************************************************

g 		st_sc=.
replace st_sc=1 if (sgroup==1 | sgroup==2)
replace st_sc=2 if (sgroup==3)
replace st_sc=3 if (sgroup==9)
label define st_sc 1 "ST and SC" 2 "Other backward classes" 3 "Others"
label values st_sc st_sc
note st_sc: In case different members belong to different social groups, the group to which the head of the household belongs will be considered as the social group of the household.

g st_sc_obc=(st_sc==1 | st_sc==2)
label define st_sc_obc 1 "ST, SC, other backward classes" 0 "Others" 
label values st_sc_obc st_sc_obc
* Questionnaire not comparable
replace st_sc_obc=. if year==1993
note st_sc_obc: In case different members belong to different social groups, the group to which the head of the household belongs will be considered as the social group of the household.

g 		st=.
replace st=1 if sgroup==1
replace st=0 if (sgroup==2 | sgroup==3 | sgroup==9)
note st: In case different members belong to different social groups, the group to which the head of the household belongs will be considered as the social group of the household.

g 		sc=.
replace sc=1 if sgroup==2
replace sc=0 if (sgroup==1 | sgroup==3 | sgroup==9)
note sc: In case different members belong to different social groups, the group to which the head of the household belongs will be considered as the social group of the household.

g 		ob=.
replace ob=1 if sgroup==3
replace ob=0 if (sgroup==1 | sgroup==2 | sgroup==9)
note ob: In case different members belong to different social groups, the group to which the head of the household belongs will be considered as the social group of the household.
replace ob=. if year==1993

g 		hc=.
replace hc=1 if sgroup==9
replace hc=0 if (sgroup==1 | sgroup==2 | sgroup==3)
lab var hc "No ST, SC or other backward classes"
note hc: In case different members belong to different social groups, the group to which the head of the household belongs will be considered as the social group of the household.
replace hc=. if year==1993

g 		hc93=.
replace hc93=1 if sgroup==9
replace hc93=0 if (sgroup==1 | sgroup==2)
lab var hc93 "other backward class and others in 1993"
note hc93: In case different members belong to different social groups, the group to which the head of the household belongs will be considered as the social group of the household.
replace hc93=. if year~=1993

g 		hc_obc=0
replace hc_obc=1 if (hc==1 | ob==1)
replace hc_obc=1 if hc93==1
replace hc_obc=. if sgroup==.
lab var hc_obc "Other backward classes or forward caste"
note hc_obc: In case different members belong to different social groups, the group to which the head of the household belongs will be considered as the social group of the household.

*****************************************************************
** Head's ST_SC indicator
*****************************************************************

bys hhid year: egen head_st_sc=max(st_sc)
lab var head_st_sc "Head belongs to ST or SC"
replace head_st_sc=. if year~=1993
note head_st_sc: Available for all years but only kept as non missing for 1993 asother years include further and better classification of social groups


bys hhid year: egen head_st_sc_obc=max(st_sc_obc)
lab var head_st_sc_obc "Head belongs to ST, SC or other backward classes"
note head_st_sc_obc: In case different members belong to different social groups, the group to which the head of the household belongs will be considered as the social group of the household.

bys hhid year: egen head_st=max(st)
lab var head_st "Head belongs to ST"
note head_st: In case different members belong to different social groups, the group to which the head of the household belongs will be considered as the social group of the household.

bys hhid year: egen head_sc=max(sc)
lab var head_sc "Head belongs to SC"
note head_sc: In case different members belong to different social groups, the group to which the head of the household belongs will be considered as the social group of the household.

bys hhid year: egen head_ob=max(ob)
lab var head_ob "Head belongs to Other backward classes"
note head_ob: In case different members belong to different social groups, the group to which the head of the household belongs will be considered as the social group of the household.
replace head_ob=. if year==1993

bys hhid year: egen head_hc=max(hc)
lab var head_hc "Head does NOT belong to ST, SC or other backward classes"
note head_hc: In case different members belong to different social groups, the group to which the head of the household belongs will be considered as the social group of the household.

bys hhid year: egen head_hc93=max(hc93)
lab var head_hc93 "Head does NOT belong to ST or SC"
note head_hc93: In case different members belong to different social groups, the group to which the head of the household belongs will be considered as the social group of the household.

bys hhid year: egen head_hc_obc=max(hc_obc)
lab var head_hc_obc "Head belongs to forward caste or OBC"


*****************************************************************
** Land size
*****************************************************************

g 		landsizecat=1 if landsize>0 & landsize<=0.03
replace landsizecat=2 if landsize>0.03 & landsize<=1
replace landsizecat=3 if landsize>1
replace landsizecat=. if landsize==.
replace landsizecat=. if landowned==0

g landsize93=landsize if year==1993	
g landsize04=landsize if year==2004	
g landsize09=landsize if year==2009	
g landsize11=landsize if year==2011	

g landsizecat93=landsizecat if year==1993	
g landsizecat04=landsizecat if year==2004	
g landsizecat09=landsizecat if year==2009	
g landsizecat11=landsizecat if year==2011	


*****************************************************************
** Land owned
*****************************************************************

g landowned93=landowned*100 if year==1993	
g landowned04=landowned*100 if year==2004	
g landowned09=landowned*100 if year==2009	
g landowned11=landowned*100 if year==2011	

replace landowned=landowned*100

*****************************************************************
** Ration card
*****************************************************************

g rationcard93=rationcard if year==1993	
g rationcard04=rationcard if year==2004	
g rationcard09=rationcard if year==2009	
g rationcard11=rationcard if year==2011	

replace rationcard=rationcard*100

*****************************************************************
** Budget shares
*****************************************************************

foreach year in 1993 2004 2009 2011 {
	foreach var in sdurables seducation sentertainment sfood shealth snonfood srent stobacco {
		g `var'`year'=`var' if year==`year'
		}
	}

*****************************************************************
** Assets owned
*****************************************************************

compress

foreach year in 1993 2004 2009 2011 {
	foreach var in tv dvd wmachine stove refrigerator appliances motorcycle motorcar laptop mobile {
		g `var'`year'=`var'*100 if year==`year'
		}
	}

*****************************************************************
** Head's sex
*****************************************************************

drop headsex
g headsex=sex if relation==1
g headmale1=(headsex==1)
bys hhid year: egen headmale=max(headmale1)

replace headmale=headmale*100

*****************************************************************
** Head's age
*****************************************************************

drop headage
g aux=age if relation==1
bys hhid year: egen headage=max(aux)

*****************************************************************
** Years of education
*****************************************************************

g education_yrs93=education_yrs if  year==1993
g education_yrs04=education_yrs if  year==2004
g education_yrs09=education_yrs if  year==2009
g education_yrs11=education_yrs if  year==2011

lab var education_yrs "Variable imputed from survey, see dataprep.do for details"


*****************************************************************
** Head's years of education
*****************************************************************

g headeducyrs1=education_yrs if relation==1
bys hhid year: egen headeducyrs=max(headeducyrs1)
drop headeducyrs1

*****************************************************************
** Maximum education by household member
*****************************************************************

bys hhid year: egen hheducyrsmax=max(education_yrs)

*****************************************************************
** Maximum education by household member
*****************************************************************

g bor=education_yrs if age>=18

bys hhid year: egen hheducyrsmean=mean(bor)
lab var hheducyrsmean "Average years of education in hhold, 18 years and above"


*****************************************************************
** Proportion of adults with over certain levels of education
*****************************************************************

compress

g ahheduc_0_2=(education_yrs==0)
g ahheduc_2_5=(education_yrs==2 | education_yrs==5)
g ahheduc_8=(education_yrs==8)
g ahheduc_10=(education_yrs==10)
g ahheduc_15=(education_yrs==15)

g bhheduc_0=ahheduc_0
g bhheduc_2_5=ahheduc_2_5
g bhheduc_8=ahheduc_8
g bhheduc_10=ahheduc_10
g bhheduc_15=ahheduc_15

replace bhheduc_0=0 	if age<=18
replace bhheduc_2_5=0 	if age<=18
replace bhheduc_8=0 	if age<=18
replace bhheduc_10=0 	if age<=18
replace bhheduc_15=0 	if age<=18

bysort year hhid: egen chheduc_0=sum(bhheduc_0)
bysort year hhid: egen chheduc_2_5=sum(bhheduc_2_5)
bysort year hhid: egen chheduc_8=sum(bhheduc_8)
bysort year hhid: egen chheduc_10=sum(bhheduc_10)
bysort year hhid: egen chheduc_15=sum(bhheduc_15)

bysort year hhid: egen dhheduc_0=max(chheduc_0)
bysort year hhid: egen dhheduc_2_5=max(chheduc_2_5)
bysort year hhid: egen dhheduc_8=max(chheduc_8)
bysort year hhid: egen dhheduc_10=max(chheduc_10)
bysort year hhid: egen dhheduc_15=max(chheduc_15)

g auxaux=1
bysort year hhid: egen anmembers=sum(auxaux) if age>18
bysort year hhid: egen nmembers=max(anmembers)

gen hheduc_0=dhheduc_0/nmembers
gen hheduc_2_5=dhheduc_2_5/nmembers
gen hheduc_8=dhheduc_8/nmembers
gen hheduc_10=dhheduc_10/nmembers
gen hheduc_15=dhheduc_15/nmembers

lab var hheduc_0 "Share of adult household members with 0 years of education"
lab var hheduc_2_5 "Share of adult household members with 2-5 years of education"
lab var hheduc_8   "Share of adult household members with 8 years of education"
lab var hheduc_10  "Share of adult household members with 10 years of education"
lab var hheduc_15  "Share of adult household members with 15 years of education"

drop ahheduc_0 ahheduc_2_5 ahheduc_8 ahheduc_10 ahheduc_15
drop bhheduc_0 bhheduc_2_5 bhheduc_8 bhheduc_10 bhheduc_15
drop chheduc_0 chheduc_2_5 chheduc_8 chheduc_10 chheduc_15
drop dhheduc_0 dhheduc_2_5 dhheduc_8 dhheduc_10 dhheduc_15
drop auxaux anmembers nmembers

*****************************************************************
* Head of household marital status
*****************************************************************

g aux1=marital if relation==1
bysort year hhid: egen headmarital=max(aux1)
drop aux1


*****************************************************************
** Illiterate
*****************************************************************

replace illiterate=illiterate*100

g illiterate93=illiterate if  year==1993
g illiterate04=illiterate if  year==2004
g illiterate09=illiterate if  year==2009
g illiterate11=illiterate if  year==2011 

*****************************************************************
** Head's literacy 
*****************************************************************

g headilliterate1=illiterate if relation==1
bys hhid year: egen headilliterate=max(headilliterate1)
drop headilliterate


*****************************************************************
** Below primary
*****************************************************************

replace belowprimary=belowprimary*100

g belowprimary93=belowprimary if  year==1993
g belowprimary04=belowprimary if  year==2004
g belowprimary09=belowprimary if  year==2009
g belowprimary11=belowprimary if  year==2011

*****************************************************************
** Primary
*****************************************************************

replace primary=primary*100

g primary93=primary if  year==1993
g primary04=primary if  year==2004
g primary09=primary if  year==2009
g primary11=primary if  year==2011

*****************************************************************
** Middle school
*****************************************************************

replace middle=middle*100

g middle93=middle if  year==1993
g middle04=middle if  year==2004
g middle09=middle if  year==2009
g middle11=middle if  year==2011

*****************************************************************
** Secondary school
*****************************************************************

replace secondary=secondary*100

g secondary93=secondary if  year==1993
g secondary04=secondary if  year==2004
g secondary09=secondary if  year==2009
g secondary11=secondary if  year==2011

*****************************************************************
** Dependency ratio
*****************************************************************

compress

*In Schedule 10, working age is defined as 15-60

g d_0_14=(age>=0 & age<=14)
g d_15_60=(age>=15 & age<=60)
g d_61_plus=(age>=61)

bysort hhid year: egen a_0_14=sum(d_0_14)
bysort hhid year: egen a_15_60=sum(d_15_60)
bysort hhid year: egen a_61_plus=sum(d_61_plus)

*g s_0_12=(a_0_12/hhsize)*100
*g s_13_18=(a_13_18/hhsize)*100
*g s_19_50=(a_19_50/hhsize)*100
*g s_51_plus=(a_51_plus/hhsize)*100

g dependency=(a_0_14+a_61_plus)/a_15_60

*Some households have missing depedency ratio beacuse no person in in 15-60 age range
*Replace those for max dependency rato by district

bysort year state district: egen dependency1=max(dependency)
replace dependency=dependency1 if dependency==.
drop dependency1
lab var dependency "(a_0_14+a_61_plus)/a_15_60"

drop a_0_14 a_15_60 a_61_plus

drop d_0_14 d_15_60 d_61_plus

g dependency93=dependency if  year==1993
g dependency04=dependency if  year==2004
g dependency09=dependency if  year==2009
g dependency11=dependency if  year==2011

g d_0_6=(age>=0 & age<=6)
g d_7_17=(age>=7 & age<=17)
g d_18_60_male=(age>=18 & age<=60 & sex==1)
g d_18_65_male=(age>=18 & age<=65 & sex==1)
g d_18_70_male=(age>=18 & age<=70 & sex==1)
g d_61_plus=(age>=61)
g d_66_plus=(age>=66)
g d_71_plus=(age>=71)

g d_18_60=(age>=18 & age<=60)
g d_18_65=(age>=18 & age<=65)
g d_18_70=(age>=18 & age<=70)

bysort hhid year: egen n_0_6=sum(d_0_6)
bysort hhid year: egen n_7_17=sum(d_7_17)
bysort hhid year: egen n_workingagemale60=sum(d_18_60_male)
bysort hhid year: egen n_workingagemale65=sum(d_18_65_male)
bysort hhid year: egen n_workingagemale70=sum(d_18_70_male)
bysort hhid year: egen n_61_plus=sum(d_61_plus)
bysort hhid year: egen n_66_plus=sum(d_66_plus)
bysort hhid year: egen n_71_plus=sum(d_71_plus)

bysort hhid year: egen n_workingage60=sum(d_18_60)
bysort hhid year: egen n_workingage65=sum(d_18_65)
bysort hhid year: egen n_workingage70=sum(d_18_70)

lab var n_0_6 "Number of children aged 0-6 years"
lab var n_7_17 "Number of children aged 7-17 years"
lab var n_workingagemale60 "Number of working age males"
lab var n_workingagemale65 "Number of working age males"
lab var n_workingagemale70 "Number of working age males"
lab var n_61_plus "Number of elderly aged 61 years and above"
lab var n_66_plus "Number of elderly aged 66 years and above"
lab var n_71_plus "Number of elderly aged 71 years and above"

lab var n_workingage60 "Number of working age"
lab var n_workingage65 "Number of working age"
lab var n_workingage70 "Number of working age"

*****************************************************************
** Household size
*****************************************************************

g hhsize93=hhsize if  year==1993
g hhsize04=hhsize if  year==2004
g hhsize09=hhsize if  year==2009
g hhsize11=hhsize if  year==2011

*****************************************************************
** Extended families
*****************************************************************

g pp=1  if (relation==3 | relation==4 | relation==3 | relation==6 | relation==7 | relation==8)
bysort year hhid: egen pp1=max(pp)

g extended=(pp1==1)
lab var extended "Extended family, three generations"

drop pp pp1



***************************************************************************************************
**Occupation
****************************************************************************************************

compress

g 		nco=.

*NOC 2004
g nco04=nco3 if (year==2009 | year==2011)
gen nco_1=substr(nco04, 1, 1)
gen nco_2=substr(nco04, 1, 2)

replace	nco=5 if nco_1=="1" & (year==2009 | year==2011) & nco==.
replace nco=4 if nco_1=="2" & (year==2009 | year==2011) & nco==.
replace nco=4 if nco_1=="3" & (year==2009 | year==2011) & nco==.
replace nco=6 if nco_1=="4" & (year==2009 | year==2011) & nco==.
replace nco=7 if nco_1=="6" & (year==2009 | year==2011) & nco==.
replace nco=3 if nco_1=="7" & (year==2009 | year==2011) & nco==.
replace nco=3 if nco_1=="8" & (year==2009 | year==2011) & nco==.

replace nco=2 if nco_2=="51" & (year==2009 | year==2011) & nco==.
replace nco=1 if nco_2=="52" & (year==2009 | year==2011) & nco==.

replace nco=8 if nco_2=="91" & (year==2009 | year==2011) & nco==.
replace nco=9 if nco_2=="92" & (year==2009 | year==2011) & nco==.
replace nco=8 if nco_2=="93" & (year==2009 | year==2011) & nco==.

*NOC 1968
g nco68=nco3 if (year==1993 | year==2004)
destring nco68, replace force

replace nco=1 if (year==1993 | year==2004) & (nco68>=400 & nco68<=419) & nco==.
replace nco=1 if (year==1993 | year==2004) & nco68==430 & nco==.
replace nco=1 if (year==1993 | year==2004) & nco68==439 & nco==.
replace nco=1 if (year==1993 | year==2004) & nco68==490 & nco==.

replace nco=2 if (year==1993 | year==2004) & (nco68>=370 & nco68<=399) & nco==.
replace nco=2 if (year==1993 | year==2004) & (nco68>=500 & nco68<=530) & nco==.
replace nco=2 if (year==1993 | year==2004) & (nco68>=560 & nco68<=570) & nco==.
replace nco=2 if (year==1993 | year==2004) & (nco68>=590 & nco68<=591) & nco==.

replace nco=3 if (year==1993 | year==2004) & nco68==551 & nco==.
replace nco=3 if (year==1993 | year==2004) & nco68==650 & nco==.
replace nco=3 if (year==1993 | year==2004) & (nco68>=710 & nco68<=857) & nco==.
replace nco=3 if (year==1993 | year==2004) & (nco68>=870 & nco68<=970) & nco==.
replace nco=3 if (year==1993 | year==2004) & (nco68>=972 & nco68<=974) & nco==.
replace nco=3 if (year==1993 | year==2004) & nco68==679 & nco==.
replace nco=3 if (year==1993 | year==2004) & (nco68>=981 & nco68<=987) & nco==.
replace nco=3 if (year==1993 | year==2004) & nco68==989 & nco==.

replace	nco=4 if (year==1993 | year==2004) & (nco68>=0 & nco68<=199)   & nco==.  
replace	nco=4 if (year==1993 | year==2004) & (nco68>=420 & nco68<=429) & nco==.
replace	nco=4 if (year==1993 | year==2004) & (nco68>=440 & nco68<=449) & nco==.
replace	nco=4 if (year==1993 | year==2004) & (nco68>=571 & nco68<=579) & nco==.
replace	nco=4 if (year==1993 | year==2004) & (nco68>=859 & nco68<=869) & nco==.

replace nco=5 if (year==1993 | year==2004) & (nco68>=200 & nco68<=299) & nco==.
replace nco=5 if (year==1993 | year==2004) & nco68==360 & nco==.
replace nco=5 if (year==1993 | year==2004) & nco68==369 & nco==.
replace nco=5 if (year==1993 | year==2004) & (nco68>=600 & nco68<=609) & nco==.

replace nco=6 if (year==1993 | year==2004) & (nco68>=300 & nco68<=359) & nco==.
replace nco=6 if (year==1993 | year==2004) & nco68==361 & nco==.
replace nco=6 if (year==1993 | year==2004) & (nco68>=450 & nco68<=459) & nco==.

replace nco=7 if (year==1993 | year==2004) & (nco68>=610 & nco68<=629) & nco==.
replace nco=7 if (year==1993 | year==2004) & nco68==641 & nco==.
replace nco=7 if (year==1993 | year==2004) & (nco68>=651 & nco68<=689) & nco==.

replace nco=8 if (year==1993 | year==2004) & nco68==431 & nco==.
replace nco=8 if (year==1993 | year==2004) & (nco68>=531 & nco68<=550) & nco==.
replace nco=8 if (year==1993 | year==2004) & nco68==559 & nco==.
replace nco=8 if (year==1993 | year==2004) & nco68==599 & nco==.
replace nco=8 if (year==1993 | year==2004) & nco68==971 & nco==.
replace nco=8 if (year==1993 | year==2004) & (nco68>=975 & nco68<=976) & nco==.
replace nco=8 if (year==1993 | year==2004) & nco68==980 & nco==.
replace nco=8 if (year==1993 | year==2004) & nco68==988 & nco==.

replace nco=9 if (year==1993 | year==2004) & (nco68>=630 & nco68<=640) & nco==.
replace nco=9 if (year==1993 | year==2004) & nco68==649 & nco==.

ren nco nco9

lab var nco9 "Classification of occupations (9 categories)"
note nco9: The principal occupation of the household is the occupation from any of the household members which fetched the maximum earnings for the household 

la def occupation9 1 "Sales workers" 2 "Service workers" 3 "Production and transportation workers" 4 "Professional and technical workers" 5 "Admin, executive and managerial works" 6 "Clerical and related workers" 7 "Skilled agricultural workers" 8 "Unskilled agricultural workers" 9 "Unskilled production workers"
la val nco9 occupation9

drop nco3 nco_1 nco_2 nco68 nco04

g 		bluecollar9=(nco==1 | nco==2 | nco==3 | nco==6)
replace bluecollar9=. if nco==.
la def bluecollar9 1 "Blue collar"
la val bluecollar9 bluecollar9
lab var bluecollar9 "Blue collar based on 9 occupation categories"

g 		whitecollar9=(nco==4 | nco==5)
replace whitecollar9=. if nco==.
la def whitecollar9 1 "White collar"
la val whitecollar9 bluecollar9
lab var whitecollar9 "White collar based on 9 occupation categories"

/*
g 		unskilled9=(nco==8 | nco==9)
replace unskilled9=. if nco==.
la def unskilled9 1 "Agricultural worker"
la val unskilled9 unskilled9
lab var unskilled9 "Unskilled worker (agricultural and non agricultural) based on 9 occupation categories"
*/

g 		unskilled9=(nco==8 | nco==9  | nco==7)
replace unskilled9=. if nco==.
la def unskilled9 1 "Agricultural worker"
la val unskilled9 unskilled9
lab var unskilled9 "Agricultural and unskilled worker based on 9 occupation categories"

*Tabulating variables

egen tag_hh=tag(year hhid)

tab nco9 [aw=hhwt] if year==2004 & tag_hh==1, m
tab bluecollar9 [aw=hhwt] if year==2004 & tag_hh==1
tab whitecollar9 [aw=hhwt] if year==2004 & tag_hh==1
tab unskilled9 [aw=hhwt] if year==2004 & tag_hh==1

ren bluecollar9 bluecollar
ren whitecollar9 whitecollar
ren unskilled9 unskilled
ren nco9 nco

lab var bluecollar "Household main source of income comes from blue collar occupation"
lab var whitecollar "Household main source of income comes from white collar occupation"
lab var unskilled "Household main source of income comes from agricultural worker occupation"

note bluecollar: includes sales workrs, servives workers, and production/transportation/laborers
note whitecollar: includes professionals, technical and related workrs; administrative, executive and managerial works; and clerical and related workers
note unskilled: included unskilled agricultural workers and unskilled production and transportation workers

/*
*Creating same occupation but with just 7 categories as in Lahiri et al (2013)
g 		nco7=nco9
replace nco7=7 if nco9==8
replace nco7=3 if nco9==9
la def occupation7 1 "Sales workers" 2 "Service workers" 3 "Production and transportation workers" 4 "Professional and technical workers" 5 "Admin, executive and managerial works" 6 "Clerical and related workers" 7 "Agricultural workers"
la val nco7 occupation7
lab var nco7 "Classification of occupations (7 categories)"
note nco7: The principal occupation of the household is the occupation from any of the household members which fetched the maximum earnings for the household 

ren nco7 nco
drop nco9

g 		bluecollar=(nco==1 | nco==2 | nco==3)
replace bluecollar=. if nco==.
la def bluecollar 1 "Blue collar"
la val bluecollar bluecollar
lab var bluecollar "Blue collar worker as defined in Lahiri et al (2013), footnote 21"

g 		whitecollar=(nco==4 | nco==5 | nco==6)
replace whitecollar=. if nco==.
la def whitecollar 1 "Blue collar"
la val whitecollar bluecollar
lab var whitecollar "White collar worker as defined in Lahiri et al (2013), footnote 21"

g 		agrworker=(nco==7)
replace agrworker=. if nco==.
la def agrworker 1 "Agricultural worker"
la val agrworker agrworker
lab var agrworker "Agricultural worker as defined in Lahiri et al (2013), footnote 21"

tab nco [aw=hhwt] if year==2004 & tag_hh==1, m

tab bluecollar [aw=hhwt] if year==2004 & tag_hh==1
tab whitecollar [aw=hhwt] if year==2004 & tag_hh==1
tab agrworker [aw=hhwt] if year==2004 & tag_hh==1
*/



***************************************************************************************************
**Occupation dummies
****************************************************************************************************

tab nco, g(nco)

ren nco1 ncosales
ren nco2 ncoservice
ren nco3 ncoproduction
ren nco4 ncoprofessional
ren nco5 ncomanagerial
ren nco6 ncoclerical
ren nco7 ncoagricultural


***************************************************************************************************
**Household type
****************************************************************************************************

*The definition of household types for rural areas has changed over time (household types for rural households are different in round 68 from those followed in previous NSS surveys).

ren hhtype hhtype_old

g hhtype=.
*sector=1=rural
*sector=2=urban
replace hhtype=1 if hhtype_old==1 & sector==1 & (year==1993 | year==2004 | year==2009)
replace hhtype=2 if hhtype_old==2 & sector==1 & (year==1993 | year==2004 | year==2009)
replace hhtype=3 if hhtype_old==3 & sector==1 & (year==1993 | year==2004 | year==2009)
replace hhtype=4 if hhtype_old==4 & sector==1 & (year==1993 | year==2004 | year==2009)
replace hhtype=5 if hhtype_old==9 & sector==1 & (year==1993 | year==2004 | year==2009)

replace hhtype=6 if hhtype_old==1 & sector==2
replace hhtype=7 if hhtype_old==2 & sector==2
replace hhtype=8 if hhtype_old==3 & sector==2
replace hhtype=9 if hhtype_old==4 & sector==2

g hhtyperural11=hhtype_old if sector==1 & year==2011
lab var hhtyperural11 "Household type for rural households, round 68"

drop hhtype_old

la def hhtype 1 "Self employment non-agr" 2 "Agricultural labor" 3 "Rural other labor" 4 "Self employment in agr" 5 "Rural others" 6 "Self employment" 7 "Regular wage" 8 "Casual labor" 9 "Urban others"
la val hhtype hhtype
lab var hhtype "Household type"

note hhtype: The household type is decided on the basis of the sources of the household's income during the 365 days preceding the date of survey. Only  household’s income from economic activities is considered for the classification.

tab hhtype [aw=hhwt] if year==1993 & tag_hh==1 & sector==1, m
tab hhtype [aw=hhwt] if year==2004 & tag_hh==1 & sector==1, m
tab hhtype [aw=hhwt] if year==2009 & tag_hh==1 & sector==1, m
tab hhtype [aw=hhwt] if year==2011 & tag_hh==1 & sector==1, m

tab hhtype [aw=hhwt] if year==1993 & tag_hh==1 & sector==1
tab hhtype [aw=hhwt] if year==2004 & tag_hh==1 & sector==1
tab hhtype [aw=hhwt] if year==2009 & tag_hh==1 & sector==1
tab hhtype [aw=hhwt] if year==2011 & tag_hh==1 & sector==1

tab hhtype [aw=hhwt] if year==1993 & tag_hh==1 & sector==2, m
tab hhtype [aw=hhwt] if year==2004 & tag_hh==1 & sector==2, m
tab hhtype [aw=hhwt] if year==2009 & tag_hh==1 & sector==2, m
tab hhtype [aw=hhwt] if year==2011 & tag_hh==1 & sector==2, m

tab hhtype [aw=hhwt] if year==1993 & tag_hh==1 & sector==2
tab hhtype [aw=hhwt] if year==2004 & tag_hh==1 & sector==2
tab hhtype [aw=hhwt] if year==2009 & tag_hh==1 & sector==2
tab hhtype [aw=hhwt] if year==2011 & tag_hh==1 & sector==2


**************************************************************************************************
**Classification of household into household type based on NCO and NIC
****************************************************************************************************

/*
We cannot separate out regular from casual in rural areas:

*Schedule 1, round68 has 6 categories for rufal households:
1) Self-employed in agriculture
2) Self employed in non-agriculture
3) Regular wage/salary earning
4) Casual labor in agriculture
5) Casual labor in non-agriculture
6) Others

*Schedule 1, rounds 50, 61 and 66 have only 5 categories for rural households:
1) Self-employed in agriculture
2) Self employed in non-agriculture
3) Agricultural labor
4) Other labor
5) Others

For schedule 10, Maria does the following classification of individuals but this is based in a different variable available only in Schedule 10, which is called status code

label define status 1 "Self-employed" 2 "Regular" 3 "Casual" 4 "Unemployed" 5 "out-LF"
*/


***************************************************************************************************
**Number of households in each PSUs 
****************************************************************************************************

*Documentation is not clear but numbers for 2009/10 do not seem to correspond to number of households

g fsu09=fsu if year==2009

replace fsu=. if year==2009
lab var fsu "Number of households in primary sampling unit (?)"
note fsu: FSU variable varies at the level of (year state region sector)


***************************************************************************************************
**Region
****************************************************************************************************

*Denis: the number of regions has increased over time -- so by standardizing your data to region 55 you would be working with fewer regions. 
*There is nothing you can do about this if you need a panel, but for purely cross-sectional work you would get a higher level of resolution by using the regions of that particular year.

*no region var in 04, 09, 11 (use state_region)



***************************************************************************************************
**Districts 
****************************************************************************************************

compress

*For the 50th round, NSS never released Block 0 data so no district variable in 1993 dataset

g ndistricts=.

egen ndistricts04=group(state region district) if year==2004
egen ndistricts09=group(state region district) if year==2009
egen ndistricts11=group(state region district) if year==2011

replace ndistricts=ndistricts04 if year==2004
replace ndistricts=ndistricts09 if year==2009
replace ndistricts=ndistricts11 if year==2011

drop ndistricts04 ndistricts09 ndistricts11
la var ndistricts "Number of districts including region identifier"
bysort year: sum ndistricts


***********************************************************************************************************
** Unique identified stratum variable
***********************************************************************************************************
/*
There is no way of  classifying smaller than million people cities into different categories.  Earlier, NSSO used to 
have a stratum of selection based on city size class.  But they discontinued that  practice since 2004-05. 

The best we can do at the moment is to have three cuts for the sample -- rural, urban -- million plus cities, and urban -- rest. 

We're stuck with having to merge district level information from the census (e.g., % of population that is urban).  
Alternatively, we could also just calculate some statistics at the district level based on the NSS data.  There will be some districts where the sample becomes too small.  
One alternative way to proceed is to link the NSS data to district level data (from the Census) on some indicators of degree of urbanness -- e.g., % of population urban, 
% of population in nonfarm occupations, etc -- from the Census 2011.  We could group our PSUs on that basis, for profile work, and use these indicators as controls in the 
propensity score regressions, for the analysis that compares rural and urban households.

*/

sort year state region district sector stratum

egen stratauniq=group(state region district sector stratum) if year==1993
egen stratauniq04=group(state region district sector stratum) if year==2004
egen stratauniq09=group(state region district sector stratum) if year==2009
egen stratauniq11=group(state region district sector stratum) if year==2011

replace stratauniq=stratauniq04 if year==2004
replace stratauniq=stratauniq09 if year==2009
replace stratauniq=stratauniq11 if year==2011

drop stratauniq04 stratauniq09 stratauniq11
lab var stratauniq "Unique stratum identifier within year"
note stratauniq: Constructed by years grouping (state region district sector stratum)

bysort year: sum stratauniq


***********************************************************************************************************
**Urbanization (at the level of strata which is computed at State--> Region --> District --> Sector)
***********************************************************************************************************

*For final variable we do not want for it to be uniquely identified because we are not interested in using this variable to control for spatial difference but for city size

g urbanization=.

replace urbanization=0 if sector==1
replace urbanization=1 if sector==2 & millionplus==0
replace urbanization=2 if sector==2 & millionplus==1

la def urbanization 0 "Rural" 1 "Urban rest" 2 "Urban million plus cities" 
la val urbanization urbanization
lab var urbanization "Degree of urbanization"

g hhwt1=round(hhwt)

tab urbanization [w=hhwt1] if year==1993 & tag_hh==1, m
tab urbanization [w=hhwt1] if year==2004 & tag_hh==1, m
tab urbanization [w=hhwt1] if year==2009 & tag_hh==1, m
tab urbanization [w=hhwt1] if year==2011 & tag_hh==1, m

drop hhwt1

compress

save "$decomposition\Output\data_covariates", replace






