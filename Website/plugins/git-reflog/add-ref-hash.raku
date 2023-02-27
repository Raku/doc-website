#!/usr/bin/env raku
use v6.d;
sub ($source-cache, $mode-cache, Bool $full-render,  $source-root, $mode-root, %p-opts, %options) {
    my $rep = $source-root.IO.parent;
    my $proc = run <<git -C $rep rev-parse --short HEAD>>, :out;
    my $reflog = $proc.out.slurp(:close).chomp;
    if $reflog {
        $reflog = '/tree/' ~ $reflog
    }
    else {
        $reflog = ''
    }
    'reflog.raku'.IO.spurt(qq:to/TEMP/);
    \%(
        git-reflog => sub (\%prm, \%tml) \{
            '\<p>from <a href="https://github.com/Raku/doc$reflog">github.com/Raku/doc$reflog\</a>\</p>'
        },
    );
    TEMP
}