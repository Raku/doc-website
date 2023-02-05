$(function(){
    // What we need to do is:
    // 1)process initial query we might have in URL parameters
    // 2)Setup an input callback
    var urlParams = new URLSearchParams(window.location.search);
    var queryParam = urlParams.get('q');
    if (queryParam !== null) {
        $("#search-input").val(queryParam);
        processQuery(queryParam);
    }
    $("#search-category-select").change(function() { processQuery($("#search-input").val()); });
    $("#search-input").keyup(function() { processQuery($("#search-input").val()); });
});

function processQuery(value) {
    if (value.length == 0) {
        return;
    }

    var category = $("#search-category-select").val();
    var res = fuzzysort.go(value, items.filter(function(item) { return category === "All" ? true : item.category === category; }), {
        limit: 50, // TODO in a nice world we will have pagination...
        allowTypo: true,
        key: 'value'
    });
    $("#search-count").text("Found: " + res.length);

    var resultsLen = res.length;
    var resultsCategorized = new Map();

    for (var i = 0; i < resultsLen; i++) {
        var item = res[i].obj;
        if (resultsCategorized.has(item.category)) {
            resultsCategorized.get(item.category).push(item);
        } else {
            resultsCategorized.set(item.category, []);
            resultsCategorized.get(item.category).push(item);
        }
    }
    $('.results').empty();
    resultsCategorized.forEach(function(value, key) {
        var catBox = $('<div/>')
            .addClass("box search-category")
            .append($('<div/>').addClass("search-category-title has-text-centered subtitle")
            .text(key));
        for (var i = 0; i < value.length; i++) {
            catBox.append(
                $('<article/>').addClass("search-item")
                    .append($('<div/>').addClass("search-item-title")
                        .append($('<a/>').attr("href", value[i].url).text(value[i].value))));
                // TODO we can append here a paragraph with some description, but it is not immediately obvious how to proceed, needs a volunteer
        }
        $('.results').append(catBox);
    });
}