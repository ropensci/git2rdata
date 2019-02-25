context("rm_data & prune_meta")

expect_error(rm_data(root = 1), "a 'root' of class numeric is not supported")
expect_error(prune_meta(root = 1), "a 'root' of class numeric is not supported")

root <- tempfile(pattern = "git2rdata-")
root <- normalizePath(root, winslash = "/", mustWork = FALSE)
expect_error(rm_data(root, "."), root)
expect_error(prune_meta(root), root)
dir.create(root)
expect_null(prune_meta(root, path = "junk"))
write_vc(test_data, file = "test", root = root, sorting = "test_Date")
write_vc(
  test_data, file = "a/verbose", root = root, sorting = "test_Date",
  optimize = FALSE
)

current <- list.files(root, recursive = TRUE)
expect_identical(rm_data(root = root, path = "a"), "a/verbose.tsv")
expect_identical(
  list.files(root, recursive = TRUE),
  current[-grep("^.*/.*\\.tsv", current)]
)

current <- list.files(root, recursive = TRUE)
expect_identical(prune_meta(root = root, path = "."), "a/verbose.yml")
expect_identical(
  list.files(root, recursive = TRUE),
  current[-grep("^.*/.*", current)]
)

file.remove(file.path(root, "test.yml"))
current <- list.files(root, recursive = TRUE)
expect_identical(rm_data(root, path = "."), character(0))
expect_identical(list.files(root, recursive = TRUE), current)
file.remove(file.path(root, "test.tsv"))
