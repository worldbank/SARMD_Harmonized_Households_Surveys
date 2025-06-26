*******************************************************************************
* Program: GMD 2.0 variable and value labels - 17Dec2019.do
* This program defines variable and value labels for all variables in GMD 2.0.
* Optional code in Section 2 also checks if any of the required variables are 
* not present in your your GMD file.
* Date: December 17, 2019
*******************************************************************************

*******************************************************************************
* Section 1: Second order variables
*******************************************************************************
******************** LABOR INCOME
******************** LABOR INCOME FROM MAIN ACTIVITY 
* IF EMPLOYEE
egen    iempp = rsum(iempp_m iempp_nm), missing
replace iempp = .  		if  iempp==0 

* IF WAGE WORKER
egen    isalp = rsum(isalp_m isalp_nm), missing
replace isalp = .  		if  isalp==0

* IF SELF-EMPLOYED
egen    isep  = rsum(isep_m isep_nm), missing
replace isep  = .  		if  isep==0 

* WHEN UNKNOW
egen    iolp  = rsum(iolp_m iolp_nm), missing
replace iolp  = .  		if  iolp==0

* MAIN ACTIVITY INCOME  
egen ip 	= rsum(iempp isalp isep iolp), missing
egen ip_m 	= rsum(iempp_m isalp_m isep_m iolp_m), missing


* WAGE: INCOME PER HOUR (BASED HOURS WORKED REFERENCE WEEK)
*gen wage 	= .
*gen wage_m 	= .


***************** INCOME OTHER THAN MAIN ACTIVITY 
* IF EMPLOYEE
egen    iempnp = rsum(iempnp_m iempnp_nm), missing
replace iempnp = .  		if  iempnp==0

* IF WAGE WORKER
egen    isalnp = rsum(isalnp_m isalnp_nm), missing
replace isalnp = .  		if  isalnp==0

* IF SELF-EMPLOYED
egen    isenp  = rsum(isenp_m isenp_nm), missing
replace isenp  = .  		if  isenp==0

* WHEN UNKNOW
egen    iolnp  = rsum(iolnp_m iolnp_nm), missing
replace iolnp  = .  		if  iolnp==0

* OTHER ACTIVITIES INCOME  
egen inp 	= rsum(iempnp isalnp isenp iolnp), missing
egen inp_m 	=	rsum(iempnp_m isalnp_m isenp_m iolnp_m), missing


********************  LABOR INCOME ALL ACTIVITIES
* IF EMPLOYEE
egen iemp   	= rsum(iempp   iempnp),  missing
egen iemp_m 	= rsum(iempp_m iempnp_m), missing

* IF WAGE WORKER
egen isal   	= rsum(isalp   isalnp),  missing
egen isal_m 	= rsum(isalp_m isalnp_m), missing

* IF SELF-EMPLOYED
egen ise   	= rsum(isep   isenp),  missing
egen ise_m 	= rsum(isep_m isenp_m), missing

* TOTAL INCOME
egen ila	  	= rsum(iemp isal ise iolp iolnp), missing
egen ila_m 	= rsum(iemp_m isal_m ise_m iolp_m iolnp_m), missing


* ALL ACTIVITIES INCOME PER HOUR
gen ilaho 	= .
gen ilaho_m 	= .


* IDENTIFICA PERCEPTORES DE INGRESOS LABORALES
gen     perila = 0
replace perila = 1  		if  ila>0 & ila~=.


******************** NON-LABOR INCOME
* PENSIONS
egen ijubi 	= rsum(ijubi_con ijubi_ncon ijubi_o), missing

* PRIVATE TRANSFERS
egen itranp		= rsum(itranext_m itranext_nm itranint_m itranint_nm itran_ns), missing
egen itranp_m	= rsum(itranext_m itranint_m), missing

* PUBLIC TRANSFER
egen itrane   	= rsum(icct inocct_m inocct_nm itrane_ns), missing
egen itrane_m 	= rsum(icct inocct_m), missing

* PUBLIC AND PRIVATE TRANSFER
egen itran   	= rsum(itrane   itranp), missing
egen itran_m 	= rsum(itrane_m itranp_m), missing

* TOTAL NON-LABOR INCOME
egen inla   		= rsum(ijubi icap itran   inla_otro), missing 
egen inla_m 		= rsum(ijubi icap itran_m inla_otro), missing

 ******************** TOTAL INDIVIDUAL INCOME
* MONETARY
egen ii	 	= rsum(ila inla), missing
* NON-MONETARY
egen ii_m 	= rsum(ila_m inla_m), missing


******************** TOTAL INCOME PER HOUSEHOLD
gen hogarsec = 0

* LABOR INCOME PER HOUSEHOLD 
egen ilf_m = sum(ila_m)  	if  hogarsec==0, by(hhid)
egen ilf   = sum(ila)  		if  hogarsec==0, by(hhid)

* NON-LABOR INCOME PER HOURHOLD
egen inlaf_m = sum(inla_m) 	if  hogarsec==0, by(hhid)
egen inlaf   = sum(inla) 	if  hogarsec==0, by(hhid)

* TOTAL MONETARY INCOME PER HOUSEHOLD
egen itf_m = sum(ii_m)  		if  hogarsec==0, by(hhid)

* HOUSEHOLD INCOME BEFORE IMPUTED RENT
egen itf_sin_ri = sum(ii) 	if  hogarsec==0, by(hhid)

* HOUSEHOLD INCOME WITH IMPUTED RENT
egen    itf = rsum(itf_sin_ri renta_imp) 
replace itf = .  			if  itf_sin_ri==.
replace itf = 0				if  itf_sin_ri<0

* PER CAPITA HOUSEHOLD INCOME 
gen ipcf = itf / members


