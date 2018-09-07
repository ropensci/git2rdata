context("write_vc")
expect_error(write_vc(), "'root' is missing")
expect_error(write_vc(root = 1), "a 'root' of class numeric is not supported")
root <- tempfile(pattern = "git2rdata-")
dir.create(root)
expect_false(any(file.exists(git2rdata:::clean_data_path(root, "test"))))
expect_is(
  output <- write_vc(x = test_data, file = "test.txt", root = root),
  "character"
)
expect_identical(length(output), 2L)
expect_identical(names(output), c("test.tsv", "test.yml"))
expect_true(all(file.exists(git2rdata:::clean_data_path(root, "test"))))
expect_identical(
  write_vc(x = test_data, file = "test.xls", root = root),
  output
)
expect_error(
  write_vc(x = test_data, file = "test", root = root, optimize = FALSE),
  "old data was stored optimized"
)
expect_error(
  write_vc(x = test_data[, -1], file = "test", root = root),
  "new data lacks old sorting variable"
)

expect_false(any(file.exists(git2rdata:::clean_data_path(root, "a/verbose"))))
expect_is(
  output <-
    write_vc(x = test_data, file = "a/verbose", root = root, optimize = FALSE),
  "character"
)
expect_true(all(file.exists(git2rdata:::clean_data_path(root, "a/verbose"))))
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
  output <- write_vc(test_na, file = "na", root = root),
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
expect_false(any(file.exists(git2rdata:::clean_data_path(root, "sorting"))))
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
  "old data has different variables"
)

yml <- file.path(root, "sorting.yml")
meta <- head(readLines(yml), -1)
writeLines(text = meta, con = yml)
expect_error(
  write_vc(test_data, file = "sorting", root = root, sorting = "test_factor"),
  "error in existing metadata"
)
