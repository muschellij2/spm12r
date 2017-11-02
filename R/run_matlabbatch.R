#' Run Matlab Batch from List
#'
#' @param spm List of the class \code{matlabbatch}
#' @param ... additional arguments to pass to 
#' \code{\link{matlabbatch_job}}
#' @param clean Remove scripts from temporary directory after running
#' @param verbose Print diagnostic messages
#' 
#' @return Result of \code{\link{run_matlab_script}}
#' @export
run_matlabbatch = function(
  spm, 
  add_spm_dir = TRUE, 
  clean = TRUE,
  verbose = TRUE,
  gui = FALSE,
  ...) {
  if (verbose) {
    message("# Creating matlabbatch job")
  }
  args = list(...)
  nargs = names(args)
  if ("display" %in% nargs) {
    display = args$display
    args$display = NULL
  } else {
    display = NULL
  }
  if ("desktop" %in% nargs) {
    desktop = args$desktop
    args$desktop = NULL
  } else {
    desktop = NULL
  } 
  args$spm = spm
  args$add_spm_dir = add_spm_dir
  args$verbose = verbose
  args$gui = gui
  
  L = do.call("matlabbatch_job", args)
  
  exec_fname = L$exec_script
  script = L$script
  if (verbose) {
    msg = paste0("Running job: ", exec_fname,
                 ", which calls ", script)
    message(msg)
  }
  run_args = list(fname = exec_fname, verbose = verbose)
  run_args$desktop = desktop
  run_args$display = display
  run_args$wait = TRUE
  res = do.call("run_matlab_script", args = run_args)
  
  if (verbose) {
    message(paste0("# Result is ", res, "\n"))
  }  
  #####################################
  # Cleaning up files
  ##################################### 
  if (clean) {
    file.remove(script)
    file.remove(exec_fname)
    if (verbose) {
      message(paste0("# Removing scripts\n"))
    }      
  }
  
  return(res)
}

#' @rdname run_matlabbatch
#' @param gui is the GUI necessary?
#' @export
matlabbatch_job = function(
  spm, 
  add_spm_dir = TRUE, 
  gui = FALSE,
  ...) {
  script = matlabbatch_to_script(spm, ...)
  exec_script = system.file(
    "scripts", 
    ifelse(gui, "Executable_withgui.m", "Executable.m"),
    package = "spm12r")
  exec_script = readLines(exec_script)
  if (add_spm_dir) {
    args = list(...)
    nargs = names(args)
    add_args = list(x = exec_script)
    if ("spmdir" %in% nargs) {
      add_args$spmdir = args$spmdir  
    }
    if ("verbose" %in% nargs) {
      add_args$verbose = args$verbose  
    }    
    exec_script = do.call("add_spm_dir", add_args)
  }
  exec_script = gsub("%jobfile%", script, exec_script)
  exec_fname = tempfile(fileext = ".m")
  exec_fname = gfilename(exec_fname)
  writeLines(exec_script, con = exec_fname)
  L = list(
    exec_script = exec_fname,
    script = script)
  return(L)
}

#' @rdname run_matlabbatch
#' @param batch_prefix prefix to add to the names of \code{spm}
#' @param add_spm_dir should SPM12 directory be added to the script
#' @export
matlabbatch_to_script = function(
  spm, 
  batch_prefix = "matlabbatch{1}.",
  ...) {
  mbatch = convert_to_matlab(spm)
  # ending the lines
  mbatch = trimws(mbatch)
  mbatch = paste0(mbatch, ";")
  mbatch = sub(";;$", ";", mbatch)
  
  # remove empty lines
  mbatch = mbatch[!mbatch %in% ""]
  
  mbatch = paste0(batch_prefix, mbatch)
  fname = tempfile(fileext = ".m")
  fname = gfilename(fname)
  writeLines(mbatch, con = fname)
  return(fname)
}