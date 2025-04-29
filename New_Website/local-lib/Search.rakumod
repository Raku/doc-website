use v6.d;
use RakuDoc::Render;
use JSON::Fast;
use Elucid8-Build;

unit class Raku-Doc-Website::Search;
has %.config =
    :name-space<Search>,
	:version<0.1.0>,
	:license<Artistic-2.0>,
	:credit<finanalyst, "https://tarekraafat.github.io/autoComplete.js , Apache 2.0">,
	:authors<finanalyst>,
    :js-link(
		['src="https://cdn.jsdelivr.net/npm/@tarekraafat/autocomplete.js@10.2.7/dist/autoComplete.min.js"', 1],
	),
	:js( [self.options-search,2], ),
	:css-link(
	    ['href="https://cdn.jsdelivr.net/npm/@tarekraafat/autocomplete.js@10.2.7/dist/css/autoComplete.min.css"',1],
	),
    :scss([self.search-scss,1],),
	:prepare-search-data( -> $rdp, $lang, $to, %config { self.prepare-search-data( $rdp, $lang, $to, %config ) } ),
    ui-tokens => %(
        :SearchText('Click to open search box'),
        :SearchCancel('Click to close search box'),
        :Search<Search>,
        :options-search-extra('Extra info'),
        :options-search-extra-tip('The search response can be shortened by excluding the extra information line'),
        :options-search-extra-on<yes>,
        :options-search-extra-off<no>,
        :options-search-loose('Search type'),
        :options-search-loose-tip('The search engine can perform a strict search (only the characters in the search box) or a loose search'),
        :options-search-loose-on<strict>,
        :options-search-loose-off<loose>,
        :options-search-headings<Headings>,
        :options-search-headings-tip('Search through headings in all web-pages'),
        :options-search-headings-on<yes>,
        :options-search-headings-off<no>,
        :options-search-indexed<Indexed>,
        :options-search-indexed-tip('Search through all indexed items'),
        :options-search-indexed-on<yes>,
        :options-search-indexed-off<no>,
        :options-search-composite<Composite>,
        :options-search-composite-tip('Search in the names of composite pages, which combine similar information from the main web pages'),
        :options-search-composite-on<yes>,
        :options-search-composite-off<no>,
        :options-search-primary<Primary>,
        :options-search-primary-tip('Search through the names of the main web pages'),
        :options-search-primary-on<yes>,
        :options-search-primary-off<no>,
        :options-search-fallback('If all else fails, an item is added to use the Google search engine on the whole site'),
        :options-search-escape-text('Exit this page by pressing &lt;Escape&gt;, or clicking on X or on the background.'),
        :options-search-last-candidate('The last search was:&nbsp;'),
    ),
;

method enable( RakuDoc::Processor:D $rdp ) {
    $rdp.add-templates( $.search-templates, :source<Search plugin> );
    $rdp.add-data( %!config<name-space>, %!config );
}

