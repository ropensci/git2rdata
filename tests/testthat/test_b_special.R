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
  names(suppressWarnings(write_vc(ds, "test_data_hash", root)))[1],
  "be6352bd3b0d1b3cd81739a5190c24a277ea16d5"
)
expect_silent({
  output_test_data_hash <- read_vc("test_data_hash", root)
})
expect_equal(
  names(attr(output_test_data_hash, "source")[1]),
  "be6352bd3b0d1b3cd81739a5190c24a277ea16d5"
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


ds <- data.frame(
  x = c("\U00E9", "&", "\U00E0", "\U00B5", "\U00E7"),
  stringsAsFactors = FALSE
)
expect_true(all(Encoding(meta(ds$x)) %in% c("UTF-8", "unknown")))
expect_equivalent(meta(ds$x), ds$x)
expect_identical(
  git2r::hash(meta(ds$x)),
  c(
    "4b04fff51468d8ab5201ab02b725dc477bc7cb45",
    "00b15c0a321af2492988194cb33b5f55b2ae8332",
    "e3b1a91ba22d76360e44b33dbac0943503cad202",
    "46aa40f5dd63d0f1470a9312ad776be198a896d1",
    "08029ea5564e2cd7a62888ae70ba62f4f1277bee"
  )
)
expect_equal(
  names(suppressWarnings(write_vc(ds, "test_1", root)))[1],
  "10cc7a45d8d71a91eb88b3f13109b1ac2732d8a5"
)
expect_equal(
  tail(readLines(file.path(root, "test_1.tsv"), encoding = "UTF-8"), -1),
  meta(ds$x),
  check.attributes = FALSE
)

ds <- data.frame(
  x = c("€", "|", "#", "@", "$"),
  stringsAsFactors = FALSE
)
expect_true(all(Encoding(meta(ds$x)) %in% c("UTF-8", "unknown")))
expect_equivalent(meta(ds$x), ds$x)
expect_identical(
  git2r::hash(meta(ds$x)),
  c(
    "eca7d6d81cace4d7fdc1808a5d7619cfe98a6bde",
    "a3871d4508259dc2e3eae0be6fc69d1d3daf0a35",
    "4287ca8617970fa8fc025b75cb319c7032706910",
    "b516b2c489f1fefd53b4a1905bf37480a8eb056d",
    "6f4f765ed6998a016a32bf9b4c48b77219ef7f0a"
  )
)
expect_equal(
  names(suppressWarnings(write_vc(ds, "test_2", root)))[1],
  "a3fef7eed4b598173700f405b0e024e7fbbb2cfe"
)
expect_equal(
  tail(readLines(file.path(root, "test_2.tsv"), encoding = "UTF-8"), -1),
  meta(ds$x),
  check.attributes = FALSE
)

file.remove(list.files(root, recursive = TRUE, full.names = TRUE))
