/*----------------------------------------------------------------------------------
  GMD Harmonization - Pakistan Social and Living Standards Measurement Survey (PSLM)
------------------------------------------------------------------------------------
<_Program name_>   	PAK_2011_HIES_v02_M_v01_A_SAMRD_IND.do	       </_Program name_>
<_Application_>    	STATA 17.0									     <_Application_>
<_Author(s)_>      	Adriana Castillo Castillo           		      </_Author(s)_>
<_Modified_by_>     Leo Tornarolli <tornarolli@gmail.com>		    </_Modified_by_>
<_Date created_>   	12-2021								           </_Date created_>
<_Date modified>   	04-2025						                  </_Date modified_>
------------------------------------------------------------------------------------
<_Country_>        	PAK											        </_Country_>
<_Survey Title_>   	HIES								           </_Survey Title_>
<_Survey Year_>    	2011										    </_Survey Year_>
------------------------------------------------------------------------------------
<_Version Control_>
Date:				04-2025
File:				PAK_2011_HIES_v02_M_v01_A_SAMRD_IND.do
First version
</_Version Control_>
----------------------------------------------------------------------------------*/

*<_Program setup_>
clear all
set more off

local code         		"PAK"
local cpiver       		"10"
local year         		"2011"
local survey       		"HIES"
local vm           		"02"
local va          		"01"
local type         		"SARMD"
global module       		"IND"
local yearfolder    		"`code'_`year'_`survey'"
local SARMDfolder    		"`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'"
local filename      		"`code'_`year'_`survey'_v`vm'_M_v`va'_A_`type'_${module}"
global output       		"${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\\Data\Harmonized" 
global shares    		"$rootdofiles\_aux\"
global support           "${rootdatalib}\\_CPIs"
*</_Program setup_>

*<_Datalibweb request_>
use   "${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata\\`yearfolder'_v`vm'_M.dta", clear
sort  hhcode idc
merge 1:1 hhcode idc using "${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\Data\Harmonized\\`yearfolder'_v`vm'_M_v`va'_A_`type'_INC.dta"
*</_Datalibweb request_>

	
/*****************************************************************************************************
* STANDARD SURVEY MODULE
*****************************************************************************************************/

*<_countrycode_>
*</_countrycode_>

*<_year_>
*</_year_>*/

*<_survey_>
gen str survey = "`survey'"
*</_survey_>

*<_int_year_> 
gen int_year = year(date)
*</_int_year_>

*<_int_month_> 
gen int_month = month(date)
label define lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
label value int_month lblint_month
*</_int_month_>

*<_fieldwork_> 
gen fieldwork = ym(int_year,int_month)
format %tm fieldwork
la var fieldwork "Date of fieldwork"
*<_/fieldwork_> 

*<_idh_>
gen idh_org = hhcode
*</_idh_>

*<_idp_>
gen idp_org = idc
*</_idp_>

*<_wgt_>
*</_wgt_>

*<_weight_>
*<_weight_note_> Household weight *</_weight_note_>
*<_weight_note_> weight brought in from rawdata *</_weight_note_>
*</_weight_>

*<_strata_>
gen strata = .
*</_strata_>

*<_psu_>
*</_psu_>

*<_vermast_>
gen vermast = "`vm'"
*</_vermast_>
	
*<_veralt_>
gen veralt = "`va'"
*</_veralt_>	


/*****************************************************************************************************
* HOUSEHOLD CHARACTERISTICS MODULE                                                                                                   *
*****************************************************************************************************/

cap gen code = countrycode

*<_urban_>
gen byte urban = region
recode urban (2 = 0) (1 = 1)
*</_urban_>

*<_subnatid1_>
gen 	subnatid1 = "1 - Punjab" 			if  province==2
replace subnatid1 = "2 - Sindh"  			if  province==3
replace subnatid1 = "3 - Khyber Pakhtunkhwa" if  province==1
replace subnatid1 = "4 - Balochistan" 		if  province==4
*</_subnatid1_>

*<_subnatid2_>
gen subnatid2 = "."

*<_subnatid3_>
gen subnatid3 = "."
*</_subnatid3_>

*<_subnatid_sar_>
decode province, gen(subnatid1_sar)
gen subnatid2_sar = ""
gen subnatid3_sar = ""
gen subnatid4_sar = ""
*<_subnatid_sar_>

*<_gaul_adm1_code_>
gen 	gaul_adm1_code = .
replace gaul_adm1_code = 2019 	if  subnatid1=="1 - Punjab"
replace gaul_adm1_code = 2020 	if  subnatid1=="2 - Sindh" 
replace gaul_adm1_code = 2016 	if  subnatid1=="3 - Khyber Pakhtunkhwa"
replace gaul_adm1_code = 2015 	if  subnatid1=="4 - Balochistan" 
*<_gaul_adm1_code_>

*<_ownhouse_>
recode s5q02 (1/2 = 1) (3/4 = 2) (5 = 3) (* = .), gen(ownhouse)
*</_ownhouse_>

*<_typehouse_>
recode s5q02 (1/2 = 1) (3/4 = 2) (5 = 3) (* = .), gen(typehouse)
*</_typehouse_>

