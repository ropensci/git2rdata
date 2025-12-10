# Retrieve the Most Recent File Change

Retrieve the most recent commit that added or updated a file or
git2rdata object. This does not imply that file still exists at the
current HEAD as it ignores the deletion of files.

Use this information to document the current version of file or
git2rdata object in an analysis. Since it refers to the most recent
change of this file, it remains unchanged by committing changes to other
files. You can also use it to track if data got updated, requiring an
analysis to be rerun. See
[`vignette("workflow", package = "git2rdata")`](https://ropensci.github.io/git2rdata/articles/workflow.md).

## Usage

``` r
recent_commit(file, root, data = FALSE)
```

## Arguments

- file:

  the name of the git2rdata object. Git2rdata objects cannot have dots
  in their name. The name may include a relative path. `file` is a path
  relative to the `root`. Note that `file` must point to a location
  within `root`.

- root:

  The root of a project. Can be a file path or a `git-repository`.

- data:

  does `file` refers to a data object (`TRUE`) or to a file (`FALSE`)?
  Defaults to `FALSE`.

## Value

a `data.frame` with `commit`, `author` and `when` for the most recent
commit that adds op updates the file.

## See also

Other version_control:
[`commit()`](https://ropensci.github.io/git2rdata/reference/commit.md),
[`pull()`](https://ropensci.github.io/git2rdata/reference/pull.md),
[`push()`](https://ropensci.github.io/git2rdata/reference/push.md),
[`repository()`](https://ropensci.github.io/git2rdata/reference/repository.md),
[`status()`](https://ropensci.github.io/git2rdata/reference/status.md)

## Examples

``` r
# initialise a git repo using git2r
repo_path <- tempfile("git2rdata-repo")
dir.create(repo_path)
repo <- git2r::init(repo_path)
git2r::config(repo, user.name = "Alice", user.email = "alice@example.org")

# write and commit a first dataframe
# store the output of write_vc() minimize screen output
junk <- write_vc(
  iris[1:6, ], "iris", repo, sorting = "Sepal.Length", stage = TRUE,
  digits = 6
)
commit(repo, "important analysis", session = TRUE)
#> [abdb05e] 2025-12-10: important analysis
list.files(repo_path)
#> [1] "iris.tsv" "iris.yml"

# write and commit a second dataframe
junk <- write_vc(
  iris[7:12, ], "iris2", repo, sorting = "Sepal.Length", stage = TRUE,
  digits = 6
)
commit(repo, "important analysis", session = TRUE)
#> [dbe87bc] 2025-12-10: important analysis
list.files(repo_path)
#> [1] "iris.tsv"  "iris.yml"  "iris2.tsv" "iris2.yml"

# write and commit a new version of the first dataframe
junk <- write_vc(iris[7:12, ], "iris", repo, stage = TRUE)
list.files(repo_path)
#> [1] "iris.tsv"  "iris.yml"  "iris2.tsv" "iris2.yml"
commit(repo, "important analysis", session = TRUE)
#> [b887da5] 2025-12-10: important analysis

# find out in which commit a file was last changed

# "iris.tsv" was last updated in the third commit
recent_commit("iris.tsv", repo)
#>                                     commit author                when
#> 2 b887da59fe4cff79f563a5c7168cb05c76601971  Alice 2025-12-10 13:32:20
# "iris.yml" was last updated in the first commit
recent_commit("iris.yml", repo)
#>                                     commit author                when
#> 2 b887da59fe4cff79f563a5c7168cb05c76601971  Alice 2025-12-10 13:32:20
# "iris2.yml" was last updated in the second commit
recent_commit("iris2.yml", repo)
#>                                     commit author                when
#> 1 dbe87bc371848050e86b2a5841d2de58271dc619  Alice 2025-12-10 13:32:20
# the git2rdata object "iris" was last updated in the third commit
recent_commit("iris", repo, data = TRUE)
#>                                     commit author                when
#> 2 b887da59fe4cff79f563a5c7168cb05c76601971  Alice 2025-12-10 13:32:20
```
