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
var category = '';
var autoCompleteJS;

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
                    if (data.results.length > 0) {
                    info.innerHTML = `Displaying <strong>${data.results.length}</strong> out of <strong>${data.matches.length}</strong> results`;
                    } else {
                    info.innerHTML = `Found <strong>${data.matches.length}</strong> matching results for <strong>"${data.query}"</strong>`;
                    }
                    list.prepend(info);
                },
                noResults: true,
                maxResults: 20
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
                      <span class="autoComplete-result-data">
                        ${data.match}
                      </span>
                      ${extraSpan}`;
                },
                highlight: true,
            },
            events: {
                input: {
                    selection: (event) => {
                        const selection = event.detail.selection.value;
                        selectedCandidate.innerHTML = selection.url;
                        if ( searchOptions.newtab ) {
                            window.open( selection.url, '_blank');
                        }
                        else {
                            window.location.href = selection.url;
                        }
                    },
                    focus: () => {
                        if (autoCompleteJS.input.value.length) autoCompleteJS.start();
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
    document.getElementById('options-search-google').addEventListener('click', function() {
        let dest = 'https://www.google.com/search?q=site%3A'
            + webSite
            + '+'
            + encodeURIComponent( keywords );
        if ( searchOptions.newtab ) {
            window.open(dest, '_blank');
        } else {
            window.location.href = dest;
        }
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
    window.addEventListener('keydown', function (e) {
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
        if (e.ctrlKey && e.key === 'f' ) {
            e.preventDefault();
            document.getElementById('navMenu').classList.add('is-active');
            document.getElementById('autoComplete').focus();
        }
    });
});