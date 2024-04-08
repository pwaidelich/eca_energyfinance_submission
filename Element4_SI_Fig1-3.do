*** CODE  for a paper entitled "Quantifying the shift of public export finance from fossil fuels to renewable energy" (submitted to Nature Communications) 

*** Corresponding author: Paul Waidelich (paul.waidelich@gess.ethz.ch)



/* Create comparable subset from OCI data

clear all

import excel "/Users/pcenskow/Library/CloudStorage/OneDrive-UniversitédeLausanne/ECA paper/Submission package/Supplementary Information/Data triangulation OCI/OCI Public Finance for Energy Database.xlsx", sheet("Dataset") firstrow

*** only retain 2013-2023 

keep if visible != "" 

drop if visible == "0"

keep if institutionKind == "Export Credit"

drop if FY < 2013

drop in 1/9 // drop first 9 deals from 2012 (that are listed in FY 2013)

drop if inlist(institutionAbbr, "DFID", "BPI", "KfW", "KfW-IPEX", "IEB", "DFID", "DBJ") // remove DFIs 

keep if inlist(mechanism, "Guarantee", "Guarantee*", "Guarantee *", "Loan", "loan")


clonevar v = amountUSD 

clonevar year = FY


*** deflate with base year 2020 

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

forv i = 2013(1)2022 {
	replace v = v/`cpi_`i'' if year == `i'
}


gen v_bn = v / 1000000000




*** replace with ECA countries 

gen ecacountry = 0 
replace ecacountry = 1 if inlist(institutionAbbr, "NEXI", "JBIC")
replace ecacountry = 2 if inlist(institutionAbbr, "Sinosure", "Chexim")
replace ecacountry = 3 if inlist(institutionAbbr, "K-sure", "Kexim")
replace ecacountry = 4 if inlist(institutionAbbr, "EDC")
replace ecacountry = 5 if inlist(institutionAbbr, "SACE")
replace ecacountry = 6 if inlist(institutionAbbr, "Hermes")
replace ecacountry = 7 if inlist(institutionAbbr, "EXIM US")
replace ecacountry = 8 if inlist(institutionAbbr, "UKEF")
replace ecacountry = 9 if inlist(institutionAbbr, "EXIAR")
replace ecacountry = 10 if inlist(institutionAbbr, "EXIM India")
replace ecacountry = 11 if inlist(institutionAbbr, "Bancomext")
replace ecacountry = 12 if inlist(institutionAbbr, "COFACE")
replace ecacountry = 13 if inlist(institutionAbbr, "ECIC") // South Africa
replace ecacountry = 14 if inlist(institutionAbbr, "EFIC") // Australia
replace ecacountry = 15 if inlist(institutionAbbr, "BICE") // Argentina
replace ecacountry = 16 if inlist(institutionAbbr, "TurkExImBank") // Turkey


label define ecacountries 1 "Japan" 2 "China" 3 "Korea" 4 "Canada" ///
5 "Italy" 6 "Germany" 7 "United States" 8 "United Kingdom" 9 "Russian Federation" 10 "India" 11 "Mexico" ///
12 "France" 13 "South Africa" 14 "Australia" 15 "Argentina" 16 "Turkey"

label values ecacountry ecacountries


gen guarantee = 0
replace guarantee = 1 if inlist(mechanism, "Guarantee", "Guarantee*", "Guarantee *")

gen dl = 0
replace dl = 1 if inlist(mechanism, "Loan", "loan")



*** create comparable variables 

gen ff = 0 
replace ff = 1 if inlist(sector, "Coal", "Efficiency - Fossil", "Mixed or unclear - Fossil", ///
  "Natural Gas", "Oil", "Oil and Gas")


gen re = 0 
replace re = 1 if inlist(sector, "Biofuels", "Biomass", "Efficiency - Clean",  ///
  "Geothermal", "Hydro - Large", "Hydro - Small", "Mixed or unclear - Clean")
replace re = 1 if inlist(sector,  "Offshore wind", "Renewables - Clean", ///
"Renewables - Other", "Renewables and Efficiency ", "Solar", "Wind", "Wind ", ///
 "Wind and Solar")

gen grid = 0 
replace grid = 1 if sector == "Batteries"
replace grid = 1 if stage == "Transmission & Distribution"
 
save "/Users/pcenskow/Library/CloudStorage/OneDrive-UniversitédeLausanne/ECA paper/Submission package/Supplementary Information/Data triangulation OCI/oci.dta", replace

*/


