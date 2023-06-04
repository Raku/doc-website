use v6.d;
use ProcessedPod;
%(
# the following are extra for HTML files and are needed by the render (class) method
# in the source-wrap template.
    '_templater' => 'RakuClosureTemplater',
    'escaped' => sub ($s) {
        if $s and $s ne ''
        { $s.trans(qw｢ <    >    &     " ｣ => qw｢ &lt; &gt; &amp; &quot; ｣) }
        else { '' }
    },
    'raw' => sub (%prm, %tml) {
        (%prm<contents> // '')
    },
    'camelia-img' => sub (%prm, %tml) {
        "\n<camelia />"
    },
    #placeholder
    'camelia-faded' => sub (%prm, %tml) {
        "\n<camelia-faded />"
    },
    #placeholder
    'favicon' => sub (%prm, %tml) {
        "\n<meta>NoIcon</meta>"
    },
    #placeholder
    'css' => sub (%prm, %tml) {
        ''
    },
    #placeholder
    'jq-lib' => sub (%prm, %tml) {
        ''
    },
    #placeholder
    'js' => sub (%prm, %tml) {
        ''
    },
    #placeholder
    'jq' => sub (%prm, %tml) {
        ''
    },
    #placeholder
    'js-bottom' => sub (%prm, %tml) {
        ''
    },
    #placeholder
    'search' => sub (%prm, %tml) {
        '<a href=search.html>Search page</a>'
    },
    #placeholder
    'block-code' => sub (%prm, %tml) {
        '<pre class="pod-block-code">'
            ~ (%prm<contents> // '')
            ~ '</pre>'
    },
    'comment' => sub (%prm, %tml) {
        '<!-- ' ~ (%prm<contents> // '') ~ ' -->'
    },
    'declarator' => sub (%prm, %tml) {
        '<a name="' ~ %tml<escaped>.(%prm<target> // '')
            ~ '"></a><article><code class="pod-code-inline">'
            ~ (%prm<code> // '') ~ '</code>' ~ (%prm<contents> // '') ~ '</article>'
    },
    'dlist-start' => sub (%prm, %tml) {
        "<dl>\n"
    },
    'defn' => sub (%prm, %tml) {
        '<dt>'
            ~ %tml<escaped>.(%prm<term> // '')
            ~ '</dt><dd>'
            ~ (%prm<contents> // '')
            ~ '</dd>'
    },
    'dlist-end' => sub (%prm, %tml) {
        "\n</dl>"
    },
    'format-b' => sub (%prm, %tml) {
        '<strong>' ~ %prm<contents> ~ '</strong>'
    },
    'format-c' => sub (%prm, %tml) {
        '<code>' ~ %prm<contents> ~ '</code>'
    },
    'format-i' => sub (%prm, %tml) {
        '<em>' ~ %prm<contents> ~ '</em>'
    },
    'format-k' => sub (%prm, %tml) {
        '<kbd>' ~ %prm<contents> ~ '</kbd>'
    },
    'format-r' => sub (%prm, %tml) {
        '<var>' ~ %prm<contents> ~ '</var>'
    },
    'format-t' => sub (%prm, %tml) {
        '<samp>' ~ %prm<contents> ~ '</samp>'
    },
    'format-u' => sub (%prm, %tml) {
        '<u>' ~ %prm<contents> ~ '</u>'
    },
    'para' => sub (%prm, %tml) {
        '<p>' ~ %prm<contents> ~ '</p>'
    },
    'format-l' => sub ( %prm, %tml ) {
        # type = local: <link-label> -> <target>#<place> | <target>
        # type = internal: <link-label> -> #<place>
        # type = external: <link-label> -> <target>
        my $trg;
        given %prm<type> {
            when 'local' {
                $trg = %prm<target>;
                $trg ~= '#' ~ %prm<place> if %prm<place>;
                $trg = 'href="' ~ $trg ~ '"'
            }
            when 'internal' {
                $trg = 'href="#' ~ %prm<place> ~ '"'
            }
            default {
                $trg = 'href="' ~ %prm<target> ~ '"'
            }
        }
        '<a '
            ~ $trg
            ~ '>'
            ~ ( %prm<link-label> // '')
            ~ '</a>'
    },
    'format-n' => sub (%prm, %tml) {
        '<sup class="content-footnote"><a name="'
            ~ %tml<escaped>.(%prm<retTarget>)
            ~ '" href="#' ~ %tml<escaped>.(%prm<fnTarget>)
            ~ '">[' ~ %tml<escaped>.(%prm<fnNumber>)
            ~ "]</a></sup>\n"
    },
    'format-p' => sub (%prm, %tml) {
        '<div class="pod-placement"><pre>'
            ~ (%prm<contents> // '').=trans(['<pre>', '</pre>'] => ['&lt;pre&gt;', '&lt;/pre&gt;'])
            ~ "</pre></div>\n"
    },
    'format-x' => sub (%prm, %tml) {
        '<a name="' ~ (%prm<target> // '') ~ '" class="index-entry"></a>'
            ~ ((%prm<text>.defined and %prm<text> ne '') ?? '<span class="glossary-entry">' ~ %prm<text> ~ '</span>' !! '')
    },
    'heading' => sub (%prm, %tml) {
        my $txt = %prm<text> // '';
        my $index-parse = $txt ~~ /
            ( '<a name="index-entry-' .+? '</a>' )
            '<span class="glossary-entry">' ( .+? ) '</span>'
        /;
        my $h = 'h' ~ (%prm<level> // '1');
        qq[[\n<$h id="{ %tml<escaped>.(%prm<target>) }">]]
            ~ ( $index-parse.so ?? $index-parse[0] !! '' )
            ~ qq[[<a href="#{ %tml<escaped>.(%prm<top>) }" class="u" title="go to top of document">]]
            ~ ( $index-parse.so ?? $index-parse[1] !! $txt )
            ~ qq[[</a></$h>\n]]
    },
    'image' => sub (%prm, %tml) {
        '<img src="' ~ (%prm<src> // 'path/to/image') ~ '"'
            ~ ' width="' ~ (%prm<width> // '100px') ~ '"'
            ~ ' height="' ~ (%prm<height> // 'auto') ~ '"'
            ~ ' alt="' ~ (%prm<alt> // 'XXXXX') ~ '"'
            ~ (%prm<class>:exists ?? (' class"' ~ %prm<class> ~ '"') !! '')
            ~ (%prm<id>:exists ?? (' class"' ~ %prm<id> ~ '"') !! '')
            ~ '>'
    },
    'item' => sub (%prm, %tml) {
        '<li' ~ (%prm<class> ?? (' class="' ~ %prm<class> ~ '"') !! '') ~ '>'
            ~ (%prm<contents> // '')
            ~ "</li>\n"
    },
    'list' => sub (%prm, %tml) {
        "<ul>\n"
            ~ %prm<items>.join
            ~ "</ul>\n"
    },
    'unknown-name' => sub (%prm, %tml) {
        with %prm<format-code> {
            '<span class="RakudocNoFormatCode">'
                ~ "<span>unknown format-code $_\</span>\&lt;\<span>{ %prm<contents> }\</span>|\<span>{ %prm<meta> }\</span>"
                ~ '&gt;</span>'
        }
        else {
            "\n<section>\<fieldset class=\"RakudocError\">\<legend>This Block name is not known, could be a typo or missing plugin\</legend>\n<h"
                ~ (%prm<level> // '1') ~ ' id="'
                ~ %tml<escaped>.(%prm<target>) ~ '"><a href="#'
                ~ %tml<escaped>.(%prm<top> // '')
                ~ '" class="u" title="go to top of document">'
                ~ (%prm<name> // '')
                ~ '</a></h' ~ (%prm<level> // '1') ~ ">\n"
                ~ '<fieldset class="contents-container"><legend>Contents are</legend>' ~ "\n"
                ~ (%prm<contents> // '')
                ~ "</fieldset>\n"
                ~ (%prm<tail> // '')
                ~ "\n</fieldset>\</section>\n"
        }
    },
    'output' => sub (%prm, %tml) {
        '<pre class="pod-output">' ~ (%prm<contents> // '') ~ '</pre>'
    },
    'input' => sub (%prm, %tml) {
        '<pre class="pod-input">' ~ (%prm<contents> // '') ~ '</pre>'
    },
    'nested' => sub (%prm, %tml) {
        '<div class="pod-nested">' ~ (%prm<contents> // '') ~ '</div>'
    },
    'page-top' => sub (%prm, %tml) {
        '<div class="pod-content ' ~ (%prm<page-config><class> // '') ~ '">'
    },
    'page-bottom' => sub (%prm, %tml) {
        '</div>'
    },
    'content-top' => sub (%prm, %tml) {
        '<div class="pod-body">' ~ "\n"
    },
    'content-bottom' => sub (%prm, %tml) {
        '</div>'
    },
    'pod' => sub (%prm, %tml) {
        '<section name="'
            ~ %tml<escaped>.(%prm<config><name> // '') ~ '">'
            ~ (%prm<contents> // '')
            ~ (%prm<tail> // '')
            ~ '</section>'
    },
    'table' => sub (%prm, %tml) {
        '<table class="pod-table'
            ~ ((%prm<class>.defined and %prm<class> ne '') ?? (' ' ~ %tml<escaped>.(%prm<class>)) !! '')
            ~ '">'
            ~ ((%prm<caption>.defined and %prm<caption> ne '') ?? ('<caption>' ~ %prm<caption> ~ '</caption>') !! '')
            ~ ((%prm<headers>.defined and %prm<headers> ne '') ??
        ("\t<thead>\n"
            ~ [~] %prm<headers>.map({ "\t\t<tr><th>" ~ .<cells>.join('</th><th>') ~ "</th></tr>\n" })
                ~ "\t</thead>"
        ) !! '')
            ~ "\t<tbody>\n"
            ~ ((%prm<rows>.defined and %prm<rows> ne '') ??
        [~] %prm<rows>.map({ "\t\t<tr><td>" ~ .<cells>.join('</td><td>') ~ "</td></tr>\n" })
        !! '')
            ~ "\t</tbody>\n"
            ~ "</table>\n"
    },
    'edit-page' => sub (%prm, %tml) {
        return '' unless %prm<config><path> ~~ / ^ .+ 'docs/' ( .+ ) $ /;
        "\n" ~ '<button title="Edit this page" class="edit-raku-doc" '
            ~ 'onclick="location=\'https://github.com/Raku/doc/edit/master/' ~ %tml<escaped>.(~$0) ~ '\'">'
            ~ '<img src="/assets/images/pencil.svg" >'
            ~ '</button>'
    },
    'top-of-page' => sub (%prm, %tml) {
        if %prm<title-target>:exists and %prm<title-target> ne '' {
            '<div id="' ~ %tml<escaped>.(%prm<title-target>) ~ '" class="top-of-page"></div>'
        }
        else { '' }
    },
    'title' => sub (%prm, %tml) {
        if %prm<title>:exists and %prm<title> ne '' {
            '<h1 class="title"'
                ~ ((%prm<title-target>:exists and %prm<title-target> ne '')
                ?? ' id="' ~ %tml<escaped>.(%prm<title-target>) !! '') ~ '">'
                ~ %prm<title> ~ '</h1>'
        }
        else { '' }
    },
    'subtitle' => sub (%prm, %tml) {
        if %prm<subtitle>:exists and %prm<subtitle> ne '' {
            '<div class="subtitle">' ~ %prm<subtitle> ~ '</div>' }
        else { '' }
    },
    'sidebar' => sub (%prm, %tml) {
        return '' unless (%prm<toc> or %prm<glossary>);
        qq:to/SIDEB/
        <div class="raku-sidebar-container">
            <input class="checkbox" type="checkbox" name="" id="rakuCheckBox" title="Contents"/>
            <div class="hamburger-lines" >
                <span class="line line1"></span>
                <span class="line line2"></span>
                <span class="line line3"></span>
            </div>
            <aside id="raku-sidebar-cont" class="raku-sidebar">
                <div class="filter-control">
                    <input id="sidebar-filter" class="input" type="text" placeholder="Filter">
                    <i class="fa fa-search" aria-hidden="true"></i>
                </div>
                { %prm<toc> }
                { %prm<glossary> }
            </aside>
        </div>
        SIDEB
    },
    'source-wrap' => sub (%prm, %tml) {
        "<!doctype html>\n"
            ~ '<html lang="' ~ ((%prm<lang>.defined and %prm<lang> ne '') ?? %tml<escaped>.(%prm<lang>) !! 'en') ~ "\">\n"
            ~ %tml<head-block>.(%prm, %tml)
            ~ "\t<body class=\"pod\">\n"
            ~ %tml<header>.(%prm, %tml)
            ~ %tml<page-top>.(%prm, %tml)
            ~ %tml<sidebar>.(%prm, %tml)
            ~ %tml<top-of-page>.(%prm, %tml)
            ~ %tml<edit-page>.(%prm, %tml)
            ~ '<h1 class="in-page-title">' ~ %prm<title> ~ '</h1>'
            ~ %tml<subtitle>.(%prm, %tml)
            ~ %tml<content-top>.(%prm, %tml)
            ~ (%prm<body> // '')
            ~ %tml<content-bottom>.({}, {})
            ~ %tml<page-bottom>.({}, {})
            ~ (%prm<footnotes> // '')
            ~ %tml<footer>.(%prm, %tml)
            ~ '<div id="raku-repl"></div>'
            ~ %tml<js-bottom>.({}, {})
            ~ "\n\t</body>\n</html>\n"
    },
    'footnotes' => sub (%prm, %tml) {
        with %prm<notes> {
            if .elems {
                "<div id=\"_Footnotes\" class=\"footnotes\">\n"
                    ~ [~] .map({ '<div class="footnote" id="' ~ %tml<escaped>.($_<fnTarget>) ~ '">'
                    ~ ('<span class="footnote-number">' ~ ($_<fnNumber> // '') ~ '</span>')
                    ~ '<a class="footnote-linkback" href="#'
                    ~ %tml<escaped>($_<retTarget>)
                    ~ '"> [↑] </a>'
                    ~ ($_<text> // '')
                    ~ "</div>\n"
                })
                ~ "\n</div>\n"
            }
            else { '' }
        }
        else { '' }
    },
    'glossary' => sub (%prm, %tml) {
        if %prm<glossary>.defined and %prm<glossary>.keys {
            '<div id="_Glossary" class="glossary">' ~ "\n"
                ~ '<div class="glossary-caption">Index</div>' ~ "\n"
                ~ [~] %prm<glossary>.map({
                '<div class="glossary-defn">'
                    ~ ($_<text> // '')
                    ~ '</div>'
                    ~ '<div class="glossary-places">'
                    ~ [~] $_<refs>.map({
                    '<div class="glossary-place"><a href="#'
                        ~ %tml<escaped>.($_<target>)
                        ~ '">'
                        ~ ($_<place>.defined ?? $_<place> !! '')
                        ~ "</a></div>\n"
                })
                ~ '</div>'
            })
            ~ "</div>\n"
        }
        else { '' }
    },
    'meta' => sub (%prm, %tml) {
        with %prm<meta> {
            [~] %prm<meta>.map({
                '<meta name="' ~ %tml<escaped>.(.<name>)
                    ~ '" value="' ~ %tml<escaped>.(.<value>)
                    ~ "\" />\n"
            })
        }
        else { '' }
    },
    'toc' => sub (%prm, %tml) {
        if %prm<toc>.defined and %prm<toc>.keys {
            "<div id=\"_TOC\"><table>\n<caption>Table of Contents</caption>\n"
                ~ [~] %prm<toc>.map({
                '<tr class="toc-level-' ~ .<level> ~ '">'
                    ~ '<td class="toc-text"><a href="#'
                    ~ %tml<escaped>.(.<target>)
                    ~ '">'
                    ~ %tml<escaped>.($_<text> // '')
                    ~ "</a></td></tr>\n"
            })
                ~ "</table></div>\n"
        }
        else { '' }
    },
    'head-block' => sub (%prm, %tml) {
        "\<head>\n"
            ~ '<title>' ~ %tml<escaped>.(%prm<title>) ~ "\</title>\n"
            ~ '<meta charset="UTF-8" />' ~ "\n"
            ~ %tml<favicon>.({}, {})
            ~ (%prm<metadata> // '')
            ~ %tml<css>.({}, {})
            ~ %tml<jq-lib>.({}, {})
            ~ %tml<js>.({}, {})
            ~ "\</head>\n"
    },
    'header' => sub (%prm,%tml) {
        "\n<header>\n"
            ~ '<div class="home" ><a href="/index.html">' ~ %tml<camelia-img>.(%prm, %tml) ~ '</a></div>'
            ~ '<div class="raku-collection"></div>'
            ~ '<div class="page-title">' ~ %prm<title> ~ "</div>\n"
            ~ '<a class="error-report" href="/error-report.html">Errors</a>'
            ~ '<a class="extra" href="/collection-examples.html">Collection</a>'
            ~ '<div class="menu">' ~ "\n"
            ~ '<a href="https://raku.org"><div class="menu-item">Raku™ homepage</div></a>'
            ~ '<a href="/language.html"><div class="menu-item">Language</div></a>'
            ~ '<a href="/search.html"><div class="menu-item">Search Site</div></a>'
            ~ '<a href="/types.html"><div class="menu-item">Types</div></a>'
            ~ '<a href="/programs.html"><div class="menu-item">Programs</div></a>'
            ~ '<a href="https://modules.raku.org/"><div class="menu-item">Modules</div></a>'
            ~ '<a href="https://docs.raku.org/"><div class="menu-item">Official site</div></a>'
            ~ "</div>
        </header>\n"
    },
    'footer' => sub (%prm, %tml) {
        "\n"
            ~ '<footer>'
            ~ '<div>Rendered from <span class="path">'
            ~ ((%prm<config><path>:exists and %prm<config><path> ne '') ?? %prm<config><path> !! 'no path')
            ~ '</span></div>'
            ~ '<div>at <span class="time">'
            ~ (DateTime(now).truncated-to('second'))
            ~ '</span></div>'
            ~ "</footer>\n"
    },
);
