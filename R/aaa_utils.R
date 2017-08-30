is.rowvec = function(x) {
  inherits(x, "rowvec")
}

is.colvec = function(x) {
  inherits(x, "colvec")
}

is.cell = function(x) {
  inherits(x, "cell")
}
is.cell_list = function(x) {
  inherits(x, "cell_list")
}  


is.matlabbatch = function(x) {
  inherits(x, "matlabbatch")
}  

# matlab


#' @importFrom matlabr rvec_to_matlab rvec_to_matlabcell 
#' @importFrom matlabr rvec_to_matlabclist rmat_to_matlab_mat
#' @export
convert_to_matlab = function(x, ...) {
  if (is.rowvec(x)) {
    x = matlabr::rvec_to_matlab(x, row = TRUE, ...)
    return(x)
  }
  if (is.colvec(x)) {
    x = matlabr::rvec_to_matlab(x, row = FALSE, ...)
    return(x)
  }    
  if (is.cell(x)) {
    x = matlabr::rvec_to_matlabcell(x = x, ...)
    return(x)
  }
  if (is.cell_list(x)) {
    x = matlabr::rvec_to_matlabclist(x = x, ...)
    return(x)
  } 
  
  if (is.factor(x)) {
    x = as.numeric(x) - 1
    return(x)
  }    
  if (is.character(x)) {
    x = paste0("'", x, "'")
    return(x)
  }  
  if (is.matrix(x)) {
    x = matlabr::rmat_to_matlab_mat(x = x, ...)
    return(x)
  }     
  if (is.matlabbatch(x)) {
    x = unlist(x)
    x = mapply(function(x, y) {
      paste0(x, " = ", y)
    }, names(x), x)
    names(x) = NULL
    return(x)
  }       
  return(x)
}