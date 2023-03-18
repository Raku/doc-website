use v6.d;
sub ($pr, %processed, %options --> Array ) {
    "js-templates.raku".IO.unlink;
    note "deleting js-templates.raku from gather-js-jq" if %options<collection-info>;
    []
}