*****************************************************************
* Creating final set of covariates (household level dataset)
*****************************************************************

use "$decomposition\Output\data_covariates", clear

g auxfsu=fsu
replace auxfsu=fsu09 if year==2009
egen clusterid=group(year state region district sector stratum auxfsu)
drop auxfsu

*svyset clusterid [w=pwt], strata(stratauniq)

svyset clusterid [w=pwt], strata(stratum)


*****************************************************************
** Keep only household level variables
*****************************************************************

*All the decomposition exercise will be made at the household level as there is no individual level variable that might be interesting to add as covariate. 
*I will then use monthly real household expenditure rather than monthly real per capita household expenditure. For Schedule 10 data, it would make sense to run individual level regressions though.

keep if tag_hh==1
*drop if year==1993
*drop if year==2009

*****************************************************************
** Create total household consumption
*****************************************************************

g real_mhe=real_mpce*hhsize
lab var real_mhe "Real monthly total household expenditure"


*****************************************************************
** Create asset index
*****************************************************************

*Not created in covariates.do because system refuses to provide memory

*tv dvd wmachine stove refrigerator appliances motorcycle motorcar laptop mobile

pca tv dvd wmachine stove refrigerator motorcycle motorcar [w=pwt]
predict assets if e(sample)

*****************************************************************
** Create district level access to electricity
*****************************************************************

bysort year state region district: egen dlightelec=mean(lightelec)
replace dlightelec=. if year==1993
lab var dlightelec "Proportion of households in district that have access to electricity"

egen auxdistrict=group(state region district)
tabstat dlight [w=pwt] if year==2004 & tag_hh==1, by(aux) format(%5.2f)
tabstat dlight [w=pwt] if tag_hh==1, by(year) format(%5.2f)
drop auxdistrict


*****************************************************************
** Create urbanization related dummies
*****************************************************************

g 		rural_1_urbanother_0=.
replace rural_1_urbanother_0=1 if urbanization==0
replace rural_1_urbanother_0=0 if urbanization==1

g 		urbanother_1_million_0=.
replace urbanother_1_million_0=1 if urbanization==1
replace urbanother_1_million_0=0 if urbanization==2

g 		rural_1_million_0=.
replace rural_1_million_0=1 if urbanization==0
replace rural_1_million_0=0 if urbanization==2

g urbanother=(urbanization==1)

g million=(urbanization==2)

*****************************************************************
** Create reginal dummies based on Lahiri and Viktoria's paper
*****************************************************************

g 		region_vl=.
*North
replace region_vl=1 if state==1 | state==2 | state==3  | state==4 | state==5 | state==6 | state==7 | state==9 
*Central
replace region_vl=2 if state==23 | state==22 
*West
replace region_vl=3 if state==8 | state==24 | state==25 | state==26 | state==27 | state==30
*East
replace region_vl=4 if state==10 | state==19 | state==20 | state==21
*Northeast
replace region_vl=5 if state==11 | state==12 | state==13 | state==14 | state==15 | state==16 | state==17 | state==18
*South (East and West)
replace region_vl=6 if state==28 | state==29 | state==32 | state==33 | state==34 | state==31 | state==35

lab def region_vl 1 "North" 2 "Central" 3 "West" 4 "East" 5 "Northeast" 6 "South"
lab val region_vl region_vl

lab var region_vl "Regional dummies for States in India (6 categories)"

*****************************************************************
* Set variables of interest
*****************************************************************

*sector
*lis
*urbanization

*****************************************************************
* Keep only vars of interest
*****************************************************************

keep year state* region district* sector stratum substratum stratauniq stratauniq clusterid hhid pwt hhwt lis urbanization rural urban real_mhe rural_1_urbanother_0 urbanother_1_million_0 rural_1_million_0 urbanother million real_mpce poor* ncosales ncoservice ncoproduction ncoprofessional ncomanagerial ncoclerical ncoagricultural hhtype head_st_sc_obc head_hc head_hc_obc assets cookingelec hheducyrsmax lightelec unskilled hhsize dependency headage headmale head_st head_sc head_ob headeducyrs hheduc_0 hheduc_2_5 hheduc_8 hheduc_10 hheduc_15 bluecollar whitecollar salary dlightelec landowned head_hc unskilled assets cookingelec hheducyrsmax lightelec dwellingowned landowned landsize head_st_sc head_hc93 hc93 region_vl illiterate belowprimary primary middle secondary mpce_mrp pline nic5 headmarital n_workingagemale* n_* extended hheducyrsmean

ren unskilled agricultural

save "$decomposition\Output\data_covariates_h", replace


