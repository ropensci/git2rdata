# Check Whether a Git2rdata Object Has Valid Metadata.

Valid metadata is a file with `.yml` extension. It has a top level item
`..generic`. This item contains `git2rdata` (the version number), `hash`
(a hash on the metadata) and `data_hash` (a hash on the data file). The
version number must be the current version.

## Usage

``` r
is_git2rmeta(file, root = ".", message = c("none", "warning", "error"))
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

- message:

  a single value indicating the type of messages on top of the logical
  value. `"none"`: no messages, `"warning"`: issue a warning in case of
  an invalid metadata file. `"error"`: an invalid metadata file results
  in an error. Defaults to `"none"`.

## Value

A logical value. `TRUE` in case of a valid metadata file. Otherwise
`FALSE`.

## See also

Other internal:
[`is_git2rdata()`](https://ropensci.github.io/git2rdata/reference/is_git2rdata.md),
[`meta()`](https://ropensci.github.io/git2rdata/reference/meta.md),
[`print.git2rdata()`](https://ropensci.github.io/git2rdata/reference/print.git2rdata.md),
[`summary.git2rdata()`](https://ropensci.github.io/git2rdata/reference/summary.git2rdata.md),
[`upgrade_data()`](https://ropensci.github.io/git2rdata/reference/upgrade_data.md)

## Examples

``` r
# create a directory
root <- tempfile("git2rdata-")
dir.create(root)

# store a file
write_vc(iris[1:6, ], "iris", root, sorting = "Sepal.Length", digits = 6)
#> 09d5bfd6a65e682a4ca030c766348180861568c8 
#>                               "iris.tsv" 
#> f5eda4fcbe143eefc267a51a511110c604848272 
#>                               "iris.yml" 
# check the stored file
is_git2rmeta("iris", root)
#> [1] TRUE
is_git2rdata("iris", root)
#> [1] TRUE

# Remove the metadata from the existing git2rdata object. Then it stops
# being a git2rdata object.
junk <- file.remove(file.path(root, "iris.yml"))
is_git2rmeta("iris", root)
#> [1] FALSE
is_git2rdata("iris", root)
#> [1] FALSE

# recreate the file and remove the data and keep the metadata. It stops being
# a git2rdata object, but the metadata remains valid.
write_vc(iris[1:6, ], "iris", root, sorting = "Sepal.Length", digits = 6)
#> 09d5bfd6a65e682a4ca030c766348180861568c8 
#>                               "iris.tsv" 
#> f5eda4fcbe143eefc267a51a511110c604848272 
#>                               "iris.yml" 
junk <- file.remove(file.path(root, "iris.tsv"))
is_git2rmeta("iris", root)
#> [1] TRUE
is_git2rdata("iris", root)
#> [1] FALSE
```
