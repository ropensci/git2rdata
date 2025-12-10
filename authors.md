# Authors and Citation

## Authors

- **[Thierry Onkelinx](https://www.muscardinus.be)**. Author,
  maintainer. [](https://orcid.org/0000-0001-8804-4216)  
  Research Institute for Nature and Forest (INBO)

- **Floris Vanderhaeghe**. Contributor.
  [](https://orcid.org/0000-0002-6378-6229)  
  Research Institute for Nature and Forest (INBO)

- **Peter Desmet**. Contributor.
  [](https://orcid.org/0000-0002-8442-8025)  
  Research Institute for Nature and Forest (INBO)

- **Els Lommelen**. Contributor.
  [](https://orcid.org/0000-0002-3481-5684)  
  Research Institute for Nature and Forest (INBO)

- **[![Research Institute for Nature and Forest
  (INBO)](https://inbo.github.io/checklist/reference/figures/logo-en.png)](https://www.vlaanderen.be/inbo/en-gb)**.
  Copyright holder, funder.
  [![ROR](https://raw.githubusercontent.com/ror-community/ror-logos/main/ror-icon-rgb.svg)](https://ror.org/https://ror.org/00j54wy13)

## Citation

Source:
[`inst/CITATION`](https://github.com/ropensci/git2rdata/blob/main/inst/CITATION)

Onkelinx, Thierry (2025) git2rdata: Store and Retrieve Data.frames in a
Git Repository. Version 0.5.1. https://ropensci.github.io/git2rdata/

    @Manual{,
      title = {git2rdata: Store and Retrieve Data.frames in a Git Repository. Version 0.5.1},
      author = {Thierry Onkelinx},
      year = {2025},
      url = {https://ropensci.github.io/git2rdata/},
      abstract = {The git2rdata package is an R package for writing and reading dataframes as plain text files. A metadata file stores important information. 1) Storing metadata allows to maintain the classes of variables. By default, git2rdata optimizes the data for file storage. The optimization is most effective on data containing factors. The optimization makes the data less human readable. The user can turn this off when they prefer a human readable format over smaller files. Details on the implementation are available in vignette("plain_text", package = "git2rdata"). 2) Storing metadata also allows smaller row based diffs between two consecutive commits. This is a useful feature when storing data as plain text files under version control. Details on this part of the implementation are available in vignette("version_control", package = "git2rdata"). Although we envisioned git2rdata with a git workflow in mind, you can use it in combination with other version control systems like subversion or mercurial. 3) git2rdata is a useful tool in a reproducible and traceable workflow. vignette("workflow", package = "git2rdata") gives a toy example. 4) vignette("efficiency", package = "git2rdata") provides some insight into the efficiency of file storage, git repository size and speed for writing and reading.},
      keywords = {git; version control; plain text data},
      doi = {10.5281/zenodo.1485309},
    }
