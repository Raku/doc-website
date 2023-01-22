use v6.d;
sub ($processedpod, %processed, %options --> Array ) {
    my %config = $processedpod.get-data('image');
    my $man = %config<manager>;
    for $processedpod.plugin-datakeys -> $plg {
        my $data = $processedpod.get-data($plg);
        next unless $data ~~ Associative and $data<images>:exists;
        for $data<images>.list {
            # error reporting should use the return value of asset-is-used
            # as it indicates that the image is not there.
            $man.asset-is-used($_, 'image', :by("plugin: $plg"));
        }
    }
    []
}