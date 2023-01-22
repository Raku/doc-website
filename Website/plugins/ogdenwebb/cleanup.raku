#!/usr/bin/env raku
use v6.d;
# cleanup the directory
sub ($pr, %processed, %options ) {
    'js/search.js'.IO.spurt: 'placeholder text'
}