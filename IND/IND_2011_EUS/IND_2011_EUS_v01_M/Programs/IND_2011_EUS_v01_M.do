***********************************************************************
*	IND_2011_EUS
*	SAR Labor Harmonization
*	Oct 2024
*	Sizhen Fang, sfang2@worldbank.com
* 	Adapted from GLD code
***********************************************************************

cd "/Users/sizhen/Documents/SAR/IND_2011_EUS/IND_2011_EUS_v01_M/Data/"

* IN the 2011 round, Block 5 is subdivided into three datasets: principal activity,
* subsidiary activity and time disposition.

tempfile pa sa block5

* Principal activity data
use "Original/Block_5_1_Usual principal activity particulars of household members.dta", clear
save `pa' ///456,999 obs

* Subsidiary activity data
use "Original/Block_5_2_Usual subsidiary economic activity particulars of household members.dta", clear
	rename Type_of_Job_Contract Type_of_Job_Contract2
	rename No_of_Workers_in_Enterprise No_of_Workers_in_Enterprise2
	rename Enterprise_Type Enterprise_Type2
	rename Social_Security_Benefits Social_Security_Benefits2
	keep HHID Person_Serial_No Type_of_Job_Contract2 Usual_Subsidiary_Activity_Status	Usual_SubsidiaryActivity_NIC2004 Usual_SubsidiaryActivity_NCO2004 No_of_Workers_in_Enterprise2 Enterprise_Type2 Social_Security_Benefits2

save `sa' //38,098 obs

* Time disposition - unique at the Sample_Hhld_No Person_Se
*** Note the awkward file name with space in the end before .dta
use "Original/Block_5_3_Time disposition during the week ended on .dta", clear


** Sorting procedure

/* Need to order activity status such that the order of priority is as follows:

	a. Working status
	b. Non-working status but seeking employment
	c. Neither working nor available for work
*/

destring Status, gen(priority_tag)
gen num_status = priority_tag
* Classify the level of priority
recode priority_tag 11/72=1 81 82=2 91/98=3 99=.

* Decreasingorder of number of days worked
gen neg_days = -(Total_no_days_in_each_activity)


* Order the records such that priority 1 comes first

/*==============================================================================
The following is the hierarchy of rules for selecting the current weekly activity
	1. Priority tag
	2. Number of days worked in a week
	3. If number of days are equal between two employment activities, the status
	code that is smaller in value is taken as the CWA (e.g., activites 11 and 51
	are worked for 3.5 days each; activity 11 will be the CWA because it is smaller
	in value than 51.
==============================================================================*/

egen PID = concat(HHID Person_Serial_No)

sort PID priority_tag neg_days num_status
bys PID: gen runner = _n

* How many cases wherein this priority order is not followed
count if Status ! = Current_Weekly_Activity_Status & runner==1 //0

drop priority_tag num_status neg_days


* Ensure that No of Days of Nominal Work is constant
bys HHID Person_Serial_No: egen Nominal_rc = max(No_of_Days_with_Nominal_Work)
keep HHID Person_Serial_No  Age Status - Mode_of_Payment Current_Weekly_Activity_Status - Nominal_rc

reshape wide Status NIC_2008_Code Operation Intensity* Total_no_days_in_each_activity Wage_* Mode_of_Payment, i(HHID Person_Serial_No) j(runner)

* Merge these three datasets
merge 1:1 HHID Person_Serial_No using `sa', assert(match master) nogen
merge 1:1 HHID Person_Serial_No using `pa', assert(match master) nogen

save `block5'

* Merge Block 3 with Block 1- 2
use "Original/Block_1_2_Identification of sample household and particulars of field operation.dta", clear
merge 1:1 FSU_Serial_No Hamlet_Group_Sub_Block_No Second_Stage_Stratum_No Sample_Hhld_No using "Original/Block_3_Household characteristics.dta", assert(match) nogen

* Merge with Block 5
merge 1:m HHID using `block5', assert(match) nogen

** There is no HHID variable in Block 3; merge using PSU+ Hamlet + Second stage + HH No
merge m:1 FSU_Serial_No Hamlet_Group_Sub_Block_No Second_Stage_Stratum_No Sample_Hhld_No using "Original/Block_3_Household characteristics.dta", assert(match) nogen

* Merge with Block 4
merge 1:1 HHID Person_Serial_No using "Original/Block_4_Demographic particulars of household members.dta", assert(match) nogen

* Merge with Block 6
merge 1:1 HHID Person_Serial_No using "Original/Block_6_Follow-up questions on availability for.dta", assert(match master) nogen

* Merge with Blcok 7
merge 1:1 HHID Person_Serial_No using "Original/Block_7_Follow-up questions for persons with usual principal activity status code 92 or 93 in col. 3 of  bl.dta", assert(match master) nogen

save "Stata/IND_EUS_2011.dta"
