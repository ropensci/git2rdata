#' Calculate Hash of Dataframe
#' Calculates a hash based on the given data that is compatible with different
#' operating systems.
#' @param file The file to calculate the hash.
#' @return A 40 hexadecimal character quasi-unique code representing the
#' dataframe.
#' @noRd
#' @family internal
#' @importFrom assertthat assert_that
#' @importFrom git2r hash
#' @importFrom utils file_test
datahash <- function(file) {
  if (file_test("-f", file)) {
    chunk_size <- 1e4
    hashes <- character(chunk_size + 1)
    i <- 0
    rawdata <- scan(
      file = file, what = character(), nmax = -1, sep = "\n", quote = "",
      skip = i * chunk_size, nlines = chunk_size, na.strings = "",
      flush = FALSE, fill = FALSE, strip.white = FALSE, quiet = TRUE,
      blank.lines.skip = FALSE, comment.char = "", allowEscapes = FALSE,
      encoding = "UTF-8", skipNul = FALSE
    )
    while (length(rawdata)) {
      hashes[1 + i %% chunk_size] <- hash(paste(hash(rawdata), collapse = "\n"))
      i <- i + 1
      if (i  %% chunk_size == 0) {
        hashes[chunk_size + 1] <- hash(paste(hashes, collapse = "")) # nocov
      }
      rawdata <- scan(
        file = file, what = character(), nmax = -1, sep = "\n", quote = "",
        skip = i * chunk_size, nlines = chunk_size, na.strings = "",
        flush = FALSE, fill = FALSE, strip.white = FALSE, quiet = TRUE,
        blank.lines.skip = FALSE, comment.char = "", allowEscapes = FALSE,
        encoding = "UTF-8", skipNul = FALSE
      )
    }
  } else {
    hashes <- sapply(
      list.files(
        file, pattern = "(index|[[:xdigit:]]{20}\\.tsv$)", full.names = TRUE
      ),
      datahash
    )
  }
  hash(paste(hashes, collapse = ""))
}

#' Set the C locale for standardized sorting
#' @noRd
#' @return a named vector with the old locale
set_c_locale <- function() {
  icuSetCollate(
    locale = "en_GB", case_first = "lower", normalization = "on",
    case_level = "on"
  )
  return(c())
}

#' Reset the old locale
#' @param locale the output of `set_c_locale()`
#' @return invisible `NULL`
#' @noRd
set_local_locale <- function(locale) {
  icuSetCollate(locale = "default")
  return(invisible(NULL))
}
