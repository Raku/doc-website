#!/bin/sh
#
set -e

relpath="Website/plugins/typegraph/typegraphs"
abspath="/home/builder/cache/typegraphs"

if [ ! -s $relpath ]; then
  rm -rf $relpath
  mkdir -p $abspath
  ln -s $abspath $relpath
fi


