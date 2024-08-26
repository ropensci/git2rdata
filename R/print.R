#' Print method for `git2rdata` objects.
#'
#' Prints the data and the description of the columns when available.
#' @param x a `git2rdata` object
#' @param ... additional arguments passed to `print`
#' @family internal
#' @export
#' @importFrom utils tail
print.git2rdata <- function(x, ...) {
  class(x) <- tail(class(x), -1)
  print(x, ...)
  if (has_attr(x, "table name")) {
    cat("\nTable name: ", attr(x, "table name"))
  }
  if (has_attr(x, "title")) {
    cat("\nTitle: ", attr(x, "title"))
  }
  if (has_attr(x, "description")) {
    cat("\nDescription: ", attr(x, "description"))
  }
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
#' @family internal
#' @export
#' @importFrom utils tail
summary.git2rdata <- function(object, ...) {
  class(object) <- tail(class(object), -1)
  summary(object, ...) |>
    print()
  if (has_attr(object, "table name")) {
    cat("\nTable name: ", attr(object, "table name"))
  }
  if (has_attr(object, "title")) {
    cat("\nTitle: ", attr(object, "title"))
  }
  if (has_attr(object, "description")) {
    cat("\nDescription: ", attr(object, "description"))
  }
  vapply(colnames(object), display_description, character(1), x = object) |>
    cat()
  return(invisible(NULL))
}
