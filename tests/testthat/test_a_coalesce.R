test_that("coalesce()", {
  expect_equal(coalesce(), NULL)
  expect_equal(coalesce(NULL), NULL)
  expect_equal(coalesce(NULL, 1), 1)
  expect_equal(coalesce(NULL, NULL, 1), 1)
})
