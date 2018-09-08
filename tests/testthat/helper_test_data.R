test_n <- 100
test_data <- data.frame(
  test_character = sample(LETTERS, size = test_n, replace = TRUE),
  test_factor = sample(
    factor(c("a", "b"), levels = c("a", "b", "c")),
    size = test_n, replace = TRUE
  ),
  test_integer = sample(.Machine$integer.max, size = test_n, replace = TRUE),
  test_numeric = rnorm(test_n, mean = 0, sd = 1),
  test_complex = complex(
    real = rnorm(test_n, mean = 0, sd = 1),
    imaginary = rnorm(test_n, mean = 0, sd = 1)
  ),
  test_logical = sample(c(TRUE, FALSE), size = test_n, replace = TRUE),
  test_POSIXct = as.POSIXct(
    sample(.Machine$integer.max, size = test_n, replace = TRUE),
    origin = "1970-01-01"
  ),
  test_Date = as.Date(
    sample(1e5, size = test_n, replace = TRUE),
    origin = "1970-01-01"
  ),
  stringsAsFactors = FALSE
)

sorted_test_data <- test_data[
  order(test_data$test_Date),
  c("test_Date", head(colnames(test_data), -1))
]
rownames(sorted_test_data) <- NULL

test_subset <- head(test_data, ceiling(test_n / 2))

sorted_test_subset <- test_subset[
  order(test_subset$test_Date),
  c("test_Date", head(colnames(test_data), -1))
]
rownames(sorted_test_subset) <- NULL
