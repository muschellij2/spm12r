#' @title Install SPM12 file into directory
#' @description Install spm12 scripts to spm12r for script capabilities
#' @param lib.loc a character vector with path names of R libraries.
#' Passed to \code{\link{system.file}}
#' @param verbose print diagnostic messages
#' @return NULL
#' @importFrom git2r clone
#' @export
install_spm12 = function(
  lib.loc = NULL,
  verbose = TRUE){
  spm12_files = system.file(
    "spm12", 
    package = "spm12r",
    lib.loc = lib.loc)
  spm12_files = c(
    spm12_files, 
    system.file(
      "spm12", "toolbox", 
      package = "spm12r",
      lib.loc = lib.loc)) 
  if (!all(file.exists(spm12_files))) {
    # url = "http://muschellij2.github.io/spm12r/spm12.zip"
    # urlfile <- file.path(system.file(package="spm12r"), "spm12.zip")
    # utils::download.file(url, urlfile, quiet = TRUE)
    # utils::unzip(urlfile, exdir = system.file(package="spm12r"))
    git2r::clone(
      "https://github.com/muschellij2/spm12r", 
      branch = "gh-pages", 
      local_path = file.path(
        system.file(package = "spm12r",
                    lib.loc = lib.loc), "spm12"),
      progress = verbose
    )
    git_folder = file.path(
      system.file(
        package = "spm12r",
        lib.loc = lib.loc), "spm12", ".git")
    unlink(git_folder, recursive = TRUE, force = TRUE)
    # for (ifile in files) system(sprintf("chmod +x %s", ifile))
    # file.remove(urlfile)
  }
  spm12_files = system.file(
    "spm12", 
    package = "spm12r",
    lib.loc = lib.loc)
  spm12_files = c(
    spm12_files, system.file(
      "spm12", "toolbox", 
      package = "spm12r",
      lib.loc = lib.loc) 
  )   
  if (!all(file.exists(spm12_files))) {
    stop("SPM12 not installed in spm12r directory, stopping")
  }
  return(TRUE)
}