#' @examples
#' # create a directory
#' root <- tempfile("git2rdata-")
#' dir.create(root)
#'
#' # store a file
#' write_vc(iris[1:6, ], "iris", root, sorting = "Sepal.Length", digits = 6)
#' # check the stored file
#' is_git2rmeta("iris", root)
#' is_git2rdata("iris", root)
#'
#' # Remove the metadata from the existing git2rdata object. Then it stops
#' # being a git2rdata object.
#' junk <- file.remove(file.path(root, "iris.yml"))
#' is_git2rmeta("iris", root)
#' is_git2rdata("iris", root)
#'
#' # recreate the file and remove the data and keep the metadata. It stops being
#' # a git2rdata object, but the metadata remains valid.
#' write_vc(iris[1:6, ], "iris", root, sorting = "Sepal.Length", digits = 6)
#' junk <- file.remove(file.path(root, "iris.tsv"))
#' is_git2rmeta("iris", root)
#' is_git2rdata("iris", root)
