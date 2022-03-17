#' Check Whether a Git2rdata Object is Valid.
#'
#' A valid git2rdata object has valid metadata.
#' @inheritParams write_vc
#' @inheritParams is_git2rmeta
#' @return A logical value. `TRUE` in case of a valid git2rdata object.
#' Otherwise `FALSE`.
#' @rdname is_git2rdata
#' @export
#' @family internal
#' @template example_isgit2r
is_git2rdata <- function(
    file, root = ".", message = c("none", "warning", "error")
) {
  UseMethod("is_git2rdata", root)
}

#' @export
is_git2rdata.default <- function(file, root, message) {
  stop("a 'root' of class ", class(root), " is not supported", call. = FALSE)
}

#' @export
#' @importFrom assertthat assert_that is.string
#' @importFrom yaml read_yaml as.yaml
#' @importFrom utils packageVersion
is_git2rdata.character <- function(
    file, root = ".", message = c("none", "warning", "error")
) {
  assert_that(is.string(file), is.string(root))
  message <- match.arg(message)
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  check_meta <- is_git2rmeta(file = file, root = root, message = message)
  if (!check_meta) {
    return(FALSE)
  }
  file <- clean_data_path(root = root, file = file)

  # read the metadata
  meta_data <- read_yaml(file["meta_file"])
  file["raw_file"] <- ifelse(
    meta_data[["..generic"]][["optimize"]],
    file["raw_file"],
    gsub("\\.tsv$", ".csv", file["raw_file"])
  )
  if (!file.exists(file["raw_file"])) {
    msg <- "Data file missing."
    switch(message, error = stop(msg, call. = FALSE),
           warning = warning(msg, call. = FALSE))
    return(FALSE)
  }

  if (has_name(meta_data[["..generic"]], "split_by")) {
    header <- readLines(
      file.path(file["raw_file"], "index.tsv"), n = 1, encoding = "UTF-8"
    )
    correct <- paste(
      c(meta_data[["..generic"]][["split_by"]], "..hash"),
      collapse = "\t"
    )
    if (correct != header) {
      msg <- paste(
        "Corrupt data, incorrect header in index.tsv. Expecting:", correct
      )
      switch(message, error = stop(msg, call. = FALSE),
             warning = warning(msg, call. = FALSE))
      return(FALSE)
    }
    correct <- names(meta_data)
    keep <- !correct %in% c("..generic", meta_data[["..generic"]][["split_by"]])
    correct <- paste(correct[keep], collapse = "\t")
    header <- vapply(
      list.files(file["raw_file"], pattern = "[[:xdigit:]]{20}\\.tsv"),
      function(z) {
        readLines(
          file.path(file["raw_file"], z), n = 1, encoding = "UTF-8"
        )
      },
      character(1)
    )
    if (any(header != correct)) {
      msg <- paste("Corrupt data, incorrect header. Expecting:", correct)
      switch(message, error = stop(msg, call. = FALSE),
             warning = warning(msg, call. = FALSE))
      return(FALSE)
    }
  } else {
    correct <- names(meta_data)
    correct <- paste(
      correct[correct != "..generic"],
      collapse = ifelse(meta_data[["..generic"]][["optimize"]], "\t", ",")
    )
    header <- readLines(file["raw_file"], n = 1, encoding = "UTF-8")
    if (correct != header) {
      msg <- paste("Corrupt data, incorrect header. Expecting:", correct)
      switch(message, error = stop(msg, call. = FALSE),
             warning = warning(msg, call. = FALSE))
      return(FALSE)
    }
  }
  return(TRUE)
}

#' @export
#' @importFrom git2r workdir
#' @include write_vc.R
is_git2rdata.git_repository <- function(
  file, root, message = c("none", "warning", "error")) {
  is_git2rdata(file = file, root = workdir(root), message = message)
}
