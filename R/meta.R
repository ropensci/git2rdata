#' Optimize a vector for storage as plain text and add meta data
#' @param x the vector
#' @param optimize recode the data to get smaller text files. Defaults to TRUE
#' @return the optimized vector `x` with `meta` attribute
#' @name meta
#' @rdname meta
#' @exportMethod meta
#' @docType methods
#' @importFrom methods setGeneric
setGeneric(
  name = "meta",
  def = function(x, optimize = TRUE){
    standardGeneric("meta") # nocov
  }
)

#' @rdname meta
#' @importFrom methods setMethod
setMethod(
  f = "meta",
  signature = signature(x = "character"),
  definition = function(x, optimize = TRUE){
    attr(x, "meta") <- "    class: character"
    return(x)
  }
)

#' @rdname meta
#' @importFrom methods setMethod
setMethod(
  f = "meta",
  signature = signature(x = "integer"),
  definition = function(x, optimize = TRUE){
    attr(x, "meta") <- "    class: integer"
    return(x)
  }
)

#' @rdname meta
#' @importFrom methods setMethod
setMethod(
  f = "meta",
  signature = signature(x = "numeric"),
  definition = function(x, optimize = TRUE){
    attr(x, "meta") <- "    class: numeric"
    return(x)
  }
)

#' @rdname meta
#' @importFrom methods setMethod
setMethod(
  f = "meta",
  signature = signature(x = "factor"),
  definition = function(x, optimize = TRUE){
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
)

#' @rdname meta
#' @importFrom methods setMethod
setMethod(
  f = "meta",
  signature = signature(x = "logical"),
  definition = function(x, optimize = TRUE){
    if (isTRUE(optimize)) {
        x <- as.integer(x)
    }
    attr(x, "meta") <- "    class: logical"
    return(x)
  }
)

#' @rdname meta
#' @importFrom methods setMethod
setMethod(
  f = "meta",
  signature = signature(x = "complex"),
  definition = function(x, optimize = TRUE){
    attr(x, "meta") <- "    class: complex"
    return(x)
  }
)

#' @rdname meta
#' @importFrom methods setMethod
setMethod(
  f = "meta",
  signature = signature(x = "POSIXct"),
  definition = function(x, optimize = TRUE){
    if (isTRUE(optimize)) {
        z <- unclass(x)
    } else {
        z <- x
    }
    attr(z, "meta") <- "    class: POSIXct\n    origin: 1970-01-01\n"
    return(z)
  }
)

#' @rdname meta
#' @importFrom methods setMethod
setMethod(
  f = "meta",
  signature = signature(x = "Date"),
  definition = function(x, optimize = TRUE){
    if (isTRUE(optimize)) {
        z <- unclass(x)
    } else {
        z <- x
    }
    attr(z, "meta") <- "    class: Date\n    origin: 1970-01-01\n"
    return(z)
  }
)
