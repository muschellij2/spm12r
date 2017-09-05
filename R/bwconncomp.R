#' @title Label Connected Clusters of Certain Size
#'
#' @description Get Cluster of certain size from spm_bwlabel
#' @param infile input filename
#' @param outfile output filename
#' @param retimg Return the image instead of matlab output
#' @param conn Connections to be passed to MATLAB's \code{bwconncomp}
#' @param reorient If \code{retimg}, then this argument is passed to
#' \code{readNIfTI}
#' @param spmdir (character) path for SPM12.  If NULL, assumes
#' SPM12 is in matlabpath.
#' @param verbose Print Diagnostics
#' @return Name of output file or \code{nifti} object,
#' depending on \code{retimg}
#' @importFrom R.utils gzip gunzip
#' @examples
#' library(neurobase)
#' set.seed(1234)
#' dims = c(30, 30, 10)
#' arr = array(rnorm(prod(dims)), dim = dims)
#' nim = nifti(arr)
#' mask = datatyper(nim > 1)
#' \dontrun{
#' cc = bwconncomp(mask)
#' tab = table(c(cc))
#' }
#' @export
#' @importFrom neurobase nii.stub readnii
bwconncomp = function(infile, # input filename
                      outfile = NULL, # output filename
                      retimg = TRUE,
                      conn = 26,
                      reorient = FALSE,
                      spmdir = spm_dir(),
                      verbose = TRUE){
  install_spm12()

  infile = checkimg(infile, gzipped = FALSE)
  infile = path.expand(infile)
  ##################
  # Checking on outfiles or return images
  ##################
  if (retimg) {
    if (is.null(outfile)) {
      outfile = tempfile(fileext = ".nii")
    }
  } else {
    stopifnot(!is.null(outfile))
  }

  outfile = path.expand(outfile)

  if (grepl("\\.gz$", infile)) {
    infile = R.utils::gunzip(infile,
                             remove = FALSE,
                             temporary = TRUE,
                             overwrite = TRUE)
  } else {
    infile = paste0(nii.stub(infile), ".nii")
  }
  stopifnot(file.exists(infile))
  gzip_outfile = FALSE
  if (grepl("\\.gz$", outfile)) {
    gzip_outfile = TRUE
    outfile = nii.stub(outfile)
    outfile = paste0(outfile, ".nii")
  }

  cmd = ""
  if (!is.null(spmdir)) {
    spmdir = path.expand(spmdir)
    cmd = paste(cmd, sprintf("addpath(genpath('%s'));", spmdir))
  }

  cmds = c(cmd,
           sprintf("ROI = '%s'", infile),
           sprintf("ROIf  = '%s'", outfile),
           "%-Connected Component labelling",
           "V = spm_vol(ROI);",
           "dat = spm_read_vols(V);",
           paste0("cc = bwconncomp(dat > 0, ", conn, ");"),
           "dat = labelmatrix(cc);",
           "%-Write new image",
           "V.fname = ROIf;",
           "V.private.cal = [0 1];",
           "spm_write_vol(V,dat);")

  sname = paste0(tempfile(), ".m")
  writeLines(cmds, con = sname)
  if (verbose) {
    message(paste0("# Script is located at ", sname, "\n"))
  }
  res = run_matlab_script(sname)


  if (gzip_outfile) {
    R.utils::gzip(outfile, overwrite = TRUE, remove = TRUE)
    outfile = paste0(nii.stub(outfile), ".nii.gz")
  }
  if (retimg) {
    if (verbose) {
      message(paste0("# Reading output file ", outfile, "\n"))
    }
    res = readnii(outfile, reorient = reorient)
  } else {
    res = outfile
  }
  return(res)
}
