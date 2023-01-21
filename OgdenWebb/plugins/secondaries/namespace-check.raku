#!/usr/bin/env raku
use v6.d;
sub ( $pp, %options --> Array ) {
    if 'heading' ~~ any( $pp.plugin-datakeys ) {
       my %ns = $pp.get-data('heading');
        %ns<defs> = {};
    }
    else {
        $pp.add-data('heading', %( :defs( {} ), ) );
    }
    []
}