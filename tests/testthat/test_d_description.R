test_that("description", {
  expect_error(
    update_metadata(
      file = "test", root = data.frame()
    ),
    "a 'root' of class data.frame is not supported"
  )

  root <- tempfile(pattern = "git2rdata-description")
  dir.create(root)

  expect_is(
    write_vc(
      x = test_data, file = "test.txt", root = root, sorting = "test_Date"
    ),
    "character"
  )

  expect_null(
    update_metadata(
      file = "test", root = root, field_description = c(
        test_character = "Some information", test_factor = "Some information",
        test_integer = "Some information"
      )
    )
  )

  expect_is({
      output <- read_vc("test", root = root)
    }, "git2rdata"
  )
  expect_true(assertthat::has_attr(output$test_character, "description"))
  expect_true(assertthat::has_attr(output$test_factor, "description"))
  expect_true(assertthat::has_attr(output$test_integer, "description"))
  expect_false(assertthat::has_attr(output$test_ordered, "description"))
  expect_false(assertthat::has_attr(output, "table name"))
  expect_false(assertthat::has_attr(output, "title"))
  expect_false(assertthat::has_attr(output, "description"))
  expect_output(print(output), "display_metadata")
  expect_output(summary(output), "display_metadata")
  expect_output(display_metadata(output, minimal = TRUE), "display_metadata")
  expect_output(display_metadata(output, minimal = FALSE), "Table name: NA")
  expect_output(display_metadata(output), "Table name: NA")

  root <- git2r::init(root)
  git2r::config(root, user.name = "Alice", user.email = "alice@example.org")
  writeLines("ignore.*\nforce.*", file.path(git2r::workdir(root), ".gitignore"))
  git2r::add(root, ".gitignore")
  commit(root, "initial commit")

  expect_null(
    update_metadata(
      file = "test", root = root, name = "my_table", title = "My Table",
      description = "This is description for the unit tests",
      field_description = c(test_character = NA, test_factor = "")
    )
  )
  expect_is({
      output <- read_vc("test", root = root)
    }, "git2rdata"
  )
  expect_false(assertthat::has_attr(output$test_character, "description"))
  expect_false(assertthat::has_attr(output$test_factor, "description"))
  expect_true(assertthat::has_attr(output$test_integer, "description"))
  expect_true(assertthat::has_attr(output, "table name"))
  expect_true(assertthat::has_attr(output, "title"))
  expect_true(assertthat::has_attr(output, "description"))
  expect_output(print(output), "display_metadata")
  expect_output(summary(output), "display_metadata")
  expect_output(display_metadata(output), "Table name: my_table")
})
