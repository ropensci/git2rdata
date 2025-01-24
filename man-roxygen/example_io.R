#' @examples
#' ## on file system
#'
#' # create a directory
#' root <- tempfile("git2rdata-")
#' dir.create(root)
#'
#' # write a dataframe to the directory
#' write_vc(
#'   iris[1:6, ], file = "iris", root = root, sorting = "Sepal.Length",
#'   digits = 6
#' )
#' # check that a data file (.tsv) and a metadata file (.yml) exist.
#' list.files(root, recursive = TRUE)
#' # read the git2rdata object from the directory
#' read_vc("iris", root)
#'
#' # store a new version with different observations but the same metadata
#' write_vc(iris[1:5, ], "iris", root)
#' list.files(root, recursive = TRUE)
#' # Removing a column requires version requires new metadata.
#' # Add strict = FALSE to override the existing metadata.
#' write_vc(
#'   iris[1:6, -2], "iris", root, sorting = "Sepal.Length", strict = FALSE
#' )
#' list.files(root, recursive = TRUE)
#' # storing the orignal version again requires another update of the metadata
#' write_vc(iris[1:6, ], "iris", root, sorting = "Sepal.Width", strict = FALSE)
#' list.files(root, recursive = TRUE)
#' # optimize = FALSE stores the data more verbose. This requires larger files.
#' write_vc(
#'   iris[1:6, ], "iris2", root, sorting = "Sepal.Width", optimize = FALSE
#' )
#' list.files(root, recursive = TRUE)
#'
#'
#'
#' ## on git repo using a git2r::git-repository
#'
#' # initialise a git repo using the git2r package
#' repo_path <- tempfile("git2rdata-repo-")
#' dir.create(repo_path)
#' repo <- git2r::init(repo_path)
#' git2r::config(repo, user.name = "Alice", user.email = "alice@example.org")
#'
#' # store a dataframe in git repo.
#' write_vc(iris[1:6, ], file = "iris", root = repo, sorting = "Sepal.Length")
#' # This git2rdata object is not staged by default.
#' status(repo)
#' # read a dataframe from a git repo
#' read_vc("iris", repo)
#'
#' # store a new version in the git repo and stage it in one go
#' write_vc(iris[1:5, ], "iris", repo, stage = TRUE)
#' status(repo)
#'
#' # store a verbose version in a different gir2data object
#' write_vc(
#'   iris[1:6, ], "iris2", repo, sorting = "Sepal.Width", optimize = FALSE
#' )
#' status(repo)
