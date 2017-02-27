#' @title SPM12 Normalize (Write)
#'
#' @description Applies SPM12 (Spatial) Normalization to images
#' @param deformation Filename of deformation (nifti)
#' @param other.files Files to be written using the estimated
#' normalization
#' @param bounding_box matrix (2x3) of the bounding box to use.  Default is for MNI 2mm template
#' size 
#' @param retimg Logical indicating if image should be returned or
#' result from \code{\link{run_matlab_script}}
#' @param reorient if \code{retimg=TRUE} pass to \code{\link{readNIfTI}}
#' @param add_spm_dir Add SPM12 directory from this package
#' @param spmdir SPM dir to add, will use package default directory
#' @param clean Remove scripts from temporary directory after running
#' @param verbose Print diagnostic messages
#' @param ... Arguments passed to \code{\link{run_spm12_script}}
#' @export
#' @return Result from run_matlab_script
spm12_normalize_write <- function(deformation,
                            other.files = NULL,
                            bounding_box = matrix(c(-90, -126, -72, 90, 90, 108),
                                                  nrow=2, byrow=TRUE),                            
                            retimg = TRUE,
                            reorient = FALSE,
                            add_spm_dir = TRUE,
                            spmdir = spm_dir(),
                            clean = TRUE,
                            verbose = TRUE,
                            ...
){
  install_spm12()

  # check deformations
  deformation = filename_check(deformation)

  if (!is.null(other.files)) {
    other.files = filename_check(other.files)
  } else {
    stop("No files specified, no files written")
  }
  other.fnames = other.files
  other.files = rvec_to_matlabcell(other.fnames, transpose = TRUE)
  # 
  # other.fnames = other.files
  # # Pasting them together
  # other.files = sapply(other.files, function(o){
  #   paste0("'", o, "'\n")
  # })
  # other.files = paste(other.files,  collapse = " ")

  if (is.matrix(bounding_box)) {
    bounding_box = rmat_to_matlab_mat(bounding_box)
  }
  
  jobvec = c(deformation, other.files, bounding_box)
  names(jobvec) = c("%deformation%", "%resample%", "%bbox%")

  res = run_spm12_script( script_name = "Normalize_Write",
                          jobvec = jobvec,
                          mvec = NULL,
                          add_spm_dir = add_spm_dir,
                          spmdir = spmdir,
                          clean = clean,
                          verbose = verbose,
                          ...)
  if (res != 0) {
    warning("Result was not zero!")
  }
  outfiles = file.path(dirname(other.fnames),
                       paste0("w", basename(other.fnames)))
  if (retimg) {
    outfiles = lapply(outfiles, readNIfTI, reorient = reorient)
  }
  L = list(outfiles = outfiles)
  return(L)
}


