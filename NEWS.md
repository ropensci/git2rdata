git2rdata 0.0.2 (2019-02-26)
============================

### BREAKING CHANGES

  * metadata is added as a list to the objects rather than in YAML format.
  * the [yaml](https://cran.r-project.org/package=yaml) package is used to store the metadata list in YAML format.
  * `write_vc()` now used the 'strict' argument instead of 'override'
  * the functionality `rm_data()` is split into `rm_data()` and `prune_meta()` (#9)

### NEW FEATURES

  * vignette on [efficiency](../articles/efficiency.html) added (#2)
  * existing vignette was split over three vignettes
      * focus on the [plain text format](../articles/plain_text.html)
      * focus on [version control](../articles/version_control.html)
      * focus on [workflows](../articles/workflow.html)
  * S4 methods are replaced by S3 methods (#8)
  * optimized factors use stable indices, resulting in smaller diffs when levels are added or removed (#13)
  * use `relabel()` to alter factor levels without changing their index (#13)
  * the raw data is written and read by base R functions instead of `readr` functions (#7)
  * `write_vc()` and `read_vc()` use the current working directory as default root (#6, @florisvdh)
  * the user can specify a string to code missing values (default = `NA`). This allows the storage of the character string `"NA"`.
  * `write_vc()` returns a list of issues which potentially result in large diffs.
  * `list_data()` returns a vector with dataframes in the repository

### Other changes

  * `write_vc()` allows to use a custom NA string
  * each helpfile contains a working example (#11)
  * README updated (#12)
      * Updated the rationale with links to the vignettes
      * `git2rdata` has an hexsticker logo
      * A DOI is added
      * The installation instructions uses `remotes` and build the vignettes
  * `auto_commit()` was removed because of limited extra functionality over `git2r::commit()`
  * dataframes are read and written by base R functions instead of `readr` functions

git2rdata 0.0.1 (2018-11-12)
============================

### NEW FEATURES

  * use readr to write and read plain text files
  * allows storage of strings with "NA" or special characters
  * handle ordered factors
  * stop handling complex numbers
