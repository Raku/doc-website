#!/usr/bin/env raku
use v6.d;
use File::Directory::Tree;
use Doc::TypeGraph;
use Doc::TypeGraph::Viz;
=comment All the directories and file locations are hard coded at present because this
program is not intended for general use


sub MAIN(
        $plugin-dir = 'Website/plugins/typegraph',  #= directory where Typegraph plugin resides
        Bool :f($force) = False #= if directory populated True = first empty  directory, or False = fail
         )
{
    exit note "Cannot find directory ｢$plugin-dir｣, run this program from repo root directory"
    unless $plugin-dir.IO ~~ :d;
    my $typegraphs = "$plugin-dir/typegraphs".IO;
    if $typegraphs.dir.elems > 1 {
        if $force { empty-directory $typegraphs }
        else { exit note "｢$typegraphs｣ is not empty, use '-f / --force' flag to first empty" }
    }
    chdir $plugin-dir;
    my $viz = Doc::TypeGraph::Viz.new;
    my $tg = Doc::TypeGraph.new-from-file('type-graph.txt');
    $viz.write-type-graph-images(path => "typegraphs",
            :force,
            type-graph => $tg);
    .unlink for 'typegraphs'.IO.dir(test => *.ends-with('.dot'));
    for 'typegraphs'.IO.dir {
        if .Str ~~ / 'int.svg' / {
            .rename: .Str.subst(/ 'type-graph-' /, 'native-').subst(/ \:\: /, '', :g)
        }
        else {
            .rename: .Str.subst(/ 'type-graph-' /, '').subst(/ \:\: /, '', :g)
        }
    }
}
