#' @title Get SPM12 Directory
#'
#' @description Returns the SPM12 directory 
#' @export
#' @return Chracter vector of spm12 paths
#' @examples 
#' spm_dir()
spm_dir <- function(){
  install_spm12()
  return(system.file("spm12", package="spm12r"))
}