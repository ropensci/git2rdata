## Test environments

* local
    * ubuntu 20.04.4 LTS, R 4.1.3
* github actions
    * macOS-latest, release
    * windows-latest, release
    * ubuntu 20.04, devel
    * ubuntu 20.04, oldrel
    * checklist package: ubuntu 20.04.4 LTS, R 4.1.3
* r-hub
    * debian: clang-devel, gcc-devel, gcc-patched, gcc-release
    * fedora: clang-devel, gcc-devel
    * macos: highsierra-release-cran
    * windows_x86_64: devel, oldrel, release

## R CMD check results

0 errors | 0 warnings | 0 note

r-hub gave a false positive note

Windows Server 2022, R-devel, 64 bit

checking for detritus in the temp directory ... NOTE
Found the following files/directories:
  'lastMiKTeXException'
  
