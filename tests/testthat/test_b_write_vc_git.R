context("write_vc() on a git-repository")
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
staged <- write_vc(test_data, file = "staged", root = root, stage = TRUE)
expect_equal(
  git2r::status(root),
  list(staged = names(staged), unstaged = list(), untracked = names(untracked)),
  check.attributes = FALSE
)
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
git2r::commit(root, "add data")

staged <- write_vc(
  head(test_data, ceiling(nrow(test_data) / 2)),
  file = "staged", root = root, stage = FALSE
)
expect_equal(
  git2r::status(root),
  list(staged = list(), unstaged = "staged.tsv", untracked = names(untracked)),
  check.attributes = FALSE
)
staged <- write_vc(
  head(test_data, ceiling(nrow(test_data) / 2)),
  file = "staged", root = root, stage = TRUE
)
expect_equal(
  git2r::status(root),
  list(staged = "staged.tsv", unstaged = list(), untracked = names(untracked)),
  check.attributes = FALSE
)
