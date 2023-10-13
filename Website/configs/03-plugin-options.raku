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
        sitemap => %(
            :root-domain<https://docs.raku.org>,
        )
    ),
)