#' Print method for `git2rdata` objects.
#'
#' Prints the data and the description of the columns when available.
#' @param x a `git2rdata` object
#' @param ... additional arguments passed to `print`
#' @export
print.git2rdata <- function(x, ...) {
  class(x) <- tail(class(x), -1)
  print(x, ...)
  vapply(colnames(x), display_description, character(1), x = x) |>
    cat()
  return(invisible(NULL))
}

#' @importFrom assertthat has_attr
display_description <- function(x, colname) {
  if (!has_attr(x[[colname]], "description")) {
    return("")
  }
  sprintf("\n%s: %s", colname, attr(x[[colname]], "description"))
}

#' Summary method for `git2rdata` objects.
#'
#' Prints the summary of the data and the description of the columns when
#' available.
#' @param object a `git2rdata` object
#' @param ... additional arguments passed to `summary`
#' @export
summary.git2rdata <- function(object, ...) {
  class(object) <- tail(class(object), -1)
  summary(object, ...) |>
    print()
  vapply(colnames(object), display_description, character(1), x = object) |>
    cat()
  return(invisible(NULL))
}
