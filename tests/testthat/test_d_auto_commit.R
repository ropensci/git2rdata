context("autocommit changes")
# create test repository
origin_path <- tempfile(pattern = "git2r-")
connection <- tempfile(pattern = "git2rclone-")
dir.create(origin_path)
dir.create(connection)
repo_bare <- git2r::init(origin_path, bare = TRUE)
repo <- git2r::clone(origin_path, connection, progress = FALSE)
git2r::config(repo, user.name = "Alice", user.email = "alice@example.org")

write_vc(
  test_data, file = "test1", root = repo, sorting = "test_Date", stage = TRUE
)
init <- commit(repo, "inital")
push(repo, "origin", "refs/heads/master")

expect_identical(
  auto_commit(package = "git2rdata", repo = repo),
  init
)
write_vc(
  test_subset, file = "test1", root = repo, sorting = "test_Date", stage = TRUE
)
expect_is(
  cm <- auto_commit(package = "git2rdata", repo = repo),
  "git_commit"
)
expect_match(cm$message, "Scripted commit from git2rdata")

write_vc(test_data, file = "test1", root = repo, stage = TRUE)
expect_message(
  cm <- auto_commit(package = "git2rdata", repo = connection, push = TRUE),
  "Pushing changes to remote repository"
)
expect_identical(cm, git2r::last_commit(repo))

file.remove(list.files(origin_path, recursive = TRUE, full.names = TRUE))
write_vc(test_subset, file = "test1", root = repo, stage = TRUE)
expect_warning(
  cm <- auto_commit(package = "git2rdata", repo = connection, push = TRUE),
  "could not find repository from"
)
expect_identical(cm, git2r::last_commit(repo))

write_vc(test_data, file = "test1", root = repo, stage = TRUE)
file.remove(
  list.files(connection, recursive = TRUE, full.names = TRUE, all.files = TRUE)
)
expect_error(
  suppressWarnings(
    auto_commit(package = "git2rdata", repo = repo)
  ),
  "Invalid repository"
)
