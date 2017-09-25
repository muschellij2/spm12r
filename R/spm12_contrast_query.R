#' Build contrasts query for SPM12 results
#'
#' @param name Name of the contrast
#' @param weights Weights of the contrast, 
#' must be the same length as the number of regressors
#' @param replicate If  there  are  multiple  sessions with 
#' identical conditions, one might want to specify contrasts 
#' which are identical over sessions. Options are 
#' no replication (\code{none}), 
#' replicate (\code{repl}), 
#' replicate + scale (\code{replsc}), 
#' create per session (\code{sess}), 
#' Both: Replicate + Create per session (\code{both}), 
#' Both: Replicate + Scale + Create per session (\code{bothsc})
#' @param type type of contrast, T-statistic or F-statistic
#' @param cons List of contrasts
#' 
#'
#' @return A list of objects, each with a \code{name} and \code{value}
#' @export
#'
#' @examples
#' res = spm12_contrast(name = "condition1", weights = c(
#' 1, rep(0, 8)))
#' print(res)
#' contrasts = list(
#' list(name = "LeftHand",
#'        weights = c(1, rep(0, 7)),
#' replicate = "none",
#' type = "T" ),
#' list(name = "RightHand",
#' weights = c(0, 1, rep(0, 6)),
#' replicate = "none",
#' type = "T"), 
#' list(name = "AllEffects",
#' weights = rbind(
#' c(1, rep(0, 7)),
#'          c(0, 1, rep(0, 6))
#'        ),
#' replicate = "none",
#' type = "F")   
#' )
#' res = spm12_contrast_list(contrasts)
#' print(res)
spm12_contrast_query = function(
  weights, 
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
  
  if (is.matrix(weights)) {
    weights = rmat_to_matlab_mat(weights)
  } else {
    if (all(weights != Inf)) {
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


