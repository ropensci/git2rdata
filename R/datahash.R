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
  datastring <- readLines(file, encoding = "UTF-8")
  datastring <- paste(datastring, collapse = "\n")
  hash(datastring)
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
