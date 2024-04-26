%(
    :mode-sources<structure-sources>, # content for the website structure
    :mode-cache<structure-cache>, # cache for the above
    :mode-ignore<search.rakudoc error-report.rakudoc language.rakudoc programs.rakudoc>, # files to ignore
    :mode-obtain(), # not a remote repository
    :mode-refresh(), # ditto
    #| the array of strings sent to the OS by run to obtain the repo's commit-id
    :mode-source-versioning<git -C Website rev-parse --short HEAD>,
    #| the array of strings sent to the OS by run to obtain version data per file
    #| the string is appended by the path of the file before the run is executed
    :mode-source-per-file-versioning('git','-C','Website/structure-sources', 'log', '-1', '--format="%h %cs"', '--'),
    :mode-extensions<rakudoc pod6>, # only use these for content
    :no-code-escape,# must use this when using highlighter
    :destination<../rendered_html>, # where the html files will be sent relative to Mode directory
    :asset-out-path<assets>, # where the image assets will be sent relative to destination
    :landing-place<index>, # the first file
    :report-path<reports>,
    :output-ext<html>,
    :templates<templates>,
    :!no-status, # show progress
    :!collection-info, # do not show milestone data
    :!without-report, # make a report - default is False, but set True
    :!without-completion, # we want the Cro app to start
    :!full-render, # force rendering of all output files
    :no-preserve-state, # we do not want to archive intermediate data
)