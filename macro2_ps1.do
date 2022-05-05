// ssc install estout
// ssc install labutil // panel labels


clear all
cls

* load data
use http://data.macrohistory.net/JST/JSTdatasetR5.dta
xtset ifs year // set as panel
labmask ifs, values(country) // country names linked to ifs



* 1.1 Trend plot
gen cred2gdp = tloans/gdp
gen mon2gdp = money/gdp

// xtline cred2gdp mon2gdp, /// 
// byopt(note("")) legend(label(1 "Credit-to-GDP") label(2 "Money-to-GDP"))
// graph export "./figures/trend.png", replace
// //title("Credit and Money Historical Trend (as share of GDP)")



* 1.2 Model eval: 5 lag of real credit
gen rcred = tloans/cpi        // real credit
gen dl_rcred = ln(rcred) - ln(l.rcred)
logit crisisJST l(1/5).dl_rcred  // estimation
test l.dl_rcred l2.dl_rcred l3.dl_rcred l4.dl_rcred l5.dl_rcred // test of joing significance of all 5 lags
eststo
esttab using ./table/estimation_I2.tex, replace se mtitle("Crisis dummy") nonumbers



* 1.3 ROC
// in-sample
logit crisisJST l(1/5).dl_rcred  // estimation
predict in_sample 

// out-of-sample
logit crisisJST l(1/5).dl_rcred if year<=1984
predict out_of_sample

// roccomp crisisJST in_sample out_of_sample if year>1984, graph summary legend(size(small)) //title("ROC: Real credit growth")
// graph export "./figures/real_credit.png", replace



* 1.4 Compare

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


* 1.5 Compare


