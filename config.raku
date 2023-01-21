use v6.d;
%(
    :cache<doc_cache>, # location relative to collection root of cached Pod
    :sources<local_raku_docs/doc>, # location of sources
    #| the array of strings sent to the OS by run to obtain sources, eg git clone
    #| assumes CWD set to the directory of collection
    #:source-obtain(),
    :source-obtain<git clone https://github.com/Raku/doc.git local_raku_docs/>,
    #| the array of strings run to refresh the sources, eg. git pull
    #| assumes CWD set to the directory of sources
    #:source-refresh(),
    :source-refresh<git -C local_raku_docs/ pull>,
    # processing options independent of Mode
    # by default, unless set in config file, options are False
    :!without-processing, # process all files if possible
    :!no-refresh, # call the refresh step after initiation
    :!recompile, # if true, force a recompilation of the source files when refresh is called
    :mode<OgdenWebb>, # the default mode, which must exist
    :ignore< 404.pod6 HomePage.pod6 >,
    :extensions< rakudoc pod pod6 raku p6 pm pm6 rakumod >,
    :asset-basename<asset_base>, # using _ so that it is not a valid Mode name
    :asset-paths( %( # type of asset is key, then metadata for that type
        image => %(
            :directory<images>,
            :extensions<png jpeg jpeg svg mp4 webm gif>,
        ),
    )),
    :with-only(''),
)