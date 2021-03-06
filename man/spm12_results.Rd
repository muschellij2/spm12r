% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/spm12_results.R
\name{spm12_results}
\alias{spm12_results}
\alias{build_spm12_results}
\title{SPM12 Results Report}
\usage{
spm12_results(
  ...,
  add_spm_dir = TRUE,
  spmdir = spm_dir(verbose = verbose, install_dir = install_dir),
  clean = TRUE,
  verbose = TRUE,
  display = FALSE,
  desktop = FALSE,
  install_dir = NULL
)

build_spm12_results(
  spm,
  units = c("Volumetric", "Scalp-Time", "Scalp-Frequency", "Time-Frequency",
    "Frequency-Frequency"),
  result_format = c("none", "ps", "eps", "png", "pdf", "jpg", "tif", "fig", "csv",
    "nidm"),
  write_images = c("none", "threshold_spm", "binary_clusters", "nary_clusters"),
  contrast_list = NULL,
  image_basename = NULL,
  ...
)
}
\arguments{
\item{...}{Arguments passed to 
\code{\link{matlabbatch_to_script}}}

\item{add_spm_dir}{Add SPM12 directory from this package}

\item{spmdir}{SPM dir to add, will use package default directory}

\item{clean}{Remove scripts from temporary directory after running}

\item{verbose}{Print diagnostic messages}

\item{display}{Run \code{\link{run_matlab_script}} with
the \code{display} option on, which is required in some
cases of output.  May fail
if no displays are available.}

\item{desktop}{Run \code{\link{run_matlab_script}} with
the \code{desktop} option on.  May fail
if no displays are available.}

\item{install_dir}{directory to download SPM12}

\item{spm}{Path to SPM.mat file}

\item{units}{Units of the data}

\item{result_format}{Output format to save, if any}

\item{write_images}{Type of images to write out}

\item{contrast_list}{List of contrasts (or just one),
to pass to \code{\link{spm12_contrast_query_list}}}

\item{image_basename}{Base stub of filenames, if 
any are to be written out}
}
\value{
A list of output and results
}
\description{
SPM12 Results Report
}
