var sidebar_is_shown;
var change_theme = function (theme) { return false; };
var persisted_theme = function () { return localStorage.getItem('color-scheme') };
var persist_theme = function (theme) { localStorage.setItem('color-scheme', theme) };

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

(function () {
    let theme = persisted_theme();
    if (theme && change_theme(theme)) {
        return;
    }
    theme = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
    change_theme(theme);
    persist_theme(theme);
})();

// Open navbar menu via burger button on mobiles
$(document).ready( function() {
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

    $('#toggle-theme').click(function () {
        var theme = persisted_theme() === 'light' ? 'dark' : 'light';
        change_theme(theme);
        persist_theme(theme);
    });
});

$(document).ready( function() {
    // trigger the highlighter
    hljs.highlightAll();
    var sidebar_is_shown = localStorage.getItem('sidebarIsShown');;
    if (sidebar_is_shown === null) {
        // If the screen is not wide enough and the sidebar overlaps content -
        // hide it (if it was not enabled on purpose and so was in cookies)
        sidebar_is_shown = $(window).width() > 1760 ? 'open' : 'closed';
        localStorage.setItem('sidebarIsShown', sidebar_is_shown);
    }
    move_sidebar( sidebar_is_shown );
    $('#raku-sidebar').click( function() {
        sidebar_is_shown = sidebar_is_shown === 'closed' ? 'open' : 'closed';
        localStorage.setItem('sidebarIsShown', sidebar_is_shown);
        move_sidebar( sidebar_is_shown );
    });
    function move_sidebar( show ) {
        var el = $('#raku-sidebar');
        var icon_container = $(el).find('.icon')[0];
        if ( show === 'open' ) {
            $("#mainSidebar").css('width', '');
            $("#mainSidebar").css('display', 'block');
            $(el).css('left', '');
            $(icon_container).html(FontAwesome.icon({prefix: 'fas', iconName: 'chevron-left'}).html[0]);
        }
        else {
            $("#mainSidebar").css('width', '0');
            $("#mainSidebar").css('display', 'none');
            $(el).css('left', '-5px');
            $(icon_container).html(FontAwesome.icon({prefix: 'fas', iconName: 'chevron-right'}).html[0]);
        }
    };

    var originalTOC = $('#toc-menu').html();
    $("#toc-filter").keyup(function () {
        $('#toc-menu').html(originalTOC);
        var searchText = this.value.toLowerCase();
        if (searchText.length === 0) return;
        var $menuListElements = $('.menu-list').find("li");
        var $matchingListElements = $menuListElements.filter(function (i, li) {
            var listItemHTML = li.firstChild.innerHTML;
            var fuzzyRes = fuzzysort.go(searchText, [listItemHTML])[0];
            if (fuzzyRes === undefined || fuzzyRes.score < -8000) {
                return false;
            }
            var res = fuzzysort.highlight(fuzzyRes);
            if (res !== null) {
                var nodes = $(li).contents().filter(function (i, node) { return node.nodeType == 1; });
                nodes[0].innerHTML = res;
                return true;
            } else {
                return false;
            }
        });
        $menuListElements.hide();
        $($matchingListElements).each(function (i, elem) {
            $(elem).parents('li').show();
        });
        $matchingListElements.show();
    });
    // copy code block to clipboard adapted from solution at
    // https://stackoverflow.com/questions/34191780/javascript-copy-string-to-clipboard-as-text-html
    // if behaviour problems with different browsers add stylesheet code from that solution.
        $('.copy-code').on('click', function(){
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

