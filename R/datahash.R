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
datahash <- function(file) {
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
  hash(paste(hashes, collapse = ""))
}

#' Set the C locale for standardized sorting
#' @noRd
#' @return a named vector with the old locale
set_c_locale <- function() {
  old_ctype <- Sys.getlocale(category = "LC_CTYPE")
  old_collate <- Sys.getlocale(category = "LC_COLLATE")
  old_time <- Sys.getlocale(category = "LC_TIME")
  Sys.setlocale(category = "LC_CTYPE", locale = "C")
  Sys.setlocale(category = "LC_COLLATE", locale = "C")
  Sys.setlocale(category = "LC_TIME", locale = "C")
  return(c(ctype = old_ctype, collate = old_collate, time = old_time))
}

#' Reset the old locale
#' @param locale the output of `set_c_locale()`
#' @return invisible `NULL`
#' @noRd
set_local_locale <- function(locale) {
  Sys.setlocale(category = "LC_CTYPE", locale = locale["ctype"])
  Sys.setlocale(category = "LC_COLLATE", locale = locale["collate"])
  Sys.setlocale(category = "LC_TIME", locale = locale["time"])
  return(invisible(NULL))
}
