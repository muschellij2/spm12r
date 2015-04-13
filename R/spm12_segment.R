#' @title SPM12 Segment
#'
#' @description Performs SPM12 Segmentation on an Image
#' @param filename File to be segmented
#' @param add_spm_dir Add SPM12 directory from this package
#' @export
#' @import matlabr
#' @return Result from run_matlab_script
spm12_segment <- function(filename, add_spm_dir = TRUE){
  scripts = spm12_script("Segment")
  m = readLines(scripts['script'])
  
  filename = path.expand(filename)
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
  
  m = gsub("%jobfile%", scripts['job'], m)

  if (add_spm_dir){
    spmdir = spm_dir()
    m = c(paste0("addpath(genpath('", spmdir, "'));"),
          m)
  }
  writeLines(m, con=scripts['script'])
  writeLines(job, con=scripts['job'])
  res = run_matlab_script(scripts['script'])
  return(res)
}