*<_tenure_>
gen 	tenure = .
replace tenure = 1 			if  s5q02==1 | s5q02==2
replace tenure = 2 			if  s5q02==3
replace tenure = 3 			if  s5q02==4 | s5q02==5 
*</_tenure_>	

*<_lanholding_>
gen     landholding = 0		if  s9aq01_901==2 | s9aq01_902==2 
replace landholding = 1		if  s9aq01_901==1 | s9aq01_902==1 
notes landholding: "PAK 2011" this variable was generated if household owns at least one acre of agricultural or non-agricultural land
*</_landholding_>	

*<_water_original_>
clonevar j = s5q05
label define lblwater_original 1 "Piped water" 2 "Hand pump" 3 "Motorized pumping/Tube well" 4 "Open well" 5 "Closed well" 6 "Pond/Canal/River/Stream" 7 "Spring" 8 "Mineral water" 9 "Tanker/Truck/water bearer" 10 "Filtration plant" 11 "Other"
label values j lblwater_original		
decode j, gen(water_original)
drop j
*</_water_original_>

*<_water_source_>
gen		water_source = .
replace water_source = 1 		if  s5q05==1
replace water_source = 4 		if  s5q05==2 | s5q05==3
replace water_source = 5 		if  s5q05==5 | s5q05==10
replace water_source = 7 		if  s5q05==8
replace water_source = 10 	if  s5q05==4
replace water_source = 12 	if  s5q05==9
replace water_source = 13 	if  s5q05==6
replace water_source = 14 	if  s5q05==7 | s5q05==11
*</_water_source_>

*<_improved_water_>
gen 	improved_water = .
replace improved_water = 1 	if inlist(water_source,1,2,3,4,5,6,7,12)
replace improved_water = 0 	if inlist(water_source,8,9,10,11,13,14) // Asuming other is not improved water source
*</_improved_water_>

*<_pipedwater_acc_>
gen 	pipedwater_acc = 0 	if  inrange(s5q05,2,11) // Asuming other is not piped water
replace pipedwater_acc = 3 	if  inlist(s5q05,1)
*</_pipedwater_acc_>

*<_watertype_quest_>
gen watertype_quest = 1
*</_watertype_quest_>

*<_piped_water_>
gen 	piped_water = .
replace piped_water = 1 		if  s5q05==1
replace piped_water = 0 		if  inlist(s5q05,2,3,4,5,6,7,8,9,10,11)
*</_piped_water_>

*<_water_jmp_>
gen 	water_jmp = .
replace water_jmp = 1 			if  inlist(s5q05,1)
replace water_jmp = 4 			if  inlist(s5q05,2,3)
replace water_jmp = 6 			if  inlist(s5q05,4)
replace water_jmp = 5 			if  inlist(s5q05,5,10)
replace water_jmp = 12 			if  inlist(s5q05,6)
replace water_jmp = 10 			if  inlist(s5q05,9)
replace water_jmp = 13 			if  inlist(s5q05,8)
replace water_jmp = 14 			if  inlist(s5q05,7,11)
note water_jmp: "PAK 2011" category 'Spring' from raw data is coded as other, given that it is an ambigous category to 'protected spring' 'unprotected spring'
*</_water_jmp_>
 
*<_sar_improved_water_>
gen 	sar_improved_water = .
replace sar_improved_water = 1 	if  inlist(water_jmp,1,2,3,4,5,7,9,10)
replace sar_improved_water = 0 	if  inlist(water_jmp, 6,8,11,12,13,14)
*</_sar_improved_water_>

*<_electricity_>
gen 	electricity = .
replace electricity = 1 			if  s5q04a==1 | s5q04a==2
replace electricity = 0 			if  s5q04a==3 
notes electricity: "PAK 2011" this variable is generated if hh has electrical connection or extension.
*</_electricity_>

*<_toilet_orig_>
gen toilet_orig = s5q14
label define lbltoilet_orig 1 "Flush connected to public sewerage" 2 "Flush connected to pit" 3 "Flush connected to open drain" 4 "Dry raised latrine" 5 "Dry pit latrine" 6 "No toilet in the house"
label values toilet_orig lbltoilet_orig
*</_toilet_orig_>

*<_sewage_toilet_>
gen  	sewage_toilet = s5q14
recode 	sewage_toilet (1 = 1) (2 = 0) (3 = 0) (4 = 0) (5 = 0) (6 = 0)
*</_sewage_toilet_>

*<_toilet_jmp_>
gen 	toilet_jmp = .
replace toilet_jmp = 1 			if  toilet_orig==1
replace toilet_jmp = 3 			if  toilet_orig==2
replace toilet_jmp = 4 			if  toilet_orig==3
replace toilet_jmp = 12 			if  toilet_orig==6
replace toilet_jmp = 13 			if  inlist(toilet_orig,4,5)
*</_toilet_jmp_>

*<_sar_improved_toilet_>
gen 	sar_improved_toilet = .
replace sar_improved_toilet = 1 	if  inlist(toilet_jmp,1,2,3,6,7,9)
replace sar_improved_toilet = 0 	if  inlist(toilet_jmp,4,5,8,10,11,12,13)
*</_sar_improved_toilet_>

