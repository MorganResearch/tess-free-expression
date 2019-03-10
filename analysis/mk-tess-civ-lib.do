
capture clear
capture log close
set more off
cls

log using log/mk-tess-civ-lib.log, replace

********************************************************************************
*** Load raw data
********************************************************************************

use data/tess030_morgan_6march19.dta
rename *, lower

********************************************************************************
*** Code core experimental variables
********************************************************************************

*** outcome variables

rename q1   mcspk
rename q2   mccol
rename q3   mclib
rename q3a  icspk
rename q5   iccol
rename q6   iclib
rename q7   irlspk
rename q8   irlcol
rename q9   irllib

label define tolerant 0 "not tolerant" 1 "tolerant" 

foreach var of varlist mcspk mccol icspk iccol irlspk irlcol {
  replace `var' = .d if `var' == 98
  recode `var' 2 = 0
  label values `var' tolerant
  codebook `var'
  tab `var' [aweight=weight]
}

foreach var of varlist mclib iclib irllib {
 replace `var' = .d if `var' == 98
 recode `var' 1 = 0 2 = 1
 label values `var' tolerant
 codebook `var'
 tab `var' [aweight=weight]
}

*** treatment variables

rename p_condition treat
label define treatment 1 "mc" 2 "ic" 3 "irl"
label values treat treatment
tab treat, gen(tmp)
rename tmp1 mc
rename tmp2 ic
rename tmp3 irl

*** outcomes, combining treatments

local domain spk col lib 

foreach dom in `domain' {
  gen `dom' = .
  replace `dom' = mc`dom' if mc == 1 & mc`dom' < .
  replace `dom' = ic`dom' if ic == 1 & ic`dom' < .
  replace `dom' = irl`dom' if irl == 1 & irl`dom' < .
  label values `dom' tolerant
}

********************************************************************************
*** Recode AmeriSpeak demographics, etc., and organize
********************************************************************************

***convert strings and impose order

encode state, gen(tmp)
drop state
rename tmp state

encode device, gen(tmp)
drop device
rename tmp device

*** code dk's and other similar as missing
recode ideo 8 = .

*** recode
rename gender female
recode female 1 = 0 2 = 1

*** paradata recode
drop surv_mode // because constant (all web, no phone)
recode duration 0 = 1  1/3 = 2 4/6 = 3 7/9 =4 10/max = 5, gen(durint)
label define durint 1 "lt 1 min" 2 "1-3 mins" 3 "4-6 mins" 4 "7-9 mins" ///
  5 "10 or more mins" 
label values durint durint
tab durint device, col

order caseid startdt enddt duration weight state treat mc ic irl spk col ///
      lib mcspk-irllib age hh* device durint
	  
codebook, c

********************************************************************************
*** Save data file for analysis
********************************************************************************

save data/tess-civ-lib.dta, replace

log close



