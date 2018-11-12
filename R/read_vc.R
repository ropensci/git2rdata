#' Read a \code{data.frame} from a repository
#' @inheritParams write_vc
#' @return The \code{data.frame}
#' @rdname read_vc
#' @exportMethod read_vc
#' @docType methods
#' @importFrom methods setGeneric
setGeneric(
  name = "read_vc",
  def = function(file, root){
    standardGeneric("read_vc") # nocov
  }
)

#' @rdname read_vc
#' @importFrom methods setMethod
#' @importFrom assertthat assert_that is.string
#' @importFrom readr read_tsv
#' @importFrom utils head
setMethod(
  f = "read_vc",
  signature = signature(root = "character"),
  definition = function(file, root){
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
      for (i in rev(seq_along(start_quote))) {
        meta_data <- c(
          meta_data[seq_len(start_quote[i] - 1)],
          paste(meta_data[start_quote[i]:end_quote[i]], collapse = "\n"),
          meta_data[(end_quote[i] + 1):length(meta_data)]
        )
      }
      meta_data
    }
    meta_cols <- grep("^\\S*:$", meta_data)
    col_names <- gsub(":", "", meta_data[meta_cols])
    if (tail(meta_data, 1) == "optimized") {
      optimize <- TRUE
      col_type <- c(
        character = "c", factor = "i", integer = "i", numeric = "d",
        logical = "i", Date = "i", POSIXct = "d"
      )
    } else if (tail(meta_data, 1) == "verbose") {
      optimize <- FALSE
      col_type <- c(
        character = "c", factor = "c", integer = "i", numeric = "d",
        logical = "l", Date = "D", POSIXct = "T"
      )
    } else {
      stop("error in metadata")
    }
    col_classes <- gsub(" {4}class: (.*)", "\\1", meta_data[meta_cols + 1])
    raw_data <- read_tsv(
      file = file["raw_file"], col_names = TRUE, na = "NA", quoted_na = FALSE,
      col_types = paste(col_type[col_classes], collapse = ""),
      trim_ws = FALSE, progress = FALSE
    )

    # reinstate factors
    col_factor <- which(col_classes == "factor")
    if (length(col_factor)) {
      level_rows <- grep("^ {8}- .*$", meta_data)
      level_value <- gsub("^ {8}- \"?(.*?)\"?$", "\\1", meta_data[level_rows])
      level_id <- cumsum(c(TRUE, diff(level_rows) > 1))
      col_factor_level <- vapply(
        seq_along(col_factor),
        function(id) {
          list(level_value[level_id == id])
        },
        list(character(0))
      )
      names(col_factor_level) <- col_names[col_factor]
      which_ordered <- sapply(
        grep("^    ordered$", meta_data),
        function(i) {
          col_names[max(which(meta_cols < i))]
        }
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

    if (optimize) {
      # reinstate logical
      col_logical <- which(col_classes == "logical")
      for (id in col_logical) {
        raw_data[[id]] <- as.logical(raw_data[[id]])
      }

      # reinstate POSIXct
      col_posix <- which(col_classes == "POSIXct")
      for (id in col_posix) {
        raw_data[[id]] <- as.POSIXct(raw_data[[id]], origin = "1970-01-01")
      }

      # reinstage Date
      col_date <- which(col_classes == "Date")
      for (id in col_date) {
        raw_data[[id]] <- as.Date(raw_data[[id]], origin = "1970-01-01")
      }
    }

    return(raw_data)
  }
)

#' @rdname read_vc
#' @importFrom methods setMethod
#' @importFrom git2r workdir
#' @include write_vc.R
setMethod(
  f = "read_vc",
  signature = signature(root = "git_repository"),
  definition = function(file, root){
    read_vc(file, root = workdir(root))
  }
)
