#' @title SPM12 Segment
#'
#' @description Performs SPM12 Segmentation on an Image
#' @param filename File to be segmented
#' @param set_origin Run \code{\link{acpc_reorient}} on image first.
#' Warning, this will set the orientation differently
#' @param add_spm_dir Add SPM12 directory from this package
#' @param clean Remove scripts from temporary directory after running
#' @param verbose Print diagnostic messages
#' @export
#' @import matlabr
#' @return Result from run_matlab_script
spm12_segment <- function(filename, 
                          set_origin = TRUE,
                          add_spm_dir = TRUE,
                          clean = TRUE,
                          verbose = TRUE
){
  spmdir = spm_dir()  
  scripts = spm12_script("Segment")
  m = readLines(scripts['script'])
  
  ##############
  # Add in checkimg(filename, gzipped = FALSE)
  ##########
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
  if (set_origin){
    res = acpc_reorient(infiles = filename, verbose = verbose)
    if (verbose) {
      cat(paste0("# Result of acpc_reorient:", res, "\n"))
    }
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
  job = gsub("%spmdir%", spmdir, job)
  
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
  return(res)
}