*<_sanitation_original_>
clonevar j = s5q14
label define lblsanitation_original 1 "Flush connected to public sewerage" 2 "Flush connected to pit" 3 "Flush connected to open drain" 4 "Dry raised latrine" 5 "Dry pit latrine" 6 "No toilet in the household"
label values j lblsanitation_original
decode j, gen(sanitation_original)
drop j
*</_sanitation_original_>

*<_sanitation_source_>
gen 	sanitation_source = .
replace sanitation_source = 2 		if  s5q14==1
replace sanitation_source = 4 		if  s5q14==2
replace sanitation_source = 9 		if  s5q14==3
replace sanitation_source = 14 		if  s5q14==4
replace sanitation_source = 10 		if  s5q14==5
replace sanitation_source = 13 		if  s5q14==6
*</_sanitation_source_>

*<_improved_sanitation_>
gen 	improved_sanitation = .
replace improved_sanitation = 1 		if  inlist(sanitation_source,1,2,3,4,5,6,7,8)
replace improved_sanitation = 0 		if  inlist(sanitation_source,9,10,11,12,13,14)
*</_improved_sanitation_>
	
*<_toilet_acc_>
gen 	toilet_acc = 3 				if  inrange(s5q14,1,3)
replace toilet_acc = 0 				if  inrange(s5q14,4,6)
*</_toilet_acc_>
	
*<_internet_>
gen internet = .
*</_internet_>


	
/*****************************************************************************************************
* DEMOGRAPHIC MODULE
*****************************************************************************************************/

*<_hsize_>
gen n = 1 		if  s1aq02>=1 & s1aq02<=12
bys hhcode: egen hsize = total(n)
drop n
gen n = 1 		if  s1aq02>=1 & s1aq02<=10
bys hhcode: egen hsize_p = total(n)
drop n
*</_hsize_>

*<_pop_wgt_>
gen pop_wgt = wgt*hsize
*</_pop_wgt_>

*<_relationharm_>
gen byte relationharm = s1aq02
recode relationharm (4 6 7 8 9 10 = 5) (5 = 4) (11 12 = 6)
gen z = 1 					if  s1aq02==1
bys idh: egen y = sum(z)
replace relationharm = 1 		if  y==0 & idc==51 
*</_relationharm_>

*<_relationcs_>
gen byte relationcs = s1aq02
label define lblrelationcs 1 "Head" 2 "Spouse" 3 "Son/Daughter" 4 "Grandchild" 5 "Father/Mother" 6 "Brother/Sister" 7  "Nephew/Niece" 8 "Son/Daughter-in-law" 9 "Brother/Sister-in-law" 10 "Father/Mother-in-law" 11 "Servant/their relatives" 12 "Other"
label values relationcs lblrelationcs
*</_relationcs_>

*<_male_>
gen byte male = s1aq03
recode male (2=0)
*</_male_>

*<_age_>
replace age = 98 	if  age>=98 & age!=.
*</_age_>

*<_soc_>
gen byte soc = .
*</_soc_>

*<_marital_>
gen byte marital = 1 		if  s1aq06==2 | s1aq06==5
replace marital = 2 		if  s1aq06==1
replace marital = 4 		if  s1aq06==4
replace marital = 5 		if  s1aq06==3
*</_marital_>



/*****************************************************************************************************
* EDUCATION MODULE
*****************************************************************************************************/

*<_ed_mod_age_>
gen byte ed_mod_age = 4
*</_ed_mod_age_>

*<_atschool_>
recode s2bq01 (3=1) (1 2 =0), gen(atschool)
replace atschool = . 		if  age<ed_mod_age & age!=.
*</_atschool_>

*<_literacy_>
gen byte literacy = .
replace literacy = 1 		if  s2aq01==1 & s2aq02==1
replace literacy = 0 		if  s2aq01==2 | s2aq02==2
replace literacy = . 		if  age<ed_mod_age & age!=.
notes literacy: "PAK 2011" literacy questions are only asked to individuals 10 years or older
*</_literacy_>

**<_educy_>
/*
code		level					years
	0		0						0
	1		class1					1
	2		class2					2
	3		class3					3
	4		class4					4
	5		class5					5
	6		class6					6
	7		class7					7
	8		class8					8
	9		class9					9
	10		class10					10
	11		polytechnic diploma		13
	12		fa/f.sc/icom			12
	13		ba/b.sc/b.ed			14
	14		ma/msc/m.ed				16
	15		degree in engineering	16
	16		degree in madicine		17
	17		degree in agriculture	16
	18		degree in law			16
	19		m.phill, ph.d			19
	20		other					NA*/
recode  s2bq05 (11 = 13) (13 = 14) (14 15 17 18 = 16) (16 = 17) (20 = .), gen(educy1)

* Substract 1 year to those currently studying before highschool
gen 	educy2 = s2bq14
replace educy2 = s2bq14-1 		if  inrange(educy2,1,10)
* Substract 1 year to those currently attending after secondary
recode  educy2 (11 = 12) (13 = 13) (14 15 17 18 = 15) (16 = 16) (20 = .) 	if  s2bq05==. & s2bq14!=.
gen 	educy3 = .
replace educy3 = educy1 			if  educy2==.
replace educy3 = educy2 			if  educy1==.
ren     educy3 educy
replace educy = 0				if  s2bq01==1
replace educy = . 				if  age<ed_mod_age & age!=.
replace educy = . 				if  age<educy & age!=. & educy!=.
*</_educy_>

