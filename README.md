# The `git2rdata` package <img src="man/figures/logo.png" align="right" alt="" width="120" />

[![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![](https://badges.ropensci.org/263_status.svg)](https://github.com/ropensci/software-review/issues/263)

[![Licence](https://img.shields.io/badge/licence-GPL--3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0.en.html)
[![minimal R version](https://img.shields.io/badge/R%3E%3D-3.4.0-6666ff.svg)](https://cran.r-project.org/)
[![DOI](https://zenodo.org/badge/147685405.svg)](https://zenodo.org/badge/latestdoi/147685405)

[![Travis-CI Build Status](https://travis-ci.org/inbo/git2rdata.svg?branch=master)](https://travis-ci.org/inbo/git2rdata)
[![AppVeyor Build status](https://ci.appveyor.com/api/projects/status/a3idhi9f6ls9xu8r/branch/master?svg=true)](https://ci.appveyor.com/project/ThierryO/git2rdata/branch/master)
[![codecov](https://codecov.io/gh/inbo/git2rdata/branch/master/graph/badge.svg)](https://codecov.io/gh/inbo/git2rdata)

<p id="github">Please visit the git2rdata website at https://inbo.github.io/git2rdata/. The vignette code on the website link to a rendered version of the vignette. Functions have a link to their helpfile.</p>

<script>
if (window.location.hostname != "github.com") {
  document.getElementById("github").innerHTML = ""
}
</script>

## Rationale

The `git2rdata` package is an R package for writing and reading dataframes as plain text files. Important information is stored in a metadata file.

1. Storing metadata allows to maintain the classes of variables. By default, the data is optimized for file storage prior to writing. This makes the data less human readable and can be turned off. Details on the implementation are available in the getting started vignette (`vignette("plain_text", package = "git2rdata")`).
1. Storing metadata also allows to minimize row based [diffs](https://en.wikipedia.org/wiki/Diff) between two consecutive [commits](https://en.wikipedia.org/wiki/Commit_(version_control)). This is a useful feature when storing data as plain text files under version control. Details on this part of the implementation are available in the `vignette("version_control", package = "git2rdata")`. Although `git2rdata` was envisioned with a [git](https://git-scm.com/) workflow in mind, it can also be used in combination with other version control systems like [subversion](https://subversion.apache.org/) or [mercurial](https://www.mercurial-scm.org/).
1. `git2rdata` is intended to facilitate a reproducible and traceable workflow. A toy example is given in `vignette("workflow", package = "git2rdata")`.
1. `vignette("efficiency", package = "git2rdata")` provides some insight into the efficiency in terms of file storage, git repository size and speed for writing and reading.

## Installation

Install the development version

```r
# installation requires the "remotes" package
# install.package("remotes")

# install with vignettes (recommended)
remotes::install_github(
  "inbo/git2rdata", 
  build = TRUE, 
  dependencies = TRUE, 
  build_opts = c("--no-resave-data", "--no-manual")
)
# install without vignettes
remotes::install_github("inbo/git2rdata"))
```

## Usage in a nutshell

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

## What data sizes can `git2rdata` handle?

The recommendation for git repositories is to use files smaller than 100 MB, an overall repository size less than 1 GB and less than 25k files. The individual file size is the limiting factor. Storing the airbag dataset ([`DAAG::nassCDS`](https://cran.r-project.org/package=DAAG)) with `write_vc()` requires on average 68 (optimized) or 97 (verbose) byte per record. The 100 MB file limit for this data is reached after about 1.5 million (optimize) or 1 million (verbose) observations. Your mileage might vary.

## Citation

Please use the output of `citation("git2rdata")`

## Folder structure

- `R`: The source scripts of the [R](https://cran.r-project.org/) functions with documentation in [Roxygen](https://github.com/klutometis/roxygen) format
- `man`: The help files in [Rd](https://cran.r-project.org/doc/manuals/r-release/R-exts.html#Rd-format) format
- `testthat`: R scripts with unit tests using the [testthat](http://testthat.r-lib.org/) framework
- `vignettes`: source code for the vignettes describing the package
- `man-roxygen`: templates for documentation in Roxygen format
- `pkgdown`: additional source files for the `git2rdata` [website](https://inbo.github.io/git2rdata/)
- `.github`: guidelines and templates for contributors
- `sticker`: source code for the `git2rdata` hex sticker

```
git2rdata
├── .github 
├── man 
├── man-roxygen 
├── pkgdown
├── R
├── sticker
├─┬ tests
│ └── testthat
└── vignettes
```

## Contributions

Contributions to `git2rdata` are welcome. Please read our [Contributing guidelines](.github/CONTRIBUTING.md) first. The `git2rdata` project is released with a [Contributor Code of Conduct](.github/CODE_OF_CONDUCT.md). By contributing to this project, you agree to abide by its terms.
