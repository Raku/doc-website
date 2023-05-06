use v6.d;
use File::Temp;
use JSON::Fast;

state $atom-highlights-path = set-highlight-basedir;
state $atom-highlighter;
state $highlighter-supply;
state &highlight = -> $frag { $frag };

if test-highlighter( $atom-highlights-path ) {
    $atom-highlighter = Proc::Async.new(
        "{ $atom-highlights-path }/node_modules/coffeescript/bin/coffee",
        "{ $atom-highlights-path }/highlight-filename-from-stdin.coffee", :r, :w);
    $highlighter-supply = $atom-highlighter.stdout.lines;
    # set up the highlighter closure
    &highlight = sub ( $frag ) {
        return $frag unless $frag ~~ Str:D;
        $atom-highlighter.start unless $atom-highlighter.started;

        my ($tmp_fname, $tmp_io) = tempfile;
        # the =comment is needed to trigger the atom highlighter when the code isn't unambiguously Raku
        $tmp_io.spurt: "=comment\n\n" ~ $frag, :close;
        my $promise = Promise.new;
        my $tap = $highlighter-supply.tap( -> $json {
            my $parsed-json = from-json($json);
            if $parsed-json<file> eq $tmp_fname {
                $promise.keep($parsed-json<html>);
                $tap.close();
            }
        } );
        $atom-highlighter.say($tmp_fname);
        await $promise;
        # get highlighted text remove raku trigger =comment
        $promise.result.subst(/ '<div' ~ '</div>' .+? /,'',:x(2) )
    }
}

sub set-highlight-basedir( --> Str ) {
    my $basedir = $*HOME;
    my $hilite-path = "$basedir/.local/lib".IO.d
            ?? "$basedir/.local/lib/raku-pod-render/highlights".IO.mkdir
            !! "$basedir/.raku-pod-render/highlights".IO.mkdir;
    exit 1 unless ~$hilite-path;
    ~$hilite-path
}
sub test-highlighter( Str $hilite-path --> Bool ) {
    ?("$hilite-path/package-lock.json".IO.f and "$hilite-path/atom-language-perl6".IO.d)
}

%(
    'block-code' => sub ( %prm, %tml ) {
        my token tag { '<' ~ '>' [ '/'? <-[ > ]>+ ] }
        my @tokens;
        my $rv = &highlight(%prm<contents>.subst(/ <tag> / , { @tokens.push( ~$/ ); "\xFF\xFF" }, :g));
        $rv.subst( / "\xFF\xFF" /, { @tokens.shift }, :g )
    }
)