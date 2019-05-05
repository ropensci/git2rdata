context("validate metadata when reading")
root <- tempfile("git2rdata-check-meta(.*)")
dir.create(root)
test_that("read_vc() checks hash", {
  file <- basename(tempfile(tmpdir = root))
  junk <- write_vc(test_data, file = file, root = root, sorting = "test_Date")
  correct_yaml <- read_yaml(file.path(root, junk[2]))
  junk_yaml <- correct_yaml
  junk_yaml[["test_Date"]] <- NULL
  write_yaml(junk_yaml, file.path(root, junk[2]))
  expect_error(
    read_vc(file = file, root = root),
    "Corrupt metadata, mismatching hash."
  )
  junk_yaml <- correct_yaml
  junk_yaml[["..generic"]][["hash"]] <- "zzz"
  write_yaml(junk_yaml, file.path(root, junk[2]))
  expect_error(
    read_vc(file = file, root = root),
    "Corrupt metadata, mismatching hash."
  )
  junk_yaml[["..generic"]][["hash"]] <- NULL
  write_yaml(junk_yaml, file.path(root, junk[2]))
  expect_error(
    read_vc(file = file, root = root),
    "Corrupt metadata, no hash found."
  )
  junk_yaml <- correct_yaml
  junk_yaml[["..generic"]][["data_hash"]] <- NULL
  write_yaml(junk_yaml, file.path(root, junk[2]))
  expect_warning(
    read_vc(file = file, root = root),
    "Data hash missing."
  )
})

test_that("read_vc() handles changes in rawdata", {
  file <- basename(tempfile(tmpdir = root))
  junk <- write_vc(test_data, file = file, root = root, sorting = "test_Date")
  correct_data <- readLines(file.path(root, junk[1]))
  correct_header <- strsplit(correct_data[1], "\t")[[1]]
  junk_data <- correct_data
  junk_data[1] <- paste(correct_header[-1], collapse = "\t")
  writeLines(junk_data, file.path(root, junk[1]))
  expect_error(
    read_vc(file = file, root = root),
    "Corrupt data, incorrect header."
  )
  writeLines(correct_data[1:2], file.path(root, junk[1]))
  expect_warning(
    read_vc(file = file, root = root),
    "Data hash mismatch."
  )
})

file.remove(list.files(root, recursive = TRUE, full.names = TRUE))
