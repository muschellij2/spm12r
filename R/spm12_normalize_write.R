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
#' @param install_dir directory to download SPM12
#' 
#' @param ... Arguments passed to \code{\link{run_spm12_script}}
#' @export
#' @return List of SPM object, results, and output filenames
#' @examples 
#' dims = rep(10, 3)
#' temp_nii = array(rnorm(prod(dims)), dim = dims)
#' temp_nii = oro.nifti::nifti(temp_nii)
#' res = build_spm12_normalize_write(temp_nii, 
#' other.files = temp_nii,
#' install_dir = tempdir())
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
  retimg = FALSE,
  reorient = FALSE,
  add_spm_dir = TRUE,
  spmdir = spm_dir(verbose = verbose,
                   install_dir = install_dir),
  clean = TRUE,
  verbose = TRUE,
  install_dir = NULL,
  ...
){
  
  install_spm12(verbose = verbose,
                install_dir = install_dir)
  
  L = build_spm12_normalize_write(
    deformation = deformation,
    other.files = other.files,
    bounding_box = bounding_box,
    voxel_size = voxel_size,
    interp = interp,
    verbose = verbose,
    ...)
  
  spm = L$spm$spm
  
  other_fnames = L$other_fnames
  deformation = L$deformation
  
  red_spm = spm$spatial$normalise$write$subj
  other.files = red_spm$resample 
  woptions = red_spm$woptions
  interp = woptions$interp
  voxel_size = woptions$vox
  bounding_box = woptions$bb
  rm(list = c("spm", "red_spm"))

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
    dirname(other_fnames),
    paste0("w", basename(other_fnames)))
  
  if (retimg) {
    if (length(outfiles) > 1) {
      outfiles = lapply(outfiles, readNIfTI, reorient = reorient)
    } else {
      outfiles = readNIfTI(outfiles, reorient = reorient)
    }
  }
  L$outfiles = outfiles
  L$result = res
  return(L)
}



#' @export
#' @rdname spm12_normalize_write
build_spm12_normalize_write <- function(
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
  verbose = TRUE,
  ...
){
  
  # check deformations
  deformation = filename_check(deformation)
  
  if (!is.null(other.files)) {
    other.files = filename_check(other.files)
  } else {
    stop("No files specified, no files written")
  }
  other_fnames = other.files
  other.files = rvec_to_matlabcell(other_fnames, transpose = TRUE)
  
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
  L = list(
    spm = spm,
    script = script,
    deformation = deformation,
    other_fnames = other_fnames
  )
  
  return(L)
}