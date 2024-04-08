*** CODE  for a paper entitled "Quantifying the shift of public export finance from fossil fuels to renewable energy" (submitted to Nature Communications) 

*** Corresponding author: Paul Waidelich (paul.waidelich@gess.ethz.ch)


clear all 

cd "/Users/pcenskow/Library/CloudStorage/OneDrive-UniversitédeLausanne/ECA paper/Philipp Graphs"

use "/Users/pcenskow/Library/CloudStorage/OneDrive-UniversitédeLausanne/ECA paper/Final dataset/TXF_data_all_energy_only.dta"

/* Change key variables from string to numeric (e.g., Year)
* re-do year variable numeric 
gen year = 0 
replace year = 2013 if closingyear == "2013"
replace year = 2014 if closingyear == "2014"
replace year = 2015 if closingyear == "2015"
replace year = 2016 if closingyear == "2016"
replace year = 2017 if closingyear == "2017"
replace year = 2018 if closingyear == "2018"
replace year = 2019 if closingyear == "2019"
replace year = 2020 if closingyear == "2020"
replace year = 2021 if closingyear == "2021"
replace year = 2022 if closingyear == "2022"
replace year = 2023 if closingyear == "2023"

* de-string tenor variable 

destring tenor, gen(tenor_num) dpcomma

*/

/* Create deflated eca or deal volume variables

clonevar v = ecainvolvementonthedealin

clonevar dv = volumein


* deflate with base year 2020 (using CPI from the US, Source: IMF); 88,39	90,13	90,25	91,63	93,97	96,72	98,80	100,00	105,58	115,52	120,67

local cpi_2013 = 0.8814
local cpi_2014 = 0.8988
local cpi_2015 = 0.9001
local cpi_2016 = 0.9138
local cpi_2017 = 0.9372
local cpi_2018 = 0.9647
local cpi_2019 = 0.9855
local cpi_2020 = 1
local cpi_2021 = 1.10558
local cpi_2022 = 1.11552
local cpi_2023 = 1.1205

forv i = 2013(1)2023 {
	replace v = v/`cpi_`i'' if year == `i'
	replace dv = dv/`cpi_`i'' if year == `i'
}

* Volumes in Billion 

gen v_bn = v/1000

gen dv_bn = dv/1000

*/

/* Remove non-official ECAs 

gen no_official_eca = 0 
replace no_official_eca = 1 if inlist(ecaname, ///
"Africa Finance Corporation (AFC)", ///
"Asian Development Bank (ADB)", ///
"Asian Infrastructure Investment Bank", ///
"British International Investment (BII)", ///
"China Development Bank") 
replace no_official_eca = 1 if inlist(ecaname, ///
"Deutsche Investitions- und Entwicklungsgesellschaft (DEG)", /// 
"Development Bank of Southern Africa", ///
"European Investment Bank (EIB)", ///
"FMO Development Bank", ///
"International Finance Corporation (IFC)") 
replace no_official_eca = 1 if inlist(ecaname, ///
"OPEC Fund for International Development (OFID)", ///
"Korea Development Bank (KDB)", ///
"TKYB (Turkiye Kalkınma ve Yatırım Bankası)", ///
"Industrial Development Bank of Turkey (TSKB)", ///
"FMO Development Bank", ///
"BNDES")
replace no_official_eca = 1 if inlist(ecaname, ///
"Development Bank of Southern Africa," ///
"Development Bank of Southern Africa (DBSA)", ///
"Afreximbank") 
replace no_official_eca = 1 if ecaname == "MIGA - Multilateral Investment Guarantee Agency"

total v_bn

total v_bn if no_official_eca == 1 // 15 billion, or 4.3% of the total  

total v_bn if no_official_eca == 1 & ff == 1 // 15 billion, or 4.3% of the total  

drop if no_official_eca == 1


*/


