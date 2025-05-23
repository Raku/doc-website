%(
    :plugins<plugins>,
    :plugin-format<html>,
    plugins-required => %(
        :setup<raku-doc-setup>,
        :render<
            rainbow
            font-awesome page-styling
            filtered-toc
            camelia simple-extras listfiles images filterlines
            tablemanager secondaries typegraph generated
            options-search link-error-test sqlite-db
            gather-js-jq gather-css sitemap
        >,
        :report<link-plugin-assets-report sitemap>,
        :transfer<secondaries gather-js-jq gather-css images raku-doc-setup options-search sqlite-db>,
        :compilation<secondaries listfiles link-error-test options-search sqlite-db>,
        :completion<cro-app>,
    ),
)
