#' SPM Version 
#'
#' @return Character vector of length 1
#' @export
#'
#' @examples 
#' if (matlabr::have_matlab()) {
#' spm_version()
#' }
spm_version = function() {
  code = "x = spm('version'); disp(x);"
  ver = run_matlab_code(
    code, 
    intern = TRUE, 
    verbose = FALSE)
  ver = ver[length(ver)]
  return(ver)
}

#' @export
#' @rdname spm_version
spm12_version = spm_version
