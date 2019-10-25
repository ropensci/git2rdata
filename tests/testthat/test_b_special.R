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




file.remove(list.files(root, recursive = TRUE, full.names = TRUE))
