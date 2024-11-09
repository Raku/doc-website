use v6.d;
use Rainbow;

my %hilight-langs = %(
    'HTML' => 'xml',
    'XML' => 'xml',
    'BASH' => 'bash',
    'C++' => 'cpp',
    'C#' => 'csharp',
    'SCSS' => 'css',
    'SASS' => 'css',
    'CSS' => 'css',
    'MARKDOWN' => 'markdown',
    'DIFF' => 'diff',
    'RUBY' => 'ruby',
    'GO' => 'go',
    'TOML' => 'ini',
    'INI' => 'ini',
    'JAVA' => 'java',
    'JAVASCRIPT' => 'javascript',
    'JSON' => 'json',
    'KOTLIN' => 'kotlin',
    'LESS' => 'less',
    'LUA' => 'lua',
    'MAKEFILE' => 'makefile',
    'PERL' => 'perl',
    'OBJECTIVE-C' => 'objectivec',
    'PHP' => 'php',
    'PHP-TEMPLATE' => 'php-template',
    'PHPTEMPLATE' => 'php-template',
    'PHP_TEMPLATE' => 'php-template',
    'PYTHON' => 'python',
    'PYTHON-REPL' => 'python-repl',
    'PYTHON_REPL' => 'python-repl',
    'R' => 'r',
    'RUST' => 'rust',
    'SCSS' => 'scss',
    'SHELL' => 'shell',
    'SQL' => 'sql',
    'SWIFT' => 'swift',
    'YAML' => 'yaml',
    'TYPESCRIPT' => 'typescript',
    'BASIC' => 'vbnet',
    '.NET' => 'vbnet',
    'HASKELL' => 'haskell',
);

# Callable returns a hash
%(
    block-code => sub (%prm, %tml) {
        # if :lang is set != raku / rakudoc, then enable highlightjs
        # otherwise pass through Raku syntax highlighter.
        my $code;
        my $syntax-label;
        if %prm<lang>:exists {
            if %prm<lang>.uc ~~ any( %hilight-langs.keys ) {
                $syntax-label = %prm<lang>.tc ~  ' highlighting by highlight-js';
                $code = qq:to/HILIGHT/;
                    <pre class="browser-hl">
                    <code class="language-{ %hilight-langs{ %prm<lang>.uc } }">{ %tml<escaped>(%prm<contents>) }
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
            $code = Rainbow::tokenize(%prm<contents>).map( -> $t {
                if $t.type.key ne 'TEXT' {
                    qq[<span class="highlite-{$t.type.key}">{%tml<escaped>($t.text)}</span>]
                }
                else { %tml<escaped>($t.text) }
            }).join;
        }
        qq[
            <div class="raku-code raku-lang">
                <button class="copy-code" title="Copy code"><i class="far fa-clipboard"></i></button>
                <label>$syntax-label\</label>
                <div>
                    <pre class="nohighlights">$code\</pre>
                </div>
            </div>
        ]
    },
)