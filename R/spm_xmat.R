
#' SPM X Matrix
#'
#' @param spm Path to SPM.mat file
#'
#' @return Matrix of values
#' @export
#' @importFrom utils read.csv
spm_xmat = function(spm) {
  tfile = tempfile(fileext = ".csv")
  spmmat = normalizePath(spm)
  code = c(sprintf("load('%s');", spmmat), 
           "X = SPM.xX.X;",
           sprintf("csvwrite('%s', X);", tfile)
  )
  res = matlabr::run_matlab_code(code)
  if (res != 0) {
    warning("Result was non-zero!  May have errors")
  }
  mat = read.csv(
    tfile, 
    stringsAsFactors = FALSE, header = FALSE)
  mat = as.matrix(mat)
  colnames(mat) = NULL
  mat
}
# spmmat = first_model$spmmat


#' SPM Directory
#'
#' @param spm Path to SPM.mat file
#'
#' @return Path to working directory
#' @export
spm_directory = function(spm) {
  tfile = tempfile(fileext = ".txt")
  spmmat = normalizePath(spm)
  
  code = c(sprintf("load('%s');", spmmat), 
           "X = SPM.swd;",
           sprintf("fileID = fopen('%s', 'w');", tfile),
           "fprintf(fileID, '%s', X);",
           "fprintf(fileID, '\\n');",
           "fclose(fileID);"
  )
  res = matlabr::run_matlab_code(code)
  if (res != 0) {
    warning("Result was non-zero!  May have errors")
  }
  mat = readLines(tfile)
  mat
}