/* SWITCHES: domestic financing, and financial instrument  

gen region = 0 
replace region = 1 if ecacountry==dealcountry // domestic 
replace region = 2 if ecaregion==dealregion & ecacountry!=dealcountry // same region 
replace region = 3 if ecaregion!=dealregion & ecacountry!=dealcountry // other region 

label define regiontype 1 "Domestic" 2 "Same region" 3 "Other region" 

label values region regiontype


total v_bn

total v_bn if region == 1 // 18.6 billion or 5.4% of the remaining total  



* dummy variable for direct lending or guarantees 
gen direct_lending = 0 
replace direct_lending = 1 if ecaroleonthedeal == "DFI/MDB direct lender" | ///
ecaroleonthedeal == "ECA direct lender"| ///
ecaroleonthedeal == "Lender"

gen guarantees = 0 
replace guarantees = 1 if ecaroleonthedeal == "DFI/MDB (guarantor)" | ///
ecaroleonthedeal == "ECA (guarantor)"

*/


/* List of switches 


*Guarantees only:
keep if ecaroleonthedeal == "DFI/MDB (guarantor)" | ///
ecaroleonthedeal == "ECA (guarantor)"


*Direct lending only:
keep if ecaroleonthedeal == "DFI/MDB direct lender" | ///
ecaroleonthedeal == "ECA direct lender"| ///
ecaroleonthedeal == "Lender"


drop if region == 1 // drop domestic engagement (about 8% of total ECA involvement)


*Total deal volume, tranchevolume or ecainvolvementonthedealin 
clonevar v = ecainvolvementonthedealin 



*Only E3F countries:
keep if inlist(ecacountry, "Belgium", "Denmark", "Finland", "France", "Germany") | ///
inlist(ecacountry, "Italy", "Netherlands", "Spain", "Sweden", "United Kingdom")

*Only E3F reporting period:
keep if inlist(year, 2015, 2016, 2017, 2018, 2019, 2020)

*Only E3F tenor period
keep if tenor_num > 1


*Only Top 10 Total energy finance countries (identified by all instruments):
keep if inlist(ecacountry, "Japan", "Korea", "China", "Italy", "Denmark", "Germany") | ///
inlist(ecacountry, "United States", "United Kingdom", "Norway", "Spain")


*Only Top 10 Non-E3F countries (identified by all instruments all energy):
keep if inlist(ecacountry, "Japan", "Korea", "China", "United States", "Norway", "Russian Federation") | ///
inlist(ecacountry, "Switzerland", "Egypt", "India", "Canada")


*Only Top 10 Non-E3F countries (identified by all instruments all energy):
keep if inlist(ecacountry, "Japan", "Korea", "China", "United States", "Norway", "Russian Federation") | ///
inlist(ecacountry, "Switzerland", "Egypt", "India", "Canada")

*Only Top 5 Non-E3F countries (identified by all instruments all energy):
keep if inlist(ecacountry, "Japan", "Korea", "China", "United States", "Norway")

* next is Russia (5.8 bn), Switzerland (2.7 bn)

*/


