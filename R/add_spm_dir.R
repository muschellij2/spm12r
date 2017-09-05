#' Add SPM Directory
#'
#' @param x Character vector of commands
#' @param spmdir SPM Directory
#' @param verbose Print diagnostic messages
#'
#' @return A character vector
#' @export
add_spm_dir = function(
  x, 
  spmdir = spm_dir(verbose = verbose),
  verbose = TRUE) {
  if (verbose) {
    message(paste0("# Adding SPMDIR: ", spmdir, "\\n"))
  }
  x = c(
    paste0("addpath(genpath('", 
           spmdir, "'));"),
    x)
  return(x)
}

#' @rdname add_spm_dir
#' @export
add_spm12_dir = add_spm_dir