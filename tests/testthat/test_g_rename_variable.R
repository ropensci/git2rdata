test_that("rename_variable() handles single files", {
  root <- tempfile(pattern = "git2rdata-rename")
  dir.create(root)
  repo <- git2r::init(root)
  git2r::config(repo, user.name = "Alice", user.email = "alice@example.org")
  files <- suppressWarnings(
    write_vc(test_data, file = "unsorted", root = repo, stage = TRUE)
  )
  cm <- commit(repo, "initial commit")

  # unsorted unstaged
  change <- c("new_var" = "test_Date")
  expect_silent({
    rf <- rename_variable(file = files[1], change = change, root = repo)
  })
  expect_identical(unname(files), unname(rf))
  expect_true(length(git2r::status(repo)[["unstaged"]]) > 0)
  expect_length(git2r::status(repo)[["staged"]], 0)
  expect_length(git2r::status(repo)[["untracked"]], 0)
  expect_silent({
    changed_df <- read_vc(rf[1], root = repo)
  })
  expect_identical(ncol(test_data), ncol(changed_df))
  updated <- which(colnames(test_data) != colnames(changed_df))
  expect_identical(length(updated), length(change))
  expect_identical(colnames(test_data)[updated], unname(change))
  expect_identical(colnames(changed_df)[updated], names(change))
  expect_identical(test_data[, change], changed_df[, names(change)])
  git2r::reset(cm, "hard")

  files <- write_vc(
    test_data, file = "sorted", root = repo, sorting = "test_Date",
    stage = TRUE, digits = 6
  )
  cm <- commit(repo, "sorted")
  # staged & sorted on changed variable
  change <- c("new_var" = "test_Date")
  expect_silent({
    rf <- rename_variable(
      file = files[1], change = change, root = repo, stage = TRUE
    )
  })
  expect_identical(unname(files), unname(rf))
  expect_true(length(git2r::status(repo)[["staged"]]) > 0)
  expect_length(git2r::status(repo)[["unstaged"]], 0)
  expect_length(git2r::status(repo)[["untracked"]], 0)
  expect_silent({
    changed_df <- read_vc(rf[1], root = repo)
  })
  expect_identical(ncol(test_data), ncol(changed_df))
  updated <- which(colnames(test_data) != colnames(changed_df))
  expect_identical(length(updated), length(change))
  expect_identical(colnames(test_data)[updated], unname(change))
  expect_identical(colnames(changed_df)[updated], names(change))
  expect_equivalent(sorted_test_data[, change], changed_df[, names(change)])
  git2r::reset(cm, "hard")

  # staged & sorted on other variable
  change <- c("new_var" = "test_numeric")
  expect_silent({
    rf <- rename_variable(
      file = files[1], change = change, root = repo, stage = TRUE
    )
  })
  expect_identical(unname(files), unname(rf))
  expect_true(length(git2r::status(repo)[["staged"]]) > 0)
  expect_length(git2r::status(repo)[["unstaged"]], 0)
  expect_length(git2r::status(repo)[["untracked"]], 0)
  expect_silent({
    changed_df <- read_vc(rf[1], root = repo)
  })
  expect_identical(ncol(test_data), ncol(changed_df))
  updated <- which(colnames(test_data) != colnames(changed_df))
  expect_identical(length(updated), length(change))
  expect_identical(colnames(test_data)[updated], unname(change))
  expect_identical(colnames(changed_df)[updated], names(change))
  expect_equivalent(sorted_test_data_6[, change], changed_df[, names(change)])
  git2r::reset(cm, "hard")
})

