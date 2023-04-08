%(
    pod => sub (%prm, %tml) {
        my $rv = %tml.prior('pod').(%prm, %tml);
        if (%prm<config><path> ~~ / 'doc/Type/' $<doc> = (.+) '.' <alnum>+ /)
            and %prm<pod><typegraphs>:exists {
            my $doc = $<doc>
                .subst( / [ '.rakudoc' || '.pod6' ] $ /, '')
                .subst( / '/' /, '', :g )
                .subst( / \:\: /, '', :g );
            with %prm<pod><typegraphs>{ $doc } {
                my $name =  %prm<config><name>
                    .subst( / ^ 'type/' /, '')
                    .subst( / '/' /, '::', :g ) ;
                $rv ~= %tml<heading>.(
                    %( %prm ,
                        :skip-parse,
                        :1level,
                        :target<typegraphrelations>,
                        :text<Typegraph>
                       ), %tml);
                $rv ~= qq:to/TYPEG/;
                    <figure class="typegraph" >
                      <figcaption>Type relations for <code>$name\</code>\</figcaption>
                      $_
                        <p class="fallback">
                            <a rel="alternate" href="/assets/typegraphs/$doc.svg">
                            Expand chart above
                        </a>\</p>
                    </figure>
                    TYPEG
            }
        }
        $rv
    },
)