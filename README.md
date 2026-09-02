# Within-Person-Standardization-Function-for-Person-Centered-Variables
This is an R function to standardize person-centered variables using the person-mean-SD approach described by Wang et al. (2019), applying within-person standard deviations to within-person components. Supports between-person standardization using global standard deviations, centering and standardization of non-centered between-person variables, and lagging/leading of specified variables.


Function arguments
* df - long-format data frame
* wp_vec - within-person component variables to standardize (each divided by that person's within-person sd)
* bp_vec - between-person component variables to standardize (divided by the global sd, computed from one row per person)
* id - name of the ID variable as a string
* non_c_bp_vars - other between-person variables that aren't yet centered to standardize (the difference between each raw value and the global mean is divided by the global sd; global mean and sd are computed from one row per person)
* lag_bool/lead_bool - whether to create lagged/led versions
* lag_n/lead_n - number of positions to lag/lead (default 1)
* lag_vec/lead_vec - variables to lag/lead. Enter the original variable names (not the _z versions); these must already be in wp_vec. The lag/lead is applied to the standardized values

This function assumes that data are already sorted in temporal order within person. Participants with only one observation are dropped automatically because a within-person SD can't be computed from a single point.

Returns the input data frame with standardized columns marked by an _z, and _z_lag{n} / _z_lead{n} for any lagged/led variables

Wang, L., Zhang, Q., Maxwell, S. E., & Bergeman, C. S. (2019). On Standardizing Within-Person Effects: Potential Problems of Global Standardization. Multivariate behavioral research, 54(3), 382–403. https://doi.org/10.1080/00273171.2018.1532280
