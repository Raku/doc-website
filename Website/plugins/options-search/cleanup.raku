#!/usr/bin/env raku
use v6.d;
# cleanup the directory
sub ($pr, %processed, %options ) {
    'searchData.json'.IO.unlink if 'searchData.json'.IO ~~ :e & :f
}