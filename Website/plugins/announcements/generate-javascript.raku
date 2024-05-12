use v6.d;
sub ( $pr, %processed, %options) {
    if 'generated.js'.IO ~~ :e & :f {
        'generated.js'.IO.unlink;
        return []
    }
    my @first = $pr.get-data('note')<first-item>.list;
    'generated.js'.IO.spurt: qq:to/JS/;
        var announceState;
        var persisted_announcements = function () \{
            return JSON.parse( localStorage.getItem('announceState') );
        };
        var persist_announcements = function (announceState) \{
            localStorage.setItem('announceState', JSON.stringify( announceState ))
        };
        document.addEventListener('DOMContentLoaded', function() \{
            // announcements suppression
            announceState = persisted_announcements();
            if ( announceState == null ) \{
                announceState = \{
                    "suppressed": false,
                    "last": ''
                }
            }
            // set and install the suppression toggle listener
            const tog = document.getElementById('cancelAnnouncements');
            tog.checked = announceState.suppressed;
            tog.addEventListener('change', function() \{
                announceState.suppressed = document.querySelector('#cancelAnnouncements').checked;
                persist_announcements(announceState);
            });
            // do nothing more if announcements suppressed
            const lastId = '{ @first[0] }';
            if (
                announceState.suppressed || announceState.last == lastId
            ) \{ return };
            announceState.last = lastId;
            persist_announcements(announceState);
            // add content to named div
            document.getElementById('raku-doc-announcement').innerHTML = `{ @first[1] }`;
            // invoke modal
            document.getElementById('announcement-modal').classList.add('is-active');
        })
    JS
    [ ['assets/scripts/announcements.js', 'myself', 'generated.js' ], ]
}
