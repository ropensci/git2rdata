# The `git2rdata` package

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
