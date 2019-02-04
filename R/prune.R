#' Remove data files
#'
#' Removes all data (`.tsv` files) from the `path` when they have accompanying metadata (`.yml` file). The metadata remains untouched.
#' @param path the directory in which to clean all the data files
#' @param recursive remove files in subdirectories too
#' @return returns invisibily a vector of removed files names. The paths are
#' relative to `root`.
#' @inheritParams write_vc
#' @export
#' @family storage
rm_data <- function(
  root = ".", path = NULL, recursive = TRUE, ...
){
  UseMethod("rm_data", root)
}

#' @export
rm_data.default <- function(
  root, path = NULL, recursive = TRUE, ...
){
  stop("a 'root' of class ", class(root), " is not supported")
}

#' @export
#' @importFrom assertthat assert_that is.flag
rm_data.character <- function(
  root = ".", path = NULL, recursive = TRUE, ...
){
  assert_that(is.string(root))
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  assert_that(is.string(path))
  path <- file.path(root, path, fsep = "/")
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
#' @importFrom git2r workdir add
#' @include write_vc.R
#' @param stage stage the changes after removing the files. Defaults to FALSE.
#' @param type which classes of files should be removed. `unmodified` are files in the git history and unchanged since the last commit. `modified` are files in the git history and changed since the last commit. `ignored` refers to file listed in a `.gitignore` file. Selecting `modified` will remove both `unmodified` and `modified` data files. Selecting `ìgnored` will remove `unmodified`, `modified` and `ignored` data files. `all` refers to all visible data files, inclusing `untracked` files. The argument can be abbreviated to the first letter.
#' @rdname rm_data
rm_data.git_repository <- function(
  root, path = NULL, recursive = TRUE, ..., stage = FALSE,
  type = c("unmodified", "modified", "ignored", "all")
){
  assert_that(is.string(path))
  assert_that(is.flag(stage))
  type <- match.arg(type)
  root_wd <- workdir(root)
  path <- file.path(root_wd, path, fsep = "/")
  path <- normalizePath(path, winslash = "/", mustWork = FALSE)
  if (!dir.exists(path)) {
    return(invisible(NULL))
  }

  to_do <- list.files(
    path, pattern = "\\.tsv$", recursive = recursive, full.names = TRUE
  )
  yml <- list.files(
    path, pattern = "\\.yml$", recursive = recursive, full.names = TRUE
  )
  yml <- gsub("\\.yml$", ".tsv", yml)
  to_do <- to_do[to_do %in% yml]

  keep <- unlist(switch(type,
    unmodified = status(
      root, staged = TRUE, unstaged = TRUE, untracked = TRUE, ignored = TRUE
    ),
    modified = status(
      root, staged = FALSE, unstaged = FALSE, untracked = TRUE, ignored = TRUE
    ),
    ignored = status(
      root, staged = FALSE, unstaged = FALSE, untracked = TRUE, ignored = FALSE
    ),
    all = list()
  ))
  to_do <- to_do[!to_do %in% file.path(root_wd, keep, fsep = "/")]
  if (length(to_do) == 0) {
    return(invisible(NULL))
  }
  file.remove(to_do)
  to_do <- gsub(sprintf("^%s/(.*)$", root_wd), "\\1", to_do)
  if (stage) {
    add(repo = root, path = to_do)
  }
  return(invisible(to_do))
}

#' Prune metadata files
#'
#' Removes all metadata (`.yml` files) from the `path` when they don't have accompanying data (`.tsv` file).
#' @inheritParams rm_data
#' @return returns invisibily a vector of removed files names. The paths are
#' relative to `root`.
#' @inheritParams write_vc
#' @export
#' @family storage
prune_meta <- function(
  root = ".", path = NULL, recursive = TRUE, ...
){
  UseMethod("prune_meta", root)
}

#' @export
prune_meta.default <- function(
  root, path = NULL, recursive = TRUE, ...
){
  stop("a 'root' of class ", class(root), " is not supported")
}

#' @export
#' @importFrom assertthat assert_that is.flag
prune_meta.character <- function(
  root = ".", path = NULL, recursive = TRUE, ...
){
  assert_that(is.string(root))
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  assert_that(is.string(path))
  path <- file.path(root, path, fsep = "/")
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
#' @importFrom git2r workdir add
#' @include write_vc.R
#' @param stage stage the changes after removing the files. Defaults to FALSE.
#' @rdname prune_meta
prune_meta.git_repository <- function(
  root, path = NULL, recursive = TRUE, ..., stage = FALSE
){
  root_wd <- normalizePath(workdir(root), winslash = "/")
  assert_that(is.string(path))
  path <- file.path(root_wd, path)
  path <- normalizePath(path, winslash = "/", mustWork = FALSE)
  if (!dir.exists(path)) {
    return(invisible(NULL))
  }
  assert_that(is.flag(recursive))
  assert_that(is.flag(stage))

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
  if (length(to_do) == 0) {
    return(invisible(NULL))
  }

  if (stage) {
    changed <- unlist(status(
      root, staged = FALSE, unstaged = TRUE, untracked = FALSE, ignored = FALSE
    ))
    changed <- gsub("\\.tsv$", ".yml", file.path(root_wd, changed, fsep = "/"))
    if (any(to_do %in% changed)) {
      stop("cannot remove and stage metadata when data is removed but unstaged")
    }
  } else {
    changed <- unlist(status(
      root, staged = TRUE, unstaged = FALSE, untracked = FALSE, ignored = FALSE
    ))
    changed <- gsub("\\.tsv$", ".yml", file.path(root_wd, changed, fsep = "/"))
    if (any(to_do %in% changed)) {
      warning("data removed and staged, metadata removed but unstaged")
    }
  }
  file.remove(to_do)
  to_do <- gsub(sprintf("^%s/(.*)$", root_wd), "\\1", to_do)

  if (stage) {
    add(repo = root, path = to_do)
  }
  return(invisible(to_do))
}
