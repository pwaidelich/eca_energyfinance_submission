# Quantifying the shift of public export finance from fossil fuels to renewable energy 
Code and data for Censkowsky et al. (2024). If you have questions about the code or find any errors/bugs, please contact Paul Waidelich (paul.waidelich@gess.ethz.ch, corresponding author).

*Please note that the preliminary version of this repository serves only to ensure maximum transparency regarding our methodology during the review process. Upon publication, all scripts and non-proprietary data will be made available in a permanent repository.*

## Organization of the overall project repository
The repository is organized in accordance to the Code and Software Submission Checklist provided by Nature Research. 
It features the following elements:
 1. Information of system requirements
 2. A brief installation guide
 3. A demo
 4. Instructions for use
 5. Description of scripts in the repository

## (1) Information of system requirements
The scripts can be executed on an ordinary computer and require neither substantial computational resources nor parallel processing. No non-standard software is required.

For do-Files, we used Stata version 17 (Figure 1-4 and supplementary Figures 1-3). We tested the Figures in STATA version 16 and confirm smooth funtioning. 

For Figure 5, we used R version 4.3.1 (2023-06-16 ucrt) with the following details: 
Platform: x86_64-w64-mingw32/x64 (64-bit)
Running under: Windows 10 x64 (build 19045)

Please see more information on R packages used below under "sessionInfo() in R".

## (2) Brief installation guide 
For STATA version 17: Please select your operating system and follow the official installation guide (https://www.stata.com/install-guide/). Typical install time: < 5 mins 

User defined commands: grc1leg2 and shufflevar

*** install grc1leg2 as follows:

1) type 'search grc1leg2' into the Command in STATA
2) click on "grc1leg2 from http://digital.cgdev.org/doc/stata/MO/Misc" and then on "(click here to install)"

*** install shufflevar as follows:
ssc install shufflevar

