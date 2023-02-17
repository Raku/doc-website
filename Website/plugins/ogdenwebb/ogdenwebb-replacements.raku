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
        { %tml<header>.(%prm, %tml)  }
        { %tml<sidebar>.(%prm, %tml)  }
        { %tml<wrapper>.(%prm, %tml)  }
        <div id="raku-repl"></div>
        { %tml<footer>.(%prm, %tml)  }
        { %tml<js-bottom>.({}, {}) }
        { %tml<end-block>.(%prm, %tml) }
        BLOCK
    },
    'header' => sub (%prm, %tml) {
        qq:to/BLOCK/
        <nav class="navbar is-fixed-top" role="navigation" aria-label="main navigation">
          <div class="container">
            { %tml<head-brand>.( %prm, %tml) }
            <div id="navMenu" class="navbar-menu">
                { %tml<head-topbar>.( %prm, %tml) }
                { %tml<head-search>.( %prm, %tml) }
            </div>
          </div>
        </nav>
        BLOCK
    },
    'head-brand' => sub (%prm, %tml ) {
        q:to/BLOCK/
        <div class="navbar-brand navbar-logo">
          <div class="navbar-logo">
            <a class="navbar-item" href="/">
              <img src="/assets/images/camelia-recoloured.png" alt="Raku" width="52.83" height="38">
            </a>
            <div class="navbar-logo-tm">tm</div>
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
        q:to/BLOCK/
          <div class="navbar-start">
            <a class="navbar-item" href="/language.html">
                Language
            </a>
            <a class="navbar-item" href="/types.html">
                Types
            </a>
            <a class="navbar-item" href="/routines.html">
                Routines
            </a>
            <a class="navbar-item" href="/programs.html">
                Programs
            </a>
            <a class="navbar-item" href="https://raku.org">
                Raku Homepage
            </a>
            <a class="navbar-item" href="https://kiwiirc.com/client/irc.libera.chat/#raku">
                Chat with us
            </a>
            <div class="navbar-item has-dropdown is-hoverable">
              <a class="navbar-link">
                More
              </a>
              <div class="navbar-dropdown">
                <a class="navbar-item" href="/search.html">
                  Extended Search
                </a>
                <hr class="navbar-divider">
                <a class="navbar-item" href="/about.html">
                  About
                </a>
                <hr class="navbar-divider">
                <a class="navbar-item" href="/error-report.html">
                  Anomalous links
                </a>
              </div>
            </div>
          </div>
        BLOCK
    },
    'head-search' => sub (%prm, %tml ) { # placeholder here. Should be modified by search-bar plugin
	    '<div class="navbar-end navbar-search-wrapper"></div>'
    },
    'sidebar' => sub (%prm, %tml) {
        return '' unless %prm<toc>;
        qq:to/BLOCK/
        <div id="raku-sidebar" class="raku-sidebar-toggle" style="">
          <a class="button is-primary">
            <span class="icon">
            <!-- This is where the chevron arrow will be loaded in the right direction -->
            </span>
          </a>
        </div>
        <div id="mainSidebar" class="raku-sidebar" style="width:0px; display:none;">
          <div class="field">
            <label class="label has-text-centered">Table of Contents</label>
            <div class="control has-icons-right">
              <input id="toc-filter" class="input" type="text" placeholder="Filter">
              <span class="icon is-right has-text-grey">
                <i class="fas fa-search is-medium"></i>
              </span>
            </div>
          </div>
          <div class="raku-sidebar-body">
            <aside id="toc-menu" class="menu">
            { %prm<toc> }
            </aside>
          </div>
        </div>
        BLOCK
    },
    'wrapper' => sub (%prm, %tml) {
        with %prm<config><direct-wrap> {
            %prm<body>
        }
        else {
            qq:to/BLOCK/
            <div id="wrapper">
            { %tml<page-header>.(%prm, %tml) }
            { %tml<page-content>.(%prm, %tml) }
            { %tml<page-footnotes>.(%prm, %tml) }
            </div>
            BLOCK
        }
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
        $rv ~= %prm<config><page-content-columns>
            ?? '<div class="container"><div class="columns listing">'
            !! '<div class="container px-4">';
        $rv ~=  %prm<body>;
        $rv ~= %prm<config><page-content-columns>
            ?? '</div></div>'
            !! '</div>';
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
            { %tml<page-generated>.(%prm, %tml) }
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
              <a href="/about.html">About</a>
            </div>
            <div class="level-item">
              <a id="toggle-theme">Toggle theme</a>
            </div>
        </div>
        FLEFT
    },
    'page-generated' => sub (%prm, %tml) {
        qq:to/BLOCK/
        <div class="level-item">
            <div class="dropdown is-up is-hoverable">
                <div class="dropdown-trigger">
                    <button class="button" aria-haspopup="true" aria-controls="footer-generated">
                        <span>Generated from</span>
                        <span class="icon is-small">
                        <i class="fas fa-angle-up" aria-hidden="true"></i>
                        </span>
                    </button>
                </div>
                <div class="dropdown-menu" id="footer-generated" role="menu">
                    <div class="dropdown-content">
                        <div class="dropdown-item generated">
                            <p>This page is generated from </p>
                            <p class="file-path">{ %prm<config><path> }</p>
                            <p>{ 'on ' ~ .yyyy-mm-dd ~ ' at ' ~ .hh-mm-ss with DateTime(now) }</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        BLOCK
    },
    footer-right => sub (%prm, %tml ) {
        q:to/FRIGHT/
        <div class="level-right">
          <div class="level-item">
            <div class="dropdown is-up is-hoverable">
                <div class="dropdown-trigger">
                    <button class="button" aria-haspopup="true" aria-controls="footer-license">
                        <span>License</span>
                        <span class="icon is-small">
                            <i class="fas fa-angle-up" aria-hidden="true"></i>
                        </span>
                    </button>
                </div>
                <div class="dropdown-menu" id="footer-license" role="menu">
                    <div class="dropdown-content">
                        <div class="dropdown-item">
                          <p>This website is licensed under
                          <a href="https://raw.githubusercontent.com/Raku/doc/master/LICENSE">the Artistic License 2.0</a>
                          </p>
                        </div>
                    </div>
                </div>
            </div>
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
    end-block => sub (%prm, %tml) {
        qq:to/BLOCK/
        <div
            role="status"
            aria-live="assertive"
            aria-relevant="additions"
            class="ui-helper-hidden-accessible">
        </div>
        BLOCK
    },
    #placeholder
    block-code => sub (%prm, %tml) { # previous block-code is set by 02-highlighter
        my $hl = %tml.prior('block-code').(%prm, %tml);
        $hl .= subst( / '<pre class="' /, '<pre class="cm-s-ayaya ');
        '<div class="raku-code raku-lang">'
            ~ $hl
            ~ '</div>'
    },
    heading => sub (%prm, %tml) {
        my $txt = %prm<text> // '';
        my $index-parse = $txt ~~ /
            ( '<a name="index-entry-' .+? '</a>' )
            '<span class="glossary-entry">' ( .+? ) '</span>'
        /;
        my $h = 'h' ~ (%prm<level> // '1');
        qq[[\n<$h id="{ %tml<escaped>.(%prm<target>) }"]]
            ~ qq[[ class="raku-$h">]]
            ~ ( $index-parse.so ?? $index-parse[0] !! '' )
            ~ qq[[<a href="#{ %tml<escaped>.(%prm<top>) }" class="u" title="go to top of document">]]
            ~ ( $index-parse.so ?? $index-parse[1] !! $txt )
            ~ qq[[</a></$h>\n]]
    },
    table => sub (%prm, %tml) {
        my $tb = %tml.prior('table').(%prm, %tml);
        $tb.subst(/ '<table class="' /, '<table class="table is-bordered centered ')
    },
    toc => sub (%prm, %tml) {
        if %prm<toc>.defined and %prm<toc>.keys {
            my $rv = "<ul class=\"menu-list\">\n";
            my Bool $sub-list = False;
            my $last-level;
            for %prm<toc>.list -> $el {
                with $last-level {
                    if $el.<level> eq $last-level {
                        $rv ~= '</li>'
                    }
                    else {
                        if $el.<level> eq 1 {
                            $rv ~= '</ul></li>';
                            $sub-list = False
                        }
                        elsif ! $sub-list {
                            $rv ~= '<ul>';
                            $sub-list = True;
                        }
                    }
                }
                $rv ~= '<li>'
                    ~ '<a href="#'
                    ~ %tml<escaped>.($el.<target>)
                    ~ '">'
                    ~ %tml<escaped>.($el.<text> // '')
                    ~ '</a>';
                $last-level = $el.<level>;
            }
            if $last-level eq 1 {
                $rv ~= "</li></ul>\n"
            }
            else {
                $rv ~= "</li></ul></li></ul>\n"
            }
        }
        else { '' }
    },
);