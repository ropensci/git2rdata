# Optimizing Storage for Version Control

## Introduction

This vignette focuses on what `git2rdata` does to make storing
dataframes under version control more efficient and convenient.
[`vignette("plain_text", package = "git2rdata")`](https://ropensci.github.io/git2rdata/articles/plain_text.md)
describes all details on the actual file format. Hence we will not
discuss the `optimize` and `na` arguments to the
[`write_vc()`](https://ropensci.github.io/git2rdata/reference/write_vc.md)
function.

We will not illustrate the efficiency of
[`write_vc()`](https://ropensci.github.io/git2rdata/reference/write_vc.md)
and
[`read_vc()`](https://ropensci.github.io/git2rdata/reference/read_vc.md).
[`vignette("efficiency", package = "git2rdata")`](https://ropensci.github.io/git2rdata/articles/efficiency.md)
covers those topics.

## Setup

``` r

# Create a directory in tempdir
root <- tempfile(pattern = "git2r-")
dir.create(root)
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

## Assumptions

A critical assumption made by `git2rdata` is that the dataframe itself
contains all information. Each row is an observation, each column is a
variable. The dataframe has `colnames` but no `rownames`. This implies
that two observations switching place does not alter the information
content. Nor does switching two variables.

Version control systems like [git](https://git-scm.com/),
[subversion](https://subversion.apache.org/) or
[mercurial](https://www.mercurial-scm.org/) focus on accurately keeping
track of *any* change in the files. Two observations switching place in
a plain text file *is* a change, although the information content[^1]
doesn’t change. `git2rdata` helps the user to prepare the plain text
files in such a way that any change in the version history is an actual
change in the information content.

## Sorting Observations

Version control systems often track changes in plain text files based on
row based differences. In layman’s terms they record lines removed from
and inserted in the file at what location. Changing an existing line
implies removing the old version and inserting the new one. The minimal
example below illustrates this.

Original version

    A,B
    1,10
    2,11
    3,12

Altered version. The row containing `1, 10` moves to the last line. The
row containing `3,12` changed to `3,0`.

    A,B
    2,11
    3,0
    1,10

Diff between original and altered version. Notice than we have a
deletion of two lines and two insertions.

``` diff
A,B
-1,10
2,11
-3,12
+3,0
+1,10
```

Ensuring that the observations are always sorted in the same way thus
helps minimizing the diff. The sorted version of the same altered
version looks like the example below.

    A,B
    1,10
    2,11
    3,0

Diff between original and the sorted alternate version. Notice that all
changes revert to actual changes in the information content. Another
benefit is that changes are easily spotted in the diff. A deletion
without insertion on the next line is a removed observation. An
insertion without preceding deletion is a new observation. A deletion
followed by an insertion is an updated observation.

``` diff
A,B
1,10
2,11
-3,12
+3,0
```

This is where the `sorting` argument comes into play. If this argument
is not provided when writing a file for the first time, it will yield a
warning about the lack of sorting.
[`write_vc()`](https://ropensci.github.io/git2rdata/reference/write_vc.md)
then writes the observations in their current order. New versions of the
file will not apply any sorting either, leaving this burden to the user.
The changed hash for the data file illustrates this in the example
below. The metadata hash remains the same.

``` r

library(git2rdata)
write_vc(x, file = "row_order", root = root)
#> Warning: `digits` was not set. Setting is automatically to 6. See ?meta
#> Warning: No sorting applied.
#> Sorting is strongly recommended in combination with version control.
#> 2b0ac8243ca27ed3d983ba8fc27a3bca7ca8f39d 79e04b2ecff2c1eac8ededc69ba09311f38f74da 
#>                          "row_order.tsv"                          "row_order.yml"
write_vc(x[sample(nrow(x)), ], file = "row_order", root = root)
#> Warning: No sorting applied.
#> Sorting is strongly recommended in combination with version control.
#> 8b6ba8f35315ad27871c5e4725d2430089ba0942 79e04b2ecff2c1eac8ededc69ba09311f38f74da 
#>                          "row_order.tsv"                          "row_order.yml"
```

`sorting` should contain a vector of variable names. The observations
are automatically sorted along these variables. Now we get an error
because the set of sorting variables has changed. The metadata stores
the set of sorting variables. Changing the sorting can potentially lead
to large diffs, which `git2rdata` tries to avoid as much as possible.

From this moment on we will store the output of
[`write_vc()`](https://ropensci.github.io/git2rdata/reference/write_vc.md)
in an object reduce output.

``` r

fn <- write_vc(x, "row_order", root, sorting = "y")
#> Warning: Sorting on 'y' results in ties.
#> Add extra sorting variables to ensure small diffs.
#> Error: The data was not overwritten because of the issues below.
#> See vignette('version_control', package = 'git2rdata') for more information.
#> 
#> - The sorting variables changed.
#>     - Sorting for the new data: 'y'.
#>     - Sorting for the old data: .
```

Using `strict = FALSE` turns such errors into warnings and allows to
update the file. Notice that we get a new warning: the variable we used
for sorting resulted in ties, thus the order of the observations is not
guaranteed to be stable. The solution is to use more or different
variables. We’ll need `strict = FALSE` again to override the change in
sorting variables.

``` r

fn <- write_vc(x, "row_order", root, sorting = "y", strict = FALSE)
#> Warning: Sorting on 'y' results in ties.
#> Add extra sorting variables to ensure small diffs.
#> Warning: Changes in the metadata may lead to unnecessarily large diffs.
#> See vignette('version_control', package = 'git2rdata') for more information.
#> 
#> - The sorting variables changed.
#>     - Sorting for the new data: 'y'.
#>     - Sorting for the old data: .
fn <- write_vc(x, "row_order", root, sorting = c("y", "x"), strict = FALSE)
#> Warning: Changes in the metadata may lead to unnecessarily large diffs.
#> See vignette('version_control', package = 'git2rdata') for more information.
#> 
#> - The sorting variables changed.
#>     - Sorting for the new data: 'y', 'x'.
#>     - Sorting for the old data: 'y'.
```

Once we have defined the sorting, we may omit the `sorting` argument
when writing new versions. `write_vc` uses the sorting as defined in the
existing metadata. It checks for potential ties. Ties results in a
warning.

``` r

print_file <- function(file, root, n = -1) {
  fn <- file.path(root, file)
  data <- readLines(fn, n = n)
  cat(data, sep = "\n")
}
print_file("row_order.yml", root, 7)
#> ..generic:
#>   git2rdata: 0.5.1
#>   optimize: yes
#>   NA string: NA
#>   sorting:
#>   - 'y'
#>   - x
fn <- write_vc(x[sample(nrow(x)), ], "row_order", root)
fn <- write_vc(x[sample(nrow(x)), ], "row_order", root, sorting = c("y", "x"))
fn <- write_vc(x[sample(nrow(x), replace = TRUE), ], "row_order", root)
```

## Sorting Variables

The order of the variables (columns) has an even bigger impact on a row
based diff. Let’s revisit our minimal example. Suppose that we swap `A`
and `B` from our [original example](#sorting-observations). The new data
looks as below.

    B,A
    10,1
    11,2
    13,3

The resulting diff is maximal because every single row changed. Yet none
of the information changed. Hence, maintaining column order is crucial
when storing dataframes as plain text files under version control. The
[`vignette("efficiency", package = "git2rdata")`](https://ropensci.github.io/git2rdata/articles/efficiency.md)
vignette illustrates this on a more realistic data set.

``` diff
-A,B
+B,A
-1,10
+10,1
-2,11
+11,2
-3,13
+13,3
```

When
[`write_vc()`](https://ropensci.github.io/git2rdata/reference/write_vc.md)
writes a dataframe for the first time, it stores the original order of
the columns in the metadata. From that moment on,
[`write_vc()`](https://ropensci.github.io/git2rdata/reference/write_vc.md)
uses the order stored in the metadata. The example below writes the same
data set twice. The second version contains identical information but
randomizes the order of the observations and the columns. The sorting by
the internals of
[`write_vc()`](https://ropensci.github.io/git2rdata/reference/write_vc.md)
will undo this randomization, resulting in an unchanged file.

``` r

write_vc(x, "column_order", root, sorting = c("x", "abc"))
#> Warning: `digits` was not set. Setting is automatically to 6. See ?meta
#> a9dcf3e5c2c2b820683c66de8e97c70826218670 0d8985d9b4bb134b5381581f854c51447f8c9300 
#>                       "column_order.tsv"                       "column_order.yml"
print_file("column_order.tsv", root, n = 5)
#> x    y   z   abc def timestamp
#> A    1   18  0.572193    0   1537470720
#> B    2   14  -1.64221    0   1532424960
#> C    NA  5   0.0228714   NA  1521072000
#> D    2   20  -0.683184   NA  1539993600
write_vc(x[sample(nrow(x)), sample(ncol(x))], "column_order", root)
#> a9dcf3e5c2c2b820683c66de8e97c70826218670 0d8985d9b4bb134b5381581f854c51447f8c9300 
#>                       "column_order.tsv"                       "column_order.yml"
print_file("column_order.tsv", root, n = 5)
#> x    y   z   abc def timestamp
#> A    1   18  0.572193    0   1537470720
#> B    2   14  -1.64221    0   1532424960
#> C    NA  5   0.0228714   NA  1521072000
#> D    2   20  -0.683184   NA  1539993600
```

## Handling Factors Optimized

[`vignette("plain_text", package = "git2rdata")`](https://ropensci.github.io/git2rdata/articles/plain_text.md)
and
[`vignette("efficiency", package = "git2rdata")`](https://ropensci.github.io/git2rdata/articles/efficiency.md)
illustrate how we can store a factor more efficiently when storing their
index in the data file and the indices and labels in the metadata. We
take this even a bit further: what happens if new data arrives and we
need an extra factor level?

``` r

old <- data.frame(color = c("red", "blue"), stringsAsFactors = TRUE)
write_vc(old, "factor", root, sorting = "color")
#> ade0e1d70155140e5115f71efae4b15b27287b37 03c3898451e17cf436da59dd0e712606ea63a838 
#>                             "factor.tsv"                             "factor.yml"
print_file("factor.yml", root)
#> ..generic:
#>   git2rdata: 0.5.1
#>   optimize: yes
#>   NA string: NA
#>   sorting: color
#>   hash: 03c3898451e17cf436da59dd0e712606ea63a838
#>   data_hash: ade0e1d70155140e5115f71efae4b15b27287b37
#> color:
#>   class: factor
#>   labels:
#>   - blue
#>   - red
#>   index:
#>   - 1
#>   - 2
#>   ordered: no
```

Let’s add an observation with a new factor level. If we store the
updated dataframe in a new file, we see that the indices are different.
The factor level `"blue"` remains unchanged, but `"red"` becomes the
third level and get index `3` instead of index `2`. This could lead to a
large diff whereas the potential semantics (and thus the information
content) are not changed.

``` r

updated <- data.frame(
  color = c("red", "green", "blue"),
  stringsAsFactors = TRUE
)
write_vc(updated, "factor2", root, sorting = "color")
#> 74f0f3c72a5041344924bed321efedf45f5c5250 f2cc274714fef0b55e17ae432e99b73e5c880e2d 
#>                            "factor2.tsv"                            "factor2.yml"
print_file("factor2.yml", root)
#> ..generic:
#>   git2rdata: 0.5.1
#>   optimize: yes
#>   NA string: NA
#>   sorting: color
#>   hash: f2cc274714fef0b55e17ae432e99b73e5c880e2d
#>   data_hash: 74f0f3c72a5041344924bed321efedf45f5c5250
#> color:
#>   class: factor
#>   labels:
#>   - blue
#>   - green
#>   - red
#>   index:
#>   - 1
#>   - 2
#>   - 3
#>   ordered: no
```

When we try to overwrite the original data with the updated version, we
get an error because there is a change in factor levels and / or
indices. In this specific case, we decided that the change is OK and
force the writing by setting `strict = FALSE`. Notice that the original
labels (`"blue"` and `"red"`) keep their index, the new level
(`"green"`) gets the first available index number.

``` r

write_vc(updated, "factor", root)
#> Error: The data was not overwritten because of the issues below.
#> See vignette('version_control', package = 'git2rdata') for more information.
#> 
#> - New factor labels for 'color'.
#> - New indices for 'color'.
fn <- write_vc(updated, "factor", root, strict = FALSE)
#> Warning: Changes in the metadata may lead to unnecessarily large diffs.
#> See vignette('version_control', package = 'git2rdata') for more information.
#> 
#> - New factor labels for 'color'.
#> - New indices for 'color'.
print_file("factor.yml", root)
#> ..generic:
#>   git2rdata: 0.5.1
#>   optimize: yes
#>   NA string: NA
#>   sorting: color
#>   hash: e0ed4c773b2179346042fef6f8c22c42c22a7c00
#>   data_hash: bf0c9f17b88b2e8768abc914349bb32e86503654
#> color:
#>   class: factor
#>   labels:
#>   - blue
#>   - green
#>   - red
#>   index:
#>   - 1
#>   - 3
#>   - 2
#>   ordered: no
```

The next example removes the `"blue"` level and switches the order of
the remaining levels. Notice that the meta data retains the existing
indices. The order of the labels and indices reflects their new
ordering.

``` r

deleted <- data.frame(
  color = factor(c("red", "green"), levels = c("red", "green"))
)
write_vc(deleted, "factor", root, sorting = "color", strict = FALSE)
#> Warning: Changes in the metadata may lead to unnecessarily large diffs.
#> See vignette('version_control', package = 'git2rdata') for more information.
#> 
#> - New factor labels for 'color'.
#> - New indices for 'color'.
#> 1d15f9b5c154535e2e7d2d5cb5619af7da41a066 3cadfe4021fe5e2990d0bb057100c608e3b602fa 
#>                             "factor.tsv"                             "factor.yml"
print_file("factor.yml", root)
#> ..generic:
#>   git2rdata: 0.5.1
#>   optimize: yes
#>   NA string: NA
#>   sorting: color
#>   hash: 3cadfe4021fe5e2990d0bb057100c608e3b602fa
#>   data_hash: 1d15f9b5c154535e2e7d2d5cb5619af7da41a066
#> color:
#>   class: factor
#>   labels:
#>   - red
#>   - green
#>   index:
#>   - 2
#>   - 3
#>   ordered: no
```

Changing a factor to an ordered factor or *vice versa* will also keep
existing level indices.

``` r

ordered <- data.frame(
  color = factor(c("red", "green"), levels = c("red", "green"), ordered = TRUE)
)
write_vc(ordered, "factor", root, sorting = "color", strict = FALSE)
#> Warning: Changes in the metadata may lead to unnecessarily large diffs.
#> See vignette('version_control', package = 'git2rdata') for more information.
#> 
#> - 'color' changes from nominal to ordinal.
#> 1d15f9b5c154535e2e7d2d5cb5619af7da41a066 57ff604596058d60e97fbb9c93ee6869f32c1850 
#>                             "factor.tsv"                             "factor.yml"
print_file("factor.yml", root)
#> ..generic:
#>   git2rdata: 0.5.1
#>   optimize: yes
#>   NA string: NA
#>   sorting: color
#>   hash: 57ff604596058d60e97fbb9c93ee6869f32c1850
#>   data_hash: 1d15f9b5c154535e2e7d2d5cb5619af7da41a066
#> color:
#>   class: factor
#>   labels:
#>   - red
#>   - green
#>   index:
#>   - 2
#>   - 3
#>   ordered: yes
```

## Relabelling a Factor

The example below will store a dataframe, relabel the factor levels and
store it again using
[`write_vc()`](https://ropensci.github.io/git2rdata/reference/write_vc.md).
Notice the update of both the labels and the indices. Hence creating a
large diff, where updating the labels would do.

``` r

write_vc(old, "write_vc", root, sorting = "color")
#> ade0e1d70155140e5115f71efae4b15b27287b37 03c3898451e17cf436da59dd0e712606ea63a838 
#>                           "write_vc.tsv"                           "write_vc.yml"
print_file("write_vc.yml", root)
#> ..generic:
#>   git2rdata: 0.5.1
#>   optimize: yes
#>   NA string: NA
#>   sorting: color
#>   hash: 03c3898451e17cf436da59dd0e712606ea63a838
#>   data_hash: ade0e1d70155140e5115f71efae4b15b27287b37
#> color:
#>   class: factor
#>   labels:
#>   - blue
#>   - red
#>   index:
#>   - 1
#>   - 2
#>   ordered: no
relabeled <- old
# translate the color names to Dutch
levels(relabeled$color) <- c("blauw", "rood")
write_vc(relabeled, "write_vc", root, strict = FALSE)
#> Warning: Changes in the metadata may lead to unnecessarily large diffs.
#> See vignette('version_control', package = 'git2rdata') for more information.
#> 
#> - New factor labels for 'color'.
#> - New indices for 'color'.
#> bcf85634c3b33377842b37e4d21c3546f7572055 f6730454185caeb173c6883ce56200c376975567 
#>                           "write_vc.tsv"                           "write_vc.yml"
print_file("write_vc.yml", root)
#> ..generic:
#>   git2rdata: 0.5.1
#>   optimize: yes
#>   NA string: NA
#>   sorting: color
#>   hash: f6730454185caeb173c6883ce56200c376975567
#>   data_hash: bcf85634c3b33377842b37e4d21c3546f7572055
#> color:
#>   class: factor
#>   labels:
#>   - blauw
#>   - rood
#>   index:
#>   - 3
#>   - 4
#>   ordered: no
```

We created
[`relabel()`](https://ropensci.github.io/git2rdata/reference/relabel.md),
which changes the labels in the meta data while maintaining their
indices. It takes three arguments: the name of the data file, the root
and the change. `change` accepts two formats, a list or a dataframe. The
name of the list must match with the variable name of a factor in the
data. Each element of the list must be a named vector, the name being
the existing label and the value the new label. The dataframe format
requires a `factor`, `old` and `new` variable with one row for each
change in label.

``` r

write_vc(old, "relabel", root, sorting = "color")
#> ade0e1d70155140e5115f71efae4b15b27287b37 03c3898451e17cf436da59dd0e712606ea63a838 
#>                            "relabel.tsv"                            "relabel.yml"
relabel("relabel", root, change = list(color = c(red = "rood", blue = "blauw")))
print_file("relabel.yml", root)
#> ..generic:
#>   git2rdata: 0.5.1
#>   optimize: yes
#>   NA string: NA
#>   sorting: color
#>   hash: bb25c6cc455f6d8e52b7daeb176adf83d8c5b0f9
#>   data_hash: ade0e1d70155140e5115f71efae4b15b27287b37
#> color:
#>   class: factor
#>   labels:
#>   - blauw
#>   - rood
#>   index:
#>   - 1
#>   - 2
#>   ordered: no
relabel(
  "relabel", root,
  change = data.frame(
    factor = "color", old = "blauw", new = "blue", stringsAsFactors = TRUE
  )
)
print_file("relabel.yml", root)
#> ..generic:
#>   git2rdata: 0.5.1
#>   optimize: yes
#>   NA string: NA
#>   sorting: color
#>   hash: a4050f89a749abce203ae6e1fe6b41483d385c2d
#>   data_hash: ade0e1d70155140e5115f71efae4b15b27287b37
#> color:
#>   class: factor
#>   labels:
#>   - blue
#>   - rood
#>   index:
#>   - 1
#>   - 2
#>   ordered: no
```

A *caveat*:
[`relabel()`](https://ropensci.github.io/git2rdata/reference/relabel.md)
does not make sense when the data file uses verbose storage. The verbose
mode stores the factor labels and not their indices, in which case
relabelling a label will always yield a large diff. Hence,
[`relabel()`](https://ropensci.github.io/git2rdata/reference/relabel.md)
requires the optimized storage.

[^1]: *sensu* `git2rdata`
