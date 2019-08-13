---
name: Feature Request
about: Suggest an idea for this project
---
<!-- IF THIS INVOLVES AUTHENTICATION: DO NOT SHARE YOUR USERNAME/PASSWORD, OR API KEYS/TOKENS IN THIS ISSUE - MOST LIKELY THE MAINTAINER WILL HAVE THEIR OWN EQUIVALENT KEY -->

<!-- Please describe the feature you propose as detailed as possible. 
If possible, add some code examples below indicating how the updated code should work.
Consider writing it as a <a href = "https://testthat.r-lib.org/">testthat</a> unit test-->

```r
# a silly feature request, fails under the current implementation
b <- 1 + 1
stopifnot(all.equal(b == 3))
```

```r
# testthat version of the silly feature request
expect_equal(1 + 1, 3)
```
