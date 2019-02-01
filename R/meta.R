#' Optimize a vector for storage as plain text and add meta data
#'
#' \code{\link{write_vc}} applies this function automatically on your
#' data.frame.
#' @param x the vector
#' @param optimize recode the data to get smaller text files. Defaults to TRUE
#' @return the optimized vector `x` with `meta` attribute
#' @export
#' @docType methods
#' @family internal
meta <- function(x, optimize = TRUE) {
  UseMethod("meta", x)
}

#' @export
meta.character <- function(x, optimize = TRUE) {
  attr(x, "meta") <- "    class: character"
  x <- gsub("\\\"", "\\\"\\\"", x)
  to_escape <- grepl("(\"|\t|\n)", x)
  x[to_escape] <- paste0("\"", x[to_escape], "\"")
  x[x == "NA"] <- "\"NA\""
  x[is.na(x)] <- "NA"
  return(x)
}

#' @export
meta.integer <- function(x, optimize = TRUE) {
  attr(x, "meta") <- "    class: integer"
  return(x)
}

#' @export
meta.numeric <- function(x, optimize = TRUE) {
  attr(x, "meta") <- "    class: numeric"
  return(x)
}
#' @export
meta.factor <- function(x, optimize = TRUE) {
  if (isTRUE(optimize)) {
      z <- as.integer(x)
  } else {
      z <- x
  }
  sprintf(
    "    class: factor\n    levels:\n%s%s",
    paste0("        - \"", levels(x), "\"", collapse = "\n"),
    ifelse(is.ordered(x), "\n    ordered", "")
  ) -> attr(z, "meta")
  return(z)
}

#' @export
meta.logical <- function(x, optimize = TRUE){
  if (isTRUE(optimize)) {
      x <- as.integer(x)
  }
  attr(x, "meta") <- "    class: logical"
  return(x)
}

#' @export
meta.complex <- function(x, optimize = TRUE) {
  attr(x, "meta") <- "    class: complex"
  return(x)
}

#' @export
meta.POSIXct <- function(x, optimize = TRUE) {
  if (isTRUE(optimize)) {
      z <- unclass(x)
  } else {
      z <- x
  }
  attr(z, "meta") <- "    class: POSIXct\n    origin: 1970-01-01\n"
  return(z)
}

#' @export
meta.Date <- function(x, optimize = TRUE){
  if (isTRUE(optimize)) {
      z <- as.integer(x)
  } else {
      z <- x
  }
  attr(z, "meta") <- "    class: Date\n    origin: 1970-01-01\n"
  return(z)
}
