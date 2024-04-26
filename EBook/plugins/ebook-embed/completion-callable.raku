use v6.d;
sub ($destination, $landing-place, $output-ext, %completion-options, %options) {
    my $ebook-path-name = %completion-options<ebook-embed><ebook-path-name>;
    my $unzipped = $destination.IO.resolve;
    indir($unzipped, { run 'zip', '-rq', $ebook-path-name, '.' } )
};
