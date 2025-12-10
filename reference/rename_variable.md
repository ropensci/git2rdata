# Rename a Variable

The raw data file contains a header with the variable names. The
metadata list the variable names and their type. Changing a variable
name and overwriting the `git2rdata` object with result in an error.
Because it will look like removing an existing variable and adding a new
one. Overwriting the object with `strict = FALSE` potentially changes
the order of the variables, leading to a large diff.

## Usage

``` r
rename_variable(file, change, root = ".", ...)

# S3 method for class 'character'
rename_variable(file, change, root = ".", ...)

# Default S3 method
rename_variable(file, change, root, ...)

# S3 method for class 'git_repository'
rename_variable(file, change, root, ..., stage = FALSE, force = FALSE)
```

## Arguments

- file:

  the name of the git2rdata object. Git2rdata objects cannot have dots
  in their name. The name may include a relative path. `file` is a path
  relative to the `root`. Note that `file` must point to a location
  within `root`.

- change:

  A named vector with the old names as values and the new names as
  names.

- root:

  The root of a project. Can be a file path or a `git-repository`.
  Defaults to the current working directory (`"."`).

- ...:

  parameters used in some methods

- stage:

  Logical value indicating whether to stage the changes after writing
  the data. Defaults to `FALSE`.

- force:

  Add ignored files. Default is FALSE.

## Value

invisible `NULL`.

## Details

This function solves this by only updating the raw data header and the
metadata.

## See also

Other storage:
[`data_package()`](https://ropensci.github.io/git2rdata/reference/data_package.md),
[`display_metadata()`](https://ropensci.github.io/git2rdata/reference/display_metadata.md),
[`list_data()`](https://ropensci.github.io/git2rdata/reference/list_data.md),
[`prune_meta()`](https://ropensci.github.io/git2rdata/reference/prune_meta.md),
[`read_vc()`](https://ropensci.github.io/git2rdata/reference/read_vc.md),
[`relabel()`](https://ropensci.github.io/git2rdata/reference/relabel.md),
[`rm_data()`](https://ropensci.github.io/git2rdata/reference/rm_data.md),
[`update_metadata()`](https://ropensci.github.io/git2rdata/reference/update_metadata.md),
[`verify_vc()`](https://ropensci.github.io/git2rdata/reference/verify_vc.md),
[`write_vc()`](https://ropensci.github.io/git2rdata/reference/write_vc.md)

## Examples

``` r

# initialise a git repo using git2r
repo_path <- tempfile("git2rdata-repo-")
dir.create(repo_path)
repo <- git2r::init(repo_path)
git2r::config(repo, user.name = "Alice", user.email = "alice@example.org")

# Create a dataframe and store it as an optimized git2rdata object.
# Note that write_vc() uses optimization by default.
# Stage and commit the git2rdata object.
ds <- data.frame(
  a = c("a1", "a2"),
  b = c("b2", "b1"),
  stringsAsFactors = TRUE
)
junk <- write_vc(ds, "rename", repo, sorting = "b", stage = TRUE)
cm <- commit(repo, "initial commit")
# check that the workspace is clean
status(repo)
#> working directory clean

# Define change.
change <- c(new_name = "a")
rename_variable(file = "rename", change = change, root = repo)
#> ec551b8fd0164c484d0a68709017d9d547d83bea 
#>                             "rename.tsv" 
#> 34818c45742ac845b073ebbbc87411abb2dc7ac7 
#>                             "rename.yml" 
# check the changes
read_vc("rename", repo)
#>   new_name  b
#> 1       a2 b1
#> 2       a1 b2
#> 
#> Use `display_metadata()` to view the metadata.
status(repo)
#> Unstaged changes:
#>  Modified:   rename.tsv
#>  Modified:   rename.yml
#> 
```
