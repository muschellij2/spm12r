## Test environments
* local OS X install, R 3.5.2
* ubuntu 14.04 (on travis-ci), R 3.5.2
* win-builder (devel and release)

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.

--- 
This should no longer have duplicate names for Vignettes.  Also, it seems as though `git2r` has errors with GitHub certificates and skipping the `git2r` commands on windows.  A `git2r` fix may be required or the configuration of CRAN may need to revise Windows setup based on TLS change: https://support.microsoft.com/en-us/help/3140245/update-to-enable-tls-1-1-and-tls-1-2-as-default-secure-protocols-in-wi