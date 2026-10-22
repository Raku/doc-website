use v6.d;
use RakuDoc::Render;
use File::Directory::Tree;
use LibCurl::Easy;

#| Add a RakuPP widget 
unit class Doc-Website::Plugin::BrowserREPL;
has %.config =
        :name-space<BrowserREPL>,
        :version<0.1.5>,
        :license<Artistic-2.0>,
        :credit<finanalyst ash>,
        :authors<finanalyst>,
        :js-link(['src="https://raku.online/raku.js"', 1],
                 ['type="module" src="https://cdn.jsdelivr.net/npm/@tokuhirom/mutsu@latest/embed.js"', 1]),
        :js([self.BrowserREPL-js, 2],),
        :scss([self.BrowserREPL-scss, 1],),
        ui-tokens => %(
            :BrowserREPL-label('Raku bar'),
            :BrowserREPL-label-tip('Enable a bar that evaluates Raku code'),
            :BrowserREPL-label-on('Enabled'),
            :BrowserREPL-label-off('Disabled'),
            :BrowserREPL-button-tip-on('Hide Raku panel'),
            :BrowserREPL-button-tip-off('Show Raku panel'),
            :BrowserREPL-rakupp-label('Raku++'),
            :BrowserREPL-mutsu-label('Mutsu'),
            :BrowserREPL-drag-tip('Click & hold to drag bar'),
        );
