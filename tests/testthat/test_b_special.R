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
    "a b c", "\"NA\"", "'NA'", NA
  ),
  stringsAsFactors = FALSE
)
expect_is(
  write_vc(ds, "character", root, sorting = "a"),
  "character"
)
expect_equal(
  junk <- read_vc("character", root),
  ds[order(ds$a), , drop = FALSE], # nolint
  check.attributes = FALSE
)
expect_is(
  write_vc(ds, "character2", root, sorting = "a", optimize = FALSE),
  "character"
)
expect_equal(
  junk <- read_vc("character2", root),
  ds[order(ds$a), , drop = FALSE], # nolint
  check.attributes = FALSE
)
z <- rbind(ds, "NA")
z$a <- factor(z$a)
expect_is(
  suppressWarnings(write_vc(z, "factor", root, sorting = "a")),
  "character"
)
expect_equal(
  read_vc("factor", root),
  z[order(z$a), , drop = FALSE], # nolint
  check.attributes = FALSE
)
ds$a <- factor(ds$a)
expect_is(
  write_vc(ds, "factor2", root, sorting = "a", optimize = FALSE),
  "character"
)
expect_equal(
  read_vc("factor2", root),
  ds[order(ds$a), , drop = FALSE], # nolint
  check.attributes = FALSE
)

test_data_fixed <-
  data.frame(
    characters = LETTERS[1:10],
    spec_chars = c("é", "&", "à", "µ", "ç", "€", "|", "#", "@", "$"),
    numbers = seq(4, 99, length.out = 10),
    stringsAsFactors = FALSE
  )
expect_equal(
  names(write_vc(test_data_fixed, "test_data_hash", root)[1]),
  "6f84620cf2e355e0ebfa7a72a3b60325d36b3f27"
)
expect_silent(
  output_test_data_hash <- read_vc("test_data_hash", root)
)
expect_equal(
  names(attr(output_test_data_hash, "source")[1]),
  "6f84620cf2e355e0ebfa7a72a3b60325d36b3f27"
)
attr(output_test_data_hash, "source") <- NULL
expect_equal(
  output_test_data_hash,
  test_data_fixed
)
file.remove(list.files(root, recursive = TRUE, full.names = TRUE))
