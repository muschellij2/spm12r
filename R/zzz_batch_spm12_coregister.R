#' @rdname spm12_coregister
#' @title Batch SPM12 Coregister (Estimate and Reslice)
#'
#' @description Performs SPM12 coregistration estimation and 
#' reslicing on an Image
#' 
#' @param fixed File that is assumed fixed
#' @param moving moving file to be registered to fixed space
#' @param other.files Other files to register to fixed, 
#' in same space as moving file
#' @param prefix Prefix to append to front of image filename
#' @param add_spm_dir Add SPM12 directory from this package
#' @param spmdir SPM dir to add, will use package default directory
#' @param clean Remove scripts from temporary directory after running
#' @param verbose Print diagnostic messages
#' @param outdir Directory to copy results.  If full filename 
#' given, then results will
#' be in \code{dirname(filename)}
#' 
#' @param cost_fun Cost function
#' @param separation The  average  distance  between  sampled 
#' points (in mm).  
#' Can be a vector to allow a coarse registration followed by 
#' increasingly fine
#' @param tol The  accuracy  for  each  parameter.    Iterations  
#' stop  when 
#'  differences  between  successive  estimates  are  less  than  
#'  the required
#' @param fwhm Gaussian  smoothing  to  apply  to  the 256x256 
#' joint histogram. 
#' Other information theoretic coregistration methods use fewer bins,
#' @param interp Interpolator for sampling in fixed space
#' @param wrap_x wrap in x-direction
#' @param wrap_y wrap in y-direction
#' @param wrap_z wrap in z-direction
#' @param mask Mask the data.  With masking enabled, 
#' the program searches 
#' through the whole time series looking for voxels which need to
#'  be sampled 
#' from outside  the  original  images.  Where  this  occurs, 
#'  that  voxel is set to zero for the whole set of images 
#' @param ... Additional arguments to pass to 
#' \code{\link{run_matlabbatch}}
#'
#' @return List of output files, the \code{matlabbatch} object, 
#' and the script
#' @export
#'
#' @examples \dontrun{
#' fname = paste0("~/Desktop/D2/scratch/", 
#' "100-318_20070723_0957_CT_3_CT_Head-_SS_0.01_SyN_ROI.nii.gz")
#' spm = spm12_coregister(
#' fixed = fname,
#' moving = fname, 
#' other.files = fname,
#' execute = FALSE)
#' }
#' dims = rep(10, 3)
#' fixed = array(rnorm(prod(dims)), dim = dims)
#' fixed = oro.nifti::nifti(fixed)
#' moving = array(rnorm(prod(dims)), dim = dims)
#' moving = oro.nifti::nifti(moving) 
#' res = build_spm12_coregister(
#' fixed = fixed, moving = moving)
#' if (matlabr::have_matlab()) {
#' run = spm12_coregister(
#'    fixed = fixed, moving = moving)
#' }
build_spm12_coregister <- function(
  fixed,
  moving,
  other.files = NULL,
  cost_fun = c("nmi", "ecc", "ncc"), # 
  separation = c(4, 2),
  tol = c(0.02, 0.02, 0.02, 0.001, 0.001, 0.001, 
          0.01, 0.01, 0.01, 0.001, 0.001, 0.001),
  fwhm = c(7, 7),
  # The  method  by  which  the  images  are  sampled  when  being  
  # written  in  a  different  space.  Nearest Neighbour is fastest, 
  # but not
  interp = c("bspline4", "nearestneighbor", "trilinear", 
             paste0("bspline", 2:3),
             paste0("bspline", 5:7)),  
  # c("nearestneighbor", "trilinear", paste0("bspline", 2:7)
  wrap_x = FALSE, #  c(0, 0, 0),
  wrap_y = FALSE, #  c(0, 0, 0),
  wrap_z = FALSE, #  c(0, 0, 0),
  mask = FALSE, # c(FALSE, TRUE) as.numeric
  prefix = "r",
  verbose = TRUE,
  ...
){  
  
  cost_fun = match.arg(cost_fun)
  cost_fun = convert_to_matlab(cost_fun)
  
  class(separation) = "rowvec"
  class(tol) = "rowvec"
  class(fwhm) = "rowvec"
  wrap = c(wrap_x, wrap_y, wrap_z)
  wrap = as.integer(wrap)
  class(wrap) = "rowvec"
  
  levs = c("nearestneighbor", "trilinear", paste0("bspline", 2:7))
  interp = interp[1]
  interp = match.arg(interp)
  interp = factor(interp, levels = levs)
  interp = convert_to_matlab(interp)
  
  separation = convert_to_matlab(separation)
  tol = convert_to_matlab(tol)
  fwhm = convert_to_matlab(fwhm)
  wrap = convert_to_matlab(wrap)
  
  
  # mask = !mask
  mask = as.numeric(mask)
  
  if (verbose) {
    message("Checking Filenames")
  }
  # check filenames
  fixed = filename_check(fixed)
  moving = filename_check(moving)
  omoving = file.path(
    dirname(moving),
    paste0(prefix, basename(moving)))
  
  class(fixed) = "cell"
  class(moving) = "cell"
  fixed = convert_to_matlab(fixed)
  moving = convert_to_matlab(moving)
  
  prefix = convert_to_matlab(prefix)
  
  if (is.null(other.files)) {
    other.files = "{''};"
    other.ofiles = NULL
    other = FALSE
  } else {
    other.files = filename_check(other.files)
    other.ofiles = file.path(
      dirname(other.files),
      paste0(prefix, basename(other.files)))
    other.files = rvec_to_matlabcell(other.files)
    other = TRUE
  }
  
  spm = list(
    spatial = list(
      coreg = list(
        estwrite = 
          list(
            ref = fixed,
            source = moving,
            other = other.files,
            eoptions = list(
              cost_fun = cost_fun,
              sep = separation,
              tol = tol,
              fwhm = fwhm
            ),
            roptions = list(
              interp = interp,
              wrap = wrap,
              mask = mask,
              prefix = prefix
            )
          )
      )
    )
  )  
  spm = list(spm = spm)
  class(spm) = "matlabbatch"
  
  script = matlabbatch_to_script(spm, ...)  
  
  L = list(
    spm = spm,
    script = script)
  L$outfile = omoving
  L$other.outfiles = other.ofiles
  return(L)
}


