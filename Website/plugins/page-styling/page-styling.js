var change_theme = function (theme) { return false; };
var persisted_theme = function () { return localStorage.getItem('color-scheme') };
var persist_theme = function (theme) { localStorage.setItem('color-scheme', theme) };

var pageOptionsState;
var persisted_pageOptions = function () {
    return JSON.parse( localStorage.getItem('pageOptionsState') );
};
var persist_pageOptions = function (pageOptionsState) {
    localStorage.setItem('pageOptionsState', JSON.stringify( pageOptionsState ))
};

var set_ToC_panel = function ( state ) {
    if ( state === 'closed') {
        $('#left-column').addClass('is-hidden');
        $('#navbar-left-toggle').prop('checked', false );
    }
    else {
        $('#left-column').removeClass('is-hidden');
        $('#navbar-left-toggle').prop('checked', true );
    }
    pageOptionsState.toc.panel = state;
    persist_pageOptions( pageOptionsState );
};
var set_settings = function ( state ) {
    if ( state === 'enabled') {
        $('#pageSettings').prop('checked', true );
    }
    else {
        $('#pageSettings').prop('checked', false );
    }
    pageOptionsState.settings.shortcuts = state;
    persist_pageOptions( pageOptionsState );
};
const searchFocus = new CustomEvent('focusOnSearchBar');

(function generateColorSchemes() {
    const theme_links = {};
    const change_themes = {};
    for (const link of document.querySelectorAll('link[rel="stylesheet"]')) {
        const title = link.getAttribute("title");
        if (!title)
            continue;
        link.disabled = true;
        (theme_links[title] ||= []).push(link);
    }
    const links_by_filter = (predicate) => Array.prototype.concat.apply([], Object.entries(theme_links).filter(k => predicate({ theme: k[0] })).map(e => e[1]));
    for (const theme in theme_links) {
        const links_to_disable = links_by_filter(e => e.theme != theme);
        const links_to_enable = links_by_filter(e => e.theme == theme);
        change_themes[theme] = function () {
            for (const link of links_to_disable)
                link.disabled = true;
            for (const link of links_to_enable)
                link.disabled = false;
        }
    }
    change_theme = function (theme) {
        let change = change_themes[theme];
        if (change) {
            change();
            return true;
        } else {
            console.error("Could not set theme", theme);
            return false;
        }
    }
})();
// initialise if localStorage not set
(function () {
    let theme = persisted_theme();
    if (! (theme && change_theme(theme) ) ) {
        theme = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
        change_theme(theme);
        persist_theme(theme);
    }

    pageOptionsState = persisted_pageOptions();
    if ( pageOptionsState == null ) {
        pageOptionsState = {
            "toc": { "alt": true, "ctrl": false, "letter": 't', "panel": 'closed' },
            "search": { "alt": false, "ctrl": false, "letter": 'f' },
            "theme": { "alt": true, "ctrl": false, "letter": 'k' },
            "settings": { "alt": true, "ctrl": false, "letter": 'g', "shortcuts": 'enabled' },
        };
        persist_pageOptions( pageOptionsState );
    } else if ( pageOptionsState.search.alt ) {
        // TODO: we need to temporarily migrate the keyboard shortcut
        // to not use alt however, we need a way to migrate the state
        // as we may change the other shortcuts.
        pageOptionsState.search.alt = false;
        persist_pageOptions( pageOptionsState );
    }
})();

// Add listeners
// Open navbar menu via burger button on mobiles

document.addEventListener('DOMContentLoaded', function () {
    // Get all "navbar-burger" elements
    const $navbarBurgers = Array.prototype.slice.call(document.querySelectorAll('.navbar-burger'), 0);
    // Check if there are any navbar burgers
    if ($navbarBurgers.length > 0) {
        // Add a click event on each of them
        $navbarBurgers.forEach(el => {
            el.addEventListener('click', () => {
                // Get the target from the "data-target" attribute
                const target = el.dataset.target;
                const $target = document.getElementById(target);
                // Toggle the "is-active" class on both the "navbar-burger" and the "navbar-menu"
                el.classList.toggle('is-active');
                $target.classList.toggle('is-active');
            });
        });
    };
    // initialise window state
    $('#toggle-theme').click(function () {
        let theme = persisted_theme() === 'light' ? 'dark' : 'light';
        change_theme(theme);
        persist_theme(theme);
    });
    set_ToC_panel( pageOptionsState.toc.panel );
    set_settings( pageOptionsState.settings.shortcuts )
    // make left toggle invisible if not TOC
    if ( $('#No-TOC').checked = 'checked' ) {
        $('#navbar-left-toggle').css({ "visibility": "invisible" });
    }
    $('#navbar-left-toggle').change(function () {
        set_ToC_panel( pageOptionsState.toc.panel === 'closed' ? 'open' : 'closed' )
    });
    $('#pageSettings').change(function () {
        set_settings( pageOptionsState.settings.shortcuts === 'enabled' ? 'disabled' : 'enabled' );
    });
    // keyboard events to change pageOptions
    document.addEventListener('keydown', e => {
        if ( e.target == document.body
             && pageOptionsState
             && pageOptionsState.settings.shortcuts !== 'disabled') {
             Object.keys( pageOptionsState ).forEach( attr => {
                if ( ( e.altKey === pageOptionsState[ attr ].alt )
                     &&
                     ( e.ctrlKey === pageOptionsState[ attr ].ctrl )
                     &&
                     (e.key === pageOptionsState[ attr ].letter
                      ||
                      e.keyCode === pageOptionsState[ attr ].letter.toUpperCase().charCodeAt(0) )
                   )
               {
                    e.preventDefault();
                    switch( attr ) {
                        case 'toc':
                            set_ToC_panel( pageOptionsState.toc.panel === 'closed' ? 'open' : 'closed' )
                            break;
                        case 'search':
                            // the action should be carried out by the search plugin
                            document.dispatchEvent( searchFocus );
                            break;
                        case 'theme':
                            let theme = persisted_theme() === 'light' ? 'dark' : 'light';
                            change_theme(theme);
                            persist_theme(theme);
                            break;
                        case 'settings':
                            set_settings( pageOptionsState.settings.shortcuts === 'enabled' ? 'disabled' : 'enabled' );
                            break;
                    }
                }
            })
        }
    });
    // copy code block to clipboard adapted from solution at
    // https://stackoverflow.com/questions/34191780/javascript-copy-string-to-clipboard-as-text-html
    // if behaviour problems with different browsers add stylesheet code from that solution.
    $('.copy-code').click( function() {
        var codeElement = $(this).next().next(); // skip the label and get the div
        var container = document.createElement('div');
        container.innerHTML = codeElement.html();
        container.style.position = 'fixed';
        container.style.pointerEvents = 'none';
        container.style.opacity = 0;
        document.body.appendChild(container);
        window.getSelection().removeAllRanges();
        var range = document.createRange();
        range.selectNode(container);
        window.getSelection().addRange(range);
        document.execCommand("copy", false);
        document.body.removeChild(container);
    });
});

