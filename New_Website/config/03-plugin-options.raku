%(
    plugin-options => %(
        cro-app => %(
            :port( 5000 ),
            :host<0.0.0.0>,
            :url-map<assets/prettyurls assets/deprecated-urls>,
        ),
        SiteMap => %(
            :root-domain<https://docs.raku.org>,
        ),
    ),
)
