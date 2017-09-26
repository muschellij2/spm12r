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
#' @importFrom utils packageVersion
ntime_points <- function(filename){
  ########################
  # Getting Number of Time points
  ########################
  
  oro_pkg = packageVersion("oro.nifti")
  neuro_pkg = packageVersion("neurobase")
  
  if (oro_pkg < 0.8 || neuro_pkg < 1.22) {
    nifti_header = neurobase::check_nifti 
  } else {
    nifti_header = neurobase::check_nifti_header
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
