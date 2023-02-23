%(
    :plugins<plugins>,
    :plugin-format<html>,
    plugins-required => %(
        :setup<raku-doc-setup git-reflog>,
        :render<
            font-awesome ogdenwebb camelia simple-extras listfiles images deprecate-span filterlines
            tablemanager secondaries typegraph
            search-bar link-error-test git-reflog
            gather-js-jq gather-css
        >,
        :report<link-plugin-assets-report>,
        :transfer<secondaries gather-js-jq gather-css images search-bar git-reflog>,
        :compilation<secondaries listfiles search-bar link-error-test>,
        :completion<cro-app>,
    ),
)