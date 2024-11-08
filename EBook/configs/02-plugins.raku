%(
    :plugins<plugins>,
    :plugin-format<xhtml>,
    plugins-required => %(
        :setup<raku-doc-setup>,
        :render<
            rainbow
            ebook-embed rakudoc-table
            generated
            gather-css
        >,
        :report(),
        :transfer<gather-css raku-doc-setup ebook-embed ebook-embed>,
        :completion<ebook-embed>,
    ),
)