*<_educat7_>
gen 	educat7 = .
* Attended in the past 
replace educat7 = 1 		if  s2bq01==1 | s2bq05==0
replace educat7 = 2 		if  s2bq05>=1 & s2bq05<5
replace educat7 = 3 		if  s2bq05==5
replace educat7 = 4 		if  s2bq05>=6 & s2bq05<10 
replace educat7 = 5 		if  s2bq05==10
replace educat7 = 6 		if  s2bq05>=11 & s2bq05<=12  
replace educat7 = 7 		if  inlist(s2bq05,13,14,15,16,17,18,19)
replace educat7 = 8 		if  s2bq05==20
* Currently attending
replace educat7 = 1		if  s2bq14==0
replace educat7 = 2 		if  s2bq14>=1 & s2bq14<=5 & s2bq01==3
replace educat7 = 4 		if  s2bq14>=6 & s2bq14<=10 & s2bq01==3
replace educat7 = 6 		if  s2bq14>=11 & s2bq14<=12 & s2bq01==3 
replace educat7 = 7 		if  inlist(s2bq14,13,14,15,16,17,18,19)
replace educat7 = 8 		if  s2bq14==20 & s2bq01==3 & educat7==.
replace educat7 = .z 	if  s2bq03==3 | s2bq11==3 
* Without the minimum age 
replace educat7 = . 		if  age<ed_mod_age & age!=.
* People with education years bigger than their age
replace educat7 = . 		if  educy>age & age!=. & educy!=.
*</_educat7_>
/*
	11		polytechnic diploma		13
	12		fa/f.sc/icom			12
	13		ba/b.sc/b.ed			14
	14		ma/msc/m.ed				16
	15		degree in engineering	16
	16		degree in madicine		17
	17		degree in agriculture	16
	18		degree in law			16
	19		m.phill, ph.d			19
	20		other					NA*/
*<_educat5_>
gen 	educat5 = .
replace educat5 = 1 		if  educat7==1
replace educat5 = 2 		if  educat7==2
replace educat5 = 3 		if  educat7==3 | educat7==4
replace educat5 = 4 		if  educat7==5
replace educat5 = 5 		if  educat7==6 | educat7==7
replace educat5 = .z 	if  educat7==.z
*</_educat5_>

*<_educat4_>
gen byte educat4 = .
replace educat4 = 1 		if  educat7==1 
replace educat4 = 2 		if  educat7==2 | educat7==3
replace educat4 = 3 		if  educat7==4 | educat7==5
replace educat4 = 4 		if  educat7==6 | educat7==7
replace educat4 = .z 	if  educat7==.z
*</_educat4_>

*<_everattend_>
recode s2bq01 (2 3 =1) (1=0), gen(everattend)
replace everattend = . 	if  age<ed_mod_age & age!=.
*</_everattend_>


/*****************************************************************************************************
* LABOR MODULE
*****************************************************************************************************/

*<_lb_mod_age_>
gen byte lb_mod_age = 10
*</_lb_mod_age_>

*<_lstatus_>
* Reported in a monthly basis (not in a weekly basis)
gen byte lstatus = 1 			if  s1bq01==1 | s1bq03==1
replace lstatus = 2 			if  s1bq01==2 & s1bq03==2
replace lstatus = 3 			if  s1bq01==2 & s1bq03==3
replace lstatus = . 			if  age<lb_mod_age & age!=.
*</_lstatus_>

*<_lstatus_year_>
gen byte lstatus_year = .
*</_lstatus_year_>

*<_empstat_>
gen byte empstat = 1 			if  s1bq06==4
replace empstat = 2 			if  s1bq06==5
replace empstat = 3 			if  s1bq06==1 | s1bq06==2
replace empstat = 4 			if  s1bq06==3 | s1bq06>=6 & s1bq06<=9
replace empstat = . 			if  lstatus!=1
*</_empstat_>

*<_empstat_year_>
gen byte empstat_year = .
*</_empstat_year_>

*<_njobs_>
gen byte njobs = .
*</_njobs_>

*<_njobs_year_>
gen byte njobs_year = .
*</_njobs_year_>

*<_ocusec_>
gen byte ocusec = .
*</_ocusec_>

*<_nlfreason_>
gen byte nlfreason = .
*</_nlfreason_>

*<_unempldur_l_>
gen byte unempldur_l = .
*</_unempldur_l_>

*<_unempldur_u_>
gen byte unempldur_u = .
*</_unempldur_u_>

