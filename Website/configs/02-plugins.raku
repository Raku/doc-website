%(
    :plugins<plugins>,
    :plugin-format<html>,
    plugins-required => %(
        :setup<raku-doc-setup>,
        :render<
            font-awesome ogdenwebb camelia simple-extras listfiles images deprecate-span filterlines
            tablemanager secondaries typegraph
            search-bar
            gather-js-jq gather-css
        >,
        :report<link-plugin-assets-report>,
        :transfer<secondaries gather-js-jq gather-css images search-bar>,
        :compilation<secondaries listfiles search-bar>,
        :completion<cro-app>,
    ),
)