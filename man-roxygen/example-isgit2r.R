#' @examples
#' # create a directory
#' root <- tempfile("git2rdata-")
#' dir.create(root)
#'
#' # everthing file
#' write_vc(iris[1:6, ], "iris", root, sorting = "Sepal.Length")
#' is_git2rmeta("iris", root)
#' is_git2rdata("iris", root)
#'
#' # missing metadata
#' junk <- file.remove(file.path(root, "iris.yml"))
#' is_git2rmeta("iris", root)
#' is_git2rdata("iris", root)
#'
#' # missing data
#' write_vc(iris[1:6, ], "iris", root, sorting = "Sepal.Length")
#' junk <- file.remove(file.path(root, "iris.tsv"))
#' is_git2rmeta("iris", root)
#' is_git2rdata("iris", root)
#'
#' # clean up
#' junk <- file.remove(list.files(root, full.names = TRUE), root)
