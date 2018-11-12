context("write_vc() and read_vc() on a file system")
expect_error(write_vc(), "'root' is missing")
expect_error(write_vc(root = 1), "a 'root' of class numeric is not supported")
root <- tempfile(pattern = "git2rdata-basic")
dir.create(root)
expect_false(any(file.exists(git2rdata:::clean_data_path(root, "test"))))
expect_error(
  write_vc(x = test_data, file = "test.txt", root = root),
  "new metadata requires 'sorting'"
)
expect_is(
  output <- write_vc(
    x = test_data, file = "test.txt", root = root, sorting = "test_Date"
  ),
  "character"
)
expect_identical(length(output), 2L)
expect_identical(names(output), c("test.tsv", "test.yml"))
expect_true(all(file.exists(git2rdata:::clean_data_path(root, "test"))))
expect_equal(
  stored <- read_vc(file = "test.xls", root = root),
  sorted_test_data,
  check.attributes = FALSE
)
for (i in colnames(stored)) {
  expect_equal(
    stored[[i]],
    sorted_test_data[[i]],
    label = paste0("stored$", i),
    expected.label = paste0("sorted_test_data$", i)
  )
}
expect_identical(
  write_vc(x = test_data, file = "test.xls", root = root),
  output
)
expect_error(
  write_vc(x = test_data, file = "test", root = root, optimize = FALSE),
  "old data was stored optimized"
)
expect_error(
  write_vc(
    x = test_data[, colnames(test_data) != "test_Date"],
    file = "test", root = root
  ),
  "new data lacks old sorting variable"
)

expect_false(any(file.exists(git2rdata:::clean_data_path(root, "a/verbose"))))
expect_is(
  output <-
    write_vc(
      x = test_data, file = "a/verbose", root = root, sorting = "test_Date",
      optimize = FALSE
    ),
  "character"
)
expect_true(all(file.exists(git2rdata:::clean_data_path(root, "a/verbose"))))
expect_equal(
  stored <- read_vc(file = "a/verbose", root = root),
  sorted_test_data,
  check.attributes = FALSE
)
for (i in colnames(stored)) {
  expect_equal(
    stored[[i]],
    sorted_test_data[[i]],
    label = paste0("stored$", i),
    expected.label = paste0("sorted_test_data$", i)
  )
}
expect_error(
  write_vc(x = test_data, file = "a/verbose", root = root),
  "old data was stored verbose"
)

expect_is(
  output <- write_vc(
    test_na, file = "na", root = root,
    sorting = c("test_Date", "test_integer", "test_numeric")
  ),
  "character"
)
expect_equal(
  stored <- read_vc(file = "na", root = root),
  sorted_test_na,
  check.attributes = FALSE
)
for (i in colnames(stored)) {
  expect_equal(
    stored[[i]],
    sorted_test_na[[i]],
    label = paste0("stored$", i),
    expected.label = paste0("sorted_test_na$", i)
  )
}

expect_error(
  write_vc(test_data, file = "error", root = root, sorting = 1),
  "sorting is not a character vector"
)
expect_error(
  write_vc(test_data, file = "error", root = root, sorting = character()),
  "at least one variable is required for sorting"
)
expect_error(
  write_vc(test_data, file = "error", root = root, sorting = "junk"),
  "use only variables of 'x' for sorting"
)
expect_false(any(file.exists(git2rdata:::clean_data_path(root, "sorting"))))
expect_warning(
  output <-
    write_vc(test_data, file = "sorting", root = root, sorting = "test_factor"),
  "sorting results in ties"
)
expect_is(output, "character")
expect_true(all(file.exists(git2rdata:::clean_data_path(root, "sorting"))))
test_changed <- test_data
test_changed$junk <- test_changed$test_character
expect_error(
  write_vc(
    test_changed, file = "sorting", root = root, sorting = "test_factor"
  ),
  "old data has different number of variables"
)
test_changed$test_character <- NULL
expect_error(
  write_vc(
    test_changed, file = "sorting", root = root, sorting = "test_factor"
  ),
  "old data has different variables"
)
test_changed <- test_data
test_changed$test_character <- factor(test_changed$test_character)
expect_error(
  write_vc(
    test_changed, file = "sorting", root = root, sorting = "test_factor"
  ),
  "old data has different variable types or sorting"
)
expect_error(
  write_vc(
    test_data, file = "sorting", root = root, sorting = "test_logical"
  ),
  "old data has different variable types or sorting"
)

yml <- file.path(root, "sorting.yml")
meta <- head(readLines(yml), -1)
writeLines(text = meta, con = yml)
expect_error(
  write_vc(test_data, file = "sorting", root = root, sorting = "test_factor"),
  "error in existing metadata"
)
expect_error(
  read_vc(file = "sorting", root = root),
  "error in metadata"
)
file.remove(list.files(root, recursive = TRUE, full.names = TRUE))

test_that(
  "meta() works on complex",
  {
    z <- complex(real = runif(10), imaginary = runif(10))
    expect_equal(
      mz <- meta(z),
      z,
      check.attributes = FALSE
    )
    expect_true(assertthat::has_attr(mz, "meta"))
    expect_match(attr(mz, "meta"), "class: complex")
  }
)
