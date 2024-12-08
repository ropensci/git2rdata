test_that("write_vc() and read_vc() on a file system", {
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
  expect_error(
    git2rdata:::clean_data_path(root, file.path("..", "wrong_location")),
    "file should not contain '..'"
  )
  expect_error(
    git2rdata:::clean_data_path(root, file.path(".", "..", "wrong_location")),
    "file should not contain '..'"
  )
  expect_is(
    output <- write_vc(
      x = test_data, file = "test.txt", root = root, sorting = "test_Date",
      digits = 6
    ),
    "character"
  )
  expect_identical(length(output), 2L)
  expect_identical(unname(output), c("test.tsv", "test.yml"))
  expect_true(all(file.exists(git2rdata:::clean_data_path(root, "test"))))
  expect_equal(
    stored <- read_vc(file = "test.xls", root = root), sorted_test_data_6,
    check.attributes = FALSE
  )
  for (i in colnames(stored)) {
    expect_equal(
      stored[[i]], sorted_test_data_6[[i]], label = paste0("stored$", i),
      expected.label = paste0("sorted_test_data$", i)
    )
  }
  expect_identical(
    write_vc(x = test_data, file = "test.xls", root = root), output
  )
  expect_error(
    write_vc(
      data.frame(junk = 5), file = "test", root = root, sorting = "junk",
      digits = 6
    ),
    "The data was not overwritten because of the issues below."
  )
  expect_error(
    write_vc(
      x = test_data, file = "test", root = root, optimize = FALSE, digits = 6
    ),
    "New data is verbose, whereas old data was optimized"
  )
  expect_warning(
    write_vc(x = test_data, file = "test", root = root, optimize = FALSE,
             strict = FALSE),
    "New data is verbose, whereas old data was optimized"
  )
  expect_error(
    write_vc(
      x = test_data[, colnames(test_data) != "test_Date"],
      file = "test", root = root
    ),
    "All sorting variables must be available"
  )

  expect_false(
    any(
      file.exists(git2rdata:::clean_data_path(root, file.path("a", "verbose")))
    )
  )
  expect_is(
    output <- write_vc(
      x = test_data, file = file.path("a", "verbose"), root = root,
      sorting = "test_Date", optimize = FALSE, digits = 6
    ),
    "character"
  )
  expect_true(
    all(file.exists(file.path(root, "a", c("verbose.csv", "verbose.yml"))))
  )
  expect_equal(
    stored <- read_vc(file = file.path("a", "verbose"), root = root),
    sorted_test_data_6, check.attributes = FALSE
  )
  for (i in colnames(stored)) {
    expect_equal(
      stored[[i]], sorted_test_data_6[[i]], label = paste0("stored$", i),
      expected.label = paste0("sorted_test_data$", i)
    )
  }
  expect_error(
    write_vc(x = test_data, file = file.path("a", "verbose"), root = root),
    "New data is optimized, whereas old data was verbose"
  )

  expect_is(
    output <- write_vc(
      test_na, file = "na", root = root, digits = 6,
      sorting = c("test_Date", "test_integer", "test_numeric")
    ),
    "character"
  )
  expect_equal(
    stored <- read_vc(file = "na", root = root),
    sorted_test_na, check.attributes = FALSE
  )
  for (i in colnames(stored)) {
    expect_equal(
      stored[[i]], sorted_test_na[[i]], label = paste0("stored$", i),
      expected.label = paste0("sorted_test_na$", i)
    )
  }

  expect_error(
    write_vc(test_data, file = "error", root = root, sorting = 1, digits = 6),
    "sorting is not a character vector"
  )
  expect_error(
    write_vc(
      test_data, file = "error", root = root, sorting = "junk", digits = 6
    ),
    "All sorting variables must be available"
  )
  expect_false(any(file.exists(git2rdata:::clean_data_path(root, "sorting"))))
  expect_warning(
    write_vc(test_data, file = "error", root = root, sorting = character(0)),
    "No sorting applied"
  )
  expect_warning(
    output <- write_vc(
      test_data, file = "sorting", root = root, sorting = "test_factor"
    ),
    "Sorting on 'test_factor' results in ties"
  )
  expect_is(output, "character")
  expect_true(all(file.exists(git2rdata:::clean_data_path(root, "sorting"))))
  expect_warning(
    write_vc(test_data, file = "sorting", root = root,
             sorting = c("test_factor", "test_Date"), strict = FALSE),
    "The sorting variables changed"
  )
  expect_error(
    suppressWarnings(
      write_vc(
        test_data, file = "sorting", root = root, sorting = "test_factor"
      )
    ),
    "The sorting variables changed"
  )
  test_changed <- test_data
  test_changed$junk <- test_changed$test_character
  expect_error(
    write_vc(test_changed, file = "sorting", root = root),
    "New data has a different number of variables"
  )
  test_changed$test_character <- NULL
  expect_error(
    write_vc(test_changed, file = "sorting", root = root), "New variables: junk"
  )
  test_changed <- test_data
  test_changed$test_character <- factor(test_changed$test_character)
  expect_error(
    write_vc(test_changed, file = "sorting", root = root),
    "Change in class: 'test_character' from character to factor"
  )
  expect_error(
    suppressWarnings(
      write_vc(
        test_data, file = "sorting", root = root, sorting = "test_logical"
      )
    ),
    "The sorting variables changed"
  )
  test_changed <- test_data
  test_changed$test_ordered <- factor(
    test_changed$test_ordered,
    levels = levels(test_changed$test_ordered),
    ordered = FALSE
  )
  expect_error(
    write_vc(test_changed, file = "sorting", root = root),
    "'test_ordered' changes from ordinal to nominal"
  )

  test_no <- test_data
  test_no$test_ordered <- NULL
  expect_is(
    output <- write_vc(
      x = test_no, file = "no_ordered", root = root, sorting = "test_Date",
      digits = 6
    ),
    "character"
  )
  sorted_test_no <- sorted_test_data
  sorted_test_no$test_ordered <- NULL
  sorted_test_no$test_numeric <- signif(sorted_test_no$test_numeric, 6)
  expect_equal(
    stored <- read_vc(file = "no_ordered", root = root), sorted_test_no,
    check.attributes = FALSE
  )
  for (i in colnames(stored)) {
    expect_equal(
      stored[[i]], sorted_test_no[[i]], label = paste0("stored$", i),
      expected.label = paste0("sorted_test_data$", i)
    )
  }
})

