#' @title SPM12 Normalize (Estimate and Write)
#'
#' @description Performs SPM12 (Spatial) Normalization on an Image
#' @param filename File to be normalized to the template
#' @param other.files Files to be written using the estimated 
#' normalization
#' @param add_spm_dir Add SPM12 directory from this package
#' @param spmdir SPM dir to add, will use package default directory 
#' @param clean Remove scripts from temporary directory after running
#' @param verbose Print diagnostic messages
#' @param ... Arguments passed to \code{\link{run_spm12_script}}
#' @export
#' @import fslr
#' @import matlabr
#' @return Result from run_matlab_script 
spm12_normalize <- function(filename, 
                            other.files = NULL,
                            add_spm_dir = TRUE,
                            spmdir = spm_dir(),                          
                            clean = TRUE,
                            verbose = TRUE,
                            ...
){
  
  # check filenames
  filename = filename_check(filename)
  
  if (!is.null(other.files)){
    other.files = filename_check(other.files)
  } else {
    other.files = filename
  }
  other.files = rvec_to_matlabcell(other.files, transpose = TRUE)
  # Pasting them together
  
  jobvec = c(filename, other.files, spmdir)
  names(jobvec) = c("%filename%", "%resample%", "%spmdir%")
  
  res = run_spm12_script( script_name = "Normalize_Estimate_and_Write",
                          jobvec = jobvec,
                          mvec = NULL,
                          add_spm_dir = add_spm_dir,
                          spmdir = spmdir,
                          clean = clean, 
                          verbose = verbose,                           
                          ...)
  
  return(res)
}


