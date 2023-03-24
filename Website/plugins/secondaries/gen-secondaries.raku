#!/usr/bin/env raku
use v6.d;
use ProcessedPod;
use Collection::Progress;

sub ($pp, %processed, %options) {
    # these chars cannot appear in a unix filesystem path
    my regex defnmark {
        '<!-- defnmark' \s+
        $<target> = (.+?) \s+
        '-->'
        $<body> = (.+?)
        <?before '<h' | '</section' | '</body' | $ >
    }
    sub good-name($name is copy --> Str) is export {
        # / => $SOLIDUS
        # % => $PERCENT_SIGN
        # ^ => $CIRCUMFLEX_ACCENT
        # # => $NUMBER_SIGN
        my @badchars = ["/", "^", "%"];
        my @goodchars = @badchars
            .map({ '$' ~ .uniname })
            .map({ .subst(' ', '_', :g) });
        # de-HTML-escape name, change bad to good, make _ into %20
        $name .= trans(qw｢ &lt; &gt; &amp; &quot; ｣ => qw｢ <    >    &   " ｣);
        $name .= subst(@badchars[0], @goodchars[0], :g);
        $name .= subst(@badchars[1], @goodchars[1], :g);
        $name .= subst( / '_' /, '%20', :g );
        # if it contains escaped sequences (like %20) we do not
        # escape %
        if (!($name ~~ /\%<xdigit> ** 2/)) {
            $name .= subst(@badchars[2], @goodchars[2], :g);
        }
        $name;
    }
    my %data = $pp.get-data('heading');
    #| get the definitions stored after parsing headers
    my %definitions = %data<defs>;
    #| each of the things we want to group in a file
    my %things = %( routine => {}, syntax => {});
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
        my $parsed = $html ~~ / [<defnmark> .*?]+ $ /;
        for $parsed<defnmark> {
            unless %targets{.<target>}:exists and %targets{.<target>} {
                note 'Error in secondaries, expected target ｢'
                    ~ .<target>.raku
                    ~ "｣ not found in definitions with file ｢$fn｣ defnmark ｢{$parsed<defnmark>}｣";
                next
            }
            my %attr = %targets{.<target>}.clone;
            my $kind = %attr<kind>:delete;
            %attr<target> = .<target>.Str;
            %attr<body> = .<body>.trim;
            %attr<source> = $fn;
            %things{$kind}{%attr<name>} = [] unless (%things{$kind}{%attr<name>}:exists);
            %things{$kind}{%attr<name>}.push: %attr;
        }
    }
    counter(:items(%things.keys), :header('Gen secondaries stage 2')) unless %options<no-status>;
    for %things.kv -> $kind, %defns {
        counter(:dec) unless %options<no-status>;
        for %defns.kv -> $dn, @dn-data {
            # my $url = "/{$kind.Str.lc}/{good-name($name)}";
            my $fn-name = "{ $kind.Str.lc }/{ good-name($dn) }";
            my $title = $dn;
            my $subtitle = 'Combined from primary sources listed below.';
            my @subkind;
            my @category;
            my $podf = PodFile.new(
                name => $dn,
                :pod-config-data(%( :$kind, :subkind<Composite> )),
                :$title,
                :path('synthetic documentation'),
                );
            my $body;
            for @dn-data {
                # Construct body
                @subkind.append: .<subkind>;
                @category.append: .<category>;
                $body ~= %templates<heading>.(%(
                  :1level,
                  :skip-parse,
                  :target($kind ~ .<subkind>),
                  :text('From ' ~ .<source>),
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
            # No TOC for the time being

            # Add data to Processed file
            $podf.pod-config-data(:$kind, :@subkind, :@category);
            %processed{$fn-name} = $podf;
            # Output html file / construct transfer triple
            "html/$fn-name\.html".IO.spurt: %templates<source-wrap>.(%(
                :$title,
                :$subtitle,
                :$body,
                :config(%( :name($dn), :path($fn-name), :lang($podf.lang))),
                :toc(''),
                :glossary(''),
                :meta(''),
                :footnotes(''),
            ), %templates);
            @transfers.push: ["$fn-name\.html", 'myself', "html/$fn-name.html"]
        }
    }
    my %ns;
    if 'tablemanager' ~~ any( $pp.plugin-datakeys ) {
        %ns := $pp.get-data('tablemanager');
        %ns<dataset> = {} without %ns<dataset>;
        %ns<dataset><routines> = @routines;
    }

    @transfers
}
