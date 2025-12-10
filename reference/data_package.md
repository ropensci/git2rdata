# Create a Data Package for a directory of CSV files

Create a `datapackage.json` file for a directory of CSV files. The
function will look for all `.csv` files in the directory and its
subdirectories. It will then create a `datapackage.json` file with the
metadata of each CSV file.

## Usage

``` r
data_package(path = ".")
```

## Arguments

- path:

  the directory in which to create the `datapackage.json` file.

## See also

Other storage:
[`display_metadata()`](https://ropensci.github.io/git2rdata/reference/display_metadata.md),
[`list_data()`](https://ropensci.github.io/git2rdata/reference/list_data.md),
[`prune_meta()`](https://ropensci.github.io/git2rdata/reference/prune_meta.md),
[`read_vc()`](https://ropensci.github.io/git2rdata/reference/read_vc.md),
[`relabel()`](https://ropensci.github.io/git2rdata/reference/relabel.md),
[`rename_variable()`](https://ropensci.github.io/git2rdata/reference/rename_variable.md),
[`rm_data()`](https://ropensci.github.io/git2rdata/reference/rm_data.md),
[`update_metadata()`](https://ropensci.github.io/git2rdata/reference/update_metadata.md),
[`verify_vc()`](https://ropensci.github.io/git2rdata/reference/verify_vc.md),
[`write_vc()`](https://ropensci.github.io/git2rdata/reference/write_vc.md)
