context("recent_commit")

# git timings don't handle subsecond changes
# therefore Sys.sleep(subsecond) is added before each commit
subsecond <- 1.2

expect_error(recent_commit(file = "junk", root = NULL),
             "a 'root' of class NULL is not supported")

root <- tempfile(pattern = "git2rdata-recent")
dir.create(root)

root <- git2r::init(root)
git2r::config(root, user.name = "Alice", user.email = "alice@example.org")

write_vc(
  test_data[1:2, ], file = "test1", root = root, stage = TRUE,
  sorting = "test_Date", digits = 6
)
commit_1 <- commit(root, "initial commit")

write_vc(
  test_data[3:4, ], file = file.path("junk", "test1"), root = root,
  stage = TRUE, sorting = "test_Date", digits = 6
)
commit_2 <- commit(root, "second file")

write_vc(
  test_data[5:6, ], file = "test1", root = root, stage = TRUE,
  sorting = "test_Date"
)
Sys.sleep(subsecond)
commit_3 <- commit(root, "update first file")

write_vc(
  test_data[7:8, ], file = "test3", root = root, stage = TRUE,
  sorting = "test_Date", digits = 6
)
Sys.sleep(subsecond)
commit_4 <- commit(root, "add third file")

write_vc(
  test_data[9:10, ], file = "test3", root = root, stage = TRUE,
  sorting = "test_Date"
)
commit_5 <- commit(root, "update third file")

expect_identical(
  recent_commit(file = "test1.tsv", root),
  data.frame(
    commit = commit_3$sha,
    author = commit_3$author$name,
    when = as.POSIXct(commit_3$author$when),
    stringsAsFactors = FALSE
  )
)
expect_identical(
  recent_commit(file = file.path("junk", "test1"), root, data = TRUE),
  data.frame(
    commit = commit_2$sha,
    author = commit_2$author$name,
    when = as.POSIXct(commit_2$author$when),
    stringsAsFactors = FALSE
  )
)

target <- file.path(git2r::workdir(root), "subsecond.txt")
while (TRUE) {
  writeLines(letters, con = target)
  git2r::add(root, target)
  cm_1 <- commit(root, "first subsecond")
  writeLines(LETTERS, con = target)
  git2r::add(root, target)
  cm_2 <- commit(root, "second subsecond")
  output <- suppressWarnings(
    recent_commit(file = "subsecond.txt", root)
  )
  if (nrow(output) > 1) {
    break
  }
}
expect_true(all(output$commit %in% c(cm_1$sha, cm_2$sha)))
expect_warning(
  recent_commit(file = "subsecond.txt", root),
  "More than one commit within the same second"
)
