#!/usr/bin/env raku
use v6.d;
sub ( $pp, %options --> Array ) {
    my $dir = 'images';
    my @move-to-dest;
    for $dir.IO.dir -> $fn {
        @move-to-dest.push( ("assets/$fn", 'myself', $fn ) );
    }
    @move-to-dest
}