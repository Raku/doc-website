%(
    :mode-sources<structure-sources>, # content for the website structure
    :mode-cache<structure-cache>, # cache for the above
    :mode-ignore<
        footnotes.rakudoc glossary.rakudoc toc.rakudoc language.rakudoc programs.rakudoc announcements.rakudoc
    >, # files to ignore
    :mode-obtain(), # not a remote repository
    :mode-refresh(), # ditto
    :mode-extensions<rakudoc pod6>, # only use these for content
    :no-code-escape,# must use this when using highlighter
    :destination<../ebook_unzipped>, # where the html files will be sent relative to Mode directory
    :asset-out-path<assets>, # where the image assets will be sent relative to destination
    :landing-place<index>, # the first file
    :report-path<reports>,
    :output-ext<xhtml>,
    :templates<templates>,
    :!no-status, # show progress
    :!collection-info, # do not show milestone data
    :!without-report, # make a report - default is False, but set True
    :!without-completion, # we want the Cro app to start
    :!full-render, # force rendering of all output files
    :no-preserve-state, # we do not want to archive intermediate data
)