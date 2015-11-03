#' @title Install SPM12 file into directory
#' @description Install spm12 scripts to spm12r for script capabilities
#' @return NULL
#' @import utils
#' @export
install_spm12 = function(){
  spm12_files = system.file("spm12", package= "spm12r")
  
  if (!file.exists(spm12_files)) {
    url = "http://muschellij2.github.io/spm12r/spm12.zip"
    urlfile <- file.path(system.file(package="spm12r"), "spm12.zip")
    utils::download.file(url, urlfile, quiet = TRUE)
    utils::unzip(urlfile, exdir = system.file(package="spm12r"))
    # for (ifile in files) system(sprintf("chmod +x %s", ifile))
    file.remove(urlfile)
  }
  spm12_files = system.file("spm12", package = "spm12r")
  if (!all(file.exists(spm12_files))){
    stop("SPM12 not installed in spm12r directory, stopping")
  }
  return(TRUE)
}