#' @title SPM12 Normalize (Estimate)
#'
#' @description Estimate SPM12 (Spatial) Normalization from image
#' @param filename File to be normalized to the template
#' @param biasreg Amount of bias regularization
#' @param biasfwhm FWHM  of  Gaussian  smoothness  of  bias.  
#' @param regularization parameters for warping regularization
#' @param affine Space to register the image to, using an affine registration
#' @param smoothness FWHM of smoothing done
#' @param sampling_distance amount of smoothing of the warping field. 
#' This is used to derive a fudge factor to account for 
#' correlations between neighbouring voxels.  Smoother data have more 
#' @param add_spm_dir Add SPM12 directory from this package
#' @param spmdir SPM dir to add, will use package default directory
#' @param clean Remove scripts from temporary directory after running
#' @param verbose Print diagnostic messages
#' @param ... Arguments passed to \code{\link{run_spm12_script}}
#' @export
#' @return Result from run_matlab_script
spm12_normalize_est <- function(
  filename,
  biasreg = 0.001,
  biasfwhm = 60,  
  regularization = c(0, 0.001, 0.5, 0.05, 0.2),
  affine = c("mni", "eastern", "subj", "none", ""),
  smoothness = 0,
  sampling_distance = 3,    
  add_spm_dir = TRUE,
  spmdir = spm_dir(verbose = verbose),
  clean = TRUE,
  verbose = TRUE,
  ...
){
  
  install_spm12(verbose = verbose)
  # check filenames
  filename = filename_check(filename)
  
  affine = match.arg(affine)
  affine = convert_to_matlab(affine)  
  class(regularization) = "rowvec"
  regularization = convert_to_matlab(regularization)
  
  levs = c("nearestneighbor", "trilinear", paste0("bspline", 2:7))
  interp = interp[1]
  interp = match.arg(interp)
  interp = factor(interp, levels = levs)
  interp = convert_to_matlab(interp)
  
  jobvec = c(
    filename, spmdir, 
    biasreg, biasfwhm,
    interp, affine, 
    regularization, smoothness, sampling_distance)
  names(jobvec) = c(
    "%filename%", "%spmdir%",
    "%biasreg%", "%biasfwhm%",
    "%interp%", "%affreg%", "%reg%",
    "%fwhm%", "%samp%")  
  #########################################
  # Change nothign in the jobvec after here
  #########################################
  tpm = file.path(spmdir, "tpm", "TPM.nii")
  tpm = convert_to_matlab(tpm)
  tpm = paste0("{", tpm , "}")
  vol = paste0("{'", filename, "'}")  
  
  res = run_spm12_script( 
    script_name = "Normalize_Estimate",
    jobvec = jobvec,
    mvec = NULL,
    add_spm_dir = add_spm_dir,
    spmdir = spmdir,
    clean = clean,
    verbose = verbose,
    ...)
  
  
  #########################################
  # Change nothign in the jobvec after here
  #########################################
  tpm = file.path(spmdir, "tpm", "TPM.nii")
  tpm = convert_to_matlab(tpm)
  tpm = paste0("{", tpm, "}")
  vol = paste0("{'", filename, "'}")
  
  spm = list(
    spatial = list(
      normalise = list(
        estwrite = 
          list(
            subj = list(
              vol = vol,
              eoptions = list(
                biasreg = biasreg,
                biasfwhm = biasfwhm,
                tpm = tpm,
                affreg = affine,
                reg = regularization,
                samp = sampling_distance,
                fwhm = smoothness
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
    result = res)
  return(L)
}


