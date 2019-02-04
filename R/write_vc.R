#' Write a \code{data.frame} to a git repository
#'
#' This will create two files. The `".tsv"` file contains the raw data.
#' The `".yml"` contains the meta data on the columns in YAML format.
#' @param x the `data.frame
#' @param file the name of the file without file extension. Can include a
#' relative path. It is relative to the `root`.
#' @param root The root of a project. Can be a file path or a `git-repository`.
#' Defaults to the current working directory (".").
#' @param sorting a vector of column names defining which columns to use for
#' sorting \code{x} and in what order to use them. Only required when writing
#' new metadata.
#' @param override Ignore existing meta data. This is required when new
#' variables are added or variables are deleted. Setting this to TRUE can
#' potentially lead to large diffs. Defaults to FALSE.
#' @param ... additional parameters used in some methods
#' @inheritParams meta
#' @return a named vector with the hashes of the files. The names contains the
#' files with their paths relative to `root`.
#' @export
#' @family storage
write_vc <- function(
  x, file, root = ".", sorting, override = FALSE, optimize = TRUE, ...
) {
  UseMethod("write_vc", root)
}

#' @export
write_vc.default <- function(
  x, file, root, sorting, override = FALSE, optimize = TRUE, ...
) {
  stop("a 'root' of class ", class(root), " is not supported")
}

#' @export
#' @importFrom assertthat assert_that is.string is.flag
#' @importFrom utils tail write.table
#' @importFrom git2r hashfile
write_vc.character <- function(
  x, file, root = ".", sorting, override = FALSE, optimize = TRUE, ...
){
  assert_that(inherits(x, "data.frame"))
  assert_that(is.string(file))
  assert_that(is.string(root))
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  if (!missing(sorting)) {
    assert_that(is.character(sorting))
    assert_that(
      length(sorting) >= 1,
      msg = "at least one variable is required for sorting"
    )
    assert_that(
      all(sorting %in% colnames(x)),
      msg = "use only variables of 'x' for sorting"
    )
  }
  assert_that(is.flag(override))
  assert_that(is.flag(optimize))

  file <- clean_data_path(root = root, file = file)
  if (!file.exists(dirname(file["raw_file"]))) {
    dir.create(dirname(file["raw_file"]), recursive = TRUE)
  }

  # prepare metadata
  raw_data <- as.data.frame(
    lapply(x, meta, optimize = optimize),
    stringsAsFactors = FALSE
  )
  metadata <- paste(
    colnames(x),
    vapply(raw_data, attr, "", which = "meta"),
    sep = ":\n"
  )
  names(metadata) <- colnames(x)
  if (override || !file.exists(file["meta_file"])) {
    #write new metadata
    if (missing(sorting)) {
      stop("new metadata requires 'sorting'")
    }
    metadata[sorting] <- paste0(metadata[sorting], "\n    sort")
    if (optimize) {
      store_metadata <- c(metadata, "optimized")
    } else {
      store_metadata <- c(metadata, "verbose")
    }
    writeLines(store_metadata, file["meta_file"])
  } else {
    old_metadata <- readLines(file["meta_file"])
    if (tail(old_metadata, 1) == "verbose") {
      if (optimize) {
        stop("old data was stored verbose")
      }
    } else if (tail(old_metadata, 1) == "optimized") {
      if (!optimize) {
        stop("old data was stored optimized")
      }
    } else {
      stop("error in existing metadata")
    }
    meta_cols <- grep("^\\S*:$", old_metadata)
    positions <- cbind(
      start = meta_cols,
      end = c(tail(meta_cols, -1) - 1, length(old_metadata) - 1)
    )
    old_metadata <- apply(
      positions,
      1,
      function(i) {
        paste(old_metadata[i["start"]:i["end"]], collapse = "\n")
      }
    )
    if (missing(sorting)) {
      sorting <- grep(".*sort", old_metadata)
      sorting <- gsub("(\\S*?):\n.*", "\\1", old_metadata)[sorting]
      if (!all(sorting %in% colnames(x))) {
        stop("new data lacks old sorting variable, use override = TRUE")
      }
    }
    metadata[sorting] <- paste0(metadata[sorting], "\n    sort")
    metadata <- compare_meta(metadata, old_metadata)
  }

  # order the variables
  raw_data <- raw_data[gsub("(\\S*?):.*", "\\1", metadata)]
  # order the observations
  if (anyDuplicated(raw_data[sorting])) {
    warning(
"sorting results in ties. Add extra sorting variables to ensure small diffs."
    )
  }
  raw_data <- raw_data[do.call(order, raw_data[sorting]), , drop = FALSE] # nolint
  write.table(
    x = raw_data, file = file["raw_file"], append = FALSE, quote = FALSE,
    sep = "\t", eol = "\n", na = "NA", dec = ".", row.names = FALSE,
    col.names = TRUE, fileEncoding = "UTF-8"
  )

  hashes <- hashfile(file)
  names(hashes) <- gsub(paste0("^", root, "/"), "", file)

  return(hashes)
}

#' @importFrom methods setOldClass
setOldClass("git_repository")

#' @rdname write_vc
#' @param stage stage the changes after writing the data. Defaults to FALSE
#' @inheritParams git2r::add
#' @export
#' @importFrom git2r workdir add
#' @importFrom assertthat assert_that is.flag
write_vc.git_repository <- function(
  x, file, root, sorting, override = FALSE, optimize = TRUE, ...,
  stage = FALSE, force = FALSE
){
  hashes <- write_vc(
    x = x, file = file, root = workdir(root), sorting = sorting,
    override = override, optimize = optimize, ...
  )
  assert_that(is.flag(stage))
  if (!stage) {
    return(hashes)
  }
  assert_that(is.flag(force))
  add(root, path = names(hashes), force = force)
  return(hashes)
}

compare_meta <- function(metadata, old_metadata) {
  if (length(old_metadata) != length(metadata)) {
    stop(
      call. = FALSE,
      "old data has different number of variables, use override = TRUE"
    )
  }
  old_col_names <- gsub("(\\S*?):.*", "\\1", old_metadata)
  col_names <- gsub("(\\S*?):.*", "\\1", metadata)
  if (!all(sort(col_names) == sort(old_col_names))) {
    stop(call. = FALSE, "old data has different variables, use override = TRUE")
  }
  if (!all(sort(metadata) == sort(old_metadata))) {
    stop(
      call. = FALSE,
      "old data has different variable types or sorting, use override = TRUE"
    )
  }
  return(old_metadata)
}
