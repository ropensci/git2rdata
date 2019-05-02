context("recent_commit")

# git timings don't handle subsecond changes
# therefore Sys.sleep(subsecond) is added before each commit
subsecond <- 1.2

root <- tempfile(pattern = "git2rdata-recent")
dir.create(root)
root <- git2r::init(root)
git2r::config(root, user.name = "Alice", user.email = "alice@example.org")

write_vc(
  test_data[1:2, ], file = "test1", root = root, stage = TRUE,
  sorting = "test_Date"
)
commit_1 <- commit(root, "initial commit")

write_vc(
  test_data[3:4, ], file = "junk/test1", root = root, stage = TRUE,
  sorting = "test_Date"
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
  sorting = "test_Date"
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
  recent_commit(file = "junk/test1", root, data = TRUE),
  data.frame(
    commit = commit_2$sha,
    author = commit_2$author$name,
    when = as.POSIXct(commit_2$author$when),
    stringsAsFactors = FALSE
  )
)

write_vc(
  test_data[11, ], file = "subsecond", root = root, stage = TRUE,
  sorting = "test_Date"
)
commit_6 <- commit(root, "first subsecond")
write_vc(
  test_data[13, ], file = "subsecond", root = root, stage = TRUE,
  sorting = "test_Date"
)
commit_7 <- commit(root, "second subsecond")
write_vc(
  test_data[15, ], file = "subsecond", root = root, stage = TRUE,
  sorting = "test_Date"
)
commit_8 <- commit(root, "third subsecond")
expect_warning(
  output <- recent_commit(file = "subsecond", root, data = TRUE),
  "Multiple commits within the same second"
)
expect_true(all(output$commit %in% c(commit_6$sha, commit_7$sha, commit_8$sha)))
