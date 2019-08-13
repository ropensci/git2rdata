#' Clean the Data Path
#' Strips any file extension from the path and adds the `".tsv"` and `".yml"`
#' file extensions
#' @inheritParams write_vc
#' @param normalize Normalize the path? Defaults to TRUE
#' @return A named vector with "raw_file" and "meta_file", refering to the
#' `".tsv"` and `".yml"` files.
#' @noRd
#' @family internal
#' @importFrom assertthat assert_that is.flag noNA
clean_data_path <- function(root, file, normalize = TRUE) {
  assert_that(is.flag(normalize), noNA(normalize))
  dir_name <- dirname(file)
  if (length(grep("\\.\\.", dir_name))) {
    stop("file should not contain '..'")
  }

  file <- gsub("\\..*$", "", basename(file))
  if (dir_name == ".") {
    path <- file.path(root, file)
  } else {
    path <- file.path(root, dir_name, file)
  }
  if (normalize) {
    path <- normalizePath(path, winslash = "/", mustWork = FALSE)
  }
  c(raw_file = paste0(path, ".tsv"), meta_file = paste0(path, ".yml"))
}
