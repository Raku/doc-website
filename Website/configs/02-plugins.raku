%(
    :plugins<plugins>,
    :plugin-format<html>,
    plugins-required => %(
        :setup<raku-doc-setup>,
        :render<
            ogdenwebb camelia simple-extras listfiles images deprecate-span filterlines
            secondaries typegraph
            link-error-test
            gather-js-jq gather-css
        >,
        :report<link-plugin-assets-report>,
        :transfer<secondaries gather-js-jq gather-css images ogdenwebb>,
        :compilation<secondaries listfiles link-error-test ogdenwebb>,
        :completion<cro-app>,
    ),
)