test_that(
  "meta() works on complex", {
    z <- complex(real = runif(10), imaginary = runif(10))
    expect_equal(mz <- meta(z), z, check.attributes = FALSE)
    expect_true(assertthat::has_attr(mz, "meta"))
    expect_equal(
      attr(mz, "meta"), list(class = "complex"), check.attributes = FALSE
    )
  }
)

test_that("user specified na strings work", {
  x <- data.frame(
    a = c(NA, "NA", "b"), b = factor(c("NA", NA, "d")), z = c(1:2, NA),
    y = c(pi, NA, Inf), stringsAsFactors = FALSE
  )
  root <- tempfile("na_string")
  dir.create(root)
  expect_error(
    write_vc(
      x, "test_na_string_verbose", root, "a", optimize = FALSE, digits = 6
    ),
    "one of the strings matches the NA string"
  )
  expect_is(
    fn <- write_vc(
      x, "test_na_string_verbose", root, "a", optimize = FALSE, na = "junk",
      digits = 6
    ),
    "character"
  )
  old_locale <- git2rdata:::set_c_locale()
  target <- x[order(x$a), ]
  target$y <- signif(target$y, 6)
  expect_equal(read_vc(fn[1], root), target, check.attributes = FALSE)
  git2rdata:::set_local_locale(old_locale)
  expect_identical(
    grep("junk", readLines(file.path(root, fn[1]), encoding = "UTF-8")), 2:4
  )
  expect_error(
    write_vc(
      x, "test_na_string_verbose", root, "a", optimize = FALSE, na = "different"
    ),
    "New data uses 'different' as NA string, whereas old data used 'junk'"
  )
  expect_is(
    fn <- write_vc(
      x, "test_na_string_optimize", root, "a", na = "junk", digits = 6
    ),
    "character"
  )
  old_locale <- git2rdata:::set_c_locale()
  expect_equal(read_vc(fn[1], root), target, check.attributes = FALSE)
  git2rdata:::set_local_locale(old_locale)
  expect_identical(
    grep("junk", readLines(file.path(root, fn[1]), encoding = "UTF-8")), 2:4
  )
})

