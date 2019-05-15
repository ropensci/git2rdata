context("check writing non ASCII characters")
root <- tempfile("git2rdata-empty-label")
dir.create(root)
characters <- data.frame(a = c("€$£ @&#§µ^ ()[]{}|²³<>/\\*+- ,;:.?!~",
                               "äàáâã ëèéê ïìíî öòóô üùúû ÿ ç ñ",
                               "ÄÀÁÂ ËÈÉÊ ÏÌÍÎ ÖÒÓÔ ÜÙÚÛ Ñ"),
                         stringsAsFactors = FALSE)
characters <- characters[order(characters$a), , drop = FALSE] # nolint

test_that("special character are written properly as character", {
  file <- basename(tempfile(tmpdir = root))
  expect_is(
    junk <- write_vc(characters, file = file, root = root, sorting = "a"),
    "character"
  )
  expect_equivalent(read_vc(file = file, root = root), characters)
})

test_that("special character are written properly as optimized factor", {
  characters$a <- factor(characters$a)
  file <- basename(tempfile(tmpdir = root))
  expect_is(
    junk <- write_vc(characters, file = file, root = root, sorting = "a"),
    "character"
  )
  expect_equivalent(read_vc(file = file, root = root), characters)
})

test_that("special character are written properly as verbose factor", {
  characters$a <- factor(characters$a)
  file <- basename(tempfile(tmpdir = root))
  expect_is(
    junk <- write_vc(characters, file = file, root = root, sorting = "a",
                     optimize = FALSE),
    "character"
  )
  expect_equivalent(read_vc(file = file, root = root), characters)
})

file.remove(list.files(root, recursive = TRUE, full.names = TRUE))
