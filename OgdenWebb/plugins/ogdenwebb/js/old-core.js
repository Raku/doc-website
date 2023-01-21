$(function () {
    setup_glot_io();
    setup_sidebar();
    setup_theme();
});

// Open navbar menu via burger button on mobiles
document.addEventListener('DOMContentLoaded', () => {

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
    }
});

function setup_theme() {
    var theme = cookie.get('color-scheme', undefined);
    if (theme === undefined) {
        cookie.set({ 'color-scheme': 'light' }, { expires: 30, path: '/' });
    }
    $('#toggle-theme').each(function (i, el) {
        $(el).click(function () {
            var theme = cookie.get('color-scheme', 'light');
            cookie.set({ 'color-scheme': theme === 'light' ? 'dark' : 'light' }, { expires: 30, path: '/' });
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
}

function setup_glot_io() {
    // CodeMirror editor is enabled on click
    $('.code-output').prev().each(function (i, el) {
        $(el).click(function () {
            var $el = $(this);
            // If already editor, return
            if ($el.find('.CodeMirror').length != 0) { return; }
            // If not a Raku snippet, return
            if (!$el.parent().hasClass('raku-lang')) { return; }
            let editorText = $($el.find('code').html().replaceAll('<div class="line">', '').replaceAll('</div>', '\n')).text();
            CodeMirror(el, {
                lineNumbers: true,
                lineWrapping: true,
                mode: 'perl6',
                scrollbarStyle: 'null',
                theme: 'ayaya',
                value: editorText
            });
            $el.find('code').text('');
        });
    });

    // Run code button
    $('.code-button').each(function (i, el) {
        $(el).click(function () {
            var code = '';
            var output_top = '<p class="code-output-title">Output</p>';
            $(this).closest('.raku-code').find('.CodeMirror-code .CodeMirror-line').each(function (i, el) { code += $(el).text() + "\n"; });
            if (code.length == 0) {
                $(this).closest('.raku-code').find('code').each(function (i, el) { $(el).find('.line').each(function (i, el) { code += $(el).text() + "\n"; }) });
            }

            // Adds a spinner for the user to wait...
            $(el).closest('.raku-code').find('.code-output').each(function (i, el) {
                $(el).find('div').append(
                    $('<div/>').addClass("code-run-spinner-container")
                        .append($('<div/>').addClass("code-run-spinner")
                            .append($('<img/>').attr('id', 'camelia-spinner').attr('src', 'https://raku.org/camelia-logo.png').attr('width', '50'))
                            .append($('<p/>').text('Running Code'))
                        )
                );
            });
            jQuery.ajax('/run', {
                method: 'POST',
                success: function (data) {
                    $(el).closest('.raku-code').find('.code-output').each(function (i, el) {
                        $(el).find('div').html(output_top + data);
                    });
                },
                data: { code: code },
                error: function (req, error) {
                    $(el).closest('.raku-code').find('.code-output').each(function (i, el) {
                        $(el).find('div').html(output_top + 'Error occurred: ' + error);
                    });
                }
            });
        });
    });
}

var sidebar_is_shown;

function setup_sidebar() {
    sidebar_is_shown = JSON.parse(cookie.get('sidebar', null));
    if (sidebar_is_shown === null) {
        // If the screen is not wide enough and the sidebar overlaps content -
        // hide it (if it was not enabled on purpose and so was in cookies)
        sidebar_is_shown = $(window).width() > 1760;
        cookie.set({ sidebar: sidebar_is_shown }, { expires: 30, path: '/' });
        if (!sidebar_is_shown) {
            hide_sidebar($('.raku-sidebar-toggle')[0]);
        }
    }

    function hide_sidebar(el) {
        var svg = $(el).find('svg')[0];
        if (svg !== undefined) {
            svg.setAttribute('data-icon', 'chevron-right');
        }
        else {
            var i_icon = $(el).find('i')[0];
            $(i).removeClass('fa-chevron-left');
            $(i).addClass('fa-chevron-right');
        }
        $("#mainSidebar").css('width', '0');
        $("#mainSidebar").css('display', 'none');
        $(el).css('left', '-5px');
    }

    function show_sidebar(el) {
        var svg = $(el).find('svg')[0];
        if (svg !== undefined) {
            svg.setAttribute('data-icon', 'chevron-left');
        }
        $("#mainSidebar").css('width', '');
        $("#mainSidebar").css('display', 'block');
        $(el).css('left', '');
    }

    // Sidebar toggle
    $('.raku-sidebar-toggle').each(function (i, el) {
        $(el).click(function () {
            if (sidebar_is_shown) {
                sidebar_is_shown = false;
                hide_sidebar(el);
            } else {
                sidebar_is_shown = true;
                show_sidebar(el);
            }
            cookie.set({ sidebar: sidebar_is_shown }, { expires: 30, path: '/' });
        });
    });

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
}
