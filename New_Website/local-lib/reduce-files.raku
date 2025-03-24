#!/usr/bin/env raku
use v6.d;
for (dir) {
    when *.ends-with('svg') { .unlink }
    when *.ends-with('dot') {
        .rename(.basename.substr(11).IO.extension('dot',:2parts) )
    }
}
