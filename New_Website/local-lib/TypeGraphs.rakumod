use experimental :rakuast;
use RakuDoc::Render;


unit class Raku-Doc-Website::TypeGraphs;

has %.config =
        :name-space<TypeGraphs>,
        :version<0.1.0>,
        :license<Artistic-2.0>,
        :credit<finanalyst>,
        :authors<finanalyst>,
        add-typegraph => -> $rdp, $lang, $fn, $ast { self.add-typegraph( $rdp, $lang, $fn, $ast ) },
        ;
has %tgs;

submethod TWEAK {
    my @typegraph-io;
    if 'resources'.IO ~~ :e & :d {
        @typegraph-io = 'resources/typegraphs'.IO.dir;
        for @typegraph-io {
            %tgs{ .basename.IO.extension('').Str } = .slurp
        }
    }
    else {
        use MONKEY-SEE-NO-EVAL;
        my @list = EVAL %?RESOURCES<tg-list>.IO.slurp;
        no MONKEY-SEE-NO-EVAL;
        for @list {
            %tgs{ .substr(11).substr(0,*-4) } = %?RESOURCES{ $_ }.IO.slurp
        }
    }
}
method enable( RakuDoc::Processor:D $rdp ) {
    $rdp.add-data( %!config<name-space>, %!config );
}
#| add a GraphViz block to the AST if the filename matches a dot description
method add-typegraph( $rdp, $lang, $fn, $ast ) {
    return unless $fn.starts-with('type');
    my $desc = $fn.subst( / ^ 'type/' /,'').subst( / '/' /,'',:g);
    return unless %!tgs{ $desc }:exists;
    # we have a description matching the filename, so add a GraphViz block
    # for AST to work properly, the part we want has to be embedded in a rakudoc block
    my $block = qq:to/BLK/.AST.rakudoc.head.paragraphs.head;
        =begin rakudoc
        =begin Graphviz :caption('Class relation diagram')
        { %!tgs{ $desc} }
        =end Graphviz
        =end rakudoc
        BLK
    $ast.rakudoc.head.add-paragraph($block);
}