For R version 4.3.1: Download instructions and installation files for different R versions are available on CRAN (https://cran.r-project.org/bin/windows/base/old/). Typical install time: < 5mins

## (3) Demo 
Instructions to run on the data: 
1. Install the right STATA software and version (see above)
2. Download the demo data file (TXF_data_censored.dta) and store it in your local disk 
3. Open the Script Element 3 ("Figures"). Note that this is the only script that is designed to 'run smoothly', i.e., for reproduction with a separately uploaded, censored dataset (10% sample size).
4. Change the file paths for the current directory according to the following instructions: 

   cd "your local folder to save the graphs in"

   use "your local folder name you saved the demo data in/TXF_data_censored.dta" 

5. Select all and run the Do-File

Expected output: Figures 1-4 (in 33 sub-elements, including png and gph formats). Final figures were prepared using Adobe Illustrator.
Expected runtime: 2 mins 

## (4) Instructions for use 
You can run the STATA code on the demo data as described above. 

Note that we cannot provide full access to the proprietary TXF data and hence no full reproducibility of our article. However, we provide a systematic description of all steps taken to generate the final dataset and figures. Below, we describe each step in detail to plausibilize our procedure to reviewers (7 elements). 


## (5) Description of scripts in the repository

## Element 1

Name: `Element1_procedure_energy_subset.do`: appends the data and creates the energy-related subset.

Description: In this DO-file, we generate the final energy data subset. We execute two main objectives: (i) exclusion of all non-energy related deals; and (ii) re-classification of deals that are falsely classified as non-energy related (e.g., LNG tankers). For a definition of 'energy sector' see Supplementary Table 2 and for a detailed re-classification procedure see main manuscript 'Methods - Classification of of energy-related transactions'.

Specifically, we:
- Import original Excel files and change to STATA data files
- Import and append different datawaves (in total two, 2013-2022 and 2023)
- Screen for additional deals in industries not evidently related to energy (e.g., ships or infrastructure) and due re-classification
- Classify in coarse energy sub-categories coal, oil, gas, oil and gas mixed (fossil fuels) and wind, solar, hydro and other RETs (RETs), and nuclear
- Classify in value chain elements and finer technology elements
- Remove all non-energy related deals from the dataset and save a new version

## Element 2

Name: `Element2_variables.do`: creates variables for the subsequent analyses.

Description: In this DO-file, we further finetune the energy data subset created in Element 1. 

Specifically, we:
- Change key variables from string to numeric (e.g., Year)
- Deflate the two key variables (ECA involvement and total deal volume) using the methodology described in the Main manuscript (see 'Methods - Inflation adjustment').  
- Remove non-official ECAs (see supplementary Table 4 for all organizations that are considered non-official, including those that were part of our original dataset, but that were not active in the energy sector).
- Generate switches for additional checks (e.g., domestic financing, guarantees vs loans).
- Generate additional variables (numeric energy source, type of borrower, periods, total energy finance by period and country, specific variables for Figure 3)
- Identify the Top 10 energy financing countries based on total energy commitments (to inform order of countries in Fig3)
- Generate specific variables for technologies coarse and fine 

## Element 3

Name: `Element3_figures.do`: creates Figures 1-4 and serves as code for demo. This is the ONLY script that is designed to 'run smoothly', i.e., for reproduction with a separately uploaded, censored dataset (10% sample size).

Description: In this DO-file, we:
- Produce Figures 1-4 (in 33 subelements, of which 8 PNG files and 25 .gph files).
- Modifies some of the variables created in element 2 as per the filtering requirements for a given figure (e.g., subset to guarantees or lending only) 
- Is the ONLY code that 'runs smooth' for reviewers that seek to execute the demo codebook  

## Element 4

Name: `Element4_SI_Fig1-3.do`: creates SI Figures 1-3. These figures notably serve to triangulate TXF data presented in the main manuscript with data openly accessible data by Oil Change International. 

Description: In this DO-file, we:
- Create comparable subset from OCI data, which means we only retain Export Credit Agencies and their ECA countries, drop observations prior to the calendar year 2013, and deflate nominal OCI data with the methodology described above
- Compare TXF and OCI data based on all commitments disaggregated by fossil commitments, RET commitments, and Grid commitments (Fig SI 1)
- Replicate Figure 1 of the main manuscript with retaining only highest values in each year (Fig SI 2)    
- Creation of difference dataframes and graphs on a country level for fossil, RET and grid commitments; distinguished by financial instrument (Fig SI 3a and 3b)

## Element 5

Name: `Element5_Censored_datafile.do`: creates the censored demo version of our energy subset (a randomly selected 10% of deals).

Description: In this DO-file, we:
- Draw a variable u at random between 0 and 1 for each unique deal
- Delete all deals with a variable u that is higher than 0.1 (we delete 90% of all deals)
- Export a censored database with 10% of the original deals (CONFIDENTIAL, for review only)   

## Element 6

Name: `figure_recipientcountry_distribution.R`: creates Figure 5 in R using the `240219 TXF_data_all_energy_only.csv` file created by `Element1_procedure_energy_subset.do`.

Description: In this R-script, we:
- Collapse cumulative ECA commitments by recipient country and technology group (renewables or fossils)
- Draw maps of recipient country shares using shapefiles from the `rnaturalearth` package (Fig. 5A)
- Collapse cumulative ECA commitments by deal location (domestic, same region, or different region) and plot as a bar chart (Fig. 5B)
- Collapse cumulative ECA commitments by phase and income country level (as per World Bank) of the recipient country and plot as a bar chart (Fig. 5C)

## Data files in the repository
1. `data/240219 WB Country and Lending Groups.xlsx`: data on the World Bank Country and Lending Groups (used to classify countries into Lower-/Middle-/High-Income in Figure 3c) taken from the World Bank Data Help Desk (URL: https://datahelpdesk.worldbank.org/knowledgebase/articles/906519-world-bank-country-and-lending-groups). Timestamp = download date.
2. `data/txf_countrynames_iso3_matched.csv`: a manually created data frame that matches the country names in the raw TXF data to standardized ISO3 identifiers.
3. `TXF_data_censored.dta`: 10% sample of TXF data. Please keep confidential and use for review purposes only (to run STATA DO-File to produce all figures, 'Element 3'). To access all data, please contact TXF Limited.


## sessionInfo() in R
```
R version 4.3.1 (2023-06-16 ucrt)
Platform: x86_64-w64-mingw32/x64 (64-bit)
Running under: Windows 10 x64 (build 19045)

Matrix products: default


locale:
[1] LC_COLLATE=English_United States.utf8  LC_CTYPE=English_United States.utf8    LC_MONETARY=English_United States.utf8 LC_NUMERIC=C                          
[5] LC_TIME=English_United States.utf8    

time zone: Europe/Zurich
tzcode source: internal

attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods   base     

other attached packages:
 [1] patchwork_1.2.0     rnaturalearth_0.3.4 readxl_1.4.3        sf_1.0-15           ggpubr_0.6.0        janitor_2.2.0       lubridate_1.9.3    
 [8] forcats_1.0.0       stringr_1.5.1       dplyr_1.1.3         purrr_1.0.2         readr_2.1.4         tidyr_1.3.0         tibble_3.2.1       
[15] ggplot2_3.5.0       tidyverse_2.0.0    

loaded via a namespace (and not attached):
 [1] utf8_1.2.4         generics_0.1.3     class_7.3-22       rstatix_0.7.2      KernSmooth_2.23-21 lattice_0.21-8     stringi_1.7.12     hms_1.1.3         
 [9] magrittr_2.0.3     grid_4.3.1         timechange_0.2.0   jsonlite_1.8.7     cellranger_1.1.0   e1071_1.7-13       backports_1.4.1    DBI_1.1.3         
[17] httr_1.4.7         fansi_1.0.5        scales_1.3.0       abind_1.4-5        cli_3.6.1          rlang_1.1.1        units_0.8-5        munsell_0.5.0     
[25] withr_2.5.2        tools_4.3.1        tzdb_0.4.0         ggsignif_0.6.4     colorspace_2.1-0   broom_1.0.5        vctrs_0.6.3        R6_2.5.1          
[33] proxy_0.4-27       lifecycle_1.0.4    classInt_0.4-10    snakecase_0.11.1   car_3.1-2          pkgconfig_2.0.3    pillar_1.9.0       gtable_0.3.4      
[41] glue_1.6.2         Rcpp_1.0.11        tidyselect_1.2.0   rstudioapi_0.15.0  carData_3.0-5      compiler_4.3.1     sp_2.1-2 
```