#' @rdname spm12_coregister
#' @export
build_spm12_coregister_estimate <- function(
  fixed,
  moving,
  other.files = NULL,
  cost_fun = c("nmi", "ecc", "ncc"), # 
  separation = c(4, 2),
  tol = c(0.02, 0.02, 0.02, 0.001, 0.001, 0.001, 
          0.01, 0.01, 0.01, 0.001, 0.001, 0.001),
  fwhm = c(7, 7),
  verbose = TRUE,
  ...
){  
  
  
  L = build_spm12_coregister(
    fixed = fixed,
    moving = moving, 
    other.files = other.files,
    cost_fun = cost_fun,
    separation = separation,
    tol = tol,
    fwhm = fwhm, 
    prefix = "",
    verbose = verbose,
    ...)
  spm = L$spm$spm
  
  
  coreg = spm$spatial$coreg
  ewrite = coreg$estwrite
  ewrite$roptions = NULL
  coreg$estwrite = NULL
  coreg$estimate = ewrite
  spm$spatial$coreg = coreg
  L$spm$spm = spm
  L$script = matlabbatch_to_script(L$spm, ...)  
  
  return(L)
  
}



#' @rdname spm12_coregister
#' @export
build_spm12_coregister_reslice <- function(
  fixed,
  moving,
  interp = c("bspline4", "nearestneighbor", "trilinear", 
             paste0("bspline", 2:3),
             paste0("bspline", 5:7)),  
  wrap_x = FALSE, #  c(0, 0, 0),
  wrap_y = FALSE, #  c(0, 0, 0),
  wrap_z = FALSE, #  c(0, 0, 0),
  mask = FALSE, # c(FALSE, TRUE) as.numeric
  prefix = "r",
  verbose = TRUE,
  ...
){  
  
  
  L = build_spm12_coregister(
    fixed = fixed,
    moving = moving, 
    interp = interp,
    wrap_x = wrap_x, #  c(0, 0, 0),
    wrap_y = wrap_y, #  c(0, 0, 0),
    wrap_z = wrap_z, #  c(0, 0, 0),
    mask = mask, # c(FALSE, TRUE) as.numeric
    prefix = prefix,
    add_spm_dir = add_spm_dir,
    verbose = verbose,
    ...)
  spm = L$spm$spm
  
  
  coreg = spm$spatial$coreg
  ewrite = coreg$estwrite
  ewrite$eoptions = NULL
  coreg$write = ewrite
  coreg$estwrite = NULL
  spm$spatial$coreg = coreg
  L$spm$spm = spm
  L$script = matlabbatch_to_script(L$spm, ...)  
  
  return(L)
  
}



