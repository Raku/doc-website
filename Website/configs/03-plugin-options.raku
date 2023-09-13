%(
    plugin-options => %(
        cro-app => %(
            :port<30000>,
            :host<0.0.0.0>,
            :url-map<assets/prettyurls assets/deprecated-urls>,
        ),
        link-error-test => %(
            :no-remote,
        ),
        raku-repl => %(
            :websocket-host<finanalyst.org>,
            :websocket-port<443>,
        ),
        search-bar => %(
            :search-site<docs.raku.org>,
        ),
    ),
)