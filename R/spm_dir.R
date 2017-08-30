#' @title Get SPM12 Directory
#'
#' @description Returns the SPM12 directory 
#' @export
#' @return Chracter vector of spm12 paths
spm_dir <- function(verbose = FALSE){
  install_spm12(verbose = verbose)
  return(system.file("spm12", package = "spm12r"))
}