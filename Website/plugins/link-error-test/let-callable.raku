#!/usr/bin/env perl6
use LibCurl::HTTP;
use Collection::Progress;

sub ($pr, %processed, %options) {
    my %config = $pr.get-data('link-error-test');
    return [] unless %config<run-tests>;
    my regex htmlcode {
        \% <[0..9 A..F]> ** 2
    };
    my regex xx-htmlcode {
        '%C2' <htmlcode>
    }
    my regex xxx-htmlcode {
        '%E2' <htmlcode> <htmlcode>
    }
    # only defined for Upper case
    my %errors = <no-file unknown remote no-target> Z=> {}, {}, {}, {};
    my %links;
    my %targets;
    #| possible filenames that map to a real html file
    my %aliases;

    sub failed-targets($file, Str $target) {
        my $old = $target.trim;
        my @ok-targets;
        my @tested-variants;
        if %aliases{ $file }:exists {
            @ok-targets = %targets{ %aliases{ $file } }.list
        }
        else {
            @ok-targets = %targets{$file}.list
        }
        # straight check
        @tested-variants.push: $old;
        return () if $old eq any(@ok-targets);
        return @tested-variants unless $old ~~ / <htmlcode> /;
        # first check for xhtml
        my $new = $old;
        given $old {
            when / <xxx-htmlcode> / {
                =comment these are the four three-byte codes found in Raku documentation
                %E2%80%A6 \u2026 …
                %E2%88%98 \u2218 ∘
                %E2%88%85 \u2205 ∅
                %E2%80%93 \u2213 ∓

                $new .= trans(<%E2%80%A6 %E2%88%98 %E2%88%85 %E2%88%85 >
                          => ['…',       '∘',      '∅',      '∓']);
                proceed
            }
            when / <xx-htmlcode> / {
                =comment these are the three two-byte codes found in Raku documentation
                %C2%AB \u00AB «
                %C2%BB \u00BB »
                %C2%B2 \u00B2 ²

                $new .= trans(<%C2%AB %C2%BB %C2%B2 >
                           => ['«',   '»',   '²']);
                proceed
            }
            default {
                # so target has delimited chars
                $new .=  trans(< %20  %24  %26  %28  %29  %2A  %2B  %2F  %3A %3C  %3E  %3F  %40  %5E  %7C   %A6  %BB   > =>
                                [' ', '$', '&', '(', ')', '*', '+', '/', ':', '<', '>', '?', '@', '^', '|', '¦', '»']);
            }
        }
        @tested-variants.push: $new;
        return () if $new eq any(@ok-targets);
        return @tested-variants unless $new ~~ / '&' .+? ';' /;
        $new .= trans(qw｢ &lt; &gt; &amp; &quot; ｣ => qw｢ <    >    &     " ｣ );
        @tested-variants.push: $new;
        return () if $new eq any(@ok-targets);
        return @tested-variants
    }
    sub test-remote($url --> Str ) {
        state $http = LibCurl::HTTP.new;
        my $resp;
        try {
            $resp = $http.HEAD($url).perform.response-code;
        }
        if $! {
            $resp = $http.error;
        }
        # return blank if any stringified response code
        return '' if ?(+$resp);
        # any numerical response code indicates http link is live
        # failures with non 404 ok as well.
        return '' if ($resp ~~ / \:\s(\d\d\d) / and +$0 != 404);
        $resp
    }
    %aliases = %config<aliases>.kv.map({ '/' ~ $^a => '/' ~ $^b });
    #| SetHash of files in collection
    my SetHash $files .= new( %aliases.keys );
    #| SetHash of files found missing
    my SetHash $missing .= new;
    my @remote-links;
    # go through all the rendered files and pick up links and targets
    for %processed.kv -> $fn, $podf {
        # not all files have links, but may be targets, so store filenames
        $files{"/$fn"}++;
        # format of podf.links Str entry => target/link-label/type/place
        # entry is not needed, but keeps the data together
        # filter out remote schemas, not target/location/link
        %links{$fn} = %(gather for $podf.links {
            if .value<type> eq 'external' {
                push @remote-links, [$fn, .value<target>, .value<link-label>]
            }
            else {
                take $_
            }
        });
        #format of podf/targets array of target ids
        %targets{"/$fn"} = [$podf.targets.keys];
    }
    # External tests
    if %config<no-remote>:exists and %config<no-remote> {
        %errors<remote><no_test> = True;
    }
    else {
        %errors<remote><no_test> = False;
        counter(:items(@remote-links.map( *.[1] ) ), :header('Testing remote links') ) unless %options<no-status>;
        for @remote-links -> ($fn, $url, $link-label) {
            counter(:dec) unless %options<no-status>;
            my $resp = test-remote($url);
            %errors<remote>{$fn}.push(%( :$url, :$resp, :$link-label)) if $resp;
        }
    }
    # test for local and internal links by matching link targets, with anchor targets registered in files
    for %links.kv -> $fn, %spec {
        for %spec.kv -> $link, %registered {
            given %registered<type> {
                when 'local' {
                    # skip this test if a file has already been registered as missing
                    next if $missing{ %registered<target> };
                    # fail if the file is not in the collection list
                    unless $files{ %registered<target> } {
                        $missing{ %registered<target> }++;
                        %errors<no-file>{$fn}.push(%(
                            :file( %registered<target> ),
                            :link-label( %registered<link-label> )
                        ));
                        next
                    }
                    # by here file exists, so check to see whether link has a specific place listed for that file
                    next unless %registered<place>:exists and %registered<place>;
                    my @failed = failed-targets( %registered<target> , %registered<place> );
                    next unless @failed.elems;
                    %errors<no-target>{$fn}.push(%(
                        :file( %registered<target> ),
                        targets => @failed,
                        link-label => %registered<link-label>
                    ))
                }
                when 'internal' {
                    my @failed = failed-targets("/$fn", %registered<place>);
                    next unless @failed.elems;
                    %errors<no-target>{$fn}.push(%(
                        file => $fn,
                        targets => @failed,
                        link-label => %registered<link-label>
                    ))
                }
                default {
                    %errors<unknown>{$fn}.push(%(
                        link-label => %registered<link-label>,
                        url => %registered<target>
                    ))
                }
            }
        }
    }
    $pr.add-data('linkerrortest', %errors);
    []
}