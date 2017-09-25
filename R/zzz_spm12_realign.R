#' @rdname spm12_realign
#' @title SPM12 Realign (Estimate and Reslice)
#'
#' @description Performs SPM12 realignment estimation 
#' and reslicing on an Image
#'
#' @param filename Files to be realigned and resliced
#' @param time_points A vector of time points to run realignment,
#' If \code{filename} is a
#' 4D file, then will do all the time points.  Otherwise, 
#' \code{filename} must be a character
#' vector of 3D files or a list of 3D nifti objects.
#' @param fwhm Full-Width Half Max to smooth.  Gaussian  
#' smoothing  
#' to  apply  to  the 256x256 joint histogram. 
#' @param register_to Should the files be registered to the 
#' first or the mean
#' @param reslice Options for reslicing all - all 
#' images in filename,
#' 2:n - all images in filename 2:length(filename),
#' all+mean - all images and the mean, mean - mean only
#' @param prefix Prefix to append to front of image filename
#' @param add_spm_dir Add SPM12 directory from this package
#' @param spmdir SPM dir to add, will use package default directory
#' @param clean Remove scripts from temporary directory 
#' after running
#' @param verbose Print diagnostic messages
#' @param outdir Directory to copy results.  
#' If full filename given, then results will
#' be in \code{dirname(filename)}
#' @param quality Quality versus speed trade-off.  
#' Highest quality (1) gives most precise results, 
#' whereas lower qualities gives faster realignment.
#' @param separation The  average  distance  between 
#'  sampled points (in mm).  
#' Can be a vector to allow a coarse registration 
#' followed by increasingly fine
#' @param wrap_x wrap in x-direction
#' @param wrap_y wrap in y-direction
#' @param wrap_z wrap in z-direction
#' @param mask Mask the data.  With masking enabled, the 
#' program searches 
#' through the whole time series looking for voxels which 
#' need to be sampled 
#' from outside  the  original  images.  Where  this  occurs, 
#'  that  voxel is set to zero for the whole set of images  
#' @param est_interp Interpolator for estimation
#' @param weight_image weighting image to weight each 
#' voxel of the reference 
#' image during estimation. The weights are proportional to the 
#' inverses of the standard deviations. May be used when there is
#' a lot of motion.
#' @param reslice_interp Interpolator for reslicing
#' @param ... Arguments passed to \code{\link{run_spm12_script}}
#'
#' @export
#' @return List of output files, the \code{matlabbatch} object, 
#' and the script
#' 
#' @examples 
#' dims = rep(10, 4)
#' temp_nii = array(rnorm(prod(dims)), dim = dims)
#' temp_nii = oro.nifti::nifti(temp_nii)
#' res = build_spm12_realign(temp_nii)
#' 
build_spm12_realign <- function(
  filename,
  time_points = NULL,  
  fwhm = 5,
  quality = 0.9,
  separation = 4,
  register_to = c("first", "mean"),
  est_interp = c(
    "bspline2", "trilinear", 
    paste0("bspline", 3:7)
  ),
  wrap_x = FALSE, 
  wrap_y = FALSE, 
  wrap_z = FALSE, 
  weight_image = NULL,
  reslice = c("all+mean", 
              "all","2:n",  
              "mean"),  
  reslice_interp = c(
    "bspline4", "nearestneighbor", "trilinear", 
    paste0("bspline", 2:3),
    paste0("bspline", 5:7),
    "fourier"),
  mask = FALSE, 
  prefix = "r",
  verbose = TRUE,
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
  
  wrap = c(wrap_x, wrap_y, wrap_z)
  wrap = as.integer(wrap)
  class(wrap) = "rowvec"
  wrap = convert_to_matlab(wrap, sep = "")  
    
  # check filenames
  filename = filename_check(filename)
  stub = nii.stub(filename, bn = TRUE)[1]
  dn = dirname(filename)
  bn = basename(filename)
  xfn = filename
  
  rpfile = file.path(
    dn,
    paste0("rp_", stub, ".txt"))
  meanfile = file.path(
    dn,
    paste0("mean", stub, ".nii"))
  matfile = file.path(
    dn,
    paste0(stub, ".mat"))
  
  ##########################################################
  # Pasting together for a 4D file
  ##########################################################
  filename = paste0(filename, ",", time_points)
  filename = rvec_to_matlabcell(filename, 
                                transpose = FALSE,
                                sep = "\n")
  filename = sub(";$", "", filename)
  filename = paste0("{", filename, "}';")
  
  ###################
  # If reslice is just mean, then the file is simply returned
  ###################
  reslice = match.arg(reslice)
  if (verbose) {
    message(paste0("# Reslice is ", reslice, "\n"))
  }
  if ( reslice %in% "mean" ) {
    outfile = xfn
  } else {
    outfile = file.path(
      dn,
      paste0(prefix, bn))
  }
  reslice = switch(
    reslice,
    "all" = "[2 0]",
    "2:n" = "[1 0]",
    "all+mean" = "[2 1]",
    "mean" = "[0 1]")  
  
  ###########################
  # weight image
  ###########################  
  if (!is.null(weight_image)) {
    weight_image = filename_check(weight_image)
  } else {
    weight_image = ""  
  }
  weight_image = convert_to_matlab(weight_image)
  
  ###########################
  # interpolations
  ###########################  
  est_interp = match.arg(est_interp)
  est_interp = factor(
    est_interp,
    levels = c(
      "trilinear", 
      paste0("bspline", 2:7)
    ))
  est_interp = convert_to_matlab(est_interp,
                                 subtractor = 0)
  
  reslice_interp = match.arg(reslice_interp)
  reslice_interp = factor(
    reslice_interp,
    levels = c(
      "nearestneighbor", "trilinear", 
      paste0("bspline", 2:7), 
      "fourier")
  )
  reslice_interp = convert_to_matlab(reslice_interp)
  
  mask = as.integer(mask)
  prefix = convert_to_matlab(prefix)
  
  ###########################
  # register to which scan
  ###########################  
  register_to = match.arg(register_to)
  register_to = switch(
    register_to,
    first = 0,
    mean = 1)
  
  spm = list(
    spatial = list(
      realign = list(
        estwrite = 
          list(
            data = filename,
            eoptions = list(
              quality = quality,
              sep = separation,
              fwhm = fwhm,
              rtm = register_to,
              interp = est_interp,
              wrap = wrap,
              weight = weight_image
            ),
            roptions = list(
              which = reslice,
              interp = reslice_interp,
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
  L$outfiles = outfile
  L$rp = rpfile
  L$mean = meanfile
  L$mat = matfile
  
  return(L)
}

#' @export
#' @rdname spm12_realign
#' @param retimg (logical) return image of class nifti
#' @param reorient (logical) If retimg, should file be 
#' reoriented when read in? 
spm12_realign = function(
  ...,
  add_spm_dir = TRUE,
  spmdir = spm_dir(verbose = verbose),
  clean = TRUE,
  retimg = FALSE,
  reorient = FALSE,  
  verbose = TRUE,
  outdir = NULL
) {
  install_spm12(verbose = verbose)
  L = build_spm12_realign(verbose = verbose, ...)
  spm = L$spm
  outfile = L$outfile 
  rpfile = L$rp 
  meanfile = L$mean
  matfile = L$mat 
  if (verbose) {
    message("# Running matlabbatch job")
  }
  res = run_matlabbatch(
    spm, 
    add_spm_dir = add_spm_dir, 
    clean = clean,
    verbose = verbose,
    spmdir = spmdir)
  L$result = res    
  
  if (res != 0) {
    warning("Result was not zero!")
  }
  
  ####################
  # Copy outfiles
  ####################
  if (!is.null(outdir)) {
    file.copy(outfile, to = outdir, overwrite = TRUE)
    file.copy(rpfile, to = outdir, overwrite = TRUE)
    if (!is.null(meanfile)) {
      file.copy(meanfile, to = outdir, overwrite = TRUE)
    }
    file.copy(matfile, to = outdir, overwrite = TRUE)
    
    outfile = file.path(outdir, basename(outfile))
    rpfile = file.path(outdir, basename(rpfile))
    meanfile = file.path(outdir, basename(meanfile))
    matfile = file.path(outdir, basename(matfile))
    
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
  
  L$outfiles = outfile
  L$rp = rpfile
  L$mean = meanfile
  L$mat = matfile  
  return(L)
}
