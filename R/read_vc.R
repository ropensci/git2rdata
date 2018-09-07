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
#' @importFrom utils read.table
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
    meta_cols <- grep("^\\S*:$", meta_data)
    col_names <- gsub(":", "", meta_data[meta_cols])
    if (tail(meta_data, 1) == "optimized") {
      optimize <- TRUE
    } else if (tail(meta_data, 1) == "verbose") {
      optimize <- FALSE
    } else {
      stop("error in metadata")
    }
    raw_data <- read.table(
      file = file["raw_file"], header = !optimize, sep = "\t", dec = ".",
      quote = ifelse(optimize, "", "\"'"), as.is = TRUE, col.names = col_names
    )

    col_classes <- gsub(" {4}class: (.*)", "\\1", meta_data[meta_cols + 1])

    # reinstate factors
    col_factor <- which(col_classes == "factor")
    level_rows <- grep("^ {8}- .*$", meta_data)
    level_value <- gsub("^ {8}- (.*)$", "\\1", meta_data[level_rows])
    level_id <- cumsum(c(TRUE, diff(level_rows) > 1))
    col_factor_level <- vapply(
      seq_along(col_factor),
      function(id) {
        list(level_value[level_id == id])
      },
      list(character(0))
    )
    names(col_factor_level) <- col_names[col_factor]
    if (optimize) {
      for (id in names(col_factor_level)) {
        raw_data[[id]] <- factor(
          raw_data[[id]],
          levels = seq_along(col_factor_level[[id]]),
          labels = col_factor_level[[id]]
        )
      }
    } else {
      for (id in names(col_factor_level)) {
        raw_data[[id]] <- factor(
          raw_data[[id]],
          levels = col_factor_level[[id]]
        )
      }
    }

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
