context("relabel")
root <- tempfile("git2rdata-relabel")
dir.create(root)
ds <- data.frame(a = c("a1", "a2"), b = c("b2", "b1"), stringsAsFactors = TRUE)
write_vc(ds, "relabel", root, sorting = "b")
new_labels <- list(a = list(a2 = "a3"))
test_that("relabel handles a list of changes", {
  meta1 <- yaml::read_yaml(file.path(root, "relabel.yml"))
  expect_null(relabel("relabel", root, new_labels))
  meta2 <- yaml::read_yaml(file.path(root, "relabel.yml"))
  expect_true(all(new_labels[["a"]] %in% meta2[["a"]][["labels"]]))
  expect_true(all(
    names(new_labels[["a"]]) %in%
    meta1[["a"]][["labels"]][
      !meta1[["a"]][["labels"]] %in% meta2[["a"]][["labels"]]
    ]
  ))
  c_1 <- meta1
  c_1[["a"]] <- NULL
  c_1[["..generic"]][["hash"]] <- NULL
  c_2 <- meta2
  c_2[["a"]] <- NULL
  c_2[["..generic"]][["hash"]] <- NULL
  expect_identical(c_1, c_2)
})

test_that("relabel handles a data.frame of changes", {
  change <- data.frame(
    factor = c("a", "a", "b"),
    old = c("a3", "a1", "b2"),
    new = c("c2", "c1", "b3"),
    stringsAsFactors = FALSE
  )
  expect_null(relabel("relabel", root, change))
  meta2 <- yaml::read_yaml(file.path(root, "relabel.yml"))
  expect_true(all(change$new[change$factor == "a"] %in%
                    meta2[["a"]][["labels"]]))
  expect_true(all(change$new[change$factor == "b"] %in%
                    meta2[["b"]][["labels"]]))
  change <- data.frame(
    factor = c("a", "b", "b"),
    old = c("c2", "b3", "b1"),
    new = c("a2", "d1", "d2"),
    stringsAsFactors = TRUE
  )
  expect_null(relabel("relabel", root, change))
  meta2 <- yaml::read_yaml(file.path(root, "relabel.yml"))
  expect_true(all(change$new[change$factor == "a"] %in%
                    meta2[["a"]][["labels"]]))
  expect_true(all(change$new[change$factor == "b"] %in%
                    meta2[["b"]][["labels"]]))
})

test_that("relabel only works on optimized files", {
  write_vc(ds, "relabel_verbose", root, sorting = "b", optimize = FALSE)
  expect_error(relabel("relabel_verbose", root, new_labels),
               "relabelling factors on verbose data leads to large diffs")
})

test_that("relabel handles git repositories", {
  repo <- git2r::init(root)
  git2r::config(repo, user.name = "Alice", user.email = "alice@example.org")
  write_vc(ds, "relabel_git", repo, sorting = "b")
  meta1 <- yaml::read_yaml(file.path(root, "relabel_git.yml"))
  new_labels <- list(a = list(a2 = "a3"))
  expect_null(relabel("relabel_git", repo, new_labels))
  meta2 <- yaml::read_yaml(file.path(root, "relabel_git.yml"))
  expect_true(all(new_labels[["a"]] %in% meta2[["a"]][["labels"]]))
  expect_true(all(
    names(new_labels[["a"]]) %in%
    meta1[["a"]][["labels"]][
      !meta1[["a"]][["labels"]] %in% meta2[["a"]][["labels"]]
    ]
  ))
  c_1 <- meta1
  c_1[["a"]] <- NULL
  c_1[["..generic"]][["hash"]] <- NULL
  c_2 <- meta2
  c_2[["a"]] <- NULL
  c_2[["..generic"]][["hash"]] <- NULL
  expect_identical(c_1, c_2)
})

test_that("relabel returns an error for unknown classes", {
  expect_error(relabel(change = NULL),
               "a 'change' of class NULL is not supported")
})