has Str $!destination;
method enable(RakuDoc::Processor:D $rdp) {
    $rdp.add-data(%!config<name-space>, %!config);
    $rdp.add-templates($.BrowserREPL-templates, :source<BrowserREPL plugin>);
    #    $!destination = $rdp.config<publication> ~ '/rakupp';
}
method get-rakupp {
    # get rakupp and other WASM files
    # this would be necessary if raku.online is no longer available.
    # in which case, the files would be downloaded somewhere, then moved to assets/rakupp
    # downloading at build time would be the same as getting from raku.online
    #    mktree $!destination;
    #    my LibCurl::Easy $curl;
    #    for <https://raku.online/raku.js https://raku.online/rakujs.js https://raku.online/rakujs.wasm> -> $url {
    #        $curl .= new(:URL($url), :followlocation, :failonerror);
    #        try {
    #            $curl.perform;
    #        }
    #        CATCH {
    #            default {
    #                my $!error = "Link ｢$url｣ caused LibCurl Exception, response code ｢{ $curl.response-code }｣ with error ｢{ $curl.error }｣";
    #            }
    #        }
    #    }
}
method BrowserREPL-js {
    q:to/JS/
        // BrowserREPL
        var BrowserREPLEnabled = true;
        var BrowserREPLState = false;
        var BrowserREPLShow;
        var BrowserREPLObject;
        var BrowserREPLGrasp;
        const toggleBrowserREPLObj = ( ) => {
            if ( BrowserREPLState ) {
                BrowserREPLObject.classList.add('is-hidden');
                BrowserREPLState = false;
            }
            else {
                BrowserREPLObject.classList.remove('is-hidden');
                BrowserREPLState = true;
            }
        };
        const enableBrowserREPL = ( ) => {
            if ( BrowserREPLEnabled ) {
                BrowserREPLShow.classList.remove('is-hidden');
            }
            else {
                BrowserREPLShow.classList.add('is-hidden');
            }
            BrowserREPLState = false;
            BrowserREPLObject.classList.add('is-hidden');
        }

        // Source - https://stackoverflow.com/a/63425707
        // Posted by mmaismma, modified by community. See post 'Timeline' for change history
        // Retrieved 2026-09-19, License - CC BY-SA 4.0
        // adapted for Raku doc files by finanalyst

        function dragStart(e) {
          document.addEventListener("mousemove", drag);
          document.addEventListener("touchmove", drag, { passive: false });

          // Remove listener when mouse/touch is lifted
          ["mouseup", "touchend"].forEach((endEvent) =>
            document.addEventListener(endEvent, () => {
              document.removeEventListener("mousemove", drag);
              document.removeEventListener("touchmove", drag, {
                passive: false,
              });
            }),
          );

          /* Use mouse events if they exist, use touch otherwise
           * Since there can be multiple touches, you need to mention one, we are using the first touch/finger only
           */
          const [oldX, oldY] = [
            e.clientX ?? e.touches[0].clientX,
            e.clientY ?? e.touches[0].clientY,
          ];

          const [oldLeft, oldTop] = [
            getComputedStyle(BrowserREPLObject).getPropertyValue("left").split("px")[0] * 1,
            getComputedStyle(BrowserREPLObject).getPropertyValue("top").split("px")[0] * 1,
          ];

          function drag(e) {
            e.preventDefault();

            const [distX, distY] = [
              (e.clientX ?? e.touches[0].clientX) - oldX,
              (e.clientY ?? e.touches[0].clientY) - oldY,
            ];

            BrowserREPLObject.style.left = oldLeft + distX + "px";
            BrowserREPLObject.style.top = oldTop + distY + "px";
            BrowserREPLObject.style.bottom = "unset";
          }
        }
        function swap_rakupp_mutsu(activate) {
            let disactivate = (activate == 'rakupp') ? 'mutsu' : 'rakupp';
            document.getElementById( activate + '-tab').classList.add('is-active');
            document.getElementById( disactivate + '-tab').classList.remove('is-active');
            document.getElementById( activate + '-widget').classList.remove('is-hidden');
            document.getElementById( disactivate + '-widget').classList.add('is-hidden');
        }
        // When the document has loaded
        window.addEventListener('load', function() {
            BrowserREPLObject = document.getElementById('BrowserREPL-panel');
            BrowserREPLGrasp =  document.getElementById('BrowserREPL-grasp-handle');
            BrowserREPLGrasp.addEventListener("mousedown", dragStart);
            BrowserREPLGrasp.addEventListener("touchstart", dragStart);
            BrowserREPLShow = document.getElementById('BrowserREPL-toggle');

            document.getElementById('BrowserREPL-enable').checked = BrowserREPLEnabled;
            enableBrowserREPL();
            // And add our event listeners
            document.getElementById('BrowserREPL-enable').addEventListener('change' , function(e) {
                BrowserREPLEnabled = e.target.checked;
                enableBrowserREPL();
            });
            BrowserREPLShow.addEventListener('click', function() {
                toggleBrowserREPLObj()
            });
            document.getElementById('rakupp-tab').addEventListener('click', function() { swap_rakupp_mutsu('rakupp') });
            document.getElementById('mutsu-tab').addEventListener('click', function() { swap_rakupp_mutsu('mutsu') });
        });
        JS
}
method BrowserREPL-templates {
    %(
        modal-container => -> %prm, $tmpl {
            $tmpl.prev ~ Q:c:to/REPLDIV/;
        <div class="panel is-hidden" id="BrowserREPL-panel">
            <div id="BrowserREPL-grasp-handle" class="tooltip">
                <span class="tooltiptext Elucid8-ui" data-UIToken="BrowserREPL-drag-tip">click & hold to drag</span>
                <span class="released"><i class="far fa-hand-pointer"></i></span>
                <span class="grasped"><i class="far fa-hand-rock"></i></span>
            </div>
            <p class="panel-tabs">
                <a id="rakupp-tab"><span data-UIToken="BrowserREPL-rakupp-label">Raku++</span></a>
                <a id="mutsu-tab"><span data-UIToken="BrowserREPL-mutsu-label">Mutsu</span></a>
            </p>
            <div id="rakupp-widget" class="panel-block" >
                <div data-raku data-run data-stdin="" data-hide="playground">say "Hello from Raku++!";</div>
            </div>
            <div id="mutsu-widget" class="panel-block is-hidden">
                <mutsu-code autorun>
                    <script type="text/raku">say "Hello from mutsu!";</script>
                </mutsu-code>
            </div>
        </div>
        <div id="BrowserREPL-toggle">
            <div class="button BrowserREPL-button tooltip">
                <span class="icon">
                    <i class="fas fa-terminal is-medium"></i>
                </span>
                <span class="Elucid8-ui tooltiptext on" data-UIToken="BrowserREPL-button-tip-on">BrowserREPL-button-tip-on</span>
                <span class="Elucid8-ui tooltiptext off" data-UIToken="BrowserREPL-button-tip-off">BrowserREPL-button-tip-off</span>
            </div>
        </div>
        REPLDIV

        },
        drop-down-list => -> %prm, $tmpl {
            $tmpl.prev ~ Q:c:to/BLOCK/;
                <hr class="navbar-divider">
                <label class="tooltip optionToggle navbar-item">
                    <span class="Elucid8-ui text" data-UIToken="BrowserREPL-label">BrowserREPL-label</span>
                    <span class="tooltiptext Elucid8-ui" data-UIToken="BrowserREPL-label-tip">BrowserREPL-label-tip</span>
                    <input id="BrowserREPL-enable" type="checkbox">
                    <span class="Elucid8-ui off" data-UIToken="BrowserREPL-label-off">BrowserREPL-label-off</span>
                    <span class="Elucid8-ui on" data-UIToken="BrowserREPL-label-on">BrowserREPL-label-on</span>
                </label>
        BLOCK

        }
    )
}
method BrowserREPL-scss {
    Q:to/SCSS/;
    #BrowserREPL-panel {
        position: fixed;
        bottom: 15vh;
        left: 1vw;
        width: 60vw;
        z-index: 60;
        background: var(--bulma-light);
        opacity: 90%;
            @media screen and (max-width: 768px) {
                width: 98vw;
        }
        #rakupp-widget div {
            margin: 0.5rem 1.5rem;
            width: 100%;
        }
        #mutsu-widget mutsu-code {
            margin: 0.5rem 1.5rem;
            width: 100%;
        }
    }
    #BrowserREPL-grasp-handle {
        position: absolute;
        left: 0.75rem;
        top: 0.75rem;
        color: blue;
        width: 4rem;
        .grasped {
            display: none;
            visibility: collapse;
        }
        &:hover:active {
            .grasped {
                display: inline;
                visibility: visible;
                color: red;
            }
            .released {
                display: none;
                visibility: collapse;
            }
        }
    }
    #BrowserREPL-toggle {
        right: 1vw;
        position: fixed;
        z-index: 10;
        top: 28vh;
        .BrowserREPL-button.tooltip {
            background: var(--bulma-scheme-main);
            border-color: var(--bulma-border);
            color: var(--bulma-info);
            span.icon {
                margin-inline-end: calc(var(--bulma-button-padding-horizontal)*-.5);
            }
            &:hover {
                background: var(--bulma-background-hover);
                color: var(--bulma-danger);
                .tooltiptext {
                    width:fit-content;
                    padding: 5px;
                    .Elucid8-ui {
                        padding: 0;
                    }
                }
            }
        }
    }
    SCSS

}
