
#' Build Conditions for SPM12 first level model
#'
#' @param name Name of the condition
#' @param onset vector of onset of the condition
#' @param duration vector of duration of the condition, 
#' must be the same length as \code{onset}
#' @param time_mod_order time modulation order. 
#' This option allows for the characterization of linear or 
#' nonlinear time effects. Zero means no modulation
#' @param param_mod parametric modulation.  Not currently
#' supported in \code{spm12r}
#' @param orth Orthogonalize the regressors within trial types.
#' @param cond List of conditions
#'
#' @return A list of objects, each with a \code{name}, \code{onset}, 
#' \code{duration}, and other condition values.
#' @export
#'
#' @examples
#' res = spm12_condition(
#' name = "condition1", 
#' onset = c(0, 2, 4, 6, 8),
#' duration = rep(1, 5) )
#' print(res)
#' L = list(
#' cond1 = list(onset = c(0, 2, 4, 6, 8), duration = rep(1, 5)), 
#' cond2 = list(onset = c(0, 2, 4, 6, 8) + 1, duration = rep(1, 5))
#' )
#' res = spm12_condition_list(L)
#' print(res) 
spm12_condition = function(
  name, onset, duration, 
  time_mod_order = 0, 
  param_mod = NULL, 
  orth = TRUE) {
  if (length(name) != 1) {
    stop("Condition name must be 1!")
  }
  name = convert_to_matlab(name)
  
  l_onset = length(onset)
  l_duration = length(duration)
  if (l_onset != l_duration) {
    stop("Number of onset must be equal to the number of duration")
  }
  orth = as.integer(orth)
  time_mod_order = as.integer(time_mod_order)
  if (time_mod_order < 0 || time_mod_order > 6) {
    stop("time_mod_order must be an integer between 0 and 6!")
  }
  if (!is.null(param_mod)) {
    stop("Parametric modulation not supported yet in spm12r!")
  }
  param_mod = "struct('name', {}, 'param', {}, 'poly', {})"
  
  class(onset) = "rowvec"
  onset = convert_to_matlab(onset)
  class(duration) = "rowvec"
  duration = convert_to_matlab(duration)
  
  L = list(
    name = name,
    onset = onset,
    duration = duration,
    tmod = time_mod_order,
    pmod = param_mod,
    orth = orth
  )
  return(L)
}




#' @rdname spm12_condition
#' @export
spm12_condition_list = function(cond) {
  
  ###########################
  # Either named list
  ###########################
  n_cond = names(cond)
  extractor = function(ind) {
    lapply(cond, `[[`, ind)
  }
  ###########################
  # or grab the "name" element
  ###########################
  n_cond2 = extractor("name")
  n_cond2 = unlist(n_cond2)
  if (!is.null(n_cond2)) {
    n_cond = n_cond2
  }
  
  l_cond = length(cond)
  msg = "Conditions must be named and not NA!"
  if (is.null(n_cond)) {
    stop(msg)
  }
  if (any(n_cond %in% "" | is.na(n_cond))) {
    stop(msg)
  }
  if (length(n_cond) != l_cond) {
    stop("Conditions not the same as the number of names")
  }
  
  # make sure name is in there
  cond = mapply(function(x, y) {
    x$name = y
    # class(x$onset) = "rowvec"
    # x$onset = convert_to_matlab(x$onset)
    # class(x$duration) = "rowvec"
    # x$duration = convert_to_matlab(x$duration)
    x
  }, cond, n_cond, SIMPLIFY = FALSE)
  
  
  cond = lapply(cond, function(x) {
    r = do.call("spm12_condition", x)
    return(r)
  })
  names(cond) = paste0("(", seq(cond), ")")
  return(cond)
}