#' @rdname spm12_coregister
spm12_coregister_wrapper = function(
  ...,
  func = c("build_spm12_coregister",
           "build_spm12_coregister_reslice",
           "build_spm12_coregister_estimate"),
  add_spm_dir = TRUE,
  spmdir = spm_dir(verbose = verbose),
  clean = TRUE,
  verbose = TRUE,
  outdir = NULL
) {
  install_spm12(verbose = verbose)
  func = match.arg(func)
  args = list(...)
  args$verbose = verbose
  L = do.call(func, args = args)
  
  spm = L$spm
  other.ofiles = L$other.outfiles
  other = !is.null(other.ofiles)
  omoving = L$outfile
  
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
  ####################
  # Copy outfiles
  ####################
  if (!is.null(outdir)) {
    file.copy(omoving, to = outdir, overwrite = TRUE)
    omoving = file.path(outdir, basename(omoving))
    if (other) {
      file.copy(other.ofiles, to = outdir, overwrite = TRUE)
      other.ofiles = file.path(
        outdir, 
        basename(other.ofiles))
    }
  }
  
  L$outfile = omoving
  L$other.outfiles = other.ofiles
  L$result = res    
  
  return(L)
}


#' @export
#' @rdname spm12_coregister
spm12_coregister = function(
  ...,
  add_spm_dir = TRUE,
  spmdir = spm_dir(verbose = verbose),
  clean = TRUE,
  verbose = TRUE,
  outdir = NULL
) {
  L = spm12_coregister_wrapper(
    ...,
    func = "build_spm12_coregister",
    add_spm_dir = add_spm_dir,
    spmdir = spmdir,
    clean = clean,
    verbose = verbose,
    outdir = outdir
  )
  return(L)
  
}


#' @export
#' @rdname spm12_coregister
spm12_coregister_estimate = function(
  ...,
  add_spm_dir = TRUE,
  spmdir = spm_dir(verbose = verbose),
  clean = TRUE,
  verbose = TRUE,
  outdir = NULL
) {
  L = spm12_coregister_wrapper(
    ...,
    func = "build_spm12_coregister_estimate",
    add_spm_dir = add_spm_dir,
    spmdir = spmdir,
    clean = clean,
    verbose = verbose,
    outdir = outdir
  )
  return(L)
  
}


#' @export
#' @rdname spm12_coregister
#' @param func not used
spm12_coregister_reslice = function(
  ...,
  add_spm_dir = TRUE,
  spmdir = spm_dir(verbose = verbose),
  clean = TRUE,
  verbose = TRUE,
  outdir = NULL
) {
  L = spm12_coregister_wrapper(
    ...,
    func = "build_spm12_coregister_reslice",
    add_spm_dir = add_spm_dir,
    spmdir = spmdir,
    clean = clean,
    verbose = verbose,
    outdir = outdir
  )
  return(L)
  
}