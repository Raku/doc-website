use v6.d;
use Doc::TypeGraph;
use Doc::TypeGraph::Viz;
use Collection::Progress;

sub ($pp, %options) {
    unless (
        ('typegraphs'.IO ~~ :e & :d)
        and ( 'type-graph.txt'.IO.modified le 'typegraphs'.IO.modified )
        and ( +'typegraphs'.IO.dir > 1 )
        )
    {
        note 'Generating Typegraphs' unless %options<no-status>;
        mkdir 'typegraphs' unless 'typegraphs'.IO ~~ :e & :d;
        my $viz = Doc::TypeGraph::Viz.new;
        my $tg  = Doc::TypeGraph.new-from-file('type-graph.txt');
        $viz.write-type-graph-images(path => "typegraphs",
            :force,
            type-graph => $tg);
        .unlink for 'typegraphs'.IO.dir( test => *.ends-with('.dot') );
        for 'typegraphs'.IO.dir {
            .rename: .Str.subst(/ 'type-graph-' /, '').subst(/ \:\: /, '', :g)
        }
    }
    my %ns;
    my @files = 'typegraphs'.IO.dir(test => *.ends-with('.svg'))>>.relative('typegraphs')>>.IO>>.extension('');
    for @files {
        my $s = "typegraphs/$_\.svg".IO.slurp.subst( / ^ .+? <?before '<svg'> /, '');
        $s ~~ s:g/ 'href=' \" ~ \" (.+?) / href="$0.html" /;
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