/* Comparison all commitments OCI versus TXF

clear all

*** Overall comparison (all instruments): OCI versus TXF 
use "/Users/pcenskow/Library/CloudStorage/OneDrive-UniversitédeLausanne/ECA paper/Submission package/Supplementary Information/Data triangulation OCI/oci.dta"


preserve 
egen tot_ff = total(v_bn) if ff == 1, by(year)
egen tot_re = total(v_bn) if re == 1, by(year)
egen tot_grid = total(v_bn) if grid == 1, by(year)
collapse (max) tot_ff tot_re tot_grid, by(year)
	foreach x of varlist tot_ff tot_re tot_grid {
	replace `x' = 0 if (`x' == .) 
	}
list
graph twoway line tot_ff tot_re tot_grid year, lc(gs1*0.6 green*0.6 orange*0.6) ///
lw(thick thick thick) yla(0(4)50, angle(0)) xla(2013(2)2023) ///
legend(order(1 "Fossil" 2 "RETs" 3 "Grid") r(1) size(small) region(lp(blank))) ///
title(OCI - All commitments) xtitle("") ytitle(USD billion{sub:2020})
graph save tot_oci, replace 
restore 

clear all

use "/Users/pcenskow/Library/CloudStorage/OneDrive-UniversitédeLausanne/ECA paper/Final paper/datasets/current_working_file_FEB22.dta"

preserve 
gen grid = 0 
replace grid = 1 if other == 3 // only transmission and storage
drop tot_ff
drop tot_re
egen tot_ff = total(v_bn) if ff == 1, by(year)
egen tot_re = total(v_bn) if re == 1, by(year)
egen tot_grid = total(v_bn) if grid == 1, by(year)
collapse (max) tot_ff tot_re tot_grid, by(year)
	foreach x of varlist tot_ff tot_re tot_grid {
	replace `x' = 0 if (`x' == .) 
	}
list
graph twoway line tot_ff tot_re tot_grid year, lc(gs1*0.6 green*0.6 orange*0.6) ///
lw(thick thick thick) yla(0(4)50, angle(0)) xla(2013(2)2023) ///
legend(order(1 "Fossil" 2 "RETs" 3 "Grid") r(1) size(small) region(lp(blank))) ///
title(TXF - All commitments) xtitle("") ytitle(USD billion{sub:2020})
graph save tot_txf, replace 
restore 

grc1leg2 tot_oci.gph tot_txf.gph


*/


*** Replicate Figure 1 with highest values (OCI or TXF) 


/* Create comparable dataframes OCI and TXF (Figure 1)

clear all 
use "/Users/pcenskow/Library/CloudStorage/OneDrive-UniversitédeLausanne/ECA paper/Submission package/Supplementary Information/Data triangulation OCI/oci.dta"

 
*** For Figure 1  

preserve 
keep if ff == 1 | re == 1 | grid == 1
keep if guarantee == 1
egen tot_coal = total(v_bn) if sector == "Coal", by(year)
egen tot_oil = total(v_bn) if sector == "Oil", by(year)
egen tot_gas = total(v_bn) if sector == "Natural Gas", by(year)
egen tot_ff_mixed = total(v_bn) if inlist(sector, "Mixed or unclear - Fossil", "Efficiency - Fossil"), by(year)
egen tot_wind = total(v_bn) if inlist(sector, "Offshore wind", "Wind", "Wind "), by(year)
egen tot_solar = total(v_bn) if sector == "Solar", by(year)
egen tot_re_mixed = total(v_bn) if inlist(sector, "Biofuels", "Biomass", "Efficiency - Clean", ///
"Geothermal", "Hydro - Large", "Hydro - Small", "Mixed or unclear - Clean", "Wind and Solar"), by(year)
egen tot_nuclear = total(v_bn) if sector == "Nuclear", by(year)
egen tot_grid = total(v_bn) if grid == 1, by(year)
collapse (max) tot_coal tot_oil tot_gas tot_ff_mixed tot_wind tot_solar tot_re_mixed ///
tot_nuclear tot_grid, by(year) 
foreach x of varlist tot_coal tot_oil tot_gas tot_ff_mixed tot_wind tot_solar tot_re_mixed ///
tot_nuclear tot_grid {
	replace `x' = 0 if(`x' == .) 
	}
	list, clean noobs
	save "/Users/pcenskow/Library/CloudStorage/OneDrive-UniversitédeLausanne/ECA paper/Final paper/datasets/summary_oci_fig1_g.dta", replace
restore

preserve 
keep if ff == 1 | re == 1 | grid == 1
keep if dl == 1
egen tot_coal = total(v_bn) if sector == "Coal", by(year)
egen tot_oil = total(v_bn) if sector == "Oil", by(year)
egen tot_gas = total(v_bn) if sector == "Natural Gas", by(year)
egen tot_ff_mixed = total(v_bn) if inlist(sector, "Mixed or unclear - Fossil", "Efficiency - Fossil"), by(year)
egen tot_wind = total(v_bn) if inlist(sector, "Offshore wind", "Wind", "Wind "), by(year)
egen tot_solar = total(v_bn) if sector == "Solar", by(year)
egen tot_re_mixed = total(v_bn) if inlist(sector, "Biofuels", "Biomass", "Efficiency - Clean", ///
"Geothermal", "Hydro - Large", "Hydro - Small", "Mixed or unclear - Clean", "Wind and Solar"), by(year)
egen tot_nuclear = total(v_bn) if sector == "Nuclear", by(year)
egen tot_grid = total(v_bn) if grid == 1, by(year)
collapse (max) tot_coal tot_oil tot_gas tot_ff_mixed tot_wind tot_solar tot_re_mixed ///
tot_nuclear tot_grid, by(year) 
foreach x of varlist tot_coal tot_oil tot_gas tot_ff_mixed tot_wind tot_solar tot_re_mixed ///
tot_nuclear tot_grid {
	replace `x' = 0 if(`x' == .) 
	}
	list, clean noobs
	save "/Users/pcenskow/Library/CloudStorage/OneDrive-UniversitédeLausanne/ECA paper/Final paper/datasets/summary_oci_fig1_dl.dta", replace
restore


*** create the same from TXF 

clear all

use "/Users/pcenskow/Library/CloudStorage/OneDrive-UniversitédeLausanne/ECA paper/Final paper/datasets/current_working_file_FEB22.dta"

*** for guarantees 
preserve 
gen grid = 0 
replace grid = 1 if other == 3 // only transmission and storage
keep if ff == 1 | re == 1 | grid == 1
keep if guarantee == 1
egen tot_coal = total(v_bn) if energy_source == 1, by(year)
egen tot_oil = total(v_bn) if energy_source == 2, by(year)
egen tot_gas = total(v_bn) if energy_source == 3, by(year)
egen tot_ff_mixed = total(v_bn) if energy_source == 4, by(year)
egen tot_wind = total(v_bn) if energy_source == 5, by(year)
egen tot_solar = total(v_bn) if energy_source == 6, by(year)
egen tot_re_mixed = total(v_bn) if inlist(energy_source, 7, 8), by(year)
egen tot_nuclear = total(v_bn) if energy_source == 9, by(year)
egen tot_grid = total(v_bn) if grid == 1, by(year)
collapse (max) tot_coal tot_oil tot_gas tot_ff_mixed tot_wind tot_solar tot_re_mixed ///
tot_nuclear tot_grid, by(year) 
foreach x of varlist tot_coal tot_oil tot_gas tot_ff_mixed tot_wind tot_solar tot_re_mixed ///
tot_nuclear tot_grid {
	replace `x' = 0 if(`x' == .) 
	}
	list, clean noobs
	save "/Users/pcenskow/Library/CloudStorage/OneDrive-UniversitédeLausanne/ECA paper/Final paper/datasets/summary_txf_fig1_g.dta", replace
restore

*** for lending 
preserve 
gen grid = 0 
replace grid = 1 if other == 3 // only transmission and storage
keep if ff == 1 | re == 1 | grid == 1
keep if direct_lending == 1
egen tot_coal = total(v_bn) if energy_source == 1, by(year)
egen tot_oil = total(v_bn) if energy_source == 2, by(year)
egen tot_gas = total(v_bn) if energy_source == 3, by(year)
egen tot_ff_mixed = total(v_bn) if energy_source == 4, by(year)
egen tot_wind = total(v_bn) if energy_source == 5, by(year)
egen tot_solar = total(v_bn) if energy_source == 6, by(year)
egen tot_re_mixed = total(v_bn) if inlist(energy_source, 7, 8), by(year)
egen tot_nuclear = total(v_bn) if energy_source == 9, by(year)
egen tot_grid = total(v_bn) if grid == 1, by(year)
collapse (max) tot_coal tot_oil tot_gas tot_ff_mixed tot_wind tot_solar tot_re_mixed ///
tot_nuclear tot_grid, by(year) 
foreach x of varlist tot_coal tot_oil tot_gas tot_ff_mixed tot_wind tot_solar tot_re_mixed ///
tot_nuclear tot_grid {
	replace `x' = 0 if(`x' == .) 
	}
	list, clean noobs
	save "/Users/pcenskow/Library/CloudStorage/OneDrive-UniversitédeLausanne/ECA paper/Final paper/datasets/summary_txf_fig1_dl.dta", replace
restore

*/

