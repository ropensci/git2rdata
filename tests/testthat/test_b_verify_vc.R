test_that("verify_vc", {
  root <- tempfile(pattern = "git2rdata-verify-vc")
  dir.create(root)
  write_vc(
    x = test_data, file = "test.txt", root = root, sorting = "test_integer",
    digits = 6
  )
  expect_s3_class(
    verify_vc("test.txt", root = root, variables = "test_integer"),
    "data.frame"
  )
  expect_s3_class(
    verify_vc(
      "test.txt", root = root, variables = c("test_numeric", "test_logical")
    ),
    "data.frame"
  )
  expect_error(
    verify_vc("test.txt", root = root, variables = c("test_integer", "junk")),
    "variables missing.*junk"
  )
})
