#!/usr/bin/env perl6
use LibCurl::HTTP;

sub ($pr, %processed, %options) {
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
    my %config = $pr.get-data('link-error-test');
    sub failed-targets($file, Str $target) {
        my $old = $target.trim;
        # straight check
        return () if $old eq any(%targets{$file}.list);
        return ($old,) unless $old ~~ / <htmlcode> /;
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
        return () if $new eq any(%targets{$file}.list);
        return ($old, $new)
    }
    my SetHash $files .= new;
    my SetHash $missing .= new;
    my @remote-links;
    for %processed.kv -> $fn, $podf {
        # not all files have links, but may be targets, so store filenames
        $files{"/$fn"}++;
        # format of podf.links Str entry -> :place :target :link-label :type
        # entry is not needed, but keeps the data together
        # filter out remote schemas
        # ProcessedPod v0.4 has target/link-label/type/place, not target/location/link
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
        my $num = @remote-links.elems;
        my $starting = $num;
        my $tail = $num ~ " / $starting links  ";
        my $rev = "\b" x $tail.chars;
        my $head = 'Waiting for internet responses on ';
        print  $head ~ $tail unless %options<no-status>;
        my $http = LibCurl::HTTP.new;
        my $start = now;
        for @remote-links -> ($fn, $url, $link-label) {
            my $resp;
            try {
                $resp = $http.HEAD($url).perform.response-code;
            }
            if $! {
                $resp = $http.error;
            }
            $tail = --$num ~ " / $starting links  ";
            print $rev ~ $tail unless %options<no-status>;
            $rev = "\b" x $tail.chars;
            next if ?(+$resp);
            # any numerical response code indicates http link is live
            next if ($resp ~~ / \:\s(\d\d\d) / and +$0 != 404);
            # failures with non 404 ok as well.
            %errors<remote><no_test> = False without %errors<remote><no_test>;
            %errors<remote>{$fn}.push(%( :$url, :$resp, :$link-label));
        }
        my $elap = (now - $start ).Int;
        say "\b" x $head.chars ~ $rev ~ "Collected responses on $starting links in { $elap div 60 } mins { $elap % 60 } secs"
                unless %options<no-status>;
    }
    # all data collected
    for %links.kv -> $fn, %spec {
        for %spec.kv -> $link, %registered {
            given %registered<type> {
                when 'local' {
                    if %registered<target> ~~ / ^ <-[#]>+ $ / {
                        # filter out local schema without #
                        my $file = ~$/;
                        next if $files{$file};
                        # not missing
                        next if $missing{$file};
                        # already registered as missing
                        $missing{$file}++;
                        %errors<no-file>{$fn}.push(%(
                            :$file,
                            link-label => %registered<link-label>
                        ))
                    }
                    elsif %registered<target> ~~ / ^ (<-[#]>+) '#' (.+) $ / {
                        my $file = ~$0;
                        next if $missing{$file};
                        # already registered as missing
                        unless $files{$file} {
                            $missing{$file}++;
                            %errors<no-file>{$fn}.push(%(
                                :$file,
                                link-label => %registered<link-label>
                            ));
                            next
                        }
                        my $target = ~$1;
                        # file exists, but is target listed for that file
                        my @failed = failed-targets($file, $target);
                        next unless @failed.elems;
                        %errors<no-target>{$fn}.push(%(
                            :$file,
                            targets => @failed,
                            link-label => %registered<link-label>
                        ))
                    }
                    # otherwise no action for matches
                }
                when 'internal' and (%registered<target> ~~ / ^ <-[#]>+ $ /) {
#                    my $target = ~$/;
#                    my @failed = failed-targets("/$fn", $target);
#                    next unless @failed.elems;
#                    %errors<no-target>{$fn}.push(%(
#                        file => $fn,
#                        targets => @failed,
#                        link-label => %registered<link-label>
#                    ))
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