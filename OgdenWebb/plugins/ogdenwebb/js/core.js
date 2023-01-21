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
    var theme = cookie.get('color-scheme', undefined);
    if (theme === undefined) {
        cookie.set({ 'color-scheme': 'light' }, { expires: 30, path: '/', sameSite: 'lax', secure: true });
    }
    $('#toggle-theme').click(function () {
            var theme = cookie.get('color-scheme', 'light');
            cookie.set({ 'color-scheme': theme === 'light' ? 'dark' : 'light' }, { expires: 30, path: '/', sameSite: 'lax', secure: true });
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
    sidebar_is_shown = JSON.parse(cookie.get('sidebar', null));
    if (sidebar_is_shown === null) {
        // If the screen is not wide enough and the sidebar overlaps content -
        // hide it (if it was not enabled on purpose and so was in cookies)
        sidebar_is_shown = $(window).width() <= 1760;
        // opposite so the toggle reverses it
        cookie.set({ sidebar: sidebar_is_shown }, { expires: 30, path: '/', sameSite: 'lax', secure: true });
    }
    move_sidebar( sidebar_is_shown );
    $('#raku-sidebar').click( function() {
        sidebar_is_shown = ! sidebar_is_shown;
        cookie.set({ sidebar: sidebar_is_shown },
            { expires: 30, path: '/', sameSite: 'lax', secure: true });
        move_sidebar( sidebar_is_shown );
    });
    function move_sidebar( show ) {
        var el = $('#raku-sidebar');
        var svg = $(el).find('svg')[0];
        if (sidebar_is_shown) {
            $("#mainSidebar").css('width', '0');
            $("#mainSidebar").css('display', 'none');
            $(el).css('left', '-5px');
//            if (svg !== undefined) {
                svg.setAttribute('data-icon', 'chevron-right');
//            }
//            else {
//                var i_icon = $(el).find('i')[0];
//                $(i).removeClass('fa-chevron-left');
//                $(i).addClass('fa-chevron-right');
//            }
        }
        else {
            $("#mainSidebar").css('width', '');
            $("#mainSidebar").css('display', 'block');
            $(el).css('left', '');
//            if (svg !== undefined) {
                svg.setAttribute('data-icon', 'chevron-left');
//            }
//            else {
//                var i_icon = $(el).find('i')[0];
//                $(i).removeClass('fa-chevron-right');
//                $(i).addClass('fa-chevron-left');
//            }
        }
    };
    $(".menu-list li").each(function (i, elLi) {
    $(elLi).find('a').each(function (i, elA) {
        $(elA).click(function () {
            // Update menu items
            $(".menu-list li").each(function (i, el) {
                $(el).find('a').each(function (i, el) { $(el).removeClass('is-active'); });
            });
            $(this).addClass('is-active');
            // Update tab visibility
            var category = $(elLi).attr('id').substring(7); // 7 is length of "switch-"
            var tab_id = 'tab-' + category;
            $('.tabcontent').each(function (i, el) { $(el).css('display', 'none'); });
            $('#' + tab_id).css('display', 'block');
            // Update title-subtitle
            $('.page-title').text($('#page-title-' + category).text());
            $('.page-subtitle').text($('#page-subtitle-' + category).text());
            // Update URL as well to follow convention of static pages like `type-basic.html` we rendered
            // since forever, so backward-compat-y thing
            let prefix = window.location.href;
            let prefixEnd = prefix.includes('type') ? prefix.lastIndexOf('type') + 4 : prefix.lastIndexOf('routine') + 7;
            history.pushState(null, null, prefix.substr(0, prefixEnd) + (category === 'all' ? '' : '-' + category));
        });
    });
});

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
