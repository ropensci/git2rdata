# The `git2rdata` package <img src="man/figures/logo.png" align="right" alt="" width="120" />

[![CRAN status](https://www.r-pkg.org/badges/version/git2rdata)](https://cran.r-project.org/package=git2rdata)
[![Rdoc](https://www.rdocumentation.org/badges/version/git2rdata)](https://www.rdocumentation.org/packages/git2rdata)

[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![lifecycle](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle/#maturing)
[![](https://badges.ropensci.org/263_status.svg)](https://github.com/ropensci/software-review/issues/263)

[![Licence](https://img.shields.io/badge/licence-GPL--3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0.en.html)
[![minimal R version](https://img.shields.io/badge/R%3E%3D-3.5.0-6666ff.svg)](https://cran.r-project.org/)
[![DOI](https://zenodo.org/badge/147685405.svg)](https://zenodo.org/badge/latestdoi/147685405)

[![Travis-CI Build Status](https://travis-ci.org/ropensci/git2rdata.svg?branch=master)](https://travis-ci.org/ropensci/git2rdata)
[![AppVeyor Build status](https://ci.appveyor.com/api/projects/status/cfbjb835fqb3dc7m/branch/master?svg=true)](https://ci.appveyor.com/project/ThierryO/git2rdata-n60yg/branch/master)
[![codecov](https://codecov.io/gh/ropensci/git2rdata/branch/master/graph/badge.svg)](https://codecov.io/gh/ropensci/git2rdata)

![GitHub forks](https://img.shields.io/github/forks/ropensci/git2rdata.svg?style=social)
![GitHub stars](https://img.shields.io/github/stars/ropensci/git2rdata.svg?style=social)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/ropensci/git2rdata.svg)
![GitHub repo size](https://img.shields.io/github/repo-size/ropensci/git2rdata.svg)

<p style="display:none">Please visit the git2rdata website at https://ropensci.github.io/git2rdata/. The vignette code on the website link to a rendered version of the vignette. Functions have a link to their help file.</p>

## Rationale

The `git2rdata` package is an R package for writing and reading dataframes as plain text files. Important information is stored in a metadata file.

1. Storing metadata allows to maintain the classes of variables. By default, the data is optimized for file storage prior to writing. The optimization is most effective on data containing factors. The optimization makes the data less human readable and can be turned off. Details on the implementation are available in `vignette("plain_text", package = "git2rdata")`.
1. Storing metadata also allows to minimize row based [diffs](https://en.wikipedia.org/wiki/Diff) between two consecutive [commits](https://en.wikipedia.org/wiki/Commit_(version_control)). This is a useful feature when storing data as plain text files under version control. Details on this part of the implementation are available in `vignette("version_control", package = "git2rdata")`. Although `git2rdata` was envisioned with a [git](https://git-scm.com/) workflow in mind, it can also be used in combination with other version control systems like [subversion](https://subversion.apache.org/) or [mercurial](https://www.mercurial-scm.org/).
1. `git2rdata` is intended to facilitate a reproducible and traceable workflow. A toy example is given in `vignette("workflow", package = "git2rdata")`.
1. `vignette("efficiency", package = "git2rdata")` provides some insight into the efficiency in terms of file storage, git repository size and speed for writing and reading.

## Why Use Git2rdata?

- You can store dataframes as plain text files.
- The dataframe you read has exactly the same information content as the one you wrote.
    - No changes in data type.
    - Factors keep their original levels, including their order.
    - Date and date-time are stored in an unambiguous format, documented in the metadata.
- The data and the metadata are stored in a standard and open format, making it readable by other software.
- Data and metadata are checked during the reading. The user is informed if there is tampering with the data or metadata.
- Git2rdata integrates with the [`git2r`](https://cran.r-project.org/package=git2r) package for working with git repository from R.
    - Another option is using git2rdata solely for writing to disk and handle the plain text files with your favourite version control system outside of R.
- The optimization reduces the required disk space by about 30% for both the working directory and the git history. 
- Reading data from a HDD is 30% faster than `read.table()`, writing to a HDD takes about 70% more time than `write.table()`.
- Git2rdata is useful as a tool in a reproducible and traceable workflow. See `vignette("workflow", package = "git2rdata")`.
- You can detect when a file was last modified in the git history. Use this to check whether an existing analysis is obsolete due to new data. This allows to not rerun up to date analyses, saving resources.

## Installation

Install from CRAN

```r
install.packages("git2rdata")
```

Install the development version from GitHub

```r
# installation requires the "remotes" package
# install.package("remotes")

# install with vignettes (recommended)
remotes::install_github(
  "ropensci/git2rdata", 
  build = TRUE, 
  dependencies = TRUE, 
  build_opts = c("--no-resave-data", "--no-manual")
)
# install without vignettes
remotes::install_github("ropensci/git2rdata"))
```

## Usage in a Nutshell

Dataframes are stored using `write_vc()` and retrieved with `read_vc()`. Both functions share the arguments `root` and `file`. `root` refers to a base location where the dataframe should be stored. It can either point to a local directory or a local git repository. `file` is the file name to use and can include a path relative to `root`. Make sure the relative path stays within `root`.

```r
# using a local directory
library(git2rdata)
root <- "~/myproject" 
write_vc(my_data, file = "rel_path/filename", root = root)
read_vc(file = "rel_path/filename", root = root)
root <- git2r::repository("~/my_git_repo") # git repository
```

More details on store dataframes as plain text files in `vignette("plain_text", package = "git2rdata")`.

```r
# using a git repository
library(git2rdata)
repo <- repository("~/my_git_repo")
pull(repo)
write_vc(my_data, file = "rel_path/filename", root = repo, stage = TRUE)
commit(repo, "My message")
push(repo)
read_vc(file = "rel_path/filename", root = repo)
```

Please read `vignette("version_control", package = "git2rdata")` for more details on using git2rdata in combination with version control.

## What Data Sizes Can Git2rdata Handle?

The recommendation for git repositories is to use files smaller than 100 MiB, an overall repository size less than 1 GiB and less than 25k files. The individual file size is the limiting factor. Storing the airbag dataset ([`DAAG::nassCDS`](https://cran.r-project.org/package=DAAG)) with `write_vc()` requires on average 68 (optimized) or 97 (verbose) byte per record. The 100 MiB file limit for this data is reached after about 1.5 million (optimize) or 1 million (verbose) observations. 

Storing a 90% random subset of the airbag dataset requires 370 kiB (optimized) or 400 kiB (verbose) storage in the git history. Updating the dataset with other 90% random subsets requires on average 60 kiB (optimized) to 100 kiB (verbose) per commit. The git history limit of 1 GiB will be reached after 17k (optimized) to 10k (verbose) commits.

Your mileage might vary.

## Citation

Please use the output of `citation("git2rdata")`

## Folder Structure

- `R`: The source scripts of the [R](https://cran.r-project.org/) functions with documentation in [Roxygen](https://github.com/klutometis/roxygen) format
- `man`: The help files in [Rd](https://cran.r-project.org/doc/manuals/r-release/R-exts.html#Rd-format) format
- `inst/efficiency`: pre-calculated data to speed up `vignette("efficiency", package = "git2rdata")`
- `testthat`: R scripts with unit tests using the [testthat](http://testthat.r-lib.org/) framework
- `vignettes`: source code for the vignettes describing the package
- `man-roxygen`: templates for documentation in Roxygen format
- `pkgdown`: additional source files for the `git2rdata` [website](https://ropensci.github.io/git2rdata/)
- `.github`: guidelines and templates for contributors

```
git2rdata
├── .github 
├─┬ inst
│ └── efficiency
├── man 
├── man-roxygen 
├── pkgdown
├── R
├─┬ tests
│ └── testthat
└── vignettes
```

## Contributions

Contributions to `git2rdata` are welcome. Please read our [Contributing guidelines](https://github.com/ropensci/git2rdata/blob/master/.github/CONTRIBUTING.md) first. The `git2rdata` project is released with a [Contributor Code of Conduct](https://github.com/ropensci/git2rdata/blob/master/.github/CODE_OF_CONDUCT.md). By contributing to this project, you agree to abide by its terms.

[![rOpenSci footer](http://ropensci.org/public_images/github_footer.png)](https://ropensci.org)
