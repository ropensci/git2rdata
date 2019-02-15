#' Read a \code{data.frame} from a repository
#' @inheritParams write_vc
#' @return The \code{data.frame} with the file names and hashes as attributes
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
#' @importFrom assertthat assert_that is.string
#' @importFrom utils head read.table
#' @importFrom stats setNames
#' @importFrom git2r hashfile
read_vc.character <- function(file, root = ".") {
  assert_that(is.string(file))
  assert_that(is.string(root))
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)

  file <- clean_data_path(root = root, file = file)
  assert_that(
    all(file.exists(file)),
    msg = "raw file and/or meta file missing"
  )

  meta_data <- readLines(file["meta_file"])
  start_quote <- grep("^        - \"", meta_data)
  if (length(start_quote) > 0) {
    end_quote <- grep("^( {8}- \".*|(?! {8}- ).*)\"$", meta_data, perl = TRUE)
    assert_that(
      length(start_quote) == length(end_quote),
      all(start_quote <= end_quote),
      all(head(end_quote, -1) < tail(start_quote, -1)),
      msg = "Mismatching quotes in metadata"
    )
    relevant <- start_quote != end_quote
    for (i in rev(which(relevant))) {
      meta_data <- c(
        meta_data[seq_len(start_quote[i] - 1)],
        paste(meta_data[start_quote[i]:end_quote[i]], collapse = "\n"),
        meta_data[(end_quote[i] + 1):length(meta_data)]
      )
    }
  }
  meta_cols <- grep("^\\S*:$", meta_data)
  col_names <- gsub(":", "", meta_data[meta_cols])
  if (tail(meta_data, 1) == "optimized") {
    optimize <- TRUE
    col_type <- c(
      character = "character", factor = "integer", integer = "integer",
      numeric = "numeric", logical = "integer", Date = "integer",
      POSIXct = "numeric", complex = "complex"
    )
  } else if (tail(meta_data, 1) == "verbose") {
    optimize <- FALSE
    col_type <- c(
      character = "character", factor = "character", integer = "integer",
      numeric = "numeric", logical = "logical", Date = "Date",
      POSIXct = "character", complex = "complex"
    )
  } else {
    stop("error in metadata")
  }
  col_classes <- gsub(" {4}class: (.*)", "\\1", meta_data[meta_cols + 1])
  raw_data <- read.table(
    file = file["raw_file"], header = TRUE, sep = "\t", quote = "\"",
    dec = ".", numerals = "warn.loss", na.strings = "NA",
    colClasses = setNames(col_type[col_classes], col_names),
    stringsAsFactors = FALSE, fileEncoding = "UTF-8", encoding = "UTF-8"
  )

  # reinstate factors
  col_factor <- which(col_classes == "factor")
  if (length(col_factor)) {
    level_rows <- grep("^ {8}- .*$", meta_data)
    level_value <- gsub("^ {8}- \"?(.*?)\"?$", "\\1", meta_data[level_rows])
    level_value <- gsub("\\\"\\\"", "\\\"", level_value)
    level_id <- cumsum(c(TRUE, diff(level_rows) > 1))
    col_factor_level <- vapply(
      seq_along(col_factor),
      function(id) {
        list(level_value[level_id == id])
      },
      list(character(0))
    )
    names(col_factor_level) <- col_names[col_factor]
    which_ordered <- vapply(
      grep("^    ordered$", meta_data),
      function(i) {
        col_names[max(which(meta_cols < i))]
      },
      character(1)
    )
    if (optimize) {
      for (id in names(col_factor_level)) {
        raw_data[[id]] <- factor(
          raw_data[[id]],
          levels = seq_along(col_factor_level[[id]]),
          labels = col_factor_level[[id]],
          ordered = id %in% which_ordered
        )
      }
    } else {
      for (id in names(col_factor_level)) {
        raw_data[[id]] <- factor(
          raw_data[[id]],
          levels = col_factor_level[[id]],
          ordered = id %in% which_ordered
        )
      }
    }
  }

  # reinstate POSIXct
  col_posix <- which(col_classes == "POSIXct")
  tz_rows <- grep("^ {4}timezone: .*$", meta_data)
  tz_value <- gsub("^ {4}timezone: (.*)$", "\\1", meta_data[tz_rows])
  if (length(col_posix)) {
    if (optimize) {
      origin_rows <- grep("^ {4}origin: .*$", meta_data)
      origin_rows <- origin_rows[origin_rows %in% (meta_cols[col_posix] + 2)]
      origin_value <- gsub("^ {4}origin: (.*)$", "\\1", meta_data[origin_rows])
      for (i in seq_along(col_posix)) {
        raw_data[[col_posix[i]]] <- as.POSIXct(
          raw_data[[col_posix[i]]], origin = origin_value[i], tz = tz_value[i]
        )
      }
    } else {
      format_rows <- grep("^ {4}format: .*$", meta_data)
      format_rows <- format_rows[format_rows %in% (meta_cols[col_posix] + 2)]
      format_value <- gsub("^ {4}format: (.*)$", "\\1", meta_data[format_rows])
      for (i in seq_along(col_posix)) {
        raw_data[[col_posix[i]]] <- as.POSIXct(
          raw_data[[col_posix[i]]], format = format_value[i], tz = tz_value[i]
        )
      }
    }
  }

  if (optimize) {
    # reinstate logical
    col_logical <- which(col_classes == "logical")
    for (id in col_logical) {
      raw_data[[id]] <- as.logical(raw_data[[id]])
    }

    # reinstage Date
    col_date <- which(col_classes == "Date")
    if (length(col_date)) {
      origin_rows <- grep("^ {4}origin: .*$", meta_data)
      origin_rows <- origin_rows[origin_rows %in% (meta_cols[col_date] + 2)]
      origin_value <- gsub("^ {4}origin: (.*)$", "\\1", meta_data[origin_rows])
      for (i in seq_along(col_date)) {
        raw_data[[col_date[i]]] <-
          as.Date(raw_data[[col_date[i]]], origin = origin_value[i])
      }
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
