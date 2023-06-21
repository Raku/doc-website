%(
    :plugins<plugins>,
    :plugin-format<html>,
    plugins-required => %(
        :setup<raku-doc-setup>,
        :render<
            hiliter font-awesome ogdenwebb camelia simple-extras listfiles images deprecate-span filterlines
            tablemanager secondaries typegraph generated
            search-bar link-error-test
            gather-js-jq gather-css
        >,
        :report<link-plugin-assets-report>,
        :transfer<secondaries gather-js-jq gather-css images search-bar >,
        :compilation<secondaries listfiles search-bar link-error-test>,
        :completion<cro-app>,
    ),
)