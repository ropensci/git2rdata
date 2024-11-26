#' Read a Git2rdata Object from Disk
#'
#' @description
#' `read_vc()` handles git2rdata objects stored by `write_vc()`. It reads and
#' verifies the metadata file (`.yml`). Then it reads and verifies the raw data.
#' The last step is back-transforming any transformation done by `meta()` to
#' return the `data.frame` as stored by `write_vc()`.
#'
#' `read_vc()` is an S3 generic on `root` which currently handles `"character"`
#' (a path) and `"git-repository"` (from `git2r`). S3 methods for other version
#' control system could be added.
#'
#' @inheritParams write_vc
#' @return The `data.frame` with the file names and hashes as attributes.
#' It has the additional class `"git2rdata"` to support extra methods to
#' display the descriptions.
#' @rdname read_vc
#' @export
#' @family storage
#' @template example_io
read_vc <- function(file, root = ".") {
  UseMethod("read_vc", root)
}

#' @export
read_vc.default <- function(file, root) {
  stop("a 'root' of class ", class(root), " is not supported", call. = FALSE)
}

#' @export
#' @importFrom assertthat assert_that is.string has_name
#' @importFrom yaml read_yaml
#' @importFrom utils read.table
#' @importFrom stats setNames
read_vc.character <- function(file, root = ".") {
  assert_that(is.string(file), is.string(root))
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)

  file <- clean_data_path(root = root, file = file)
  tryCatch(
    is_git2rdata(file = remove_root(file = file["meta_file"], root = root),
                 root = root, message = "error"),
    error = function(e) {
      stop(e$message, call. = FALSE)
    }
  )

  # read the metadata
  meta_data <- read_yaml(file["meta_file"])
  optimize <- meta_data[["..generic"]][["optimize"]]
  file["raw_file"] <- ifelse(
    optimize, file["raw_file"], gsub("\\.tsv$", ".csv", file["raw_file"])
  )
  col_type <- list(
    c(
      character = "character", factor = "character", integer = "integer",
      numeric = "numeric", logical = "logical", Date = "Date",
      POSIXct = "character", complex = "complex"
    ),
    c(
      character = "character", factor = "integer", integer = "integer",
      numeric = "numeric", logical = "integer", Date = "integer",
      POSIXct = "numeric", complex = "complex"
    )
  )[[optimize + 1]]
  na_string <- meta_data[["..generic"]][["NA string"]]
  details <- meta_data[names(meta_data) != "..generic"]
  col_names <- names(details)
  col_classes <- vapply(details, "[[", character(1), "class")

  # read the raw data and check the data hash
  if (has_name(meta_data[["..generic"]], "split_by")) {
    split_by <- meta_data[["..generic"]][["split_by"]]
    which_split_by <- col_names %in% split_by
    index <- read.table(
      file = file.path(file["raw_file"], "index.tsv"),
      header = TRUE, sep = "\t", quote = "\"",
      dec = ".", numerals = "warn.loss", na.strings = na_string,
      colClasses = setNames(
        col_type[col_classes[which_split_by]],
        col_names[which_split_by]
      ),
      comment.char = "",
      stringsAsFactors = FALSE, fileEncoding = "UTF-8"
    )
    if (nrow(index) == 0) {
      list(
        character = character(0), factor = character(0), integer = integer(0),
        numeric = numeric(0)
      )[col_classes] |>
        setNames(col_names) |>
        as.data.frame() -> raw_data
    } else {
      raw_data <- vapply(
        seq_len(nrow(index)),
        function(i) {
          rf <- file.path(file["raw_file"], paste0(index[i, "..hash"], ".tsv"))
          raw_data <- read.table(
            file = rf, header = TRUE, sep = "\t", quote = "\"",
            dec = ".", numerals = "warn.loss", na.strings = na_string,
            colClasses = setNames(
              col_type[col_classes[!which_split_by]],
              col_names[!which_split_by]
            ),
            comment.char = "",
            stringsAsFactors = FALSE, fileEncoding = "UTF-8"
          )
          raw_data <- cbind(
            index[rep(i, nrow(raw_data)), split_by, drop = FALSE],
            raw_data
          )
          return(list(raw_data))
        },
        vector(mode = "list", length = 1)
      )
      raw_data <- do.call(rbind, raw_data)[, col_names]
    }
  } else {
    raw_data <- read.table(
      file = file["raw_file"], header = TRUE, sep = ifelse(optimize, "\t", ","),
      quote = "\"",
      dec = ".", numerals = "warn.loss", na.strings = na_string,
      colClasses = setNames(col_type[col_classes], col_names),
      comment.char = "",
      stringsAsFactors = FALSE, fileEncoding = "UTF-8"
    )
  }
  dh <- datahash(file["raw_file"])

  if (meta_data[["..generic"]][["data_hash"]] != dh) {
    meta_data[["..generic"]][["data_hash"]] <- dh
    warning("Mismatching data hash. Data altered outside of git2rdata.",
            call. = FALSE)
  }

  raw_data <- reinstate(
    raw_data = raw_data, col_names = col_names, col_classes = col_classes,
    details = details, optimize = optimize
  )

  names(file) <- c(
      meta_data[["..generic"]][["data_hash"]],
      meta_data[["..generic"]][["hash"]]
    )
  attr(raw_data, "source") <- file

  has_description <- vapply(
    details, FUN.VALUE = logical(1),
    FUN = function(x) {
      "description" %in% names(x)
    }
  )
  has_description <- names(has_description)[has_description]
  for (desc in has_description) {
    attr(raw_data[[desc]], "description") <- details[[desc]]$description
  }

  if (has_name(meta_data[["..generic"]], "name")) {
    attr(raw_data, "table name") <- meta_data[["..generic"]][["name"]]
  }

  if (has_name(meta_data[["..generic"]], "title")) {
    attr(raw_data, "title") <- meta_data[["..generic"]][["title"]]
  }

  if (has_name(meta_data[["..generic"]], "description")) {
    attr(raw_data, "description") <- meta_data[["..generic"]][["description"]]
  }

  attr(raw_data, "optimize") <- meta_data[["..generic"]][["optimize"]]
  attr(raw_data, "sorting") <- meta_data[["..generic"]][["sorting"]]

  class(raw_data) <- c("git2rdata", class(raw_data))

  return(raw_data)
}

reinstate <- function(raw_data, col_names, col_classes, details, optimize) {
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

  if (!optimize) {
    return(raw_data)
  }
  # reinstate logical
  for (id in col_names[col_classes == "logical"]) {
    raw_data[[id]] <- as.logical(raw_data[[id]])
  }

  # reinstage Date
  for (id in col_names[col_classes == "Date"]) {
    raw_data[[id]] <- as.Date(raw_data[[id]],
                              origin = details[[id]][["origin"]])
  }
  return(raw_data)
}

#' @export
#' @importFrom git2r workdir
#' @include write_vc.R
read_vc.git_repository <- function(file, root) {
  read_vc(file, root = workdir(root))
}
