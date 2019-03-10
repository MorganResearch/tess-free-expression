
capture clear
capture log close
set more off
cls

log using log/check-treatment-variation.log, replace

use data/tess-civ-lib.dta

********************************************************************************
*** Predict observed treatment assignment
********************************************************************************

foreach var of varlist age-hh18ov {
  codebook `var', c
  mlogit treat `var'
  mlogit treat `var' [pweight=weight]
}

foreach var of varlist device-phoneservice {
  codebook `var', c
  mlogit treat i.`var'
  mlogit treat i.`var' [pweight=weight]
}

log close



