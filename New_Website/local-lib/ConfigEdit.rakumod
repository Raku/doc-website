use v6.d;
use RakuDoc::Render;

unit class Raku-Doc-Website::ConfigEdit;
has %.config =
        :name-space<ConfigEdit>,
        :version<0.1.0>,
        :license<Artistic-2.0>,
        :credit<finanalyst>,
        :authors<finanalyst>,
        :scss([self.edit-scss,1],),
        :js( [[self.edit-config-js,2], [self.browser-js,2], ] ),
        :js-link(
        ['src="https://cdnjs.cloudflare.com/ajax/libs/ace/1.39.1/ace.js" integrity="sha512-tGc7XQXpQYGpFGmdQCEaYhGdJ8B64vyI9c8zdEO4vjYaWRCKYnLy+HkudtawJS3ttk/Pd7xrkRjK8ijcMMyauw==" crossorigin="anonymous" referrerpolicy="no-referrer"', 1],
        ['src="https://unpkg.com/diff"',1],
        ),
        set-host-port => -> %final-config { self.set-host-port( %final-config ) },
        ui-tokens => %(
            :ConfigEditGetModal('Edit configuration'),
            :ConfigEditGetModal-tip('Select options to edit pages'),
            :ConfigEditEnable('Enable edit button'),
            :ConfigEditGitPage('Open Github editor page'),
            :ConfigEditInBrowserBot('In browser editor with HTML rendering. Suggested edits are submitted by Edit Bot'),
            :ConfigEditInBrowserWithLogin('In browser editor with HTML rendering. Github authorisation is requested and PR is labelled with Github user name'),
            :ConfigEditLinkText_01('Open documentation '),
            :ConfigEditLinkText_02('page about website editing'),
            :ConfigEditLinkText_03(' for more information.'),
            :ConfigEditButtonTip('Edit this page. Modified&#13; '),
            :ConfigEditButtonTipUnable('Cannot edit this page.'),
            :ConfigEditRepeat('Suggestion accepted, thank you. Only one GitBot edit per session is accepted.'),
            :ConfigEditComposite(q:to/MOD/),
                This is an automatically generated page and cannot be edited directly. Text in Composite
                pages, (URLs starting with 'routine' or 'syntax') can be edited by clicking on the
                link labeled 'in context', and editing the text there.
                MOD
            :ConfigEditModalOff('Exit this popup by pressing &lt;Escape&gt;, or clicking on X or on the background.'),
            :EditorPanel('Editor panel'),
            :EditTabRendered('Rendered'),
            :EditTabDifferences('Differences'),
            :EditTabPatch('Patch'),
            :Edit-editor-tip('Click on Render to refresh'),
            :EditTabSubmit('Suggest'),
            :EditFormSubmit('Submit suggestion'),
            :EditFormName('Name'),
            :EditFormComment('Comment attached to suggestion'),
            :EditFormThanks('Thank you'),
            :EditFormTimeStamp('At: '),
            :EditFormError('There is an error: '),
            :EditFormQueuedOK(' your suggestion was queued'),
            :EditFormErrorUnknown('error unknown'),
            :EditFormTooManyChanges('too many changes. Patch is too big (see first line of Patch tab)'),
            :EditFormQueuedTooManyChanges('your suggestion was rejected: too many changes. Patch is too big (see first line of Patch tab)'),
            :EditFormQueuedTooLittleTimeOnToken('your suggestion was rejected: not enough time left on authorisation token'),
            :EditFormQueuedNoAuthorisation('your suggestion was rejected: no editor authorisation'),
            :EditFormInvalidEditorName('Editor must have form 3 > name.length < 39 and only have alphanumerics or -, no blank'),
            :EditFormErrorPatchZero('no changes have been made (see first line of Patch tab, zero changed chars)'),
        );

