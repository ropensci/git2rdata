# Using the convert argument

## Introduction

The `convert` argument in
[`write_vc()`](https://ropensci.github.io/git2rdata/reference/write_vc.md)
and
[`read_vc()`](https://ropensci.github.io/git2rdata/reference/read_vc.md)
allows you to apply transformations to data columns during the write and
read operations. This is useful when you want to store data types that
`git2rdata` doesn’t support. The only requirement is that there exist
two functions in some R package that do the transformation. One function
should convert the unsupported data type into a supported data type. The
second function should revert the supported data type into the original
unsupported data type.

## Basic usage

The `convert` argument is a named list where:

- Names correspond to column names in your data frame
- Each element is a character vector of length 2 with names `write` and
  `read`
- Functions are specified in the format `"package::function"`

``` r

library(git2rdata)
root <- tempfile("git2rdata-convert")
dir.create(root)
```

## Example: case conversion

A simple example is converting text to uppercase for storage while
keeping it lowercase in R:

``` r

# Create sample data
data <- data.frame(
  id = 1:3,
  name = c("alice", "bob", "charlie"),
  stringsAsFactors = FALSE
)

# Write with case conversion
write_vc(
  data,
  file = "people",
  root = root,
  sorting = "id",
  convert = list(
    name = c(
      write = "base::toupper", # Convert to uppercase when writing
      read = "base::tolower" # Convert to lowercase when reading
    )
  )
)
```

    ## 766b5ac81e1dd8ac12c46ab0f765de87fa05b465 
    ##                             "people.tsv" 
    ## d4e04e976482cb8bfd5978f21be4ec353bf156a0 
    ##                             "people.yml"

The stored file contains the names in uppercase:

``` r

# Check the raw file content
raw_content <- readLines(file.path(root, "people.tsv"))
cat(raw_content, sep = "\n")
```

    ## id   name
    ## 1    ALICE
    ## 2    BOB
    ## 3    CHARLIE

When reading the data back, the conversion is automatically applied:

``` r

# Read the data back
result <- read_vc("people", root = root)
print(result)
```

    ##   id    name
    ## 1  1   alice
    ## 2  2     bob
    ## 3  3 charlie
    ## 
    ## Use `display_metadata()` to view the metadata.

``` r

# The convert specification is stored in the attributes
attr(result, "convert")
```

    ## $name
    ## [1] "base::toupper" "base::tolower"

## Multiple columns

You can apply conversions to multiple columns:

``` r

data2 <- data.frame(
  id = 1:2,
  first_name = c("alice", "bob"),
  last_name = c("smith", "jones"),
  stringsAsFactors = FALSE
)

write_vc(
  data2,
  file = "names",
  root = root,
  sorting = "id",
  convert = list(
    first_name = c(write = "base::toupper", read = "base::tolower"),
    last_name = c(write = "base::toupper", read = "base::tolower")
  )
)
```

    ## be646a79460482c4df21cbdbf3d1395140015240 
    ##                              "names.tsv" 
    ## 65167961915d41cf81854bd4f715e61ee96b3183 
    ##                              "names.yml"

``` r

result2 <- read_vc("names", root = root)
print(result2)
```

    ##   id first_name last_name
    ## 1  1      alice     smith
    ## 2  2        bob     jones
    ## 
    ## Use `display_metadata()` to view the metadata.

## Use cases

### Unsupported data type

`git2rdata` doesn’t have support for 64-bit integers. You can store them
by converting them into a character.

``` r

mtcars2 <- mtcars |>
  dplyr::mutate(cyl = bit64::as.integer64(cyl))
write_vc(
  mtcars2,
  file = "mtcars2",
  convert = list(
    cyl = c(write = "bit64::as.character", read = "bit64::as.integer64")
  )
)
```

### Storage optimization

Convert numeric data to a more compact string representation:

``` r

# Example with custom conversion functions
# (requires defining custom functions in a package)
write_vc(
  data,
  file = "data",
  root = root,
  sorting = "id",
  convert = list(
    large_number = c(
      write = "mypackage::to_scientific",
      read = "mypackage::from_scientific"
    )
  )
)
```

### Data standardization

Ensure consistent formatting across different data sources:

``` r

# Convert dates to ISO format
write_vc(
  data,
  file = "events",
  root = root,
  sorting = "id",
  convert = list(
    event_date = c(
      write = "mypackage::to_iso_date",
      read = "mypackage::from_iso_date"
    )
  )
)
```

## Important notes

- **Package availability**: All packages referenced in the `convert`
  argument must be available when calling
  [`write_vc()`](https://ropensci.github.io/git2rdata/reference/write_vc.md)
  and
  [`read_vc()`](https://ropensci.github.io/git2rdata/reference/read_vc.md).
  The function checks for package availability at read and write time.

- **Function validation**: The function validates that the specified
  functions exist in the specified packages.

- **Metadata storage**: Conversion specifications are stored in the
  metadata YAML file, ensuring that
  [`read_vc()`](https://ropensci.github.io/git2rdata/reference/read_vc.md)
  knows how to reverse the transformations.

- **Strict mode**: When updating existing files, changes to the
  `convert` argument are detected by `compare_meta()` and will trigger
  an error in strict mode or a warning in non-strict mode.

## Limitations

- The `convert` argument only accepts functions in the
  `package::function` format. Anonymous functions or functions from the
  global environment are not supported.

- Conversions must be reversible. The `read` function should be able to
  restore the original data from the converted form.

- The conversion is applied before
  [`meta()`](https://ropensci.github.io/git2rdata/reference/meta.md)
  processes the data, so optimizations (like factor encoding) work on
  the converted data.
