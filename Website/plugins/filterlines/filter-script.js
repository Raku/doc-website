$(document).ready(function(){
    $("#RakuSearchLine").on("keyup", function() {
        var selector = $('#_search_selector').text();
        var value = $(this).val().toLowerCase();
        $(selector).filter(function() {
            $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1);
        });
    });
});