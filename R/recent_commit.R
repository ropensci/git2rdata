#' Most recent file change
#'
#' Retrieve the most recent commit in which a file or data object was added or updated.
#' @inheritParams write_vc
#' @param root The root of a project. Can be a file path or a `git-repository`
#' @param data does `file` refers to a data object (TRUE) or to a file (FALSE).
#' Defaults to FALSE.
#' @return a `data.frame` with `commit`, `author` and `when` for the most recent
#' commit in which the file was altered
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
#' write_vc(iris[1:6, ], "iris", repo, sorting = "Sepal.Length", stage = TRUE)
#' commit(repo, "important analysis", session = TRUE)
#' list.files(repo_path)
#' Sys.sleep(1.1) # required because git doesn't handle subsecond timings
#'
#' # write and commit a second dataframe
#' write_vc(iris[7:12, ], "iris2", repo, sorting = "Sepal.Length", stage = TRUE)
#' commit(repo, "important analysis", session = TRUE)
#' list.files(repo_path)
#' Sys.sleep(1.1) # required because git doesn't handle subsecond timings
#'
#' # write and commit a new version of the first dataframe
#' write_vc(iris[7:12, ], "iris", repo, stage = TRUE)
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
#' # the data object "iris" was last updated in the third commit
#' recent_commit("iris", repo, data = TRUE)
#'
#' # remove a dataframe and commit it
#' file.remove(file.path(repo_path, "iris.tsv"))
#' prune_meta(repo, ".")
#' commit(repo, message = "remove iris", all = TRUE, session = TRUE)
#'
#' # still points to the third commit as it is the latest commit in which the
#' # data was present
#' recent_commit("iris", repo, data = TRUE)
recent_commit <- function(file, root, data = FALSE){
  UseMethod("recent_commit", root)
}

#' @export
#' @importFrom assertthat assert_that is.string is.flag
#' @importFrom git2r odb_blobs last_commit
recent_commit.git_repository <- function(file, root, data = FALSE) {
  assert_that(is.string(file), is.flag(data))

  if (isTRUE(data)) {
    file <- clean_data_path(root = ".", file, normalize = FALSE)
  }
  name <- basename(file)
  path <- gsub("^\\./?", "", unique(dirname(file)))
  blobs <- odb_blobs(root)
  blobs <- blobs[blobs$path == path & blobs$name %in% name, ]
  blobs <- blobs[blobs$when <= as.data.frame(last_commit(root))$when, ]
  blobs <- blobs[blobs$when == max(blobs$when), c("commit", "author", "when")]
  blobs <- unique(blobs)
  if (nrow(blobs) > 1) {
      warning("Multiple commits within the same second")
  }
  rownames(blobs) <- NULL
  blobs
}
