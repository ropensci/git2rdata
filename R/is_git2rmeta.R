#' Check whether a git2rdata file has valid metadata.
#'
#' Valid metadata is a file with `.yml` extension. It has a top level item
#' `..generic`. This item contains `git2rdata` (the version number), `hash` (a
#' hash on the metadata) and `data_hash` (a hash on the data file). The version
#' number must be the current version.
#' @inheritParams write_vc
#' @param validate Should invalid metadata result in an error. Defaults to
#' `FALSE`.
#' @return A logical value. `TRUE` in case of a valid metadata file. Otherwise
#' `FALSE` or an error depending on `validate`
#' @rdname is_git2rmeta
#' @export
#' @family internal
is_git2rmeta <- function(file, root = ".", validate) {
  UseMethod("is_git2rmeta", root)
}

#' @export
is_git2rmeta.default <- function(file, root, validate) {
  stop("a 'root' of class ", class(root), " is not supported")
}

#' @export
#' @importFrom assertthat assert_that is.string is.flag noNA
#' @importFrom yaml read_yaml as.yaml
#' @importFrom utils packageVersion
#' @importFrom git2r hash
is_git2rmeta.character <- function(file, root = ".", validate = FALSE) {
  assert_that(is.string(file), is.string(root), is.flag(validate),
              noNA(validate))
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
    file <- clean_data_path(root = root, file = file)

  if (!file.exists(file["meta_file"])) {
    if (validate) {
      stop("Metadata file missing.")
    }
    return(FALSE)
  }

  # read the metadata
  meta_data <- read_yaml(file["meta_file"])
  if (!has_name(meta_data, "..generic")) {
    if (validate) {
      stop("No '..generic' element.")
    }
    return(FALSE)
  }
  if (!has_name(meta_data[["..generic"]], "hash")) {
    if (validate) {
      stop("Corrupt metadata, no hash found.")
    }
    return(FALSE)
  }
  if (!has_name(meta_data[["..generic"]], "git2rdata")) {
    if (validate) {
      stop("Data stored using an older version of `git2rdata`.
See `?upgrade_data()`.")
    }
    return(FALSE)
  }
  if (package_version(meta_data[["..generic"]][["git2rdata"]]) <
        packageVersion("git2rdata")) {
    if (validate) {
      stop("Data stored using an older version of `git2rdata`.
See `?upgrade_data()`.")
    }
    return(FALSE)
  }
  if (!has_name(meta_data[["..generic"]], "data_hash")) {
    if (validate) {
      stop("Corrupt metadata, no data hash found.")
    }
    return(FALSE)
  }
  meta_data[["..generic"]][["git2rdata"]] <- NULL
  current_hash <- meta_data[["..generic"]][["hash"]]
  meta_data[["..generic"]][["hash"]] <- NULL
  meta_data[["..generic"]][["data_hash"]] <- NULL
  if (current_hash != hash(as.yaml(meta_data))) {
    if (validate) {
      stop("Corrupt metadata, mismatching hash.")
    }
    return(FALSE)
  }
  return(TRUE)
}

#' @export
#' @importFrom git2r workdir
#' @include write_vc.R
is_git2rmeta.git_repository <- function(file, root, validate = FALSE) {
  is_git2rmeta(file = file, root = workdir(root), validate = validate)
}
