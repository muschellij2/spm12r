#' SPM12 fMRI Contrasts
#'
#' @param spm Path to SPM.mat file
#' @param ... Arguments passed to 
#' \code{\link{matlabbatch_to_script}}
#' @param add_spm_dir Add SPM12 directory from this package
#' @param spmdir SPM dir to add, will use package default directory
#' @param clean Remove scripts from temporary directory after running
#' @param verbose Print diagnostic messages
#' @param delete_existing Delete existing contrasts
#' @param contrast_list List of contrasts to pass to 
#' \code{\link{spm12_contrast_list}} for conversion
#' @param install_dir directory to download SPM12
#'
#' @return A list of output and results
#' @export
spm12_contrast_manager = function(
  ...,
  add_spm_dir = TRUE,
  spmdir = spm_dir(verbose = verbose),
  clean = TRUE,
  verbose = TRUE,
  install_dir = NULL
) {
  install_spm12(verbose = verbose,
                install_dir = install_dir)
  L = build_spm12_contrast_manager(...)
  
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
  
  L$result = res  
  return(L)
  
}

#' @rdname spm12_contrast_manager
#' @export
build_spm12_contrast_manager = function(
  spm,
  delete_existing = TRUE,
  contrast_list = NULL,
  ...
) {
  
  # if (length(contrast_list) == 1) {
  #   contrast_list = list(contrast_list)
  # }
  contrast_list = spm12_contrast_list(contrast_list)
  delete_existing = as.integer(delete_existing)
  
  spmmat = normalizePath(spm)
  xspmmat = spmmat
  class(spmmat) = "cell"
  spmmat = convert_to_matlab(spmmat)
  
  names(contrast_list) = paste0("consess", names(contrast_list))
  
  spm = list(
    stats = list(
      con = list(
        spmmat = spmmat,
        contrast_list,
        delete = delete_existing
      )
    )
  )
  
  spm = list(spm = spm)
  class(spm) = "matlabbatch"
  
  script = matlabbatch_to_script(spm, ...)  
  
  L = list(
    spm = spm,
    script = script)
  
  L$spmmat = xspmmat
  
  return(L) 
  
}



