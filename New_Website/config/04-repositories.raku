%(
    :repository-store<repos>,
    :repository-info-file<repo-info.rakuon>,
    repositories => %(
        raku-docs => %(
            repo-name => 'Raku/doc',
            description => 'documentation of the Raku language',
            languages => %(
                en => %(
                    source-entry => 'doc/',
                    destination-modify => '*.subst(/ ^\w /, *.lc)',
                ),
            ),
        ),
        rakudoc => %(
            repo-name => 'Raku/RakuDoc-v2',
            description => 'Rakudoc specification document',
            languages => %(
                en => %(
                    source-entry => '',
                    destination => 'language',
                    :select<rakudoc_v2_specification rakudoc_v2_exposition>,
                ),
            ),
        ),
        'self' => %( # meaning this repository
            repo-name => 'Raku/doc-website',
            description => 'website sources',
            languages => %(
                en => %(
                    source-entry => 'site-sources/en/',
                    edit-path => 'New_Website',
                ),
            ),
        ),
    ),
)
