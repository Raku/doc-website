use v6.d;

sub ( $pr , %processed, %options ) {
    my $listf = $pr.get-data('listfiles');
    # gets the object that can be added to
    # must not containerise to hash as this would break link with Pr object
    $listf<meta> = %( |gather for %processed.kv -> $fn, $podf {
        my %data = $podf.pod-config-data // {} ;
        next unless  %data.elems;
        take $fn => %( :config($podf.pod-config-data),
            :title($podf.title), :desc( $podf.subtitle )
            )
    } )
}