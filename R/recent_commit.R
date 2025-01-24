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
#' Sys.sleep(1.1) # required because git doesn't handle subsecond timings
#'
#' # write and commit a second dataframe
#' junk <- write_vc(
#'   iris[7:12, ], "iris2", repo, sorting = "Sepal.Length", stage = TRUE,
#'   digits = 6
#' )
#' commit(repo, "important analysis", session = TRUE)
#' list.files(repo_path)
#' Sys.sleep(1.1) # required because git doesn't handle subsecond timings
#'
#' # write and commit a new version of the first dataframe
#' junk <- write_vc(iris[7:12, ], "iris", repo, stage = TRUE)
#' list.files(repo_path)
#' commit(repo, "important analysis", session = TRUE)
#'
#'
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
#'
#' # remove a dataframe and commit it to see what happens with deleted files
#' file.remove(file.path(repo_path, "iris.tsv"))
#' prune_meta(repo, ".")
#' commit(repo, message = "remove iris", all = TRUE, session = TRUE)
#' list.files(repo_path)
#'
#' # still points to the third commit as this is the latest commit in which the
#' # data was present
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
#' @importFrom git2r odb_blobs last_commit workdir
recent_commit.git_repository <- function(file, root, data = FALSE) {
  assert_that(is.string(file), is.flag(data), noNA(data))

  path <- ifelse(dirname(file) == ".", "", dirname(file))
  if (data) {
    bn <- gsub("\\..*$", "", basename(file))
    name <- paste(bn, c("tsv", "csv"), sep = ".")
  } else {
    name <- basename(file)
  }
  blobs <- odb_blobs(root)
  blobs <- blobs[blobs$path == path & blobs$name %in% name, ]
  blobs <- blobs[blobs$when <= as.data.frame(last_commit(root))$when, ]
  blobs <- blobs[blobs$when == max(blobs$when), c("commit", "author", "when")]
  blobs <- unique(blobs)
  if (nrow(blobs) > 1) {
      warning("More than one commit within the same second", call. = FALSE)
  }
  rownames(blobs) <- NULL
  blobs
}
