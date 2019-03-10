
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


estimates clear
foreach dom in `domain' {

regress `dom' i.treat [pweight=weight]
estimates store `dom'_r1
margins, dydx(*) post
estimates store `dom'_rm1

/*
regress `dom' i.treat c.partyid7 [pweight=weight]
estimates store `dom'_r2
margins, dydx(*) post
estimates store `dom'_rm2
*/

regress `dom' i.treat##c.partyid7 [pweight=weight]
estimates store `dom'_r3
margins, dydx(*) post
estimates store `dom'_rm3
/*
regress `dom' i.treat c.ideo [pweight=weight]
estimates store `dom'_r4
margins, dydx(*) post
estimates store `dom'_rm4


regress `dom' i.treat##c.ideo [pweight=weight]
estimates store `dom'_r5
margins, dydx(*) post
estimates store `dom'_rm5
*/
}

estimates dir


outreg2 [*] ///
  using docs/tmp.xls, ///
  excel replace

asdf


outreg2 [lib_*4 lib_*1] ///
  using docs/tmp.xls, ///
  excel replace

outreg2 [*] ///
  using docs/tmp.xls, ///
  excel replace
*/
estimates clear
foreach dom in `domain' {

logit `dom' i.treat [pweight=weight]
estimates store `dom'_l1
margins, dydx(*) post
estimates store `dom'_lm1

logit `dom' i.treat c.partyid7 [pweight=weight]
estimates store `dom'_l2
margins, dydx(*) post
estimates store `dom'_lm2

logit `dom' i.treat##c.partyid7 [pweight=weight]
estimates store `dom'_l3
margins, dydx(*) post
estimates store `dom'_lm3

logit `dom' i.treat c.ideo [pweight=weight]
estimates store `dom'l4
margins, dydx(*) post
estimates store `dom'_lm4

logit `dom' i.treat##c.ideo [pweight=weight]
estimates store `dom'_l5
margins, dydx(*) post
estimates store `dom'_lm5

}

estimates dir
/*
outreg2 [*] ///
  using docs/logits.xls, ///
  excel replace

  
  asdf
*** macros for types of variables

local intvars 
asdf
/*
quietly ds *_1 *_2 *_3
local tmp_macro `r(varlist)'
local all_question_variables : list sort tmp_macro
macro drop _tmp_macro
macro list _all_question_variables

* Macro for questions all questions asked
quietly ds *_1 *_2 *_3
local tmp_macro `r(varlist)'
local all_questions_asked : list sort tmp_macro
macro drop _tmp_macro
macro list _all_questions_asked

* Subset existing macros to get all questions not asked:
local all_questions_not_asked : ///
  list all_question_variables - all_questions_asked
macro list _all_questions_asked _all_questions_not_asked
*/




log close



