#!/usr/bin/env raku
use v6.d;
use Doc::TypeGraph;
use Doc::TypeGraph::Viz;

my $viz = Doc::TypeGraph::Viz.new;
my $tg  = Doc::TypeGraph.new-from-file('type-graph.txt');
$viz.write-type-graph-images(path => ".",
    :force,
    type-graph => $tg);