method enable( RakuDoc::Processor:D $rdp ) {
    $rdp.add-data( %!config<name-space>, %!config );
    $rdp.add-templates( self.templates, :source<ConfigEdit plugin>);
}
method set-host-port( %final-config ) {
    my $js = qq:to/VARS/;
    var suggestionWebsocket =  '{ %final-config<plugin-options><ConfigEdit><suggestion-websocket> }';
    var suggestionPatchLimit = '{ %final-config<plugin-options><ConfigEdit><patch-limit> }';
    VARS
    %!config<js>.push: [  $js, 1 ] ; # the script with host/port has to be before the repl-js script
}
method templates {
    %(
        page-edit => -> %prm, $tmpl {
            my %sd := %prm<source-data>;
            given %sd<type> {
                when <primary glue info>.any {
                    my $commit-time = '<i class="fa fa-ban"></i>';
                    $commit-time = %sd<modified>.yyyy-mm-dd if %sd<modified>:exists;
                    if %sd<repo-name>:exists and %sd<repo-path>:exists {
                        qq:to/BLOCK/
                        <div class="page-edit is-hidden">
                            <a id="editActivate" class="button page-edit-button tooltip"
                                data-reponame="{%sd<repo-name>}"
                                data-repopath="{%sd<repo-path>}"
                                >
                                <span class="icon">
                                    <i class="fas fa-pen-alt is-medium"></i>
                                </span>
                                <p class="tooltiptext">
                                    <span class="Elucid8-ui" data-UIToken="ConfigEditButtonTip">ConfigEditButtonTip</span>
                                    $commit-time
                                </p>
                            </a>
                          </div>
                        BLOCK
                    }
                    else  {
                        q:to/NOEDIT/
                        <div class="page-edit is-hidden">
                            <a class="button page-edit-button tooltip">
                                <span class="icon">
                                    <i class="fas fa-pen-alt is-medium"></i>
                                </span>
                                <p class="tooltiptext">
                                    <span class="Elucid8-ui" data-UIToken="ConfigEditButtonTipUnable">ConfigEditButtonTipUnable</span>
                                </p>
                            </a>
                        </div>
                        NOEDIT
                    }
                }
                when 'composite'  {
                    qq:to/BLOCK/
                    <div class="page-edit">
                        <a class="button page-edit-button js-modal-trigger tooltip"
                            data-target="page-edit-info">
                            <span class="icon">
                                <i class="fas fa-pen-alt is-medium"></i>
                            </span>
                        </a>
                    </div>
                    BLOCK
                }
                default {''}
            }
        },
        drop-down-list => -> %prm, $tmpl {
            $tmpl.prev ~ Q:c:to/BLOCK/;
                <hr class="navbar-divider">
                <a class="navbar-item tooltip js-modal-trigger"
                    id="ConfigEditGetModal"
                    data-target="EditConfigModal">
                    <span class="Elucid8-ui" data-UIToken="ConfigEditGetModal">ConfigEditGetModal</span>
                    <span class="tooltiptext Elucid8-ui" data-UIToken="ConfigEditGetModal-tip">ConfigEditGetModal-tip</span>
                </a>
                BLOCK
        },
        modal-container-inner => -> %prm, $tmpl {
            $tmpl.prev ~ Q:to/BLOCK/ ~ qq[<a href="/{%prm<source-data><language>}/editing-rakudoc">] ~ Q:to/BLOCK/;
            <div id="EditConfigModal" class="modal">
                <div class="modal-background"></div>
                <div class="modal-content">
                    <div class="box">
                        <p><span class="Elucid8-ui" data-UIToken="ConfigEditLinkText_01">ConfigEditLinkText_01</span>
            BLOCK
                        <span class="Elucid8-ui" data-UIToken="ConfigEditLinkText_02">ConfigEditLinkText_02</span></a>
                        <span class="Elucid8-ui" data-UIToken="ConfigEditLinkText_03">ConfigEditLinkText_03</span></p>
                        <label class="checkbox">
                            <input type="checkbox" id="ConfigEditEnable" />
                            <span class="Elucid8-ui" data-UIToken="ConfigEditEnable">ConfigEditEnable</span>
                        </label>
                        <div id="editOptionsGroup" class="field is-hidden">
                        <div class="radio is-hidden"></div> <!- to fool bulma ->
                            <label class="radio">
                                <input type="radio" name="editconfigoption" id="ConfigEditGitPage" />
                                <span class="Elucid8-ui" data-UIToken="ConfigEditGitPage">ConfigEditGitPage</span>
                            </label>
                            <label class="radio">
                                <input type="radio" name="editconfigoption" id="ConfigEditInBrowserBot" />
                                <span class="Elucid8-ui" data-UIToken="ConfigEditInBrowserBot">ConfigEditInBrowserBot</span>
                            </label>
                            <label class="radio">
                                <input type="radio" name="editconfigoption" id="ConfigEditInBrowserWithLogin" />
                                <span class="Elucid8-ui" data-UIToken="ConfigEditInBrowserWithLogin">ConfigEditInBrowserWithLogin</span>
                            </label>
                        </div>
                        <p><span class="Elucid8-ui" data-UIToken="ConfigEditModalOff">ConfigEditModalOff</span></p>
                    </div>
                </div>
                <button class="modal-close is-large" aria-label="close"></button>
            </div>
            <div id="PageEditor" class="modal">
                <div class="modal-background"></div>
                <div class="modal-content">
                    <div class="box">
                        <div class="edit-preview-box">
                            <div id="editor-panel">
                                <div>
                                    <span class="Elucid8-ui" data-UIToken="EditorPanel">Editor panel</span>&nbsp;
                                    <span id="editor-tip" class="tooltip has-text-info">
                                        <span class="icon">
                                            <i class="fas fa-question"></i>
                                        </span>
                                        <span class="Elucid8-ui tooltiptext" data-UIToken="Edit-editor-tip">Edit-editor-tip</span>
                                    </span>
                                </div>
                                <div id="editor"></div>
                            </div>
                            <div id="preview-panel" class="panel">
                                <div class="panel-tabs">
                                    <a id="showRendered" data-openchannel="off" class="showEditTab Elucid8-ui is-active" data-UIToken="EditTabRendered">Rendered</a>
                                    <a id="showDifference" class="showEditTab Elucid8-ui" data-UIToken="EditTabDifferences">Differences</a>
                                    <a id="showPatch" class="showEditTab Elucid8-ui" data-UIToken="EditTabPatch">Patch</a>
                                    <a id="showSubmit" class="showEditTab Elucid8-ui" data-UIToken="EditTabSubmit">Submit</a>
                                </div>
                                <iframe id="renderPanel" class="panel-block edit-panel-border"></iframe>
                                <div id="differencePanel" class="panel-block is-hidden edit-panel-border"></div>
                                <div id="patchPanel" class="panel-block is-hidden edit-panel-border"></div>
                                <div id="submitPanel" class="panel-block is-hidden edit-panel-border">
                                    <div class="field tooltip">
                                        <label class="label Elucid8-ui" data-UIToken="EditFormName">Name</label>
                                        <div class="control">
                                            <input id="EditFormEditor" class="input" type="text">
                                        </div>
                                    </div>
                                    <div class="field tooltip">
                                        <label class="label Elucid8-ui" data-UIToken="EditFormComment">Comment</label>
                                        <div class="control">
                                            <textarea id="EditFormComment" class="textarea"></textarea>
                                        </div>
                                    </div>
                                    <div class="field">
                                        <div class="control">
                                            <button id="EditFormSubmit" disabled="true" class="button is-link Elucid8-ui" data-UIToken="EditFormSubmit">Submit</button>
                                        </div>
                                    </div>
                                    <div id="EditFormQueued" class="field is-hidden">
                                        <label class="label Elucid8-ui" data-UIToken="EditFormThanks">Thanks</label>
                                        <div class="control">
                                            <span class="Elucid8-ui" data-UIToken="EditFormTimeStamp">EditFormTimeStamp</span>
                                            <span id="EditFormQueuedResp"></span>
                                            <span id="EditFormQueuedOK" class="is-hidden Elucid8-ui" data-UIToken="EditFormQueuedOK"></span>
                                        </div>
                                    </div>
                                    <div id="EditFormError" class="is-hidden control">
                                        <span class="Elucid8-ui" data-UIToken="EditFormError"></span>
                                        <span id="EditFormErrorUnknown" class="is-hidden Elucid8-ui editFormError" data-UIToken="EditFormErrorUnknown"></span>
                                        <span id="EditFormTooManyChanges" class="is-hidden Elucid8-ui editFormError" data-UIToken="EditFormTooManyChanges"></span>
                                        <span id="EditFormInvalidEditorName" class="is-hidden Elucid8-ui editFormError" data-UIToken="EditFormInvalidEditorName"></span>
                                        <span id="EditFormErrorPatchZero" class="is-hidden Elucid8-ui editFormError" data-UIToken="EditFormErrorPatchZero"></span>
                                        <span id="EditFormQueuedTooManyChanges" class="is-hidden Elucid8-ui editFormError" data-UIToken="EditFormQueuedTooManyChanges"></span>
                                        <span id="EditFormQueuedNoAuthorisation" class="is-hidden Elucid8-ui editFormError" data-UIToken="EditFormNoAuthorisation"></span>
                                        <span id="EditFormQueuedTooLittleTimeOnToken" class="is-hidden Elucid8-ui editFormError" data-UIToken="EditFormTooLittleTimeOnToken"></span>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <p><span class="Elucid8-ui" data-UIToken="ConfigEditModalOff">ConfigEditModalOff</span></p>
                    </div>
                </div>
                <button class="modal-close is-large" aria-label="close"></button>
            </div>
            <div id="page-edit-info" class="modal">
                <div class="modal-background"></div>
                <div class="modal-content">
                    <div class="box">
                        <p><span class="Elucid8-ui" data-UIToken="ConfigEditComposite">ConfigEditComposite</span></p>
                        <p><span class="Elucid8-ui" data-UIToken="ConfigEditModalOff">ConfigEditModalOff</span></p>
                    </div>
                </div>
                <button class="modal-close is-large" aria-label="close"></button>
            </div>
            <div id="configEditRepeat" class="modal">
                <div class="modal-background"></div>
                <div class="modal-content">
                    <div class="box">
                        <p><span class="Elucid8-ui" data-UIToken="ConfigEditRepeat">ConfigEditRepeat</span></p>
                        <p><span class="Elucid8-ui" data-UIToken="ConfigEditModalOff">ConfigEditModalOff</span></p>
                    </div>
                </div>
                <button class="modal-close is-large" aria-label="close"></button>
            </div>
            <div id="githubConfirm" class="modal">
                <div class="modal-background"></div>
                <div class="modal-content">
                    <div class="box">
                        <iframe id="githubFrame"></iframe>
                        <p><span class="Elucid8-ui" data-UIToken="ConfigEditModalOff">ConfigEditModalOff</span></p>
                    </div>
                </div>
                <button class="modal-close is-large" aria-label="close"></button>
            </div>
            BLOCK
        },
    )
}
method edit-scss {
    q:to/SCSS/;
        .page-edit {
            right: 1vw;
            position: fixed;
            top: 15vh;
            z-index: 10;

            .page-edit-button.tooltip {
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
        #PageEditor .modal-content {
            width: 80vw;
            .box { height: 80vh; }
            p { text-align: center; }
        }
        .edit-preview-box {
            height: 95%;
            #editor-panel, #preview-panel {
                display: flex;
                flex-direction: column;
                div:first-child {
                    align-self: center;
                    gap: 10px;
                }
                #patchPanel { overflow: auto; white-space: nowrap; }
                #submitPanel {
                    display: flex;
                    flex-direction: column;
                    #EditFormSubmit:disabled {
                        background-color: var(--bulma-warning);
                        cursor: not-allowed;
                    }
                    .field { width: 100% }
                }
            }
            .edit-panel-border {
                border: gray solid 1px;
                border-radius: 5px;
            }
        }
        @media screen and (min-width: 1024px){
            .edit-preview-box {
                display: flex;
                flex-direction: row;
                padding-bottom: 10px;
                gap: 5px;
                #editor-panel, #preview-panel { width: 38vw; }
                #editor { height: calc(60vh + 3.3em + 10px); }
                #renderPanel, #differencePanel, #patchPanel, #submitPanel {
                    height: 90%;
                    width: 100%;
                    display: block;
                    overflow: auto;
                }
            }
        }
        @media screen and (max-width: 1023px){
            .edit-preview-box {
                display: flex;
                flex-direction: column;
                #editor { height: 30vh; }
                #renderPanel, #differencePanel, #patchPanel, #submitPanel {
                    width: 100%;
                    display: block;
                    overflow: auto;
                    height: 26vh;
                }
            }
        }
        #editor-tip .tooltiptext { width: 25rem; right: -12.5rem; }
        .panel-tabs a.showEditTab {
            padding:0 3px;
            margin-bottom: 10px;
            border: double 2px;
            border-radius: 5px;
            width:fit-content;
            padding: 0.4rem 0.75rem;
            border-color: var(--bulma-info);
            &[data-openchannel="off"] {
                border-color: var(--bulma-danger);
            }
            &[data-openchannel="on"] {
                border-color: var(--bulma-primary);
            }
            &.is-active {
                box-shadow: var(--bulma-border-active) 3px 3px 3px;
            }
        }
    SCSS
}
method edit-config-js {
    q:to/JS/;
    // Edit State and Configuration
    var editState;
    var persisted_EditState = function () { return JSON.parse( localStorage.getItem('editState') ) };
    var persist_EditState = function () { localStorage.setItem('editState',JSON.stringify(editState) ) };
    window.addEventListener('load', function () {
        const editActivate = document.getElementById("editActivate");
        const editOpts = document.getElementById("editOptionsGroup");
        const pageEdits = Array.prototype.slice.call(document.querySelectorAll('.page-edit'), 0);
        editState = persisted_EditState();
        // editState will always be null until an option is changed from default and stored
        if ( editState == null ) {
            editState  = {
                "Enable": false,
                "GitPage": true,
                "InBrowserBot": false,
                "InBrowserWithLogin": false
            };
        }
        if ( editState.Enable ) {
            pageEdits.forEach( (elem) => { elem.classList.remove('is-hidden') });
            editOpts.classList.remove('is-hidden');
        }
        else {
            pageEdits.forEach( (elem) => { elem.classList.add('is-hidden') });
            editOpts.classList.add('is-hidden');
        }
        document.getElementById('ConfigEditInBrowserWithLogin').checked = editState.InBrowserWithLogin;
        document.getElementById('ConfigEditInBrowserBot').checked = editState.InBrowserBot;
        document.getElementById('ConfigEditGitPage').checked = editState.GitPage;
        modal = document.getElementById("EditConfigModal");
        modal.addEventListener('click', (event) => {
            if (event.target && event.target.matches('#ConfigEditEnable') ) {
                if (event.target.checked) {
                    pageEdits.forEach( (elem) => { elem.classList.remove('is-hidden') });
                    editOpts.classList.remove('is-hidden');
                    editState.Enable = true;
                    persist_EditState()
                }
                else {
                    pageEdits.forEach( (elem) => { elem.classList.add('is-hidden') });
                    editOpts.classList.add('is-hidden');
                    editState.Enable = false;
                    persist_EditState()
                }
            }
            else if (event.target && event.target.matches("input[type='radio']")) {
                editState.GitPage = false;
                editState.InBrowserBot = false;
                editState.InBrowserWithLogin = false;
                editState[ event.target.id.slice(10) ] = true;
                persist_EditState()
            }
        })
    })
    JS
}
method browser-js {
    q:to/JS/;
        var reponame;
        var repopath;
        var sha;
        var editor;
        var taintedRender = true;
        var taintedDiffs = true;
        var showRendered;
        var renderPanel;
        var showDifference;
        var differencePanel;
        var showPatch;
        var patchPanel;
        var showSubmit;
        var submitPanel;
        var initialContent;
        var patch;
        var patchLen;
        var suggestionSocket;
        var firstSuggestion = true; // only send one suggestion per page
        const toggle8 = ( p1, p2 ) => {
            // first make all inactive, then activate givens
            showRendered.classList.remove('is-active');
            showDifference.classList.remove('is-active');
            showPatch.classList.remove('is-active');
            showSubmit.classList.remove('is-active');
            renderPanel.classList.add('is-hidden');
            differencePanel.classList.add('is-hidden');
            patchPanel.classList.add('is-hidden');
            submitPanel.classList.add('is-hidden');
            p1.classList.add('is-active');
            p2.classList.remove('is-hidden');
        }
        // check if websocket is open (works for both)
        const socketIsOpen = function(ws) {
            return ws.readyState === ws.OPEN
        }
        function sendSource() {
            let source = editor.session.getValue();
            if(socketIsOpen(suggestionSocket)) {
                suggestionSocket.send(JSON.stringify({
                    "rakudocsource" : source
                }))
            }
        }
        function fetchFile() {
            url = `https://api.github.com/repos/${reponame}/contents/${repopath}`;
            fetch(url)
                .then( (response) => response.json() )
                .then( (json) => {
                    sha = json.sha;
                    text = decodeURIComponent(escape(atob(json.content)));
                    editor.session.setValue( text );
                    sendSource();
                    initialContent = text;
                });
        }
        var blobUrl;
        const blobify = ( bUrl, data ) => {
            if ( bUrl !== null ) { URL.revokeObjectURL( bUrl ) }
            const blob = new Blob([ data ], { type: "text/html" } );
            bUrl = URL.createObjectURL( blob );
            return bUrl
        };
        function newDiffs() {
            if (taintedDiffs) {
                patch = Diff.createPatch(repopath, initialContent, editor.session.getValue() );
                patchLen = 0;
                diff = Diff.diffChars(initialContent, editor.session.getValue() );
                fragment = document.createDocumentFragment();
                diff.forEach((part) => {
                  const color = part.added ? 'var(--bulma-info)' :
                    part.removed ? 'var(--bulma-danger)' : 'var(--bulma-text)';
                  span = document.createElement('span');
                  span.style.color = color;
                  span.innerHTML = part.value
                    .replace(/&/g, '&amp;')
                    .replace(/</g, '&lt;')
                    .replace(/>/g, '&gt;')
                    .replace(/"/g, '&quot;')
                    .replace(/'/g, '&#39;')
                    .replace(/\n/g, '<br>');
                  fragment.appendChild(span);
                  if (part.added || part.removed) { patchLen = patchLen + part.count }
                });
                while (differencePanel.firstChild) {
                  differencePanel.removeChild(differencePanel.firstChild);
                }
                differencePanel.appendChild(fragment);
                patchPanel.innerText = patch.length + ' (' + patchLen + ') / ' + suggestionPatchLimit + '\n^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n' + patch;
                taintedDiffs = false;
            }
        }
        window.addEventListener('load', function () {
            editorModal = document.getElementById('PageEditor');
            repeatModal = document.getElementById('configEditRepeat');
            renderPanel = document.getElementById('renderPanel');
            showDifference = document.getElementById('showDifference');
            differencePanel = document.getElementById('differencePanel');
            showPatch = document.getElementById('showPatch');
            patchPanel = document.getElementById('patchPanel');
            showSubmit = document.getElementById('showSubmit');
            submitPanel = document.getElementById('submitPanel');
            EditFormEditor = document.getElementById('EditFormEditor');
            EditFormComment = document.getElementById('EditFormComment');
            EditFormSubmit = document.getElementById('EditFormSubmit');
            EditFormQueued = document.getElementById('EditFormQueued');
            EditFormQueuedResp = document.getElementById('EditFormQueuedResp');
            showRendered = document.getElementById('showRendered');
            editActivate = document.getElementById('editActivate');
            editActivate.addEventListener('click', (activated) => {
                if (!firstSuggestion) {
                    repeatModal.classList.add('is-active');
                    return
                }
                editorModal.classList.add('is-active');
                reponame = activated.currentTarget.dataset.reponame;
                repopath = activated.currentTarget.dataset.repopath;
                // determine which of the edit modes is configured - one is always true
                // editState is set when configuring
                if (editState.GitPage) {
                    window.open( "https://github.com/" + reponame + "/edit/main/" + repopath , '_newtab').focus;
                    return
                }
                // edit activation should happen once a page refresh
                // remove any data from page refresh
                EditFormEditor.value = '';
                EditFormComment.value = '';
                // credit: This javascript file is adapted from
                // https://fjolt.com/article/javascript-websockets
                // Connect to the websocket
                // This will let us create a connection to our Server websocket.
                const connectRender = function() {
                    // Return a promise, which will wait for the socket to open
                    return new Promise((resolve, reject) => {
                        suggestionSocket = new WebSocket(suggestionWebsocket);
                        // This will fire once the socket opens
                        suggestionSocket.onopen = (e) => {
                            // Send a little test data, which we can use on the server if we want
                            suggestionSocket.send(JSON.stringify({ "loaded" : true }));
                            // Resolve the promise - we are connected
                            resolve();
                        }
                        // This will fire when the server sends the user a message
                        suggestionSocket.onmessage = (data) => {
                            let parsedData = JSON.parse(data.data);
                            if (parsedData.connection == 'Confirmed') {
                                showRendered.dataset.openchannel = 'on';
                                EditFormSubmit.removeAttribute('disabled');
                                sendSource();
                            }
                            else if ( parsedData.hasOwnProperty('html')) {
                                renderPanel.src = blobify(blobUrl, parsedData.html);
                            }
                            else {
                                EditFormQueuedResp.innerText = parsedData.timestamp;
                                if (parsedData.response == 'OK' && editState.InBrowserWithLogin ) {
                                    editorModal.classList.remove('is-active');
                                    repeatModal.classList.add('is-active');
                                    firstSuggestion = false;
                                    localStorage.setItem('editor', JSON.stringify(
                                        { editor: parsedData.editor,
                                          expiration: parsedData.expiration } ) )
                                }
                                else if (parsedData.response == 'OK' && editState.InBrowserBot ) {
                                    editorModal.classList.remove('is-active');
                                    repeatModal.classList.add('is-active');
                                    firstSuggestion = false;
                                }
                                else {
                                    showError('Queued' + parsedData.response)
                                }
                            }
                        }
                        // This will fire on error
                        suggestionSocket.onerror = (e) => {
                            // Return an error if any occurs
                            console.log(e);
                            showRendered.dataset.openchannel = 'off';
                            EditFormSubmit.setAttribute('disabled','true');
                            resolve();
                            // Try to connect again
                            connect();
                        }
                    });
                }
                editor = ace.edit("editor");
                editor.setOptions({
                   behavioursEnabled: true,
                   autoScrollEditorIntoView: true
                });
                editor.session.on('change', function() {
                    taintedRender = true;
                    taintedDiffs = true;
                });
                fetchFile();
                if (suggestionSocket == null ) { connectRender() }
            });
            showRendered.addEventListener('click', () => {
                if (taintedRender) {
                    sendSource();
                    taintedRender = false;
                }
                toggle8(showRendered, renderPanel);
            });
            showDifference.addEventListener('click', () => {
                toggle8(showDifference, differencePanel);
                newDiffs()
            });
            showPatch.addEventListener('click', () => {
                toggle8(showPatch, patchPanel);
                newDiffs()
            });
            showSubmit.addEventListener('click', () => {
                toggle8(showSubmit, submitPanel);
                newDiffs();
                if ( patchLen == 0 ) {
                    showError('ErrorPatchZero');
                    return
                }
                if ( patch.length > suggestionPatchLimit ) {
                    showError('TooManyChanges');
                    return
                }
                showError('None');
            });
            EditFormSubmit.addEventListener('click', () => {
                newDiffs();
                if ( patchLen == 0 ) {
                    showError('ErrorPatchZero');
                    return
                }
                if ( patch.length > suggestionPatchLimit ) {
                    showError('TooManyChanges');
                    return
                }
                edtr = EditFormEditor.value;
                if ( !/^[\w-]{3,39}$/.test(edtr) ) {
                    showError('InvalidEditorName');
                    return
                }
                showError('None');
                loginNeeded = true;
                // check to see if the editor already has a token, if yes send to Github login
                edtrData = localStorage.getItem('editorData');
                if ( edtrData !== null ) {
                    edtrData = JSON.parse( edtrData );
                    limit = new Date(Date.now() + (10 * 60 * 1000));
                    expiration = new Date(edtrData.expiration);
                    if (edtrData.name == edtr &&
                        expiration >= limit ) {
                        loginNeeded = false;
                    }
                }
                if(socketIsOpen(suggestionSocket) && firstSuggestion ) {
                    cmt = EditFormComment.value;
                    cmt = cmt ? cmt : 'No comment'; // set a non-blank default
                    suggestionSocket.send(JSON.stringify({
                        "editor"  : edtr,
                        "comment" : cmt,
                        "content" : btoa(unescape(encodeURIComponent(editor.session.getValue()))),
                        "repo"    : reponame,
                        "sha"     : sha,
                        "patch"   : patch,
                        "path"    : repopath,
                        "bot"     : editState.InBrowserBot,
                        "ghuser"  : editState.InBrowserWithLogin
                    }));
                    if ( loginNeeded && editState.InBrowserWithLogin ) {
                        client_id = '?client_id=Iv23liljgJ1Koi6bIfaa';
                        stObject = { editor: edtr, path: repopath };
                        state = '&state=' + btoa(unescape(encodeURIComponent( JSON.stringify(stObject) )));
                        other = '&allow_signup=true&prompt=select_account'
                        window.open('https://github.com/login/oauth/authorize'
                            + client_id + state + other, '_blank').focus
                    }
                }

            });
            function showError( type ) {
                (document.querySelectorAll('.editFormError') || []).forEach(($errPanel) => {
                    $errPanel.classList.add('is-hidden');
                });
                if ( type == 'None' ) {
                    document.getElementById('EditFormError').classList.add('is-hidden');
                    return
                };
                document.getElementById('EditFormError').classList.remove('is-hidden');
                if ( document.getElementById('EditForm' + type ) !== null ) {
                    document.getElementById('EditForm' + type ).classList.remove('is-hidden')
                }
                else {
                    document.getElementById('EditFormErrorUnknown').classList.remove('is-hidden')
                }
            }
        });
    JS
}
