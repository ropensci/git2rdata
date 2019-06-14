#' Optimize an Object for Storage as Plain Text and Add Metadata
#'
#' @description
#' Prepares a vector for storage. When relevant, `meta()`optimizes the object
#' for storage by changing the format to one which needs less characters. The
#' metadata stored in the `meta` attribute, contains all required information to
#' back-transform the optimized format into the original format.
#' @param x the vector.
#' @param ... further arguments to the methods.
#' @return the optimized vector `x` with `meta` attribute.
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
Please use a different NA string or consider using a factor.", call. = FALSE)
  }
  x <- gsub("\\\"", "\\\"\\\"", x)
  to_escape <- grepl("(\"|\t|\n)", x)
  x[to_escape] <- paste0("\"", x[to_escape], "\"")
  x[is.na(x)] <- na
  m <- list(class = "character", na_string = na)
  class(m) <- "meta_detail"
  attr(x, "meta") <- m
  return(x)
}

#' @export
meta.integer <- function(x, ...) {
  m <- list(class = "integer")
  class(m) <- "meta_detail"
  attr(x, "meta") <- m
  return(x)
}

#' @export
meta.numeric <- function(x, ...) {
  m <- list(class = "numeric")
  class(m) <- "meta_detail"
  attr(x, "meta") <- m
  return(x)
}

