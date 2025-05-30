% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/zzz_spm12_realign.R
\name{build_spm12_realign}
\alias{build_spm12_realign}
\alias{spm12_realign}
\title{SPM12 Realign (Estimate and Reslice)}
\usage{
build_spm12_realign(
  filename,
  time_points = NULL,
  fwhm = 5,
  quality = 0.9,
  separation = 4,
  register_to = c("first", "mean"),
  est_interp = c("bspline2", "trilinear", paste0("bspline", 3:7)),
  wrap_x = FALSE,
  wrap_y = FALSE,
  wrap_z = FALSE,
  weight_image = NULL,
  reslice = c("all+mean", "all", "2:n", "mean"),
  reslice_interp = c("bspline4", "nearestneighbor", "trilinear", paste0("bspline", 2:3),
    paste0("bspline", 5:7), "fourier"),
  mask = FALSE,
  prefix = "r",
  verbose = TRUE,
  ...
)

spm12_realign(
  ...,
  add_spm_dir = TRUE,
  spmdir = spm_dir(verbose = verbose, install_dir = install_dir),
  clean = TRUE,
  retimg = FALSE,
  reorient = FALSE,
  verbose = TRUE,
  outdir = NULL,
  install_dir = NULL
)
}
\arguments{
\item{filename}{Files to be realigned and resliced}

\item{time_points}{A vector of time points to run realignment,
If \code{filename} is a
4D file, then will do all the time points.  Otherwise, 
\code{filename} must be a character
vector of 3D files or a list of 3D nifti objects.}

\item{fwhm}{Full-Width Half Max to smooth.  Gaussian
smoothing  
to  apply  to  the 256x256 joint histogram.}

\item{quality}{Quality versus speed trade-off.
Highest quality (1) gives most precise results, 
whereas lower qualities gives faster realignment.}

\item{separation}{The  average  distance  between 
 sampled points (in mm).  
Can be a vector to allow a coarse registration 
followed by increasingly fine}

\item{register_to}{Should the files be registered to the 
first or the mean}

\item{est_interp}{Interpolator for estimation}

\item{wrap_x}{wrap in x-direction}

\item{wrap_y}{wrap in y-direction}

\item{wrap_z}{wrap in z-direction}

\item{weight_image}{weighting image to weight each 
voxel of the reference 
image during estimation. The weights are proportional to the 
inverses of the standard deviations. May be used when there is
a lot of motion.}

\item{reslice}{Options for reslicing all - all 
images in filename,
2:n - all images in filename 2:length(filename),
all+mean - all images and the mean, mean - mean only}

\item{reslice_interp}{Interpolator for reslicing}

\item{mask}{Mask the data.  With masking enabled, the 
program searches 
through the whole time series looking for voxels which 
need to be sampled 
from outside  the  original  images.  Where  this  occurs, 
 that  voxel is set to zero for the whole set of images}

\item{prefix}{Prefix to append to front of image filename}

\item{verbose}{Print diagnostic messages}

\item{...}{Arguments passed to \code{\link{run_spm12_script}}}

\item{add_spm_dir}{Add SPM12 directory from this package}

\item{spmdir}{SPM dir to add, will use package default directory}

\item{clean}{Remove scripts from temporary directory 
after running}

\item{retimg}{(logical) return image of class nifti}

\item{reorient}{(logical) If retimg, should file be 
reoriented when read in?}

\item{outdir}{Directory to copy results.
If full filename given, then results will
be in \code{dirname(filename)}}

\item{install_dir}{directory to download SPM12}
}
\value{
List of output files, the \code{matlabbatch} object, 
and the script
}
\description{
Performs SPM12 realignment estimation 
and reslicing on an Image
}
\examples{
dims = rep(10, 4)
temp_nii = array(rnorm(prod(dims)), dim = dims)
temp_nii = oro.nifti::nifti(temp_nii)
res = build_spm12_realign(temp_nii)

}
