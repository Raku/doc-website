#!/usr/bin/env raku
use v6.d;
sub ( $pp, %options) {
    my $js = 'raku-draft.js'.IO.slurp;
    my %ns = $pp.get-data('raku-repl');
    $js = qq:to/PREFIX/ ~ $js;
        let websocketPort = { %ns<websocket-port> };
        let websocketHost = '{ %ns<websocket-host> }';
        PREFIX
    'raku-repl.js'.IO.spurt: $js;
    []
}