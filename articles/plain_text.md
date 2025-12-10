# Getting Started Storing Dataframes as Plain Text

## Introduction

This vignette motivates why we wrote `git2rdata` and illustrates how you
can use it to store dataframes as plain text files.

### Maintaining Variable Classes

R has different options to store dataframes as plain text files from R.
Base R has [`write.table()`](https://rdrr.io/r/utils/write.table.html)
and its companions like
[`write.csv()`](https://rdrr.io/r/utils/write.table.html). Some other
options are
[`data.table::fwrite()`](https://rdatatable.gitlab.io/data.table/reference/fwrite.html),
[`readr::write_delim()`](https://readr.tidyverse.org/reference/write_delim.html),
[`readr::write_csv()`](https://readr.tidyverse.org/reference/write_delim.html)
and
[`readr::write_tsv()`](https://readr.tidyverse.org/reference/write_delim.html).
Each of them writes a dataframe as a plain text file by converting all
variables into characters. After reading the file, they revert this
conversion. The distinction between `character` and `factor` gets lost
in translation.
[`read.table()`](https://rdrr.io/r/utils/read.table.html) converts by
default all strings to factors,
[`readr::read_csv()`](https://readr.tidyverse.org/reference/read_delim.html)
keeps by default all strings as character. These functions cannot
recover the factor levels. These functions determine factor levels based
on the observed levels in the plain text file. Hence factor levels
without observations will disappear. The order of the factor levels is
also determined by the available levels in the plain text file, which
can be different from the original order.

The
[`write_vc()`](https://ropensci.github.io/git2rdata/reference/write_vc.md)
and
[`read_vc()`](https://ropensci.github.io/git2rdata/reference/read_vc.md)
functions from `git2rdata` keep track of the class of each variable and,
in case of a factor, also of the factor levels and their order. Hence
this function pair preserves the information content of the dataframe.
The `vc` suffix stands for **v**ersion **c**ontrol as these functions
use their full capacity in combination with a version control system.

## Efficiency Relative to Storage and Time

### Optimizing File Storage

Plain text files require more disk space than binary files. This is the
price we have to pay for a readable file format. The default option of
[`write_vc()`](https://ropensci.github.io/git2rdata/reference/write_vc.md)
is to create file as compact as possible. Since we use a tab delimited
file format, we can omit quotes around character variables. This saves 2
bytes per row for each character variable. `write_vc` add quotes
automatically in the exceptional cases when we needed them, e.g. to
store a string that contains tab or newline characters. We don’t add
quotes to row-variable combinations where we don’t need them.

Since we store the class of each variable, we can further reduce the
file size by following rules:

- Store a `logical` as 0 (FALSE), 1 (TRUE) or NA to the data.
- Store a `factor` as its indices in the data. Store the index, labels
  of levels and their order in the metadata.
- Store a `POSIXct` as a numeric to the data. Store the class and the
  origin in the metadata. Store and return timestamps as UTC.
- Store a `Date` as an integer to the data. Store the class and the
  origin in the metadata.

Storing the factors, POSIXct and Date as their index, makes them less
user readable. The user can turn off this optimization when user
readability is more important than file size.

### Optimized for Version Control

Another main goal of `git2rdata` is to optimise the storage of the plain
text files under version control.
[`write_vc()`](https://ropensci.github.io/git2rdata/reference/write_vc.md)
and
[`read_vc()`](https://ropensci.github.io/git2rdata/reference/read_vc.md)
has methods for interacting with [git](https://git-scm.com/)
repositories using the `git2r` framework. Users who want to use git
without `git2r` or use a different version control system
(e.g. [Subversion](https://subversion.apache.org/),
[Mercurial](https://www.mercurial-scm.org/)), still can use `git2rdata`
to write the files to disk and uses their preferred workflow on version
control.

Hence,
[`write_vc()`](https://ropensci.github.io/git2rdata/reference/write_vc.md)
will always perform checks to look for changes which potentially lead to
large diffs. More details on this in
[`vignette("version_control", package = "git2rdata")`](https://ropensci.github.io/git2rdata/articles/version_control.md).
Some problems will always yield a warning. Other problems will yield an
error by default. The user can turn these errors into warnings by
setting the `strict = FALSE` argument.

As this vignette ignores the part on version control, we will always use
`write_vc(strict = FALSE)` and hide the warnings to improve the
readability.

## Basic Usage

Let’s start by setting up the environment. We need a directory to store
the data and a dataframe to store.

``` r

# Create a directory in tempdir
path <- tempfile(pattern = "git2r-")
dir.create(path)
# Create dummy data
set.seed(20190222)
x <- data.frame(
  x = sample(LETTERS),
  y = factor(
    sample(c("a", "b", NA), 26, replace = TRUE),
    levels = c("a", "b", "c")
  ),
  z = c(NA, 1:25),
  abc = c(rnorm(25), NA),
  def = sample(c(TRUE, FALSE, NA), 26, replace = TRUE),
  timestamp = seq(
    as.POSIXct("2018-01-01"),
    as.POSIXct("2019-01-01"),
    length = 26
  ),
  stringsAsFactors = FALSE
)
str(x)
#> 'data.frame':    26 obs. of  6 variables:
#>  $ x        : chr  "V" "U" "Z" "W" ...
#>  $ y        : Factor w/ 3 levels "a","b","c": 1 2 NA NA 1 NA 2 1 NA 1 ...
#>  $ z        : int  NA 1 2 3 4 5 6 7 8 9 ...
#>  $ abc      : num  -0.382 -0.42 -0.917 0.387 -0.992 ...
#>  $ def      : logi  TRUE FALSE NA FALSE NA NA ...
#>  $ timestamp: POSIXct, format: "2018-01-01 00:00:00" "2018-01-15 14:24:00" ...
```

## Storing Optimized

Use
[`write_vc()`](https://ropensci.github.io/git2rdata/reference/write_vc.md)
to store the dataframe. The `root` argument refers to the base directory
where we store the data. The `file` argument becomes the base name of
the files. The data file gets a `.tsv` extension, the metadata file a
`.yml` extension. `file` can include a relative path starting from
`root`.

``` r

library(git2rdata)
write_vc(x = x, file = "first_test", root = path, strict = FALSE)
#> 2b0ac8243ca27ed3d983ba8fc27a3bca7ca8f39d 79e04b2ecff2c1eac8ededc69ba09311f38f74da 
#>                         "first_test.tsv"                         "first_test.yml"
```

[`write_vc()`](https://ropensci.github.io/git2rdata/reference/write_vc.md)
returns a vector of relative paths to the raw data and metadata files.
The names of this vector contains the hashes of these files. We can have
a look at both files. We’ll display the first 10 rows of the raw data.
Notice that the YAML format of the metadata has the benefit of being
both human and machine readable.

``` r

print_file <- function(file, root, n = -1) {
  fn <- file.path(root, file)
  data <- readLines(fn, n = n)
  cat(data, sep = "\n")
}
print_file("first_test.tsv", path, 10)
#> x    y   z   abc def timestamp
#> V    1   NA  -0.38201    1   1514764800
#> U    2   1   -0.420348   0   1516026240
#> Z    NA  2   -0.916731   NA  1517287680
#> W    NA  3   0.387455    0   1518549120
#> L    1   4   -0.992355   NA  1519810560
#> C    NA  5   0.0228714   NA  1521072000
#> R    2   6   -0.947557   1   1522333440
#> S    1   7   -0.163029   NA  1523594880
#> O    NA  8   0.523643    1   1524856320
print_file("first_test.yml", path)
#> ..generic:
#>   git2rdata: 0.5.1
#>   optimize: yes
#>   NA string: NA
#>   hash: 79e04b2ecff2c1eac8ededc69ba09311f38f74da
#>   data_hash: 2b0ac8243ca27ed3d983ba8fc27a3bca7ca8f39d
#> x:
#>   class: character
#> 'y':
#>   class: factor
#>   labels:
#>   - a
#>   - b
#>   - c
#>   index:
#>   - 1
#>   - 2
#>   - 3
#>   ordered: no
#> z:
#>   class: integer
#> abc:
#>   class: numeric
#>   digits: 6
#> def:
#>   class: logical
#> timestamp:
#>   class: POSIXct
#>   origin: 1970-01-01 00:00:00
#>   timezone: UTC
```

## Storing Verbose

Adding `optimize = FALSE` to
[`write_vc()`](https://ropensci.github.io/git2rdata/reference/write_vc.md)
will keep the raw data in a human readable format. The metadata file is
slightly different. The most obvious is the `optimize: no` tag and the
different hash. Another difference is the metadata for POSIXct and Date
classes. They will no longer have an origin tag but a format tag.

Another important difference is that we store the data file as comma
separated values instead of tab separated values. We noticed that the
`csv` file format is more easily recognised by a larger audience as a
data file.

``` r

write_vc(x = x, file = "verbose", root = path, optimize = FALSE, strict = FALSE)
#> a8979a8d3737e28729523ce04932453f1efbe04a 14cb4010f7f9f65eac46751c055904fc1e7d74e4 
#>                            "verbose.csv"                            "verbose.yml"
```

``` r

print_file("verbose.csv", path, 10)
#> x,y,z,abc,def,timestamp
#> V,a,NA,-0.38201,TRUE,2018-01-01T00:00:00Z
#> U,b,1,-0.420348,FALSE,2018-01-15T14:24:00Z
#> Z,NA,2,-0.916731,NA,2018-01-30T04:48:00Z
#> W,NA,3,0.387455,FALSE,2018-02-13T19:12:00Z
#> L,a,4,-0.992355,NA,2018-02-28T09:36:00Z
#> C,NA,5,0.0228714,NA,2018-03-15T00:00:00Z
#> R,b,6,-0.947557,TRUE,2018-03-29T14:24:00Z
#> S,a,7,-0.163029,NA,2018-04-13T04:48:00Z
#> O,NA,8,0.523643,TRUE,2018-04-27T19:12:00Z
print_file("verbose.yml", path)
#> ..generic:
#>   git2rdata: 0.5.1
#>   optimize: no
#>   NA string: NA
#>   hash: 14cb4010f7f9f65eac46751c055904fc1e7d74e4
#>   data_hash: a8979a8d3737e28729523ce04932453f1efbe04a
#> x:
#>   class: character
#> 'y':
#>   class: factor
#>   labels:
#>   - a
#>   - b
#>   - c
#>   index:
#>   - 1
#>   - 2
#>   - 3
#>   ordered: no
#> z:
#>   class: integer
#> abc:
#>   class: numeric
#>   digits: 6
#> def:
#>   class: logical
#> timestamp:
#>   class: POSIXct
#>   format: '%Y-%m-%dT%H:%M:%SZ'
#>   timezone: UTC
```

## Efficiency Relative to File Storage

Storing dataframes optimized or verbose has an impact on the required
file size. The
[efficiency](https://ropensci.github.io/git2rdata/articles/efficiency.html#on-a-file-system)
vignette give a comparison.

## Reading Data

You retrieve the data with
[`read_vc()`](https://ropensci.github.io/git2rdata/reference/read_vc.md).
This function will reinstate the variables to their original state.

``` r

y <- read_vc(file = "first_test", root = path)
all.equal(x, y, check.attributes = FALSE)
#> [1] "Component \"abc\": Mean relative difference: 5.679135e-07"                  
#> [2] "Component \"timestamp\": 'tzone' attributes are inconsistent ('' and 'UTC')"
y2 <- read_vc(file = "verbose", root = path)
all.equal(x, y2, check.attributes = FALSE)
#> [1] "Component \"abc\": Mean relative difference: 5.679135e-07"                  
#> [2] "Component \"timestamp\": 'tzone' attributes are inconsistent ('' and 'UTC')"
```

[`read_vc()`](https://ropensci.github.io/git2rdata/reference/read_vc.md)
requires the meta data. It cannot handle dataframe not stored by
[`write_vc()`](https://ropensci.github.io/git2rdata/reference/write_vc.md).

## Missing Values

[`write_vc()`](https://ropensci.github.io/git2rdata/reference/write_vc.md)
has an `na` argument which specifies the string which to use for missing
values. Because we avoid using quotes, this string must be different
from any character value in the data. This includes factor labels with
verbose data storage.
[`write_vc()`](https://ropensci.github.io/git2rdata/reference/write_vc.md)
checks this and will always return an error, even with `strict = FALSE`.

``` r

write_vc(x, "custom_na", path, strict = FALSE, na = "X", optimize = FALSE)
#> Error: one of the strings matches the NA string ('X')
#> Please use a different NA string or consider using a factor.
write_vc(x, "custom_na", path, strict = FALSE, na = "b", optimize = FALSE)
#> Error: one of the levels matches the NA string ('b').
#> Please use a different NA string or use optimize = TRUE
write_vc(x, "custom_na", path, strict = FALSE, na = "X")
#> Error: one of the strings matches the NA string ('X')
#> Please use a different NA string or consider using a factor.
write_vc(x, "custom_na", path, strict = FALSE, na = "b")
#> 9af818152e63482469c89ea7432fda1216f5eaf1 42235e10f9b5734d8718d02799d3ca6760c6a640 
#>                          "custom_na.tsv"                          "custom_na.yml"
```

Please note that
[`write_vc()`](https://ropensci.github.io/git2rdata/reference/write_vc.md)
uses the same NA string for the entire dataset, thus for every variable.

``` r

print_file("custom_na.tsv", path, 10)
#> x    y   z   abc def timestamp
#> V    1   b   -0.38201    1   1514764800
#> U    2   1   -0.420348   0   1516026240
#> Z    b   2   -0.916731   b   1517287680
#> W    b   3   0.387455    0   1518549120
#> L    1   4   -0.992355   b   1519810560
#> C    b   5   0.0228714   b   1521072000
#> R    2   6   -0.947557   1   1522333440
#> S    1   7   -0.163029   b   1523594880
#> O    b   8   0.523643    1   1524856320
print_file("custom_na.yml", path, 4)
#> ..generic:
#>   git2rdata: 0.5.1
#>   optimize: yes
#>   NA string: b
```

The default string for missing values is `"NA"`. We recommend to keep
this default, as long as the dataset permits it. A first good
alternative is an empty string (`""`). If that won’t work either, you’ll
have to use your imagination. Try to keep it short, clear and
robust[^1].

``` r

write_vc(x, "custom_na", path, strict = FALSE, na = "")
#> af77e2ece69634db88061c747cc833d868640218 e58a31060d6f1e2f42e3541bf26276fa1f8102f4 
#>                          "custom_na.tsv"                          "custom_na.yml"
```

[^1]: robust in the sense that you won’t need to change it later
