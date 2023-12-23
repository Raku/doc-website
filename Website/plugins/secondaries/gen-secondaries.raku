#!/usr/bin/env raku
use v6.d;
use RakuConfig;
use ProcessedPod;
use Collection::Progress;
use nqp;

sub (ProcessedPod $pp, %processed, %options) {
    my regex defnmark {
        '<!-- defnmark' \s+
        $<target> = (.+?) \s+
        $<level> = (\d+) \s+
        '-->'
    }
    my $level;
    my regex chunk {
        (.+?)
        <?before
            "<h$level"
            | "<h{ $level - 1 > 0 ?? $level - 1 !! '' }"
            | "<h{ $level - 2 > 0 ?? $level - 2 !! '' }"
            | "<h{ $level - 3 > 0 ?? $level - 3 !! '' }"
            | "<h{ $level - 4 > 0 ?? $level - 4 !! '' }"
            | '</section'
            | '</body'
            | $
        >
    }
    sub good-name($name is copy --> Str) is export {
        # Documentable substitutes Filesystem unsafe chars with
        # / => $SOLIDUS
        # % => $PERCENT_SIGN
        # ^ => $CIRCUMFLEX_ACCENT
        # # => $NUMBER_SIGN
        # So, we need to generate psuedo-urls that will also point to hashed files using
        # the same algorithm as Documentable. If these are used in anchors in sources, they
        # will be correctly mapped as well.
        my @badchars = ["/", "^", "%"];
        my @goodchars = @badchars
            .map({ '$' ~ .uniname })
            .map({ .subst(' ', '_', :g) });
        # Collection has already escaped names, so de-HTML-escape name
        $name .= trans(qw｢ &lt; &gt; &amp; &quot; ｣ => qw｢ <    >    &   " ｣);
        $name .= subst(@badchars[0], @goodchars[0], :g);
        $name .= subst(@badchars[1], @goodchars[1], :g);
        # if it contains escaped sequences (like %20) we do not
        # escape %
        if (!($name ~~ /\%<xdigit> ** 2/)) {
            $name .= subst(@badchars[2], @goodchars[2], :g);
        }
        $name;
    }
    my %config = get-config;
    my $hash-urls = %config<hash-urls>;
    $hash-urls = $_ with $pp.get-data('secondaries')<hash-urls>;
    my %data = $pp.get-data('heading');
    #| get the definitions stored after parsing headers
    my %definitions = %data<defs>;
    #| each of the things we want to group in a file
    my %things = %( routine => {}, syntax => {});
    #| url mapping data
    my %url-maps;
    #| templates hash in ProcessedPod instance
    my %templates := $pp.tmpl;
    #| container for the triples describing the files to be transferred once created
    my @transfers;
    #| container for tablesearch plugin
    my @routines = [ ['Category', 'Name' , 'Type', 'Where documented'] , ];
    counter(:items(%definitions.keys), :header('Gen secondaries stage 1 ')) unless %options<no-status>;
    for %definitions.kv -> $fn, %targets {
        counter(:dec) unless %options<no-status>;
        my $html = %processed{$fn}.pod-output;
        while $html ~~ m:c / <defnmark> / {
            given $/<defnmark> {
                my $targ = .<target>.Str;
                unless %targets{ $targ }:exists and $targ {
                    die "Error in secondaries, target ｢$targ｣ not found in definitions but in file ｢$fn｣ as ｢$_｣";
                }
                my %attr = %targets{ $targ }.clone;
                my $kind = %attr<kind>:delete;
                %attr<target> = $targ;
                %attr<source> = $fn;
                $level = .<level>.Str;
                $html ~~ m:c / <chunk> /;
                %attr<body> = $/<chunk>[0].Str.trim;
                %things{$kind}{%attr<name>} = [] unless (%things{$kind}{%attr<name>}:exists);
                %things{$kind}{%attr<name>}.push: %attr;
            }
        }
    }
    counter(:items(%things.keys), :header('Gen secondaries stage 2')) unless %options<no-status>;
    for %things.kv -> $kind, %defns {
        counter(:dec) unless %options<no-status>;
        for %defns.kv -> $dn, @dn-data {
            my $mapped-name = 'hashed/' ~ nqp::sha1( "$kind/$dn" );
            my $fn-name-old = "{ $kind.Str.lc }/{ good-name($dn) }";
            my $fn-new = "{ $kind.Str.lc }/$dn";
            $mapped-name = $fn-name-old unless $hash-urls;
            my $esc-dn = $dn.subst(/ <-[ a .. z A .. Z 0 .. 9 _ \- \. ~ ]> /,
                *.encode>>.fmt('%%%02X').join, :g);
            # special case '.','..','\'
            $esc-dn ~= '_(as_name)' if $dn eq any( < . .. >);
            $esc-dn = 'backslash character' if $dn eq '\\';
            my $url = "{ $kind.Str.lc }/$esc-dn";
            %url-maps{ $url } = $mapped-name;
            %url-maps{ $fn-new.subst(/\"/,'\"',:g) } = $mapped-name;
            unless $fn-name-old eq $fn-new {
                %url-maps{ $fn-name-old.subst(/\"/,'\"',:g) } = $mapped-name
            }
            my $title = $dn.trans(qw｢ &lt; &gt; &amp; &quot; ｣ => qw｢ <    >    &   " ｣);
            my $subtitle = 'Combined from primary sources listed below.';
            my @sources;
            my @subkind;
            my @category;
            my $podf = PodFile.new(
                :name($dn),
                :pod-config-data(%( :$kind, :subkind<Composite> )),
                :$title,
                :path($url),
            );
            my $body;
            my @toc;
            for @dn-data {
                # Construct body
                @subkind.append: .<subkind>;
                @category.append: .<category>;
                @sources.push: .<source>;
                my $target = .<source> ~ $kind ~ .<subkind>;
                my $text = 'In ' ~ .<source>;
                @toc.push: %( :1level, :$text, :$target );
                $body ~= %templates<heading>.(%(
                  :1level,
                  :skip-parse,
                  :$target,
                  :$text,
                  :top($podf.top)
                ), %templates);
                $body ~= %templates<para>.(%(
                   :contents(qq:to/CONT/)
                        See primary documentation
                        <a href="/{ .<source> }#{ .<target> }">in context\</a>
                        for <b>{ .<target>.subst( / '_' / , ' ', :g ) }</b>
                    CONT
                ), %templates);
                $body ~= .<body>;
                @routines.push: [
                    .<category>.tc,
                    $dn,
                    .<subkind>,
                    qq[[<a href="/{ .<source> }#{ .<target> }">{ .<source> }</a>]]
                ];
            }
            # Construct TOC
            $podf.raw-toc = @toc;
            my $toc = %templates<toc>.( %( :@toc ) , %templates );
            # The podf subtitle is used for the search engine
            $podf.subtitle = 'From: ' ~ @sources.join(', ');
            # Add data to Processed file
            $podf.pod-config-data(:$kind, :@subkind, :@category);
            %processed{$url} = $podf;
            # Output html file / construct transfer triple
            "html/$mapped-name\.html".IO.spurt: %templates<source-wrap>.(%(
                :$title,
                :$subtitle,
                :$body,
                :config(%( :name($dn), :path($url), :lang($podf.lang))),
                :$toc,
                :glossary(''),
                :meta(''),
                :footnotes(''),
            ), %templates);
            @transfers.push: ["$mapped-name\.html", 'myself', "html/$mapped-name\.html"]
        }
    }
    my %ns;
    if 'tablemanager' ~~ any( $pp.plugin-datakeys ) {
        %ns := $pp.get-data('tablemanager');
        %ns<dataset> = {} without %ns<dataset>;
        %ns<dataset><routines> = @routines;
    }
    if $hash-urls {
        'prettyurls'.IO.spurt: %url-maps.fmt("\"\/%s\" \"\/%s\"").join("\n");
        @transfers.push: ['assets/prettyurls', 'myself', 'prettyurls'];
    }
    @transfers
}
