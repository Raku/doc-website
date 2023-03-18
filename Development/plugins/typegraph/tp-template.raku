%(
    pod => sub (%prm, %tml) {
        my $rv = %tml.prior('pod').(%prm, %tml);
        if (%prm<config><path> ~~ / 'doc/Type/' $<doc> = (.+) '.pod6' /)
            and %prm<pod><typegraphs>:exists {
            with %prm<pod><typegraphs>{ $<doc> } {
                $rv ~= %tml<heading>.(
                    %( %prm ,
                        :skip-parse,
                        :1level,
                        :target<typegraphrelations>,
                        :text<Typegraph>
                       ), %tml);
                $rv ~= qq:to/TYPEG/;
                    <figure class="typegraph" >
                      <figcaption>Type relations for <code>{ %prm<config><name> }</code></figcaption>
                      $_
                        <p class="fallback">
                            <a rel="alternate" href="/assets/typegraphs/$<doc>.svg">
                            Expand chart above
                        </a></p>
                    </figure>
                    TYPEG
            }
        }
        $rv
    },
)
