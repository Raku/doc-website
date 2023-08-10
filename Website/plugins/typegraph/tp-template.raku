%(
    pod => sub (%prm, %tml) {
        my $rv = %tml.prior('pod').(%prm, %tml);
        return $rv without %prm<config><kind>;
        return $rv unless %prm<config><kind> eq 'Type';

        my $fn = %prm<config><path>.IO.extension('');
        my $doc = ($fn.parts[1]<dirname>.contains('Native') ?? 'native-' !! '' ) ~ $fn.basename;
        $doc .= subst( / '/' /, '', :g )
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
        $rv
    },
)