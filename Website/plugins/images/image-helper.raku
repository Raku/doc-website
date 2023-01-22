sub ( $pp, %options ) {
    my $mnger = $pp.get-data('image-manager');
    $pp.add-data('image', $mnger);
    () # return empty list of triples, required of render plugins
}