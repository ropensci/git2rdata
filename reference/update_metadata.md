# Update the description of a `git2rdata` object

Allows to update the description of the fields, the table name, the
title, and the description of a `git2rdata` object. All arguments are
optional. Setting an argument to `NA` or an empty string will remove the
corresponding field from the metadata.

## Usage

``` r
update_metadata(
  file,
  root = ".",
  field_description,
  name,
  title,
  description,
  ...
)
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

- field_description:

  a named character vector with the new descriptions for the fields. The
  names of the vector must match the variable names.

- name:

  a character string with the new table name of the object.

- title:

  a character string with the new title of the object.

- description:

  a character string with the new description of the object.

- ...:

  parameters used in some methods

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
[`verify_vc()`](https://ropensci.github.io/git2rdata/reference/verify_vc.md),
[`write_vc()`](https://ropensci.github.io/git2rdata/reference/write_vc.md)
