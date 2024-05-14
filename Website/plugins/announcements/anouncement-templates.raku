#!/usr/bin/env raku
use v6.d;
%(
    'cancel-announcement-popup' => sub ( %prm, %tml) {
        q:to/ITEM/;
            <hr class="navbar-divider">
            <label class="navbar-item centreToggle" title="Enable/Disable Announcements" style="--switch-width: 18">
               <input id="cancelAnnouncements" type="checkbox">
               <span class="text">Announcements</span>
               <span class="on">suppressed</span>
               <span class="off">allowed</span>
            </label>
        ITEM
    },
    'announcement-modal' => sub ( %prm, %tml) {
        q[       <div id="announcement-modal" class="modal">
                    <div class="modal-background"></div>
                    <div class="modal-content">
                        <div class="box">
                            <div id="raku-doc-announcement"></div>
                            <p>For more see <a href="/announcements">Announcements page</a>.</p>
                            <p>Exit this popup by pressing &lt;Escape&gt;, or clicking on X or on the background.</p>
                        </div>
                    </div>
                    <button class="modal-close is-large" aria-label="close"></button>
                </div>
        ]
    },
    'note' => sub ( %prm, %tml ) { # expecting contents, caption and date
        unless %prm<note><first-item>.elems { # id of note is concatenation of date & caption
            %prm<note><first-item> = [ ( %prm<date> ~ %prm<caption> ).Str, qq:to/POP/ ];
                    <div class="pop-header">{ %prm<date> } { %prm<caption> }</div>
                    <div class="pop-text">{ %prm<contents> }</div>
            POP
        }
        qq:to/NOTE/;
            <div class="announce">
            <div class="announce-head"><span class="date">{ %prm<date> }</span> { %prm<caption> }</div>
            <div class="announcement">{ %prm<contents> }</div>
            </div>
        NOTE
    },
)