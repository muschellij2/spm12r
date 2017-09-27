

# regressor_list = list(
#   name = NULL,
#   value = NULL
# )
# condition_list = list(
#   name = NULL,
#   onset = NULL, 
#   duration = NULL, 
#   time_mod_order = 0, 
#   param_mod = NULL, 
#   orth = TRUE
# )

#' SPM12 fMRI First Level Specification
#'
#' @param scans images to run
#' @param outdir output directory for results
#' @param slice_timed Were the image slice-time corrected
#' @param nslices If the data were slice-time corrected, the number of 
#' slices of the image
#' @param ref_slice If the data were slice-time corrected, the 
#' reference slice
#' @param units The onsets of events or blocks can be 
#' specified in either scans or seconds. 
#' @param tr The repetition time, in seconds
#' @param condition_mat multiple condition mat/txt file
#' @param condition_list List of conditions:
#' see \code{\link{spm12_condition}}.  This should be a list 
#' (or a list of lists) which have the items:
#' \code{name}, \code{onset}, \code{duration}, \code{time_mod_order},
#' \code{param_mod}, \code{orth}.  \code{name} does not need to be specified
#' if it is a named list of lists.
#' @param regressor_mat multiple regressor mat/txt file
#' @param regressor_list List of regressors:
#' see \code{\link{spm12_regressor}}.  This should be a list 
#' (or a list of lists) which have the items:
#' \code{name}, \code{value}, and \code{n_time_points}. 
#' \code{name} does not need to be specified
#' if it is a named list of lists.
#' @param hpf High pass filter, in seconds.
#' @param time_deriv time derivative. 
#' The time derivative allows the peak response to  vary  by  plus  
#' or  minus  a  second.
#' @param disp_deriv dispersion derivative, allows the width of 
#' the response to vary.
#' @param interactions Model interactions, 
#' Generalized convolution of inputs with basis set.
#' @param global_norm Global intensity normalisation
#' @param mthresh Masking threshold, defined as proportion of globals.
#' @param mask Specify an image for explicitly masking the analysis. 
#' @param correlation Serial correlations in fMRI time series
#' @param n_time_points Number of time points
#' @param verbose Print diagnostic messages
#' @param add_spm_dir Add SPM12 directory from this package
#' @param spmdir SPM dir to add, will use package default directory
#' @param clean Remove scripts from temporary directory after running
#' @param overwrite If a SPM.mat file exists in the outdir, 
#' should the file be removed?
#' @param ... Arguments passed to \code{\link{run_spm12_script}}
#' @return A list of objects, including an spm object and output files.
#' @export
#' @rdname spm12_first_level_spec
# #' @examples
build_spm12_first_level_spec = function(
  scans = NULL,
  outdir = NULL,
  units = c("scans", "secs"),
  slice_timed = TRUE,
  nslices = NULL,
  ref_slice = NULL,  
  tr,
  condition_mat = NULL,
  condition_list = NULL,
  regressor_mat = NULL,
  regressor_list = NULL,
  hpf = 128,
  time_deriv = FALSE,
  disp_deriv = FALSE, 
  interactions = FALSE,
  global_norm = c("None", "Scaling"),
  mthresh = 0.8,
  mask = NULL,
  correlation = c("AR(1)", "none", "FAST"),
  n_time_points = NULL,
  verbose = TRUE,
  overwrite = TRUE,
  ...
) {
  
  if (is.null(outdir)) {
    outdir = tempfile()
    dir.create(outdir, showWarnings = FALSE)
  }
  spm_mat = file.path(outdir, "SPM.mat")    
  if (file.exists(spm_mat)) {
    if (!overwrite) {
      stop(paste0(
        "SPM.mat exists in outdir specified, but ", 
           "overwrite = FALSE")
      )
    } else {
      file.remove(spm_mat)
    }
  }  
  
  ##################
  # Time units
  ##################  
  units = match.arg(units)
  units = convert_to_matlab(units)
  
  if (!is.null(scans)) {
    if (slice_timed) {
      if (is.null(nslices) || is.null(ref_slice)) {
        msg = paste0(
          "If the data is slice-time corrected, nslices and ",
          "ref_slice must be specified!")
        stop(msg)
      }
    } else {
      if (is.null(nslices)) {
        nslices = 16
      }
      if (is.null(ref_slice)) {
        nslices = 8
      }      
    }
    scans = filename_check(scans)
    if (is.null(n_time_points)) {
      time_points = ntime_points(scans)
      if (verbose) {
        message("# Getting Number of Time Points\n")
      }      
      n_time_points = length(time_points)
    } else {
      time_points = seq(n_time_points) 
    }
    
    filename = paste0(scans, ",", time_points)
    filename = rvec_to_matlabcell(
      filename, 
      transpose = FALSE,
      sep = "\n")
    # filename = sub(";$", "", filename)
    # filename = paste0("{", filename, "}';")  
  }
  
  ###################################
  # Model derivatives
  ###################################  
  time_deriv = as.numeric(time_deriv)
  disp_deriv = as.numeric(disp_deriv)
  derivatives = c(time_deriv, disp_deriv)
  class(derivatives) = "rowvec"
  derivatives = convert_to_matlab(derivatives)
  
  # true is 2, 1 is false
  interactions = as.logical(interactions)
  interactions = as.integer(interactions) + 1L
  
  #################################
  # Serial correlations
  #################################  
  correlation = match.arg(correlation)
  correlation = convert_to_matlab(correlation)
  
  #################################
  # Global Normalization
  #################################    
  global_norm = match.arg(global_norm)
  global_norm = convert_to_matlab(global_norm)
  
  #################################
  # Explicit mask
  #################################    
  if (!is.null(mask)) {
    mask = filename_check(mask)
    class(mask) = "cell"
    mask = rvec_to_matlabcell(mask, sep = "")
  } else {
    mask = rvec_to_matlabcell("", sep = "")
  }
  
  if ( (is.null(condition_mat) && is.null(condition_list))
       || (!is.null(condition_mat) && !is.null(condition_list)) )  {
    msg = paste0("Either condition_mat or condition_list", 
                 " must be specified, but not both!")
    stop(msg)
  }
  
  if ( (is.null(regressor_mat) && is.null(regressor_list))
       || (!is.null(regressor_mat) && !is.null(regressor_list)) )  {
    msg = paste0("Either regressor_mat or regressor_list", 
                 " must be specified, but not both!")
    stop(msg)
  }
  
  
  
  sess = list(
    scans = filename
  )
  
  if (!is.null(condition_mat)) {
    condition_mat = normalizePath(condition_mat)
    class(condition_mat) = "cell"
    condition_mat = convert_to_matlab(condition_mat, sep = "")
    sess$cond = paste0("struct('name', {}, 'onset', {},", 
                       " 'duration', {}, ", 
                       "'tmod', {}, 'pmod', {}, ", 
                       "'orth', {});")
    sess$multi = condition_mat
  } else {
    # if (length(condition_list) == 1) {
    #   condition_list = list(condition_list)
    # }
    condition_list = spm12_condition_list(condition_list)
    names(condition_list) = paste0("cond", names(condition_list))
    sess = c(sess, 
             condition_list)
    # sess$cond = condition_list
    sess$multi = "{''}"
  }
  
  if (!is.null(regressor_mat)) {
    regressor_mat = normalizePath(regressor_mat)
    class(regressor_mat) = "cell"
    regressor_mat = convert_to_matlab(regressor_mat, sep = "")
    sess$regress = paste0("struct('name', {}, 'val', {});")
    sess$multi_reg = regressor_mat
  } else {
    # if (length(regressor_list) == 1) {
    #   regressor_list = list(regressor_list)
    # }
    regressor_list = spm12_regressor_list(
      regressor_list, 
      n_time_points = n_time_points)
    names(regressor_list) = paste0("regress", names(regressor_list))
    sess = c(sess, 
             regressor_list)    
    # sess$regress = regressor_list
    sess$multi_reg = "{''}"
  }  
  
  xoutdir = outdir

  class(outdir) = "cell"
  outdir = convert_to_matlab(outdir)
  
  sess$hpf = hpf
  
  spm = list(
    stats = list(
      fmri_spec = list(
        dir = outdir,
        timing = list(
          units = units,
          RT = tr,
          fmri_t = nslices,
          fmri_t0 = ref_slice
        ),
        sess = sess,
        fact = "struct('name', {}, 'levels', {})",
        bases = list(
          hrf = list(
            derivs = derivatives
          )
        ),
        volt = interactions,
        global = global_norm,
        mthresh = mthresh,
        mask = mask,
        cvi = correlation
      )
    )
  )
  
  spm = list(spm = spm)
  class(spm) = "matlabbatch"
  
  script = matlabbatch_to_script(spm, ...)    
  
  L = list(
    spm = spm,
    script = script)
  L$outfile = L$spm_mat = spm_mat 
  
  L$outdir = xoutdir
  return(L)
  
}


#' @rdname spm12_first_level_spec
#' @export
spm12_first_level_spec = function(
  ...,   
  outdir = NULL,
  add_spm_dir = TRUE,
  spmdir = spm_dir(verbose = verbose),
  clean = TRUE,
  verbose = TRUE,
  overwrite = TRUE
){
  
  install_spm12(verbose = verbose)
  
  L = build_spm12_first_level_spec(
    outdir = outdir,
    verbose = verbose,
    ...)
  
  outdir = L$outdir
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