#' Create a Data Package for a directory of CSV files
#'
#' @description
#' Create a `datapackage.json` file for a directory of CSV files.
#' The function will look for all `.csv` files in the directory and its
#' subdirectories.
#' It will then create a `datapackage.json` file with the metadata of each CSV
#' file.
#'
#' @param path the directory in which to create the `datapackage.json` file.
#' @family storage
#' @export
#' @importFrom assertthat assert_that is.string noNA
data_package <- function(path = ".") {
  assert_that(
    is.string(path), noNA(path), requireNamespace("jsonlite", quietly = TRUE)
  )
  stopifnot("`path` is not a directory" = file_test("-d", path))

  data_files <- list.files(path, pattern = ".csv$", recursive = TRUE)
  relevant <- vapply(
    data_files, FUN = is_git2rdata, FUN.VALUE = logical(1), root = path
  )
  stopifnot(
    "no non-optimized git2rdata objects found at `path`" = any(relevant)
  )
  data_files <- data_files[relevant]

  list(
    resources = vapply(
        data_files, path = path, FUN = data_resource,
        FUN.VALUE = vector(mode = "list", length = 1)
      ) |>
        unname()
  ) |>
    jsonlite::toJSON(pretty = TRUE, auto_unbox = TRUE) |>
    writeLines(file.path(path, "datapackage.json"))
  return(file.path(path, "datapackage.json"))
}

#' @importFrom assertthat assert_that is.string noNA
#' @importFrom yaml read_yaml
data_resource <- function(file, path = ".") {
  assert_that(
    is.string(file), is.string(path), noNA(file), noNA(path)
  )
  stopifnot("`path` is not a directory" = file_test("-d", path))

  clean_data_path(root = path, file = file)[2] |>
    read_yaml() -> metadata
  list(
    name = coalesce(metadata[["..generic"]][["name"]], file), path = file,
    "encoding" = "utf-8", format = "csv", media_type = "text/csv",
    hash = paste0("sha1:", metadata[["..generic"]][["data_hash"]]),
    schema = list(
      fields = vapply(
        names(metadata)[-1], metadata = metadata, FUN = field_schema,
        FUN.VALUE = vector(mode = "list", length = 1)
      ) |>
        unname(),
      missingValues = list(
        c(value = metadata[["..generic"]][["NA string"]], label = "missing")
      )
    )
  ) -> dr
  extra <- c("title", "description")
  metadata[["..generic"]][extra[extra %in% names(metadata[["..generic"]])]] |>
    c(dr) |>
    list()
}

field_schema <- function(x, metadata) {
  switch(
    metadata[[x]]$class,
    "character" = list(name = x, type = "string"),
    "Date" = list(name = x, type = "date"),
    "logical" = list(
      name = x, type = "boolean", trueValues = c("TRUE", "true"),
      falseValues = c("FALSE", "false")
    ),
    "factor" = list(
      name = x, type = "string", categories = metadata[[x]][["labels"]],
      categoriesOrdered = metadata[[x]][["ordered"]]
    ),
    "integer" = list(name = x, type = "integer"),
    "numeric" = list(name = x, type = "number"),
    "POSIXct" = list(
      name = x, type = "datetime", format = "%Y-%m-%dT%H:%M:%SZ"
    ),
    stop("field_schema() can't handle ", metadata[[x]]$class)
  ) -> fs
  if ("description" %in% names(metadata[[x]])) {
    fs$description <- metadata[[x]][["description"]]
  }
  return(list(fs))
}

coalesce <- function(...) {
  dots <- list(...)
  if (length(dots) == 0) {
    return(NULL)
  }
  if (!is.null(dots[[1]])) {
    return(dots[[1]])
  }
  do.call(coalesce, dots[-1])
}
