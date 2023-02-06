%(
    plugin-options => %(
        cro-app => %(
            :port<30000>,
            :host<0.0.0.0>,
        ),
        link-error-test => %(
            :no-remote,
        ),
        raku-repl => %(
            :websocket-host<finanalyst.org>,
            :websocket-port<443>,
        ),
        search-bar => %(
            :search-site<new-raku.finanalyst.org>,
        ),
    ),
)