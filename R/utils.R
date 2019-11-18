# function used by devtools::release()
# gramr is avaible from https://github.com/ropenscilabs/gramr
release_questions <- function() { # nocov start
  c(
    'Did you ran `gramr::check_project(exclude_chunks = TRUE)`'
  )
} # nocov end
