## Test environments
* local
    * ubuntu 18.04.5 LTS, R 4.0.3
* github actions
    * macOS-latest, release
    * windows-latest, release
    * ubuntu 20.04, devel
    * ubuntu 16.04, oldrel
    * checklist package: ubuntu 20.04.1, R 4.0.3
* r-hub
    * Windows Server 2008 R2 SP1, R-devel, 32/64 bit
    * Ubuntu Linux 16.04 LTS, R-release, GCC
    * Fedora Linux, R-devel, clang, gfortran

## R CMD check results

0 errors | 0 warnings | 0 note

r-hub gave a few false positive notes

* Windows Server 2008 R2 SP1, R-devel, 32/64 bit

```
Possibly mis-spelled words in DESCRIPTION:
  rdata (28:22, 31:33, 36:20, 40:48, 41:20, 43:24, 44:62, 45:62)
  workflow (41:37, 44:15, 44:36)
```

* Fedora Linux, R-devel, clang, gfortran

```
Possibly mis-spelled words in DESCRIPTION:
  rdata (28:22, 31:33, 36:20, 40:48, 41:20, 43:24, 44:62, 45:62)
```

Ubuntu Linux 16.04 LTS, R-release, GCC failed on r-hub because ICU is not
available on that build.

