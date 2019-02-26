#' list available data objects in the repository
#' @param root the `root` of the repository. Either a path or a `git-repository`
#' @param path relative `path` from the `root`. Defaults to the `root`
#' @inheritParams base::list.files
#' @export
#' @template example-prune
#' @return a character vector is dataframe names, including their relative path
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

  data_files <- list.files(path, pattern = "\\.tsv$", recursive = TRUE,
                           full.names = TRUE)
  meta_files <- list.files(path, pattern = "\\.yml$", recursive = TRUE,
                           full.names = TRUE)
  data_files <- gsub("\\.tsv$", "", data_files)
  meta_files <- gsub("\\.yml$", "", meta_files)
  data_files <- data_files[data_files %in% meta_files]
  gsub(paste0("^", root, "/"), "", data_files)
}

#' @export
#' @importFrom git2r workdir
list_data.git_repository <- function(root, path = ".", recursive = TRUE) {
  list_data(root = workdir(root), path = path, recursive = recursive)
}
