#' @title SPM12 Slice Timing Correction
#'
#' @description Performs SPM12 slice timing correction on images
#' @param filename Files to be slice-time corrected
#' @param time_points A vector of time points to run 
#' slice-time correction.  
#' If \code{filename} is a
#' 4D file, then will do all the time points.  Otherwise, 
#' \code{filename} must be a character
#' vector of 3D files or a list of 3D nifti objects.
#' @param nslices Number of slices in the images
#' @param tr Repetition time (in seconds)
#' @param ta Time between the first and the last slice 
#' within one scan
#' @param slice_order Order slices were taken (if not specified, 
#' assumed ascending),
#' bottom slice = 1
#' @param ref_slice Reference slice
#' @param prefix Prefix to append to front of image filename
#' @param add_spm_dir Add SPM12 directory from this package
#' @param spmdir SPM dir to add, will use package default directory
#' @param clean Remove scripts from temporary directory 
#' after running
#' @param verbose Print diagnostic messages
#' @param outdir Directory to copy results
#' @param retimg (logical) return image of class nifti
#' @param reorient (logical) If retimg, should file be 
#' reoriented when read in?
#' Passed to \code{\link{readNIfTI}}.
#' @param ... Arguments passed to \code{\link{run_spm12_script}}
#' @export
#' @importFrom oro.nifti readNIfTI
#' @importFrom matlabr rvec_to_matlab
#' @return List of results, the SPM job, the script and the outfile
#' 
spm12_slice_timing <- function(
  filename,
  time_points = NULL,
  nslices,
  tr,
  ta = tr - tr/nslices,
  slice_order = 1:nslices,
  ref_slice,
  prefix = "a",
  add_spm_dir = TRUE,
  spmdir = spm_dir(verbose = verbose),
  clean = TRUE,
  verbose = TRUE,
  outdir = tempdir(),
  retimg = FALSE,
  reorient = FALSE,
  ...
){
  install_spm12(verbose = verbose)
  
  L = build_spm12_slice_timing(
    filename = filename,
    time_points = time_points,
    nslices = nslices,
    tr = tr,
    ta = ta,
    slice_order = slice_order,
    ref_slice = ref_slice,
    prefix = prefix,
    add_spm_dir = add_spm_dir,
    spmdir = spmdir,
    clean = clean,
    verbose = verbose,
    outdir = outdir,
    ...
  )
  
  # orig_filename = L$orig_filename 
  # base_name = L$base_name 
  # tdir = L$temporary_directory
  outfile = L$outfile
  
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
    ...) 
  
  if (res != 0) {
    warning("Result was not zero!")
  }
  file.copy(outfile, to = outdir, overwrite = TRUE)
  
  outfile = file.path(outdir, basename(outfile))
  if (!file.exists(outfile)) {
    warning(paste0("Output file of slice timing", 
                   " does not exist!  May be an error")
    )
  }
  #############################
  # Returning Image
  #############################
  if (retimg) {
    if (length(outfile) > 1) {
      outfile = lapply(outfile, readNIfTI, reorient = reorient)
    } else {
      outfile = readNIfTI(outfile, reorient = reorient)
    }
  }
  L$outfile = outfile
  L$result = res      
  return(L)
}

#' @rdname spm12_slice_timing
#' @export
build_spm12_slice_timing <- function(
  filename,
  time_points = NULL,
  nslices,
  tr,
  ta = tr - tr/nslices,
  slice_order = 1:nslices,
  ref_slice,
  prefix = "a",
  add_spm_dir = TRUE,
  spmdir = spm_dir(),
  clean = TRUE,
  verbose = TRUE,
  outdir = tempdir(),
  ...
){
  
  ########################
  # Getting Number of Time points
  ########################
  if (is.null(time_points)) {
    if (verbose) {
      message("# Getting Number of Time Points\n")
    }
    time_points = ntime_points(filename)
  }
  
  if (length(time_points) < 2) {
    stop("SPM Slice Timing Correction requires >= 2 images")
  }
  
  # check filenames
  filename = filename_check(filename)
  
  # need to make another directory, not in tempdir() to get around issue
  # of double copy
  orig_filename = filename
  base_name = basename(filename)
  
  #########################
  # Nested tempfile
  #########################
  tdir = tempfile()
  dir.create(tdir, showWarnings =  FALSE)
  file.copy(from = orig_filename, to = tdir, overwrite = TRUE)
  filename = file.path(tdir, base_name)
  outfile = file.path(
    tdir,
    paste0(prefix, base_name)
  )

  
  slice_order = rvec_to_matlab(slice_order, row = TRUE)
  
  filename = paste0(filename, ",", time_points)
  filename = rvec_to_matlabcell(
    filename, 
    transpose = FALSE,
    sep = "\n")
  filename = sub(";$", "", filename)
  filename = paste0("{", filename, "}';")  
  
  # Change nothign in the jobvec after here
  #########################################
  prefix = convert_to_matlab(prefix)
  
  spm = list(
    temporal = list(
      st = list(
        scans = filename,
        nslices = nslices,
        tr = tr,
        ta = ta,
        so = slice_order,
        refslice = ref_slice,
        prefix = prefix
      )
    )
  )
  
  spm = list(spm = spm)
  class(spm) = "matlabbatch"
  
  script = matlabbatch_to_script(spm)    
  
  L = list(
    spm = spm,
    script = script)
  L$orig_filename = orig_filename
  L$base_name = base_name
  L$temporary_directory = tdir
  L$outfile = outfile
  
  return(L)
}





