
clear all
cls

 
// ssc install estout
// net install st0154  // roc 
// ssc install labutil // panel labels

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
// graph export "./trend.png", replace



* 1.2 Model eval: 5 lag of real credit
gen rcred = tloans/cpi        // real credit
gen g_rcred = ln(D.rcred)
logit crisisJST l(1/5).g_rcred  // estimation
test l.g_rcred l2.g_rcred l3.g_rcred l4.g_rcred l5.g_rcred // test of joing significance of all 5 lags
eststo
esttab, se

* 1.3 ROC
// in-sample
logit crisisJST l(1/5).g_rcred  // estimation
predict yhat_baselineIn_cred 

// out-of-sample
logit crisisJST l(1/5).g_rcred if year<=1984
predict yhat_baselineOut_cred

// export to csv for plotting in Python
// export delimited year country crisisJST yhat* if year>1984 using "roc_raw_in_out.csv", replace

roccurve crisisJST yhat_baselineIn_cred yhat_baselineOut_cred if year>1984, legend(label(1 "In-sample") label(2 "Out-of_sample")) title("ROC: Real credit growth")
// comproc crisisJST yhat_baselineIn_cred yhat_baselineOut_cred if year>1984

* 1.4 Compare
local yrs 1984 2017
local preds narrowm eq_capgain housing_capgain bond_tr bill_rate ca
local preds_nice "Narrow_money Equity_price Housing_price Bond_return Bill_rate Current_account"
local preds_nice_list Narrow_money Housing_price Bond_return Bill_rate Current_account //Equity_price

local i 1
foreach ipred in `preds' {
		logit crisisJST l(1/5).`ipred' if year <= 1984
        local thisname : word `i' of `preds_nice'
		predict `thisname'
		local ++i
}

roccomp crisisJST `preds_nice_list' if year>1984, graph summary legend(size(vsmall)) title("Out-of-sample ROC curves (Reference year: 1984)")

local preds_nice_list Narrow_money Housing_price Bond_return Bill_rate Current_account //Equity_price
drop `preds_nice_list'

local i 1
foreach ipred in `preds' {
		logit crisisJST l(1/5).`ipred'
        local thisname : word `i' of `preds_nice'
		predict `thisname'
		local ++i
}

roccomp crisisJST `preds_nice_list' if year>1984, graph summary legend(size(vsmall)) title("In-sample ROC curves")


foreach ipred in `preds' {
	foreach iyear in `yrs' {
		logit crisisJST l(1/5).`ipred' if year <= `iyear'
		predict yhat_`ipred'_`iyear'
		}
}



    // all predictors
    logit crisisJST l(1/5).eq_capgain l(1/5).housing_capgain l(1/5).bond_tr l(1/5).bill_rate l(1/5).ca if year <= `iyear'
    predict yhat_all_`iyear'

local thresholdlist "4 32 7"
local varlist "var1 var2 var3"

local numitems = wordcount("`thresholdlist'")

forv i=1/`numitems' {
 local thisthreshold : word `i' of `thresholdlist'
 local thisvar : word `i' of `varlist'
 di "variable: `thisvar', threshold: `thisthreshold'"

  tab `thisvar' region if `thisvar' > `thisthreshold'

}

// export to csv for plotting in Python
export delimited year country crisisJST yhat* using "roc_raw_all_in.csv", replace
export delimited year country crisisJST yhat* if year>1984 using "roc_raw_all_out.csv", replace

la var yhat_baselineIn_cred "Hairtai"
roccurve crisisJST yhat*2017
roccurve crisisJST yhat*1984 if year>1984



drop yhat_eq_capgain_1984
drop yhat_eq_capgain_2017


rename 

local mis 1 2 3 
di `mis'[1]

roccomp crisisJST yhat*2017, graph summary legend(label(1 "Narrow Money") label(2 "Housing") label(3 "Bond") label(4 "Bill") on)

la var yhat_housing_capgain_1984 "Fantastic"
roccomp crisisJST yhat*1984, graph summary legend(label(1 "Narrow Money") label(2 "Housing") label(3 "Bond") label(4 "Bill"))
// legend(on)
// label(1 "Narrow Money") label(2 "Housing") label(3 "Bond") label(4 "Bill")
/* roctab crisisJST yhat1, graph
roctab crisisJST yhat2, graph
twoway scatter yhat1 crisisJST money, connect(l i) msymbol(i 0) sort ylabel(0 1) */

