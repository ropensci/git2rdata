test_that("rm_data & prune_meta", {
  expect_error(rm_data(root = 1), "a 'root' of class numeric is not supported")
  expect_error(
    prune_meta(root = 1), "a 'root' of class numeric is not supported"
  )
  expect_error(
    list_data(root = 1), "a 'root' of class numeric is not supported"
  )

  root <- tempfile(pattern = "git2rdata-prune")
  root <- normalizePath(root, winslash = "/", mustWork = FALSE)
  expect_error(rm_data(root, "."), root)
  expect_error(prune_meta(root), root)
  dir.create(root)
  expect_null(prune_meta(root, path = "junk"))
  write_vc(
    test_data, file = "test", root = root, sorting = "test_Date",
    digits = 6
  )
  write_vc(
    test_data, file = file.path("a", "verbose"), root = root,
    sorting = "test_Date", optimize = FALSE, digits = 6
  )

  current <- list.files(root, recursive = TRUE)
  expect_identical(
    rm_data(root = root, path = "a"), file.path("a", "verbose.csv")
  )
  expect_identical(
    list.files(root, recursive = TRUE),
    current[-grep("^.*/.*\\.csv", current)]
  )

  current <- list.files(root, recursive = TRUE)
  expect_identical(
    prune_meta(root = root, path = "."), file.path("a", "verbose.yml")
  )
  expect_identical(
    list.files(root, recursive = TRUE),
    current[-grep("^.*/.*", current)]
  )

  file.remove(file.path(root, "test.yml"))
  current <- list.files(root, recursive = TRUE)
  expect_identical(rm_data(root, path = "."), character(0))
  expect_identical(list.files(root, recursive = TRUE), current)

  write_vc(
    test_data, file = "test1", root = root, sorting = "test_Date", digits = 6
  )
  junk <- write_vc(
    test_data, file = "test2", root = root, sorting = "test_Date", digits = 6
  )
  write_vc(
    test_data, file = file.path("a", "test2"), root = root,
    sorting = "test_Date", digits = 6
  )
  meta_data <- yaml::read_yaml(file.path(root, junk[2]))
  meta_data[["..generic"]] <- NULL
  yaml::write_yaml(meta_data, file = file.path(root, junk[2]))
  yaml::write_yaml(meta_data, file = file.path(root, "a", junk[2]))
  expect_warning(
    list_data(root = root, path = ".", recursive = FALSE),
    "Invalid metadata files found.*:\ntest2"
  )
  expect_warning(
    list_data(root = root, path = ".", recursive = TRUE),
    "Invalid metadata files found.*:\na/test2\ntest2"
  )
  current <- list.files(root, recursive = TRUE)
  expect_warning(
    rm_data(root = root, path = "."),
    "Invalid metadata files found.*:\na/test2\ntest2"
  )
  expect_identical(current[current != "test1.tsv"],
                   list.files(root, recursive = TRUE))
  file.remove(file.path(root, "test2.tsv"))
  current <- list.files(root, recursive = TRUE)
  expect_warning(
    prune_meta(root = root, path = "."),
    "Invalid metadata files found.*:\ntest2"
  )
  expect_identical(current[current != "test1.yml"],
                   list.files(root, recursive = TRUE))
})
