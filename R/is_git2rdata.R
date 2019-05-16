#' Check Whether a Git2rdata Object is Valid.
#'
#' A valid git2rdata object has valid metadata. The data hash must match the
#' data hash stored in the metadata.
#' @inheritParams write_vc
#' @inheritParams is_git2rmeta
#' @return A logical value. `TRUE` in case of a valid git2rdata object.
#' Otherwise `FALSE`.
#' @rdname is_git2rdata
#' @export
#' @family internal
#' @template example-isgit2r
is_git2rdata <- function(file, root = ".",
                         message = c("none", "warning", "error")) {
  UseMethod("is_git2rdata", root)
}

#' @export
is_git2rdata.default <- function(file, root, message) {
  stop("a 'root' of class ", class(root), " is not supported")
}

#' @export
#' @importFrom assertthat assert_that is.string
#' @importFrom yaml read_yaml as.yaml
#' @importFrom utils packageVersion
#' @importFrom git2r hash
is_git2rdata.character <- function(file, root = ".",
                                   message = c("none", "warning", "error")) {
  assert_that(is.string(file), is.string(root))
  message <- match.arg(message)
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  check_meta <- is_git2rmeta(file = file, root = root, message = message)
  if (!check_meta) {
    return(FALSE)
  }
  file <- clean_data_path(root = root, file = file)

  if (!file.exists(file["raw_file"])) {
    msg <- "Data file missing."
    switch(message, error = stop(msg), warning = warning(msg))
    return(FALSE)
  }

  # read the metadata
  meta_data <- read_yaml(file["meta_file"])

  correct <- names(meta_data)
  correct <- paste(correct[correct != "..generic"], collapse = "\t")
  header <- readLines(file["raw_file"], n = 1, encoding = "UTF-8")
  if (correct != header) {
    msg <- paste("Corrupt data, incorrect header. Expecting:", correct)
    switch(message, error = stop(msg), warning = warning(msg))
    return(FALSE)
  }

  if (meta_data[["..generic"]][["data_hash"]] != hashfile(file[["raw_file"]])) {
    msg <- "Corrupt data, mismatching data hash."
    switch(message, error = stop(msg), warning = warning(msg))
    return(FALSE)
  }

  return(TRUE)
}

#' @export
#' @importFrom git2r workdir
#' @include write_vc.R
is_git2rdata.git_repository <- function(
  file, root, message = c("none", "warning", "error")) {
  is_git2rdata(file = file, root = workdir(root), message = message)
}