*<_industry_orig_>
gen industry_orig = s1bq05
#delimit
label define lblindustry_orig
	1	"Crop and animal production, hunting and related services activities"
	2	"Forestry and logging"
	3	"Fishing and aquaculture"
	5	"Mining of coal and lignite"
	6	"Extraction of crude petroleum and natural gas"
	7	"Mining of metal oras"
	8	"Other mining and quarrying"
	9	"Minning support survice activities"
	10	"Manufacture of food products"
	11	"Manufacture of beverages"
	12	"Manufature of tobacco products"
	13	"Manufacture of textile"
	14	"Manufacture of wearing apparel"
	15	"Manufacture of leather and related products"
	16	"Manufacture of wood and products of wood and cork, except furniture; manufacture of articles of straw and plaiting meterials"
	17	"Manufacture of paper and paper products"
	18	"Printing and reproduction of recorded media"
	19	"Manufacture of coke and refined petroleum products"
	20	"Manufacture of chemicals and chemical products"
	21	"Manufacture of basic pharmaceutical products and pharmaceutical preprations"
	22	"Manufacture of rubber and plastics products"
	23	"Manufacture of other non-metalic mineral products"
	24	"Manufacture of basic metals"
	25	"Manufacture of febricated metal products, except mechinary and equipment"
	26	"Manufacture of computer, electronic and optical products"
	27	"Manufacture of electrical equipment"
	28	"Manufacture of Machinery and equipment n.e.c."
	29	"Manufacture of motor vehicles, trailers and semi-trailers"
	30	"Manufacture of other transport equipment"
	31	"Manufacture of furtinure"
	32	"Oher manufacturing"
	33	"Repair and istallation of machinery and equipment"
	35	"Electricity, gas, steam, and airconditioning supply"
	36	"water collection, treatment and supply"
	37	"Sewerage"
	38	"Waste collection, treatment and disposal activities; meterial recovery"
	39	"Remediation activities and other waste management services"
	41	"Construction of buildings"
	42	"Civil engineering"
	43	"Specialized construction activities"
	45	"Wholesale and retail trade and repair of motor vehicles and motorcycles"
	46	"Wholesale trade, except of motor vehicles and motorcycles"
	47	"Retail trade; except of motor vehicles and motorcycles"
	49	"Land transport and transport via pipelines"
	50	"Water transport"
	51	"Air transport"
	52	"Warehousing and storage"
	53	"Postal and courier activities"
	55	"Accommodation"
	56	"Food and beverage service activities"
	58	"Printing activities"
	59	"Motion picture, video and television programme production, sound recording and other music publishing activities"
	60	"Programming and broadcasting activities"
	61	"Telecommunications"
	62	"Computer programming, consultancy and related activities"
	63	"Information service activities"
	64	"Financial service activities, except insurance and pension funding"
	65	"Insurance, reinsurance and pension funding, except compulsory social security"
	66	"Activities auxiliary to financial service and insurance activities"
	68	"Real estate activities"
	69	"Legal and accounting activities"
	70	"Activities of head offices; management consultancy activities"
	71	"Architectural and engineering activities; technical testing and anallysis"
	72	"Scientific research and development"
	73	"Advertising and market research"
	74	"Other professional, scientific and technical activities"
	75	"Veterinary activities"
	77	"Rental and leasing activities"
	78	"Employment activities"
	79	"Travel agency, tour operator, reservation service and related activities"
	80	"Security and investigation activities"
	81	"Services to buildings and lanscape activities"
	82	"Office administrative, office support and other business support activities"
	84	"Public administration and defence; compulsory social security"
	85	"Education"
	86	"Human health activities"
	87	"Residential care activities"
	88	"Social work activities  without accommodation"
	90	"Creative, arts and entertainment activities"
	91	"Libraries, archives, mseums and other cultural activities"
	92	"Gambling and betting activities"
	93	"Sports activites and amusement and recreative activities"
	94	"Activities of membership orginazatoins"
	95	"Repair of Computer and personal and household goods"
	96	"other personal services activities"
	97	"Activities of households as employers of domestic personnel"
	98	"Undifferentiated goods and services producing activities of private households for own use"
	99	"Activities of extraterritorial organizations and bodies";
#delimit cr
label values industry_orig lblindustry_orig
replace industry_orig = . 		if  lstatus!=1
*</_industry_orig_>

*<_industry_>
gen byte	industrycat10 = 1 		if  s1bq05>=1 & s1bq05<5
replace industrycat10 = 2 		if  s1bq05>=5 & s1bq05<10
replace industrycat10 = 3 		if  s1bq05>=10 & s1bq05<35
replace industrycat10 = 4 		if  s1bq05>=35 & s1bq05<41
replace industrycat10 = 5 	 	if  s1bq05>=41 & s1bq05<45
replace industrycat10 = 6 		if  s1bq05>=45 & s1bq05<=47
replace industrycat10 = 7 		if  s1bq05>=49 & s1bq05<=64
replace industrycat10 = 8 		if  s1bq05>=64 & s1bq05<=82
replace industrycat10 = 9 		if  s1bq05==84
replace industrycat10 = 10 		if  s1bq05>=85 & s1bq05<=99
replace industrycat10 = . 		if  lstatus!=1
*</_industry_>

*<_industrycat4_>
gen industrycat4 = industrycat10
recode industrycat4 (2/5 = 2) (6/9 = 3) (10 = 4)
*</_industrycat4_>

