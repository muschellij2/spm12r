#' SPM12 Results Report
#'
#' @param spm Path to SPM.mat file
#' @param ... Arguments passed to 
#' \code{\link{matlabbatch_to_script}}
#' @param add_spm_dir Add SPM12 directory from this package
#' @param spmdir SPM dir to add, will use package default directory
#' @param clean Remove scripts from temporary directory after running
#' @param verbose Print diagnostic messages
#' @param display Run \code{\link{run_matlab_script}} with
#' the \code{display} option on, which is required in some
#' cases of output.  May fail
#' if no displays are available.
#' @param desktop Run \code{\link{run_matlab_script}} with
#' the \code{desktop} option on.  May fail
#' if no displays are available. 
#' @param install_dir directory to download SPM12
#' 
#'
#' @return A list of output and results
#' @export
spm12_results = function(
  ...,
  add_spm_dir = TRUE,
  spmdir = spm_dir(verbose = verbose,
                   install_dir = install_dir),
  clean = TRUE,
  verbose = TRUE,
  display = FALSE,
  desktop = FALSE,
  install_dir = NULL) {
  install_spm12(verbose = verbose,
                install_dir = install_dir)
  args = list(...)
  L = do.call("build_spm12_results", args = args)
  
  spm = L$spm
  
  if (verbose) {
    message("# Running matlabbatch job")
  }  
  if (args$result_format %in% c("csv", "xls")) {
    if (!display) {
      warning("CSV and xls may require display = TRUE")
    }
  }
  gui = args$result_format %in% c("ps", "eps", "png",
    "pdf", "jpg", "tif", "fig")
  
  if (L$write_images != "none") {
    if (!display) {
      warning("Writing Images may require display = TRUE")
    }
    if (!desktop) {
      warning("Writing Images may require desktop = TRUE")
    }    
  }  
  # L$write_images = NULL
  
  res = run_matlabbatch(
    spm, 
    add_spm_dir = add_spm_dir, 
    clean = clean,
    verbose = verbose,
    spmdir = spmdir,
    display = display,
    desktop = desktop,
    gui = gui)
  
  if (res != 0) {
    warning("Result was not zero!")
  }
  
  L$result = res  
  return(L)
  
}


#' @param units Units of the data
#' @param result_format Output format to save, if any
#' @param write_images Type of images to write out
#' @param contrast_list List of contrasts (or just one),
#' to pass to \code{\link{spm12_contrast_query_list}}
#' @param image_basename Base stub of filenames, if 
#' any are to be written out
#'
#' @rdname spm12_results
#' @export
build_spm12_results = function(
  spm,
  units = c("Volumetric", "Scalp-Time", 
            "Scalp-Frequency", "Time-Frequency", 
            "Frequency-Frequency"),
  result_format = c("none", "ps", "eps", "png",
                    "pdf", "jpg", "tif",
                    "fig", "csv", "nidm"),
  write_images = c("none", "threshold_spm", 
                   "binary_clusters", "nary_clusters"),  
  contrast_list = NULL,
  image_basename = NULL,
  ...
) {
  
  
  units = match.arg(units)
  
  unit_levs = c("Volumetric", "Scalp-Time", "Scalp-Frequency", 
                "Time-Frequency", "Frequency-Frequency")  
  units = factor(units, levels = unit_levs)
  units = convert_to_matlab(units, subtractor = 0)
  
  # if (length(contrast_list) == 1) {
  #   contrast_list = list(contrast_list)
  # }
  contrast_list = spm12_contrast_query_list(contrast_list)
  
  spmmat = normalizePath(spm)
  xspmmat = spmmat
  class(spmmat) = "cell"
  spmmat = convert_to_matlab(spmmat)
  
  
  ###########################
  # output printout
  ###########################
  result_format = match.arg(result_format)
  if (result_format == "none") {
    result_format = "false"
  } else {
    result_format = convert_to_matlab(result_format)
  }
  
  ###########################
  # output images
  ###########################
  write_images = match.arg(write_images)
  if (write_images != "none") {
    if (is.null(image_basename)) {
      stop(paste0(
        "If write_images != none, then image_basename ",
        "must be specified")
      )
    } else {
      image_basename = convert_to_matlab(image_basename)
    }
    l_name = switch(
      write_images,
      threshold_spm = "tspm",
      binary_clusters = "binary", 
      nary_clusters = "nary")
    write = list(
      basename = image_basename
    )
    write = list(write)
    names(write) = l_name
  } else {
    write = list(
      none = 1
    )
  }
  
  names(contrast_list) = paste0("conspec", names(contrast_list))
  
  spm = list(
    stats = list(
      results = list(
        spmmat = spmmat,
        contrast_list,
        units = units,
        print = result_format,
        write = write        
      )
    )
  )
  
  spm = list(spm = spm)
  class(spm) = "matlabbatch"
  
  script = matlabbatch_to_script(spm, ...)  
  
  L = list(
    spm = spm,
    script = script)
  
  L$write_images = write_images
  L$spmmat = xspmmat
  
  return(L) 
  
}



