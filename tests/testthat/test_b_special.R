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
    "a b c", "\"NA\"", "'NA'", NA,
    "\U00E9", "&", "\U00E0", "\U00B5", "\U00E7", "€", "|", "#", "@", "$"
  ),
  stringsAsFactors = FALSE
)
expect_is(
  write_vc(ds, "character", root, sorting = "a"),
  "character"
)
old_locale <- git2rdata:::set_c_locale()
dso <- ds[order(ds$a), , drop = FALSE] # nolint
git2rdata:::set_local_locale(old_locale)
expect_equal(
  junk <- read_vc("character", root), dso, check.attributes = FALSE
)
expect_is(
  write_vc(ds, "character2", root, sorting = "a", optimize = FALSE),
  "character"
)
expect_equal(
  junk <- read_vc("character2", root), dso, check.attributes = FALSE
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
expect_equal(
  names(suppressWarnings(write_vc(ds, "hash_equality", root)))[1],
  names(attr(read_vc("hash_equality", root), "source"))[1]
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

expect_equal(
  names(
    suppressWarnings(write_vc(ds[1:17, , drop = FALSE], "test_data_hash", root))
  )[1],
  "2f8fac9fa87ad46e4744ece09cdcf6a17c2645a0"
)
expect_equal(
  names(
    suppressWarnings(
      write_vc(ds[18:34, , drop = FALSE], "test_data_hash", root)
    )
  )[1],
  "1d4ff22735dc3d7e7f94386e149f0acde22e8c3b"
)

expect_identical(
  as.integer(ds$a),
  c(15L, 23L, 18L, 19L, 1L, 17L, 21L, 22L, 2L, 20L, 29L, 30L, 6L,
28L, 7L, 26L, 27L, 3L, 25L, 4L, 24L, 8L, 5L, NA, 32L, 10L, 16L,
33L, 31L, 14L, 12L, 11L, 9L, 13L)
)
expect_identical(
  levels(ds$a),
  c("\ta", "\na", "'b", "'b'", "'NA'", "\"b", "\"b\"", "\"NA\"",
"@", "&", "#", "|", "$", "€", "a", "\U00E0", "a\t", "a\tb", "a\tb\tc",
"a\n", "a\nb", "a\nb\nc", "a b", "a b c", "a'", "a'b", "a'b'c",
"a\"", "a\"b", "a\"b\"c", "\U00E7", "\U00E9", "\U00B5")
)

expect_equal(
  names(suppressWarnings(write_vc(ds, "test_data_hash", root)))[1],
  "dd99251ec3ad80ce137db113a8baee5801e73bc4"
)
expect_silent({
  output_test_data_hash <- read_vc("test_data_hash", root)
})
expect_equal(
  names(attr(output_test_data_hash, "source")[1]),
  "dd99251ec3ad80ce137db113a8baee5801e73bc4"
)
attr(output_test_data_hash, "source") <- NULL
expect_equal(
  output_test_data_hash,
  ds
)
yaml_file <- yaml::read_yaml(file.path(root, "test_data_hash.yml"))
yaml_file[["..generic"]][["data_hash"]] <- "zzz"
yaml::write_yaml(yaml_file, file.path(root, "test_data_hash.yml"))
expect_warning(read_vc("test_data_hash", root = root),
             "Mismatching data hash. Data altered outside of git2rdata.")

ds$a <- as.character(ds$a)
expect_equal(
  names(suppressWarnings(write_vc(ds, "test_data_hash2", root)))[1],
  "a5bdb23c869ada2eedffa7add5c18dca38aa3d61"
)

file.remove(list.files(root, recursive = TRUE, full.names = TRUE))
