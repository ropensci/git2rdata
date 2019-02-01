#' Most recent file change
#' Retrieve the most recent commit in which a file or data object existed.
#' @inheritParams write_vc
#' @param root The root of a project. Can be a file path or a `git-repository`
#' @param data refers file to a file (FALSE) or a data object (TRUE). Defaults
#' to FALSE
#' @return a `data.frame` with `commit`, `author` and `when` for the most recent
#' commit in which the file was altered
#' @export
#' @family version_control
recent_commit <- function(file, root, data = FALSE){
  UseMethod("recent_commit", root)
}

#' @export
#' @importFrom assertthat assert_that is.string is.flag
#' @importFrom git2r odb_blobs
recent_commit.git_repository <- function(file, root, data = FALSE) {
  assert_that(is.string(file))
  assert_that(is.flag(data))

  if (data) {
    file <- clean_data_path(root = ".", file, normalize = FALSE)
  }
  name <- basename(file)
  path <- gsub("^\\./?", "", unique(dirname(file)))
  blobs <- odb_blobs(root)
  blobs <- blobs[blobs$path == path & blobs$name %in% name, ]
  blobs <- blobs[blobs$when == max(blobs$when), c("commit", "author", "when")]
  blobs <- unique(blobs)
  if (nrow(blobs) > 1) {
      warning("Multiple commits within the same second")
  }
  rownames(blobs) <- NULL
  blobs
}
