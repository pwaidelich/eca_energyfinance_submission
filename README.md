# Quantifying the shift of public export finance from fossil fuels to renewable energy 
Code and data for Censkowsky et al. (2024). If you have questions about the code or find any errors/bugs, please contact Philipp Censkowsky at philipp.censkowsky [at] unil.ch (corresponding author).

*Please note that the preliminary version of this repository serves only to ensure maximum transparency regarding our methodology during the review process. Upon publication, all scripts and non-proprietary data will be made available in a permanent repository.*

## Organization of the overall project repository
The repository features the following elements:
1. The top folder level, which hosts the main TXF data (in DTA format) and all scripts used for the analysis and creation of the figures.
2. The `data` folder, which hosts all secondary data objects (in CSV or Excel format) required.
3. The `graphs` folder, to which figures are exported.

## Scripts in the repository
1. `Element1_procedure_energy_subset.do`: appends the data and creates the energy-related subset.
2. `Element2_variables.do`: creates variables for the subsequent analyses.
3. `Element3_figures.do`: creates Figures 1-4.
5. `Element4_SI_Fig1-3.do`: creates SI Figures 1-3.
6. `Element5_Empty_datafile.do`: creates the censored version of the main data file (``TXF_data_empty.dta``).
7. `figure_recipientcountry_distribution.R`: creates Figure 5 in R using the `240219 TXF_data_all_energy_only.csv` file created by `Element1_procedure_energy_subset.do`.

## Data files in the repository
1. `data/240219 WB Country and Lending Groups.xlsx`: data on the World Bank Country and Lending Groups (used to classify countries into Lower-/Middle-/High-Income in Figure 3c) taken from the World Bank Data Help Desk (URL: https://datahelpdesk.worldbank.org/knowledgebase/articles/906519-world-bank-country-and-lending-groups). Timestamp = download date.
2. `data/txf_countrynames_iso3_matched.csv`: a manually created data frame that matches the country names in the raw TXF data to standardized ISO3 identifiers.
3. `TXF_data_empty.dta`: the main deal- & tranche-level data files provided by TXF, augmented with additional variables created by our scripts. Please note that TXF data is proprietary. Therefore, `TXF_data_empty.dta` is a censored file version that features empty placeholder values for all variables to illustrate the structure and shape of our data set. To access the data, please contact TXF Limited.

## System requirements
The scripts can be executed on an ordinary computer and require neither substantial computational resources nor parallel processing. For do-Files, we used Stata version 17.

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
