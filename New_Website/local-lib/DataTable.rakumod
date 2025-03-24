use v6.d;
use RakuDoc::Render;
use JSON::Fast;

unit class Raku-Doc-Website::DataTable;

has %.config =
    :name-space<DataTable>,
	:version<0.1.0>,
	:license<LGPL>,
	:credit<https://github.com/fiduswriter/Simple-DataTables?tab=readme-ov-file>,
	:authors<finanalyst>,
    :scss([self.add-scss,2],),
	:css-link(['href="https://cdn.jsdelivr.net/npm/simple-datatables@latest/dist/style.css"',1],),
	:js-link(['src="https://cdn.jsdelivr.net/npm/simple-datatables@latest"',1],),
	ui-tokens => %(
        :DataTableError<No website data found>,
        :DataTableNoData<No data found for kind: >,
    ),
;
method enable( RakuDoc::Processor:D $rdp ) {
    $rdp.add-data( %!config<name-space>, %!config );
    $rdp.add-templates( self.templates, :source<DataTable plugin>);
}
method templates {
    %(
    DataTable => -> %prm, $tmpl {
        my $rv;
        my %d := $tmpl.globals.data.hash;
        if %d<SiteData>:exists {
            my %sd := %d<SiteData>.hash;
            if %sd<definitions>{ %prm<data> }:exists && %sd<definitions>{ %prm<data> }.elems {
                #| definition is Hash <routine syntax operator> of Hash
                #| each has keys sh-name = Array of Hash
                #| of name, subkind, snip, source(filename), src-ref, targ-in-fn
                my %defns := %sd<definitions>{ %prm<data> }.hash;
                # convert options in DataTable to js options
                # keep RakuDoc metadata
                my %table-options = %prm.pairs
                                        .grep({ .key ~~ / ^ 'dt-' / })
                                        .map({ .key.substr(3) => .value })
                                        .hash;
                my $table-id = '__' ~ %prm<caption> ~ '_Data_Table';
                my $options = JSON::Fast::to-json( %table-options );
                my $js = qq:to/JS/;
                        <script>
                        let dataTable = new simpleDatatables.DataTable("#$table-id", $options);
                        </script>
                    JS
                $rv ~= qq:to/TABLE/;
                        <table id="$table-id" class="elucid8-datatable table is-striped is-bordered is-hoverable">
                        <thead>
                        <tr><th>{ %prm<header1> // 'Type'}\</th><th>{ %prm<header2> // 'Name' }\</th><th>{ %prm<header3> // 'Described in'}\</th>\</tr>
                        </thead>
                        <tbody>
                    TABLE
                $rv ~= %defns.pairs.map({
                    qq:to/LN/
                        <tr><td>{ .value[0]<subkind> }</td>
                            <td>{ .key }</td>
                            <td>{   .value
                                    .map({ '<a href="' ~ .<source> ~ '.html' ~ ( .<targ-in-fn> ?? ('#' ~ .<targ-in-fn> ) !! '' ) ~ '">' ~ .<src-caption> ~ '</a>' })
                                    .join('<br>')
                                }</td>
                        </tr>
                    LN
                });
                $rv ~= "\n</tbody></table>\n$js";
            }
            else {
                $rv ~= qq:to/ERR/;
                <div class="Elucid8-error">
                <span class="Elucid8-ui" data-UIToken="DataTableNoData">DataTableNoData</span>\<span>{ %prm<data> }\</span>
                </div>
                ERR
            }
        }
        else {
            $rv ~= q:to/ERR/;
            <div class="Elucid8-error">
            <span class="Elucid8-ui" data-UIToken="DataTableError">DataTableError</span>
            </div>
            ERR
        }
        $rv
    },
)}
method add-scss {
    q:to/SCSS/;
    /*! DataTable scss extra */
    .elucid8-datatable {
        width: 75%;
    }
    SCSS
}
