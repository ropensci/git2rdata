#' Remove data files
#' Remove all tsv and/or yml files within the path
#' @param path the directory in which to clean all the data files
#' @param type which file type should be removed
#' @param recursive remove files in subdirectories too
#' @inheritParams write_vc
#' @rdname rm_data
#' @exportMethod rm_data
#' @docType methods
#' @importFrom methods setGeneric
setGeneric(
  name = "rm_data",
  def = function(
    root, path = NULL, type = c("tsv", "yml", "both"), recursive = TRUE, ...
  ){
    standardGeneric("rm_data") # nocov
  }
)

#' @rdname rm_data
#' @importFrom methods setMethod
#' @importFrom assertthat assert_that is.flag
setMethod(
  f = "rm_data",
  signature = signature(root = "character"),
  definition = function(
    root, path = NULL, type = c("tsv", "yml", "both"), recursive = TRUE, ...
  ){
    assert_that(is.string(root))
    root <- normalizePath(root, winslash = "/", mustWork = TRUE)
    assert_that(is.string(path))
    path <- file.path(root, path)
    path <- normalizePath(path, winslash = "/", mustWork = TRUE)
    type <- match.arg(type)
    assert_that(is.flag(recursive))

    if (type == "tsv") {
      to_do <- list.files(
        path = path,
        pattern = "\\.tsv$",
        recursive = recursive,
        full.names = TRUE
      )
    } else if (type == "both") {
      to_do <- list.files(
        path = path,
        pattern = "\\.(tsv|yml)$",
        recursive = recursive,
        full.names = TRUE
      )
    } else {
      to_do <- list.files(
        path = path,
        pattern = "\\.yml$",
        recursive = recursive,
        full.names = TRUE
      )
      keep <- list.files(
        path = path,
        pattern = "\\.tsv$",
        recursive = recursive,
        full.names = TRUE
      )
      keep <- gsub("\\.tsv$", ".yml", keep)
      to_do <- to_do[!to_do %in% keep]
    }
    file.remove(to_do)

    return(invisible(TRUE))
  }
)
