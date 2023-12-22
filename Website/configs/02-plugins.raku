%(
    :plugins<plugins>,
    :plugin-format<html>,
    plugins-required => %(
        :setup<raku-doc-setup>,
        :render<
            hiliter font-awesome page-styling
            filtered-toc
            camelia simple-extras listfiles images deprecate-span filterlines
            tablemanager secondaries typegraph generated
            options-search link-error-test
            gather-js-jq gather-css sitemap
        >,
        :report<link-plugin-assets-report sitemap>,
        :transfer<secondaries gather-js-jq gather-css images raku-doc-setup options-search>,
        :compilation<secondaries listfiles link-error-test options-search>,
        :completion<cro-app>,
    ),
)