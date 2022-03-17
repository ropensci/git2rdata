#' Read a file an verify the presence of variables
#'
#' Reads the file with [read_vc()].
#' Then verifies that every variable listed in `variables` is present in the
#' data.frame.
#' @export
#' @inheritParams read_vc
#' @param variables a character vector with variable names.
#' @importFrom assertthat assert_that
#' @family storage
verify_vc <- function(file, root, variables) {
  assert_that(is.character(variables), length(variables) > 0, noNA(variables))
  x <- read_vc(file = file, root = root)
  ok <- variables %in% colnames(x)
  assert_that(
    all(ok),
    msg =   sprintf(
      "variables missing from `%s`: %s", file,
      paste(variables[!ok], collapse = ", ")
    )
  )
  return(x)
}
