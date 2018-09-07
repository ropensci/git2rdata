context("write_vc() and read_vc() on a git-repository")
root <- tempfile(pattern = "git2rdata-")
dir.create(root)
root <- git2r::init(root)
writeLines("ignore.*", file.path(workdir(root), ".gitignore"))
git2r::add(root, ".gitignore")
git2r::commit(root, "initial commit")
untracked <- write_vc(test_data, file = "untracked", root = root)
expect_equal(
  git2r::status(root),
  list(staged = list(), unstaged = list(), untracked = names(untracked)),
  check.attributes = FALSE
)
expect_equal(read_vc("untracked", root), sorted_test_data)

staged <- write_vc(test_data, file = "staged", root = root, stage = TRUE)
expect_equal(
  git2r::status(root),
  list(staged = names(staged), unstaged = list(), untracked = names(untracked)),
  check.attributes = FALSE
)
expect_equal(read_vc("staged", root), sorted_test_data)

ignored <- write_vc(test_data, file = "ignore", root = root, stage = TRUE)
expect_equal(
  git2r::status(root),
  list(staged = names(staged), unstaged = list(), untracked = names(untracked)),
  check.attributes = FALSE
)
expect_identical(
  list.files(workdir(root)),
  c(names(ignored), names(staged), names(untracked))
)
expect_equal(read_vc("ignore", root), sorted_test_data)

ignored <-
  write_vc(test_data, file = "ignore", root = root, stage = TRUE, force = TRUE)
expect_equal(
  git2r::status(root),
  list(
    staged = c(names(ignored), names(staged)),
    unstaged = list(),
    untracked = names(untracked)
  ),
  check.attributes = FALSE
)
expect_equal(read_vc("ignore", root), sorted_test_data)
git2r::commit(root, "add data")

staged <- write_vc(
  test_subset,
  file = "staged", root = root, stage = FALSE
)
expect_equal(
  git2r::status(root),
  list(staged = list(), unstaged = "staged.tsv", untracked = names(untracked)),
  check.attributes = FALSE
)
expect_equal(read_vc("staged", root), sorted_test_subset)

staged <- write_vc(
  test_subset,
  file = "staged", root = root, stage = TRUE
)
expect_equal(
  git2r::status(root),
  list(staged = "staged.tsv", unstaged = list(), untracked = names(untracked)),
  check.attributes = FALSE
)
expect_equal(read_vc("staged", root), sorted_test_subset)
