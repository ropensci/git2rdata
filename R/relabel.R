#' Relabel Factor Levels by Updating the Metadata
#'
#' Imagine the situation where we have a dataframe with a factor variable and we
#' have stored it with `write_vc(optimize = TRUE)`. The raw data file contains
#' the factor indices and the metadata contains the link between the factor
#' index and the corresponding label. See
#' `vignette("version_control", package = "git2rdata")`. In such a case,
#' relabelling a factor can be fast and lightweight by updating the metadata.
#' @inheritParams write_vc
#' @param change either a `list` or a `data.frame`. In case of a `list` is a
#' named `list` with named `vectors`. The names of list elements must match the
#' names of the variables. The names of the vector elements must match the
#' existing factor labels. The values represent the new factor labels. In case
#' of a `data.frame` it needs to have the variables `factor` (name of the
#' factor), `old` (the old) factor label and `new` (the new factor label).
#' `relabel()` ignores all other columns.
#' @return invisible `NULL`.
#' @export
#' @examples
#'
#' # initialise a git repo using git2r
#' repo_path <- tempfile("git2rdata-repo-")
#' dir.create(repo_path)
#' repo <- git2r::init(repo_path)
#' git2r::config(repo, user.name = "Alice", user.email = "alice@example.org")
#'
#' # Create a dataframe and store it as an optimized git2rdata object.
#' # Note that write_vc() uses optimization by default.
#' # Stage and commit the git2rdata object.
#' ds <- data.frame(
#'   a = c("a1", "a2"),
#'   b = c("b2", "b1"),
#'   stringsAsFactors = TRUE
#' )
#' junk <- write_vc(ds, "relabel", repo, sorting = "b", stage = TRUE)
#' cm <- commit(repo, "initial commit")
#' # check that the workspace is clean
#' status(repo)
#'
#' # Define new labels as a list and apply them to the git2rdata object.
#' new_labels <- list(
#'   a = list(a2 = "a3")
#' )
#' relabel("relabel", repo, new_labels)
#' # check the changes
#' read_vc("relabel", repo)
#' # relabel() changed the metadata, not the raw data
#' status(repo)
#' git2r::add(repo, "relabel.*")
#' cm <- commit(repo, "relabel using a list")
#'
#' # Define new labels as a dataframe and apply them to the git2rdata object
#' change <- data.frame(
#'   factor = c("a", "a", "b"),
#'   old = c("a3", "a1", "b2"),
#'   new = c("c2", "c1", "b3"),
#'   stringsAsFactors = TRUE
#' )
#' relabel("relabel", repo, change)
#' # check the changes
#' read_vc("relabel", repo)
#' # relabel() changed the metadata, not the raw data
#' status(repo)
#' @family storage
relabel <- function(file, root = ".", change) {
  UseMethod("relabel", change)
}

#' @export
relabel.default <- function(file, root, change) {
  stop("a 'change' of class ", class(change), " is not supported",
       call. = FALSE)
}

#' @export
#' @importFrom git2r workdir hash
#' @importFrom assertthat assert_that is.string has_name
#' @importFrom yaml read_yaml write_yaml
#' @importFrom utils packageVersion
relabel.list <- function(file, root = ".", change) {
  if (inherits(root, "git_repository")) {
    return(relabel(file = file, root = workdir(root), change = change))
  }
  assert_that(is.string(root), is.string(file))
  assert_that(!is.null(names(change)), msg = "'change' has no names")
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  is_git2rdata(file = file, root = root, message = "error")
  file <- clean_data_path(root = root, file = file)
  meta_data <- read_yaml(file["meta_file"])
  optimize <- meta_data[["..generic"]][["optimize"]]
  stopifnot("relabelling factors on verbose data leads to large diffs.
Use write_vc() instead." = optimize)
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

    if (any(names(change[[id]]) == "")) {
      empty_change <- which(names(change[[id]]) == "")
      empty_meta <- which(names(meta_data[[id]][["labels"]]) == "")
      meta_data[[id]][["labels"]][empty_meta] <- change[[id]][empty_change]
      change[[id]] <- change[[id]][-empty_change]
    }
    meta_data[[id]][["labels"]][names(change[[id]])] <- change[[id]]
    meta_data[[id]][["labels"]] <- unname(meta_data[[id]][["labels"]])
    assert_that(
      anyDuplicated(meta_data[[id]][["labels"]]) == 0,
      msg = sprintf("relabelling '%s' leads to duplicated labels", id)
    )
  }
  meta_data[["..generic"]][["hash"]] <- metadata_hash(meta_data)
  meta_data[["..generic"]][["git2rdata"]] <-
    as.character(packageVersion("git2rdata"))
  write_yaml(meta_data, file["meta_file"])
  return(invisible(NULL))
}

#' @export
#' @importFrom assertthat assert_that has_name
#' @importFrom stats setNames
relabel.data.frame <- function(file, root, change) { #nolint
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
