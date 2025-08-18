%(
    plugin-options => %(
        SiteMap => %(
            :root-domain<https://docs.raku.org>,
        ),
        RakuREPL => %(
            :repl-websocket('wss://finanalyst.org/raku_repl'),
        ),
        ConfigEdit => %(
            :suggestion-websocket('wss:finanalyst.org/suggestion_box'),
            :patch-limit(5120), # limit on length of patch 5k chars
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
