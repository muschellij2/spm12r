#' @title Get SPM12 Directory
#'
#' @description Returns the SPM12 directory 
#' @param verbose print diagnostic messages, passed to 
#' \code{\link{install_spm12}}
#' @param install_dir directory to download SPM12
#' @export
#' @return Character vector of spm12 paths
spm_dir <- function(verbose = FALSE,
                    install_dir = NULL){
  install_spm12(verbose = verbose,
                install_dir = install_dir)
  res = system.file("spm12", package = "spm12r")
  if (!is.null(install_dir)) {
    res = file.path(install_dir, "spm12")
  }
  return(res)
}