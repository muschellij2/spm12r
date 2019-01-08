#' @title Install SPM12 file into directory
#' @description Install spm12 scripts to spm12r for script capabilities
#' @param lib.loc a character vector with path names of R libraries.
#' Passed to \code{\link{system.file}}
#' @param verbose print diagnostic messages
#' @param install_dir Alternative directory to download SPM12
#' @return NULL
#' @importFrom git2r clone
#' @export
#' @examples 
#' tdir = tempfile()
#' dir.create(tdir)
#' in_ci <- function() {
#' nzchar(Sys.getenv("CI"))
#' }
#' if (.Platform$OS.type == "unix" | in_ci()) { # windows problem
#' res = install_spm12(install_dir = tdir)
#' res = install_spm12(install_dir = tdir)
#' }
install_spm12 = function(
  lib.loc = NULL,
  verbose = TRUE,
  install_dir = NULL) {
  if (is.null(install_dir)) {
    install_dir = system.file(package = "spm12r",
                lib.loc = lib.loc)
  }
  spm12_files = file.path(install_dir, "spm12")
  spm12_files = file.path(install_dir, "spm12", "toolbox")  
  if (!all(file.exists(spm12_files))) {
    # url = "http://muschellij2.github.io/spm12r/spm12.zip"
    # urlfile <- file.path(system.file(package="spm12r"), "spm12.zip")
    # utils::download.file(url, urlfile, quiet = TRUE)
    # utils::unzip(urlfile, exdir = system.file(package="spm12r"))
    out_path = file.path(install_dir, "spm12")
    git2r::clone(
      "https://github.com/muschellij2/spm12r", 
      branch = "gh-pages", 
      local_path = out_path,
      progress = verbose
    )
    git_folder = file.path(out_path, ".git")
    unlink(git_folder, recursive = TRUE, force = TRUE)
    # for (ifile in files) system(sprintf("chmod +x %s", ifile))
    # file.remove(urlfile)
  }
  # spm12_files = system.file(
  #   "spm12", 
  #   package = "spm12r",
  #   lib.loc = lib.loc)
  # spm12_files = c(
  #   spm12_files, system.file(
  #     "spm12", "toolbox", 
  #     package = "spm12r",
  #     lib.loc = lib.loc) 
  # )   
  if (!all(file.exists(spm12_files))) {
    stop("SPM12 not installed in spm12r directory, stopping")
  }
  return(TRUE)
}