test_that("write_vc() allows changes in factor levels", {
  x <- data.frame(
    test_factor = factor(c("a", "b")), stringsAsFactors = FALSE
  )
  root <- tempfile("factor_levels")
  dir.create(root)
  expect_is(
    fn <- write_vc(x, "factor_levels", root, sorting = "test_factor"),
    "character"
  )
  x$test_factor <- factor(x$test_factor, levels = c("b", "a"))
  expect_warning(
    write_vc(x, "factor_levels", root),
    "Same levels with a different order detected"
  )
  expect_warning(
    write_vc(x, "factor_levels", root, strict = FALSE),
    " New factor labels"
  )
  x$test_factor <- factor(x$test_factor, levels = c("a", "b", "c"))
  expect_error(
    write_vc(x, "factor_levels", root), "New factor labels for 'test_factor'"
  )
})

test_that("meta attributes are printed as yaml", {
  expect_output(
    print(suppressWarnings(attr(meta(test_data, digits = 6), "meta"))),
    "hash: [0-9a-f]{40}"
  )
  expect_output(
    print(attr(meta(test_data$test_factor), "meta")),
    "class: factor.*\nordered: no"
  )
})

test_that("digits works as expected", {
  x <- data.frame(
    a = c(exp(1), pi), b = c(1.23456789, 1.23456789),
    stringsAsFactors = FALSE
  )
  root <- tempfile("digits")
  dir.create(root)
  expect_warning(
    fn <- write_vc(x, "default", root, sorting = "a"),
    "`digits` was not set."
  )
  expect_equal(
    read_vc(fn[1], root), check.attributes = FALSE,
    signif(x, 6)
  )

  expect_is(
    fn <- write_vc(x, "digits", root, digits = 4, sorting = "a"),
    "character"
  )
  expect_equal(
    read_vc(fn[1], root), check.attributes = FALSE,
    signif(x, 4)
  )
  write_vc(x, "digits", root, digits = 6)
  expect_equal(
    read_vc(fn[1], root), check.attributes = FALSE,
    signif(x, 6)
  )

  expect_is(
    fn <- write_vc(x, "delta", root, digits = c(a = 4, b = 5), sorting = "a"),
    "character"
  )
  expect_equal(
    read_vc(fn[1], root), check.attributes = FALSE,
    data.frame(a = signif(x$a, 4), b = signif(x$b, 5))
  )
  expect_is(
    fn <- write_vc(x, "delta", root, digits = c(a = 5, b = 4)),
    "character"
  )
  expect_equal(
    read_vc(fn[1], root), check.attributes = FALSE,
    data.frame(a = signif(x$a, 5), b = signif(x$b, 4))
  )

  expect_error(
    write_vc(x, "faults", root, digits = c(4, 5), sorting = "a"),
    "`digits` must be either named"
  )
  expect_error(
    write_vc(x, "faults", root, digits = c(a = 4, b = NA), sorting = "a"),
    "`digits` must be a strict positive integer"
  )
  expect_error(
    write_vc(x, "faults", root, digits = c(a = 4, c = 5), sorting = "a"),
    "`digits` must contain all numeric variables"
  )
})