/* Generate additional variables 

* Energy source variable 

gen energy_source_coarse = 0
replace energy_source_coarse = 1 if ff == 1
replace energy_source_coarse = 2 if re == 1
replace energy_source_coarse = 3 if other == 1

label define energy_s_coarse 1 "Fossil" 2 "Renewables" 3 "Other energy"

label values energy_source_coarse energy_s_coarse

* Type of borrower variable 

gen borrowertype2 = 0 
replace borrowertype2 = 1 if borrowertype == "SPV"
replace borrowertype2 = 2 if borrowertype == "Private company"
replace borrowertype2 = 3 if borrowertype == "Government owned company"
replace borrowertype2 = 4 if borrowertype == "Listed company"
replace borrowertype2 = 5 if borrowertype == "Government"
replace borrowertype2 = 6 if !inlist(borrowertype, "SPV", "Private company", ///
"Government owned company", "Listed company", "Government")

label define b_type 1 "SPV" 2 "Private company" 3 "Government owned company" ///
4 "Listed company" 5 "Government" 6 "Other"

label values borrowertype2 b_type


* Unique number of tranches

unique uniquetrancheid, by(tmddealid) gen(tranche_number)


* Periods 

gen p1 = 0
replace p1 = 1 if inlist(year, 2013, 2014, 2015)
gen p2 = 0
replace p2 = 1 if inlist(year, 2016, 2017, 2018, 2019) 
gen p3 = 0
replace p3 = 1 if inlist(year, 2020, 2021) 
gen p4 = 0
replace p4 = 1 if inlist(year, 2022, 2023) 


gen period = 0
replace period = 1 if p1 == 1 
replace period = 2 if p2 == 1
replace period = 3 if p3 == 1
replace period = 4 if p4 == 1


* Total energy finance by period 

bys period: egen tot_en_period = sum(v/1000)

* Total energy finance by year 

bys year: egen tot_en = sum(v/1000)

bys year: egen tot_ff = sum(v/1000) if ff == 1
bys year: egen tot_re = sum(v/1000) if re == 1
bys year: egen tot_other = sum(v/1000) if other != 0


* Total energy finance by period and country 


forv i = 1(1)4 {
bys ecacountry: egen tot_en_p`i' = sum(v/1000) if p`i' == 1 
}

forv i = 1(1)4 {
bys ecacountry: egen tot_ff_p`i' = sum(v/1000) if ff == 1 & p`i' == 1 
}
forv i = 1(1)4 {
bys ecacountry: egen tot_re_p`i' = sum(v/1000) if re == 1 & p`i' == 1 
}
forv i = 1(1)4 {
bys ecacountry: egen tot_other_p`i' = sum(v/1000) if other != 0 & p`i' == 1 
}

* Relative shares of total energy finance by country over total energy finance by period 


forv i = 1(1)4 {
bys ecacountry: egen rel_en_p`i' = mean(tot_en_p`i'/tot_en_period) if p`i' == 1 
}


forv i = 1(1)4 {
bys ecacountry: egen rel_ff_p`i' = mean(tot_en_p`i'/tot_en_period) if ff == 1 & p`i' == 1 
}
forv i = 1(1)4 {
bys ecacountry: egen rel_re_p`i' = mean(tot_en_p`i'/tot_en_period) if re == 1 & p`i' == 1 
}
forv i = 1(1)4 {
bys ecacountry: egen rel_other_p`i' = mean(tot_en_p`i'/tot_en_period) if other != 0 & p`i' == 1 
}


*/

/* Generate specific variables for Figure 1
* energy source by year 

bys year: egen total_coal = sum(v/1000) if coal==1
bys year: egen total_oil = sum(v/1000) if oil==1
bys year: egen total_gas = sum(v/1000) if gas==1
bys year: egen total_wind = sum(v/1000) if wind==1
bys year: egen total_solar = sum(v/1000) if solar==1
bys year: egen total_hydro = sum(v/1000) if hydro==1
bys year: egen total_biomass = sum(v/1000) if biomass==1
bys year: egen total_biogas = sum(v/1000) if biogas==1
bys year: egen total_waste = sum(v/1000) if waste_to_energy==1
bys year: egen total_nuclear = sum(v/1000) if nuclear==1
bys year: egen total_infra = sum(v/1000) if other == 3


*/

