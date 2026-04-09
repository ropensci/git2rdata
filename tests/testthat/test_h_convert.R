test_that("convert parameter validation", {
  root <- tempfile(pattern = "git2rdata-convert")
  dir.create(root)
  test_df <- data.frame(
    a = c("hello", "world"),
    b = 1:2,
    stringsAsFactors = FALSE
  )

  # convert must be a list
  expect_error(
    write_vc(
      test_df,
      "test",
      root = root,
      sorting = "b",
      convert = "not_a_list",
      digits = 6
    ),
    "convert must be a list"
  )

  # convert must be a named list
  expect_error(
    write_vc(
      test_df,
      "test",
      root = root,
      sorting = "b",
      convert = list("base::toupper"),
      digits = 6
    ),
    "convert must be a named list"
  )

  # all elements must be named
  expect_error(
    write_vc(
      test_df,
      "test",
      root = root,
      sorting = "b",
      convert = list(
        a = c(write = "base::toupper", read = "base::tolower"),
        ""
      ),
      digits = 6
    ),
    "all elements of convert must be named"
  )

  # names must be present in colnames
  expect_error(
    write_vc(
      test_df,
      "test",
      root = root,
      sorting = "b",
      convert = list(c = c(write = "base::toupper", read = "base::tolower")),
      digits = 6
    ),
    "all names in convert must be present in colnames of x"
  )

  # each element must be character vector
  expect_error(
    write_vc(
      test_df,
      "test",
      root = root,
      sorting = "b",
      convert = list(a = 123),
      digits = 6
    ),
    "convert\\[\\['a'\\]\\] must be a character vector"
  )

  # each element must have length 2
  expect_error(
    write_vc(
      test_df,
      "test",
      root = root,
      sorting = "b",
      convert = list(a = c("base::toupper")),
      digits = 6
    ),
    "convert\\[\\['a'\\]\\] must have length 2"
  )

  # each element must be a named vector
  expect_error(
    write_vc(
      test_df,
      "test",
      root = root,
      sorting = "b",
      convert = list(a = c("base::toupper", "base::tolower")),
      digits = 6
    ),
    "convert\\[\\['a'\\]\\] must be a named vector"
  )

  # names must be 'write' and 'read'
  expect_error(
    write_vc(
      test_df,
      "test",
      root = root,
      sorting = "b",
      convert = list(a = c(w = "base::toupper", r = "base::tolower")),
      digits = 6
    ),
    "convert\\[\\['a'\\]\\] must have names 'write' and 'read'"
  )

  # must have both 'write' and 'read'
  expect_error(
    write_vc(
      test_df,
      "test",
      root = root,
      sorting = "b",
      convert = list(a = c(write = "base::toupper", write = "base::tolower")),
      digits = 6
    ),
    "convert\\[\\['a'\\]\\] must have both 'write' and 'read' elements"
  )

  # function must be in package::function format
  expect_error(
    write_vc(
      test_df,
      "test",
      root = root,
      sorting = "b",
      convert = list(a = c(write = "toupper", read = "base::tolower")),
      digits = 6
    ),
    paste(
      "convert\\[\\['a'\\]\\]\\[\\['write'\\]\\]",
      "must be in 'package::function' format"
    )
  )

  # must have exactly one '::'
  expect_error(
    write_vc(
      test_df,
      "test",
      root = root,
      sorting = "b",
      convert = list(
        a = c(write = "base::pkg::toupper", read = "base::tolower")
      ),
      digits = 6
    ),
    "convert\\[\\['a'\\]\\]\\[\\['write'\\]\\] must have exactly one '::'"
  )

  # package and function name must not be empty
  expect_error(
    write_vc(
      test_df,
      "test",
      root = root,
      sorting = "b",
      convert = list(a = c(write = "::toupper", read = "base::tolower")),
      digits = 6
    ),
    paste(
      "convert\\[\\['a'\\]\\]\\[\\['write'\\]\\]",
      "has empty package or function name"
    )
  )

  # package must be available
  expect_error(
    write_vc(
      test_df,
      "test",
      root = root,
      sorting = "b",
      convert = list(
        a = c(write = "nonexistent::toupper", read = "base::tolower")
      ),
      digits = 6
    ),
    "Package 'nonexistent' required .* is not available"
  )

  # function must exist in package
  expect_error(
    write_vc(
      test_df,
      "test",
      root = root,
      sorting = "b",
      convert = list(
        a = c(write = "base::nonexistent_func", read = "base::tolower")
      ),
      digits = 6
    ),
    "Function 'nonexistent_func' not found in package 'base'"
  )

  unlink(root, recursive = TRUE)
})

