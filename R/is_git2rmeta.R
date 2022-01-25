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
#' @template example_isgit2r
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
is_git2rmeta.character <- function(
    file, root = ".", message = c("none", "warning", "error")
) {
  assert_that(is.string(file), is.string(root))
  message <- match.arg(message)
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  file <- clean_data_path(root = root, file = file)

  check <- error_warning(
    file.exists(file["meta_file"]),
    msg = ifelse(
      file.exists(file["raw_file"]),
      "Metadata file missing.",
      "`git2rdata` object not found."
    ),
    message = message
  )
  if (!check) {
    return(check)
  }

  # read the metadata
  meta_data <- read_yaml(file["meta_file"])
  check <- error_warning(
    has_name(meta_data, "..generic"),
    msg = "No '..generic' element.",
    message = message, previous = check
  )

  check <- error_warning(
    has_name(meta_data[["..generic"]], "hash"),
    msg = "Corrupt metadata, no hash found.",
    message = message, previous = check
  )

  check <- error_warning(
    has_name(meta_data[["..generic"]], "git2rdata"),
    msg = "Data stored using an older version of `git2rdata`.
See `?upgrade_data()`.",
    message = message, previous = check
  )

  used_version <- package_version(meta_data[["..generic"]][["git2rdata"]])
  check <- error_warning(
    used_version >= package_version("0.4.0") || (
      used_version >= package_version("0.2.0") &&
        meta_data[["..generic"]][["optimize"]]
    ),
    msg = "Data stored using an older version of `git2rdata`.
See `?upgrade_data()`.",
    message = message, previous = check
  )

  check <- error_warning(
    has_name(meta_data[["..generic"]], "data_hash"),
    msg = "Corrupt metadata, no data hash found.",
    message = message, previous = check
  )

  current_hash <- meta_data[["..generic"]][["hash"]]
  check <- error_warning(
    current_hash == metadata_hash(meta_data),
    msg = "Corrupt metadata, mismatching hash.",
    message = message, previous = check
  )

  return(check)
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

error_warning <- function(
  test, msg, message = c("none", "warning", "error"), previous = TRUE
) {
  message <- match.arg(message)
  if (!previous) {
    return(FALSE)
  }
  if (!test) {
    switch(
      message, error = stop(msg, call. = FALSE),
      warning = warning(msg, call. = FALSE)
    )
  }
  return(test)
}
