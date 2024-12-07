#' Store a Data.Frame as a Git2rdata Object on Disk
#'
#' A git2rdata object consists of two files.
#' The `".tsv"` file contains the raw data as a plain text tab separated file.
#' The `".yml"` contains the metadata on the columns in plain text YAML format.
#' See `vignette("plain text", package = "git2rdata")` for more details on the
#' implementation.
#' @param x the `data.frame`.
#' @param file the name of the git2rdata object. Git2rdata objects cannot
#' have dots in their name. The name may include a relative path. `file` is a
#' path relative to the `root`.
#' Note that `file` must point to a location within `root`.
#' @param root The root of a project. Can be a file path or a `git-repository`.
#' Defaults to the current working directory (`"."`).
#' @param sorting an optional vector of column names defining which columns to
#' use for sorting `x` and in what order to use them.
#' The default empty `sorting` yields a warning.
#' Add `sorting` to avoid this warning.
#' Strongly recommended in combination with version control.
#' See `vignette("efficiency", package = "git2rdata")` for an illustration of
#' the importance of sorting.
#' @param strict What to do when the metadata changes. `strict = FALSE`
#' overwrites the data and the metadata with a warning listing the changes,
#' `strict = TRUE` returns an error and leaves the data and metadata as is.
#' Defaults to `TRUE`.
#' @param ... parameters used in some methods
#' @inheritParams meta
#' @inheritParams utils::write.table
#' @return a named vector with the file paths relative to `root`. The names
#' contain the hashes of the files.
#' @export
#' @family storage
#' @template example_io
#' @note `..generic` is a reserved name for the metadata and is a forbidden
#' column name in a `data.frame`.
write_vc <- function(
  x, file, root = ".", sorting, strict = TRUE, optimize = TRUE, na = "NA", ...,
  split_by
) {
  UseMethod("write_vc", root)
}

#' @export
write_vc.default <- function(
  x, file, root, sorting, strict = TRUE, optimize = TRUE, na = "NA", ...
) {
  stop("a 'root' of class ", class(root), " is not supported", call. = FALSE)
}

