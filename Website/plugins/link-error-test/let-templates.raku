#!/usr/bin/env perl6
%(
    linkerrortest => sub (%prm, %tml) {
        my $rv = '';
        if %prm<linkerrortest>:exists and +%prm<linkerrortest>.keys {
            my $data = %prm<linkerrortest>;
            # structure: no-file|no-target|unknown|remote
            my %titles =
                no-file => %( :div('Links to missing files'), :cap(q:to/CAP/), ),
                    <table class="table"><tr>
					<th>Document with glitch</th>
                    <th>Displayed text</th>
                    <th>Non-Existent target file</th>
                    </tr>
                    CAP
                no-target => %( :div('Links to non-existent interior targets'), :cap(q:to/CAP/), ),
                    <table class="table"><tr>
					<th>Document with glitch</th>
                    <th>Displayed text</th>
                    <th col-span="2">Document containing anchor</th>
                    <th>Attempted anchor name (variants tried)</th>
                    </tr>
                    CAP
                unknown => %( :div('Unknown target schema (typo in L<> ?)'), :cap(q:to/CAP/), ),
                    <table class="table"><tr>
					<th>Document with glitch</th>
                    <th>Displayed text</th>
                    <th>Dubious url</th>
                    </tr>
                    CAP
                remote  => %( :div('Remote http/s links with bad host or 404'), :cap(q:to/CAP/), :not-set(q:to/NOT/),),
                    <table class="table"><tr>
					<th>Document with glitch</th>
                    <th>Displayed text</th>
                    <th>Dubious url</th>
                    <th>Error response</th>
                    </tr>
                    CAP
                    <table class="table"><tr>
					<th>Remote link test skipped</th>
                    <th>Link-error-test plugin has option <strong>no-remote</strong> set to True</th>
                    </tr>
                    NOT
            ;
            for <remote no-target unknown no-file> -> $type {
                my %object = $data{$type};
                next unless %object.elems;
                $rv ~= '<h2 class="raku-h2">' ~ %titles{$type}<div> ~ "</h2>\n";
                if $type eq 'remote' and %object<no_test> {
                    $rv ~= %titles{$type}<not-set>
                }
                else {
                    $rv ~= %titles{$type}<cap>;
                    for %object.sort.grep( { .value ~~ Positional } ).map(|*.kv) -> $fn, $resp {
                        $rv ~= qq:to/HEAD/;
                            <tr>\<td>\<a class="button" href="$fn" target="_blank" rel="noopener noreferrer">$fn\</a>\</td>
                        HEAD
                        when $type eq 'no-file' {
                            $rv ~= '<td></td><td></td></tr>';
                            for $resp.list -> %info {
                                $rv ~= '<tr><td></td><td>' ~ %tml<escaped>( %info<link-label> )
                                    ~ '</td><td>'
                                    ~ %tml<escaped>(%info<file>)
                                    ~ "</td></tr>\n"
                            }
                        }
                        when $type eq 'unknown' {
                            $rv ~= '<td></td><td></td></tr>';
                            for $resp.list -> %info {
                                $rv ~= '<tr><td></td><td>' ~ %tml<escaped>( %info<link-label> )
                                    ~ '</td><td>'
                                    ~ %tml<escaped>(%info<url>)
                                    ~ '</td>'
                            }
                            $rv ~= "</tr>\n";
                        }
                        when $type eq 'remote' {
                            $rv ~= '<td></td><td></td><td></td></tr>';
                            for $resp.list -> %info {
                                $rv ~= '<tr><td></td><td>' ~ %tml<escaped>( %info<link-label> )
                                    ~ '</td><td>'
                                    ~ %tml<escaped>(%info<url> )
                                    ~ '</td><td>'
                                    ~ %info<resp>
                                    ~ "</td></tr>\n"
                            }
                        }
                        when $type eq 'no-target' {
                            $rv ~= '<td></td><td></td><td></td></tr>';
                            for $resp.list -> %info {
                                $rv ~= '<tr><td></td><td>' ~ %tml<escaped>( %info<link-label> )
                                    ~ '</td><td>'
                                    ~ '<a class="button" href="' ~ %tml<escaped>( %info<file> ) ~ '" target="_blank" rel="noopener noreferrer">'
                                    ~ %tml<escaped>(%info<file> )
                                    ~ "</a></td><td></td></tr>\n"
                                    ~ %info<targets>.map( {
                                        '<tr><td></td><td></td><td></td><td>'
                                        ~ %tml<escaped>( $_ )
                                        ~ "</td></tr>\n"
                                    } )
                            }
                        }
                    }
                }
                $rv ~= "</table>\n"
            }
        }
        else {
            $rv = "<div><h2>Link Tests</h2>No errors detected</div>"
        }
        $rv
    },
)