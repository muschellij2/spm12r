#' Build contrasts query for SPM12 results
#'
#' @param name Name of the contrast
#' @param weights Weights of the contrast, 
#' must be the same length as the number of regressors
#' @param threshold_type type of thresholding done, if any
#' @param threshold Threshold value 
#' @param number_extent_voxels Number of voxel extent to call
#' an area a cluster
#' @param mask_type type of mask, if any
#' @param mask_image If \code{mask_type = "Image"}, then the 
#' filename of the mask
#' @param mask_contrast Vector of weights for the contrast that
#' will be used as the mask if \code{mask_type = "Contrast"}
#' @param mask_threshold if \code{mask_type = "Contrast"},
#' the threshold for the mask
#' @param mask_inclusive Is the mask inclusive?  If \code{FALSE},
#' then values in the mask which are zero will be included in the
#' output
#' @param cons List of contrasts
#' 
#' @return A list of objects, each with a 
#' \code{titlestr} (title string), contrast, threshold description,
#' threshold value, extent of voxels, and a mask (if appropriate)
#' @export
#'
#' @examples
#' res = spm12_contrast_query(name = "condition1", weights = 1)
#' print(res)
#' contrasts = list(
#' list(name = "All Contrasts",
#'        weights = Inf
#'        ),
#' list(name = "RightHand",
#' weights = 2) 
#' )
#' res = spm12_contrast_query_list(contrasts)
#' print(res)
spm12_contrast_query = function(
  weights = Inf, 
  name = "", 
  threshold_type = c("FWE", "none", "FDR"),
  threshold = 0.05,
  number_extent_voxels = 0,
  mask_type = c("None", "Contrast", "Image"),
  mask_image = NULL,
  mask_contrast = NULL,
  mask_threshold = 0.05,
  mask_inclusive = TRUE
) {
  
  threshold_type = match.arg(threshold_type)
  threshold_type = convert_to_matlab(threshold_type)
  
  name = convert_to_matlab(name)
  is.wholenumber <- function(x, 
                             tol = .Machine$double.eps^0.5)  {
    non_fin = !is.infinite(x)
    res = rep(TRUE, length = length(x))
    res[non_fin] = abs(x[non_fin] - round(x[non_fin])) < tol
    res
  }
  
  if (is.matrix(weights)) {
    stop("weights must be a vector for results query!")
    # weights = rmat_to_matlab_mat(weights)
  } else {
    msg = paste0(
      "Weights must whole number (integers), indexing the ",
      " contrast (> 0).  e.g. 1 or 1, 2 for conjunction")
    if (!all(is.wholenumber(weights))) {
      fin = is.finite(weights)
      weights[fin] = as.integer(weights[fin])
      warning(msg)
    }
    if (!all(weights > 0)) {
      stop(msg)
    }
    if (all(!is.infinite(weights))) {
      class(weights) = "rowvec"
      weights = convert_to_matlab(weights)
    }
  }
  
  mask_type = match.arg(mask_type)
  if (mask_type == "None" ) {
    mask_list = list(
      none = 1
    )  
  }
  
  if (mask_type == "Image" ) {
    if (is.null(mask_image)) {
      stop("If mask_type = Image, mask_image must be specified")
    }
    mask_image = filename_check(mask_image)
    mask_image = convert_to_matlab(mask_image)
    
    mask_inclusive = as.integer(mask_inclusive)
    mask_list = list(
      image = list(
        name = mask_image,
        mtype = mask_inclusive
      )
    )
  }
  
  if (mask_type == "Contrast" ) {
    if (is.null(mask_contrast)) {
      stop("If mask_type = Contrast, mask_contrast must be specified")
    }
    
    if (is.matrix(mask_contrast)) {
      mask_contrast = rmat_to_matlab_mat(mask_contrast)
    } else {
      if (all(mask_contrast == Inf)) {
        stop("Mask_contrast cannot be Inf!")
      }
      class(mask_contrast) = "rowvec"
      mask_contrast = convert_to_matlab(mask_contrast)
    }    
    mask_list = list(
      contrast = list(
        contrasts = mask_contrast,
        thresh = mask_threshold,
        mtype = mask_inclusive
      )
    )
  }  
  
  
  
  L = list(
    titlestr = name,
    contrasts = weights,
    threshdesc = threshold_type,
    thresh = threshold,
    extent = number_extent_voxels,
    mask = mask_list
  )
  # names(L) =paste0(tolower(type), "con")
  return(L)
}



#' @rdname spm12_contrast_query
#' @export
spm12_contrast_query_list = function(
  cons) {
  
  ###########################
  # Either named list
  ###########################
  n_cond = names(cons)
  extractor = function(ind) {
    lapply(cons, `[[`, ind)
  }
  ###########################
  # or grab the "name" element
  ###########################
  n_cond2 = extractor("name")
  n_cond2 = unlist(n_cond2)
  if (!is.null(n_cond2)) {
    n_cond = n_cond2
  }
  
  l_cond = length(cons)
  if (is.null(n_cond)) {
    n_cond = rep("", length = l_cond)
  }
  na_name = is.na(n_cond)
  if (any(na_name)) {
    n_cond[na_name] = ""
  }
  if (length(n_cond) != l_cond) {
    stop("Conditions not the same as the number of names")
  }

  
  # make sure name is in there
  cons = mapply(function(x, y) {
    x$name = y
    x
  }, cons, n_cond, SIMPLIFY = FALSE)
  
  
  
  cons = lapply(cons, function(x) {
    r = do.call("spm12_contrast_query", x)
    return(r)
  })
  
  names(cons) = paste0("(", seq(cons), ")")
  return(cons)
}


