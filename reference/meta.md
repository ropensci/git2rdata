# Optimize an Object for Storage as Plain Text and Add Metadata

Prepares a vector for storage. When relevant, `meta()` optimizes the
object for storage by changing the format to one which needs less
characters. The metadata stored in the `meta` attribute, contains all
required information to back-transform the optimized format into the
original format.

In case of a data.frame, `meta()` applies itself to each of the columns.
The `meta` attribute becomes a named list containing the metadata for
each column plus an additional `..generic` element. `..generic` is a
reserved name for the metadata and not allowed as column name in a
`data.frame`.

[`write_vc()`](https://ropensci.github.io/git2rdata/reference/write_vc.md)
uses this function to prepare a dataframe for storage. Existing metadata
is passed through the optional `old` argument. This argument intended
for internal use.

## Usage

``` r
meta(x, ..., digits)

# S3 method for class 'character'
meta(x, na = "NA", optimize = TRUE, ...)

# S3 method for class 'factor'
meta(x, optimize = TRUE, na = "NA", index, strict = TRUE, ...)

# S3 method for class 'logical'
meta(x, optimize = TRUE, ...)

# S3 method for class 'POSIXct'
meta(x, optimize = TRUE, ...)

# S3 method for class 'Date'
meta(x, optimize = TRUE, ...)

# S3 method for class 'data.frame'
meta(
  x,
  optimize = TRUE,
  na = "NA",
  sorting,
  strict = TRUE,
  split_by = character(0),
  ...,
  digits
)
```

## Arguments

- x:

  the vector.

- ...:

  further arguments to the methods.

- digits:

  The number of significant digits of the smallest absolute value. The
  function applies the rounding automatically. Only relevant for numeric
  variables. Either a single positive integer or a named vector where
  the names link to the variables in the `data.frame`. Defaults to `6`
  with a warning.

- na:

  the string to use for missing values in the data.

- optimize:

  If `TRUE`, recode the data to get smaller text files. If `FALSE`,
  `meta()` converts the data to character. Defaults to `TRUE`.

- index:

  An optional named vector with existing factor indices. The names must
  match the existing factor levels. Unmatched levels from `x` will get
  new indices.

- strict:

  What to do when the metadata changes. `strict = FALSE` overwrites the
  data and the metadata with a warning listing the changes,
  `strict = TRUE` returns an error and leaves the data and metadata as
  is. Defaults to `TRUE`.

- sorting:

  an optional vector of column names defining which columns to use for
  sorting `x` and in what order to use them. The default empty `sorting`
  yields a warning. Add `sorting` to avoid this warning. Strongly
  recommended in combination with version control. See
  [`vignette("efficiency", package = "git2rdata")`](https://ropensci.github.io/git2rdata/articles/efficiency.md)
  for an illustration of the importance of sorting.

- split_by:

  An optional vector of variables name to split the text files. This
  creates a separate file for every combination. We prepend these
  variables to the vector of `sorting` variables.

## Value

the optimized vector `x` with `meta` attribute.

## Note

The default order of factor levels depends on the current locale. See
[`Comparison`](https://rdrr.io/r/base/Comparison.html) for more details
on that. The same code on a different locale might result in a different
sorting. `meta()` ignores, with a warning, any change in the order of
factor levels. Add `strict = FALSE` to enforce the new order of factor
levels.

## See also

Other internal:
[`is_git2rdata()`](https://ropensci.github.io/git2rdata/reference/is_git2rdata.md),
[`is_git2rmeta()`](https://ropensci.github.io/git2rdata/reference/is_git2rmeta.md),
[`print.git2rdata()`](https://ropensci.github.io/git2rdata/reference/print.git2rdata.md),
[`summary.git2rdata()`](https://ropensci.github.io/git2rdata/reference/summary.git2rdata.md),
[`upgrade_data()`](https://ropensci.github.io/git2rdata/reference/upgrade_data.md)

## Examples

``` r
meta(c(NA, "'NA'", '"NA"', "abc\tdef", "abc\ndef"))
#> [1] "NA"             "'NA'"           "\"\"\"NA\"\"\"" "\"abc\tdef\""  
#> [5] "\"abc\ndef\""  
#> attr(,"meta")
#> class: character
#> na_string: NA
#> 
meta(1:3)
#> [1] 1 2 3
#> attr(,"meta")
#> class: integer
#> 
meta(seq(1, 3, length = 4), digits = 6)
#> [1] 1.00000 1.66667 2.33333 3.00000
#> attr(,"meta")
#> class: numeric
#> digits: 6
#> 
meta(factor(c("b", NA, "NA"), levels = c("NA", "b", "c")))
#>    b <NA>   NA 
#>    2   NA    1 
#> attr(,"meta")
#> class: factor
#> na_string: NA
#> optimize: yes
#> labels:
#> - NA
#> - b
#> - c
#> index:
#> - 1
#> - 2
#> - 3
#> ordered: no
#> 
meta(factor(c("b", NA, "a"), levels = c("a", "b", "c")), optimize = FALSE)
#> [1] "b"  "NA" "a" 
#> attr(,"meta")
#> class: factor
#> na_string: NA
#> optimize: no
#> labels:
#> - a
#> - b
#> - c
#> index:
#> - 1
#> - 2
#> - 3
#> ordered: no
#> 
meta(factor(c("b", NA, "a"), levels = c("a", "b", "c"), ordered = TRUE))
#>    b <NA>    a 
#>    2   NA    1 
#> attr(,"meta")
#> class: factor
#> na_string: NA
#> optimize: yes
#> labels:
#> - a
#> - b
#> - c
#> index:
#> - 1
#> - 2
#> - 3
#> ordered: yes
#> 
meta(
  factor(c("b", NA, "a"), levels = c("a", "b", "c"), ordered = TRUE),
  optimize = FALSE
)
#> [1] "b"  "NA" "a" 
#> attr(,"meta")
#> class: factor
#> na_string: NA
#> optimize: no
#> labels:
#> - a
#> - b
#> - c
#> index:
#> - 1
#> - 2
#> - 3
#> ordered: yes
#> 
meta(c(FALSE, NA, TRUE))
#> [1]  0 NA  1
#> attr(,"meta")
#> class: logical
#> optimize: yes
#> 
meta(c(FALSE, NA, TRUE), optimize = FALSE)
#> [1] FALSE    NA  TRUE
#> attr(,"meta")
#> class: logical
#> optimize: no
#> 
meta(complex(real = c(1, NA, 2), imaginary = c(3, NA, -1)))
#> [1] 1+3i   NA 2-1i
#> attr(,"meta")
#> class: complex
#> 
meta(as.POSIXct("2019-02-01 10:59:59", tz = "CET"))
#> [1] 1549015199
#> attr(,"tzone")
#> [1] "CET"
#> attr(,"meta")
#> class: POSIXct
#> optimize: yes
#> origin: 1970-01-01 00:00:00
#> timezone: UTC
#> 
meta(as.POSIXct("2019-02-01 10:59:59", tz = "CET"), optimize = FALSE)
#> [1] "2019-02-01T09:59:59Z"
#> attr(,"meta")
#> class: POSIXct
#> optimize: no
#> format: '%Y-%m-%dT%H:%M:%SZ'
#> timezone: UTC
#> 
meta(as.Date("2019-02-01"))
#> [1] 17928
#> attr(,"meta")
#> class: Date
#> optimize: yes
#> origin: '1970-01-01'
#> 
meta(as.Date("2019-02-01"), optimize = FALSE)
#> [1] "2019-02-01"
#> attr(,"meta")
#> class: Date
#> optimize: no
#> format: '%Y-%m-%d'
#> 
```