/* Generate specific variables for Figure 2

* value chain by year and type of fuel 

forv i = 1(1)5 {
	bys year: egen v_c`i'_coal = sum(v/1000) if v_c==`i' & coal == 1 
}

local names Upstream Midstream Downstream Power_generation Electricity_infrastructure
foreach var of varlist v_c1_coal-v_c5_coal {
    local list `list' `var'
}
forvalues i=1(1)5 {
        local name : word `i' of `names'
        local varname : word `i' of `list'
        label variable `varname' `name'
}

forv i = 1(1)5 {
	bys year: egen v_c`i'_oil = sum(v/1000) if v_c==`i' & oil == 1 
}

local names Upstream Midstream Downstream Power_generation Electricity_infrastructure
foreach var of varlist v_c1_oil-v_c5_oil {
    local list `list' `var'
}
forvalues i=1(1)5 {
        local name : word `i' of `names'
        local varname : word `i' of `list'
        label variable `varname' `name'
}

forv i = 1(1)5 {
	bys year: egen v_c`i'_gas = sum(v/1000) if v_c==`i' & gas == 1 
}

local names Upstream Midstream Downstream Power_generation Electricity_infrastructure
foreach var of varlist v_c1_oil-v_c5_gas {
    local list `list' `var'
}
forvalues i=1(1)5 {
        local name : word `i' of `names'
        local varname : word `i' of `list'
        label variable `varname' `name'
}



*/

/* Generate specific variables for Figure 3 


* Add a country 'All_others'

gen all_others = 0
replace all_others = 1 if !inlist(ecacountry, "Japan", "Korea", "China", "Italy", "Denmark", "Germany", "United States", "United Kingdom", "Norway")


clonevar ecacountry2 = ecacountry

replace ecacountry2 = "All others" if all_others == 1 


* Absolute shares 

forv i = 1(1)3 {
bys ecacountry2: egen tot_en_p`i' = sum(v/1000) if p`i' == 1 
}

forv i = 1(1)3 {
bys ecacountry2: egen tot_ff_p`i' = sum(v/1000) if ff == 1 & p`i' == 1 
}
forv i = 1(1)3 {
bys ecacountry2: egen tot_re_p`i' = sum(v/1000) if re == 1 & p`i' == 1 
}
forv i = 1(1)3 {
bys ecacountry2: egen tot_other_p`i' = sum(v/1000) if other != 0 & p`i' == 1 
}

* Relative shares 

forv i = 1(1)3 {
bys ecacountry2: egen rel_en_p`i' = mean(tot_en_p`i'/tot_en_period) if p`i' == 1 
}


forv i = 1(1)3 {
bys ecacountry2: egen rel_ff_p`i' = mean(tot_en_p`i'/tot_en_period) if ff == 1 & p`i' == 1 
}
forv i = 1(1)3 {
bys ecacountry2: egen rel_re_p`i' = mean(tot_en_p`i'/tot_en_period) if re == 1 & p`i' == 1 
}
forv i = 1(1)3 {
bys ecacountry2: egen rel_other_p`i' = mean(tot_en_p`i'/tot_en_period) if other != 0 & p`i' == 1 
}


* Identification of Top 10 Energy finance countries

collapse (max) tot_en_country, by(ecacountry)

gsort -tot_en_country

keep in 1/10
list, clean noobs

*/

/* Generate specific variables for Figure 4

* By type of borrower 


forv i = 1(1)6 {
	bys year: egen borrower_type_ff`i' = sum(v/1000) if borrowertype2==`i' & ff == 1 
}

forv i = 1(1)6 {
	bys year: egen borrower_type_re`i' = sum(v/1000) if borrowertype2==`i' & re == 1 
}


local names SPV Private_company Gov_owned_company Listed_company Government Other
foreach var of varlist borrower_type_ff1-borrower_type_ff6 {
    local list `list' `var'
}
forvalues i=1(1)6 {
        local name : word `i' of `names'
        local varname : word `i' of `list'
        label variable `varname' `name'
}

local names SPV Private_company Gov_owned_company Listed_company Government Other
foreach var of varlist borrower_type_re1-borrower_type_re6 {
    local list `list' `var'
}
forvalues i=1(1)6 {
        local name : word `i' of `names'
        local varname : word `i' of `list'
        label variable `varname' `name'
}


* Type of financing 


forv i = 1(1)2 {
	bys year: egen f_type_ff`i' = sum(v/1000) if typeoffinancing2==`i' & ff == 1 
}

forv i = 1(1)2 {
	bys year: egen f_type_re`i' = sum(v/1000) if typeoffinancing2==`i' & re == 1 
}


local names New_finance Refinancing 
foreach var of varlist f_type_ff1-f_type_ff2 {
    local list `list' `var'
}
forvalues i=1(1)2 {
        local name : word `i' of `names'
        local varname : word `i' of `list'
        label variable `varname' `name'
}

local names New_finance Refinancing 
foreach var of varlist f_type_re1-f_type_re2 {
    local list `list' `var'
}
forvalues i=1(1)2 {
        local name : word `i' of `names'
        local varname : word `i' of `list'
        label variable `varname' `name'
}




*/



