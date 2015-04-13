
#' @title AC/PC Reorientation
#' @description Function that AC/PC re-orients the images for SPM 
#' spatial normalization routine.  Uses nii_setorigin from 
#' http://www.mccauslandcenter.sc.edu/CRNL/sw/spm8/spm.zip
#' @param infiles (character) Files to reorient.  First file will be used to 
#' estimate AC/PC, then rest will be transformed
#' @param spmdir (character) path for SPM8.  If NULL, assumes 
#' SPM8 is in matlabpath and so is spm8/toolbox
#' Must have nii_setorigin installed.  In 
#' \code{system.file("", package="cttools")} from
#' http://www.mccauslandcenter.sc.edu/CRNL/sw/spm8/spm.zip
#' @param verbose (logical) Print diagnostic output
#' @return Exit code from MATLAB.  If not zero, there was an error
#' @export
acpc_reorient <- function(
  infiles, 
  spmdir = spm_dir(), 
  verbose=TRUE 
){
  if (verbose) cat(paste0("\nReorientation ", infiles[1]))
  matcmd = get_matlab()
  ### gantry tilt correction - make new folder
  ### ranem old folder - zip it and then run matlab script
  infiles <- path.expand(infiles)
  
  cmd <- paste(matcmd, '" try, ')
  if (!is.null(spmdir)){
    spmdir = path.expand(spmdir)
    cmd <- paste(cmd, sprintf("addpath('%s');", spmdir))
    cmd <- paste(cmd, sprintf("addpath('%s/toolbox');", spmdir))
  }
  
  
  #   cmd <- paste(cmd, sprintf("addpath('%s/toolbox/rorden');", spmdir))
  cmd <- paste(cmd, sprintf("addpath('%s');", 
                            system.file("", package="cttools")))
  
  limgs = length(infiles)
  imgs = sprintf("'%s',", infiles[1])
  if (limgs > 1){
    for (ifile in 2:limgs){
      imgs = paste( imgs, sprintf("'%s',", 
                                  infiles[ifile]))
    }
  }
  imgs = str_trim(imgs)
  imgs = gsub(",$", "", imgs)
  cmd <- paste(cmd, sprintf("runimgs = strvcat(%s);", imgs))
  cmd <- paste(cmd, "nii_setorigin(runimgs);")
  cmd <- paste(cmd, "catch err, disp(err); exit(1);")
  cmd <- paste0(cmd, 'end; exit(0);"')
  # if (verbose) cat(cmd, "\n")
  x <- system(cmd, 
              ignore.stdout = !verbose )
  
  return(x)
}
