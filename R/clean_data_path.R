#' Clean the data path
#' Strips any file extension from the path and adds the ".tsv" and ".yml" file extensions
#' @inheritParams write_vc
#' @param normalize normalize the path? Defaults to TRUE
#' @return a named vector with "raw_file" and "meta_file", refering to the ".tsv" and ".yml" files
#' @noRd
clean_data_path <- function(root, file, normalize = TRUE) {
    dir_name <- dirname(file)
    file <- gsub("\\..*$", "", basename(file))
    path <- file.path(root, dir_name, file)
    if (isTRUE(normalize)) {
        path <- normalizePath(path, winslash = "/", mustWork = FALSE)
    }
    c(raw_file = paste0(path, ".tsv"), meta_file = paste0(path, ".yml"))
}
