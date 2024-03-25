%(
    :plugins<plugins>,
    :plugin-format<html>,
    plugins-required => %(
        :setup<raku-doc-setup>,
        :render<
            hiliter
            ebook-embed
            font-awesome tablemanager rakudoc-table
            camelia simple-extras listfiles images deprecate-span filterlines
            typegraph generated
            gather-js-jq gather-css
        >,
        :report<link-plugin-assets-report>,
        :transfer<gather-js-jq gather-css images raku-doc-setup ebook-embed>,
        :compilation<listfiles ebook-embed>,
        :completion<ebook-embed>,
    ),
)