#' @export
#' @rdname meta
#' @param optimize If `TRUE`, recode the data to get smaller text files. If
#' `FALSE`, `meta()` converts the data to character. Defaults to `TRUE`.
#' @param index an optional named vector with existing factor indices. The names
#' must match the existing factor levels. Unmatched levels from `x` will get new
#' indices.
#' @inheritParams utils::write.table
#' @importFrom assertthat assert_that is.flag noNA
meta.factor <- function(x, optimize = TRUE, na = "NA", index, ...) {
  assert_that(is.flag(optimize), noNA(optimize))
  if (missing(index) || is.null(index)) {
    index <- seq_along(levels(x))
    names(index) <- levels(x)
  } else {
    assert_that(is.integer(index))
    assert_that(anyDuplicated(index) == 0, msg = "duplicate indices")
    new_levels <- which(!levels(x) %in% names(index))
    candidate_index <- seq_len(length(new_levels) + length(index))
    candidate_index <- candidate_index[!candidate_index %in% index]
    extra_index <- candidate_index[seq_along(new_levels)]
    names(extra_index) <- levels(x)[new_levels]
    new_index <- c(index, extra_index)
    index <- new_index[levels(x)]
    empty <- levels(x) == ""
    index[empty] <- new_index[names(new_index) == ""]
    names(index)[empty] <- ""
  }

  if (optimize) {
    z <- index[x]
  } else {
    assert_that(is.string(na), noNA(na), no_whitespace(na))
    if (na %in% levels(x)) {
      stop("one of the levels matches the NA string ('", na, "').
Please use a different NA string or use optimize = TRUE", call. = FALSE)
    }
    z <- meta(as.character(x), optimize = optimize, na = na, ...)
  }

  m <- list(class = "factor", na_string = na, optimize = optimize,
            labels = enc2utf8(names(index)), index = unname(index),
            ordered = is.ordered(x))
  class(m) <- "meta_detail"
  attr(z, "meta") <- m
  return(z)
}

#' @export
#' @rdname meta
#' @importFrom assertthat assert_that is.flag noNA
meta.logical <- function(x, optimize = TRUE, ...){
  assert_that(is.flag(optimize), noNA(optimize))
  if (optimize) {
    x <- as.integer(x)
  }
  m <- list(class = "logical", optimize = optimize)
  class(m) <- "meta_detail"
  attr(x, "meta") <- m
  return(x)
}

#' @export
meta.complex <- function(x, ...) {
  m <- list(class = "complex")
  class(m) <- "meta_detail"
  attr(x, "meta") <- m
  return(x)
}

#' @export
#' @rdname meta
#' @importFrom assertthat assert_that is.flag noNA
meta.POSIXct <- function(x, optimize = TRUE, ...) {
  assert_that(is.flag(optimize), noNA(optimize))
  if (optimize) {
    z <- unclass(x)
    m <- list(class = "POSIXct", optimize = TRUE,
              origin = "1970-01-01 00:00:00", timezone = "UTC")
  } else {
    z <- format(x, format = "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
    m <- list(class = "POSIXct", optimize = FALSE,
              format = "%Y-%m-%dT%H:%M:%SZ", timezone = "UTC")
  }
  class(m) <- "meta_detail"
  attr(z, "meta") <- m
  return(z)
}

#' @export
#' @rdname meta
#' @importFrom assertthat assert_that is.flag noNA
meta.Date <- function(x, optimize = TRUE, ...){
  assert_that(is.flag(optimize), noNA(optimize))
  if (optimize) {
    z <- as.integer(x)
    m <- list(class = "Date", optimize = TRUE, origin = "1970-01-01")
  } else {
    z <- format(x, format = "%Y-%m-%d")
    m <- list(class = "Date", optimize = FALSE, format = "%Y-%m-%d")
  }
  class(m) <- "meta_detail"
  attr(z, "meta") <- m
  return(z)
}

#' @export
#' @importFrom assertthat assert_that
#' @importFrom utils packageVersion
#' @description
#' In case of a data.frame, `meta()` applies itself to each of the columns. The
#' `meta` attribute becomes a named list containing the metadata for each column
#' plus an additional `..generic` element. `..generic` is a reserved name for
#' the metadata and not allowed as column name in a `data.frame`.
#'
#' \code{\link{write_vc}} uses this function to prepare a dataframe for storage.
#' Existing metadata is passed through the optional `old` argument. This
#' argument intended for internal use.
#' @rdname meta
#' @inheritParams write_vc
meta.data.frame <- function(x, optimize = TRUE, na = "NA", sorting, ...) {
  assert_that(
    !has_name(x, "..generic"),
    msg = "'..generic' is a reserved name and not allowed as column name")
  generic <- list(optimize = optimize, "NA string" = na)

  dots <- list(...)
  if (has_name(dots, "old")) {
    old <- dots$old
    assert_that(inherits(old, "meta_list"))
    if (missing(sorting)) {
      sorting <- old[["..generic"]][["sorting"]]
    }
  }

  # apply sorting
  if (missing(sorting) || is.null(sorting) || !length(sorting)) {
    warning("No sorting applied.
Sorting is strongly recommended in combination with version control.")
  } else {
    assert_that(is.character(sorting))
    assert_that(
      all(sorting %in% colnames(x)),
      msg = "All sorting variables must be available in the data.frame")
    if (nrow(x) > 1) {
      x <- x[do.call(order, unname(x[sorting])), , drop = FALSE] # nolint
      if (any_duplicated(x[sorting])) {
        sorted <- paste(sprintf("'%s'", sorting), collapse = ", ")
        sorted <- sprintf("Sorting on %s results in ties.
Add extra sorting variables to ensure small diffs.", sorted)
        warning(sorted)
      }
    }
    generic <- c(generic, sorting = list(sorting))
  }
  # calculate meta for each column
  if (has_name(dots, "old")) {
    common <- names(old)[names(old) %in% colnames(x)]
    if (length(common)) {
      z_common <- lapply(
        common,
        function(id, optimize, na) {
          meta(
            x[[id]], optimize = optimize, na = na,
            index = setNames(old[[id]][["index"]], old[[id]][["labels"]])
          )
        },
        optimize = old[["..generic"]][["optimize"]],
        na = old[["..generic"]][["NA string"]]
      )
      names(z_common) <- common
    } else {
      z_common <- list()
    }
    new <- colnames(x)[!colnames(x) %in% names(old)]
    if (length(new)) {
      z_new <- lapply(x[new], meta, optimize = optimize, na = na)
    } else {
      z_new <- list()
    }
    z <- c(z_common, z_new)
  } else {
    z <- lapply(x, meta, optimize = optimize, na = na)
  }

  # compose generic metadata list
  m <- lapply(z, attr, "meta")
  m <- lapply(
    m,
    function(x) {
      x[!names(x) %in% c("optimize", "na_string")]
    }
  )
  m <- c(..generic = list(generic), m)
  class(m) <- "meta_list"
  m[["..generic"]] <- c(
    list(git2rdata = as.character(packageVersion("git2rdata"))),
    m[["..generic"]], hash = metadata_hash(m))
  z <- lapply(z, `attr<-`, "meta", NULL)

  # convert z to dataframe and add metadata list
  z <- as.data.frame(z, row.names = seq_len(nrow(x)), stringsAsFactors = FALSE)
  attr(z, "meta") <- m
  return(z)
}

no_whitespace <- function(na) {
  !grepl("\\s", na)
}

#' @importFrom assertthat on_failure<-
on_failure(no_whitespace) <- function(call, env) {
  paste0(deparse(call$na), " contains whitespace characters")
}

#' @export
#' @importFrom yaml as.yaml
format.meta_list <- function(x, ...) {
  as.yaml(x, ...)
}

#' @export
#' @importFrom yaml as.yaml
format.meta_detail <- function(x, ...) {
  as.yaml(x, ...)
}

#' @export
print.meta_list <- function(x, ...) {
  cat(format(x), sep = "\n")
}

#' @export
print.meta_detail <- function(x, ...) {
  cat(format(x), sep = "\n")
}

delta <- function(a, b) {
  ifelse(
    is.na(a),
    is.na(b),
    ifelse(is.na(b), FALSE, a == b)
  )
}

any_duplicated <- function(x) {
  y <- vapply(
    x,
    function(z) {
      delta(z[-1], z[-length(z)])
    },
    logical(nrow(x) - 1)
  )
  if (inherits(y, "matrix")) {
    y <- rowSums(y)
  }
  sum(y == ncol(x)) > 0
}
