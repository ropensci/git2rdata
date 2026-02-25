#' @noRd
#' @importFrom utils flush.console
#' @importFrom assertthat assert_that is.flag noNA
display <- function(verbose, message, linefeed = TRUE) {
  assert_that(is.flag(verbose), noNA(verbose))
  assert_that(is.flag(linefeed), noNA(linefeed))

  if (verbose) {
    message(message, appendLF = linefeed)
    flush.console()
  }
  return(invisible(NULL))
}

#' Validate the convert argument
#' @noRd
#' @importFrom assertthat assert_that
validate_convert <- function(convert, colnames_x) {
  if (is.null(convert) || length(convert) == 0) {
    return(list())
  }

  assert_that(
    is.list(convert),
    msg = "convert must be a list"
  )

  assert_that(
    !is.null(names(convert)),
    msg = "convert must be a named list"
  )

  assert_that(
    all(names(convert) != ""),
    msg = "all elements of convert must be named"
  )

  assert_that(
    all(names(convert) %in% colnames_x),
    msg = paste(
      "all names in convert must be present in colnames of x.",
      "Missing:",
      paste(names(convert)[!names(convert) %in% colnames_x], collapse = ", ")
    )
  )

  for (col_name in names(convert)) {
    conv <- convert[[col_name]]
    assert_that(
      is.character(conv),
      msg = sprintf(
        "convert[['%s']] must be a character vector",
        col_name
      )
    )
    assert_that(
      length(conv) == 2,
      msg = sprintf(
        "convert[['%s']] must have length 2",
        col_name
      )
    )
    assert_that(
      !is.null(names(conv)),
      msg = sprintf(
        "convert[['%s']] must be a named vector",
        col_name
      )
    )
    assert_that(
      all(names(conv) %in% c("write", "read")),
      msg = sprintf(
        "convert[['%s']] must have names 'write' and 'read'",
        col_name
      )
    )
    assert_that(
      "write" %in% names(conv) && "read" %in% names(conv),
      msg = sprintf(
        "convert[['%s']] must have both 'write' and 'read' elements",
        col_name
      )
    )

    for (direction in c("write", "read")) {
      func_spec <- conv[[direction]]
      assert_that(
        grepl("::", func_spec, fixed = TRUE),
        msg = sprintf(
          "convert[['%s']][['%s']] must be in 'package::function' format",
          col_name,
          direction
        )
      )

      parts <- strsplit(func_spec, "::", fixed = TRUE)[[1]]
      assert_that(
        length(parts) == 2,
        msg = sprintf(
          "convert[['%s']][['%s']] must have exactly one '::'",
          col_name,
          direction
        )
      )

      pkg_name <- parts[1]
      func_name <- parts[2]

      assert_that(
        nzchar(pkg_name) && nzchar(func_name),
        msg = sprintf(
          "convert[['%s']][['%s']] has empty package or function name",
          col_name,
          direction
        )
      )

      if (!requireNamespace(pkg_name, quietly = TRUE)) {
        stop(
          sprintf(
            "Package '%s' required for convert[['%s']][['%s']] is not available",
            pkg_name,
            col_name,
            direction
          ),
          call. = FALSE
        )
      }

      if (!exists(func_name, where = asNamespace(pkg_name), mode = "function")) {
        stop(
          sprintf(
            "Function '%s' not found in package '%s' for convert[['%s']][['%s']]",
            func_name,
            pkg_name,
            col_name,
            direction
          ),
          call. = FALSE
        )
      }
    }
  }

  return(convert)
}

#' Apply conversion functions to columns
#' @noRd
apply_convert <- function(x, convert, direction = "write") {
  if (is.null(convert) || length(convert) == 0) {
    return(x)
  }

  for (col_name in names(convert)) {
    func_spec <- convert[[col_name]][[direction]]
    parts <- strsplit(func_spec, "::", fixed = TRUE)[[1]]
    pkg_name <- parts[1]
    func_name <- parts[2]

    func <- get(func_name, envir = asNamespace(pkg_name), mode = "function")
    x[[col_name]] <- func(x[[col_name]])
  }

  return(x)
}
