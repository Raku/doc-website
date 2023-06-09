#!/usr/bin/env raku
use v6.d;
sub ($pr, %processed, %options --> Array) {
    for <html html/routine html/syntax html/hashed> -> $d {
        for $d.IO.dir(test => *.ends-with('html')) {
            note "deleting $_"
               if %options<collection-info>;
            .unlink
        }
    }
    'prettyurls'.IO.unlink if 'prettyurls'.IO ~~ :e & :f;
    []
}