#' @examples
#' # on file system
#' root <- tempfile("git2rdata-")
#' dir.create(root)
#' write_vc(iris[1:6, ], file = "iris", root = root, sorting = "Sepal.Length")
#' list.files(root, recursive = TRUE)
#' read_vc("iris", root)
#' write_vc(iris[1:5, ], "iris", root)
#' list.files(root, recursive = TRUE)
#' write_vc(
#'   iris[1:6, -2], "iris", root, sorting = "Sepal.Length", override = TRUE
#' )
#' list.files(root, recursive = TRUE)
#' write_vc(iris[1:6, ], "iris", root, sorting = "Sepal.Width", override = TRUE)
#' list.files(root, recursive = TRUE)
#' write_vc(
#'   iris[1:6, ], "iris2", root, sorting = "Sepal.Width", optimize = FALSE
#' )
#' list.files(root, recursive = TRUE)
#'
#' # on git repo
#' repo_path <- tempfile("git2rdata-repo-")
#' dir.create(repo_path)
#' repo <- git2r::init(repo_path)
#' git2r::config(repo, user.name = "Alice", user.email = "alice@example.org")
#' write_vc(iris[1:6, ], file = "iris", root = repo, sorting = "Sepal.Length")
#' status(repo)
#' read_vc("iris", repo)
#' write_vc(iris[1:5, ], "iris", repo, stage = TRUE)
#' status(repo)
#' write_vc(
#'   iris[1:6, -2], "iris", repo, sorting = "Sepal.Length", override = TRUE
#' )
#' status(repo)
#' write_vc(
#'   iris[1:6, ], "iris", repo, sorting = "Sepal.Width", override = TRUE,
#'   stage = TRUE
#' )
#' status(repo)
#' write_vc(
#'   iris[1:6, ], "iris2", repo, sorting = "Sepal.Width", optimize = FALSE
#' )
#' status(repo)
