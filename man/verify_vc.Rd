% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/verify_vc.R
\name{verify_vc}
\alias{verify_vc}
\title{Read a file an verify the presence of variables}
\usage{
verify_vc(file, root, variables)
}
\arguments{
\item{file}{the name of the git2rdata object. Git2rdata objects cannot
have dots in their name. The name may include a relative path. \code{file} is a
path relative to the \code{root}.
Note that \code{file} must point to a location within \code{root}.}

\item{root}{The root of a project. Can be a file path or a \code{git-repository}.
Defaults to the current working directory (\code{"."}).}

\item{variables}{a character vector with variable names.}
}
\description{
Reads the file with \code{\link[=read_vc]{read_vc()}}.
Then verifies that every variable listed in \code{variables} is present in the
data.frame.
}
\seealso{
Other storage: 
\code{\link{display_metadata}()},
\code{\link{list_data}()},
\code{\link{prune_meta}()},
\code{\link{read_vc}()},
\code{\link{relabel}()},
\code{\link{rename_variable}()},
\code{\link{rm_data}()},
\code{\link{update_metadata}()},
\code{\link{write_vc}()}
}
\concept{storage}
