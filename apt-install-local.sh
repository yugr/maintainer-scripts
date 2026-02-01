#!/bin/sh

# Copyright 2026 Yury Gribov
# 
# Use of this source code is governed by MIT license that can be
# found in the LICENSE.txt file.

# Install APT packages into local directory.
# This may be useful if you do not have root access on system.
#
# This script is quite hacky and will not work for all packages.
# By default it simple download and unpacks .deb files to destination directory.
# It can also (try to) run pre/post-install scripts (firstly fixing paths in them).
# Even after that you may need to fix configs in /etc to understand that
# they should use local directory instead of root.

set -eu
#set -x

if test $(whoami) = root; then
  echo 'This script is not meant to be run by root' >&2
  exit 1
fi

PREFIX=./root
RUN=

print_short_help() {
  cat <<EOF
Usage: $(basename $0) [options] pkgs...
Run \`$(basename $0) -h' for more details.
EOF
}

print_help() {
  cat <<EOF
Usage: $(basename $0) [options] pkgs
Download and install APT packages to subdirectory.

Options:
  -h, --help         Print help and exit.
  -o dir             Destination directory (default $PREFIX).
  -r                 Run pre/post-install scripts (DANGEROUS !!)

EOF
}

ARGS=$(getopt -o 'ho:r' --long 'help' -n $(basename $0) -- "$@")
eval set -- "$ARGS"

while true; do
  case "$1" in
  -o)
    PREFIX="$2"
    shift 2
    ;;
  -r)
    RUN=1
    shift
    ;;
  --help | -h)
    print_help
    exit 1
    ;;
    --)
      shift
      break
      ;;
  -*)
    echo "unknown option: $1" >&2
    exit 1
    ;;
  *)
    break
    ;;
  esac
done

if [ $# -lt 1 ]; then
  print_short_help >&2
  exit 1
fi

if test "$RUN" = 1; then
  cat <<EOF
-r is a dangerous option because it may damage files in your home directory.
It should only be run on temp. environments.
EOF
  while true; do
    read -p "Are you sure you wan't to continue? [y/N]: " yn
    case $yn in
    [Yy] | [Yy]es | YES )
      break
      ;;
    [Nn] | [Nn]o | NO | '' )
      exit 1
      ;;
    esac
  done
fi

PREFIX=$(realpath -s $PREFIX)
mkdir -p $PREFIX

DOWNLOAD=$PREFIX/download
mkdir -p $DOWNLOAD

pkgs=$(apt install --dry-run "$@" 2>/dev/null | awk '/^Inst /{print $2}')
for pkg in $pkgs; do
  (cd $DOWNLOAD && apt-get download $pkg)
done

UNPACK=$DOWNLOAD/unpack
mkdir -p $UNPACK

# TODO: A better way would be to intercept open() syscall from shell
#       and redirect them to prefixed files ?
add_prefix() {
  sed -i -e '
    s!^set -e$!!g;
    s!\(/usr\|/var\|^#\!\)/!\1@!g;
    s!\(/etc\|/usr\|/bin\|/sbin\|/lib\|/var\)!'$PREFIX'\1!g;
    s!\(/usr\|/var\|^#\!\)@!\1/!g;
    s!\<ucf !cp !g
    ' "$1"
}

export PATH=$PREFIX/bin:$PREFIX/sbin:$PREFIX/usr/bin:$PREFIX/usr/sbin${PATH:+:$PATH}
export LD_LIBRARY_PATH=$PREFIX/lib:$PREFIX/usr/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}

# Need to respect dependencies
for pkg in $pkgs; do
  debs=$(ls -1 $DOWNLOAD/*.deb | grep -F "$pkg")
  for pkg_deb in $debs; do
    pkg_full=$(basename $pkg_deb | sed -e 's/\.deb$//')
    dpkg-deb -R $pkg_deb $UNPACK/$pkg_full

    if test "$RUN" = 1; then
      if test -f $UNPACK/$pkg_full/DEBIAN/preinst; then
        add_prefix $UNPACK/$pkg_full/DEBIAN/preinst
        (cd $UNPACK/$pkg_full/DEBIAN && bash -x preinst install)
      fi
    fi

    dpkg -x $pkg_deb $PREFIX

    if test "$RUN" = 1; then
      for f in $(cd $UNPACK/$pkg_full && find -type f | grep -v DEBIAN); do
        test -f $PREFIX/$f
        if file $PREFIX/$f | grep 'shell script'; then
          add_prefix $PREFIX/$f
        fi
      done
      if test -f $UNPACK/$pkg_full/DEBIAN/postinst; then
        add_prefix $UNPACK/$pkg_full/DEBIAN/postinst
        (cd $UNPACK/$pkg_full/DEBIAN && bash -x postinst configure)
      fi
    fi
  done
done

# TODO: PYTHONPATH, etc.
cat >$PREFIX/env <<EOF
export PATH=$PREFIX/bin:$PREFIX/sbin:$PREFIX/usr/bin:$PREFIX/usr/sbin${PATH:+:$PATH}
export LD_LIBRARY_PATH=$PREFIX/lib:$PREFIX/usr/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig:$PREFIX/usr/lib/pkgconfig${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}
export MANPATH=$PREFIX/usr/share/man${MANPATH:+:$MANPATH}
EOF
