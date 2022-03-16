root <- tempfile("git2rdata-upgrade")
dir.create(root)
origin <- system.file("testthat", package = "git2rdata")
file.copy(origin, root, recursive = TRUE)
path <- file.path(root, "testthat")

test_that("read_vc() checks version", {
  expect_error(
    read_vc("optimized_0_0_4", path), "Data stored using an older version"
  )
  expect_error(
    read_vc("verbose_0_0_4", path), "Data stored using an older version"
  )
  expect_is(read_vc("optimized_0_3_1", path), "data.frame")
  expect_error(
    read_vc("verbose_0_3_1", path), "Data stored using an older version"
  )
})


test_that("upgrade_data() works on single files", {
  expect_message(
    z <- upgrade_data(file = "optimized_0_4_0", root = path),
    "already up to date"
  )
  expect_is(z, "character")
  expect_silent(
    upgrade_data(file = "optimized_0_4_0", root = path, verbose = FALSE)
  )
  expect_is(read_vc("optimized_0_4_0", path), "data.frame")

  expect_message(
    z <- upgrade_data(file = "verbose_0_4_0", root = path),
    "already up to date"
  )
  expect_is(z, "character")
  expect_silent(
    upgrade_data(file = "verbose_0_4_0", root = path, verbose = FALSE)
  )
  expect_is(read_vc("verbose_0_4_0", path), "data.frame")

  expect_message(
    z <- upgrade_data(file = "optimized_0_3_1", root = path),
    "already up to date"
  )
  expect_is(z, "character")
  expect_silent(
    upgrade_data(file = "optimized_0_3_1", root = path, verbose = FALSE)
  )
  expect_is(read_vc("optimized_0_3_1", path), "data.frame")

  expect_message(
    z <- upgrade_data(file = "verbose_0_3_1", root = path), "updated"
  )
  expect_true(file_test("-f", file.path(path, "verbose_0_3_1.csv")))
  expect_false(file_test("-f", file.path(path, "verbose_0_3_1.tsv")))
  expect_is(read_vc("verbose_0_3_1", path), "data.frame")

  expect_error(
    upgrade_data(file = "optimized_0_0_4", root = path), "ancient"
  )
})

root <- tempfile("git2rdata-upgrade")
dir.create(root)
origin <- system.file("testthat", package = "git2rdata")
file.copy(origin, root, recursive = TRUE)
path <- file.path(root, "testthat")
file.remove(
  list.files(path, pattern = "0_0_4", full.names = TRUE)
)
test_that("upgrade_data() works on paths", {
  expect_message(z <- upgrade_data(root = root, path = "."))
  expect_is(z, "character")
  expect_silent(upgrade_data(root = root, path = ".", verbose = FALSE))
  expect_is(read_vc("optimized_0_4_0", path), "data.frame")
  expect_is(read_vc("verbose_0_4_0", path), "data.frame")
  expect_is(read_vc("optimized_0_3_1", path), "data.frame")
  expect_is(read_vc("verbose_0_3_1", path), "data.frame")
})
file.remove(
  list.files(root, recursive = TRUE, full.names = TRUE)
)

root <- tempfile("git2rdata-upgrade")
dir.create(root)
origin <- system.file("testthat", package = "git2rdata")
file.copy(origin, root, recursive = TRUE)
path <- file.path(root, "testthat")
file.remove(list.files(path, pattern = "0_0_4", full.names = TRUE))
repo <- git2r::init(root)
git2r::config(repo, user.name = "Alice", user.email = "alice@example.org")
git2r::add(repo, list.files(root, recursive = TRUE))
git2r::commit(repo, message = "initial commit")

test_that("upgrade_data() works on a git repository", {
  expect_message(z <- upgrade_data(root = repo, path = "."))
  expect_is(z, "character")
  expect_silent(upgrade_data(root = repo, path = ".", verbose = FALSE))
  expect_is(read_vc("optimized_0_4_0", path), "data.frame")
  expect_is(read_vc("verbose_0_4_0", path), "data.frame")
  expect_is(read_vc("optimized_0_3_1", path), "data.frame")
  expect_is(read_vc("verbose_0_3_1", path), "data.frame")
  expect_identical(
    vapply(status(repo), length, integer(1)),
    c(staged = 0L, unstaged = 2L, untracked = 1L)
  )
  expect_silent(
    upgrade_data(root = repo, path = ".", verbose = FALSE, stage = TRUE)
  )
  expect_identical(
    vapply(status(repo), length, integer(1)),
    c(staged = 3L, unstaged = 0L, untracked = 0L)
  )
})

test_that("validation", {
  root <- tempfile("git2rdata-upgrade")
  dir.create(root)
  origin <- system.file("testthat", package = "git2rdata")
  file.copy(origin, root, recursive = TRUE)
  path <- file.path(root, "testthat")
  expect_error(
    upgrade_data(root = 1), "a 'root' of class numeric is not supported"
  )
  yml <- read_yaml(file.path(path, "verbose_0_0_4.yml"))
  write_yaml(
    yml[names(yml) != "..generic"], file.path(path, "verbose_0_0_4.yml")
  )
  expect_message(
    upgrade_data(file = "verbose_0_0_4", root = path),
    "is not a git2rdata object"
  )
})
