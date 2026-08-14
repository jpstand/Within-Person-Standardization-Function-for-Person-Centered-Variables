
ps_standardization <- function(df, wp_vec = c(), bp_vec = c(), id, lag_bool = FALSE, lead_bool = FALSE, 
                               lag_n = 0L, lead_n = 0L, lag_vec = c(), lead_vec = c()) {
  #this function assumes (1) your wp_vec and bp_vec will contain within-person and between-person components 
  #of person-centered variables, respectively, and (2) that your day is already temporally arranged.
  
  #if you want to lag/lead your variables the lag/lead will be applied to the standardized version; however,
  #you should still enter your lag/lead variables of interest as their original name before standardization
  #lag/lead variables should already be included in wp_vec. 
  
  #if you did not already filter your df to exclude your id var based on a minimum observation requirement
  #the function will remove those with only one observation because standard deviation of within-person
  #components can not be computed
  one_obs_ids <- df |>
    dplyr::count(.data[[id]]) |>
    dplyr::filter(n == 1) |>
    dplyr::pull(.data[[id]])
  
  df <- df |>
    dplyr::filter(!.data[[id]] %in% one_obs_ids)
  
  df <- df |>
    dplyr::mutate(dplyr::across(dplyr::all_of(c(wp_vec, bp_vec)), ~ as.numeric(.)),
                  !!id := as.factor(.data[[id]]))
  
  for (wp_var in wp_vec) {
    wp_z = paste0(wp_var, "_z")
    
    df <- df |>
      dplyr::group_by(.data[[id]]) |>
      dplyr::mutate(!!wp_z := .data[[wp_var]] / sd(.data[[wp_var]], na.rm = TRUE)) |>
      dplyr::ungroup()
  }
  
  for (bp_var in bp_vec) {
    bp_z = paste0(bp_var, "_z")
    
    global_sd <- df |>
      dplyr::group_by(.data[[id]]) |>
      dplyr::slice(1) |>
      dplyr::ungroup() |>
      dplyr::summarise(s = sd(.data[[bp_var]], na.rm = TRUE)) |>
      dplyr::pull(s)
    
    df <- df |>
      dplyr::mutate(!!bp_z := .data[[bp_var]] / global_sd)
    
  }
  
  if (lag_bool == TRUE) {
    lag_vec <- paste0(lag_vec, "_z")
    df <- df |>
      dplyr::group_by(.data[[id]]) |>
      dplyr::mutate(dplyr::across(dplyr::all_of(lag_vec), ~ dplyr::lag(., n = lag_n), .names = "{.col}_lag{lag_n}")) |> 
      dplyr::ungroup()
  }
  
  if (lead_bool == TRUE) {
    lead_vec <- paste0(lead_vec, "_z")
    df <- df |>
      dplyr::group_by(.data[[id]]) |>
      dplyr::mutate(dplyr::across(dplyr::all_of(lead_vec), ~ dplyr::lead(., n = lead_n), .names = "{.col}_lead{lead_n}")) |> 
      dplyr::ungroup()
  }
  
  return(df)
}