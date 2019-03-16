capture clear
capture log close
set more off
set cformat %9.3f
cls

log using log/analyze-experimental-results-without-covariates-3party.log, replace

use data/tess-civ-lib.dta

********************************************************************************
*** Set up for analysis
********************************************************************************

*** Set macros

local domain spk col lib 

*** Create additional regressors

recode partyid7 1/2 = 1 2/5 = 2 6/7 = 3, gen(partyid3)
recode partyid7 1/3 = 1 4 = 2 5/7 = 3, gen(partyid3l)
order partyid7 partyid3 partyid3l, after(treat)
tab partyid7 partyid3, miss
tab partyid7 partyid3l, miss

********************************************************************************
*** Summary of outcomes
********************************************************************************

summ `domain' [aweight = weight]
corr `domain' [aweight = weight]
bys treat: corr `domain' [aweight = weight]
bys partyid3: corr `domain' [aweight = weight]

********************************************************************************
*** Basic treatment effect analysis
********************************************************************************

*** OLS regression models, with no additional adjustment

foreach dom in `domain' {

regress `dom' b1.treat b1.partyid3 [pweight=weight]
estimates store `dom'_r4

regress `dom' b1.treat##b1.partyid3 [pweight=weight]
estimates store `dom'_r5

regress `dom' b1.treat b1.partyid3l [pweight=weight]
estimates store `dom'_r6

regress `dom' b1.treat##b1.partyid3l [pweight=weight]
estimates store `dom'_r7

}

estimates dir

outreg2 [*] ///
  using docs/ols-estimates-without-covariates-3party.xls, ///
  noaster stats(coef se ci pval)  dec(3)  ///
  paren(se) bracket(ci) ///
  excel replace
  
estimates clear

foreach dom in `domain' {

regress `dom' b1.partyid3 [pweight=weight]
  margins, dydx(b1.partyid3) post
  estimates store `dom'_r2
  
regress `dom' b1.treat##b1.partyid3 [pweight=weight]
  margins b1.treat, post
  estimates store `dom'_r3
    quietly regress `dom' b1.treat##b1.partyid3 [pweight=weight]
    margins, dydx(b1.treat) post
    estimates store `dom'_r3d1
    quietly regress `dom' b2.treat##b1.partyid3 [pweight=weight]
    margins, dydx(b2.treat) post
    estimates store `dom'_r3d2
  quietly regress `dom' b1.treat##b1.partyid3 [pweight=weight]
    margins, dydx(b1.partyid3) post
    estimates store `dom'_r4
  quietly regress `dom' b1.treat##b1.partyid3 [pweight=weight]
    margins, dydx(b1.partyid3) at(treat = (1(1)3)) post
    estimates store `dom'_r5
  quietly regress `dom' b1.treat##b1.partyid3 [pweight=weight] 
    margins, dydx(b1.treat) at(partyid3 = (1(1)3)) post
    estimates store `dom'_r6

regress `dom' b1.partyid3l [pweight=weight]
  margins, dydx(b1.partyid3l) post
  estimates store `dom'_r2l

regress `dom' b1.treat##b1.partyid3l [pweight=weight]
  margins b1.treat, post
  estimates store `dom'_r3l
    quietly regress `dom' b1.treat##b1.partyid3l [pweight=weight]
    margins, dydx(b1.treat) post
    estimates store `dom'_r3ld1
    quietly regress `dom' b2.treat##b1.partyid3l [pweight=weight]
    margins, dydx(b2.treat) post
    estimates store `dom'_r3ld2
  quietly regress `dom' b1.treat##b1.partyid3l [pweight=weight]
    margins, dydx(b1.partyid3l) post
    estimates store `dom'_r4l
  quietly regress `dom' b1.treat##b1.partyid3l [pweight=weight]
    margins, dydx(b1.partyid3l) at(treat = (1(1)3)) post
    estimates store `dom'_r5l
  quietly regress `dom' b1.treat##b1.partyid3l [pweight=weight] 
    margins, dydx(b1.treat) at(partyid3l = (1(1)3)) post
    estimates store `dom'_r6l

}

