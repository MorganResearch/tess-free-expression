capture clear
capture log close
set more off
set cformat %9.3f
cls

log using log/analyze-experimental-results-with-covariates.log, replace

use data/tess-civ-lib.dta

********************************************************************************
*** Set up for analysis
********************************************************************************

*** Set macros

local domain spk col lib 

#delimit ;

local covariates i.region4 i.metro i.female i.age4 i.race4 i.hhsize i.marital
 i.relig i.educ4 i.income i.housing i.home_type 
 i.internet i.phoneservice i.device i.durint ;

 #delimit cr
                 
*** Create additional regressors

recode partyid7 1/2 = 1 2/5 = 2 6/7 = 3, gen(partyid3)
recode partyid7 1/3 = 1 4 = 2 5/7 = 3, gen(partyid3l)
order partyid7 partyid3 partyid3l, after(treat)
tab partyid7 partyid3, miss
tab partyid7 partyid3l, miss

recode racethnicity 3 5 6 = 3 , gen(race4)
recode relig . = 15
recode attend . = 10

summ `covariates'

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

regress `dom' `covariates' b1.treat [pweight=weight]
estimates store `dom'_r1

regress `dom' `covariates' c.partyid7 [pweight=weight]
estimates store `dom'_r2

regress `dom' `covariates' b1.treat##c.partyid7 [pweight=weight]
estimates store `dom'_r3

}

estimates dir

outreg2 [*] ///
  using docs/ols-estimates-with-covariates.xls, ///
  noaster stats(coef se ci pval)  dec(3)  ///
  paren(se) bracket(ci) ///
  excel replace
  
estimates clear

foreach dom in `domain' {

regress `dom' `covariates' b1.treat [pweight=weight]
  margins b1.treat, post
  estimates store `dom'_r1
    quietly regress `dom' `covariates' b1.treat [pweight=weight]
    margins, dydx(b1.treat) post
    estimates store `dom'_r1d1
    quietly regress `dom' `covariates' b2.treat [pweight=weight]
    margins, dydx(b2.treat) post
    estimates store `dom'_r1d2

regress `dom' `covariates' c.partyid7 [pweight=weight]
  margins, dydx(c.partyid7) post
  estimates store `dom'_r2
   
regress `dom' `covariates' b1.treat##c.partyid7 [pweight=weight]
  margins b1.treat, post
  estimates store `dom'_r3
    quietly regress `dom' `covariates' b1.treat##c.partyid7 [pweight=weight]
    margins, dydx(b1.treat) post
    estimates store `dom'_r3d1
    quietly regress `dom' `covariates' b2.treat##c.partyid7 [pweight=weight]
    margins, dydx(b2.treat) post
    estimates store `dom'_r3d2
  quietly regress `dom' `covariates' b1.treat##c.partyid7 [pweight=weight]
    margins, dydx(c.partyid7) post
    estimates store `dom'_r4
  quietly regress `dom' `covariates' b1.treat##c.partyid7 [pweight=weight]
    margins, dydx(partyid7) at(treat = (1(1)3)) post
    estimates store `dom'_r5
  quietly regress `dom' `covariates' b1.treat##c.partyid7 [pweight=weight] 
    margins, dydx(b1.treat) at(partyid = (1(1)7)) post
    estimates store `dom'_r6

}

outreg2 [*] ///
  using docs/ols-margins-with-covariates.xls, ///
  noaster stats(coef se ci pval) bdec(1) sdec(1) cdec(3)  ///
  stnum(replace coef=coef*100, replace se=se*100) ///
  paren(se) bracket(ci) ///
  excel replace

estimates clear

*** Logit models, with no additional adjustment

foreach dom in `domain' {

logit `dom' `covariates' b1.treat [pweight=weight]
estimates store `dom'_r1

logit `dom' `covariates' c.partyid7 [pweight=weight]
estimates store `dom'_r2

logit `dom' `covariates' b1.treat##c.partyid7 [pweight=weight]
estimates store `dom'_r3

}

estimates dir

outreg2 [*] ///
  using docs/logit-estimates-with-covariates.xls, ///
  noaster stats(coef se ci pval)  dec(3)  ///
  paren(se) bracket(ci) ///
  excel replace

estimates clear

foreach dom in `domain' {

logit `dom' `covariates' b1.treat [pweight=weight]
  margins b1.treat, post
  estimates store `dom'_r1
    quietly logit `dom' `covariates' b1.treat [pweight=weight]
    margins, dydx(b1.treat) post
    estimates store `dom'_r1d1
    quietly logit `dom' `covariates' b2.treat [pweight=weight]
    margins, dydx(b2.treat) post
    estimates store `dom'_r1d2

logit `dom' `covariates' c.partyid7 [pweight=weight]
  margins, dydx(c.partyid7) post
  estimates store `dom'_r2
   
logit `dom' `covariates' b1.treat##c.partyid7 [pweight=weight]
  margins b1.treat, post
  estimates store `dom'_r3
    quietly logit `dom' `covariates' b1.treat##c.partyid7 [pweight=weight]
    margins, dydx(b1.treat) post
    estimates store `dom'_r3d1
    quietly logit `dom' `covariates' b2.treat##c.partyid7 [pweight=weight]
    margins, dydx(b2.treat) post
    estimates store `dom'_r3d2
  quietly logit `dom' `covariates' b1.treat##c.partyid7 [pweight=weight]
    margins, dydx(c.partyid7) post
    estimates store `dom'_r4
  quietly logit `dom' `covariates' b1.treat##c.partyid7 [pweight=weight]
    margins, dydx(partyid7) at(treat = (1(1)3)) post
    estimates store `dom'_r5
  quietly logit `dom' `covariates' b1.treat##c.partyid7 [pweight=weight] 
    margins, dydx(b1.treat) at(partyid = (1(1)7)) post
    estimates store `dom'_r6
	
}

outreg2 [*] ///
  using docs/logit-margins-with-covariates.xls, ///
  noaster stats(coef se ci pval) bdec(1) sdec(1) cdec(3)  ///
  stnum(replace coef=coef*100, replace se=se*100) ///
  paren(se) bracket(ci) ///
  excel replace


estimates clear

log close



