context("empty label")
root <- tempfile("git2rdata-empty-label")
dir.create(root)

test_that("write_vc handles empty labels", {
  # "" is first level
  mydf <- data.frame(
    id = 1:6,
    var = factor(c("", "", "a", "b", NA, NA), levels = c("", "a", "b"))
  )
  file <- basename(tempfile(tmpdir = root))
  expect_is(
    original <- write_vc(mydf, file = file, root = root, sorting = "id"),
    "character"
  )
  expect_equivalent(mydf, mydfr <- read_vc(file = file, root = root))
  expect_is(
    original <- write_vc(mydfr, file = file, root = root),
    "character"
  )
  expect_equivalent(mydf, mydfr <- read_vc(file = file, root = root))

  # "" is middle level
  mydf <- data.frame(
    id = 1:6,
    var = factor(c("", "", "a", "b", NA, NA), levels = c("a", "", "b"))
  )
  file <- basename(tempfile(tmpdir = root))
  expect_is(
    original <- write_vc(mydf, file = file, root = root, sorting = "id"),
    "character"
  )
  expect_equivalent(mydf, mydfr <- read_vc(file = file, root = root))
  expect_is(
    original <- write_vc(mydfr, file = file, root = root),
    "character"
  )
  expect_equivalent(mydf, mydfr <- read_vc(file = file, root = root))

  # "" is last level
  mydf <- data.frame(
    id = 1:6,
    var = factor(c("", "", "a", "b", NA, NA), levels = c("a", "b", ""))
  )
  file <- basename(tempfile(tmpdir = root))
  expect_is(
    original <- write_vc(mydf, file = file, root = root, sorting = "id"),
    "character"
  )
  expect_equivalent(mydf, mydfr <- read_vc(file = file, root = root))
  expect_is(
    original <- write_vc(mydfr, file = file, root = root),
    "character"
  )
  expect_equivalent(mydf, mydfr <- read_vc(file = file, root = root))
})

test_that("relabel handles empty labels", {
  change <- data.frame(
    factor = "var", old = "", new = "something", stringsAsFactors = TRUE
  )

  # "" is first level
  mydf <- data.frame(
    id = 1:6,
    var = factor(c("", "", "a", "b", NA, NA), levels = c("", "a", "b"))
  )
  file <- basename(tempfile(tmpdir = root))
  expect_is(
    original <- write_vc(mydf, file = file, root = root, sorting = "id"),
    "character"
  )
  relabel(file = file, root = root, change = change)
  expect_is(mydfr <- read_vc(file = file, root = root), "data.frame")

  # "" is middle level
  mydf <- data.frame(
    id = 1:6,
    var = factor(c("", "", "a", "b", NA, NA), levels = c("a", "", "b"))
  )
  file <- basename(tempfile(tmpdir = root))
  expect_is(
    original <- write_vc(mydf, file = file, root = root, sorting = "id"),
    "character"
  )
  relabel(file = file, root = root, change = change)
  expect_is(mydfr <- read_vc(file = file, root = root), "data.frame")

  # "" is last level
  mydf <- data.frame(
    id = 1:6,
    var = factor(c("", "", "a", "b", NA, NA), levels = c("a", "b", ""))
  )
  file <- basename(tempfile(tmpdir = root))
  expect_is(
    original <- write_vc(mydf, file = file, root = root, sorting = "id"),
    "character"
  )
  relabel(file = file, root = root, change = change)
  expect_is(mydfr <- read_vc(file = file, root = root), "data.frame")
})
