# git2rdata 0.5.0

* `read_vc()` handles empty datasets stored with `split_by`. 
* `write_vc()` and `meta()` gain a `digits` argument.
  The arguments specifies the number of significant digits to store for numeric
  values.

# git2rdata 0.4.1

* Add `update_metadata()` to update the description of a `git2rdata` object.
  See `vignette("metadata")` for more details.
* Update the checklist and pkgdown infrastructure.

# git2rdata 0.4.0

## New features

* `write_vc()` stores non optimised files as comma separated values rather than
  tab separated values.
  The general public seems to better recognised `.csv` files than `.tsv` files
  as being data files.
* Add a new function `verify_vc()` which reads a `git2rdata` object and verifies
  the presence of a set of variables.
  It return the data upon success.

## Internal changes

* Upgrade to Roxygen2 7.1.2
* Add `inst/CITATION`, `CITATION.cff`, `.zenodo.json`

# git2rdata 0.3.1

* Use `icuSetCollate()` to define a standardised sorting.

# git2rdata 0.3.0

## New features

* `write_vc()` gains an optional `split_by` argument.
  See `vignette("split_by")` for more details.
* `rename_variable()` efficiently renames variables in a stored `git2rdata`
  object.

## Bugfixes

* `read_vc()`, `is_git2rdata()` and `is_git2rmeta()` now yield a better message
  when both the data and metadata are missing.

# git2rdata 0.2.2

* Use the [checklist](https://packages.inbo.be/checklist/) package for CI.

# git2rdata 0.2.1

## Bugfixes

* Explicitly use the `stringsAsFactors` of `data.frame()` in the examples and 
  unit tests if the dataframe contains characters. 
  The upcoming change in default value of `stringsAsFactors` requires this 
  change. 
  See https://developer.r-project.org/Blog/public/2020/02/16/stringsasfactors/index.html

# git2rdata 0.2.0

## BREAKING FEATURES

* Calculation of data hash has changed (#53). 
  You must use `upgrade_data()` to read data stored by an older version.
* `is_git2rdata()` and `upgrade_data()` no longer not test equality in data
  hashes (but `read_vc()` still does).
* `write_vc()` and `read_vc()` fail when `file` is a location outside of `root`
  (#50).
* Reordering factor levels requires `strict = TRUE`.

## Bugfixes

* Linux and Windows machines now generated the same data hash (#49).

## NEW FEATURES

* Internal sorting uses the "C" locale, regardless of the current locale.
* `read_vc()` reads older stored in an older version (#44). 
  When the version is too old, it prompts to `upgrade_data()`.
* Improve `warnings()` and `error()` messages.
* Use vector version of logo.

# git2rdata 0.1

* Transfer to rOpenSci.
* Use new logo (@peterdesmet, #37).
* Add estimate of upper bound of the number of commits.

# git2rdata 0.0.5

* `upgrade_data()` uses the same order of the metadata as `write_vc()`.

# git2rdata 0.0.4

## BREAKING FEATURES

* `write_vc()` stores the `git2rdata` version number to the metadata.
  Use `upgrade_data()` to update existing data.

## NEW FEATURES

* `read_vc()` checks the meta data hash. A mismatch results in an error.
* The meta data gains a data hash.
  A mismatch throws a warning when reading the object.
  This tolerates updating the data by other software, while informing the user
  that such change occurred.
* `is_git2rmeta()` validates metadata.
* `list_data()` lists files with valid metadata. 
* `rm_data()` and `prune_meta()` remove files with valid metadata. 
  They don't touch `tsv` file without metadata or `yml` files not associated
  with `git2rdata`.
* Files with invalid metadata yield a warning with `list_data()`, `rm_data()`
  and `prune_meta()`.

## Bugfixes

* `write_vc()` and `relabel()` handle empty strings (`''`) in characters and 
  factors (#24).
* `read_vc()` no longer treats `#` as a comment character.
* `read_vc()` handles non ASCII characters on Windows.

## Other changes

* Use a faster algorithm to detect duplicates (suggestion by @brodieG). 
* Improve documentation.
* Fix typo's in documentation, vignettes and README.
* Add a rOpenSci review badge to the README.
* The README mentions on upper bound on the size of dataframes.
* Set lifecycle to "maturing" and repo status to "active".
* The functions handle `root` containing regex expressions.
* Rework `vignette("workflow", package = "git2rdata")`.
* Update timings in `vignette("efficiency", package = "git2rdata")`
* Minor tweaks in `vignette("plain_text", package = "git2rdata")`

# git2rdata 0.0.3

* Fix typo's in documentation, vignettes and README.

# git2rdata 0.0.2

## BREAKING CHANGES

* `meta()` appends the metadata as a list to the objects rather than in YAML
  format.
* `yaml::write_yaml()` writes the metadata list in YAML format.
* `write_vc()` now uses the 'strict' argument instead of 'override'.
* `rm_data()` removes the data files. Use `prune_meta()` to remove left-over
  metadata files (#9).

## NEW FEATURES

* Vignette on [efficiency](https://ropensci.github.io/git2rdata/articles/efficiency.html) added (#2).
* Three separate vignettes instead of one large vignette.
    * Focus on the [plain text format](https://ropensci.github.io/git2rdata/articles/plain_text.html).
    * Focus on [version control](https://ropensci.github.io/git2rdata/articles/version_control.html).
    * Focus on [workflows](https://ropensci.github.io/git2rdata/articles/workflow.html).
* S3 methods replace the old S4 methods (#8).
* Optimized factors use stable indices. Adding or removing levels result in
  smaller diffs (#13).
* Use `relabel()` to alter factor levels without changing their index (#13).
* `write.table()` stores the raw data instead of `readr::write_tsv()` (#7).
  This avoids the `readr` dependency.
* `write_vc()` and `read_vc()` use the current working directory as default root
  (#6, @florisvdh).
* The user can specify a string to code missing values (default = `NA`).
  This allows the storage of the character string `"NA"`.
* `write_vc()` returns a list of issues which potentially result in large diffs.
* `list_data()` returns a vector with dataframes in the repository.

## Other changes

* `write_vc()` allows to use a custom `NA` string.
* Each helpfile contains a working example (#11).
* README updated (#12).
    * Updated the rationale with links to the vignettes.
    * `git2rdata` has a hexagon sticker logo.
    * Add the [![DOI](https://zenodo.org/badge/147685405.svg)](https://zenodo.org/badge/latestdoi/147685405).
    * The installation instructions use `remotes` and build the vignettes.
* We removed `auto_commit()` because of limited extra functionality over
  `git2r::commit()`.

# git2rdata 0.0.1

## NEW FEATURES

* Use `readr` to write and read plain text files.
* Allow storage of strings with "NA" or special characters.
* Handle ordered factors.
* Stop handling complex numbers.
