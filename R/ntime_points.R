#' @title Get number of time points from a file
#'
#' @description Extracts the number of time points from a nifti 
#' object, list or character
#' @param filename List of nifti objects, a vector of character 
#' filenames, or a single 4D nifti 
#' @export
#' @return Vector of time points
#' @importFrom oro.nifti is.nifti ntim 
#' @importFrom neurobase check_nifti
ntime_points <- function(filename){
  ########################
  # Getting Number of Time points
  ########################
  
  oro_pkg = packageVersion("oro.nifti")
  
  if (oro_pkg < 0.8) {
    nifti_header = neurobase::check_nifti_header
  } else {
    nifti_header = neurobase::check_nifti
  }
  
  img = nifti_header(filename)

  if (is.list(img)) {
    time_points = rep(1, length(img))
  } else if (is.nifti(img)) {
    time_points = seq(ntim(img))
  } else {
    stop("Unknown filename type - not nifti, character, or list")
  }
  return(time_points)
}
