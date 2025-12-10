#' Retrieve the Most Recent File Change
#'
#' @description
#' Retrieve the most recent commit that added or updated a file or git2rdata
#' object. This does not imply that file still exists at the current HEAD as it
#' ignores the deletion of files.
#'
#' Use this information to document the current version of file or git2rdata
#' object in an analysis. Since it refers to the most recent change of this
#' file, it remains unchanged by committing changes to other files. You can
#' also use it to track if data got updated, requiring an analysis to
#' be rerun. See `vignette("workflow", package = "git2rdata")`.
#' @inheritParams write_vc
#' @param root The root of a project. Can be a file path or a `git-repository`.
#' @param data does `file` refers to a data object (`TRUE`) or to a file
#' (`FALSE`)?
#' Defaults to `FALSE`.
#' @return a `data.frame` with `commit`, `author` and `when` for the most recent
#' commit that adds op updates the file.
#' @export
#' @family version_control
#' @examples
#' # initialise a git repo using git2r
#' repo_path <- tempfile("git2rdata-repo")
#' dir.create(repo_path)
#' repo <- git2r::init(repo_path)
#' git2r::config(repo, user.name = "Alice", user.email = "alice@example.org")
#'
#' # write and commit a first dataframe
#' # store the output of write_vc() minimize screen output
#' junk <- write_vc(
#'   iris[1:6, ], "iris", repo, sorting = "Sepal.Length", stage = TRUE,
#'   digits = 6
#' )
#' commit(repo, "important analysis", session = TRUE)
#' list.files(repo_path)
#'
#' # write and commit a second dataframe
#' junk <- write_vc(
#'   iris[7:12, ], "iris2", repo, sorting = "Sepal.Length", stage = TRUE,
#'   digits = 6
#' )
#' commit(repo, "important analysis", session = TRUE)
#' list.files(repo_path)
#'
#' # write and commit a new version of the first dataframe
#' junk <- write_vc(iris[7:12, ], "iris", repo, stage = TRUE)
#' list.files(repo_path)
#' commit(repo, "important analysis", session = TRUE)
#'
#' # find out in which commit a file was last changed
#'
#' # "iris.tsv" was last updated in the third commit
#' recent_commit("iris.tsv", repo)
#' # "iris.yml" was last updated in the first commit
#' recent_commit("iris.yml", repo)
#' # "iris2.yml" was last updated in the second commit
#' recent_commit("iris2.yml", repo)
#' # the git2rdata object "iris" was last updated in the third commit
#' recent_commit("iris", repo, data = TRUE)
recent_commit <- function(file, root, data = FALSE) {
  UseMethod("recent_commit", root)
}

#' @export
recent_commit.default <- function(file, root, data = FALSE) {
  stop("a 'root' of class ", class(root), " is not supported", call. = FALSE)
}

#' @export
#' @importFrom assertthat assert_that is.string is.flag noNA
#' @importFrom git2r blame commits
#' @importFrom utils file_test head
recent_commit.git_repository <- function(file, root, data = FALSE) {
  assert_that(is.string(file), is.flag(data), noNA(data))

  if (data) {
    file <- paste(file, c("tsv", "csv"), sep = ".")
  }
  dirname(root$path) |>
    file.path(file) |>
    file_test(op = "-f") |>
    which() |>
    head(1) -> relevant
  stopifnot("`file` not found in current checkout" = length(relevant) == 1)
  blamed <- blame(repo = root, path = file[relevant])
  vapply(
    blamed$hunks,
    FUN = function(x) {
      c(
        commit = x$final_commit_id,
        author = x$final_signature$name,
        when = as.character(x$final_signature$when)
      )
    },
    FUN.VALUE = character(3)
  ) |>
    t() |>
    unique() |>
    as.data.frame() -> commits
  commits$when <- as.POSIXct(commits$when, tz = "GMT")
  commits(repo = root) |>
    vapply(FUN = `[[`, FUN.VALUE = character(1), "sha") -> hashes
  vapply(commits$commit, grep, hashes, FUN.VALUE = integer(1)) |>
    which.min() -> most_recent
  commits[commits$commit == names(most_recent), ]
}
