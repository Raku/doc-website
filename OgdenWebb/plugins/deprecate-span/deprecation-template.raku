#!/usr/bin/env raku
use v6.d;
%(
    format-d => sub (%prm, %tml) {
        '<span class="raku-deprecation" title="' ~ %prm<meta> ~ '">'
        ~ %prm<contents>
        ~ '</span>'
    },
);
