#' @title SPM12 Segment
#'
#' @description Performs SPM12 Segmentation on an Image
#' @param filename File to be segmented
#' @param retimg Logical indicating if image should be returned or
#' result from \code{\link{run_matlab_script}}
#' @param set_origin Run \code{\link{acpc_reorient}} on image first.
#' Warning, this will set the orientation differently
#' @param add_spm_dir Add SPM12 directory from this package
#' @param spmdir SPM dir to add, will use package default directory 
#' @param clean Remove scripts from temporary directory after running
#' @param verbose Print diagnostic messages
#' @param reorient if \code{retimg=TRUE} pass to \code{\link{readNIfTI}}
#' @param ... Arguments passed to \code{\link{run_spm12_script}}
#' @export
#' @return List of output files (or niftis depending on \code{retimg}),
#' output matrix, and output deformations.
#' @importFrom neurobase nii.stub
spm12_segment <- function(filename, 
                          retimg = TRUE,
                          set_origin = TRUE,
                          add_spm_dir = TRUE,
                          spmdir = spm_dir(),                          
                          clean = TRUE,
                          verbose = TRUE,
                          reorient = FALSE,
                          ...
){
  install_spm12()
  # check filenames
  filename = filename_check(filename)  
  
  if (set_origin) {
    res = acpc_reorient(infiles = filename, verbose = verbose)
    if (verbose) {
      message(paste0("# Result of acpc_reorient:", res, "\n"))
    }
  }
  
  # put in the correct filenames
  jobvec = c(filename, spmdir)
  names(jobvec) = c("%filename%", "%spmdir%")
  
  res = run_spm12_script( script_name = "Segment",
                          jobvec = jobvec,
                          mvec = NULL,
                          add_spm_dir = add_spm_dir,
                          spmdir = spmdir,
                          clean = clean,
                          verbose = verbose,
                          ...)  
  outfiles = file.path(
    dirname(filename), 
    paste0("c", 1:6, basename(filename)))
  
  out_mat = file.path(dirname(filename),
                      paste0(  
                        nii.stub(filename, bn = TRUE),
                        "_seg8.mat"))
  
  out_def = file.path(dirname(filename),
                      paste0(
                        "y_",
                        basename(filename)))
  res = list(
    outfiles = outfiles,
    outmat = out_mat,
    deformation = out_def)
  
  if (retimg) {
    res$outfiles = check_nifti(outfiles, reorient = reorient)
  }
  
  return(res)
}


