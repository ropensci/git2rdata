context("rm_data")

expect_error(rm_data(root = 1), "a 'root' of class numeric is not supported")

root <- tempfile(pattern = "git2rdata-")
expect_error(rm_data(root), root)
dir.create(root)
expect_null(rm_data(root, path = "junk"))
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
expect_identical(
  rm_data(root = root, path = ".", type = "both", recursive = FALSE),
  c("test.tsv", "test.yml")
)
expect_identical(
  list.files(root, recursive = TRUE),
  current[grep("^.*/.*", current)]
)

write_vc(test_data, file = "test", root = root, sorting = "test_Date")
current <- list.files(root, recursive = TRUE)
expect_identical(
  rm_data(root = root, path = ".", type = "yml"),
  "a/verbose.yml"
)
expect_identical(
  list.files(root, recursive = TRUE),
  current[-grep("^.*/.*", current)]
)

write_vc(test_data, file = "test", sorting = "test_Date")
current <- list.files(".", recursive = TRUE)
expect_identical(
  rm_data(type = "both", recursive = FALSE),
  c("test.tsv", "test.yml")
)
expect_identical(
  list.files(".", recursive = TRUE),
  current[grep("^.*/.*", current)]
)
