context("write_vc() and read_vc() on a git-repository")
root <- tempfile(pattern = "git2rdata-")
dir.create(root)
root <- git2r::init(root)
git2r::config(root, user.name = "Alice", user.email = "alice@example.org")
writeLines("ignore.*", file.path(git2r::workdir(root), ".gitignore"))
git2r::add(root, ".gitignore")
commit(root, "initial commit")
untracked <- write_vc(
  test_data, file = "untracked", root = root, sorting = "test_Date"
)
expect_equal(
  status(root),
  list(staged = list(), unstaged = list(), untracked = names(untracked)),
  check.attributes = FALSE
)
expect_equal(
  stored <- read_vc(file = "untracked", root = root),
  sorted_test_data,
  check.attributes = FALSE
)
for (i in colnames(stored)) {
  expect_equal(
    stored[[i]],
    sorted_test_data[[i]],
    label = paste0("stored$", i),
    expected.label = paste0("sorted_test_data$", i)
  )
}

staged <- write_vc(
  test_data, file = "staged", root = root, sorting = "test_Date", stage = TRUE
)
expect_equal(
  status(root),
  list(staged = names(staged), unstaged = list(), untracked = names(untracked)),
  check.attributes = FALSE
)
expect_equal(
  stored <- read_vc(file = "staged", root = root),
  sorted_test_data,
  check.attributes = FALSE
)
for (i in colnames(stored)) {
  expect_equal(
    stored[[i]],
    sorted_test_data[[i]],
    label = paste0("stored$", i),
    expected.label = paste0("sorted_test_data$", i)
  )
}

ignored <- write_vc(
  test_data, file = "ignore", root = root, sorting = "test_Date", stage = TRUE
)
expect_equal(
  status(root),
  list(staged = names(staged), unstaged = list(), untracked = names(untracked)),
  check.attributes = FALSE
)
expect_identical(
  list.files(workdir(root)),
  c(names(ignored), names(staged), names(untracked))
)
expect_equal(
  stored <- read_vc(file = "ignore", root = root),
  sorted_test_data,
  check.attributes = FALSE
)
for (i in colnames(stored)) {
  expect_equal(
    stored[[i]],
    sorted_test_data[[i]],
    label = paste0("stored$", i),
    expected.label = paste0("sorted_test_data$", i)
  )
}

ignored <-
  write_vc(test_data, file = "ignore", root = root, stage = TRUE, force = TRUE)
expect_equal(
  status(root),
  list(
    staged = c(names(ignored), names(staged)),
    unstaged = list(),
    untracked = names(untracked)
  ),
  check.attributes = FALSE
)
expect_equal(
  stored <- read_vc(file = "ignore", root = root),
  sorted_test_data,
  check.attributes = FALSE
)
for (i in colnames(stored)) {
  expect_equal(
    stored[[i]],
    sorted_test_data[[i]],
    label = paste0("stored$", i),
    expected.label = paste0("sorted_test_data$", i)
  )
}
commit(root, "add data")

staged <- write_vc(
  test_subset,
  file = "staged", root = root, stage = FALSE
)
expect_equal(
  status(root),
  list(staged = list(), unstaged = "staged.tsv", untracked = names(untracked)),
  check.attributes = FALSE
)
expect_equal(
  stored <- read_vc(file = "staged", root = root),
  sorted_test_subset,
  check.attributes = FALSE
)
for (i in colnames(stored)) {
  expect_equal(
    stored[[i]],
    sorted_test_subset[[i]],
    label = paste0("stored$", i),
    expected.label = paste0("sorted_test_subset$", i)
  )
}

staged <- write_vc(
  test_subset,
  file = "staged", root = root, stage = TRUE
)
expect_equal(
  status(root),
  list(staged = "staged.tsv", unstaged = list(), untracked = names(untracked)),
  check.attributes = FALSE
)
expect_equal(
  stored <- read_vc(file = "staged", root = root),
  sorted_test_subset,
  check.attributes = FALSE
)
for (i in colnames(stored)) {
  expect_equal(
    stored[[i]],
    sorted_test_subset[[i]],
    label = paste0("stored$", i),
    expected.label = paste0("sorted_test_subset$", i)
  )
}
commit(root, "update data")

current <- list.files(workdir(root), recursive = TRUE)
expect_identical(
  rm_data(root = root, path = ".", type = "tsv"),
  c("ignore.tsv", "staged.tsv", "untracked.tsv")
)
expect_identical(
  list.files(workdir(root), recursive = TRUE),
  current[grep(".*\\.yml", current)]
)
expect_equal(
  status(root),
  list(
    staged = list(),
    unstaged = c("ignore.tsv", "staged.tsv"),
    untracked = "untracked.yml"
  ),
  check.attributes = FALSE
)

current <- list.files(workdir(root), recursive = TRUE)
expect_identical(
  rm_data(root = root, path = ".", type = "yml", stage = TRUE),
  c("ignore.yml", "staged.yml", "untracked.yml")
)
expect_identical(
  list.files(workdir(root), recursive = TRUE),
  character(0)
)
expect_equal(
  status(root),
  list(
    staged = c("ignore.yml", "staged.yml"),
    unstaged = c("ignore.tsv", "staged.tsv"),
    untracked = list()
  ),
  check.attributes = FALSE
)
