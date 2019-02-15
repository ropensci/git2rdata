cv <- covr::package_coverage()
covr::report(cv)

cv <- covr::package_coverage(type = "examples")
covr::report(cv)

cv <- covr::package_coverage(type = "vignette")
covr::report(cv)

pkgdown::build_site()

goodpractice::gp()
