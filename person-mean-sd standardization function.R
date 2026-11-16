
ps_standardization <- function(df, var_vec = c(), id, lag_bool = FALSE, lead_bool = FALSE,
                               lag_n = 1L, lead_n = 1L, lag_vec = c(), lead_vec = c()) {
  
  #this function will take variables in the var_vec and decompose them into within-person components 
  # (i.e., person center them) and then standardize those variables using person-mean-SD standardization for
  #within-person variables
  
  #this function assumes that (1) your var_vec will contain variables that have not yet been decomposed into
  #within-person components, and that (2) your data is already temporally arranged. 
  
  #if you want to lag/lead variables pass them into lag_vec/lead_vec, respectively. The function will create the
  #lagged/led columns and then drop the first/last occasion(s) where lagged/led values are NA. Then, function will
  #person-center and standardize all variables on the remaining rows. lagged/led columns are added to the within-person
  #variables automatically. You should pass the original variables into var_vec if you need their own non
  #lagged/led within-person components 
  
  #if you did not already filter your df to exclude your id var based on a minimum observation requirement
  #the function will remove those with only one observation because standard deviation of within-person
  #components can not be computed. Do note that Wang et al. (2019) recommend having 10 observations or more when 
  #using this standardization approach
  
  #it should be noted that if you are examining within-person processes, and your outcome is a within-person component
  #of a variable, you should not include between-person components of variables (or any between-person variables) as
  #covariates. This is because the mean of a within-person component variable is 0 for all individuals, thus there is 
  #no between-person variance in the mean of a within-person component
  
  one_obs_ids <- df |>
    dplyr::count(.data[[id]]) |>
    dplyr::filter(n == 1) |>
    dplyr::pull(.data[[id]])
  
  df <- df |>
    dplyr::filter(!.data[[id]] %in% one_obs_ids)
  
  df <- df |>
    dplyr::mutate(dplyr::across(dplyr::all_of(var_vec), ~ as.numeric(.)),
                  !!id := as.factor(.data[[id]]))
  
  if (lag_bool == TRUE) {
    
    lag_names <- paste0(lag_vec, "_lag", lag_n)
    
    df <- df |>
      dplyr::group_by(.data[[id]]) |>
      dplyr::mutate(dplyr::across(dplyr::all_of(lag_vec), ~ dplyr::lag(., n = lag_n),
                                  .names = "{.col}_lag{lag_n}")) |>
      dplyr::ungroup() |>
      dplyr::filter(dplyr::if_all(dplyr::all_of(lag_names), ~ !is.na(.))) |>
      dplyr::group_by(.data[[id]]) |>
      dplyr::filter(dplyr::n() > 1) |>
      dplyr::ungroup()
    
    var_vec <- c(var_vec, lag_names)
  }
  
  if (lead_bool == TRUE) {
    
    lead_names <- paste0(lead_vec, "_lead", lead_n)
    
    df <- df |>
      dplyr::group_by(.data[[id]]) |>
      dplyr::mutate(dplyr::across(dplyr::all_of(lead_vec),
                                  ~ dplyr::lead(., n = lead_n),
                                  .names = "{.col}_lead{lead_n}")) |>
      dplyr::ungroup() |>
      dplyr::filter(dplyr::if_all(dplyr::all_of(lead_names), ~ !is.na(.))) |>
      dplyr::group_by(.data[[id]]) |>
      dplyr::filter(dplyr::n() > 1) |>
      dplyr::ungroup()
    
    var_vec <- c(var_vec, lead_names)
  }
  
  df <- df |>
    dplyr::filter(!dplyr::if_any(dplyr::all_of(var_vec), ~ is.na(.))) |>
    dplyr::group_by(.data[[id]]) |>
    dplyr::filter(dplyr::n() > 1) |>
    dplyr::ungroup()
  
  for (var in var_vec) {
    person_dev <- paste0(var, "_d")
    df <- df |>
      dplyr::group_by(.data[[id]]) |>
      dplyr::mutate(!!person_dev  := as.numeric(.data[[var]]) - mean(as.numeric(.data[[var]]), na.rm = TRUE)) |>
      dplyr::ungroup()
  }
  
  wp_vec <- paste0(var_vec, "_d")
  
  for (wp_var in wp_vec) {
    wp_z = paste0(wp_var, "_z")
    
    df <- df |>
      dplyr::group_by(.data[[id]]) |>
      dplyr::mutate(!!wp_z := {
        s <- sd(.data[[wp_var]], na.rm = TRUE)
        if(is.na(s) || s == 0) {
          message(wp_z, " has a within-person SD of 0/NA for ID ", dplyr::first(.data[[id]]))
          NA_real_
        } else {
          .data[[wp_var]] / s
        }
      }) |>
      dplyr::ungroup()
  }
  
  return(df)
}
