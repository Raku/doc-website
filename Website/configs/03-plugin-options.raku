%(
    plugin-options => %(
        cro-app => %(
            :port<30000>,
            :host<0.0.0.0>,
            :url-map<assets/prettyurls assets/deprecated-urls>,
        ),
        link-error-test => %(
            :no-remote,
            :run-tests,
            :structure-files<introduction about index miscellaneous reference routines types>,
        ),
        sitemap => %(
            :root-domain<https://docs.raku.org>,
            :sitemap-destination<../../rendered_html>,
        ),
        sqlite-db => %(
            :database-dir<../../sqlite_dir>,
            :db-filename<sqlite-db-definition.sql>,
        ),
    ),
)