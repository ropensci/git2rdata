# Upgrade Files to the New Version

Updates the data written by older versions to the current data format
standard. Works both on a single file and (recursively) on a path. The
`".yml"` file must contain a `"..generic"` element. `upgrade_data()`
ignores all other files.

## Usage

``` r
upgrade_data(file, root = ".", verbose, ..., path)

# S3 method for class 'git_repository'
upgrade_data(
  file,
  root = ".",
  verbose = TRUE,
  ...,
  path,
  stage = FALSE,
  force = FALSE
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

- verbose:

  display a message with the update status. Defaults to `TRUE`.

- ...:

  parameters used in some methods

- path:

  specify `path` instead of `file` to update all git2rdata objects in
  this directory and it's subdirectories. `path` is relative to `root`.
  Use `path = "."` to upgrade all git2rdata objects under `root`.

- stage:

  Logical value indicating whether to stage the changes after writing
  the data. Defaults to `FALSE`.

- force:

  Add ignored files. Default is FALSE.

## Value

the git2rdata object names.

## See also

Other internal:
[`is_git2rdata()`](https://ropensci.github.io/git2rdata/reference/is_git2rdata.md),
[`is_git2rmeta()`](https://ropensci.github.io/git2rdata/reference/is_git2rmeta.md),
[`meta()`](https://ropensci.github.io/git2rdata/reference/meta.md),
[`print.git2rdata()`](https://ropensci.github.io/git2rdata/reference/print.git2rdata.md),
[`summary.git2rdata()`](https://ropensci.github.io/git2rdata/reference/summary.git2rdata.md)

## Examples

``` r
# create a directory
root <- tempfile("git2rdata-")
dir.create(root)

# write dataframes to the root
write_vc(
  iris[1:6, ], file = "iris", root = root, sorting = "Sepal.Length",
  digits = 6
)
#> 09d5bfd6a65e682a4ca030c766348180861568c8 
#>                               "iris.tsv" 
#> f5eda4fcbe143eefc267a51a511110c604848272 
#>                               "iris.yml" 
write_vc(
  iris[5:10, ], file = "subdir/iris", root = root, sorting = "Sepal.Length",
  digits = 6
)
#> 6e79e0fe40f73c14a7ffc87da75d5637b5986a23 
#>                        "subdir/iris.tsv" 
#> f5eda4fcbe143eefc267a51a511110c604848272 
#>                        "subdir/iris.yml" 
# upgrade a single git2rdata object
upgrade_data(file = "iris", root = root)
#> iris already up to date
#> meta_file 
#>    "iris" 
# use path = "." to upgrade all git2rdata objects under root
upgrade_data(path = ".", root = root)
#> iris already up to date
#> ./subdir/iris already up to date
#>        ./iris.yml ./subdir/iris.yml 
#>            "iris"   "./subdir/iris" 
```
