# SARMD_Harmonized_Households_Surveys

This repository contains the harmonization do-files of the harmonized households survey collection (SARMD) for South Asian countries. The table below shows the set of available harmonized surveys and its latest version:

| Year    | Afghanistan | Bangladesh | Bhutan | India  | Maldives | Nepal  | Pakistan | Sri Lanka | 
| :----   | :----:      | :----:     | :----: | :----: |  :----:  | :----: | :----:   | :----:    | 
| 2000    |     --      | --          | --  | --   | --  | --   | --  |  --  | 
| 2005    |     --      | --           | --  | --   | --  | --   | --  |  --  | 
| 2010    |     --      |--           | --  | --   | --  | --   | --  |  --  | 
| 2016    |     --      | --           | --  | --   | --  | --   | --  |  --  | 
| 2022    |     --      | v02_M_v04_A  |--   | --   | --  | --   | --  |  --  | 

## Getting Started
### Step-by-step explanation
1. Run the Master do file available in the "Master" directory for each country and year: "code_year_survey_M". 

#### SAR database
2. Run the SARMD do files available in the "SARMD" directory for each country and year: "code_year_survey_SARMD".
   <br>
   a. First, please run the Income do file "code_year_survey__INC.do".
   <br>
   b. Then, run the IND do file "code_year_survey__IND.do".

#### GMD database
3. Run the SARMD do files available in the "SARMD" directory for each country and year, in the following order:
   <br>
   a. Run the COR, DEM, DWL,GEO,IDN,LBR, UTL do files.
   <br>
   b. Run the GMD do file (that will allow you to have the final GMD database that is uploaded to datalibweb).

## Help
For any questions, please get in contact with the SAR Statistical Team at: sardatalab@worldbank.org

## Authors
SAR Data an Stats Team

## Version History
* 1.0
    * Initial Release