/* Join dataframes retaining the highest amount for each year (Figure 1, Guarantee)


clear all

use "/Users/pcenskow/Library/CloudStorage/OneDrive-UniversitédeLausanne/ECA paper/Final paper/datasets/summary_oci_fig1_g.dta"

ren tot_coal tot_coal2
ren tot_oil tot_oil2
ren tot_gas tot_gas2
ren tot_ff_mixed tot_ff_mixed2
ren tot_wind tot_wind2
ren tot_solar tot_solar2
ren tot_re_mixed tot_re_mixed2
ren tot_nuclear tot_nuclear2
ren tot_grid tot_grid2

save "/Users/pcenskow/Library/CloudStorage/OneDrive-UniversitédeLausanne/ECA paper/Final paper/datasets/summary_oci_fig1_g.dta", replace

clear all

use "/Users/pcenskow/Library/CloudStorage/OneDrive-UniversitédeLausanne/ECA paper/Final paper/datasets/summary_txf_fig1_g.dta"

merge using "/Users/pcenskow/Library/CloudStorage/OneDrive-UniversitédeLausanne/ECA paper/Final paper/datasets/summary_oci_fig1_g.dta"

foreach x of varlist * {
	replace `x' = 0 if(`x' == .) 
	}

gen tot_coal3 = 0 

forv i = 2013(1)2023 {
	replace tot_coal3 = tot_coal2 if tot_coal2 > tot_coal & year == `i' 
	replace tot_coal3 = tot_coal if tot_coal2 < tot_coal & year == `i' 
}

gen tot_oil3 = 0 

forv i = 2013(1)2023 {
	replace tot_oil3 = tot_oil2 if tot_oil2 > tot_oil & year == `i' 
	replace tot_oil3 = tot_oil if tot_oil2 < tot_oil & year == `i' 
}

gen tot_gas3 = 0 

forv i = 2013(1)2023 {
	replace tot_gas3 = tot_gas2 if tot_gas2 > tot_gas & year == `i' 
	replace tot_gas3 = tot_gas if tot_gas2 < tot_gas & year == `i' 
}

gen tot_ff_mixed3 = 0 

forv i = 2013(1)2023 {
	replace tot_ff_mixed3 = tot_ff_mixed2 if tot_ff_mixed2 > tot_ff_mixed & year == `i' 
	replace tot_ff_mixed3 = tot_ff_mixed if tot_ff_mixed2 < tot_ff_mixed & year == `i' 
}

gen tot_wind3 = 0 

forv i = 2013(1)2023 {
	replace tot_wind3 = tot_wind2 if tot_wind2 > tot_wind & year == `i' 
	replace tot_wind3 = tot_wind if tot_wind2 < tot_wind & year == `i' 
}

gen tot_solar3 = 0 

forv i = 2013(1)2023 {
	replace tot_solar3 = tot_solar2 if tot_solar2 > tot_solar & year == `i' 
	replace tot_solar3 = tot_solar if tot_solar2 < tot_solar & year == `i' 
}

gen tot_re_mixed3 = 0 

forv i = 2013(1)2023 {
	replace tot_re_mixed3 = tot_re_mixed2 if tot_re_mixed2 > tot_re_mixed & year == `i' 
	replace tot_re_mixed3 = tot_re_mixed if tot_re_mixed2 < tot_re_mixed & year == `i' 
}

gen tot_nuclear3 = 0 

forv i = 2013(1)2023 {
	replace tot_nuclear3 = tot_nuclear2 if tot_nuclear2 > tot_nuclear & year == `i' 
	replace tot_nuclear3 = tot_nuclear if tot_nuclear2 < tot_nuclear & year == `i' 
}

gen tot_grid3 = 0 

forv i = 2013(1)2023 {
	replace tot_grid3 = tot_grid2 if tot_grid2 > tot_grid & year == `i' 
	replace tot_grid3 = tot_grid if tot_grid2 < tot_grid & year == `i' 
}


keep year tot_coal3 tot_oil3 tot_gas3 tot_ff_mixed3 tot_wind3 tot_solar3 tot_re_mixed3 tot_nuclear3 tot_grid3

save "/Users/pcenskow/Library/CloudStorage/OneDrive-UniversitédeLausanne/ECA paper/Final paper/datasets/summary_fig1_highest_g.dta", replace

*/

