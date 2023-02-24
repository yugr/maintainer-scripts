This repo contains a bunch of scripts which can be useful
for typical toolchain/distro maintenance tasks:
* `boilerplate/*` : boilerplate codes for various languages
* `clang-format-all`: format files from top commit via clang-format
* `configure-build-install`: configure, build and install a typical Autoconf project
* `cpptags`, `pytags`: wrappers for `ctags` to generate tags for different languages
* `deja-compare-checks`, `gcc-compare-checks`: compare two sets of Dejagnu reports
* `find-binaries`: find all binary files in folder
* `gcc-build`, `llvm-build`: build compilers
* `gcc-bootstrap-and-regtest`: test a single GCC change (builds compiler, runs testsuite and compares results)
* `gcc-bisect`: bisect GCC regression
* `gcc-debug`: debug GCC compiler proper instead of driver
* `gcc-predefs`: print predefined GCC macros
* `gcc-tags`, `llvm-tags`: set up ctags for GCC/LLVM source dir (avoiding irrelevant subdirs and respecting supermacro)
* `gcov-tool-many`: apply `gcov-tool` to more than 2 files
* `git-all`: run Git command in all repos in current folder
* `git-bareize` : convert normal git repo to bare format
* `git-reset-dates`: change date of last N commits
* `gnu-compare-projects`: compare ChangeLogs of two OSS projects
* `insert-license-header`: insert license header into all files in a folder
* `lddr`: recursively applies ldd to all files in folder (and its subfolders)
* `llvm-collect-logs`, `llvm-splitlog`: generate Clang debug logs
* `llvm-classify-error`: print short summary of LLVM error log
* `llvm-print-fatpoints`: print fatpoints from LLVM MIR dump
* `llvm-print-crit-path`: print critical path from based on MachineScheduler's dump
* `mangle`: mangle function prototype (primitive types only)
* `py-lint`: wrapper around `pylint` to make it more usable
* `plot-percentiles`: a simple pyplot-based script which plots percentile-based benchmark summaries
* `straces`: open straces of all child processes in editor
* `touchall`: unify times of all files in folder
* `update-copyrights`: update copyright comments in all files in a folder

All the code is MIT-licensed.
