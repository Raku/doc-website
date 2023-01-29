#!/usr/bin/env raku
use v6.d;
sub ($pr, %processed, %options --> Array ) {
    note "deleting raku-repl.js from raku-repl" if %options<collection-info>;
    'raku-repl.js'.IO.unlink;
    []
}