## ----knit-setup, echo=FALSE, results='hide', eval=TRUE, cache = FALSE, warning = FALSE, message = FALSE----
library(spm12r)

## ----makefiles-----------------------------------------------------------
library(kirby21.t1)
library(kirby21.fmri)
functional = get_fmri_filenames(ids = 113, visit = 1)
anatomical = get_t1_filenames(ids = 113, visit = 1)
files = c(anatomical = anatomical,
          functional = functional)
files

