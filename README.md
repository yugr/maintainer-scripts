This repo contains a bunch of scripts which can be useful
for typical toolchain/distro maintenance tasks:
* `boilerplate/*` : boilerplate codes for various languages
* `configure-build-install`: configure, build and install a typical Autoconf project
* `cpptags`, `pytags`: wrappers for `ctags` to generate tags for different languages
* `deja-compare-checks`, `gcc-compare-checks`: compare two sets of Dejagnu reports
* `gcc-build`, `llvm-build`: build compilers
* `gcc-bootstrap-and-regtest`: test a single GCC change (builds compiler, runs testsuite and compares results)
* `gcc-bisect`: bisect GCC regression
* `gcc-index`: set up ctags for GCC source dir (avoiding irrelevant subdirs and respecting supermacro)
* `gcc-debug`: debug GCC compiler proper instead of driver
* `gcc-predefs`: print predefined GCC macros
* `lddr`: recursively applies ldd to all files in folder (and its subfolders)
* `llvm-collect-logs`, `llvm-splitlog`: generate Clang debug logs
* `llvm-classify-error`: print short summary of LLVM error log
* `llvm-print-fatpoints`: print fatpoints from LLVM MIR dump
* `llvm-print-crit-path`: print critical path from based on MachineScheduler's dump
* `mangle`: mangle function prototype (primitive types only)
* `git-all`: run Git command in all repos in current folder
* `git-bareize` : convert normal git repo to bare format
* `git-reset-dates`: change date of last N commits
* `gnu-compare-projects`: compare ChangeLogs of two OSS projects
* `insert-license-header`: insert license header into all files in a folder
* `py-lint`: wrapper around `pylint` to make it more usable
* `update-copyrights`: update copyright comments in all files in a folder

All the code is MIT-licensed.