test_that("convert works with valid conversions", {
  root <- tempfile(pattern = "git2rdata-convert")
  dir.create(root)
  test_df <- data.frame(
    text = c("hello", "world", "test"),
    number = 1:3,
    stringsAsFactors = FALSE
  )

  # Test basic conversion
  output <- write_vc(
    test_df,
    "test",
    root = root,
    sorting = "number",
    convert = list(text = c(write = "base::toupper", read = "base::tolower")),
    digits = 6
  )

  expect_identical(length(output), 2L)
  expect_true(all(file.exists(git2rdata:::clean_data_path(root, "test"))))

  # Check that data was written in uppercase
  raw_file <- file.path(root, "test.tsv")
  raw_content <- readLines(raw_file)
  expect_true(any(grepl("HELLO", raw_content)))
  expect_true(any(grepl("WORLD", raw_content)))

  # Read back and check conversion
  result <- read_vc("test", root = root)
  expect_equal(result$text, c("hello", "world", "test"))
  expect_equal(result$number, 1:3)

  # Check that convert is in attributes
  expect_true("convert" %in% names(attributes(result)))
  expect_equal(
    attr(result, "convert"),
    list(text = c("base::toupper", "base::tolower"))
  )

  unlink(root, recursive = TRUE)
})

test_that("convert works with multiple columns", {
  root <- tempfile(pattern = "git2rdata-convert")
  dir.create(root)
  test_df <- data.frame(
    text1 = c("hello", "world"),
    text2 = c("foo", "bar"),
    number = 1:2,
    stringsAsFactors = FALSE
  )

  output <- write_vc(
    test_df,
    "test",
    root = root,
    sorting = "number",
    convert = list(
      text1 = c(write = "base::toupper", read = "base::tolower"),
      text2 = c(write = "base::toupper", read = "base::tolower")
    ),
    digits = 6
  )

  # Read back and check both conversions applied
  result <- read_vc("test", root = root)
  expect_equal(result$text1, c("hello", "world"))
  expect_equal(result$text2, c("foo", "bar"))

  unlink(root, recursive = TRUE)
})

test_that("convert stores and reads metadata correctly", {
  root <- tempfile(pattern = "git2rdata-convert")
  dir.create(root)
  test_df <- data.frame(
    text = c("hello", "world"),
    number = 1:2,
    stringsAsFactors = FALSE
  )

  write_vc(
    test_df,
    "test",
    root = root,
    sorting = "number",
    convert = list(text = c(read = "base::tolower", write = "base::toupper")),
    digits = 6
  )

  # Check metadata file contains convert information
  meta_file <- file.path(root, "test.yml")
  meta_content <- yaml::read_yaml(meta_file)

  expect_true("convert" %in% names(meta_content[["..generic"]]))
  expect_equal(
    meta_content[["..generic"]][["convert"]],
    list(text = c("base::toupper", "base::tolower"))
  )

  unlink(root, recursive = TRUE)
})

test_that("convert works with empty list", {
  root <- tempfile(pattern = "git2rdata-convert")
  dir.create(root)
  test_df <- data.frame(
    text = c("hello", "world"),
    number = 1:2,
    stringsAsFactors = FALSE
  )

  # Should work with empty convert list
  output <- write_vc(
    test_df,
    "test",
    root = root,
    sorting = "number",
    convert = list(),
    digits = 6
  )

  result <- read_vc("test", root = root)
  expect_equal(result$text, c("hello", "world"))

  # Check that convert is not in metadata when empty
  meta_file <- file.path(root, "test.yml")
  meta_content <- yaml::read_yaml(meta_file)
  expect_false("convert" %in% names(meta_content[["..generic"]]))

  unlink(root, recursive = TRUE)
})