sub escape(Str $s) is export {
    $s.trans([</ \\ ">] => [<\\/ \\\\ \\">]);
}
sub escape-json(Str $s) is export {
    $s.subst(｢\｣, ｢%5C｣, :g)
            .subst('"', '\"', :g)
            .subst(｢?｣, ｢%3F｣, :g)
            .subst(｢.｣, '%2E', :g)
}
method prepare-search-data( $rdp, $lang, $to, %config ) {
    say 'Preparing Search data';
    # This routine creates the JS data structure to be added to the JS query function
    # The data structure is an array of hashes each having keys
    # :category, :value, :url, :info, :type
    # Category is used to split the candidate list,
    # value is what is searched for,
    # info is extra information, which can be searched for
    # url is where it is to be found.
    # type is used by search to filter candidates
    # e.g. { "category": "Types", "value": "Distribution::Hash", "url": "/type/Distribution::Hash", "info": "class Distribution::Hash" ,"type":"heading" }
    my %fd := $rdp.file-data{ $lang };
    my @entries;
    # collect info stored from parsing headers
    # structure of file-data
    # <filename> => %(
    # :config => :kind, :sub-kind, :category | file's config data if primary
    # :modified | when source was modified
    # :primary | True if source exists. False if generated (composite)
    # :title
    # :subtitle
    # :defns | things that make up composite
    # :index | index structure of file
    # :toc | toc structure of file
    # Helper functions as in Documentable
    # search items pointing to Composites
    for %fd.kv -> $fn, %fdata {
        next if %fdata<type> eq <glue info>.any; # ignore contents of glue files.
        my $route = %fdata<route>;
        my $value = %fdata<title>;
        my $info = %fdata<subtitle> // '';
        if %fdata<type> eq 'primary' {
            @entries.push: %(
                :category( (%fdata<config><subkind> // 'Language').tc ), # a default subkind in case one is missing.
                :$value,
                :$info,
                :url(escape-json($route)),
                :type<primary>, # type is used to filter search candidates
            );
            # exclude headings from all composite files because they are duplicates
            for %fdata<toc>.grep({ !(.<is-title>) }) {
                @entries.push: %(
                    :category<Heading>,
                    :value(.<caption>),
                    :info('Section in <b>' ~ $value ~ '</b>'),
                    :url(escape-json("$route\.html#" ~ .<target>)),
                    :type<headings>,
                )
            }
            for %fdata<index>.kv -> $label, %info {
                for %info<refs>.list {
                    @entries.push: %(
                        :category<Indexed>,
                        :value( "$label [{ .<place> }]"),
                        :info("in <b>{$value}\</b>"),
                        :url(escape-json("$route\.html#" ~ .<target>)),
                        :type<indexed>,
                    )
                }
                # handle sub refs
            }
        }
        else {
            @entries.push: %(
                :category<Composite>,
                :$value,
                :$info,
                :url(escape-json($route)),
                :type<composite>,
            )
        }
    }
    # try to filter out duplicates by looking for only unique urls
    @entries .= unique(:as(*.<url>));
    # now sort so js only does filtering.
    my $search-order = -> $pre, $pos {
        if $pre.<category> ne 'Language' and $pos.<category> eq 'Language' { Order::More }
        elsif $pos.<category> ne 'Language' and $pre.<category> eq 'Language' { Order::Less }
        elsif $pre.<url>.contains('5to6') and $pos.<category> eq 'Language' and ! $pos.<url>.contains('5to6') { Order::More }
        elsif $pos.<url>.contains('5to6') and $pre.<category> eq 'Language' and ! $pre.<url>.contains('5to6') { Order::Less }
        elsif $pre.<category> ne 'Indexed' and $pos.<category> eq 'Indexed' { Order::Less }
        elsif $pos.<category> ne 'Indexed' and $pre.<category> eq 'Indexed' { Order::More }
        elsif $pre.<category> ne 'Heading' and $pos.<category> eq 'Heading' { Order::Less }
        elsif $pos.<category> ne 'Heading' and $pre.<category> eq 'Heading' { Order::More }
        elsif $pre.<category> ne 'Composite' and $pos.<category> eq 'Composite' { Order::Less }
        elsif $pos.<category> ne 'Composite' and $pre.<category> eq 'Composite' { Order::More }
        elsif $pre.<category> ne $pos.<category> { $pre.<category> leg $pos.<category> }
        else { $pre.<value> leg $pos.<value> }
    }
    ("$to/" ~ NAV_DIR ~ "/searchData.json").IO.spurt: JSON::Fast::to-json( @entries.sort( $search-order ) );
}

method search-templates {
    %(
        'head-search' => -> %prm, $tmpl {
            qq:to/BLOCK/
                <div class="navbar-end Elucid8-search">
                    <label class="Elucid8-search-mark tooltip">
                        <input type="checkbox"/>
                        <span class="banned"><i class="fa fa-ban fa-3x"></i></span>
                        <i class="fa fa-search"></i>
                        <span class="Elucid8-ui" data-UIToken="Search">Search</span>
                        <span class="tooltiptext Elucid8-ui" data-UIToken="SearchText">SearchText</span>
                        <span class="tooltiptext Elucid8-ui cancel" data-UIToken="SearchCancel">SearchCancel</span>
                    </label>
                </div>
                BLOCK
        },
        'search-modal' => -> %prm, $tmpl {
            q:to/BLOCK/;
                <div id="Elucid8_search_wrapper" class="is-hidden">
                    <input id="Elucid8_search_input" type="search" dir="ltr" spellcheck=false autocorrect="off" autocomplete="off" autocapitalize="off" maxlength="2048" tabindex="1">
                    <a class="button is-primary js-modal-trigger" data-target="options-search-info">
                        <span class="icon">
                            <i class="fas fa-cogs"></i>
                        </span>
                    </a>
                </div>
                <div id="options-search-info" class="modal">
                    <div class="modal-background"></div>
                    <div class="modal-content">
                        <div class="box">
                            <p><span class="Elucid8-ui" data-UIToken="options-search-last-candidate">options-search-last-candidate</span>
                            <span id="selected-candidate" class="ss-selected"><i class="fa fa-inbox"></i></span></p>
                            <div class="content is-grouped is-grouped-centered options-search-controls">
                                <label class="tooltip optionToggle">
                                    <span class="Elucid8-ui text" data-UIToken="options-search-extra">options-search-extra</span>
                                    <span class="tooltiptext Elucid8-ui" data-UIToken="options-search-extra-tip">options-search-extra-tip</span>
                                    <input id="options-search-extra" type="checkbox">
                                    <span class="Elucid8-ui off" data-UIToken="options-search-extra-off">options-search-extra-off</span>
                                    <span class="Elucid8-ui on" data-UIToken="options-search-extra-on">options-search-extra-on</span>
                                </label>
                                <label class="tooltip optionToggle">
                                    <span class="Elucid8-ui text" data-UIToken="options-search-loose">options-search-loose</span>
                                    <span class="tooltiptext Elucid8-ui" data-UIToken="options-search-loose-tip">options-search-loose-tip</span>
                                    <input id="options-search-loose" type="checkbox">
                                    <span class="Elucid8-ui off" data-UIToken="options-search-loose-off">options-search-loose-off</span>
                                    <span class="Elucid8-ui on" data-UIToken="options-search-loose-on">options-search-loose-on</span>
                                </label>
                                <label class="tooltip optionToggle">
                                    <span class="Elucid8-ui text" data-UIToken="options-search-headings">options-search-headings</span>
                                    <span class="tooltiptext Elucid8-ui" data-UIToken="options-search-headings-tip">options-search-headings-tip</span>
                                    <input id="options-search-headings" type="checkbox">
                                    <span class="Elucid8-ui off" data-UIToken="options-search-headings-off">options-search-headings-off</span>
                                    <span class="Elucid8-ui on" data-UIToken="options-search-headings-on">options-search-headings-on</span>
                                </label>
                                <label class="tooltip optionToggle">
                                    <span class="Elucid8-ui text" data-UIToken="options-search-indexed">options-search-indexed</span>
                                    <span class="tooltiptext Elucid8-ui" data-UIToken="options-search-indexed-tip">options-search-indexed-tip</span>
                                    <input id="options-search-indexed" type="checkbox">
                                    <span class="Elucid8-ui off" data-UIToken="options-search-indexed-off">options-search-indexed-off</span>
                                    <span class="Elucid8-ui on" data-UIToken="options-search-indexed-on">options-search-indexed-on</span>
                                </label>
                                <label class="tooltip optionToggle">
                                    <span class="Elucid8-ui text" data-UIToken="options-search-composite">options-search-composite</span>
                                    <span class="tooltiptext Elucid8-ui" data-UIToken="options-search-composite-tip">options-search-composite-tip</span>
                                    <input id="options-search-composite" type="checkbox">
                                    <span class="Elucid8-ui off" data-UIToken="options-search-composite-off">options-search-composite-off</span>
                                    <span class="Elucid8-ui on" data-UIToken="options-search-composite-on">options-search-composite-on</span>
                                </label>
                                <label class="tooltip optionToggle">
                                    <span class="Elucid8-ui text" data-UIToken="options-search-primary">options-search-primary</span>
                                    <span class="tooltiptext Elucid8-ui" data-UIToken="options-search-primary-tip">options-search-primary-tip</span>
                                    <input id="options-search-primary" type="checkbox">
                                    <span class="Elucid8-ui off" data-UIToken="options-search-primary-off">options-search-primary-off</span>
                                    <span class="Elucid8-ui on" data-UIToken="options-search-primary-on">options-search-primary-on</span>
                                </label>
                            </div>
                            <p><span class="Elucid8-ui" data-UIToken="options-search-fallback">options-search-fallback</span></p>
                            <p><span class="Elucid8-ui" data-UIToken="options-search-escape-text">options-search-escape-text</span></p>
                        </div>
                    </div>
                    <button class="modal-close is-large" aria-label="close"></button>
                </div>
            BLOCK
       },
    );
}

method options-search {
    q:to/JS/
    /* from Elucid8 Search plugin */
    /* ========================== */
    var webSite = window.location.hostname;
    var searchOptions;
    var persisted_searchOptions = function () {
        return JSON.parse( localStorage.getItem('searchOptions') );
    };
    var persist_searchOptions = function (searchOptions) {
        localStorage.setItem('searchOptions', JSON.stringify( searchOptions ))
    };
    var autoCompleteJS;
    var defaultOptions = {
        "loose": false,
        "headings": true,
        "indexed": true,
        "primary": true,
        "composite": true,
        "extra": true
    };
    var searchProcess = false;
    var searchBox;
    window.addEventListener('load', function () {
        searchBox = document.getElementById('Elucid8_search_wrapper');
        searchOptions = persisted_searchOptions();
        // searchOptions will always be null until an option is changed from default and stored
        if ( searchOptions == null ) {
            searchOptions  = defaultOptions;
        }
        var selectedCandidate = document.getElementById('selected-candidate');
        var category = 'Composite';
        document.querySelectorAll('.Elucid8-search').forEach( ( el ) => {
            el.addEventListener('click', (searchEvent) => {
                if ( autoCompleteJS == null ) {
                    autoCompleteJS = new autoComplete({
                        selector: '#Elucid8_search_input',
                        data: {
                            src: async () => {
                                try {
                                    // Fetch External Data Source
                                    const source = await fetch(
                                      "/assets/searchData.json"
                                    );
                                    data = await source.json();
                                    return data;
                                } catch (error) {
                                    return error;
                                }
                            },
                            keys: ['value'],
                            cache: true,
                            filter: (list) => {
                                let newArray = new Array;
                                list.forEach( candidate => {
                                    if ( candidate.value.type == 'primary' && searchOptions.primary ) { newArray.push( candidate ) };
                                    if ( candidate.value.type == 'composite' && searchOptions.composite ) { newArray.push( candidate ) };
                                    if ( candidate.value.type == 'headings' && searchOptions.headings ) { newArray.push( candidate ) };
                                    if ( candidate.value.type == 'indexed' && searchOptions.indexed ) { newArray.push( candidate ) };
                                });
                                return newArray
                            }
                        },
                        resultsList: {
                            element: (list, data) => {
                                category = '';
                                const info = document.createElement("div");
                                info.id = 'Elucid8_search_res_head';
                                let resp = '';
                                if (data.results.length > 1) {
                                    resp = `<strong>${data.matches.length}</strong> matches found`;
                                }
                                else if (data.results.length == 1) {
                                    resp = '<strong>One</strong> match found';
                                }
                                else {
                                    resp = `<strong>No</strong> matches found for <strong>${data.query}</strong>`;
                                }
                                resp = resp + `.   <strong>${ searchOptions.loose ? "Loose" : "Strict" }</strong> search.`;
                                info.innerHTML = resp;
                                list.prepend(info);
                                const lastItem = document.createElement("li");
                                lastItem.innerHTML = `Use Google search on this site for <strong>"${data.query}"</strong>`;
                                list.append(lastItem);
                            },
                            noResults: true,
                            threshold: 0,
                            maxResults: 500
                        },
                        resultItem: {
                            class: "autoComplete_result",
                            element: (item, data) => {
                                let catSpan = '';
                                let extraSpan = '';
                                if ( searchOptions.extra ) { extraSpan = `<span class="autoComplete-result-extra">${data.value.info}</span>` };
                                if ( data.value.category !== category ) {
                                    category = data.value.category;
                                    catSpan = `<span class="autoComplete-result-category">${category}</span>`;
                                }
                              // Modify Results Item Content
                              item.innerHTML = `
                              ${catSpan}
                              <a href="${data.value.url}">
                              <span class="autoComplete-result-data">
                                ${data.match}
                              </span></a>
                              <a href="${data.value.url}">
                              ${extraSpan}</a>`;
                            },
                            highlight: true,
                        },
                        events: {
                            input: {
                                keydown: (event) => {
                                    //document.querySelector('.autoComplete_wrapper ul').scrollTop = 0;
                                    switch (event.keyCode) {
                                        // Escape
                                        case 27:
                                            autoCompleteJS.close();
                                            unfocusSearchBar();
                                            break;
                                        // Down/Up arrow
                                        case 40:
                                        case 38:
                                            event.preventDefault();
                                            event.keyCode === 40 ? autoCompleteJS.next() : autoCompleteJS.previous();
                                            break;
                                        // Enter
                                        case 13:
                                            event.preventDefault();
                                            openInTab =  event.ctrlKey;
                                            if (autoCompleteJS.cursor < 0) {
                                                autoCompleteJS.next();
                                            }
                                            autoCompleteJS.select(autoCompleteJS.cursor)
                                            break;
                                    }
                                },
                                selection: (event) => {
                                    const selection = event.detail.selection.value;
                                    var dest;
                                    if ( selection ) {
                                        selectedCandidate.innerHTML = selection.url;
                                        dest = selection.url;
                                    }
                                    else {
                                        dest = 'https://www.google.com/search?q=site%3A'
                                        + webSite
                                        + '+'
                                        + encodeURIComponent( event.detail.query );
                                    }
                                    if ( searchOptions.newtab || openInTab ) {
                                        window.open( dest, '_blank');
                                    }
                                    else {
                                        window.location.href = dest;
                                    }
                                },
                                focus: () => {
                                    if (autoCompleteJS.input.value.length) autoCompleteJS.start();
                                    document.querySelector('.autoComplete_wrapper ul').scrollTop = 0;
                                }
                            }
                        }
                    });
                }
                if ( searchEvent.target.localName == 'input')  {
                    if ( searchProcess ) {
                        searchBox.classList.add('is-hidden');
                        searchProcess = false;
                    }
                    else {
                        searchBox.classList.remove('is-hidden');
                        searchProcess = true;
                        document.getElementById('Elucid8_search_input').focus();
                    }
                    el.querySelector('input').checked = searchProcess;
                }
                // add change listener
                for ( const prop in searchOptions ) {
                    let opt = document.getElementById('options-search-' + prop );
                    opt.checked = searchOptions[ prop ];
                    opt.addEventListener('change', function() {
                        searchOptions[ prop ] = opt.checked;
                        persist_searchOptions( searchOptions );
                        autoCompleteJS.start();
                    });
                };
            });
        });

        // Functions to open and close a modal
        function openModal($el) {
            $el.classList.add('is-active');
        }

        function closeModal($el) {
            $el.classList.remove('is-active');
        }

        function closeAllModals() {
            (document.querySelectorAll('.modal') || []).forEach(($modal) => {
              closeModal($modal);
            });
        }

        // Add a click event on buttons to open a specific modal
        (document.querySelectorAll('.js-modal-trigger') || []).forEach(($trigger) => {
            const modal = $trigger.dataset.target;
            const $target = document.getElementById(modal);

            $trigger.addEventListener('click', () => {
              openModal($target);
            });
        });

        // Add a click event on various child elements to close the parent modal
        (document.querySelectorAll('.modal-background, .modal-close, .modal-card-head .delete, .modal-card-foot .button') || []).forEach(($close) => {
            const $target = $close.closest('.modal');

            $close.addEventListener('click', () => {
              closeModal($target);
            });
        });
        // keyboard shortcuts, check that keyboard shortcuts are not disabled
        window.addEventListener('keydown', function (e) {
            // Add a keyboard event to close all modals
            if (e.code === 'Escape') {
              closeAllModals();
            }
        });
    });
    JS
}
method search-scss {
    q:to/SCSS/
    $border: hsl(221, 14%, 86%);
    $text: var(--bulma-text);
    .navbar-item input {
      width: 200px;
      padding: 0 0 0 0.5rem;
    }

    .navbar-search-wrapper {
        position: absolute;
        top: 10%;
        right: 3px;
    }

    .navbar-item .button, .navbar-item input {
      height: 1.85em;
    }

    .autoComplete_wrapper {
        > input {
            background-color: var(--bulma-background);
            border-color: $border;
            color: $text;
            width: 100%;
            height: 1.85em;
            border-radius: 4px 0 0 4px;
            background-image: unset;
            padding: 0 0 0 0.5rem;
            &:focus {
                color: $text;
                border-color: $border;
            }
            &+ ul {
                z-index: 2;
                background-color: var(--bulma-background);
                color: var(--bulma-info-40);
                left: -25vw;
                padding: 0 0 0 0.5rem;
                max-height: 60vh;
                > li {
                    background-color: var(--bulma-background);
                    color: var(--bulma-info-40);
                    white-space: revert;
                }
            }
        }
    }
    .autoComplete_result {
        display: grid;
        .autoComplete-result-category {
            color: var(--bulma-danger);
            font-weight: var(--bulma-weight-semibold);
            justify-self: center;
        }
        a span.autoComplete-result-extra {
            overflow-x: hidden;
            text-overflow: ellipsis;
            margin: 5px;
            font-style: oblique;
            color: var(--bulma-info);
        }
    }
    #Elucid8_search_wrapper {
        position: relative;
        margin-left: auto;
        margin-right: 1%;
        width: fit-content;
    }
    #Elucid8_search_input {
        height: var(--bulma-control-height);
        border-radius: 5px;
        padding: 0 2rem 0 2.5rem;
        background-position: left 0.6rem top 0.6rem;
    }
    #Elucid8_search_res_head {
        padding: 0.3rem 0.5rem;
    }
    label.Elucid8-search-mark input[type="checkbox"] {
        opacity: 0;
        height: 0;
        width: 0;
    }
    label.Elucid8-search-mark:hover input[type="checkbox"]:checked ~ span.tooltiptext {
        opacity: 0;
        width: 0;
        visibility: hidden;
        display: inline-block;
    }
    label.Elucid8-search-mark:hover input[type="checkbox"] ~ span.tooltiptext {
        opacity: 1;
        visibility: visible;
        width: 200%;
        display: inline-block;
        top: -10%;
        right: 100%;
    }
    @media screen and (max-width: 1023px) {
        label.Elucid8-search-mark:hover input[type="checkbox"] ~ span.tooltiptext {
            top: 120%;
            right: -100%;
        }
    }

    label.Elucid8-search-mark:hover input[type="checkbox"] ~ span.tooltiptext.cancel {
        opacity: 0;
        width: 0;
        visibility: hidden;
        display: inline-block;
    }
    label.Elucid8-search-mark:hover input[type="checkbox"]:checked ~ span.tooltiptext.cancel {
        opacity: 1;
        visibility: visible;
        width: 200%;
        display: inline-block;
    }
    label.Elucid8-search-mark input[type="checkbox"] + span.banned {
        opacity: 0;
        width: 0;
        display: inline-block;
    }
    label.Elucid8-search-mark input[type="checkbox"]:checked + span.banned {
        color: var(--bulma-danger);
        opacity: 1;
        transform: translateX(-14px);
        transition: opacity 1s;
    }
    label.optionToggle {
        span.text {
            font-weight: var(--bulma-weight-bold);
            width: 10rem;
        }
        span.tooltiptext {
            width: 100%;
            right: -40%;
        }
        input[type="checkbox"] {
            opacity: 0;
            height: 0;
            width: 0;
            & ~ span.off {
                border: 2px solid var(--bulma-danger);
                font-weight: var(--bulma-weight-normal);
                border-radius: 5px;
                padding: 0 5px 0 5px;
            }
            & ~ span.on {
                border: 2px solid var(--bulma-background);
                font-weight: var(--bulma-weight-normal);
                border-radius: 5px;
                padding: 0 5px 0 5px;
            }
            &:checked ~ span.off {
                border: 2px solid var(--bulma-background);
                font-weight: var(--bulma-weight-normal);
                border-radius: 5px;
                padding: 0 5px 0 5px;
            }
            &:checked ~ span.on {
                border: 2px solid var(--bulma-primary-30);
                font-weight: var(--bulma-weight-normal);
                border-radius: 5px;
                padding: 0 5px 0 5px;
            }
        }
    }

    SCSS
}
