#' Display metadata for a `git2rdata` object
#' @param x a `git2rdata` object
#' @param minimal logical, if `TRUE` only a message is displayed
#' @family storage
#' @export
#' @importFrom assertthat has_attr
display_metadata <- function(x, minimal = FALSE) {
  stopifnot("`x` is not a `git2rdata` object" = inherits(x, "git2rdata"))
  assert_that(is.flag(minimal), noNA(minimal))
  if (minimal) {
    cat("\nUse `display_metadata()` to view the metadata.")
    return(invisible(NULL))
  }
  display_element_description(x, "table name", "Table name")
  display_element_description(x, "title", "Title")
  display_element_description(x, "description", "Description")
  display_element_description(x, "source", "Path")
  display_element_description(x, "sorting", "Sorting order")
  display_element_description(x, "optimize", "Optimized storage")
  cat("Variables:\n")
  vapply(colnames(x), display_colname_description, character(1), x = x) |>
    cat(sep = "")
  return(invisible(NULL))
}

#' @importFrom assertthat has_attr is.string noNA
display_element_description <- function(x, element, text) {
  assert_that(is.string(element), is.string(text), noNA(element), noNA(text))
  value <- "NA"
  if (has_attr(x, element)) {
    value <- attr(x, element)
  }
  if (length(names(value))) {
    value <- sprintf("%s (%s)", value, names(value))
  }
  sprintf("%s: %s\n", text, paste(value, collapse = ", ")) |>
    cat()
}

#' @importFrom assertthat has_attr is.string noNA
display_colname_description <- function(x, colname) {
  assert_that(is.string(colname), noNA(colname))
  value <- "NA"
  if (has_attr(x[[colname]], "description")) {
    value <- attr(x[[colname]], "description")
  }
  sprintf("  - %s: %s\n", colname, value)
}
