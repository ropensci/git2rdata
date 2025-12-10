reinstate_factor <- function(x, optimize, details) {
  if (optimize) {
    return(factor(
      x,
      levels = details[["index"]],
      labels = details[["labels"]],
      ordered = details[["ordered"]]
    ))
  }
  return(factor(
    x,
    levels = details[["labels"]],
    labels = details[["labels"]],
    ordered = details[["ordered"]]
  ))
}

reinstate_positxct <- function(x, optimize, details) {
  if (optimize) {
    z <- as.POSIXct(
      x,
      origin = details[["origin"]],
      tz = details[["timezone"]]
    )
    attr(z, "origin") <- details[["origin"]]
    return(z)
  }
  z <- as.POSIXct(
    x,
    format = details[["format"]],
    tz = details[["timezone"]]
  )
  attr(z, "format") <- details[["format"]]
  return(z)
}

reinstate_numeric <- function(x, details, ...) {
  attr(x, "digits") <- details[["digits"]]
  return(x)
}

reinstate_date <- function(x, optimize, details) {
  if (optimize) {
    z <- as.Date(x, origin = details[["origin"]])
    attr(z, "origin") <- details[["origin"]]
    return(z)
  }
  attr(x, "origin") <- details[["origin"]]
  return(x)
}

reinstage_logical <- function(x, ...) {
  return(as.logical(x))
}

reinstate <- function(raw_data, optimize, col_names, col_classes, details) {
  for (i in seq_along(col_names)) {
    id <- col_names[i]
    raw_data[[id]] <- switch(
      col_classes[i],
      factor = reinstate_factor(
        x = raw_data[[id]],
        optimize = optimize,
        details = details[[id]]
      ),
      POSIXct = reinstate_positxct(
        x = raw_data[[id]],
        optimize = optimize,
        details = details[[id]]
      ),
      numeric = reinstate_numeric(
        x = raw_data[[id]],
        optimize = optimize,
        details = details[[id]]
      ),
      Date = reinstate_date(
        x = raw_data[[id]],
        optimize = optimize,
        details = details[[id]]
      ),
      logical = reinstage_logical(
        x = raw_data[[id]],
        optimize = optimize,
        details = details[[id]]
      ),
      raw_data[[id]]
    )
  }
  return(raw_data)
}
