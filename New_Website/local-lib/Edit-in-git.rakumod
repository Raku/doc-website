use v6.d;
use RakuDoc::Render;

unit class Raku-Doc-Website::Edit-in-git;
has %.config =
        :name-space<Edit-in-git>,
        :version<0.1.0>,
        :license<Artistic-2.0>,
        :credit<finanalyst>,
        :authors<finanalyst>,
        :scss([self.edit-scss,1],),
        ui-tokens => %(
            :EditButtonTip('Edit this page. Modified&#13; '),
            :EditButtonTipUnable('Cannot edit this page.'),
            :EditButtonModal(q:to/MOD/),
                This is an automatically generated page and cannot be edited directly. Text in Composite
                pages, (URLs starting with 'routine' or 'syntax') can be edited by clicking on the
                link labeled 'in context', and editing the text there.
                MOD
            :EditButtonModalOff('Exit this popup by pressing &lt;Escape&gt;, or clicking on X or on the background.'),
        );

method enable( RakuDoc::Processor:D $rdp ) {
    $rdp.add-data( %!config<name-space>, %!config );
    $rdp.add-templates( self.templates, :source<Edit-in-git plugin>);
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
                        <div class="page-edit">
                            <a class="button page-edit-button tooltip"
                                href="https://github.com/{%sd<repo-name>}/edit/main/{%sd<repo-path>}">
                                <span class="icon">
                                    <i class="fas fa-pen-alt is-medium"></i>
                                </span>
                                <p class="tooltiptext">
                                    <span class="Elucid8-ui" data-UIToken="EditButtonTip">EditButtonTip</span>
                                    $commit-time
                                </p>
                            </a>
                          </div>
                        BLOCK
                    }
                    else  {
                        q:to/NOEDIT/
                        <div class="page-edit">
                            <a class="button page-edit-button tooltip">
                                <span class="icon">
                                    <i class="fas fa-pen-alt is-medium"></i>
                                </span>
                                <p class="tooltiptext">
                                    <span class="Elucid8-ui" data-UIToken="EditButtonTipUnable">EditButtonTipUnable</span>
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
                    <div id="page-edit-info" class="modal">
                        <div class="modal-background"></div>
                        <div class="modal-content">
                            <div class="box">
                                <p><span class="Elucid8-ui" data-UIToken="EditButtonModal">EditButtonModal</span></p>
                                <p><span class="Elucid8-ui" data-UIToken="EditButtonModalOff">EditButtonModalOff</span></p>
                            </div>
                        </div>
                        <button class="modal-close is-large" aria-label="close"></button>
                    </div>
                    BLOCK
                }
                default {''}
            }
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
    SCSS
}
