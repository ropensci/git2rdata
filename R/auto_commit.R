#' Commit staged changes in a git repository with automated message
#'
#' The mesagge is based on the information returned by
#' \code{\link[utils]{sessionInfo}}
#' @param package The name of the package from which we auto commit
#' @param push Logical indicating whether to push the commit. Defaults to FALSE.
#' @param ... arguments passed to \code{\link[git2r]{commit}} and
#' \code{\link[git2r]{push}}
#' @inheritParams git2r::commit
#' @return The `git_repository` object that contains the commit
#' @name auto_commit
#' @rdname auto_commit
#' @exportMethod auto_commit
#' @docType methods
#' @importFrom methods setGeneric
setGeneric(
  name = "auto_commit",
  def = function(package, repo = ".", push = FALSE, ...){
    standard.generic("autocommit")
  }
)

#' @rdname auto_commit
#' @importFrom methods setMethod
setMethod(
  f = "auto_commit",
  signature = signature(repo = "ANY"),
  definition = function(package, repo = ".", push = FALSE, ...){
    auto_commit(package = package, repo = repository(repo), push = push, ...)
  }
)


#' @rdname auto_commit
#' @aliases auto_commit,git_repository-methods
#' @importFrom methods setMethod
#' @importFrom assertthat assert_that is.string
#' @importFrom git2r commit last_commit push
#' @importFrom utils sessionInfo
#' @include write_vc.R
setMethod(
  f = "auto_commit",
  signature = signature(repo = "git_repository"),
  definition = function(package, repo = ".", push = FALSE, ...){
    assert_that(is.string(package))
    assert_that(is.flag(push))

    #format commit message based on sessionInfo()
    info <- sessionInfo()
    format_other <- function(x){
      paste0(x$Package, " ", x$Version, " built ", x$Built, "\n")
    }
    message <- paste0(
      "Scripted commit from ", package, "\n\n",
      info$R.version$version.string, " revision ", info$R.version$"svn rev",
      " on ", info$R.version$platform, "\n",
      "\nBase packages: ",
        paste0(info$basePkgs, collapse = ", "), "\n", #nolint
      "\nOther package(s):\n",
        paste(sapply(info$otherPkgs, format_other), collapse = ""), #nolint
      "\nLoaded via a namespace:\n",
        paste(sapply(info$loadedOnly, format_other), collapse = "") #nolint
    )

    committed <- tryCatch(
      commit(repo = repo, message = message, ...),
      error = function(e){
        if (e$message == "Error in 'git2r_commit': Nothing added to commit\n") {
          last_commit(repo)
        } else {
          e
        }
      }
    )
    if ("error" %in% class(committed)) {
      stop(committed)
    }
    if (isTRUE(push)) {
      message("Pushing changes to remote repository")
      pushed <- tryCatch(
        push(object = repo, ...),
        error = function(e){
          e$message
        }
      )
      if (!is.null(pushed)) {
        warning(pushed)
      }
    }
    return(committed)
  }
)
