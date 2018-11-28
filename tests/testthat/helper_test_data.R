test_n <- 100
test_data <- data.frame(
  test_character = sample(LETTERS, size = test_n, replace = TRUE),
  test_factor = sample(
    factor(c("a", "b"), levels = c("a", "b", "c")),
    size = test_n, replace = TRUE
  ),
  test_ordered = sample(
    factor(c("a", "b"), levels = c("a", "b", "c"), ordered = TRUE),
    size = test_n, replace = TRUE
  ),
  test_integer = sample(.Machine$integer.max, size = test_n, replace = TRUE),
  test_numeric = rnorm(test_n, mean = 0, sd = 1),
  test_logical = sample(c(TRUE, FALSE), size = test_n, replace = TRUE),
  test_POSIXct = as.POSIXct(
    sample(.Machine$integer.max, size = test_n, replace = TRUE),
    origin = "1970-01-01"
  ),
  test_Date = as.Date(
    c(sample(1e5, size = test_n - 1, replace = TRUE), 16000),
    origin = "1970-01-01"
  ),
  stringsAsFactors = FALSE
)

sorted_test_data <- test_data[order(test_data$test_Date), ]
rownames(sorted_test_data) <- NULL
attr(sorted_test_data$test_POSIXct, "tzone") <- "UTC"

test_subset <- head(test_data, ceiling(test_n / 2))

sorted_test_subset <- test_subset[order(test_subset$test_Date), ]
rownames(sorted_test_subset) <- NULL
attr(sorted_test_subset$test_POSIXct, "tzone") <- "UTC"

test_na <- test_data
for (i in seq_along(test_na)) {
  test_na[sample(test_n, size = ceiling(0.1 * test_n)), i] <- NA
}
sorted_test_na <- test_na[
  order(test_na$test_Date, test_na$test_integer, test_na$test_numeric),
]
rownames(sorted_test_na) <- NULL
attr(sorted_test_na$test_POSIXct, "tzone") <- "UTC"
