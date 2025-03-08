%(
    :sources<sources>,      #| directory root of rakudoc source files
    :file-data-name<file-data.rakuon>,
                            #| name of file that contains all the ToC, index, and other state data
                            #| for each source file that has been rendered. Intended to avoid
                            #| re-rendering every source when only some have been modified
    :canonical<en>,         #| sub-dir of sources with canonical content
    :L10N<L10N>,            #| directory with translation information
    :ui-dictionary<ui-dictionary.rakuon>, #| name of dictionary with ui token and translations
    :extensions<rakudoc rakumod>, #| possible extension of rakudoc source
    :!quiet,                #| no output is required if True
    :with-only(),           #| only render files in this list
    :ignore(),              #| ignore files in this list
    :destination<publication>, #| directory where rendered HTML files are placed
    :landing-page<index>,   #| name of file where the web-site starts
    :landing-title(         #| title for the auto-generated landing page
                    'Website contents'),
    :landing-subtitle(      #| subtitle = description of auto-generated landing page
                    'Choose the language to start' ),
    :glues( {               #| files that should be rendered after all the others
                            #| the files are in the form :filename( n ), where n >= 1
                            #| n is rendered before n+1
        } ),
    :deprecated( %(         #| mapping of deprecated urls to
                            #| newer equivalents
                            #| it will be server centric
         )
    ),
)