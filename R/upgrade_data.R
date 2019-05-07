#' Upgrade files to the new version
#'
#' Updates the data written by older versions to the current data format
#' standard.
#' @inheritParams write_vc
#' @param verbose display a message with the update status. Defaults to `TRUE`.
#' @export
#' @return the file names
#' @family internal
#' @examples
#' # create a directory
#' root <- tempfile("git2rdata-")
#' dir.create(root)
#'
#' # write a dataframe to the directory
#' write_vc(iris[1:6, ], file = "iris", root = root, sorting = "Sepal.Length")
#' # upgrade the file
#' upgrade_data(file = "iris", root = root)
#'
#' # clean up
#' junk <- file.remove(list.files(root, full.names = TRUE), root)
upgrade_data <- function(
  file, root = ".", verbose, ...
) {
  UseMethod("upgrade_data", root)
}

#' @export
upgrade_data.default <- function(file, root, verbose, ...) {
  stop("a 'root' of class ", class(root), " is not supported", call. = FALSE)
}

#' @importFrom assertthat assert_that is.string is.flag noNA
#' @importFrom yaml read_yaml write_yaml
#' @importFrom utils packageVersion
#' @export
upgrade_data.character <- function(file, root = ".", verbose = TRUE, ...) {
  assert_that(is.string(root), is.string(file), is.flag(verbose), noNA(verbose))
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  file <- clean_data_path(root = root, file = file)

  meta_data <- read_yaml(file["meta_file"])
  assert_that(has_name(meta_data, "..generic"),
              msg = "Corrupt metadata")
  assert_that(
    has_name(meta_data[["..generic"]], "hash"),
    msg = "Corrupt metadata, no hash found."
  )
  if (has_name(meta_data[["..generic"]], "git2rdata")) {
    if (package_version(meta_data[["..generic"]][["git2rdata"]]) ==
        packageVersion("git2rdata")
        ) {
      if (verbose) {
        message(remove_root(file = file["meta_file"], root = root),
                " already up to date")
      }
      file <- remove_root(file = file, root = root)
      return(file)
    }
  }
  check_meta_data <- meta_data
  check_meta_data[["..generic"]][["git2rdata"]] <- NULL
  check_meta_data[["..generic"]][["hash"]] <- NULL
  check_meta_data[["..generic"]][["data_hash"]] <- NULL
  assert_that(
    meta_data[["..generic"]][["hash"]] == hash(as.yaml(check_meta_data)),
    msg = "Corrupt metadata, mismatching hash."
  )
  meta_data[["..generic"]][["git2rdata"]] <-
    as.character(packageVersion("git2rdata"))
  if (!has_name(meta_data[["..generic"]], "data_hash")) {
    meta_data[["..generic"]][["data_hash"]] <- hashfile(file["raw_file"])
  }
  write_yaml(meta_data, file["meta_file"], fileEncoding = "UTF-8")
  if (verbose) {
    message(file["meta_file"], " updated")
  }
  file <- remove_root(file = file, root = root)
  return(file)
}

#' @rdname upgrade_data
#' @inheritParams write_vc.git_repository
#' @inheritParams git2r::add
#' @export
#' @importFrom git2r workdir add
#' @importFrom assertthat assert_that is.flag noNA
#' @importFrom git2r workdir add
upgrade_data.git_repository <- function(
  file, root = ".", verbose = TRUE, ..., stage = FALSE, force = FALSE
) {
  assert_that(is.flag(stage), noNA(stage), is.flag(force), noNA(force))
  file <- upgrade_data(file = file, root = workdir(root), verbose = verbose,
                       ...)
  if (!stage) {
    return(file)
  }
  add(root, path = file, force = force)
  return(file)
}
