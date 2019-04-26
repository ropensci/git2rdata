#' @examples
#' ## on file system
#'
#' # create a directory
#' root <- tempfile("git2rdata-")
#' dir.create(root)
#'
#' # write a dataframe to the directory
#' write_vc(iris[1:6, ], file = "iris", root = root, sorting = "Sepal.Length")
#' # check that a data file (.tsv) and a meta data file (.yml) are created
#' list.files(root, recursive = TRUE)
#' # read the data from the directory
#' read_vc("iris", root)
#'
#' # store a new version
#' write_vc(iris[1:5, ], "iris", root)
#' list.files(root, recursive = TRUE)
#' # store a new version in case the meta data must change
#' write_vc(
#'   iris[1:6, -2], "iris", root, sorting = "Sepal.Length", strict = FALSE
#' )
#' list.files(root, recursive = TRUE)
#' # storing the first version again required another update of the meta data
#' write_vc(iris[1:6, ], "iris", root, sorting = "Sepal.Width", strict = FALSE)
#' list.files(root, recursive = TRUE)
#' # storing the data in verbose format leads to larger files
#' write_vc(
#'   iris[1:6, ], "iris2", root, sorting = "Sepal.Width", optimize = FALSE
#' )
#' list.files(root, recursive = TRUE)
#'
#'
#'
#' ## on git repo
#'
#' # initialise a git repo using the git2r package
#' repo_path <- tempfile("git2rdata-repo-")
#' dir.create(repo_path)
#' repo <- git2r::init(repo_path)
#' git2r::config(repo, user.name = "Alice", user.email = "alice@example.org")
#'
#' # store a dataframe in git repo
#' write_vc(iris[1:6, ], file = "iris", root = repo, sorting = "Sepal.Length")
#' status(repo)
#' # read a dataframe from a git repo
#' read_vc("iris", repo)
#'
#' # store a new version in the git repo
#' write_vc(iris[1:5, ], "iris", repo, stage = TRUE)
#' status(repo)
#'
#' # store a version with altered meta data
#' write_vc(
#'   iris[1:6, -2], "iris", repo, sorting = "Sepal.Length", strict = FALSE
#' )
#' status(repo)
#'
#' # store the original version again
#' write_vc(
#'   iris[1:6, ], "iris", repo, sorting = "Sepal.Width", strict = FALSE,
#'   stage = TRUE
#' )
#' status(repo)
#'
#' # store a verbose version in separate files
#' write_vc(
#'   iris[1:6, ], "iris2", repo, sorting = "Sepal.Width", optimize = FALSE
#' )
#' status(repo)
