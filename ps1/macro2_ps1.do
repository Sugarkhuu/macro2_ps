// Code for Problem 1, Macro II by Prof. Schularick
// done by Sugarkhuu, Omer, Jerome


// install necessary packages 
ssc install estout
ssc install labutil // panel labels, labmask


clear all
cls

* load data
use http://data.macrohistory.net/JST/JSTdatasetR5.dta
xtset ifs year // set as panel
labmask ifs, values(country) // country names linked to ifs



* I.1 Trend plot
gen cred2gdp = tloans/gdp
gen mon2gdp = money/gdp

xtline cred2gdp mon2gdp, /// 
byopt(note("")) legend(label(1 "Credit-to-GDP") label(2 "Money-to-GDP"))
graph export "./figures/trend.png", replace
//title("Credit and Money Historical Trend (as share of GDP)")



* I.2 Model eval: 5 lag of real credit
gen rcred = tloans/cpi        // real credit
gen dl_rcred = ln(rcred) - ln(l.rcred)
logit crisisJST l(1/5).dl_rcred  // estimation
test l.dl_rcred l2.dl_rcred l3.dl_rcred l4.dl_rcred l5.dl_rcred // test of joing significance of all 5 lags
eststo
esttab using ./table/estimation_I2.tex, replace se mtitle("Crisis dummy") nonumbers



* I.3 ROC
// in-sample
logit crisisJST l(1/5).dl_rcred  // estimation
predict in_sample 

// out-of-sample
logit crisisJST l(1/5).dl_rcred if year<=1984
predict out_of_sample

roccomp crisisJST in_sample out_of_sample if year>1984, graph summary legend(size(small)) //title("ROC: Real credit growth")
graph export "./figures/real_credit.png", replace



* I.4 Compare

// data cleaning
gen dl_narrowm = ln(narrowm)-ln(l.narrowm)
gen ca2gdp = ca/gdp
replace eq_capgain = . if eq_capgain > 10 & !missing(eq_capgain) // Germany hyperinflation
// replace housing_capgain = 0.9 if housing_capgain > 0.9 & !missing(housing_capgain) // 


local preds dl_narrowm eq_capgain housing_capgain ca2gdp 
local preds_text "Narrow_money_growth Equity_price Housing_price Current_account_to_GDP" 
local preds_text_list Narrow_money_growth Equity_price Housing_price Current_account_to_GDP



// Out-of-sample
gen Baseline = out_of_sample
local i 1
foreach ipred in `preds' {
		logit crisisJST l(1/5).`ipred' if year <= 1984
		eststo
        local thisname : word `i' of `preds_text'
		predict `thisname'
		roccomp crisisJST `thisname' Baseline if year>1984, graph summary legend(size(small)) //title("Out-of-sample ROC curves (Reference year: 1984)")
		graph export "./figures/out_bs_`thisname'.png", replace
		
		local ++i
		}
				
// all predictors - Out-of-sample
logit crisisJST l(1/5).dl_narrowm l(1/5).eq_capgain l(0/5).housing_capgain l(1/5).ca2gdp if year <= 1984
predict all_predictors

roccomp crisisJST all_predictors Baseline if year>1984, graph summary legend(size(small)) //title("Out-of-sample ROC curves (Reference year: 1984)")

graph export "./figures/out_all_predictors.png", replace


* I.5 Compare


gen dl_rgdppc = ln(rgdppc) - ln(l.rgdppc)     // real gdp per capita, log change
gen dl_rconpc = ln(rconpc) - ln(l.rconpc)     // real consumption per capita, log change
gen dl_gdp = ln(gdp) - ln(l.gdp)              // nominal gdp, log change
gen dl_cpi = ln(cpi) - ln(l.cpi)              // CPI, log change
gen im2gdp = imports/gdp                      // import to gdp
gen ex2gdp = exports/gdp                      // export to gdp
gen nx2gdp = ex2gdp - im2gdp                  // net export to gdp
gen rstir = stir - d.cpi/l.cpi                // real short term rate
gen rltrate = ltrate - d.cpi/l.cpi            // real long term rate
gen rev2gdp = revenue/gdp                     // government revenue to gdp
gen exp2gdp = expenditure/gdp                 // government expenditure to gdp
gen gov2gdp = rev2gdp - exp2gdp               // govt budget balance to gdp
gen dl_xrusd = ln(xrusd) - ln(l.xrusd)        // LCY exchange rate to usd, log change
gen tmort2gdp = tmort/gdp                     // total mortgage to NF to gdp
gen thh2gdp = thh/gdp                         // HH loans to gdp
gen tbus2gdp = tbus/gdp                       // business loans to gdp
gen rtmort = tmort/cpi                        // total mortgage to NF
gen rthh = thh/cpi                            // real HH loans
gen rtbus = tbus/cpi                          // real business loans

 
local myvarlist dl_xrusd gov2gdp tbus2gdp cred2gdp dl_rgdppc dl_rconpc dl_gdp iy dl_cpi im2gdp ///
ex2gdp nx2gdp mon2gdp rstir rltrate hpnom debtgdp rev2gdp ///
exp2gdp tmort2gdp thh2gdp rtmort rthh rtbus ///
lev ltd noncore peg peg_strict eq_tr housing_tr ///
bond_tr bill_rate housing_rent_rtn housing_rent_yd eq_dp bond_rate ///
eq_div_rtn capital_tr risky_tr safe_tr

replace eq_tr = . if eq_tr > 1000 & !missing(eq_tr) // Germany hyperinflation

foreach var in `myvarlist' {
		logit crisisJST l(1/5).`var' if year <= 1984
		predict pred_`var'
		}

local myvarlist_pred pred_dl_xrusd pred_gov2gdp pred_tbus2gdp pred_cred2gdp pred_dl_rgdppc pred_dl_rconpc pred_dl_gdp pred_iy pred_dl_cpi pred_im2gdp ///
pred_ex2gdp pred_nx2gdp pred_mon2gdp pred_rstir pred_rltrate pred_hpnom pred_debtgdp pred_rev2gdp ///
pred_exp2gdp pred_tmort2gdp pred_thh2gdp pred_rtmort pred_rthh pred_rtbus ///
pred_lev pred_ltd pred_noncore pred_peg pred_peg_strict pred_eq_tr pred_housing_tr ///
pred_bond_tr pred_bill_rate pred_housing_rent_rtn pred_housing_rent_yd pred_eq_dp pred_bond_rate ///
pred_eq_div_rtn pred_capital_tr pred_risky_tr pred_safe_tr

// summary table with all AUCs
// commented out usually as it uses lots of memory
// roccomp crisisJST `myvarlist_pred' if year>1984, summary

// compare Baseline to the second highest: pred_dl_xrusd 
roccomp crisisJST Baseline pred_dl_xrusd if year>1984, summary


* END OF PROGRAM