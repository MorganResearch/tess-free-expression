********************************************************************************
// Author:  Stephen L. Morgan
// Date:    March 9, 2019
// Note:    Monte Carlo  analysis of treatment distribution
********************************************************************************
		 
capture clear
capture graph drop _all 
capture program drop _all
capture log close
cls
set more off

set scheme s1color

*******************************************************************************
*******************************************************************************
*******************************************************************************
***  SIMULATE and CALCULATE (RELOAD subset and GRAPH below)
*******************************************************************************
*******************************************************************************
*******************************************************************************
/*
log using log/monte-carlo-treatment-distribution.log, replace

*******************************************************************************
// Monte Carlo
*******************************************************************************

*** Set up

local sample_size = 2019 
local number_of_polls = 1000000

program conduct_poll, rclass
  args n
  drop _all
  
  quietly set obs `n'
  gen rand = runiform(0, 1)
  gen treat = 1
  replace treat = 2 if (rand > 1/3) & (rand <= 2/3)
  replace treat = 3 if (rand > 2/3) & (rand <= 1)
  quietly tab treat, gen(treat) matcell(cells)

  quietly summarize treat1
  return scalar meant1 = r(mean)
  quietly summarize treat2
  return scalar meant2 = r(mean)
  quietly summarize treat3
  return scalar meant3 = r(mean)
  
  matrix list cells
  mata: st_numscalar("max", max(st_matrix("cells")))
  return scalar maxtreat = max
  mata: st_numscalar("min", min(st_matrix("cells")))
  return scalar mintreat = min
  return scalar midtreat = `n' - min - max
  matrix drop cells
end

conduct_poll `sample_size'
return list

simulate meant1=r(meant1) meant2=r(meant2) meant3=r(meant3) ///
         mintreat=r(mintreat) midtreat=r(midtreat) maxtreat=r(maxtreat), ///
		 reps(`number_of_polls') dots(1000): conduct_poll `sample_size'

summarize, d

*******************************************************************************
// Examine observed distribution and calculate Monte Carlo estimates
*******************************************************************************

/*
use data/tess030_morgan_6march19.dta
tab P_CONDITION
tab P_CONDITION [aweight=weight]

. tab P_CONDITION

 DATA-ONLY: |
   Randomly |
   assigned |
  condition |
for TESS030 |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |        709       35.12       35.12
          2 |        660       32.69       67.81
          3 |        650       32.19      100.00
------------+-----------------------------------
      Total |      2,019      100.00

. tab P_CONDITION [aweight=weight]

 DATA-ONLY: |
   Randomly |
   assigned |
  condition |
for TESS030 |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 | 727.665546       36.04       36.04
          2 | 669.680965       33.17       69.21
          3 | 621.653489       30.79      100.00
------------+-----------------------------------
      Total |      2,019      100.00
*/

gen ltewtmin = (min(meant1, meant2, meant3) <= 621.653489/2019)
gen lte650 = (mintreat <= 650)
gen gte709 = (maxtreat >= 709)
gen gtewtmax = (max(meant1, meant2, meant3) >= 727.665546/2019)

summarize lt* gt*

*******************************************************************************
// Save simulated data
*******************************************************************************

compress
save data/civlib-1mil-experiments.dta, replace

log close
*/
*******************************************************************************
*******************************************************************************
*******************************************************************************
***  RELOAD and GRAPH
*******************************************************************************
*******************************************************************************
*******************************************************************************

log using log/monte-carlo-treatment-distribution-graph.log, replace

use data/civlib-1mil-experiments.dta, replace


* Graph setup

local sample_size = 2019 
local number_of_polls = 10000

sample `number_of_polls', count

gen range = maxtreat - mintreat
gen upbias = maxtreat - 673
gen downbias = mintreat - 673
gen maxp = max(meant1, meant2, meant3) 
gen minp = min(meant1, meant2, meant3)
gen rangep = maxp - minp
gen max_upbias = maxp - 1/3
gen min_downbias = minp - 1/3
summ



* Graph

#delimit ;

kdensity range, 
  title(Monte Carlo Simulation of `number_of_polls' Polls (n = `sample_size'))
  subtitle("Range of Max to Min) 
  t2title("asdf1")
  t1title("asdf2")
  ytitle("asdf3") xtitle("asdf4") 
  normal normopts(lc(black))  
  lcolor(navy%75) fcolor(navy%20)
  name(kd_range)
  legend(off) ;

  
#delimit cr

*/

* MC results
summ mean
local mc_mean = round(`r(mean)', .0001)
local mc_moe = round(`r(sd)' * 1.96, .0001)
display `mc_mean'
display `mc_moe'

* Graph locations
local moe_l = `proportion_agree' - .03
local moe_u = `proportion_agree' + .03
local range_l = `proportion_agree' - .1
local range_u = `proportion_agree' + .1 

#delimit ;

dotplot mean, 
  title(Monte Carlo Simulation of `number_of_polls' Polls (n = `sample_size'))
  subtitle(True proportion agree = `proportion_agree') 
  t2title("MC mean proportion agree = `mc_mean'")
  t1title("MC margin of error = `mc_moe'")
  ytitle("Estimated proportion agree (in bins)") xtitle("Number of polls") 
  yline(`moe_l' `moe_u') ylabel(`range_l'(.05)`range_u') 
  msize(tiny)
  mcolor(navy)
  note("Notes:  This is a dotplot graph from Stata. Red lines are +/- .03 (the true margin of error for n = 1067).")
  name(dot_moe)
  ;
hist mean, 
  title(Monte Carlo Simulation of `number_of_polls' Polls (n = `sample_size'))
  subtitle(True proportion agree = `proportion_agree') 
  t2title("MC mean proportion agree = `mc_mean'")
  t1title("MC margin of error = `mc_moe'")
  ytitle("Percentage of polls") xtitle("Estimated proportion agree (in bins)") 
  bin(20) percent 
  lcolor(navy) lwidth(vthin) fcolor(navy%75)
  normal normopts(lc(black)) 
  xline(`moe_l' `moe_u') xlabel(`range_l'(.05)`range_u') 
  note("Notes:  This is a historgram from Stata with 20 bins and a superimposed normal."
	     "Red lines are +/- .03 (the true margin of error for n = 1067).")
  name(hist_moe)
  ;

kdensity mean, 
  title(Monte Carlo Simulation of `number_of_polls' Polls (n = `sample_size'))
  subtitle(True proportion agree = `proportion_agree') 
  t2title("MC mean proportion agree = `mc_mean'")
  t1title("MC margin of error = `mc_moe'")
  ytitle(" ") xtitle("Estimated proportion agree") 
  normal normopts(lc(black))  
  lcolor(navy%75) fcolor(navy%20)
  xline(`moe_l' `moe_u') xlabel(`range_l'(.05)`range_u') name(kd_moe)
  legend(off)
  note("Notes:  This is a kdensity graph from Stata with a superimposed normal."
       "Red lines are +/- .03 (the true margin of error for n = 1067).")
  ;

#delimit cr

log close