/* Preliminary checks
bys ecacountry (period): egen tot_en = sum(v/1000)  
bys ecacountry (period): egen tot_ff = sum(v/1000) if ff == 1
bys ecacountry (period): egen tot_re = sum(v/1000) if re == 1
bys ecacountry (period): egen tot_other = sum(v/1000) if other != 0

bys period: egen tot_en_all = sum(v/1000)



foreach name in "Korea" "Japan" "Italy" "Denmark" "Germany" "China" "Spain" "Norway" {
     bys ecacountry (period): egen `name' = mean(tot_en/tot_en_all) if ecacountry == "`name'"
 }
 

bys ecacountry (period): egen united_states = mean(tot_en/tot_en_all) if ecacountry == "United States"

bys ecacountry (period): egen united_kingdom = mean(tot_en/tot_en_all) if ecacountry == "United Kingdom"


collapse (sum) Korea Japan Italy Denmark Germany China united_states Spain united_kingdom Norway, by(period) 
list, clean
br

preserve
collapse (max) tot_en Korea Japan Italy Denmark Germany China united_states Spain united_kingdom Norway, by(period ecacountry) 
gsort -tot_en
keep in 1/10
graph hbar Korea Japan Italy Denmark Germany China united_states Spain united_kingdom Norway, over(period)
list, clean noobs
restore






forv i = 1(1)3 {
bys ecacountry: egen tot_ff_p`i' = sum(v/1000) if ff == 1 & p`i' == 1 
}
forv i = 1(1)3 {
bys ecacountry: egen tot_re_p`i' = sum(v/1000) if re == 1 & p`i' == 1 
}
forv i = 1(1)3 {
bys ecacountry: egen tot_other_p`i' = sum(v/1000) if other != 0 & p`i' == 1 
}
 */



/* Generate specific variables for technologies coarse and fine 

* technology coarse by year 

forv i = 1(1)13 {
	bys year: egen tech`i' = sum(v/1000) if tech==`i'
}

local names Coal_fired Gas_fired Oil_fired Other_or_mixed_fossil Wind Solar Hydro Biogas Biomass Geothermal Other_or_mixed_renewables Waste_to_energy Nuclear

foreach var of varlist tech1-tech13 {
    local list `list' `var'
}
forvalues i=1(1)13 {
        local name : word `i' of `names'
        local varname : word `i' of `list'
        label variable `varname' `name'
}

* technology fine by year 


forv i = 1(1)20 {
	bys year: egen tech_fine`i' = sum(v/1000) if tech_fine==`i'
}

local names Coal_fired Gas_fired Gas_fired_combined_cycle Gas_fired_simple_cycle Heavy_fuel_oil_fired Fossil_mixed Other_power Offshore_wind Onshore_wind Other_wind Solar_PV Solar_thermal Small_hydro Large_hydro Biogas Biomass Geothermal Renewables_mixed Waste_to_energy Nuclear

foreach var of varlist tech_fine1-tech_fine20 {
    local list `list' `var'
}
forvalues i=1(1)20 {
        local name : word `i' of `names'
        local varname : word `i' of `list'
        label variable `varname' `name'
}


*/

save "/Users/pcenskow/Library/CloudStorage/OneDrive-UniversitédeLausanne/ECA paper/Final paper/datasets/current_working_file_FEB22.dta", replace

*/ 
