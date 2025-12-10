# Adding metadata

## Introduction

`git2rdata` supports extra metadata since version 0.4.1. Metadata is
stored in a separate file with the same name as the data file, but with
the extension `.yml`. The metadata file is a YAML file with a specific
structure. The metadata file contains a generic section and a section
for each field in the data file. The generic section contains
information about the data file as a whole. The fields sections contain
information about the fields in the data file. The metadata file is
stored in the same directory as the data file.

The generic section contains the following mandatory properties,
automatically created by `git2rdata`:

- `git2rdata`: the version of `git2rdata` used to create the metadata.
- `datahash`: the hash of the data file.
- `hash`: the hash of the metadata file.
- `optimize`: a logical indicating whether the data file is optimized
  for `git2rdata`.
- `sorting`: a character vector with the names of the fields in the data
  file.
- `split_by`: a character vector with the names of the fields used to
  split the data file.
- `NA string`: the string used to represent missing values in the data
  file.

The generic section can contain the following optional properties:

- `table name`: the name of the dataset.
- `title`: the title of the dataset.
- `description`: a description of the dataset.

The fields sections contain the following mandatory properties,
automatically created by `git2rdata`:

- `type`: the type of the field.
- `class`: the class of the field.
- `levels`: the levels of the field (for factors).
- `index`: the index of the field (for factors).
- `NA string`: the string used to represent missing values in the field.

The fields sections can contain the following optional properties:

- `description`: a description of the field.

## Adding metadata

