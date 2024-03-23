#!/usr/bin/env raku
use v6.d;
%(
    raku-toc-block => sub (%prm, %tml) { # called by source-wrap with rendered toc & rendered glossary
        if %prm<toc> {
            qq:to/TOC/
            <div class="tabs" id="tabs">
              <ul>
                <li class="is-active" id="toc-tab">
                  <a>Table of Contents</a>
                </li>
                <li id="index-tab">
                  <a>Index</a>
                </li>
              </ul>
            </div>
              <div class="field">
                <div class="control has-icons-right">
                  <input id="toc-filter" class="input" type="text" placeholder="Filter">
                  <span class="icon is-right has-text-grey">
                    <i class="fas fa-search is-medium"></i>
                  </span>
                </div>
              </div>
              <div class="raku-sidebar">
                <aside id="toc-menu" class="menu">
                { %prm<toc> }
                </aside>
                <aside id="index-menu" class="menu is-hidden">
                { %prm<glossary> }
                </aside>
              </div>
            TOC
        }
        else {
            qq:to/TOC/
                <input type="checkbox" id="No-TOC"
                    checked="checked"
                    style="visibility: collapse;">
                </input>
                <div class="content">No Table of Contents or Index available</div>
            TOC
        }
    },
    toc => sub (%prm, %tml) { # special template called within ProcessedPod
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
    'glossary' => sub (%prm, %tml) { # special template called by ProcessedPod
        if %prm<glossary>.defined and %prm<glossary>.keys {
#            '<div id="_Glossary" class="glossary">' ~ "\n"
#                ~ '<div class="glossary-caption">Index</div>' ~ "\n"
#                ~ [~] %prm<glossary>.map({
#                '<div class="glossary-defn">'
#                    ~ ($_<text> // '')
#                    ~ '</div>'
#                    ~ '<div class="glossary-places">'
#                    ~ [~] $_<refs>.map({
#                    '<div class="glossary-place"><a href="#'
#                        ~ %tml<escaped>.($_<target>)
#                        ~ '">'
#                        ~ ($_<place>.defined ?? $_<place> !! '')
#                        ~ "</a></div>\n"
#                })
#                ~ '</div>'
#            })
#            ~ "</div>\n"
            "<ul class=\"menu-list\">\n"
                ~ [~] %prm<glossary>.map({
                    '<li>' ~ ( .<text> // '' ) ~ "<ul>\n"
                    ~ [~] .<refs>.grep( ! *.<is-header> ).map({
                        '<li><a href="#'
                        ~ %tml<escaped>.( .<target> )
                        ~ '">'
                        ~ .<place>.subst( / \( ~ \) .+? $ /, '')
                        ~ "</a></li>\n"
                    })
                    ~ "</ul></li>\n"
                })
                ~ "</ul>\n"
        }
        else { '' }
    },
);
