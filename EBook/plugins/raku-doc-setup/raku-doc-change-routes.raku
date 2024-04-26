use v6.d;
sub ($source-cache, $mode-cache, Bool $full-render,  $source-root, $mode-root, %p-opts, %options) {
    # internal links are to lower case directories, so change from upper to lower
    # compress directory hierarchy because css can only be accessed from fixed structure in an epub
    for $source-cache.sources -> $k {
        next unless $k ~~ / ^ (.+) ('/Language/' | '/Type/' | '/Programs/' | '/Native/' ) (.+) $/;
        $source-cache.add-alias($k, :alias($0 ~ $1.lc ~ $2.subst(/ '/' /,'::',:g))).mask($k);
    }
    # move all structure files down a directory so they can access css
    for $mode-cache.sources -> $k {
        $mode-cache.add-alias( $k, :alias( "{$k.subst(/ $mode-root /, "$mode-root/packaging")}" )).mask($k)
    }
}