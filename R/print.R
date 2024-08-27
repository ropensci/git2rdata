#' Print method for `git2rdata` objects.
#'
#' Prints the data and the description of the columns when available.
#' @param x a `git2rdata` object
#' @param ... additional arguments passed to `print`
#' @family internal
#' @export
print.git2rdata <- function(x, ...) {
  print.data.frame(x, ...)
  display_metadata(x, minimal = TRUE)
  return(invisible(NULL))
}

#' Summary method for `git2rdata` objects.
#'
#' Prints the summary of the data and the description of the columns when
#' available.
#' @param object a `git2rdata` object
#' @param ... additional arguments passed to `summary`
#' @family internal
#' @export
summary.git2rdata <- function(object, ...) {
  summary.data.frame(object, ...) |>
    print()
  display_metadata(object, minimal = TRUE)
  return(invisible(NULL))
}
