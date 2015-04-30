#' @title SPM12 Realign (Estimate)
#'
#' @description Performs SPM12 Realignment estimation on an Image
#' @param filename Files to be realigned 
#' @param fwhm Full-Width Half Max to smooth 
#' @param register_to Should the files be registered to the first or the mean
#' @param prefix Prefix to append to front of image filename 
#' @param add_spm_dir Add SPM12 directory from this package
#' @param spmdir SPM dir to add, will use package default directory 
#' @param clean Remove scripts from temporary directory after running
#' @param verbose Print diagnostic messages
#' @param outdir Directory to copy results.  If full filename given, then results will
#' be in \code{dirname(filename)}
#' @param retimg (logical) return image of class nifti
#' @param reorient (logical) If retimg, should file be reoriented when read in?
#' Passed to \code{\link{readNIfTI}}. 
#' @param ... Arguments passed to \code{\link{run_spm12_script}}
#' @export
#' @import fslr
#' @import matlabr
#' @return Result from run_matlab_script 
spm12_realign <- function(filename, 
                          fwhm = 5,                              
                          register_to = c("first", "mean"),
                          prefix = "r",
                          add_spm_dir = TRUE,
                          spmdir = spm_dir(),                          
                          clean = TRUE,
                          verbose = TRUE,
                          outdir = NULL,
                          retimg = TRUE,
                          reorient = FALSE,                          
                          ...
){
  
  ########################
  # Getting Number of Time points
  ########################  
  if (verbose){
    cat("# Getting Number of Time Points\n")
  }
  time_points = ntime_points(filename)
  
  # check filenames
  filename = filename_check(filename)
  outfile = file.path(dirname(filename),
                      paste0(prefix, basename(filename)))
  stub = nii.stub(filename, bn=TRUE)[1]
  rpfile = file.path(dirname(filename),
                     paste0("rp_", stub, ".txt"))
  meanfile = file.path(dirname(filename),
                     paste0("mean", stub, ".nii"))
  matfile = file.path(dirname(filename),
                       paste0(stub, ".mat"))
  
  ##########################################################
  # Pasting together for a 4D file
  ##########################################################
  filename = paste0(filename, ",", time_points)
  filename = rvec_to_matlabcell(filename)
  
  register_to = match.arg(register_to, c("first", "mean"))
  register_to = switch(register_to,
                       first = 0, 
                       mean = 1)
  
  jobvec = c(filename, prefix, fwhm, 
             register_to, spmdir)
  names(jobvec) = c("%filename%", "%prefix%", "%fwhm%", 
                    "%registerto%", "%spmdir%")  
  
  res = run_spm12_script( script_name = "Realign",
                          jobvec = jobvec,
                          mvec = NULL,
                          add_spm_dir = add_spm_dir,
                          spmdir = spmdir,
                          clean = clean, 
                          verbose = verbose, 
                          ...)
  stopifnot(res == 0)
  ####################
  # Copy outfiles
  ####################  
  if (!is.null(outdir)){
    file.copy(outfile, to = outdir, overwrite = TRUE)
    file.copy(rpfile, to = outdir, overwrite = TRUE)
    file.copy(meanfile, to = outdir, overwrite = TRUE)
    file.copy(matfile, to = outdir, overwrite = TRUE)    
  }
  
  #############################
  # Returning Image
  #############################  
  if (retimg){
    if (length(outfile) > 1){
      outfile = lapply(outfile, readNIfTI, reorient=reorient)
    } else {
      outfile = readNIfTI(outfile, reorient=reorient)
    }
  }
  return(outfile)
}

