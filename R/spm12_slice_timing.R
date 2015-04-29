#' @title SPM12 Slice Timing Correction
#'
#' @description Performs SPM12 slice timing correction on images
#' @param filename Files to be slice-time corrected 
#' @param nslices Number of slices in the images
#' @param tr Repetition time (in seconds)
#' @param ta Time between the first and the last slice within one scan
#' @param slice_order Order slices were taken (if not specified, assumed ascending), 
#' bottom slice = 1
#' @param ref_slice Reference slice
#' @param prefix Prefix to append to front of image filename 
#' @param add_spm_dir Add SPM12 directory from this package
#' @param spmdir SPM dir to add, will use package default directory 
#' @param clean Remove scripts from temporary directory after running
#' @param verbose Print diagnostic messages
#' @param ... Arguments passed to \code{\link{run_spm12_script}}
#' @export
#' @import fslr
#' @import matlabr
#' @return Result from run_matlab_script 
spm12_slice_timing <- function(filename, 
                          nslices,
                          tr, 
                          ta = tr - tr/nslices,
                          slice_order = 1:nslices,
                          ref_slice = slice_order[median(seq(nslices))],
                          prefix = "a",
                          add_spm_dir = TRUE,
                          spmdir = spm_dir(),                          
                          clean = TRUE,
                          verbose = TRUE,
                          ...
){
  
  # check filenames
  filename = filename_check(filename)
  
  slice_order = rvec_to_matlab(slice_order, row=TRUE)
  jobvec = c(filename, prefix, nslices, 
             tr, ta, slice_order,
             ref_slice)
  names(jobvec) = c("%filename%", "%prefix%", 
                    "%tr%", "%ta%", "%sliceorder%", 
                    "%refslice%")
  
  res = run_spm12_script( script_name = "Slice_Timing",
                          jobvec = jobvec,
                          mvec = NULL,
                          add_spm_dir = add_spm_dir,
                          spmdir = spmdir,
                          clean = clean, 
                          verbose = verbose, 
                          ...)
  
  return(res)
}


