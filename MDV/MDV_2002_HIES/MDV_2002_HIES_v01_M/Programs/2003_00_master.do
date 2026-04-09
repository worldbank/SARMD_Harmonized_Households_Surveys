/* -----------------------------------------------------------------------------

     Poverty Trend in Maldives
          
     CONTACT: 
	 
	 Silvia Redaelli
	 sredaelli@worldbank.org
	 
	 Giovanni Vecchi 
	 giovanni.vecchi@uniroma2.it
                    
     MASTER FILE
     
     This version: May 1, 2015

----------------------------------------------------------------------------- */

*	Clear environment and set Stata working parameters
	clear
	set more off
	set max_memory ., perm


*	Instruct Stata where to work in the HD
*	(select the proper directory from the list below)

	global path "/Users/Giovz/Documents/giovz/worldbank/maldives/data"

*	Note: 	new dta files are always saved in the folder $path/outputdata/
*			original data are stored in the folder $path/inputdata/
	
	cd $path


/*-------------------------------------------------

	2003_01_check_data.do
	
	AIMS:	- assess 2002/03 data quality 
			- replicate official estimates in the DNP (2012) report 
			- construct consumption aggregate
			
--------------------------------------------------*/

	do 2003_01_check_data.do

/*-------------------------------------------------

	2003_02_consumption_aggregate.do
	
	AIMS:	- assess 2002/03 data quality 
			- replicate official estimates in the DNP (2012) report 
			- construct consumption aggregate
			
--------------------------------------------------*/


	do 2003_02_consumption_aggregate.do


/*-------------------------------------------------

	2003_03_deflation.do
	
	AIM:	- carry out spatial deflation for 2009
			  based on 2003 regions
	
--------------------------------------------------*/


	do 2003_03_deflation.do
	

/*-------------------------------------------------

	2003_04_wfile.do
	
	AIM:	- generate working file
			(individual level)
			- pool 2002-03 and 2009-10 data
	
--------------------------------------------------*/


	do 2003_04_wfile.do
	

/*-------------------------------------------------

	2003_05_poverty_lines.do
	
	AIM:	- produce growth incidence curves 2002-03/2009-10
	
--------------------------------------------------*/

	do 2003_05_poverty_lines.do

	
/*-------------------------------------------------

	2003_06_gic.do
	
	AIM:	- produce growth incidence curves 2002-03/2009-10
	
--------------------------------------------------*/
exit

	do 2003_06_gic.do
	
exit