test_that("rename_variable() handles split_by files", {
  root <- tempfile(pattern = "git2rdata-rename")
  dir.create(root)
  repo <- git2r::init(root)
  git2r::config(repo, user.name = "Alice", user.email = "alice@example.org")
  files <- suppressWarnings(
    write_vc(
      test_data, file = "unsorted", split_by = "test_factor", root = repo,
      stage = TRUE
    )
  )
  cm <- commit(repo, "initial commit")

  # unsorted unstaged
  change <- c("new_var" = "test_Date")
  expect_silent({
    rf <- rename_variable(file = files[1], change = change, root = repo)
  })
  expect_identical(unname(files), unname(rf))
  expect_true(length(git2r::status(repo)[["unstaged"]]) > 0)
  expect_length(git2r::status(repo)[["staged"]], 0)
  expect_length(git2r::status(repo)[["untracked"]], 0)
  expect_silent({
    changed_df <- read_vc(rf[1], root = repo)
  })
  expect_identical(ncol(test_data), ncol(changed_df))
  updated <- which(colnames(test_data) != colnames(changed_df))
  expect_identical(length(updated), length(change))
  expect_identical(colnames(test_data)[updated], unname(change))
  expect_identical(colnames(changed_df)[updated], names(change))
  git2r::reset(cm, "hard")

  files <- write_vc(
    test_data, file = "sorted", root = repo, sorting = "test_Date",
    split_by = "test_factor", stage = TRUE, digits = 6
  )
  cm <- commit(repo, "sorted")
  # staged & sorted on changed variable
  change <- c("new_var" = "test_Date")
  expect_silent({
    rf <- rename_variable(
      file = files[1], change = change, root = repo, stage = TRUE
    )
  })
  expect_identical(unname(files), unname(rf))
  expect_true(length(git2r::status(repo)[["staged"]]) > 0)
  expect_length(git2r::status(repo)[["unstaged"]], 0)
  expect_length(git2r::status(repo)[["untracked"]], 0)
  expect_silent({
    changed_df <- read_vc(rf[1], root = repo)
  })
  expect_identical(ncol(test_data), ncol(changed_df))
  updated <- which(colnames(test_data) != colnames(changed_df))
  expect_identical(length(updated), length(change))
  expect_identical(colnames(test_data)[updated], unname(change))
  expect_identical(colnames(changed_df)[updated], names(change))
  expect_equivalent(
    test_data[order(test_data$test_factor, test_data$test_Date), change],
    changed_df[, names(change)]
  )
  git2r::reset(cm, "hard")

  # staged & split_by variable
  change <- c("new_var" = "test_factor")
  expect_silent({
    rf <- rename_variable(
      file = files[1], change = change, root = repo, stage = TRUE
    )
  })
  expect_identical(unname(files), unname(rf))
  expect_true(length(git2r::status(repo)[["staged"]]) > 0)
  expect_length(git2r::status(repo)[["unstaged"]], 0)
  expect_length(git2r::status(repo)[["untracked"]], 0)
  expect_silent({
    changed_df <- read_vc(rf[1], root = repo)
  })
  expect_identical(ncol(test_data), ncol(changed_df))
  updated <- which(colnames(test_data) != colnames(changed_df))
  expect_identical(length(updated), length(change))
  expect_identical(colnames(test_data)[updated], unname(change))
  expect_identical(colnames(changed_df)[updated], names(change))
  expect_equivalent(
    test_data[order(test_data$test_factor, test_data$test_Date), change],
    changed_df[, names(change)]
  )
  git2r::reset(cm, "hard")

  # staged & sorted on other variable
  change <- c("new_var" = "test_numeric")
  expect_silent({
    rf <- rename_variable(
      file = files[1], change = change, root = repo, stage = TRUE
    )
  })
  expect_identical(unname(files), unname(rf))
  expect_true(length(git2r::status(repo)[["staged"]]) > 0)
  expect_length(git2r::status(repo)[["unstaged"]], 0)
  expect_length(git2r::status(repo)[["untracked"]], 0)
  expect_silent({
    changed_df <- read_vc(rf[1], root = repo)
  })
  expect_identical(ncol(test_data), ncol(changed_df))
  updated <- which(colnames(test_data) != colnames(changed_df))
  expect_identical(length(updated), length(change))
  expect_identical(colnames(test_data)[updated], unname(change))
  expect_identical(colnames(changed_df)[updated], names(change))
  expect_equivalent(
    signif(
      test_data[order(test_data$test_factor, test_data$test_Date), change], 6
    ),
    changed_df[, names(change)]
  )
  git2r::reset(cm, "hard")
})

test_that("rename_variable() handles wrong type of root", {
  expect_error(
    rename_variable(root = 1),
    "a 'root' of class numeric is not supported"
  )
})
