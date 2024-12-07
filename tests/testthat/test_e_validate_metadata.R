context("validate metadata when reading")
root <- tempfile("git2rdata-check-meta")
dir.create(root)
test_that("read_vc() checks hash", {
  file <- basename(tempfile(tmpdir = root))
  junk <- write_vc(
    test_data, file = file, root = root, sorting = "test_Date", digits = 6
  )
  correct_yaml <- yaml::read_yaml(file.path(root, junk[2]))
  junk_yaml <- correct_yaml
  junk_yaml[["test_Date"]] <- NULL
  yaml::write_yaml(junk_yaml, file.path(root, junk[2]))
  expect_error(
    read_vc(file = file, root = root),
    "Corrupt metadata, mismatching hash."
  )
  junk_yaml <- correct_yaml
  junk_yaml[["..generic"]][["hash"]] <- "zzz"
  yaml::write_yaml(junk_yaml, file.path(root, junk[2]))
  expect_error(
    read_vc(file = file, root = root),
    "Corrupt metadata, mismatching hash."
  )
  junk_yaml[["..generic"]][["hash"]] <- NULL
  yaml::write_yaml(junk_yaml, file.path(root, junk[2]))
  expect_error(
    read_vc(file = file, root = root),
    "Corrupt metadata, no hash found."
  )
  junk_yaml <- correct_yaml
  junk_yaml[["..generic"]][["data_hash"]] <- NULL
  yaml::write_yaml(junk_yaml, file.path(root, junk[2]))
  expect_error(read_vc(file = file, root = root),
               "Corrupt metadata, no data hash found.")
})

test_that("read_vc() handles changes in rawdata", {
  file <- basename(tempfile(tmpdir = root))
  junk <- write_vc(
    test_data, file = file, root = root, sorting = "test_Date", digits = 6
  )
  correct_data <- readLines(file.path(root, junk[1]), encoding = "UTF-8")
  correct_header <- strsplit(correct_data[1], "\t")[[1]]
  junk_data <- correct_data
  junk_data[1] <- paste(correct_header[-1], collapse = "\t")
  writeLines(junk_data, file.path(root, junk[1]))
  expect_error(read_vc(file = file, root = root),
               "Corrupt data, incorrect header.")
  writeLines(correct_data[1:2], file.path(root, junk[1]))
  expect_warning(
    read_vc(file = file, root = root),
    "Mismatching data hash. Data altered outside of git2rdata."
  )
})

test_that("write_vc() checks existing metadata", {
  file <- basename(tempfile(tmpdir = root))
  junk <- write_vc(
    test_data, file = file, root = root, sorting = "test_Date", digits = 6
  )
  correct_yaml <- yaml::read_yaml(file.path(root, junk[2]))
  junk_yaml <- correct_yaml
  junk_yaml[["test_Date"]] <- NULL
  yaml::write_yaml(junk_yaml, file.path(root, junk[2]))
  expect_error(
    write_vc(test_data, file = file, root = root, sorting = "test_Date"),
    "Existing metadata file is invalid"
  )
})
