#' @title SPM12 Slice Timing Correction
#'
#' @description Performs SPM12 slice timing correction on images
#' @param filename Files to be slice-time corrected
#' @param time_points Time points to run slice-time correction.  
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
#' @param install_dir directory to download SPM12
#' @param ... Arguments passed to \code{\link{run_spm12_script}}
#' @export
#' @importFrom oro.nifti readNIfTI
#' @importFrom matlabr rvec_to_matlab
#' @return Output filenames
spm12_slice_timing.deprecated <- function(
  filename,
  time_points = NULL,
  nslices,
  tr,
  ta = tr - tr/nslices,
  slice_order = 1:nslices,
  ref_slice,
  prefix = "a",
  add_spm_dir = TRUE,
  spmdir = spm_dir(verbose = verbose,
                   install_dir = NULL),
  clean = TRUE,
  verbose = TRUE,
  outdir = tempdir(),
  retimg = FALSE,
  reorient = FALSE,
  install_dir = NULL,
  ...
){
  install_spm12(verbose = verbose,
                install_dir = install_dir)

  ########################
  # Getting Number of Time points
  ########################
  if (is.null(time_points)) {
    if (verbose) {
      cat("# Getting Number of Time Points\n")
    }
    time_points = ntime_points(filename)
  }
  if (length(time_points) < 2) {
    stop("SPM Slice Timing Correction requires >= 2 images")
  }  

  # check filenames
  filename = filename_check(filename)

  # need to make anotehr directory, not in tempdir() to get around issue
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
  outfile = file.path(tdir,
                      paste0(prefix, base_name)
  )


  slice_order = rvec_to_matlab(slice_order, row = TRUE)
  filename = paste0(filename, ",", time_points)
  filename = rvec_to_matlabcell(filename)
  jobvec = c(filename, prefix, nslices,
             tr, ta, slice_order,
             ref_slice)
  names(jobvec) = c("%filename%", "%prefix%", "%nslices%",
                    "%tr%", "%ta%", "%sliceorder%",
                    "%refslice%")

  res = run_spm12_script( script_name = "Slice_Timing",
                          jobvec = jobvec,
                          mvec = NULL,
                          add_spm_dir = add_spm_dir,
                          spmdir = spmdir,
                          clean = clean,
                          verbose = verbose,
                          ...)
  stopifnot(res == 0)
  file.copy(outfile, to = outdir, overwrite = TRUE)

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
  return(outfile)
}


