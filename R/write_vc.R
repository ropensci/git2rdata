#' Write a \code{data.frame} to a git repository
#'
#' This will create two files. The `".tsv"` file contains the raw data.
#' The `".yml"` contains the meta data on the columns in YAML format.
#' @param x the `data.frame
#' @param file the name of the file without file extension. Can include a
#' relative path. It is relative to the `root`.
#' @param root The root of a project. Can be a file path or a `git-repository`.
#' Defaults to the current working directory (".").
#' @param sorting a vector of column names defining which columns to use for
#' sorting \code{x} and in what order to use them. Only required when writing
#' new metadata.
#' @param strict What to do when the metadata changes. `strict = FALSE` will
#' overwrite the data with a warning listing the changes, `strict = TRUE` will
#' return an error and leave the data as is. Default to `TRUE`
#' @param ... additional parameters used in some methods
#' @inheritParams meta
#' @inheritParams utils::write.table
#' @return a named vector with the file paths relative to `root`. The names
#' contain the hashes of the files.
#' @export
#' @family storage
#' @template example-io
write_vc <- function(
  x, file, root = ".", sorting, strict = TRUE, optimize = TRUE, na = "NA",
  ...
) {
  UseMethod("write_vc", root)
}

#' @export
write_vc.default <- function(
  x, file, root, sorting, strict = TRUE, optimize = TRUE, na = "NA", ...
) {
  stop("a 'root' of class ", class(root), " is not supported")
}

#' @export
#' @importFrom assertthat assert_that is.string is.flag
#' @importFrom yaml read_yaml write_yaml
#' @importFrom utils write.table
#' @importFrom git2r hashfile
write_vc.character <- function(
  x, file, root = ".", sorting, strict = TRUE, optimize = TRUE, na = "NA",
  ...
){
  assert_that(
    inherits(x, "data.frame"), is.string(file), is.string(root),  is.string(na),
    noNA(na), no_whitespace(na), is.flag(strict), is.flag(optimize)
  )
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  file <- clean_data_path(root = root, file = file)
  if (!file.exists(dirname(file["raw_file"]))) {
    dir.create(dirname(file["raw_file"]), recursive = TRUE)
  }

  if (file.exists(file["meta_file"])) {
    old <- read_yaml(file["meta_file"])
    class(old) <- "meta_list"
    if (missing(sorting)) {
      sorting <- old[["..generic"]][["sorting"]]
      if (is.null(sorting)) {
        sorting <- character(0)
      }
    }
    raw_data <- meta(x, optimize = optimize, na = na, sorting = sorting)
    problems <- compare_meta(attr(raw_data, "meta"), old)
    if (length(problems)) {
      if (strict) {
        stop(paste(problems, collapse = "\n"))
      }
      warning(paste(problems, collapse = "\n"))
      raw_data <- meta(
        x,
        optimize = old[["..generic"]][["optimize"]],
        na = old[["..generic"]][["NA string"]],
        sorting = old[["..generic"]][["sorting"]]
      )
    }
  } else {
    raw_data <- meta(x, optimize = optimize, na = na, sorting = sorting)
    write_yaml(attr(raw_data, "meta"), file["meta_file"],
               fileEncoding = "UTF-8")
  }
  write.table(
    x = raw_data, file = file["raw_file"], append = FALSE, quote = FALSE,
    sep = "\t", eol = "\n", na = na, dec = ".", row.names = FALSE,
    col.names = TRUE, fileEncoding = "UTF-8"
  )

  hashes <- gsub(paste0("^", root, "/"), "", file)
  names(hashes) <- hashfile(file)

  return(hashes)
}

#' @importFrom methods setOldClass
setOldClass("git_repository")

