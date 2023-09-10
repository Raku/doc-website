#!/usr/bin/env raku
use v6.d;
%(
    'source-wrap' => sub (%prm, %tml) {
        qq:to/BLOCK/
        <!DOCTYPE html>
        <html lang="{ %prm<config><lang> }"
            class="fontawesome-i2svg-active fontawesome-i2svg-complete">
        { %tml<head-block>.(%prm, %tml) }
        <body class="has-navbar-fixed-top">
        { %tml<top-of-page>.(%prm, %tml) }
        { %tml<navigation>.(%prm, %tml)  }
        { %tml<wrapper>.(%prm, %tml)  }
        { %tml<footer>.(%prm, %tml)  }
        { %tml<js-bottom>.({}, {}) }
        </body>
        </html>
        BLOCK
    },
    'head-block' => sub (%prm, %tml) {
        qq:to/HEADBLOCK/
            <head>
                <title>{ %tml<escaped>.(%prm<title>) } | Raku Documentation\</title>
                <meta charset="UTF-8" />
                { %tml<favicon>.({}, {}) }
                { %prm<metadata> // '' }
                { %tml<css>.({}, {}) }
                { %tml<jq-lib>.({}, {}) }
                { %tml<js>.({}, {}) }
            </head>
            HEADBLOCK
    },
    'top-of-page' => sub (%prm, %tml) {
        if %prm<title-target>:exists and %prm<title-target> ne '' {
            '<div id="' ~ %prm<title-target> ~ '" class="top-of-page"></div>'
        }
        else { '' }
    },
    'navigation' => sub (%prm, %tml) {
        my $add-sidebars = %prm<config><direct-wrap>:!exists;
        qq:to/BLOCK/
        <nav class="navbar is-fixed-top is-flex-touch" role="navigation" aria-label="main navigation">
            {
            qq:to/SIDE/ if $add-sidebars;
                <div class="navbar-item" style="margin-left: auto;">
                    { %tml<left-bar-toggle>.( %prm, %tml) }
                </div>
            SIDE
            }
            <div class="container is-justify-content-space-around">
                { %tml<head-brand>.( %prm, %tml) }
                { %tml<head-topbar>.( %prm, %tml) }
            </div>
            {
            qq:to/SIDE/ if $add-sidebars and ! %tml<head-search>.defined;
                <div class="navbar-item" style="margin-right: auto;">
                    { %tml<right-bar-toggle>.( %prm, %tml) }
                </div>
            SIDE
            }
        </nav>
        BLOCK
    },
    'left-bar-toggle' => sub (%prm, %tml ) {
      q:to/BLOCK/
        <div class="left-bar-toggle" title="Toggle Table of Contents (Ctl-a)">
            <label class="chyronToggle left">
                <input id="navbar-left-toggle" type="checkbox">
                <span class="text">Contents</span>
            </label>
        </div>
      BLOCK
    },
    'right-bar-toggle' => sub (%prm, %tml ) {
	   without %tml<head-search> { # head-search is provided by search-bar, but not sidebar-search
           q:to/BLOCK/
            <div class="right-bar-toggle" title="Toggle search sidebar (Ctl-s">
                <label class="chyronToggle right">
                  <input id="navbar-right-toggle" type="checkbox">
                  <span class="text">Search</span>
                </label>
            </div>
            BLOCK
       }
    },
    'head-brand' => sub (%prm, %tml ) {
        q:to/BLOCK/
        <div class="navbar-brand">
          <div class="navbar-logo">
            <a class="navbar-item" href="/">
              <img src="/assets/images/camelia-recoloured.png" alt="Raku" width="52.83" height="38">
            </a>
            <span class="navbar-logo-tm">tm</span>
          </div>
          <a role="button" class="navbar-burger burger" aria-label="menu" aria-expanded="false" data-target="navMenu">
            <span aria-hidden="true"></span>
            <span aria-hidden="true"></span>
            <span aria-hidden="true"></span>
          </a>
        </div>
        BLOCK
    },
    'head-topbar' => sub ( %prm, %tml ) {
        my $search-bar = %tml<head-search>.( %prm, %tml) with %tml<head-search>;
        qq:to/BLOCK/
          <div id="navMenu" class="navbar-menu">
            <div class="navbar-start">
                <a class="navbar-item" href="/introduction" title="Getting started, Tutorials, Migration guides">
                    Introduction
                </a>
                <a class="navbar-item" href="/reference" title="Fundamentals, General reference">
                    Reference
                </a>
                <a class="navbar-item" href="/miscellaneous" title="Programs, Experimental">
                    Miscellaneous
                </a>
                <a class="navbar-item" href="/types" title="The core types (classes) available">
                    Types
                </a>
                <a class="navbar-item" href="/routines" title="Searchable table of routines">
                    Routines
                </a>
                <a class="navbar-item" href="https://raku.org" title="Home page for community">
                    Raku™
                </a>
                <a class="navbar-item" href="https://kiwiirc.com/client/irc.libera.chat/#raku" title="IRC live chat">
                    Chat
                </a>
                <div class="navbar-item has-dropdown is-hoverable">
                  <a class="navbar-link">
                    More
                  </a>
                  <div class="navbar-dropdown is-right is-rounded">
                    <hr class="navbar-divider">
                    <a class="navbar-item" href="/about">
                      About
                    </a>
                    <hr class="navbar-divider">
                    <a class="navbar-item has-text-red" href="https://github.com/raku/doc-website/issues">
                      Report an issue with this site
                    </a>
                    <hr class="navbar-divider">
                    <a class="navbar-item has-text-red" href="https://github.com/raku/doc/issues">
                      Report an issue with the documentation content
                    </a>
                  </div>
                </div>
            </div>
            { $_ with $search-bar }
          </div>
        BLOCK
    },
    'wrapper' => sub (%prm, %tml) {
        with %prm<config><direct-wrap> {
            %prm<body>
        }
        else {
            qq:to/BLOCK/
            <div class="tile is-ancestor section">
                <div id="left-column" class="tile is-parent is-2 is-hidden">
                    <div style="height: 90vh; overflow-y: scroll;">
                        { %tml<toc-sidebar>.(%prm, %tml)  }
                    </div>
                </div>
                <div id="main-column" class="tile is-parent" style="overflow-x: hidden;">
                    <div style="height: 92vh; overflow-y: scroll; flex-grow:inherit;">
                        { %tml<page-main>.(%prm, %tml) }
                    </div>
                </div>
                <div id="right-column" class="tile is-parent is-3 is-hidden">
                    <div style="height: 90vh; overflow-y: scroll;">
                        { %tml<search-sidebar>.(%prm, %tml)  }
                    </div>
                </div>
            </div>
            BLOCK
        }
    },
    'search-sidebar' => sub (%prm, %tml ) {
	    if %tml<raku-search-block>:exists { %tml<raku-search-block>.(%prm, %tml) }
        else { 'No search function' }
    },
    'toc-sidebar' => sub (%prm, %tml) {
        if %tml<raku-toc-block>:exists { %tml<raku-toc-block>.(%prm, %tml) }
        else { 'No Table of Contents' }
    },
    'page-main' => sub (%prm, %tml ) {
        %tml<page-header>.(%prm, %tml)
        ~ %tml<page-content>.(%prm, %tml)
        ~ %tml<page-footnotes>.(%prm, %tml)
    },
    'page-header' => sub (%prm, %tml) {
        qq:to/BLOCK/
        <section class="raku page-header">
            <div class="container px-4">
                <div class="raku page-title has-text-centered">
                { %prm<title> }
                </div>
                <div class="raku page-subtitle has-text-centered">
                { %prm<subtitle> }
                </div>
                { %tml<page-edit>.(%prm,%tml) }
            </div>
        </section>
        BLOCK
    },
    'page-content' => sub (%prm, %tml) {
        my $rv = '<section class="raku page-content">';
        with %prm<config><page-content-columns> {
            $rv ~= '<div class="container"><div class="columns listing">'
                    ~ %prm<body> ~ '</div>';
        }
        orwith %prm<config><page-content-one-col> {
            $rv ~= '<div class="container"><div class="columns one-col">'
                ~ %prm<body> ~ '</div>';
        }
        else {
            $rv ~= '<div class="container px-4">' ~ %prm<body> ~ '</div>';
        }
        $rv ~= "</section>\n"
    },
    'page-footnotes' => sub (%prm, %tml) {
        return '' unless %prm<footnotes>;
        qq:to/BLOCK/
        <section class="page-footnotes">
            <div class="container">
            { %prm<footnotes>  }
            </div>
        </section>
        BLOCK
    },
    'pod' => sub (%prm, %tml) {
        (%prm<contents> // '')
        ~ "\n" ~ (%prm<tail> // '') ~ "\n"
    },
    'footer' => sub (%prm, %tml) {
        qq:to/BLOCK/
        <footer class="footer main-footer">
          <div class="container px-4">
            <nav class="level">
            { %tml<footer-left>.(%prm, %tml) }
            { %tml<footer-right>.(%prm, %tml) }
            </nav>
          </div>
        </footer>
        BLOCK
    },
    footer-left => sub (%prm, %tml ) {
        q:to/FLEFT/
        <div class="level-left">
            <div class="level-item">
              <a href="/about">About</a>
            </div>
            <div class="level-item">
              <a id="toggle-theme">Toggle theme</a>
            </div>
        </div>
        FLEFT
    },
    footer-right => sub (%prm, %tml ) {
        q:to/FRIGHT/
        <div class="level-right">
            <div class="level-item">
              <a href="/license">License</a>
            </div>
        </div>
        FRIGHT
    },
    page-edit => sub (%prm, %tml) {
        return '' unless %prm<config><path> ~~ / ^ .+ 'docs/' ( .+) $ /;
        qq:to/BLOCK/
        <div class="page-edit">
            <a class="button page-edit-button"
               href="https://github.com/Raku/doc/edit/main/{ %tml<escaped>.(~$0) }"
               title="Edit this page.">
              <span class="icon is-right">
                <i class="fas fa-pen-alt is-medium"></i>
              </span>
            </a>
          </div>
        BLOCK
    },
    heading => sub (%prm, %tml) {
        my $txt = %prm<text> // '';
        my $index-parse = $txt ~~ /
            ( '<a name="index-entry-' .+? '</a>' )
            '<span class="glossary-entry">' ( .+? ) '</span>'
        /;
        my $h = 'h' ~ (%prm<level> // '1');
        my $targ = %tml<escaped>.(%prm<target>);
        qq[[\n<$h id="$targ"]]
            ~ qq[[ class="raku-$h">]]
            ~ ( $index-parse.so ?? $index-parse[0] !! '' )
            ~ qq[[<a href="#{ %tml<escaped>.(%prm<top>) }" title="go to top of document">]]
            ~ ( $index-parse.so ?? $index-parse[1] !! $txt )
            ~ qq[[<a class="raku-anchor" title="direct link" href="#$targ">§</a>]]
            ~ qq[[</a></$h>\n]]
    },
    toc => sub (%prm, %tml) {
        my $rv = '';
        if %prm<toc>.defined and %prm<toc>.keys {
            $rv = "<ul class=\"menu-list\">\n";
            my $last-level = 1;
            for %prm<toc>.list -> %el {
                my $lev = %el<level>;
                given $last-level {
                    when $_ > $lev {
                        while $last-level > $lev {
                            $rv ~= "\n</ul>\n";
                            $last-level--;
                        }
                    }
                    when $_ < $lev {
                        while $lev > $last-level {
                            $last-level++;
                            $rv ~= "\n<ul>\n";
                        }
                    }
                }
                $rv ~= "\n<li>"
                    ~ '<a href="#'
                    ~ (%el.<target>)
                    ~ '">'
                    ~ (%el.<text> // '')
                    ~ '</a></li>';
            }
            $rv ~= "\n</ul>\n";
        }
        $rv
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
        my $indexedheader = %prm<meta>.elems ?? %prm<meta>[0].join(';') !! %prm<text>;
        my $beg = qq[
            <a name="{ %prm<target> // ''}" class="index-entry"
            data-indexedheader="{ $indexedheader }"></a>
            { (%prm<text>.defined and %prm<text> ne '') ?? '<span class="glossary-entry">' !! '' }
        ];
        my $end = '</span>';
        my $mark = "\xFF\xFF";
        if %prm<context>.Str eq 'InCodeBlock' {
            $beg = $mark ~ $beg ~ $mark;
            $end = $mark ~ $end ~ $mark;
        }
        # if there is indexedheader but no text, must still return beg. If indexh.. but text, then end
        $beg ~ ( (%prm<text>.defined and %prm<text> ne '') ?? %prm<text> ~ $end !! '' )
    },
);
