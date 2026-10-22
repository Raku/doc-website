use experimental :rakuast;
use RakuDoc::Render;
use Introspection-Map;

unit class Doc-Website::Plugin::TypeGraphs;

has %.config =
        :name-space<TypeGraphs>,
        :version<0.2.0>,
        :license<Artistic-2.0>,
        :credit<finanalyst>,
        :authors<finanalyst>,
        add-typegraph => -> $rdp, $lang, $fn, $ast {
            self.add-typegraph($rdp, $lang, $fn, $ast)
        },
        ;

method enable(RakuDoc::Processor:D $rdp) {
    $rdp.add-data(%!config<name-space>, %!config);
}
#| add a GraphViz block to the AST if the filename matches a dot description
method add-typegraph($rdp, $lang, $fn, $ast) {
    return unless $fn.starts-with('Type');
    # because we are looking at the source file name
    my $desc = $fn.subst(/ ^ 'Type/' /, '').subst(/ '/' /, '', :g);
    my $dot = generate-dot($desc);
    say "$fn { $dot.so ?? 'has' !! 'does not have' } an introspection typegraph"
        if $rdp.templates.data<trace> and $rdp.templates.data<trace> ~~ / << <{ %!config<name-space> }> >> /;
    return unless $dot;
    # we have a graph matching the filename, so add a GraphViz block
    # for AST to work properly, the part we want has to be embedded in a rakudoc block
    my $block = qq:to/BLK/.AST.rakudoc.head.paragraphs.head;
        =begin rakudoc
        =begin Graphviz :caption('Class relation diagram') :toc
        $dot
        =end Graphviz
        =end rakudoc
        BLK

    $ast.rakudoc.head.add-paragraph($block);
}