*******************************************************************************
* Section 3: Variables labels 
*******************************************************************************
cap la var wgt "Household weight"
cap la var isalp_m "Salaried income in the main occupation - monetary"
cap la var isalp_nm "Salaried income in the main occupation - non-monetary"
cap la var isep_m "Self-employed income in the main occupation - monetary"
cap la var isep_nm "Self-employed income in the main occupation - non-monetary"
cap la var iempp_m "Income by employer in the main occupation - monetary"
cap la var iempp_nm "Income by employer in the main occupation - non-monetary"
cap la var iolp_m "Other labor income in the main occupation - monetary"
cap la var iolp_nm "Other labor income in the main occupation - non-monetary"
cap la var isalnp_m "Salaried income in the non-principal occupation - monetary"
cap la var isalnp_nm "Salaried income in the non-principal occupation - non-monetary"
cap la var isenp_m "Self-employed income in the non- principal occupation - monetary"
cap la var isenp_nm "Self-employed income in the non- principal occupation - non-monetary"
cap la var iempnp_m "Income by employer in the non-principal occupation - monetary"
cap la var iempnp_nm "Income by employer in the non- principal occupation - non-monetary"
cap la var iolnp_m "Other labor income in the non-principal - monetary occupation"
cap la var iolnp_nm "Other labor income in the non-principal occupation - non-monetary"
cap la var ijubi_con "Income for retirement and contributory pensions"
cap la var ijubi_ncon "Income for retirement and non-contributory pensions"
cap la var ijubi_o "Income for retirement and pensions (not identified if contributory or not)"
cap la var icap "Income from capital"
cap la var icct "Income from conditional cash transfer programs"
cap la var inocct_m "Income from public transfers not CCT - monetary"
cap la var inocct_nm "Income from public transfers not CCT - non-monetary"
cap la var itrane_ns "Income from unspecified public transfers"
cap la var itranext_m "Income from foreign remittances - monetary"
cap la var itranext_nm "Revenue from remittances from abroad - non-monetary"
cap la var itranint_m "Income by private transfers from the country - monetary"
cap la var itranint_nm "Income by private transfers from the country - non-monetary"
cap la var itran_ns "Income from unspecified private transfers"
cap la var inla_other "Other non-labor income"
cap la var ila "Total labor income"
cap la var ila_m "Labor income - monetary"
*cap la var wage "Hourly income in the main occupation"
*cap la var wage_m "Hourly income in the main occupation - monetary"
cap la var ilaho "Hourly income in all occupations"
cap la var ilaho_m "Hourly income in all occupations - monetary"
cap la var iemp "Income for work as employer"
cap la var iemp_m "Income for work as employer - monetary"
cap la var isal "Income for work as a salaried employee"
cap la var isal_m "Income for work as a salaried employee - monetary"
cap la var ise "Income for work as self-employed"
cap la var ise_m "Income for work as self-employed - monetary"
cap la var iempp "Income by employer in the main occupation - total"
cap la var isalp "Salaried income in the main occupation - total"
cap la var isep "Self-employed income in the main occupation - total"
cap la var iolp "Other labor income in the main occupation - total"
cap la var ip "Income in the main occupation"
cap la var ip_m "Income in the main occupation - monetary"
cap la var iempnp "Income by employer in the non-main occupation - total"
cap la var isalnp "Salaried income in the non-main occupation - total"
cap la var isenp "Self-employed income in the non-main occupation - total"
cap la var iolnp "Other labor income in the main occupation - total"
cap la var inp "Income for work in the non-main activity"
cap la var inp_m "Income for work in the non-main activity - monetary"
cap la var inla "Total non-labor income"
cap la var inla_m "Total non-labor income - monetary"
cap la var ijubi "Income for pensions and retirement"
cap la var itranp "Income by private transfers"
cap la var itranp_m "Income by private transfers - monetary"
cap la var itrane "Income by state transfers"
cap la var itrane_m "Income by state transfers - monetary"
cap la var itran "Income by transfer"
cap la var itran_m "Income by transfer - monetary"
cap la var perila "Number of members with labor income"
cap la var inla_otro "Other non-labor income"
*-
cap la var itf "Total family income"
cap la var itf_m "Total family income - monetary"
cap la var itf_sin_ri "Total family income without imputed income"
cap la var ii "Total individual income"
cap la var ii_m "Total individual income - monetary"
cap la var ilf_m "Total family income - monetary"
cap la var ilf "Total family work income"
cap la var inlaf_m "Total family non-labor income - monetary"
cap la var inlaf "Total family non-labor income"
cap la var renta_imp "Implicit rent for own-housing"
cap la var members "Number of household members"
cap la var ipcf "Household per capita income"


*******************************************************************************
* Section 5: Clean up
*******************************************************************************
order countrycode year hhid pid PSU HHID PID wgt weighttype iempp_m iempp_nm iempp isalp_m isalp_nm isalp isep_m isep_nm isep iolp_m iolp_nm iolp ip ip_m iempnp_m iempnp_nm iempnp isalnp_m isalnp_nm isalnp isenp_m isenp_nm isenp iolnp_m iolnp_nm iolnp inp inp_m iemp iemp_m isal isal_m ise ise_m ila ila_m ilaho ilaho_m perila ijubi ijubi_con ijubi_ncon ijubi_o icap itranext_m itranext_nm itranint_m itranint_nm itran_ns inocct_m inocct_nm itrane_ns inla_otro icct itran itrane itranp itran_m itrane_m itranp_m inla inla_m ii ii_m ilf ilf_m inlaf inlaf_m itf_m itf_sin_ri renta_imp itf hogarsec members ipcf  
 
*<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>*
sort hhid pid
