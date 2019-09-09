#' Calculate hash of dataframe
#' Calculates a hash based on the given data that is compatible with different operating systems
#' @param data dataframe to calculate the hash
#' @param convert convert characters in dataframe data to UTF-8?
#' @return A 40 digit unique code representing the dataframe
#' @noRd
#' @family internal
#' @importFrom assertthat assert_that
#' @importFrom git2r hash
datahash <- function(data, convert = FALSE) {
  assert_that(inherits(data, "data.frame"))
  datastring <- do.call(paste, c(data, sep = "\t", collapse = "\n"))
  if (convert) {
    datastring <- iconv(datastring, to = "UTF-8")
  }
  hash(datastring)
}
