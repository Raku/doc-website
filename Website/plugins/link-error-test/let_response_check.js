$(document).ready(function(){
    $('a.let-links').each(function() {
        var ref = $(this).attr('href');
        var chng = $(this).next();
        var lnk = $(this).parent();
        var resp = $.get(ref);
        resp.done(function() {
            chng.html('OK');
            chng.css('color', 'green');
        });
        resp.always(function(xhr) {
            if ( xhr.status == 0 ) {
                chng.html('OK');
            }
            else {
                chng.html(xhr.statusCode + ' ' + xhr.statusText);
            }
        })
    })
})