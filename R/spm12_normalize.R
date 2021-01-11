#' @title SPM12 Normalize (Estimate and Write)
#'
#' @description Performs SPM12 (Spatial) Normalization on an Image
#'
#' @param filename File to be normalized to the template
#' @param other.files Files to be written using the estimated
#' normalization
#' @param bounding_box matrix (2x3) of the bounding box to use.  
#' Default is for MNI 2mm template
#' size
#' @param add_spm_dir Add SPM12 directory from this package
#' @param spmdir SPM dir to add, will use package default directory
#' @param clean Remove scripts from temporary directory after running
#' @param verbose Print diagnostic messages
#' @param ... Arguments passed to \code{\link{run_spm12_script}}
#' @param biasreg Amount of bias regularization
#' @param regularization parameters for warping regularization
#' @param affine Space to register the image to, using an affine 
#' registration
#' @param smoothness FWHM of smoothing done
#' @param sampling_distance smoothness of the warping field. 
#' This is used to derive a fudge factor to account for 
#' correlations between neighbouring voxels.  
#' Approximate distance between sampled points when estimating 
#' the model parameters.
#' @param voxel_size The voxel sizes (x, y & z, in mm) 
#' of the written normalised images.
#' @param interp Interpolator for sampling in fixed space
#' @param biasfwhm FWHM  of  Gaussian  smoothness  of  bias.  
#' @param install_dir directory to download SPM12
#'
#' @export
#' @return List of output filenames
#' @importFrom matlabr rvec_to_matlabcell rvec_to_matlabcell 
#' @importFrom matlabr rmat_to_matlab_mat
spm12_normalize <- function(
  filename,
  other.files = NULL,
  bounding_box = matrix(
    c(-90, -126, -72, 90, 90, 108),
    nrow = 2, byrow = TRUE),
  biasreg = 0.001,
  biasfwhm = 60,  
  regularization = c(0, 0.001, 0.5, 0.05, 0.2),
  affine = c("mni", "eastern", "subj", "none", ""),
  smoothness = 0,
  sampling_distance = 3,  
  voxel_size = c(2,2,2),
  interp = c("bspline4", "nearestneighbor", "trilinear", 
             paste0("bspline", 2:3),
             paste0("bspline", 5:7)),    
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
  
  # check filenames
  filename = filename_check(filename)
  
  if (!is.null(other.files)) {
    other.files = filename_check(other.files)
  } else {
    other.files = filename
  }
  other.fnames = other.files
  other.files = rvec_to_matlabcell(other.files, transpose = TRUE)
  # Pasting them together
  
  if (is.matrix(bounding_box)) {
    bounding_box = rmat_to_matlab_mat(bounding_box)
  }
  
  affine = match.arg(affine)
  affine = convert_to_matlab(affine)  
  class(regularization) = "rowvec"
  regularization = convert_to_matlab(regularization)
  
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
  tpm = file.path(spmdir, "tpm", "TPM.nii")
  tpm = convert_to_matlab(tpm)
  tpm = paste0("{", tpm , "}")
  vol = paste0("{'", filename, "'}")
  
  spm = list(
    spatial = list(
      normalise = list(
        estwrite = 
          list(
            subj = list(
              vol = vol,
              resample = other.files,
              eoptions = list(
                biasreg = biasreg,
                biasfwhm = biasfwhm,
                tpm = tpm,
                affreg = affine,
                reg = regularization,
                samp = sampling_distance,
                fwhm = smoothness
              ),
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
    script = script)
  outfiles = file.path(
    dirname(other.fnames),
    paste0("w", basename(other.fnames)))  
  L$outfiles = outfiles
  
  jobvec = c(
    filename, other.files, 
    spmdir, bounding_box,
    biasreg, biasfwhm, 
    smoothness, sampling_distance,
    affine,
    voxel_size,
    interp,
    regularization)
  names(jobvec) = c(
    "%filename%", "%resample%", 
    "%spmdir%", "%bbox%",
    "%biasreg%", "%biasfwhm%",
    "%fwhm%", "%samp%", 
    "%affreg%",
    "%vox%",
    "%interp%", 
    "%reg%")
  
  res = run_spm12_script(
    script_name = "Normalize_Estimate_and_Write",
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
  
  L$result = res
  return(L)
}


