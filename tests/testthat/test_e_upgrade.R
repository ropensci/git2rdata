context("upgrade to new version")
root <- tempfile("git2rdata-upgrade")
dir.create(root)
test_that("read_vc() checks version", {
  file <- basename(tempfile(tmpdir = root))
  junk <- write_vc(test_data, file = file, root = root, sorting = "test_Date")
  correct_yaml <- yaml::read_yaml(file.path(root, junk[2]))
  junk_yaml <- correct_yaml
  junk_yaml[["..generic"]][["git2rdata"]] <- "0.0.3"
  yaml::write_yaml(junk_yaml, file.path(root, junk[2]))
  expect_error(
    read_vc(file = file, root = root),
    "Data stored using an older version of `git2rdata`."
  )

  junk_yaml[["..generic"]][["git2rdata"]] <- NULL
  yaml::write_yaml(junk_yaml, file.path(root, junk[2]))
  expect_error(
    read_vc(file = file, root = root),
    "Data stored using an older version of `git2rdata`."
  )
})

test_that("relabel() checks version", {
  file <- basename(tempfile(tmpdir = root))
  junk <- write_vc(test_data, file = file, root = root, sorting = "test_Date")
  new_labels <- list(test_factor = list(a = "xyz"))
  correct_yaml <- yaml::read_yaml(file.path(root, junk[2]))
  junk_yaml <- correct_yaml
  junk_yaml[["..generic"]][["git2rdata"]] <- "0.0.3"
  yaml::write_yaml(junk_yaml, file.path(root, junk[2]))
  expect_error(
    relabel(file = file, root = root, change = new_labels),
    "Data stored using an older version of `git2rdata`."
  )

  junk_yaml[["..generic"]][["git2rdata"]] <- NULL
  yaml::write_yaml(junk_yaml, file.path(root, junk[2]))
  expect_error(
    relabel(file = file, root = root, change = new_labels),
    "Data stored using an older version of `git2rdata`."
  )
})

test_that("upgrade_data() validates metadata", {
  file <- basename(tempfile(tmpdir = root))
  junk <- write_vc(test_data, file = file, root = root, sorting = "test_Date")
  expect_error(
    upgrade_data(file = file, root = pi),
    "a 'root' of class numeric is not supported"
  )

  correct_yaml <- yaml::read_yaml(file.path(root, junk[2]))
  junk_yaml <- correct_yaml
  junk_yaml[["..generic"]][["git2rdata"]] <- "0.0.4"
  yaml::write_yaml(junk_yaml, file.path(root, junk[2]))
  expect_identical(
    unname(upgrade_data(file = file, root = root)),
    file
  )
  junk_yaml[["..generic"]][["hash"]] <- NULL
  yaml::write_yaml(junk_yaml, file.path(root, junk[2]))
  expect_error(
    upgrade_data(file = file, root = root),
    "corrupt metadata, no hash found."
  )
  junk_yaml[["..generic"]] <- NULL
  yaml::write_yaml(junk_yaml, file.path(root, junk[2]))
  expect_message(
    junk <- upgrade_data(file = file, root = root),
    "is not a git2rdata object"
  )
  expect_equivalent(file, junk)

  file <- basename(tempfile(tmpdir = root))
  junk <- write_vc(test_data, file = file, root = root, sorting = "test_Date",
                   optimize = FALSE)
  correct_yaml <- yaml::read_yaml(file.path(root, junk[2]))
  junk_yaml <- correct_yaml
  junk_yaml[["..generic"]][["git2rdata"]] <- "0.0.5"
  yaml::write_yaml(junk_yaml, file.path(root, junk[2]))
  expect_identical(
    unname(upgrade_data(file = file, root = root)),
    file
  )
})

file.remove(list.files(root, recursive = TRUE, full.names = TRUE))

test_that("upgrade_data() works from 0.0.3 to 0.0.4", {
  file <- basename(tempfile(tmpdir = root))
  junk <- write_vc(test_data, file = file, root = root, sorting = "test_Date")
  correct_yaml <- yaml::read_yaml(file.path(root, junk[2]))
  old_yaml <- correct_yaml
  old_yaml[["..generic"]][["git2rdata"]] <- NULL
  old_yaml[["..generic"]][["data_hash"]] <- NULL
  yaml::write_yaml(old_yaml, file.path(root, junk[2]))
  expect_message(
    files <- upgrade_data(file = file, root = root, verbose = TRUE),
    paste0(file, ".yml updated")
  )
  expect_message(
    files <- upgrade_data(file = file, root = root, verbose = TRUE),
    paste(file, "already up to date")
  )
  expect_equivalent(read_vc(file = file, root = root), sorted_test_data)

  root <- git2r::init(root)
  git2r::config(root, user.name = "Alice", user.email = "alice@example.org")
  yaml::write_yaml(old_yaml, file.path(git2r::workdir(root), junk[2]))
  git2r::add(root, paste0(file, c(".tsv", ".yml")))
  initial_commit <- commit(root, "initial commit", all = TRUE)
  expect_message(
    files <- upgrade_data(file = file, root = root, verbose = TRUE),
    paste0(file, ".yml updated")
  )
  expect_equal(
    status(root),
    list(staged = list(), unstaged = list(paste0(files, ".yml")),
      untracked = list()),
    check.attributes = FALSE
  )
  expect_message(
    files <- upgrade_data(file = file, root = root, verbose = TRUE,
                          stage = TRUE),
    paste(file, "already up to date")
  )
  expect_equal(
    status(root),
    list(
      staged = list(paste0(files, ".yml")), unstaged = list(),
      untracked = list()
    ),
    check.attributes = FALSE
  )

  file <- basename(tempfile(tmpdir = git2r::workdir(root)))
  junk <- write_vc(test_data, file = file, root = root, sorting = "test_Date")
  expect_error(
    upgrade_data(file = file, path = ".", root = root, verbose = TRUE),
    "specify either 'file' or 'path'"
  )
  expect_is(
    upgrade_data(path = ".", root = root, verbose = TRUE),
    "character"
  )
})

file.remove(list.files(git2r::workdir(root), recursive = TRUE,
                       full.names = TRUE))
