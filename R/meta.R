#' Optimize a vector for storage as plain text and add meta data
#'
#' \code{\link{write_vc}} applies this function automatically on your
#' data.frame.
#' @param x the vector
#' @param ... further arguments to the methods
#' @return the optimized vector `x` with `meta` attribute
#' @export
#' @docType methods
#' @family internal
#' @examples
#' meta(c(NA, "'NA'", '"NA"', "abc\tdef", "abc\ndef"))
#' meta(1:3)
#' meta(seq(1, 3, length = 4))
#' meta(factor(c("b", NA, "NA"), levels = c("NA", "b", "c")))
#' meta(factor(c("b", NA, "a"), levels = c("a", "b", "c")), optimize = FALSE)
#' meta(factor(c("b", NA, "a"), levels = c("a", "b", "c"), ordered = TRUE))
#' meta(
#'   factor(c("b", NA, "a"), levels = c("a", "b", "c"), ordered = TRUE),
#'   optimize = FALSE
#' )
#' meta(c(FALSE, NA, TRUE))
#' meta(c(FALSE, NA, TRUE), optimize = FALSE)
#' meta(complex(real = c(1, NA, 2), imaginary = c(3, NA, -1)))
#' meta(as.POSIXct("2019-02-01 10:59:59", tz = "CET"))
#' meta(as.POSIXct("2019-02-01 10:59:59", tz = "CET"), optimize = FALSE)
#' meta(as.Date("2019-02-01"))
#' meta(as.Date("2019-02-01"), optimize = FALSE)
meta <- function(x, ...) {
  UseMethod("meta", x)
}

#' @export
#' @rdname meta
#' @importFrom assertthat assert_that is.string noNA
meta.character <- function(x, na = "NA", ...) {
  assert_that(is.string(na), noNA(na), no_whitespace(na))
  if (na %in% x) {
    stop("one of the strings matches the NA string ('", na, "')
Please use a different NA string or consider using a factor.")
  }
  attr(x, "meta") <- "    class: character"
  attr(x, "na_string") <- na
  x <- gsub("\\\"", "\\\"\\\"", x)
  to_escape <- grepl("(\"|\t|\n)", x)
  x[to_escape] <- paste0("\"", x[to_escape], "\"")
  x[is.na(x)] <- na
  return(x)
}

#' @export
meta.integer <- function(x, ...) {
  attr(x, "meta") <- "    class: integer"
  return(x)
}

#' @export
meta.numeric <- function(x, ...) {
  attr(x, "meta") <- "    class: numeric"
  return(x)
}

#' @export
#' @rdname meta
#' @param optimize recode the data to get smaller text files. Defaults to TRUE
#' @inheritParams utils::write.table
meta.factor <- function(x, optimize = TRUE, na = "NA", ...) {
  if (isTRUE(optimize)) {
    z <- as.integer(x)
    na <- "NA"
  } else {
    assert_that(is.string(na), noNA(na), no_whitespace(na))
    if (na %in% levels(x)) {
      stop("one of the levels matches the NA string ('", na, "').
Please use a different NA string or use optimize = TRUE")
    }
    z <- meta(as.character(x), optimize = optimize, na = na, ...)
  }
  levels(x) <- gsub("\\\"", "\\\"\\\"", levels(x))
  sprintf(
    "    class: factor\n    levels:\n%s%s",
    paste0("        - \"", levels(x), "\"", collapse = "\n"),
    ifelse(is.ordered(x), "\n    ordered", "")
  ) -> attr(z, "meta")
  attr(z, "na_string") <- na
  return(z)
}

#' @export
#' @rdname meta
meta.logical <- function(x, optimize = TRUE, ...){
  if (isTRUE(optimize)) {
    x <- as.integer(x)
  }
  attr(x, "meta") <- "    class: logical"
  return(x)
}

#' @export
meta.complex <- function(x, ...) {
  attr(x, "meta") <- "    class: complex"
  return(x)
}

#' @export
#' @rdname meta
meta.POSIXct <- function(x, optimize = TRUE, ...) {
  if (isTRUE(optimize)) {
    z <- unclass(x)
    attr(z, "meta") <-
      "    class: POSIXct\n    origin: 1970-01-01 00:00:00\n    timezone: UTC"
  } else {
    z <- format(x, format = "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
    attr(z, "meta") <-
      "    class: POSIXct\n    format: %Y-%m-%dT%H:%M:%SZ\n    timezone: UTC"
  }
  return(z)
}

#' @export
#' @rdname meta
meta.Date <- function(x, optimize = TRUE, ...){
  if (isTRUE(optimize)) {
    z <- as.integer(x)
    attr(z, "meta") <-
      "    class: Date\n    origin: 1970-01-01\n"
  } else {
    z <- format(x, format = "%Y-%m-%d", tz = "UTC")
    attr(z, "meta") <-
      "    class: Date\n    format: %Y-%m-%d\n"
  }
  return(z)
}

no_whitespace <- function(na) {
  !grepl("\\s", na)
}

#' @importFrom assertthat on_failure<-
on_failure(no_whitespace) <- function(call, env) {
  paste0(deparse(call$na), " contains whitespace characters")
}
