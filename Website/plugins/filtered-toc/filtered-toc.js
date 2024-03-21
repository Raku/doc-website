$(document).ready( function() {
    var originalTOC = $('#toc-menu').html();
    var originalIndex = $('#index-menu').html();
    $("#toc-filter").keyup(function () {
        $('#toc-menu').html(originalTOC);
        $('#index-menu').html(originalIndex);
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
    $('#toc-tab').click( function() { swap_toc_index('toc') });
    $('#index-tab').click( function() { swap_toc_index('index') });
});
function swap_toc_index(activate ) {
    let disactivate = (activate == 'toc') ? 'index' : 'toc';
    $('#' + activate + '-tab').addClass('is-active');
    $('#' + disactivate + '-menu').addClass('is-hidden');
    $('#' + disactivate + '-tab').removeClass('is-active');
    $('#' + activate + '-menu').removeClass('is-hidden');
}