/* Create SI Figure1 Guarantees 

preserve
	use "/Users/pcenskow/Library/CloudStorage/OneDrive-UniversitédeLausanne/ECA paper/Final paper/datasets/summary_fig1_highest_g.dta"
	foreach x of varlist tot_coal3 tot_oil3 tot_gas3 tot_ff_mixed3 tot_wind3 tot_solar3 tot_re_mixed3 tot_nuclear3 tot_grid3 {
	replace `x' = 0 if(`x' == .) 
	}
	gen sum1 = tot_coal3 + tot_oil3
	gen sum2 = (sum1 + tot_gas3)
	gen sum3 = (sum2 + tot_ff_mixed3) // other/mixed fossil power
	gen sum4 = (sum3 + tot_wind3)
	gen sum5 = (sum4 + tot_solar3)
	gen sum6 = (sum5 + tot_re_mixed3)
	gen sum7 = (sum6 + tot_nuclear3)
	gen sum8 = (sum7 + tot_grid3)
	gen zero = 0
	twoway rarea zero tot_coal3 year, color(gs1*0.8) ///
	|| rarea tot_coal3 sum1 year, color(gs1*0.6)  ///
	|| rarea sum1 sum2 year, color(gs1*0.4) ///
	|| rarea sum2 sum3 year, color(gs1*0.2) ///
	|| rarea sum3 sum4 year, color(green*1.2) ///
	|| rarea sum4 sum5 year, color(green*0.7) ///
	|| rarea sum5 sum6 year, color(green*0.3) ///
	|| rarea sum6 sum7 year, color(yellow*0.4) ///
	|| rarea sum7 sum8 year, color(orange*0.6) ///
	||, legend(order(1 "Coal" 2 "Oil" 3 "Gas" 4 "Other Fossil" 5 "Wind" 6 "Solar" 7 "Other Renew." 8 "Nuclear" 9 "Grid") pos(3) r(9) size(small) symxsize(4) symysize(4) region(lp(blank))) ///
	xla(2013(1)2023, nolab notick grid) ///
	yla(0(5)30, grid angle(0) labsize(small)) xtitle("") ///
	xline(2015.5 2019.5 2021.5, lp(dash) lc(red) lwidth(medthick)) scheme(s1mono)
	 graph save "guarantees_only_highest", replace
	 list year sum3 sum6 sum8, clean noobs
restore

*/



/* Join dataframes retaining the highest amount for each year (Figure 1, Direct Lending)

clear all

use "/Users/pcenskow/Library/CloudStorage/OneDrive-UniversitédeLausanne/ECA paper/Final paper/datasets/summary_txf_fig1_dl.dta"

merge using "/Users/pcenskow/Library/CloudStorage/OneDrive-UniversitédeLausanne/ECA paper/Final paper/datasets/summary_oci_fig1_dl.dta"

foreach x of varlist * {
	replace `x' = 0 if(`x' == .) 
	}

gen tot_coal3 = 0 

forv i = 2013(1)2023 {
	replace tot_coal3 = tot_coal2 if tot_coal2 > tot_coal & year == `i' 
	replace tot_coal3 = tot_coal if tot_coal2 < tot_coal & year == `i' 
}

gen tot_oil3 = 0 

forv i = 2013(1)2023 {
	replace tot_oil3 = tot_oil2 if tot_oil2 > tot_oil & year == `i' 
	replace tot_oil3 = tot_oil if tot_oil2 < tot_oil & year == `i' 
}

gen tot_gas3 = 0 

forv i = 2013(1)2023 {
	replace tot_gas3 = tot_gas2 if tot_gas2 > tot_gas & year == `i' 
	replace tot_gas3 = tot_gas if tot_gas2 < tot_gas & year == `i' 
}

gen tot_ff_mixed3 = 0 

forv i = 2013(1)2023 {
	replace tot_ff_mixed3 = tot_ff_mixed2 if tot_ff_mixed2 > tot_ff_mixed & year == `i' 
	replace tot_ff_mixed3 = tot_ff_mixed if tot_ff_mixed2 < tot_ff_mixed & year == `i' 
}

gen tot_wind3 = 0 

forv i = 2013(1)2023 {
	replace tot_wind3 = tot_wind2 if tot_wind2 > tot_wind & year == `i' 
	replace tot_wind3 = tot_wind if tot_wind2 < tot_wind & year == `i' 
}

gen tot_solar3 = 0 

forv i = 2013(1)2023 {
	replace tot_solar3 = tot_solar2 if tot_solar2 > tot_solar & year == `i' 
	replace tot_solar3 = tot_solar if tot_solar2 < tot_solar & year == `i' 
}

gen tot_re_mixed3 = 0 

forv i = 2013(1)2023 {
	replace tot_re_mixed3 = tot_re_mixed2 if tot_re_mixed2 > tot_re_mixed & year == `i' 
	replace tot_re_mixed3 = tot_re_mixed if tot_re_mixed2 < tot_re_mixed & year == `i' 
}

gen tot_nuclear3 = 0 

forv i = 2013(1)2023 {
	replace tot_nuclear3 = tot_nuclear2 if tot_nuclear2 > tot_nuclear & year == `i' 
	replace tot_nuclear3 = tot_nuclear if tot_nuclear2 < tot_nuclear & year == `i' 
}

gen tot_grid3 = 0 

forv i = 2013(1)2023 {
	replace tot_grid3 = tot_grid2 if tot_grid2 > tot_grid & year == `i' 
	replace tot_grid3 = tot_grid if tot_grid2 < tot_grid & year == `i' 
}


keep year tot_coal3 tot_oil3 tot_gas3 tot_ff_mixed3 tot_wind3 tot_solar3 tot_re_mixed3 tot_nuclear3 tot_grid3

save "/Users/pcenskow/Library/CloudStorage/OneDrive-UniversitédeLausanne/ECA paper/Final paper/datasets/summary_fig1_highest_dl.dta", replace

*/