*<_occup_orig_>
gen occup_orig = s1bq04
labmask  occup_orig, val(s1bq04) lbl(lbloccup_orig) decode	 
label define lbloccup_orig 1 `"armed forces"', modify
label define lbloccup_orig 11 `"legislators and senior officials"', modify
label define lbloccup_orig 12 `"cooperate managers"', modify
label define lbloccup_orig 13 `"general managers"', modify
label define lbloccup_orig 21 `"physical, mathematical"', modify
label define lbloccup_orig 22 `"life science and health"', modify
label define lbloccup_orig 23 `"teaching professionals"', modify
label define lbloccup_orig 24 `"other professionals"', modify
label define lbloccup_orig 31 `"physical and engineering science"', modify
label define lbloccup_orig 32 `"life science and health associate"', modify
label define lbloccup_orig 33 `"teaching associate professionals"', modify
label define lbloccup_orig 34 `"other associate professionals"', modify
label define lbloccup_orig 41 `"office clerks"', modify
label define lbloccup_orig 42 `"customer services clerks"', modify
label define lbloccup_orig 51 `"personal and protective"', modify
label define lbloccup_orig 52 `"models, salespersons"', modify
label define lbloccup_orig 61 `"market-oriented skilled agricultural"', modify
label define lbloccup_orig 62 `"subsistence agricultural"', modify
label define lbloccup_orig 71 `"extraction and building"', modify
label define lbloccup_orig 72 `"Metal, Machinery And Related Trades Workers ( Metal Moulders, Welders, Sheet-Metal Workers,Structural-Metal, etc)"', modify 
label define lbloccup_orig 73 `"precision, handicraft, printing"', modify
label define lbloccup_orig 74 `"other craft and related trades workers"', modify
label define lbloccup_orig 81 `"stationary-plant and related operators"', modify
label define lbloccup_orig 82 `"machine operators and assemblers"', modify
label define lbloccup_orig 83 `"drivers and mobile-plant operators"', modify
label define lbloccup_orig 91 `"sales and services elementary"', modify
label define lbloccup_orig 92 `"agricultural, fishery and related labourers"', modify
label define lbloccup_orig 93 `"labourers in mining, construction,"', modify
label values occup_orig lbloccup_orig
replace occup_orig = . 		if  lstatus!=1
*</_occup_orig_>

*<_occup_>
gen byte occup = .
replace occup = 10 			if  s1bq04==1
replace occup = 1 			if  s1bq04>=11 & s1bq04<=13
replace occup = 2 			if  s1bq04>=21 & s1bq04<=24
replace occup = 3 			if  s1bq04>=31 & s1bq04<=34
replace occup = 4 			if  s1bq04>=41 & s1bq04<=42
replace occup = 5 			if  s1bq04>=51 & s1bq04<=52
replace occup = 6 			if  s1bq04>=61 & s1bq04<=62
replace occup = 7 			if  s1bq04>=71 & s1bq04<=74
replace occup = 8 			if  s1bq04>=81 & s1bq04<=83
replace occup = 9 			if  s1bq04>=91 & s1bq04<=93
*</_occup_>

*<_firmsize_l_>
gen byte firmsize_l = .
*</_firmsize_l_>

*<_firmsize_u_>
gen byte firmsize_u = .
*</_firmsize_u_>

*<_whours_>
gen 	whours = .
*</_whours_>

*<_wage_>
gen double wage = .
replace wage = s1bq08 		if  s1bq08!=.
replace wage = s1bq10 		if  s1bq10!=.
replace wage = . 			if  lstatus!=1
replace wage = 0 			if  wage>0 & empstat==2 & wage!=.
notes wage: "PAK 2011" this variable is reported monthly and yearly
*</_wage_>

*<_unitwage_>
gen byte unitwage = .
replace unitwage = 5 		if  s1bq08!=.
replace unitwage = 8 		if  s1bq10!=.
replace unitwage = . 		if  lstatus!=1
notes unitwage: "PAK 2011" this variable is reported monthly and yearly
*</_wageunit_>

*<_empstat_2_year_>
gen byte empstat_2_year = .
*</_empstat_2_year_>

*<_empstat_2_>
gen byte empstat_2 = 1 		if  s1bq14==4
replace empstat_2 = 2 		if  s1bq14==5
replace empstat_2 = 3 		if  s1bq14==1 | s1bq14==2
replace empstat_2 = 4 		if  s1bq14==3 | s1bq14>=6 & s1bq14<=9
replace empstat_2 = . 		if  s1bq11!=1
*</_empstat_2_>

*<_industry_2_>
gen 	industry_2 = 1 		if  s1bq13>=1 & s1bq13<5
replace industry_2 = 2 		if  s1bq13>=5 & s1bq13<10
replace industry_2 = 3 		if  s1bq13>=10 & s1bq13<35
replace industry_2 = 4 		if  s1bq13>=35 & s1bq13<41
replace industry_2 = 5 		if  s1bq13>=41 & s1bq13<45
replace industry_2 = 6 		if  s1bq13>=45 & s1bq13<=47
replace industry_2 = 7 		if  s1bq13>=49 & s1bq13<=64
replace industry_2 = 8 		if  s1bq13>=64 & s1bq13<=82
replace industry_2 = 9 		if  s1bq13==84
replace industry_2 = 10 		if  s1bq13>=85 & s1bq13<=99
replace industry_2 = . 		if  s1bq11!=1
gen 	industrycat10_2 = industry_2
recode 	industrycat10_2 (2/5=2) (6/9=3) (10=4), gen(industrycat4_2)
*<_industry_2_>

