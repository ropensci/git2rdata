context("rm_data")

root <- tempfile(pattern = "git2rdata-")
expect_error(rm_data(root), root)
dir.create(root)
expect_error(rm_data(root, path = "junk"), file.path(root, "junk"))
write_vc(test_data, file = "test", root = root)
write_vc(test_data, file = "a/verbose", root = root, optimize = FALSE)

current <- list.files(root, recursive = TRUE)
expect_true(rm_data(root = root, path = "a"))
expect_identical(
  list.files(root, recursive = TRUE),
  current[-grep("^a/.*\\.tsv", current)]
)

current <- list.files(root, recursive = TRUE)
expect_true(rm_data(root = root, path = ".", type = "both", recursive = FALSE))
expect_identical(
  list.files(root, recursive = TRUE),
  current <- current[grep("^.*/.*", current)]
)
write_vc(test_data, file = "test", root = root)

current <- list.files(root, recursive = TRUE)
expect_true(rm_data(root = root, path = ".", type = "yml"))
expect_identical(
  list.files(root, recursive = TRUE),
  current[-grep("^.*/.*", current)]
)
