#!/usr/bin/env raku
use v6.d;
sub ($pr, %processed, %options --> Array) {
    $pr.get-data('sqlite-db')<db-filename>.IO.unlink;
    []
}