#!/usr/bin/env raku
use v6.d;
%(
    tablemanager => sub (%prm, %tml ) {
        my $rv;
        with %prm<tablemanager> {
            with .<dataset> {
                with .{ %prm<data> } {
                    # enforce type of structure, at least 1 header & 1 data rows, at least 1 column
                    if $_ ~~ Positional and .elems > 2 and .[0].elems > 0 {
                        my $cols = .[0].elems;
                        my $d-rows = .elems - 1 ;
                        my @rows = .Array;
                        $rv = qq[\n<div class="tablemanager-collection">];
                        my $inpt;
                        my $table-id = 'tmTable' ~ %prm<data>.tc;
                        my $head = qq[[\n<table id="$table-id">]];
                        $head ~= ('<caption>' ~ %prm<contents> ~ '</caption>')
                            if %prm<contents>:exists and %prm<contents> ne '';
                        $head ~= "\n<thead><tr>";
                        for ^$cols -> $col {
                            $head ~= "<th>@rows[0][$col]\</th>"
                        }
                        $head ~= "</tr>\n</thead>\n";
                        my $body = "<tbody>\n";
                        for @rows[ 1..^$d-rows ] -> @row {
                            $body ~= '<tr>' ~ @row.map({ "<td>$_\</td>" }).join('') ~ "</tr>\n";
                        }
                        $body ~= "\n</tbody>\n\</table>\n</div>";
                        $rv ~= $head ~ $body ~ qq:to/SCR/
                            <script>
                            \$\('#{ $table-id }').tablemanager(\{
                                firstSort: { %prm<firstSort> // '[[2,0]]' },
                                disable: { %prm<disable> // '["last"]' },
                                appendFilterby: { %prm<appendFilterby> // 'true'},
                                vocabulary: \{
                                    voc_filter_by: 'Filter By',
                                    voc_type_here_filter: 'Filter...',
                                    voc_show_rows: 'Rows Per Page'
                                },
                                pagination: { %prm<pagination> // ' true' },
                                showrows: { %prm<showrows> // ' [5,10,20,50,100]' },
                                disableFilterBy: { %prm<disableFilterBy> // '["last"]' },
		                    \});
                            </script>
                            SCR
                    }
                    else {
                        $rv = qq:to/ERROR/;
                        <div class="listf-error">The data set corresponding to
                        ｢{ %prm<data> }｣ is in the wrong format, has no data rows, or has no columns.
                        This is being rendered from
                        a Rakudoc directive ｢=TableManager :data\<{ %prm<data> }>｣
                        </div>
                        ERROR
                    }
                }
                else {
                    $rv = qq:to/ERROR/;
                    <div class="listf-error">There is no data corresponding to
                    the data set ｢{ %prm<data> }｣. This is being rendered from
                    a Rakudoc directive equivalent to ｢=for TableManager :data\<{ %prm<data> }>｣
                    </div>
                    ERROR
                }
            }
            else {
                $rv = q:to/ERROR/;
                    <div class="listf-error">tablemanager has no data to operate on.
                    Another plugin needs to add a data set to the key ｢<tablemanager><dataset>｣.
                    </div>
                    ERROR
            }
        }
        else {
            $rv = q:to/ERROR/;
            <div class="listf-error">There is no namespace for ｢tablemanager｣.
            Is ｢tablemanager｣ in the Mode's ｢plugins-required<render>｣ list?
            Another plugin needs to provide the data set.
            </div>
            ERROR
        }
        $rv
    },
);