# Relabel Factor Levels by Updating the Metadata

Imagine the situation where we have a dataframe with a factor variable
and we have stored it with `write_vc(optimize = TRUE)`. The raw data
file contains the factor indices and the metadata contains the link
between the factor index and the corresponding label. See
[`vignette("version_control", package = "git2rdata")`](https://ropensci.github.io/git2rdata/articles/version_control.md).
In such a case, relabelling a factor can be fast and lightweight by
updating the metadata.

## Usage

``` r
relabel(file, root = ".", change)
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

- change:

  either a `list` or a `data.frame`. In case of a `list` is a named
  `list` with named `vectors`. The names of list elements must match the
  names of the variables. The names of the vector elements must match
  the existing factor labels. The values represent the new factor
  labels. In case of a `data.frame` it needs to have the variables
  `factor` (name of the factor), `old` (the old) factor label and `new`
  (the new factor label). `relabel()` ignores all other columns.

## Value

invisible `NULL`.

## See also

Other storage:
[`data_package()`](https://ropensci.github.io/git2rdata/reference/data_package.md),
[`display_metadata()`](https://ropensci.github.io/git2rdata/reference/display_metadata.md),
[`list_data()`](https://ropensci.github.io/git2rdata/reference/list_data.md),
[`prune_meta()`](https://ropensci.github.io/git2rdata/reference/prune_meta.md),
[`read_vc()`](https://ropensci.github.io/git2rdata/reference/read_vc.md),
[`rename_variable()`](https://ropensci.github.io/git2rdata/reference/rename_variable.md),
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
junk <- write_vc(ds, "relabel", repo, sorting = "b", stage = TRUE)
cm <- commit(repo, "initial commit")
# check that the workspace is clean
status(repo)
#> working directory clean

# Define new labels as a list and apply them to the git2rdata object.
new_labels <- list(
  a = list(a2 = "a3")
)
relabel("relabel", repo, new_labels)
# check the changes
read_vc("relabel", repo)
#>    a  b
#> 1 a3 b1
#> 2 a1 b2
#> 
#> Use `display_metadata()` to view the metadata.
# relabel() changed the metadata, not the raw data
status(repo)
#> Unstaged changes:
#>  Modified:   relabel.yml
#> 
git2r::add(repo, "relabel.*")
cm <- commit(repo, "relabel using a list")

# Define new labels as a dataframe and apply them to the git2rdata object
change <- data.frame(
  factor = c("a", "a", "b"),
  old = c("a3", "a1", "b2"),
  new = c("c2", "c1", "b3"),
  stringsAsFactors = TRUE
)
relabel("relabel", repo, change)
# check the changes
read_vc("relabel", repo)
#>    a  b
#> 1 c2 b1
#> 2 c1 b3
#> 
#> Use `display_metadata()` to view the metadata.
# relabel() changed the metadata, not the raw data
status(repo)
#> Unstaged changes:
#>  Modified:   relabel.yml
#> 
```
