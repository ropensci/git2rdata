# The `git2rdata` package

[![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
[![Licence](https://img.shields.io/badge/licence-GPL--3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0.en.html)
[![minimal R version](https://img.shields.io/badge/R%3E%3D-3.4.0-6666ff.svg)](https://cran.r-project.org/)
[![Travis-CI Build Status](https://travis-ci.org/inbo/git2rdata.svg?branch=master)](https://travis-ci.org/inbo/git2rdata)
[![AppVeyor Build status](https://ci.appveyor.com/api/projects/status/a3idhi9f6ls9xu8r/branch/master?svg=true)](https://ci.appveyor.com/project/ThierryO/git2rdata/branch/master)
[![codecov](https://codecov.io/gh/inbo/git2rdata/branch/master/graph/badge.svg)](https://codecov.io/gh/inbo/git2rdata)

## Rationale

The `git2rdata` package writes and reads `data.frame`s as plain text files. Important information is stored in a metadata file. This allows the following features:

- all factor labels and their order is conserved, even if a factor label isn't present in the `data.frame`.
- `factor`, `logical`, `POSIXct` and `Date` are by default stored as integers for efficiency. The user can opt for verbose storage.
- the order of the variables is stored in the metadata
- the definition for sorting the observations is stored in the metadata
- the metadata for new data is compared with existing metadata for that file. When the metadata matches, the old data will be overwritten by the new data. In case of a mismatch, the user can force overwritting the data.
- both the variables and the observations will be sorting according to the metadata prior to overwriting existing data

These features are inspired by storing data in a [version control system](https://en.wikipedia.org/wiki/Version_control) like [git](https://en.wikipedia.org/wiki/Git). The predefined sorting prior to writing ensures minimal [diffs](https://en.wikipedia.org/wiki/Diff) between [commits](https://en.wikipedia.org/wiki/Commit_(version_control)).

## Folder structure

- `R`: The source scripts of the [R](https://cloud.r-project.org/) functions with documentation in [Roxygen](https://github.com/klutometis/roxygen) format
- `man`: The helpfile in [Rd](https://cloud.r-project.org/doc/manuals/r-release/R-exts.html#Rd-format) format
- `testthat`: R scripts with unit tests using the [testthat](http://testthat.r-lib.org/) framework

```
git2rdata
├── man 
├── R
└─┬ tests
  └── testthat
```
