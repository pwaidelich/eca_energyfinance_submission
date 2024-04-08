*** CODE  for a paper entitled "Quantifying the shift of public export finance from fossil fuels to renewable energy" (submitted to Nature Communications) 

*** Corresponding author: Paul Waidelich (paul.waidelich@gess.ethz.ch)

*** Output CONFIDENTIAL, for review only 

clear all 

cd "/Users/pcenskow/Library/CloudStorage/OneDrive-UniversitédeLausanne/ECA paper/Final dataset/Censored DF"

use current_working_file_FEB22_for_censoring.dta

*** censor key identifiers
     
replace dealtitle = "XXX"
replace description = "XXX"
replace borrower = "XXX"
replace exporter = "XXX"
replace lendername = "XXX"
replace lendercountry = "XXX"


*** shuffle key values at random 

ssc install shufflevar

shufflevar tmddealid closingdate dealcountry uniquetrancheid ecaname ecacountry

drop tmddealid closingdate dealcountry uniquetrancheid ecaname ecacountry

ren tmddealid_shuffled tmddealid
ren closingdate_shuffled closingdate
ren dealcountry_shuffled dealcountry
ren uniquetrancheid_shuffled uniquetrancheid
ren ecaname_shuffled ecaname 
ren ecacountry_shuffled ecacountry

order tmddealid closingdate dealcountry uniquetrancheid ecaname ecacountry, after(v3)


bys tmddealid: gen u = runiform() if _n == 1
bys tmddealid: egen uu = total(u)
keep if uu < .1 // keep a random 10% of observations 
drop u uu

save TXF_data_censored, replace

