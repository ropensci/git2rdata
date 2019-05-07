#' @examples
#' ## on file system
#'
#' # create a directory
#' root <- tempfile("git2rdata-")
#' dir.create(root)
#'
#' # store a dataframe
#' write_vc(iris[1:6, ], "iris", root, sorting = "Sepal.Length")
#' # list the available data and the files
#' list_data(root)
#' list.files(root, recursive = TRUE)
#'
#' # remove all .tsv files with an associated .yml file
#' rm_data(root, path = ".")
#' # check the removal of the data
#' list.files(root, recursive = TRUE)
#' list_data(root)
#'
#' # remove dangling meta data files
#' prune_meta(root, path = ".")
#' # check the removal of the meta data
#' list.files(root, recursive = TRUE)
#' list_data(root)
#'
#'
#' ## on git repo
#'
#' # initialise a git repo using git2r
#' repo_path <- tempfile("git2rdata-repo-")
#' dir.create(repo_path)
#' repo <- git2r::init(repo_path)
#' git2r::config(repo, user.name = "Alice", user.email = "alice@example.org")
#'
#' # store a dataframe
#' write_vc(iris[1:6, ], "iris", repo, sorting = "Sepal.Length", stage = TRUE)
#' # check that the dataframe is stored
#' status(repo)
#' list_data(repo)
#'
#' # commit the current version and check the git repo
#' commit(repo, "add iris data", session = TRUE)
#' status(repo)
#'
#' # remove the data files from the repo
#' rm_data(repo, path = ".")
#' # check the removal
#' list_data(repo)
#' status(repo)
#'
#' # remove dangling meta data
#' prune_meta(repo, path = ".")
#' # check the removal
#' list_data(repo)
#' status(repo)
#'
#' # clean up
#' junk <- file.remove(
#'   list.files(root, full.names = TRUE, recursive = TRUE), root)
#' junk <- file.remove(
#'   rev(list.files(repo_path, full.names = TRUE, recursive = TRUE,
#'                  include.dirs = TRUE, all.files = TRUE)),
#'   repo_path)

