This repo contains a bunch of scripts which can be useful for typical toolchain/distro maintenance tasks:
* `gcc-build`, `llvm-build`: build compilers
* `gcc-bootstrap-and-regtest`: test a single GCC change (builds compiler, runs testsuite and compares results)
* `gcc-bisect`: bisect GCC regression
* `gcc-index`: set up ctags for GCC source dir
* `gcc-debug`: run GCC compiler proper under debugger
* `gcc-predefs`: print predefined GCC macros
* `gnu-compare-projects`: compare ChangeLogs of two OSS projects
* `deja-compare-checks`, `gcc-compare-checks`: compare two sets of Dejagnu reports
* `configure-build-install`: configure, build and install a typical Autoconf project
* `insert-license-header`: insert license header into all files in a folder
* `update-copyrights`: update copyright comments in all files in a folder
* `cpptags`, `pytags`: wrappers for `ctags` to generate tags for different languages
* `sh-boilerplate`, `py-boilerplate`: boilerplate code for different languages
* `git-all`: run Git command in all repos in current folder
* `py-linter`: Pylint wrapper

All the code is MIT-licensed.