/* Create SI Figure1 DL

clear all

use "/Users/pcenskow/Library/CloudStorage/OneDrive-UniversitédeLausanne/ECA paper/Final paper/datasets/summary_fig1_highest_dl.dta"

*** create SI Figure1 DL 
preserve
	foreach x of varlist tot_coal3 tot_oil3 tot_gas3 tot_ff_mixed3 tot_wind3 tot_solar3 tot_re_mixed3 tot_nuclear3 tot_grid3 {
	replace `x' = 0 if(`x' == .) 
	}
	gen sum1 = tot_coal3 + tot_oil3
	gen sum2 = (sum1 + tot_gas3)
	gen sum3 = (sum2 + tot_ff_mixed3) // other/mixed fossil power
	gen sum4 = (sum3 + tot_wind3)
	gen sum5 = (sum4 + tot_solar3)
	gen sum6 = (sum5 + tot_re_mixed3)
	gen sum7 = (sum6 + tot_nuclear3)
	gen sum8 = (sum7 + tot_grid3)
	gen zero = 0
	twoway rarea zero tot_coal3 year, color(gs1*0.8) ///
	|| rarea tot_coal3 sum1 year, color(gs1*0.6)  ///
	|| rarea sum1 sum2 year, color(gs1*0.4) ///
	|| rarea sum2 sum3 year, color(gs1*0.2) ///
	|| rarea sum3 sum4 year, color(green*1.2) ///
	|| rarea sum4 sum5 year, color(green*0.7) ///
	|| rarea sum5 sum6 year, color(green*0.3) ///
	|| rarea sum6 sum7 year, color(yellow*0.4) ///
	|| rarea sum7 sum8 year, color(orange*0.6) ///
	||, legend(off) /// 
      ytitle("") ///
		xla(2013(1)2023, nolab notick grid) ///
		yla(0(5)30, grid angle(0) labsize(small)) ///
		xtitle("") ///
		xline(2015.5 2019.5 2021.5, lp(dash) lc(red) lwidth(medthick)) scheme(s1mono)
	 graph save "dl_only_highest", replace
	 list year sum3 sum6 sum8, clean noobs
restore


*/

