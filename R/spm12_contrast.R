
#' Build contrasts for SPM12 first level model
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
spm12_contrast = function(
  name, 
  weights, 
  replicate = 
    c("none", "repl", "replsc", 
      "sess", "both", "bothsc")) {
  
  replicate = match.arg(replicate)
  replicate = convert_to_matlab(replicate)
  
  name = convert_to_matlab(name)
  
  if (is.matrix(weights)) {
    weights = rmat_to_matlab_mat(weights)
  } else {
    class(weights) = "rowvec"
    weights = convert_to_matlab(weights)
  }
  
  L = list(
    name = name,
    weights = weights,
    sessrep = replicate
  )
  # names(L) =paste0(tolower(type), "con")
  return(L)
}




#' @rdname spm12_contrast
#' @export
spm12_contrast_list = function(
  cons,
  type = "T") {
  
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
  msg = "Contrasts must be named and not NA!"
  if (is.null(n_cond)) {
    stop(msg)
  }
  if (any(n_cond %in% "" | is.na(n_cond))) {
    stop(msg)
  }
  if (length(n_cond) != l_cond) {
    stop("Conditions not the same as the number of names")
  }
  
  type2 = extractor("type")
  type2 = unlist(type2)
  if (!is.null(type2)) {
    type = type2
  }
  
  type = match.arg(
    type, choices = c("T", "F"),
    several.ok = TRUE)
  type = rep_len(type, length.out = l_cond)
  

  # make sure name is in there
  cons = mapply(function(x, y) {
    x$name = y
    x$type = NULL
    x
  }, cons, n_cond, SIMPLIFY = FALSE)
  
  
  
  cons = lapply(cons, function(x) {
    r = do.call("spm12_contrast", x)
    return(r)
  })
  
  names(cons) = paste0(
    "{", seq(cons), "}.", 
    paste0(tolower(type), "con")
  )
  return(cons)
}


