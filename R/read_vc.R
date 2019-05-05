#' Read a `data.frame` stored by `write_vc()`
#'
#' `read_vc()` reads and checks the meta data. Then it reads the raw data and
#' applies the meta data. It returns the `data.frame` as stored by `write_vc()`.
#'
#' @inheritParams write_vc
#' @return The `data.frame` with the file names and hashes as attributes
#' @rdname read_vc
#' @export
#' @family storage
#' @template example-io
read_vc <- function(file, root = ".") {
  UseMethod("read_vc", root)
}

#' @export
read_vc.default <- function(file, root) {
  stop("a 'root' of class ", class(root), " is not supported")
}

#' @export
#' @importFrom assertthat assert_that is.string has_name
#' @importFrom yaml read_yaml
#' @importFrom utils read.table
#' @importFrom stats setNames
#' @importFrom git2r hashfile
read_vc.character <- function(file, root = ".") {
  assert_that(is.string(file), is.string(root))
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)

  file <- clean_data_path(root = root, file = file)
  assert_that(
    all(file.exists(file)),
    msg = "raw file and/or meta file missing"
  )

  # read the metadata
  meta_data <- read_yaml(file["meta_file"])
  assert_that(has_name(meta_data, "..generic"))
  assert_that(
    has_name(meta_data[["..generic"]], "hash"),
    msg = "Corrupt metadata, no hash found."
  )
  if (!has_name(meta_data[["..generic"]], "git2rdata") ||
        package_version(meta_data[["..generic"]][["git2rdata"]]) <
        packageVersion("git2rdata")
      ) {
    stop("Data stored using an older version of `git2rdata`.
See `?upgrade_data()`.")
  }
  check_meta_data <- meta_data
  check_meta_data[["..generic"]][["git2rdata"]] <- NULL
  check_meta_data[["..generic"]][["hash"]] <- NULL
  check_meta_data[["..generic"]][["data_hash"]] <- NULL
  assert_that(
    meta_data[["..generic"]][["hash"]] == hash(as.yaml(check_meta_data)),
    msg = "Corrupt metadata, mismatching hash."
  )
  correct <- names(meta_data)
  correct <- paste(correct[correct != "..generic"], collapse = "\t")
  header <- readLines(file["raw_file"], n = 1, encoding = "UTF-8")
  assert_that(
    correct == header,
    msg = paste("Corrupt data, incorrect header. Expecting:", correct)
  )
  if (!has_name(meta_data[["..generic"]], "data_hash")) {
    warning("Data hash missing. Was the data stored by git2rdata <= 0.0.3?")
  } else {
    if (meta_data[["..generic"]][["data_hash"]] != hashfile(file["raw_file"])) {
      warning("Data hash mismatch. Was the data changed by other software?")
    }
  }
  optimize <- meta_data[["..generic"]][["optimize"]]
  if (optimize) {
    col_type <- c(
      character = "character", factor = "integer", integer = "integer",
      numeric = "numeric", logical = "integer", Date = "integer",
      POSIXct = "numeric", complex = "complex"
    )
  } else {
    col_type <- c(
      character = "character", factor = "character", integer = "integer",
      numeric = "numeric", logical = "logical", Date = "Date",
      POSIXct = "character", complex = "complex"
    )
  }
  na_string <- meta_data[["..generic"]][["NA string"]]
  details <- meta_data[names(meta_data) != "..generic"]
  col_names <- names(details)
  col_classes <- vapply(details, "[[", character(1), "class")

  # read the raw data
  raw_data <- read.table(
    file = file["raw_file"], header = TRUE, sep = "\t", quote = "\"",
    dec = ".", numerals = "warn.loss", na.strings = na_string,
    colClasses = setNames(col_type[col_classes], col_names), comment.char = "",
    stringsAsFactors = FALSE, fileEncoding = "UTF-8"
  )

  # reinstate factors
  for (id in col_names[col_classes == "factor"]) {
    if (optimize) {
      raw_data[[id]] <- factor(
        raw_data[[id]],
        levels = details[[id]][["index"]],
        labels = details[[id]][["labels"]],
        ordered = details[[id]][["ordered"]]
      )
    } else {
      raw_data[[id]] <- factor(
        raw_data[[id]],
        levels = details[[id]][["labels"]],
        labels = details[[id]][["labels"]],
        ordered = details[[id]][["ordered"]]
      )
    }
  }

  # reinstate POSIXct
  for (id in col_names[col_classes == "POSIXct"]) {
    if (optimize) {
      raw_data[[id]] <- as.POSIXct(
        raw_data[[id]],
        origin = details[[id]][["origin"]],
        tz = details[[id]][["timezone"]]
      )
    } else {
      raw_data[[id]] <- as.POSIXct(
        raw_data[[id]],
        format = details[[id]][["format"]],
        tz = details[[id]][["timezone"]]
      )
    }
  }

  if (optimize) {
    # reinstate logical
    for (id in col_names[col_classes == "logical"]) {
      raw_data[[id]] <- as.logical(raw_data[[id]])
    }

    # reinstage Date
    for (id in col_names[col_classes == "Date"]) {
      raw_data[[id]] <- as.Date(raw_data[[id]],
                                origin = details[[id]][["origin"]])
    }
  }

  names(file) <- hashfile(file)
  attr(raw_data, "source") <- file
  return(raw_data)
}

#' @export
#' @importFrom git2r workdir
#' @include write_vc.R
read_vc.git_repository <- function(file, root) {
  read_vc(file, root = workdir(root))
}
