context("write_vc() and read_vc() on a file system")
expect_error(meta("NA"), "one of the strings matches the NA string")
expect_error(meta("NA", na = "abc def"), "na contains whitespace characters")
expect_error(meta("NA", na = "abc\tdef"), "na contains whitespace characters")
expect_error(meta("NA", na = "abc\ndef"), "na contains whitespace characters")
expect_error(
  meta(factor("NA"), optimize = FALSE),
  "one of the levels matches the NA string"
)
expect_error(write_vc(root = 1), "a 'root' of class numeric is not supported")
expect_error(read_vc(root = 1), "a 'root' of class numeric is not supported")
root <- tempfile(pattern = "git2rdata-basic")
dir.create(root)
expect_false(any(file.exists(git2rdata:::clean_data_path(root, "test"))))
expect_is(
  output <- write_vc(
    x = test_data, file = "test.txt", root = root, sorting = "test_Date"
  ),
  "character"
)
expect_identical(length(output), 2L)
expect_identical(unname(output), c("test.tsv", "test.yml"))
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
  write_vc(data.frame(junk = 5), file = "test", root = root, sorting = "junk"),
"new data uses different variables for sorting
new data has a different number of variables
new variables: junk
deleted variables: test_character, test_factor, test_ordered, test_integer"
)
expect_error(
  write_vc(x = test_data, file = "test", root = root, optimize = FALSE),
  "new data is verbose, whereas old data was optimized"
)
expect_warning(
  write_vc(x = test_data, file = "test", root = root, optimize = FALSE,
           strict = FALSE),
  "new data is verbose, whereas old data was optimized"
)
expect_error(
  write_vc(
    x = test_data[, colnames(test_data) != "test_Date"],
    file = "test", root = root
  ),
  "all sorting variables must be available"
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
  "new data is optimized, whereas old data was verbose"
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
  write_vc(test_data, file = "error", root = root, sorting = "junk"),
  "all sorting variables must be available"
)
expect_false(any(file.exists(git2rdata:::clean_data_path(root, "sorting"))))
expect_warning(
  output <-
    write_vc(test_data, file = "sorting", root = root, sorting = "test_factor"),
  "sorting results in ties"
)
expect_is(output, "character")
expect_true(all(file.exists(git2rdata:::clean_data_path(root, "sorting"))))
expect_warning(
  write_vc(test_data, file = "sorting", root = root,
           sorting = c("test_factor", "test_Date"), strict = FALSE),
  "new data uses more variables for sorting"
)
expect_error(
  suppressWarnings(
    write_vc(test_data, file = "sorting", root = root, sorting = "test_factor")
  ),
  "new data uses less variables for sorting"
)
test_changed <- test_data
test_changed$junk <- test_changed$test_character
expect_error(
  suppressWarnings(write_vc(test_changed, file = "sorting", root = root)),
  "new data has a different number of variables"
)
test_changed$test_character <- NULL
expect_error(
  suppressWarnings(write_vc(test_changed, file = "sorting", root = root)),
  "new variables: junk\ndeleted variables: test_character"
)
test_changed <- test_data
test_changed$test_character <- factor(test_changed$test_character)
expect_error(
  suppressWarnings(write_vc(test_changed, file = "sorting", root = root
  )),
  "change in class: test_character from character to factor"
)
expect_error(
  suppressWarnings(
    write_vc(test_data, file = "sorting", root = root, sorting = "test_logical")
  ),
  "new data uses different variables for sorting"
)
test_changed <- test_data
test_changed$test_ordered <- factor(
  test_changed$test_ordered,
  levels = levels(test_changed$test_ordered),
  ordered = FALSE
)
expect_error(
  suppressWarnings(write_vc(test_changed, file = "sorting", root = root
  )),
  "test_ordered changes from ordinal to nominal"
)

test_no <- test_data
test_no$test_ordered <- NULL
expect_is(
  output <- write_vc(
    x = test_no, file = "no_ordered", root = root, sorting = "test_Date"
  ),
  "character"
)
sorted_test_no <- sorted_test_data
sorted_test_no$test_ordered <- NULL
expect_equal(
  stored <- read_vc(file = "no_ordered", root = root),
  sorted_test_no,
  check.attributes = FALSE
)
for (i in colnames(stored)) {
  expect_equal(
    stored[[i]],
    sorted_test_no[[i]],
    label = paste0("stored$", i),
    expected.label = paste0("sorted_test_data$", i)
  )
}

file.remove(list.files(root, recursive = TRUE, full.names = TRUE))

test_that(
  "meta() works on complex", {
    z <- complex(real = runif(10), imaginary = runif(10))
    expect_equal(
      mz <- meta(z),
      z,
      check.attributes = FALSE
    )
    expect_true(assertthat::has_attr(mz, "meta"))
    expect_equal(attr(mz, "meta"), list(class = "complex"),
                 check.attributes = FALSE)
  }
)


test_that("user specified na strings work", {
  x <- data.frame(
    a = c(NA, "NA", "b"),
    b = factor(c("NA", NA, "d")),
    z = c(1:2, NA),
    y = c(pi, NA, Inf),
    stringsAsFactors = FALSE
  )
  root <- tempfile("na_string")
  dir.create(root)
  expect_error(
    suppressWarnings(
      write_vc(x, "test_na_string_verbose", root, "a", optimize = FALSE)
    ),
    "one of the strings matches the NA string"
  )
  expect_is(
    fn <- suppressWarnings(
      write_vc(x, "test_na_string_verbose", root, "a", optimize = FALSE,
               na = "junk")
    ),
    "character"
  )
  expect_equal(
    read_vc(fn[1], root),
    x[order(x$a), ],
    check.attributes = FALSE
  )
  expect_identical(
    grep("junk", readLines(file.path(root, fn[1]))),
    2:4
  )
  expect_error(
    suppressWarnings(
      write_vc(x, "test_na_string_verbose", root, "a", optimize = FALSE,
               na = "different")
    ),
    "new data uses 'different' as NA string, whereas old data used 'junk'"
  )
  expect_is(
    fn <- suppressWarnings(
      write_vc(x, "test_na_string_optimize", root, "a", na = "junk")
    ),
    "character"
  )
  expect_equal(
    read_vc(fn[1], root),
    x[order(x$a), ],
    check.attributes = FALSE
  )
  expect_identical(
    grep("junk", readLines(file.path(root, fn[1]))),
    2:4
  )
})

test_that("write_vc() allows changes in factor levels", {
  x <- data.frame(
    test_factor = factor(c("a", "b")),
    stringsAsFactors = FALSE
  )
  root <- tempfile("factor_levels")
  dir.create(root)
  expect_is(
    fn <- write_vc(x, "factor_levels", root, sorting = "test_factor"),
    "character"
  )
  x$test_factor <- factor(x$test_factor, levels = c("a", "b", "c"))
  expect_error(
    write_vc(x, "factor_levels", root),
    "new factor labels for test_factor\nnew indices labels for test_factor"
  )
})

test_that("meta attributes are printed as yaml", {
  expect_output(print(suppressWarnings(attr(meta(test_data), "meta"))),
                "hash: d8b9851bcc840c6203c39f70c514803e7acb96d0")
  expect_output(print(attr(meta(test_data$test_factor), "meta")),
                "class: factor.*\nordered: no")
})
