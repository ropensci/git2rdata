# Read a file an verify the presence of variables

Reads the file with
[`read_vc()`](https://ropensci.github.io/git2rdata/reference/read_vc.md).
Then verifies that every variable listed in `variables` is present in
the data.frame.

## Usage

``` r
verify_vc(file, root, variables)
```

## Arguments

- file:

  the name of the git2rdata object. Git2rdata objects cannot have dots
  in their name. The name may include a relative path. `file` is a path
  relative to the `root`. Note that `file` must point to a location
  within `root`.

- root:

  The root of a project. Can be a file path or a `git-repository`.
  Defaults to the current working directory (`"."`).

- variables:

  a character vector with variable names.

## See also

Other storage:
[`data_package()`](https://ropensci.github.io/git2rdata/reference/data_package.md),
[`display_metadata()`](https://ropensci.github.io/git2rdata/reference/display_metadata.md),
[`list_data()`](https://ropensci.github.io/git2rdata/reference/list_data.md),
[`prune_meta()`](https://ropensci.github.io/git2rdata/reference/prune_meta.md),
[`read_vc()`](https://ropensci.github.io/git2rdata/reference/read_vc.md),
[`relabel()`](https://ropensci.github.io/git2rdata/reference/relabel.md),
[`rename_variable()`](https://ropensci.github.io/git2rdata/reference/rename_variable.md),
[`rm_data()`](https://ropensci.github.io/git2rdata/reference/rm_data.md),
[`update_metadata()`](https://ropensci.github.io/git2rdata/reference/update_metadata.md),
[`write_vc()`](https://ropensci.github.io/git2rdata/reference/write_vc.md)
