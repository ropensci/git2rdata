#' @examples
#' # on file system
#' root <- tempfile("git2rdata-")
#' dir.create(root)
#' write_vc(iris[1:6, ], "iris", root, sorting = "Sepal.Length")
#' list.files(root, recursive = TRUE)
#' rm_data(root, path = ".")
#' list.files(root, recursive = TRUE)
#' prune_meta(root, path = ".")
#' list.files(root, recursive = TRUE)
#'
#' # on git repo
#' repo_path <- tempfile("git2rdata-repo-")
#' dir.create(repo_path)
#' repo <- git2r::init(repo_path)
#' git2r::config(repo, user.name = "Alice", user.email = "alice@example.org")
#' write_vc(iris[1:6, ], "iris", repo, sorting = "Sepal.Length", stage = TRUE)
#' status(repo)
#' auto_commit(package = "my_package", repo)
#' status(repo)
#' rm_data(repo, path = ".")
#' status(repo)
#' prune_meta(repo, path = ".")
#' status(repo)
