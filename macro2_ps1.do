// ssc install estout
// ssc install labutil // panel labels


clear all
cls

* load data
use http://data.macrohistory.net/JST/JSTdatasetR5.dta
xtset ifs year // set as panel
labmask ifs, values(country) // country names linked to ifs
la var eq_capgain "Fantastic"

* 1.1 Generate ratios and plot
gen cred2gdp = tloans/gdp
gen mon2gdp = money/gdp


// CHANGE NEEDED: subplot titles should be country names
xtline cred2gdp mon2gdp, /// 
byopt(note("") title("Credit and Money Historical Trend (as share of GDP)")) ///
legend(label(1 "Credit-to-GDP") label(2 "Money-to-GDP"))
graph export "./figures/trend.png", replace



* 1.2 Model eval: 5 lag of real credit
gen rcred = tloans/cpi        // real credit
gen g_rcred = ln(D.rcred)
logit crisisJST l(1/5).g_rcred  // estimation
test l.g_rcred l2.g_rcred l3.g_rcred l4.g_rcred l5.g_rcred // test of joing significance of all 5 lags
/* eststo
esttab, se */

* 1.3 ROC
// in-sample
logit crisisJST l(1/5).g_rcred  // estimation
predict in_sample 

// out-of-sample
logit crisisJST l(1/5).g_rcred if year<=1984
predict out_of_sample

roccomp crisisJST in_sample out_of_sample if year>1984, graph summary title("ROC: Real credit growth")
graph export "./figures/real_credit.png", replace

* 1.4 Compare
local yrs 1984 2017
local preds narrowm housing_capgain bond_tr bill_rate ca // eq_capgain
local preds_nice "Narrow_money Housing_price Bond_return Bill_rate Current_account" // Equity_price
local preds_nice_list Narrow_money Housing_price Bond_return Bill_rate Current_account //Equity_price

// Out-of-sample
local i 1
foreach ipred in `preds' {
		logit crisisJST l(1/5).`ipred' if year <= 1984
        local thisname : word `i' of `preds_nice'
		predict `thisname'
		local ++i
}
roccomp crisisJST `preds_nice_list' if year>1984, graph summary legend(size(vsmall)) title("Out-of-sample ROC curves (Reference year: 1984)")

graph export "./figures/out_many.png", replace

// In-sample
drop `preds_nice_list'

local i 1
foreach ipred in `preds' {
		logit crisisJST l(1/5).`ipred'
        local thisname : word `i' of `preds_nice'
		predict `thisname'
		local ++i
}

roccomp crisisJST `preds_nice_list' if year>1984, graph summary legend(size(vsmall)) title("In-sample ROC curves")
graph export "./figures/in_many.png", replace

// all predictors - Out-of-sample
logit crisisJST l(1/5).eq_capgain l(1/5).housing_capgain l(1/5).bond_tr l(1/5).bill_rate l(1/5).ca if year <= 1984
predict yhat_all_1984

graph export "./figures/out_altogether.png", replace

* 1.5 Compare
