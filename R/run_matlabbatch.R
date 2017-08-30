#' Run Matlab Batch from List
#'
#' @param spm List of the class \code{matlabbatch}
#' @param ... additional arguments to pass to  \code{\link{add_spm_dir}}
#' @param clean Remove scripts from temporary directory after running
#' @param verbose Print diagnostic messages
#' 
#' @return Result of \code{\link{res}}
#' @export
run_matlabbatch = function(
  spm, 
  add_spm_dir = TRUE, 
  clean = TRUE,
  verbose = TRUE,
  ...) {
  exec_fname = matlabbatch_job(
    spm = spm, 
    add_spm_dir = add_spm_dir, 
    ...)
  res = run_matlab_script(exec_fname)
  if (verbose) {
    message(paste0("# Result is ", res, "\n"))
  }  
  #####################################
  # Cleaning up files
  ##################################### 
  if (clean) {
    file.remove(script)
    if (verbose) {
      message(paste0("# Removing scripts\n"))
    }      
  }
  
  return(res)
}

#' @rdname run_matlabbatch
#' @export
matlabbatch_job = function(
  spm, 
  add_spm_dir = TRUE, 
  ...) {
  script = matlabbatch_to_script(spm, ...)
  exec_script = system.file(
    "scripts", 
    "Executable.m", 
    package = "spm12r")
  exec_script = readLines(exec_script)
  if (add_spm_dir) {
    exec_script = add_spm_dir(x = exec_script, ...)
  }
  exec_script = gsub("%jobfile%", script, exec_script)
  exec_fname = tempfile(fileext = ".m")
  writeLines(exec_script, con = exec_fname)
  return(exec_fname)
}

#' @rdname run_matlabbatch
#' @param prefix prefix to add to the names of \code{spm}
#' @param add_spm_dir should SPM12 directory be added to the script
#' @export
matlabbatch_to_script = function(
  spm, 
  prefix = "matlabbatch{1}.",
  ...) {
  mbatch = convert_to_matlab(spm)
  # ending the lines
  mbatch = trimws(mbatch)
  mbatch = paste0(mbatch, ";")
  mbatch = sub(";;$", ";", mbatch)
  
  mbatch = paste0(prefix, mbatch)
  fname = tempfile(fileext = ".m")
  writeLines(mbatch, fname)
  return(fname)
}