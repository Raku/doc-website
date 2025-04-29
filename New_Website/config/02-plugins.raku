%(
    # plugins in the order to be applied
    # templates in later plugins over-ride or can use those in earlier ones
    # elucid8-build prefixes names here with 'RakuDoc::Plugin::HTML::'
    plugins => <
        RakuDoc::Plugin::HTML::Hilite
        RakuDoc::Plugin::HTML::ListFiles
        RakuDoc::Plugin::HTML::Graphviz
        RakuDoc::Plugin::HTML::FontAwesome
        RakuDoc::Plugin::HTML::Latex
        RakuDoc::Plugin::HTML::LeafletMaps
        RakuDoc::Plugin::HTML::SCSS
        Elucid8::Plugin::HTML::UISwitcher
        Elucid8::Plugin::HTML::AutoIndex
        Elucid8::Plugin::HTML::SiteMap
        Raku-Doc-Website::PageStyling
        Raku-Doc-Website::SiteData
        Raku-Doc-Website::DataTable
        Raku-Doc-Website::Search
        Raku-Doc-Website::TypeGraphs
        Raku-Doc-Website::Edit-In-Browser
        Raku-Doc-Website::RakuREPL
    >,
    setup => (# sequence not hash because order can matter
        RakuREPL => 'set-host-port',
        Edit-In-Browser => 'set-host-port',
#        CreditTable => 'get-repo-data',
    ),
    pre-file-render => (# sequence not hash because order can matter
        SiteData => 'initialise',
        TypeGraphs => 'add-typegraph',
    ),
    post-file-render => (# sequence not hash because order can matter
    ),
    post-all-content-files => (# sequence not hash because order can matter
        SiteData => 'gen-composites',
        Search => 'prepare-search-data',
    ),
    post-all-files => ( # sequence because order matters
        SiteMap => 'create-site-map'
    )
)