*<_industry_orig_2_>
gen industry_orig_2 = s1bq13
*</_industry_orig_2>

*<_occup_2_>
gen byte occup_2 = .
replace occup_2 = 10 		if  s1bq12==1
replace occup_2 = 1 			if  s1bq12>=11 & s1bq12<=13
replace occup_2 = 2 			if  s1bq12>=21 & s1bq12<=24
replace occup_2 = 3 			if  s1bq12>=31 & s1bq12<=34
replace occup_2 = 4 			if  s1bq12>=41 & s1bq12<=42
replace occup_2 = 5 			if  s1bq12>=51 & s1bq12<=52
replace occup_2 = 6 			if  s1bq12>=61 & s1bq12<=62
replace occup_2 = 7 			if  s1bq12>=71 & s1bq12<=74
replace occup_2 = 8 			if  s1bq12>=81 & s1bq12<=83
replace occup_2 = 9 			if  s1bq12>=91 & s1bq12<=93
replace occup_2 = . 			if  s1bq11!=1
*</_occup_2_>

*<_wage_2_>
gen  wage_2 = s1bq15
*</_wage_2_>

*<_unitwage_2_>
gen     unitwage_2 = 8 				if  wage_2!=.
replace unitwage_2 = . 				if  s1bq11!=1
*</_unitwage_2_>

*<_contract_>
gen byte contract = .
*</_contract_>

*<_healthins_>
gen byte healthins = .
*</_healthins_>

*<_socialsec_>
gen byte socialsec = .
*</_socialsec_>

*<_union_>
gen byte union = .
*</_union_>