#' @rdname write_vc
#' @param stage stage the changes after writing the data. Defaults to FALSE
#' @inheritParams git2r::add
#' @export
#' @importFrom git2r workdir add
#' @importFrom assertthat assert_that is.flag
write_vc.git_repository <- function(
  x, file, root, sorting, strict = TRUE, optimize = TRUE, na = "NA", ...,
  stage = FALSE, force = FALSE
){
  assert_that(is.flag(stage), is.flag(force))
  hashes <- write_vc(
    x = x, file = file, root = workdir(root), sorting = sorting,
    strict = strict, optimize = optimize, na = na, ...
  )
  if (!stage) {
    return(hashes)
  }
  add(root, path = hashes, force = force)
  return(hashes)
}

compare_meta <- function(new, old) {
  problems <- character(0)
  if (isTRUE(all.equal(new, old))) {
    return(problems)
  }
  new_optimize <- new[["..generic"]][["optimize"]]
  old_optimize <- old[["..generic"]][["optimize"]]
  if (new_optimize != old_optimize) {
    problems <- c(
      problems,
      sprintf(
        "new data is %s, whereas old data was %s",
        ifelse(new_optimize, "optimized", "verbose"),
        ifelse(old_optimize, "optimized", "verbose")
      )
    )
  }
  if (new[["..generic"]][["NA string"]] != old[["..generic"]][["NA string"]]) {
    problems <- c(
      problems,
      sprintf(
        "new data uses '%s' as NA string, whereas old data used '%s'",
        new[["..generic"]][["NA string"]], old[["..generic"]][["NA string"]]
      )
    )
  }
  new_sorting <- new[["..generic"]][["sorting"]]
  old_sorting <- old[["..generic"]][["sorting"]]
  if (!isTRUE(all.equal(new_sorting, old_sorting))) {
    if (length(new_sorting) < length(old_sorting)) {
      problems <- c(problems, "new data uses less variables for sorting")
    }
    common_sorting <- seq_len(min(length(new_sorting), length(old_sorting)))
    if (any(new_sorting[common_sorting] != old_sorting[common_sorting])) {
      problems <- c(problems, "new data uses different variables for sorting")
    }
  }

  new <- new[names(new) != "..generic"]
  old <- old[names(old) != "..generic"]
  if (length(new) != length(old)) {
    problems <- c(problems, "new data has a different number of variables")
  }
  if (!all(names(new) %in% names(old))) {
    problems <- c(problems,
      paste(
        "new variables:",
        paste(names(new)[!names(new) %in% names(old)], collapse = ", ")
      )
    )
  }
  if (!all(names(old) %in% names(new))) {
    problems <- c(problems,
      paste(
        "deleted variables:",
        paste(names(old)[!names(old) %in% names(new)], collapse = ", ")
      )
    )
  }

  common_variables <- names(old)[names(old) %in% names(new)]
  old_class <- sapply(old[common_variables], "[[", "class")
  new_class <- sapply(new[common_variables], "[[", "class")
  delta <- which(old_class != new_class)
  if (length(delta)) {
    problems <- c(problems,
      sprintf("change in class: %s from %s to %s", common_variables[delta],
              old_class[delta], new_class[delta])
    )
  }

  common_variables <- common_variables[old_class == new_class]
  old_class <- old_class[old_class == new_class]
  for (id in common_variables[old_class == "factor"]) {
    if (old[[id]]$ordered != old[[id]]$ordered) {
      problems <- c(
        problems,
        sprintf(
          "%s changes from %s to %s", id,
          ifelse(old[[id]]$ordered, "ordinal", "nominal"),
          ifelse(new[[id]]$ordered, "ordinal", "nominal")
        )
      )
    }
    if (!isTRUE(all.equal(old[[id]][["labels"]],  new[[id]][["labels"]]))) {
      problems <- c(problems, sprintf("new factor labels for %s", id))
    }
    if (!isTRUE(all.equal(old[[id]][["index"]],  new[[id]][["index"]]))) {
      problems <- c(problems, sprintf("new indices labels for %s", id))
    }
  }

  return(problems)
}
