# Creating data packages

## Introduction

The
[`data_package()`](https://ropensci.github.io/git2rdata/reference/data_package.md)
function creates a `datapackage.json` file for a directory containing
CSV files that were created by `git2rdata`. This makes your data
compatible with the [Frictionless Data](https://frictionlessdata.io/)
specification, allowing other tools and platforms to discover and use
your data.

A data package is a simple container format for describing a collection
of data files. The `datapackage.json` file provides metadata about the
package and its resources (data files).

## Basic usage

``` r

library(git2rdata)
root <- tempfile("git2rdata-package")
dir.create(root)
```

First, create some data files in non-optimized format (CSV):

``` r

# Write several datasets in non-optimized (CSV) format
write_vc(
  iris,
  file = "iris",
  root = root,
  sorting = c("Species", "Sepal.Length"),
  optimize = FALSE # Use CSV format instead of optimized TSV
)
```

    ## Warning: `digits` was not set. Setting is automatically to 6. See ?meta

    ## Warning: Sorting on 'Species', 'Sepal.Length' results in ties.
    ## Add extra sorting variables to ensure small diffs.

    ## 2dbb3bc1688b7302a8a676761e5ada82f0a39656 
    ##                               "iris.csv" 
    ## 441db0f89c1c2d72ab3ff613dbdfcdc8d73e1804 
    ##                               "iris.yml"

``` r

write_vc(
  mtcars,
  file = "mtcars",
  root = root,
  sorting = "mpg",
  optimize = FALSE
)
```

    ## Warning: `digits` was not set. Setting is automatically to 6. See ?meta

    ## Warning: Sorting on 'mpg' results in ties.
    ## Add extra sorting variables to ensure small diffs.

    ## 73b6f3fcee60fe52281dba4b3ab0125294373a84 
    ##                             "mtcars.csv" 
    ## b887465e051c1d5229adff3f783e56f54c2b5369 
    ##                             "mtcars.yml"

``` r

# Check what files were created
list.files(root, recursive = TRUE)
```

    ## [1] "iris.csv"   "iris.yml"   "mtcars.csv" "mtcars.yml"

Now create the data package:

``` r

# Create the datapackage.json file
package_file <- data_package(root)
cat("Created:", package_file, "\n")
```

    ## Created: /tmp/RtmpcgqZIt/git2rdata-package1581564e4810/datapackage.json

## Package contents

The `datapackage.json` file contains metadata for each CSV file:

``` r

# Read and display the package file
package_data <- jsonlite::read_json(package_file)

# Show the structure
str(package_data, max.level = 2)
```

    ## List of 1
    ##  $ resources:List of 2
    ##   ..$ :List of 7
    ##   ..$ :List of 7

Each resource in the package includes:

- **name**: The name of the dataset
- **path**: The relative path to the CSV file
- **profile**: The profile type (tabular-data-resource)
- **schema**: The schema describing the data structure

## Schema information

The schema for each resource describes the fields (columns) in the data:

``` r

# Show the schema for the iris dataset
iris_resource <- package_data$resources[[1]]
cat("Resource name:", iris_resource$name, "\n")
```

    ## Resource name: iris.csv

``` r

cat("Number of fields:", length(iris_resource$schema$fields), "\n\n")
```

    ## Number of fields: 5

``` r

# Show first few fields
for (i in seq_len(min(3, length(iris_resource$schema$fields)))) {
  field <- iris_resource$schema$fields[[i]]
  cat(sprintf(
    "Field %d: %s (type: %s)\n",
    i,
    field$name,
    field$type
  ))
}
```

    ## Field 1: Sepal.Length (type: number)
    ## Field 2: Sepal.Width (type: number)
    ## Field 3: Petal.Length (type: number)

## Important notes

### CSV format required

[`data_package()`](https://ropensci.github.io/git2rdata/reference/data_package.md)
only works with non-optimized git2rdata objects (CSV files). This is
because the Frictionless Data specification expects CSV format.

``` r

# This will fail because optimized files use TSV format
optimized_root <- tempfile("git2rdata-optimized")
dir.create(optimized_root)

write_vc(
  iris,
  file = "iris",
  root = optimized_root,
  sorting = "Species",
  optimize = TRUE # This creates TSV files
)
```

    ## Warning: `digits` was not set. Setting is automatically to 6. See ?meta

    ## Warning: Sorting on 'Species' results in ties.
    ## Add extra sorting variables to ensure small diffs.

    ## 21e3457b30b4165a413377d29f4844a95ed24634 
    ##                               "iris.tsv" 
    ## ee01b10edc7294f2c1420811e93f9849db63013d 
    ##                               "iris.yml"

``` r

# This will fail with an error
try(data_package(optimized_root))
```

    ## Error in data_package(optimized_root) : 
    ##   no non-optimized git2rdata objects found at `path`

``` r

unlink(optimized_root, recursive = TRUE)
```

### Metadata integration

The function reads the git2rdata metadata (`.yml` files) to extract
field information, including:

- Field names
- Field types (mapped to Frictionless Data types)
- Factor levels (for categorical data)
- Description (if available through
  [`update_metadata()`](https://ropensci.github.io/git2rdata/reference/update_metadata.md))

### Recursive search

The function searches recursively in the specified directory, so you can
organize your data files in subdirectories:

``` r

# Create a subdirectory
subdir <- file.path(root, "subset")
dir.create(subdir)

# Write data in subdirectory
write_vc(
  head(iris, 50),
  file = file.path("subset", "iris_subset"),
  root = root,
  sorting = "Species",
  optimize = FALSE
)
```

    ## Warning: `digits` was not set. Setting is automatically to 6. See ?meta

    ## Warning: Sorting on 'Species' results in ties.
    ## Add extra sorting variables to ensure small diffs.

    ## 85c3f140752ebb46c472d74cb5ee5fd632fc1bcb 
    ##                 "subset/iris_subset.csv" 
    ## fe35efaf05acf4614ff9551ef60441db70fd82db 
    ##                 "subset/iris_subset.yml"

``` r

# Recreate the package - it will include the subdirectory file
data_package(root)
```

    ## [1] "/tmp/RtmpcgqZIt/git2rdata-package1581564e4810/datapackage.json"

``` r

# Check the package contents
package_data <- jsonlite::read_json(package_file)
cat("Number of resources:", length(package_data$resources), "\n")
```

    ## Number of resources: 3

## Use cases

### Data sharing

Create a data package to share your datasets with others:

``` r

# After creating your data files
write_vc(my_data, "my_data", root = "data", optimize = FALSE)

# Create the package
data_package("data")

# Share the entire 'data' directory
# Others can now use Frictionless Data tools to read your data
```

### Data validation

The Frictionless Data ecosystem provides tools to validate data
packages:

``` r

# After creating the package, use frictionless-py or other tools
# to validate your data package
system("frictionless validate datapackage.json")
```

### Data catalogs

Data packages can be published to data catalogs and portals that support
the Frictionless Data specification, making your data discoverable.

## See also

- [Frictionless Data documentation](https://frictionlessdata.io/)
- [Data Package
  specification](https://specs.frictionlessdata.io/data-package/)
- The `metadata` vignette for adding descriptions to your data
