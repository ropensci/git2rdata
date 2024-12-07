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
#' write_vc(
#'   iris[1:6, ], file = "iris", root = root, sorting = "Sepal.Length",
#'   digits = 6
#' )
#' write_vc(
#'   iris[5:10, ], file = "subdir/iris", root = root, sorting = "Sepal.Length",
#'   digits = 6
#' )
#' # upgrade a single git2rdata object
#' upgrade_data(file = "iris", root = root)
#' # use path = "." to upgrade all git2rdata objects under root
#' upgrade_data(path = ".", root = root)
upgrade_data <- function(file, root = ".", verbose, ..., path) {
  UseMethod("upgrade_data", root)
}

#' @export
upgrade_data.default <- function(file, root, verbose, path, ...) {
  stop("a 'root' of class ", class(root), " is not supported", call. = FALSE)
}

#' @importFrom assertthat assert_that is.string
#' @importFrom yaml read_yaml write_yaml
#' @importFrom utils packageVersion
#' @export
upgrade_data.character <- function(
  file, root = ".", verbose = TRUE, ..., path) {
  assert_that(is.string(root))
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  if (missing(file)) {
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
    message(target, " is not a git2rdata object")
    return(target)
  }
  assert_that(
    has_name(meta_data[["..generic"]], "hash"),
    msg = paste(target, "has corrupt metadata, no hash found.")
  )
  if (has_name(meta_data[["..generic"]], "git2rdata")) {
    current <- package_version(meta_data[["..generic"]][["git2rdata"]])
    if (current >= package_version("0.4.0")) {
      display(verbose, c(target, " already up to date"))
      return(target)
    }
    assert_that(
      has_name(meta_data[["..generic"]], "optimize"),
      msg = paste(target, "has corrupt metadata, optimize flag not found.")
    )
    assert_that(
      current >= package_version("0.2.0"),
      msg = "Data stored with ancient version of git2rdata.
Please install version 0.3.1 and upgrade to that version first.
Then reinstall the current version and upgrade to this version.
Install version 0.3.1 with remotes::install_github('ropensci/git2rdata@v0.3.1')"
    )
    if (meta_data[["..generic"]][["optimize"]]) {
      display(verbose, c(target, " already up to date"))
      return(target)
    }
    na_string <- meta_data[["..generic"]][["NA string"]]
    details <- meta_data[names(meta_data) != "..generic"]
    col_names <- names(details)
    col_classes <- vapply(details, "[[", character(1), "class")
    col_type <- c(
      character = "character", factor = "character", integer = "integer",
      numeric = "numeric", logical = "logical", Date = "Date",
      POSIXct = "character", complex = "complex"
    )
    old <- read.table(
      file = file["raw_file"], header = TRUE, sep = "\t", quote = "\"",
      dec = ".", numerals = "warn.loss", na.strings = na_string,
      colClasses = setNames(col_type[col_classes], col_names),
      comment.char = "",
      stringsAsFactors = FALSE, fileEncoding = "UTF-8"
    )
    file.remove(file["raw_file"])
    file["raw_file"] <- gsub("\\.tsv$", ".csv", file["raw_file"])
    for (i in which(col_type[col_classes] == "character")) {
      x <- gsub("\\\"", "\\\"\\\"", old[[i]])
      to_escape <- grepl("(\"|,|\n)", x)
      x[to_escape] <- paste0("\"", x[to_escape], "\"")
      x[is.na(x)] <- na_string
      old[[i]] <- x
    }
    write.table(
      x = old, file = file["raw_file"],
      append = FALSE, quote = FALSE, sep = ",", eol = "\n", na = na_string,
      dec = ".", row.names = FALSE, col.names = TRUE, fileEncoding = "UTF-8"
    )
    meta_data[["..generic"]][["git2rdata"]] <- NULL
    meta_data[["..generic"]][["data_hash"]] <- NULL
  }
  meta_data[["..generic"]] <- c(
    git2rdata = as.character(packageVersion("git2rdata")),
    meta_data[["..generic"]]
  )
  if (!has_name(meta_data[["..generic"]], "data_hash")) {
    # recalculate the data hash
    meta_data[["..generic"]][["data_hash"]] <- datahash(file["raw_file"])
  }
  write_yaml(meta_data, file["meta_file"], fileEncoding = "UTF-8")
  display(verbose, c(file["meta_file"], " updated"))
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

  file <- gsub("^\\./", "", file)
  add(root, path = sprintf("%s.csv", file), force = force)
  add(root, path = sprintf("%s.tsv", file), force = force)
  add(root, path = sprintf("%s.yml", file), force = force)
  return(file)
}
