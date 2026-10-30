%(
    # plugins in the order to be applied
    # templates in later plugins over-ride or can use those in earlier ones
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
        Elucid8::Plugin::HTML::Favicon
        Doc-Website::Plugin::PageStyling:ver<0.2.2>
        Doc-Website::Plugin::SiteData:ver<0.1.0>
        Doc-Website::Plugin::DataTable:ver<0.1.0>
        Doc-Website::Plugin::Search:ver<0.1.0>
        Doc-Website::Plugin::TypeGraphs:ver<0.1.0>
        Doc-Website::Plugin::BrowserREPL:ver<0.1.5>
        Doc-Website::Plugin::CreditObject:ver<0.1.0>
        Doc-Website::Plugin::Edit-in-github:ver<0.1.0>
    >,
    # callable in the class will expect arguments as documented here
    setup => (# sequence not hash because order can matter
    # callable-name ( %config )
        CreditObject => 'get-repo-data',
        Favicon => 'move-favicon',
#        BrowserREPL => 'get-rakupp',
    ),
    pre-file-render => (# sequence not hash because order can matter
    # callable-name ( $rdp, $lang, $fn, $ast )
        SiteData => 'initialise',
        TypeGraphs => 'add-typegraph',
    ),
    post-file-render => (# sequence not hash because order can matter
    # callable-name ( $rdp, $rendered-html )
    ),
    post-all-content-files => (# sequence not hash because order can matter
    # callable-name ( $rdp, $lang, $to, %config )
        SiteData => 'gen-composites',
        Search => 'prepare-search-data',
    ),
    post-all-files => ( # sequence because order matters
    # callable-name ( $rdp, %site-config )
        SiteMap => 'create-site-map'
    )
)
