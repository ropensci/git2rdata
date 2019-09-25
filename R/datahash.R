#' Calculate Hash of Dataframe
#' Calculates a hash based on the given data that is compatible with different operating systems.
#' @param file The file to calculate the hash.
#' @return A 40 hexadecimal character quasi-unique code representing the dataframe.
#' @noRd
#' @family internal
#' @importFrom assertthat assert_that
#' @importFrom git2r hash
datahash <- function(file) {
  datastring <- readLines(file, encoding = "UTF-8")
  datastring <- paste(datastring, collapse = "\n")
  hash(datastring)
}
