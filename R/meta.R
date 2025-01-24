#' Optimize an Object for Storage as Plain Text and Add Metadata
#'
#' @description
#' Prepares a vector for storage. When relevant, `meta()` optimizes the object
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
#' meta(seq(1, 3, length = 4), digits = 6)
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
meta <- function(x, ..., digits) {
  UseMethod("meta", x)
}

#' @export
#' @rdname meta
#' @importFrom assertthat assert_that is.string noNA
meta.character <- function(x, na = "NA", optimize = TRUE, ...) {
  assert_that(is.string(na), noNA(na), no_whitespace(na))
  assert_that(is.flag(optimize), noNA(optimize))
  x <- enc2utf8(x)
  if (na %in% x) {
    stop("one of the strings matches the NA string ('", na, "')
Please use a different NA string or consider using a factor.", call. = FALSE)
  }
  x <- gsub("\\\"", "\\\"\\\"", x)
  to_escape <- grepl(ifelse(optimize, "(\"|\t|\n)", "(\"|,|\n)"), x)
  x[to_escape] <- paste0("\"", x[to_escape], "\"")
  x[is.na(x)] <- na
  list(class = "character", na_string = na) -> m
  class(m) <- "meta_detail"
  attr(x, "meta") <- m
  return(x)
}

#' @export
meta.integer <- function(x, ...) {
  list(class = "integer") -> m
  class(m) <- "meta_detail"
  attr(x, "meta") <- m
  return(x)
}

#' @export
#' @importFrom assertthat assert_that is.count
meta.numeric <- function(x, ..., digits) {
  stopifnot("`digits` must be a strict positive integer" = is.count(digits))
  x <- signif(x, digits = digits)
  list(class = "numeric", digits = as.integer(digits)) -> m
  class(m) <- "meta_detail"
  attr(x, "meta") <- m
  return(x)
}

#' @export
#' @rdname meta
#' @param optimize If `TRUE`, recode the data to get smaller text files.
#' If `FALSE`, `meta()` converts the data to character.
#' Defaults to `TRUE`.
#' @param index An optional named vector with existing factor indices.
#' The names must match the existing factor levels.
#' Unmatched levels from `x` will get new indices.
#' @inheritParams utils::write.table
#' @importFrom assertthat assert_that is.flag noNA
#' @note The default order of factor levels depends on the current locale.
#' See \code{\link{Comparison}} for more details on that.
#' The same code on a different locale might result in a different sorting.
#' `meta()` ignores, with a warning, any change in the order of factor levels.
#' Add `strict = FALSE` to enforce the new order of factor levels.
meta.factor <- function(
  x, optimize = TRUE, na = "NA", index, strict = TRUE, ...
) {
  assert_that(is.flag(optimize), noNA(optimize), is.flag(strict), noNA(strict))
  levels(x) <- enc2utf8(levels(x))
  if (missing(index) || is.null(index)) {
    index <- seq_along(levels(x))
    names(index) <- levels(x)
  } else {
    assert_that(is.integer(index))
    assert_that(anyDuplicated(index) == 0, msg = "duplicate indices")

    if (
      strict &&
      all(names(index) %in% levels(x)) &&
      all(levels(x) %in% names(index)) &&
      any(levels(x) != names(index))
    ) {
      warning("Same levels with a different order detected.
This change is ignored. Use `strict = FALSE` to reorder the factor.")
      x <- factor(x, levels = names(index))
    }
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
    assert_that(
      !na %in% levels(x),
      msg = paste0("one of the levels matches the NA string ('", na, "').
Please use a different NA string or use optimize = TRUE")
    )
    z <- meta(as.character(x), optimize = optimize, na = na, ...)
  }

  list(
    class = "factor", na_string = na, optimize = optimize,
    labels = names(index), index = unname(index), ordered = is.ordered(x)
  ) -> m
  class(m) <- "meta_detail"
  attr(z, "meta") <- m
  return(z)
}

#' @export
#' @rdname meta
#' @importFrom assertthat assert_that is.flag noNA
meta.logical <- function(x, optimize = TRUE, ...) {
  assert_that(is.flag(optimize), noNA(optimize))
  if (optimize) {
    x <- as.integer(x)
  }
  list(class = "logical", optimize = optimize) -> m
  class(m) <- "meta_detail"
  attr(x, "meta") <- m
  return(x)
}

#' @export
meta.complex <- function(x, ...) {
  list(class = "complex") -> m
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
    list(
      class = "POSIXct", optimize = TRUE, origin = "1970-01-01 00:00:00",
      timezone = "UTC"
    ) -> m
  } else {
    z <- format(x, format = "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
    list(
      class = "POSIXct", optimize = FALSE, format = "%Y-%m-%dT%H:%M:%SZ",
      timezone = "UTC"
    ) -> m
  }
  class(m) <- "meta_detail"
  attr(z, "meta") <- m
  return(z)
}

#' @export
#' @rdname meta
#' @importFrom assertthat assert_that is.flag noNA
meta.Date <- function(x, optimize = TRUE, ...) {
  assert_that(is.flag(optimize), noNA(optimize))
  if (optimize) {
    z <- as.integer(x)
    list(class = "Date", optimize = TRUE, origin = "1970-01-01") -> m
  } else {
    z <- format(x, format = "%Y-%m-%d")
    list(class = "Date", optimize = FALSE, format = "%Y-%m-%d") -> m
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
#' `write_vc()` uses this function to prepare a dataframe for storage.
#' Existing metadata is passed through the optional `old` argument. This
#' argument intended for internal use.
#' @rdname meta
#' @inheritParams write_vc
meta.data.frame <- function(# nolint
  x, optimize = TRUE, na = "NA", sorting, strict = TRUE,
  split_by = character(0), ..., digits
) {
  assert_that(
    !has_name(x, "..generic"),
    msg = "'..generic' is a reserved name and not allowed as column name")
  assert_that(
    !has_name(x, "..hash"),
    msg = "'..hash' is a reserved name and not allowed as column name")
  generic <- list(optimize = optimize, "NA string" = na)
  assert_that(is.character(split_by))
  assert_that(
    all(split_by %in% colnames(x)),
    msg = "All split_by variables must be available in the data.frame")
  assert_that(
    any(!colnames(x) %in% split_by),
    msg = "No remaining variables after splitting"
  )

  dots <- list(...)
  float <- vapply(x, is.numeric, logical(1)) &
    !vapply(x, is.integer, logical(1))
  if (has_name(dots, "old")) {
    old <- dots$old
    assert_that(inherits(old, "meta_list"))
    if (missing(sorting)) {
      sorting <- old[["..generic"]][["sorting"]]
    }
    if (any(float) && missing(digits)) {
      old_numeric <- vapply(
        old, FUN.VALUE = logical(1),
        FUN = function(x) {
          has_name(x, "class") && x$class == "numeric" && has_name(x, "digits")
        }
      )
      digits <- vapply(
        old[old_numeric], FUN.VALUE = numeric(1),
        FUN = function(x) {
          x[["digits"]]
        }
      )
      relevant <- names(float)[float][!names(float)[float] %in% names(digits)]
      rep(6L, length(relevant)) -> digits[relevant]
    }
  }
  if (any(float) && missing(digits)) {
    digits <- 6L
    warning("`digits` was not set. Setting is automatically to 6. See ?meta")
  }
  if (any(float) && is.null(names(digits))) {
    stopifnot(
      "`digits` must be either named or have length 1" = length(digits) == 1
    )
    digits <- rep(digits, sum(float))
    names(digits) <- names(float)[float]
  }
  stopifnot(
    "`digits` must contain all numeric variables of `x`" =
      all(!float) || all(names(float)[float] %in% names(digits))
  )

  # apply sorting
  if (missing(sorting) || is.null(sorting) || !length(sorting)) {
    warning(call. = FALSE, "No sorting applied.
Sorting is strongly recommended in combination with version control.")
  } else {
    assert_that(is.character(sorting))
    assert_that(
      all(sorting %in% colnames(x)),
      msg = "All sorting variables must be available in the data.frame")
    sorting <- unique(c(split_by, sorting))
    if (nrow(x) > 1) {
      old_locale <- set_c_locale()
      x <- x[do.call(order, unname(x[sorting])), , drop = FALSE] # nolint
      set_local_locale(old_locale)
      if (any_duplicated(x[sorting])) {
        sorted <- paste(sprintf("'%s'", sorting), collapse = ", ")
        sorted <- sprintf("Sorting on %s results in ties.
Add extra sorting variables to ensure small diffs.", sorted)
        warning(sorted, call. = FALSE)
      }
    }
    generic <- c(generic, sorting = list(sorting))
  }
  if (length(split_by) > 0) {
    generic <- c(generic, split_by = list(split_by))
  }

  # calculate meta for each column
  if (!has_name(dots, "old")) {
    z <- lapply(
      colnames(x),
      function(id, optimize, na) {
        meta(x[[id]], optimize = optimize, na = na, digits = digits[[id]])
      },
      optimize = optimize, na = na
    )
    names(z) <- colnames(x)
  } else {
    common <- names(old)[names(old) %in% colnames(x)]
    if (length(common)) {
      z_common <- lapply(
        common,
        function(id, optimize, na, strict) {
          meta(
            x[[id]], optimize = optimize, na = na,
            index = setNames(old[[id]][["index"]], old[[id]][["labels"]]),
            strict = strict, digits = digits[[id]]
          )
        },
        optimize = old[["..generic"]][["optimize"]],
        na = old[["..generic"]][["NA string"]], strict = strict
      )
      names(z_common) <- common
    } else {
      z_common <- list()
    }
    new <- colnames(x)[!colnames(x) %in% names(old)]
    if (length(new)) {
      z_new <- lapply(
        new,
        function(id, optimize, na) {
          meta(x[[id]], optimize = optimize, na = na, digits = digits[[id]])
        },
        optimize = optimize, na = na
      )
      names(z_new) <- new
    } else {
      z_new <- list()
    }
    z <- c(z_common, z_new)
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
