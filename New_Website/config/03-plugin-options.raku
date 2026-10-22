%(
    plugin-options => %(
        SiteMap => %(
            :root-domain<https://new-raku.finanalyst.org>,
        ),
        CreditObject => %(
            :top-committer-threshold(250),
            filter => %(
                'finanalyst' => 'Richard Hainsworth',
                'Coke' => 'Will Coleda',
                'Will "Coke" Coleda' => 'Will Coleda',
                'lizmat' => 'Elizabeth Mattijsen',
                'Juan Julián Merelo Guervós' => 'JJ Merelo',
            )
        ),
    ),
)
