
sub ( $pp, %options ) {
    # need to move fonts in directory to asset file
    my $dir = 'fontawesome5_15_4/webfonts';
    my @move-to-dest;
    for $dir.IO.dir -> $fn {
        @move-to-dest.push( ('assets/' ~ $fn.IO.relative('fontawesome5_15_4'), 'myself', "$fn", ) );
    }
    @move-to-dest
}