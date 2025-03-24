%(
    :sources<sources>,      #| directory root of rakudoc source files
    :file-data-name<file-data.rakuon>,
                            #| name of file that contains all the ToC, index, and other state data
                            #| for each source file that has been rendered. Intended to avoid
                            #| re-rendering every source when only some have been modified
    :canonical<en>,         #| sub-dir of sources with canonical content
    :misc<misc>,            #| directory with translation & other information
    :ui-dictionary<ui-dictionary.rakuon>, #| name of dictionary with ui token and translations
    :extensions<rakudoc rakumod>, #| possible extension of rakudoc source
    :!quiet,                #| no output is required if True
    :with-only<
        Language/operators Language/REPL Language/variables Language/math Language/101-basics Type/AST
        Type/Anytype/IO/Handle Type/IO/CatHandle Type/IO/Special Type/IO/ArgFiles Type/IO/Socket
        Type/IO/Notification Type/IO/Pipe Type/IO/Spec Type/IO/Pathtype/RakuAST/Doc
        RakuDoc_v2
        about 403 404 license
    >,           #| only render files in this list
    :ignore(),              #| ignore files in this list
    :publication<publication>, #| directory where rendered HTML files are placed
    :landing-page<index>,   #| name of file where the web-site starts
    :landing-title(         #| title for the auto-generated landing page
                    'Website contents'),
    :landing-subtitle(      #| subtitle = description of auto-generated landing page
                    'Under development with only one language so far' ),
    :glues( {               #| files that should be rendered after all the others
                            #| the files are in the form :filename( n ), where n >= 1
                            #| n is rendered before n+1
                            #| and in landing page in reverse order
        :introduction(4),
        :miscellaneous(3),
        :reference(2),
        :programs(1),
        :types(1),
        :all-routines(1),
        :all-syntax(1),
        :all-operators(2),
        :index(5),
        }
    ),
    :deprecated( %(         #| mapping of deprecated urls to
                            #| newer equivalents
        "/language" => "/introduction",
        "/programs" => "/miscellaneous",
        "/language/independent-routines" => "/type/independent-routines",
         )
    ),
)
