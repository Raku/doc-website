use v6.d;
sub ( $pp, %options --> Array ) {
    if 'note' ~~ any( $pp.plugin-datakeys ) {
       my %ns = $pp.get-data('note');
        %ns<first-item> = [];
    }
    else {
        $pp.add-data('note', %( :first-item( [] ), ) );
    }
    []
}