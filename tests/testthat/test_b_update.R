context("write_vc() updates correctly when strict = FALSE")
root <- tempfile("git2rdata-update")
setup({
  dir.create(root)
})
teardown({
  unlink(root, recursive = TRUE)
})
original <- data.frame(
  test_logical = TRUE,
  test_integer = 1L,
  test_numeric = pi,
  test_character = "abc",
  test_factor = factor("abc", levels = c("abc", "def")),
  test_Date = Sys.Date(),
  test_POSIXct = Sys.time(),
  test_complex = complex(imaginary = 1),
  stringsAsFactors = FALSE
)
test_that("updates to logical", {
  write_vc(original, "logical", root, sorting = "test_logical", digits = 6)
  updated <- matrix(TRUE, ncol = ncol(original), dimnames = dimnames(original))
  updated <- as.data.frame(updated)
  expect_is(
    suppressWarnings(
      fn <- write_vc(updated, "logical", root, strict = FALSE)
    ),
    "character"
  )
  expect_equal(read_vc(fn[1], root), updated, check.attributes = FALSE)
})
test_that("updates to integer", {
  write_vc(original, "integer", root, sorting = "test_logical", digits = 6)
  updated <- matrix(1L, ncol = ncol(original), dimnames = dimnames(original))
  updated <- as.data.frame(updated)
  expect_is(
    suppressWarnings(
      fn <- write_vc(updated, "integer", root, strict = FALSE)
    ),
    "character"
  )
  expect_equal(read_vc(fn[1], root), updated, check.attributes = FALSE)
})
test_that("updates to numeric", {
  write_vc(original, "numeric", root, sorting = "test_logical", digits = 6)
  updated <- matrix(pi, ncol = ncol(original), dimnames = dimnames(original))
  updated <- as.data.frame(updated)
  expect_is(
    suppressWarnings(
      fn <- write_vc(updated, "numeric", root, strict = FALSE)
    ),
    "character"
  )
  expect_equal(
    read_vc(fn[1], root), signif(updated, 6), check.attributes = FALSE
  )
})
test_that("updates to character", {
  write_vc(original, "character", root, sorting = "test_logical", digits = 6)
  updated <- matrix("xyz", ncol = ncol(original), dimnames = dimnames(original))
  updated <- as.data.frame(updated, stringsAsFactor = FALSE)
  expect_is(
    suppressWarnings(
      fn <- write_vc(updated, "character", root, strict = FALSE)
    ),
    "character"
  )
  expect_equal(read_vc(fn[1], root), updated, check.attributes = FALSE)
})
test_that("updates to factor", {
  write_vc(original, "factor", root, sorting = "test_logical", digits = 6)
  updated <- matrix("xyz", ncol = ncol(original), dimnames = dimnames(original))
  updated <- apply(updated, 2, list)
  updated <- as.data.frame(lapply(updated, factor, levels = c("xyz", "abc")))
  expect_is(
    suppressWarnings(
      fn <- write_vc(updated, "factor", root, strict = FALSE)
    ),
    "character"
  )
  expect_equal(read_vc(fn[1], root), updated, check.attributes = FALSE)
  expect_identical(
    yaml::read_yaml(file.path(root, fn[2]))$test_factor$labels,
    levels(updated$test_factor)
  )
  expect_identical(
    yaml::read_yaml(file.path(root, fn[2]))$test_factor$index,
    c(3L, 1L)
  )
})
test_that("updates to Date", {
  write_vc(original, "Date", root, sorting = "test_logical", digits = 6)
  updated <- matrix(Sys.Date(), ncol = ncol(original),
                    dimnames = dimnames(original))
  updated <- as.data.frame(updated)
  expect_is(
    suppressWarnings(
      fn <- write_vc(updated, "Date", root, strict = FALSE)
    ),
    "character"
  )
  expect_equal(read_vc(fn[1], root), updated, check.attributes = FALSE)
})
test_that("updates to POSIXct", {
  write_vc(original, "POSIXct", root, sorting = "test_logical", digits = 6)
  Sys.time() |>
    as.POSIXct(tz = "UTC") |>
    list() |>
    rep(ncol(original)) |>
    setNames(colnames(original)) |>
    as.data.frame() -> updated
  expect_is(
    suppressWarnings(
      fn <- write_vc(updated, "POSIXct", root, strict = FALSE)
    ),
    "character"
  )
  expect_equal(read_vc(fn[1], root), updated, check.attributes = FALSE)
})
test_that("updates to complex", {
  write_vc(original, "complex", root, sorting = "test_logical", digits = 6)
  updated <- matrix(complex(imaginary = 1), ncol = ncol(original),
                    dimnames = dimnames(original))
  updated <- as.data.frame(updated)
  expect_is(
    suppressWarnings(
      fn <- write_vc(updated, "complex", root, strict = FALSE)
    ),
    "character"
  )
  expect_equal(read_vc(fn[1], root), updated, check.attributes = FALSE)
})
