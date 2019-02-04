#' Prune tsv files
#'
#' Removes all tsv files from the `path` when they have an accompanying yml file
#' @param path the directory in which to clean all the data files
#' @param recursive remove files in subdirectories too
#' @return returns invisibily a vector of removed files names. The paths are
#' relative to `root`.
#' @inheritParams write_vc
#' @export
#' @family storage
prune_tsv <- function(
  root = ".", path = NULL, recursive = TRUE, ...
){
  UseMethod("prune_tsv", root)
}

#' @export
prune_tsv.default <- function(
  root, path = NULL, recursive = TRUE, ...
){
  stop("a 'root' of class ", class(root), " is not supported")
}

#' @export
#' @importFrom assertthat assert_that is.flag
prune_tsv.character <- function(
  root = ".", path = NULL, recursive = TRUE, ...
){
  assert_that(is.string(root))
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  assert_that(is.string(path))
  path <- file.path(root, path)
  path <- normalizePath(path, winslash = "/", mustWork = FALSE)
  if (!dir.exists(path)) {
    return(invisible(NULL))
  }
  assert_that(is.flag(recursive))

  to_do <- list.files(
    path = path,
    pattern = "\\.tsv$",
    recursive = recursive,
    full.names = TRUE
  )
  yml <- list.files(
    path = path,
    pattern = "\\.yml$",
    recursive = recursive,
    full.names = TRUE
  )
  yml <- gsub("\\.yml$", ".tsv", yml)
  to_do <- to_do[to_do %in% yml]
  file.remove(to_do)
  to_do <- gsub(paste0("^", root, "/"), "", to_do)

  return(invisible(to_do))
}

#' @export
#' @importFrom assertthat assert_that is.flag
#' @importFrom git2r add
#' @include write_vc.R
#' @param stage stage the changes after removing the files. Defaults to FALSE.
#' @rdname prune_tsv
prune_tsv.git_repository <- function(
  root, path = NULL, recursive = TRUE, ..., stage = FALSE
){
  assert_that(is.flag(stage))
  removed <- prune_tsv(
    root = workdir(root), path = path, recursive = recursive, ...
  )
  if (stage && !is.null(removed)) {
    add(repo = root, path = removed)
  }
  return(invisible(removed))
}

#' Prune yml files
#'
#' Removes all yml files from the `path` when they don't have an accompanying tsv file
#' @inheritParams prune_tsv
#' @return returns invisibily a vector of removed files names. The paths are
#' relative to `root`.
#' @inheritParams write_vc
#' @export
#' @family storage
prune_yml <- function(
  root = ".", path = NULL, recursive = TRUE, ...
){
  UseMethod("prune_yml", root)
}

#' @export
prune_yml.default <- function(
  root, path = NULL, recursive = TRUE, ...
){
  stop("a 'root' of class ", class(root), " is not supported")
}

#' @export
#' @importFrom assertthat assert_that is.flag
prune_yml.character <- function(
  root = ".", path = NULL, recursive = TRUE, ...
){
  assert_that(is.string(root))
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  assert_that(is.string(path))
  path <- file.path(root, path)
  path <- normalizePath(path, winslash = "/", mustWork = FALSE)
  if (!dir.exists(path)) {
    return(invisible(NULL))
  }
  assert_that(is.flag(recursive))

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
  file.remove(to_do)
  to_do <- gsub(paste0("^", root, "/"), "", to_do)

  return(invisible(to_do))
}

#' @export
#' @importFrom assertthat assert_that is.flag
#' @importFrom git2r add
#' @include write_vc.R
#' @param stage stage the changes after removing the files. Defaults to FALSE.
#' @rdname prune_yml
prune_yml.git_repository <- function(
  root, path = NULL, recursive = TRUE, ..., stage = FALSE
){
  assert_that(is.flag(stage))
  removed <- prune_yml(
    root = workdir(root), path = path, recursive = recursive, ...
  )
  if (stage && !is.null(removed)) {
    add(repo = root, path = removed)
  }
  return(invisible(removed))
}
