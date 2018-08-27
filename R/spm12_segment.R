#' @title SPM12 Segment
#'
#' @description Performs SPM12 Segmentation on an Image
#'
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
#' @param biasreg Amount of bias regularization
#' @param biasfwhm FWHM  of  Gaussian  smoothness  of  bias. 
#' @param native Keep tissue class image (c*) in alignment with the original. 
#' @param dartel  Keep tissue class image (rc*) that can be used with the 
#' Dartel toolbox .
#' @param modulated Keep modulated images.  Modulation  is  to  compensate  
#' for  the  effect of spatial normalisation.  
#' @param unmodulated Keep unmodulated data
#' @param bias_field save a bias corrected version of your images
#' @param bias_corrected save an estimated bias field from  your images
#' @param n_gaus The number of Gaussians used to represent the 
#' intensity distribution for each tissue class.  Can be 1:8 or infinity
#' @param smoothness FWHM of smoothing done
#' @param sampling_distance smoothingess of the warping field. 
#' This is used to derive a fudge factor to account for 
#' correlations between neighbouring voxels.  Smoother data have more
#' @param regularization parameters for warping regularization
#' @param affine Space to register the image to, using an affine registration
#' @param def_inverse keep the inverse deformation field
#' @param def_forward keep the forward deformation field
#' @param warp_cleanup Level of cleanup with the warping.
#' If you find pieces of brain being chopped out in your data, 
#' then you may wish to disable or tone down the cleanup procedure. 
#' @param ... Arguments passed to \code{\link{run_spm12_script}}
#' @param mrf strength of the Markov random field. 
#' Setting the value to zero will disable the cleanup.
#' @param install_dir directory to download SPM12
#' 
#' @export
#' @return List of output files (or niftis depending on \code{retimg}),
#' output matrix, and output deformations.
#' @importFrom neurobase nii.stub
spm12_segment <- function(
  filename, 
  set_origin = TRUE,
  biasreg = 0.001,
  biasfwhm = 60,
  native = TRUE,
  dartel = FALSE,
  modulated = FALSE,
  unmodulated = FALSE,
  bias_field = FALSE,
  bias_corrected = FALSE,
  n_gaus = c(1, 1, 2, 3, 4, 2),
  smoothness = 0,
  sampling_distance = 3,
  regularization = c(0, 0.001, 0.5, 0.05, 0.2),
  affine = c("mni", "eastern", "subj", "none"),
  mrf = 1,
  def_inverse = TRUE,
  def_forward = TRUE,
  warp_cleanup = c("light", "none", "thorough"),
  retimg = TRUE,
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
  
  bias_field = as.integer(bias_field)
  bias_corrected = as.integer(bias_corrected)
  
  native = as.integer(native)
  dartel = as.integer(dartel)
  
  modulated = as.integer(modulated)
  unmodulated = as.integer(unmodulated)
  
  warp_cleanup = match.arg(warp_cleanup)
  warp_cleanup = factor(warp_cleanup, 
                        levels = c("none", "light", "thorough")
  )
  warp_cleanup = convert_to_matlab(warp_cleanup)
  
  affine = match.arg(affine)
  affine = convert_to_matlab(affine)
  
  def_inverse = as.integer(def_inverse)
  def_forward = as.integer(def_forward)
  
  class(regularization) = "rowvec"
  regularization = convert_to_matlab(regularization)
  
  if (set_origin) {
    res = acpc_reorient(infiles = filename, verbose = verbose)
    if (verbose) {
      message(paste0("# Result of acpc_reorient:", res, "\n"))
    }
  }
  
  stopifnot(length(n_gaus) == 6)
  n_gaus = as.character(n_gaus)
  
  # put in the correct filenames
  jobvec = c(
    filename, spmdir, 
    biasreg, biasfwhm, 
    n_gaus,
    bias_field, bias_corrected,
    native, dartel, 
    unmodulated, modulated,
    smoothness, sampling_distance,
    affine, def_inverse, def_forward,
    regularization, warp_cleanup,
    mrf)
  
  names(jobvec) = c(
    "%filename%", "%spmdir%", 
    "%biasreg%", "%biasfwhm%",
    paste0("%ngaus", 1:6, "%"),
    "%save_bf%", "%save_bc%",
    "%native%", "%dartel%",
    "%unmodulated%", "%modulated%", 
    "%fwhm%", "%samp%", 
    "%affreg%", "%def_inverse%", "%def_forward%", 
    "%reg%", "%warp_cleanup%",
    "%mrf%")
  
  tpm = file.path(spmdir, "tpm", "TPM.nii")
  tpm = convert_to_matlab(tpm)
  
  tissues = NULL
  for (i in 1:6) {
    tlist = list(
      tpm = paste0("{", tpm, ",", i, "}"),
      ngaus = n_gaus[i],
      native = paste0("[", native, " ", dartel, "]"),
      warped = paste0("[", unmodulated, " ", modulated, "]")
    )
    tissues = c(tissues, list(tlist))
  }
  class(tissues) = "unnumbered_list"
  attr(tissues, "mat_name") = "tissue"
  names(tissues) = paste0("tissue(", seq_along(tissues), ")")
  
  spm = list(
    spatial = list(
      preproc = list(
        channel = 
          list(
            biasreg = biasreg,
            biasfwhm = biasfwhm,
            write = paste0("[", bias_field, " ", bias_corrected, "];")
          ),
        tissue = tissues,
        warp = list(
          mrf = mrf,
          cleanup = warp_cleanup,
          reg = regularization,
          affreg = affine,
          fwhm = smoothness,
          samp = sampling_distance,
          write = paste0("[", def_inverse, " ", def_forward, "];")
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
  
  res = run_spm12_script( 
    script_name = "Segment",
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
  
  if (dartel) {
    dartel_outfiles = file.path(
      dirname(filename), 
      paste0("rc", 1:6, basename(filename)))
  } else {
    dartel_outfiles = NULL
  }
  
  if (unmodulated) {
    unmod_outfiles = file.path(
      dirname(filename), 
      paste0("wc", 1:6, basename(filename)))
  } else {
    unmod_outfiles = NULL
  }
  if (modulated) {
    mod_outfiles = file.path(
      dirname(filename), 
      paste0("mwc", 1:6, basename(filename))) 
  } else {
    mod_outfiles = NULL
  }
  
  
  out_mat = file.path(
    dirname(filename),
    paste0(  
      nii.stub(filename, bn = TRUE),
      "_seg8.mat"))
  if (def_forward) {
    out_def = file.path(
      dirname(filename),
      paste0(
        "y_",
        basename(filename)))
  } else {
    out_def = NULL
  }
  if (def_inverse) {
    inv_def = file.path(
      dirname(filename),
      paste0(
        "iy_",
        basename(filename)))
  } else {
    inv_def = NULL 
  }
  
  if (bias_corrected) {
    bc_outfile = file.path(
      dirname(filename),
      paste0(
        "m",
        basename(filename)))
  } else {
    bc_outfile = NULL
  }

  if (bias_field) {
    bf_outfile = file.path(
      dirname(filename),
      paste0(
        "BiasField_",
        basename(filename)))
  } else {
    bf_outfile = NULL
  }  

  L$result = res
  L$outfiles = outfiles
  
  L$outmat = out_mat
  L$deformation = out_def
  L$inverse_deformation = inv_def
  
  L$dartel = dartel_outfiles
  L$unmodulated = unmod_outfiles
  L$modulated = mod_outfiles
  L$bias_corrected = bc_outfile
  L$bias_field = bf_outfile
  
  if (retimg) {
    L$outfiles = check_nifti(outfiles, reorient = reorient)
  }
  
  return(L)
}


