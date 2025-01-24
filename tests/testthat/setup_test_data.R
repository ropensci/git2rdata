test_n <- 100
test_data <- data.frame(
  test_character = c(
    sample(LETTERS, size = test_n - 10, replace = TRUE),
    c("é", "&", "à", "µ", "ç", "€", "|", "#", "@", "$")
  ),
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
    origin = "1970-01-01",
    tz = "UTC"
  ),
  test_Date = as.Date(
    c(sample(1e5, size = test_n - 1, replace = TRUE), 16000),
    origin = "1970-01-01"
  ),
  stringsAsFactors = FALSE
)

old_locale <- git2rdata:::set_c_locale()
sorted_test_data <- test_data[order(test_data$test_Date), ]
git2rdata:::set_local_locale(old_locale)
sorted_test_data$test_character <- enc2utf8(sorted_test_data$test_character)
rownames(sorted_test_data) <- NULL

sorted_test_data_6 <- sorted_test_data
sorted_test_data_6$test_numeric <- signif(sorted_test_data_6$test_numeric, 6)

sorted_test_data_4 <- sorted_test_data
sorted_test_data_4$test_numeric <- signif(sorted_test_data_4$test_numeric, 4)


test_subset <- head(test_data, ceiling(test_n / 2))

sorted_test_subset <- test_subset[order(test_subset$test_Date), ]
rownames(sorted_test_subset) <- NULL
sorted_test_subset_6 <- sorted_test_subset
sorted_test_subset_6$test_numeric <- signif(
  sorted_test_subset_6$test_numeric, 6
)

test_na <- test_data
for (i in seq_along(test_na)) {
  test_na[sample(test_n, size = ceiling(0.1 * test_n)), i] <- NA
}
old_locale <- git2rdata:::set_c_locale()
sorted_test_na <- test_na[
  order(test_na$test_Date, test_na$test_integer, test_na$test_numeric),
]
sorted_test_na$test_numeric <- signif(sorted_test_na$test_numeric, 6)
git2rdata:::set_local_locale(old_locale)
rownames(sorted_test_na) <- NULL
