# List Available Git2rdata Files Containing Data

The function returns the names of all valid git2rdata objects. This
implies `.tsv` files with a matching **valid** metadata file (`.yml`).
**Invalid** metadata files result in a warning. The function ignores
**valid** metadata files without matching raw data (`.tsv`).

## Usage

``` r
list_data(root = ".", path = ".", recursive = TRUE)
```

## Arguments

- root:

  the `root` of the repository. Either a path or a `git-repository`

- path:

  relative `path` from the `root`. Defaults to the `root`

- recursive:

  logical. Should the listing recurse into directories?

## Value

A character vector of git2rdata object names, including their relative
path.

## See also

Other storage:
[`data_package()`](https://ropensci.github.io/git2rdata/reference/data_package.md),
[`display_metadata()`](https://ropensci.github.io/git2rdata/reference/display_metadata.md),
[`prune_meta()`](https://ropensci.github.io/git2rdata/reference/prune_meta.md),
[`read_vc()`](https://ropensci.github.io/git2rdata/reference/read_vc.md),
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

# store a dataframe as git2rdata object. Capture the result to minimise
# screen output
junk <- write_vc(
  iris[1:6, ], "iris", root, sorting = "Sepal.Length", digits = 6
)
# write a standard tab separate file (non git2rdata object)
write.table(iris, file = file.path(root, "standard.tsv"), sep = "\t")
# write a YAML file
yml <- list(
  authors = list(
   "Research Institute for Nature and Forest" = list(
       href = "https://www.inbo.be/en")))
yaml::write_yaml(yml, file = file.path(root, "_pkgdown.yml"))

# list the git2rdata objects
list_data(root)
#> [1] "iris.tsv"
# list the files
list.files(root, recursive = TRUE)
#> [1] "_pkgdown.yml" "iris.tsv"     "iris.yml"     "standard.tsv"

# remove all .tsv files from valid git2rdata objects
rm_data(root, path = ".")
# check the removal of the .tsv file
list.files(root, recursive = TRUE)
#> [1] "_pkgdown.yml" "iris.yml"     "standard.tsv"
list_data(root)
#> character(0)

# remove dangling git2rdata metadata files
prune_meta(root, path = ".")
#> Warning: Invalid metadata files found. See ?is_git2rmeta():
#> _pkgdown.yml
# check the removal of the metadata
list.files(root, recursive = TRUE)
#> [1] "_pkgdown.yml" "standard.tsv"
list_data(root)
#> character(0)


## on git repo

# initialise a git repo using git2r
repo_path <- tempfile("git2rdata-repo-")
dir.create(repo_path)
repo <- git2r::init(repo_path)
git2r::config(repo, user.name = "Alice", user.email = "alice@example.org")

# store a dataframe
write_vc(
  iris[1:6, ], "iris", repo, sorting = "Sepal.Length", stage = TRUE,
  digits = 6
)
#> 09d5bfd6a65e682a4ca030c766348180861568c8 
#>                               "iris.tsv" 
#> f5eda4fcbe143eefc267a51a511110c604848272 
#>                               "iris.yml" 
# check that the dataframe is stored
status(repo)
#> Staged changes:
#>  New:        iris.tsv
#>  New:        iris.yml
#> 
list_data(repo)
#> [1] "iris.tsv"

# commit the current version and check the git repo
commit(repo, "add iris data", session = TRUE)
#> [4b086de] 2025-12-10: add iris data
status(repo)
#> working directory clean

# remove the data files from the repo
rm_data(repo, path = ".")
# check the removal
list_data(repo)
#> character(0)
status(repo)
#> Unstaged changes:
#>  Deleted:    iris.tsv
#> 

# remove dangling metadata
prune_meta(repo, path = ".")
# check the removal
list_data(repo)
#> character(0)
status(repo)
#> Unstaged changes:
#>  Deleted:    iris.tsv
#>  Deleted:    iris.yml
#> 
```
