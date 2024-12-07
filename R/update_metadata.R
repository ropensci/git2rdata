#' Update the description of a `git2rdata` object
#'
#' Allows to update the description of the fields, the table name, the title,
#' and the description of a `git2rdata` object.
#' All arguments are optional.
#' Setting an argument to `NA` or an empty string will remove the corresponding
#' field from the metadata.
#'
#' @inheritParams is_git2rmeta
#' @param field_description a named character vector with the new descriptions
#' for the fields.
#' The names of the vector must match the variable names.
#' @param name a character string with the new table name of the object.
#' @param title a character string with the new title of the object.
#' @param description a character string with the new description of the object.
#' @param ... parameters used in some methods
#' @family storage
#' @export
#' @importFrom assertthat assert_that has_name
update_metadata <- function(
  file, root = ".", field_description, name, title, description, ...
) {
  UseMethod("update_metadata", root)
}

#' @export
update_metadata.default <- function(
  file, root = ".", field_description, name, title, description, ...
) {
  stop("a 'root' of class ", class(root), " is not supported", call. = FALSE)
}

#' @export
#' @importFrom assertthat assert_that is.string noNA
#' @importFrom git2r add
#' @inheritParams git2r::add
update_metadata.git_repository <- function(
  file, root = ".", field_description, name, title, description, ...,
  stage = FALSE, force = FALSE
) {
  assert_that(is.flag(stage), is.flag(force), noNA(stage), noNA(force))
  file <- update_metadata(
    file = file, root = workdir(root), name = name, title = title,
    description = description, field_description = field_description
  )
  if (!stage) {
    return(invisible(file))
  }
  add(root, path = file, force = force)
  return(invisible(file))
}

#' @export
update_metadata.character <- function(
  file, root = ".", field_description, name, title, description, ...
) {
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  file <- clean_data_path(root = root, file = file)
  is_git2rmeta(
    file = remove_root(file = file["meta_file"], root = root), root = root,
    message = "error"
  )
  old <- read_yaml(file["meta_file"])
  class(old) <- "meta_list"
  if (!missing(field_description)) {
    assert_that(
      is.character(field_description), length(field_description) > 0,
      !has_name(field_description, "..generic")
    )
    stopifnot(
      "names in `field_description` don't match variable names" =
        all(names(field_description) %in% names(old))
    )
    for (field_name in names(field_description)) {
      old[[field_name]][["description"]] <- update_or_drop(
        field_description[[field_name]]
      )
    }
  }

  if (!missing(name)) {
    old[["..generic"]][["name"]] <- update_or_drop(name)
  }

  if (!missing(title)) {
    old[["..generic"]][["title"]] <- update_or_drop(title)
  }

  if (!missing(description)) {
    old[["..generic"]][["description"]] <- update_or_drop(description)
  }

  packageVersion("git2rdata") |>
    as.character() -> old[["..generic"]][["git2rdata"]]
  metadata_hash(old) -> old[["..generic"]][["hash"]]
  write_yaml(old, file["meta_file"])
  return(invisible(file["meta_file"]))
}

#' @importFrom assertthat assert_that is.string
update_or_drop <- function(x) {
  assert_that(is.string(x))
  if (is.na(x) || x == "") {
    return(NULL)
  } else {
    return(x)
  }
}
