#' @title Wrapper for running \code{spm12_script}
#'
#' @description Runs \code{\link{spm12_script}} with wrapper for
#' spm12r functions
#' @param script_name Name of the script filename without .m ext,
#' passed to \code{\link{spm12_script}}
#' @param jobvec Vector of characters to be substituted in _job.m file
#' @param mvec Vector of characters to be substituted in .m file
#' @param add_spm_dir Add SPM12 directory from this package
#' @param spmdir SPM dir to add, will use package default directory
#' @param clean Remove scripts from temporary directory after running
#' @param verbose Print diagnostic messages
#' @param single_thread Should the flag \code{-singleCompThread} 
#' be executed to limit MATLAB to a single computational thread? 
#' @param ... Arguments to pass to \code{\link{spm12_script}}
#' @export
#' @importFrom matlabr run_matlab_script get_matlab run_matlab_code
#' @return Result of \code{\link{run_matlab_script}}
run_spm12_script <- function(
  script_name,
  jobvec = NULL,
  mvec = NULL,
  add_spm_dir = TRUE,
  spmdir = spm_dir(verbose = verbose),
  clean = TRUE,
  verbose = TRUE,
  single_thread = FALSE,
  ...
){
  
  # simple workup for CRAN
  if (on_cran()) {
    single_thread = TRUE
  }
  
  scripts = build_spm12_script(
    script_name = script_name,
    jobvec = jobvec,
    mvec = mvec,
    add_spm_dir = add_spm_dir,
    spmdir = spmdir,
    verbose = verbose,
    ...)
  
  if (verbose) {
    message(paste0(
      "# Running script ", scripts["script"], "\nwhich calls ",
      scripts["job"], "\n"))
  }
  res = run_matlab_script(
    scripts["script"], 
    verbose = verbose,
    single_thread = single_thread)
  if (verbose) {
    message(paste0("# Result is ", res, "\n"))
  }  
  #####################################
  # Cleaning up files
  ##################################### 
  if (clean) {
    file.remove(scripts)
    if (verbose) {
      message(paste0("# Removing scripts\n"))
    }      
  }
  return(res)
}


#' @export
#' @rdname run_spm12_script
#' @param install_dir directory to download SPM12
build_spm12_script <- function(
  script_name,
  jobvec = NULL,
  mvec = NULL,
  add_spm_dir = TRUE,
  spmdir = spm_dir(verbose = verbose),
  verbose = TRUE,
  install_dir = NULL,
  ...
){
  install_spm12(verbose = verbose, 
                install_dir = install_dir)
  
  scripts = spm12_script(script_name, ...)
  # put in the correct filenames
  job = readLines(scripts["job"])
  njvec = names(jobvec)
  if (any(is.na(jobvec))) {
    print(jobvec)
    stop("There is an NA in jobvec")
  }
  for (ijob in seq_along(jobvec)) {
    job = gsub(njvec[ijob], jobvec[ijob], job)
  }
  
  m = readLines(scripts["script"])
  nmvec = names(mvec)
  for (ijob in seq_along(mvec)) {
    m = gsub(nmvec[ijob], mvec[ijob], job)
  }
  m = gsub("%jobfile%", scripts['job'], m)
  
  #####################################
  # Adding in SPMDIR
  #####################################  
  if (add_spm_dir) {
    if (verbose) {
      message(paste0("# Adding SPMDIR: ", spmdir, "\n"))
    }
    m = c(paste0("addpath(genpath('", spmdir, "'));"),
          m)
  }
  
  #####################################
  # Write Out files
  ##################################### 
  writeLines(m, con = scripts['script'])
  writeLines(job, con = scripts['job'])
  
  return(scripts)
}