#' @title SPM12 Smooth
#'
#' @description Performs SPM12 Smoothing on an Image
#' @param filename File to be segmented
#' @param retimg Logical indicating if image should be returned or
#' result from \code{\link{run_matlab_script}}
#' @param fwhm Full-Width Half Max to smooth
#' @param prefix Prefix to append to front of image filename
#' @param add_spm_dir Add SPM12 directory from this package
#' @param spmdir SPM dir to add, will use package default directory 
#' @param clean Remove scripts from temporary directory after running
#' @param verbose Print diagnostic messages
#' @param reorient if \code{retimg=TRUE} pass to \code{\link{readNIfTI}}
#' @param ... if \code{retimg=TRUE} arguments to pass to 
#' \code{\link{readNIfTI}}
#' @export
#' @import fslr
#' @import matlabr
#' @return Result from run_matlab_script or nifti file, depending on 
#' \code{retimg}
spm12_smooth <- function(filename, 
                          retimg = TRUE,
                          fwhm = 8,
                          prefix = "s",
                          add_spm_dir = TRUE,
                          spmdir = spm_dir(),                          
                          clean = TRUE,
                          verbose = TRUE,
                          reorient = FALSE,
                          ...
){
  scripts = spm12_script("Smooth")
  m = readLines(scripts['script'])
  
  ###########################
  # Passing to see if image or filename passed in
  ###########################  
  filename = checknii(filename, ...)
  filename = path.expand(filename)
  ##################################
  # Making an absolute path
  ##################################  
  dn = dirname(filename)
  filename = file.path(dn, basename(filename))
  if (grepl("^[.]", filename)){
    gd = getwd()
    filename = gsub("^[.]", "", filename)
    filename = file.path(gd, filename)
  }

  stopifnot(inherits(filename, "character"))
  stopifnot(file.exists(filename))
  #   infile = checkimg(infile, gzipped=FALSE)
  #   infile = path.expand(infile)
  #   if (grepl("\\.gz$", infile)){
  #     infile = gunzip(infile, remove=FALSE, temporary=TRUE,
  #                     overwrite=TRUE)
  #   } else { 
  #     infile = paste0(nii.stub(infile), ".nii")
  #   }
  #   
  job = readLines(scripts['job'])
  job = gsub("%filename%", filename, job)
  job = gsub("%prefix%", prefix, job)
  job = gsub("%fwhm%", fwhm, job)
  
  m = gsub("%jobfile%", scripts['job'], m)
  
  if (add_spm_dir){
    m = c(paste0("addpath(genpath('", spmdir, "'));"),
          m)
  }
  writeLines(m, con=scripts['script'])
  writeLines(job, con=scripts['job'])
  res = run_matlab_script(scripts['script'])
  if (clean) {
    file.remove(scripts)
  }
  if (retimg){
    outfile = file.path(dirname(filename), 
                         paste0(prefix, basename(filename)))
    res = readNIfTI(outfile, reorient = reorient, ...)
    return(res)
  }
  return(res)
}


