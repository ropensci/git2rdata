#' Check Whether a Git2rdata Object Has Valid Metadata.
#'
#' Valid metadata is a file with `.yml` extension. It has a top level item
#' `..generic`. This item contains `git2rdata` (the version number), `hash` (a
#' hash on the metadata) and `data_hash` (a hash on the data file). The version
#' number must be the current version.
#' @inheritParams write_vc
#' @param message a single value indicating the type of messages on top of the
#' logical value. `"none"`: no messages, `"warning"`: issue a warning in case of
#' an invalid metadata file. `"error"`: an invalid metadata file results in an
#' error. Defaults to `"none"`.
#' @return A logical value. `TRUE` in case of a valid metadata file. Otherwise
#' `FALSE`.
#' @rdname is_git2rmeta
#' @export
#' @family internal
#' @template example-isgit2r
is_git2rmeta <- function(file, root = ".",
                         message = c("none", "warning", "error")) {
  UseMethod("is_git2rmeta", root)
}

#' @export
is_git2rmeta.default <- function(file, root,
                                 message = c("none", "warning", "error")) {
  stop("a 'root' of class ", class(root), " is not supported", call. = FALSE)
}

#' @export
#' @importFrom assertthat assert_that is.string
#' @importFrom yaml read_yaml
#' @importFrom utils packageVersion
is_git2rmeta.character <- function(file, root = ".",
                                   message = c("none", "warning", "error")) {
  assert_that(is.string(file), is.string(root))
  message <- match.arg(message)
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  file <- clean_data_path(root = root, file = file)

  if (!file.exists(file["meta_file"])) {
    msg <- "Metadata file missing."
    switch(message, error = stop(msg, call. = FALSE),
           warning = warning(msg, call. = FALSE))
    return(FALSE)
  }

  # read the metadata
  meta_data <- read_yaml(file["meta_file"])
  if (!has_name(meta_data, "..generic")) {
    msg <- "No '..generic' element."
    switch(message, error = stop(msg, call. = FALSE),
           warning = warning(msg, call. = FALSE))
    return(FALSE)
  }
  if (!has_name(meta_data[["..generic"]], "hash")) {
    msg <- "Corrupt metadata, no hash found."
    switch(message, error = stop(msg, call. = FALSE),
           warning = warning(msg, call. = FALSE))
    return(FALSE)
  }
  if (!has_name(meta_data[["..generic"]], "git2rdata")) {
    msg <- "Data stored using an older version of `git2rdata`.
See `?upgrade_data()`."
    switch(message, error = stop(msg, call. = FALSE),
           warning = warning(msg, call. = FALSE))
    return(FALSE)
  }
  if (package_version(meta_data[["..generic"]][["git2rdata"]]) <
      package_version("0.1.0.9001")) {
    msg <- "Data stored using an older version of `git2rdata`.
See `?upgrade_data()`."
    switch(message, error = stop(msg, call. = FALSE),
           warning = warning(msg, call. = FALSE))
    return(FALSE)
  }
  if (!has_name(meta_data[["..generic"]], "data_hash")) {
    msg <- "Corrupt metadata, no data hash found."
    switch(message, error = stop(msg, call. = FALSE),
           warning = warning(msg, call. = FALSE))
    return(FALSE)
  }
  current_hash <- meta_data[["..generic"]][["hash"]]
  if (current_hash != metadata_hash(meta_data)) {
    msg <- "Corrupt metadata, mismatching hash."
    switch(message, error = stop(msg, call. = FALSE),
           warning = warning(msg, call. = FALSE))
    return(FALSE)
  }

  return(TRUE)
}

#' @export
#' @importFrom git2r workdir
#' @include write_vc.R
is_git2rmeta.git_repository <- function(
  file, root, message = c("none", "warning", "error")) {
  is_git2rmeta(file = file, root = workdir(root), message = message)
}

#' @importFrom yaml as.yaml
#' @importFrom git2r hash
metadata_hash <- function(meta_data) {
  meta_data[["..generic"]][["git2rdata"]] <- NULL
  meta_data[["..generic"]][["hash"]] <- NULL
  meta_data[["..generic"]][["data_hash"]] <- NULL
  hash(as.yaml(meta_data))
}
