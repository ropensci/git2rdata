#' Calculate hash of dataframe
#' Calculates a hash based on the given data that is compatible with different operating systems
#' @param data dataframe to calculate the hash
#' @return A 40 digit unique code representind the dataframe
#' @noRd
#' @family internal
#' @importFrom assertthat assert_that
#' @importFrom git2r hash
datahash <- function(data) {
  assert_that(inherits(data, "data.frame"))
  for (i in seq(ncol(data))) {
    if (is.numeric(data[, i])) {
      data[, i] <- as.character(data[, i])
    }
  }
  datastring <- paste(data, sep = "\t", collapse = "\n")
  datastring <- iconv(datastring, to = "UTF-8")
  hash(datastring)
}
