#' Relabel factor levels
#'
#' Imagine the situation where we have a dataframe with a factor variable and we
#' have stored it with `write_vc(optimize = TRUE)`. The raw data file contains
#' the factor indices and the metadata contains the link between the factor
#' index and the corresponding label.
#' @inheritParams write_vc
#' @param change either list or a data.frame. In case of a list is a named list
#' with named vectors. The name of list elements must match the names of the
#' variables. The names of the vector elements must match the existing factor
#' labels. The values represent the new factor labels. In case of a data.frame
#' it needs to have the variables `factor` (name of the factor), `old` (the old)
#' factor label and `new` (the new factor label). Other columns are ignored.
#' @return invisible `NULL`
#' @export
#' @examples
#'
#' # setup a directory
#' root <- tempfile("git2rdata-relabel")
#' dir.create(root)
#'
#' # create a dataframe and store it
#' ds <- ds <- data.frame(a = c("a1", "a2"), b = c("b2", "b1"))
#' write_vc(ds, "relabel", root, sorting = "b")
#'
#' # define new labels as a list and apply them
#' new_labels <- list(
#'   a = list(a2 = "a3")
#' )
#' relabel("relabel", root, new_labels)
#'
#' # define new labels as a dataframe and apply them
#' change <- data.frame(
#'   factor = c("a", "a", "b"),
#'   old = c("a3", "a1", "b2"),
#'   new = c("c2", "c1", "b3")
#' )
#' relabel("relabel", root, change)
#' @family storage
relabel <- function(file, root = ".", change) {
  UseMethod("relabel", change)
}

#' @export
relabel.default <- function(file, root, change) {
  stop("a 'change' of class ", class(change), " is not supported")
}

#' @export
#' @importFrom git2r workdir hash
#' @importFrom assertthat assert_that is.string has_name
#' @importFrom yaml read_yaml write_yaml
relabel.list <- function(file, root = ".", change) {
  if (inherits(root, "git_repository")) {
    return(relabel(file = file, root = workdir(root), change = change))
  }
  assert_that(is.string(root), is.string(file))
  assert_that(!is.null(names(change)), msg = "'change' must be named")
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  file <- clean_data_path(root = root, file = file)
  assert_that(
    all(file.exists(file)),
    msg = "raw file and/or meta file missing"
  )
  meta_data <- read_yaml(file["meta_file"])
  assert_that(has_name(meta_data, "..generic"))
  optimize <- meta_data[["..generic"]][["optimize"]]
  if (!optimize) {
    stop("relabeling factors on verbose data leads to large diffs.
Use write_vc() instead.")
  }
  assert_that(
    all(names(change) %in% names(meta_data)),
    msg = "every name in 'change' must match an exisiting variable"
  )
  for (id in names(change)) {
    assert_that(
      all(names(change[[id]]) %in% meta_data[[id]][["labels"]]),
      msg = sprintf("the names in '%s' don't match existing labels", id)
    )
    names(meta_data[[id]][["labels"]]) <- meta_data[[id]][["labels"]]
    meta_data[[id]][["labels"]][names(change[[id]])] <- change[[id]]
    meta_data[[id]][["labels"]] <- unname(meta_data[[id]][["labels"]])
    assert_that(
      anyDuplicated(meta_data[[id]][["labels"]]) == 0,
      msg = sprintf("relabeling '%s' leads to duplicated labels", id)
    )
  }
  meta_data[["..generic"]][["hash"]] <- NULL
  meta_data[["..generic"]] <- c(meta_data[["..generic"]],
                                hash = hash(as.yaml(meta_data)))
  write_yaml(meta_data, file["meta_file"])
  return(invisible(NULL))
}

#' @export
#' @importFrom assertthat assert_that has_name
#' @importFrom stats setNames
relabel.data.frame <- function(file, root, change) {
  assert_that(
    has_name(change, "factor"),
    has_name(change, "old"),
    has_name(change, "new")
  )
  if (is.factor(change$factor)) {
    change$factor <- as.character(change$factor)
  } else {
    assert_that(inherits(change$factor, "character"))
  }
  if (is.factor(change$old)) {
    change$old <- as.character(change$old)
  } else {
    assert_that(inherits(change$old, "character"))
  }
  if (is.factor(change$new)) {
    change$new <- as.character(change$new)
  } else {
    assert_that(inherits(change$new, "character"))
  }
  change_list <- lapply(
    unique(change$factor),
    function(id) {
      setNames(
        change[change$factor == id, "new"],
        change[change$factor == id, "old"]
      )
    }
  )
  names(change_list) <- unique(change$factor)
  relabel(file = file, root = root, change = change_list)
}