/* Join dataframes RE share (lower element of Figure 1)

clear all

use "/Users/pcenskow/Library/CloudStorage/OneDrive-UniversitédeLausanne/ECA paper/Submission package/Supplementary Information/Data triangulation OCI/oci.dta"

preserve 
keep if ff == 1 | re == 1 | grid == 1
egen tot_ff_g = total(v_bn) if ff == 1 & guarantee == 1, by(year)
egen tot_re_g = total(v_bn) if re == 1 & guarantee == 1, by(year)
egen tot_grid_g = total(v_bn) if grid == 1 & guarantee == 1, by(year)
egen tot_en_g = total(v_bn) if guarantee == 1, by(year)
egen tot_ff_dl = total(v_bn) if ff == 1 & dl == 1, by(year)
egen tot_re_dl = total(v_bn) if re == 1 & dl == 1, by(year)
egen tot_grid_dl = total(v_bn) if grid == 1 & dl == 1, by(year)
egen tot_en_dl = total(v_bn) if dl == 1, by(year)
collapse (max) tot_ff_g tot_re_g tot_grid_g tot_en_g tot_ff_dl tot_re_dl tot_grid_dl tot_en_dl, by(year) 
foreach x of varlist tot_ff_g tot_re_g tot_grid_g tot_en_g tot_ff_dl tot_re_dl tot_grid_dl tot_en_dl {
	replace `x' = 0 if(`x' == .) 
	}
	list, clean noobs
	ren tot_ff_g tot_ff_g2
	ren tot_re_g tot_re_g2 
	ren tot_grid_g tot_grid_g2 
	ren tot_en_g tot_en_g2 
	ren tot_ff_dl tot_ff_dl2 
	ren tot_re_dl tot_re_dl2 
	ren tot_grid_dl tot_grid_dl2 
	ren tot_en_dl tot_en_dl2
	save "/Users/pcenskow/Library/CloudStorage/OneDrive-UniversitédeLausanne/ECA paper/Final paper/datasets/summary_oci_fig_re_share.dta", replace
restore


clear all 

use "/Users/pcenskow/Library/CloudStorage/OneDrive-UniversitédeLausanne/ECA paper/Final paper/datasets/current_working_file_FEB22.dta"

preserve 
gen grid = 0 
replace grid = 1 if other == 3 // only transmission and storage
ren direct_lending dl
keep if ff == 1 | re == 1 | grid == 1
egen tot_ff_g = total(v_bn) if ff == 1 & guarantee == 1, by(year)
egen tot_re_g = total(v_bn) if re == 1 & guarantee == 1, by(year)
egen tot_grid_g = total(v_bn) if grid == 1 & guarantee == 1, by(year)
egen tot_en_g = total(v_bn) if guarantee == 1, by(year)
egen tot_ff_dl = total(v_bn) if ff == 1 & dl == 1, by(year)
egen tot_re_dl = total(v_bn) if re == 1 & dl == 1, by(year)
egen tot_grid_dl = total(v_bn) if grid == 1 & dl == 1, by(year)
egen tot_en_dl = total(v_bn) if dl == 1, by(year)
collapse (max) tot_ff_g tot_re_g tot_grid_g tot_en_g tot_ff_dl tot_re_dl tot_grid_dl tot_en_dl, by(year) 
foreach x of varlist tot_ff_g tot_re_g tot_grid_g tot_en_g tot_ff_dl tot_re_dl tot_grid_dl tot_en_dl {
	replace `x' = 0 if(`x' == .) 
	}
	list, clean noobs
	save "/Users/pcenskow/Library/CloudStorage/OneDrive-UniversitédeLausanne/ECA paper/Final paper/datasets/summary_txf_fig_re_share.dta", replace
restore


clear all 

use "/Users/pcenskow/Library/CloudStorage/OneDrive-UniversitédeLausanne/ECA paper/Final paper/datasets/summary_txf_fig_re_share.dta"



merge using "/Users/pcenskow/Library/CloudStorage/OneDrive-UniversitédeLausanne/ECA paper/Final paper/datasets/summary_oci_fig_re_share.dta"

foreach x of varlist * {
	replace `x' = 0 if(`x' == .) 
	}


gen tot_ff_g3 = 0 

forv i = 2013(1)2023 {
	replace tot_ff_g3 = tot_ff_g2 if tot_ff_g2 > tot_ff_g & year == `i' 
	replace tot_ff_g3 = tot_ff_g if tot_ff_g2 < tot_ff_g & year == `i' 
}

gen tot_re_g3 = 0 

forv i = 2013(1)2023 {
	replace tot_re_g3 = tot_re_g2 if tot_re_g2 > tot_re_g & year == `i' 
	replace tot_re_g3 = tot_re_g if tot_re_g2 < tot_re_g & year == `i' 
}

gen tot_en_g3 = 0 

forv i = 2013(1)2023 {
	replace tot_en_g3 = tot_en_g2 if tot_en_g2 > tot_en_g & year == `i' 
	replace tot_en_g3 = tot_en_g if tot_en_g2 < tot_en_g & year == `i' 
}

gen tot_ff_dl3 = 0 

forv i = 2013(1)2023 {
	replace tot_ff_dl3 = tot_ff_dl2 if tot_ff_dl2 > tot_ff_dl & year == `i' 
	replace tot_ff_dl3 = tot_ff_dl if tot_ff_dl2 < tot_ff_dl & year == `i' 
}

gen tot_re_dl3 = 0 

forv i = 2013(1)2023 {
	replace tot_re_dl3 = tot_re_dl2 if tot_re_dl2 > tot_re_dl & year == `i' 
	replace tot_re_dl3 = tot_re_dl if tot_re_dl2 < tot_re_dl & year == `i' 
}

gen tot_en_dl3 = 0 

forv i = 2013(1)2023 {
	replace tot_en_dl3 = tot_en_dl2 if tot_en_dl2 > tot_en_dl & year == `i' 
	replace tot_en_dl3 = tot_en_dl if tot_en_dl2 < tot_en_dl & year == `i' 
}



keep year tot_ff_g3 tot_re_g3 tot_en_g3 tot_ff_dl3 tot_re_dl3 tot_en_dl3

save "/Users/pcenskow/Library/CloudStorage/OneDrive-UniversitédeLausanne/ECA paper/Final paper/datasets/summary_fig1_RE_Share_highest_dl.dta", replace
	

*/	
	

/* Create RE share figure 

clear all 

use "/Users/pcenskow/Library/CloudStorage/OneDrive-UniversitédeLausanne/ECA paper/Final paper/datasets/summary_fig1_RE_Share_highest_dl.dta"


forvalues i=2013(1)2023 {
	gen share_dl_`i' = tot_re_dl3/tot_en_dl3 if year == `i'
	gen share_g_`i' = tot_re_g3/tot_en_g3 if year == `i'
	list share_dl_`i' share_g_`i' year, clean noobs
}
gen share_re_dl = 0 
gen share_re_g = 0 
forv i = 2013(1)2023 {
replace share_re_dl = (share_dl_`i')*100 if year == `i'
replace share_re_g = (share_g_`i')*100 if year == `i'
}
list year share_re_dl share_re_g, clean noobs
twoway (line share_re_dl year, lc(dkgreen) lpattern(solid)) ///
(line share_re_g year, lc(dkgreen) lpattern(shortdash)) ///
, xla(2013(1)2023) ///
ylab(0(15)60, grid angle(0) labsize(small)) ///
legend(order(1 "Direct lending" 2 "Guarantees")) ///
xtitle("") xline(2015.5 2019.5 2021.5, lp(dash) lc(red) lwidth(medthick)) 
graph save "RE_share_highest", replace


*/
	


