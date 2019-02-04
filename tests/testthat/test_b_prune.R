context("prune_tsv & prune_yml")

expect_error(prune_tsv(root = 1), "a 'root' of class numeric is not supported")
expect_error(prune_yml(root = 1), "a 'root' of class numeric is not supported")

root <- tempfile(pattern = "git2rdata-")
expect_error(prune_tsv(root), root)
expect_error(prune_yml(root), root)
dir.create(root)
expect_null(prune_tsv(root, path = "junk"))
expect_null(prune_yml(root, path = "junk"))
write_vc(test_data, file = "test", root = root, sorting = "test_Date")
write_vc(
  test_data, file = "a/verbose", root = root, sorting = "test_Date",
  optimize = FALSE
)

current <- list.files(root, recursive = TRUE)
expect_identical(prune_tsv(root = root, path = "a"), "a/verbose.tsv")
expect_identical(
  list.files(root, recursive = TRUE),
  current[-grep("^.*/.*\\.tsv", current)]
)

current <- list.files(root, recursive = TRUE)
expect_identical(prune_yml(root = root, path = "."), "a/verbose.yml")
expect_identical(
  list.files(root, recursive = TRUE),
  current[-grep("^.*/.*", current)]
)

file.remove(file.path(root, "test.yml"))
current <- list.files(root, recursive = TRUE)
expect_identical(prune_tsv(root, path = "."), character(0))
expect_identical(list.files(root, recursive = TRUE), current)
file.remove(file.path(root, "test.tsv"))

old_wd <- getwd()
setwd(tempdir(check = TRUE))
write_vc(test_data, file = "test", sorting = "test_Date")
current <- list.files(".", recursive = TRUE, pattern = c("\\.(tsv|yml)$"))
expect_identical(prune_tsv(path = ".", recursive = FALSE), "test.tsv")
expect_identical(prune_yml(path = ".", recursive = FALSE), "test.yml")
expect_identical(
  list.files(".", recursive = TRUE),
  character(0)
)
setwd(old_wd)
