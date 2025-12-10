test_that("recent_commit", {
  expect_error(
    recent_commit(file = "junk", root = NULL),
    "a 'root' of class NULL is not supported"
  )

  root <- tempfile(pattern = "git2rdata-recent")
  dir.create(root)

  root <- git2r::init(root)
  git2r::config(root, user.name = "Alice", user.email = "alice@example.org")

  write_vc(
    test_data[1:2, ],
    file = "test1",
    root = root,
    stage = TRUE,
    sorting = "test_Date",
    digits = 6
  )
  commit_1 <- commit(root, "initial commit")

  write_vc(
    test_data[3:4, ],
    file = file.path("junk", "test1"),
    root = root,
    stage = TRUE,
    sorting = "test_Date",
    digits = 6
  )
  commit_2 <- commit(root, "second file")

  write_vc(
    test_data[5:6, ],
    file = "test1",
    root = root,
    stage = TRUE,
    sorting = "test_Date"
  )
  commit_3 <- commit(root, "update first file")

  write_vc(
    test_data[7:8, ],
    file = "test3",
    root = root,
    stage = TRUE,
    sorting = "test_Date",
    digits = 6
  )
  commit_4 <- commit(root, "add third file")

  write_vc(
    test_data[9:10, ],
    file = "test3",
    root = root,
    stage = TRUE,
    sorting = "test_Date"
  )
  commit_5 <- commit(root, "update third file")

  expect_identical(
    recent_commit(file = "test1.tsv", root) |>
      `row.names<-`(NULL),
    data.frame(
      commit = commit_3$sha,
      author = commit_3$author$name,
      when = as.POSIXct(commit_3$author$when),
      stringsAsFactors = FALSE
    )
  )
  expect_identical(
    recent_commit(file = file.path("junk", "test1"), root, data = TRUE) |>
      `row.names<-`(NULL),
    data.frame(
      commit = commit_2$sha,
      author = commit_2$author$name,
      when = as.POSIXct(commit_2$author$when),
      stringsAsFactors = FALSE
    )
  )

  unlink(root, recursive = TRUE)
})
