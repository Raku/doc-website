var sidebar_is_shown;

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
    var theme = localStorage.getItem('color-scheme');
    if (theme == null) {
        localStorage.setItem('color-scheme', window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light');
    }
    $('#toggle-theme').click(function () {
            var theme = localStorage.getItem('color-scheme') || 'light';
            localStorage.setItem('color-scheme', theme === 'light' ? 'dark' : 'light');
            let links = document.getElementsByTagName('link');
            for (let i = 0; i < links.length; i++) {
                if (links[i].getAttribute('rel') == 'stylesheet') {
                    let href = links[i].getAttribute('href');
                    var replacer = undefined;
                    if (href.includes('light')) {
                        replacer = href.replace('light', 'dark');
                    } else if (href.includes('dark')) {
                        replacer = href.replace('dark', 'light');
                    }
                    if (replacer !== undefined)
                        links[i].setAttribute('href', replacer);
                }
            }
        });
    });

$(document).ready( function() {
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
});
$(document).ready(function() {
    $('#query').focus(function () {
        if ($('.navbar-menu').css('display') == 'flex') {
            $("#query").stop(true);
            $('.navbar-start').hide();
            $("#query").animate({ width: "980px" }, 200, function () { $(".navbar-search-autocomplete").width("980px"); $('#navbar-search').show(); });
        } else {
            $('#navbar-search').show();
        }
        $('#navMenu').addClass('navbar-autocomplete-active');
    });
    $('#query').blur(function () {
        if ($('.navbar-menu').css('display') == 'flex') {
            $("#query").stop(true);
            $("#query").animate({ width: "200px" }, 400, function () { $('.navbar-start').show() });
        }

        $('#navbar-search').hide();
        $('#navMenu').removeClass('navbar-autocomplete-active');
    });
});

(function enforceCurrentTheme() {
    var theme = localStorage.getItem('color-scheme') || 'light';
    var cssLinks = $('link[rel="stylesheet"]');
    var toDelete = [];
    for (var i = 0; i < cssLinks.length; i++) {
        let href = cssLinks[i].getAttribute('href');
        if (!href.includes('light.css') && !href.includes('dark.css'))
            continue;
        if (!href.includes(theme))
            toDelete.push(cssLinks[i]);
    }
    for (var i = 0; i < toDelete.length; i++) {
        toDelete[i].parentNode.removeChild(toDelete[i]);
    }
})(); // Invoke this right away because it modifies metadata