test_that("handle special characters", {
  root <- tempfile(pattern = "git2rdata-special")
  dir.create(root)
  ds <- data.frame(
    a = c(
      "a", "a b",
      "a\tb", "a\tb\tc", "\ta", "a\t",
      "a,b", "a,b,c", ",a", "a,",
      "a;b", "a;b;c", ";a", "a;",
      "a\nb", "a\nb\nc", "\na", "a\n",
      "a\"b", "a\"b\"c", "\"b", "a\"", "\"b\"",
      "a'b", "a'b'c", "'b", "a'", "'b'",
      "a b c", "\"NA\"", "'NA'", NA,
      "\U00E9", "&", "\U00E0", "\U00B5", "\U00E7", "€", "|", "#", "@", "$"
    ),
    stringsAsFactors = FALSE
  )
  expect_is(
    output <- write_vc(ds, "character", root, sorting = "a"),
    "character"
  )
  expect_equal(
    names(output)[1],
    "e8a6734d740941f347bbc21e3227b4a6392b6562"
  )
  old_locale <- git2rdata:::set_c_locale()
  dso <- ds[order(ds$a), , drop = FALSE] # nolint
  git2rdata:::set_local_locale(old_locale)
  expect_equal(
    junk <- read_vc("character", root), dso, check.attributes = FALSE
  )
  expect_identical(
    names(output),
    names(attr(junk, "source"))
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

  old_locale <- git2rdata:::set_c_locale()
  ds$a <- factor(ds$a)
  git2rdata:::set_local_locale(old_locale)
  expect_is(
    output <- write_vc(ds, "factor2", root, sorting = "a", optimize = FALSE),
    "character"
  )
  expect_equal(
    junk <- read_vc("factor2", root),
    ds[order(ds$a), , drop = FALSE], # nolint
    check.attributes = FALSE
  )
  expect_equal(
    names(output)[1],
    "5fd788c095d847d8e1a8386f621ee11fc69cd9a5"
  )
  expect_identical(
    names(output),
    names(attr(junk, "source"))
  )


  yaml_file <- yaml::read_yaml(file.path(root, "factor2.yml"))
  yaml_file[["..generic"]][["data_hash"]] <- "zzz"
  yaml::write_yaml(yaml_file, file.path(root, "factor2.yml"))
  expect_warning(read_vc("factor2", root = root),
               "Mismatching data hash. Data altered outside of git2rdata.")
})