test_that("convert works with NULL", {
  root <- tempfile(pattern = "git2rdata-convert")
  dir.create(root)
  test_df <- data.frame(
    text = c("hello", "world"),
    number = 1:2,
    stringsAsFactors = FALSE
  )

  # Should work with NULL convert
  output <- write_vc(
    test_df,
    "test",
    root = root,
    sorting = "number",
    convert = NULL,
    digits = 6
  )

  result <- read_vc("test", root = root)
  expect_equal(result$text, c("hello", "world"))

  unlink(root, recursive = TRUE)
})

test_that("convert attribute is not present when not used", {
  root <- tempfile(pattern = "git2rdata-convert")
  dir.create(root)
  test_df <- data.frame(
    text = c("hello", "world"),
    number = 1:2,
    stringsAsFactors = FALSE
  )

  # Write without convert
  write_vc(
    test_df,
    "test",
    root = root,
    sorting = "number",
    digits = 6
  )

  result <- read_vc("test", root = root)
  expect_false("convert" %in% names(attributes(result)))

  unlink(root, recursive = TRUE)
})

test_that("convert works with optimize = FALSE", {
  root <- tempfile(pattern = "git2rdata-convert")
  dir.create(root)
  test_df <- data.frame(
    text = c("hello", "world"),
    number = 1:2,
    stringsAsFactors = FALSE
  )

  output <- write_vc(
    test_df,
    "test",
    root = root,
    sorting = "number",
    optimize = FALSE,
    convert = list(text = c(write = "base::toupper", read = "base::tolower")),
    digits = 6
  )

  # Check that data was written as CSV with uppercase
  raw_file <- file.path(root, "test.csv")
  expect_true(file.exists(raw_file))
  raw_content <- readLines(raw_file)
  expect_true(any(grepl("HELLO", raw_content)))

  result <- read_vc("test", root = root)
  expect_equal(result$text, c("hello", "world"))
  expect_equal(
    attr(result, "convert"),
    list(text = c("base::toupper", "base::tolower"))
  )

  unlink(root, recursive = TRUE)
})

test_that("convert changes are detected when updating files", {
  root <- tempfile(pattern = "git2rdata-convert")
  dir.create(root)
  test_df <- data.frame(
    text = c("hello", "world"),
    number = 1:2,
    stringsAsFactors = FALSE
  )

  # Write first time with convert
  write_vc(
    test_df,
    "test",
    root = root,
    sorting = "number",
    convert = list(text = c(write = "base::toupper", read = "base::tolower")),
    digits = 6
  )

  # Try to write again with different convert in strict mode - should error
  expect_error(
    write_vc(
      test_df,
      "test",
      root = root,
      sorting = "number",
      convert = list(),
      digits = 6,
      strict = TRUE
    ),
    "The data was not overwritten"
  )

  # Write with strict = FALSE should warn
  expect_warning(
    write_vc(
      test_df,
      "test",
      root = root,
      sorting = "number",
      convert = list(),
      digits = 6,
      strict = FALSE
    ),
    "Changes in the metadata"
  )

  unlink(root, recursive = TRUE)
})

test_that("backward compatibility: reading files without convert", {
  root <- tempfile(pattern = "git2rdata-convert")
  dir.create(root)
  test_df <- data.frame(
    text = c("hello", "world"),
    number = 1:2,
    stringsAsFactors = FALSE
  )

  # Write without convert
  write_vc(
    test_df,
    "test",
    root = root,
    sorting = "number",
    digits = 6
  )

  # Read should work fine, no convert in attributes
  result <- read_vc("test", root = root)
  expect_equal(result$text, c("hello", "world"))
  expect_false("convert" %in% names(attributes(result)))

  # Now update with convert should work with strict = FALSE
  expect_warning(
    write_vc(
      test_df,
      "test",
      root = root,
      sorting = "number",
      convert = list(text = c(write = "base::toupper", read = "base::tolower")),
      digits = 6,
      strict = FALSE
    ),
    "The convert variables changed"
  )

  unlink(root, recursive = TRUE)
})
