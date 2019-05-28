#' Upgrade Files to the New Version
#'
#' Updates the data written by older versions to the current data format
#' standard. Works both on a single file and (recursively) on a path. The
#' `".yml"` file must contain a `"..generic"` element. `upgrade_data()` ignores
#' all other files.
#' @inheritParams write_vc
#' @param verbose display a message with the update status. Defaults to `TRUE`.
#' @param path specify `path` instead of `file` to update all git2rdata objects
#' in this directory and it's subdirectories. `path` is relative to `root`. Use
#' `path = "."` to upgrade all git2rdata objects under `root`.
#' @export
#' @return the git2rdata object names.
#' @family internal
#' @examples
#' # create a directory
#' root <- tempfile("git2rdata-")
#' dir.create(root)
#'
#' # write dataframes to the root
#' write_vc(iris[1:6, ], file = "iris", root = root, sorting = "Sepal.Length")
#' write_vc(iris[5:10, ], file = "subdir/iris", root = root,
#'          sorting = "Sepal.Length")
#' # upgrade a single git2rdata object
#' upgrade_data(file = "iris", root = root)
#' # use path = "." to upgrade all git2rdata objects under root
#' upgrade_data(path = ".", root = root)
#'
#' # clean up
#' junk <- file.remove(list.files(root, full.names = TRUE), root)
upgrade_data <- function(file, root = ".", verbose, ..., path) {
  UseMethod("upgrade_data", root)
}

#' @export
upgrade_data.default <- function(file, root, verbose, path, ...) {
  stop("a 'root' of class ", class(root), " is not supported", call. = FALSE)
}

#' @importFrom assertthat assert_that is.string is.flag noNA
#' @importFrom yaml read_yaml write_yaml
#' @importFrom utils packageVersion
#' @export
upgrade_data.character <- function(
  file, root = ".", verbose = TRUE, ..., path) {
  assert_that(is.string(root), is.flag(verbose), noNA(verbose))
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  if (missing(file)) {
    assert_that(missing(file),
                msg = "specify either 'file' or 'path'")
    assert_that(is.string(path))
    full_path <- normalizePath(file.path(root, path), winslash = "/",
                               mustWork = TRUE)
    ymls <- list.files(path = full_path, pattern = "\\.yml$", recursive = TRUE)
    files <- vapply(file.path(path, ymls), upgrade_data, root = root,
                    verbose = verbose, FUN.VALUE = "")
    return(files)
  }
  assert_that(missing(path), msg = "specify either 'file' or 'path'")
  assert_that(is.string(file))
  file <- clean_data_path(root = root, file = file)

  meta_data <- read_yaml(file["meta_file"])
  target <- remove_root(file = file["meta_file"], root = root)
  target <- gsub(".yml", "", target)
  if (!has_name(meta_data, "..generic")) {
    message(target, "is not a git2rdata object")
    return(target)
  }
  assert_that(
    has_name(meta_data[["..generic"]], "hash"),
    msg = paste(target, "has corrupt metadata, no hash found.")
  )
  if (has_name(meta_data[["..generic"]], "git2rdata")) {
    if (package_version(meta_data[["..generic"]][["git2rdata"]]) ==
        packageVersion("git2rdata")
        ) {
      if (verbose) {
        message(target, " already up to date")
      }
      return(target)
    }
    meta_data[["..generic"]][["git2rdata"]] <- NULL
  }
  assert_that(
    meta_data[["..generic"]][["hash"]] == metadata_hash(meta_data),
    msg = paste(target, "has corrupt metadata: mismatching hash.")
  )
  meta_data[["..generic"]] <- c(
    git2rdata = as.character(packageVersion("git2rdata")),
    meta_data[["..generic"]]
  )
  if (!has_name(meta_data[["..generic"]], "data_hash")) {
    meta_data[["..generic"]][["data_hash"]] <- hashfile(file["raw_file"])
  }
  write_yaml(meta_data, file["meta_file"], fileEncoding = "UTF-8")
  if (verbose) {
    message(file["meta_file"], " updated")
  }
  return(target)
}

#' @rdname upgrade_data
#' @inheritParams write_vc.git_repository
#' @inheritParams git2r::add
#' @export
#' @importFrom git2r workdir add
#' @importFrom assertthat assert_that is.flag noNA
#' @importFrom git2r workdir add
upgrade_data.git_repository <- function(
  file, root = ".", verbose = TRUE, ..., path, stage = FALSE, force = FALSE
) {
  assert_that(is.flag(stage), noNA(stage), is.flag(force), noNA(force))
  file <- upgrade_data(file = file, root = workdir(root), verbose = verbose,
                       path = path, ...)
  if (!stage) {
    return(file)
  }
  add(root, path = paste0(file, ".yml"), force = force)
  return(file)
}