outreg2 [*] ///
  using docs/ols-margins-without-covariates-3party.xls, ///
  noaster stats(coef se ci pval) bdec(1) sdec(1) cdec(3)  ///
  stnum(replace coef=coef*100, replace se=se*100) ///
  paren(se) bracket(ci) ///
  excel replace

estimates clear

*** Logit models, with no additional adjustment

foreach dom in `domain' {

logit `dom' b1.treat b1.partyid3 [pweight=weight]
estimates store `dom'_r4

logit `dom' b1.treat##b1.partyid3 [pweight=weight]
estimates store `dom'_r5

logit `dom' b1.treat b1.partyid3l [pweight=weight]
estimates store `dom'_r6

logit `dom' b1.treat##b1.partyid3l [pweight=weight]
estimates store `dom'_r7

}

estimates dir

outreg2 [*] ///
  using docs/logit-estimates-without-covariates-3party.xls, ///
  noaster stats(coef se ci pval)  dec(3)  ///
  paren(se) bracket(ci) ///
  excel replace

estimates clear

foreach dom in `domain' {

logit `dom' b1.partyid3 [pweight=weight]
  margins, dydx(b1.partyid3) post
  estimates store `dom'_r2
  
logit `dom' b1.treat##b1.partyid3 [pweight=weight]
  margins b1.treat, post
  estimates store `dom'_r3
    quietly logit `dom' b1.treat##b1.partyid3 [pweight=weight]
    margins, dydx(b1.treat) post
    estimates store `dom'_r3d1
    quietly logit `dom' b2.treat##b1.partyid3 [pweight=weight]
    margins, dydx(b2.treat) post
    estimates store `dom'_r3d2
  quietly logit `dom' b1.treat##b1.partyid3 [pweight=weight]
    margins, dydx(b1.partyid3) post
    estimates store `dom'_r4
  quietly logit `dom' b1.treat##b1.partyid3 [pweight=weight]
    margins, dydx(b1.partyid3) at(treat = (1(1)3)) post
    estimates store `dom'_r5
  quietly logit `dom' b1.treat##b1.partyid3 [pweight=weight] 
    margins, dydx(b1.treat) at(partyid3 = (1(1)3)) post
    estimates store `dom'_r6

logit `dom' b1.partyid3l [pweight=weight]
  margins, dydx(b1.partyid3l) post
  estimates store `dom'_r2l

logit `dom' b1.treat##b1.partyid3l [pweight=weight]
  margins b1.treat, post
  estimates store `dom'_r3l
    quietly logit `dom' b1.treat##b1.partyid3l [pweight=weight]
    margins, dydx(b1.treat) post
    estimates store `dom'_r3ld1
    quietly logit `dom' b2.treat##b1.partyid3l [pweight=weight]
    margins, dydx(b2.treat) post
    estimates store `dom'_r3ld2
  quietly logit `dom' b1.treat##b1.partyid3l [pweight=weight]
    margins, dydx(b1.partyid3l) post
    estimates store `dom'_r4l
  quietly logit `dom' b1.treat##b1.partyid3l [pweight=weight]
    margins, dydx(b1.partyid3l) at(treat = (1(1)3)) post
    estimates store `dom'_r5l
  quietly logit `dom' b1.treat##b1.partyid3l [pweight=weight] 
    margins, dydx(b1.treat) at(partyid3l = (1(1)3)) post
    estimates store `dom'_r6l

}

outreg2 [*] ///
  using docs/logit-margins-without-covariates-3party.xls, ///
  noaster stats(coef se ci pval) bdec(1) sdec(1) cdec(3)  ///
  stnum(replace coef=coef*100, replace se=se*100) ///
  paren(se) bracket(ci) ///
  excel replace

log close



