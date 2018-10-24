context("write_vc() and read_vc() on a file system")
expect_error(write_vc(), "'root' is missing")
expect_error(write_vc(root = 1), "a 'root' of class numeric is not supported")
root <- tempfile(pattern = "git2rdata-")
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
  read_vc(file = "test.xls", root = root),
  sorted_test_data
)
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
expect_equal(read_vc(file = "a/verbose", root = root), sorted_test_data)
expect_error(
  write_vc(x = test_data, file = "a/verbose", root = root),
  "old data was stored verbose"
)


test_na <- test_data
for (i in seq_along(test_na)) {
  test_na[sample(test_n, size = ceiling(0.1 * test_n)), i] <- NA
}
expect_error(
  write_vc(test_na, file = "na", root = root),
  "The string 'NA' cannot be stored"
)
test_na[["test_character"]] <- NULL
expect_is(
  output <- write_vc(
    test_na, file = "na", root = root,
    sorting = c("test_Date", "test_integer", "test_numeric")
  ),
  "character"
)
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

expect_error(
  meta("NA"),
  "The string 'NA' cannot be stored"
)
expect_error(
  meta(c("NA ", " NA", "\t")),
  "Character variable cannot contain tab"
)
expect_error(
  meta(c(" \n ")),
  "Character variable cannot contain tab"
)
