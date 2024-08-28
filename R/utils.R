#' @noRd
#' @importFrom utils flush.console
#' @importFrom assertthat assert_that is.flag noNA
display <- function(verbose, message, linefeed = TRUE) {
  assert_that(is.flag(verbose), noNA(verbose))
  assert_that(is.flag(linefeed), noNA(linefeed))

  if (verbose) {
    message(message, appendLF = linefeed)
    flush.console()
  }
  return(invisible(NULL))
}
