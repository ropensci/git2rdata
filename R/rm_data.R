#' Remove data files
#'
#' Remove all tsv and/or yml files within the path
#' @param path the directory in which to clean all the data files
#' @param type which file type should be removed
#' @param recursive remove files in subdirectories too
#' @return returns invisibily a vector of removed files names. The paths are
#' relative to `root`.
#' @inheritParams write_vc
#' @export
#' @family storage
rm_data <- function(
  root = ".", path = NULL, type = c("tsv", "yml", "both"), recursive = TRUE, ...
){
  UseMethod("rm_data", root)
}

#' @export
rm_data.default <- function(
  root, path = NULL, type = c("tsv", "yml", "both"), recursive = TRUE, ...
){
  stop("a 'root' of class ", class(root), " is not supported")
}

#' @export
#' @importFrom assertthat assert_that is.flag
rm_data.character <- function(
  root = ".", path = NULL, type = c("tsv", "yml", "both"), recursive = TRUE, ...
){
  assert_that(is.string(root))
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  assert_that(is.string(path))
  path <- file.path(root, path)
  path <- normalizePath(path, winslash = "/", mustWork = FALSE)
  if (!dir.exists(path)) {
    return(invisible(NULL))
  }
  type <- match.arg(type)
  assert_that(is.flag(recursive))

  if (type == "tsv") {
    to_do <- list.files(
      path = path,
      pattern = "\\.tsv$",
      recursive = recursive,
      full.names = TRUE
    )
  } else if (type == "both") {
    to_do <- list.files(
      path = path,
      pattern = "\\.(tsv|yml)$",
      recursive = recursive,
      full.names = TRUE
    )
  } else {
    to_do <- list.files(
      path = path,
      pattern = "\\.yml$",
      recursive = recursive,
      full.names = TRUE
    )
    keep <- list.files(
      path = path,
      pattern = "\\.tsv$",
      recursive = recursive,
      full.names = TRUE
    )
    keep <- gsub("\\.tsv$", ".yml", keep)
    to_do <- to_do[!to_do %in% keep]
  }
  file.remove(to_do)
  to_do <- gsub(paste0("^", root, "/"), "", to_do)

  return(invisible(to_do))
}

#' @export
#' @importFrom assertthat assert_that is.flag
#' @importFrom git2r add
#' @include write_vc.R
#' @param stage stage the changes after removing the files. Defaults to FALSE.
#' @rdname rm_data
rm_data.git_repository <- function(
  root, path = NULL, type = c("tsv", "yml", "both"), recursive = TRUE, ...,
  stage = FALSE
){
  assert_that(is.flag(stage))
  removed <- rm_data(
    root = workdir(root), path = path, type = type, recursive = recursive, ...
  )
  if (stage && !is.null(removed)) {
    add(repo = root, path = removed)
  }
  return(invisible(removed))
}
