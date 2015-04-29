#' @title SPM12 Slice Timing Correction
#'
#' @description Performs SPM12 slice timing correction on images
#' @param filename Files to be slice-time corrected 
#' @param time_points Time points to run slice-time correction.  If \code{filename} is a 
#' 4D file, then will do all the time points.  Otherwise, \code{filename} must be a character 
#' vector of 3D files or a list of 3D nifti objects.
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
#' @param outdir Directory to copy results
#' @param ... Arguments passed to \code{\link{run_spm12_script}}
#' @export
#' @import fslr
#' @import matlabr
#' @import oro.nifti
#' @return Output filenames
spm12_slice_timing <- function(filename, 
                               time_points = NULL,
                               nslices,
                               tr, 
                               ta = tr - tr/nslices,
                               slice_order = 1:nslices,
                               ref_slice,
                               prefix = "a",
                               add_spm_dir = TRUE,
                               spmdir = spm_dir(),                          
                               clean = TRUE,
                               verbose = TRUE,
                               outdir = tempdir(),
                               ...
){
  
  ########################
  # Getting Number of Time points
  ########################  
  if (is.null(time_points)){
    img = check_nifti(filename)
    if (is.list(img)){
      time_points = rep(1, length(img))
    } else if (is.nifti(img)){
      time_points = seq(ntim(img))
    } else {
      stop("Unknown filename type - not nifti, character, or list")
    }
  }
  
  # check filenames
  filename = filename_check(filename) 
  outfile = file.path(dirname(filename),
                      paste0(prefix, basename(filename)))  
  if (length(time_points) < 2){
    stop("SPM Slice Timing Correction requires >= 2 images")
  }  
  
  slice_order = rvec_to_matlab(slice_order, row=TRUE)
  filename = paste0(filename, ",", time_points)
  filename = rvec_to_matlabcell(filename)
  jobvec = c(filename, prefix, nslices, 
             tr, ta, slice_order,
             ref_slice)
  names(jobvec) = c("%filename%", "%prefix%", "%nslices%",
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
  
  file.copy(outfile, to = outdir, overwrite = TRUE)
  return(outfile)
}


