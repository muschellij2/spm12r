#' SPM12 fMRI First Level Model
#'
#' @param outdir output directory for results
#' @param est_args Arguments passed to 
#' \code{\link{build_spm12_fmri_est}}
#' @param verbose Print diagnostic messages
#' @param add_spm_dir Add SPM12 directory from this package
#' @param spmdir SPM dir to add, will use package default directory
#' @param clean Remove scripts from temporary directory 
#' after running
#' @param ... Arguments passed to 
#' \code{\link{build_spm12_first_level_spec}}
#' @return A list of objects, including an spm object 
#' and output files.
#' @export
#' @rdname spm12_first_level
# #' @examples
build_spm12_first_level = function(
  ...,
  outdir = NULL,
  est_args = list(  
    write_residuals = FALSE,
    method  = "Classical",
    bayesian = NULL),
  verbose = TRUE
) {
  
  spec_out = build_spm12_first_level_spec(
    verbose = TRUE,
    outdir = outdir,
    ...
  )
  spm_mat = spec_out$spm_mat
  spm = spec_out$spm
  
  
  est_args$spm = spm_mat
  
  est_out = do.call(
    "build_spm12_fmri_est", 
    args = est_args)
  
  
  out_spm = list(spm,
           est_out$spm)
  names(out_spm) = c("{1}", "{2}")
  class(out_spm) = "matlabbatch"
  
  script = matlabbatch_to_script(
    out_spm, 
    batch_prefix = "matlabbatch")      
  
  L = list(
    spm = out_spm,
    script = script
  )
  L$spmmat = spm_mat
  L$outdir = spec_out$outdir
  
  return(L)
}

#' @export
#' @rdname spm12_first_level
spm12_first_level = function(
  ...,
  outdir = NULL,
  est_args = list(  
    write_residuals = FALSE,
    method  = "Classical",
    bayesian = NULL),
  add_spm_dir = TRUE,
  spmdir = spm_dir(verbose = verbose),
  clean = TRUE,
  verbose = TRUE
) {
  
  if (is.null(outdir)) {
    outdir = tempfile()
    dir.create(outdir, showWarnings = FALSE)
  }
  
  L = build_spm12_first_level(
    ...,
    outdir = outdir,
    est_args = est_args,
    verbose = verbose) 
  spm = L$spm
  
  if (verbose) {
    message("# Running matlabbatch job")
  }
  res = run_matlabbatch(
    spm, 
    add_spm_dir = add_spm_dir, 
    clean = clean,
    verbose = verbose,
    spmdir = spmdir, 
    batch_prefix = "matlabbatch")
  L$result = res    
  
  if (res != 0) {
    warning("Result was not zero!")
  }
  
  outfiles = list.files(
    pattern = "beta_.*[.]nii$",
    path = outdir,
    full.names = TRUE
  )
  L$outfiles = outfiles
  
  return(L)
  
}

