test_that("write_vc() handles the split_by argument", {
  root <- tempfile(pattern = "git2rdata-split-by")
  dir.create(root)

  expect_warning(
    write_vc(
      test_data, file = "unsorted", root = root, split_by = "test_factor"
    ),
    "No sorting applied."
  )
  expect_is({
    z <- read_vc("unsorted", root)
    },
    "data.frame"
  )
  expect_equal(
    z[order(z$test_numeric), ],
    sorted_test_data_6[order(sorted_test_data_6$test_numeric), ],
    check.attributes = FALSE
  )

  expect_is({
    sorted_file <- write_vc(
      test_data, file = "sorted", root = root, digits = 6,
      sorting = "test_Date", split_by = "test_factor"
    )
  },
    "character"
  )

  expect_is({
    z <- read_vc(sorted_file[1], root)
    },
    "data.frame"
  )
  expect_equal(
    z,
    sorted_test_data_6[
      order(sorted_test_data_6$test_factor, sorted_test_data_6$test_Date),
    ],
    check.attributes = FALSE
  )

  expect_error(
    write_vc(
      test_data, file = "sorted", root = root, split_by = character(0),
      digits = 6
    ),
    "The split_by variables changed."
  )
  expect_warning(
    write_vc(
      test_data, file = "sorted", root = root, split_by = character(0),
      strict = FALSE
    ),
    "The split_by variables changed."
  )
  expect_error(
    write_vc(
      test_data, file = "sorted", root = root, split_by = "test_factor"
    ),
    "The split_by variables changed."
  )
  expect_warning(
    write_vc(
      test_data, file = "sorted", root = root, split_by = "test_factor",
      strict = FALSE
    ),
    "The split_by variables changed."
  )

  data_file <- list.files(
    file.path(root, sorted_file[1]), pattern = "[[:xdigit:]]{20}",
    full.names = TRUE
  )
  data_file <- sample(data_file, 1)
  raw_data <- readLines(data_file)
  writeLines(raw_data[-1], data_file)
  expect_warning(
    is_git2rdata("sorted", root, "warning"),
    "Corrupt data, incorrect header"
  )
  expect_error(
    is_git2rdata("sorted", root, "error"),
    "Corrupt data, incorrect header"
  )
  expect_false(
    suppressWarnings(is_git2rdata("sorted", root, "warning")),
    "Corrupt data, incorrect header"
  )

  index_file <- file.path(root, sorted_file[1], "index.tsv")
  index <- readLines(index_file)
  writeLines(index[-1], index_file)
  expect_warning(
    is_git2rdata("sorted", root, "warning"),
    "Corrupt data, incorrect header in index.tsv"
  )
  expect_error(
    is_git2rdata("sorted", root, "error"),
    "Corrupt data, incorrect header in index.tsv"
  )
  expect_false(
    suppressWarnings(is_git2rdata("sorted", root, "warning")),
    "Corrupt data, incorrect header in index.tsv"
  )
})
