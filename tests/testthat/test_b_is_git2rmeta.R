context("validate metadata")
root <- tempfile("git2rdata-is_git2rmeta")
dir.create(root)
test_that("is_git2rmeta checks root", {
  expect_error(is_git2rmeta(file = "junk", root = 1),
               "a 'root' of class numeric is not supported")
  expect_error(is_git2rdata(file = "junk", root = 1),
               "a 'root' of class numeric is not supported")
})

test_that("is_git2rmeta checks metadata", {
  expect_false(is_git2rmeta(file = "junk", root = root))
  expect_false(is_git2rdata(file = "junk", root = root))
  expect_error(is_git2rmeta(file = "junk", root = root, message = "error"),
               "`git2rdata` object not found.")
  expect_warning(is_git2rmeta(file = "junk", root = root, message = "warning"),
                 "`git2rdata` object not found.")
  expect_false(
    suppressWarnings(
      is_git2rmeta(file = "junk", root = root, message = "warning")
    )
  )
  expect_warning(is_git2rdata(file = "junk", root = root, message = "warning"),
                 "`git2rdata` object not found.")
  expect_false(
    suppressWarnings(
      is_git2rdata(file = "junk", root = root, message = "warning")
    )
  )

  file <- basename(tempfile(tmpdir = root))
  junk <- write_vc(
    test_data, file = file, root = root, sorting = "test_Date", digits = 6
  )
  correct_yaml <- yaml::read_yaml(file.path(root, junk[2]))

  file.remove(file.path(root, junk[2]))
  expect_error(is_git2rmeta(file = file, root = root, message = "error"),
               "Metadata file missing.")
  expect_warning(is_git2rmeta(file = file, root = root, message = "warning"),
                 "Metadata file missing.")
  expect_false(is_git2rmeta(file = file, root = root))


  junk_yaml <- correct_yaml
  junk_yaml[["..generic"]] <- NULL
  yaml::write_yaml(junk_yaml, file.path(root, junk[2]))
  expect_false(is_git2rmeta(file = file, root = root))
  expect_error(is_git2rmeta(file = file, root = root, message = "error"),
               "No '..generic' element.")
  expect_warning(is_git2rmeta(file = file, root = root, message = "warning"),
               "No '..generic' element.")
  expect_false(
    suppressWarnings(
      is_git2rmeta(file = file, root = root, message = "warning")
    )
  )

  junk_yaml <- correct_yaml
  junk_yaml[["..generic"]][["hash"]] <- NULL
  yaml::write_yaml(junk_yaml, file.path(root, junk[2]))
  expect_false(is_git2rmeta(file = file, root = root))
  expect_error(is_git2rmeta(file = file, root = root, message = "error"),
               "Corrupt metadata, no hash found.")
  expect_warning(is_git2rmeta(file = file, root = root, message = "warning"),
               "Corrupt metadata, no hash found.")
  expect_false(
    suppressWarnings(
      is_git2rmeta(file = file, root = root, message = "warning")
    )
  )

  junk_yaml <- correct_yaml
  junk_yaml[["..generic"]][["git2rdata"]] <- NULL
  yaml::write_yaml(junk_yaml, file.path(root, junk[2]))
  expect_false(is_git2rmeta(file = file, root = root))
  expect_error(is_git2rmeta(file = file, root = root, message = "error"),
               "Data stored using an older version of `git2rdata`.")
  expect_warning(is_git2rmeta(file = file, root = root, message = "warning"),
               "Data stored using an older version of `git2rdata`.")
  expect_false(
    suppressWarnings(
      is_git2rmeta(file = file, root = root, message = "warning")
    )
  )

  junk_yaml <- correct_yaml
  junk_yaml[["..generic"]][["git2rdata"]] <- "0.0.3"
  yaml::write_yaml(junk_yaml, file.path(root, junk[2]))
  expect_false(is_git2rmeta(file = file, root = root))
  expect_error(is_git2rmeta(file = file, root = root, message = "error"),
               "Data stored using an older version of `git2rdata`.")
  expect_warning(is_git2rmeta(file = file, root = root, message = "warning"),
               "Data stored using an older version of `git2rdata`.")
  expect_false(
    suppressWarnings(
      is_git2rmeta(file = file, root = root, message = "warning")
    )
  )

  junk_yaml <- correct_yaml
  junk_yaml[["..generic"]][["data_hash"]] <- NULL
  yaml::write_yaml(junk_yaml, file.path(root, junk[2]))
  expect_false(is_git2rmeta(file = file, root = root))
  expect_error(is_git2rmeta(file = file, root = root, message = "error"),
               "Corrupt metadata, no data hash found.")
  expect_warning(is_git2rmeta(file = file, root = root, message = "warning"),
               "Corrupt metadata, no data hash found.")
  expect_false(
    suppressWarnings(
      is_git2rmeta(file = file, root = root, message = "warning")
    )
  )

  junk_yaml <- correct_yaml
  junk_yaml[["..generic"]][["hash"]] <- "zzz"
  yaml::write_yaml(junk_yaml, file.path(root, junk[2]))
  expect_false(is_git2rmeta(file = file, root = root))
  expect_error(is_git2rmeta(file = file, root = root, message = "error"),
               "Corrupt metadata, mismatching hash.")
  expect_warning(is_git2rmeta(file = file, root = root, message = "warning"),
               "Corrupt metadata, mismatching hash.")
  expect_false(
    suppressWarnings(
      is_git2rmeta(file = file, root = root, message = "warning")
    )
  )
})

test_that("is_git2rdata checks data", {
  file <- basename(tempfile(tmpdir = root))
  junk <- write_vc(
    test_data, file = file, root = root, sorting = "test_Date", digits = 6
  )
  correct_yaml <- yaml::read_yaml(file.path(root, junk[2]))
  yaml::write_yaml(correct_yaml, file.path(root, junk[2]))
  correct_data <- readLines(file.path(root, junk[1]), encoding = "UTF-8")
  junk_header <- correct_data
  junk_header[1] <- "junk"
  writeLines(junk_header, file.path(root, junk[1]))
  expect_false(is_git2rdata(file = file, root = root))
  expect_error(is_git2rdata(file = file, root = root, message = "error"),
               "Corrupt data, incorrect header.")
  expect_warning(is_git2rdata(file = file, root = root, message = "warning"),
                 "Corrupt data, incorrect header.")
  expect_false(
    suppressWarnings(
      is_git2rdata(file = file, root = root, message = "warning")
    )
  )

  file.remove(file.path(root, junk[1]))
  expect_false(is_git2rdata(file = file, root = root))
  expect_error(is_git2rdata(file = file, root = root, message = "error"),
               "Data file missing.")
  expect_warning(is_git2rdata(file = file, root = root, message = "warning"),
                 "Data file missing.")
  expect_false(
    suppressWarnings(
      is_git2rdata(file = file, root = root, message = "warning")
    )
  )
})

root <- git2r::init(root)
git2r::config(root, user.name = "Alice", user.email = "alice@example.org")

test_that("is_git2rmeta handle git repositories", {
  file <- basename(tempfile(tmpdir = git2r::workdir(root)))
  junk <- write_vc(
    test_data, file = file, root = root, sorting = "test_Date", digits = 6
  )
  expect_true(is_git2rmeta(file = file, root = root))
  expect_true(is_git2rdata(file = file, root = root))
})
