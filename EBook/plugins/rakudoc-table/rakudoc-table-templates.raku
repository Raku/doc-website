#!/usr/bin/env raku
use v6.d;
%(
    'table' => sub (%prm, %tml) {
        if %prm<procedural> {
            my $rv = "\n<table class=\"table is-bordered centered rakudoc-table { %prm<class> // '' }\">";
            $rv ~= "\n<caption>$_\</caption>" with %prm<caption>;
            for %prm<grid>.list -> @row {
                $rv ~= "\n<tr>";
                for @row -> $cell {
                    next if $cell<no-cell>;
                    my $content;
                    $content ~= ' colspan="' ~ $cell<span>[0] ~'"' if $cell<span>:exists and $cell<span>[0] != 1;
                    $content ~= ' rowspan="' ~ $cell<span>[1] ~'"' if $cell<span>:exists and $cell<span>[1] != 1;
                    $content ~= ' class="';
                    with $cell<align> { for .list {
                        $content ~= "rakudoc-cell-$_ "
                    } }
                    $content ~= 'rakudoc-cell-label' if $cell<label>;
                    $content ~= '">' ~ $cell<data>;
                    if $cell<header> {
                        $rv ~= "<th$content\</th>"
                    }
                    else {
                        $rv ~= "<td$content\</td>"
                    }
                }
                $rv ~= "</tr>"
            }
            $rv ~= "</table>\n";
        }
        else {
            '<table class="table is-bordered centered'
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
        }
    },
)