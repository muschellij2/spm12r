
#' @title Find SPM12 Script
#'
#' @description Copies the SPM12 script from the scripts directory
#' to a temporary file
#' @param script_name Name of the script filename without ".m" ext
#' @export
#' @return Chracter vector of script paths
#' @examples spm12_script(script_name = "Segment")
spm12_script <- function(script_name){
  m_scripts = system.file("scripts", 
                           paste0(script_name, c(".m")), 
                           package="spm12r")
  job_scripts = system.file("scripts", 
                        paste0(script_name, c("_job.m")), 
                        package="spm12r")  
  scripts = c(job = job_scripts, script = m_scripts)
  scripts = scripts[scripts != "", drop = FALSE]
  nn = names(scripts)
  if (length(scripts) > 0){
    tdir = tempdir()
    file.copy(scripts, to = tdir)
    scripts = file.path(tdir, basename(scripts))
    names(scripts) = nn
  }
  return(scripts)
}
