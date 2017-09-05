#' @title SPM12 Normalize (Write)
#'
#' @description Applies SPM12 (Spatial) Normalization to images
#' @param deformation Filename of deformation (nifti)
#' @param other.files Files to be written using the estimated
#' normalization
#' @param bounding_box matrix (2x3) of the bounding box to use.  
#' Default is for MNI 2mm template
#' size 
#' @param voxel_size The voxel sizes (x, y & z, in mm) 
#' of the written normalised images.
#' @param interp Interpolator for sampling in fixed space 
#' @param retimg Logical indicating if image should be returned or
#' result from \code{\link{run_matlab_script}}
#' @param reorient if \code{retimg=TRUE} pass to 
#' \code{\link{readNIfTI}}
#' @param add_spm_dir Add SPM12 directory from this package
#' @param spmdir SPM dir to add, will use package default directory
#' @param clean Remove scripts from temporary directory after running
#' @param verbose Print diagnostic messages
#' @param ... Arguments passed to \code{\link{run_spm12_script}}
#' @export
#' @return Result from run_matlab_script
spm12_normalize_write <- function(
  deformation,
  other.files = NULL,
  bounding_box = matrix(
    c(-90, -126, -72, 90, 90, 108),
    nrow = 2, byrow = TRUE),         
  voxel_size = c(2,2,2),
  interp = c(
    "bspline4", "nearestneighbor", "trilinear", 
    paste0("bspline", 2:3),
    paste0("bspline", 5:7)),      
  retimg = TRUE,
  reorient = FALSE,
  add_spm_dir = TRUE,
  spmdir = spm_dir(),
  clean = TRUE,
  verbose = TRUE,
  ...
){
  install_spm12(verbose = verbose)
  
  # check deformations
  deformation = filename_check(deformation)
  
  if (!is.null(other.files)) {
    other.files = filename_check(other.files)
  } else {
    stop("No files specified, no files written")
  }
  other.fnames = other.files
  other.files = rvec_to_matlabcell(other.fnames, transpose = TRUE)
  
  
  if (is.matrix(bounding_box)) {
    bounding_box = rmat_to_matlab_mat(bounding_box)
  }
  
  stopifnot(length(voxel_size) == 3)
  class(voxel_size) = "rowvec"
  voxel_size = convert_to_matlab(voxel_size)
  
  levs = c("nearestneighbor", "trilinear", paste0("bspline", 2:7))
  interp = interp[1]
  interp = match.arg(interp)
  interp = factor(interp, levels = levs)
  interp = convert_to_matlab(interp)  
  
  jobvec = c(
    deformation, other.files, bounding_box,
    interp, voxel_size)
  names(jobvec) = c(
    "%deformation%", "%resample%", "%bbox%",
    "%interp%", "%vox%")
  
  res = run_spm12_script(
    script_name = "Normalize_Write",
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
  outfiles = file.path(
    dirname(other.fnames),
    paste0("w", basename(other.fnames)))
  if (retimg) {
    outfiles = lapply(outfiles, readNIfTI, reorient = reorient)
  }
  L = list(outfiles = outfiles)
  
  #########################################
  # Change nothign in the jobvec after here
  #########################################
  vol = paste0("{'", deformation, "'}")
  
  spm = list(
    spatial = list(
      normalise = list(
        write = 
          list(
            subj = list(
              def = vol,
              resample = other.files,
              woptions = list(
                interp = interp,
                vox = voxel_size,
                bb = bounding_box
              )
            )
          )
      )
    )
  )
  spm = list(spm = spm)
  class(spm) = "matlabbatch"
  
  script = matlabbatch_to_script(spm)      
  L$spm = spm
  L$script = script
  
  return(L)
}


