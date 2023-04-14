use v6.d;
sub ( $pp, %options ) {
    my %ns := $pp.get-data('generated');
    for $pp.get-data('generation-data').kv -> $k, $v {
        %ns{ $k } = $v
    }
    []
}
