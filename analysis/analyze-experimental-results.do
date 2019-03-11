capture clear
capture log close
set more off
cls

log using log/analyze-experimental-results.log, replace

use data/tess-civ-lib.dta

********************************************************************************
*** Basic treatment effect analysis
********************************************************************************

local domain spk col lib 

*** analysis, first cut:
set cformat %9.3f
 
corr `domain' [aweight=weight]
bys treat: corr `domain' [aweight=weight]
/*
foreach dom in `domain' {

regress `dom' i.treat [pweight=weight]
estimates store `dom'_r1
margins, dydx(*) post
estimates store `dom'_rm1

regress `dom' i.treat c.partyid7 [pweight=weight]
estimates store `dom'_r2
margins, dydx(*) post
estimates store `dom'_rm2

regress `dom' i.treat##c.partyid7 [pweight=weight]
estimates store `dom'_r3
margins, dydx(*) post
estimates store `dom'_rm3

regress `dom' i.treat c.ideo [pweight=weight]
estimates store `dom'_r4
margins, dydx(*) post
estimates store `dom'_rm4

regress `dom' i.treat##c.ideo [pweight=weight]
estimates store `dom'_r5
margins, dydx(*) post
estimates store `dom'_rm5

}

/*  This is not working on home laptop
estimates dir

outreg2 [*] ///
  using docs/tmp.xls, ///
  excel replace
estimates clear

*/
*/
foreach dom in `domain' {

logit `dom' i.treat [pweight=weight]
estimates store `dom'_l1
margins i.treat
margins, dydx(*) post
estimates store `dom'_lm1

logit `dom' i.treat c.partyid7 [pweight=weight]
estimates store `dom'_l2
margins i.treat
margins, dydx(*) post
estimates store `dom'_lm2

logit `dom' i.treat##c.partyid7 [pweight=weight]
estimates store `dom'_l3
margins i.treat
margins, dydx(*) post
estimates store `dom'_lm3

logit `dom' i.treat c.ideo [pweight=weight]
estimates store `dom'l4
margins i.treat
margins, dydx(*) post
estimates store `dom'_lm4

logit `dom' i.treat##c.ideo [pweight=weight]
estimates store `dom'_l5
margins i.treat
margins, dydx(*) post
estimates store `dom'_lm5
*/
}

/*  This is not working on home laptop
estimates dir

outreg2 [*] ///
  using docs/tmp.xls, ///
  excel replace
estimates clear

*/


log close



