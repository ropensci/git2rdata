# Read a Git2rdata Object from Disk

`read_vc()` handles git2rdata objects stored by
[`write_vc()`](https://ropensci.github.io/git2rdata/reference/write_vc.md).
It reads and verifies the metadata file (`.yml`). Then it reads and
verifies the raw data. The last step is back-transforming any
transformation done by
[`meta()`](https://ropensci.github.io/git2rdata/reference/meta.md) to
return the `data.frame` as stored by
[`write_vc()`](https://ropensci.github.io/git2rdata/reference/write_vc.md).

`read_vc()` is an S3 generic on `root` which currently handles
`"character"` (a path) and `"git-repository"` (from `git2r`). S3 methods
for other version control system could be added.

## Usage

``` r
read_vc(file, root = ".")
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

## Value

The `data.frame` with the file names and hashes as attributes. It has
the additional class `"git2rdata"` to support extra methods to display
the descriptions.

## See also

Other storage:
[`data_package()`](https://ropensci.github.io/git2rdata/reference/data_package.md),
[`display_metadata()`](https://ropensci.github.io/git2rdata/reference/display_metadata.md),
[`list_data()`](https://ropensci.github.io/git2rdata/reference/list_data.md),
[`prune_meta()`](https://ropensci.github.io/git2rdata/reference/prune_meta.md),
[`relabel()`](https://ropensci.github.io/git2rdata/reference/relabel.md),
[`rename_variable()`](https://ropensci.github.io/git2rdata/reference/rename_variable.md),
[`rm_data()`](https://ropensci.github.io/git2rdata/reference/rm_data.md),
[`update_metadata()`](https://ropensci.github.io/git2rdata/reference/update_metadata.md),
[`verify_vc()`](https://ropensci.github.io/git2rdata/reference/verify_vc.md),
[`write_vc()`](https://ropensci.github.io/git2rdata/reference/write_vc.md)

## Examples

``` r
## on file system

# create a directory
root <- tempfile("git2rdata-")
dir.create(root)

# write a dataframe to the directory
write_vc(
  iris[1:6, ], file = "iris", root = root, sorting = "Sepal.Length",
  digits = 6
)
#> 09d5bfd6a65e682a4ca030c766348180861568c8 
#>                               "iris.tsv" 
#> f5eda4fcbe143eefc267a51a511110c604848272 
#>                               "iris.yml" 
# check that a data file (.tsv) and a metadata file (.yml) exist.
list.files(root, recursive = TRUE)
#> [1] "iris.tsv" "iris.yml"
# read the git2rdata object from the directory
read_vc("iris", root)
#>   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
#> 1          4.6         3.1          1.5         0.2  setosa
#> 2          4.7         3.2          1.3         0.2  setosa
#> 3          4.9         3.0          1.4         0.2  setosa
#> 4          5.0         3.6          1.4         0.2  setosa
#> 5          5.1         3.5          1.4         0.2  setosa
#> 6          5.4         3.9          1.7         0.4  setosa
#> 
#> Use `display_metadata()` to view the metadata.

# store a new version with different observations but the same metadata
write_vc(iris[1:5, ], "iris", root)
#> 31ff841b58e569e8a4a4ac2f02152295c19f94db 
#>                               "iris.tsv" 
#> f5eda4fcbe143eefc267a51a511110c604848272 
#>                               "iris.yml" 
list.files(root, recursive = TRUE)
#> [1] "iris.tsv" "iris.yml"
# Removing a column requires version requires new metadata.
# Add strict = FALSE to override the existing metadata.
write_vc(
  iris[1:6, -2], "iris", root, sorting = "Sepal.Length", strict = FALSE
)
#> Warning: Changes in the metadata may lead to unnecessarily large diffs.
#> See vignette('version_control', package = 'git2rdata') for more information.
#> 
#> - New data has a different number of variables.
#> - Deleted variables: Sepal.Width.
#> b2098d507b0d749a86bb61a185ab2d31f7622418 
#>                               "iris.tsv" 
#> 08179205a52ffe296818ef844180093eaaadfe00 
#>                               "iris.yml" 
list.files(root, recursive = TRUE)
#> [1] "iris.tsv" "iris.yml"
# storing the original version again requires another update of the metadata
write_vc(iris[1:6, ], "iris", root, sorting = "Sepal.Width", strict = FALSE)
#> Warning: Changes in the metadata may lead to unnecessarily large diffs.
#> See vignette('version_control', package = 'git2rdata') for more information.
#> 
#> - The sorting variables changed.
#>     - Sorting for the new data: 'Sepal.Width'.
#>     - Sorting for the old data: 'Sepal.Length'.
#> - New data has a different number of variables.
#> - New variables: Sepal.Width.
#> 4045436d3a61801f4eaad5769e32726838deecbc 
#>                               "iris.tsv" 
#> 4e0919ca66a485cf0e198981782f3cd122d10fef 
#>                               "iris.yml" 
list.files(root, recursive = TRUE)
#> [1] "iris.tsv" "iris.yml"
# optimize = FALSE stores the data more verbose. This requires larger files.
write_vc(
  iris[1:6, ], "iris2", root, sorting = "Sepal.Width", optimize = FALSE,
  digits = 6
)
#> 79547bc5fecc2c82bd01988d1591130e578fdcf9 
#>                              "iris2.csv" 
#> 4f86db2012b3267f1a50131945158aead6d918ec 
#>                              "iris2.yml" 
list.files(root, recursive = TRUE)
#> [1] "iris.tsv"  "iris.yml"  "iris2.csv" "iris2.yml"



## on git repo using a git2r::git-repository

# initialise a git repo using the git2r package
repo_path <- tempfile("git2rdata-repo-")
dir.create(repo_path)
repo <- git2r::init(repo_path)
git2r::config(repo, user.name = "Alice", user.email = "alice@example.org")

# store a dataframe in git repo.
write_vc(
  iris[1:6, ], file = "iris", root = repo, sorting = "Sepal.Length",
  digits = 6
)
#> 09d5bfd6a65e682a4ca030c766348180861568c8 
#>                               "iris.tsv" 
#> f5eda4fcbe143eefc267a51a511110c604848272 
#>                               "iris.yml" 
# This git2rdata object is not staged by default.
status(repo)
#> Untracked files:
#>  Untracked:  iris.tsv
#>  Untracked:  iris.yml
#> 
# read a dataframe from a git repo
read_vc("iris", repo)
#>   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
#> 1          4.6         3.1          1.5         0.2  setosa
#> 2          4.7         3.2          1.3         0.2  setosa
#> 3          4.9         3.0          1.4         0.2  setosa
#> 4          5.0         3.6          1.4         0.2  setosa
#> 5          5.1         3.5          1.4         0.2  setosa
#> 6          5.4         3.9          1.7         0.4  setosa
#> 
#> Use `display_metadata()` to view the metadata.

# store a new version in the git repo and stage it in one go
write_vc(iris[1:5, ], "iris", repo, stage = TRUE)
#> 31ff841b58e569e8a4a4ac2f02152295c19f94db 
#>                               "iris.tsv" 
#> f5eda4fcbe143eefc267a51a511110c604848272 
#>                               "iris.yml" 
status(repo)
#> Staged changes:
#>  New:        iris.tsv
#>  New:        iris.yml
#> 

# store a verbose version in a different gir2data object
write_vc(
  iris[1:6, ], "iris2", repo, sorting = "Sepal.Width", optimize = FALSE,
  digits = 6
)
#> 79547bc5fecc2c82bd01988d1591130e578fdcf9 
#>                              "iris2.csv" 
#> 4f86db2012b3267f1a50131945158aead6d918ec 
#>                              "iris2.yml" 
status(repo)
#> Untracked files:
#>  Untracked:  iris2.csv
#>  Untracked:  iris2.yml
#> 
#> Staged changes:
#>  New:        iris.tsv
#>  New:        iris.yml
#> 
```
