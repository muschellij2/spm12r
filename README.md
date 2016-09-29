R Package wrapping up [SPM12](http://www.fil.ion.ucl.ac.uk/spm/software/spm12/) from the Wellcome Trust Centre for Neuroimaging 

[![Build Status](https://travis-ci.org/muschellij2/spm12r.svg?branch=master)](https://travis-ci.org/muschellij2/spm12r)
[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/spm12r)](http://cran.rstudio.com/web/packages/spm12r/index.html)
[![](http://cranlogs.r-pkg.org/badges/grand-total/spm12r)](http://cran.rstudio.com/web/packages/spm12r/index.html)

## Installation

You can install the stable version on
[CRAN](http://cran.rstudio.com/package=spm12r):

```r
install.packages('spm12r', dependencies = TRUE)
```

Install in `R` using `devtools`:
```r
devtools::install_github("muschellij2/spm12r")
```


### Installing SPM12 Commands
After `spm12r` is installed, you can install the required SPM scripts using:

```r
spm12r::install_spm12()
```