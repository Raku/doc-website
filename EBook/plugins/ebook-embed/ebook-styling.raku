#!/usr/bin/env raku
use v6.d;
%(
    'escaped' => sub ($s) { # special case with only a string as input
        if $s and $s ne ''
        { $s.trans(qw｢ <    >    &     " ｣ => qw｢ &lt; &gt; &amp; &quot; ｣) }
        else { '' }
    },
    'toc-section' => sub (%prm, %tml ) {
        qq:to/SECT/
                    <li class="section">
                        <a href="toc.xhtml#{ %prm<key> }">\<h1 id="{ %prm<key> }">{ %prm<data><name> }\</h1></a>
                        <ol class="section">
        { %prm<data><contents> }                </ol> <!-- section -->
                    </li> <!-- section -->
        SECT
    },
    'toc' => sub (%prm, %tml) { '' },
    'glossary' => sub (%prm, %tml) { '' },
    'toc-chapter' => sub (%prm, %tml ) {
        sub inset($n) { "\t" x ($n + 7) };
        my $file = %prm<fn-link> ~ '.xhtml';
        my $opened = False;
        my $rv = qq[{ inset(-2) }<li class="chapter">\n{ inset(-1) }<a href="$file">{ %prm<title> }</a> ];
        if %prm<toc>.defined and %prm<toc>.keys {
            my @cont = %prm<toc>.grep( ! *.<is-title> );
            my $last-level = 1;
            $rv ~= "\n{ inset(0) }<ol class=\"chapter-contents\">\n";
            for @cont -> %el {
                my $lev = %el<level>;
                given $last-level {
                    when $_ < $lev {
                        $last-level++;
                        if $opened {
                            $rv ~= "\n" ~ inset($last-level) ~ "<ol class=\"lev-$last-level\">\n";
                        }
                        else {
                            $rv ~= qq[{inset($last-level -1 )}<li>\n{ inset($last-level -1) }<a href="$file">{ %prm<title> } - Preface</a>\n { inset($last-level) } <ol class="lev-$last-level">\n];
                            $opened = True;
                        }
                        while $lev < $last-level {
                            $last-level++;
                            $rv ~= "\n" ~ inset($last-level)  ~ "<ol class=\"lev-$last-level\">\n";
                        }
                    }
                    when $_ > $lev {
                        while $last-level > $lev {
                            $last-level--;
                            $rv ~= "</li>\n" ~ inset($last-level + 1) ~ "</ol>\n" ~ inset($last-level) ~ "</li>\n";
                        }
                    }
                    default {
                        $rv ~= "</li>\n" if $opened;
                        $opened = True;
                    }
                }
                $rv ~= inset($last-level)
                    ~ qq[<li><a href="$file#{%el.<target>}">{%el.<text> // ''}</a>];
            }
            # close last item
            $rv ~= "</li>\n";
            $last-level--;
            # close off any remaining ol lists
            while $last-level > 0 {
                $last-level--;
                $rv ~= inset($last-level) ~ "</ol>\n" ~ inset($last-level) ~ "</li>\n";
            }
            # final contents ol
            $rv ~= "{ inset(-1) }</ol>\n{ inset(-2) }</li>\n";
        }
        else {
            $rv ~= "\n{ inset(-2) }</li> <!-- chapter -->\n"
        }
        $rv
    },
    'index' => sub (%prm, %tml) {
        %tml<source-wrap>.( %(
            title => 'Index of Documentation',
            subtitle => 'Indexed items in all the Raku documentation sources',
            body => ([~] gather for %prm<index>.sort {
                take qq[[\t\t<div class="index-defn">{ .key }\n]]
                    ~ ([~] gather for .value.sort({ .<fn-link> ~ .<place> }) -> %ref {
                        take qq[\t\t\t<a class="index-entry" href="{%ref<fn-link>}.xhtml#{%ref<target>}">{ %tml<escaped>(%ref<place>) }\</a>\n]
                    })
                    ~ qq[[\t\t</div>\n]]
            }),
        ), %tml );
     },
    'ebook-toc' => sub (%prm, %tml) {
        %tml<source-wrap>.( %(
            title => 'Raku Documentation',
            subtitle => '',
            body => (
                q:to/TOC/ ~ %prm<toc-main> ~ q:to/TOCEND/;
                    <nav epub:type="toc">
                        <h1>Table of Contents</h1>
                        <ol class="contents">
                TOC
                        </ol> <!-- contents -->
                    </nav>
                    <nav epub:type="landmarks" class="hide">
                      <h1>Guide</h1>
                      <ol>
                        <li><a epub:type="toc" href="toc.xhtml">Table of Contents</a></li>
                        <!--must be in here to display in kindle which only picks up
                            toc under epub:type="landmarks">. Be sure to include nav.css to hide <ol> numbering. -->
                      </ol>
                    </nav>
                TOCEND
            ),
        ), %tml );
     },
    'source-wrap' => sub (%prm, %tml) {
        qq:to/BLOCK/
        <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
        <html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops" lang="en-US" xml:lang="en-US">
        { %tml<head-block>.(%prm, %tml) }
        <body>
        %tml<page-header>.(%prm, %tml)
        %tml<page-content>.(%prm, %tml)
        %tml<page-footnotes>.(%prm, %tml)
        %tml<page-footer>.(%prm, %tml)
        </body>
        </html>
        BLOCK
    },
    'head-block' => sub (%prm, %tml) {
        qq:to/HEADBLOCK/
            <head>
                <title>{ %tml<escaped>.(%prm<title>) }</title>
                <meta charset="UTF-8" />
                { %tml<favicon>.({}, {}) }
                { %prm<metadata> // '' }
                { %tml<css>.({}, {}) }
            </head>
            HEADBLOCK
    },
    'page-header' => sub (%prm, %tml) {
        qq:to/BLOCK/
        <section class="page-header">
            <div class="page-title">
            { %prm<title> }
            </div>
            <div class="page-subtitle">
            { %prm<subtitle> }
            </div>
        </section>
        BLOCK
    },
    'page-content' => sub (%prm, %tml) {
        qq:to/PAGE/;
        <section class="page-content">
        { %prm<body> }
        </section>
        PAGE
    },
    'page-footnotes' => sub (%prm, %tml) {
        return '' unless %prm<footnotes>;
        qq:to/BLOCK/
        <section class="page-footnotes">
            { %prm<footnotes>  }
        </section>
        BLOCK
    },
    'page-footer' => sub (%prm, %tml) {
        my $rv = '';
        $rv ~= qq[[<p>Contents rendered from ｢{ %prm<config><path> }｣.</p>\n]] if %prm<config><path>:exists;
        if %prm<config><last-edited>:exists and %prm<config><last-edited>.so {
            $rv ~= qq[[<p>Source file was last changed by commit #{ %prm<config><last-edited> }.</p>]]
        }
        qq:to/TIME/;
                <div class="footer-item">
                  $rv
                </div>
            TIME
    },
    'pod' => sub (%prm, %tml) {
        (%prm<contents> // '')
        ~ "\n" ~ (%prm<tail> // '') ~ "\n"
    },
    heading => sub (%prm, %tml) {
        my $txt = %prm<text>;
        my $index-parse = $txt ~~ /
            ( '<a name="index-entry-' .+? '"></a>' )
            '<span class="glossary-entry-heading">' ( .+? ) '</span>'
        /;
        my $h = 'h' ~ (%prm<level> // '1');
        my $targ = %tml<escaped>.(%prm<target>);
        qq:to/HEAD/;
            <$h id="$targ" class="raku-$h">
            { $index-parse.so ?? $index-parse[0] !! '' }
            { $index-parse.so ?? $index-parse[1] !! $txt }
            </$h>
            HEAD
    },
    'list' => sub (%prm, %tml) {
        qq[
        <ul{ %prm<nesting> == 0 ?? ' class="rakudoc-item"' !! ''}>
           { %prm<items>.join }
        </ul>
        ]
    },
    'format-b' => sub (%prm, %tml) {
        my $beg = '<strong>';
        my $end = '</strong>';
        my $mark = "\xFF\xFF";
        if %prm<context>.Str eq 'InCodeBlock' {
            $beg = $mark ~ $beg ~ $mark;
            $end = $mark ~ $end ~ $mark;
        }
        $beg ~ %prm<contents> ~ $end
    },
    'format-c' => sub (%prm, %tml) {
        my $beg = '<code>';
        my $end = '</code>';
        my $mark = "\xFF\xFF";
        if %prm<context>.Str eq 'InCodeBlock' {
            $beg = $mark ~ $beg ~ $mark;
            $end = $mark ~ $end ~ $mark;
        }
        $beg ~ %prm<contents> ~ $end
    },
    'format-i' => sub (%prm, %tml) {
        my $beg = '<em>';
        my $end = '</em>';
        my $mark = "\xFF\xFF";
        if %prm<context>.Str eq 'InCodeBlock' {
            $beg = $mark ~ $beg ~ $mark;
            $end = $mark ~ $end ~ $mark;
        }
        $beg ~ %prm<contents> ~ $end
    },
    'format-k' => sub (%prm, %tml) {
        my $beg = '<kbd>';
        my $end = '</kbd>';
        my $mark = "\xFF\xFF";
        if %prm<context>.Str eq 'InCodeBlock' {
            $beg = $mark ~ $beg ~ $mark;
            $end = $mark ~ $end ~ $mark;
        }
        $beg ~ %prm<contents> ~ $end
    },
    'format-r' => sub (%prm, %tml) {
        my $beg = '<var>';
        my $end = '</var>';
        my $mark = "\xFF\xFF";
        if %prm<context>.Str eq 'InCodeBlock' {
            $beg = $mark ~ $beg ~ $mark;
            $end = $mark ~ $end ~ $mark;
        }
        $beg ~ %prm<contents> ~ $end
    },
    'format-t' => sub (%prm, %tml) {
        my $beg = '<samp>';
        my $end = '</samp>';
        my $mark = "\xFF\xFF";
        if %prm<context>.Str eq 'InCodeBlock' {
            $beg = $mark ~ $beg ~ $mark;
            $end = $mark ~ $end ~ $mark;
        }
        $beg ~ %prm<contents> ~ $end
    },
    'format-u' => sub (%prm, %tml) {
        my $beg = '<u>';
        my $end = '</u>';
        my $mark = "\xFF\xFF";
        if %prm<context>.Str eq 'InCodeBlock' {
            $beg = $mark ~ $beg ~ $mark;
            $end = $mark ~ $end ~ $mark;
        }
        $beg ~ %prm<contents> ~ $end
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
        my $beg = '<a ' ~ $trg ~ '>';
        my $end =  '</a>';
        my $mark = "\xFF\xFF";
        if %prm<context>.Str eq 'InCodeBlock' {
            $beg = $mark ~ $beg ~ $mark;
            $end = $mark ~ $end ~ $mark;
        }
        $beg ~ ( %prm<link-label> // '' ) ~ $end;
    },
    'format-n' => sub (%prm, %tml) {
        my $beg = '<sup class="content-footnote"><a name="'
                ~ %tml<escaped>.(%prm<retTarget>)
                ~ '" href="#' ~ %tml<escaped>.(%prm<fnTarget>)
                ~ '">';
        my $end = "</a></sup>\n";
        my $mark = "\xFF\xFF";
        if %prm<context>.Str eq 'InCodeBlock' {
            $beg = $mark ~ $beg ~ $mark;
            $end = $mark ~ $end ~ $mark;
        }
        $beg ~ '[' ~ %tml<escaped>.(%prm<fnNumber>) ~ ']' ~ $end
    },
    'format-p' => sub (%prm, %tml) {
        if %prm<as-pre> {
            '<div class="pod-placement"><pre>'
                ~ (%prm<contents> // '').=trans(['<pre>', '</pre>'] => ['&lt;pre&gt;', '&lt;/pre&gt;'])
                ~ "</pre></div>\n"
        }
        else {
            '<a id="' ~ %prm<target> ~ '"></a>'
            ~ %prm<contents>
        }
    },
    'format-x' => sub (%prm, %tml) {
        my $beg;
        my $end;
        my $indexedheader = %prm<meta>.elems ?? %prm<meta>[0].join(';') !! %prm<text>;
        my $text = %prm<text> // '';
        if %prm<context> eq 'Heading' {
            $beg = qq[<a name="{ %prm<target> }"{ $indexedheader ?? (' data-indexedheader="' ~ $indexedheader ~ '"') !! '' }></a><span class="glossary-entry-heading">];
            $end = '</span>';
        }
        else {
            my $index-text;
            $index-text = %prm<meta>.map( { $_.elems ?? ( "\x2983" ~ $_.map({ "\x301a$_\x301b" }) ~ "\x2984") !! "\x301a$_\x301b" })
                if %prm<meta>.elems;
            $beg = qq[<a name="{ %prm<target> }" class="index-entry">]
                    ~ ($index-text && $text ?? qq[<span class="glossary-entry" data-index-text="{ $index-text }">] !! '')
                    ;
            $end = ($index-text && $text ?? '</span>' !! '') ~ '</a>';
        }
        my $mark = "\xFF\xFF";
        if %prm<context>.Str eq 'InCodeBlock' {
            $beg = $mark ~ $beg ~ $mark;
            $end = $mark ~ $end ~ $mark;
        }
        $beg ~ $text ~ $end
    },
);
