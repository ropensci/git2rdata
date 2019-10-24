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
  git2rdata:::datahash(file.path(root, "test_1.tsv")),
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
  git2rdata:::datahash(file.path(root, "test_2.tsv")),
  "a3fef7eed4b598173700f405b0e024e7fbbb2cfe"
)
expect_equal(
  tail(readLines(file.path(root, "test_2.tsv"), encoding = "UTF-8"), -1),
  meta(ds$x),
  check.attributes = FALSE
)

ds <- data.frame(
  x = c(
    "a", "a b",
    "a\tb", "a\tb\tc", "\ta", "a\t",
    "a\"b", "a\"b\"c", "\"b", "a\"", "\"b\"",
    "a'b", "a'b'c", "'b", "a'", "'b'",
    "a b c", "\"NA\"", "'NA'", NA
  ),
  stringsAsFactors = FALSE
)
expect_true(all(Encoding(meta(ds$x)) %in% c("UTF-8", "unknown")))
expect_identical(
  git2r::hash(meta(ds$x)),
  c(
    "2e65efe2a145dda7ee51d1741299f848e5bf752e",
    "9eb1507c015c9e04b0db04402ed780a1526cce64",
    "fc438c7cd0a48c1bb82c1d03832ae2e505363e07",
    "2ec24bdca245c60779f8fa754257960b1c431b00",
    "147aee08dd4e1c1575b6874aecdd48c18beefc7b",
    "e51f3dcf524d247c4b7328331296f1dd83bee056",
    "949de239b95cddbd0f6a85cf3c4605e0c1be1f2a",
    "5d5e05f77a0721e35d10d20c028c65677414e90b",
    "3a32b181d9c43fe836960d79e918ae82f24bbbd0",
    "590314a1782fc21e1ed9bb6855c7dbf6b6ffbf76",
    "f53225ad8dbbb1996b52ba6a56271e1f29770de4",
    "5004405d88f0e72c9c3b2bc934e9c7995008fe08",
    "40161910c4d01f86ca5445b03fea8ff916fc28ea",
    "4842e50fa142b625ef38fb3a9adc345546c1bda3",
    "5538e13830c17d53f031fb424e29694f2a36f29a",
    "ac4ffbd4c9aef7d0f87cb5e7bffb73a2eb7917b6",
    "ed2c580a02320106284f10d8fceccf637c4e54da",
    "4a625a192bd7cd9969d170ed1b26f1a72b60c5d5",
    "b38d577c63f701ea17db2dead04178408d85cfc5",
    "280762b91bd56d59af8ccc798d8e96b6ef17cb66"
  )
)
expect_equal(
  names(suppressWarnings(write_vc(ds, "test_3", root)))[1],
  "c55e686867fd6ab13b8612942df6776660a79782"
)
expect_equal(
  git2rdata:::datahash(file.path(root, "test_3.tsv")),
  "c55e686867fd6ab13b8612942df6776660a79782"
)
expect_equal(
  tail(readLines(file.path(root, "test_3.tsv"), encoding = "UTF-8"), -1),
  meta(ds$x),
  check.attributes = FALSE
)

ds <- data.frame(
  x = c("a\nb", "a\nb\nc", "\na", "a\n"),
  stringsAsFactors = FALSE
)
expect_true(all(Encoding(meta(ds$x)) %in% c("UTF-8", "unknown")))
expect_identical(
  git2r::hash(meta(ds$x)),
  c(
    "f53e156553acec3310424d6568005da1e460b961",
    "643634f40a6bc57b6dba05f14e19ed9e79de4951",
    "1305b51188266b9bebe9206bea9fe0ef843fb479",
    "d59cd3316b3720aa2bc51479cb37e4b88ccf736c"
  )
)
expect_equal(
  names(suppressWarnings(write_vc(ds, "test_4", root)))[1],
  "21e1b61d9e6dbff1ee712643e6262fdd13777a90"
)
expect_equal(
  git2rdata:::datahash(file.path(root, "test_4.tsv")),
  "21e1b61d9e6dbff1ee712643e6262fdd13777a90"
)
expect_equal(
  paste(
    tail(readLines(file.path(root, "test_4.tsv"), encoding = "UTF-8"), -1),
    collapse = "\n"
  ),
  paste(meta(ds$x), collapse = "\n"),
  check.attributes = FALSE
)

file.remove(list.files(root, recursive = TRUE, full.names = TRUE))