[`write_vc()`](https://ropensci.github.io/git2rdata/reference/write_vc.md)
only stores the mandatory properties in the metadata file.

``` r

library(git2rdata)
root <- tempfile("git2rdata-metadata")
dir.create(root)
write_vc(iris, file = "iris", root = root, sorting = "Sepal.Length")
```

    ## Warning: `digits` was not set. Setting is automatically to 6. See ?meta

    ## Warning: Sorting on 'Sepal.Length' results in ties.
    ## Add extra sorting variables to ensure small diffs.

    ## 9282fad022c924c16a76bd8b3c174e71fc4515fe 
    ##                               "iris.tsv" 
    ## f5eda4fcbe143eefc267a51a511110c604848272 
    ##                               "iris.yml"

## Reading metadata

[`read_vc()`](https://ropensci.github.io/git2rdata/reference/read_vc.md)
reads the metadata file and adds it as attributes to the `data.frame`.
[`print()`](https://rdrr.io/r/base/print.html) and
[`summary()`](https://rdrr.io/r/base/summary.html) alert the user to the
[`display_metadata()`](https://ropensci.github.io/git2rdata/reference/display_metadata.md)
function. This function displays the metadata of a `git2rdata` object.
Missing optional metadata results in an `NA` value in the output of
[`display_metadata()`](https://ropensci.github.io/git2rdata/reference/display_metadata.md).

``` r

my_iris <- read_vc("iris", root = root)
str(my_iris)
```

    ## Classes 'git2rdata' and 'data.frame':    150 obs. of  5 variables:
    ##  $ Sepal.Length: num  4.3 4.4 4.4 4.4 4.5 4.6 4.6 4.6 4.6 4.7 ...
    ##   ..- attr(*, "digits")= int 6
    ##  $ Sepal.Width : num  3 2.9 3 3.2 2.3 3.1 3.4 3.6 3.2 3.2 ...
    ##   ..- attr(*, "digits")= int 6
    ##  $ Petal.Length: num  1.1 1.4 1.3 1.3 1.3 1.5 1.4 1 1.4 1.3 ...
    ##   ..- attr(*, "digits")= int 6
    ##  $ Petal.Width : num  0.1 0.2 0.2 0.2 0.3 0.2 0.3 0.2 0.2 0.2 ...
    ##   ..- attr(*, "digits")= int 6
    ##  $ Species     : Factor w/ 3 levels "setosa","versicolor",..: 1 1 1 1 1 1 1 1 1 1 ...
    ##  - attr(*, "source")= Named chr [1:2] "/tmp/Rtmpgebwsa/git2rdata-metadata13ad118122f9/iris.tsv" "/tmp/Rtmpgebwsa/git2rdata-metadata13ad118122f9/iris.yml"
    ##   ..- attr(*, "names")= chr [1:2] "9282fad022c924c16a76bd8b3c174e71fc4515fe" "f5eda4fcbe143eefc267a51a511110c604848272"
    ##  - attr(*, "optimize")= logi TRUE
    ##  - attr(*, "sorting")= chr "Sepal.Length"

``` r

print(head(my_iris))
```

    ##   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
    ## 1          4.3         3.0          1.1         0.1  setosa
    ## 2          4.4         2.9          1.4         0.2  setosa
    ## 3          4.4         3.0          1.3         0.2  setosa
    ## 4          4.4         3.2          1.3         0.2  setosa
    ## 5          4.5         2.3          1.3         0.3  setosa
    ## 6          4.6         3.1          1.5         0.2  setosa
    ## 
    ## Use `display_metadata()` to view the metadata.

``` r

summary(my_iris)
```

    ##   Sepal.Length    Sepal.Width     Petal.Length    Petal.Width   
    ##  Min.   :4.300   Min.   :2.000   Min.   :1.000   Min.   :0.100  
    ##  1st Qu.:5.100   1st Qu.:2.800   1st Qu.:1.600   1st Qu.:0.300  
    ##  Median :5.800   Median :3.000   Median :4.350   Median :1.300  
    ##  Mean   :5.843   Mean   :3.057   Mean   :3.758   Mean   :1.199  
    ##  3rd Qu.:6.400   3rd Qu.:3.300   3rd Qu.:5.100   3rd Qu.:1.800  
    ##  Max.   :7.900   Max.   :4.400   Max.   :6.900   Max.   :2.500  
    ##        Species  
    ##  setosa    :50  
    ##  versicolor:50  
    ##  virginica :50  
    ##                 
    ##                 
    ##                 
    ## 
    ## Use `display_metadata()` to view the metadata.

``` r

display_metadata(my_iris)
```

    ## Table name: NA
    ## Title: NA
    ## Description: NA
    ## Path: /tmp/Rtmpgebwsa/git2rdata-metadata13ad118122f9/iris.tsv (9282fad022c924c16a76bd8b3c174e71fc4515fe), /tmp/Rtmpgebwsa/git2rdata-metadata13ad118122f9/iris.yml (f5eda4fcbe143eefc267a51a511110c604848272)
    ## Sorting order: Sepal.Length
    ## Optimized storage: TRUE
    ## Variables:
    ##   - Sepal.Length: NA
    ##   - Sepal.Width: NA
    ##   - Petal.Length: NA
    ##   - Petal.Width: NA
    ##   - Species: NA

## Updating the optional metadata

To add metadata to a `git2rdata` object, use the
[`update_metadata()`](https://ropensci.github.io/git2rdata/reference/update_metadata.md)
function. This function allows you to add or update the optional
metadata of a `git2rdata` object. Setting an argument to `NA` or an
empty string will remove the corresponding property from the metadata.
The function only updates the metadata file, not the data file. To see
the changes, read the object again before using
[`display_metadata()`](https://ropensci.github.io/git2rdata/reference/display_metadata.md).
Note that all the metadata is available in the `data.frame` as
attributes.

``` r

update_metadata(
  file = "iris", root = root, name = "iris", title = "Iris dataset",
  description = paste(
    "The Iris dataset is a multivariate dataset introduced by the British",
    "statistician and biologist Ronald Fisher in his 1936 paper The use of",
    "multiple measurements in taxonomic problems."
  ),
  field_description = c(
    Sepal.Length = "The length of the sepal in cm",
    Sepal.Width = "The width of the sepal in cm",
    Petal.Length = "The length of the petal in cm",
    Petal.Width = "The width of the petal in cm",
    Species = "The species of the iris"
  )
)
my_iris <- read_vc("iris", root = root)
display_metadata(my_iris)
```

    ## Table name: iris
    ## Title: Iris dataset
    ## Description: The Iris dataset is a multivariate dataset introduced by the British statistician and biologist Ronald Fisher in his 1936 paper The use of multiple measurements in taxonomic problems.
    ## Path: /tmp/Rtmpgebwsa/git2rdata-metadata13ad118122f9/iris.tsv (9282fad022c924c16a76bd8b3c174e71fc4515fe), /tmp/Rtmpgebwsa/git2rdata-metadata13ad118122f9/iris.yml (a8e8987f123e0aea13157081b03b47f2b039b1bf)
    ## Sorting order: Sepal.Length
    ## Optimized storage: TRUE
    ## Variables:
    ##   - Sepal.Length: The length of the sepal in cm
    ##   - Sepal.Width: The width of the sepal in cm
    ##   - Petal.Length: The length of the petal in cm
    ##   - Petal.Width: The width of the petal in cm
    ##   - Species: The species of the iris

``` r

str(my_iris)
```

    ## Classes 'git2rdata' and 'data.frame':    150 obs. of  5 variables:
    ##  $ Sepal.Length: num  4.3 4.4 4.4 4.4 4.5 4.6 4.6 4.6 4.6 4.7 ...
    ##   ..- attr(*, "digits")= int 6
    ##   ..- attr(*, "description")= chr "The length of the sepal in cm"
    ##  $ Sepal.Width : num  3 2.9 3 3.2 2.3 3.1 3.4 3.6 3.2 3.2 ...
    ##   ..- attr(*, "digits")= int 6
    ##   ..- attr(*, "description")= chr "The width of the sepal in cm"
    ##  $ Petal.Length: num  1.1 1.4 1.3 1.3 1.3 1.5 1.4 1 1.4 1.3 ...
    ##   ..- attr(*, "digits")= int 6
    ##   ..- attr(*, "description")= chr "The length of the petal in cm"
    ##  $ Petal.Width : num  0.1 0.2 0.2 0.2 0.3 0.2 0.3 0.2 0.2 0.2 ...
    ##   ..- attr(*, "digits")= int 6
    ##   ..- attr(*, "description")= chr "The width of the petal in cm"
    ##  $ Species     : Factor w/ 3 levels "setosa","versicolor",..: 1 1 1 1 1 1 1 1 1 1 ...
    ##   ..- attr(*, "description")= chr "The species of the iris"
    ##  - attr(*, "source")= Named chr [1:2] "/tmp/Rtmpgebwsa/git2rdata-metadata13ad118122f9/iris.tsv" "/tmp/Rtmpgebwsa/git2rdata-metadata13ad118122f9/iris.yml"
    ##   ..- attr(*, "names")= chr [1:2] "9282fad022c924c16a76bd8b3c174e71fc4515fe" "a8e8987f123e0aea13157081b03b47f2b039b1bf"
    ##  - attr(*, "table name")= chr "iris"
    ##  - attr(*, "title")= chr "Iris dataset"
    ##  - attr(*, "description")= chr "The Iris dataset is a multivariate dataset introduced by the British statistician and biologist Ronald Fisher i"| __truncated__
    ##  - attr(*, "optimize")= logi TRUE
    ##  - attr(*, "sorting")= chr "Sepal.Length"
