%(
    :repository-store<repos>,
    :repository-info-file<repo-info.rakuon>,
    repositories => %(
        for-testing => %(
            repo-name => 'finanalyst/tmp-test',
            description => 'testing file',
            languages => %(
                en => %(
                    source-entry => '',
                    destination => 'language',
                    :select('TestFile',),
                ),
            ),
        ),
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
            repo-name => 'Raku/RakuDoc-GAMMA',
            description => 'Rakudoc specification document',
            languages => %(
                en => %(
                    source-entry => '',
                    destination => 'language',
                    :select('rakudoc_v2',),
                ),
            ),
        ),
        'self' => %( # meaning this repository
            repo-name => 'raku-doc-website',
            description => 'website sources',
            languages => %(
                en => %(
                    source-entry => 'site-sources/en/',
                ),
            ),
        ),
    ),
)
