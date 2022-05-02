
clear all
cls

* load data
use http://data.macrohistory.net/JST/JSTdatasetR5.dta
xtset ifs year // set as panel

* 1.1 Generate ratios and plot
gen cred2gdp = tloans/gdp
gen mon2gdp = money/gdp

// CHANGE NEEDED: subplot titles should be country names
xtline cred2gdp mon2gdp
graph export "./trend.png"
// ytitle(Credit and money over time across countries) ///
// xtitle(Year) ///
// graphregion(fcolor(white) ///

* 1.2 Model eval: 5 lag of real credit
gen rcred = tloans/cpi        // real credit
gen g_rcred = ln(D.rcred)
logit crisisJST l(1/5).g_rcred  // estimation
test l.g_rcred l2.g_rcred l3.g_rcred l4.g_rcred l5.g_rcred // test of joing significance of all 5 lags

* 1.3 ROC
// in-sample
logit crisisJST l(1/5).g_rcred  // estimation
predict yhat_baselineIn_cred 

// out-of-sample
logit crisisJST l(1/5).g_rcred if year<=1984
predict yhat_baselineOut_cred

// export to csv for plotting in Python
export delimited year country crisisJST yhat* if year>1984 using "roc_raw_in_out.csv", replace

* 1.4 Compare
local yrs 1984 2017

foreach iyear in `yrs' {
    // narrow money
    logit crisisJST l(0/5).narrowm if year <= `iyear'
    predict yhat_narrowm_`iyear'
    // asset prices
    logit crisisJST l(0/5).eq_capgain if year <= `iyear'
    predict yhat_eq_`iyear'
    logit crisisJST l(0/5).housing_capgain if year <= `iyear'
    predict yhat_hous_`iyear'
    logit crisisJST l(0/5).bond_tr if year <= `iyear'
    predict yhat_bond_`iyear'
    logit crisisJST l(0/5).bill_rate if year <= `iyear'
    predict yhat_bill_`iyear'

    // current account
    logit crisisJST l(0/5).ca if year <= `iyear'
    predict yhat_ca_`iyear'
    // all predictors
    logit crisisJST l(0/5).eq_capgain l(0/5).housing_capgain l(0/5).bond_tr l(0/5).bill_rate l(0/5).ca if year <= `iyear'
    predict yhat_all_`iyear'
}

// export to csv for plotting in Python
export delimited year country crisisJST yhat* using "roc_raw_all_in.csv", replace
export delimited year country crisisJST yhat* if year>1984 using "roc_raw_all_out.csv", replace

/* roctab crisisJST yhat1, graph
roctab crisisJST yhat2, graph
twoway scatter yhat1 crisisJST money, connect(l i) msymbol(i 0) sort ylabel(0 1) */

