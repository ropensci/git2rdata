#' List Available Git2rdata Files Containing Data
#'
#' The function returns the names of all valid git2rdata objects. This implies
#' `.tsv` files with a matching **valid** metadata file (`.yml`). **Invalid**
#' metadata files result in a warning. The function ignores **valid** metadata
#' files without matching raw data (`.tsv`).
#' @param root the `root` of the repository. Either a path or a `git-repository`
#' @param path relative `path` from the `root`. Defaults to the `root`
#' @inheritParams base::list.files
#' @export
#' @template example-prune
#' @return A character vector of git2rdata object names, including their
#' relative path.
#' @family storage
list_data <- function(root = ".", path = ".", recursive = TRUE) {
  UseMethod("list_data", root)
}

#' @export
list_data.default <- function(root, path, recursive) {
  stop("a 'root' of class ", class(root), " is not supported", call. = FALSE)
}

#' @export
#' @importFrom assertthat assert_that is.string is.flag
list_data.character <- function(root = ".", path = ".", recursive = TRUE) {
  assert_that(is.string(root), is.string(path), is.flag(recursive))
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  path <- normalizePath(file.path(root, path), winslash = "/", mustWork = TRUE)

  data_files <- list.files(path, pattern = "\\.tsv$", recursive = recursive,
                           full.names = TRUE)
  meta_files <- list.files(path, pattern = "\\.yml$", recursive = recursive,
                           full.names = TRUE)
  data_files <- gsub("\\.tsv$", "", data_files)
  meta_files <- gsub("\\.yml$", "", meta_files)
  meta_files <- meta_files[meta_files %in% data_files]
  meta_files_base <- remove_root(file = meta_files, root = root)
  check <- vapply(X = meta_files_base, FUN = is_git2rmeta,
                  FUN.VALUE = NA, root = root, message = "none")
  if (any(!check)) {
    warning("Invalid metadata files found. See ?is_git2rmeta():\n",
            paste(meta_files_base[!check], collapse = "\n"))
  }
  meta_files <- meta_files[check]
  data_files <- data_files[data_files %in% meta_files]
  remove_root(file = data_files, root = root)
}

#' @export
#' @importFrom git2r workdir
list_data.git_repository <- function(root, path = ".", recursive = TRUE) {
  list_data(root = workdir(root), path = path, recursive = recursive)
}
