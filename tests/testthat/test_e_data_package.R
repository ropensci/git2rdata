test_that("datapackage", {
  root <- tempfile("datapackage")
  dir.create(root)
  write_vc(
    x = test_data, file = "human_readable", root = root, optimize = FALSE,
    sorting = "test_integer", digits = 4
  )
  expect_identical(
    data_package(path = root), file.path(root, "datapackage.json")
  )
  write_vc(
    x = test_data, file = "human_readable_meta", root = root, optimize = FALSE,
    sorting = "test_integer", digits = 4
  )
  update_metadata(
    file = "human_readable_meta", root = root, title = "Test title",
    description = "Test description", name = "test",
    field_description = c(
      test_integer = "Test integer", test_numeric = "Test numeric",
      test_character = "Test character", test_factor = "Test factor",
      test_logical = "Test logical", test_Date = "Test date",
      test_POSIXct = "Test POSIXct", test_ordered = "Test ordered"
    )
  )
  expect_identical(
    data_package(path = root), file.path(root, "datapackage.json")
  )

  human_meta <- read_vc("human_readable_meta", root = root)
  write_vc(human_meta, file = "rewrite", root = root)
  rewrite <- read_vc("rewrite", root = root)
  expect_identical(attributes(human_meta), attributes(rewrite))
  for (i in colnames(human_meta)) {
    expect_identical(attributes(human_meta[[i]]), attributes(rewrite[[i]]))
  }
})
