#' @examples
#' ## on file system
#'
#' # create a directory
#' root <- tempfile("git2rdata-")
#' dir.create(root)
#'
#' # store a dataframe as git2rdata object. Capture the result to minimise
#' # screen output
#' junk <- write_vc(
#'   iris[1:6, ], "iris", root, sorting = "Sepal.Length", digits = 6
#' )
#' # write a standard tab separate file (non git2rdata object)
#' write.table(iris, file = file.path(root, "standard.tsv"), sep = "\t")
#' # write a YAML file
#' yml <- list(
#'   authors = list(
#'    "Research Institute for Nature and Forest" = list(
#'        href = "https://www.inbo.be/en")))
#' yaml::write_yaml(yml, file = file.path(root, "_pkgdown.yml"))
#'
#' # list the git2rdata objects
#' list_data(root)
#' # list the files
#' list.files(root, recursive = TRUE)
#'
#' # remove all .tsv files from valid git2rdata objects
#' rm_data(root, path = ".")
#' # check the removal of the .tsv file
#' list.files(root, recursive = TRUE)
#' list_data(root)
#'
#' # remove dangling git2rdata metadata files
#' prune_meta(root, path = ".")
#' # check the removal of the metadata
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
#' write_vc(
#'   iris[1:6, ], "iris", repo, sorting = "Sepal.Length", stage = TRUE,
#'   digits = 6
#' )
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
#' # remove dangling metadata
#' prune_meta(repo, path = ".")
#' # check the removal
#' list_data(repo)
#' status(repo)