#' @rdname write_vc
#' @param split_by An optional vector of variables name to split the text files.
#' This creates a separate file for every combination.
#' We prepend these variables to the vector of `sorting` variables.
#' @param digits The number of significant digits of the smallest absolute
#' value.
#' The function applies the rounding automatically.
#' Only relevant for numeric variables.
#' Either a single positive integer or a named vector where the names link to
#' the variables in the `data.frame`.
#' Defaults to `6` with a warning.
#' @export
#' @importFrom assertthat assert_that is.string is.flag
#' @importFrom yaml read_yaml write_yaml
#' @importFrom utils write.table
#' @importFrom git2r hash
write_vc.character <- function(
  x, file, root = ".", sorting, strict = TRUE, optimize = TRUE,
  na = "NA", ..., append = FALSE, split_by = character(0), digits
) {
  assert_that(
    inherits(x, "data.frame"), is.string(file), is.string(root), is.string(na),
    noNA(na), no_whitespace(na), is.flag(strict), is.flag(optimize),
    is.flag(append), noNA(append), noNA(strict), noNA(optimize)
  )
  if (append) {
    x <- append_df(x = x, file = file, root = root)
  }
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  file <- clean_data_path(root = root, file = file)
  if (!file.exists(dirname(file["raw_file"]))) {
    dir.create(dirname(file["raw_file"]), recursive = TRUE)
  }

  if (!file.exists(file["meta_file"])) {
    raw_data <- meta(
      x, optimize = optimize, na = na, sorting = sorting, split_by = split_by,
      digits = digits
    )
  } else {
    tryCatch(
      is_git2rmeta(file = remove_root(file = file["meta_file"], root = root),
                   root = root, message = "error"),
      error = function(e) {
        stop(paste("Existing metadata file is invalid.", e$message, sep = "\n"),
             call. = FALSE)
      }
    )
    old <- read_yaml(file["meta_file"])
    class(old) <- "meta_list"
    raw_data <- meta(
      x, optimize = optimize, na = na, sorting = sorting, old = old,
      strict = strict, split_by = split_by, digits = digits
    )
    problems <- compare_meta(attr(raw_data, "meta"), old)
    if (length(problems)) {
      problems <- c(
"See vignette('version_control', package = 'git2rdata') for more information.",
          "", problems)
      if (strict) {
        problems <- c(
          "The data was not overwritten because of the issues below.", problems)
        stop(paste(problems, collapse = "\n"), call. = FALSE)
      }
      problems <- c(
        "Changes in the metadata may lead to unnecessarily large diffs.",
        problems)
      warning(paste(problems, collapse = "\n"), call. = FALSE)
      if (missing(sorting) && !is.null(old[["..generic"]][["sorting"]])) {
        sorting <- old[["..generic"]][["sorting"]]
      }
    }
  }
  file["raw_file"] <- ifelse(
    attr(raw_data, "meta")[["..generic"]][["optimize"]],
    file["raw_file"],
    gsub("\\.tsv$", ".csv", file["raw_file"])
  )
  assert_that(
    unlink(file["raw_file"], recursive = TRUE) == 0,
    msg = "Failed to remove existing files."
  )
  if (length(split_by) == 0) {
    write.table(
      x = raw_data, file = file["raw_file"], append = FALSE, quote = FALSE,
      sep = ifelse(
        attr(raw_data, "meta")[["..generic"]][["optimize"]], "\t", ","
      ),
      eol = "\n", na = na, dec = ".", row.names = FALSE,
      col.names = TRUE, fileEncoding = "UTF-8"
    )
  } else {
    index <- unique(raw_data[split_by])
    index[["..hash"]] <- hash(apply(index, 1, paste, collapse = "\t"))
    dir.create(file["raw_file"], showWarnings = FALSE, recursive = TRUE)
    write.table(
      x = index, file = file.path(file["raw_file"], "index.tsv"),
      append = FALSE, quote = FALSE, sep = "\t", eol = "\n", na = na, dec = ".",
      row.names = FALSE, col.names = TRUE, fileEncoding = "UTF-8"
    )
    detail_names <- colnames(raw_data)[!colnames(raw_data) %in% split_by]
    vapply(
      seq_len(nrow(index)),
      function(i) {
        matching <- vapply(
          split_by,
          function(split) {
            raw_data[[split]] == index[[split]][i]
          },
          logical(nrow(raw_data))
        )
        rf <- file.path(file["raw_file"], paste0(index[i, "..hash"], ".tsv"))
        write.table(
          x = raw_data[apply(matching, 1, all), detail_names, drop = FALSE],
          file = rf,
          append = FALSE, quote = FALSE, sep = "\t", eol = "\n", na = na,
          dec = ".", row.names = FALSE, col.names = TRUE, fileEncoding = "UTF-8"
        )
        return(TRUE)
      },
      logical(1)
    )
  }
  meta_data <- attr(raw_data, "meta")
  meta_data[["..generic"]][["git2rdata"]] <- as.character(
    packageVersion("git2rdata")
  )
  meta_data[["..generic"]][["data_hash"]] <- datahash(file["raw_file"])
  write_yaml(meta_data, file["meta_file"], fileEncoding = "UTF-8")

  hashes <- remove_root(file = file, root = root)
  names(hashes) <-
    c(
      meta_data[["..generic"]][["data_hash"]],
      meta_data[["..generic"]][["hash"]]
    )

  return(hashes)
}

#' @importFrom methods setOldClass
setOldClass("git_repository")

