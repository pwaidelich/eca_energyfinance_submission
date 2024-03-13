*** CODE  for a paper entitled "A dynamic analysis of energy financing patterns by public export credit agencies" (submitted) 

*** Corresponding author: philipp.censkowsky@unil.ch

clear all 

cd "/Users/pcenskow/Library/CloudStorage/OneDrive-UniversitédeLausanne/ECA paper/Final dataset/Stata code"

use TXF_data_empty.dta

tostring _all, replace force

foreach var of varlist _all {
	replace `var' = ""
}

save TXF_data_empty, replace