/*	Export joint graph 
	
	
grc1leg2 guarantees_only_highest.gph dl_only_highest.gph RE_share_highest.gph, r(3) leg(guarantees_only_highest.gph) pos(3) lr(9) 


graph export Fig1_final_SI, as(png) replace


*/



/* Creation of difference dataframes by country and financial instrument (cumulative USD 2020)

*** OCI data per country (cumulative)

clear all

use "/Users/pcenskow/Library/CloudStorage/OneDrive-UniversitédeLausanne/ECA paper/Submission package/Supplementary Information/Data triangulation OCI/oci.dta"

decode ecacountry, gen(ecacountry2)

drop ecacountry 

ren ecacountry2 ecacountry

preserve 
keep if ff == 1 | re == 1 | grid == 1
keep if guarantee == 1
egen tot_ff_country_g = total(v_bn) if ff == 1 & guarantee == 1, by(ecacountry)
egen tot_re_country_g = total(v_bn) if re == 1 & guarantee == 1, by(ecacountry)
egen tot_grid_country_g = total(v_bn) if grid == 1 & guarantee == 1, by(ecacountry)
collapse (max) tot_ff_country_g tot_re_country_g tot_grid_country_g, by(ecacountry) 
foreach x of varlist tot_ff_country_g tot_re_country_g tot_grid_country_g {
	replace `x' = 0 if(`x' == .) 
	}
	ren tot_ff_country_g tot_ff_country_g2
	ren tot_re_country_g tot_re_country_g2
	ren tot_grid_country_g tot_grid_country_g2
	list, clean noobs
	
	save "/Users/pcenskow/Library/CloudStorage/OneDrive-UniversitédeLausanne/ECA paper/Final paper/datasets/fig_4_SI_g_oci.dta", replace
restore

preserve 
keep if ff == 1 | re == 1 | grid == 1
keep if dl == 1
egen tot_ff_country_dl = total(v_bn) if ff == 1 & dl == 1, by(ecacountry)
egen tot_re_country_dl = total(v_bn) if re == 1 & dl == 1, by(ecacountry)
egen tot_grid_country_dl = total(v_bn) if grid == 1 & dl == 1, by(ecacountry)
collapse (max) tot_ff_country_dl tot_re_country_dl tot_grid_country_dl, by(ecacountry) 
foreach x of varlist tot_ff_country_dl tot_re_country_dl tot_grid_country_dl {
	replace `x' = 0 if(`x' == .) 
	}
	ren tot_ff_country_dl tot_ff_country_dl2
	ren tot_re_country_dl tot_re_country_dl2
	ren tot_grid_country_dl tot_grid_country_dl2
	list, clean noobs
	save "/Users/pcenskow/Library/CloudStorage/OneDrive-UniversitédeLausanne/ECA paper/Final paper/datasets/fig_4_SI_dl_oci.dta", replace
restore

*** TXF data per country (cumulative)

clear all

use "/Users/pcenskow/Library/CloudStorage/OneDrive-UniversitédeLausanne/ECA paper/Final paper/datasets/current_working_file_FEB22.dta"

preserve 
gen grid = 0 
replace grid = 1 if other == 3 // only transmission and storage
keep if ff == 1 | re == 1 | grid == 1
keep if guarantee == 1
egen tot_ff_country_g = total(v_bn) if ff == 1 & guarantee == 1, by(ecacountry)
egen tot_re_country_g = total(v_bn) if re == 1 & guarantee == 1, by(ecacountry)
egen tot_grid_country_g = total(v_bn) if grid == 1 & guarantee == 1, by(ecacountry)
collapse (max) tot_ff_country_g tot_re_country_g tot_grid_country_g, by(ecacountry) 
foreach x of varlist tot_ff_country_g tot_re_country_g tot_grid_country_g {
	replace `x' = 0 if(`x' == .) 
	}
	list, clean noobs
	save "/Users/pcenskow/Library/CloudStorage/OneDrive-UniversitédeLausanne/ECA paper/Final paper/datasets/fig_4_SI_g_txf.dta", replace
restore

preserve 
gen dl = 0 
replace dl = 1 if direct_lending == 1
gen grid = 0 
replace grid = 1 if other == 3 // only transmission and storage
keep if ff == 1 | re == 1 | grid == 1
keep if dl == 1
egen tot_ff_country_dl = total(v_bn) if ff == 1 & dl == 1, by(ecacountry)
egen tot_re_country_dl = total(v_bn) if re == 1 & dl == 1, by(ecacountry)
egen tot_grid_country_dl = total(v_bn) if grid == 1 & dl == 1, by(ecacountry)
collapse (max) tot_ff_country_dl tot_re_country_dl tot_grid_country_dl, by(ecacountry) 
foreach x of varlist tot_ff_country_dl tot_re_country_dl tot_grid_country_dl {
	replace `x' = 0 if(`x' == .) 
	}
	list, clean noobs
	sort ecacountry
	save "/Users/pcenskow/Library/CloudStorage/OneDrive-UniversitédeLausanne/ECA paper/Final paper/datasets/fig_4_SI_dl_txf.dta", replace
restore


*** take the difference between the two dataframes (for each country where possible)

*** Guarantees 

clear all

use "/Users/pcenskow/Library/CloudStorage/OneDrive-UniversitédeLausanne/ECA paper/Final paper/datasets/fig_4_SI_g_txf.dta"

joinby ecacountry using "/Users/pcenskow/Library/CloudStorage/OneDrive-UniversitédeLausanne/ECA paper/Final paper/datasets/fig_4_SI_g_oci.dta", unmatched(both)


foreach x of varlist tot_ff_country_g tot_re_country_g tot_grid_country_g  tot_ff_country_g2 tot_re_country_g2 tot_grid_country_g2 {
	replace `x' = 0 if(`x' == .) 
	}

	
gen tot_ff_country_g_diff = 0 

foreach varname of var ecacountry {
		replace tot_ff_country_g_diff = tot_ff_country_g-tot_ff_country_g2
} 	

gen tot_re_country_g_diff = 0 

foreach varname of var ecacountry {
		replace tot_re_country_g_diff = tot_re_country_g-tot_re_country_g2
} 	

gen tot_grid_country_g_diff = 0 

foreach varname of var ecacountry {
		replace tot_grid_country_g_diff = tot_grid_country_g-tot_grid_country_g2
} 	

keep ecacountry tot_ff_country_g_diff tot_re_country_g_diff tot_grid_country_g_diff

save "/Users/pcenskow/Library/CloudStorage/OneDrive-UniversitédeLausanne/ECA paper/Final paper/datasets/fig_4_SI_g_diff.dta", replace

	
*** Direct lending 

clear all

use "/Users/pcenskow/Library/CloudStorage/OneDrive-UniversitédeLausanne/ECA paper/Final paper/datasets/fig_4_SI_dl_txf.dta"

joinby ecacountry using "/Users/pcenskow/Library/CloudStorage/OneDrive-UniversitédeLausanne/ECA paper/Final paper/datasets/fig_4_SI_dl_oci.dta", unmatched(both)


foreach x of varlist tot_ff_country_dl tot_re_country_dl tot_grid_country_dl  tot_ff_country_dl2 tot_re_country_dl2 tot_grid_country_dl2 {
	replace `x' = 0 if(`x' == .) 
	}

	
gen tot_ff_country_dl_diff = 0 

foreach varname of var ecacountry {
		replace tot_ff_country_dl_diff = tot_ff_country_dl-tot_ff_country_dl2
} 	

gen tot_re_country_dl_diff = 0 

foreach varname of var ecacountry {
		replace tot_re_country_dl_diff = tot_re_country_dl-tot_re_country_dl2
} 	

gen tot_grid_country_dl_diff = 0 

foreach varname of var ecacountry {
		replace tot_grid_country_dl_diff = tot_grid_country_dl-tot_grid_country_dl2
} 	

keep ecacountry tot_ff_country_dl_diff tot_re_country_dl_diff tot_grid_country_dl_diff

save "/Users/pcenskow/Library/CloudStorage/OneDrive-UniversitédeLausanne/ECA paper/Final paper/datasets/fig_4_SI_dl_diff.dta", replace





*/


