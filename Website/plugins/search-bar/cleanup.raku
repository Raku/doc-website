#!/usr/bin/env raku
use v6.d;
# cleanup the directory
sub ($pr, %processed, %options ) {
    'search-bar.js'.IO.spurt: '// This is a placeholder file for gather-js-jq, which is overwritten in compilation stage'
}