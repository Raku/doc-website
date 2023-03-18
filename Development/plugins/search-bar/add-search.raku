#!/usr/bin/env raku
use v6.d;
use JSON::Fast;
use ProcessedPod;

sub ( $pp, %processed, %options ) {
    my $search-site = $pp.get-data('search-bar')<search-site>;
    # This routine creates the JS data structure to be added to the JS query function
    # The data structure is an array of hashes :category, :value, :url
    # Category is used to split up items, value is what is searched for, url is where it is to be found.
    # eg { "category": "Types", "value": "Distribution::Hash", "url": "/type/Distribution::Hash" }
    # The first three items are supplied for some reason.
    my @entries =
        %( :category("Syntax"), :value("# single-line comment"), :url("/language/syntax.html#Single-line_comments") ),
        %( :category("Syntax"), :value("#` multi-line comment"), :url("/language/syntax.html#Multi-line_/_embedded_comments") ),
        %( :category("Signature"), :value(";; (long name)"), :url("/type/Signature.html#index-entry-Long_Names") )
    ;
    my $categories = <Syntax Signature Heading Glossary>.SetHash;
    # collect info stored from parsing headers
    my %defns = $pp.get-data('heading')<defs>;
    # structure of %defns is <file name as in processed> => %( <target> => %info )
    # %info = :name, :kind, :subkind, :category
    note 'no data from parsed headings' unless +%defns;
    # structure of processed
    # <filename> => %( :config-data => :kind, @sub-kind, @category )
    # Helper functions as in Documentable
    #| We need to escape names like \. Otherwise, if we convert them to JSON, we
    #| would have "\", and " would be escaped.
    sub escape(Str $s) is export {
        $s.trans([</ \\ ">] => [<\\/ \\\\ \\">]);
    }
    sub escape-json(Str $s) is export {
        $s.subst(｢\｣, ｢%5c｣, :g).subst('"', '\"', :g).subst(｢?｣, ｢%3F｣, :g)
    }
    for %defns.kv -> $fn, %targets {
        for %targets.kv -> $targ, %info {
            my $category = %info<category>.tc ;
            $category = %info<subkind>.tc ~ ' operator' if $category eq 'Operator';
            $categories{ $category }++;
            @entries.push: %(
                :$category,
                :value( escape( %info<name> ) ),
                :info( ': in <b>' ~ escape-json($fn) ~ '</b>' ),
                :url( escape-json( "/$fn\.html\#$targ" ) )
            )
        }
    }
    for %processed.kv -> $fn, $podf {
        next unless $podf.pod-config-data<subkind>:exists;
        my $value = $podf.name ~~ / ^ 'type/' (.+) $ / ?? ~$/[0] !! $podf.name;
        @entries.push: %(
            :category( $podf.pod-config-data<subkind>.tc ),
            :value( escape-json( $value )),
            :info( ' ' ),
            :url( escape-json( '/' ~ $fn ~ '.html' ))
        );
        for $podf.raw-toc.grep({ !(.<is-title>) }) {
            @entries.push: %(
                :category<Heading>,
                :value( escape( .<text> ) ),
                :info( ': section in <b>' ~ escape-json( $podf.title ) ~ '</b>' ),
                :url( escape-json( '/' ~ $fn ~ '.html#' ~ .<target> ) )
            )
        }
        $categories{ $podf.pod-config-data<kind>.tc }++
    }
    # try to file out duplicates by looking for only unique urls
    @entries .= unique(:as( *.<url> ) );
    # now sort so js only does filtering.
    sub head-or-fivesix( $a, $b ) { # heading and 5to6 are independent
        return Order::Same unless $a ~~ Str:D and $b ~~ Str:D;
        my $a-h = $a.contains('heading',:i);
        my $b-h = $b.contains('heading',:i);
        my $a5 = $a.contains('5to6');
        my $b5 = $b.contains('5to6');
        return Order::Same if ($a-h and $b-h) or ($a5 and $b5);
        return Order::More if $a-h or $a5;
        return Order::Less if $b-h or $b5;
        return $a cmp $b
    }
    @entries .= sort({ &head-or-fivesix( $^a.<category>, $^b.<category> ) })
        .sort({ &head-or-fivesix( $^a.<url>, $^b.<url> ) })
        .sort({ $^a.<value> cmp $^b.<value> });
    $pp.add-data('extendedsearch', $categories.keys);
    'search-bar.js'.IO.spurt:
        'var items = '
        ~ to-json( @entries )
        ~ ";\n"
#        ~ "var searchSite = '$search-site';\n"
        ~ 'search-temp.js'.IO.slurp;
    [
        [ 'assets/scripts/search-bar.js', 'myself', 'search-bar.js' ],
    ]
}