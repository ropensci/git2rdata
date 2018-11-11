context("handle special characters")
root <- tempfile(pattern = "git2rdata-special")
dir.create(root)
ds <- data.frame(
  a = c(
    "a", "a b",
    "a\tb", "a\tb\tc", "\ta", "a\t",
    "a\nb", "a\nb\nc", "\na", "a\n",
    "a\"b", "a\"b\"c", "\"b", "a\"", "\"b\"",
    "a'b", "a'b'c", "'b", "a'", "'b'",
    "a b c"
  ),
  stringsAsFactors = FALSE
)
expect_is(
  write_vc(ds, "character", root, sorting = "a"),
  "character"
)
expect_equal(
  junk <- read_vc("character", root),
  ds[order(ds$a), , drop = FALSE],
  check.attributes = FALSE
)
ds$a <- factor(ds$a)
expect_is(
  write_vc(ds, "factor", root, sorting = "a"),
  "character"
)
expect_equal(
  read_vc("factor", root),
  ds[order(ds$a), , drop = FALSE],
  check.attributes = FALSE
)
file.remove(list.files(root, recursive = TRUE, full.names = TRUE))