/* Create SI Figure 3

*** Guarantees 

clear all 

use "/Users/pcenskow/Library/CloudStorage/OneDrive-UniversitédeLausanne/ECA paper/Final paper/datasets/fig_4_SI_g_diff.dta"

preserve

keep in 1/14
 
graph hbar tot_ff_country_g_diff tot_re_country_g_diff tot_grid_country_g_diff, ///
bar(1, color(gs1*0.6)) ///
bar(2, color(green*0.6)) /// 
bar(3, color(orange*0.6)) ///
over(ecacountry) ///
legend(order(1 "Fossil" 2 "RETs" 3 "Grid") r(1) size(small) region(lp(blank))) 
graph save Fig4_SI_g_14, replace
restore

preserve

keep in 15/28
 
graph hbar tot_ff_country_g_diff tot_re_country_g_diff tot_grid_country_g_diff, ///
bar(1, color(gs1*0.6)) ///
bar(2, color(green*0.6)) /// 
bar(3, color(orange*0.6)) ///
over(ecacountry) ///
legend(order(1 "Fossil" 2 "RETs" 3 "Grid") r(1) size(small) region(lp(blank))) 
graph save Fig4_SI_g_28, replace
restore

preserve


grc1leg2 Fig4_SI_g_14.gph Fig4_SI_g_28.gph, r(1) title(TXF minus OCI Guarantees (USD billion{sub:2020}), size(small))


*** Direct lending 

clear all 

use "/Users/pcenskow/Library/CloudStorage/OneDrive-UniversitédeLausanne/ECA paper/Final paper/datasets/fig_4_SI_dl_diff.dta"

preserve

keep in 1/14
 
graph hbar tot_ff_country_dl_diff tot_re_country_dl_diff tot_grid_country_dl_diff, ///
bar(1, color(gs1*0.6)) ///
bar(2, color(green*0.6)) /// 
bar(3, color(orange*0.6)) ///
over(ecacountry) ///
legend(order(1 "Fossil" 2 "RETs" 3 "Grid") r(1) size(small) region(lp(blank))) 
graph save Fig4_SI_dl_14, replace
restore

preserve

keep in 15/27
 
graph hbar tot_ff_country_dl_diff tot_re_country_dl_diff tot_grid_country_dl_diff, ///
bar(1, color(gs1*0.6)) ///
bar(2, color(green*0.6)) /// 
bar(3, color(orange*0.6)) ///
over(ecacountry) ///
legend(order(1 "Fossil" 2 "RETs" 3 "Grid") r(1) size(small) region(lp(blank))) 
graph save Fig4_SI_dl_27, replace
restore

preserve


grc1leg2 Fig4_SI_dl_14.gph Fig4_SI_dl_27.gph, r(1) title(TXF minus OCI Direct Lending (USD billion{sub:2020}), size(small))

*/





