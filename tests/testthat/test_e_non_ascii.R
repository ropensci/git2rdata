root <- tempfile("git2rdata-empty-label")
dir.create(root)
characters <- data.frame(a = c("€$£ @&#§µ^ ()[]{}|²³<>/\\*+- ,;:.?!~",
                               "äàáâã ëèéê ïìíî öòóô üùúû ÿ ç ñ",
                               "ÄÀÁÂ ËÈÉÊ ÏÌÍÎ ÖÒÓÔ ÜÙÚÛ Ñ"),
                         stringsAsFactors = FALSE)
old_locale <- git2rdata:::set_c_locale()
characters <- characters[order(characters$a), , drop = FALSE] # nolint
git2rdata:::set_local_locale(old_locale)

test_that("special character are written properly as character", {
  file <- basename(tempfile(tmpdir = root))
  expect_is(
    junk <- write_vc(characters, file = file, root = root, sorting = "a"),
    "character"
  )
  expect_equivalent(read_vc(file = file, root = root), characters)
})

characters$a <- factor(characters$a)
old_locale <- git2rdata:::set_c_locale()
characters <- characters[order(characters$a), , drop = FALSE] # nolint
git2rdata:::set_local_locale(old_locale)
test_that("special character are written properly as optimized factor", {
  file <- basename(tempfile(tmpdir = root))
  expect_is(
    junk <- write_vc(characters, file = file, root = root, sorting = "a"),
    "character"
  )
  expect_equivalent(read_vc(file = file, root = root), characters)
})

test_that("special character are written properly as verbose factor", {
  file <- basename(tempfile(tmpdir = root))
  expect_is(
    junk <- write_vc(characters, file = file, root = root, sorting = "a",
                     optimize = FALSE),
    "character"
  )
  expect_equivalent(read_vc(file = file, root = root), characters)
})