#' @rdname write_vc
#' @param stage Logical value indicating whether to stage the changes after
#' writing the data. Defaults to `FALSE`.
#' @inheritParams git2r::add
#' @export
#' @importFrom git2r workdir add
#' @importFrom assertthat assert_that is.flag noNA
write_vc.git_repository <- function(
  x, file, root, sorting, strict = TRUE, optimize = TRUE, na = "NA", ...,
  stage = FALSE, force = FALSE
) {
  assert_that(is.flag(stage), is.flag(force), noNA(stage), noNA(force))
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
  new[["..generic"]][["data_hash"]] <- NULL
  old[["..generic"]][["data_hash"]] <- NULL
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
        "- New data is %s, whereas old data was %s.
    Check the 'optimized' argument.",
        ifelse(new_optimize, "optimized", "verbose"),
        ifelse(old_optimize, "optimized", "verbose")
      )
    )
  }
  if (new[["..generic"]][["NA string"]] != old[["..generic"]][["NA string"]]) {
    problems <- c(
      problems,
      sprintf(
        "- New data uses '%s' as NA string, whereas old data used '%s'.
     Check the 'NA' argument.",
        new[["..generic"]][["NA string"]], old[["..generic"]][["NA string"]]
      )
    )
  }
  new_sorting <- new[["..generic"]][["sorting"]]
  old_sorting <- old[["..generic"]][["sorting"]]
  if (!isTRUE(all.equal(new_sorting, old_sorting))) {
    sprintf(
      "- The sorting variables changed.
    - Sorting for the new data: %s.
    - Sorting for the old data: %s.",
      paste(sprintf("'%s'", new_sorting), collapse = ", "),
      paste(sprintf("'%s'", old_sorting), collapse = ", ")
    ) -> extra
    problems <- c(problems, extra)
  }
  new_split_by <- new[["..generic"]][["split_by"]]
  old_split_by <- old[["..generic"]][["split_by"]]
  if (!isTRUE(all.equal(new_split_by, old_split_by))) {
    sprintf(
      "- The split_by variables changed.
    - Split_by for the new data: %s.
    - Split_by for the old data: %s.",
      paste(sprintf("'%s'", new_split_by), collapse = ", "),
      paste(sprintf("'%s'", old_split_by), collapse = ", ")
    ) -> extra
    problems <- c(problems, extra)
  }


  new <- new[names(new) != "..generic"]
  old <- old[names(old) != "..generic"]
  if (length(new) != length(old)) {
    problems <- c(problems, "- New data has a different number of variables.")
  }
  if (!all(names(new) %in% names(old))) {
    problems <- c(problems,
      sprintf(
        "- New variables: %s.",
        paste(names(new)[!names(new) %in% names(old)], collapse = ", ")
      )
    )
  }
  if (!all(names(old) %in% names(new))) {
    problems <- c(problems,
      sprintf(
        "- Deleted variables: %s.",
        paste(names(old)[!names(old) %in% names(new)], collapse = ", ")
      )
    )
  }

  common_variables <- names(old)[names(old) %in% names(new)]
  old_class <- vapply(old[common_variables], "[[", character(1), "class")
  new_class <- vapply(new[common_variables], "[[", character(1), "class")
  delta <- which(old_class != new_class)
  if (length(delta)) {
    problems <- c(problems,
      sprintf("- Change in class: '%s' from %s to %s.", common_variables[delta],
              old_class[delta], new_class[delta])
    )
  }

  problems <- compare_factors(
    problems = problems,
    common_variables = common_variables[old_class == new_class],
    old_class = old_class[old_class == new_class],
    old = old,
    new = new
  )

  return(problems)
}

compare_factors <- function(problems, common_variables, old_class, old, new) {
  for (id in common_variables[old_class == "factor"]) {
    if (old[[id]]$ordered != new[[id]]$ordered) {
      problems <- c(
        problems,
        sprintf(
          "- '%s' changes from %s to %s.", id,
          ifelse(old[[id]]$ordered, "ordinal", "nominal"),
          ifelse(new[[id]]$ordered, "ordinal", "nominal")
        )
      )
    }
    if (!isTRUE(all.equal(old[[id]][["labels"]],  new[[id]][["labels"]]))) {
      problems <- c(problems, sprintf("- New factor labels for '%s'.", id))
    }
    if (!isTRUE(all.equal(old[[id]][["index"]],  new[[id]][["index"]]))) {
      problems <- c(problems, sprintf("- New indices for '%s'.", id))
    }
  }
  return(problems)
}
#' @noRd
#' @param file the file including the path
#' @param root the path of the root
remove_root <- function(file, root) {
  n_root <- nchar(root) + 1
  has_root <- substr(file, 1, n_root) == paste0(root, "/")
  file[has_root] <- substr(file[has_root], n_root + 1, nchar(file[has_root]))
  return(file)
}

#' @importFrom assertthat assert_that
append_df <- function(x, file, root) {
  assert_that(inherits(x, "data.frame"))
  if (!is_git2rdata(file = file, root = root, message = "none")) {
    return(x)
  }
  read_vc(file = file, root = root) |>
    rbind(x)
}
