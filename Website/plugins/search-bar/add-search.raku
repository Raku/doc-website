#!/usr/bin/env raku
use v6.d;
use JSON::Fast;
use ProcessedPod;

sub ($pp, %processed, %options) {
    # This routine creates the JS data structure to be added to the JS query function
    # The data structure is an array of hashes :category, :value, :url
    # Category is used to split up items, value is what is searched for, url is where it is to be found.
    # eg { "category": "Types", "value": "Distribution::Hash", "url": "/type/Distribution::Hash" }
    # The first three items are supplied for some reason.
    my @entries =
        %( :category("Syntax"), :value("# single-line comment"), :url("/language/syntax#Single-line_comments")),
        %( :category("Syntax"), :value("#` multi-line comment"),
           :url("/language/syntax#Multi-line_/_embedded_comments")),
        %( :category("Signature"), :value(";; (long name)"), :url("/type/Signature#index-entry-Long_Names"));
    my $categories = <Syntax Signature Heading Glossary>.SetHash;
    # collect info stored from parsing headers
    # structure of processed
    # <filename> => %( :config-data => :kind, @sub-kind, @category )
    # Helper functions as in Documentable
    sub escape(Str $s) is export {
        $s.trans([</ \\ ">] => [<\\/ \\\\ \\">]);
    }
    sub escape-json(Str $s) is export {
        $s.subst(｢\｣, ｢%5C｣, :g).subst('"', '\"', :g).subst(｢?｣, ｢%3F｣, :g)
    }
    for %processed.kv -> $fn, $podf {
        my $value = $podf.name ~~ / ^ 'type/' (.+) $ / ?? ~$/[0] !! $podf.name;
        @entries.push: %(
            :category($podf.pod-config-data<subkind>.tc),
            :$value,
            :info(' '),
            :url(escape-json('/' ~ $fn))
        );
        for $podf.raw-toc.grep({ !(.<is-title>) }) {
            @entries.push: %(
                :category<Heading>,
                :value(.<text>),
                :info(': section in <b>' ~ escape-json($podf.title) ~ '</b>'),
                :url(escape-json('/' ~ $fn ~ '#' ~ .<target>))
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
            ~ JSON::Fast::to-json(@entries)
            ~ ";
    \n"
        ~ 'search-temp.js'.IO.slurp;
    [
        [ 'assets/scripts/search-bar.js', 'myself', 'search-bar.js' ],
    ]
}