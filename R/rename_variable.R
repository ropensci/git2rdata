#' Rename a Variable
#'
#' The raw data file contains a header with the variable names.
#' The metadata list the variable names and their type.
#' Changing a variable name and overwriting the `git2rdata` object with result
#' in an error.
#' Because it will look like removing an existing variable and adding a new one.
#' Overwriting the object with `strict = FALSE` potentially changes the order of
#' the variables, leading to a large diff.
#'
#' This function solves this by only updating the raw data header and the
#' metadata.
#' @inheritParams write_vc
#' @param change A named vector with the old names as values and the new names
#' as names.
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
#' junk <- write_vc(ds, "rename", repo, sorting = "b", stage = TRUE)
#' cm <- commit(repo, "initial commit")
#' # check that the workspace is clean
#' status(repo)
#'
#' # Define change.
#' change <- c(new_name = "a")
#' rename_variable(file = "rename", change = change, root = repo)
#' # check the changes
#' read_vc("rename", repo)
#' status(repo)
#' @family storage
rename_variable <- function(file, change, root = ".", ...) {
  UseMethod("rename_variable", root)
}

#' @rdname rename_variable
#' @export
#' @importFrom assertthat assert_that noNA
#' @importFrom yaml read_yaml write_yaml
#' @importFrom utils file_test
rename_variable.character <- function(file, change, root = ".", ...) {
  assert_that(is.character(change), noNA(change), length(change) > 0)
  assert_that(length(names(change)) > 0, msg = "`change` must have names.")
  assert_that(
    length(unique(change)) == length(change),
    length(unique(names(change))) == length(names(change)),
    msg = "The names and values in `change` are not unique."
  )
  is_git2rdata(file = file, root = root, message = "error")
  file <- clean_data_path(root = root, file = file)
  yaml <- read_yaml(file[["meta_file"]])
  file["raw_file"] <- ifelse(
    yaml[["..generic"]][["optimize"]],
    file["raw_file"],
    gsub("\\.tsv$", ".csv", file["raw_file"])
  )
  assert_that(
    all(change %in% names(yaml)),
    msg = "Not every old name in `change` present in the `git2rdata` object."
  )
  assert_that(
    !any(names(change) %in% names(yaml)),
    msg = "New name in `change` present in the existing `git2rdata` object."
  )
  names(yaml) <- replace_vector(names(yaml), change)
  yaml[["..generic"]][["sorting"]] <- replace_vector(
    yaml[["..generic"]][["sorting"]], change
  )
  if (file_test("-f", file["raw_file"])) {
    replace_header(file["raw_file"], change)
  } else {
    vapply(
      c(
        file.path(file["raw_file"], "index.tsv"),
        list.files(
          file["raw_file"], pattern = "[[:xdigit:]]{20}.tsv", full.names = TRUE
        )
      ),
      replace_header, change = change, logical(1)
    )
    yaml[["..generic"]][["split_by"]] <- replace_vector(
      yaml[["..generic"]][["split_by"]], change
    )
  }
  yaml[["..generic"]][["hash"]] <- metadata_hash(yaml)
  yaml[["..generic"]][["data_hash"]] <- datahash(file["raw_file"])
  write_yaml(yaml, file["meta_file"], fileEncoding = "UTF-8")

  hashes <- remove_root(file = file, root = root)
  names(hashes) <-
    c(
      yaml[["..generic"]][["data_hash"]],
      yaml[["..generic"]][["hash"]]
    )

  return(hashes)
}

replace_vector <- function(x, change) {
  if (!any(change %in% x)) {
    return(x)
  }
  for (i in seq_along(change)) {
    x[x == change[i]] <- names(change[i])
  }
  return(x)
}

replace_header <- function(x, change) {
  raw_data <- readLines(x)
  header <- strsplit(raw_data[1], "\t")[[1]]
  for (i in seq_along(change)) {
    header[header == change[i]] <- names(change)[i]
  }
  raw_data[1] <- paste0(header, collapse = "\t")
  writeLines(text = raw_data, con = x)
  return(TRUE)
}

#' @rdname rename_variable
#' @export
rename_variable.default <- function(file, change, root, ...) {
  stop("a 'root' of class ", class(root), " is not supported",
       call. = FALSE)
}

#' @rdname rename_variable
#' @export
#' @inheritParams write_vc
#' @inheritParams git2r::add
#' @importFrom assertthat assert_that is.flag noNA
#' @importFrom git2r add workdir
rename_variable.git_repository <- function(
  file, change, root, ..., stage = FALSE, force = FALSE
) {
  assert_that(is.flag(stage), noNA(stage), is.flag(force), noNA(force))
  hashes <- rename_variable(file = file, root = workdir(root), change = change)
  if (!stage) {
    return(hashes)
  }

  add(root, path = hashes, force = force)
  return(hashes)
}