foreach var in lstatus lstatus_year empstat empstat_year njobs njobs_year ocusec nlfreason unempldur_l unempldur_u industry_orig occup_orig occup firmsize_l firmsize_u whours wage unitwage empstat_2 empstat_2_year industry_2 industry_orig_2 occup_2 wage_2 unitwage_2 contract healthins socialsec union{
replace `var'=. if age<lb_mod_age
}


/*****************************************************************************************************
* MIGRATION MODULE
*****************************************************************************************************/

*<_rbirth_juris_>
gen byte rbirth_juris = .
*</_rbirth_juris_>

*<_rbirth_>
gen byte rbirth = .
*</_rbirth_>

*<_rprevious_juris_>
gen byte rprevious_juris = .
*</_rprevious_juris_>

*<_rprevious_>
gen byte rprevious = .
*</_rprevious_>

*<_yrmove_>
gen int yrmove = .
*</_yrmove_>



/*****************************************************************************************************
* ASSETS
*****************************************************************************************************/
notes _dta: "PAK 2011" information on assets comes from durables list, which states the number of items owned by hh at present
notes _dta: "PAK 2011" The relevant question from module 10B only provides information on exepected values from owned animals, not quantities. This would hinder comparability of measurement with other countries.  

*<_landphone_>
recode s5q04c (1 2=1) (3=0), gen(landphone)
clonevar lphone = landphone
*</_landphone_>

*<_cellphone_>
gen cellphone = c02_722>=1 & c02_722<.
*</_cellphone_>

*<_computer_>
gen computer = .
*</_computer_>

*<_radio_>
gen radio = c02_718>=1 & c02_718<.
*</_radio_>

*<_television_>
gen television = c02_716>=1 & c02_716<.
*</_television>

*<_fan_>
gen fan = c02_705>=1 & c02_705<.
*</_fan>

*<_sewingmachine_>
gen sewingmachine = c02_721>=1 & c02_721<.
*</_sewingmachine>

*<_washingmachine_>
gen washingmachine = c02_707>=1 & c02_707<.
*</_washingmachine>

*<_refrigerator_>
gen refrigerator = c02_701>=1 & c02_701<.
*</_refrigerator>

*<_lamp_>
gen lamp = .
*</_lamp>

*<_bycicle_>
gen bicycle = c02_713>=1 & c02_713<.
*</_bycicle>

*<_motorcycle_>
gen motorcycle = c02_715>=1 & c02_715<.
*</_motorcycle>

*<_motorcar_>
gen motorcar = c02_714>=1 & c02_714<.
*</_motorcar>

*<_cow_>
gen cow = .
*</_cow>

*<_buffalo_>
gen buffalo = .
*</_buffalo>

*<_chicken_>
gen chicken = .
*</_chicken>


/*****************************************************************************************************
* WELFARE MODULE
*****************************************************************************************************/

*<_spdef_>
gen spdef = psupind
*</_spdef_>

*<_welfare_>
gen welfare_old = nomexpend/hsize
gen welfare = (nomexpend/hsize)/psupindm_n 
*</_welfare_>

*<_welfarenom_>
gen welfarenom = nomexpend/hsize
*</_welfarenom_>

*<_welfaredef_>
gen welfaredef = texpend/hsize
*</_welfaredef_>

*<_welfshprosperity_>
gen welfshprosperity = welfare
*</_welfshprosperity_>

*<_welfaretype_>
gen welfaretype = "EXP"
*</_welfaretype_>

*<_welfareother_>
gen welfareother = ipcf
*</_welfareother_>

*<_welfareothertype_>
gen welfareothertype = "INC"
*</_welfareothertype_>

*<_welfarenat_>
gen welfarenat = peaexpM
*</_welfarenat_>
	

* QUINTILE, DECILE AND FOOD/NON-FOOD SHARES OF CONSUMPTION AGGREGATE
*levelsof year, loc(y)
*merge m:1 idh using "$shares/PAK_fnf_`y'", keepusing (food_share nfood_share quintile_cons_aggregate decile_cons_aggregate) gen(_merge2)
*drop _merge2


/*****************************************************************************************************
* NATIONAL POVERTY
******************************************************************************************************/

* ADULT EQUIVALENCY
gen eqadult = eqadultM

*<_pline_nat_>
gen pline_nat = new_pline
*</_pline_nat_>

*<_poor_nat_>
gen poor_nat = welfarenat<pline_nat 	if  welfarenat!=. & pline_nat!=.
*</_poor_nat_>



/*****************************************************************************************************
* INTERNATIONAL POVERTY
*****************************************************************************************************/
local year = 2011
/*	
*<_cpi_>
preserve
use   "${support}\\Monthly_CPI.dta", clear
keep if inlist(code,"PAK")
keep code year month yearly_cpi monthly_cpi
keep if month==1 

gen jan_nextyear = monthly_cpi[_n+1] 
foreach x of numlist 11 17 {
	egen yearly_cpi20`x' = mean(yearly_cpi) 		if  year==20`x' 
    egen m_yearly_cpi20`x' = mean(yearly_cpi20`x')
    drop yearly_cpi20`x'
    rename m_yearly_cpi20`x' yearly_cpi20`x'
	gen cpi20`x'_06 = (jan_nextyear/yearly_cpi20`x') 
	}
keep code year cpi20*
tempfile cpibasedata_M
save `cpibasedata_M'
restore 
merge m:1 year using `cpibasedata_M', nogen keep(match)
label variable cpi2011_06 "CPI (CPI from January 2012 base 2011)"
label variable cpi2017_06 "CPI (CPI from January 2012 base 2017)"
*</_cpi_>

*<_ppp_>
preserve
use   "${support}\\Final_CPI_PPP_to_be_used.dta", clear
keep if inlist(code,"PAK") 
replace ppp_2011 = icp2011
replace ppp_2017 = icp2017
collapse (mean) ppp_2011 ppp_2017, by(countryname code ppp_domain_value)
tempfile pppdata
save `pppdata', replace
restore 
merge m:1 code using `pppdata', nogen keep(match)
label variable cpi2011_06 "PPP (base 2011)"
label variable cpi2017_06 "PPP (base 2017)"
*</_ppp_>

*<_cpiperiod_>
gen cpiperiod = "2012m1"
*</_cpiperiod_>	
	
*<_pline_int_>
gen pline_int_215 = 2.15*cpi2017_06*ppp_2017*365/12
*</_pline_int_>

*<_poor_int_>
gen poor_int_215 = welfare<pline_int_215 & welfare!=.
tab poor_int_215 [aw=wgt] 	if !mi(poor_int_215)
*</_poor_int_>

*<_pline_int_>
gen pline_int_365 = 3.65*cpi2017_06*ppp_2017*365/12
*</_pline_int_>

*<_poor_int_>
gen poor_int_365 = welfare<pline_int_365 & welfare!=.
tab poor_int_365 [aw=wgt] 	if !mi(poor_int_365)
*</_poor_int_>

*<_pline_int_>
gen pline_int_685 = 6.85*cpi2017_06*ppp_2017*365/12
*</_pline_int_>

*<_poor_int_>
gen poor_int_685 = welfare<pline_int_685 & welfare!=.
tab poor_int_685 [aw=wgt] 	if !mi(poor_int_685)
*</_poor_int_>
*/
** GINI COEFFICIENT
ainequal welfare [aw=wgt] 

*<_shared_toilet_>
gen shared_toilet = .
*</_shared_toilet_>

*<_industry_>
gen industry = industrycat10
*</_industry_>

*<_weighttype_>
*<_weighttype_note_> Weight type (frequency, probability, analytical, importance) *</_weighttype_note_>
*<_weighttype_note_> weighttype brought in from rawdata *</_weighttype_note_>
capture drop weighttype
gen weighttype = "IW"
*</_weighttype_>


/*****************************************************************************************************
* FINAL STEPS
*****************************************************************************************************/
	
* create variables that were not in questionnaire as missing 
foreach var_notfound in industry_year industry_2_year industry_orig_year industry_orig_2_year occup_year ocusec_year subnatid4 {
	if strmatch("`var_notfound'","*_orig*") g `var_notfound' = ""
	else g `var_notfound' = .
	note `var_notfound': PAK_2011_HIES does not have any relevant questions or variables.
}

* create variables that do not have sufficient definitions from the SAR team
foreach var_notfound in food_share nfood_share pline_int poor_int quintile_cons_aggregate {
	gen `var_notfound'=.
	note `var_notfound': For PAK_2011_HIES, I did not have a sufficient understanding of how `var_notfound' is defined from the SAR team, so it was created as missing.
}

*<_Save data file_>
do    "$rootdofiles\_aux\Labels_SARMD.do"
save  "$output\\`filename'.dta", replace
*</_Save data file_>	
	