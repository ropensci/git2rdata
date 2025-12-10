# Changelog

## git2rdata 0.5.1

- [`write_vc()`](https://ropensci.github.io/git2rdata/reference/write_vc.md)
  stores metadata stored in the data frame.
- [`read_vc()`](https://ropensci.github.io/git2rdata/reference/read_vc.md)
  returns more metadata.
- [`read_vc()`](https://ropensci.github.io/git2rdata/reference/read_vc.md)
  can handle empty factors.
- [`recent_commit()`](https://ropensci.github.io/git2rdata/reference/recent_commit.md)
  now returns handles multiple commits within the same second.

## git2rdata 0.5.0

CRAN release: 2025-01-24

- [`read_vc()`](https://ropensci.github.io/git2rdata/reference/read_vc.md)
  handles empty datasets stored with `split_by`.
- [`write_vc()`](https://ropensci.github.io/git2rdata/reference/write_vc.md)
  and [`meta()`](https://ropensci.github.io/git2rdata/reference/meta.md)
  gain a `digits` argument. The arguments specifies the number of
  significant digits to store for numeric values.

## git2rdata 0.4.1

CRAN release: 2024-09-06

- Add
  [`update_metadata()`](https://ropensci.github.io/git2rdata/reference/update_metadata.md)
  to update the description of a `git2rdata` object. See
  [`vignette("metadata")`](https://ropensci.github.io/git2rdata/articles/metadata.md)
  for more details.
- Update the checklist and pkgdown infrastructure.

## git2rdata 0.4.0

CRAN release: 2022-03-17

### New features

- [`write_vc()`](https://ropensci.github.io/git2rdata/reference/write_vc.md)
  stores non optimised files as comma separated values rather than tab
  separated values. The general public seems to better recognised `.csv`
  files than `.tsv` files as being data files.
- Add a new function
  [`verify_vc()`](https://ropensci.github.io/git2rdata/reference/verify_vc.md)
  which reads a `git2rdata` object and verifies the presence of a set of
  variables. It return the data upon success.

### Internal changes

- Upgrade to Roxygen2 7.1.2
- Add `inst/CITATION`, `CITATION.cff`, `.zenodo.json`

## git2rdata 0.3.1

CRAN release: 2021-01-21

- Use [`icuSetCollate()`](https://rdrr.io/r/base/icuSetCollate.html) to
  define a standardised sorting.

## git2rdata 0.3.0

### New features

- [`write_vc()`](https://ropensci.github.io/git2rdata/reference/write_vc.md)
  gains an optional `split_by` argument. See
  [`vignette("split_by")`](https://ropensci.github.io/git2rdata/articles/split_by.md)
  for more details.
- [`rename_variable()`](https://ropensci.github.io/git2rdata/reference/rename_variable.md)
  efficiently renames variables in a stored `git2rdata` object.

### Bugfixes

- [`read_vc()`](https://ropensci.github.io/git2rdata/reference/read_vc.md),
  [`is_git2rdata()`](https://ropensci.github.io/git2rdata/reference/is_git2rdata.md)
  and
  [`is_git2rmeta()`](https://ropensci.github.io/git2rdata/reference/is_git2rmeta.md)
  now yield a better message when both the data and metadata are
  missing.

## git2rdata 0.2.2

- Use the [checklist](https://packages.inbo.be/checklist/) package for
  CI.

## git2rdata 0.2.1

CRAN release: 2020-03-02

### Bugfixes

- Explicitly use the `stringsAsFactors` of
  [`data.frame()`](https://rdrr.io/r/base/data.frame.html) in the
  examples and unit tests if the dataframe contains characters. The
  upcoming change in default value of `stringsAsFactors` requires this
  change. See
  <https://developer.r-project.org/Blog/public/2020/02/16/stringsasfactors/index.html>

## git2rdata 0.2.0

CRAN release: 2019-11-18

### BREAKING FEATURES

- Calculation of data hash has changed
  ([\#53](https://github.com/ropensci/git2rdata/issues/53)). You must
  use
  [`upgrade_data()`](https://ropensci.github.io/git2rdata/reference/upgrade_data.md)
  to read data stored by an older version.
- [`is_git2rdata()`](https://ropensci.github.io/git2rdata/reference/is_git2rdata.md)
  and
  [`upgrade_data()`](https://ropensci.github.io/git2rdata/reference/upgrade_data.md)
  no longer not test equality in data hashes (but
  [`read_vc()`](https://ropensci.github.io/git2rdata/reference/read_vc.md)
  still does).
- [`write_vc()`](https://ropensci.github.io/git2rdata/reference/write_vc.md)
  and
  [`read_vc()`](https://ropensci.github.io/git2rdata/reference/read_vc.md)
  fail when `file` is a location outside of `root`
  ([\#50](https://github.com/ropensci/git2rdata/issues/50)).
- Reordering factor levels requires `strict = TRUE`.

### Bugfixes

- Linux and Windows machines now generated the same data hash
  ([\#49](https://github.com/ropensci/git2rdata/issues/49)).

### NEW FEATURES

- Internal sorting uses the “C” locale, regardless of the current
  locale.
- [`read_vc()`](https://ropensci.github.io/git2rdata/reference/read_vc.md)
  reads older stored in an older version
  ([\#44](https://github.com/ropensci/git2rdata/issues/44)). When the
  version is too old, it prompts to
  [`upgrade_data()`](https://ropensci.github.io/git2rdata/reference/upgrade_data.md).
- Improve [`warnings()`](https://rdrr.io/r/base/warnings.html) and
  `error()` messages.
- Use vector version of logo.

## git2rdata 0.1

CRAN release: 2019-06-17

- Transfer to rOpenSci.
- Use new logo ([@peterdesmet](https://github.com/peterdesmet),
  [\#37](https://github.com/ropensci/git2rdata/issues/37)).
- Add estimate of upper bound of the number of commits.

## git2rdata 0.0.5

- [`upgrade_data()`](https://ropensci.github.io/git2rdata/reference/upgrade_data.md)
  uses the same order of the metadata as
  [`write_vc()`](https://ropensci.github.io/git2rdata/reference/write_vc.md).

## git2rdata 0.0.4

### BREAKING FEATURES

- [`write_vc()`](https://ropensci.github.io/git2rdata/reference/write_vc.md)
  stores the `git2rdata` version number to the metadata. Use
  [`upgrade_data()`](https://ropensci.github.io/git2rdata/reference/upgrade_data.md)
  to update existing data.

### NEW FEATURES

- [`read_vc()`](https://ropensci.github.io/git2rdata/reference/read_vc.md)
  checks the meta data hash. A mismatch results in an error.
- The meta data gains a data hash. A mismatch throws a warning when
  reading the object. This tolerates updating the data by other
  software, while informing the user that such change occurred.
- [`is_git2rmeta()`](https://ropensci.github.io/git2rdata/reference/is_git2rmeta.md)
  validates metadata.
- [`list_data()`](https://ropensci.github.io/git2rdata/reference/list_data.md)
  lists files with valid metadata.
- [`rm_data()`](https://ropensci.github.io/git2rdata/reference/rm_data.md)
  and
  [`prune_meta()`](https://ropensci.github.io/git2rdata/reference/prune_meta.md)
  remove files with valid metadata. They don’t touch `tsv` file without
  metadata or `yml` files not associated with `git2rdata`.
- Files with invalid metadata yield a warning with
  [`list_data()`](https://ropensci.github.io/git2rdata/reference/list_data.md),
  [`rm_data()`](https://ropensci.github.io/git2rdata/reference/rm_data.md)
  and
  [`prune_meta()`](https://ropensci.github.io/git2rdata/reference/prune_meta.md).

### Bugfixes

- [`write_vc()`](https://ropensci.github.io/git2rdata/reference/write_vc.md)
  and
  [`relabel()`](https://ropensci.github.io/git2rdata/reference/relabel.md)
  handle empty strings (`''`) in characters and factors
  ([\#24](https://github.com/ropensci/git2rdata/issues/24)).
- [`read_vc()`](https://ropensci.github.io/git2rdata/reference/read_vc.md)
  no longer treats `#` as a comment character.
- [`read_vc()`](https://ropensci.github.io/git2rdata/reference/read_vc.md)
  handles non ASCII characters on Windows.

### Other changes

- Use a faster algorithm to detect duplicates (suggestion by
  [@brodieG](https://github.com/brodieG)).
- Improve documentation.
- Fix typo’s in documentation, vignettes and README.
- Add a rOpenSci review badge to the README.
- The README mentions on upper bound on the size of dataframes.
- Set lifecycle to “maturing” and repo status to “active”.
- The functions handle `root` containing regex expressions.
- Rework
  [`vignette("workflow", package = "git2rdata")`](https://ropensci.github.io/git2rdata/articles/workflow.md).
- Update timings in
  [`vignette("efficiency", package = "git2rdata")`](https://ropensci.github.io/git2rdata/articles/efficiency.md)
- Minor tweaks in
  [`vignette("plain_text", package = "git2rdata")`](https://ropensci.github.io/git2rdata/articles/plain_text.md)

## git2rdata 0.0.3

- Fix typo’s in documentation, vignettes and README.

## git2rdata 0.0.2

### BREAKING CHANGES

- [`meta()`](https://ropensci.github.io/git2rdata/reference/meta.md)
  appends the metadata as a list to the objects rather than in YAML
  format.
- [`yaml::write_yaml()`](https://yaml.r-lib.org/reference/write_yaml.html)
  writes the metadata list in YAML format.
- [`write_vc()`](https://ropensci.github.io/git2rdata/reference/write_vc.md)
  now uses the ‘strict’ argument instead of ‘override’.
- [`rm_data()`](https://ropensci.github.io/git2rdata/reference/rm_data.md)
  removes the data files. Use
  [`prune_meta()`](https://ropensci.github.io/git2rdata/reference/prune_meta.md)
  to remove left-over metadata files
  ([\#9](https://github.com/ropensci/git2rdata/issues/9)).

### NEW FEATURES

- Vignette on
  [efficiency](https://ropensci.github.io/git2rdata/articles/efficiency.html)
  added ([\#2](https://github.com/ropensci/git2rdata/issues/2)).
- Three separate vignettes instead of one large vignette.
  - Focus on the [plain text
    format](https://ropensci.github.io/git2rdata/articles/plain_text.html).
  - Focus on [version
    control](https://ropensci.github.io/git2rdata/articles/version_control.html).
  - Focus on
    [workflows](https://ropensci.github.io/git2rdata/articles/workflow.html).
- S3 methods replace the old S4 methods
  ([\#8](https://github.com/ropensci/git2rdata/issues/8)).
- Optimized factors use stable indices. Adding or removing levels result
  in smaller diffs
  ([\#13](https://github.com/ropensci/git2rdata/issues/13)).
- Use
  [`relabel()`](https://ropensci.github.io/git2rdata/reference/relabel.md)
  to alter factor levels without changing their index
  ([\#13](https://github.com/ropensci/git2rdata/issues/13)).
- [`write.table()`](https://rdrr.io/r/utils/write.table.html) stores the
  raw data instead of
  [`readr::write_tsv()`](https://readr.tidyverse.org/reference/write_delim.html)
  ([\#7](https://github.com/ropensci/git2rdata/issues/7)). This avoids
  the `readr` dependency.
- [`write_vc()`](https://ropensci.github.io/git2rdata/reference/write_vc.md)
  and
  [`read_vc()`](https://ropensci.github.io/git2rdata/reference/read_vc.md)
  use the current working directory as default root
  ([\#6](https://github.com/ropensci/git2rdata/issues/6),
  [@florisvdh](https://github.com/florisvdh)).
- The user can specify a string to code missing values (default = `NA`).
  This allows the storage of the character string `"NA"`.
- [`write_vc()`](https://ropensci.github.io/git2rdata/reference/write_vc.md)
  returns a list of issues which potentially result in large diffs.
- [`list_data()`](https://ropensci.github.io/git2rdata/reference/list_data.md)
  returns a vector with dataframes in the repository.

### Other changes

- [`write_vc()`](https://ropensci.github.io/git2rdata/reference/write_vc.md)
  allows to use a custom `NA` string.
- Each helpfile contains a working example
  ([\#11](https://github.com/ropensci/git2rdata/issues/11)).
- README updated
  ([\#12](https://github.com/ropensci/git2rdata/issues/12)).
  - Updated the rationale with links to the vignettes.
  - `git2rdata` has a hexagon sticker logo.
  - Add the
    [![DOI](https://zenodo.org/badge/147685405.svg)](https://zenodo.org/badge/latestdoi/147685405).
  - The installation instructions use `remotes` and build the vignettes.
- We removed `auto_commit()` because of limited extra functionality over
  [`git2r::commit()`](https://docs.ropensci.org/git2r/reference/commit.html).

## git2rdata 0.0.1

### NEW FEATURES

- Use `readr` to write and read plain text files.
- Allow storage of strings with “NA” or special characters.
- Handle ordered factors.
- Stop handling complex numbers.
