$(document).ready( function() {
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