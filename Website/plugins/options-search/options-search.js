var webSite = window.location.hostname;
var searchOptions;
var optionAtts = {
    "loose": { "letter": 'l' },
    "headings": { "letter": 'h' },
    "indexed": { "letter": 'i' },
    "primary": { "letter": 'p' },
    "composite": { "letter": 'c' },
    "newtab": { "letter": 'q' },
    "extra": { "letter": 'e' }
};
var persisted_searchOptions = function () {
    return JSON.parse( localStorage.getItem('searchOptions') );
};
var persist_searchOptions = function (searchOptions) {
    localStorage.setItem('searchOptions', JSON.stringify( searchOptions ))
};
var focusOnSearchBar = function() {
    // make sure when search key is hit, the div with the search bar is made visible
    document.getElementById('navMenu').classList.add('is-active');
    document.querySelector('.navbar-burger.burger').classList.add('is-active');
    document.getElementById('autoComplete').focus();
};

var unfocusSearchBar = function() {
    document.getElementById('navMenu').classList.remove('is-active');
    document.querySelector('.navbar-burger.burger').classList.remove('is-active');
    document.getElementById('autoComplete').blur();
};

var category = '';
var autoCompleteJS;
var openInTab = false;

document.addEventListener('DOMContentLoaded', function () {
    searchOptions = persisted_searchOptions();
    var searchDataObtained = false;
    if ( searchOptions == null ) {
        searchOptions  = {
            "loose": false,
            "headings": true,
            "indexed": false,
            "primary": true,
            "composite": true,
            "newtab": false,
            "extra": true
        };
        persist_searchOptions( searchOptions );
    }
    var selectedCandidate = document.getElementById('selected-candidate');
    selectedCandidate.innerHTML = 'No page selected';
    document.getElementById('autoComplete').addEventListener('focus', function () {
        if ( searchDataObtained ) { return };
        searchDataObtained = true;
        autoCompleteJS = new autoComplete({
            selector: "#autoComplete",
            placeHolder: "🔍 Search for ...",
            data: {
                src: async () => {
                    try {
                        // Loading placeholder text
                        document
                          .getElementById("autoComplete")
                          .setAttribute("placeholder", "Loading search data ...");
                        // Fetch External Data Source
                        const source = await fetch(
                          "/assets/searchData.json"
                        );
                        const data = await source.json();
                        // Post Loading placeholder text
                        document
                          .getElementById("autoComplete")
                          .setAttribute("placeholder", autoCompleteJS.placeHolder);
                        // Returns Fetched data
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
                    const info = document.createElement("p");
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
                    resp = resp + `.   <strong>${ searchOptions.loose ? "Loose" : "Strict" }</strong> search.`
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
        setTimeout(function() {
          document.getElementById('autoComplete').focus();
        }, 0);
    });
    // add change listener
    for ( const prop in searchOptions ) {
        let opt = document.getElementById('options-search-' + prop );
        opt.checked = searchOptions[ prop ];
        optionAtts[ prop ].elem = opt;
        if ( prop === 'loose') {
            // handle loose option separately
            opt.addEventListener('change', function() {
                searchOptions[ prop ] = opt.checked;
                persist_searchOptions( searchOptions );
                autoCompleteJS.searchEngine = opt.checked ? "strict" : "loose";
                autoCompleteJS.start();
            });
        }
        else {
            opt.addEventListener('change', function() {
                searchOptions[ prop ] = opt.checked;
                persist_searchOptions( searchOptions );
                autoCompleteJS.start();
            });
        }
    };
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
        if ( pageOptionsState && pageOptionsState.settings.shortcuts !== 'disabled') {
            Object.keys( optionAtts ).forEach( attr => {
                if (e.altKey && e.key === optionAtts[ attr ].letter ) {
                    // generic options
                    e.preventDefault();
                    let opp = optionAtts[ attr ].elem;
                    let togg = ! opp.checked;
                    opp.checked = togg;
                    searchOptions[ attr ] = togg;
                    persist_searchOptions( searchOptions );
                    // handle loose option separately
                    if ( attr === 'loose' ) {
                        autoCompleteJS.searchEngine = togg ? "loose" : "strict";
                    }
                    autoCompleteJS.start();
                }
            });
            // Add a keyboard event to close all modals
            if (e.code === 'Escape') {
              closeAllModals();
            }
        }
    });
});
document.addEventListener('focusOnSearchBar', function() {
    focusOnSearchBar();
});
