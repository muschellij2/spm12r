#' @title SPM12 Realign (Estimate)
#'
#' @description Performs SPM12 Realignment estimation on an Image
#' @param filename Files to be realigned 
#' @param fwhm Full-Width Half Max to smooth 
#' @param register_to Should the files be registered to the first or the mean
#' @param add_spm_dir Add SPM12 directory from this package
#' @param spmdir SPM dir to add, will use package default directory 
#' @param clean Remove scripts from temporary directory after running
#' @param verbose Print diagnostic messages
#' @param ... Arguments passed to \code{\link{run_spm12_script}}
#' @export
#' @import fslr
#' @import matlabr
#' @return Result from run_matlab_script 
spm12_realign_est <- function(filename, 
                              fwhm = 5,                              
                              register_to = c("first", "mean"),
                              add_spm_dir = TRUE,
                              spmdir = spm_dir(),                          
                              clean = TRUE,
                              verbose = TRUE,
                              ...
){
  
  # check filenames
  filename = filename_check(filename)
  
  register_to = match.arg(register_to, c("first", "mean"))
  register_to = switch(register_to,
                       first = 0, 
                       mean = 1)
  
  jobvec = c(filename, register_to, spmdir)
  names(jobvec) = c("%filename%", "%registerto%", "%spmdir%")
  
  res = run_spm12_script( script_name = "Realign_Estimate",
                          jobvec = jobvec,
                          mvec = NULL,
                          add_spm_dir = add_spm_dir,
                          spmdir = spmdir,
                          clean = clean, 
                          verbose = verbose, 
                          ...)
  
  return(res)
}


