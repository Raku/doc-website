use v6.d;
sub ($source-cache, $mode-cache, Bool $full-render,  $source-root, $mode-root, %p-opts, %options) {
    for $source-cache.sources -> $k {
        next unless $k ~~ / ^ (.+) ('/Language/' | '/Type/' | '/Programs/' | '/Native/' ) (.+) $/;
        $source-cache.add-alias($k, :alias($0 ~ $1.lc ~ $2)).mask($k);
    }
}