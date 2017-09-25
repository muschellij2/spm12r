
#' Build Regressors for SPM12 first level model
#'
#' @param name Name of the regressor
#' @param value Value of the regressor, must be the same length as
#' \code{n_time_points}
#' @param n_time_points Number of time points for the analysis
#' @param reg List of regressors
#' 
#'
#' @return A list of objects, each with a \code{name} and \code{value}
#' @export
#'
#' @examples
#' res = spm12_regressor(name = "condition1", value = c(
#' rep(1, 10), rep(0, 10)), n_time_points = 20)
#' print(res)
#' L = list(
#' cond1 = list(value = c(rep(1, 10), rep(0, 10)), n_time_points = 20),
#' cond2 = list(value = c(rep(0, 10), rep(1, 10)), n_time_points = 20)
#' )
#' res = spm12_regressor_list(L, n_time_points = 20)
#' print(res)
spm12_regressor = function(
  name, value, n_time_points) {
  
  name = convert_to_matlab(name)
  
  l_value = length(value)
  stopifnot(l_value == n_time_points)
  class(value) = "rowvec"
  value = convert_to_matlab(value)
  L = list(
    name = name,
    value = value
    )
  return(L)
}




#' @rdname spm12_regressor
#' @export
spm12_regressor_list = function(reg, n_time_points) {
  
  ###########################
  # Either named list
  ###########################
  n_cond = names(reg)
  extractor = function(ind) {
    lapply(reg, `[[`, ind)
  }
  ###########################
  # or grab the "name" element
  ###########################
  n_cond2 = extractor("name")
  n_cond2 = unlist(n_cond2)
  if (!is.null(n_cond2)) {
    n_cond = n_cond2
  }
  
  l_cond = length(reg)
  msg = "Regressors must be named and not NA!"
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
  reg = mapply(function(x, y) {
    x$name = y
    x
  }, reg, n_cond, SIMPLIFY = FALSE)
  
  
  
  reg = lapply(reg, function(x) {
    x$n_time_points = n_time_points
    r = do.call("spm12_regressor", x)
    return(r)
  })
  names(reg) = paste0("(", seq(reg), ")")
  return(reg)
}


