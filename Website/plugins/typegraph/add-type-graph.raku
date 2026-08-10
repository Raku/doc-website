use v6.d;
use Doc::TypeGraph;
use Doc::TypeGraph::Viz;
use Collection::Progress;

sub ($pp, %options) {
    unless +'typegraphs'.IO.dir > 1
    {
        note 'No typegraphs. They need to be generated with bin_files/generate-typegraph-images.raku'' unless %options<no-status>;
        return ()
    }
    my %ns;
    my @files = 'typegraphs'.IO.dir(test => *.ends-with('.svg'))>>.relative('typegraphs')>>.IO>>.extension('');
    for @files {
        my $s = "typegraphs/$_\.svg".IO.slurp.subst( / ^ .+? <?before '<svg'> /, '');
        %ns<typegraphs>{ $_ } = $s;
    }
    if 'pod' ~~ $pp.plugin-datakeys {
        my %ns-ex := $pp.get-data('pod');
        %ns-ex<typegraphs> = %ns<typegraphs>;
    }
    else {
        $pp.add-data('pod', %ns)
    }
    @files.map( { ["assets/typegraphs/$_\.svg", 'myself', "typegraphs/$_\.svg"] } );
}
