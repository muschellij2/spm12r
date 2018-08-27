#' @title SPM12 Smooth
#'
#' @description Performs SPM12 Smoothing on an Image
#' @param filename File to be smoothed
#' @param retimg Logical indicating if image should be returned or
#' result from \code{\link{run_matlab_script}}
#' @param fwhm Full-Width Half Max to smooth
#' @param dtype data type for the output format 
#' @param implicit_mask Should an implicit mask be used.
#' An "implicit mask" is a mask implied by a 
#' particular voxel value (0 for images with integer type, 
#' NaN for float images).
#' @param prefix Prefix to append to front of image filename
#' @param add_spm_dir Add SPM12 directory from this package
#' @param spmdir SPM dir to add, will use package default directory
#' @param clean Remove scripts from temporary directory after running
#' @param verbose Print diagnostic messages
#' @param reorient if \code{retimg=TRUE} pass to \code{\link{readNIfTI}}
#' @param ... Arguments passed to \code{\link{run_spm12_script}}
#' \code{\link{readNIfTI}}
#' @param install_dir directory to download SPM12
#' 
#' @export
#' @return Result from run_matlab_script or nifti file, depending on
#' \code{retimg}
spm12_smooth <- function(
  filename,
  retimg = FALSE,
  fwhm = 8,
  dtype = c("SAME", "UINT8", "INT16", 
            "INT32", "FLOAT32", "FLOAT64"),
  implicit_mask = FALSE,
  prefix = "s",
  add_spm_dir = TRUE,
  spmdir = spm_dir(verbose = verbose,
                   install_dir = install_dir),
  clean = TRUE,
  verbose = TRUE,
  reorient = FALSE,
  install_dir = NULL,
  ...
){
  install_spm12(verbose = verbose,
                install_dir = install_dir)
  # check filenames
  filename = filename_check(filename)
  xfilename = filename
  
  dtype = toupper(dtype)
  dtype = match.arg(dtype)
  dtype = switch(
    dtype,
    SAME = 0,
    UINT8 = 2,
    INT16 = 4,
    INT32 = 8,
    FLOAT32 = 16,
    FLOAT64 = 64)
  
  implicit_mask = as.integer(implicit_mask)
  xprefix = prefix
  jobvec = c(filename, prefix, fwhm, 
             dtype, implicit_mask)
  names(jobvec) = c("%filename%", "%prefix%", "%fwhm%", 
                    "%dtype%", "%implicit_mask%")
  
  class(filename) = "cell"
  filename = convert_to_matlab(filename)
  
  fwhm = rep(fwhm, 3)
  class(fwhm) = "rowvec"
  fwhm = convert_to_matlab(fwhm)
  
  # Change nothign in the jobvec after here
  #########################################
  prefix = convert_to_matlab(prefix)
  
  spm = list(
    spatial = list(
      smooth = list(
        im = filename,
        fwhm = fwhm,
        dtype = dtype,
        im = implicit_mask,
        prefix = prefix
      )
    )
  )
  
  spm = list(spm = spm)
  class(spm) = "matlabbatch"
  
  script = matlabbatch_to_script(spm)    
  
  L = list(
    spm = spm,
    script = script)  
  
  res = run_spm12_script(
    script_name = "Smooth",
    jobvec = jobvec,
    mvec = NULL,
    add_spm_dir = add_spm_dir,
    spmdir = spmdir,
    clean = clean,
    verbose = verbose,
    ...)
  L$result = res
  if (res != 0) {
    warning("Result was not zero!")
  }  
  outfile = file.path(
    dirname(xfilename),
    paste0(xprefix, basename(xfilename)))
  L$outfiles = outfile

  if (retimg) {
    if (length(outfile) > 1) {
      L$outfiles = lapply(outfile, readNIfTI, reorient = reorient)
    } else {
      L$outfiles = readNIfTI(outfile, reorient = reorient)
    }
  }
  return(L)
}


