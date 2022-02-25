#' Remove Data Files From Git2rdata Objects
#'
#' @description
#' Remove the data (`.tsv`) file from all valid git2rdata objects at the `path`.
#' The metadata remains untouched. A warning lists any git2rdata object with
#' **invalid** metadata. The function keeps any `.tsv` file with
#' invalid metadata or from non-git2rdata objects.
#'
#' Use this function with caution since it will remove all valid data files
#' without asking for confirmation. We strongly recommend to use this
#' function on files under version control. See
#' `vignette("workflow", package = "git2rdata")` for some examples on how to use
#' this.
#' @param path the directory in which to clean all the data files. The directory
#' is relative to `root`.
#' @param recursive remove files in subdirectories too.
#' @return returns invisibly a vector of removed files names. The paths are
#' relative to `root`.
#' @inheritParams write_vc
#' @export
#' @family storage
#' @template example_prune
rm_data <- function(
  root = ".", path = NULL, recursive = TRUE, ...
) {
  UseMethod("rm_data", root)
}

#' @export
rm_data.default <- function(
  root, path = NULL, recursive = TRUE, ...
) {
  stop("a 'root' of class ", class(root), " is not supported", call. = FALSE)
}

#' @export
#' @importFrom assertthat assert_that is.flag
rm_data.character <- function(
  root = ".", path = NULL, recursive = TRUE, ...
) {
  to_do <- list_data(root = root, path = path, recursive = recursive)
  if (length(to_do) == 0) {
    return(to_do)
  }
  file.remove(file.path(root, to_do))

  return(invisible(to_do))
}

#' @export
#' @importFrom assertthat assert_that is.flag
#' @importFrom git2r workdir add
#' @include write_vc.R
#' @param stage stage the changes after removing the files. Defaults to FALSE.
#' @param type Defines the classes of files to remove. `unmodified` are files in
#' the git history and unchanged since the last commit. `modified` are files in
#' the git history and changed since the last commit. `ignored` refers to file
#' listed in a `.gitignore` file. Selecting `modified` will remove both
#' `unmodified` and `modified` data files. Selecting `ìgnored` will remove
#' `unmodified`, `modified` and `ignored` data files. `all` refers to all
#' visible data files, including `untracked` files.
#' @rdname rm_data
rm_data.git_repository <- function(
  root, path = NULL, recursive = TRUE, ..., stage = FALSE,
  type = c("unmodified", "modified", "ignored", "all")
) {
  type <- match.arg(type)
  to_do <- list_data(root = root, path = path, recursive = recursive)
  if (length(to_do) == 0) {
    return(to_do)
  }

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
  to_do <- to_do[!to_do %in% keep]
  if (length(to_do) == 0) {
    return(invisible(NULL))
  }
  file.remove(file.path(workdir(root), to_do))
  if (stage) {
    add(repo = root, path = to_do)
  }

  return(invisible(to_do))
}

#' Prune Metadata Files
#'
#' @description
#' Removes all **valid** metadata (`.yml` files) from the `path` when they don't
#' have accompanying data (`.tsv` file). **Invalid** metadata triggers a warning
#' without removing the metadata file.
#'
#' Use this function with caution since it will remove all valid metadata files
#' without asking for confirmation. We strongly recommend to use this
#' function on files under version control. See
#' `vignette("workflow", package = "git2rdata")` for some examples on how to use
#' this.
#' @inheritParams rm_data
#' @return returns invisibly a vector of removed files names. The paths are
#' relative to `root`.
#' @inheritParams write_vc
#' @export
#' @family storage
#' @template example_prune
prune_meta <- function(
  root = ".", path = NULL, recursive = TRUE, ...
) {
  UseMethod("prune_meta", root)
}

#' @export
prune_meta.default <- function(
  root, path = NULL, recursive = TRUE, ...
) {
  stop("a 'root' of class ", class(root), " is not supported", call. = FALSE)
}

#' @export
#' @importFrom assertthat assert_that is.flag noNA
prune_meta.character <- function(
  root = ".", path = NULL, recursive = TRUE, ...
) {
  assert_that(is.string(root))
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  assert_that(is.string(path))
  path <- file.path(root, path, fsep = "/")
  path <- normalizePath(path, winslash = "/", mustWork = FALSE)
  if (!dir.exists(path)) {
    return(invisible(NULL))
  }
  assert_that(is.flag(recursive), noNA(recursive))

  to_do <- list.files(path = path, pattern = "\\.yml$", recursive = recursive,
                      full.names = TRUE)
  keep <- list.files(path = path, pattern = "\\.tsv$", recursive = recursive,
                     full.names = TRUE)
  keep <- gsub("\\.tsv$", ".yml", keep)
  to_do <- to_do[!to_do %in% keep]
  keep <- list.files(path = path, pattern = "\\.csv$", recursive = recursive,
                     full.names = TRUE)
  keep <- gsub("\\.csv$", ".yml", keep)
  to_do <- to_do[!to_do %in% keep]
  to_do_base <- remove_root(file = to_do, root = root)
  check <- vapply(X = gsub(".yml$", "", to_do_base), FUN = is_git2rmeta,
                  FUN.VALUE = NA, root = root, message = "none")
  if (any(!check)) {
    warning("Invalid metadata files found. See ?is_git2rmeta():\n",
            paste(to_do_base[!check], collapse = "\n"), call. = FALSE)
  }
  to_do <- to_do[check]

  file.remove(to_do)
  to_do <- remove_root(file = to_do, root = root)

  return(invisible(to_do))
}

#' @export
#' @importFrom assertthat assert_that is.flag
#' @importFrom git2r workdir add
#' @include write_vc.R
#' @param stage stage the changes after removing the files. Defaults to `FALSE`.
#' @rdname prune_meta
prune_meta.git_repository <- function(
  root, path = NULL, recursive = TRUE, ..., stage = FALSE
) {
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
    path = path, pattern = "\\.yml$", recursive = recursive, full.names = TRUE
  )
  keep <- list.files(
    path = path, pattern = "\\.[ct]sv$", recursive = recursive,
    full.names = TRUE
  )
  keep <- gsub("\\.[ct]sv$", ".yml", keep)
  to_do <- to_do[!to_do %in% keep]
  if (length(to_do) == 0) {
    return(invisible(NULL))
  }

  if (stage) {
    changed <- unlist(status(
      root, staged = FALSE, unstaged = TRUE, untracked = FALSE, ignored = FALSE
    ))
    changed <- gsub(
      "\\.[ct]sv$", ".yml", file.path(root_wd, changed, fsep = "/")
    )
    if (any(to_do %in% changed)) {
      stop(
        call. = FALSE,
"cannot remove and stage metadata in combination with removed but unstaged data"
      )
    }
  } else {
    changed <- unlist(status(
      root, staged = TRUE, unstaged = FALSE, untracked = FALSE, ignored = FALSE
    ))
    changed <- gsub(
      "\\.[ct]sv$", ".yml", file.path(root_wd, changed, fsep = "/")
    )
    if (any(to_do %in% changed)) {
      warning("data removed and staged, metadata removed but unstaged",
              call. = FALSE)
    }
  }
  file.remove(to_do)
  to_do <- remove_root(file = to_do, root = root_wd)

  if (stage) {
    add(repo = root, path = to_do)
  }
  return(invisible(to_do))
}
