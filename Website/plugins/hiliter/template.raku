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

my %hilight-langs = %(
    'HTML' => 'xml',
    'XML' => 'xml',
    'Bash' => 'bash',
    'C++' => 'cpp',
    'C#' => 'csharp',
    'CSS' => 'css',
    'Markdown' => 'markdown',
    'Diff' => 'diff',
    'Ruby' => 'ruby',
    'Go' => 'go',
    'TOML, also INI' => 'ini',
    'Java' => 'java',
    'JavaScript' => 'javascript',
    'JSON' => 'json',
    'Kotlin' => 'kotlin',
    'Less' => 'less',
    'Lua' => 'lua',
    'Makefile' => 'makefile',
    'Perl' => 'perl',
    'Objective-C' => 'objectivec',
    'PHP' => 'php',
    'PHP Template' => 'php-template',
    'Python' => 'python',
    'Python REPL' => 'python-repl',
    'R' => 'r',
    'Rust' => 'rust',
    'SCSS' => 'scss',
    'Shell Session' => 'shell',
    'SQL' => 'sql',
    'Swift' => 'swift',
    'YAML' => 'yaml',
    'TypeScript' => 'typescript',
    'Visual Basic .NET' => 'vbnet',
    'Haskell' => 'haskell',
);

# Callable returns a hash
%(
    block-code => sub (%prm, %tml) {
        my regex marker {
            "\xFF\xFF" ~ "\xFF\xFF" $<content> = (.+?)
        };
        # if :lang is set != raku / rakudoc, then enable highlightjs
        # otherwise pass through Raku syntax highlighter.
        my $code;
        my $syntax-label;
        if %prm<lang>:exists {
            if %prm<lang> ~~ any( %hilight-langs.keys ) {
                $syntax-label = %prm<lang>.tc ~  ' highlighting by highlight-js';
                $code = qq:to/HILIGHT/;
                    <pre class="browser-hl">
                    <code class="language-{ %hilight-langs{ %prm<lang> } }">{ %prm<contents> }
                    </code></pre>
                    HILIGHT
            }
            elsif %prm<lang> ~~ any( <Raku Rakudoc raku rakudoc> ) {
                $syntax-label = %prm<lang>.tc ~ ' highlighting';
            }
            else {
                $syntax-label = "｢{ %prm<lang> }｣ without highlighting";
                $code = qq:to/NOHIGHS/;
                    <pre class="nohighlights">
                    { %tml<escaped>( %prm<contents> ) }
                    </pre>
                    NOHIGHS
            }
        }
        else {
            $syntax-label = 'Raku highlighting';
        }
        without $code {
            my @tokens;
            my $t;
            my $parsed = %prm<contents> ~~ / ^ .*? [<marker> .*?]+ $/;
            if $parsed {
                for $parsed.chunks -> $c {
                    if $c.key eq 'marker' {
                        $t ~= "\xFF\xFF";
                        @tokens.push: $c.value<content>.Str;
                    }
                    else {
                        $t ~= $c.value
                    }
                }
                %prm<contents> = $t;
            }
            $syntax-label = (%prm<lang> // 'Raku').tc ~ ' highlighting';
            $code = &highlight(%prm<contents>);
            $code .= subst( / '<pre class="' /, '<pre class="nohighlights cm-s-ayaya ');
            $code .= subst( / "\xFF\xFF" /, { @tokens.shift }, :g );
        }
        qq[
            <div class="raku-code raku-lang">
                <button class="copy-code" title="Copy code"><i class="far fa-clipboard"></i></button>
                <label>$syntax-label\</label>
                <div>$code\</div>
            </div>
        ]
    },
)