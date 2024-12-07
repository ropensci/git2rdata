test_that("write_vc() and read_vc() on a git-repository", {
root <- tempfile(pattern = "git2rdata-git")
dir.create(root)
root <- git2r::init(root)
git2r::config(root, user.name = "Alice", user.email = "alice@example.org")
writeLines("ignore.*\nforce.*", file.path(git2r::workdir(root), ".gitignore"))
git2r::add(root, ".gitignore")
commit(root, "initial commit")
expect_identical(rm_data(root, "."), character(0))
untracked <- write_vc(
  test_data, file = "untracked", root = root, sorting = "test_Date", digits = 6
)
expect_equal(
  status(root, ignored = TRUE),
  list(
    staged = list(), unstaged = list(), untracked = unname(untracked),
    ignored = list()
  ),
  check.attributes = FALSE
)
expect_equal(
  stored <- read_vc(file = "untracked", root = root), sorted_test_data_6,
  check.attributes = FALSE
)
for (i in colnames(stored)) {
  expect_equal(
    stored[[i]], sorted_test_data_6[[i]], label = paste0("stored$", i),
    expected.label = paste0("sorted_test_data$", i)
  )
}

staged <- write_vc(
  test_data, file = "staged", root = root, sorting = "test_Date", stage = TRUE,
  digits = 6
)
expect_equal(
  status(root, ignored = TRUE),
  list(
    staged = unname(staged), unstaged = list(), untracked = unname(untracked),
    ignored = list()
  ),
  check.attributes = FALSE
)
expect_equal(
  stored <- read_vc(file = "staged", root = root), sorted_test_data_6,
  check.attributes = FALSE
)
for (i in colnames(stored)) {
  expect_equal(
    stored[[i]], sorted_test_data_6[[i]], label = paste0("stored$", i),
    expected.label = paste0("sorted_test_data$", i)
  )
}

ignored <- write_vc(
  test_data, file = "ignore", root = root, sorting = "test_Date", stage = TRUE,
  digits = 6
)
expect_equal(
  status(root, ignored = TRUE),
  list(
    staged = unname(staged), unstaged = list(), untracked = unname(untracked),
    ignored = unname(ignored)
  ),
  check.attributes = FALSE
)
expect_equal(
  stored <- read_vc(file = "ignore", root = root), sorted_test_data_6,
  check.attributes = FALSE
)
for (i in colnames(stored)) {
  expect_equal(
    stored[[i]], sorted_test_data_6[[i]], label = paste0("stored$", i),
    expected.label = paste0("sorted_test_data$", i)
  )
}

forced <- write_vc(
  test_data, file = file.path("forced", "force"), root = root, digits = 6,
  sorting = "test_Date", stage = TRUE, force = TRUE
)
expect_equal(
  status(root, ignored = TRUE),
  list(
    staged = c(unname(forced), unname(staged)),
    unstaged = list(),
    untracked = unname(untracked),
    ignored = unname(ignored)
  ),
  check.attributes = FALSE
)
expect_equal(
  stored <- read_vc(file = file.path("forced", "force"), root = root),
  sorted_test_data_6, check.attributes = FALSE
)
for (i in colnames(stored)) {
  expect_equal(
    stored[[i]], sorted_test_data_6[[i]], label = paste0("stored$", i),
    expected.label = paste0("sorted_test_data$", i)
  )
}
commit(root, "add data")

staged <- write_vc(
  test_subset, file = "staged", root = root, stage = FALSE, digits = 6
)
expect_equal(
  status(root, ignored = TRUE),
  list(
    staged = list(), unstaged = c("staged.tsv", "staged.yml"),
    untracked = unname(untracked), ignored = unname(ignored)
  ),
  check.attributes = FALSE
)
expect_equal(
  stored <- read_vc(file = "staged", root = root), sorted_test_subset_6,
  check.attributes = FALSE
)
for (i in colnames(stored)) {
  expect_equal(
    stored[[i]], sorted_test_subset_6[[i]], label = paste0("stored$", i),
    expected.label = paste0("sorted_test_subset$", i)
  )
}

staged <- write_vc(
  test_subset, file = "staged", root = root, stage = TRUE, digits = 6
)
expect_equal(
  status(root, ignored = TRUE),
  list(
    staged = c("staged.tsv", "staged.yml"), unstaged = list(),
    untracked = unname(untracked), ignored = unname(ignored)
  ),
  check.attributes = FALSE
)
expect_equal(
  stored <- read_vc(file = "staged", root = root), sorted_test_subset_6,
  check.attributes = FALSE
)
for (i in colnames(stored)) {
  expect_equal(
    stored[[i]], sorted_test_subset_6[[i]], label = paste0("stored$", i),
    expected.label = paste0("sorted_test_subset$", i)
  )
}
commit(root, "update data")

expect_null(prune_meta(root, path = "junk"))

staged <- write_vc(
  test_data, file = "staged", root = root, stage = TRUE, digits = 6
)
current <- list.files(git2r::workdir(root), recursive = TRUE)
expect_identical(
  rm_data(root = root, path = "."), file.path("forced", "force.tsv")
)
expect_identical(
  current[!current %in% list.files(git2r::workdir(root), recursive = TRUE)],
  file.path("forced", "force.tsv")
)
expect_error(
  prune_meta(root = root, path = ".", stage = TRUE),
"cannot remove and stage metadata in combination with removed but unstaged data"
)
expect_identical(
  current[!current %in% list.files(git2r::workdir(root), recursive = TRUE)],
  file.path("forced", "force.tsv")
)
expect_null(rm_data(root, path = "."))
expect_identical(
  prune_meta(root = root, path = ".", stage = FALSE),
  file.path("forced", "force.yml")
)
expect_identical(
  current[!current %in% list.files(git2r::workdir(root), recursive = TRUE)],
  file.path("forced", c("force.tsv", "force.yml"))
)
expect_null(prune_meta(root, path = "."))
git2r::reset(git2r::last_commit(root), reset_type = "hard", path = ".")

staged <- write_vc(
  test_data, file = "staged", root = root, stage = TRUE
)
expect_identical(
  rm_data(root = root, path = ".", type = "m"),
  c(file.path("forced", "force.tsv"), "staged.tsv")
)
expect_identical(
  current[!current %in% list.files(git2r::workdir(root), recursive = TRUE)],
  c(file.path("forced", "force.tsv"), "staged.tsv")
)
expect_warning(
  removed <- prune_meta(root = root, path = ".", stage = FALSE),
  "data removed and staged, metadata removed but unstaged"
)
expect_identical(removed, c(file.path("forced", "force.yml"), "staged.yml"))
expect_identical(
  current[!current %in% list.files(git2r::workdir(root), recursive = TRUE)],
  c(
    file.path("forced", c("force.tsv", "force.yml")), "staged.tsv", "staged.yml"
  )
)
git2r::reset(git2r::last_commit(root), reset_type = "hard", path = ".")

staged <- write_vc(
  test_data, file = "staged", root = root, stage = TRUE
)
expect_identical(
  rm_data(root = root, path = ".", type = "i", stage = TRUE),
  c(file.path("forced", "force.tsv"), "ignore.tsv", "staged.tsv")
)
expect_identical(
  current[!current %in% list.files(git2r::workdir(root), recursive = TRUE)],
  c(file.path("forced", "force.tsv"), "ignore.tsv", "staged.tsv")
)
expect_identical(
  prune_meta(root = root, path = ".", stage = TRUE),
  c(file.path("forced", "force.yml"), "ignore.yml", "staged.yml")
)
expect_identical(
  current[!current %in% list.files(git2r::workdir(root), recursive = TRUE)],
  c(
    file.path("forced", c("force.tsv", "force.yml")), "ignore.tsv",
    "ignore.yml", "staged.tsv", "staged.yml"
  )
)
git2r::reset(git2r::last_commit(root), reset_type = "hard", path = ".")

ignored <- write_vc(
  test_data, file = "ignore", root = root, sorting = "test_Date", stage = TRUE,
  digits = 6
)
staged <- write_vc(test_data, file = "staged", root = root, stage = TRUE)
expect_identical(
  rm_data(root = root, path = ".", type = "all", stage = TRUE),
  c(
    file.path("forced", "force.tsv"), "ignore.tsv", "staged.tsv",
    "untracked.tsv"
  )
)
expect_identical(
  current[!current %in% list.files(git2r::workdir(root), recursive = TRUE)],
  c(
    file.path("forced", "force.tsv"), "ignore.tsv", "staged.tsv",
    "untracked.tsv"
  )
)
expect_identical(
  prune_meta(root = root, path = ".", stage = TRUE),
  c(
    file.path("forced", "force.yml"), "ignore.yml", "staged.yml",
    "untracked.yml"
  )
)
expect_identical(
  current[!current %in% list.files(git2r::workdir(root), recursive = TRUE)],
  c(
    file.path("forced", c("force.tsv", "force.yml")), "ignore.tsv",
    "ignore.yml", "staged.tsv", "staged.yml", "untracked.tsv", "untracked.yml"
  )
)
git2r::reset(git2r::last_commit(root), reset_type = "hard", path = ".")
})
