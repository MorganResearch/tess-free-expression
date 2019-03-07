
capture clear
capture log close
set more off
cls

log using log/mk-tess-civ-lib.log, replace

use data/tess030_morgan_6march19.dta

********************************************************************************
*** Generate variables for analysis
********************************************************************************

rename *, lower

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
}

*** analysis, first cut:
set cformat %9.3f
 
corr `domain' [aweight=weight]
bys treat: corr `domain' [aweight=weight]

foreach dom in `domain' {

regress `dom' i.treat [pweight=weight]
margins, dydx(treat)
*regress `dom' i.treat i.partyid7 [pweight=weight]
*margins, dydx(treat)
regress `dom' i.treat##c.partyid7 [pweight=weight]
margins, dydx(treat partyid7)

logit `dom' i.treat [pweight=weight]
margins, dydx(treat)
*logit `dom' i.treat i.partyid7 [pweight=weight]
*margins, dydx(treat)
logit `dom' i.treat##c.partyid7 [pweight=weight]
margins, dydx(treat partyid7)

}

log close



