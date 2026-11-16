# Within-Person-Standardization-Function-for-Person-Centered-Variables
This is an R function to standardize person-centered variables using the person-mean-SD approach described by Wang et al. (2019), applying within-person standard deviations to within-person components. Supports lagging/leading of specified variables.


Function arguments
* df - long-format data frame
* var_vec - raw (not yet person-centered) variables to person-center and standardize, entered as strings
* id - name of the ID variable as a string
* lag_bool/lead_bool - whether to create lagged/led versions (default FALSE)
* lag_n/lead_n - number of positions to lag/lead (default 1)
* lag_vec/lead_vec - variables to lag/lead, entered as strings using the original raw variable names. The lag/lead is applied to the raw values before centering and standardization, and the lagged/led columns are added to the variables to be centered and standardized automatically. If you also need the non-lagged/led within-person component of a variable, include it in var_vec as well.

This function assumes that data are already sorted in temporal order within person. Participants with only one observation are dropped automatically because a within-person SD can't be computed from a single point. Do note that Wang et al. (2019) recommend having 10 observations or more per cluster when using this standardization approach.

The function returns filtered input data frame with two new columns for each variable:
* {var}_d - the person-centered (within-person) component
* {var}_d_z - the person-mean-SD standardized within-person component
* Lagged/led variables follow the same pattern: {var}_lag{n}_d / {var}_lag{n}_d_z and {var}_lead{n}_d / {var}_lead{n}_d_z

Wang, L., Zhang, Q., Maxwell, S. E., & Bergeman, C. S. (2019). On Standardizing Within-Person Effects: Potential Problems of Global Standardization. Multivariate behavioral research, 54(3), 382–403. https://doi.org/10.1080/00273171.2018.1532280
