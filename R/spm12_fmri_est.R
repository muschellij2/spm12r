
#' SPM12 FMRI Estimation
#'
#' @param spm Path to SPM.mat file
#' @param write_residuals Should residuals be written?
#' @param method Method for model estimation
#' @param bayesian If method = "Bayesian", this is for a 1st level
#' model Bayesian estimation and this list specifies the 
#' parameters
#' @param ... Arguments passed to 
#' \code{\link{matlabbatch_to_script}}
#' @param add_spm_dir Add SPM12 directory from this package
#' @param spmdir SPM dir to add, will use package default directory
#' @param clean Remove scripts from temporary directory after running
#' @param verbose Print diagnostic messages
#' @param install_dir directory to download SPM12
#'
#' @return A list of output and results
#' @export
spm12_fmri_est = function(
  ...,
  add_spm_dir = TRUE,
  spmdir = spm_dir(verbose = verbose),
  clean = TRUE,
  verbose = TRUE,
  install_dir = NULL
) {
  install_spm12(verbose = verbose,
                install_dir = install_dir)
  L = build_spm12_fmri_est(...)
  
  spm = L$spm
  
  if (verbose) {
    message("# Running matlabbatch job")
  }  
  res = run_matlabbatch(
    spm, 
    add_spm_dir = add_spm_dir, 
    clean = clean,
    verbose = verbose,
    spmdir = spmdir) 
  
  if (res != 0) {
    warning("Result was not zero!")
  }
  
  
  # outfiles = list.files(
  #   pattern = "con.*",
  #   path = outdir,
  #   full.names = TRUE
  # )
  # L$outfiles = outfiles
  
  
  # L$outfiles = outfiles
  L$result = res  
  return(L)
  
}
  
#' @rdname spm12_fmri_est
#' @export
build_spm12_fmri_est = function(
  spm,
  write_residuals = FALSE,
  method  = c("Classical", "Bayesian", "Bayesian2"),
  bayesian = list(
    space.volume.block_type = "Slices",
    signal = "UGL",
    ARP = 3,
    noise.UGL = 1,
    LogEv = "No",
    anova.first = "No",
    anova.second = "Yes",
    gcon = list(
      name = "",
      convec = numeric(0)
    )
  ),
  ...
  ) {
  
  write_residuals = as.integer(write_residuals)
  method = match.arg(method)
  
  spmmat = normalizePath(spm)
  xspmmat = spmmat
  class(spmmat) = "cell"
  spmmat = convert_to_matlab(spmmat)

  spm = list(
    stats = list(
      fmri_est = list(
        spmmat = spmmat,
        write_residuals = write_residuals
      )
    )
  )
  
  if (method == "Classical" ) {
    spm$stats$fmri_est$method$Classical = 1
  }

  if (method == "Bayesian" ) {
    bayesian$space.volume.block_type = 
      convert_to_matlab(
        bayesian$space.volume.block_type)
    bayesian$signal = convert_to_matlab(bayesian$signal)
    bayesian$LogEv = convert_to_matlab(bayesian$LogEv)
    bayesian$anova.first = convert_to_matlab(bayesian$anova.first)
    bayesian$anova.second = convert_to_matlab(bayesian$anova.second)
    bayesian$gcon$name = convert_to_matlab(bayesian$gcon$name)
    class(bayesian$gcon$convec) = "rowvec"
    bayesian$gcon$convec = convert_to_matlab(bayesian$gcon$convec)
    spm$stats$fmri_est$method$Bayesian = bayesian
  }
  
  if (method == "Bayesian2" ) {
    spm$stats$fmri_est$method$Bayesian2 = 1
  }  
  
  spm = list(spm = spm)
  class(spm) = "matlabbatch"
  
  script = matlabbatch_to_script(spm, ...)  
  
  L = list(
    spm = spm,
    script = script)

  L$spmmat = xspmmat
  
  return(L)    

}

